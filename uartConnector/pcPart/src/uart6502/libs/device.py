from abc import ABC, abstractmethod
import os.path
import socket
import serial


DEFAULT_USB_DEV = '/dev/ttyUSB0'
DEFAULT_NET_DEV = 'markus.local:23'

class Device(ABC):
    @abstractmethod
    def write(self, data:bytes):
        pass

    @abstractmethod
    def read(self, size:int)-> bytes:
        pass

class UsbDevice(Device):
    def __init__(self, dev) -> None:
        super().__init__()
        self.serial = serial.Serial(dev, parity=serial.PARITY_EVEN)

    def write(self, data: bytes):
        self.serial.write(data)

    def read(self, size: int) -> bytes:
        return self.serial.read(size)    

class NetworkDevice(Device):
    def __init__(self, host) -> None:
        super().__init__()
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        separated = host.split(':')
        self.sock.connect((separated[0], int(separated[1])))

    def write(self, data: bytes):
        self.sock.sendall(data)

    def read(self, size: int) -> bytes:
        return self.sock.recv(size)

def connect(addr: str)-> Device:
    if addr == '':
        if os.path.exists(DEFAULT_USB_DEV):
            addr = DEFAULT_USB_DEV
        else:
            addr = DEFAULT_NET_DEV
    if addr.startswith('/'):
        return UsbDevice(addr)
    return NetworkDevice(addr)
