#!/usr/bin/python

import sys
import serial
import time


INVALID_COMMAND = 0
TICK_COMMAND = 1
BUS_STATUS_COMMAND = 2
RESET_COMMAND = 5
RAM_READ_COMMAND = 6
RAM_WRITE_COMMAND = 7
BUS_DATA_COMMAND = 8
DONE_COMMAND = 9
ROM_WRITE_COMMAND = 10
DISABLE_CLOCK_COMMAND = 11
ENABLE_CLOCK_COMMAND = 12
CPU_BUS_ENABLE_COMMAND = 13
CPU_BUS_DISABLE_COMMAND = 14

RW_MASK = 4
IRQ_MASK = 8
NMI_MASK = 0x10


class Emulator:
    def __init__(self):
        self.memory = {}
        self.port = serial.Serial('/dev/ttyACM1', 9600, timeout=None)

    def steps(self):
        self.enable_cpu_bus()
        self.reset()
        while True:
            self.port.write(bytes([TICK_COMMAND]))
            command = self.read_serial()
            if command != BUS_STATUS_COMMAND:
                print(f"Invalid tick response: ${command}")
                sys.exit(1)
            address = (self.read_serial() << 8) + self.read_serial()
            data = self.read_serial()
            flags = self.read_serial()
            print(f"A: {address:04x} D: {data:02x} | {Emulator.print_flags(flags)}")
            if (flags & 0x3 == 0x3) and data == 0xFF:
                sys.exit(0)

    def reset(self):
        self._send_command(RESET_COMMAND)

    @staticmethod
    def print_flags(flags):
        result = ""
        if flags & RW_MASK:
            result = "R "
        else:
            result = "W "
        valid_address = flags & 0x3
        if valid_address == 3:
            result += "OPCODE   "
        if valid_address == 2:
            result += "PROGRAM  "
        if valid_address == 1:
            result += "DATA     "
        if valid_address == 0:
            result += "INTERNAL "
        if not flags & IRQ_MASK:
            result += "IRQ "
        if not flags & NMI_MASK:
            result += "NMI"
        return result

    def read_serial(self):
        return self.port.read(1)[0]

    def print_zp(self):
        ind = 0
        while ind < 0xff:
            print(f"{ind:02x}: ", end='')
            for i in range(8):
                print(f"{self.memory.get(ind,0):02x} ", end='')
                ind += 1
            print(' ', end='')
            for i in range(8):
                print(f"{self.memory.get(ind,0):02x} ", end='')
                ind += 1
            print()

    def write_prog(self, file_name):
        self.disable_cpu_bus()
        with open(file_name, 'rb') as f:
            pointer = f.read(1)[0] + f.read(1)[0]*0x100
            while byte := f.read(1):
                self.port.write(bytes([RAM_WRITE_COMMAND, pointer // 0x100, pointer % 0x100, byte[0]]))
                command = self.read_serial()
                if command != DONE_COMMAND:
                    print(f"Bad command: {command}")
                pointer += 1

    def clean(self):
        self.disable_cpu_bus()
        for i in range(0x100):
            self.port.write(bytes([RAM_WRITE_COMMAND, 0, i, 0]))
            command = self.read_serial()
            if command != DONE_COMMAND:
                print(f"Bad command: {command}")

    def show_zp(self):
        self.show_page(0)

    def show_page(self, number):
        self.disable_cpu_bus()
        for i in range(0x100):
            self.port.write(bytes([RAM_READ_COMMAND, number, i]))
            command = self.read_serial()
            if command != BUS_DATA_COMMAND:
                print(f"Bad comamnd: {command}")
            self.memory[i] = self.read_serial()
        self.print_zp()

    def write_default(self):
        self.write_prog('/home/stk/projects/8-bit/6502/hard/prog/a.out')

    def disable_clock(self):
        self._send_command(DISABLE_CLOCK_COMMAND)

    def enable_clock(self):
        self._send_command(ENABLE_CLOCK_COMMAND)

    def disable_cpu_bus(self):
        self._send_command(CPU_BUS_DISABLE_COMMAND)

    def enable_cpu_bus(self):
        self._send_command(CPU_BUS_ENABLE_COMMAND)

    def _send_command(self, command_id):
        self.port.write(bytes([command_id]))
        time.sleep(0.1)
        command = self.read_serial()
        if command != DONE_COMMAND:
            print(f"Bad comamnd: {command}")


if __name__ == '__main__':
    if len(sys.argv) > 1:
        if sys.argv[1].lower().startswith("w"):
            Emulator().write_default()
        if sys.argv[1].lower().startswith('r'):
            Emulator().show_zp()
        if sys.argv[1].lower().startswith('s'):
            Emulator().steps()
        if sys.argv[1].lower().startswith('c'):
            Emulator().clean()
    else:
        print("Use with 'write' or 'read' or 'steps' or 'clean'")
