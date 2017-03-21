/*
 Example using the SparkFun HX711 breakout board with a scale
 By: Nathan Seidle
 SparkFun Electronics
 Date: November 19th, 2014
 License: This code is public domain but you buy me a beer if you use this and we meet someday (Beerware license).

 This is the calibration sketch. Use it to determine the calibration_factor that the main example uses. It also
 outputs the zero_factor useful for projects that have a permanent mass on the scale in between power cycles.

 Setup your scale and start the sketch WITHOUT a weight on the scale
 Once readings are displayed place the weight on the scale
 Press +/- or a/z to adjust the calibration_factor until the output readings match the known weight
 Use this calibration_factor on the example sketch

 This example assumes pounds (lbs). If you prefer kilograms, change the Serial.print(" lbs"); line to kg. The
 calibration factor will be significantly different but it will be linearly related to lbs (1 lbs = 0.453592 kg).

 Your calibration factor may be very positive or very negative. It all depends on the setup of your scale system
 and the direction the sensors deflect from zero state
 This example code uses bogde's excellent library: https://github.com/bogde/HX711
 bogde's library is released under a GNU GENERAL PUBLIC LICENSE
 Arduino pin 2 -> HX711 CLK
 3 -> DOUT
 5V -> VCC
 GND -> GND

 Most any pin on the Arduino Uno will be compatible with DOUT/CLK.

 The HX711 board can be powered from 2.7V to 5V so the Arduino 5V power should be fine.

*/

#include "HX711.h"

#define CLK_FL  4
#define DOUT_FL  5
#define CLK_FR  8
#define DOUT_FR  9
#define CLK_BL  2
#define DOUT_BL  3
#define CLK_BR  6
#define DOUT_BR  7

HX711 frontLeft(DOUT_FL, CLK_FL);
HX711 frontRight(DOUT_FR, CLK_FR);
HX711 backLeft(DOUT_BL, CLK_BL);
HX711 backRight(DOUT_BR, CLK_BR);

float calibration_factor = -6000;

void setup() {
  Serial.begin(9600);
  Serial.println("HX711 calibration sketch");
  Serial.println("Remove all weight from scale");
  Serial.println("After readings begin, place known weight on scale");
  Serial.println("Press + or a to increase calibration factor");
  Serial.println("Press - or z to decrease calibration factor");

  // Calibrate and zero feet
  frontLeft.set_scale(calibration_factor);
  frontLeft.tare();
  frontRight.set_scale(calibration_factor);
  frontRight.tare();
  backLeft.set_scale(calibration_factor);
  backLeft.tare();
  backRight.set_scale(calibration_factor);
  backRight.tare();

  //long zero_factor = scale.read_average(); //Get a baseline reading
  //Serial.print("Zero factor: "); //This can be used to remove the need to tare the scale. Useful in permanent scale projects.
  //Serial.println(zero_factor);
}

void loop() {

  frontLeft.set_scale(calibration_factor); //Adjust to this calibration factor
  frontRight.set_scale(calibration_factor);
  backLeft.set_scale(calibration_factor);
  backRight.set_scale(calibration_factor);

  Serial.print("Reading: ");
  float totalWeight = frontLeft.get_units() + frontRight.get_units() + 
      backLeft.get_units() + backRight.get_units();
  Serial.print(totalWeight, 1);
  Serial.print(" lbs"); //Change this to kg and re-adjust the calibration factor if you follow SI units like a sane person
  Serial.print(" calibration_factor: ");
  Serial.print(calibration_factor);
  Serial.println();

  if(Serial.available())
  {
    char temp = Serial.read();
    if(temp == '+' || temp == 'a')
      calibration_factor += 10;
    else if(temp == '-' || temp == 'z')
      calibration_factor -= 10;
  }
}
