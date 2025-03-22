import threading
import sys

from .consts import COMMAND_RUN
from .utils import convert_word_number_to_bytes
from .timer import timer
from .device import connect


def register_run(subparsers):
    run_parser = subparsers.add_parser('run')
    run_parser.set_defaults(func=run_run_cmd)
    run_parser.add_argument('addr', help='The subroutine address')
    run_parser.add_argument('-s', '--send', action='append', help='Send the content of given test file')


@timer("Run")
def run_run_cmd(args):
    addr = int(args.addr, 16)
    run_run(connect(args.dev), addr, args.send)

def handle_keyboard(device, proceed):
    while proceed:
        keypress = sys.stdin.read(1)
        device.write(keypress.encode('UTF-8'))

def run_run(dev, addr, send_files=None):
    dev.write(bytes([COMMAND_RUN]))
    dev.write(convert_word_number_to_bytes(addr))

    if send_files:
        from_file(dev, send_files)
    else:
        interactive(dev)


def interactive(dev):
    capture_input = True
    receiver_thread = threading.Thread(target=handle_keyboard, args=(dev,capture_input), daemon=True)
    receiver_thread.start()

    # wait for the end
    # and print logs
    has_logs = False
    last_byte = None

    while True:
        byte = dev.read(1)
        if byte[0] == 4:
            if last_byte != 0xA and has_logs:  # Newline
                print()
            capture_input = False
            return
        has_logs = True
        print(byte_to_string(byte), end='', flush=True)
        last_byte = byte[0]


def from_file(dev, files):
    # wait for the end
    # and print logs
    has_logs = False
    last_byte = None
    
    file_content = ""
    for file in files:
        with open(file, 'r') as text_file:
            file_content += text_file.read() + "\n"

    expected_sequence = []

    while True:
        byte = dev.read(1)


        if len(expected_sequence) > 0 and byte[0] == expected_sequence[0]:
            expected_sequence = expected_sequence[1:]
        if byte[0] == 4:
            if last_byte != 0xA and has_logs:  # Newline
                print()
            return
        has_logs = True
        print(byte_to_string(byte), end='', flush=True)
        last_byte = byte[0]
        
        if len(expected_sequence) == 0 and len(file_content) > 0:
            chunk = file_content[:20]
            file_content = file_content[20:]
            expected_sequence = chunk.encode('ascii')
            dev.write(expected_sequence)

def byte_to_string(byte):
    if byte[0] < 127:
        char = byte.decode('ascii')
        if char.isprintable() or char == '\n':
            return char
    return f"↧{byte[0]:02x}"
