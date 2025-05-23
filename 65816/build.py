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

def obj_is_actual(src_file_name):
    obj_file_name = get_obj_file_name(src_file_name)
    if not os.path.exists(obj_file_name):
        return False
    obj_time = os.path.getmtime(obj_file_name)
    if obj_time < os.path.getmtime(src_file_name):
        return False
    src_file_dir = os.path.dirname(src_file_name)
    with open(src_file_name, 'r') as src_file:
        for line in src_file.readlines():
            match = re.match(r"\s*\.(?:include|incbin)\s+\"(.+)\"", line)
            if match:
                included_file = match.group(1)
                included_file_name = os.path.normpath(os.path.join(src_file_dir, included_file))
                if obj_time < os.path.getmtime(included_file_name):
                    return False
    return True

def ensure_obj_file(src_file_name):
    if obj_is_actual(src_file_name):
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
               '--obj', get_obj_file_name(args.src), '--obj-path', 'lib', '--dbgfile', '/tmp/debug65.txt']
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
