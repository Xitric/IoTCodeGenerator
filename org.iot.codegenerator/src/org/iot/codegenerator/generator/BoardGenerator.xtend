package org.iot.codegenerator.generator

import org.eclipse.xtext.generator.IFileSystemAccess2
import org.iot.codegenerator.codeGenerator.Board
import org.iot.codegenerator.codeGenerator.FrequencySampler
import org.iot.codegenerator.codeGenerator.Sensor
import org.iot.codegenerator.codeGenerator.SignalSampler

//import static extension org.eclipse.emf.ecore.util.EcoreUtil.*
//import static extension org.eclipse.xtext.EcoreUtil2.*
class BoardGenerator {

	def compile(Board board, IFileSystemAccess2 fsa) {
		fsa.generateFile("board/main.py", board.compileMain)

		board.sensors.forEach [
			fsa.generateFile('''board/«name».py''', compile)
		]
	}

	def String compileMain(Board board) {
		'''
			import thread
			import utime
			import sys
			«board.compileSensorImports»
			
			«board.compileSensorInstantiations»
			
			«compileCommLoops»
			
			«board.compileThreads»
		'''
	}

	def String compileSensorImports(Board board) {
		'''
			«FOR sensor : board.sensors»
				from «sensor.name» import «sensor.className»
			«ENDFOR»
		'''
	}

	def String compileSensorInstantiations(Board board) {
		'''
			sensors = {
				«FOR sensor : board.sensors SEPARATOR ","»
					"«sensor.name»": «sensor.className()»
			«ENDFOR»
			}
		'''
	}

	def String compileCommLoops() {
		'''
			def send_loop(thread: thread.Thread):
			    for _ in range(10):
			        print("Send")
			        utime.sleep(1)
			        if not thread.active:
			            break
			
			def receive_loop(thread: thread.Thread):
			    while thread.active:
			        command = sys.stdin.readline().replace("\r", "").replace("\n", "")
			        print("Received: " + command)
			        elements = command.split(":")
			        sensor = sensors[elements[0]]
			        sensor.signal(elements[1])
		'''
	}

	def String compileThreads(Board board) {
		val frequencySensors = board.sensors.filter[isFrequency]

		'''
			send_thread = thread.Thread(send_loop, "ThreadSend")
			send_thread.start()
			receive_thread = thread.Thread(receive_loop, "ThreadReceive")
			receive_thread.start()
			
			«FOR sensor : frequencySensors»
				«sensor.name»_thread = sensors["«sensor.name»"].thread
			«ENDFOR»
			
			thread.join([
				send_thread,
				receive_thread«IF !frequencySensors.empty»,«ENDIF»
				«FOR sensor : frequencySensors SEPARATOR ","»
					«sensor.name»_thread
				«ENDFOR»
			])
		'''
	}

	def String compile(Sensor sensor) {
		'''
			import thread
			«IF sensor.isFrequency»import utime«ENDIF»
			
			class «sensor.className»:
				«IF sensor.isFrequency»
					«sensor.compileFrequencyThread»
				«ENDIF»
				
				«sensor.compileSignalHandler»
				
				«sensor.compileSamplers»
		'''
	}

	def String compileFrequencyThread(Sensor sensor) {
		'''
			def __init__(self):
				self.thread = thread.Thread(self.__timer, "Thread«sensor.className»")
				self.thread.start()
			
			def __timer(self, thread: thread.Thread):
				while thread.active:
					utime.sleep(«(sensor.sampler as FrequencySampler).delay»)
					«sensor.compileSamplerCalls»
		'''
	}

	def String compileSignalHandler(Sensor sensor) {
		'''
			def signal(self, command: str):
				if command == "kill":
				    self.thread.interrupt()
				«IF sensor.isSignal»
					elif command == "signal":
						«sensor.compileSamplerCalls»
				«ENDIF»
		'''
	}

	def String compileSamplerCalls(Sensor sensor) {
		var counter = 1

		'''
			«FOR data : sensor.datas»
				self.__sample_«counter++»()
			«ENDFOR»
		'''
	}
	
	def String compileSamplers(Sensor sensor) {
		var counter = 1
		
		//TODO: Sample sensors, perform pipeline, etc.
		'''
		«FOR data : sensor.datas»
		def __sample_«counter++»(self):
			print("Sample «counter - 1»")
		«ENDFOR»
		'''
	}

	/*
	 * Utility extension methods
	 */
	def boolean isFrequency(Sensor sensor) {
		sensor.sampler instanceof FrequencySampler
	}

	def boolean isSignal(Sensor sensor) {
		sensor.sampler instanceof SignalSampler
	}

	def String className(Sensor sensor) {
		sensor.name.toFirstUpper
	}
}
