package org.iot.codegenerator.validation

import java.util.List

class UtilityBoard {
	static GenericBoard board = null
	
	def static <B extends GenericBoard> getBoard(String model, String version){
		var lowerCaseVersion = version
		
		if (version !== null) {
			lowerCaseVersion = lowerCaseVersion.toLowerCase()
		}
		
		if (model.toLowerCase().equals("esp32") && validateBoardVersion(lowerCaseVersion)){
			board = new ESP32(lowerCaseVersion)
		} 
		
		return board
	}
	
	def static boolean validateBoardVersion(String version){
		return (board === null || !board.getVersion().equals(version))
	}
}

abstract class GenericBoard {
	
	def String getVersion()
	def List<String> getSensors()
	override String toString()
			
}

