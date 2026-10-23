//+------------------------------------------------------------------+
//|                                                          111.mq4 |
//|                      Copyright © 2008, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Yellow
#property indicator_level1 0

extern int MAPeriod=14;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+1;
//----
   for(int i=limit;i>=0; i--)
     {
      ExtMapBuffer1[i] = iCustom(NULL,0,"MUV",MAPeriod,0,1,i)-iCustom(NULL,0,"MUV",MAPeriod,0,1,i+1);
      ExtMapBuffer2[i] = iCustom(NULL,0,"MUV",MAPeriod,1,1,i)-iCustom(NULL,0,"MUV",MAPeriod,1,1,i+1);
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
