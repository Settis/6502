#!/usr/bin/python

import sys
import serial
import time
import logging


INVALID_COMMAND = 0
TICK_COMMAND = 1
DATA_WRITE_COMMAND = 2
DATA_READ_COMMAND = 3
RESET_COMMAND = 4

OK_RESULT = 5
FAIL_RESULT = 6
PROG_END_RESULT = 7


class Runner:
    def __init__(self, prog):
        self.port = serial.Serial('/dev/ttyACM0', 9600, timeout=None)
        self.prog = prog

    def data_write(self, addr, data):
        self.port.write(bytes([DATA_WRITE_COMMAND, addr >> 8, addr & 0xFF, data]))
        self.wait()

    def data_read(self, addr):
        self.port.write(bytes([DATA_READ_COMMAND, addr >> 8, addr & 0xFF]))
        self.wait()
        return self.read_byte()

    def reset(self):
        self.port.write(bytes([RESET_COMMAND]))
        self.wait()

    def tick(self, ticks):
        command = []
        for i in range(4):
            command.insert(0, ticks & 0xFF)
            ticks >>= 8
        command.insert(0, TICK_COMMAND)
        logging.debug("Tick loop started")
        start = time.time()
        self.port.write(bytes(command))
        result = self.wait()
        stop = time.time()
        logging.debug("Tick loop ended")
        passed_ticks = 0
        for i in range(4):
            passed_ticks <<= 8
            received = self.read_byte()
            logging.debug(f"Received {received:02x}")
            passed_ticks += received
        logging.info(f"Passed {passed_ticks} ticks in {stop - start} ms")
        logging.info(f"Freq {passed_ticks/(stop - start)}")
        return result != PROG_END_RESULT

    def wait(self):
        return_code = self.read_byte()
        if return_code == FAIL_RESULT:
            logging.error("Fail from Arduino")
            raise Exception("Fail result")
        return return_code

    def read_byte(self):
        return self.port.read(1)[0]

    def run(self):
        self.test()
        logging.info("Writing program to Arduino")
        with open(self.prog, 'rb') as f:
            pointer = f.read(1)[0] + f.read(1)[0]*0x100
            while byte := f.read(1):
                self.data_write(pointer, byte[0])
                logging.debug(f"to Ard: addr {pointer:04x}")
                pointer += 1
        logging.info("Resetting 6502")
        self.reset()

        logging.info("Running...")
        while self.tick(10000):
            # input("Press Enter to continue...")
            pass

        logging.info("Done")
        self.print_zp()

    def test(self):
        logging.info("Testing")
        self.test_memory(0x0001, 0xAA)
        self.test_memory(0x0002, 0x99)
        self.test_memory(0xFFF4, 0x11)
        self.test_memory(0xFFF7, 0xFF)
        logging.info("Testing done")

    def test_memory(self, addr, data):
        self.data_write(addr, data)
        actual = self.data_read(addr)
        if data != actual:
            logging.error(f"Fail to check addr {addr:04x}. Expected: {data:02x}, actual: {actual:02x}.")
            raise Exception("Memory check fail")

    def print_zp(self):
        ind = 0
        while ind < 0xff:
            print(f"{ind:02x}: ", end='')
            for i in range(8):
                print(f"{self.data_read(ind):02x} ", end='')
                ind += 1
            print(' ', end='')
            for i in range(8):
                print(f"{self.data_read(ind):02x} ", end='')
                ind += 1
            print()


if __name__ == '__main__':
    logging.basicConfig(level=logging.DEBUG)
    Runner(sys.argv[1]).run()
