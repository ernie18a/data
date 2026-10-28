//+------------------------------------------------------------------+
//|                                                    DayImpuls.mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.001"
#include <MovingAverages.mqh>
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot Impuls
#property indicator_label1  "Impuls"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLawnGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input int      Inp_ma_period=14;    // averaging period 
//--- indicator buffers
double         ImpulsBuffer[];
double         ImpulsBufferTemp[];
double         ImpulsBufferTempDbl[];
//---
double m_point;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ImpulsBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ImpulsBufferTemp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,ImpulsBufferTempDbl,INDICATOR_CALCULATIONS);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,0);
   IndicatorSetString(INDICATOR_SHORTNAME,"Impuls("+string(Inp_ma_period)+")");
   m_point=Point();
   if(m_point==0.0)
     {
      Print("ERROR: Point = 0");
      return(INIT_FAILED);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   int limit=prev_calculated-1;
   if(prev_calculated==0)
      limit=0;
   for(int i=limit;i<rates_total;i++)
     {
      ImpulsBufferTemp[i]=(close[i]-open[i])/m_point;
     }
//---
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,Inp_ma_period,ImpulsBufferTemp,ImpulsBufferTempDbl);
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,Inp_ma_period,ImpulsBufferTempDbl,ImpulsBuffer);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
