//+------------------------------------------------------------------+
//|                                             Time_Averaged_MA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Time Averaged moving average"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot TAMA
#property indicator_label1  "TAMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  10;            // Period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input uint                 InpPeriodMA       =  15;            // Smoothing period
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;      // Smoothing method
//--- indicator buffers
double         BufferTAMA[];
double         BufferTAP[];
//--- global variables
int            period_ind;
int            period_sm;
int            weight_sum;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ind=int(InpPeriod<1 ? 1 : InpPeriod);
   period_sm=int(InpPeriodMA<2 ? 2 : InpPeriodMA);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTAMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferTAP);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Time Averaged MA ("+(string)period_ind+","+(string)period_sm+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTAMA,true);
   ArraySetAsSeries(BufferTAP,true);
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_ind,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_ind-1;
      ArrayInitialize(BufferTAMA,EMPTY_VALUE);
      ArrayInitialize(BufferTAP,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bh=Highest(period_ind,i);
      int bl=Lowest(period_ind,i);
      if(bh==WRONG_VALUE || bl==WRONG_VALUE)
         continue;
      double max=high[bh];
      double min=low[bl];
      
      BufferTAP[i]=
        (
         InpAppliedPrice==PRICE_CLOSE     ?  close[i+period_ind-1]   :
         InpAppliedPrice==PRICE_OPEN      ?  open[i+period_ind-1]    :
         InpAppliedPrice==PRICE_HIGH      ?  max                     :
         InpAppliedPrice==PRICE_LOW       ?  min                     :
         InpAppliedPrice==PRICE_MEDIAN    ? (max+min)/2.0            :
         InpAppliedPrice==PRICE_TYPICAL   ? (max+min+close[i])/3.0   :
         //--- PRICE_WEIGHTED
         (max+min+2.0*close[i])/4.0
        );  
     }
//--- Расчёт индикатора
   switch(InpMethod)
     {
      case MODE_EMA  :  return ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferTAP,BufferTAMA);
      case MODE_SMMA :  return SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferTAP,BufferTAMA);
      case MODE_LWMA :  return LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferTAP,BufferTAMA,weight_sum);
      //---MODE_SMA
      default        :  return SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferTAP,BufferTAMA);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии High          |
//+------------------------------------------------------------------+
int Highest(const int count,const int start,const bool as_series=true)
  {
   double array[];
   ArraySetAsSeries(array,as_series);
   return(CopyHigh(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMaximum(array)+start : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс минимального значения таймсерии Low            |
//+------------------------------------------------------------------+
int Lowest(const int count,const int start,const bool as_series=true)
  {
   double array[];
   ArraySetAsSeries(array,as_series);
   return(CopyLow(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMinimum(array)+start : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
