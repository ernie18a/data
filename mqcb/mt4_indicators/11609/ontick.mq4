//+------------------------------------------------------------------+
//|                                                       OnTick.mq4 |
//|                                          Copyright 2018, pipPod. |
//|                             https://www.mql5.com/en/users/pippod |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, pipPod."
#property link      "https://www.mql5.com/en/users/pippod"
#property version   "1.00"
#property strict
#property indicator_chart_window
//--- input parameters
input long ChartID=0;
input ushort Index=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
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
   if(prev_calculated)
      ::EventChartCustom(ChartID,Index,Index,rates_total-prev_calculated,_Symbol);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
