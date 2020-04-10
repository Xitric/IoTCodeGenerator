/*
 * generated by Xtext 2.20.0
 */
package org.iot.codegenerator.validation

import com.google.common.collect.Sets
import com.google.inject.Inject
import java.util.ArrayList
import java.util.Arrays
import java.util.HashMap
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtext.validation.Check
import org.iot.codegenerator.codeGenerator.And
import org.iot.codegenerator.codeGenerator.Board
import org.iot.codegenerator.codeGenerator.CodeGeneratorPackage
import org.iot.codegenerator.codeGenerator.Conditional
import org.iot.codegenerator.codeGenerator.Data
import org.iot.codegenerator.codeGenerator.DeviceConf
import org.iot.codegenerator.codeGenerator.Div
import org.iot.codegenerator.codeGenerator.Equal
import org.iot.codegenerator.codeGenerator.Exponent
import org.iot.codegenerator.codeGenerator.Filter
import org.iot.codegenerator.codeGenerator.GreaterThan
import org.iot.codegenerator.codeGenerator.GreaterThanEqual
import org.iot.codegenerator.codeGenerator.Language
import org.iot.codegenerator.codeGenerator.LessThan
import org.iot.codegenerator.codeGenerator.LessThanEqual
import org.iot.codegenerator.codeGenerator.Minus
import org.iot.codegenerator.codeGenerator.Mul
import org.iot.codegenerator.codeGenerator.Negation
import org.iot.codegenerator.codeGenerator.Not
import org.iot.codegenerator.codeGenerator.Or
import org.iot.codegenerator.codeGenerator.Plus
import org.iot.codegenerator.codeGenerator.Sensor
import org.iot.codegenerator.codeGenerator.Transformation
import org.iot.codegenerator.codeGenerator.Unequal
import org.iot.codegenerator.typing.TypeChecker
import java.util.List
import org.iot.codegenerator.codeGenerator.Variable
import org.iot.codegenerator.codeGenerator.Variables
import org.iot.codegenerator.codeGenerator.Provider

/**
 * This class contains custom validation rules. 
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class CodeGeneratorValidator extends AbstractCodeGeneratorValidator {

	public static val INCORRECT_INPUT_TYPE_PIN = "org.iot.codegenerator.IncorrectInputTypePin"
	public static val INCORRECT_INPUT_TYPE_I2C = "org.iot.codegenerator.IncorrectInputTypeI2c"

	@Inject
	extension TypeChecker

	@Check
	def checkDeviceConfiguration(DeviceConf configuration) {
		val boards = configuration.board

		if (boards.size() < 1) {
			warning('''there should be a board definition''', CodeGeneratorPackage.eINSTANCE.deviceConf_Board)
			return
		} else if (boards.size() > 1) {
			error('''there must be exactly 1 board definition''', CodeGeneratorPackage.eINSTANCE.deviceConf_Board)
			return
		}

		val clouds = configuration.cloud

		if (clouds.size() < 1) {
			warning('''there should be a cloud definition''', CodeGeneratorPackage.eINSTANCE.deviceConf_Cloud)
			return
		} else if (clouds.size() > 1) {
			error('''there must be exactly 1 cloud definition''', CodeGeneratorPackage.eINSTANCE.deviceConf_Cloud)
			return
		}

		val fogs = configuration.fog

		if (fogs.size() > 1) {
			error('''there must at maximum be 1 fog definition''', CodeGeneratorPackage.eINSTANCE.deviceConf_Fog)
			return
		}
	}

	@Check
	def validateBoard(Board board) {
		val b = UtilityBoard.getBoard(board.name, board.version)
		if (b === null) {
			error('''unsupported board type''', CodeGeneratorPackage.eINSTANCE.board_Name)
		} else {
			info('''«b.getVersion()» supports the following sensors: «b.getSensors()»''',
				CodeGeneratorPackage.eINSTANCE.board_Name)
		}
	}

// TODO: Fixme	
//	@Check
//	def validatePinsMatchesVars(Pin pin){
//		if (pin.ids.size() < pin.vars.ids.size()){
//			error('''exprects �pin.vars.ids.size()� pin inputs, got �pin.ids.size()�''', CodeGeneratorPackage.eINSTANCE.pin_Ids)
//		} else if (pin.ids.size() > pin.vars.ids.size()){
//			info('''number of pin inputs shuld match number of variables after "as"''', CodeGeneratorPackage.eINSTANCE.pin_Ids)
//		}	
//	} 
//	@Check
//	def validatePinsMatchesVars(Variables variables){
//		val sensor = variables.getContainerOfType(Sensor)
//		switch(sensor) {
//			ExtSensor:
//				if (sensor.pins.size() < variables.ids.size()) {
//					error('''expected �sensor.pins.size()� pin inputs, got �variables.ids.size()�''', CodeGeneratorPackage.eINSTANCE.variables_Ids)
//				} else if (sensor.pins.size() > variables.ids.size()) {
//					warning('''number of pin inputs shuld match number of variables after "as"''', CodeGeneratorPackage.eINSTANCE.variables_Ids)					
//				}
//			OnbSensor:
//				//TODO: Check keyword expectations
//		}
//	}
	@Check
	def validateLanguage(Language lang) {
		var approved = Arrays.asList("python", "cplusplus")
		if (!approved.contains(lang.name)) {
			error('''no support for language «lang.name», only "python" and "cplusplus"''',
				CodeGeneratorPackage.eINSTANCE.language_Name)
		} else {
			info('''generator supports "python" and "cplusplus"''', CodeGeneratorPackage.eINSTANCE.language_Name)
		}
	}

// TODO: Fixme	
//	@Check
//	def validateSource(Data data) {
//	switch (data.eContainer) {
//		ExtSensor case data.input instanceof I2C:
//			error('''expected pin got i2c''', CodeGeneratorPackage.Literals.OUTPUT_DEFINITION__INPUT, INCORRECT_INPUT_TYPE_I2C)
//		OnbSensor case data.input instanceof Pin:
//			error('''expected i2c got pin''', CodeGeneratorPackage.Literals.OUTPUT_DEFINITION__INPUT, INCORRECT_INPUT_TYPE_PIN)
//	}

	def checkNoDuplicateDataName(List<Data> datas) {
		val dataNameValues = new HashMap<String, Set<Data>>

		for (data : datas) {
			val name = data.name
			if (dataNameValues.containsKey(name)) {
				dataNameValues.get(name).add(data)
			} else {
				dataNameValues.put(name, Sets.newHashSet(data))
			}
		}

		for (Set<Data> dataSet : dataNameValues.values) {
			if (dataSet.size > 1) {
				for (data : dataSet) {
					error('''duplicate '«data.name»' ''', data, CodeGeneratorPackage.eINSTANCE.data_Name)
				}
			}
		}
	}

	@Check
	def validateData(Data data) {
		var datas = new ArrayList<Data>
		for (EObject eObject : data.eResource.getContents()) {
			if (eObject instanceof DeviceConf) {
				val deviceConf = eObject as DeviceConf
				val board = deviceConf.board
				val cloud = deviceConf.cloud
				val fog = deviceConf.fog

				if (board.size > 0) {
					for (Sensor sensor : board.get(0).sensors) {
						datas.addAll(sensor.datas)
					}
				}

				if (cloud.size > 0) {
					for (Transformation transformation : cloud.get(0).transformations) {
						datas.addAll(transformation.datas)
					}
				}

				if (fog.size > 0) {
					for (Transformation transformation : fog.get(0).transformations) {
						datas.addAll(transformation.datas)
					}
				}

				checkNoDuplicateDataName(datas)
				return
			}
		}
	}
	
	
	def checkNoDuplicateVariableNamesInStatement(List<Variable> variables) {
		val variableNameValues = new HashMap<String, Set<Variable>>

		for (variable : variables) {
			val name = variable.name
			if (variableNameValues.containsKey(name)) {
				variableNameValues.get(name).add(variable)
			} else {
				variableNameValues.put(name, Sets.newHashSet(variable))
			}
		}

		for (Set<Variable> variableSet : variableNameValues.values) {
			if (variableSet.size > 1) {
				for (variable : variableSet) {
					error('''duplicate '«variable.name»' ''', variable, CodeGeneratorPackage.eINSTANCE.variable_Name)
				}
			}
		}
	}
	
	@Check
	def validateVariable(Variables variables){	
		val eContainer = variables.eContainer
		if (eContainer instanceof Provider){
			val provider = eContainer as Provider
			checkNoDuplicateVariableNamesInStatement(provider.variables.ids)
		}
	}

	@Check
	def validateFilterExpression(Filter filter) {
		filter.expression.type.validateTypes(TypeChecker.Type.BOOLEAN,
			CodeGeneratorPackage.Literals.TUPLE_PIPELINE__EXPRESSION)
	}

	def validateTypes(TypeChecker.Type actual, TypeChecker.Type expected, EStructuralFeature error) {
		if (expected != actual) {
			error('''expected �expected� got �actual�''', error)
		}
	}

	def validateNumbers(TypeChecker.Type type, EStructuralFeature error) {
		if (!type.isNumberType) {
			error('''expected number got �type�''', error)
		}
	}

	@Check
	def checkExpression(Conditional conditional) {
		conditional.condition.type.validateTypes(TypeChecker.Type.BOOLEAN,
			CodeGeneratorPackage.Literals.CONDITIONAL__CONDITION)
		conditional.incorrect.type.validateTypes(conditional.correct.type,
			CodeGeneratorPackage.Literals.CONDITIONAL__INCORRECT)
	}

	@Check
	def checkExpression(Or or) {
		or.left.type.validateTypes(TypeChecker.Type.BOOLEAN, CodeGeneratorPackage.Literals.OR__LEFT)
		or.right.type.validateTypes(TypeChecker.Type.BOOLEAN, CodeGeneratorPackage.Literals.OR__RIGHT)
	}

	@Check
	def checkExpression(And and) {
		and.left.type.validateTypes(TypeChecker.Type.BOOLEAN, CodeGeneratorPackage.Literals.AND__LEFT)
		and.right.type.validateTypes(TypeChecker.Type.BOOLEAN, CodeGeneratorPackage.Literals.AND__RIGHT)
	}

	@Check
	def checkExpression(Equal equal) {
		if (!equal.left.type.isNumberType || !equal.right.type.isNumberType) {
			equal.right.type.validateTypes(equal.left.type, CodeGeneratorPackage.Literals.EQUAL__RIGHT)
		}
	}

	@Check
	def checkExpression(Unequal unequal) {
		if (!unequal.left.type.isNumberType || !unequal.right.type.isNumberType) {
			unequal.right.type.validateTypes(unequal.left.type, CodeGeneratorPackage.Literals.UNEQUAL__RIGHT)
		}
	}

	@Check
	def checkExpression(LessThan lessThan) {
		lessThan.left.type.validateNumbers(CodeGeneratorPackage.Literals.LESS_THAN__LEFT)
		lessThan.right.type.validateNumbers(CodeGeneratorPackage.Literals.LESS_THAN__RIGHT)
	}

	@Check
	def checkExpression(LessThanEqual lessThanEqual) {
		lessThanEqual.left.type.validateNumbers(CodeGeneratorPackage.Literals.LESS_THAN_EQUAL__LEFT)
		lessThanEqual.right.type.validateNumbers(CodeGeneratorPackage.Literals.LESS_THAN_EQUAL__RIGHT)
	}

	@Check
	def checkExpression(GreaterThan greaterThan) {
		greaterThan.left.type.validateNumbers(CodeGeneratorPackage.Literals.GREATER_THAN__LEFT)
		greaterThan.right.type.validateNumbers(CodeGeneratorPackage.Literals.GREATER_THAN__RIGHT)
	}

	@Check
	def checkExpression(GreaterThanEqual greaterThanEqual) {
		greaterThanEqual.left.type.validateNumbers(CodeGeneratorPackage.Literals.GREATER_THAN_EQUAL__LEFT)
		greaterThanEqual.right.type.validateNumbers(CodeGeneratorPackage.Literals.GREATER_THAN_EQUAL__RIGHT)
	}

	@Check
	def checkExpression(Plus plus) {
		if (plus.left.type != TypeChecker.Type.STRING && plus.right.type != TypeChecker.Type.STRING) {
			plus.left.type.validateNumbers(CodeGeneratorPackage.Literals.PLUS__LEFT)
			plus.right.type.validateNumbers(CodeGeneratorPackage.Literals.PLUS__RIGHT)
		}
	}

	@Check
	def checkExpression(Minus minus) {
		minus.left.type.validateNumbers(CodeGeneratorPackage.Literals.MINUS__LEFT)
		minus.right.type.validateNumbers(CodeGeneratorPackage.Literals.MINUS__RIGHT)
	}

	@Check
	def checkExpression(Mul mul) {
		mul.left.type.validateNumbers(CodeGeneratorPackage.Literals.MUL__LEFT)
		mul.right.type.validateNumbers(CodeGeneratorPackage.Literals.MUL__RIGHT)
	}

	@Check
	def checkExpression(Div div) {
		div.left.type.validateNumbers(CodeGeneratorPackage.Literals.DIV__LEFT)
		div.right.type.validateNumbers(CodeGeneratorPackage.Literals.DIV__RIGHT)
	}

	@Check
	def checkExpression(Negation negation) {
		negation.value.type.validateNumbers(CodeGeneratorPackage.Literals.NEGATION__VALUE)
	}

	@Check
	def checkExpression(Exponent exponent) {
		exponent.base.type.validateNumbers(CodeGeneratorPackage.Literals.EXPONENT__BASE)
		exponent.power.type.validateNumbers(CodeGeneratorPackage.Literals.EXPONENT__POWER)
	}

	@Check
	def checkPower(Not not) {
		not.value.type.validateTypes(TypeChecker.Type.BOOLEAN, CodeGeneratorPackage.Literals.NOT__VALUE)
	}

}
