//+------------------------------------------------------------------+
//|                                              InverseReaction.mq5 |
//|                                        Copyright 2013, Erdem Sen |
//|                          https://www.mql5.com/en/users/erdogenes |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Erdem Sen"
#property version   "2.0"
#property link      "https://www.mql5.com/en/users/erdogenes"
//---
#property description "This indicator is based on the idea of that an unusual impact in price changes will be" 
#property description "adjusted by an inverse reaction. It consists of two main buffers: One shows gap-free"
#property description "price changes and the other(s) shows the possible volatility limits."
#property description "The signal comes out when the price change buffer exceeds the possible volatility limits."
#property description "Then you can expect an inverse reaction."
//--- Indicator
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
//--- PriceChanges Plot
#property indicator_label1  "PriceChanges"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrBlueViolet
//--- UpperLevel Plot 
#property indicator_label2  "u_Level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
//--- LowerLevel Plot
#property indicator_label3  "l_Level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
//--- ZeroLevel
#property indicator_level1 0
#property indicator_levelcolor clrBlueViolet
//---inputs
input int      MaPeriod    = 3;     // Moving average period
input double   Coefficient = 1.618; // Confidence coefficient
input int      MinCriteria = 300;   // Signal Criteria (EA usage only)
input int      MaxCriteria = 2000;  // Signal Criteria (EA usage only)
//--- buffers
double   AbsolutePriceChangesBuffer[];
double   PriceChangesBuffer[];
double   u_CLevelBuffer[];
double   l_CLevelBuffer[];
double   EAsignal[];
//--- global variables
int      startpoint     = MaPeriod-1;
double   umincriteria   = MinCriteria*_Point;
double   lmincriteria   = -1*umincriteria;
double   umaxcriteria   = MaxCriteria*_Point;
double   lmaxcriteria   = -1*umaxcriteria;
//+------------------------------------------------------------------+
// CMoving_Average class description                                 |
//+------------------------------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- main buffers
   SetIndexBuffer(0,PriceChangesBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,u_CLevelBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,l_CLevelBuffer,INDICATOR_DATA);
//--- secondary buffer for calculation
   SetIndexBuffer(3,AbsolutePriceChangesBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,EAsignal,INDICATOR_CALCULATIONS);
//---
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,startpoint);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,startpoint);
//--- name of indicator
   string name="InverseReaction ("+IntegerToString(MaPeriod)+" , "+DoubleToString(Coefficient,3)+")";
   IndicatorSetString(INDICATOR_SHORTNAME,name);
//---
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of price maximums for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(rates_total<MaPeriod)
     {
      Print("Sorry!!, there is not enough bars. Download more historical data and retry");
      return(0);
     }
//---- declaration of local variables 
   int first,bar;
//---- calculation of the 'first' starting number for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=0; // starting index for calculation of all bars
     }
   else first=prev_calculated-1; // starting number for calculation of new bars

//--- Gap free price changes
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      PriceChangesBuffer[bar]=(close[bar]-open[bar]);
      AbsolutePriceChangesBuffer[bar]=fabs(PriceChangesBuffer[bar]);
     }
//--- Dynamic Confidence Levels (DCL)------------------------------------------------------------------------
//
// To determine DCLs, first, moving standard deviation (MStD) must be calculated. With the assumption of 
// "PERFECT NORMALITY CONDITIONS" in price changes, and using absolute values with "HALF NORMAL" 
// distribution method, MStD can be calculated by MA:
// Ex:---------------------------------------------------| 
// |    MStD = Sqrt[Pi]/Sqrt[2] * MA[Abs[Price Changes]] |
// |    GoldenRatio ~= z[%80] * Sqrt[Pi]/Sqrt[2]         |
// |    DCL[%80]~= GoldenRatio * MA[Abs[Price Changes]]  |
// |-----------------------------------------------------|
// With large numbers of MaPeriod, DCL aproximates to static ConfidenceLevel for normal distribution, 
// However the system is dynamic and memory is very short for such economic behavours, 
// so it set with a small number: 3 as default. (!!! plus, considering a possible HEAVY-TAIL problem, 
// small values of MaPeriod will relatively response better.) 
// ---------------------------------------------------------------------------------------------------------- 
//---- объявление переменных класса CMoving_Average из файла SmoothAlgorithms.mqh 
   static CMoving_Average SMA;

   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      u_CLevelBuffer[bar]=Coefficient*SMA.SMASeries(0,prev_calculated,rates_total,MaPeriod,AbsolutePriceChangesBuffer[bar],bar,false);
      l_CLevelBuffer[bar]=-1*u_CLevelBuffer[bar];
     }
   if(prev_calculated>rates_total || prev_calculated<=0) first+=MaPeriod+1;

//--- Signal buffer !!!FOR EXPERT ADVISOR!!!
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      if(PriceChangesBuffer[bar-1]>u_CLevelBuffer[bar-1]
         && PriceChangesBuffer[bar-1]>umincriteria
         && PriceChangesBuffer[bar-1]<umaxcriteria) EAsignal[bar]=1;
      else if(PriceChangesBuffer[bar-1]<l_CLevelBuffer[bar-1]
         && PriceChangesBuffer[bar-1]<lmincriteria
         && PriceChangesBuffer[bar-1]>lmaxcriteria) EAsignal[bar]=-1;
      else EAsignal[bar]=0.0;
     }
//---
   return(rates_total);
  }
//+------------------------------------------------------------------+
