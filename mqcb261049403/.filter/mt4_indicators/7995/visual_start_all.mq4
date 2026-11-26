//+------------------------------------------------------------------+
//|                                                      1-start.mq4 |
//|                                             Copyright © 2008, AP |
//|                                                   ekr-ap@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, AP"
#property link      "ekr-ap@mail.ru"

#property indicator_separate_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

#property indicator_minimum -1
#property indicator_maximum 1
#property indicator_level1 0

#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Lime

extern int P=1;

double B[1000],A[1000];
int init()
  {
//---- indicators
//----
SetIndexBuffer(0,B);
SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,2);

SetIndexBuffer(1,A);
SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,2);

 IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
 WindowRedraw();
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
   int   i, counted_bars=IndicatorCounted();
//----
 /*
  for(i=0;i<Bars-counted_bars-1;i++) B[i]=50;
IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
 WindowRedraw();
   */
//----
   return(0);
  }
//+------------------------------------------------------------------+