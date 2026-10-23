//+------------------------------------------------------------------+
//|                                                     NavelEMA.mq4 |
//+------------------------------------------------------------------+
//|   На базе (код постарался сохранить, как в оригинале):
//|                                        Custom Moving Average.mq4 
//|                      Copyright © 2004, MetaQuotes Software Corp. 
//|                                       http://www.metaquotes.net/ 
//|   Вызов:
//|   Val=iCustom(symbol,
//|               timeframe,
//|               "NavelEMA",
//|               MA_Period,
//|               MA_Shift,
//|               0,
//|               NumBar);
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Bookkeeper"
#property link      "yuzefovich@gmail.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red
extern int MA_Period=13;
extern int MA_Shift=0;
double ExtMapBuffer[];
int ExtCountedBars=0;
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0,DRAW_LINE);
   SetIndexShift(0,MA_Shift);
   if(MA_Period<2) MA_Period=13;
   SetIndexBuffer(0,ExtMapBuffer);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   if(Bars<=MA_Period) return(0);
   ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   if (ExtCountedBars>0) ExtCountedBars--;
   double pr=2.0/(MA_Period+1);
   int    pos=Bars-2;
   if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
   while(pos>=0)
     {
      if(pos==Bars-2) ExtMapBuffer[pos+1]=Navel(pos+1);
      ExtMapBuffer[pos]=Navel(pos)*pr+ExtMapBuffer[pos+1]*(1-pr);
 	   pos--;
     }
   return(0);
  }
//+------------------------------------------------------------------+
double Navel(int bar)
{
   double price=(Close[bar]*5+Open[bar]*2+High[bar]+Low[bar])/9;
   return(price);
}

