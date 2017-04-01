/*
   Code to control both linear actuators
*/

#define ACTUATOR_ONE '1'
#define ACTUATOR_TWO '2'
#define OFF '0'
#define UP '1'
#define DOWN '2'

#define SET_VELOCITY 'V'
#define SET_DIRECTION 'D'
#define MAX_VELOCITY 255

int oneVelocity; // Velocity for actuator one (Note: 255 Maximum value of for analogWrite)
int twoVelocity; // Velocity for actuator two (Note: 255 Maximum value of for analogWrite)

void setup() {
  Serial.begin(9600);
  Serial.println('a');
  char a = 'b';
  while (a != 'a') {
    a = Serial.read();
  }

  // Actuator 1: Controls pitch
  // Actuator 2: Controls roll
  pinMode(2, OUTPUT); // Actuator 1: set high to move down
  pinMode(4, OUTPUT); // Actuator 1: set high to move up
  pinMode(3, OUTPUT); // Actuator 1: velocity control
  pinMode(8, OUTPUT); // Actuator 2: set high to move down
  pinMode(12, OUTPUT); // Actuator 2: set high to move up
  pinMode(10, OUTPUT); // Actuator 2: velocity control

//  // Set initial velocities of actuators //////// CHANGE LATER ////////
//  oneVelocity = 128;
//  twoVelocity = 128;
//  ramp(oneVelocity);
}

void loop() {
  // Wait for data from serial port
  while (Serial.available() == 0) {}

  if (Serial.available() > 0) {
    int mode = Serial.read();

    if (mode == SET_VELOCITY) {
      //Serial.println("Mode = SET_VELOCITY");
      while (Serial.available() == 0) {}
      Serial.read(); // REMOVE NEW LINE CHARACTER
            
      while (Serial.available() == 0) {}
      int percentVelocity = (int) Serial.read();
      //Serial.println((char) percentVelocity);
      int velocity = percentVelocity / 100.0 * MAX_VELOCITY;
      //Serial.println(velocity);
      ramp(velocity);
    } else if (mode == SET_DIRECTION) {
      while (Serial.available() == 0) {}
      Serial.read(); // REMOVE NEW LINE CHARACTER
      
      while (Serial.available() == 0) {}
      int actuator = Serial.read();
      //Serial.println(actuator);
      
      while (Serial.available() == 0) {}
      Serial.read(); // REMOVE NEW LINE CHARACTER
      while (Serial.available() == 0) {}
      int dir = Serial.read();
      //Serial.println(dir);
      setDirection(actuator, dir);
    }
  }

}

void setDirection(int actuator, int dir) {
  if (actuator == ACTUATOR_ONE) {
    switch (dir) {
      case OFF:
        digitalWrite(2, LOW);
        digitalWrite(4, LOW);
        break;
      case UP:
        digitalWrite(2, LOW);
        digitalWrite(4, HIGH);
        break;
      case DOWN:
        digitalWrite(2, HIGH);
        digitalWrite(4, LOW);
        break;
    }
  } else if (actuator = ACTUATOR_TWO) {
    switch (dir) {
      case OFF:
        digitalWrite(8, LOW);
        digitalWrite(12, LOW);
        break;
      case UP:
        digitalWrite(8, LOW);
        digitalWrite(12, HIGH);
        break;
      case DOWN:
        digitalWrite(8, HIGH);
        digitalWrite(12, LOW);
    }
  }
}

void ramp(int velocity) {
  // Make sure velocity is in the correct range
  if (velocity > MAX_VELOCITY) {
    velocity = 255;  
  } else if (velocity < 0) {
    velocity = 0;  
  }

  // Ramp velocity of first actuator to correct value
  if (velocity > oneVelocity) {
    for (oneVelocity; oneVelocity < velocity; oneVelocity++) {
      analogWrite(3, oneVelocity);
      delay(2);
    }
  } else {
    for (oneVelocity; oneVelocity > velocity; oneVelocity--) {
      analogWrite(3, oneVelocity);
      delay(2);
    }
  }

  // Ramp velocity of second actuator to correct value
  if (velocity > twoVelocity) {
    for (twoVelocity; twoVelocity < velocity; twoVelocity++) {
      analogWrite(10, twoVelocity);
      delay(2);
    }
  } else {
    for (twoVelocity; twoVelocity > velocity; twoVelocity--) {
      analogWrite(10, twoVelocity);
      delay(2);
    }
  }
}
