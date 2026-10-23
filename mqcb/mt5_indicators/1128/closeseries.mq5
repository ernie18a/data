//+------------------------------------------------------------------+
//|                                                  CloseSeries.mq5 |
//|                                            Copyright 2012, Rone. |
//|                                            rone.sergey@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Rone."
#property link      "rone.sergey@gmail.com"
#property version   "1.00"
#property description "The indicator shows the series of internal, external and unidirectional closures."
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3
//--- plot InClose
#property indicator_label1  "In Close"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDimGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot OutClose
#property indicator_label2  "Out Close"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlueViolet
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot DirectClose
#property indicator_label3  "Direct Close"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDodgerBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- indicator levels
#property indicator_level1 0
#property indicator_level2 3
#property indicator_level3 -3
#property indicator_levelcolor clrGray
//--- indicator buffers
double         InCloseBuffer[];
double         OutCloseBuffer[];
double         DirectCloseBuffer[];
//--- global variables
int            minRequiredBars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//---
   minRequiredBars = 1;
//--- indicator buffers mapping
   SetIndexBuffer(0, InCloseBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, OutCloseBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, DirectCloseBuffer, INDICATOR_DATA);
//---
   for ( int i = 0; i < 3; i++ ) {
      PlotIndexSetInteger(i, PLOT_DRAW_BEGIN, minRequiredBars);
      PlotIndexSetInteger(i, PLOT_SHIFT, 0);
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   }
//---
   IndicatorSetInteger(INDICATOR_DIGITS, 0);
//---
   IndicatorSetString(INDICATOR_SHORTNAME, "Close Series");
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
      startBar = minRequiredBars;
      for ( int bar = 0; bar < minRequiredBars; bar++ ) {
         InCloseBuffer[bar] = 0.0;
         OutCloseBuffer[bar] = 0.0;
         DirectCloseBuffer[bar] = 0.0;
      }
   } else {
      startBar = prev_calculated - 1;
   }
//---
   for ( int bar = startBar; bar < rates_total && !IsStopped(); bar++ ) {
      int prevBar = bar - 1;
      //---
      if ( close[bar] <= high[prevBar] && close[bar] >= low[prevBar] ) {
         if ( InCloseBuffer[prevBar] > 0 ) {
            InCloseBuffer[bar] = InCloseBuffer[prevBar] + 1;
         } else {
            InCloseBuffer[bar] = 1;
         }
      } else {
         InCloseBuffer[bar] = 0;
      }
      //---
      if ( close[bar] > high[prevBar] ) {
         if ( OutCloseBuffer[prevBar] > 0 ) {
            OutCloseBuffer[bar] = OutCloseBuffer[prevBar] + 1;
         } else {
            OutCloseBuffer[bar] = 1;
         }
      } else if (close[bar] < low[prevBar] ) {
         if ( OutCloseBuffer[prevBar] < 0 ) {
            OutCloseBuffer[bar] = OutCloseBuffer[prevBar] - 1;
         } else {
            OutCloseBuffer[bar] = -1;
         }
      } else {
         OutCloseBuffer[bar] = 0;
      }
      //---
      if ( close[bar] > open[bar] ) {
         if ( DirectCloseBuffer[prevBar] > 0 ) {
            DirectCloseBuffer[bar] = DirectCloseBuffer[prevBar] + 1;
         } else {
            DirectCloseBuffer[bar] = 1;
         }
      } else if ( close[bar] < open[bar] ) {
         if ( DirectCloseBuffer[prevBar] < 0 ) {
            DirectCloseBuffer[bar] = DirectCloseBuffer[prevBar] - 1;
         } else {
            DirectCloseBuffer[bar] = -1;
         }
      } else {
         DirectCloseBuffer[bar] = 0;
      }
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
