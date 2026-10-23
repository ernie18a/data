//+------------------------------------------------------------------+
//|                                       Directional_Volatility.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Directional Volatility indicator"
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   2
//--- plot Slow
#property indicator_label1  "VShort"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Fast
#property indicator_label2  "VLong"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint     InpPeriod      =  14;   // Period
input uint     InpDeviation   =  3;    // Deviation
//--- indicator buffers
double         BufferShort[];
double         BufferLong[];
double         BufferShortS[];
double         BufferLongS[];
double         BufferShortMA[];
double         BufferLongMA[];
double         BufferShortDev[];
double         BufferLongDev[];
double         BufferMADevTmp[];
//--- global variables
double         deviation;
int            period_sm;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_sm=int(InpPeriod<2 ? 2 : InpPeriod);
   deviation=InpDeviation;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferShort,INDICATOR_DATA);
   SetIndexBuffer(1,BufferLong,INDICATOR_DATA);
   SetIndexBuffer(2,BufferShortS,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferLongS,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferShortMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferLongMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferShortDev,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferLongDev,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferMADevTmp,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Directional Volatility ("+(string)period_sm+","+DoubleToString(deviation,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferShort,true);
   ArraySetAsSeries(BufferLong,true);
   ArraySetAsSeries(BufferShortS,true);
   ArraySetAsSeries(BufferLongS,true);
   ArraySetAsSeries(BufferShortMA,true);
   ArraySetAsSeries(BufferLongMA,true);
   ArraySetAsSeries(BufferShortDev,true);
   ArraySetAsSeries(BufferLongDev,true);
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_sm,4) || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferShort,EMPTY_VALUE);
      ArrayInitialize(BufferLong,0);
      ArrayInitialize(BufferShortS,0);
      ArrayInitialize(BufferLongS,0);
      ArrayInitialize(BufferShortMA,0);
      ArrayInitialize(BufferLongMA,0);
      ArrayInitialize(BufferShortDev,0);
      ArrayInitialize(BufferLongDev,0);
      ArrayInitialize(BufferMADevTmp,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferShortS[i]=close[i+1]-low[i];
      BufferLongS[i]=high[i]-close[i+1];
     }
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferShortS,BufferShortMA)==0)
      return 0;
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferLongS,BufferLongMA)==0)
      return 0;
   if(StdDevOnArray(rates_total,prev_calculated,0,period_sm,MODE_SMA,BufferMADevTmp,BufferShortMA,BufferShortDev)==0)
      return 0;
   if(StdDevOnArray(rates_total,prev_calculated,0,period_sm,MODE_SMA,BufferMADevTmp,BufferLongMA,BufferLongDev)==0)
      return 0;
   
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferShort[i]=(BufferShortMA[i]+deviation*BufferShortDev[i])/Point();
      BufferLong[i]=(BufferLongMA[i]+deviation*BufferLongDev[i])/Point();
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
   for(int i=0; i<period; i++) dev+=pow(price[position-i]-price_ma[position],2);
   dev=sqrt(dev/period);
   return(dev);
  }
//+------------------------------------------------------------------+
