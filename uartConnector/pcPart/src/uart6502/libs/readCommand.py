import sys

from .consts import COMMAND_READ
from .serialPort import get_port
from .utils import convert_word_number_to_bytes, crc


def register_read(subparsers):
    read_parser = subparsers.add_parser('read')
    read_parser.set_defaults(func=run_read_cmd)
    read_parser.add_argument('-o', '--offset', default='0', help='The starting point')
    read_parser.add_argument('-s', '--size', default='FF', help='How many bytes to read')


def run_read_cmd(args):
    dev = args.dev
    offset = int(args.offset, 16)
    size = int(args.size, 16)
    result = run_read(dev, offset, size)
    print_bytes(offset, result)


def run_read(dev, offset, size):
    port = get_port(dev)
    port.write(bytes([COMMAND_READ]))
    port.write(convert_word_number_to_bytes(offset))
    port.write(bytes([size]))
    result = []
    for i in range(size):
        # send something to trigger interrupt
        port.write(bytes([0]))
        result.append(port.read(1)[0])

    calc_crc = crc(result)
    # send something to trigger interrupt
    port.write(bytes([0]))
    rec_crc = port.read(1)[0]
    if calc_crc != rec_crc:
        print('Checksum is wrong')
        sys.exit(1)

    return result


def print_bytes(offset, data):
    pointer = offset
    for data_byte in data:
        if pointer % 0x10 == 0:
            print(f"{pointer:04x}:", end='')
        if pointer % 0x8 == 0:
            print(' ', end='')
        print(f"{data_byte:02x} ", end='')
        pointer += 1
        if pointer % 0x10 == 0:
            print()
    print()
