import sys

from .consts import COMMAND_WRITE
from .utils import convert_word_number_to_bytes, convert_word_bytes_to_number, crc, construct_chunks
from .timer import timer
from .device import connect


def register_write(subparsers):
    write_parser = subparsers.add_parser('write')
    write_parser.set_defaults(func=run_write_cmd)
    write_parser.add_argument('-f', '--file', default='a.out',
                              help='The binary file with two initial bytes for offset')


@timer("Write")
def run_write_cmd(args):
    data = Data(args)
    dev = connect(args.dev)
    for chunk in data.chunks:
        run_write(dev, chunk.start, chunk.data)


def run_write(dev, offset, data):
    chunks = construct_chunks(len(data))
    chunk_offset = 0
    for chunk in chunks:
        run_write_chunk(dev, offset + chunk_offset, data[chunk_offset:chunk_offset+chunk])
        chunk_offset += chunk


def run_write_chunk(dev, offset, data):
    dev.write(bytes([COMMAND_WRITE]))
    dev.write(convert_word_number_to_bytes(offset))
    length = len(data)
    if length == 0x100:
        dev.write(bytes([0]))
    else:
        dev.write(bytes([len(data)]))
    dev.write(bytes(data))

    calc_crc = crc(data)
    rec_crc = dev.read(1)[0]

    if calc_crc != rec_crc:
        print('Checksum is wrong')
        sys.exit(1)


class Data:
    def __init__(self, args):
        self.chunks = []
        with open(args.file, 'rb') as file:
            while True:
                two_bytes = file.read(2)
                if not two_bytes:
                    break
                start = convert_word_bytes_to_number(two_bytes)
                if (start == 0xFFFF):
                    start = convert_word_bytes_to_number(file.read(2))
                end = convert_word_bytes_to_number(file.read(2))
                data = []
                for i in range(start, end+1):
                    data.append(file.read(1)[0])
                self.chunks.append(Chunk(start, data))


class Chunk:
    def __init__(self, start, data):
        self.start = start
        self.data = data
