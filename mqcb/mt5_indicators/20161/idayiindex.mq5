//+------------------------------------------------------------------+
//|                                                   IDayIIndex.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Intraday Intensity Index"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot IDI
#property indicator_label1  "IDIndex"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input ENUM_INPUT_YES_NO InpNormal   =  INPUT_YES;  // Normalized
input uint              InpPeriod   =  21;         // Period
//--- indicator buffers
double         BufferIDI[];
double         BufferRaw[];
//--- global variables
int            period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferIDI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferRaw,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"IDayII("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferIDI,true);
   ArraySetAsSeries(BufferRaw,true);
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
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<period) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   int limit1=limit;
   if(limit>1)
     {
      limit=rates_total-1;
      limit1=limit-period;
      ArrayInitialize(BufferIDI,EMPTY_VALUE);
      ArrayInitialize(BufferRaw,EMPTY_VALUE);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double value=high[i]-low[i];
      BufferRaw[i]=(value!=0 ? ((2*close[i]-high[i]-low[i])/value)*tick_volume[i] : 0);
     }
//--- Расчёт индикатора
   for(int i=limit1; i>=0 && !IsStopped(); i--)
     {
      double summ_idi=ArraySum(BufferRaw,i);
      if(InpNormal)
         BufferIDI[i]=summ_idi;
      else
        {
         double summ_vol=(double)ArraySum(tick_volume,i);
         BufferIDI[i]=(summ_idi/summ_vol)*100;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T> 
T ArraySum(const T &array[],const int index)
  {
   T summation=0;
   for(int i=period; i>=0; i--)
      summation+=array[i+index];
   return summation;
  }
//+------------------------------------------------------------------+
