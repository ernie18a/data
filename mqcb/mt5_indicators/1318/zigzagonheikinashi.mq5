//+------------------------------------------------------------------+
//|                                           ZigZagOnHeikinAshi.mq5 |
//|                                            Copyright 2012, Rone. |
//|                                            rone.sergey@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Rone."
#property link      "rone.sergey@gmail.com"
#property version   "1.00"
#property description "ZigZag on Heikin Ashi."
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   2
//--- plot ZigZag
#property indicator_label1  "ZigZag Lowest;ZigZag Highest"
#property indicator_type1   DRAW_COLOR_ZIGZAG
#property indicator_color1  clrDeepPink,clrSlateBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Heikin Ashi
#property indicator_label2  "Heikin Ashi Open;Heikin Ashi High;Heikin Ashi Low;Heikin Ashi Close"
#property indicator_type2   DRAW_COLOR_CANDLES
#property indicator_color2  clrTomato,clrDodgerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input int      InpHaPeriod = 1;           // Heikin Ashi period
input bool     InpShowHekinAshi = false;  // Show Heikin Ashi
//--- indicator buffers
double         HaOpenBuffer[];
double         HaHighBuffer[];
double         HaLowBuffer[];
double         HaCloseBuffer[];
double         HaColors[];
double         LowestBuffer[];
double         HighestBuffer[];
double         ZigZagColors[];
//---
int            minRequiredBars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//---
   minRequiredBars = InpHaPeriod;
//--- indicator buffers mapping
   SetIndexBuffer(0, LowestBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, HighestBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, ZigZagColors, INDICATOR_COLOR_INDEX);   
   SetIndexBuffer(3, HaOpenBuffer, INDICATOR_DATA);
   SetIndexBuffer(4, HaHighBuffer, INDICATOR_DATA);
   SetIndexBuffer(5, HaLowBuffer, INDICATOR_DATA);
   SetIndexBuffer(6, HaCloseBuffer, INDICATOR_DATA);
   SetIndexBuffer(7, HaColors, INDICATOR_COLOR_INDEX);
//---
   for ( int i = 0; i < 2; i++ ) {
      PlotIndexSetInteger(i, PLOT_DRAW_BEGIN, minRequiredBars);
      PlotIndexSetInteger(i, PLOT_SHIFT, 0);
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0.0);
   }
//---
   if ( !InpShowHekinAshi ) {
      PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);
   } else {
      PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_COLOR_CANDLES);
   }
//---
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
//---
   IndicatorSetString(INDICATOR_SHORTNAME, "ZigZag On Heikin Ashi ("+(string)InpHaPeriod+")");
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
   double haOpen, haHigh, haLow, haClose;
   
   int lastHighPos, lastLowPos;
   static int _lastHighPos, _lastLowPos;
   double highValue, lowValue;
   static double _highValue, _lowValue;
   bool up;
   static bool _up;
//---
   if ( rates_total < minRequiredBars ) {
      Print("Not enough data to calculate");
      return(0);
   }
//---
   if ( prev_calculated > rates_total || prev_calculated <= 0 ) {
      startBar = minRequiredBars;
      for ( int bar = 0; bar < startBar; bar++ ) {
         HaOpenBuffer[bar] = open[bar];
         HaHighBuffer[bar] = high[bar];
         HaLowBuffer[bar] = low[bar];
         HaCloseBuffer[bar] = close[bar];
      }
      if ( close[startBar-1] >= close[startBar-1] ) {
         _up = true;
         _highValue = high[startBar-1];
         _lowValue = low[startBar-1];
         _lastHighPos = _lastLowPos = startBar - 1;   
      }
   } else {
      startBar = prev_calculated - 1;
   }
//---
   up = _up;
   highValue = _highValue;
   lowValue = _lowValue;
   lastHighPos = _lastHighPos;
   lastLowPos = _lastLowPos;
//--- loop for heikin ashi
   for ( int bar = startBar; bar < rates_total && !IsStopped(); bar++ ) {
      //--- Heikin Ashi
      haOpen = (HaOpenBuffer[bar-InpHaPeriod] + HaCloseBuffer[bar-InpHaPeriod]) / 2;
      haClose = (open[bar] + high[bar] + low[bar] + close[bar]) / 4;
      haHigh = MathMax(high[bar], MathMax(haOpen, haClose));
      haLow = MathMin(low[bar], MathMin(haOpen, haClose));
      //---
      if ( InpHaPeriod > 1 ) {
         haOpen = (haClose > haOpen) ? MathMax(haOpen, HaOpenBuffer[bar-1]) : MathMin(haOpen, HaOpenBuffer[bar-1]);
      }
      //---
      HaOpenBuffer[bar] = haOpen;
      HaHighBuffer[bar] = haHigh;
      HaLowBuffer[bar] = haLow;
      HaCloseBuffer[bar] = haClose;
      //---
      if ( haClose > haOpen ) {
         HaColors[bar] = 1.0;
      } else {
         HaColors[bar] = 0.0;
      }
      
      //--- ZigZag On Heikin Ashi
      if ( rates_total != prev_calculated && bar == rates_total - 1 ) {
         _up = up;
         _highValue = highValue;
         _lowValue = lowValue;
         _lastHighPos = lastHighPos;
         _lastLowPos = lastLowPos;
      }
      //---
      if ( up ) {
         ZigZagColors[bar] = 1;
         if ( high[bar] > highValue ) {
            HighestBuffer[lastHighPos] = 0.0;
            HighestBuffer[bar] = highValue = high[bar];
            lastHighPos = bar;
            LowestBuffer[bar] = 0.0;
         } else if ( haClose <= haOpen ) {
            up = false;
            LowestBuffer[bar] = lowValue = low[bar];
            lastLowPos = bar;
            HighestBuffer[bar] = 0.0;
            ZigZagColors[bar] = 0;
         } else {
            HighestBuffer[bar] = 0.0;
            LowestBuffer[bar] = 0.0;
         }
      } else {
         ZigZagColors[bar] = 0;
         if ( low[bar] < lowValue ) {
            LowestBuffer[lastLowPos] = 0.0;
            LowestBuffer[bar] = lowValue = low[bar];
            lastLowPos = bar;
            HighestBuffer[bar] = 0.0;
         } else if ( haClose > haOpen ) {
            up = true;
            HighestBuffer[bar] = highValue = high[bar];
            lastHighPos = bar;
            LowestBuffer[bar] = 0.0;
            ZigZagColors[bar] = 1;
         } else {
            HighestBuffer[bar] = 0.0;
            LowestBuffer[bar] = 0.0;
         }
      }      
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
