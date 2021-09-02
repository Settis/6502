#!/usr/bin/python

import sys
import serial
import time


INVALID_COMMAND = 0
TICK_COMMAND = 1
DATA_WRITE_COMMAND = 2
CPU_READ_COMMAND = 3
CPU_WRITE_COMMAND = 4
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
VPA_COMMAND_FLAG = 0x80
VDA_COMMAND_FLAG = 0x40


class Command:
    def __init__(self, command):
        self.cmd = command & 0x0F
        self.vpa = bool(command & VPA_COMMAND_FLAG)
        self.vda = bool(command & VDA_COMMAND_FLAG)

    def suffix(self):
        result = ""
        if self.vpa:
            result += "VPA "
        if self.vda:
            result += "VDA"
        return result


class Emulator:
    def __init__(self):
        self.memory = {}
        self.port = serial.Serial('/dev/ttyACM0', 9600, timeout=None)
        self.commands = {
            CPU_READ_COMMAND: self.handle_read,
            CPU_WRITE_COMMAND: self.handle_write,
            INVALID_COMMAND: self.handle_invalid,
        }

    def run(self):
        self.enable_clock()
        self.enable_cpu_bus()
        self.port.write(bytes([RESET_COMMAND]))
        self.port.write(bytes([TICK_COMMAND]))
        while True:
            data = self.port.read(1)[0]
            # print(f"Read data: {data:02x}")
            command = Command(data)
            self.commands.get(command.cmd, self.unknown)(command)
            self.port.write(bytes([TICK_COMMAND]))

    def handle_read(self, command):
        addr = self.read_serial_addr()
        print(f"R {addr:04x} | {command.suffix()}")

    def handle_write(self, command):
        addr = self.read_serial_addr()
        data = self.read_serial_data()
        print(f"W {addr:04x} : {data:02x} | {command.suffix()}")

    def read_serial_addr(self):
        rawData = self.port.read(2)
        return (rawData[0] << 8) + rawData[1]

    def read_serial_data(self):
        return self.port.read(1)[0]

    @staticmethod
    def unknown(command):
        print(f"Unknown command: {command.cmd}")

    @staticmethod
    def handle_invalid(data):
        print("Invalid command")

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
        self.enable_clock()
        self.disable_cpu_bus()
        with open(file_name, 'rb') as f:
            pointer = f.read(1)[0] + f.read(1)[0]*0x100
            while byte := f.read(1):
                self.port.write(bytes([RAM_WRITE_COMMAND, pointer // 0x100, pointer % 0x100, byte[0]]))
                command = self.read_serial_data()
                if command != DONE_COMMAND:
                    print(f"Bad command: {command}")
                pointer += 1
        self.enable_cpu_bus()
        self.port.write(bytes([RESET_COMMAND]))
        self.disable_clock()

    def clean(self):
        self.enable_clock()
        self.disable_cpu_bus()
        for i in range(0x100):
            self.port.write(bytes([RAM_WRITE_COMMAND, 0, i, 0]))
            command = self.read_serial_data()
            if command != DONE_COMMAND:
                print(f"Bad command: {command}")
        self.disable_clock()

    def show_zp(self):
        self.show_page(0)

    def show_page(self, number):
        self.enable_clock()
        self.disable_cpu_bus()
        for i in range(0x100):
            self.port.write(bytes([RAM_READ_COMMAND, number, i]))
            command = self.read_serial_data()
            if command != BUS_DATA_COMMAND:
                print(f"Bad comamnd: {command}")
            self.memory[i] = self.read_serial_data()
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
        command = self.read_serial_data()
        if command != DONE_COMMAND:
            print(f"Bad comamnd: {command}")


if __name__ == '__main__':
    if len(sys.argv) > 1:
        if sys.argv[1].lower().startswith("w"):
            Emulator().write_default()
        if sys.argv[1].lower().startswith('r'):
            Emulator().show_zp()
        if sys.argv[1].lower().startswith('s'):
            Emulator().run()
        if sys.argv[1].lower().startswith('c'):
            Emulator().clean()
    else:
        print("Use with 'write' or 'read' or 'steps' or 'clean'")
