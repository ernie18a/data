//+------------------------------------------------------------------+
//|                                             Days of the week.mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#property indicator_separate_window
#property description "Days of the week in the form of a histogram"

#property indicator_separate_window 
#property indicator_buffers 1 
#property indicator_plots   1 
//--- plot Histogram 
#property indicator_label1  "Day" 
#property indicator_type1   DRAW_HISTOGRAM 
#property indicator_color1  clrGray 
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  2
//--- indicator buffers 
double         HistogramBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,HistogramBuffer,INDICATOR_DATA);
//--- indicator digits
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- indicator short name
   IndicatorSetString(INDICATOR_SHORTNAME,"Day");
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
      MqlDateTime STime;
      TimeToStruct(time[i],STime);
      switch(STime.day_of_week)
        {
         case  0:
            HistogramBuffer[i]=0;
            break;
         case  1:
            HistogramBuffer[i]=1;
            break;
         case  2:
            HistogramBuffer[i]=2;
            break;
         case  3:
            HistogramBuffer[i]=3;
            break;
         case  4:
            HistogramBuffer[i]=4;
            break;
         case  5:
            HistogramBuffer[i]=5;
            break;
         case  6:
            HistogramBuffer[i]=6;
            break;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
