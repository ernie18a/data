//+------------------------------------------------------------------+
//|                                                 KDJ_Averages.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "KDJ averages oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
//--- plot K
#property indicator_label1  "K Avg"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot D
#property indicator_label2  "D Avg"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot J
#property indicator_label3  "J Avg"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint           InpPeriod      =  9;          // KDJ period
input uint           InpPeriodK     =  3;          // K period
input ENUM_MA_METHOD InpMethodK     =  MODE_SMA;   // K method
input uint           InpPeriodD     =  3;          // D period
input ENUM_MA_METHOD InpMethodD     =  MODE_SMA;   // D method
input double         InpThreshold   =  50.0;       // Threshold
//--- indicator buffers
double         BufferK[];
double         BufferD[];
double         BufferJ[];
double         BufferRSV[];
//--- global variables
double         threshold;
int            period_kdj;
int            period_ksm;
int            period_dsm;
int            period_max;
int            weight_sum_k;
int            weight_sum_d;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_kdj=(int)InpPeriod;
   period_ksm=int(InpPeriodK<2 ? 2 : InpPeriodK);
   period_dsm=int(InpPeriodD<2 ? 2 : InpPeriodD);
   period_max=fmax(period_kdj,fmax(period_ksm,period_dsm));
   threshold=(InpThreshold<0 ? 0 : InpThreshold>100 ? 100 : InpThreshold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferK,INDICATOR_DATA);
   SetIndexBuffer(1,BufferD,INDICATOR_DATA);
   SetIndexBuffer(2,BufferJ,INDICATOR_DATA);
   SetIndexBuffer(3,BufferRSV,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"KDJ averages ("+(string)period_kdj+","+(string)period_ksm+","+(string)period_dsm+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,threshold);
//--- setting plot buffer parameters
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferK,true);
   ArraySetAsSeries(BufferD,true);
   ArraySetAsSeries(BufferJ,true);
   ArraySetAsSeries(BufferRSV,true);
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
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_kdj-1;
      ArrayInitialize(BufferK,0);
      ArrayInitialize(BufferD,0);
      ArrayInitialize(BufferJ,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double Cn=close[i];
      int bl=Lowest(period_kdj,i);
      int bh=Highest(period_kdj,i);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         continue;
      double Ln=fmin(Cn,low[bl]);
      double Hn=fmax(Cn,high[bh]);
      BufferRSV[i]=(Hn!=Ln ? 100.0*(Cn-Ln)/(Hn-Ln) : 50.0);
     }
//--- Расчёт индикатора
   switch(InpMethodK)
     {
      case MODE_EMA  :  if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_kdj,period_ksm,BufferRSV,BufferK)==0) return 0;                 break;
      case MODE_SMMA :  if(SmoothedMAOnBuffer(rates_total,prev_calculated,period_kdj,period_ksm,BufferRSV,BufferK)==0) return 0;                    break;
      case MODE_LWMA :  if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_kdj,period_ksm,BufferRSV,BufferK,weight_sum_k)==0) return 0; break;
      //---MODE_SMA
      default        :  if(SimpleMAOnBuffer(rates_total,prev_calculated,period_kdj,period_ksm,BufferRSV,BufferK)==0) return 0;                      break;
     }
   switch(InpMethodD)
     {
      case MODE_EMA  :  if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_ksm,period_dsm,BufferK,BufferD)==0) return 0;                   break;
      case MODE_SMMA :  if(SmoothedMAOnBuffer(rates_total,prev_calculated,period_ksm,period_dsm,BufferK,BufferD)==0) return 0;                      break;
      case MODE_LWMA :  if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_ksm,period_dsm,BufferK,BufferD,weight_sum_d)==0) return 0;   break;
      //---MODE_SMA
      default        :  if(SimpleMAOnBuffer(rates_total,prev_calculated,period_ksm,period_dsm,BufferK,BufferD)==0) return 0;                        break;
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferJ[i]=3.0*BufferD[i]-2.0*BufferK[i];

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
   return(CopyHigh(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMaximum(array)+start : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс минимального значения таймсерии Low            |
//+------------------------------------------------------------------+
int Lowest(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyLow(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMinimum(array)+start : WRONG_VALUE);
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
