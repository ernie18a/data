//+------------------------------------------------------------------+
//|                                              Range_Histogram.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Range Histogram indicator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot Range
#property indicator_label1  "Range"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- enums
enum ENUM_TYPE_CALC
  {
   TYPE_OC,          // Open/Close
   TYPE_HL           // High/Low
  };
//---
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input ENUM_TYPE_CALC    InpType        =  TYPE_OC;    // Calculation type
input ENUM_INPUT_YES_NO InpSmoothing   =  INPUT_NO;   // Smoothing
input uint              InpPeriod      =  14;         // Period
input ENUM_MA_METHOD    InpMethod      =  MODE_SMA;   // Method
//--- indicator buffers
double         BufferRange[];
double         BufferColors[];
double         BufferRAW[];
double         BufferAVG[];
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
   uint min=(InpSmoothing ? 2 : 1);
   period_ind=int(InpPeriod<min ? min : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferRange,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferRAW,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferAVG,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   string descr=(InpType==TYPE_HL ? "Range High/Low" : "Range Open/Close");
   IndicatorSetString(INDICATOR_SHORTNAME,descr+" Histogram ("+(string)period_ind+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
//--- setting plot buffer psrsmeters
   PlotIndexSetString(0,PLOT_LABEL,descr);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferRange,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferRAW,true);
   ArraySetAsSeries(BufferAVG,true);
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<period_ind) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferRange,EMPTY_VALUE);
      ArrayInitialize(BufferRAW,0);
      ArrayInitialize(BufferAVG,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferRAW[i]=(InpType==TYPE_HL ? high[i]-low[i] : fabs(open[i]-close[i]));
   if(InpSmoothing)
     {
      switch(InpMethod)
        {
         case MODE_EMA  :  ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferRAW,BufferAVG);               break;
         case MODE_SMMA :  SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferRAW,BufferAVG);                  break;
         case MODE_LWMA :  LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferRAW,BufferAVG,weight_sum); break;
         //---MODE_SMA
         default        :  SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferRAW,BufferAVG);                    break;
        }
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferRange[i]=(InpSmoothing ? BufferAVG[i] : BufferRAW[i]);
      BufferColors[i]=(BufferRange[i]<BufferRange[i+1] ? 1 : 0);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
