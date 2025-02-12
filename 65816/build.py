#!/bin/env python3
import argparse
import os
import re
import subprocess
import sys

def parse_args():
    parser = argparse.ArgumentParser(prog='build', description='Builds ca65 assembly')
    parser.add_argument('src', help='main assembly file')
    parser.add_argument('-m', '--map', help='map file output', default='map.txt')
    parser.add_argument('-o', '--output', help='output binary file', default='a.out')
    parser.add_argument('-c', '--config', help='mapping config', default='uart.conf')
    return parser.parse_args()

def get_obj_file_name(src_file_name):
    return src_file_name[:-3] + 'o'

def ensure_obj_file(src_file_name):
    obj_file_name = get_obj_file_name(src_file_name)
    if os.path.exists(obj_file_name) and os.path.getmtime(obj_file_name) > os.path.getmtime(src_file_name):
        return # obj file is already up to date
    p = subprocess.run(['ca65', src_file_name], capture_output=True)
    exit_code = p.returncode
    if exit_code != 0:
        print(f"Fail to compile {src_file_name}:")
        print(p.stdout.decode('utf-8'))
        print('Error:')
        print(p.stderr.decode('utf-8'))
        sys.exit(1)

def extract_libs(src_file_name):
    with open(src_file_name, 'r') as src_file:
        for line in src_file.readlines():
            if re.match(r"\s*;\s*libs?\s*:", line, re.IGNORECASE):
                return [it.strip() for it in line.split(':')[1].split(', ')]
    return []

def build(args):
    ensure_obj_file(args.src)
    libs = extract_libs(args.src)
    command = ['ld65', '-vm', '-m', args.map, '-C', args.config, '-o', args.output, 
               '--obj', get_obj_file_name(args.src), '--obj-path', 'lib']
    for lib in libs:
        ensure_obj_file(f"lib/{lib}.a65")
        command.extend(['--obj', f"{lib}.o"])
    p = subprocess.run(command, capture_output=True)
    exit_code = p.returncode
    if exit_code != 0:
        print(f"Fail to link {args.src}:")
        print(p.stdout.decode('utf-8'))
        print('Error:')
        print(p.stderr.decode('utf-8'))
        sys.exit(1)

build(parse_args())
