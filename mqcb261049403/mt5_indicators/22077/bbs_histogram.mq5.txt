//+------------------------------------------------------------------+
//|                                                BBS_Histogram.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Bar Based Stochastic with histogram"
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   3
//--- plot K
#property indicator_label1  "BBSH %K"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot D
#property indicator_label2  "BBSH %D"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Hist
#property indicator_label3  "Histogram"
#property indicator_type3   DRAW_COLOR_HISTOGRAM
#property indicator_color3  clrGreen,clrRed,clrDarkGray
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1,          // Yes
   INPUT_NO    =  0           // No
  };
enum ENUM_METHOD
  {
   METHOD_SMA  =  MODE_SMA,   // Simple
   METHOD_EMA  =  MODE_EMA,   // Exponential
   METHOD_SMMA =  MODE_SMMA,  // Smoothing
   METHOD_LWMA =  MODE_LWMA,  // Linear weighted
   METHOD_MT   =  4           // MT algorithm
  };
//--- input parameters
input uint              InpPeriodK     =  5;          // %K period
input uint              InpPeriodD     =  3;          // %D period
input uint              InpSlowing     =  3;          // Slowing
input ENUM_METHOD       InpMethodK     =  METHOD_SMA; // %K method
input ENUM_MA_METHOD    InpMethodD     =  MODE_SMA;   // %D method
input double            InpOverbought  =  30.0;       // Overbought
input double            InpOversold    = -30.0;       // Oversold
input ENUM_INPUT_YES_NO InpShowK       =  INPUT_YES;  // Show %K line
input ENUM_INPUT_YES_NO InpShowD       =  INPUT_YES;  // Show %D line
//--- indicator buffers
double         BufferK[];
double         BufferD[];
double         BufferHist[];
double         BufferColors[];
double         BufferMins[];
double         BufferMaxes[];
double         BufferFastK[];
double         BufferAvgFastK[];
double         BufferRawK[];
//--- global variables
double         overbought;
double         oversold;
int            period_k;
int            period_d;
int            slowing;
int            weight_sum_k;
int            weight_sum_d;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_k=int(InpPeriodK<2 ? 2 : InpPeriodK);
   period_d=int(InpPeriodD<2 ? 2 : InpPeriodD);
   slowing=int(InpSlowing<2 ? 2 : InpSlowing);
   overbought=(InpOverbought<0.1 ? 0.1 : InpOverbought);
   oversold=(InpOversold>-0.1 ? -0.1 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferK,INDICATOR_DATA);
   SetIndexBuffer(1,BufferD,INDICATOR_DATA);
   SetIndexBuffer(2,BufferHist,INDICATOR_DATA);
   SetIndexBuffer(3,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,BufferMins,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferMaxes,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferFastK,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferAvgFastK,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferRawK,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"BBSH("+(string)period_k+","+(string)period_d+","+(string)slowing+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Oversold");
//--- setting plot buffer parameters
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,(InpShowK ? DRAW_LINE : DRAW_NONE));
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,(InpShowD ? DRAW_LINE : DRAW_NONE));
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferK,true);
   ArraySetAsSeries(BufferD,true);
   ArraySetAsSeries(BufferHist,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferMins,true);
   ArraySetAsSeries(BufferMaxes,true);
   ArraySetAsSeries(BufferFastK,true);
   ArraySetAsSeries(BufferAvgFastK,true);
   ArraySetAsSeries(BufferRawK,true);
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_k,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_k-2;
      ArrayInitialize(BufferK,0);
      ArrayInitialize(BufferD,0);
      ArrayInitialize(BufferHist,0);
      ArrayInitialize(BufferMins,0);
      ArrayInitialize(BufferMaxes,0);
      ArrayInitialize(BufferFastK,0);
      ArrayInitialize(BufferAvgFastK,0);
      ArrayInitialize(BufferRawK,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bl=Lowest(period_k,i);
      int bh=Highest(period_k,i);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         continue;
      double minLow=low[bl];
      double maxHigh=high[bh];

      BufferMins[i]=close[i]-minLow;
      BufferMaxes[i]=maxHigh-minLow;
      BufferFastK[i]=(BufferMaxes[i]>0 ? 100.0*BufferMins[i]/BufferMaxes[i] : 50.0);
      if(InpMethodK==METHOD_MT)
        {
         double avgMax=GetSMA(rates_total,i,slowing,BufferMaxes);
         double avgMin=GetSMA(rates_total,i,slowing,BufferMins);
         BufferK[i]=(avgMax!=0 ? 100.0*avgMin/avgMax-50.0 : 0);
        }
     }
     
//--- Расчёт индикатора
   if(InpMethodK<METHOD_MT)
     {
      switch(InpMethodK)
        {
         case METHOD_EMA  :  if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,slowing,BufferFastK,BufferRawK)==0) return 0;                 break;
         case METHOD_SMMA :  if(SmoothedMAOnBuffer(rates_total,prev_calculated,0,slowing,BufferFastK,BufferRawK)==0) return 0;                    break;
         case METHOD_LWMA :  if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,slowing,BufferFastK,BufferRawK,weight_sum_k)==0) return 0; break;
         //---METHOD_SMA
         default          :  if(SimpleMAOnBuffer(rates_total,prev_calculated,0,slowing,BufferFastK,BufferRawK)==0) return 0;                      break;
        }
      for(int i=limit; i>=0 && !IsStopped(); i--)
         BufferK[i]=BufferRawK[i]-50.0;
     }
   switch(InpMethodD)
     {
      case MODE_EMA  :  if(ExponentialMAOnBuffer(rates_total,prev_calculated,slowing,period_d,BufferK,BufferD)==0) return 0;                 break;
      case MODE_SMMA :  if(SmoothedMAOnBuffer(rates_total,prev_calculated,slowing,period_d,BufferK,BufferD)==0) return 0;                    break;
      case MODE_LWMA :  if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,slowing,period_d,BufferK,BufferD,weight_sum_d)==0) return 0; break;
      //---MODE_SMA
      default        :  if(SimpleMAOnBuffer(rates_total,prev_calculated,slowing,period_d,BufferK,BufferD)==0) return 0;                      break;
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferHist[i]=BufferK[i]-BufferD[i];
      BufferColors[i]=(BufferHist[i]>BufferHist[i+1] ? 0 : BufferHist[i]<BufferHist[i+1] ? 1 : 2);
     }
   
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
      result=result+(as_series ? price[index+i]: price[index-i]);
//---
   return(result/period);
  }
//+------------------------------------------------------------------+
