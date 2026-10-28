//+------------------------------------------------------------------+
//|                                 Size of a candle (histogram).mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.001"
#property description "Size of a candle (histogram)"
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrBlue,clrRed
#property indicator_width1  3
//--- indicator buffer
double               ExtBuffer[];
double               ExtColorBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- name for DataWindow
   string short_name="Size of a candle";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---
   ArraySetAsSeries(ExtBuffer,false);
   ArraySetAsSeries(ExtColorBuffer,false);
//+------------------------------------------------------------------+
//| ArraySetAsSeries(time,false) =>                                  |
//|  time[0]            = D'2016.01.04 00:00:00'                     |
//|  time[rates_total-1]= D'2017.01.04 00:00:00'                     |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//| ArraySetAsSeries(time,false) =>                                  |
//|  time[0]            = D'2016.01.04 00:00:00'                     |
//|  time[rates_total-1]= D'2017.01.04 00:00:00'                     |
//+------------------------------------------------------------------+
   ArraySetAsSeries(time,false);
   ArraySetAsSeries(open,false);
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);
   ArraySetAsSeries(close,false);
//---
   int limit=-1;
   if(prev_calculated==0)
      limit=0;
   else
      limit=prev_calculated-1;

   for(int i=limit;i<rates_total;i++)
     {
      double calculations=high[i]-low[i];
      bool   close_or_open=(close[i]-open[i]>0)?true:false;
      ExtBuffer[i]=(close_or_open)?calculations:-calculations;
      ExtColorBuffer[i]=(close[i]-open[i]>0)?0:1;
      int g=0;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
