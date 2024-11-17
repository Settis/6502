import argparse
import sys
import traceback

from .libs.pingCommand import register_ping
from .libs.readCommand import register_read
from .libs.runCommand import register_run
from .libs.testCommand import register_test
from .libs.writeCommand import register_write
from .libs.compileRunCommand import register_compile_and_run
from serial import SerialException


def no_command(args):
    print('You must specify a command')
    sys.exit(1)


def create_parser():
    parser = argparse.ArgumentParser(prog='uart6502', description='Sends commands to 6502 via UART.')
    parser.add_argument('--dev', default='', help='UART device')
    parser.add_argument('--trace', action='store_true', help='Print exceptions stack traces')
    parser.add_argument('--time', action='store_true', help='Print execution time')
    parser.set_defaults(func=no_command)
    subparsers = parser.add_subparsers(title='subcommands')
    register_ping(subparsers)
    register_write(subparsers)
    register_read(subparsers)
    register_run(subparsers)
    register_test(subparsers)
    register_compile_and_run(subparsers)
    return parser


def run():
    try:
        args = create_parser().parse_args()
        args.func(args)
    except SerialException:
        if args.trace:
            traceback.print_exc()
        else:
            print("Serial exception")
        sys.exit(3)
    except KeyboardInterrupt:
        if args.trace:
            traceback.print_exc()
        sys.exit(2)


if __name__ == "__main__":
    run()
