import thread
import utime
import sys
from thermistor import Thermistor

# First instantiate all sensors
thermistor = Thermistor()

# Then fill out the sensor map with thermistor, thermometer, etc. along with their names from the DSL
sensors = {"thermistor": thermistor}

# Loops to handle external communication
# TODO: Asbtract serial vs wifi
def send_loop(thread: thread.Thread):
    for _ in range(10):
        print("Send")
        utime.sleep(1)
        if not thread.active:
            break

def receive_loop(thread: thread.Thread):
    while thread.active:
        command = sys.stdin.readline().replace("\r", "").replace("\n", "")  # e.g. thermistor:kill  or  thermistor:signal
        print("Received: " + command)
        elements = command.split(":")
        sensor = sensors[elements[0]]
        sensor.signal(elements[1])
        print(sensor)

send_thread = thread.Thread(send_loop, "ThreadSend")
send_thread.start()
receive_thread = thread.Thread(receive_loop, "ThreadReceive")
receive_thread.start()

# Get locks from local sensor clocks
thermistor_thread = thermistor.thread

# Wait for threads to finish, then shut down
thread.join([send_thread, receive_thread, thermistor_thread])

print("Goodbye")
