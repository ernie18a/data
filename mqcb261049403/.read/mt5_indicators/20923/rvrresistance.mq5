//+------------------------------------------------------------------+
//|                                                RVRResistance.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "RVR Price Resistance oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
//--- plot SR
#property indicator_label1  "SR"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrCadetBlue,clrForestGreen,clrSalmon
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- enums
enum ENUM_TYPE_CALC
  {
   TYPE_OC,          // Open/Close
   TYPE_HL           // High/Low
  };
//---
enum ENUM_COLOR_SET
  {
   COLORS_PREV =  1, // By previous bar position
   COLORS_ONE  =  0  // One color
  };
//---
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input ENUM_TYPE_CALC    InpType     =  TYPE_OC;       // Calculation type
input uint              InpPeriod   =  15;            // Period
input uint              InpMinP     =  5;             // Min points
input uint              InpMinV     =  5;             // Min volume
input ENUM_MA_METHOD    InpMethod   =  MODE_EMA;      // MA Method
input ENUM_COLOR_SET    InpPrevBars =  COLORS_PREV;   // Colors setting
input ENUM_INPUT_YES_NO InpInverse  =  INPUT_NO;      // Inverse
//--- indicator buffers
double         BufferSR[];
double         BufferColors[];
double         BufferSignal[];
double         BufferRVR[];
//--- global variables
int            period_ind;
int            min_point;
int            min_volume;
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
   min_point=int(InpMinP<1 ? 1 : InpMinP);
   min_volume=int(InpMinV<1 ? 1 : InpMinV);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSR,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(3,BufferRVR,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   string descr=(InpType==TYPE_HL ? "High/Low" : "Open/Close");
   IndicatorSetString(INDICATOR_SHORTNAME,"RVR Price Resistance "+descr+" ("+(string)period_ind+","+(string)min_point+","+(string)min_volume+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
//--- setting plot buffer psrsmeters
   PlotIndexSetString(0,PLOT_LABEL,"SR "+descr);
   PlotIndexSetString(1,PLOT_LABEL,"Signal"+" ("+(string)period_ind+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSR,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferRVR,true);
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
      limit=rates_total-2;
      ArrayInitialize(BufferRVR,EMPTY_VALUE);
      ArrayInitialize(BufferSignal,0);
      ArrayInitialize(BufferRVR,0);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferRVR[i]=(InpType==TYPE_OC ? fabs(open[i]-close[i]) : (high[i]-low[i]))/Point();
      double diff=fmax(BufferRVR[i],min_point);
      double vol=(int)fmax(tick_volume[i],min_volume);
      BufferSR[i]=(vol!=0 && diff!=0 ? (InpInverse ? vol/diff : diff/vol) : 0);
      BufferColors[i]=0;
     }
   switch(InpMethod)
     {
      case MODE_EMA  :  ExponentialMAOnBuffer(rates_total,prev_calculated,period_ind,period_ind,BufferSR,BufferSignal);               break;
      case MODE_SMMA :  SmoothedMAOnBuffer(rates_total,prev_calculated,period_ind,period_ind,BufferSR,BufferSignal);                  break;
      case MODE_LWMA :  LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_ind,period_ind,BufferSR,BufferSignal,weight_sum); break;
      //---MODE_SMA
      default        :  SimpleMAOnBuffer(rates_total,prev_calculated,period_ind,period_ind,BufferSR,BufferSignal);                    break;
     }
   if(InpPrevBars)
      for(int i=limit; i>=0 && !IsStopped(); i--)
         BufferColors[i]=(BufferSR[i+1]>BufferSignal[i+1] ? 1 : 2);
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
