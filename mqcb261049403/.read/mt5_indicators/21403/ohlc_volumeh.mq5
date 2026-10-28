//+------------------------------------------------------------------+
//|                                                 OHLC_VolumeH.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "OHLC Volume Histogram indicator"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot OHLCV
#property indicator_label1  "OHLCV"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- indicator buffers
double         BufferOHLCV[];
double         BufferColors[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferOHLCV,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"OHLC VolumeH");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferOHLCV,true);
   ArraySetAsSeries(BufferColors,true);
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferOHLCV,EMPTY_VALUE);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double up_coeff=high[i]-open[i];
      double dn_coeff=close[i]-low[i];
      double sum_coeff=up_coeff+dn_coeff;
      
      if(sum_coeff!=0)
        {
         double up_v=tick_volume[i]*up_coeff/(sum_coeff);
         double dn_v=tick_volume[i]*dn_coeff/(sum_coeff);

         BufferOHLCV[i]=up_v-dn_v;
         BufferColors[i]=(up_v>dn_v ? 0 : up_v<dn_v ? 1 : 2);
        }
      else
        {
         BufferOHLCV[i]=0;
         BufferColors[i]=2;
        }
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
