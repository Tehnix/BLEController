#include <SPI.h>
#include <EEPROM.h>
#include <boards.h>
#include <RBL_nRF8001.h>
#include <Servo.h>

#define DIGITAL_OUT_PIN    2
#define SERVO_PIN          5
Servo doorServo;

void setup() {
  // Set up and start the BLE shield
  ble_set_name("The Door");
  ble_begin();
  // Attach servo and set the pin to output
  pinMode(DIGITAL_OUT_PIN, OUTPUT);
  doorServo.attach(SERVO_PIN);
}

void loop() {
  // Read data when the BLE module is ready
  while(ble_available()) {
    // read out command and data
    byte control = ble_read();
    byte state = ble_read();

    if (control == 0x01) {
      // Command is to control digital out pin
      if (state == 0x01) {
        digitalWrite(DIGITAL_OUT_PIN, HIGH);
      } else {
        digitalWrite(DIGITAL_OUT_PIN, LOW);
      }
    } else if (control == 0x03) {
      // Command is to control Servo pin
      doorServo.write(state);
    } else if (control == 0x04) {
      // Reset everything
      doorServo.write(0);
      digitalWrite(DIGITAL_OUT_PIN, LOW);
    }
  }

  // If BLE is not connected, turn off the pin
  if (!ble_connected()) {
    digitalWrite(DIGITAL_OUT_PIN, LOW);
  }
  // Allow the BLE Shield to send/receive data
  ble_do_events();
}
