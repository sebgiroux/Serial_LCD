//
// μLCD-32PT(SGC) 3.2” Serial LCD Display Module
// Arduino + chipKIT Library
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
//
// SC16IS750 I2C slave bridge to serial
// Arduino + chipKIT Library
//
// Oct 06, 2011 release 1 - initial release
// Oct 10, 2011 release 2 - Stream.h class based
//
//
// CC = BY NC SA
// http://sites.google.com/site/vilorei/
//
// Required
// NewSoftSerial release 11
//
// Based on
// 4D LABS PICASO-SGC Command Set
// Software Interface Specification
// Document Date: 1st March 2011     
// Document Revision: 6.0
// http://www.4d-Labs.com

// Needs to be defined in both proxySerial and main program
#define __i2cSerialPort__ 

#include "Serial_LCD.h"
#include "proxySerial.h"
#include "button.h"


// I2C case
#if defined(__i2cSerialPort__) 
#include "Wire.h"
#include "I2C_Serial.h"
I2C_Serial myI2CSerial;
ProxySerial mySerial(&myI2CSerial);

// Arduino Case
#elif defined(__AVR__) 
#include "NewSoftSerial.h"
NewSoftSerial nss(2, 3); // RX, TX
ProxySerial mySerial(&nss);

// chipKIT Case
#elif defined(__PIC32MX__) 
ProxySerial Serial1;

#else
#error Non defined board
#endif


Serial_LCD myLCD( &mySerial); 

uint16_t x, y;
uint32_t l;

button b7( &myLCD);



void setup() {
  Serial.begin(19200);
  Serial.print("\n\n\n***\n");

  //#if defined(__AVR__)
  //  Serial.print("avr\t");
  //  Serial.print(__AVR__);
  //  Serial.print("\n");
  //#elif defined(__PIC32MX__) 
  //  Serial.print("chipKIT\t");
  //  Serial.print(__PIC32MX__);
  //  Serial.print("\n");
  //#endif 

#if defined(__i2cSerialPort__) 
  Wire.begin();
#endif 


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



