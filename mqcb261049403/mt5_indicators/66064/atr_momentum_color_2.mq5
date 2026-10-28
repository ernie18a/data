#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2

//--- Plot 1: Momentum line (colored)
#property indicator_label1  "Momentum"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrLime, clrRed
#property indicator_width1  2

//--- Plot 2: Threshold lines
#property indicator_label2  "Threshold_Mid"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_DOT
#property indicator_width2  1

//--- Inputs
input int ATR_Period        = 14;
input int Momentum_Period   = 14;
input ENUM_APPLIED_PRICE MomentumPrice = PRICE_CLOSE;
input double ThresholdMultiplier = 1.5;  // Sensitivity control

//--- Buffers
double SignalBuffer[];   // Momentum values
double ColorBuffer[];    // Color index
double ThresholdBuffer[]; // Threshold middle line

//--- Handles
int atr_handle;
int mom_handle;

//+------------------------------------------------------------------+
int OnInit()
{
   // Set indicator short name
   string shortName = "ATR_Mom_Cross(" + (string)ATR_Period + "," + (string)Momentum_Period + ")";
   IndicatorSetString(INDICATOR_SHORTNAME, shortName);
   
   // Set buffers
   SetIndexBuffer(0, SignalBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, ColorBuffer, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, ThresholdBuffer, INDICATOR_DATA);
   
   // Set empty values for proper display
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   
   // Create indicator handles
   atr_handle = iATR(_Symbol, _Period, ATR_Period);
   if(atr_handle == INVALID_HANDLE)
   {
      Print("Error creating ATR handle: ", GetLastError());
      return INIT_FAILED;
   }

   mom_handle = iMomentum(_Symbol, _Period, Momentum_Period, MomentumPrice);
   if(mom_handle == INVALID_HANDLE)
   {
      Print("Error creating Momentum handle: ", GetLastError());
      return INIT_FAILED;
   }

   return INIT_SUCCEEDED;
}

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
   // Minimum bars check
   if(rates_total < MathMax(ATR_Period, Momentum_Period) + 2)
      return 0;

   // Local buffers for indicator values
   double atr[], mom[];
   
   // Copy ATR values
   if(CopyBuffer(atr_handle, 0, 0, rates_total, atr) != rates_total)
   {
      Print("Failed to copy ATR buffer, error: ", GetLastError());
      return 0;
   }
   
   // Copy Momentum values
   if(CopyBuffer(mom_handle, 0, 0, rates_total, mom) != rates_total)
   {
      Print("Failed to copy Momentum buffer, error: ", GetLastError());
      return 0;
   }

   // Calculate starting position
   int start = prev_calculated > 0 ? prev_calculated - 1 : 0;
   
   // Main calculation loop
   for(int i = start; i < rates_total; i++)
   {
      // Calculate threshold values around the 100 baseline
      double upperThreshold = 100.0 + ThresholdMultiplier * atr[i];
      double lowerThreshold = 100.0 - ThresholdMultiplier * atr[i];
      
      // Store threshold midline for plotting
      ThresholdBuffer[i] = 100.0; // Midline at 100 baseline
      
      // Plot Momentum value
      SignalBuffer[i] = mom[i];
      
      // PROPER COLOR LOGIC: Compare to 100 baseline with ATR-based thresholds
      if(mom[i] > upperThreshold)
         ColorBuffer[i] = 0;  // Lime - Strong bullish momentum
      else if(mom[i] < lowerThreshold)
         ColorBuffer[i] = 1;  // Red - Strong bearish momentum
      else
         ColorBuffer[i] = EMPTY_VALUE;  // No color for neutral areas
   }

   return rates_total;
}