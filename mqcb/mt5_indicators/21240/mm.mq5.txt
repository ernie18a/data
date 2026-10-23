//+------------------------------------------------------------------+
//|                                                           MM.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Market Mode oscillator"
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   3
//--- plot Mode
#property indicator_label1  "Mode"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Peak
#property indicator_label2  "Peak"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Valley
#property indicator_label3  "Valley"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint     InpPeriod   =  20;      // Period
input double   InpDelta    =  0.1;     // Delta
input double   InpFract    =  0.25;    // Fraction
//--- indicator buffers
double         BufferMode[];
double         BufferPeak[];
double         BufferValley[];
double         BufferRAW[];
double         BufferRawPeak[];
double         BufferRawValley[];
double         BufferAvgRAW[];
double         BufferAvgRawPeak[];
double         BufferAvgRawValley[];
//--- global variables
int            period_ind;
int            period_2;
int            weight_sum;
double         delta;
double         beta;
double         gamma;
double         alpha;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ind=int(InpPeriod<1 ? 1 : InpPeriod);
   period_2=2*period_ind+5;
   delta=(InpDelta>0 && InpDelta<0.002 ? 0.002 : InpDelta<0 && InpDelta>-0.002 ? 0.002 : InpDelta);
   beta=cos(2.0*M_PI/(double)period_ind);
   gamma=1.0/cos(4.0*M_PI*delta/(double)period_ind);
   alpha=gamma-sqrt(gamma*gamma-1.0);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMode,INDICATOR_DATA);
   SetIndexBuffer(1,BufferPeak,INDICATOR_DATA);
   SetIndexBuffer(2,BufferValley,INDICATOR_DATA);
   SetIndexBuffer(3,BufferRAW,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferAvgRAW,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferRawPeak,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferAvgRawPeak,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferRawValley,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferAvgRawValley,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Market Mode ("+(string)period_ind+","+DoubleToString(delta,2)+","+DoubleToString(InpFract,2)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMode,true);
   ArraySetAsSeries(BufferPeak,true);
   ArraySetAsSeries(BufferValley,true);
   ArraySetAsSeries(BufferRAW,true);
   ArraySetAsSeries(BufferAvgRAW,true);
   ArraySetAsSeries(BufferRawPeak,true);
   ArraySetAsSeries(BufferAvgRawPeak,true);
   ArraySetAsSeries(BufferRawValley,true);
   ArraySetAsSeries(BufferAvgRawValley,true);
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
   if(rates_total<4 || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-3;
      ArrayInitialize(BufferMode,EMPTY_VALUE);
      ArrayInitialize(BufferPeak,EMPTY_VALUE);
      ArrayInitialize(BufferValley,EMPTY_VALUE);
      ArrayInitialize(BufferRAW,0);
      ArrayInitialize(BufferAvgRAW,0);
      ArrayInitialize(BufferRawPeak,0);
      ArrayInitialize(BufferAvgRawPeak,0);
      ArrayInitialize(BufferRawValley,0);
      ArrayInitialize(BufferAvgRawValley,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferRAW[i]=0.25*(1.0-alpha)*(high[i]+low[i]-high[i+2]-low[i+2])+beta*(1.0+alpha)*BufferRAW[i+1]-alpha*BufferRAW[i+2];
      BufferRawPeak[i]=(BufferRAW[i+1]>BufferRAW[i] && BufferRAW[i+1]>BufferRAW[i+2] ? BufferRAW[i+1] : BufferRawPeak[i+1]);
      BufferRawValley[i]=(BufferRAW[i+1]<BufferRAW[i] && BufferRAW[i+1]<BufferRAW[i+2] ? BufferRAW[i+1] : BufferRawValley[i+1]);
     }
   if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_2,BufferRAW,BufferAvgRAW)==0)
      return 0;
   if(SimpleMAOnBuffer(rates_total,prev_calculated,0,50,BufferRawPeak,BufferAvgRawPeak)==0)
      return 0;
   if(SimpleMAOnBuffer(rates_total,prev_calculated,0,50,BufferRawValley,BufferAvgRawValley)==0)
      return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferMode[i]=BufferAvgRAW[i]/Point();
      BufferPeak[i]=InpFract*BufferAvgRawPeak[i]/Point();
      BufferValley[i]=InpFract*BufferAvgRawValley[i]/Point();
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
