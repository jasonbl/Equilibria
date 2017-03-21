void setup() {
  Serial.begin(9600);

  // put your setup code here, to run once:
  pinMode(2, OUTPUT);
  pinMode(3, OUTPUT);
  pinMode(4, OUTPUT);
  pinMode(8, OUTPUT);
  pinMode(10, OUTPUT);
  pinMode(12, OUTPUT);
  

  Serial.println("Ready");

  delay(5000);
  
}


void loop() {
  
  Serial.println("1 forward, 2 forward");
  setDir1(1);
  setDir2(4);

  slide1(2);
  
  delay(2000);

  Serial.println("1 forward, 2 backward");
  setDir1(1);
  setDir2(5);
   
  slide1(2);

  delay(2000);
  
  Serial.println("1 backward, 2 forward");
  setDir1(2);
  setDir2(4);
   
  slide1(2);  

  delay(2000);

  Serial.println("1 off, 2 forward");
  setDir1(0);
  setDir2(4);

  slide1(2);

  delay(2000);

  Serial.println("1 off, 2 backward");
  setDir1(0);
  setDir2(5);

  delay(2000);

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


// gradually speed up, then gradually slow down. Basic Code
void slide1(int d) {
  for(int v=0;v<256;++v) {
    analogWrite(3, v);
    analogWrite(10, v);
    delay(d);
  }
  for(int v=255;v>=0;--v) {
    analogWrite(3,v);
    analogWrite(10,v);
    delay(d);
  }
}

//actuator 2
// void slide2(int d) {
//  for(int v=0;v<256;++v) {
//    analogWrite(10,v);
//    delay(d);
//  }
//  for(int v=255;v>=0;--v) {
//    analogWrite(10,v);
//    delay(d);
//  }    
// } 
