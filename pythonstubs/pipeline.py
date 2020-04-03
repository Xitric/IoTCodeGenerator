from interceptor import Interceptor, InterceptorA, InterceptorB, InterceptorC, InterceptorD

class Pipeline:

    def __init__(self, root: Interceptor):
        self.head = root
        next = root
        while next is not None:
            next = next.next
        self.tail = next
    
    def add(self, index: int, interceptor: Interceptor):
        i = 0
        previous = None
        next = self.head
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

p = Pipeline(InterceptorA(InterceptorB(InterceptorC(InterceptorD(None)))))
