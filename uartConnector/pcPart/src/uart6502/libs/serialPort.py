import serial


def get_port(dev):
    return serial.Serial(dev, parity=serial.PARITY_EVEN)
