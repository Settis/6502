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
        self.ticks = 0
        self.memory = {}
        self.port = serial.Serial('/dev/ttyACM0', 9600, timeout=None)

    def run(self):
        for i in range(0xFF):
            self.port.write(bytes([RAM_READ_COMMAND, 0, i]))
            command = self.read_serial_data()
            if command != BUS_DATA_COMMAND:
                print(f"Bad comamnd: {command}")
            self.memory[i] = self.read_serial_data()
        self.print_zp()
        for i in range(0xFF):
            self.port.write(bytes([RAM_WRITE_COMMAND, 0, i, 0]))
            command = self.read_serial_data()
            if command != DONE_COMMAND:
                print(f"Bad comamnd: {command}")

        for i in range(0xFF):
            self.port.write(bytes([RAM_READ_COMMAND, 0, i]))
            command = self.read_serial_data()
            if command != BUS_DATA_COMMAND:
                print(f"Bad comamnd: {command}")
            self.memory[i] = self.read_serial_data()
        self.print_zp()

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


if __name__ == '__main__':
    Emulator().run()
