package org.iot.codegenerator.generator.python

import com.google.inject.Inject
import org.iot.codegenerator.codeGenerator.And
import org.iot.codegenerator.codeGenerator.BooleanLiteral
import org.iot.codegenerator.codeGenerator.Conditional
import org.iot.codegenerator.codeGenerator.Div
import org.iot.codegenerator.codeGenerator.Equal
import org.iot.codegenerator.codeGenerator.Exponent
import org.iot.codegenerator.codeGenerator.GreaterThan
import org.iot.codegenerator.codeGenerator.GreaterThanEqual
import org.iot.codegenerator.codeGenerator.LessThan
import org.iot.codegenerator.codeGenerator.LessThanEqual
import org.iot.codegenerator.codeGenerator.Minus
import org.iot.codegenerator.codeGenerator.Mul
import org.iot.codegenerator.codeGenerator.Negation
import org.iot.codegenerator.codeGenerator.Not
import org.iot.codegenerator.codeGenerator.NumberLiteral
import org.iot.codegenerator.codeGenerator.Or
import org.iot.codegenerator.codeGenerator.Plus
import org.iot.codegenerator.codeGenerator.Reference
import org.iot.codegenerator.codeGenerator.Sensor
import org.iot.codegenerator.codeGenerator.StringLiteral
import org.iot.codegenerator.codeGenerator.Unequal
import org.iot.codegenerator.typing.TypeChecker
import org.iot.codegenerator.typing.TypeChecker.Type

import static extension org.eclipse.xtext.EcoreUtil2.*
import static extension org.iot.codegenerator.generator.python.GeneratorUtil.*

class ExpressionGenerator {

	@Inject
	extension TypeChecker

	def dispatch String compile(Conditional conditional) {
		'''(«conditional.correct.compile» if «conditional.condition.compile» else «conditional.incorrect.compile»)'''
	}

	def dispatch String compile(Or or) {
		'''(«or.left.compile» or «or.right.compile»)'''
	}

	def dispatch String compile(And and) {
		'''(«and.left.compile» and «and.right.compile»)'''
	}

	def dispatch String compile(Equal equal) {
		'''(«equal.left.compile» == «equal.right.compile»)'''
	}

	def dispatch String compile(Unequal unequal) {
		'''(«unequal.left.compile» != «unequal.right.compile»)'''
	}

	def dispatch String compile(LessThan lessThan) {
		'''(«lessThan.left.compile» < «lessThan.right.compile»)'''
	}

	def dispatch String compile(LessThanEqual lessThanEqual) {
		'''(«lessThanEqual.left.compile» <= «lessThanEqual.right.compile»)'''
	}

	def dispatch String compile(GreaterThan greaterThan) {
		'''(«greaterThan.left.compile» > «greaterThan.right.compile»)'''
	}

	def dispatch String compile(GreaterThanEqual greaterThanEqual) {
		'''(«greaterThanEqual.left.compile» >= «greaterThanEqual.right.compile»)'''
	}

	def dispatch String compile(Plus exp) {
		val wrapLeft = exp.left.type === Type.STRING
		val wrapRight = exp.right.type === Type.STRING
		
		val left = '''«IF wrapLeft»str(«exp.left.compile»)«ELSE»«exp.left.compile»«ENDIF»'''
		val right = '''«IF wrapRight»str(«exp.right.compile»)«ELSE»«exp.right.compile»«ENDIF»'''
		
		'''(«left» + «right»)'''
	}

	def dispatch String compile(Minus minus) {
		'''(«minus.left.compile» - «minus.right.compile»)'''
	}

	def dispatch String compile(Mul mul) {
		'''(«mul.left.compile» * «mul.right.compile»)'''
	}

	def dispatch String compile(Div div) {
		'''(«div.left.compile» / «div.right.compile»)'''
	}

	def dispatch String compile(Negation negation) {
		'''(-«negation.value.compile»)'''
	}

	def dispatch String compile(Exponent exponent) {
		'''(«exponent.base.compile» ** «exponent.power.compile»)'''
	}

	def dispatch String compile(Not not) {
		'''(not «not.value.compile»)'''
	}

	def dispatch String compile(NumberLiteral numberLiteral) {
		'''(«numberLiteral.value»)'''
	}

	def dispatch String compile(BooleanLiteral booleanLiteral) {
		'''(«booleanLiteral.value.booleanValue.toString.toFirstUpper»)'''
	}

	def dispatch String compile(Reference reference) {
		val sensor = reference.getContainerOfType(Sensor)
		val variableName = sensor.variables.name
		'''(«variableName.asInstance».«reference.variable.name»)'''
	}

	def dispatch String compile(StringLiteral stringLiteral) {
		'''("«stringLiteral.value»")'''
	}
}
