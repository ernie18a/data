//+------------------------------------------------------------------+
//|                                                          TBS.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Tick Based Stochastic"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   2
//--- plot K
#property indicator_label1  "TBS %K"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot D
#property indicator_label2  "TBS %D"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- enums
enum ENUM_METHOD
  {
   METHOD_SMA  =  MODE_SMA,   // Simple
   METHOD_EMA  =  MODE_EMA,   // Exponential
   METHOD_SMMA =  MODE_SMMA,  // Smoothing
   METHOD_LWMA =  MODE_LWMA,  // Linear weighted
   METHOD_MT   =  4           // MT algorithm
  };
//--- input parameters
input uint                 InpPeriodK        =  5;             // %K period
input uint                 InpPeriodD        =  3;             // %D period
input uint                 InpSlowing        =  3;             // Slowing
input ENUM_METHOD          InpMethodK        =  METHOD_SMA;    // %K method
input ENUM_MA_METHOD       InpMethodD        =  MODE_SMA;      // %D method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input double               InpOverbought     =  80.0;          // Overbought
input double               InpOversold       =  20.0;          // Oversold
//--- indicator buffers
double         BufferK[];
double         BufferD[];
double         BufferMins[];
double         BufferMaxes[];
double         BufferFastK[];
double         BufferMA[];
//--- global variables
double         overbought;
double         oversold;
int            period_k;
int            period_d;
int            slowing;
int            period_max;
int            weight_sum_k;
int            weight_sum_d;
int            handle_ma;
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
   period_max=fmax(period_k,slowing);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>=overbought ? overbought-0.1 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferK,INDICATOR_DATA);
   SetIndexBuffer(1,BufferD,INDICATOR_DATA);
   SetIndexBuffer(2,BufferMins,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMaxes,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferFastK,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"TBS("+(string)period_k+","+(string)period_d+","+(string)slowing+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Oversold");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferK,true);
   ArraySetAsSeries(BufferD,true);
   ArraySetAsSeries(BufferMins,true);
   ArraySetAsSeries(BufferMaxes,true);
   ArraySetAsSeries(BufferFastK,true);
   ArraySetAsSeries(BufferMA,true);
//--- create MA handle
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_k-1;
      ArrayInitialize(BufferK,0);
      ArrayInitialize(BufferD,0);
      ArrayInitialize(BufferMins,0);
      ArrayInitialize(BufferMaxes,0);
      ArrayInitialize(BufferFastK,0);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bl=ArrayMinimum(BufferMA,i,period_k);
      int bh=ArrayMaximum(BufferMA,i,period_k);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         continue;
      double min=BufferMA[bl];
      double max=BufferMA[bh];
      BufferMins[i]=BufferMA[i]-min;
      BufferMaxes[i]=max-min;
      BufferFastK[i]=(BufferMaxes[i]>0 ? 100.0*BufferMins[i]/BufferMaxes[i] : 50.0);
      if(InpMethodK==METHOD_MT)
        {
         max=GetSMA(rates_total,i,slowing,BufferMaxes);
         min=GetSMA(rates_total,i,slowing,BufferMins); 
         BufferK[i]=(max!=0 ? 100.0*min/max : 50.0);
        }
     }

//--- Расчёт индикатора
   if(InpMethodK<METHOD_MT)
     {
      switch(InpMethodK)
        {
         case METHOD_EMA  :  if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,slowing,BufferFastK,BufferK)==0) return 0;                 break;
         case METHOD_SMMA :  if(SmoothedMAOnBuffer(rates_total,prev_calculated,0,slowing,BufferFastK,BufferK)==0) return 0;                    break;
         case METHOD_LWMA :  if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,slowing,BufferFastK,BufferK,weight_sum_k)==0) return 0; break;
         //---METHOD_SMA
         default          :  if(SimpleMAOnBuffer(rates_total,prev_calculated,0,slowing,BufferFastK,BufferK)==0) return 0;                      break;
        }
     }
   switch(InpMethodD)
     {
      case MODE_EMA  :  if(ExponentialMAOnBuffer(rates_total,prev_calculated,slowing,period_d,BufferK,BufferD)==0) return 0;                 break;
      case MODE_SMMA :  if(SmoothedMAOnBuffer(rates_total,prev_calculated,slowing,period_d,BufferK,BufferD)==0) return 0;                    break;
      case MODE_LWMA :  if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,slowing,period_d,BufferK,BufferD,weight_sum_d)==0) return 0; break;
      //---MODE_SMA
      default        :  if(SimpleMAOnBuffer(rates_total,prev_calculated,slowing,period_d,BufferK,BufferD)==0) return 0;                      break;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
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
