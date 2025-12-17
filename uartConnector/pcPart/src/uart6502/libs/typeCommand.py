import threading
import sys

from .timer import timer
from .device import connect


def register_type(subparsers):
    run_parser = subparsers.add_parser('type')
    run_parser.set_defaults(func=run_type_cmd)
    run_parser.add_argument('-s', '--send', action='append', help='Send the content of given test file')


@timer("Run")
def run_type_cmd(args):
    send_files = args.send
    dev = connect(args.dev)
    if send_files:
        from_file(dev, send_files)
    else:
        interactive(dev)

def handle_keyboard(device, proceed):
    while proceed:
        keypress = sys.stdin.read(1)
        try:
            device.write(keypress.encode('UTF-8'))
        except RuntimeError as e:
            print("Exception: " + str(e))

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

    byte = dev.read(1)
    dev.write(file_content.encode('ascii'))
    while True:
        if byte[0] == 4:
            if last_byte != 0xA and has_logs:  # Newline
                print()
            return
        has_logs = True
        print(byte_to_string(byte), end='', flush=True)
        last_byte = byte[0]
        byte = dev.read(1)

def byte_to_string(byte):
    if byte[0] < 127:
        char = byte.decode('ascii')
        if char.isprintable() or char == '\n':
            return char
    return f"↧{byte[0]:02x}"
