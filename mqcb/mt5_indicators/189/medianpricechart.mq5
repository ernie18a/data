//+------------------------------------------------------------------+
//|                                             MedianPriceChart.mq5 |
//|                                              Copyright 2010, Alf |
//|                                      http://forum.liteforex.org/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, Alf"
#property link      "http://forum.liteforex.org/"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Mpc
#property indicator_label1  "Mpc"
#property indicator_type1   DRAW_LINE
#property indicator_color1  White
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- indicator buffers
double         MpcBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MpcBuffer,INDICATOR_DATA);
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
//---
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);
   int limit;
   if(prev_calculated==0)
      limit=0;
   else limit=prev_calculated-1;
//--- calculate MACD
   for(int i=limit;i<rates_total;i++) MpcBuffer[i]=(high[i]+low[i])/2;
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
