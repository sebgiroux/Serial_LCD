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
// Oct 27, 2011 release 12 - setSpeed fixed for 155200 
// Nov 02, 2011 release 13 - HardwareSerial derived from Stream on chipKIT platform by msproul
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
#include "WProgram.h"
//#include "Arduino.h"

#ifndef button_h
#define button_h

class button {
public:
  button(Serial_LCD * pscreen0);

  void define(uint16_t x1, uint16_t y1, uint16_t dx1, uint16_t dy1, String text0, uint16_t textColour1, uint16_t highColour1, uint16_t lowColour1);
  void define(uint16_t x1, uint16_t y1, uint16_t dx1, uint16_t dy1, String text0, uint16_t textColour1, uint16_t highColour1, uint16_t lowColour1, uint8_t size0=9);
  bool state() {     
    return _enable;   
  }
  void draw(bool b1=false);
  void enable(bool b1); 
  bool check();

private:
  uint16_t _x1, _y1, _x2, _y2, _xt, _yt;
  uint16_t _textColour, _highColour, _lowColour;
  bool _enable;  
  String _text;
  Serial_LCD * _pscreen;
  uint8_t _size;
};


class dialog {
public:
  dialog(Serial_LCD * pscreen0);
  String prompt(String text0, uint8_t kind0, uint16_t textColour0, uint16_t highColour0, uint16_t lowColour0, String text1, String button1, uint16_t textColour1, uint16_t highColour1, uint16_t lowColour1);
  String prompt(String text0, uint8_t kind0, uint16_t textColour0, uint16_t highColour0, uint16_t lowColour0, String text1, String button1, uint16_t textColour1, uint16_t highColour1, uint16_t lowColour1, String text2, String button2, uint16_t textColour2, uint16_t highColour2, uint16_t lowColour2);
  String prompt(String text0, uint8_t kind0, uint16_t textColour0, uint16_t highColour0, uint16_t lowColour0, String text1, String button1, uint16_t textColour1, uint16_t highColour1, uint16_t lowColour1, String text2, String button2, uint16_t textColour2, uint16_t highColour2, uint16_t lowColour2, String text3, String button3, uint16_t textColour3, uint16_t highColour3, uint16_t lowColour3);

private:
  Serial_LCD * _pscreen;
  bool _checkedSD;


};

#endif








