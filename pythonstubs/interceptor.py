
class Interceptor:

    def __init__(self, next):
        self.next = next

    def handle(self, data):
        pass

class InterceptorA(Interceptor):

    def handle(self, data):
        should_continue = data < 10 and data > 0
        if should_continue:
            self.next.handle(data)

class InterceptorB(Interceptor):

    def handle(self, data):
        newValue = data * 5 + 3
        self.next.handle(newValue)

class InterceptorC(Interceptor):

    def __init__(self, next: Interceptor):
        super().__init__(next)
        self.buffer = []
    
    def handle(self, data):
        self.buffer.append(data)
        if len(self.buffer) == 10:
            result = sum(self.buffer) / len(self.buffer)
            self.buffer = []
            self.next.handle(result)

class InterceptorD(Interceptor):

    def handle(self, data):
        print(data)  # Send somewhere...
