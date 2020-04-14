package org.iot.codegenerator.generator.python.board

import org.iot.codegenerator.codeGenerator.Board

import static extension org.iot.codegenerator.generator.python.GeneratorUtil.*

class DeviceGenerator {
	
	def String compile(Board board) {
		'''
		class «board.name.asClass»:
			# Coming soon to a city near you :)
			pass
		'''
	}
}