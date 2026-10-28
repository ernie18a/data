/*-------------------------------------------------------------------+
 |                                                MaEnv_02B_v3a.mq4  |
 |                                                 Copyright © 2010  |
 |                                             basisforex@gmail.com  |
 +-------------------------------------------------------------------*/
#property copyright "Copyright © 2010, basisforex@gmail.com"
#property link      "basisforex@gmail.com"
//------------------------------
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Yellow
#property indicator_color2 Yellow
#property indicator_color3 Aqua
#property indicator_color4 Aqua
#property indicator_color5 Blue
#property indicator_color6 Blue
#property indicator_color7 Red
#property indicator_color8 Red
//----------------------------
int    BorisKoeff;
double aquaUp1[];
double aquaDn1[];
double aquaUp2[];
double aquaDn2[];
double aquaUp3[];
double aquaDn3[];
double aquaUp4[];
double aquaDn4[];
double yMA[];
//--------------
int init()
 {
   IndicatorBuffers(8);
   //-----
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, aquaUp1);
   SetIndexDrawBegin(0, 0);
   //-----
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, aquaDn1);
   SetIndexDrawBegin(1, 0);
   //-------------------------
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, aquaUp2);
   SetIndexDrawBegin(2, 0);
   //-----
   SetIndexStyle(3, DRAW_LINE);
   SetIndexBuffer(3, aquaDn2);
   SetIndexDrawBegin(3, 0);
   //-------------------------
   SetIndexStyle(4, DRAW_LINE);
   SetIndexBuffer(4, aquaUp3);
   SetIndexDrawBegin(4, 0);
   //-----
   SetIndexStyle(5, DRAW_LINE);
   SetIndexBuffer(5, aquaDn3);
   SetIndexDrawBegin(5, 0);
   //-------------------------
   SetIndexStyle(6, DRAW_LINE);
   SetIndexBuffer(6, aquaUp4);
   SetIndexDrawBegin(6, 0);
   //-----
   SetIndexStyle(7, DRAW_LINE);
   SetIndexBuffer(7, aquaDn4);
   SetIndexDrawBegin(7, 0);
   //-------------------------
   return(0);
 }
//+------------------------------------------------------------------+
int GetBorisKoeff()
 { 
   if(Period() <= 5) return(1); 
   else if(Period() <= 15) return(2); 
   else if(Period() <= 30) return(3); 
   else if(Period() <= 60) return(4); 
   else if(Period() <= 240) return(8);//5); 
   else if(Period() <= 1440) return(14);//7);
   else if(Period() <= 10080) return(20);//9);
   else return(25);//15);
 }
//+------------------------------------------------------------------+ 
int start()
 {
   int limit;
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0) return(-1);
   if(counted_bars > 0) counted_bars--;
   limit = Bars - counted_bars;
   //-----
   ArrayResize(yMA, Bars);
   ArrayInitialize(yMA, 0.0);
   //-----
   for(int i = limit; i >= 0; i--)
    {
      yMA[i]=(iMA(NULL, 0, 30, 0, MODE_LWMA, PRICE_WEIGHTED, i) +
              iMA(NULL, 0, 50, 0, MODE_LWMA, PRICE_WEIGHTED, i) +
              iMA(NULL, 0, 100, 0, MODE_LWMA, PRICE_WEIGHTED, i)) / 3;
      //--------------------------------------------------------------
      int Boril = GetBorisKoeff();
      if(Digits == 4 || Digits == 2) aquaUp1[i] = yMA[i] + 6.18 * Point * Boril;
      if(Digits == 5 || Digits == 3) aquaUp1[i] = yMA[i] + 61.8 * Point * Boril;
      if(Digits == 4 || Digits == 2) aquaDn1[i] = yMA[i] - 6.18 * Point * Boril;
      if(Digits == 5 || Digits == 3) aquaDn1[i] = yMA[i] - 61.8 * Point * Boril;
      if(Digits == 4 || Digits == 2) aquaUp2[i] = yMA[i] + 16.18 * Point * Boril;
      if(Digits == 5 || Digits == 3) aquaUp2[i] = yMA[i] + 161.8 * Point * Boril;
      if(Digits == 4 || Digits == 2) aquaDn2[i] = yMA[i] - 16.18 * Point * Boril;
      if(Digits == 5 || Digits == 3) aquaDn2[i] = yMA[i] - 161.8 * Point * Boril;
      if(Digits == 4 || Digits == 2) aquaUp3[i] = yMA[i] + 26.18 * Point * Boril;
      if(Digits == 5 || Digits == 3) aquaUp3[i] = yMA[i] + 261.8 * Point * Boril;
      if(Digits == 4 || Digits == 2) aquaDn3[i] = yMA[i] - 26.18 * Point * Boril;
      if(Digits == 5 || Digits == 3) aquaDn3[i] = yMA[i] - 261.8 * Point * Boril;
      if(Digits == 4 || Digits == 2) aquaUp4[i] = yMA[i] + 36.18 * Point * Boril;
      if(Digits == 5 || Digits == 3) aquaUp4[i] = yMA[i] + 361.8 * Point * Boril;
      if(Digits == 4 || Digits == 2) aquaDn4[i] = yMA[i] - 36.18 * Point * Boril;
      if(Digits == 5 || Digits == 3) aquaDn4[i] = yMA[i] - 361.8 * Point * Boril;
    }
   return(0);
  }
//+------------------------------------------------------------------+