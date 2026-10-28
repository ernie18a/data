//+------------------------------------------------------------------+
//|                                                          VSI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Volatility (Regime) Switch Indicator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot VS
#property indicator_label1  "VSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriod      =  21;   // Period
input double   InpOverbought  =  0.8;  // Overbought
input double   InpOversold    =  0.2;  // Oversold
//--- indicator buffers
double         BufferVS[];
double         BufferDaily[];
double         BufferDeviation[];
double         BufferMADevTmp[];
//--- global variables
double         overbought;
double         oversold;
int            period_vsi;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_vsi=int(InpPeriod<1 ? 1 : InpPeriod);
   oversold=(InpOversold<0 ? 0 : InpOversold>0.5 ? 0.5 : InpOversold);
   overbought=(InpOverbought>1 ? 1 : InpOverbought<0.5 ? 0.5 : InpOverbought);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferVS,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDaily,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferDeviation,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMADevTmp,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"VSI("+(string)period_vsi+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,0.5);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,oversold);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferVS,true);
   ArraySetAsSeries(BufferDaily,true);
   ArraySetAsSeries(BufferDeviation,true);
   ArraySetAsSeries(BufferMADevTmp,true);
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
   if(rates_total<period_vsi*2+1) return 0;
//--- Установка индексации массивов как таймсерий
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   int limit1=limit;
   if(limit>1)
     {
      limit=rates_total-2;
      limit1=limit-1-period_vsi*2;
      ArrayInitialize(BufferVS,EMPTY_VALUE);
      ArrayInitialize(BufferDaily,EMPTY_VALUE);
      ArrayInitialize(BufferDeviation,0);
      ArrayInitialize(BufferMADevTmp,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0; i--)
     {
      double value=(close[i]+close[i+1])/2;
      BufferDaily[i]=(close[i]-close[i+1])/(value!=0 ? value : DBL_MIN);
     }
   StdDevOnArray(rates_total,prev_calculated,0,period_vsi,MODE_SMA,BufferMADevTmp,BufferDaily,BufferDeviation);
//--- Расчёт индикатора
   for(int i=limit1; i>=0 && !IsStopped(); i--)
     {
      double count=0;
      for(int j=period_vsi-1; j>=0; j--)
         if(BufferDeviation[i+j]<=BufferDeviation[i])
            count+=1;
      BufferVS[i]=count/period_vsi;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Standart Deviation on array                                      |
//+------------------------------------------------------------------+
#include <MovingAverages.mqh>
template<typename T>
int StdDevOnArray(const int rates_total,
                  const int prev_calculated,
                  const int begin,
                  const int period,
                  const ENUM_MA_METHOD method,
                  double &buffer_ma_tmp[],
                  const T &src_array[],
                  double &dest_buffer[]
                  )
  {
//--- variables of indicator
   int pos=0;
//--- check for rates count
   if(rates_total<period) return(0);
//--- save as_series flags
   bool as_series_arr=ArrayGetAsSeries(src_array);
   bool as_series_dev=ArrayGetAsSeries(dest_buffer);
   bool as_series_ma=ArrayGetAsSeries(buffer_ma_tmp);
   if(as_series_arr)
      ArraySetAsSeries(src_array,false);
   if(as_series_dev)
      ArraySetAsSeries(dest_buffer,false);
   if(as_series_ma)
      ArraySetAsSeries(buffer_ma_tmp,false);

//--- starting work
   pos=prev_calculated-1;
//--- correct position for first iteration
   if(pos<period)
     {
      pos=period-1;
      ArrayInitialize(dest_buffer,0.0);
      ArrayInitialize(buffer_ma_tmp,0.0);
     }
//--- main cycle
   switch(method)
     {
      case  MODE_EMA :
         for(int i=pos;i<rates_total && !IsStopped();i++)
           {
            if(i==period-1)
               buffer_ma_tmp[i]=SimpleMA(i,period,src_array);
            else
               buffer_ma_tmp[i]=ExponentialMA(i,period,buffer_ma_tmp[i-1],src_array);
            //--- Calculate StdDev
            dest_buffer[i]=StdDevFunc(src_array,buffer_ma_tmp,period,i);
           }
         break;
      case MODE_SMMA :
         for(int i=pos;i<rates_total && !IsStopped();i++)
           {
            if(i==period-1)
               buffer_ma_tmp[i]=SimpleMA(i,period,src_array);
            else
               buffer_ma_tmp[i]=SmoothedMA(i,period,buffer_ma_tmp[i-1],src_array);
            //--- Calculate StdDev
            dest_buffer[i]=StdDevFunc(src_array,buffer_ma_tmp,period,i);
           }
         break;
      case MODE_LWMA :
         for(int i=pos;i<rates_total && !IsStopped();i++)
           {
            buffer_ma_tmp[i]=LinearWeightedMA(i,period,src_array);
            dest_buffer[i]=StdDevFunc(src_array,buffer_ma_tmp,period,i);
           }
         break;
      default   :
         for(int i=pos;i<rates_total && !IsStopped();i++)
           {
            buffer_ma_tmp[i]=SimpleMA(i,period,src_array);
            //--- Calculate StdDev
            dest_buffer[i]=StdDevFunc(src_array,buffer_ma_tmp,period,i);
           }
     }
//--- restore as_series flags
   if(as_series_arr)
      ArraySetAsSeries(src_array,true);
   if(as_series_dev)
      ArraySetAsSeries(dest_buffer,true);
   if(as_series_ma)
      ArraySetAsSeries(buffer_ma_tmp,true);
//---- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Calculate Standard Deviation                                     |
//+------------------------------------------------------------------+
template<typename T>
double StdDevFunc(const T &price[],const double &price_ma[],const int period,int position)
  {
   double dev=0.0;
   for(int i=0;i<period;i++) dev+=pow(price[position-i]-price_ma[position],2);
   dev=sqrt(dev/period);
   return(dev);
  }
//+------------------------------------------------------------------+
