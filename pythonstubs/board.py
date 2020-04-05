import thread

try:
    import utime
except ModuleNotFoundError:
    import time as utime

class Board:

    # TODO: Don't generate input channel if the board does not accept input
    # TODO: Make input optional in the DSL
    def __init__(self):
        self._sensors = {}
        # Message bus
        self._input_channel = None
        self._output_channels = []
        self._subscriptions = {}

        # Threading
        self._out_lock = thread.make_lock()
        self._out_buffer = []
        self._out_thread = thread.Thread(self._output_loop, "ThreadOutput")
        self._in_thread = thread.Thread(self._input_loop, "ThreadInput")

    def add_sensor(self, identifier: str, sensor):
        self._sensors[identifier] = sensor
        # Hook pipelines up to the event bus of this board
        for variable in sensor.variables:
                for pipeline in sensor.variables[variable]:
                    pipeline.tail.next = self._make_sink(variable)

    def set_input_channel(self, channel):
        self._input_channel = channel

    def add_output_channel(self, channel):
        self._output_channels.append(channel)

    def subscribe(self, event: str, callback):
        if event in self._subscriptions:
            self._subscriptions[event].append(callback)
        else:
            self._subscriptions[event] = [callback]

    def _make_sink(self, event: str):
        return type('EventSink', (object,), {
            "handle": lambda data: self._raise_event(event, data)
        })

    def _raise_event(self, event: str, data):
        try:
            self._out_lock.acquire()
            self._out_buffer.append((event, data))
        finally:
            self._out_lock.release()
    
    def _output_loop(self, thread: thread.Thread):
        while thread.active:
            utime.sleep(1)
            try:
                # TODO: Work on a snapshot of the buffer in case this is slow?
                self._out_lock.acquire()
                if len(self._out_buffer) > 0:
                    for (event, data) in self._out_buffer:
                        for subscriber in self._subscriptions[event]:
                            subscriber(data)
            finally:
                self._out_buffer = []
                self._out_lock.release()
    
    def _input_loop(self, thread: thread.Thread):
        while thread.active:
            command = self._input_channel.receive().decode("utf-8")  # e.g. thermistor:kill  or  thermistor:signal
            print("Received: " + command)
            elements = command.split(":")
            sensor = self._sensors[elements[0]]
            sensor.signal(elements[1])

    def run(self):
        self._out_thread.start()
        self._in_thread.start()

        thread.join([
            self._out_thread,
            self._in_thread,
            # Join on threads only from frequency-based sensors
            self._sensors["thermistor"].thread
        ])
