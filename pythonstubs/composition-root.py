from machine import Pin, I2C
from mpu6050 import MPU6050
from pipeline import Pipeline, Sink
from communication import Serial, Wifi
import ujson
import struct
import thermistor

# To allow for easily modifying the composition, or simply using the generated one
# This is a very basic style of dependency injection framework

class CompositionRoot:

    def __init__(self):
        with open("conf-filled.json", "r") as _conf_file:
            self.configuration = ujson.loads("".join(_conf_file.readlines()))

    # Uses the entire composition root to instantiate the board object
    def provide_board(self):
        #TODO: Methods on board for add_sensor, add_..., etc.
        #TODO: Configure event manager on board
        #TODO: Handle threads :)
        pass

    # A provide method is created for every sensor
    def provide_sensor_thermistor(self):
        _thermistor = thermistor.Thermistor(MPU6050(I2C(-1, scl=Pin(26, Pin.IN), sda=Pin(25, Pin.OUT))))
        _thermistor.add_pipeline("voltage", self.provide_pipeline_thermistor_voltage_1())

    # And for every pipeline
    def provide_pipeline_thermistor_voltage_1(self):
        # TODO: How do we connect the end of the pipeline to the event system?
        return Pipeline(thermistor.InterceptorFilter1(thermistor.InterceptorMap1(thermistor.InterceptorWindowMean1(None))))
    
    # And for every channel
    def provide_channel_inserial(self, board):
        return self.make_channel("inserial")
    
    def provide_channel_outserial(self, board):
        outserial = self.make_channel("outserial")
        # The conversion to binary depends on the expected type of the value
        board.subscribe("voltage", lambda val: outserial.send(struct.pack("i", val)))
        board.subscribe("debug", lambda val: outserial.send(val.encode("utf-8")))
        return outserial
    
    def provide_channel_endpoint1(self, board):
        endpoint1 = self.make_channel("endpoint1")
        board.subscribe("voltage", lambda val: endpoint1.send(struct.pack("i", val)))
        board.subscribe("watts", lambda val: endpoint1.send(struct.pack("d", val)))
        return endpoint1
    
    def make_channel(self, identifier: str):
        if self.configuration["outserial"]["type"] == "serial":
            return Serial(self.configuration["serial"]["baud"],
                          self.configuration["serial"]["databits"],
                          self.configuration["serial"]["paritybits"],
                          self.configuration["serial"]["stopbit"])
        
        elif self.configuration["outserial"]["type"] == "wifi":
            return Wifi(self.configuration["outserial"]["lane"], 
                        self.configuration["wifi"]["ssid"],
                        self.configuration["wifi"]["password"])

# Users can override methods to modify the objects as the
# dependency graph is constructed.
class CustomCompositionRoot(CompositionRoot):
    
    # For instance, users can inject their own interceptors into an existing
    # pipeline, or provide a different pipeline altogether
    def provide_pipeline_thermistor_voltage_1(self):
        return super().provide_pipeline_thermistor_voltage_1()\
            .add(2, thermistor.InterceptorMap1(None))
