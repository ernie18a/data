//+------------------------------------------------------------------+
//|                                                  OHLC_Volume.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "OHLC Volume indicator"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot VolUP
#property indicator_label1  "Stream VolUp"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot VolDN
#property indicator_label2  "Stream VolDown"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- indicator buffers
double         BufferVolUP[];
double         BufferVolDN[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferVolUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferVolDN,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"OHLC Volume");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
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
      ArrayInitialize(BufferVolUP,EMPTY_VALUE);
      ArrayInitialize(BufferVolDN,EMPTY_VALUE);
     }
   
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double coeff_up=Point()+(high[i]-open[i]);
      double coeff_dn=Point()+(close[i]-low[i]);
      double coeff_sum=coeff_up+coeff_dn;
      BufferVolUP[i]=(coeff_sum!= 0 ? tick_volume[i]*(coeff_up)/(coeff_sum) : 0);
      BufferVolDN[i]=(coeff_sum!= 0 ? tick_volume[i]*(coeff_dn)/(coeff_sum) : 0);
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
