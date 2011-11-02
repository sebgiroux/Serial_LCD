#include "Serial_LCD.h"
#include "proxySerial.h"
#include "button.h"

// === Serial port choice
// --- SoftwareSerial Case - Arduino only
//#include "NewSoftSerial.h"
//NewSoftSerial myNSS(2, 3);
//ProxySerial mySerial(&myNSS);
//
// --- HardwareSerial Case - Arduino + chipKIT
//ProxySerial mySerial(&Serial1);
// 
// --- i2cSerial Case - Arduino + chipKIT
#include "Wire.h"
#include "I2C_Serial.h"
I2C_Serial myI2C;
ProxySerial mySerial(&myI2C);
//
// ===


Serial_LCD myLCD( &mySerial); 

uint16_t x, y;
uint32_t l;

button b7( &myLCD);


String ftoa(float number, uint8_t precision, uint8_t size) {
  // Based on mem,  16.07.2008
  // http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num = 1207226548/6#6

  // prints val with number of decimal places determine by precision
  // precision is a number from 0 to 6 indicating the desired decimial places
  // example: printDouble(3.1415, 2); // prints 3.14 (two decimal places)

  // Added rounding, size and overflow #
  // ftoa(343.1453, 2, 10) -> "    343.15"
  // ftoa(343.1453, 4,  7) -> "#      "
  // avenue33, April 10th, 2010

  String s = "";

  // Negative 
  if (number < 0.0)  {
    s = "-";
    number = -number;
  }

  double rounding = 0.5;
  for (uint8_t i = 0; i < precision; ++i)    rounding /= 10.0;

  number += rounding;
  s += String(uint16_t(number));  // prints the integer part

  if(precision > 0) {
    s += ".";                // prints the decimal point
    uint32_t frac;
    uint32_t mult = 1;
    uint8_t padding = precision -1;
    while(precision--)     mult *= 10;

    frac = (number - uint16_t(number)) * mult;

    uint32_t frac1 = frac;
    while(frac1 /= 10)    padding--;
    while(padding--)      s += "0";

    s += String(frac,DEC) ;  // prints the fractional part
  }

  if (size>0)                // checks size
    if (s.length()>size)        return("#");
    else while(s.length()<size) s = " "+s;

  return s;
}


void setup() {
  Serial.begin(19200);
  Serial.print("\n\n\n***\n");

//  // === Serial port initialisation
//  // --- SoftwareSerial Case - Arduino only
//  myNSS.begin(9600);
//  Serial.print("SoftwareSerial\t");
//  Serial.print("\n");
//  //
//  // --- HardwareSerial Case - Arduino + chipKIT
//  Serial1.begin(9600);
//  Serial.print("HardwareSerial\t");
//  Serial.print("\n");
//  // 
//  // --- i2cSerial Case - Arduino + chipKIT
  Wire.begin();
  myI2C.begin(9600);
  Serial.print("i2cSerial\t");
  Serial.print("\n");
//  //
//  // ===

  myLCD.begin();

  delay(10);
  myLCD.setSpeed(38400);

//  // === Serial port speed up
//  // --- SoftwareSerial Case - Arduino only
//  myNSS.begin(38400);
//  //
//  // --- HardwareSerial Case - Arduino + chipKIT
//  Serial1.begin(38400);
//  // 
//  // --- i2cSerial Case - Arduino + chipKIT
  myI2C.begin(38400);
//  //
//  // ===  

  myLCD.setOrientation(0x03);

  myLCD.setPenSolid(true);
  myLCD.setFontSolid(true);

  myLCD.setFont(0);
  myLCD.gText( 0, 210, 0xffff, myLCD.WhoAmI());

  myLCD.setTouch(true);

  l=millis();

  b7.define( 0, 0, 79, 59, "Stop", myLCD.rgb16(0xff, 0xff, 0xff), myLCD.rgb16(0xff, 0x00, 0x00), myLCD.rgb16(0x88, 0x00, 0x00), 9);

  b7.enable(true);
  b7.draw();

  uint16_t chrono0, chrono1;
  chrono0=millis();

  myLCD.setPenSolid(false);
  for (int i=0; i<10; i++) {
    for (int j=0; j<10; j++) {
      myLCD.circle(120+j*10, 30+i*10, 30, random(0, 0xffff));
    }
  }

  chrono1=millis();
  myLCD.gText( 0, 180, 0xffff, ftoa((chrono1-chrono0), 0, 10 ));

  chrono0=millis();

  myLCD.setPenSolid(true);
  for (int i=0; i<10; i++) {
    for (int j=0; j<10; j++) {
      myLCD.circle(120+j*10, 30+i*10, 30, random(0, 0xffff));
    }
  }

  chrono1=millis();
  myLCD.gText( 160, 180, 0xffff, ftoa((chrono1-chrono0), 0, 10 ));

}

uint8_t c;

void loop() {

  c=myLCD.getTouchActivity();

  if (c>0) {
    myLCD.getTouchXY(x, y);
    myLCD.setFont(0);
    myLCD.gText(200, 0, 0xffff, ftoa(x, 0, 5)); 
    myLCD.gText(200, 15, 0xffff, ftoa(y, 0, 5)); 

    // quit
    if (b7.check()) {
      myLCD.off();
      while(true);
    }



  }
  myLCD.setFont(0);
  myLCD.setFontSolid(true);
  myLCD.gText( 250, 225, 0xffff, ftoa(millis()-l, 0, 6));
  l=millis();
}




















