#property copyright "ATR_Momentum_Color"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "ATR_Momentum_Color"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2

//--- Plot: Main oscillator line with color index
#property indicator_label1  "ATR_Momentum_Color"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrLimeGreen, clrGreen, clrOrange, clrRed
#property indicator_width1  2

//--- Input parameters
input int    InpPeriod       = 14;    // Momentum & ATR period
input double InpDeviation    = 1.5;   // ATR multiplier
input int    InpSignalPeriod = 1;     // Optional smoothing (used internally)

//--- Buffers
double ExtOscBuffer[];   // Main oscillator values
double ExtColorIndex[];  // Color index buffer

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   // Main data buffer
   SetIndexBuffer(0, ExtOscBuffer, INDICATOR_DATA);
   
   // Color index buffer (must be INDICATOR_COLOR_INDEX)
   SetIndexBuffer(1, ExtColorIndex, INDICATOR_COLOR_INDEX);
   
   // Set indicator levels
   IndicatorSetInteger(INDICATOR_LEVELS, 3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, 70.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 1, 0.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 2, -70.0);
   
   IndicatorSetString(INDICATOR_SHORTNAME, "ATR_Momentum_Color");
   
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
   int start = (prev_calculated == 0) ? InpPeriod + 2 : prev_calculated - 1;
   if (start >= rates_total) return(rates_total);

   // Temporary arrays
   double atr[], momentum[], smoothed[];
   ArrayResize(atr, rates_total);
   ArrayResize(momentum, rates_total);
   ArrayResize(smoothed, rates_total);

   // Step 1: Calculate raw momentum and ATR
   for (int i = start; i < rates_total; i++)
   {
      if (i < InpPeriod)
      {
         ExtOscBuffer[i] = 0;
         ExtColorIndex[i] = 0;
         continue;
      }

      // True Range sum
      double tr_sum = 0;
      for (int k = 0; k < InpPeriod; k++)
      {
         int idx = i - k;
         double prev_close = (idx - 1 >= 0) ? close[idx - 1] : close[idx];
         tr_sum += MathMax(high[idx], prev_close) - MathMin(low[idx], prev_close);
      }
      atr[i] = tr_sum / InpPeriod;

      // Momentum
      momentum[i] = close[i] - close[i - InpPeriod];

      // Normalize and scale
      double raw_osc = (atr[i] > 0) ? (momentum[i] / (atr[i] * InpDeviation)) * 50.0 : 0.0;
      smoothed[i] = raw_osc; // Optional: add EMA here if desired
   }

   // Optional: Smooth with EMA (uncomment if needed)
   
   for (int i = start; i < rates_total; i++)
   {
      if (i < InpPeriod + InpSignalPeriod)
         smoothed[i] = momentum[i] / (atr[i] * InpDeviation) * 50;
      else
      {
         double alpha = 2.0 / (InpSignalPeriod + 1);
         smoothed[i] = alpha * (momentum[i] / (atr[i] * InpDeviation) * 50) + (1 - alpha) * smoothed[i-1];
      }
   }
   

   // Step 2: Final oscillator and color logic
   for (int i = start; i < rates_total; i++)
   {
      if (i < InpPeriod)
      {
         ExtOscBuffer[i] = 0;
         ExtColorIndex[i] = 0;
         continue;
      }

      // Clamp to [-100, 100]
      ExtOscBuffer[i] = MathMin(100.0, MathMax(-100.0, smoothed[i]));

      // Color logic
      if (i < 1)
      {
         ExtColorIndex[i] = 0;
         continue;
      }

      double current = ExtOscBuffer[i];
      double prev    = ExtOscBuffer[i - 1];

      if (current > 0)
      {
         if (current >= prev)
            ExtColorIndex[i] = 1;  // Green: rising above zero
         else
            ExtColorIndex[i] = 0;  // LimeGreen: falling but still positive
      }
      else
      {
         if (current <= prev)
            ExtColorIndex[i] = 3;  // Red: falling below zero
         else
            ExtColorIndex[i] = 2;  // Orange: rising from negative
      }
   }

   return(rates_total);
}