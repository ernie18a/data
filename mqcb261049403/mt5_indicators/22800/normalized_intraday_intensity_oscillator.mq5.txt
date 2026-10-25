//+------------------------------------------------------------------+
//|                     Normalized_Intraday_Intensity_Oscillator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Normalized Intraday Intensity Oscillator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot NIIO
#property indicator_label1  "Intensity"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDeepSkyBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriod=10;   // Period
//--- indicator buffers
double         BufferNII[];
double         BufferTemp[];
double         BufferRaw[];
//--- global variables
int            period_sm;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_sm=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferNII,INDICATOR_DATA);
   SetIndexBuffer(1,BufferRaw,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferTemp,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Normalized Intraday Intensity ("+(string)period_sm+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferNII,true);
   ArraySetAsSeries(BufferTemp,true);
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_sm,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferNII,EMPTY_VALUE);
      ArrayInitialize(BufferTemp,0);
      ArrayInitialize(BufferRaw,0);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferTemp[i]=(high[i]-low[i]!=0 ? (2.0*close[i]-high[i]-low[i])/(high[i]-low[i])*tick_volume[i] : 0);
      BufferRaw[i]=(double)tick_volume[i];
      double raw_avg=GetSMA(rates_total,i,period_sm,BufferRaw);
      BufferNII[i]=(raw_avg!=0 ? GetSMA(rates_total,i,period_sm,BufferTemp)/raw_avg*100.0 : 0);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
double GetSMA(const int rates_total,const int index,const int period,const double &price[],const bool as_series=true)
  {
//---
   double result=0.0;
//--- check position
   bool check_index=(as_series ? index<=rates_total-period-1 : index>=period-1);
   if(period<1 || !check_index)
      return 0;
//--- calculate value
   for(int i=0; i<period; i++)
      result=result+(as_series ? price[index+i]: price[index-i]);
//---
   return(result/period);
  }
//+------------------------------------------------------------------+
