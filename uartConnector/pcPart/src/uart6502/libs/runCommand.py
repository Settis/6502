from .consts import COMMAND_RUN
from .utils import convert_word_number_to_bytes
from .timer import timer
from .device import connect


def register_run(subparsers):
    run_parser = subparsers.add_parser('run')
    run_parser.set_defaults(func=run_run_cmd)
    run_parser.add_argument('addr', help='The subroutine address')


@timer("Run")
def run_run_cmd(args):
    addr = int(args.addr, 16)
    run_run(connect(args.dev), addr)


def run_run(dev, addr):
    dev.write(bytes([COMMAND_RUN]))
    dev.write(convert_word_number_to_bytes(addr))

    # wait for the end
    # and print logs
    has_logs = False
    last_byte = None
    while True:
        byte = dev.read(1)
        if byte[0] == 4:
            if last_byte != 0xA and has_logs:  # Newline
                print()
            return
        has_logs = True
        print(byte_to_string(byte), end='', flush=True)
        last_byte = byte[0]


def byte_to_string(byte):
    if byte[0] < 127:
        char = byte.decode('ascii')
        if char.isprintable() or char == '\n':
            return char
    return f"↧{byte[0]:02x}"
