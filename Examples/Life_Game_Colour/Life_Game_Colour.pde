//
// Life Game in Colour
//
// 
// Nov 06, 2011 release 1 - initial release
// Nov 07, 2011 release 2 - nicer colours!
//
//
// Required : Serial_LCD release 13
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
int scanline;
int df;
int rf;
uint16_t clut[16];

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
  //  while(!digitalRead(7)) {
  //    __asm__("nop\n\t");
  //  }
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

  // dying: from red to yellow to orange to black
  clut[8]=myLCD.rgb16(255, 0, 0);
  clut[9]=myLCD.rgb16(255, 85, 0);
  clut[10]=myLCD.rgb16(255, 170, 0);
  clut[11]=myLCD.rgb16(255, 255, 0);
  clut[12]=myLCD.rgb16(191, 191, 0);
  clut[13]=myLCD.rgb16(127, 127, 0);
  clut[14]=myLCD.rgb16(63, 63, 0);
  clut[15]=myLCD.rgb16(0, 0, 0);
  
  // living: from blue to green 3x 5 bits
  clut[0]=myLCD.rgb16(0, 255, 0);
  clut[1]=myLCD.rgb16(0, 204, 0);
  clut[2]=myLCD.rgb16(0, 153, 0);
  clut[3]=myLCD.rgb16(0, 102, 51);
  clut[4]=myLCD.rgb16(0, 51, 102);
  clut[5]=myLCD.rgb16(0, 0, 153);
  clut[6]=myLCD.rgb16(0, 0, 204);
  clut[7]=myLCD.rgb16(0, 0, 255);





  randomSeed(analogRead(0));
  df = 0;
  rf = 0;
  new_game();

  //  TRISECLR = 0xff;
  //  TRISDCLR = HSYNC_MASK | VSYNC_MASK;
  //  OC1CON = 0x0000;
  //  OC1R = 0x083a;
  //  OC1RS = 0x083a;
  //  OC1CON = 0x0006;
  //  PR2 = 0x08A6;
  //
  //  T4CON = 0x0;
  //  T5CON = 0x0;
  //  T4CONSET = 0x0038;            // divide by eight i.e. 1MHz
  //  TMR4 = 0x0;
  //  PR4 = 0x4C4B40;               // 10 million i.e. 1Second
  //
  //  LATDSET = HSYNC_MASK | VSYNC_MASK;
  //  IFS0CLR = _IFS0_T2IF_MASK | _IFS0_T5IF_MASK;
  //
  //  // enable the timers and output compare
  //  T2CONSET = 0x8000;
  //  T4CONSET = 0x8000;
  //  OC1CONSET = 0x8000;
  //
  //  ConfigIntTimer2((T2_INT_ON | T2_INT_PRIOR_3));
  //  delay(3000);
  //  mConfigIntCoreTimer((CT_INT_OFF));
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
  myLCD.rectangle(4*i, 4*j, 4*i+3, 4*j+3, clut[_screen[rf][i][j]]);
}

void loop() {
  int i, j;
  int neighbours;
  //  while(!(_IFS0_T5IF_MASK & IFS0)) {
  //    if(!digitalRead(7)) {
  //      new_game();
  //      //      TMR4 = 0;
  //    }
  //  }
  //  if(df == rf) {
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
  //  }
  //  TMR4 = 0;
  //  IFS0CLR = _IFS0_T5IF_MASK;
//  delay(300);
  if (myLCD.getTouchActivity()>0) {
    myLCD.off();
    while(1);
  }
}  

//// interrupt functions have to be C functions
//#ifdef __cplusplus
//extern "C" {
//#endif
//
//void __ISR(_TIMER_2_VECTOR, IPL3AUTO) scanline_handler(void) {
//  int i=0;
//  // keep track of how far down the _screen we've got
//  scanline++;
//  if(scanline < 480) {
//    // front porch
//    for(int i=0;i<HFRONTP;i++) {
//      __asm__("nop\n\t");
//    }
//
//    // main display
//    for(int i=0;i<80;i++) {
//      LATE = clut[_screen[df][scanline/8][i]];
//      __asm__("nop\n\t");
//      __asm__("nop\n\t");
//      __asm__("nop\n\t");
//      __asm__("nop\n\t");
//      __asm__("nop\n\t");
//      __asm__("nop\n\t");
//      __asm__("nop\n\t");
//      __asm__("nop\n\t");
//      __asm__("nop\n\t");
//      __asm__("nop\n\t");
//      __asm__("nop\n\t");
//      __asm__("nop\n\t");
//      __asm__("nop\n\t");
//      __asm__("nop\n\t");
//      __asm__("nop\n\t");
//    }
//  
//    // back porch
//    LATE = 0;
//  } else if(scanline == (480 + VBACKP)) {
//    LATDCLR = VSYNC_MASK;
//  } else if(scanline == (482 + VBACKP)) {
//    LATDSET = VSYNC_MASK;
//  } else if(scanline == 526) {
//    scanline = -1;
//    if(df != rf) {
//      df = rf;
//    }
//  }
//  
//  // make sure all the timer interrupt flags are clear and ready to trigger
//  // again
//  IFS0CLR = _IFS0_T2IF_MASK;
//}
//
//
//#ifdef __cplusplus
//}
//#endif









