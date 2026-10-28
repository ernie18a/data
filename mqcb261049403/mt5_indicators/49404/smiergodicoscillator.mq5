//+------------------------------------------------------------------+
//|                                         SMIErgodicOscillator.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   1

#include <MovingAverages.mqh>

//--- plot SMIO
#property indicator_label1  "SMIO"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3

//--- input parameters
input uint     InpPeriodLong     =  20;   // Long Length
input uint     InpPeriodShort    =  5;    // Short Length
input uint     InpPeriodSignal   =  5;    // Signal Line Length

//--- indicator buffers
double         ExtBufferSMIO[];
double         ExtBufferSig[];
double         ExtBufferTSI[];
double         ExtBufferUDM[];
double         ExtBufferADM[];
double         ExtBufferUDM1[];
double         ExtBufferUDM2[];
double         ExtBufferADM1[];
double         ExtBufferADM2[];

//--- global variables
int      ExtPeriodLong;
int      ExtPeriodShort;
int      ExtPeriodSignal;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtBufferSMIO,INDICATOR_DATA);
   SetIndexBuffer(1,ExtBufferSig,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,ExtBufferTSI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,ExtBufferUDM,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,ExtBufferADM,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,ExtBufferUDM1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,ExtBufferUDM2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,ExtBufferADM1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,ExtBufferADM2,INDICATOR_CALCULATIONS);
   
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(ExtBufferSMIO,true);
   ArraySetAsSeries(ExtBufferSig,true);
   ArraySetAsSeries(ExtBufferTSI,true);
   ArraySetAsSeries(ExtBufferUDM,true);
   ArraySetAsSeries(ExtBufferADM,true);
   ArraySetAsSeries(ExtBufferUDM1,true);
   ArraySetAsSeries(ExtBufferUDM2,true);
   ArraySetAsSeries(ExtBufferADM1,true);
   ArraySetAsSeries(ExtBufferADM2,true);
   
//--- setting the periods, short name and levels for the indicator
   ExtPeriodLong  =int(InpPeriodLong  <2 ? 2 : InpPeriodLong);
   ExtPeriodShort =int(InpPeriodShort <2 ? 2 : InpPeriodShort);
   ExtPeriodSignal=int(InpPeriodSignal<2 ? 2 : InpPeriodSignal);
   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("SMIO (%lu, %lu, %lu)",ExtPeriodLong,ExtPeriodShort,ExtPeriodSignal));
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0, 0.0);

//--- success
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
//--- checking for the minimum number of bars for calculation
   int max=fmax(ExtPeriodLong,fmax(ExtPeriodShort,ExtPeriodSignal));
   if(rates_total<max)
      return 0;
      
//--- setting predefined indicator arrays as timeseries
   ArraySetAsSeries(close,true);
   
//--- checking and calculating the number of bars to be calculated
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(ExtBufferSMIO,EMPTY_VALUE);
      ArrayInitialize(ExtBufferSig,0);
      ArrayInitialize(ExtBufferTSI,0);
      ArrayInitialize(ExtBufferUDM,0);
      ArrayInitialize(ExtBufferUDM1,0);
      ArrayInitialize(ExtBufferUDM2,0);
      ArrayInitialize(ExtBufferADM,0);
      ArrayInitialize(ExtBufferADM1,0);
      ArrayInitialize(ExtBufferADM2,0);
     }

//--- calculate RAW data (True Strength Index)
   for(int i=limit; i>=0; i--)
     {
      ExtBufferUDM[i]=close[i]-close[i+1];
      ExtBufferADM[i]=fabs(ExtBufferUDM[i]);
     }
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,ExtPeriodShort,ExtBufferUDM,ExtBufferUDM1)==0)
      return 0;
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,ExtPeriodShort,ExtBufferADM,ExtBufferADM1)==0)
      return 0;
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,ExtPeriodShort,ExtPeriodLong,ExtBufferUDM1,ExtBufferUDM2)==0)
      return 0;
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,ExtPeriodShort,ExtPeriodLong,ExtBufferADM1,ExtBufferADM2)==0)
      return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
      ExtBufferTSI[i]=(ExtBufferADM2[i]!=0 ? 100.0 * ExtBufferUDM2[i] / ExtBufferADM2[i] : 0);
//--- signal line
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,ExtPeriodSignal,ExtBufferTSI,ExtBufferSig)==0)
      return 0;
   
//--- calculation SMI Ergodic Oscillator
   for(int i=limit; i>=0 && !IsStopped(); i--)
      ExtBufferSMIO[i]=ExtBufferTSI[i] - ExtBufferSig[i];

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
