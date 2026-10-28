//+------------------------------------------------------------------+
//|                                       Blau_Candlestick_Index.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "William Blau Candlestick Index"
#property indicator_separate_window
#property indicator_buffers 13
#property indicator_plots   1
//--- plot CI
#property indicator_label1  "BCIndex"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumVioletRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  1;             // Period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input uint                 InpPeriodSmooth1  =  20;            // First smoothing period
input uint                 InpPeriodSmooth2  =  5;             // Second smoothing period
input uint                 InpPeriodSmooth3  =  3;             // Third smoothing period
input double               InpLevelUP        =  25.0;          // Upper level
input double               InpLevelDN        =  25.0;          // Lower level
//--- indicator buffers
double         BufferCI[];
double         BufferMA[];
double         BufferMAA1[];
double         BufferMAA2[];
double         BufferMAA3[];
double         BufferCM[];
double         BufferCMMA1[];
double         BufferCMMA2[];
double         BufferCMMA3[];
double         BufferMinMax[];
double         BufferMinMaxMA1[];
double         BufferMinMaxMA2[];
double         BufferMinMaxMA3[];
//--- global variables
double         level_up;
double         level_dn;
int            period_ind;
int            period_sm1;
int            period_sm2;
int            period_sm3;
int            handle_ma;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ind=int(InpPeriod<1 ? 1 : InpPeriod);
   period_sm1=int(InpPeriodSmooth1<2 ? 2 : InpPeriodSmooth1);
   period_sm2=int(InpPeriodSmooth2<2 ? 2 : InpPeriodSmooth2);
   period_sm3=int(InpPeriodSmooth3<2 ? 2 : InpPeriodSmooth3);
   level_up=(InpLevelUP<0.1 ? 0.1 : InpLevelUP);
   level_dn=(InpLevelDN>0 ? -InpLevelDN : InpLevelDN>-0.1 ? -0.1 : InpLevelDN);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferCI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferMAA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMAA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMAA3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferCM,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferCMMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferCMMA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferCMMA3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferMinMax,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,BufferMinMaxMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,BufferMinMaxMA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(12,BufferMinMaxMA3,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"BCSI("+(string)period_ind+","+(string)period_sm1+","+(string)period_sm2+","+(string)period_sm3+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,level_up);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,level_dn);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferCI,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferMAA1,true);
   ArraySetAsSeries(BufferMAA2,true);
   ArraySetAsSeries(BufferMAA3,true);
   ArraySetAsSeries(BufferCM,true);
   ArraySetAsSeries(BufferCMMA1,true);
   ArraySetAsSeries(BufferCMMA2,true);
   ArraySetAsSeries(BufferCMMA3,true);
   ArraySetAsSeries(BufferMinMax,true);
   ArraySetAsSeries(BufferMinMaxMA1,true);
   ArraySetAsSeries(BufferMinMaxMA2,true);
   ArraySetAsSeries(BufferMinMaxMA3,true);
//--- create MA's handle
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
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
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<period_ind) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_ind-1;
      ArrayInitialize(BufferCI,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferMAA1,0);
      ArrayInitialize(BufferMAA2,0);
      ArrayInitialize(BufferMAA3,0);
      ArrayInitialize(BufferCM,0);
      ArrayInitialize(BufferCMMA1,0);
      ArrayInitialize(BufferCMMA2,0);
      ArrayInitialize(BufferCMMA3,0);
      ArrayInitialize(BufferMinMax,0);
      ArrayInitialize(BufferMinMaxMA1,0);
      ArrayInitialize(BufferMinMaxMA2,0);
      ArrayInitialize(BufferMinMaxMA3,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferCM[i]=BufferMA[i]-BufferMA[i+period_ind];
      int bl=Lowest(period_ind,i);
      int bh=Highest(period_ind,i);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE) continue;
      double min=low[bl];
      double max=high[bh];
      BufferMinMax[i]=max-min;
     }
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm1,BufferCM,BufferCMMA1);
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm1,BufferMinMax,BufferMinMaxMA1);
   
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm2,BufferCMMA1,BufferCMMA2);
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm2,BufferMinMaxMA1,BufferMinMaxMA2);
   
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm3,BufferCMMA2,BufferCMMA3);
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm3,BufferMinMaxMA2,BufferMinMaxMA3);
   
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferCI[i]=100.*BufferCMMA3[i]/(BufferMinMaxMA3[i]!=0 ? BufferMinMaxMA3[i] : DBL_MIN);

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
   if(CopyHigh(Symbol(),PERIOD_CURRENT,start,count,array)==count)
      return ArrayMaximum(array)+start;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс минимального значения таймсерии Low            |
//+------------------------------------------------------------------+
int Lowest(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   if(CopyLow(Symbol(),PERIOD_CURRENT,start,count,array)==count)
      return ArrayMinimum(array)+start;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
