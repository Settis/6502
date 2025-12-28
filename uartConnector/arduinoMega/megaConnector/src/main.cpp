#include <Arduino.h>
#include <LiquidCrystal.h>

const int LCD_NB_ROWS = 2;
const int LCD_NB_COLUMNS = 16;
const int rs = 8, en = 9, d4 = 4, d5 = 5, d6 = 6, d7 = 7;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

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

void setup() {

  // read state for adress
  DDRA = 0;
  DDRC = 0;
  // read state for data
  DDRL = 0;

  pinMode(RWB_PIN, INPUT);
  pinMode(RESB_PIN, OUTPUT);
  digitalWrite(RESB_PIN, HIGH);
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
  digitalWrite(BE_PIN, LOW);

  pinMode(LED_BUILTIN, OUTPUT);
  lcd.begin(LCD_NB_COLUMNS, LCD_NB_ROWS);
  lcd.clear();

  digitalWrite(RESB_PIN, LOW);
  Serial.begin(115200, SERIAL_8E1);

  lcd.print("Loaded");
  digitalWrite(BE_PIN, HIGH);
  digitalWrite(CLOCK_PIN, HIGH);
  digitalWrite(CLOCK_PIN, LOW);
  digitalWrite(CLOCK_PIN, HIGH);
  digitalWrite(CLOCK_PIN, LOW);
  digitalWrite(RESB_PIN, HIGH);
}

void handlePingCommand() {
  lcd.clear();
  lcd.print("Ping");
  byte body = Serial.read();
  Serial.write(body+1);
}

int crc_sum;
int address;

void updateCrc(byte data) {
  crc_sum ^= data;
  for (byte i=0; i<8; i++) {
    crc_sum <<= 1;
    if (crc_sum & 0x100) 
      crc_sum ^= 0x107;
  }
}

void handleReadCommand() {
  address = Serial.read() | (Serial.read() << 8 );
  int length = Serial.read();
  byte data;

  digitalWrite(BE_PIN, LOW);
  pinMode(RWB_PIN, OUTPUT);
  digitalWrite(RWB_PIN, HIGH);
  // write state for adress
  DDRA = 0xFF;
  DDRC = 0xFF;

  crc_sum = 0;
  for (; length > 0; length--) {
    PORTA = address >> 8;
    PORTC = address & 0xFF;
    digitalWrite(CLOCK_PIN, HIGH);
    data = PINL;
    digitalWrite(CLOCK_PIN, LOW);
    updateCrc(data);
    Serial.write(data);
    address += 1;
  }

  Serial.write(crc_sum);

  pinMode(RWB_PIN, INPUT);
  // read state for adress
  DDRA = 0;
  DDRC = 0;
}

byte addrHi, addrLo;

void handleRunWithBreakCommand() {
  addrLo = Serial.read();
  addrHi = Serial.read();
  digitalWrite(BE_PIN, HIGH);
  while (true) {
    PORTF = 0x80;
    if (addrHi == PINA) {
      if (addrLo == PINC) {
        break;
      }
    }
    PORTF = 0x00;
  }
  digitalWrite(CLOCK_PIN, LOW);
  Serial.write(4);
}

#define PING_COMMAND 1
#define READ_COMMAND 3
#define RUN_WITH_BREAK_COMMAND 4

void loop() {
  if (Serial.available()) {
    delay(10);
    byte commandByte = Serial.read();
    switch(commandByte) {
      case PING_COMMAND:
        handlePingCommand();
        break;
      case READ_COMMAND:
        handleReadCommand();
        break;
      case RUN_WITH_BREAK_COMMAND:
        handleRunWithBreakCommand();
        break;
    }
  }
}
