package org.iot.codegenerator.generator.python.board

import org.iot.codegenerator.codeGenerator.ExtSensor
import org.iot.codegenerator.codeGenerator.OnbSensor
import org.iot.codegenerator.codeGenerator.Sensor
import org.iot.codegenerator.generator.python.GeneratorEnvironment

import static extension org.iot.codegenerator.generator.python.GeneratorUtil.*

class DriverProviderGenerator {

	static String i2c = "I2C(-1, Pin(26, Pin.IN), Pin(25, Pin.OUT))"

	static def String compileDriverProvider(Sensor sensor, GeneratorEnvironment env) {
		switch sensor {
			OnbSensor: sensor.compileOnboardProvider(env)
			ExtSensor: sensor.compileExternalProvider(env)
		}
	}

	private static def String compileOnboardProvider(OnbSensor sensor, GeneratorEnvironment env) {
		env.useImport("machine", "Pin")
		env.useImport("machine", "I2C")

		switch sensor.sensortype {
			case "thermometer": sensor.compileHts221Provider(env)
			case "lux": sensor.compileBh1750Provider(env)
			case "motion": sensor.compileMpu6050Provider(env)
			default: "pass  # Not yet supported"
		}
	}

	private static def String compileHts221Provider(OnbSensor sensor, GeneratorEnvironment env) {
		env.useLibFile("hts221.py")
		env.useLibFile("LICENSE_hts221.txt")
		env.useLibFile("usmbus.py")
		env.useLibFile("LICENSE_usmbus.txt")

		'''
			def provide_driver_hts221(self):
				«sensor.compileNamedTuple(env)»
				_sensor = «env.useImport("hts221", "HTS221")»(«i2c»)
				
				def sample():
					_temp = _sensor.read_temp()
					_humi = _sensor.read_humi()
					return _Container(_temp, _humi)
				
				return «compileSamplerWrapper("sample")»
		'''
	}

	private static def String compileBh1750Provider(OnbSensor sensor, GeneratorEnvironment env) {
		env.useLibFile("bh1750.py")

		'''
			def provide_driver_bh1750(self):
				«sensor.compileNamedTuple(env)»
				_sensor = «env.useImport("bh1750", "BH1750")»(«i2c»)
				
				def sample():
					_lumi = _sensor.luminance(«IF sensor.isFrequency»«env.useImport("bh1750", "CONT_HIRES_1")»«ELSE»«env.useImport("bh1750", "ONCE_HIRES_1")»«ENDIF»)
					return _Container(_lumi)
				
				return «compileSamplerWrapper("sample")»
		'''
	}

	private static def String compileMpu6050Provider(OnbSensor sensor, GeneratorEnvironment env) {
		env.useLibFile("mpu6050.py")
		env.useLibFile("LICENSE_mpu6050.txt")

		'''
			def provide_driver_mpu6050(self):
				«sensor.compileNamedTuple(env)»
				_sensor = «env.useImport("mpu6050", "MPU6050")»(«i2c»)
				
				def sample():
					_vals = _sensor.get_values()
					return _Container(_vals["AcX"], _vals["AcY"], _vals["AcZ"], _vals["Tmp"], _vals["GyX"], _vals["GyY"], _vals["GyZ"])
				
				return «compileSamplerWrapper("sample")»
		'''
	}

	private static def String compileExternalProvider(ExtSensor sensor, GeneratorEnvironment env) {
		if (! env.libFiles.contains("ADCDriver.py")) {
			env.useLibFile("ADCDriver.py")
			
			'''
				def provide_driver_adc(self, *pins):
					«sensor.compileNamedTuple(env)»
					return «env.useImport("ADCDriver", "ADCDriver")»(_Container, *pins)
				
			'''
		}
	}

	private static def String compileNamedTuple(Sensor sensor, GeneratorEnvironment env) {
		val source = sensor.variables
		'''_Container = «env.useImport("collections", "namedtuple")»("«source.name.asInstance»", "«FOR id : source.ids SEPARATOR " "»«id.name.asModule»«ENDFOR»")'''
	}

	private static def String compileSamplerWrapper(String sampler) {
		'''
			type('Driver', (object,), {
				"sample": «sampler»
			})
		'''
	}
}
