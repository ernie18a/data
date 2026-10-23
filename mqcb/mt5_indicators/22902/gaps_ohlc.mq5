//+------------------------------------------------------------------+
//|                                                    Gaps OHLC.mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.002"
#property description "Gaps OHLC"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//--- input parameters
input ENUM_TIMEFRAMES   InpTimeFrame=PERIOD_CURRENT; // TimeFrame on which we are looking for gep
//--- plot Color_Histogram 
#property indicator_label1  "Gaps OHLC" 
#property indicator_type1   DRAW_COLOR_HISTOGRAM 
//--- define 8 colors for coloring sections (they are stored in a special array) 
#property indicator_color1  clrRed,clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- a buffer of values
double         Color_HistogramBuffer[];
//--- a buffer of color indexes
double         Color_HistogramColors[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping 
   SetIndexBuffer(0,Color_HistogramBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,Color_HistogramColors,INDICATOR_COLOR_INDEX);
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
   if(rates_total<=1)
      return(0);
   int limit=prev_calculated-1;
   if(prev_calculated==0)
      limit=0;
   for(int i=0;i<rates_total;i++)
     {
      if(i==0)
        {
         Color_HistogramBuffer[i]=0.0;
         Color_HistogramColors[i]=0;
         continue;
        }
      if(open[i]<low[i-1])
        {
         Color_HistogramBuffer[i]=(open[i]-low[i-1])/Point();
         Color_HistogramColors[i]=0;
        }
      else if(open[i]>high[i-1])
        {
         Color_HistogramBuffer[i]=(open[i]-high[i-1])/Point();
         Color_HistogramColors[i]=1;
        }
      else
        {
         Color_HistogramBuffer[i]=0.0;
         Color_HistogramColors[i]=0;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
