from .busOutput import BusOutput, BusState, DataDirection, getAddrState
from .consts import COMMAND_DEBUG
from .utils import convert_word_number_to_bytes
from .timer import timer
from .device import connect

def register_debug(subparsers):
    debug_parser = subparsers.add_parser('debug')
    debug_parser.set_defaults(func=run_debug_cmd)
    debug_parser.add_argument('addr', help='touched address')
    debug_parser.add_argument('data', nargs='?', help='Stop only if this data on the bus')
    debug_parser.add_argument('-q', '--quiet', action='store_true', help='Be quiet and quick')
    debug_parser.add_argument('-r', '--read', action='store_true', help='Stop only when address is readed')
    debug_parser.add_argument('-w', '--write', action='store_true', help='Stop only when address is writed')

@timer('Debug')
def run_debug_cmd(args):
    addr = int(args.addr, 16)
    dev = connect(args.dev)
    mode = 0
    if args.data:
        mode |= 0x08
    if args.read != args.write:
        mode |= 0x02
        if args.read:
            mode |= 0x04
    if mode == 0:
        mode = 1 # no condition so far - all cations should match
    if args.quiet:
        mode |= 0x10
    
    dev.write(bytes([COMMAND_DEBUG, mode]))
    dev.write(convert_word_number_to_bytes(addr))
    if args.data:
        dev.write(bytes([int(args.data, 16)]))

    bus_output = BusOutput()
    while True:
        flags = dev.read(1)[0]
        if flags == 0:
            bus_output.flush()
            break
        packet = dev.read(3)
        direction = DataDirection.READ if bool(flags & 0x01) else DataDirection.WRITE
        state = BusState(packet[0],
                         packet[1] | (packet[2] << 8),
                         getAddrState(bool(flags & 0x04), bool(flags & 0x02)),
                         direction)
        bus_output.register_state(state)
