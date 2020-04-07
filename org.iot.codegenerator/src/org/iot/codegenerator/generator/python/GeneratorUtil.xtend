package org.iot.codegenerator.generator.python

import org.iot.codegenerator.codeGenerator.ChannelOut
import org.iot.codegenerator.codeGenerator.FrequencySampler
import org.iot.codegenerator.codeGenerator.Sensor
import org.iot.codegenerator.codeGenerator.SensorData
import org.iot.codegenerator.codeGenerator.SignalSampler

class GeneratorUtil {

	static def String asInstance(String name) {
		'''_«name»'''
	}
	
	static def String asModule(String name) {
		name.toLowerCase
	}

	static def String asClass(String name) {
		name.toFirstUpper
	}

	static def boolean isFrequency(Sensor sensor) {
		sensor.sampler instanceof FrequencySampler
	}

	static def boolean isSignal(Sensor sensor) {
		sensor.sampler instanceof SignalSampler
	}

	static def Iterable<SensorData> sensorDatas(Sensor sensor) {
		return sensor.eAllContents.filter(SensorData).toIterable
	}
}
