//+------------------------------------------------------------------+
//|                                                  Gideons_ATR.mq4 |
//|                       Copyright © 2007, GideonSmolders@gmail.com |
//|                                           MetaTrader Group Yahoo |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, GideonSmolders"
#property link      ""
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  Silver
#property  indicator_color2  Red
//---- indicator parameters
extern int       atr_fast=5;
extern int       atr_slow=48;


//---- indicator buffers
double     ind_buffer1[];
double     ind_buffer2[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexDrawBegin(0,atr_slow);
   SetIndexDrawBegin(1,atr_slow);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
//---- indicator buffers mapping
   if(!SetIndexBuffer(0,ind_buffer1) && !SetIndexBuffer(1,ind_buffer2))
      Print("cannot set indicator buffers!");
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("Gideons ATR("+atr_fast+","+atr_slow+")");
   SetIndexLabel(0,"ATR_Signal");
   SetIndexLabel(1,"MA");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- atr signal counted in the 1-st buffer
   for(int i=0; i<limit; i++)
      ind_buffer1[i]= iATR(NULL,0,atr_fast,i)/iATR(NULL,0,atr_slow,i);  
      
//---- ma line counted in the 2-nd buffer
   for(i=0; i<limit; i++)
      ind_buffer2[i]=iMAOnArray(ind_buffer1,0,7,0,MODE_SMMA,i);
//---- done
   return(0);
  }