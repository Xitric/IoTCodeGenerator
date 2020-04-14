package org.iot.codegenerator.validation

import java.util.List
import org.iot.codegenerator.codeGenerator.Board

class UtilityBoard {
	static GenericBoard board = null
	
	def static <B extends GenericBoard> getBoard(Board b){
		return UtilityBoard.getBoard(b.name, b.version)
	}
	
	def static <B extends GenericBoard> getBoard(String model, String version){
		var lowerCaseVersion = version
		
		if (version !== null) {
			lowerCaseVersion = lowerCaseVersion.toLowerCase()
		}
		
		if (model.toLowerCase().equals("esp32")){ // && validateBoardVersion(lowerCaseVersion)){
			board = new ESP32(lowerCaseVersion)
		} else {
			board = null
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
	def int getVariables(String s)
	override String toString()
			
}

