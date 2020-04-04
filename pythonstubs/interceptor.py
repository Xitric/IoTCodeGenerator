from communication import Communication

class Interceptor:

    def __init__(self, next):
        self.next = next

    def handle(self, data):
        pass

# Begin channels
# A single, common sink interceptor exists to pass data on to other devices.
# At runtime, a connection is instantiated and passed to the sink
# to use for communication for each channel
class Sink(Interceptor):

    def __init__(self, comm: Communication):
        super().__init__(None)
        self.communication = comm

    def handle(self, data):
        self.communication.send(str(data).encode("utf-8"))
# End channels
