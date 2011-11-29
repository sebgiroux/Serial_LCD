// Dialog example
//
// CC = BY NC SA
// http://sites.google.com/site/vilorei/

#include "WProgram.h"
//#include <Wire.h>

#include "Serial_LCD.h"
#include "button.h"

// Arduino Case : uncomment #include
// #if defined(__AVR__) doesn't work!
// ---
//#include "NewSoftSerial.h"
// ===

#include "proxySerial.h"

//// Arduino Case ---
#if defined(__AVR__)
#include "NewSoftSerial.h"
NewSoftSerial nss(2, 3); // RX, TX
ProxySerial mySerial(&nss);

// chipKIT Case ---
#elif defined(__PIC32MX__) 
ProxySerial mySerial(&Serial1);

#else
#error Non defined board
#endif 

Serial_LCD myLCD( &mySerial); 



uint16_t x, y;
uint32_t l;

button b7( &myLCD);
dialog d1( &myLCD);


void setup() {
  Serial.begin(19200);
  Serial.print("\n\n\n***\n");

#if defined(__AVR__)
  Serial.print("avr\t");
  Serial.print(__AVR__);
  Serial.print("\n");
  nss.begin(9600);
  
#elif defined(__PIC32MX__) 
  Serial.print("chipKIT\t");
  Serial.print(__PIC32MX__);
  Serial.print("\n");
  Serial1.begin(9600);
#endif 

  myLCD.begin();
  myLCD.setOrientation(0x03);

//  Wire.begin();

  myLCD.setPenSolid(true);
  myLCD.setFontSolid(true);

  myLCD.setFont(0);
  myLCD.gText( 0, 210, 0xffff, myLCD.WhoAmI());

  myLCD.setTouch(true);

  l=millis();

  //  Serial.print("*** SD ");
  //  Serial.print(myLCD.initSD(), DEC);
  //  Serial.print("\n");

  String s;
  Serial.println("prompt 1");
  s="*";
//  s=d1.prompt(String("Dialog 1"), uint8_t(1), myLCD.rgb16(0xff,0xff,0xff), myLCD.rgb16(0x20,0x20,0x20), myLCD.rgb16(0x80,0x80,0x80), String("First line"), String("OK"), myLCD.rgb16(0xff,0xff,0xff), myLCD.rgb16(0x00,0xff,0x00), myLCD.rgb16(0x00,0x80,0x00),"","",0,0,0,"","",0,0,0);
  s=d1.prompt(String("Dialog 1"), uint8_t(1), myLCD.rgb16(0xff,0xff,0xff), myLCD.rgb16(0x20,0x20,0x20), myLCD.rgb16(0x80,0x80,0x80), String("First line"), String("OK"), myLCD.rgb16(0xff,0xff,0xff), myLCD.rgb16(0x00,0xff,0x00), myLCD.rgb16(0x00,0x80,0x00));
  Serial.print(s);
  Serial.print("\n");

  myLCD.setFontSolid(true);
  myLCD.setFont(2);
  myLCD.gText(0, 160, 0xffff, s); 


  myLCD.setFont(3);
  myLCD.gText(0,  0, 0xffff, "         1         2    ");
  myLCD.gText(0, 20, 0xffff, "12345678901234567890123456"); 
  myLCD.gText(0, 40, 0xffff, ftoa(myLCD.fontX(), 0, 8)); 

  myLCD.setFont(2);
  myLCD.gText(0,  60, 0xffff, "         1         2         3         4");
  myLCD.gText(0, 80, 0xffff, "1234567890123456789012345678901234567890"); 
  myLCD.gText(0, 100, 0xffff, ftoa(myLCD.fontX(), 0, 8)); 

  myLCD.setFont(1);
  myLCD.gText(0,  120, 0xffff, "         1         2         3         4");
  myLCD.gText(0, 140, 0xffff, "1234567890123456789012345678901234567890"); 
  myLCD.gText(0, 160, 0xffff, ftoa(myLCD.fontX(), 0, 8)); 

  myLCD.setFont(0);
  myLCD.gText(0,  180, 0xffff, "         1         2         3         4         5");
  myLCD.gText(0, 200, 0xffff, "12345678901234567890123456789012345678901234567890123"); 
  myLCD.gText(0, 220, 0xffff, ftoa(myLCD.fontX(), 0, 8)); 



  // void dialog::prompt(String &result0, String text0, uint8_t kind0, uint16_t textColour0, uint16_t highColour0, uint16_t lowColour0,

  // String text1, String button1="OK", uint16_t textColour1=0xffff, uint16_t highColour1=0x000f, uint16_t lowColour1=0x0008, 
  // String text2="", String button2="", uint16_t textColour2=0, uint16_t highColour2=0, uint16_t lowColour2=0, 
  // String text3="", String button3="", uint16_t textColour3=0, uint16_t highColour3=0, uint16_t lowColour3=0) {



  Serial.println("prompt 2");
  s="*";
  s=d1.prompt(String("Dialog 2"), uint8_t(2), myLCD.rgb16(0xff,0xff,0xff), myLCD.rgb16(0x20,0x20,0x20), myLCD.rgb16(0x80,0x80,0x80), String("First line"), String("Yes"), myLCD.rgb16(0xff,0xff,0xff), myLCD.rgb16(0x00,0xff,0x00), myLCD.rgb16(0x00,0x80,0x00), "Second line","No",myLCD.rgb16(0xff,0xff,0xff), myLCD.rgb16(0xff,0x00,0x00), myLCD.rgb16(0x80,0x00,0x00),"Third line","Cancel",myLCD.rgb16(0xff,0xff,0xff), myLCD.rgb16(0xff,0xff,0x00), myLCD.rgb16(0x80,0x80,0x00));
  Serial.print(s);
  Serial.print("\n");

  myLCD.setFontSolid(true);
  myLCD.setFont(2);
  myLCD.gText(0, 160, 0xffff, s); 

  uint16_t i=9;
  b7.define( 160, 120, 79, 59, "STOP",        myLCD.rgb16(0xff, 0xff, 0xff), myLCD.rgb16(0xff, 0x00, 0x00), myLCD.rgb16(0x88, 0x00, 0x00), i);

  b7.enable(true);
  b7.draw();

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

