import sys
import serial
import time


INVALID_COMMAND = 0
TICK_COMMAND = 1
DATA_WRITE_COMMAND = 2
CPU_READ_COMMAND = 3
CPU_WRITE_COMMAND = 4
RESET_COMMAND = 5
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
    def __init__(self, prog):
        self.ticks = 0
        self.memory = {}
        with open(prog, 'rb') as f:
            pointer = f.read(1)[0] + f.read(1)[0]*0x100
            while byte := f.read(1):
                self.memory[pointer] = byte[0]
                pointer += 1
        self.port = serial.Serial('/dev/ttyACM0', 9600, timeout=None)
        self.proceed = True
        self.command = []
        self.commands = {
            CPU_READ_COMMAND: self.handle_read,
            CPU_WRITE_COMMAND: self.handle_write,
            INVALID_COMMAND: self.handle_invalid,
        }

    def run(self):
        self.port.write(bytes([RESET_COMMAND]))
        # self.port.write(bytes([TICK_COMMAND, 0]))
        start = time.time()
        command_count = 0
        while self.proceed:
            data = self.port.read(1)[0]
            # print(f"Read data: {data:02x}")
            command = Command(data)
            command_count += 1
            self.commands.get(command.cmd, self.unknown)(command)
            # time.sleep(0.5)
        end = time.time()
        self.print_zp()
        print(f"Running time: {end - start}")
        print(f"Freq: {command_count / (end - start)}")

    def handle_read(self, command):
        addr = self.read_serial_addr()
        data = self.memory.get(addr, 0)
        print(f"R {addr:04x} : {data:02x} | {command.suffix()}")
        if command.vpa & command.vda & (data == 0xff):
            self.proceed = False
        else:
            self.port.write(bytes([DATA_WRITE_COMMAND, data]))

    def handle_write(self, command):
        addr = self.read_serial_addr()
        data = self.read_serial_data()
        self.memory[addr] = data
        print(f"W {addr:04x} : {data:02x} | {command.suffix()}")
        self.port.write(bytes([TICK_COMMAND]))

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
    Emulator(sys.argv[1]).run()
