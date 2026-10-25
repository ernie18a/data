//+------------------------------------------------------------------+
//|                                               SMA(no loop)_0.mq5 |
//|                                        Copyright 2021, PuguForex |
//|                          https://www.mql5.com/en/users/puguforex |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, PuguForex"
#property link      "https://www.mql5.com/en/users/puguforex"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers   2
#property indicator_plots     1

#property indicator_label1 "SMA"
#property indicator_type1  DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_color1 clrDodgerBlue
#property indicator_width1 2

input int   inpPeriod   =  14;   // SMA period

double   sma[],sumSma[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,sma    ,INDICATOR_DATA);
   SetIndexBuffer(1,sumSma ,INDICATOR_CALCULATIONS);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"SMA(no loop)("+(string)inpPeriod+")");
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
   int   limit =  prev_calculated   ?  prev_calculated-1 :  0;  
//---
   for(int i=limit;   i<rates_total  && !_StopFlag; i++)
     {
      sumSma[i]   =  (i>inpPeriod)        ?  sumSma[i-1] +  close[i] -  close[i-inpPeriod]      :
                     (i>0&&i<=inpPeriod)  ?  sumSma[i-1] +  close[i] -  (i==inpPeriod)*close[0] :
                     close[i];
      sma[i]      =  sumSma[i]/inpPeriod;                                 
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
