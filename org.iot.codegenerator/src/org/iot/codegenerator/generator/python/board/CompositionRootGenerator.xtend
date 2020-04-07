package org.iot.codegenerator.generator.python.board

import org.eclipse.emf.ecore.EObject
import org.iot.codegenerator.codeGenerator.Board
import org.iot.codegenerator.codeGenerator.Channel
import org.iot.codegenerator.codeGenerator.ChannelOut
import org.iot.codegenerator.codeGenerator.Filter
import org.iot.codegenerator.codeGenerator.Map
import org.iot.codegenerator.codeGenerator.Pipeline
import org.iot.codegenerator.codeGenerator.ScreenOut
import org.iot.codegenerator.codeGenerator.Sensor
import org.iot.codegenerator.codeGenerator.SensorData
import org.iot.codegenerator.codeGenerator.SensorDataOut
import org.iot.codegenerator.codeGenerator.TransformationOut
import org.iot.codegenerator.codeGenerator.Window
import org.iot.codegenerator.generator.python.GeneratorEnvironment

import static extension org.eclipse.xtext.EcoreUtil2.*
import static extension org.iot.codegenerator.generator.python.GeneratorUtil.*
import static extension org.iot.codegenerator.generator.python.GeneratorEnvironment.*

class CompositionRootGenerator {

	def String compile(Board board) {
		val env = new GeneratorEnvironment()
		val classDef = board.compileClass(env)

		'''
			«FOR module : env.definitionImports»
				from «module» import «FOR definition : env.getDefinitionsFor(module) SEPARATOR ", "»«definition»«ENDFOR»
			«ENDFOR»
			«FOR module : env.moduleImports»
				«module.asSafeImport»
			«ENDFOR»
			
			«classDef»
		'''
	}

	private def String compileClass(Board board, GeneratorEnvironment env) {
		val sensorProviders = board.compileSensorProviders(env)
		val pipelineProviders = board.compilePipelineProviders(env)
		val boardProvider = board.compileBoardProvider(env)

		'''
			class CompositionRoot:
				«board.compileConstructor(env)»
				«boardProvider»
				«sensorProviders»
				«pipelineProviders»
				«board.compileChannelProviders(env)»
				«compileMakeChannel(env)»
		'''
	}

	private def String compileConstructor(Board board, GeneratorEnvironment env) {
		env.useImport("ujson")

		'''
			def __init__(self):
				«FOR channel : env.channels»
					self.«channel.name.asInstance» = None
				«ENDFOR»
				
				with open("conf-filled.json", "r") as _conf_file:
					self.configuration = ujson.loads("".join(_conf_file.readlines()))
			
		'''
	}

	private def String compileBoardProvider(Board board, GeneratorEnvironment env) {
		'''
			def «board.providerName»(self):
				«board.name.asInstance» = «env.useImport(board.name.asModule, board.name.asClass)»()
				«FOR sensor : board.sensors»
					«board.name.asInstance».add_sensor("«sensor.name.asModule»", self.«sensor.providerName»())
				«ENDFOR»
				«board.name.asInstance».set_input_channel(self.«env.useChannel(board.input).providerName»())
				«FOR channel : env.channels.filter[it != board.input]»
					«board.name.asInstance».add_output_channel(self.«channel.providerName»())
				«ENDFOR»
			
		'''
	}

	private def String compileSensorProviders(Board board, GeneratorEnvironment env) {
		'''
			«FOR sensor : board.sensors»
				def «sensor.providerName»(self):
					«sensor.name.asInstance» = «env.useImport(sensor.name.asModule)».«sensor.name.asClass»(self.provide_driver_)  # TODO: Cannot determine driver yet
					«FOR data : sensor.sensorDatas»
						«FOR out : data.outputs»
							«sensor.name.asInstance».add_pipeline("«data.name.asModule»", self.«out.providerName»())
						«ENDFOR»
					«ENDFOR»
					return «sensor.name.asInstance»
				
			«ENDFOR»
		'''
	}

	// TODO: Driver provider
	private def String compilePipelineProviders(Board board, GeneratorEnvironment env) {
		'''
			«FOR sensor : board.sensors»
				«FOR data : sensor.sensorDatas»
					«FOR out : data.outputs»
						«out.compilePipelineProvider(env)»
						
					«ENDFOR»
				«ENDFOR»
			«ENDFOR»
		'''
	}

	private def dispatch String compilePipelineProvider(ChannelOut out, GeneratorEnvironment env) {
		env.useImport("pipeline", "Pipeline")
		env.useImport("struct")

		val sink = '''
		type('Sink', (object,), {
			"handle": lambda data: «out.channel.name.asInstance».send(struct.pack("f", data)),  #TODO: Handle data type conversion
			"next": None
		})'''

		'''
			def «out.providerName»(self):
				«env.useChannel(out.channel).name.asInstance» = self.«out.channel.providerName»()
				return Pipeline(
					«out.pipeline.compilePipelineComposition(sink, env)»
				)
		'''
	}

	private def String compilePipelineComposition(Pipeline pipeline, String sink, GeneratorEnvironment env) {
		val inner = pipeline.next === null ? sink : pipeline.next.compilePipelineComposition(sink, env)
		val sensorName = pipeline.getContainerOfType(Sensor).name
		val interceptorName = pipeline.interceptorName
		
		'''
		«env.useImport(sensorName.asModule)».«interceptorName»(
			«inner»
		)
		'''
	}

	private def dispatch String compilePipelineProvider(ScreenOut out, GeneratorEnvironment env) {
		'''
			def «out.providerName»(self):
				# TODO: Unsupported
				return None
		'''
	}

	private def String compileChannelProviders(Board board, GeneratorEnvironment env) {
		'''
			«FOR channel : env.channels»
				def «channel.providerName»(self):
					if not self.«channel.name.asInstance»:
						self.«channel.name.asInstance» = self.make_channel("«channel.name»")
					return self.«channel.name.asInstance»
				
			«ENDFOR»
		'''
	}

	private def String compileMakeChannel(GeneratorEnvironment env) {
		env.useImport("communication", "Serial")
		env.useImport("communication", "Wifi")

		'''
			def make_channel(self, identifier: str):
				if self.configuration[identifier]["type"] == "serial":
					return Serial(self.configuration["serial"]["baud"],
								  self.configuration["serial"]["databits"],
								  self.configuration["serial"]["paritybits"],
								  self.configuration["serial"]["stopbit"])
				
				elif self.configuration[identifier]["type"] == "wifi":
					return Wifi(self.configuration[identifier]["lane"], 
								self.configuration["wifi"]["ssid"],
								self.configuration["wifi"]["password"])
		'''
	}

	/*
	 * Utility extension methods
	 */
	private def String providerName(Board board) {
		'''provide_«board.name.asModule»'''
	}

	private def String providerName(Sensor sensor) {
		'''provide_sensor_«sensor.name.asModule»'''
	}

	private def String providerName(Channel channel) {
		'''provide_channel_«channel.name.asModule»'''
	}

	private def String providerName(SensorDataOut out) {
		val sensor = out.getContainerOfType(Sensor)
		val data = out.getContainerOfType(SensorData)
		val index = data.outputs.takeWhile [
			it != out
		].size + 1

		'''provide_pipeline_«sensor.name.asModule»_«data.name.asModule»_«index»'''
	}

	private def String interceptorName(Pipeline pipeline) {
		val type = switch (pipeline) {
			Filter: "Filter"
			Map: "Map"
			Window: "Window"
		}

		val sensor = pipeline.getContainerOfType(Sensor)
		val index = sensor.eAllContents.filter [
			it.class == pipeline.class
		].takeWhile [
			it != pipeline
		].size + 1

		'''Interceptor«type»«index»'''
	}
}
