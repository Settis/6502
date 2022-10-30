import sys

from .consts import COMMAND_WRITE
from .serialPort import get_port
from .utils import convert_word_number_to_bytes, convert_word_bytes_to_number, crc


def register_write(subparsers):
    write_parser = subparsers.add_parser('write')
    write_parser.set_defaults(func=run_write_cmd)
    write_parser.add_argument('-f', '--file', default='test.bin',
                              help='The binary file with two initial bytes for offset')


def run_write_cmd(args):
    data = Data(args)
    run_write(args.dev, data.offset, data.content)


def run_write(dev, offset, data):
    port = get_port(dev)
    port.write(bytes([COMMAND_WRITE]))
    port.write(convert_word_number_to_bytes(offset))
    port.write(bytes([len(data)]))
    port.write(bytes(data))

    calc_crc = crc(data)
    rec_crc = port.read(1)[0]

    if calc_crc != rec_crc:
        print('Checksum is wrong')
        sys.exit(1)


class Data:
    def __init__(self, args):
        with open(args.file, 'rb') as file:
            self.offset = convert_word_bytes_to_number(file.read(2))
            self.content = []
            while byte := file.read(1):
                self.content.append(byte[0])

    def get_little_endian_offset(self):
        return convert_word_number_to_bytes(self.offset)

    def get_length(self):
        return bytes([len(self.content)])

    def get_data(self):
        return bytes(self.content)
