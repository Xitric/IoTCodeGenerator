# TODO: Only import things that are actually used, keep track
# of an import collection during generation, for instance by
# having an environment object that is being passed around,
# and generating the code templates from the inside-out
# TODO: Choose between importing into namespace or referencing,
# e.g. InterceptorMap1 vs thermistor.InterceptorMap1
# TODO: Make a separate package for python code generators
# TODO: Name this file composition root, and have a method for
# composing everything
import thread
import utime
import sys
import ujson
from machine import Pin, I2C
from mpu6050 import MPU6050
import thermistor
from pipeline import Pipeline
from interceptor import Sink
from communication import Serial, Wifi

# First instantiate all channels (but only if they are used somewhere)
# TODO: Instantiate channels that are registered in the environment after
# generating the rest inside-out
with open("conf-filled.json", "r") as _conf_file:
    _conf = ujson.loads("".join(_conf_file.readlines()))

if _conf["outserial"]["type"] == "serial":
    outserial = Serial(_conf["serial"]["baud"], _conf["serial"]["databits"], _conf["serial"]["paritybits"], _conf["serial"]["stopbit"])
elif _conf["outserial"]["type"] == "wifi":
    outserial = Wifi(_conf["outserial"]["lane"], _conf["wifi"]["ssid"], _conf["wifi"]["password"])

if _conf["inserial"]["type"] == "serial":
    inserial = Serial(_conf["serial"]["baud"], _conf["serial"]["databits"], _conf["serial"]["paritybits"], _conf["serial"]["stopbit"])
elif _conf["inserial"]["type"] == "wifi":
    inserial = Wifi(_conf["inserial"]["lane"], _conf["wifi"]["ssid"], _conf["wifi"]["password"])

# Next instantiate all sensors
_thermistor = thermistor.Thermistor(MPU6050(I2C(-1, scl=Pin(26, Pin.IN), sda=Pin(25, Pin.OUT))))
_thermistor.add_pipeline("voltage", Pipeline(thermistor.InterceptorFilter1(thermistor.InterceptorMap1(thermistor.InterceptorWindowMean1(Sink(outserial))))))

# Then fill out the sensor map with thermistor, thermometer, etc. along with their names from the DSL
sensors = {"thermistor": _thermistor}

# Loops to handle external communication
# TODO: One thread per output channel?
# TODO: While generating, keep track of which channels are used
# for input and which for output
# def send_loop(thread: thread.Thread):
#     for _ in range(10):
#         print("Send")
#         utime.sleep(1)
#         if not thread.active:
#             break

def receive_loop(thread: thread.Thread):
    while thread.active:
        command = inserial.receive().decode("utf-8")  # e.g. thermistor:kill  or  thermistor:signal
        print("Received: " + command)
        elements = command.split(":")
        sensor = sensors[elements[0]]
        sensor.signal(elements[1])

# send_thread = thread.Thread(send_loop, "ThreadSend")
# send_thread.start()
receive_thread = thread.Thread(receive_loop, "ThreadReceive")
receive_thread.start()

# Get locks from local sensor clocks
thermistor_thread = _thermistor.thread

# Wait for threads to finish, then shut down
thread.join([
    # send_thread,
    receive_thread,
    thermistor_thread
])

print("Goodbye")
