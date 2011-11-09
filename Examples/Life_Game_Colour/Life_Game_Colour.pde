//
// Life Game in Colour
//
// 
// Nov 06, 2011 release 1 - initial release
// Nov 07, 2011 release 2 - nicer colours!
// Nov 08, 2011 release 3 - speedier display
//
//
// Required : Serial_LCD release 14
// Nov 09, 2011 release 14 - proxySerial as autonomous project with ftoa utility
//
// Based on http://nathandumont.com/node/245
// Submitted by nathan on Fri, 11/04/2011 - 20:46
//
// CC = BY NC SA
// http://sites.google.com/site/vilorei/
// http://github.com/rei-vilo/Serial_LCD
//
//
#include "proxySerial.h"
#include "Serial_LCD.h"

#define HSYNC_MASK 0x01
#define VSYNC_MASK 0x02

#define HFRONTP 12
#define HBACKP 33
#define VBACKP 4

#define ROWS 80
#define COLS 60

#define ALIVE 0x08
#define DEAD 0x00

#define NMASK 0x08
#define AGEMASK 0x07

ProxySerial myPort(&Serial1);
Serial_LCD myLCD(&myPort);

uint8_t _screen[2][ROWS][COLS];
uint32_t t;
int scanline;
int df;
int rf;
uint16_t clut[16];
uint16_t generation;

void new_game() {
  int i, j;
  if(rf == df) {
    for(int i=0;i<ROWS;i++) {
      for(int j=0;j<COLS;j++) {
        if(random(100)>70) {
          _screen[rf^1][i][j] = ALIVE;
        } 
        else {
          _screen[rf^1][i][j] = DEAD;
        }
      }
    }
  }
  rf ^= 1;
  generation=0;
  t=millis();
}




void setup() {
  //  Serial.begin(19800);
  //  Serial.print("\n\n\n***\n");

  Serial1.begin(9600);
  myLCD.begin();

  myLCD.setSpeed(115200);
  Serial1.begin(115200);

  myLCD.setOrientation(0x03);

  myLCD.setPenSolid(true);
  myLCD.setTouch(true);

  // 0-7 dying: cold colours
  // from green to blue to black
  clut[ 0] = myLCD.rgb16(0, 255,   0);
  clut[ 1] = myLCD.rgb16(0, 191,  63);
  clut[ 2] = myLCD.rgb16(0, 127, 127);
  clut[ 3] = myLCD.rgb16(0,  63, 191);
  clut[ 4] = myLCD.rgb16(0,   0, 255);
  clut[ 5] = myLCD.rgb16(0,   0, 127);
  clut[ 6] = myLCD.rgb16(0,   0,   0);
  clut[ 7] = myLCD.rgb16(0,   0,   0); // never used?


  // 8-15 living: hot colours
  // from red to orange to yellow
  clut[ 8] = myLCD.rgb16(255,   0, 0);
  clut[ 9] = myLCD.rgb16(255,  43, 0);
  clut[10] = myLCD.rgb16(255,  85, 0);
  clut[11] = myLCD.rgb16(255, 127, 0);
  clut[12] = myLCD.rgb16(255, 171, 0);
  clut[13] = myLCD.rgb16(255, 213, 0);
  clut[14] = myLCD.rgb16(255, 255, 0);
  clut[15] = myLCD.rgb16(255, 255, 0); // never used? 

  myLCD.setFontSolid(true);
  myLCD.setFont(3);
  myLCD.gText(40, 20, 0xffff, "Life Game");

  myLCD.setFont(2);
  myLCD.gText(40+16*8, 80, 0xffff, "Death");
  for (uint8_t i=0; i<8; i++) 
    myLCD.rectangle(128+40+16*i, 60, 128+40+16*i+15, 60+16, clut[i]);

  myLCD.gText(40+16*0, 80, 0xffff, "Life");
  for (uint8_t i=8; i<16; i++) 
    myLCD.rectangle(40+16*i-128, 60, 40+16*i+15-128, 60+16, clut[i]);
  
  myLCD.setFont(0);
  myLCD.gText(40, 120, 0xffff, "Touch to stop the game.");

  delay(5000);
  
  myLCD.clear();

  randomSeed(analogRead(0));
  df = 0;
  rf = 0;
  new_game();

}


void update_pixel(int i, int j, int neighbours) {
  if(_screen[rf][i][j] & NMASK) {
    // alive
    if((neighbours < (2*NMASK)) || (neighbours > (3*NMASK))) {
      _screen[rf^1][i][j] = DEAD;	// zero age dead pixel
    } 
    else {
      if((_screen[rf][i][j] & AGEMASK) < AGEMASK) {
        _screen[rf^1][i][j] = ALIVE | ((_screen[rf][i][j] + 1) & AGEMASK);
      } 
      else {
        _screen[rf^1][i][j] = 0xf;
      }
    }
  } 
  else {
    // dead
    if((neighbours == (3*NMASK))) {
      _screen[rf^1][i][j] = ALIVE; // zero age alive pixel
    } 
    else {
      if((_screen[rf][i][j] & AGEMASK) < AGEMASK) {
        _screen[rf^1][i][j] = DEAD | ((_screen[rf][i][j] + 1) & AGEMASK);
      } 
      else {
        _screen[rf^1][i][j] = 0x7;
      }
    }
  }

  //  Serial.print(i, DEC);
  //  Serial.print("\t");  
  //  Serial.print(j, DEC);
  //  Serial.print("\t");
  //  Serial.print(_screen[rf][i][j], HEX);
  //  Serial.print("\t");
  //  Serial.print(clut[_screen[rf][i][j]]);
  //  Serial.print("\n");

  //  myLCD.point(i, j, clut[_screen[rf][i][j]]);

  if(_screen[rf][i][j]!=_screen[rf^1][i][j]) 
    myLCD.rectangle(4*i, 4*j, 4*i+3, 4*j+3, clut[_screen[rf][i][j]]);
}

void loop() {
  int i, j;
  int neighbours;

  generation++;

  for(i=1;i<ROWS-1;i++) {
    for(j=1;j<COLS-1;j++) {
      neighbours = _screen[rf][i-1][j-1] & NMASK;
      neighbours += _screen[rf][i-1][j] & NMASK;
      neighbours += _screen[rf][i-1][j+1] & NMASK;
      neighbours += _screen[rf][i][j-1] & NMASK;
      neighbours += _screen[rf][i][j+1] & NMASK;
      neighbours += _screen[rf][i+1][j-1] & NMASK;
      neighbours += _screen[rf][i+1][j] & NMASK;
      neighbours += _screen[rf][i+1][j+1] & NMASK;

      update_pixel(i,j, neighbours);
    }
  }
  for(i=1;i<COLS-1;i++) {
    neighbours = _screen[rf][0][i-1] & NMASK;
    neighbours += _screen[rf][0][i+1] & NMASK;
    neighbours += _screen[rf][1][i-1] & NMASK;
    neighbours += _screen[rf][1][i] & NMASK;
    neighbours += _screen[rf][1][i+1] & NMASK;
    neighbours += _screen[rf][ROWS-1][i-1] & NMASK;
    neighbours += _screen[rf][ROWS-1][i] & NMASK;
    neighbours += _screen[rf][ROWS-1][i+1] & NMASK;
    update_pixel(0, i, neighbours);

    neighbours = _screen[rf][ROWS-2][i-1] & NMASK;
    neighbours += _screen[rf][ROWS-2][i] & NMASK;
    neighbours += _screen[rf][ROWS-2][i+1] & NMASK;
    neighbours += _screen[rf][ROWS-1][i-1] & NMASK;
    neighbours += _screen[rf][ROWS-1][i+1] & NMASK;
    neighbours += _screen[rf][0][i-1] & NMASK;
    neighbours += _screen[rf][0][i] & NMASK;
    neighbours += _screen[rf][0][i+1] & NMASK;
    update_pixel(ROWS-1,i, neighbours);
  }
  for(i=1;i<ROWS-1;i++) {
    neighbours = _screen[rf][i-1][0] & NMASK;
    neighbours += _screen[rf][i+1][0] & NMASK;
    neighbours += _screen[rf][i-1][1] & NMASK;
    neighbours += _screen[rf][i][1] & NMASK;
    neighbours += _screen[rf][i+1][1] & NMASK;
    neighbours += _screen[rf][i-1][COLS-1] & NMASK;
    neighbours += _screen[rf][i][COLS-1] & NMASK;
    neighbours += _screen[rf][i+1][COLS-1] & NMASK;
    update_pixel(i, 0, neighbours);

    neighbours = _screen[rf][i-1][COLS-1] & NMASK;
    neighbours += _screen[rf][i+1][COLS-1] & NMASK;
    neighbours += _screen[rf][i-1][COLS-2] & NMASK;
    neighbours += _screen[rf][i][COLS-2] & NMASK;
    neighbours += _screen[rf][i+1][COLS-2] & NMASK;
    neighbours += _screen[rf][i-1][0] & NMASK;
    neighbours += _screen[rf][i][0] & NMASK;
    neighbours += _screen[rf][i+1][0] & NMASK;
    update_pixel(i,COLS-1, neighbours);
  }

  neighbours = _screen[rf][1][0] & NMASK;
  neighbours += _screen[rf][1][1] & NMASK;
  neighbours += _screen[rf][0][1] & NMASK;
  neighbours += _screen[rf][ROWS-1][0] & NMASK;
  neighbours += _screen[rf][ROWS-1][1] & NMASK;
  neighbours += _screen[rf][ROWS-1][COLS-1] & NMASK;
  neighbours += _screen[rf][0][COLS-1] & NMASK;
  neighbours += _screen[rf][1][COLS-1] & NMASK;
  update_pixel(0,0, neighbours);

  neighbours = _screen[rf][1][0] & NMASK;
  neighbours += _screen[rf][0][0] & NMASK;
  neighbours += _screen[rf][0][COLS-2] & NMASK;
  neighbours += _screen[rf][1][COLS-2] & NMASK;
  neighbours += _screen[rf][1][COLS-1] & NMASK;
  neighbours += _screen[rf][ROWS-1][COLS-1] & NMASK;
  neighbours += _screen[rf][ROWS-1][COLS-2] & NMASK;
  neighbours += _screen[rf][ROWS-1][0] & NMASK;
  update_pixel(0,COLS-1, neighbours);

  neighbours = _screen[rf][ROWS-1][1] & NMASK;
  neighbours += _screen[rf][ROWS-2][0] & NMASK;
  neighbours += _screen[rf][ROWS-2][1] & NMASK;
  neighbours += _screen[rf][ROWS-1][COLS-1] & NMASK;
  neighbours += _screen[rf][ROWS-2][COLS-1] & NMASK;
  neighbours += _screen[rf][0][COLS-1] & NMASK;
  neighbours += _screen[rf][0][0] & NMASK;
  neighbours += _screen[rf][0][1] & NMASK;
  update_pixel(ROWS-1,0, neighbours);

  neighbours = _screen[rf][ROWS-1][COLS-2] & NMASK;
  neighbours += _screen[rf][ROWS-2][COLS-2] & NMASK;
  neighbours += _screen[rf][ROWS-2][COLS-1] & NMASK;
  neighbours += _screen[rf][ROWS-1][0] & NMASK;
  neighbours += _screen[rf][ROWS-2][0] & NMASK;
  neighbours += _screen[rf][0][0] & NMASK;
  neighbours += _screen[rf][0][COLS-1] & NMASK;
  neighbours += _screen[rf][1][COLS-2] & NMASK;
  update_pixel(ROWS-1,COLS-1, neighbours);

  rf ^= 1;

  myLCD.setFontSolid(true);
  myLCD.setFont(3);
  myLCD.gText(210, 235-myLCD.fontY(), 0xffff, ftoa(generation, 0, 5));
  myLCD.setFont(1);
  myLCD.gText(280, 235-myLCD.fontY(), 0xffff, ftoa((millis()-t)/1000.0, 1, 4));
  t=millis();


  if (myLCD.getTouchActivity()>0) {
    myLCD.off();
    while(1);
  }
}  





