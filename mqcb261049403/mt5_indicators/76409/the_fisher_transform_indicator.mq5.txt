//+------------------------------------------------------------------+
//|          The Fisher Transform Indicator.mq5 BY Ali Kazim & Jawad |
//+------------------------------------------------------------------+
#property copyright   "2026"
#property version     "2.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_minimum -4
#property indicator_maximum 4
#property indicator_level1  0.0
#property indicator_levelstyle STYLE_DOT

#property indicator_label1  "Fisher"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

input int InpLookbackPeriod = 10;  // Highest/Lowest Lookback Period

//--- Indicator output buffer used for drawing the oscillator line. There
//--- are deliberately no arrow buffers here — this indicator's only job
//--- is to output a clean, continuous value every bar. Deciding when a
//--- given value counts as a buy or sell signal (a threshold concept,
//--- the same way RSI's 70/30 levels work) belongs to whatever EA reads
//--- this indicator, not to the indicator itself.
double BufFisher[];

//--- Internal recursive state, registered as a calculation buffer so the
//--- terminal manages its size and bar-to-bar continuity automatically.
//--- kRawValue stores each bar's normalized value (Idea 1), needed by
//--- Idea 2's smoothing step, which blends the current bar's raw value
//--- with the previous bar's. BufFisher itself has a value on every bar
//--- with no gaps, so it doubles as its own recursive state for Idea 3 —
//--- no separate buffer is needed just to look up the previous Fisher
//--- value.
double kRawValue[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Connect indicator buffers with their corresponding plots
   SetIndexBuffer(0, BufFisher, INDICATOR_DATA);

//--- Register the recursive state as a calculation buffer
   SetIndexBuffer(1, kRawValue, INDICATOR_CALCULATIONS);

//--- Define an empty value so unused buffer points are not drawn
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   IndicatorSetString(INDICATOR_SHORTNAME,
                      "FisherTransform(" + IntegerToString(InpLookbackPeriod) + ")");

//--- Validate inputs before allowing the indicator to run
   if(InpLookbackPeriod < 2)
     {
      Print("InpLookbackPeriod must be at least 2");
      return INIT_PARAMETERS_INCORRECT;
     }

   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int      &spread[])
  {
//--- Check that enough bars exist for the lookback and recursive calculations
   if(rates_total < InpLookbackPeriod + 3)
      return 0;

//--- Use series indexing where index 0 represents the latest bar. Since
//--- kRawValue is a terminal-managed calculation buffer, no manual
//--- ArrayResize()/ArrayInitialize() is needed here — the terminal keeps
//--- its existing values correctly aligned as new bars appear.
   ArraySetAsSeries(high,  true);
   ArraySetAsSeries(low,   true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(BufFisher, true);
   ArraySetAsSeries(kRawValue, true);

//--- Determine the starting point for the calculation
   int start = rates_total - prev_calculated;

//--- Perform a full initialization on the first calculation
   if(prev_calculated <= 1)
     {
      ArrayInitialize(BufFisher, 0.0);
      ArrayInitialize(kRawValue, 0.0);

      //--- Seed the recursive state at the oldest bar the lookback allows
      int seed = rates_total - InpLookbackPeriod - 1;
      BufFisher[seed] = 0.0;
      kRawValue[seed] = 0.0;

      start = seed - 1;
     }
   else
     {
      //--- Recalculate the current and most recently closed bar on live ticks
      if(start < 1)
         start = 1;
     }

//--- Main loop: normalize price, smooth it, and apply the Fisher Transform
   for(int i = start; i >= 0; i--)
     {
      //--- Skip invalid oldest index
      if(i >= rates_total - InpLookbackPeriod)
         continue;

      //--- Idea 1: normalize price into a bounded range using the recent
      //--- highest high and lowest low
      double highestHigh = high[i];
      double lowestLow    = low[i];
      for(int j = 1; j < InpLookbackPeriod; j++)
        {
         if(high[i + j] > highestHigh)
            highestHigh = high[i + j];
         if(low[i + j] < lowestLow)
            lowestLow = low[i + j];
        }

      double range = highestHigh - lowestLow;
      double rawValue = (range > 0) ? 2.0 * ((close[i] - lowestLow) / range - 0.5) : 0.0;

      //--- Idea 2: smooth the raw value against the previous bar's raw
      //--- value, then clamp it just short of the ±1 boundary so the
      //--- upcoming logarithm never receives an invalid input
      double prevRawValue = kRawValue[i + 1];
      double smoothedValue = 0.5 * (rawValue + prevRawValue);
      if(smoothedValue > 0.999)
         smoothedValue = 0.999;
      if(smoothedValue < -0.999)
         smoothedValue = -0.999;
      kRawValue[i] = rawValue;

      //--- Idea 3: apply the Fisher Transform itself, smoothed recursively
      //--- against the previous bar's own Fisher value
      double prevFisher = BufFisher[i + 1];
      BufFisher[i] = 0.5 * MathLog((1.0 + smoothedValue) / (1.0 - smoothedValue)) + 0.5 * prevFisher;
     }

   return rates_total;
  }
//+------------------------------------------------------------------+

