/*
 * generated by Xtext 2.20.0
 */
package org.iot.codegenerator.scoping

import java.util.ArrayList
import java.util.Collections
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.Scopes
import org.iot.codegenerator.codeGenerator.Board
import org.iot.codegenerator.codeGenerator.Cloud
import org.iot.codegenerator.codeGenerator.CodeGeneratorPackage
import org.iot.codegenerator.codeGenerator.Data
import org.iot.codegenerator.codeGenerator.Fog
import org.iot.codegenerator.codeGenerator.Map
import org.iot.codegenerator.codeGenerator.OutputDefinition
import org.iot.codegenerator.codeGenerator.Pipeline
import org.iot.codegenerator.codeGenerator.Transformation
import org.iot.codegenerator.codeGenerator.Vars

import static extension org.eclipse.emf.ecore.util.EcoreUtil.*
import static extension org.eclipse.xtext.EcoreUtil2.*

/**
 * This class contains custom scoping description.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#scoping
 * on how and when to use it.
 */
class CodeGeneratorScopeProvider extends AbstractCodeGeneratorScopeProvider {

	override getScope(EObject context, EReference reference) {
		val codeGen = CodeGeneratorPackage.eINSTANCE
		switch (reference) {
			case codeGen.reference_Varid:
				context.varIdScope
			case codeGen.dataOut_DataId:
				context.dataOutIdScope
			case codeGen.transformationIn_Entities:
				context.transInIdScope
			default:
				super.getScope(context, reference)
		}

	}

	def private IScope getVarIdScope(EObject context) {
		val mapContainer = context.eContainer.getContainerOfType(Pipeline)?.eContainer()?.getContainerOfType(Map)
		if (mapContainer !== null) {
			Scopes.scopeFor((Collections.singleton(mapContainer.output)))
		} else {
			val dataContainer = context.eContainer.getContainerOfType(Data)
			val tranContainer = context.eContainer.getContainerOfType(Transformation)
			val vars = dataContainer.getVariables(tranContainer)
			Scopes.scopeFor(vars.ids)
		}
	}

	def private IScope getDataOutIdScope(EObject context) {
		val dataContainer = context.eContainer.getContainerOfType(Data)
		if (dataContainer !== null) {
			return Scopes.scopeFor(dataContainer.entities)
		}
	}

	def private IScope getTransInIdScope(EObject context) {
		val List<OutputDefinition> outputDefinitions = new ArrayList();
		val cloudContainer = context.eContainer.getContainerOfType(Cloud)
		if (cloudContainer !== null) {
			val boardContainer = cloudContainer.getSiblingsOfType(Board)
			if (boardContainer !== null) {
				outputDefinitions.addAll(
					boardContainer.allContents.filter(OutputDefinition).toIterable)
			}
			val fogContainer = cloudContainer.getSiblingsOfType(Fog)
			if (fogContainer !== null) {
				outputDefinitions.addAll(
					fogContainer.allContents.filter(OutputDefinition).toIterable)
			}

			return Scopes.scopeFor(outputDefinitions.flatMap[it.entities])
		}
		
		val fogContainer = context.eContainer.getContainerOfType(Fog)
		if(fogContainer !== null){
			val boardContainer = fogContainer.getSiblingsOfType(Board)
			if(boardContainer !== null){
				return Scopes.scopeFor(boardContainer.allContents.filter(OutputDefinition).toIterable)
			}
		}

	}

	// var ids reside in both transformations and data inputs
	// these are added to the same scope
	def Vars getVariables(Data data, Transformation trans) {
		if (data !== null) {
			return data.input.vars
		} else if (trans !== null) {
			return trans.input.vars
		}
	}

}
