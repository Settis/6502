import sys

from .consts import COMMAND_READ
from .utils import convert_word_number_to_bytes, crc, construct_chunks
from .timer import timer
from .device import connect


def register_read(subparsers):
    read_parser = subparsers.add_parser('read')
    read_parser.set_defaults(func=run_read_cmd)
    read_parser.add_argument('-o', '--offset', default='0', help='The starting point')
    read_parser.add_argument('-s', '--size', default='100', help='How many bytes to read')
    read_parser.add_argument('-r', '--raw', action='store_true', help='Return raw data to output')


@timer("Read")
def run_read_cmd(args):
    dev = connect(args.dev)
    offset = int(args.offset, 16)
    size = int(args.size, 16)
    result = run_read(dev, offset, size)
    if args.raw:
        print_raw_bytes(result)
    else:
        print_bytes(offset, result)


def run_read(dev, offset, size):
    chunks = construct_chunks(size)
    result = []
    chunk_offset = 0
    for chunk in chunks:
        result.extend(run_read_chunk(dev, offset + chunk_offset, chunk))
        chunk_offset += chunk
    return result


def run_read_chunk(dev, offset, size):
    dev.write(bytes([COMMAND_READ]))
    dev.write(convert_word_number_to_bytes(offset))
    if size == 0x100:
        dev.write(bytes([0]))
    else:
        dev.write(bytes([size]))
    result = []
    for i in range(size):
        # send something to trigger interrupt
        dev.write(bytes([0]))
        result.append(dev.read(1)[0])

    calc_crc = crc(result)
    # send something to trigger interrupt
    dev.write(bytes([0]))
    rec_crc = dev.read(1)[0]
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


def print_raw_bytes(data):
    sys.stdout.buffer.write(bytes(data))
