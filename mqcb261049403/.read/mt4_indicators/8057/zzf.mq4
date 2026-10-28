//+------------------------------------------------------------------+
//|                                                   FX-CHANNEL.mq4 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Chris Battles"
#property link      "mailto:cbattles@neo.rr.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Gold

//---- buffers
double v1[];

//----
double val1;

int k;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
int init()
  {
//---- drawing settings  
   SetIndexStyle(0,DRAW_SECTION,STYLE_SOLID,1);
   SetIndexBuffer(0,v1);
   SetIndexLabel(0,"UPPER");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int k=Bars-counted_bars;
   if(counted_bars==0) k-=1+1;

   while(k>=0)
     {
      val1=iCustom(NULL,0,"ZIGZAG-FRACTALS",0,k);
      if(val1>0)
         v1[k]=val1;
      else
         v1[k]=v1[k+1];

      k--;
     }
   return(0);
  }

//+------------------------------------------------------------------+
