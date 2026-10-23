//+------------------------------------------------------------------+
//|                                                          EMV.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Arm's Ease of Movement Value"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot EMV
#property indicator_label1  "EMV"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint           InpPeriod   =  10;         // Period
input ENUM_MA_METHOD InpMethod   =  MODE_SMA;   // Method
//--- indicator buffers
double         BufferEMV[];
double         BufferSignal[];
//--- global variables
int            period_ind;
int            weight_sum;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ind=int(InpPeriod<2 ? 2 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferEMV,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSignal,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"AEMV("+(string)period_ind+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferEMV,true);
   ArraySetAsSeries(BufferSignal,true);
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
   //int max=fmax(period_fma,fmax(period_sma,period_sig));
   if(rates_total<4 || Point()==0) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_ind-2;
      ArrayInitialize(BufferEMV,0);
      ArrayInitialize(BufferSignal,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double V=(double)tick_volume[i];
      double HL0=(high[i]+low[i])/(2.0*Point());
      double HL1=(high[i+1]+low[i+1])/(2.0*Point());
      BufferEMV[i]=(V!=0 ? ((HL0-HL1)*(high[i]-low[i])/V)/Point() : 0);
     }
//--- Расчёт индикатора
   switch(InpMethod)
     {
      case MODE_EMA  :  ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferEMV,BufferSignal);               break;
      case MODE_SMMA :  SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferEMV,BufferSignal);                  break;
      case MODE_LWMA :  LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferEMV,BufferSignal,weight_sum); break;
      default        :  SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferEMV,BufferSignal);                    break;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
