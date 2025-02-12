import sys
import subprocess
import re

from .writeCommand import run_write_cmd
from .runCommand import run_run_cmd


def register_compile_and_run(subparsers):
    cr_parser = subparsers.add_parser('cr')
    cr_parser.set_defaults(func=run_compile_and_run_command)
    cr_parser.add_argument('src', help='the source file')


def run_compile_and_run_command(args):
    src = args.src
    p = subprocess.run(['./build.py', src, '-o', '/tmp/a.out', '-m' ,'/tmp/map.txt'], capture_output=True)
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
    with open('/tmp/map.txt', 'r') as mapping:
        pre_exports = True
        for line in mapping.readlines():
            if line.startswith('-----'):
                continue
            if pre_exports:
                if line.startswith('Exports list by name:'):
                    pre_exports = False
            else:
                if line == '\n':
                    break
                label_line = re.split(r"\s+", line)
                if label_line[0].upper() == "MAIN":
                    return label_line[1]
                if len(label_line) > 3 and label_line[3].upper() == "MAIN":
                    return label_line[4]
    print("No MAIN label in the source")
    sys.exit(1)
