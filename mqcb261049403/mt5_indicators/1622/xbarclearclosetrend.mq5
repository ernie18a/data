//+------------------------------------------------------------------+
//|                                          XBarClearCloseTrend.mq5 |
//|                                             Copyright 2013, Rone |
//|                                            rone.sergey@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Rone"
#property link      "rone.sergey@gmail.com"
#property version   "1.00"
#property description "Alternative trend indicator. Trend reversal appears in the case, "
#property description "if bar closing is higher than high (lower than low) of other bars pattern."
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   2
//--- plot Value
#property indicator_label1  "Value"
#property indicator_type1   DRAW_NONE
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Bar
#property indicator_label2  "XBCC Open;XBCC High;XBCC Low;XBCC Close"
#property indicator_type2   DRAW_COLOR_CANDLES
#property indicator_color2  clrRed, clrBlue, clrTomato, clrOrange, clrRoyalBlue, clrDeepSkyBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input int      InpBarsInPattern = 5;   // Bars In Pattern
//--- indicator buffers
double         ValueBuffer[];
double         OpenXbccBuffer[];
double         HighXbccBuffer[];
double         LowXbccBuffer[];
double         CloseXbccBuffer[];
double         XbccColors[];
//---
int            bars_in_pattern;
int            min_required_bars;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsXBarUpClearClose(int current, int bars, const double &high[], 
                        const double &low[], const double &close[]) {
//---
   for ( int bar = current - bars + 1; bar < current; bar++ ) {
      if ( high[bar] >= close[current] ) {
         return(false);
      }
   }
//---
   return(true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsXBarDownClearClose(int current, int bars, const double &high[], 
                          const double &low[], const double &close[]) {
//---
   for ( int bar = current - bars + 1; bar < current; bar++ ) {
      if ( low[bar] <= close[current] ) {
         return(false);
      }
   }
//---
   return(true);
}
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
   if ( InpBarsInPattern < 2 ) {
      bars_in_pattern = 5;
      printf("Incorrected input value for InpBarsInPattern = %d. Indicator will use value %d.",
             InpBarsInPattern, bars_in_pattern);
   } else {
      bars_in_pattern = InpBarsInPattern;
   }
   min_required_bars = bars_in_pattern + 1;
//--- indicator buffers mapping
   SetIndexBuffer(0, ValueBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, OpenXbccBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, HighXbccBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, LowXbccBuffer, INDICATOR_DATA);
   SetIndexBuffer(4, CloseXbccBuffer, INDICATOR_DATA);
   SetIndexBuffer(5, XbccColors, INDICATOR_COLOR_INDEX);
//---
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, min_required_bars);
   PlotIndexSetInteger(1, PLOT_SHIFT, 0);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);
//---
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   IndicatorSetString(INDICATOR_SHORTNAME, "XBarClearCloseTrend ("+(string)bars_in_pattern+")");
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
   if ( rates_total < min_required_bars ) {
      Print("Not enough bars for calculation.");
      return(0);
   }
//---
   int start_bar;
   bool up_trend;
   
   static bool _up_trend;
   
   if ( prev_calculated > rates_total || prev_calculated <= 0 ) {
      start_bar = min_required_bars;
      if ( close[start_bar] >= close[start_bar-1] ) {
         _up_trend = true;   
      } else {
         _up_trend = false;
      }
   } else {
      start_bar = prev_calculated - 1;
   }
//---
   up_trend = _up_trend;
//---
   for ( int bar = start_bar; bar < rates_total; bar++ ) {
      int prev_bar = bar - 1;
      
      OpenXbccBuffer[bar] = open[bar];
      HighXbccBuffer[bar] = high[bar];
      LowXbccBuffer[bar] = low[bar];
      CloseXbccBuffer[bar] = close[bar];
      
      if ( up_trend ) {
         if ( IsXBarUpClearClose(bar, bars_in_pattern, high, low, close) ) {
            ValueBuffer[bar] = ValueBuffer[prev_bar] + 1.0;
            XbccColors[bar] = 1.0;
         } else if ( IsXBarDownClearClose(bar, bars_in_pattern, high, low, close) ) {
            ValueBuffer[bar] = -1.0;
            XbccColors[bar] = 0.0;
            up_trend = false;
         } else {
            ValueBuffer[bar] = ValueBuffer[prev_bar];
            if ( close[bar] >= close[prev_bar] ) {
               XbccColors[bar] = 4.0;
            } else {
               XbccColors[bar] = 5.0;
            }
         }
      } else {
         if ( IsXBarDownClearClose(bar, bars_in_pattern, high, low, close) ) {
            ValueBuffer[bar] = ValueBuffer[prev_bar] - 1.0;
            XbccColors[bar] = 0.0;
         } else if ( IsXBarUpClearClose(bar, bars_in_pattern, high, low, close) ) {
            ValueBuffer[bar] = 1.0;
            XbccColors[bar] = 1.0;
            up_trend = true;
         } else {
            ValueBuffer[bar] = ValueBuffer[prev_bar];
            if ( close[bar] <= close[prev_bar] ) {
               XbccColors[bar] = 2.0;
            } else {
               XbccColors[bar] = 3.0;
            }
         }
      }
      
      if ( bar < rates_total - 1 ) {
         _up_trend = up_trend;
      }
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
