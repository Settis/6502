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
  digitalWrite(RESB_PIN, LOW);
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

  pinMode(LED_BUILTIN, OUTPUT);
  lcd.begin(LCD_NB_COLUMNS, LCD_NB_ROWS);
  lcd.clear();

  Serial.begin(115200, SERIAL_8E1);

  lcd.print("Loaded");
}

void handlePingCommand() {
  lcd.clear();
  lcd.print("Ping");
  byte body = Serial.read();
  Serial.write(body+1);
}

void handleReadCommand() {

}

void handleRunWithBreakCommand() {

}

#define PING_COMMAND 1
#define READ_COMMAND 3
#define RUN_WITH_BREAK_COMMAND 5

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
