from composition_root import CompositionRoot
from collections import namedtuple

# First we create a composition root subclass with providers for each type of sensor
# Then generate csv files with the input data for each sensor
#   - because the input to all pipelines in all datas is the same within the same sensor!!!
# The first line is the names of the variables that the sensor provides
# Each following line is a single sample
# mpu6050.csv
# AcX, AcY, AcZ, Tmp, GyX, GyY, GyZ
# ..., ..., ..., ..., ..., ..., ...
# ..., ..., ..., ..., ..., ..., ...
# ..., ..., ..., ..., ..., ..., ...
# ..., ..., ..., ..., ..., ..., ...

class DriverStub():

    def __init__(self, file_name: str):
        self.samples = []

        with open(file_name, "r") as file:
            types = " ".join(file.readline().split(", "))
            self.Tuple = namedtuple("Stub", types)

            self.samples = [
                [float(value) for value in line.split(", ")]
                for line in file.readlines()
            ]

    def sample(self):
        values = self.samples.pop(0)
        return self.Tuple(*values)


class CustomCompositionRoot(CompositionRoot):
    def provide_driver_motion(self):
        return DriverStub("motion.csv")

    def provide_driver_magnetometer(self):
        return DriverStub("magnetometer.csv")

    def provide_driver_barometer(self):
        return DriverStub("barometer.csv")

    def provide_driver_thermometer(self):
        return DriverStub("thermometer.csv")

    def provide_driver_lux(self):
        return DriverStub("lux.csv")

CustomCompositionRoot().provide_esp32().run()
