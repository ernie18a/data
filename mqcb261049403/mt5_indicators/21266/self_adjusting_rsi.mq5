//+------------------------------------------------------------------+
//|                                           Self_Adjusting_RSI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Self-Adjusting RSI oscillator"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   3
//--- plot RSI
#property indicator_label1  "SA RSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot OB
#property indicator_label2  "Overbought"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_DOT
#property indicator_width2  1
//--- plot OS
#property indicator_label3  "Oversold"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_DOT
#property indicator_width3  1
//--- enums
enum ENUM_MODE
  {
   MODE_STDEV, // Standard deviation
   MODE_MA     // Moving average
  };
//--- input parameters
input uint                 InpPeriod         =  14;            // Period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input ENUM_MODE            InpMode           =  MODE_STDEV;    // Calculation mode
input double               InpDeviation      =  1.8;           // Deviation for StdDev mode
input double               InpConstantMA     =  2.0;           // Deviation for MA mode
//--- indicator buffers
double         BufferRSI[];
double         BufferOB[];
double         BufferOS[];
double         BufferRAW[];
double         BufferAvgDev[];
double         BufferAvgRAW[];
double         BufferMADevTmp[];
//--- global variables
int            period_rsi;
int            handle_rsi;
double         deviation;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_rsi=int(InpPeriod<1 ? 1 : InpPeriod);
   deviation=(InpMode==MODE_STDEV ? InpDeviation : InpConstantMA);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferRSI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferOB,INDICATOR_DATA);
   SetIndexBuffer(2,BufferOS,INDICATOR_DATA);
   SetIndexBuffer(3,BufferRAW,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferAvgDev,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferAvgRAW,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferMADevTmp,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"SA RSI ("+(string)period_rsi+","+DoubleToString(deviation,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferRSI,true);
   ArraySetAsSeries(BufferOB,true);
   ArraySetAsSeries(BufferOS,true);
   ArraySetAsSeries(BufferRAW,true);
   ArraySetAsSeries(BufferAvgDev,true);
   ArraySetAsSeries(BufferAvgRAW,true);
   ArraySetAsSeries(BufferMADevTmp,true);
//--- create MA's handles
   ResetLastError();
   handle_rsi=iRSI(NULL,PERIOD_CURRENT,period_rsi,InpAppliedPrice);
   if(handle_rsi==INVALID_HANDLE)
     {
      Print("The iRSI(",(string)period_rsi,") object was not created: Error ",GetLastError());
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
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferRSI,EMPTY_VALUE);
      ArrayInitialize(BufferOB,EMPTY_VALUE);
      ArrayInitialize(BufferOS,EMPTY_VALUE);
      ArrayInitialize(BufferRAW,0);
      ArrayInitialize(BufferAvgDev,0);
      ArrayInitialize(BufferAvgRAW,0);
      ArrayInitialize(BufferMADevTmp,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_rsi,0,0,count,BufferRSI);
   if(copied!=count) return 0;
   
   if(InpMode==MODE_STDEV)
     {
      if(StdDevOnArray(rates_total,prev_calculated,0,period_rsi,MODE_SMA,BufferMADevTmp,BufferRSI,BufferAvgDev)==0)
         return 0;
     }
   else
     {
      if(SimpleMAOnBuffer(rates_total,prev_calculated,period_rsi,period_rsi,BufferRSI,BufferAvgDev)==0)
         return 0;
     }
//--- Расчёт индикатора
   if(InpMode==MODE_STDEV)
     {
      for(int i=limit; i>=0 && !IsStopped(); i--)
        {
         BufferOB[i]=50.0+deviation*BufferAvgDev[i];
         BufferOS[i]=50.0-deviation*BufferAvgDev[i];
        }
     }
   else
     {
      for(int i=limit; i>=0 && !IsStopped(); i--)
         BufferRAW[i]=fabs(BufferRSI[i]-BufferAvgDev[i]);
      if(SimpleMAOnBuffer(rates_total,prev_calculated,period_rsi,period_rsi,BufferRAW,BufferAvgRAW)==0)
         return 0;
      for(int i=limit; i>=0 && !IsStopped(); i--)
        {
         BufferOB[i]=50.0+deviation*BufferAvgRAW[i];
         BufferOS[i]=50.0-deviation*BufferAvgRAW[i];
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Standart Deviation on array                                      |
//+------------------------------------------------------------------+
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
