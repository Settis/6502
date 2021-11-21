#include <LiquidCrystal.h>

const int LCD_NB_ROWS = 2;
const int LCD_NB_COLUMNS = 16;
const int rs = 8, en = 9, d4 = 4, d5 = 5, d6 = 6, d7 = 7;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

const int RIGHT_KEY = 1, UP_KEY = 2, DOWN_KEY = 3, LEFT_KEY = 4, SELECT_KEY = 5;

const int RWB_PIN = 38;
const int RESB_PIN = 39;
const int VPA_PIN = 40;
const int VDA_PIN = 41;
const int IRQ_PIN = 50;
const int NMI_PIN = 51;
const int ROM_W_PIN = 52;
const int BE_PIN = 53;
const int CLOCK_ENABLE_PIN = 60;
const int CLOCK_PIN = 61;

const int PROC_OPCODE_ADDR = 3, PROC_PROG_ADDR = 2, PROC_DATA_ADDR = 1, PROC_INTERNAL_ADDR = 0;

bool userAction = false;
bool pcActionShowed = false;
unsigned long lastPcCommand = 0;

void setup() {
  lcd.begin(LCD_NB_COLUMNS, LCD_NB_ROWS);
  lcd.clear();
  setAddressToReadState();
  setDataToReadState();
  pinMode(RWB_PIN, INPUT);
  pinMode(RESB_PIN, INPUT);
  pinMode(VPA_PIN, INPUT);
  pinMode(VDA_PIN, INPUT);
  pinMode(IRQ_PIN, INPUT);
  pinMode(NMI_PIN, INPUT);
  pinMode(ROM_W_PIN, INPUT);
  pinMode(CLOCK_ENABLE_PIN, OUTPUT);
  digitalWrite(CLOCK_ENABLE_PIN, LOW);
  pinMode(CLOCK_PIN, OUTPUT);
  digitalWrite(CLOCK_PIN, LOW);
  pinMode(BE_PIN, OUTPUT);
  digitalWrite(BE_PIN, HIGH);
  reset();
  Serial.begin(9600);
  lcd.write("Ready");
  lcd.setCursor(1, 3);
  lcd.write("after reset");
}

int readKeyPressed() {
  int x;
  x = analogRead(0);
  if (x < 60) {
    return RIGHT_KEY;
  }
  else if (x < 200) {
    return UP_KEY;
  }
  else if (x < 400){
    return DOWN_KEY;
  }
  else if (x < 600){
    return LEFT_KEY;
  }
  else if (x < 800){
    return SELECT_KEY;
  }
  return 0;
}

void setAddressToReadState() {
  DDRA = 0;
  DDRC = 0;
}

void setDataToReadState() {
  DDRL = 0;
}

int readAddress() {
  return (readAddressHi() << 8) + readAddressLo();
}

int readAddressHi() {
  return PINA;
}

int readAddressLo() {
  return PINC;
}

int readData() {
  return PINL;
}

void writeAddressHi(int data) {
  DDRA = 0xFF;
  PORTA = data;
}

void writeAddressLo(int data) {
  DDRC = 0xFF;
  PORTC = data;
}

void writeData(int data) {
  DDRL = 0xFF;
  PORTL = data;
}

void reset() {
  pinMode(RESB_PIN, OUTPUT);
  digitalWrite(RESB_PIN, LOW);
  tick();
  tick();
  tick();
  tick();
  tick();
  pinMode(RESB_PIN, INPUT);
}

void tick() {
  digitalWrite(CLOCK_PIN, LOW);
  digitalWrite(CLOCK_PIN, HIGH);
}

int readProcVitrualAddr() {
  return (digitalRead(VPA_PIN) << 1) + digitalRead(VDA_PIN);
}

void printData() {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Addr: ");
  lcd.setCursor(0, 1);
  lcd.print("Data: ");
  char tmp[6];
  sprintf(tmp, "%04x", readAddress());
  lcd.setCursor(6, 0);
  lcd.print(tmp);
  sprintf(tmp, "%02x", readData());
  lcd.setCursor(6, 1);
  lcd.print(tmp);
  lcd.setCursor(12, 0);
  if (digitalRead(RWB_PIN)) {
    lcd.print('R');
  } else {
    lcd.print('W');
  }
  lcd.setCursor(9, 1);
  int procVirtualAddr = readProcVitrualAddr();
  if (procVirtualAddr == PROC_OPCODE_ADDR)
    lcd.print("OPCODE ");
  else if (procVirtualAddr == PROC_PROG_ADDR)
    lcd.print("PROGRAM");
  else if (procVirtualAddr == PROC_DATA_ADDR)
    lcd.print("DATA   ");
  else
    lcd.print("INTER  ");
}

#define INVALID_COMMAND 0
#define TICK_COMMAND 1
#define BUS_STATUS_COMMAND 2
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

#define RW_MASK 4
#define IRQ_MASK 8
#define NMI_MASK 0x10

void loop() {
  int keyPressed = readKeyPressed();
  if (keyPressed == SELECT_KEY) {
    userAction = true;
    pcActionShowed = false;
    tick();
    printData();
    delay(500);
  }
  if (keyPressed == DOWN_KEY) {
    digitalWrite(CLOCK_PIN, LOW);
    digitalWrite(CLOCK_ENABLE_PIN, HIGH);
  }
  if (Serial.available()) {
    delay(10);
    byte commandByte = Serial.read();
    switch(commandByte) {
      case TICK_COMMAND:
        handleTickCommand();
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
    userAction = false;
    lastPcCommand = millis();
  }
  updateDisplay();
}

void updateDisplay() {
  if (userAction) return;
  if (lastPcCommand == 0) return; 
  if (pcActionShowed) {
    if (lastPcCommand + 1000 < millis()) {
      lcd.clear();
      lcd.write("Ready");
      pcActionShowed = false;
    }
  } else {
    if (lastPcCommand + 1000 > millis()) {
      lcd.clear();
      lcd.write("PC commands");
      lcd.setCursor(1, 7);
      lcd.write("processing...");
      pcActionShowed = true;
    }
  }
}

void handleTickCommand() {
  do {
    tick();
  } while (readProcVitrualAddr() == 0);
  reportBusStatus();
}

void reportBusStatus() {
  Serial.write(BUS_STATUS_COMMAND);
  Serial.write(readAddressHi());
  Serial.write(readAddressLo());
  Serial.write(readData());
  int flags = readProcVitrualAddr();
  if (digitalRead(RWB_PIN))
    flags |= RW_MASK;
  if (digitalRead(IRQ_PIN))
    flags |= IRQ_MASK;
  if (digitalRead(NMI_PIN))
    flags |= NMI_MASK;
  Serial.write(flags);
}

void handleResetCommand() {
  reset();
  Serial.write(DONE_COMMAND);
}

void handleRamReadCommand() {
  digitalWrite(CLOCK_PIN, LOW);
  writeAddressHi(Serial.read());
  writeAddressLo(Serial.read());
  pinMode(RWB_PIN, OUTPUT);
  digitalWrite(RWB_PIN, HIGH);
  digitalWrite(CLOCK_PIN, HIGH);
  int data = readData();
  digitalWrite(CLOCK_PIN, LOW);
  pinMode(RWB_PIN, INPUT);
  setAddressToReadState();
  Serial.write(BUS_DATA_COMMAND);
  Serial.write(data);
}

void handleRamWriteCommand() {
  digitalWrite(CLOCK_PIN, LOW);
  writeAddressHi(Serial.read());
  writeAddressLo(Serial.read());
  writeData(Serial.read());
  pinMode(RWB_PIN, OUTPUT);
  digitalWrite(RWB_PIN, LOW);
  digitalWrite(CLOCK_PIN, HIGH);
  digitalWrite(CLOCK_PIN, LOW);
  pinMode(RWB_PIN, INPUT);
  setAddressToReadState();
  setDataToReadState();
  Serial.write(DONE_COMMAND);
}

void handleRomWriteCommand() {
  digitalWrite(CLOCK_PIN, LOW);
  pinMode(ROM_W_PIN, OUTPUT);
  digitalWrite(ROM_W_PIN, LOW);
  writeAddressHi(Serial.read());
  writeAddressLo(Serial.read());
  writeData(Serial.read());
  digitalWrite(CLOCK_PIN, HIGH);
  digitalWrite(CLOCK_PIN, LOW);
  pinMode(ROM_W_PIN, INPUT);
  setAddressToReadState();
  setDataToReadState();
  Serial.write(DONE_COMMAND);
}

void handleDisableClockCommand() {
  digitalWrite(CLOCK_ENABLE_PIN, LOW);
  Serial.write(DONE_COMMAND);
}

void handleEnableClockCommand() {
  digitalWrite(CLOCK_PIN, LOW);
  digitalWrite(CLOCK_ENABLE_PIN, HIGH);
  Serial.write(DONE_COMMAND);
}

void handleEnableCpuBusCommand() {
  digitalWrite(BE_PIN, HIGH);
  Serial.write(DONE_COMMAND);
}

void handleDisableCpuBusCommand() {
  digitalWrite(BE_PIN, LOW);
  Serial.write(DONE_COMMAND);
}
