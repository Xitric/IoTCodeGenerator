package org.iot.codegenerator.validation

import java.util.List
import java.util.Arrays

class ESP32 extends GenericBoard {
	
	// varying types of ESP32 boards exist
	String version
	
	// sensors is reachable
	List<String>  sensors
	List<Integer> variables
	
	// different keywords for different models	
	List<String> wrover_s = Arrays.asList("temperature", "barometer", "lux", "motion", "magnetometor")
	List<Integer> wrover_v = Arrays.asList(2, 1, 1, 7, 3)

	new (String version) {
		this.version = version
		
		// assign correct keywords
		switch this.version {
			case "wrover" : wrover_s.update(wrover_v)
			case "default" : wrover_s.update(wrover_v)
		}
	}
	
	override int getVariables(String s){
		var i = sensors.indexOf(s)
		return variables.get(i)
	}
	
	def update(List<String> s, List<Integer> p){
		sensors = s
		variables = p
	}
	
	override getSensors() {
		sensors
	}
	
	override getVersion() {
		version
	}
	
	override toString() {
		"Board{ESP-32 -> "+this.version+"}"
	}
	
}