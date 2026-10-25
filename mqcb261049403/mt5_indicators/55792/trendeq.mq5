//+------------------------------------------------------------------+
//|                                     TrendEquilibriumIndicator.mq5|
//|                                                                  |
//|                   Copyright 2025, Simon Draxler                  |
//|                           drxtrading.com                         |
//+------------------------------------------------------------------+

#property copyright "Copyright 2025, Simon Draxler"
#property link      "drxtrading.com"
#property version   "2.00"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3

// Indicator properties
#property indicator_label1  "TrendEquilibriumIndicator"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "Overbought"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_DOT
#property indicator_width2  1

#property indicator_label3  "Oversold"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_DOT
#property indicator_width3  1

// Input parameters
input int    momentum_period  = 14;       // Number of candles to calculate momentum
input int    volatility_period = 14;      // Number of candles to calculate volatility
input double scaling_factor    = 100000;  // Adjusts the indicator's readability
input double overbought_level  = 100.0;   // Threshold above which market is overbought
input double oversold_level    = -100.0;  // Threshold below which market is oversold

// Buffers for indicator values
double trendEQ_buffer[];         // Stores calculated TrendEQ values
double overbought_buffer[];      // Stores overbought level
double oversold_buffer[];        // Stores oversold level

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
// Assign buffers to indicator plots
   SetIndexBuffer(0, trendEQ_buffer, INDICATOR_DATA); // Main TrendEQ line
   SetIndexBuffer(1, overbought_buffer, INDICATOR_DATA); // Overbought level
   SetIndexBuffer(2, oversold_buffer, INDICATOR_DATA); // Oversold level
// Set short name for the indicator
   string shortName = "TrendEQ(" + IntegerToString(momentum_period) + "," + IntegerToString(volatility_period) + ")";
   IndicatorSetString(INDICATOR_SHORTNAME, shortName);
// Configure the number of decimal places to display
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
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
// Ensure that there are enough data points for calculation
   int required_bars = MathMax(momentum_period, volatility_period) + 1;
   if(rates_total < required_bars)
      return(0);
// Determine the starting index for calculation
   int start = prev_calculated > 0 ? prev_calculated - 1 : required_bars;
// Loop through the available data
   for(int i = start; i < rates_total; i++)
     {
      // Skip calculation if not enough data for momentum
      if(i < momentum_period)
        {
         trendEQ_buffer[i] = 0.0; // Default value
         overbought_buffer[i] = overbought_level; // Set overbought level
         oversold_buffer[i] = oversold_level; // Set oversold level
         continue;
        }
      // Calculate momentum: Difference between the current close and close 'momentum_period' bars ago
      double momentum = close[i] - close[i - momentum_period];
      // Calculate volatility: Moving average of close prices over 'volatility_period'
      double volatility = 0.0;
      for(int j = i - volatility_period + 1; j <= i; j++)
        {
         volatility += close[j];
        }
      volatility /= volatility_period;
      // Avoid division by zero
      if(volatility > 0)
        {
         // Calculate and scale the TEI value
         trendEQ_buffer[i] = (momentum / (volatility * MathSqrt(momentum_period))) * scaling_factor;
        }
      else
        {
         trendEQ_buffer[i] = 0.0; // Fallback if volatility is zero
        }
      // Set overbought and oversold levels
      overbought_buffer[i] = overbought_level;
      oversold_buffer[i] = oversold_level;
     }
   return(rates_total); // Return the number of calculated bars
  }
//+------------------------------------------------------------------+
