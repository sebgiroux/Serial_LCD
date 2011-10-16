
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
//
// CC = BY NC SA
// http://sites.google.com/site/vilorei/
//
#include "WProgram.h"
//#include "Arduino.h"

// Needs to be defined in both proxySerial and main program
//#define __i2cSerialPort__ 

#define securityDelay 3

// I2C case
#if defined(__i2cSerialPort__) 
#include "Wire.h"
#include "i2cSerial.h"

// Arduino Case
#elif defined(__AVR__) 
#include "NewSoftSerial.h"

// chipKIT Case
#elif defined(__PIC32MX__) 

#else
#error Non defined board
#endif

#ifndef proxySerial_h
#define proxySerial_h

class ProxySerial
{
public:
  // I2C case
#if defined(__i2cSerialPort__) 
  ProxySerial(i2cSerial * port0);

  // Arduino Case
#elif defined(__AVR__) 
  ProxySerial(NewSoftSerial * port0);

  // chipKIT Case
#elif defined(__PIC32MX__) 
  ProxySerial(HardwareSerial * port0);

#else
#error Non defined board
#endif


  void begin(uint16_t b);
  void print(int8_t i);
  void print(uint8_t ui);
  void print(int16_t i);
  void print(uint16_t ui);
  void print(char c);
  void print(String s);

  uint8_t read();
  int8_t available();
  void flush();

private:
  uint16_t _millis;
  void _checkSpeed();

  // I2C case
#if defined(__i2cSerialPort__) 
  i2cSerial * _proxyPort;

  // Arduino Case
#elif defined(__AVR__) 
  NewSoftSerial * _proxyPort;

  // chipKIT Case
#elif defined(__PIC32MX__) 
  HardwareSerial * _proxyPort;

#else
#error Non defined board
#endif

};

#endif




