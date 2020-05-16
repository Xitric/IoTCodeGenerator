package org.iot.codegenerator.generator.python.board

import com.google.inject.Inject
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.iot.codegenerator.codeGenerator.Board
import org.iot.codegenerator.codeGenerator.ScreenOut
import org.iot.codegenerator.generator.python.GeneratorEnvironment

import static extension org.iot.codegenerator.generator.python.GeneratorUtil.*

class BoardGenerator {

	@Inject CompositionRootGenerator compositionRootGenerator
	@Inject DeviceGenerator deviceGenerator
	@Inject SensorGenerator sensorGenerator

	def compile(Board board, IFileSystemAccess2 fsa) {
		val env = new GeneratorEnvironment()
		fsa.generateFile('''board/composition_root.py''', compositionRootGenerator.compile(board, env))
		fsa.generateFile('''board/«board.name.asModule».py''', deviceGenerator.compile(board))

		if (fsa.isFile("board/main.py")) {
			val mainContents = fsa.readTextFile("board/main.py")
			fsa.generateFile('''board/main.py''', mainContents)
		} else {
			fsa.generateFile('''board/main.py''', compileMain(board))
		}

		board.sensors.forEach [
			fsa.generateFile('''board/«sensortype».py''', sensorGenerator.compile(it))
		]

		"/libfiles/communication.py".compileAsLibfile(fsa)
		"/libfiles/pipeline.py".compileAsLibfile(fsa)
		"/libfiles/thread.py".compileAsLibfile(fsa)

		if (board.usesOled) {
			"/libfiles/ssd1306.py".compileAsLibfile(fsa)
			"/libfiles/LICENSE_ssd1306.txt".compileAsLibfile(fsa)
		}

		for (String libFile : env.libFiles) {
			("/libfiles/" + libFile).compileAsLibfile(fsa)
		}
	}

	def compileAsLibfile(String path, IFileSystemAccess2 fsa) {
		try (val stream = class.getResourceAsStream(path)) {
			val fileName = path.replaceFirst("/libfiles/", "")
			fsa.generateFile('''board/«fileName»''', stream)
		}
	}

	def usesOled(Board board) {
		return !board.eContents.filter(ScreenOut).empty
	}

	def String compileMain(Board board) {
		'''
			from composition_root import CompositionRoot
			
			class CustomCompositionRoot(CompositionRoot):
				# This file will not be overwritten by the IoT code generator.
				# 
				# To adapt the generated code, override the methods from CompositionRoot
				# inside this class, for instance:
				# 
				# def provide_«board.name.asModule»(self):
				#     board = super().provide_«board.name.asModule»()
				#     board.add_sensor(...)
				«IF board.input !== null»
					#     board.set_input_channel(...)
				«ENDIF»
				#     board.add_output_channel(...)
				pass
			
			CustomCompositionRoot().provide_«board.name.asModule»().run()
		'''
	}
}
