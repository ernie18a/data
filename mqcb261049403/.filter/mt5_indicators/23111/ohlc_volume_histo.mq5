//+------------------------------------------------------------------+
//|                                            OHLC_Volume_Histo.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "OHLC Volume Histogram indicator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot VolHist
#property indicator_label1  "VolHisto"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrLimeGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- indicator buffers
double         BufferVolHist[];
double         BufferColors[];
double         BufferVolUP[];
double         BufferVolDN[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferVolHist,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferVolUP,INDICATOR_DATA);
   SetIndexBuffer(3,BufferVolDN,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"OHLC Volume Histogram");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferVolHist,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferVolUP,true);
   ArraySetAsSeries(BufferVolDN,true);
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
//--- Проверка количества доступных баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferVolHist,EMPTY_VALUE);
      ArrayInitialize(BufferColors,2);
      ArrayInitialize(BufferVolUP,0);
      ArrayInitialize(BufferVolDN,0);
     }
   
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double coeff_up=Point()+(high[i]-open[i]);
      double coeff_dn=Point()+(close[i]-low[i]);
      double coeff_sum=coeff_up+coeff_dn;
      BufferVolUP[i]=(coeff_sum!= 0 ? tick_volume[i]*(coeff_up)/(coeff_sum) : 0);
      BufferVolDN[i]=(coeff_sum!= 0 ? tick_volume[i]*(coeff_dn)/(coeff_sum) : 0);
      //---
      BufferVolHist[i]=BufferVolUP[i]-BufferVolDN[i];
      BufferColors[i]=(BufferVolUP[i]>BufferVolDN[i] ? 0 : BufferVolUP[i]<BufferVolDN[i] ? 1 : 2);
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
