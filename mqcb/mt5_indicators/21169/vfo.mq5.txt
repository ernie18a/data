//+------------------------------------------------------------------+
//|                                                          VFO.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Volume Flow oscillator"
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_plots   1
//--- plot VFO
#property indicator_label1  "VFO"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCadetBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriod   =  130;  // Period
input double   InpCoeff    =  0.2;  // Dev Coefficient
input double   InpCoeffV   =  2.5;  // Vol Coefficient
input uint     InpPeriodSm =  3;    // Smoothing period
//--- indicator buffers
double         BufferVFI[];
double         BufferVFIRaw[];
double         BufferVFIRawAvg[];
double         BufferInter[];
double         BufferInterDev[];
double         BufferVol[];
double         BufferVolAvg[];
double         BufferDirVol[];
double         BufferDirVolAvg[];
double         BufferMADevTmp[];
//--- global variables
int            period_ind;
int            period_sm;
double         coeff_v;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ind=int(InpPeriod<2 ? 2 : InpPeriod);
   period_sm=int(InpPeriodSm<1 ? 1 : InpPeriodSm);
   coeff_v=(InpCoeffV==0 ? 0.01 : InpCoeffV);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferVFI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferVFIRaw,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferVFIRawAvg,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferInter,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferInterDev,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferVol,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferVolAvg,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferDirVol,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferDirVolAvg,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferMADevTmp,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"VFO ("+(string)period_ind+","+DoubleToString(InpCoeff,2)+","+DoubleToString(coeff_v,2)+","+(string)period_sm+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferVFI,true);
   ArraySetAsSeries(BufferVFIRaw,true);
   ArraySetAsSeries(BufferVFIRawAvg,true);
   ArraySetAsSeries(BufferInter,true);
   ArraySetAsSeries(BufferInterDev,true);
   ArraySetAsSeries(BufferVol,true);
   ArraySetAsSeries(BufferVolAvg,true);
   ArraySetAsSeries(BufferDirVol,true);
   ArraySetAsSeries(BufferDirVolAvg,true);
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
      ArrayInitialize(BufferVFI,EMPTY_VALUE);
      ArrayInitialize(BufferVFIRaw,0);
      ArrayInitialize(BufferVFIRawAvg,0);
      ArrayInitialize(BufferInter,0);
      ArrayInitialize(BufferInterDev,0);
      ArrayInitialize(BufferVol,0);
      ArrayInitialize(BufferVolAvg,0);
      ArrayInitialize(BufferDirVol,0);
      ArrayInitialize(BufferDirVolAvg,0);
      ArrayInitialize(BufferMADevTmp,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double t0=(high[i]+low[i]+close[i])/3.0;
      double t1=(high[i+1]+low[i+1]+close[i+1])/3.0;
      BufferInter[i]=log(t0)-log(t1);
      BufferVol[i]=(double)tick_volume[i];
     }
   if(StdDevOnArray(rates_total,prev_calculated,0,30,MODE_SMA,BufferMADevTmp,BufferInter,BufferInterDev)==0)
      return 0;
   if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferVol,BufferVolAvg)==0)
      return 0;
   double VAve=0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      VAve=BufferVolAvg[i+1];
      double vmax=VAve*coeff_v;
      double vinter=BufferInterDev[i];
      double cutoff=InpCoeff*vinter*close[i];
      double vc=(BufferVol[i]<vmax ? BufferVol[i] : vmax);
      double t0=(high[i]+low[i]+close[i])/3.0;
      double t1=(high[i+1]+low[i+1]+close[i+1])/3.0;
      double mf=t0-t1;
      BufferDirVol[i]=(mf>cutoff ? vc : mf<-cutoff ? -vc : 0);
     }
   if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferDirVol,BufferDirVolAvg)==0)
      return 0;
   
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferVFIRaw[i]=(VAve!=0 ? period_ind*BufferDirVolAvg[i]/(VAve*Point()) : 0);
   if(period_sm>1)
      if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferVFIRaw,BufferVFIRawAvg)==0)
         return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferVFI[i]=(period_sm>1 ? BufferVFIRawAvg[i] : BufferVFIRaw[i]);

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
