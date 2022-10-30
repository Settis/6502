from .consts import COMMAND_RUN
from .serialPort import get_port
from .utils import convert_word_number_to_bytes


def register_run(subparsers):
    run_parser = subparsers.add_parser('run')
    run_parser.set_defaults(func=run_run_cmd)
    run_parser.add_argument('addr', help='The subroutine address')


def run_run_cmd(args):
    addr = int(args.addr, 16)
    run_run(args.dev, addr)


def run_run(dev, addr):
    port = get_port(dev)
    port.write(bytes([COMMAND_RUN]))
    port.write(convert_word_number_to_bytes(addr))

    # wait for the end
    port.read(1)
