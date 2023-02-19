import sys
import subprocess

from .writeCommand import run_write_cmd
from .runCommand import run_run_cmd


def register_compile_and_run(subparsers):
    cr_parser = subparsers.add_parser('cr')
    cr_parser.set_defaults(func=run_compile_and_run_command)
    cr_parser.add_argument('src', help='the source file')


def run_compile_and_run_command(args):
    src = args.src
    p = subprocess.run(['dasm', src, '-o/tmp/a.out', '-s/tmp/symbol.txt'], capture_output=True)
    exit_code = p.returncode
    if exit_code != 0:
        print('Fail to compile the source')
        print(p.stdout.decode('utf-8'))
        print('Error:')
        print(p.stderr.decode('utf-8'))
        sys.exit(1)
    args.addr = extract_main()
    args.file = '/tmp/a.out'
    run_write_cmd(args)
    run_run_cmd(args)


def extract_main():
    with open('/tmp/symbol.txt', 'r') as symbols:
        for line in symbols:
            if line.startswith('-') or len(line) == 0:
                continue
            symbol_line = line.split()
            if symbol_line[0].upper() == 'MAIN':
                return symbol_line[1]
    print("No MAIN label in the source")
    sys.exit(1)
