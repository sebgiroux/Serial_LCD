#include "WProgram.h"
#include <Wire.h>

#include "Serial_LCD.h"
#include "button.h"

// Arduino Case : uncomment #include
// #if defined(__AVR__) doesn't work!
// ---
//#include "NewSoftSerial.h"
// ===

#include "proxySerial.h"

#if defined(__AVR__)
// Arduino Case ---
#include "NewSoftSerial.h"
NewSoftSerial nss(2, 3); // RX, TX
ProxySerial mySerial(&nss);

#elif defined(__PIC32MX__) 
// chipKIT Case ---
ProxySerial mySerial(&Serial1);

#else
#error Non defined board
#endif 


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

#if defined(__AVR__)
  Serial.print("avr\t");
  Serial.print(__AVR__);
  Serial.print("\n");
#elif defined(__PIC32MX__) 
  Serial.print("chipKIT\t");
  Serial.print(__PIC32MX__);
  Serial.print("\n");
#endif 

  myLCD.begin();
  myLCD.setOrientation(0x03);

  Wire.begin();

  myLCD.setPenSolid(true);
  myLCD.setFontSolid(true);

  myLCD.setFont(0);
  myLCD.gText( 0, 210, 0xffff, myLCD.WhoAmI());

  myLCD.setTouch(true);

  l=millis();

  uint16_t i=9;
  b7.define( 160, 120, 79, 59, "arreter tout    ",        myLCD.rgb16(0xff, 0xff, 0xff), myLCD.rgb16(0xff, 0x00, 0x00), myLCD.rgb16(0x88, 0x00, 0x00), i);

  b7.enable(true);
  b7.draw();

  //    myLCD.setFont(3);
  //    myLCD.gText(0,  0, 0xffff, "         1         2    ");
  //    myLCD.gText(0, 20, 0xffff, "12345678901234567890123456"); 
  //    myLCD.gText(0, 60, 0xffff, ftoa(myLCD.fontX(), 0, 8)); 
  //
  //    myLCD.setFont(2);
  //    myLCD.gText(0,  80, 0xffff, "         1         2         3         4");
  //    myLCD.gText(0, 100, 0xffff, "1234567890123456789012345678901234567890"); 
  //    myLCD.gText(0, 120, 0xffff, ftoa(myLCD.fontX(), 0, 8)); 

  myLCD.setFont(1);
  myLCD.gText(0,  0, 0xffff, "         1         2         3         4");
  myLCD.gText(0, 20, 0xffff, "1234567890123456789012345678901234567890"); 
  myLCD.gText(0, 60, 0xffff, ftoa(myLCD.fontX(), 0, 8)); 

  myLCD.setFont(0);
  myLCD.gText(0,  80, 0xffff, "         1         2         3         4         5");
  myLCD.gText(0, 100, 0xffff, "12345678901234567890123456789012345678901234567890123"); 
  myLCD.gText(0, 120, 0xffff, ftoa(myLCD.fontX(), 0, 8)); 
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
  myLCD.gText( 250, 225, 0xffff, String(millis()-l));
  l=millis();
}


















