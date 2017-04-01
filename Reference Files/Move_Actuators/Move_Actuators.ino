#define PITCH 'P'
#define ROLL 'R'

void setup() {
    Serial.begin(9600);

  // put your setup code here, to run once:
  pinMode(2, OUTPUT);
  pinMode(3, OUTPUT);
  pinMode(4, OUTPUT);
  pinMode(8, OUTPUT);
  pinMode(10, OUTPUT);
  pinMode(12, OUTPUT);
  
  ramp();
  Serial.println("Ready");

  delay(5000);

}

void loop() {
  // put your main code here, to run repeatedly:
  while (Serial.available() == 0) {}
  char input = Serial.read();
  if (input == PITCH) {
    Serial.println("Adjusting pitch");
    setDir1(1);
    delay(300);
    setDir1(0);
  } else if (input == ROLL) {
    Serial.println("Adjusting roll");
    setDir2(4);
    delay(300);
    setDir2(3);
  }
  

}

void setDir1(int d) {
  switch(d) {
    case 0: // off
    digitalWrite(2,LOW);
    digitalWrite(4,LOW);
    break;
    case 1: // forward
    digitalWrite(2,HIGH);
    digitalWrite(4,LOW);
    break;
    case 2:  // backward
    digitalWrite(2,LOW);
    digitalWrite(4,HIGH);
    break;

  }
}

 void setDir2(int d) {
  switch(d) {   
    case 3:  // off
    digitalWrite(8,LOW);
    digitalWrite(12,LOW);
    break;
    case 4:  // right
    digitalWrite(8,HIGH);
    digitalWrite(12,LOW);
    break;
    case 5: // left
    digitalWrite(8,LOW);
    digitalWrite(12,HIGH);
  }
}

// Ramp to half speed
void ramp() {
  for(int v = 0; v < 128; v++) {
    analogWrite(3, v);
    analogWrite(10, v);
    delay(2);
  }
}
