import argparse
import sys

from libs.pingCommand import register_ping
from libs.readCommand import register_read
from libs.runCommand import register_run
from libs.writeCommand import register_write


def no_command(args):
    print('You must specify a command')
    sys.exit(1)


def create_parser():
    parser = argparse.ArgumentParser(prog='uart6502', description='Sends commands to 6502 via UART.')
    parser.add_argument('--dev', default='/dev/ttyUSB0', help='UART device')
    parser.set_defaults(func=no_command)
    subparsers = parser.add_subparsers(title='subcommands')
    register_ping(subparsers)
    register_write(subparsers)
    register_read(subparsers)
    register_run(subparsers)
    return parser


def run():
    args = create_parser().parse_args()
    args.func(args)


if __name__ == "__main__":
    run()
