//+------------------------------------------------------------------+
//|                                             Balance Of Power.mq5 |
//|                                                  Henrique Araújo |
//+------------------------------------------------------------------+
#include <MovingAverages.mqh>

#property copyright "Henrique Araújo"
#property link      ""
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot BOP
#property indicator_label1  "BOP"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrRed,clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- indicator buffers
double         BOPBuffer[];
double         BOPColors[];
double         BOPCalcBuffer[];

//+------------------------------------------------------------------+
//INPUTS
//+------------------------------------------------------------------+
input uint     iPeriod = 14;     //Smoothing
input double   iHighZone = 0;    //Highest Zone
input double   iLowZone = 0;    //Lowest Zone


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BOPBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,BOPColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BOPCalcBuffer,INDICATOR_CALCULATIONS);

   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   IndicatorSetString(INDICATOR_SHORTNAME,"Balance of Power ("+(string)iPeriod+")");

// Zones Lines
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,iHighZone);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,iLowZone);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,0);

   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DOT);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,0,1);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DOT);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,1,1);

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
   int start = 0;
   if(prev_calculated > 1)
      start = prev_calculated - 1;
   else
      start = 1;

   for(int i=start; i<rates_total && !IsStopped(); i++)
     {
      if(high[i]-low[i] > 0.0)
         BOPCalcBuffer[i] = (close[i]-open[i]) / (high[i]-low[i]);
      else
         BOPCalcBuffer[i] = 0.0;
     }

   SimpleMAOnBuffer(rates_total, prev_calculated, 0, iPeriod, BOPCalcBuffer, BOPBuffer);

// --- define as cores
   for(int i=start; i<rates_total && !IsStopped(); i++)
     {
      BOPColors[i] = 0;
      if(BOPBuffer[i] >= 0)
        {
         BOPColors[i] = 1;
        }
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
