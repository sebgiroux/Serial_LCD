//
// Life Game in Colour
//
// 
// Nov 06, 2011 release 1 - initial release
// Nov 07, 2011 release 2 - nicer colours!
// Nov 08, 2011 release 3 - speedier display
// Nov 11, 2011 release 4 - revised calculation for 16 colours
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

#define ROWS 80
#define COLS 60
#define PERCENT 70 // % dead

// bits 7 . 6 . 5 . 4 . 3 . 2 . 1 . 0
// [3] = dead 0, alive 1
// [2..0] = age 0-7 

#define ALIVE 0x08
#define DEAD  0x00

#define NMASK 0x08
#define AGEMASK 0x07

ProxySerial myPort(&Serial1); 
Serial_LCD myLCD(&myPort); 

uint8_t _screen[2][ROWS][COLS]; 
uint32_t t; 
uint8_t scanline; 
uint8_t df; 
uint8_t rf; 
uint16_t clut[16]; 
uint16_t generation; 

void new_game() {
  uint8_t i, j; 
  if(rf == df) {
    for(i=0; i<ROWS; i++) {
      for(j=0; j<COLS; j++) {
        if(random(100)>PERCENT) {
          _screen[rf^1][i][j] = ALIVE; 
        } 
        else {
          _screen[rf^1][i][j] = DEAD; 
        }
        myLCD.rectangle(4*i, 4*j, 4*i+3, 4*j+3, clut[_screen[rf^1][i][j]]);
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
  clut[ 0] = myLCD.rgb16(  0, 255,   0); 
  clut[ 1] = myLCD.rgb16(  0, 204,  51); 
  clut[ 2] = myLCD.rgb16(  0, 153, 102); 
  clut[ 3] = myLCD.rgb16(  0, 102, 153); 
  clut[ 4] = myLCD.rgb16(  0,  51, 204); 
  clut[ 5] = myLCD.rgb16(  0,   0, 255); 
  clut[ 6] = myLCD.rgb16(  0,   0, 127); 
  clut[ 7] = myLCD.rgb16(  0,   0,   0); 


  // 8-15 living: hot colours
  // from red to orange to yellow
  clut[ 8] = myLCD.rgb16(255,   0,   0); 
  clut[ 9] = myLCD.rgb16(255,  43,   0); 
  clut[10] = myLCD.rgb16(255,  85,   0); 
  clut[11] = myLCD.rgb16(255, 127,   0); 
  clut[12] = myLCD.rgb16(255, 171,   0); 
  clut[13] = myLCD.rgb16(255, 213,   0); 
  clut[14] = myLCD.rgb16(255, 255,   0); 
  clut[15] = myLCD.rgb16(255, 255, 255); 

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

  delay(4000); 

  myLCD.clear(); 

  randomSeed(analogRead(0)); 
  df = 0; 
  rf = 0; 
  new_game(); 

}


void update_pixel(uint8_t i, uint8_t j, uint8_t neighbours) {
  if( bitRead(_screen[rf][i][j], 3) ) {
    // alive
    if((neighbours < 2) || (neighbours > 3)) { 
      _screen[rf^1][i][j] = DEAD;   // zero age dead pixel      // 0 pass
    }  
    else {
      _screen[rf^1][i][j] = _screen[rf][i][j] + 1;             // 8-15 living
      if (_screen[rf^1][i][j] > 0x0f) { 
        _screen[rf^1][i][j] = 0x0f; 
      } 
    }
  }   
  else {
    // dead
    if((neighbours == 3)) {
      _screen[rf^1][i][j] = ALIVE; // zero age alive pixel     // 8 born
    }     
    else { 
      _screen[rf^1][i][j] = _screen[rf][i][j] + 1;             // 0-7 dying
      if (_screen[rf^1][i][j] > 0x07) { 
        _screen[rf^1][i][j] = 0x07; 
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
    myLCD.rectangle(4*i, 4*j, 4*i+3, 4*j+3, clut[_screen[rf^1][i][j]]); 
}

void loop() {
  uint8_t i, j; 
  uint8_t neighbours; 

  generation++; 

  for(i=1; i<ROWS-1; i++) {
    for(j=1; j<COLS-1; j++) {
      neighbours  = bitRead(_screen[rf][i-1][j-1], 3); 
      neighbours += bitRead(_screen[rf][i-1][j  ], 3); 
      neighbours += bitRead(_screen[rf][i-1][j+1], 3); 
      neighbours += bitRead(_screen[rf][i  ][j-1], 3); 
      neighbours += bitRead(_screen[rf][i  ][j+1], 3); 
      neighbours += bitRead(_screen[rf][i+1][j-1], 3); 
      neighbours += bitRead(_screen[rf][i+1][j  ], 3); 
      neighbours += bitRead(_screen[rf][i+1][j+1], 3); 
      update_pixel(i,j, neighbours); 
    }
  }
  for(i=1; i<COLS-1; i++) {
    neighbours  = bitRead(_screen[rf][0     ][i-1], 3); 
    neighbours += bitRead(_screen[rf][0     ][i+1], 3); 
    neighbours += bitRead(_screen[rf][1     ][i-1], 3); 
    neighbours += bitRead(_screen[rf][1     ][i  ], 3); 
    neighbours += bitRead(_screen[rf][1     ][i+1], 3); 
    neighbours += bitRead(_screen[rf][ROWS-1][i-1], 3); 
    neighbours += bitRead(_screen[rf][ROWS-1][i  ], 3); 
    neighbours += bitRead(_screen[rf][ROWS-1][i+1], 3); 
    update_pixel(0, i, neighbours); 

    neighbours  = bitRead(_screen[rf][ROWS-2][i-1], 3); 
    neighbours += bitRead(_screen[rf][ROWS-2][i  ], 3); 
    neighbours += bitRead(_screen[rf][ROWS-2][i+1], 3); 
    neighbours += bitRead(_screen[rf][ROWS-1][i-1], 3); 
    neighbours += bitRead(_screen[rf][ROWS-1][i+1], 3); 
    neighbours += bitRead(_screen[rf][0     ][i-1], 3); 
    neighbours += bitRead(_screen[rf][0     ][i  ], 3); 
    neighbours += bitRead(_screen[rf][0     ][i+1], 3); 
    update_pixel(ROWS-1,i, neighbours); 
  }
  for(i=1; i<ROWS-1; i++) {
    neighbours  = bitRead(_screen[rf][i-1][0     ], 3); 
    neighbours += bitRead(_screen[rf][i+1][0     ], 3); 
    neighbours += bitRead(_screen[rf][i-1][1     ], 3); 
    neighbours += bitRead(_screen[rf][i  ][1     ], 3); 
    neighbours += bitRead(_screen[rf][i+1][1     ], 3); 
    neighbours += bitRead(_screen[rf][i-1][COLS-1], 3); 
    neighbours += bitRead(_screen[rf][i  ][COLS-1], 3); 
    neighbours += bitRead(_screen[rf][i+1][COLS-1], 3); 
    update_pixel(i, 0, neighbours); 

    neighbours  = bitRead(_screen[rf][i-1][COLS-1], 3); 
    neighbours += bitRead(_screen[rf][i+1][COLS-1], 3); 
    neighbours += bitRead(_screen[rf][i-1][COLS-2], 3); 
    neighbours += bitRead(_screen[rf][i  ][COLS-2], 3); 
    neighbours += bitRead(_screen[rf][i+1][COLS-2], 3); 
    neighbours += bitRead(_screen[rf][i-1][0     ], 3); 
    neighbours += bitRead(_screen[rf][i  ][0     ], 3); 
    neighbours += bitRead(_screen[rf][i+1][0     ], 3); 
    update_pixel(i,COLS-1, neighbours); 
  }

  neighbours  = bitRead(_screen[rf][1     ][0     ], 3); 
  neighbours += bitRead(_screen[rf][1     ][1     ], 3); 
  neighbours += bitRead(_screen[rf][0     ][1     ], 3); 
  neighbours += bitRead(_screen[rf][ROWS-1][0     ], 3); 
  neighbours += bitRead(_screen[rf][ROWS-1][1     ], 3); 
  neighbours += bitRead(_screen[rf][ROWS-1][COLS-1], 3); 
  neighbours += bitRead(_screen[rf][0     ][COLS-1], 3); 
  neighbours += bitRead(_screen[rf][1     ][COLS-1], 3); 
  update_pixel(0,0, neighbours); 

  neighbours  = bitRead(_screen[rf][1     ][0     ], 3); 
  neighbours += bitRead(_screen[rf][0     ][0     ], 3); 
  neighbours += bitRead(_screen[rf][0     ][COLS-2], 3); 
  neighbours += bitRead(_screen[rf][1     ][COLS-2], 3); 
  neighbours += bitRead(_screen[rf][1     ][COLS-1], 3); 
  neighbours += bitRead(_screen[rf][ROWS-1][COLS-1], 3); 
  neighbours += bitRead(_screen[rf][ROWS-1][COLS-2], 3); 
  neighbours += bitRead(_screen[rf][ROWS-1][0     ], 3); 
  update_pixel(0,COLS-1, neighbours); 

  neighbours  = bitRead(_screen[rf][ROWS-1][1     ], 3); 
  neighbours += bitRead(_screen[rf][ROWS-2][0     ], 3); 
  neighbours += bitRead(_screen[rf][ROWS-2][1     ], 3); 
  neighbours += bitRead(_screen[rf][ROWS-1][COLS-1], 3); 
  neighbours += bitRead(_screen[rf][ROWS-2][COLS-1], 3); 
  neighbours += bitRead(_screen[rf][0     ][COLS-1], 3); 
  neighbours += bitRead(_screen[rf][0     ][0     ], 3); 
  neighbours += bitRead(_screen[rf][0     ][1     ], 3); 
  update_pixel(ROWS-1,0, neighbours); 

  neighbours  = bitRead(_screen[rf][ROWS-1][COLS-2], 3); 
  neighbours += bitRead(_screen[rf][ROWS-2][COLS-2], 3); 
  neighbours += bitRead(_screen[rf][ROWS-2][COLS-1], 3); 
  neighbours += bitRead(_screen[rf][ROWS-1][0     ], 3); 
  neighbours += bitRead(_screen[rf][ROWS-2][0     ], 3); 
  neighbours += bitRead(_screen[rf][0     ][0     ], 3); 
  neighbours += bitRead(_screen[rf][0     ][COLS-1], 3); 
  neighbours += bitRead(_screen[rf][1     ][COLS-2], 3); 
  update_pixel(ROWS-1,COLS-1, neighbours); 

  rf ^= 1; 

  // generation
  myLCD.setFont(3); 
  myLCD.gText(210, 235-myLCD.fontY(), 0xffff, ftoa(generation, 0, 5)); 

  // calculation time in seconds
  myLCD.setFont(1); 
  myLCD.gText(280, 235-myLCD.fontY(), 0xffff, ftoa((millis()-t)/1000.0, 1, 4)); 
  t=millis(); 

  // touch to stop
  if (myLCD.getTouchActivity()>0) {
    myLCD.off(); 
    while(1); 
  }
}  











