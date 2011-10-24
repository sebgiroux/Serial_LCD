//
// SC16IS750 I2C slave bridge to serial
// Arduino Library
//
// Oct 06, 2011 release 1 - initial release
// Oct 10, 2011 release 2 - Stream.h class based
//
//
// CC = BY NC SA
// http://sites.google.com/site/vilorei/
//

#ifndef i2cSerial_h
#define i2cSerial_h

#include "WProgram.h"
#include <Stream.h>
#include <Wire.h>

class i2cSerial : public Stream
{
public:
  i2cSerial(); // constructor
  String WhoAmI();
  void begin(long b=9600);
  boolean test();

  virtual void write(uint8_t byte);
  virtual int read();
  virtual int available();
  virtual void flush();

  virtual int peek(); // !
  int free();       // TX

private:
  int8_t _address;
};

#endif




