//+--------------------------------------------------------------------+
//| Copyright:  (C) 2015, Andy Ismail    - All rights reserved!        |
//| Website:    http://fbsbroker.com/                                  |
//|                                                                    |
//+--------------------------------------------------------------------+
#property copyright "Copyright 2015, Andy Ismail"
#property link      "http://fbsbroker.com"
#property version   "1.00"
#property description   "Alpha Trend Spotter Price Action"
#property description   "Suplement for Alpha Trend Spotter Indicator"
#property description   "Suitable for 5M to above timeframe"
#property description   "Suitable for 5 minutes Binary Option"
#property strict
//---
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Pink
#property indicator_width1 2
#property indicator_color2 Lime
#property indicator_width2 2
//---
double BufferMap1[];
double BufferMap2[];
double CandleHighF;
double CandleHighL;
double CandleOpenL;
double CandleHigh;
double CandleLowS;
double CandleOpenS;
double TimeFrameC;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0,DRAW_ARROW,2);
   SetIndexArrow(0,234);
   SetIndexBuffer(0,BufferMap1);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1,DRAW_ARROW,2);
   SetIndexArrow(1,233);
   SetIndexBuffer(1,BufferMap2);
   SetIndexEmptyValue(1,0.0);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int BarCount=IndicatorCounted();
   for(int i=100; i>0; i--)
     {
      CandleHigh=High[Highest(NULL, 0,2,3,i)];
      CandleLowS=Low[Lowest(NULL,0,1,3,i)];
      CandleOpenS=Open[i];
      CandleHighF=High[Highest(NULL, 0, 2, 3, (i+3))];
      CandleHighL=Low[Lowest(NULL,0,1,3,(i+3))];
      CandleOpenL=Open[i+3];
      //---
      if((CandleHigh>CandleHighF) && (CandleOpenS<CandleHighL))
        {
         BufferMap1[i]=High[i+3]+0.0010;
        }
      //---
      if((CandleLowS<CandleHighL) && (CandleOpenS>CandleHighF))
        {
         BufferMap2[i]=Low[i+3]-0.0010;
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
