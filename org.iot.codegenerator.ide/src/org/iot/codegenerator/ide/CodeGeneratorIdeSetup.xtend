/*
 * generated by Xtext 2.20.0
 */
package org.iot.codegenerator.ide

import com.google.inject.Guice
import org.eclipse.xtext.util.Modules2
import org.iot.codegenerator.CodeGeneratorRuntimeModule
import org.iot.codegenerator.CodeGeneratorStandaloneSetup

/**
 * Initialization support for running Xtext languages as language servers.
 */
class CodeGeneratorIdeSetup extends CodeGeneratorStandaloneSetup {

	override createInjector() {
		Guice.createInjector(Modules2.mixin(new CodeGeneratorRuntimeModule, new CodeGeneratorIdeModule))
	}
	
}
