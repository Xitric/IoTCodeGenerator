package org.iot.codegenerator.generator.python

import java.util.HashMap
import java.util.HashSet
import java.util.Map
import java.util.Set
import org.iot.codegenerator.codeGenerator.Channel

class GeneratorEnvironment {

	Map<String, Set<String>> imports
	Set<Channel> channels

	new() {
		imports = new HashMap()
		channels = new HashSet()
	}

	def String useImport(String module) {
		imports.putIfAbsent(module, new HashSet())
		return module
	}

	def String useImport(String module, String definition) {
		useImport(module)
		val definitions = imports.get(module)
		definitions.add(definition)
		imports.put(module, definitions)
		return definition
	}

	def Iterable<String> getModuleImports() {
		imports.filter[key, value|value.empty].keySet
	}

	def Iterable<String> getDefinitionImports() {
		imports.filter[key, value|!value.empty].keySet
	}

	def Iterable<String> getDefinitionsFor(String module) {
		return imports.get(module)
	}

	def Channel useChannel(Channel channel) {
		channels.add(channel)
		return channel
	}

	def Iterable<Channel> getChannels() {
		return channels
	}

	static def String asSafeImport(String module) {
		if (#["ujson", "utime"].contains(module)) {
			'''
			try:
			    import «module»
			except ModuleNotFoundError:
			    import «module.substring(1)» as «module»
			'''
		} else {
			'''import «module»'''
		}
	}
}
