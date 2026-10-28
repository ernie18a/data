//+------------------------------------------------------------------+
//|                                             Lentz_Volatility.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Lentz Volatility oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot LVOL
#property indicator_label1  "Lentz Vol"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint           InpPeriodATR   =  20;         // ATR period
input uint           InpPeriodMA    =  20;         // Smoothing period
input ENUM_MA_METHOD InpMethod      =  MODE_EMA;   // Smoothing method
//--- indicator buffers
double         BufferLVOL[];
double         BufferColors[];
double         BufferATR[];
double         BufferAvgATR[];
//--- global variables
int            period_atr;
int            period_ma;
int            weight_sum;
int            handle_atr;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_atr=int(InpPeriodATR<1 ? 1 : InpPeriodATR);
   period_ma=int(InpPeriodMA<2 ? 2 : InpPeriodMA);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferLVOL,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferATR,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferAvgATR,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Lentz Volatility ("+(string)period_atr+","+(string)period_ma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferLVOL,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferATR,true);
   ArraySetAsSeries(BufferAvgATR,true);
//--- create MA's handles
   ResetLastError();
   handle_atr=iATR(NULL,PERIOD_CURRENT,period_atr);
   if(handle_atr==INVALID_HANDLE)
     {
      Print("The iATR(",(string)period_atr,") object was not created: Error ",GetLastError());
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
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_ma,4) || Point()==0)
      return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferLVOL,EMPTY_VALUE);
      ArrayInitialize(BufferATR,0);
      ArrayInitialize(BufferAvgATR,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_atr,0,0,count,BufferATR);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   switch(InpMethod)
     {
      case MODE_EMA  :  if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_atr,period_ma,BufferATR,BufferAvgATR)==0) return 0;               break;
      case MODE_SMMA :  if(SmoothedMAOnBuffer(rates_total,prev_calculated,period_atr,period_ma,BufferATR,BufferAvgATR)==0) return 0;                  break;
      case MODE_LWMA :  if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_atr,period_ma,BufferATR,BufferAvgATR,weight_sum)==0) return 0; break;
      //---MODE_SMA
      default        :  if(SimpleMAOnBuffer(rates_total,prev_calculated,period_atr,period_ma,BufferATR,BufferAvgATR)==0) return 0;                    break;
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferLVOL[i]=(BufferAvgATR[i]-BufferATR[i])/Point();
      BufferColors[i]=(BufferAvgATR[i]>BufferATR[i] ? 0 : BufferAvgATR[i]<BufferATR[i] ? 1 : 2);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
