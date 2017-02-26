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
#define calibration_factor -6850.0

#define CLK_FL  6
#define DOUT_FL  7
#define CLK_FR  2
#define DOUT_FR  3
#define CLK_BL  8
#define DOUT_BL  9
#define CLK_BR  4
#define DOUT_BR  5

#define readFrontLeft 'A'
#define readFrontRight 'B'
#define readBackLeft 'C'
#define readBackRight 'D'

HX711 frontLeft(DOUT_FL, CLK_FL);
HX711 frontRight(DOUT_FR, CLK_FR);
HX711 backLeft(DOUT_BL, CLK_BL);
HX711 backRight(DOUT_BR, CLK_BR);

void setup() {
  Serial.begin(9600);
  Serial.println('a');
  char a = 'b';
  while (a != 'a') {
    a = Serial.read();
  }

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

void loop() {
  // Wait for data from serial port
  while (Serial.available() == 0) {
  }
  
  if (Serial.available() > 0) {
    int mode = Serial.read();
    if (mode == readFrontLeft) {
      Serial.println(frontLeft.get_units(), 1); //scale.get_units() returns a float
    } else if (mode == readFrontRight) {
      Serial.println(frontRight.get_units(), 1);
      // TEMPORARY WEIGHT FOR VISUALIZATION
    } else if (mode == readBackLeft) {
      Serial.println(backLeft.get_units(), 1);
    } else if (mode == readBackRight) {
      Serial.println(backRight.get_units(), 1);
    }
  }
  delay(20);
  
  //Serial.print("Reading: ");
  //Serial.println(scale.get_units(), 1); //scale.get_units() returns a float
  //Serial.print(" lbs"); //You can change this to kg but you'll need to refactor the calibration_factor
  //Serial.println();
}

