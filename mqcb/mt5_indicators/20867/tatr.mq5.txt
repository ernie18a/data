//+------------------------------------------------------------------+
//|                                                         TATR.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Tick ATR indicator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot TATR
#property indicator_label1  "TATR"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlueViolet
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  14;            // Period
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;      // Method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferTATR[];
double         BufferMA[];
double         BufferTR[];
double         BufferAVG[];
//--- global variables
int            period_ind;
int            handle_ma;
int            weight_sum;
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
   SetIndexBuffer(0,BufferTATR,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferTR,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferAVG,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Tick ATR ("+(string)period_ind+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTATR,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferTR,true);
   ArraySetAsSeries(BufferAVG,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
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
   if(rates_total<period_ind || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferTATR,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferTR,0);
      ArrayInitialize(BufferAVG,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferTR[i]=fabs(BufferMA[i]-BufferMA[i+1]);
   switch(InpMethod)
     {
      case MODE_EMA  :  ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferTR,BufferAVG);               break;
      case MODE_SMMA :  SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferTR,BufferAVG);                  break;
      case MODE_LWMA :  LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferTR,BufferAVG,weight_sum); break;
      //---MODE_SMA
      default        :  SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferTR,BufferAVG);                    break;
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferTATR[i]=BufferAVG[i]/Point();

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
