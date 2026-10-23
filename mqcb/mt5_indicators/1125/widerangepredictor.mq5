//+------------------------------------------------------------------+
//|                                           WideRangePredictor.mq5 |
//|                                            Copyright 2012, Rone. |
//|                                            rone.sergey@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Rone."
#property link      "rone.sergey@gmail.com"
#property version   "1.00"
#property description "Indicator used to predict the bars with extended range "
#property description "or for the strong directions of trend"
//---
#include <MovingAverages.mqh>
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   4
//--- plot Range
#property indicator_label1  "Range"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrDarkBlue, clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3
//--- plot Body
#property indicator_label2  "Body"
#property indicator_type2   DRAW_COLOR_HISTOGRAM
#property indicator_color2  clrGreen, clrChartreuse
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot RangeMa
#property indicator_label3  "RangeMa"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBrown
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- plot BodyMa
#property indicator_label4  "BodyMa"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrDeepPink
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2
//---
#property indicator_minimum 0
//--- input parameters
input int      InpMaPeriod=10;
//--- indicator buffers
double         RangeBuffer[];
double         RangeColors[];
double         BodyBuffer[];
double         BodyColors[];
double         RangeMaBuffer[];
double         BodyMaBuffer[];
//--- global variables
int            minRequiredBars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//---
   minRequiredBars = InpMaPeriod;
//--- indicator buffers mapping
   SetIndexBuffer(0,RangeBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,RangeColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BodyBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,BodyColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,RangeMaBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,BodyMaBuffer,INDICATOR_DATA);
//---
   for ( int i = 0; i <= 3; i++ ) {
      PlotIndexSetInteger(i, PLOT_DRAW_BEGIN, 0);
      PlotIndexSetInteger(i, PLOT_SHIFT, 0);
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   }
   for ( int i = 4; i <= 5; i++ ) {
      PlotIndexSetInteger(i, PLOT_DRAW_BEGIN, minRequiredBars);
      PlotIndexSetInteger(i, PLOT_SHIFT, 0);
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   }
//---
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
//---
   IndicatorSetString(INDICATOR_SHORTNAME, "BreakoutPredictor ("+(string)InpMaPeriod+")");
//---
   return(0);
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
//---
   int startBar;
//---
   if ( rates_total < minRequiredBars ) {
      Print("Not enough bars for the calculation.");
      return(0);
   }
//---
   if ( prev_calculated > rates_total || prev_calculated <= 0 ) {
      startBar = 0;
   } else {
      startBar = prev_calculated - 1;
   }
//--- 
   for ( int bar = startBar; bar < rates_total && !IsStopped(); bar++ ) {
      RangeBuffer[bar] = high[bar] - low[bar];
      BodyBuffer[bar] = MathAbs(close[bar]-open[bar]);
   }
//---
   SimpleMAOnBuffer(rates_total, prev_calculated, InpMaPeriod, InpMaPeriod, RangeBuffer, RangeMaBuffer);
   SimpleMAOnBuffer(rates_total, prev_calculated, InpMaPeriod, InpMaPeriod, BodyBuffer, BodyMaBuffer);
//---
   for ( int bar = startBar; bar < rates_total && !IsStopped(); bar++ ) {
      if ( RangeBuffer[bar] > RangeMaBuffer[bar] ) {
         RangeColors[bar] = 0;
      } else {
         RangeColors[bar] = 1;
      }
      //---
      if ( BodyBuffer[bar] > BodyMaBuffer[bar] ) {
         BodyColors[bar] = 0;
      } else {
         BodyColors[bar] = 1;
      }
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
