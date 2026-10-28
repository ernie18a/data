//+------------------------------------------------------------------+
//|                                                          VZO.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Volume Zone Oscillator"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot VZO
#property indicator_label1  "VZO"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCadetBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriod      =  6;    // Period
input double   InpUpper       =  60.0; // Extreme overbought
input double   InpOverbought  =  40.0; // Overbought
input double   InpOversold    = -40.0; // Oversold
input double   InpLower       = -60.0; // Extreme oversold

//--- indicator buffers
double         BufferVZO[];
double         BufferAvgVP[];
double         BufferAvgVol[];
double         BufferVP[];
double         BufferVOL[];
//--- global variables
double         upper;
double         overbought;
double         oversold;
double         lower;
int            period_vzo;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_vzo=int(InpPeriod<1 ? 1 : InpPeriod);
   overbought=(fabs(InpOverbought)<0.1 ? 0.1 : InpOverbought>99.9 ? 99.9 : fabs(InpOverbought));
   oversold=(-fabs(InpOversold)>-0.1 ? -0.1 : -fabs(InpOversold)<-99.9 ? -99.9 : -fabs(InpOversold));
   upper=(fabs(InpUpper)<=overbought ? overbought+0.1 : InpUpper>100.0 ? 100.0 : fabs(InpUpper));
   lower=(-fabs(InpLower)>=oversold ? oversold-0.1 : -fabs(InpLower)<-100.0 ? -100.0 : -fabs(InpLower));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferVZO,INDICATOR_DATA);
   SetIndexBuffer(1,BufferAvgVP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferAvgVol,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferVP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferVOL,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"VZO ("+(string)period_vzo+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,4);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,upper);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,oversold);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,3,lower);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Extreme overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,2,"Oversold");
   IndicatorSetString(INDICATOR_LEVELTEXT,3,"Extreme oversold");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferVZO,true);
   ArraySetAsSeries(BufferAvgVP,true);
   ArraySetAsSeries(BufferAvgVol,true);
   ArraySetAsSeries(BufferVP,true);
   ArraySetAsSeries(BufferVOL,true);
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
   if(rates_total<fmax(period_vzo,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferVZO,EMPTY_VALUE);
      ArrayInitialize(BufferAvgVP,0);
      ArrayInitialize(BufferAvgVol,0);
      ArrayInitialize(BufferVP,0);
      ArrayInitialize(BufferVOL,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferVOL[i]=(double)tick_volume[i];
      BufferVP[i]=double(close[i]>close[i+1] ? tick_volume[i] : -tick_volume[i]);
      BufferAvgVP[i]=ExponentialMA(rates_total,period_vzo,i,BufferVP);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferAvgVol[i]=ExponentialMA(rates_total,period_vzo,i,BufferVOL);
      BufferVZO[i]=(BufferAvgVol[i]!=0 ? (BufferAvgVP[i]/BufferAvgVol[i])*100.0 : 0);
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
double SimpleMA(const int rates_total,const int period,const int index,const double &price[])
  {
//---
   double result=0.0;
//--- check position
   if(period<1 || index>rates_total-period-1)
      return 0;
//--- calculate value
   for(int i=0; i<period; i++)
     result=result+price[index+i];
   result/=period;
//---
   return result;
  }
//+------------------------------------------------------------------+
//| Exponential Moving Average                                       |
//+------------------------------------------------------------------+
double ExponentialMA(const int rates_total,const int period,const int index,const double &price[])
  {
//---
   static double prev_value=0;
   double result=0.0;
//--- check position
   if(period<1 || index>rates_total-period-1)
      return 0;
   double pr=2.0/(period+1.0);
//--- SMA for first data
   if(index==rates_total-period-1 || prev_value==0)
      prev_value=result=SimpleMA(rates_total,period,index,price);
//--- EMA
   else
     {
      result=prev_value+pr*(price[index]-prev_value);
      //--- new bar
      if(index!=0)
         prev_value=result;
     }
//---
   return result;
  }
//+------------------------------------------------------------------+
