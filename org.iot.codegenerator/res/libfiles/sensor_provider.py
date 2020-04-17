from machine import Pin, I2C
i2c = I2C(-1, Pin(26, Pin.IN), Pin(25, Pin.OUT))

class default_wrapper:
    def __init__(self):
        pass

    def read_data(self):
        pass

class temperature_wrapper(default_wrapper):

    def __init__(self):
        from hts221 import HTS221
        self.driver = HTS221(i2c) 

    def read_data(self):
        return self.driver.read_temp(), self.driver.read_humi()

class lux_wrapper(default_wrapper):

    def __init__(self):
        from bh1750 import BH1750
        self.driver = BH1750(i2c)

    def read_data(self):
        return self.driver.luminance(0x10)

class motion_wrapper(default_wrapper):
    
    def __init__(self):
        from mpu6050 import MPU6050
        self.driver = MPU6050(i2c)

    def read_data(self):
        # return a dictionary with 7 keys
        return self.driver.get_values()
        