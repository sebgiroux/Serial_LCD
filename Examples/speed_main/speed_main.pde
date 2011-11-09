//
// Arduino Case : uncomment #include
// #if defined(__AVR__) doesn't work!
// ---
//#include "NewSoftSerial.h"
// ===

// Needs to be defined in both proxySerial and main program
//#define __i2cSerialPort__ 

#include "Serial_LCD.h"
#include "proxySerial.h"
#include "button.h"

ProxySerial mySerial(&Serial1);
 
Serial_LCD myLCD( &mySerial); 



uint16_t x, y;
uint32_t l;

button b7( &myLCD);



void setup() {
  Serial.begin(19200);
  Serial.print("\n\n\n***\n");

#if defined(__i2cSerialPort__) 
  Serial.print("i2cSerialPort\t");
  Serial.print("\n");
#elif defined(__AVR__)
  Serial.print("avr\t");
  Serial.print(__AVR__);
  Serial.print("\n");
#elif defined(__PIC32MX__) 
  Serial.print("chipKIT\t");
  Serial.print(__PIC32MX__);
  Serial.print("\n");
#endif 

#if defined(__i2cSerialPort__) 
  Wire.begin();
#endif

  Serial1.begin(9600);

  myLCD.begin();
  
//  // Very dirty area - for tests purposes only
//  // Arduino
//  Serial.print("speed \t");
//  nss.print('Q');
//  nss.print((uint8_t)0x0a); // 0x0a max
//  while (!nss.available());
//  Serial.print(nss.read(), HEX);
//  Serial.print("\n");
//  
//  nss.begin(38400); // 38400 max
//  // End of dirty area
  
//  // Very dirty area - for tests purposes only
//  // chipKIT
//  Serial.print("speed \t");
//  Serial1.print('Q');
//  Serial1.print((uint8_t)0x0d); // ok  
//  while (!Serial1.available());
//  Serial.print(Serial1.read(), HEX);
//  Serial.print("\n");
//  
//  Serial1.begin(115200); // ok
//  // End of dirty area
//  
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



















