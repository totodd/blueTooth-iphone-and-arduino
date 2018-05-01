#include <SoftwareSerial.h>

SoftwareSerial ble(8,9); // RX, TX

void setup() {
  // Open serial port
  Serial.begin(9600);
  // begin bluetooth serial port communication
  ble.begin(9600);
  ble.write("AT+NAMETOTO-BLE");
}

// Now for the loop

void loop() {
   if (ble.available())
       Serial.write(ble.read());
   if (Serial.available())
       ble.write(Serial.read());
//   ble.write("AT+NAMETOTO-BLE");

//  ble.write("testing");
//  delay(500);
  
}
