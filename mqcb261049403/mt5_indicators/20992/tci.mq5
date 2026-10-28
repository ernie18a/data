//+------------------------------------------------------------------+
//|                                                          TCI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Trend Confirmation Index indicator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
//--- plot TCI
#property indicator_label1  "TCI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrForestGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot ACT
#property indicator_label2  "Actual CP"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrSilver
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input int               InpPeriod      =  14;         // Period
input ENUM_MA_METHOD    InpMethod      =  MODE_SMA;   // Method
input double            InpOverbought  =  70.0;       // Overbought level
input double            InpOversold    =  30.0;       // Oversold level
input ENUM_INPUT_YES_NO InpShowActual  =  INPUT_NO;   // Show actual CPP
//--- indicator buffers
double         BufferTCI[];
double         BufferCPP[];
double         BufferAVG[];
//--- global variables
double         overbought;
double         oversold;
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
   oversold=(InpOversold<0 ? 0 : InpOversold>99.9 ? 99.9 : InpOversold);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   if(overbought<=oversold) overbought=oversold+0.1;
   if(oversold>=overbought) oversold=overbought-0.1;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTCI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferCPP,INDICATOR_DATA);
   SetIndexBuffer(2,BufferAVG,INDICATOR_CALCULATIONS);
//--- setting plot buffers parameters
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,(InpShowActual ? DRAW_LINE : DRAW_NONE));
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Trend Confirmation Index ("+(string)period_ind+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,50.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,oversold);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTCI,true);
   ArraySetAsSeries(BufferCPP,true);
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
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<2) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferTCI,EMPTY_VALUE);
      ArrayInitialize(BufferCPP,EMPTY_VALUE);
      ArrayInitialize(BufferAVG,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferCPP[i]=(high[i]-low[i]!=0 ? 100.0*(close[i]-low[i])/(high[i]-low[i]) : 0);

//--- Расчёт индикатора
   switch(InpMethod)
     {
      case MODE_EMA  :  ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferCPP,BufferTCI);               break;
      case MODE_SMMA :  SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferCPP,BufferTCI);                  break;
      case MODE_LWMA :  LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferCPP,BufferTCI,weight_sum); break;
      //---MODE_SMA
      default        :  SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferCPP,BufferTCI);                    break;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
