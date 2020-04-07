package org.iot.codegenerator.typing

import org.iot.codegenerator.codeGenerator.BooleanLiteral
import org.iot.codegenerator.codeGenerator.Conditional
import org.iot.codegenerator.codeGenerator.Div
import org.iot.codegenerator.codeGenerator.Exponent
import org.iot.codegenerator.codeGenerator.Expression
import org.iot.codegenerator.codeGenerator.Minus
import org.iot.codegenerator.codeGenerator.Mul
import org.iot.codegenerator.codeGenerator.Negation
import org.iot.codegenerator.codeGenerator.NumberLiteral
import org.iot.codegenerator.codeGenerator.Plus
import org.iot.codegenerator.codeGenerator.Reference
import org.iot.codegenerator.codeGenerator.StringLiteral
import org.iot.codegenerator.codeGenerator.DataOut
import org.iot.codegenerator.codeGenerator.TuplePipeline
import org.iot.codegenerator.codeGenerator.Map
import org.eclipse.xtext.util.IResourceScopeCache
import com.google.inject.Inject
import org.iot.codegenerator.codeGenerator.Source
import org.iot.codegenerator.codeGenerator.VarID
import org.eclipse.xtext.util.OnChangeEvictingCache
import org.iot.codegenerator.codeGenerator.Pipeline

class TypeChecker {

	@Inject OnChangeEvictingCache cache

	enum Type {
		INT,
		DOUBLE,
		BOOLEAN,
		STRING,
		INVALID,
		VARS,
		PIPELINE,
		DATAOUT
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

	def dispatch Type type(StringLiteral str) {
		Type.STRING
	}

	def dispatch Type type(BooleanLiteral bool) {
		Type.BOOLEAN
	}

	def dispatch Type type(Expression expression) {
		Type.BOOLEAN
	}
	
	def dispatch Type type(Conditional conditional) {
		val correctType = conditional.correct.type
		val incorrectType = conditional.incorrect.type
		val numberType = evaluateNumeralTypes(correctType, incorrectType)

		if (numberType == Type.INVALID) {
			if (correctType == incorrectType) {
				correctType
			} else {
				Type.INVALID
			}
		} else {
			numberType
		}
	}

	def isNumberType(Type type) {
		return type == Type.INT || type == Type.DOUBLE
	}

	def evaluateNumeralTypes(Type type1, Type type2) {
		if (! (type1.isNumberType && type2.isNumberType)) {
			Type.INVALID
		} else if (type1 == Type.DOUBLE || type2 == Type.DOUBLE) {
			Type.DOUBLE
		} else {
			Type.INT
		}
	}

	def dispatch Type type(Source source) {
		Type.VARS
	}
	
	def dispatch Type type(Pipeline pipeline){
		if (pipeline instanceof Map) {
			val mapPipeline = (pipeline as Map)
			cache.getOrCreate(mapPipeline.eResource).set(mapPipeline.output.name, mapPipeline.expression.type)	
		}
		Type.PIPELINE
	}
	
	def dispatch Type type(DataOut dataOut) {
		for (VarID varId : dataOut.source.vars.ids){
			cache.getOrCreate(varId.eResource).set(varId.name, Type.INT)
		}
		Type.DATAOUT
	}

	def dispatch Type type(Plus plus) {
		if (plus.left.type == Type.STRING || plus.right.type == Type.STRING) {
			Type.STRING
		} else {
			evaluateNumeralTypes(plus.left.type, plus.right.type)
		}
	}

	def dispatch Type type(Minus minus) {
		evaluateNumeralTypes(minus.left.type, minus.right.type)
	}

	def dispatch Type type(Mul multiply) {
		evaluateNumeralTypes(multiply.left.type, multiply.right.type)
	}

	def dispatch Type type(Div division) {
		evaluateNumeralTypes(division.left.type, division.right.type)
	}

	def dispatch Type type(Negation negation) {
		if (! negation.value.type.isNumberType) {
			Type.INVALID
		} else {
			negation.value.type
		}
	}

	def dispatch Type type(Exponent exponent) {
		if (evaluateNumeralTypes(exponent.base.type, exponent.power.type) == Type.INVALID) {
			Type.INVALID
		} else {
			Type.DOUBLE
		}
	}

	def dispatch Type type(Reference reference) {
		val cached = cache.get(reference.varid.name, reference.eResource, [Type.INVALID])
		return cached
	}
}
