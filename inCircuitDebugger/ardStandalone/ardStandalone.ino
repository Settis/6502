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

#define RESET_TICK_COUNT 6
#define RESET_SEQUENCE_PREFIX_TICK_COUNT 5

#define RW_READ 1
#define RW_WRITE 0

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
  Serial.begin(9600);
}

#define INVALID_COMMAND 0
#define TICK_COMMAND 1
#define DATA_WRITE_COMMAND 2
#define DATA_READ_COMMAND 3
#define RESET_COMMAND 4

#define OK_RESULT 5
#define FAIL_RESULT 6
#define PROG_END_RESULT 7

#define RAM_PAGES 2
#define ROM_PAGES 4

byte memory[RAM_PAGES + ROM_PAGES][256];
byte currentTickSerialized[4];

void loop() {
  if (Serial.available()) {
    delay(10);
    byte commandByte = Serial.read();
    switch(commandByte) {
      case TICK_COMMAND:
        tickCPUCommand();
        break;
      case DATA_WRITE_COMMAND:
        handleDataWriteCommand();
        break;
      case DATA_READ_COMMAND:
        handleDataReadCommand();
        break;
      case RESET_COMMAND:
        handleResetCommand();
        break;
    }
  }
}

void tickCPUCommand() {
  int requiredTicks = (((((Serial.read() << 8) + Serial.read()) << 8) + Serial.read()) << 8) + Serial.read();
  int currentTick = 0;
  byte vpa = digitalRead(VPA_PIN);
  byte vda = digitalRead(VDA_PIN);
  byte rw;
  int addr;
  int data;
  int memPosition;
  boolean ended = false;
  do {
    addr = addrReg.read();
    rw = digitalRead(RW_PIN);
    memPosition = getMemPosition(addr >> 8);
    if (memPosition !=  -1) {
      if (rw == RW_WRITE) {
        data = dataReg.read();
        memory[memPosition][addr & 0xFF] = data;
      } else {
        data = memory[memPosition][addr & 0xFF];
        if ( vpa + vda == 2 && data == 0xFF) {
          ended = true;
          break;
        }
        dataReg.write(memory[memPosition][addr & 0xFF]);
      }
    }
    do {
      tickCPU();
      vpa = digitalRead(VPA_PIN);
      vda = digitalRead(VDA_PIN);
    } while (vpa + vda == 0);
    currentTick ++;
  } while (currentTick < requiredTicks);

  if (ended) {
    Serial.write(PROG_END_RESULT);
  } else {
    Serial.write(OK_RESULT);
  }

  for (int i = 3; i>=0; i--) {
    currentTickSerialized[i] = currentTick & 0xFF;
    currentTick >>= 8;
  }
  Serial.write(currentTickSerialized, 4);
}

void handleDataWriteCommand() {
  int hAddr = getMemPosition(Serial.read());
  byte lAddr = Serial.read();
  byte data = Serial.read();
  if (hAddr == -1){
    Serial.write(FAIL_RESULT);
  } else {
    memory[hAddr][lAddr] = data;
    Serial.write(OK_RESULT);
  }
}

void handleDataReadCommand() {
  int hAddr = getMemPosition(Serial.read());
  byte lAddr = Serial.read();
  if (hAddr == -1){
    Serial.write(FAIL_RESULT);
  } else {
    byte data = memory[hAddr][lAddr];
    Serial.write(OK_RESULT);
    Serial.write(data);
  }
}

int getMemPosition(byte original) {
  if (original < RAM_PAGES) return original;
  if (original > 256 - ROM_PAGES) return original - (256-ROM_PAGES) + RAM_PAGES - 1;
  return -1;
}

void handleResetCommand() {
  pinMode(RESET_PIN, OUTPUT);
  digitalWrite(RESET_PIN, LOW);
  for (int i = 0; i <= RESET_TICK_COUNT; i++)
    tickCPU();
  pinMode(RESET_PIN, INPUT);
  for (int i = 0; i < RESET_SEQUENCE_PREFIX_TICK_COUNT; i++)
    tickCPU();
  Serial.write(OK_RESULT);
}

void tickCPU() {
  digitalWrite(CPU_CLOCK_PIN, LOW);
  dataReg.outputDisable();
  digitalWrite(CPU_CLOCK_PIN, HIGH);
}
