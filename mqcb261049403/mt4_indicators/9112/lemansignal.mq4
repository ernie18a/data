//+------------------------------------------------------------------+
//|                                                  LeManSignal.mq4 |
//|                                         Copyright © 2009, LeMan. |
//|                                                 b-market@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, LeMan."
#property link      "b-market@mail.ru"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_width1 2
#property indicator_width2 2
//----
extern int N=12;
//----
double OpenUp[];
double OpenDown[];
//+------------------------------------------------------------------+
int init() 
  {
//----
   string short_name;
//----
   IndicatorDigits(Digits);
   IndicatorBuffers(2);
//----
   short_name="LeManSignal ("+N+")";
   IndicatorShortName(short_name);
//----      
   SetIndexBuffer(0,OpenUp);
   SetIndexBuffer(1,OpenDown);

   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);

   SetIndexStyle(0,DRAW_ARROW,EMPTY,2);
   SetIndexArrow(0,159);
   SetIndexLabel(0,"Open Buy");
   SetIndexStyle(1,DRAW_ARROW,EMPTY,2);
   SetIndexArrow(1,159);
   SetIndexLabel(1,"Open Sell");

//----
   return(0);
  }
//+------------------------------------------------------------------+
int start() 
  {
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=2;

   double LevelStop=MarketInfo(Symbol(),14);

   for(int i=limit; i>=0; i--) 
     {
      double H1 = iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, N, i+1));
      double H2 = iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, N, i+1+N));
      double H3 = iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, N, i+2));
      double H4 = iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, N, i+2+N));
      double L1 = iLow(NULL, 0, iLowest(NULL, 0, MODE_LOW, N, i+1));
      double L2 = iLow(NULL, 0, iLowest(NULL, 0, MODE_LOW, N, i+1+N));
      double L3 = iLow(NULL, 0, iLowest(NULL, 0, MODE_LOW, N, i+2));
      double L4 = iLow(NULL, 0, iLowest(NULL, 0, MODE_LOW, N, i+2+N));
      
      OpenUp[i]=0;
      OpenDown[i]=0;      

      // Условие покупки                       
      if(H3<=H4 && H1>H2) 
        {
         OpenUp[i]=High[i+1]+Point;
        }
      // Условие продажи      
      if(L3>=L4 && L1<L2) 
        {
         OpenDown[i]=Low[i+1]-Point;
        }
     }

//----
   return(0);
  }
//+------------------------------------------------------------------+
