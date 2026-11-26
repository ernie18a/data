//+------------------------------------------------------------------+
//|                                                         III2.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Intraday Intensity Index oscillator"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   2
//--- plot III
#property indicator_label1  "Intensity Idx"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint     InpPeriod      =  21;   // Intensity period
input uint     InpPeriodSig   =  14;   // Signal period
//--- indicator buffers
double         BufferIII[];
double         BufferColors[];
double         BufferSignal[];
double         BufferRaw[];
double         BufferVol[];
double         BufferAvgRaw[];
double         BufferAvgVol[];
//--- global variables
int            period_iii;
int            period_sig;
int            period_max;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_iii=int(InpPeriod<1 ? 1 : InpPeriod);
   period_sig=int(InpPeriodSig<2 ? 2 : InpPeriodSig);
   period_max=fmax(period_iii,period_sig);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferIII,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(3,BufferRaw,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferVol,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferAvgRaw,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferAvgVol,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Intraday Intensity ("+(string)period_iii+","+(string)period_sig+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferIII,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferRaw,true);
   ArraySetAsSeries(BufferVol,true);
   ArraySetAsSeries(BufferAvgRaw,true);
   ArraySetAsSeries(BufferAvgVol,true);
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
   if(rates_total<period_max || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferIII,EMPTY_VALUE);
      ArrayInitialize(BufferSignal,EMPTY_VALUE);
      ArrayInitialize(BufferRaw,0);
      ArrayInitialize(BufferVol,0);
      ArrayInitialize(BufferAvgRaw,0);
      ArrayInitialize(BufferAvgVol,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferRaw[i]=(high[i]!=low[i] ? tick_volume[i]*(2.0*close[i]-high[i]-low[i])/(high[i]-low[i]) : 0);
      BufferVol[i]=(double)tick_volume[i];
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double Avg=GetSMA(rates_total,i,period_iii,BufferRaw);
      double AvgVol=GetSMA(rates_total,i,period_iii,BufferVol);
      BufferIII[i]=(AvgVol!=0 ? 100.0*Avg/(AvgVol*Point()) : 0);
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferSignal[i]=GetSMA(rates_total,i,period_sig,BufferIII);
      BufferColors[i]=(BufferSignal[i]<BufferIII[i] ? 0 : BufferSignal[i]>BufferIII[i] ? 1 : 2);
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
     result=result+(as_series ? price[index+i] : price[index-i]);
//---
   return(result/period);
  }
//+------------------------------------------------------------------+
