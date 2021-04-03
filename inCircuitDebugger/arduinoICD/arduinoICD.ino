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

class ShiftReg {
  public:
    ShiftReg(int oePin, int s0Pin, int s1Pin, int clockPin, int qPin, int dsPin, int size);
    void write(int data);
    int read();
    void outputEnable();
    void outputDisable();
    void tick();
    void shiftEnable();
    void hold();
    void parallelLoad();
  private:
    int _oePin;
    int _s0Pin;
    int _s1Pin;
    int _clockPin;
    int _qPin;
    int _dsPin;
    int _size;
};

ShiftReg::ShiftReg(int oePin, int s0Pin, int s1Pin, int clockPin, int qPin, int dsPin, int size) {
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
  digitalWrite(_clockPin, HIGH);
  digitalWrite(_clockPin, LOW);
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
  for (int i = 0; i < _size; i++) {
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
  for (int i = 0; i < _size; i++) {
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
#define CPU_READ_COMMAND 3
#define CPU_WRITE_COMMAND 4
#define RESET_COMMAND 5

#define VPA_COMMAND_FLAG 0x80
#define VDA_COMMAND_FLAG 0x40

void loop() {
  if (Serial.available()) {
    int commandByte = Serial.read();
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
    }
  }
}

void tickCPUCommand() {
  int vpa;
  int vda;
  do {
    tickCPU();
    vpa = digitalRead(VPA_PIN);
    vda = digitalRead(VDA_PIN);
  } while (vpa + vda == 0);
  int addr = addrReg.read();
  int rw = digitalRead(RW_PIN);
  if (rw == 0) {
    int data = dataReg.read();
    Serial.write(CPU_WRITE_COMMAND + vpa * VPA_COMMAND_FLAG + vda * VDA_COMMAND_FLAG);
    Serial.write((addr >> 8) & 0xFF);
    Serial.write(addr & 0xFF);
    Serial.write(data);
  } else {
    Serial.write(CPU_READ_COMMAND + vpa * VPA_COMMAND_FLAG + vda * VDA_COMMAND_FLAG);
    Serial.write((addr >> 8) & 0xFF);
    Serial.write(addr & 0xFF);
  }
}

void handleDataWriteCommand() {
  int data = -1;
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
  tickCPUCommand();
}

void tickCPU() {
  digitalWrite(CPU_CLOCK_PIN, LOW);
  dataReg.outputDisable();
  digitalWrite(CPU_CLOCK_PIN, HIGH);
}
