from interceptor import Interceptor

class Pipeline:

    def __init__(self, root: Interceptor):
        self.__head = root
        next = root
        while next is not None:
            next = next.next
        self.__tail = next
    
    def add(self, index: int, interceptor: Interceptor):
        i = 0
        previous = None
        next = self.__head
        while i < index and next is not None:
            previous = next
            next = next.next
            i += 1
        if i == index:
            if previous is not None:
                previous.next = interceptor
            if next is not None:
                interceptor.next = next
        else:
            raise IndexError("Illegal index " + i)
        return self
    
    def handle(self, x):
        self.__head.handle(x)
