package org.iot.codegenerator.generator.python.board

import org.eclipse.xtext.generator.IFileSystemAccess2
import org.iot.codegenerator.codeGenerator.Board
import com.google.inject.Inject

import static extension org.iot.codegenerator.generator.python.GeneratorUtil.*

class BoardGenerator {

	@Inject CompositionRootGenerator compositionRootGenerator
	@Inject DeviceGenerator deviceGenerator
	@Inject SensorGenerator sensorGenerator

	def compile(Board board, IFileSystemAccess2 fsa) {
		fsa.generateFile('''board/composition_root.py''', compositionRootGenerator.compile(board))
		fsa.generateFile('''board/«board.name.asModule».py''', deviceGenerator.compile(board))

		board.sensors.forEach [
			fsa.generateFile('''board/«sensortype».py''', sensorGenerator.compile(it))
		]
		
		"/libfiles/communication.py".compileAsLibfile(fsa)
		"/libfiles/pipeline.py".compileAsLibfile(fsa)
		"/libfiles/thread.py".compileAsLibfile(fsa)
	}
	
	def compileAsLibfile(String path, IFileSystemAccess2 fsa) {
		try (val stream = this.class.getResourceAsStream(path)) {
			val fileName = fsa.getURI(path).deresolve(fsa.getURI("libfiles/"))
			fsa.generateFile('''board/«fileName.path»''', stream)
		}
	}
}
