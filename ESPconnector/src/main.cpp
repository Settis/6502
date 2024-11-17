#include <Arduino.h>
#include <WiFi.h>
#include <wifiSecrets.h>
#include <ESPmDNS.h>

const char* ssid     = WIFI_SSID;
const char* password = WIFI_PASS;

WiFiServer server(23);
WiFiClient serverClient;

#define LED_PIN 2
#define DEBUG false

void setup() {
  pinMode(LED_PIN, OUTPUT);

  Serial.begin(9600);

  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    digitalWrite(LED_PIN, 1);
    delay(200);
    digitalWrite(LED_PIN, 0);
    delay(300);
    Serial.print(".");
  }

  Serial.println("");
  Serial.print("Connected to ");
  Serial.println(ssid);
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());

  if (!MDNS.begin("markus")) {
    Serial.println("Error setting up MDNS responder!");
    digitalWrite(LED_PIN, 1);
    while(1) {
      delay(1000);
    }
  }
  Serial.println("mDNS responder started");
  Serial2.begin(9600, SERIAL_8E1);
  server.begin();
  server.setNoDelay(true);
  Serial.println("telnet server started");

  // Add service to MDNS-SD
  MDNS.addService("telnet", "tcp", 23);
  
  serverClient = WiFiClient();

  Serial.println("Ready.");
}

void handleConnection() {
  if (server.hasClient()) {
    if (!serverClient.connected()) {
      serverClient = server.available();
      Serial.print("New connection from: ");
      Serial.println(serverClient.remoteIP());
      digitalWrite(LED_PIN, 1);
    } else {
      server.available().stop();
    }
  }
}

void handleWifiData() {
  if (serverClient.connected()) {
    if (serverClient.available()) {
      if (DEBUG) {
        Serial.print("From WiFi: ");
      }
      int data = serverClient.read();
      if (DEBUG) {
        Serial.print(data, HEX);
      }
      Serial2.write(data);
      if (DEBUG) {
        Serial.println("");
      }
    }
  } else {
    digitalWrite(LED_PIN, 0);
  }
}

void handleUartData() {
  if (Serial2.available()) {
    size_t len = Serial2.available();
    uint8_t sbuf[len];
    Serial2.readBytes(sbuf, len);
    if (DEBUG) {
      Serial.print("From UART: ");
      for (size_t i=0; i<len; i++) {
        Serial.print(sbuf[i], HEX);
      }
      Serial.println("");
    }
    if (serverClient.connected()) {
      serverClient.write(sbuf, len);
    }
  }
}

void loop() {
  handleConnection();
  handleWifiData();
  handleUartData();
}