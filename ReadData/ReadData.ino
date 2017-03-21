/*
  Example using the SparkFun HX711 breakout board with a scale
  By: Nathan Seidle
  SparkFun Electronics
  Date: November 19th, 2014
  License: This code is public domain but you buy me a beer if you use this and we meet someday (Beerware license).

  This example demonstrates basic scale output. See the calibration sketch to get the calibration_factor for your
  specific load cell setup.

  This example code uses bogde's excellent library: https://github.com/bogde/HX711
  bogde's library is released under a GNU GENERAL PUBLIC LICENSE

  The HX711 does one thing well: read load cells. The breakout board is compatible with any wheat-stone bridge
  based load cell which should allow a user to measure everything from a few grams to tens of tons.
  Arduino pin 2 -> HX711 CLK
  3 -> DAT
  5V -> VCC
  GND -> GND

  The HX711 board can be powered from 2.7V to 5V so the Arduino 5V power should be fine.

*/

#include "HX711.h"

//This value is obtained using the SparkFun_HX711_Calibration sketch
#define calibration_factor -6000.0

#define CLK_FL  4
#define DOUT_FL  5
#define CLK_FR  8
#define DOUT_FR  9
#define CLK_BL  2
#define DOUT_BL  3
#define CLK_BR  6
#define DOUT_BR  7

#define READ_COP 'R'
#define READ_TILT 'T'

HX711 frontLeft(DOUT_FL, CLK_FL);
HX711 frontRight(DOUT_FR, CLK_FR);
HX711 backLeft(DOUT_BL, CLK_BL);
HX711 backRight(DOUT_BR, CLK_BR);

// Analog input pins for accelerometer
const int X_PIN = 0;
const int Y_PIN = 1;
const int Z_PIN = 2;

// max/min analog values for accelerometer
const int MIN = 405;
const int MAX = 615;

void setup() {
  // set analogRead max to 3.3v instead of default 5v - for accelerometer
  analogReference(EXTERNAL);

  Serial.begin(9600);
  Serial.println('a');
  char a = 'b';
  while (a != 'a') {
    a = Serial.read();
  }

  resetScale();
}

void loop() {
  // Wait for data from serial port
  while (Serial.available() == 0) {
  }

  //  Serial.print("Time1: ");
  //  unsigned long time1 = millis();
  //  Serial.println(time1);
  //  Serial.print("Weight: ");

  if (Serial.available() > 0) {
    int mode = Serial.read();

    // Readings sent to MATLAB in following order: FL, FR, BL, BR
    if (mode == READ_COP) {
      Serial.println(frontLeft.get_units(), 1);
      Serial.println(frontRight.get_units(), 1);
      Serial.println(backLeft.get_units(), 1);
      Serial.println(backRight.get_units(), 1);
    } else if (mode == READ_TILT) {
      int angles[2];
      getTilt(angles);

      Serial.println(angles[0]); // PITCH
      Serial.println(angles[1]); // ROLL
    }

  }

  //  Serial.print("Time2: ");
  //  unsigned long time2 = millis();
  //  Serial.println(time2);

  //Serial.print("Reading: ");
  //Serial.println(scale.get_units(), 1); //scale.get_units() returns a float
  //Serial.print(" lbs"); //You can change this to kg but you'll need to refactor the calibration_factor
  //Serial.println();
}

void resetScale() {
  // Calibrate and zero feet
  frontLeft.set_scale(calibration_factor);
  frontLeft.tare();
  frontRight.set_scale(calibration_factor);
  frontRight.tare();
  backLeft.set_scale(calibration_factor);
  backLeft.tare();
  backRight.set_scale(calibration_factor);
  backRight.tare();
}

void getTilt(int angles[]) {
  // sample the voltages
  int x = analogRead(X_PIN);
  int y = analogRead(Y_PIN);
  int z = analogRead(Z_PIN);

  // convert to range of -90 to +90 degrees
  int xAng = map(x, MIN, MAX, -90, 90);
  int yAng = map(y, MIN, MAX, -90, 90);
  int zAng = map(z, MIN, MAX, -90, 90);

  // convert radians to degrees
  int pitch = RAD_TO_DEG * (atan2(-xAng, -zAng));
  int roll = RAD_TO_DEG * (atan2(-yAng, -zAng));

  // convert left roll and forward pitch to negative degrees
  if (pitch > 180) {
    pitch = pitch - 360;
  }
  if (roll > 180) {
    roll = roll - 360;
  }

  angles[0] = pitch;
  angles[1] = roll;
}

