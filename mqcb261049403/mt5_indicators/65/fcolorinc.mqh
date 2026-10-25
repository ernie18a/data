//+------------------------------------------------------------------+
//|                                                    fColorInc.mqh |
//|                             Copyright 2010, Loong@forum.mql4.com |
//|                                             Loong@forum.mql4.com |
//+------------------------------------------------------------------+
#property copyright "2010, Loong@forum.mql4.com"
#property link      "Loong@forum.mql4.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2005
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

//color iColor8Cycle[8] = {Red,OrangeRed,Gold,Yellow,Lime,Aqua,Blue,Magenta};
color iColor8Cycle[8] = {Red,Orange,Yellow,Lime,Aqua,Blue,Magenta,White};
// OrangeRed //DarkOrange

int ColorInc16(int i)
{
   color iColor = 0;
   int MA_Rinc=0;
   int MA_Ginc=0;
   int MA_Binc=0;
        if(i<=0) {iColor = 0x0000FF; MA_Rinc=  0; MA_Ginc=  0; MA_Binc=  0;}
   else if(i< 4) {iColor = 0x0000FF; MA_Rinc=  0; MA_Ginc= 96; MA_Binc=  0;}
   else if(i< 8) {iColor = 0x00FFFF; MA_Rinc=-96; MA_Ginc=  0; MA_Binc=  0;}
   else if(i<12) {iColor = 0x00FF00; MA_Rinc=  0; MA_Ginc=  0; MA_Binc= 96;}
   else if(i<16) {iColor = 0xFFFF00; MA_Rinc=  0; MA_Ginc=-96; MA_Binc=  0;}
   else if(i<20) {iColor = 0xFF0000; MA_Rinc= 96; MA_Ginc=  0; MA_Binc=  0;}
   else if(i<24) {iColor = 0xFF00FF; MA_Rinc=  0; MA_Ginc=  0; MA_Binc=-96;}
   else if(i<28) {iColor = 0x0000FF; MA_Rinc=  0; MA_Ginc= 96; MA_Binc=  0;}
   else if(i<32) {iColor = 0x00FFFF; MA_Rinc=-96; MA_Ginc=  0; MA_Binc=  0;}
   else          {iColor = 0x0000FF; MA_Rinc=  0; MA_Ginc=  0; MA_Binc=  0;}
   int iColorInc=(MA_Rinc+256*MA_Ginc+65536*MA_Binc);
   return iColor+iColorInc*(i%2);
}
int ColorInc32(int i)
{
   color iColor = 0;
   int MA_Rinc=0;
   int MA_Ginc=0;
   int MA_Binc=0;
        if(i<=0) {iColor = 0x0000FF; MA_Rinc=  0; MA_Ginc=  0; MA_Binc=  0;}
   else if(i< 4) {iColor = 0x0000FF; MA_Rinc=  0; MA_Ginc= 48; MA_Binc=  0;}
   else if(i< 8) {iColor = 0x00FFFF; MA_Rinc=-48; MA_Ginc=  0; MA_Binc=  0;}
   else if(i<12) {iColor = 0x00FF00; MA_Rinc=  0; MA_Ginc=  0; MA_Binc= 48;}
   else if(i<16) {iColor = 0xFFFF00; MA_Rinc=  0; MA_Ginc=-48; MA_Binc=  0;}
   else if(i<20) {iColor = 0xFF0000; MA_Rinc= 48; MA_Ginc=  0; MA_Binc=  0;}
   else if(i<24) {iColor = 0xFF00FF; MA_Rinc=  0; MA_Ginc=  0; MA_Binc=-48;}
   else if(i<28) {iColor = 0x0000FF; MA_Rinc=  0; MA_Ginc= 48; MA_Binc=  0;}
   else if(i<32) {iColor = 0x00FFFF; MA_Rinc=-48; MA_Ginc=  0; MA_Binc=  0;}
   else          {iColor = 0x0000FF; MA_Rinc=  0; MA_Ginc=  0; MA_Binc=  0;}
   int iColorInc=(MA_Rinc+256*MA_Ginc+65536*MA_Binc);
   return iColor+iColorInc*(i%4);
}
int ColorInc96(int i)
{
   color iColor = 0;
   int MA_Rinc=0;
   int MA_Ginc=0;
   int MA_Binc=0;
        if(i<=0) {iColor = 0x0000FF; MA_Rinc=  0; MA_Ginc=  0; MA_Binc=  0;}
   else if(i<16) {iColor = 0x0000FF; MA_Rinc=  0; MA_Ginc= 16; MA_Binc=  0;}
   else if(i<32) {iColor = 0x00FFFF; MA_Rinc=-16; MA_Ginc=  0; MA_Binc=  0;}
   else if(i<48) {iColor = 0x00FF00; MA_Rinc=  0; MA_Ginc=  0; MA_Binc= 16;}
   else if(i<64) {iColor = 0xFFFF00; MA_Rinc=  0; MA_Ginc=-16; MA_Binc=  0;}
   else if(i<80) {iColor = 0xFF0000; MA_Rinc= 16; MA_Ginc=  0; MA_Binc=  0;}
   else if(i<96) {iColor = 0xFF00FF; MA_Rinc=  0; MA_Ginc=  0; MA_Binc=-16;}
   else          {iColor = 0x0000FF; MA_Rinc=  0; MA_Ginc=  0; MA_Binc=  0;}
   int iColorInc=(MA_Rinc+256*MA_Ginc+65536*MA_Binc);
   return iColor+iColorInc*(i%16);
}
