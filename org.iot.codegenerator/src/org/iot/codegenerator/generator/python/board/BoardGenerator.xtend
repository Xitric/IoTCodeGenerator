package org.iot.codegenerator.generator.python.board

import org.eclipse.xtext.generator.IFileSystemAccess2
import org.iot.codegenerator.codeGenerator.Board

class BoardGenerator {

	def compile(Board board, IFileSystemAccess2 fsa) {
		val compositionRootGenerator = new CompositionRootGenerator()
		fsa.generateFile("board/composition_root.py", compositionRootGenerator.compile(board))

		val sensorGenerator = new SensorGenerator()
		board.sensors.forEach [
			fsa.generateFile('''board/«type».py''', sensorGenerator.compile(it))
		]
	}
}