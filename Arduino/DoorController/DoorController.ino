#include <SPI.h>
#include <EEPROM.h>
#include <boards.h>
#include <RBL_nRF8001.h>
#include <Servo.h>

Servo doorServo;
// Pin definitions
int digitalOutPin = 2;
int servoPin = 5;

// Various control codes
byte controlDigitalOutPin = 0x01;
byte controlDigitalInPin = 0x02;
byte controlServo = 0x03;
byte controlReset = 0x04;

// Values for various states
byte low = 0x00;
byte high = 0x01;

void setup() {
  // Set up and start the BLE shield
  ble_set_name("The Door");
  ble_begin();
  // Attach servo and set the pin to output
  pinMode(digitalOutPin, OUTPUT);
  doorServo.attach(servoPin);
}

void loop() {
  // Read data when the BLE module is ready
  while(ble_available()) {
    // read out command and data
    byte controlCode = ble_read();
    byte value = ble_read();

    // Check was action to take based on the control code
    if (controlCode == controlDigitalOutPin) {
      // Commands that control the digital out pin
      if (value == high) {
        digitalWrite(digitalOutPin, HIGH);
      } else {
        digitalWrite(digitalOutPin, LOW);
      }
    } else if (controlCode == controlServo) {
      // Commands that control the servo pin
      doorServo.write(value);
    } else if (controlCode == controlReset) {
      // Reset everything
      doorServo.write(0);
      digitalWrite(digitalOutPin, LOW);
    }
  }

  // If a BLE is not connected, turn off the pin
  if (!ble_connected()) {
    digitalWrite(digitalOutPin, LOW);
  }
  // Allow the BLE Shield to send/receive data
  ble_do_events();
}

