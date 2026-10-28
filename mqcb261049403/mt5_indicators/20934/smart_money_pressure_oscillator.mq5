//+------------------------------------------------------------------+
//|                              Smart_Money_Pressure_Oscillator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Smart Money Pressure Oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot SMP
#property indicator_label1  "SMP"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCadetBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriod   =  14;   // Period
//--- indicator buffers
double         BufferSMP[];
double         BufferSM[];
double         BufferVol[];
double         BufferVolMA[];
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
   SetIndexBuffer(0,BufferSMP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSM,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferVol,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferVolMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Smart Money Pressure ("+(string)period_ind+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSMP,true);
   ArraySetAsSeries(BufferSM,true);
   ArraySetAsSeries(BufferVol,true);
   ArraySetAsSeries(BufferVolMA,true);
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
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4 || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   int first=rates_total-period_ind-2;
   if(limit>1)
     {
      limit=first;
      ArrayInitialize(BufferSMP,EMPTY_VALUE);
      ArrayInitialize(BufferSM,0);
      ArrayInitialize(BufferVol,0);
      ArrayInitialize(BufferVolMA,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferVol[i]=(double)tick_volume[i];
   SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferVol,BufferVolMA);
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(i==first)
         BufferSM[i]=close[i];
      else
        {
         double VolMA=BufferVolMA[i];
         double Change=close[i]-close[i+1];
         BufferSM[i]=(BufferVol[i]>VolMA ? BufferSM[i+1]+Change : BufferSM[i+1]);
         BufferSMP[i]=(close[period_ind]-BufferSM[i])/Point();
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
