//+------------------------------------------------------------------+
//|                                                       WPRfix.mq5 |
//|                                        Copyright 2012, kazakov.v |
//|                                              kazakov.v@fxmail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, kazakov.v"
#property link      "kazakov.v@fxmail.ru"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Main
#property indicator_label1  "Main"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumTurquoise
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input int      Range=800;
//--- indicator buffers
double         MainBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MainBuffer,INDICATOR_DATA);
   IndicatorSetString(INDICATOR_SHORTNAME,"%Rfix("+IntegerToString(Range)+") ");   
//---
   return(0);
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
      double min,max,X=Range*_Point;
      int i,j;
      ArraySetAsSeries(low,false); ArraySetAsSeries(high,false); ArraySetAsSeries(close,false);
      for(i=prev_calculated;i<rates_total;i++)
      {
         min=low[i]; max=high[i]+_Point;  j=i;
         while(j-->0)
         {
            if((max-min)>X) break;
            if(low[j]<min)    min=low[j];
            if(high[j]>max)   max=high[j];
         }
         MainBuffer[i]=(close[i]-min)/(max-min)*100-50;
      }   
//--- return value of prev_calculated for next call
   return(rates_total-1);
  }
//+------------------------------------------------------------------+
