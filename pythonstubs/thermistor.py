import thread
import utime

class Thermistor:  # Name from sensor ID

    def __init__(self):
        super().__init__()
        # Begin frequency
        # If sampling type is frequency, we run a loop in a thread specific to the sensor
        # Alternatively we can have a central timer dispatch thread
        # For all sensors that have a frequency technique, we must acquire their state locks in connection.py and join on them
        self.thread = thread.Thread(self.__timer, "ThreadThermistor")
        self.thread.start()
    
    #This is the timer loop
    def __timer(self, thread: thread.Thread):
        while thread.active:
            utime.sleep(10)  # 10 seconds
            # Run all sampling methods
            self.__sample_1()
            self.__sample_2()
    # End frequency

    # We always have a signal method for handling the kill command
    def signal(self, command: str):
        if command == "kill":
            self.thread.interrupt()
        # Begin signal
        # If sampling type is signal, then we have a signal method that handles the signal command
        elif command == "signal":
            self.__sample_1()
            self.__sample_2()
        # End signal
    
    def __sample_1(self):  # One for each data declaration
        print("Sample 1")  # Perform the actual sensor reading and pipeline transformation

    def __sample_2(self):  # One for each data declaration
        print("Sample 2")  # Perform the actual sensor reading and pipeline transformation
