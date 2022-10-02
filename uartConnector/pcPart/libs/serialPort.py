import serial


def get_port(args):
    return serial.Serial(args.dev, parity=serial.PARITY_EVEN)
