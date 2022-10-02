from libs.consts import COMMAND_RUN
from libs.serialPort import get_port
from libs.utils import convert_word_number_to_bytes


def register_run(subparsers):
    run_parser = subparsers.add_parser('run')
    run_parser.set_defaults(func=run_run)
    run_parser.add_argument('addr', help='The subroutine address')


def run_run(args):
    addr = int(args.addr, 16)

    port = get_port(args)
    port.write(bytes([COMMAND_RUN]))
    port.write(convert_word_number_to_bytes(addr))

    # wait for the end
    port.read(1)
