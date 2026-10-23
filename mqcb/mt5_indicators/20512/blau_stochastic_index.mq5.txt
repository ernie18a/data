//+------------------------------------------------------------------+
//|                                        Blau_Stochastic_Index.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Blau Stochastic Index oscillator"
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_plots   1
//--- plot Hist
#property indicator_label1  "BStoIndexOsc"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrBlue,clrFuchsia
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint           InpPeriod         =  10;         // Period
input uint           InpPeriodSmooth1  =  5;          // First smooth period
input uint           InpPeriodSmooth2  =  15;         // Second smooth period
input uint           InpPeriodSignal   =  10;         // Signal period
input ENUM_MA_METHOD InpMethod         =  MODE_SMA;   // Method
//--- indicator buffers
double         BufferHist[];
double         BufferColors[];
double         BufferDiff[];
double         BufferDiff_MA1[];
double         BufferDiff_MA2[];
double         BufferDiff_MA3[];
double         BufferRange[];
double         BufferRange_MA1[];
double         BufferRange_MA2[];
double         BufferRange_MA3[];
//--- global variables
int            period_ind;
int            period_sm1;
int            period_sm2;
int            period_sig;
int            weight_summ;
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
   period_sig=int(InpPeriodSignal<2 ? 2 : InpPeriodSignal);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferHist,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferDiff,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferDiff_MA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferDiff_MA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferDiff_MA3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferRange,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferRange_MA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferRange_MA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferRange_MA3,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"BStoIndexOsc("+(string)period_ind+","+(string)period_sm1+","+(string)period_sm2+","+(string)period_sig+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferHist,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferDiff,true);
   ArraySetAsSeries(BufferDiff_MA1,true);
   ArraySetAsSeries(BufferDiff_MA2,true);
   ArraySetAsSeries(BufferDiff_MA3,true);
   ArraySetAsSeries(BufferRange,true);
   ArraySetAsSeries(BufferRange_MA1,true);
   ArraySetAsSeries(BufferRange_MA2,true);
   ArraySetAsSeries(BufferRange_MA3,true);
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
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferHist,EMPTY_VALUE);
      ArrayInitialize(BufferDiff,0);
      ArrayInitialize(BufferDiff_MA1,0);
      ArrayInitialize(BufferDiff_MA2,0);
      ArrayInitialize(BufferDiff_MA3,0);
      ArrayInitialize(BufferRange,0);
      ArrayInitialize(BufferRange_MA1,0);
      ArrayInitialize(BufferRange_MA2,0);
      ArrayInitialize(BufferRange_MA3,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bl=Lowest(period_ind,i);
      int bh=Highest(period_ind,i);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         continue;
      double min=low[bl];
      double max=high[bh];
      BufferDiff[i]=close[i]-min;
      BufferRange[i]=max-min;
     }
   switch(InpMethod)
     {
      case MODE_EMA :  
        ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm1,BufferDiff,BufferDiff_MA1);
        ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm1,BufferRange,BufferRange_MA1);
        
        ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm2,BufferDiff_MA1,BufferDiff_MA2);
        ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm2,BufferRange_MA1,BufferRange_MA2);
        
        ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sig,BufferDiff_MA2,BufferDiff_MA3);
        ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sig,BufferRange_MA2,BufferRange_MA3);
        break;
      case MODE_SMMA :  
        SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_sm1,BufferDiff,BufferDiff_MA1);
        SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_sm1,BufferRange,BufferRange_MA1);
        
        SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_sm2,BufferDiff_MA1,BufferDiff_MA2);
        SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_sm2,BufferRange_MA1,BufferRange_MA2);
        
        SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_sig,BufferDiff_MA2,BufferDiff_MA3);
        SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_sig,BufferRange_MA2,BufferRange_MA3);
        break;
      case MODE_LWMA :  
        LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_sm1,BufferDiff,BufferDiff_MA1,weight_summ);
        LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_sm1,BufferRange,BufferRange_MA1,weight_summ);
        
        LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_sm2,BufferDiff_MA1,BufferDiff_MA2,weight_summ);
        LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_sm2,BufferRange_MA1,BufferRange_MA2,weight_summ);
        
        LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_sig,BufferDiff_MA2,BufferDiff_MA3,weight_summ);
        LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_sig,BufferRange_MA2,BufferRange_MA3,weight_summ);
        break;
      default:
        SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sm1,BufferDiff,BufferDiff_MA1);
        SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sm1,BufferRange,BufferRange_MA1);
        
        SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sm2,BufferDiff_MA1,BufferDiff_MA2);
        SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sm2,BufferRange_MA1,BufferRange_MA2);
        
        SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sig,BufferDiff_MA2,BufferDiff_MA3);
        SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sig,BufferRange_MA2,BufferRange_MA3);
        break;
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferHist[i]=(BufferRange_MA3[i]!=0 ? 100.0*BufferDiff_MA3[i]/BufferRange_MA3[i]-50.0 : 0);
      BufferColors[i]=(BufferHist[i]<BufferHist[i+1] ? 1 : 0);

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
