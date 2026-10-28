//+------------------------------------------------------------------+
//|                                              Open_Oscillator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Open oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   4
//--- plot LO
#property indicator_label1  "Low"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrOrangeRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot HI
#property indicator_label2  "High"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrMediumSeaGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot SignalL
#property indicator_label3  "Signal Low"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- plot SignalH
#property indicator_label4  "Signal High"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGreen
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2
//--- input parameters
input uint     InpPeriod      =  20;   // Period
input uint     InpPeriodSig   =  10;   // Signal period
//--- indicator buffers
double         BufferLO[];
double         BufferHI[];
double         BufferSigLO[];
double         BufferSigHI[];
//--- global variables
int            period_hl;
int            period_sig;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_hl=int(InpPeriod<1 ? 1 : InpPeriod);
   period_sig=int(InpPeriodSig<1 ? 1 : InpPeriodSig);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferLO,INDICATOR_DATA);
   SetIndexBuffer(1,BufferHI,INDICATOR_DATA);
   SetIndexBuffer(2,BufferSigLO,INDICATOR_DATA);
   SetIndexBuffer(3,BufferSigHI,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Open oscillator ("+(string)period_hl+","+(string)period_sig+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferLO,true);
   ArraySetAsSeries(BufferHI,true);
   ArraySetAsSeries(BufferSigLO,true);
   ArraySetAsSeries(BufferSigHI,true);
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_hl,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_hl-1;
      ArrayInitialize(BufferLO,EMPTY_VALUE);
      ArrayInitialize(BufferHI,EMPTY_VALUE);
      ArrayInitialize(BufferSigLO,0);
      ArrayInitialize(BufferSigHI,0);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bl=Lowest(period_hl,i);
      int bh=Highest(period_hl,i);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         continue;
      BufferLO[i]=open[bl]-open[i];
      BufferHI[i]=open[i]-open[bh];
     }
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_hl,period_sig,BufferLO,BufferSigLO)==0) return 0;
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_hl,period_sig,BufferHI,BufferSigHI)==0) return 0;

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии High          |
//+------------------------------------------------------------------+
int Highest(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyHigh(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMaximum(array)+start : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс минимального значения таймсерии Low            |
//+------------------------------------------------------------------+
int Lowest(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyLow(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMinimum(array)+start : WRONG_VALUE);
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
