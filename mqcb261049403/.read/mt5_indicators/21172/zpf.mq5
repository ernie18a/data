//+------------------------------------------------------------------+
//|                                                          ZPF.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Zero Point Force indicator"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   1
//--- plot ZPF
#property indicator_label1  "+ZP Force;-ZP Force"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrYellowGreen,clrOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint           InpPeriodFast  =  12;         // Fast MA period
input ENUM_MA_METHOD InpMethodFast  =  MODE_SMA;   // Fast MA method
input uint           InpPeriodSlow  =  24;         // Slow MA period
input ENUM_MA_METHOD InpMethodSlow  =  MODE_SMA;   // Slow MA method
input uint           InpPeriodVol   =  12;         // Volume smoothing period
input ENUM_MA_METHOD InpMethodVol   =  MODE_SMA;   // Volume smoothing method
//--- indicator buffers
double         BufferZPF1[];
double         BufferZPF2[];
double         BufferFMA[];
double         BufferSMA[];
double         BufferVol[];
double         BufferVolAvg[];
//--- global variables
int            period_fma;
int            period_sma;
int            period_vol;
int            weight_sum;
int            handle_fma;
int            handle_sma;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fma=int(InpPeriodFast<1 ? 1 : InpPeriodFast);
   period_sma=int(InpPeriodSlow==period_fma ? period_fma+1 : InpPeriodSlow<1 ? 1 : InpPeriodSlow);
   period_vol=int(InpPeriodVol<2 ? 2 : InpPeriodVol);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferZPF1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferZPF2,INDICATOR_DATA);
   SetIndexBuffer(2,BufferFMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferSMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferVol,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferVolAvg,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Zero Point Force ("+(string)period_fma+","+(string)period_sma+","+(string)period_vol+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferZPF1,true);
   ArraySetAsSeries(BufferZPF2,true);
   ArraySetAsSeries(BufferFMA,true);
   ArraySetAsSeries(BufferSMA,true);
   ArraySetAsSeries(BufferVol,true);
   ArraySetAsSeries(BufferVolAvg,true);
//--- create MA's handles
   ResetLastError();
   handle_fma=iMA(NULL,PERIOD_CURRENT,period_fma,0,InpMethodFast,PRICE_CLOSE);
   if(handle_fma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_fma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sma=iMA(NULL,PERIOD_CURRENT,period_sma,0,InpMethodFast,PRICE_CLOSE);
   if(handle_sma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_sma,") object was not created: Error ",GetLastError());
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4 || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferZPF1,EMPTY_VALUE);
      ArrayInitialize(BufferZPF2,EMPTY_VALUE);
      ArrayInitialize(BufferFMA,0);
      ArrayInitialize(BufferSMA,0);
      ArrayInitialize(BufferVol,0);
      ArrayInitialize(BufferVolAvg,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_fma,0,0,count,BufferFMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sma,0,0,count,BufferSMA);
   if(copied!=count) return 0;
   
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferVol[i]=(double)tick_volume[i];
   switch(InpMethodVol)
     {
      case MODE_EMA  :  if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_vol,BufferVol,BufferVolAvg)==0) return 0;               break;
      case MODE_SMMA :  if(SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_vol,BufferVol,BufferVolAvg)==0) return 0;                  break;
      case MODE_LWMA :  if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_vol,BufferVol,BufferVolAvg,weight_sum)==0) return 0; break;
      //---MODE_SMA
      default        :  if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_vol,BufferVol,BufferVolAvg)==0) return 0;                    break;
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double zpf=BufferVolAvg[i]*(BufferFMA[i]-BufferSMA[i])/(2.0*Point());
      BufferZPF1[i]=zpf;
      BufferZPF2[i]=-zpf;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
