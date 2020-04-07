package org.iot.codegenerator.validation

import java.util.List
import java.util.Arrays

class ESP32 extends GenericBoard {
	
	// varying types of ESP32 boards exist
	String version
	
	// sensors is reachable
	List<String> sensors
	
	// different keywords for different models	
	List<String> wrover = Arrays.asList("thermistor", "barometer", "lux", "accelerometer")

	new (String version) {
		this.version = version
		
		// assign correct keywords
		switch this.version {
			case "wrover" : sensors = wrover
			case "default" : sensors = wrover	
		}
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