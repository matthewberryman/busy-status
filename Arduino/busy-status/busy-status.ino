#include <ArduinoBLE.h>
#include "Arduino_LED_Matrix.h"
ArduinoLEDMatrix matrix;

const uint32_t happy[] = {
  0x19819,
  0x80000001,
  0x81f8000
};

const uint32_t blank[] = {
  0x00,
  0x00,
  0x00
};

BLEService ledService("180F"); // BLE LED Service

// BLE LED Switch Characteristic - custom 128-bit UUID, read and writable by central
BLEByteCharacteristic switchCharacteristic("2A58", BLERead | BLEWrite);

void setup() {
  Serial.begin(115200);
  matrix.begin();
  while (!Serial);

  matrix.loadFrame(blank);

  // begin initialization
  if (!BLE.begin()) {
    Serial.println("starting Bluetooth® Low Energy failed!");

    while (1);
  }

  // set advertised local name and service UUID:
  BLE.setLocalName("Uno R4 BLE Sense");
  BLE.setAdvertisedService(ledService);

  // add the characteristic to the service
  ledService.addCharacteristic(switchCharacteristic);

  // add service
  BLE.addService(ledService);

  // set the initial value for the characteristic:
  switchCharacteristic.writeValue(0);

  // start advertising
  BLE.advertise();

  Serial.println("BLE LED Peripheral");
}

void loop() {
  // listen for Bluetooth® Low Energy peripherals to connect:
  BLEDevice central = BLE.central();

  // if a central is connected to peripheral:
  if (central) {
    Serial.print("Connected to central: ");
    // print the central's MAC address:
    Serial.println(central.address());
    matrix.loadFrame(blank);

    // while the central is still connected to peripheral:
    while (central.connected()) {
      // if the remote device wrote to the characteristic,
      // use the value to control the LED:
      if (switchCharacteristic.written()) {

        switch (switchCharacteristic.value()) {   // any value other than 0
          case 01:
            Serial.println("Happy on");
            matrix.loadFrame(happy);
            break;
          default:
            matrix.loadFrame(blank);
            break;
        }
      }
    }

    // when the central disconnects, print it out:
    Serial.print(F("Disconnected from central: "));
    Serial.println(central.address());
    matrix.loadFrame(blank);
  }
}