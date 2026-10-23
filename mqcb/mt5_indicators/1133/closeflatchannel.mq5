//+------------------------------------------------------------------+
//|                                             CloseFlatChannel.mq5 |
//|                                            Copyright 2012, Rone. |
//|                                            rone.sergey@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Rone."
#property link      "rone.sergey@gmail.com"
#property version   "1.00"
#property description "Indicator of the flat channel. If the closing of the required number of bars are located"
#property description "within the maximum width - draw the channel."
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot Upper
#property indicator_label1  "Upper"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Lower
#property indicator_label2  "Lower"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrDeepPink
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input int      InpMaxRange = 100;     // Max range between the closing
input int      InpBarsQuantity = 4;   // Number of bars
input int      InpIndent = 50;        // Indent before the channel boundaries
input int      InpShift = 1;          // horizontal shiftи
input bool     InpTakePrev = true;    // consider the previous boundaries
//--- indicator buffers
double         UpperBuffer[];
double         LowerBuffer[];
//--- global variables
int            minRequiredBars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//---
   minRequiredBars = InpBarsQuantity;
//--- indicator buffers mapping
   SetIndexBuffer(0,UpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,LowerBuffer,INDICATOR_DATA);
//---   
   for ( int i = 0; i < 2; i++ ) {
      PlotIndexSetInteger(i, PLOT_DRAW_BEGIN, minRequiredBars);
      PlotIndexSetInteger(i, PLOT_SHIFT, InpShift);
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   }
//---
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
//---
   string shortname = "CloseFlatChannel (" + (string)InpMaxRange + ", " + (string)InpBarsQuantity + ", " + 
            (string)InpIndent + ")";
   IndicatorSetString(INDICATOR_SHORTNAME, shortname);
//---
   return(0);
}
//+------------------------------------------------------------------+
//| Get Array Max Value function                                     |
//+------------------------------------------------------------------+
double getArrayMax(const double &array[], int curIndex, int quantity) {
//---
   int first = curIndex - quantity + 1;
   double max = array[first];
//---
   for ( int bar = first + 1; bar <= curIndex; bar++ ) {
      if ( array[bar] > max ) {
         max = array[bar];
      }
   }
//---
   return(max);
}
//+------------------------------------------------------------------+
//| Get Array Min Value function                                     |
//+------------------------------------------------------------------+
double getArrayMin(const double &array[], int curIndex, int quantity) {
//---
   int first = curIndex - quantity + 1;
   double min = array[first];
//---
   for ( int bar = first + 1; bar <= curIndex; bar++ ) {
      if ( array[bar] < min ) {
         min = array[bar];
      }
   }
//---
   return(min);
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
   if ( rates_total < minRequiredBars) {
      Print("Not enough bars for the calculation.");
      return(0);
   }
//---
   if ( prev_calculated > rates_total || prev_calculated <= 0 ) {
      startBar = minRequiredBars;
   } else {
      startBar = prev_calculated - 1;
   }
//---
   for ( int bar = startBar; bar < rates_total && !IsStopped(); bar++ ) {
      double maxClose = getArrayMax(close, bar, InpBarsQuantity);
      double minClose = getArrayMin(close, bar, InpBarsQuantity);
      
      if ( maxClose - minClose <= InpMaxRange * _Point ) {
         int prevBar = bar - 1;
         
         UpperBuffer[bar] = getArrayMax(high, bar, InpBarsQuantity) + (spread[bar] + InpIndent) * _Point;
         LowerBuffer[bar] = getArrayMin(low, bar, InpBarsQuantity) - InpIndent * _Point;
         if ( InpTakePrev ) {
            if ( UpperBuffer[prevBar] != 0.0 || LowerBuffer[prevBar] != 0.0 ) {
               UpperBuffer[bar] = MathMax(UpperBuffer[prevBar], high[bar]+(spread[bar]+InpIndent)*_Point);
               LowerBuffer[bar] = MathMin(LowerBuffer[prevBar], low[bar]-InpIndent*_Point);
            }
         }
      } else {
         UpperBuffer[bar] = 0.0;
         LowerBuffer[bar] = 0.0;
      }
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
