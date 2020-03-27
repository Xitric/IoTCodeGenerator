package org.iot.codegenerator.typing

import org.iot.codegenerator.codeGenerator.BooleanLiteral
import org.iot.codegenerator.codeGenerator.Conditional
import org.iot.codegenerator.codeGenerator.Div
import org.iot.codegenerator.codeGenerator.Exponent
import org.iot.codegenerator.codeGenerator.Expression
import org.iot.codegenerator.codeGenerator.Minus
import org.iot.codegenerator.codeGenerator.Mul
import org.iot.codegenerator.codeGenerator.Negation
import org.iot.codegenerator.codeGenerator.Not
import org.iot.codegenerator.codeGenerator.NumberLiteral
import org.iot.codegenerator.codeGenerator.Plus
import org.iot.codegenerator.codeGenerator.Reference

class TypeChecker {

	enum Type {
		INT,
		DOUBLE,
		BOOLEAN,
		STRING,
		INVALID
	}

	def dispatch Type type(NumberLiteral number) {
		val value = number.value
		switch (value) {
			case value.contains('.'):
				Type.DOUBLE
			case value.contains('0x'):
				Type.INT
			case value.toLowerCase.contains('e'):
				Type.DOUBLE
			default:
				Type.INT
		}
	}

	def dispatch Type type(BooleanLiteral bool) {
		Type.BOOLEAN
	}

	def dispatch Type type(Expression expression) {
		Type.BOOLEAN
	}

	def dispatch Type type(Conditional conditional) {
		conditional.correct.type

	}

	def evaluateNumeralTypes(Type type1, Type type2) {
		if (type1 == Type.INT && type2 == Type.INT) {
			return Type.INT
		} else if (type1 == Type.DOUBLE && type2 == Type.DOUBLE) {
			return Type.DOUBLE
		} else if (type1 == Type.STRING && type2 == Type.STRING) {
			return Type.STRING
		} else if ((type1 == Type.STRING && type2 != type1) || (type2 == Type.STRING && type2 != type1)) {
			return Type.INVALID
		} else if (type1 == Type.DOUBLE || type2 == Type.DOUBLE) {
			return Type.DOUBLE
		} 
		Type.INVALID
	}

	def dispatch Type type(Plus plus) {
	}

	def dispatch Type type(Minus minus) {
	}

	def dispatch Type type(Mul multiply) {
	}

	def dispatch Type type(Div division) {
	}

	def dispatch Type type(Negation negation) {
	}

	def dispatch Type type(Exponent exponent) {
	}

	def dispatch Type type(Reference reference) {
	}

	def dispatch Type type(Not not) {
	}

}
