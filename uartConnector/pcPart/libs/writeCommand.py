from libs.consts import COMMAND_WRITE
from libs.serialPort import get_port


def register_write(subparsers):
    write_parser = subparsers.add_parser('write')
    write_parser.set_defaults(func=run_write)
    write_parser.add_argument('-f', '--file', default='test.bin',
                              help='The binary file with two initial bytes for offset')


def run_write(args):
    data = Data(args)
    port = get_port(args)
    port.write(bytes([COMMAND_WRITE]))
    port.write(data.get_little_endian_offset())
    port.write(data.get_length())
    port.write(data.get_data())
    port.read(1)


class Data:
    def __init__(self, args):
        with open(args.file, 'rb') as file:
            self.offset = file.read(1)[0] + file.read(1)[0]*0x100
            self.content = []
            while byte := file.read(1):
                self.content.append(byte[0])

    def get_little_endian_offset(self):
        return bytes([self.offset & 0xFF, (self.offset & 0xFF00) >> 8])

    def get_length(self):
        return bytes([len(self.content)])

    def get_data(self):
        return bytes(self.content)
