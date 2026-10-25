//+------------------------------------------------------------------+
//|                                                     Trend_ID.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Trend identifier oscillator"
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   3
//--- plot B1
#property indicator_label1  "Plus deviation"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot B2
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot B3
#property indicator_label3  "Minus deviation"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint                 InpPeriodMA       =  200;           // MA period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // MA applied price
input uint                 InpPeriodSm       =  20;            // Signal period
input uint                 InpPeriodDev      =  20;            // Deviation period
input double               InpMultiplier     =  2.0;           // Deviation factor
//--- indicator buffers
double         BufferB1[];
double         BufferB2[];
double         BufferB3[];
double         BufferMAP[];
double         BufferMA1[];
double         BufferRAW[];
double         BufferAvgRAW[];
double         BufferDEV[];
double         BufferMADevTmp[];
//--- global variables
double         multiplier;
int            period_ma;
int            period_dev;
int            period_sm;
int            handle_maP;
int            handle_ma1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriodMA<1 ? 1 : InpPeriodMA);
   period_dev=int(InpPeriodDev<1 ? 1 : InpPeriodDev);
   period_sm=int(InpPeriodSm<1 ? 1 : InpPeriodSm);
   multiplier=InpMultiplier;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferB1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferB2,INDICATOR_DATA);
   SetIndexBuffer(2,BufferB3,INDICATOR_DATA);
   SetIndexBuffer(3,BufferMAP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferRAW,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferAvgRAW,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferDEV,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferMADevTmp,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Trend ID ("+(string)period_ma+","+(string)period_dev+","+(string)period_sm+","+DoubleToString(multiplier,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferB1,true);
   ArraySetAsSeries(BufferB2,true);
   ArraySetAsSeries(BufferB3,true);
   ArraySetAsSeries(BufferMAP,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferRAW,true);
   ArraySetAsSeries(BufferAvgRAW,true);
   ArraySetAsSeries(BufferDEV,true);
   ArraySetAsSeries(BufferMADevTmp,true);
//--- create MA's handles
   ResetLastError();
   handle_maP=iMA(NULL,PERIOD_CURRENT,period_ma,0,MODE_SMA,InpAppliedPrice);
   if(handle_maP==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma1=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma1==INVALID_HANDLE)
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_ma,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_ma-1;
      ArrayInitialize(BufferB1,EMPTY_VALUE);
      ArrayInitialize(BufferB2,EMPTY_VALUE);
      ArrayInitialize(BufferB3,EMPTY_VALUE);
      ArrayInitialize(BufferMAP,0);
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferRAW,0);
      ArrayInitialize(BufferAvgRAW,0);
      ArrayInitialize(BufferDEV,0);
      ArrayInitialize(BufferMADevTmp,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_maP,0,0,count,BufferMAP);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma1,0,0,count,BufferMA1);
   if(copied!=count) return 0;
   
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double MA=BufferMAP[i];
      BufferRAW[i]=(MA!=0 ? 100.0*(BufferMA1[i]-MA)/MA : 0);
      BufferAvgRAW[i]=GetSMA(rates_total,i,period_sm,BufferRAW);
     }
   if(StdDevOnArray(rates_total,prev_calculated,period_ma,period_dev,MODE_SMA,BufferMADevTmp,BufferAvgRAW,BufferDEV)==0)
      return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double StdDev=BufferDEV[i];
      BufferB1[i]=multiplier*StdDev;
      BufferB2[i]=BufferAvgRAW[i];
      BufferB3[i]=-1.*multiplier*StdDev;
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
