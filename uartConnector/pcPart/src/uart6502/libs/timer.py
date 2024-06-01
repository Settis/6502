import time

def timer(name):
    def decorator(fun):
        def wrapper(*args, **kwargs):
            start = time.time()
            result = fun(*args, **kwargs)
            stop = time.time()
            if args[0].time:
                print(f"{name} was done in {stop-start} seconds")
            return result
        return wrapper
    return decorator
