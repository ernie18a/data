//+------------------------------------------------------------------+
//|                                                          FVE.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Finite Volume Elements indicator"
#property indicator_separate_window
#property indicator_buffers 11
#property indicator_plots   2
//--- plot FVE
#property indicator_label1  "FVE"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint           InpPeriod      =  22;         // FVE period
input ENUM_MA_METHOD InpMethod      =  MODE_SMA;   // FVE method
input uint           InpPeriodSig   =  22;         // Signal line period
input ENUM_MA_METHOD InpMethodSig   =  MODE_SMA;   // Signal line method
//--- indicator buffers
double         BufferFVE[];
double         BufferSignal[];
double         BufferIntra[];
double         BufferInter[];
double         BufferIntraDev[];
double         BufferInterDev[];
double         BufferVol[];
double         BufferVE[];
double         BufferVolAVG[];
double         BufferVEAVG[];
double         BufferMADevTmp[];
//--- global variables
int            period_ma;
int            period_sig;
int            weight_sum;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriod<2 ? 2 : InpPeriod);
   period_sig=int(InpPeriodSig<2 ? 2 : InpPeriodSig);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferFVE,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(2,BufferIntra,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferInter,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferIntraDev,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferInterDev,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferVol,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferVE,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferVolAVG,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferVEAVG,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,BufferMADevTmp,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Finite Volume Elements ("+(string)period_ma+","+(string)period_sig+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferFVE,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferIntra,true);
   ArraySetAsSeries(BufferInter,true);
   ArraySetAsSeries(BufferIntraDev,true);
   ArraySetAsSeries(BufferInterDev,true);
   ArraySetAsSeries(BufferVol,true);
   ArraySetAsSeries(BufferVE,true);
   ArraySetAsSeries(BufferVolAVG,true);
   ArraySetAsSeries(BufferVEAVG,true);
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
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4 || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferFVE,EMPTY_VALUE);
      ArrayInitialize(BufferSignal,EMPTY_VALUE);
      ArrayInitialize(BufferIntra,0);
      ArrayInitialize(BufferInter,0);
      ArrayInitialize(BufferIntraDev,0);
      ArrayInitialize(BufferInterDev,0);
      ArrayInitialize(BufferVol,0);
      ArrayInitialize(BufferVE,0);
      ArrayInitialize(BufferVolAVG,0);
      ArrayInitialize(BufferVEAVG,0);
      ArrayInitialize(BufferMADevTmp,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferIntra[i]=log(high[i])-log(low[i]);
      BufferInter[i]=log((high[i]+low[i]+close[i])/3.0)-log((high[i+1]+low[i+1]+close[i+1])/3.0);
      BufferVol[i]=(double)tick_volume[i];
     }
   StdDevOnArray(rates_total,prev_calculated,0,period_ma,MODE_SMA,BufferMADevTmp,BufferIntra,BufferIntraDev);
   StdDevOnArray(rates_total,prev_calculated,0,period_ma,MODE_SMA,BufferMADevTmp,BufferInter,BufferInterDev);
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double Vintra=BufferIntraDev[i];
      double Vinter=BufferInterDev[i];
      double Cutoff=0.1*(Vintra+Vinter)*close[i];
      double MF=close[i]-(high[i]+low[i])/2.0+high[i]+low[i]+close[i]-high[i+1]-low[i+1]-close[i+1];
      double v=(MF>Cutoff ? 1.0 : MF<-Cutoff ? -1 : 0);
      BufferVE[i]=v*(double)tick_volume[i];
     }
   SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ma,BufferVE,BufferVEAVG);
   switch(InpMethod)
     {
      case MODE_EMA  :  ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ma,BufferVol,BufferVolAVG);               break;
      case MODE_SMMA :  SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_ma,BufferVol,BufferVolAVG);                  break;
      case MODE_LWMA :  LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_ma,BufferVol,BufferVolAVG,weight_sum); break;
      //---MODE_SMA
      default        :  SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ma,BufferVol,BufferVolAVG);                    break;
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferFVE[i]=(BufferVolAVG[i]!=0 ? 100.0*BufferVEAVG[i]/(BufferVolAVG[i]*Point()) : 0);
   switch(InpMethodSig)
     {
      case MODE_EMA  :  ExponentialMAOnBuffer(rates_total,prev_calculated,period_ma,period_sig,BufferFVE,BufferSignal);               break;
      case MODE_SMMA :  SmoothedMAOnBuffer(rates_total,prev_calculated,period_ma,period_sig,BufferFVE,BufferSignal);                  break;
      case MODE_LWMA :  LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_ma,period_sig,BufferFVE,BufferSignal,weight_sum); break;
      //---MODE_SMA
      default        :  SimpleMAOnBuffer(rates_total,prev_calculated,period_ma,period_sig,BufferFVE,BufferSignal);                    break;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Standart Deviation on array                                      |
//+------------------------------------------------------------------+
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
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
