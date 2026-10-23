//+------------------------------------------------------------------+
//|                                                       WEVOMO.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Weight Volume Move-Adjusted Moving Average"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   2
//--- plot VOMOMA
#property indicator_label1  "VMoveAdjMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot WEVOMO
#property indicator_label2  "WVMovAdjMA"
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
input uint              InpPeriod   =  14;         // Period
input ENUM_INPUT_YES_NO InpShowVMA  =  INPUT_YES;  // Show Volume Move MA
input ENUM_INPUT_YES_NO InpShowWMA  =  INPUT_YES;  // Show Weighted Volume Move MA
//--- indicator buffers
double         BufferVOMOMA[];
double         BufferWEVOMO[];
double         BufferDiff[];
double         BufferVol[];
double         BufferDiffMA[];
double         BufferVolMA[];
//--- global variables
int            period_ind;
double         lsum;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ind=int(InpPeriod<2 ? 2 : InpPeriod);
   lsum=(period_ind+1.0)*period_ind/2.0;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferVOMOMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferWEVOMO,INDICATOR_DATA);
   SetIndexBuffer(2,BufferDiff,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferVol,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferDiffMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferVolMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"WVolume Move-Adjusted MA ("+(string)period_ind+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferVOMOMA,true);
   ArraySetAsSeries(BufferWEVOMO,true);
   ArraySetAsSeries(BufferDiff,true);
   ArraySetAsSeries(BufferVol,true);
   ArraySetAsSeries(BufferDiffMA,true);
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
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_ind-2;
      ArrayInitialize(BufferVOMOMA,EMPTY_VALUE);
      ArrayInitialize(BufferWEVOMO,EMPTY_VALUE);
      ArrayInitialize(BufferDiff,0);
      ArrayInitialize(BufferVol,0);
      ArrayInitialize(BufferDiffMA,0);
      ArrayInitialize(BufferVolMA,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferDiff[i]=fabs(close[i]-close[i+1]);
      BufferVol[i]=(double)tick_volume[i];
     }
   SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferDiff,BufferDiffMA);
   SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferVol,BufferVolMA);
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double DifferenceSum=BufferDiffMA[i]*period_ind;
      double VolumeSum=BufferVolMA[i]*period_ind;
      if(DifferenceSum!=0 && VolumeSum!=0)
        {
         double VOMA=0;
         double MOMA=0;
         double WMA=0;
         for(int j=1; j<=period_ind; j++)
           {
            MOMA+=close[i+period_ind-j]*BufferDiff[i+period_ind-j]/DifferenceSum;
            VOMA+=close[i+period_ind-j]*BufferVol[i+period_ind-j]/VolumeSum;
            WMA+=close[i+period_ind-j]*j;
           }
         WMA=WMA/lsum;

         if(InpShowVMA)
            BufferVOMOMA[i]=(MOMA+VOMA)/2.0;
         if(InpShowWMA)
            BufferWEVOMO[i]=(MOMA+VOMA+WMA)/3.0;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
