import random
import sys

from .consts import COMMAND_PING
from .timer import timer
from .device import connect


def register_ping(subparsers):
    ping_parser = subparsers.add_parser('ping')
    ping_parser.set_defaults(func=run_ping_cmd)


@timer("Ping")
def run_ping_cmd(args):
    run_ping(connect(args.dev))


def run_ping(dev):
    # port.timeout = 1
    data = random.randint(5, 200)
    dev.write(bytes([COMMAND_PING, data]))
    response_raw = dev.read(1)
    if len(response_raw) == 0:
        print('No response for ping.')
        sys.exit(1)
    response = response_raw[0]
    if response != data + 1:
        print(f"Ping response is wrong. Expected: {data + 1}, but received {response}.")
        sys.exit(1)
    print("Ping is OK")
