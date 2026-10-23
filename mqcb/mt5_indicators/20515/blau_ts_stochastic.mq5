//+------------------------------------------------------------------+
//|                                           Blau_TS_Stochastic.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "William Blau Stochastic oscillator"
#property indicator_separate_window
#property indicator_buffers 12
#property indicator_plots   2
//--- plot BStoch
#property indicator_label1  "BStochOSC"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrPowderBlue,clrPeachPuff,clrLightGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint                 InpPeriod         =  5;             // Period
input uint                 InpPeriodSmooth1  =  20;            // First smooth period
input uint                 InpPeriodSmooth2  =  5;             // Second smooth period
input uint                 InpPeriodSmooth3  =  3;             // Third smooth period
input uint                 InpPeriodSignal   =  3;             // Signal period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferBStoch[];
double         BufferColors[];
double         BufferSignal[];
double         BufferMA[];
double         BufferSto[];
double         BufferSto_EMA1[];
double         BufferSto_EMA2[];
double         BufferSto_EMA3[];
double         BufferHH[];
double         BufferHH_EMA1[];
double         BufferHH_EMA2[];
double         BufferHH_EMA3[];
//--- global variables
int            period_ind;
int            period_sm1;
int            period_sm2;
int            period_sm3;
int            period_sig;
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
   period_sig=int(InpPeriodSignal<2  ? 2 : InpPeriodSignal);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferBStoch,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(3,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferSto,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferSto_EMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferSto_EMA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferSto_EMA3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferHH,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferHH_EMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,BufferHH_EMA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,BufferHH_EMA3,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"BStochOsc("+(string)period_ind+","+(string)period_sm1+","+(string)period_sm2+","+(string)period_sm3+(string)period_sig+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferBStoch,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferSto,true);
   ArraySetAsSeries(BufferSto_EMA1,true);
   ArraySetAsSeries(BufferSto_EMA2,true);
   ArraySetAsSeries(BufferSto_EMA3,true);
   ArraySetAsSeries(BufferHH,true);
   ArraySetAsSeries(BufferHH_EMA1,true);
   ArraySetAsSeries(BufferHH_EMA2,true);
   ArraySetAsSeries(BufferHH_EMA3,true);
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
      limit=rates_total-2;
      ArrayInitialize(BufferBStoch,EMPTY_VALUE);
      ArrayInitialize(BufferSignal,0);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferSto,0);
      ArrayInitialize(BufferSto_EMA1,0);
      ArrayInitialize(BufferSto_EMA2,0);
      ArrayInitialize(BufferSto_EMA3,0);
      ArrayInitialize(BufferHH,0);
      ArrayInitialize(BufferHH_EMA1,0);
      ArrayInitialize(BufferHH_EMA2,0);
      ArrayInitialize(BufferHH_EMA3,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bl=Lowest(period_ind,i);
      int bh=Highest(period_ind,i);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         continue;
      double min=low[bl];
      double max=high[bh];
      BufferHH[i]=max-min;
      BufferSto[i]=BufferMA[i]-min;
     }
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm1,BufferHH,BufferHH_EMA1);
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm1,BufferSto,BufferSto_EMA1);

   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm2,BufferHH_EMA1,BufferHH_EMA2);
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm2,BufferSto_EMA1,BufferSto_EMA2);
   
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm3,BufferHH_EMA2,BufferHH_EMA3);
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm3,BufferSto_EMA2,BufferSto_EMA3);
      
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double HH_EMA3=BufferHH_EMA3[i];
      double Stoch_EMA3=BufferSto_EMA3[i];
      BufferBStoch[i]=(HH_EMA3>0 ? 100.*Stoch_EMA3/HH_EMA3 : 0);
      BufferColors[i]=(BufferBStoch[i]>BufferBStoch[i+1] ? 0 : BufferBStoch[i]<BufferBStoch[i+1] ? 1 : 2);
     }
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sig,BufferBStoch,BufferSignal);
//--- Цвет гистограммы
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferColors[i]=(BufferBStoch[i]>BufferSignal[i+1] ? 0 : BufferBStoch[i]<BufferSignal[i+1] ? 1 : 2);
   
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
