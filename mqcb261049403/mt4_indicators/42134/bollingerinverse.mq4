//+------------------------------------------------------------------+
//|                                            bollinger-inverse.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net"

#property strict
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 MediumSeaGreen
#property indicator_color2 Orange
#property indicator_color3 IndianRed



extern int periodbb =10; // period of wpr#1
extern double deviation =1.25; // period of ma of wpr#1
extern int shift = 1; // method of MAWPR buffers
//----
double BBH[];
double BB[];
double BBL[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator line
   SetIndexStyle(0,DRAW_LINE, 0, 3, MediumSeaGreen);
   SetIndexBuffer(0, BBH);

   SetIndexStyle(1,DRAW_LINE, 0, 3, Orange);
   SetIndexBuffer(1, BB);

   SetIndexStyle(2,DRAW_LINE, 0, 3, IndianRed);
   SetIndexBuffer(2, BBL);


//---- name for DataWindow and indicator subwindow label




   return(0);
  }
//----

//+------------------------------------------------------------------+
//| MTF Parabolic Sar                                                |
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray[];

   int    i,limit,counted_bars=IndicatorCounted();

// Plot defined time frame on to current time frame

//----
   limit=Bars-counted_bars;
   for(i=0; i<limit; i++)
     {
      BBH[i]=iBands(Symbol(),PERIOD_CURRENT,periodbb, deviation,shift,0,MODE_LOWER,i);//upper
      BB[i]=iBands(Symbol(),PERIOD_CURRENT,periodbb,deviation,shift,0,MODE_MAIN,i);//middle
      BBL[i]=iBands(Symbol(),PERIOD_CURRENT,periodbb, deviation,shift,0,MODE_UPPER,i);//lower
     }


//----
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
