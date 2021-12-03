/***************************************************** 
* Copyright (c) 2013, Regents of National Taiwan University
* All rights reserved.
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*        notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of the National Taiwan University nor the
*       names of its contributors may be used to endorse or promote products
*       derived from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS "AS IS" AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE REGENTS AND CONTRIBUTORS BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
****************************************************/
//GaussSenseV1 32x16 (WSH136) 8Bit RawHID [TCP]

const int SEN_ROW = 16;
const int SEN_COL = 16;
const int SEN_NUM = 256;

const int BOARD_NUM = 2;
byte sensorVal[SEN_NUM*BOARD_NUM];

const int BUFFER_SIZE = 64;



int selPin[] = {
  0,1,2,3};
int muxInPin[] = {
  4,5,6,7};

int r0 = 0, r1 = 0, r2 = 0, r3 = 0;
int e0 = 0, e1 = 0, e2 = 0, e3 = 0;
int x = 0, y = 0 , z = 0;

char recvBuf[BUFFER_SIZE];
char sendBuf[BUFFER_SIZE];

int bytes = 8;
int txLed = 0;

void setup()
{
  for(int i = 0 ; i < 4 ; i++)
  {
    pinMode(muxInPin[i], OUTPUT);
    pinMode(selPin[i], OUTPUT);
  }

}

void loop()
{
  //input / output
  if (RawHID.available())
  {
    RawHID.recv(recvBuf, 100);
    if (recvBuf[0] == 'a') 
    {      
      RawHID.send(&sensorVal[0], bytes);
      RawHID.send(&sensorVal[64], bytes);
      RawHID.send(&sensorVal[128], bytes);
      RawHID.send(&sensorVal[192], bytes);
      RawHID.send(&sensorVal[256], bytes);
      RawHID.send(&sensorVal[320], bytes);
      RawHID.send(&sensorVal[384], bytes);
      RawHID.send(&sensorVal[448], bytes);

      digitalWrite(11, txLed);
      txLed = 1-txLed;
    }
  }

  //update sensor value
  for (x=0; x<SEN_ROW; x++) {
    e0 = x & 0x01;
    e1 = (x>>1) & 0x01;
    e2 = (x>>2) & 0x01;
    e3 = (x>>3) & 0x01;
    digitalWrite(selPin[0], e0);
    digitalWrite(selPin[1], e1);
    digitalWrite(selPin[2], e2);
    digitalWrite(selPin[3], e3);
    for (y=0; y<SEN_COL; y++) {
      r0 = y & 0x01;
      r1 = (y>>1) & 0x01;
      r2 = (y>>2) & 0x01;
      r3 = (y>>3) & 0x01;
      digitalWrite(muxInPin[0], r0);
      digitalWrite(muxInPin[1], r1);
      digitalWrite(muxInPin[2], r2);
      digitalWrite(muxInPin[3], r3);
      for(z = 0; z < BOARD_NUM; z++){
        int v = analogRead(z);
        
        /*CUSTOMIZE SENSING RANGE HERE*/
        v-=384;
        if(v<0) v = 0;
        if(v>255) v = 255;
        /*CUSTOMIZE SENSING RANGE HERE*/
        
        sensorVal[y* (SEN_ROW*BOARD_NUM) + (z*SEN_ROW) + x] = v;
      }
    }
  }
}



