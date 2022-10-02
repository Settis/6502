import random
import sys

from libs.consts import COMMAND_PING
from libs.serialPort import get_port


def register_ping(subparsers):
    ping_parser = subparsers.add_parser('ping')
    ping_parser.set_defaults(func=run_ping)


def run_ping(args):
    port = get_port(args)
    port.timeout = 1
    data = random.randint(5, 200)
    port.write(bytes([COMMAND_PING, data]))
    response_raw = port.read(1)
    if len(response_raw) == 0:
        print('No response for ping.')
        sys.exit(1)
    response = response_raw[0]
    if response != data + 1:
        print(f"Ping response is wrong. Expected: {data + 1}, but received {response}.")
        sys.exit(1)
    print("Ping is OK")
