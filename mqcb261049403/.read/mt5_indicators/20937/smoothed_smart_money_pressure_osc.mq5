//+------------------------------------------------------------------+
//|                     Smoothed_Smart_Money_Pressure_Oscillator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Smoothed Smart Money Pressure Oscillator"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   2
//--- plot SMP
#property indicator_label1  "SSMP Osc"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCadetBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpPeriod      =  14;         // SM Period
input uint              InpPeriodSM    =  5;          // SM Smoothing period
input ENUM_MA_METHOD    InpMethodSM    =  MODE_EMA;   // SM Smoothing method
input uint              InpPeriodSig   =  20;         // Signal line Smoothing period
input ENUM_MA_METHOD    InpMethodSig   =  MODE_EMA;   // Signal line Smoothing method
input ENUM_INPUT_YES_NO InpInverse     =  INPUT_YES;  // Graph inverse
//--- indicator buffers
double         BufferAVG[];
double         BufferSig[];
double         BufferSMP[];
double         BufferSM[];
double         BufferVol[];
double         BufferVolMA[];
//--- global variables
int            period_ind;
int            period_sm;
int            period_sig;
int            weight_sum;
char           inv;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ind=int(InpPeriod<2 ? 2 : InpPeriod);
   period_sm=int(InpPeriodSM<2 ? 2 : InpPeriodSM);
   period_sig=int(InpPeriodSig<2 ? 2 : InpPeriodSig);
   inv=(InpInverse ? -1 : 1);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferAVG,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSig,INDICATOR_DATA);
   SetIndexBuffer(2,BufferSMP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferSM,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferVol,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferVolMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Smoothed Smart Money Pressure Osc ("+(string)period_ind+","+(string)period_sm+","+(string)period_sig+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferAVG,true);
   ArraySetAsSeries(BufferSig,true);
   ArraySetAsSeries(BufferSMP,true);
   ArraySetAsSeries(BufferSM,true);
   ArraySetAsSeries(BufferVol,true);
   ArraySetAsSeries(BufferVolMA,true);
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
   if(rates_total<4 || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   int first=rates_total-2;
   if(limit>1)
     {
      limit=first;
      ArrayInitialize(BufferAVG,EMPTY_VALUE);
      ArrayInitialize(BufferSig,EMPTY_VALUE);
      ArrayInitialize(BufferSMP,0);
      ArrayInitialize(BufferSM,0);
      ArrayInitialize(BufferVol,0);
      ArrayInitialize(BufferVolMA,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferVol[i]=(double)tick_volume[i];
   SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferVol,BufferVolMA);
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(i==first)
         BufferSM[i]=close[i];
      else
        {
         double VolMA=BufferVolMA[i];
         double Change=close[i]-close[i+1];
         BufferSM[i]=(BufferVol[i]>VolMA ? BufferSM[i+1]+Change : BufferSM[i+1]);
         BufferSMP[i]=(close[period_ind]-BufferSM[i])/Point()*inv;
        }
     }
   switch(InpMethodSM)
     {
      case MODE_EMA  :  ExponentialMAOnBuffer(rates_total,prev_calculated,period_ind,period_sm,BufferSMP,BufferAVG);               break;
      case MODE_SMMA :  SmoothedMAOnBuffer(rates_total,prev_calculated,period_ind,period_sm,BufferSMP,BufferAVG);                  break;
      case MODE_LWMA :  LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_ind,period_sm,BufferSMP,BufferAVG,weight_sum); break;
      //---MODE_SMA
      default        :  SimpleMAOnBuffer(rates_total,prev_calculated,period_ind,period_sm,BufferSMP,BufferAVG);                    break;
     }
   switch(InpMethodSig)
     {
      case MODE_EMA  :  ExponentialMAOnBuffer(rates_total,prev_calculated,period_sm,period_sig,BufferAVG,BufferSig);               break;
      case MODE_SMMA :  SmoothedMAOnBuffer(rates_total,prev_calculated,period_sm,period_sig,BufferAVG,BufferSig);                  break;
      case MODE_LWMA :  LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_sm,period_sig,BufferAVG,BufferSig,weight_sum); break;
      //---MODE_SMA
      default        :  SimpleMAOnBuffer(rates_total,prev_calculated,period_sm,period_sig,BufferAVG,BufferSig);                    break;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
