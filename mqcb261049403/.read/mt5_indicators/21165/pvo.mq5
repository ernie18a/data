//+------------------------------------------------------------------+
//|                                                          PVO.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Percentage Volume Oscillator"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   3
//--- plot PVO
#property indicator_label1  "PVO"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrFuchsia
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Hist
#property indicator_label3  "Histogram"
#property indicator_type3   DRAW_COLOR_HISTOGRAM
#property indicator_color3  clrGreen,clrRed,clrDarkGray
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- enums
enum ENUM_MODE
  {
   MODE_ABS,         // Absolute
   MODE_RLT          // Relative
  };
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input ENUM_INPUT_YES_NO InpShowHist    =  INPUT_YES;  // Show histogram
input ENUM_INPUT_YES_NO InpShowPVO     =  INPUT_YES;  // Show PVO
input ENUM_INPUT_YES_NO InpShowSig     =  INPUT_YES;  // Show Signal
input uint              InpPeriodFast  =  12;         // Fast MA period
input ENUM_MA_METHOD    InpMethodFast  =  MODE_EMA;   // Fast MA method
input uint              InpPeriodSlow  =  26;         // Slow MA period
input ENUM_MA_METHOD    InpMethodSlow  =  MODE_EMA;   // Slow MA method
input uint              InpPeriodSig   =  9;          // Signal period
input ENUM_MA_METHOD    InpMethodSig   =  MODE_EMA;   // Signal method
input ENUM_MODE         InpMode        =  MODE_ABS;   // Calculation mode
//--- indicator buffers
double         BufferPVO[];
double         BufferSignal[];
double         BufferHist[];
double         BufferColors[];
double         BufferVol[];
double         BufferAvgFVol[];
double         BufferAvgSVol[];
//--- global variables
int            period_fma;
int            period_sma;
int            period_sig;
int            period_max;
int            weight_sum;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fma=int(InpPeriodFast<2 ? 2 : InpPeriodFast);
   period_sma=int(InpPeriodSlow==period_fma ? period_fma+1 : InpPeriodSlow<2 ? 2 : InpPeriodSlow);
   period_sig=int(InpPeriodSig<2 ? 2 : InpPeriodSig);
   period_max=fmax(period_fma,period_sma);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferPVO,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(2,BufferHist,INDICATOR_DATA);
   SetIndexBuffer(3,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,BufferVol,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferAvgFVol,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferAvgSVol,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"PVO ("+(string)period_fma+","+(string)period_sma+","+(string)period_sig+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,(InpShowPVO ? DRAW_LINE : DRAW_NONE));
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,(InpShowSig ? DRAW_LINE : DRAW_NONE));
   PlotIndexSetInteger(2,PLOT_DRAW_TYPE,(InpShowHist ? DRAW_COLOR_HISTOGRAM : DRAW_NONE));
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferPVO,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferHist,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferVol,true);
   ArraySetAsSeries(BufferAvgFVol,true);
   ArraySetAsSeries(BufferAvgSVol,true);
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferPVO,EMPTY_VALUE);
      ArrayInitialize(BufferSignal,EMPTY_VALUE);
      ArrayInitialize(BufferHist,EMPTY_VALUE);
      ArrayInitialize(BufferVol,0);
      ArrayInitialize(BufferAvgFVol,0);
      ArrayInitialize(BufferAvgSVol,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferVol[i]=(double)tick_volume[i];

   switch(InpMethodFast)
     {
      case MODE_EMA  :  if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_max,period_fma,BufferVol,BufferAvgFVol)==0) return 0;               break;
      case MODE_SMMA :  if(SmoothedMAOnBuffer(rates_total,prev_calculated,period_max,period_fma,BufferVol,BufferAvgFVol)==0) return 0;                  break;
      case MODE_LWMA :  if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_max,period_fma,BufferVol,BufferAvgFVol,weight_sum)==0) return 0; break;
      //---MODE_SMA
      default        :  if(SimpleMAOnBuffer(rates_total,prev_calculated,period_max,period_fma,BufferVol,BufferAvgFVol)==0) return 0;                    break;
     }
   switch(InpMethodSlow)
     {
      case MODE_EMA  :  if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_max,period_sma,BufferVol,BufferAvgSVol)==0) return 0;               break;
      case MODE_SMMA :  if(SmoothedMAOnBuffer(rates_total,prev_calculated,period_max,period_sma,BufferVol,BufferAvgSVol)==0) return 0;                  break;
      case MODE_LWMA :  if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_max,period_sma,BufferVol,BufferAvgSVol,weight_sum)==0) return 0; break;
      //---MODE_SMA
      default        :  if(SimpleMAOnBuffer(rates_total,prev_calculated,period_max,period_sma,BufferVol,BufferAvgSVol)==0) return 0;                    break;
     }

//--- Расчёт PVO и Signal
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double fma=BufferAvgFVol[i];
      double sma=BufferAvgSVol[i];
      BufferPVO[i]=(InpMode==MODE_ABS ? fma-sma : (sma!=0 ? 100.0*(fma-sma)/sma : 0));
     }
   switch(InpMethodSig)
     {
      case MODE_EMA  :  if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_max,period_sig,BufferPVO,BufferSignal)==0) return 0;               break;
      case MODE_SMMA :  if(SmoothedMAOnBuffer(rates_total,prev_calculated,period_max,period_sig,BufferPVO,BufferSignal)==0) return 0;                  break;
      case MODE_LWMA :  if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_max,period_sig,BufferPVO,BufferSignal,weight_sum)==0) return 0; break;
      //---MODE_SMA
      default        :  if(SimpleMAOnBuffer(rates_total,prev_calculated,period_max,period_sig,BufferPVO,BufferSignal)==0) return 0;                    break;
     }
   
//--- Расчёт гистограммы
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferHist[i]=BufferPVO[i]-BufferSignal[i];
      BufferColors[i]=(BufferHist[i]>BufferHist[i+1] ? 0 : BufferHist[i]<BufferHist[i+1] ? 1 : 0);
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
