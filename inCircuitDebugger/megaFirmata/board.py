import pyfirmata


class RawByte:
    def __init__(self, arduino, pins):
        """
        Pins from high to low: 7, 6 .. 0
        """
        self.arduino = arduino
        self.pins = pins
        self.read_mode()

    def read_mode(self):
        for pin in self.pins:
            self.arduino.digital[pin].mode = pyfirmata.INPUT


class Board:
    def __init__(self):
        layout = {
            'digital' : tuple(x for x in range(70)),
            'analog' : tuple(x for x in range(16)),
            'pwm' : tuple(x for x in range(2,14)),
            'use_ports' : True,
            'disabled' : (0, 1, 14, 15) # Rx, Tx, Crystal
        }
        self.arduino = pyfirmata.Board('/dev/ttyACM0', layout)
        self.it = pyfirmata.util.Iterator(self.arduino)
        self.it.start()

        self.rw = self.arduino.digital[38]
        self.rw.mode = pyfirmata.INPUT
        self.reset = self.arduino.digital[39]
        self.reset.mode = pyfirmata.INPUT
        self.vpa = self.arduino.digital[40]
        self.vpa.mode = pyfirmata.INPUT
        self.vda = self.arduino.digital[41]
        self.vda.mode = pyfirmata.INPUT
        self.irq = self.arduino.digital[50]
        self.irq.mode = pyfirmata.INPUT
        self.nmi = self.arduino.digital[51]
        self.nmi.mode = pyfirmata.INPUT
        self.rom_w = self.arduino.digital[52]
        self.rom_w.mode = pyfirmata.INPUT
        self.be = self.arduino.digital[53]
        # change it in future after I fix the board
        self.be.mode = pyfirmata.OUTPUT
        self.be.write(1)
        self.clock_enable = self.arduino.digital[60]
        self.clock_enable.mode = pyfirmata.OUTPUT
        self.clock_enable.write(0)
        self.clock = self.arduino.digital[61]
        self.clock.mode = pyfirmata.OUTPUT
        self.clock.write(0)

        self.data = RawByte(self.arduino, range(42, 50))
        self.addr_hi = RawByte(self.arduino, range(29, 21, -1))
        self.addr_lo = RawByte(self.arduino, range(30, 38))

        self.do_reset()

    def do_reset(self):
        self.tick()
        self.reset.mode = pyfirmata.OUTPUT
        self.reset.write(0)
        for i in range(5):
            self.tick()
        self.reset.mode = pyfirmata.INPUT

    def tick(self):
        self.clock.write(0)
        self.clock.write(1)
