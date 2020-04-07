/*
 * generated by Xtext 2.20.0
 */
package org.iot.codegenerator.scoping

import java.util.Collections
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.Scopes
import org.iot.codegenerator.codeGenerator.Board
import org.iot.codegenerator.codeGenerator.Cloud
import org.iot.codegenerator.codeGenerator.CodeGeneratorPackage
import org.iot.codegenerator.codeGenerator.Fog
import org.iot.codegenerator.codeGenerator.Map
import org.iot.codegenerator.codeGenerator.Pipeline
import org.iot.codegenerator.codeGenerator.Transformation

import static extension org.eclipse.emf.ecore.util.EcoreUtil.*
import static extension org.eclipse.xtext.EcoreUtil2.*

/**
 * This class contains custom scoping description.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#scoping
 * on how and when to use it.
 */
class CodeGeneratorScopeProvider extends AbstractCodeGeneratorScopeProvider {

// TODO: Fixme
//	override getScope(EObject context, EReference reference) {
//		val codeGen = CodeGeneratorPackage.eINSTANCE
//		switch (reference) {
//			case codeGen.reference_Varid:
//				context.varIdScope
//			case codeGen.dataOut_DataId:
//				context.dataOutIdScope
//			case codeGen.transformationIn_Entities:
//				context.transInIdScope
//			default:
//				super.getScope(context, reference)
//		}
//
//	}
//
//	def private IScope getVarIdScope(EObject context) {
//		val mapContainer = context.eContainer.getContainerOfType(Pipeline)?.eContainer()?.getContainerOfType(Map)
//		if (mapContainer !== null) {
//			Scopes.scopeFor((Collections.singleton(mapContainer.output)))
//		} else {
//			val dataContainer = context.eContainer.getContainerOfType(Data)
//			val tranContainer = context.eContainer.getContainerOfType(Transformation)
//			val vars = dataContainer.getVariables(tranContainer)
//			Scopes.scopeFor(vars.ids)
//		}
//	}
//
//	def private IScope getDataOutIdScope(EObject context) {
//		val dataContainer = context.eContainer.getContainerOfType(Data)
//		if (dataContainer !== null) {
//			return Scopes.scopeFor(dataContainer.entities)
//		}
//	}
//
//	def private IScope getTransInIdScope(EObject context) {
//		var scope = context.eContainer.getContainerOfType(Cloud)?.getOutputDefinitionsFrom(Board, Fog)
//		if (scope === null) {
//			scope = context.eContainer.getContainerOfType(Fog)?.getOutputDefinitionsFrom(Board)
//			if (scope === null) {
//				return IScope.NULLSCOPE
//			}
//			return Scopes.scopeFor(scope)
//		}
//		return Scopes.scopeFor(scope)
//	}
//
//	def private Iterable<DataID> getOutputDefinitionsFrom(EObject context, Class<? extends EObject>... types) {
//		types.flatMap [
//			context.getSiblingsOfType(it).allContents.filter(OutputDefinition).toIterable.flatMap[it.entities]
//		]
//	}
//
//	// var ids reside in both transformations and data inputs
//	// these are added to the same scope
//	def Vars getVariables(Data data, Transformation trans) {
//		if (data !== null) {
//			return data.input.vars
//		} else if (trans !== null) {
//			return trans.input.vars
//		}
//	}

}
