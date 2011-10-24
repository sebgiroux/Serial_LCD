//
// μLCD-32PT(SGC) 3.2” Serial LCD Display Module
// Arduino & chipKIT Library
//
// May 10, 2011 release 1 - initial release
// Jun 15, 2011 release 2 - features added and bugs fixed
// Jun 29, 2011 release 3 - setBackGroundColour added and SD card
// Jul 31, 2011 release 4 - stdint.h types for chipKIT compatibility
// Aug 04, 2011 release 5 - chipKIT compatibility with external proxySerial.h
// Aug 07, 2011 release 6 - playing sounds - up to 250 mA!
// Sep 18, 2011 release 7 - dialog window with up to 3 buttons
// Sep 23, 2011 release 8 - ms monitoring to avoid RX TX collapse
// Oct 10, 2011 release 9 - Stream.h class based i2cSerial library
// Oct 14, 2011 release 10 - ellipse and detectTouchRegion from sebgiroux
// Oct 24, 2011 release 11 - serial port managed in main only - setSpeed added - proxySerial still needed
//
//
// CC = BY NC SA
// http://sites.google.com/site/vilorei/
// http://github.com/rei-vilo/Serial_LCD
//
// Based on
// 4D LABS PICASO-SGC Command Set
// Software Interface Specification
// Document Date: 1st March 2011 
// Document Revision: 6.0
// http://www.4d-Labs.com
//
//

#include "Serial_LCD.h"
#include "proxySerial.h"
#include "button.h"


// Arduino Case
#include "NewSoftSerial.h"
NewSoftSerial nss(2, 3); // RX, TX
ProxySerial mySerial(&nss);


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

  nss.begin(9600);

  myLCD.begin();
  myLCD.setOrientation(0x03);


  myLCD.setPenSolid(true);
  myLCD.setFontSolid(true);

  myLCD.setFont(0);
  myLCD.gText( 0, 210, 0xffff, myLCD.WhoAmI());

  myLCD.setTouch(true);

  l=millis();

  //  Serial.print("*** SD ");
  //  Serial.print(myLCD.initSD(), DEC);
  //  Serial.print("\n");

  myLCD.ellipse(100, 100, 50, 20, myLCD.rgb16(0xff,0x00,0x00));


  b7.define( 0, 0, 79, 59, "STOP",        myLCD.rgb16(0xff, 0xff, 0xff), myLCD.rgb16(0xff, 0x00, 0x00), myLCD.rgb16(0x88, 0x00, 0x00), 9);
  b7.enable(true);
  b7.draw();

  myLCD.setPenSolid(false);
  myLCD.rectangle(40, 40, 200, 200, myLCD.rgb16(0x00, 0x00, 0xff));

// Oct 14, 2011 release 10 - ellipse and detectTouchRegion from Sébastien Giroux
// filters only events 1=press and 3=move
  myLCD.detectTouchRegion(40, 40, 200, 200);

}

uint8_t c;

void loop() {
  c=myLCD.getTouchActivity();
  myLCD.setFont(3);
  myLCD.gText(140, 10, 0xffff, ftoa(c, 0, 5)); 

  if ((c==1) || (c==3)) {
    myLCD.getTouchXY(x, y);

    myLCD.setFont(1);
    myLCD.gText(200, 0, 0xffff, ftoa(x, 0, 5)); 
    myLCD.gText(200, 20, 0xffff, ftoa(y, 0, 5)); 

    myLCD.point(x, y, 0xffff);

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



