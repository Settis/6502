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
    # and print logs
    has_logs = False
    last_byte = None
    while True:
        byte = port.read(1)
        if byte[0] == 4:
            if last_byte != 0xA and has_logs:  # Newline
                print()
            return
        has_logs = True
        print(byte.decode('utf-8'), end='')
        last_byte = byte[0]
