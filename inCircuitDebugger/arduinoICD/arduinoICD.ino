#define OE_ADDR_PIN 11
#define OE_DATA_PIN 4
#define S0_ADDR_PIN 10
#define S0_DATA_PIN 3
#define S1_ADDR_PIN 7
#define S1_DATA_PIN 6
#define SHIFT_CLOCK_PIN 9
#define Q_ADDR_PIN 12
#define Q_DATA_PIN 5
#define DS_SHIFT_PIN 8
#define CPU_CLOCK_PIN 13
#define RW_PIN 18
#define RESET_PIN 19
#define VPA_PIN 20
#define VDA_PIN 21
#define ROM_RW_PIN 14
#define CPU_BUS_ENABLE_PIN 15

#define RESET_TICK_COUNT 6

class ShiftReg {
  public:
    ShiftReg(byte oePin, byte s0Pin, byte s1Pin, byte clockPin, byte qPin, byte dsPin, byte size);
    void write(int data);
    int read();
    inline void outputDisable() __attribute__((always_inline));
  private:
    byte _oePin;
    byte _s0Pin;
    byte _s1Pin;
    byte _clockPin;
    byte _qPin;
    byte _dsPin;
    byte _size;
    inline void outputEnable() __attribute__((always_inline));
    inline void tick() __attribute__((always_inline));
    inline void shiftEnable() __attribute__((always_inline));
    inline void hold() __attribute__((always_inline));
    inline void parallelLoad() __attribute__((always_inline));
};

ShiftReg::ShiftReg(byte oePin, byte s0Pin, byte s1Pin, byte clockPin, byte qPin, byte dsPin, byte size) {
  pinMode(oePin, OUTPUT);
  digitalWrite(oePin, HIGH);
  _oePin = oePin;
  pinMode(s0Pin, OUTPUT);
  digitalWrite(s0Pin, LOW);
  _s0Pin = s0Pin;
  pinMode(s1Pin, OUTPUT);
  digitalWrite(s1Pin, LOW);
  _s1Pin = s1Pin;
  pinMode(clockPin, OUTPUT);
  digitalWrite(clockPin, LOW);
  _clockPin = clockPin;
  pinMode(qPin, INPUT);
  _qPin = qPin;
  pinMode(dsPin, OUTPUT);
  digitalWrite(dsPin, LOW);
  _dsPin = dsPin;
  _size = size;
};

void ShiftReg::outputEnable() {
  digitalWrite(_oePin, LOW);
}

void ShiftReg::outputDisable() {
  digitalWrite(_oePin, HIGH);
}

void ShiftReg::tick() {
  //digitalWrite(_clockPin, HIGH);

  PORTB |= B00100000;
  //digitalWrite(_clockPin, LOW); 
  PORTB &= B11011111;
}

void ShiftReg::shiftEnable() {
  digitalWrite(_s0Pin, LOW);
  digitalWrite(_s1Pin, HIGH);
}

void ShiftReg::hold() {
  digitalWrite(_s0Pin, LOW);
  digitalWrite(_s1Pin, LOW);
}

void ShiftReg::parallelLoad() {
  digitalWrite(_s0Pin, HIGH);
  digitalWrite(_s1Pin, HIGH);
}

void ShiftReg::write(int data) {
  shiftEnable();
  for (byte i = 0; i < _size; i++) {
    digitalWrite(_dsPin, data & 1);
    tick();
    data = data >> 1;
  }
  hold();
  outputEnable();
}

int ShiftReg::read() {
  outputDisable();
  parallelLoad();
  tick();
  shiftEnable();
  int pos = 1;
  int result = 0;
  for (byte i = 0; i < _size; i++) {
    if (digitalRead(_qPin))
      result += pos;
    pos = pos << 1;
    tick();
  }
  hold();
  return result;
}

ShiftReg addrReg(OE_ADDR_PIN, S0_ADDR_PIN, S1_ADDR_PIN, SHIFT_CLOCK_PIN, Q_ADDR_PIN, DS_SHIFT_PIN, 16);
ShiftReg dataReg(OE_DATA_PIN, S0_DATA_PIN, S1_DATA_PIN, SHIFT_CLOCK_PIN, Q_DATA_PIN, DS_SHIFT_PIN, 8);

void setup() {
  pinMode(CPU_CLOCK_PIN, OUTPUT);
  digitalWrite(CPU_CLOCK_PIN, LOW);
  pinMode(RW_PIN, INPUT);
  pinMode(RESET_PIN, INPUT);
  pinMode(VPA_PIN, INPUT);
  pinMode(VDA_PIN, INPUT);
  pinMode(ROM_RW_PIN, INPUT);
  pinMode(CPU_BUS_ENABLE_PIN, OUTPUT);
  digitalWrite(CPU_BUS_ENABLE_PIN, LOW);
  Serial.begin(9600);
}

#define INVALID_COMMAND 0
#define TICK_COMMAND 1
#define DATA_WRITE_COMMAND 2
#define CPU_READ_COMMAND 3
#define CPU_WRITE_COMMAND 4
#define RESET_COMMAND 5
#define RAM_READ_COMMAND 6
#define RAM_WRITE_COMMAND 7
#define BUS_DATA_COMMAND 8
#define DONE_COMMAND 9
#define ROM_WRITE_COMMAND 10
#define DISABLE_CLOCK_COMMAND 11
#define ENABLE_CLOCK_COMMAND 12
#define CPU_BUS_ENABLE_COMMAND 13
#define CPU_BUS_DISABLE_COMMAND 14

#define VPA_COMMAND_FLAG 0x80
#define VDA_COMMAND_FLAG 0x40

#define VPA_COMMAND_FLAG_OFFSET 7
#define VDA_COMMAND_FLAG_OFFSET 7

void loop() {
  if (Serial.available()) {
    byte commandByte = Serial.read();
    switch(commandByte) {
      case TICK_COMMAND:
        tickCPUCommand();
        break;
      case DATA_WRITE_COMMAND:
        handleDataWriteCommand();
        break;
      case RESET_COMMAND:
        handleResetCommand();
        break;
      case RAM_READ_COMMAND:
        handleRamReadCommand();
        break;
      case RAM_WRITE_COMMAND:
        handleRamWriteCommand();
        break;
      case ROM_WRITE_COMMAND:
        handleRomWriteCommand();
        break;
      case DISABLE_CLOCK_COMMAND:
        handleDisableClockCommand();
        break;
      case ENABLE_CLOCK_COMMAND:
        handleEnableClockCommand();
        break;
      case CPU_BUS_ENABLE_COMMAND:
        handleEnableCpuBusCommand();
        break;
      case CPU_BUS_DISABLE_COMMAND:
        handleDisableCpuBusCommand();
        break;
    }
  }
}

byte commandToWrite[4];

void tickCPUCommand() {
  byte vpa;
  byte vda;
  do {
    tickCPU();
    vpa = digitalRead(VPA_PIN);
    vda = digitalRead(VDA_PIN);
  } while (vpa + vda == 0);
  int addr = addrReg.read();
  byte rw = digitalRead(RW_PIN);
  if (rw == 0) {
    int data = dataReg.read();
    commandToWrite[0] = CPU_WRITE_COMMAND + vpa * VPA_COMMAND_FLAG + vda * VDA_COMMAND_FLAG;
    commandToWrite[1] = (addr >> 8) & 0xFF;
    commandToWrite[2] = addr & 0xFF;
    commandToWrite[3] = data;
    Serial.write(commandToWrite, 4);
  } else {
    commandToWrite[0] = CPU_READ_COMMAND + vpa * VPA_COMMAND_FLAG + vda * VDA_COMMAND_FLAG;
    commandToWrite[1] = (addr >> 8) & 0xFF;
    commandToWrite[2] = addr & 0xFF;
    Serial.write(commandToWrite, 3);
  }
}

void handleDataWriteCommand() {
  byte data = -1;
  do {
    data = Serial.read();
  } while (data == -1);
  dataReg.write(data);
  tickCPUCommand();
}

void handleResetCommand() {
  pinMode(RESET_PIN, OUTPUT);
  digitalWrite(RESET_PIN, LOW);
  for (int i = 0; i <= RESET_TICK_COUNT; i++)
    tickCPU();
  pinMode(RESET_PIN, INPUT);
  // tickCPUCommand();
}

void tickCPU() {
  digitalWrite(CPU_CLOCK_PIN, LOW);
  dataReg.outputDisable();
  digitalWrite(CPU_CLOCK_PIN, HIGH);
}

void handleRamReadCommand() {
  int addr = (Serial.read() << 8) + Serial.read();
  digitalWrite(CPU_CLOCK_PIN, LOW);
  pinMode(RW_PIN, OUTPUT);
  digitalWrite(RW_PIN, HIGH);
  addrReg.write(addr);
  digitalWrite(CPU_CLOCK_PIN, HIGH);
  int data = dataReg.read();
  digitalWrite(CPU_CLOCK_PIN, LOW);
  commandToWrite[0] = BUS_DATA_COMMAND;
  commandToWrite[1] = data;
  pinMode(RW_PIN, INPUT);
  addrReg.outputDisable();
  Serial.write(commandToWrite, 2);
}

void handleRamWriteCommand() {
  int addr = (Serial.read() << 8) + Serial.read();
  int data = Serial.read();
  digitalWrite(CPU_CLOCK_PIN, LOW);
  pinMode(RW_PIN, OUTPUT);
  digitalWrite(RW_PIN, LOW);
  addrReg.write(addr);
  dataReg.write(data);
  digitalWrite(CPU_CLOCK_PIN, HIGH);
  digitalWrite(CPU_CLOCK_PIN, LOW);
  commandToWrite[0] = DONE_COMMAND;
  pinMode(RW_PIN, INPUT);
  addrReg.outputDisable();
  dataReg.outputDisable();
  Serial.write(commandToWrite, 1);
}

void handleRomWriteCommand() {
  int addr = (Serial.read() << 8) + Serial.read();
  int data = Serial.read();
  digitalWrite(CPU_CLOCK_PIN, LOW);
  pinMode(ROM_RW_PIN, OUTPUT);
  digitalWrite(ROM_RW_PIN, LOW);
  addrReg.write(addr);
  dataReg.write(data);
  digitalWrite(CPU_CLOCK_PIN, HIGH);
  digitalWrite(CPU_CLOCK_PIN, LOW);
  commandToWrite[0] = DONE_COMMAND;
  pinMode(ROM_RW_PIN, INPUT);
  addrReg.outputDisable();
  dataReg.outputDisable();
  Serial.write(commandToWrite, 1);
}

void handleDisableClockCommand() {
  pinMode(CPU_CLOCK_PIN, INPUT);
  commandToWrite[0] = DONE_COMMAND;
  Serial.write(commandToWrite, 1);
}

void handleEnableClockCommand() {
  pinMode(CPU_CLOCK_PIN, OUTPUT);
  commandToWrite[0] = DONE_COMMAND;
  Serial.write(commandToWrite, 1);
}

void handleEnableCpuBusCommand() {
  digitalWrite(CPU_BUS_ENABLE_PIN, HIGH);
  commandToWrite[0] = DONE_COMMAND;
  Serial.write(commandToWrite, 1);
}

void handleDisableCpuBusCommand() {
  digitalWrite(CPU_BUS_ENABLE_PIN, LOW);
  commandToWrite[0] = DONE_COMMAND;
  Serial.write(commandToWrite, 1);
}
