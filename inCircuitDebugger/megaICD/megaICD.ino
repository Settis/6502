#include <LiquidCrystal.h>

const int LCD_NB_ROWS = 2;
const int LCD_NB_COLUMNS = 16;
const int rs = 8, en = 9, d4 = 4, d5 = 5, d6 = 6, d7 = 7;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

const int RIGHT_KEY = 1, UP_KEY = 2, DOWN_KEY = 3, LEFT_KEY = 4, SELECT_KEY = 5;

const int RWB_PIN = 38;
const int RESB = 39;
const int VPA = 40;
const int VDA = 41;
const int IRQ = 50;
const int NMI = 51;
const int ROM_W = 52;
const int CLOCK_ENABLE_PIN = 60;
const int CLOCK_PIN = 61;

const int PROC_OPCODE_ADDR = 3, PROC_PROG_ADDR = 2, PROC_DATA_ADDR = 1, PROC_INTERNAL_ADDR = 0;


void setup() {
  lcd.begin(LCD_NB_COLUMNS, LCD_NB_ROWS);
  lcd.clear();
  setAddressToReadState();
  setDataToReadState();
  pinMode(RWB_PIN, INPUT);
  pinMode(RESB, INPUT);
  pinMode(VPA, INPUT);
  pinMode(VDA, INPUT);
  pinMode(IRQ, INPUT);
  pinMode(NMI, INPUT);
  pinMode(ROM_W, INPUT);
  pinMode(CLOCK_ENABLE_PIN, OUTPUT);
  digitalWrite(CLOCK_ENABLE_PIN, LOW);
  pinMode(CLOCK_PIN, OUTPUT);
  digitalWrite(CLOCK_PIN, LOW);
  lcd.setCursor(0, 0);
  lcd.print("Addr: ");
  lcd.setCursor(0, 1);
  lcd.print("Data: ");
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
  return (PINA << 8) + PINC;
}

int readData() {
  return PINL;
}

void tick() {
  digitalWrite(CLOCK_PIN, LOW);
  digitalWrite(CLOCK_PIN, HIGH);
}

int readProcVitrualAddr() {
  return (digitalRead(VPA) << 1) + digitalRead(VDA);
}

void printData() {
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

void loop() {
  int keyPressed = readKeyPressed();
  if (keyPressed == SELECT_KEY) {
    tick();
    printData();
    delay(500);
  }
}
