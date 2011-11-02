//
// μLCD-32PT(SGC) 3.2” Serial LCD Display Module
// Arduino Library
//
// May 10, 2011 - Sample Code
// Jul 31, 2011 - stdint.h library for chipKIT compatibility
//

//
// CC = BY NC SA
// http://sites.google.com/site/vilorei/
//
// Based on
// 4D LABS PICASO-SGC Command Set
// Software Interface Specification
// Document Date: 1st March 2011 
// Document Revision: 6.0
// http://www.4d-Labs.com

//int foo;

#include "Serial_LCD.h"

//// Arduino Case : uncomment #include
//#if defined(__AVR__) // doesn't work!
//// ---
//#include "NewSoftSerial.h"
//// ===
//#endif

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

uint8_t aa;

void setup() {
  Serial.begin(19200);
  Serial.print("\n\n\n***\n");

  myLCD.begin();

delay(100);
  aa=myLCD.setOrientation(0x03);

delay(100);
  Serial.print("\n line \t");
  aa=myLCD.line(0,0,100,100, myLCD.rgb16(0,255,0));
  Serial.print(aa, DEC);

delay(100);
  Serial.print("\n rectangle \t");
  aa=myLCD.rectangle(239,0,319,256, myLCD.rgb16(255,0,0));
  Serial.print(aa, DEC);

delay(100);
  Serial.print("\n circle \t");
  aa=myLCD.circle(200,100, 50, myLCD.rgb16(0,0,255));
  Serial.print(aa, DEC);

delay(200);
  Serial.print("\n setFont \t");
  aa=myLCD.setFont(2);
  Serial.print(aa, DEC);

delay(100);
  Serial.print("\n gText \t");
  aa=myLCD.gText(25, 25, 0xffff, "String");
  Serial.print(aa, DEC);

delay(100);
//  Serial.print("\n tText \t");
//  aa=myLCD.tText(0, 19, 0xffff, "WhoAmI? "+ myLCD.WhoAmI());
//  Serial.print(aa, DEC);

//  for (uint8_t i=0; i<myLCD.WhoAmI().length(); i++)   
//    Serial.print(myLCD.WhoAmI().charAt(i));
//  Serial.print("\n");

  delay(100);

delay(1000);
  Serial.print("\n triangle \t");
  aa=myLCD.triangle(160, 200, 80, 160, 60, 100, 0xffff);
  Serial.print(aa, DEC);

delay(100);
  Serial.print("\n setTouch \t");
  aa=myLCD.setTouch(true);
  Serial.print(aa, DEC);

  Serial.print("\n ");
}

uint16_t x, y;
uint8_t b;

void loop() {


  Serial.print("\n getTouchActivity \t");
  aa=myLCD.getTouchActivity();
  Serial.print(aa, DEC);


  if (aa) {
aa=0;
Serial.print(" * " );
    Serial.print("\t getTouchXY \t");
    aa=myLCD.getTouchXY(x, y);
delay(10);
    Serial.print(aa, DEC);

    Serial.print("\t");
    Serial.print(x, DEC );      
    Serial.print("\t");
    Serial.print(y, DEC );

    if (x>256) {
      myLCD.off();
      while(1);
    }
    Serial.println();
  }


  delay(200);

}












