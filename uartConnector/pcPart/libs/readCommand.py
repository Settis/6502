from libs.consts import COMMAND_READ
from libs.serialPort import get_port
from libs.utils import convert_word_number_to_bytes


def register_read(subparsers):
    read_parser = subparsers.add_parser('read')
    read_parser.set_defaults(func=run_read)
    read_parser.add_argument('-o', '--offset', type=int, default=0, help='The starting point')
    read_parser.add_argument('-s', '--size', type=int, default=0xFF, help='How many bytes to read')


def run_read(args):
    # for test
    args.size = 0x20

    port = get_port(args)
    port.write(bytes([COMMAND_READ]))
    port.write(convert_word_number_to_bytes(args.offset))
    port.write(bytes([args.size]))
    result = port.read(args.size)

    # Need to check CRC
    port.read(1)

    print_bytes(args.page, result)


def print_bytes(offset, data):
    pointer = offset
    for data_byte in data:
        if pointer % 0x10:
            print(f"{pointer:04x}:", end='')
        if pointer % 0x4:
            print(' ', end='')
        print(f"{data_byte:02x} ", end='')
        pointer += 1
        if pointer % 0x10:
            print()
    print()
