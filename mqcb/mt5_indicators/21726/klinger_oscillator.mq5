//+------------------------------------------------------------------+
//|                                           Klinger_Oscillator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Klinger Oscillator"
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   2
//--- plot Klinger
#property indicator_label1  "Klinger"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint     InpPeriodFast  =  34;   // Fast period
input uint     InpPeriodSlow  =  55;   // Slow period
input uint     InpPeriodSig   =  13;   // Signal period
//--- indicator buffers
double         BufferKlinger[];
double         BufferSignal[];
double         BufferDM[];
double         BufferCM[];
double         BufferTR[];
double         BufferVF[];
double         BufferAvgFVF[];
double         BufferAvgSVF[];
double         BufferMA[];
//--- global variables
int            period_fast;
int            period_slow;
int            period_max;
int            period_sig;
int            handle_ma;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fast=int(InpPeriodFast<2 ? 2 : InpPeriodFast);
   period_slow=int(InpPeriodSlow<2 ? 2 : InpPeriodSlow);
   period_sig=int(InpPeriodSig<2 ? 2 : InpPeriodSig);
   period_max=fmax(period_fast,fmax(period_slow,period_sig));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferKlinger,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(2,BufferDM,INDICATOR_DATA);
   SetIndexBuffer(3,BufferCM,INDICATOR_DATA);
   SetIndexBuffer(4,BufferTR,INDICATOR_DATA);
   SetIndexBuffer(5,BufferVF,INDICATOR_DATA);
   SetIndexBuffer(6,BufferAvgFVF,INDICATOR_DATA);
   SetIndexBuffer(7,BufferAvgSVF,INDICATOR_DATA);
   SetIndexBuffer(8,BufferMA,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Klinger Oscillator ("+(string)period_fast+","+(string)period_slow+","+(string)period_sig+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetString(0,PLOT_LABEL,"Klinger("+(string)period_fast+","+(string)period_slow+")");
   PlotIndexSetString(1,PLOT_LABEL,"Signal("+(string)period_sig+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferKlinger,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferDM,true);
   ArraySetAsSeries(BufferCM,true);
   ArraySetAsSeries(BufferTR,true);
   ArraySetAsSeries(BufferVF,true);
   ArraySetAsSeries(BufferAvgFVF,true);
   ArraySetAsSeries(BufferAvgSVF,true);
   ArraySetAsSeries(BufferMA,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,PRICE_TYPICAL);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) by PRICE_TYPICAL object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
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
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferKlinger,0);
      ArrayInitialize(BufferSignal,0);
      ArrayInitialize(BufferDM,0);
      ArrayInitialize(BufferCM,0);
      ArrayInitialize(BufferTR,0);
      ArrayInitialize(BufferVF,0);
      ArrayInitialize(BufferAvgFVF,0);
      ArrayInitialize(BufferAvgSVF,0);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferTR[i]=0;
      BufferCM[i]=0;
      BufferDM[i]=high[i]-low[i];
      BufferTR[i]=(BufferMA[i]>BufferMA[i+1] ? 1 : BufferMA[i]<BufferMA[i+1] ? -1 : BufferTR[i+1]);
      
      BufferCM[i]=(BufferTR[i]==BufferTR[i+1] ? BufferCM[i]+BufferDM[i] : BufferDM[i+1]+BufferDM[i]);
      BufferVF[i]=(BufferCM[i]==0 ? 0 : tick_volume[i]*fabs(2.0*BufferDM[i]/BufferCM[i]+1) *BufferTR[i]*100.0);
     }
   
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_fast,BufferVF,BufferAvgFVF)==0)
      return 0;
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_slow,BufferVF,BufferAvgSVF)==0)
      return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferKlinger[i]=BufferAvgFVF[i]-BufferAvgSVF[i];

   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sig,BufferKlinger,BufferSignal)==0)
      return 0;

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
