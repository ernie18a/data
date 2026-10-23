//+------------------------------------------------------------------+
//|                                                          FoM.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Freedom of Movement oscillator"
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_plots   1
//--- plot FoM
#property indicator_label1  "FoM"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRoyalBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint           InpPeriod   =  10;         // Period
input ENUM_MA_METHOD InpMethod   =  MODE_SMA;   // Method
//--- indicator buffers
double         BufferFoM[];
double         BufferRV[];
double         BufferVol[];
double         BufferAMove[];
double         BufferVByM[];
double         BufferMADevTmp[];
double         BufferAvgVol[];
double         BufferDevVol[];
double         BufferAvgVByM[];
double         BufferDevVByM[];
//--- global variables
double         K;
int            period_ind;
int            weight_sum;
int            weight_sum2;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ind=int(InpPeriod<2 ? 2 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferFoM,INDICATOR_DATA);
   SetIndexBuffer(1,BufferRV,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferVol,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferAMove,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferVByM,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferMADevTmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferAvgVol,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferDevVol,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferAvgVByM,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferDevVByM,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"FoM ("+(string)period_ind+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferFoM,true);
   ArraySetAsSeries(BufferRV,true);
   ArraySetAsSeries(BufferVol,true);
   ArraySetAsSeries(BufferAMove,true);
   ArraySetAsSeries(BufferVByM,true);
   ArraySetAsSeries(BufferMADevTmp,true);
   ArraySetAsSeries(BufferAvgVol,true);
   ArraySetAsSeries(BufferDevVol,true);
   ArraySetAsSeries(BufferAvgVByM,true);
   ArraySetAsSeries(BufferDevVByM,true);
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
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_ind,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_ind-2;
      ArrayInitialize(BufferFoM,EMPTY_VALUE);
      ArrayInitialize(BufferRV,0);
      ArrayInitialize(BufferVol,0);
      ArrayInitialize(BufferAMove,0);
      ArrayInitialize(BufferVByM,0);
      ArrayInitialize(BufferMADevTmp,0);
      ArrayInitialize(BufferAvgVol,0);
      ArrayInitialize(BufferDevVol,0);
      ArrayInitialize(BufferAvgVByM,0);
      ArrayInitialize(BufferDevVByM,0);
     }
//--- Подготовка данных
   K=ceil(100.0*tick_volume[0]);
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferVol[i]=tick_volume[i]/K;
   switch(InpMethod)
     {
      case MODE_EMA  :  if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferVol,BufferAvgVol)==0) return 0;               break;
      case MODE_SMMA :  if(SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferVol,BufferAvgVol)==0) return 0;                  break;
      case MODE_LWMA :  if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferVol,BufferAvgVol,weight_sum)==0) return 0; break;
      //---MODE_SMA
      default        :  if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferVol,BufferAvgVol)==0) return 0;                    break;
     }
   if(StdDevOnArray(rates_total,prev_calculated,0,period_ind,InpMethod,BufferMADevTmp,BufferVol,BufferDevVol)==0)
      return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double MA=BufferAvgVol[i];
      double StdDev=BufferDevVol[i];
      BufferRV[i]=(StdDev!=0 ? (BufferVol[i]-MA)/StdDev : 0);
      BufferAMove[i]=(close[i+1]!=0 ? fabs(close[i]-close[i+1])/close[i+1] : 0);
      
      int bl=ArrayMinimum(BufferAMove,i,period_ind);
      int bh=ArrayMaximum(BufferAMove,i,period_ind);
      if(bh==WRONG_VALUE || bl==WRONG_VALUE)
         continue;
      double Min=BufferAMove[bl];
      double Max=BufferAMove[bh];
      double denom=(Max-Min!=0 ? Max-Min : -1);
      double Move=1.0+9.0*(BufferAMove[i]-Min)/fabs(denom);

      bl=ArrayMinimum(BufferRV,i,period_ind);
      bh=ArrayMaximum(BufferRV,i,period_ind);
      if(bh==WRONG_VALUE || bl==WRONG_VALUE)
         continue;
      double MinV=BufferRV[bl];
      double MaxV=BufferRV[bh];
      double denomV=(MaxV-MinV!=0 ? MaxV-MinV : -1);
      double V=1.0+9.0*(BufferRV[i]-MinV)/fabs(denomV);
      BufferVByM[i]=V/(10.0*Move);
     }
   switch(InpMethod)
     {
      case MODE_EMA  :  if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferVByM,BufferAvgVByM)==0) return 0;                  break;
      case MODE_SMMA :  if(SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferVByM,BufferAvgVByM)==0) return 0;                     break;
      case MODE_LWMA :  if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferVByM,BufferAvgVByM,weight_sum2)==0) return 0;   break;
      //---MODE_SMA
      default        :  if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferVByM,BufferAvgVByM)==0) return 0;                       break;
     }
   if(StdDevOnArray(rates_total,prev_calculated,0,period_ind,InpMethod,BufferMADevTmp,BufferVByM,BufferDevVByM)==0)
      return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferFoM[i]=(BufferDevVByM[i]!=0 ? (BufferVByM[i]-BufferAvgVByM[i])/BufferDevVByM[i] : 0);

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
   for(int i=0; i<period; i++) dev+=pow(price[position-i]-price_ma[position],2);
   dev=sqrt(dev/period);
   return(dev);
  }
//+------------------------------------------------------------------+
