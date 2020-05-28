package org.iot.codegenerator.typing

import org.iot.codegenerator.codeGenerator.Map
import org.iot.codegenerator.codeGenerator.Reference
import org.iot.codegenerator.codeGenerator.Sensor
import org.iot.codegenerator.codeGenerator.Variable
import org.iot.codegenerator.typing.TypeChecker.Type

import static extension org.eclipse.xtext.EcoreUtil2.*

class ReferenceTypeProvider {

	def typeOf(Reference ref, TypeChecker typeChecker) {
		val variable = ref.variable

		val map = variable.getContainerOfType(Map)
		if (map !== null) {
			return variable.getMapType(map, typeChecker)
		}

		val baseSensor = variable.getContainerOfType(Sensor)
		if (baseSensor !== null) {
			return getBaseSensorType()
		}

		getFallbackType()
	}

	private def getMapType(Variable variable, Map map, extension TypeChecker typeChecker) {
		map.expression.type
	}

	private def getBaseSensorType() {
		Type.INT
	}

	private def getFallbackType() {
		Type.INVALID
	}
}
