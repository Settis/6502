from .pingCommand import run_ping
import sys

#  ORG $0A00
#  A9 B5    |  LDA  #$B5
#  8B 00 0A |  STA $0A00
#  60       |  RTS
from .readCommand import run_read
from .runCommand import run_run
from .writeCommand import run_write_chunk

OFFSET = 0x0A00
PROG = [0xa9, 0xb5, 0x8d, 0x00, 0x0a, 0x60]


def register_test(subparsers):
    test_parser = subparsers.add_parser('test')
    test_parser.set_defaults(func=run_test)


def run_test(args):
    dev = args.dev
    run_ping(dev)
    print('Write prog')
    run_write_chunk(dev, OFFSET, PROG)
    print('Read it back')
    result = run_read(dev, OFFSET, len(PROG))
    if result != PROG:
        print('Read result is wrong')
        sys.exit(1)
    print('Run the program')
    run_run(dev, OFFSET)
    result = run_read(dev, OFFSET, 1)
    if result[0] != 0xB5:
        print('The result of program run is wrong')
        sys.exit(1)
    print('Test passed')
