//+------------------------------------------------------------------+
//|                                                    DRAW_NONE.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Invisible
#property indicator_label1  "Bar Index"
#property indicator_type1   DRAW_NONE
#property indicator_style1  STYLE_SOLID
#property indicator_color1  clrRed
#property indicator_width1  1
//--- indicator buffer
double         InvisibleBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set InvisibleBuffer array as indicator buffer
   SetIndexBuffer(0,InvisibleBuffer,INDICATOR_DATA);
//--- set precision for indicator's values in "Data window"
   IndicatorSetInteger(INDICATOR_DIGITS,0);
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
   static datetime lastbar=0;
//--- if first iteration
   if(prev_calculated==0)
     {
      //--- calc indicator values
      CalcValues(rates_total,close);
      //--- save open time of the current bar to lastbar variable
      lastbar=(datetime)SeriesInfoInteger(_Symbol,_Period,SERIES_LASTBAR_DATE);
     }
   else
     {
      //--- if new bar has appeared and its time isn't equal to lastbar
      if(lastbar!=SeriesInfoInteger(_Symbol,_Period,SERIES_LASTBAR_DATE))
        {
         //--- recalc values
         CalcValues(rates_total,close);
         //--- update the open time of the current bar
         lastbar=(datetime)SeriesInfoInteger(_Symbol,_Period,SERIES_LASTBAR_DATE);
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Sets indexing as timeseries                                      |
//+------------------------------------------------------------------+
void CalcValues(int total,double const  &array[])
  {
//--- set indexing as time series
   ArraySetAsSeries(InvisibleBuffer,true);
//--- set indicator values as bar index
   for(int i=0;i<total;i++) InvisibleBuffer[i]=i;
  }
//+------------------------------------------------------------------+
