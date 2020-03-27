/*
 * generated by Xtext 2.20.0
 */
package org.iot.codegenerator.validation

import org.eclipse.xtext.validation.Check
import org.iot.codegenerator.codeGenerator.DeviceConf
import org.iot.codegenerator.codeGenerator.CodeGeneratorPackage
import org.iot.codegenerator.codeGenerator.And

/**
 * This class contains custom validation rules. 
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class CodeGeneratorValidator extends AbstractCodeGeneratorValidator {

	@Check
	def checkDeviceConfiguration(DeviceConf configuration) {
		val boards = configuration.board
		
		if (boards.size() < 1){
			warning('''there should be a board definition''', CodeGeneratorPackage.eINSTANCE.deviceConf_Board)
			return
		}else if (boards.size() > 1){
			error('''there must be exactly 1 board definition''', CodeGeneratorPackage.eINSTANCE.deviceConf_Board)
			return
		}
		
		val clouds = configuration.cloud
		
		if (clouds.size() < 1){
			warning('''there should be a cloud definition''', CodeGeneratorPackage.eINSTANCE.deviceConf_Cloud)
			return
		} else if (clouds.size() > 1){
			error('''there must be exactly 1 cloud definition''', CodeGeneratorPackage.eINSTANCE.deviceConf_Cloud)
			return
		}
		
		val fogs = configuration.fog
		
		if (fogs.size() > 1){
			error('''there must at maximum be 1 fog definition''', CodeGeneratorPackage.eINSTANCE.deviceConf_Fog)
			return
		}		
	}
	
	@Check
	def checkExpressionLiteral(And and){
	}
	
}
