//+------------------------------------------------------------------+
//|                                         Breakdown_Oscillator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Breakdown oscillator"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   1
//--- plot BD
#property indicator_label1  "Breakdown"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCadetBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  10;            // Period
input uint                 InpPeriodBand     =  20;            // Band period
input double               InpDeviation      =  1.5;           // Deviation
input double               InpSlopeFactor    =  2.0;           // Slope factor
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input double               InpLevel          =  2.0;           // Upper level
//--- indicator buffers
double         BufferBD[];
double         BufferDiff[];
double         BufferMA1[];
double         BufferMAP[];
double         BufferDev[];
double         BufferEMA[];
//--- global variables
double         deviation;
double         slope;
double         level;
int            period_ma;
int            period_dev;
int            handle_ma1;
int            handle_maP;
int            handle_dev;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriod<2 ? 2 : InpPeriod);
   period_dev=int(InpPeriodBand<1 ? 1 : InpPeriodBand);
   deviation=InpDeviation;
   slope=InpSlopeFactor;
   level=(InpLevel<0 ? 0 : InpLevel);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferBD,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDiff,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMAP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferDev,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferEMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Breakdown ("+(string)period_ma+","+(string)period_dev+","+DoubleToString(deviation,2)+DoubleToString(slope,2)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,level);
//--- setting plot buffer parameters
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferBD,true);
   ArraySetAsSeries(BufferDiff,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferMAP,true);
   ArraySetAsSeries(BufferDev,true);
   ArraySetAsSeries(BufferEMA,true);
//--- create handles
   ResetLastError();
   handle_ma1=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("The iMA(1) by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_maP=iMA(NULL,PERIOD_CURRENT,period_ma,0,MODE_SMA,InpAppliedPrice);
   if(handle_maP==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_dev=iStdDev(NULL,PERIOD_CURRENT,period_dev,0,MODE_SMA,InpAppliedPrice);
   if(handle_dev==INVALID_HANDLE)
     {
      Print("The iStdDev(",(string)period_dev,") by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_ma,4) || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_ma-2;
      ArrayInitialize(BufferBD,EMPTY_VALUE);
      ArrayInitialize(BufferDiff,0);
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferMAP,0);
      ArrayInitialize(BufferDev,0);
      ArrayInitialize(BufferEMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma1,0,0,count,BufferMA1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_maP,0,0,count,BufferMAP);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_dev,0,0,count,BufferDev);
   if(copied!=count) return 0;
   
   double Bottom=0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double SMA0=BufferMAP[i];
      double SMA1=BufferMAP[i+1];
      double StdDev=BufferDev[i];
      Bottom=SMA0-deviation*StdDev;
      BufferDiff[i]=BufferMA1[i]-Bottom+slope*(SMA0-SMA1);
     }
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_dev,period_ma,BufferDiff,BufferEMA)==0)
      return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferBD[i]=(Bottom!=0 ? 100.0*BufferEMA[i]/Bottom : 0);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
