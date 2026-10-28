//+------------------------------------------------------------------+
//|                                     Intraday_Intensity_Index.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Intraday Intensity Index indicator"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot IIDX
#property indicator_label1  "Intensity Idx"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrFireBrick
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpPeriod   =  21;         // Period  
input ENUM_INPUT_YES_NO InpUseNorm  =  INPUT_YES;  // Use normalization
//--- indicator buffers
double         BufferIIDX[];
double         BufferRAW[];
double         BufferAVG1[];
double         BufferAVG2[];
double         BufferVol[];
//--- global variables
int            period_ind;
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
   SetIndexBuffer(0,BufferIIDX,INDICATOR_DATA);
   SetIndexBuffer(1,BufferRAW,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferAVG1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferAVG2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferVol,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Intraday Intensity Index ("+(string)period_ind+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferIIDX,true);
   ArraySetAsSeries(BufferRAW,true);
   ArraySetAsSeries(BufferAVG1,true);
   ArraySetAsSeries(BufferAVG2,true);
   ArraySetAsSeries(BufferVol,true);
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
   if(rates_total<4 || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferIIDX,EMPTY_VALUE);
      ArrayInitialize(BufferRAW,0);
      ArrayInitialize(BufferAVG1,0);
      ArrayInitialize(BufferAVG2,0);
      ArrayInitialize(BufferVol,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double v=high[i]-low[i];
      BufferRAW[i]=((2.0*close[i]-high[i]-low[i])/(v!=0 ? v : 1.0))*tick_volume[i];
      BufferVol[i]=(double)tick_volume[i];
     }
   SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferRAW,BufferAVG1);
   if(InpUseNorm)
      SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferVol,BufferAVG2);
   
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferIIDX[i]=(InpUseNorm ? 100.*BufferAVG1[i]/(BufferAVG2[i]!=0 ? BufferAVG2[i]*Point() : 1.0) : BufferAVG1[i]*period_ind)*Point();

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
