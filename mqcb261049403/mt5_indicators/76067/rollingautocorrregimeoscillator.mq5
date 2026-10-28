//+------------------------------------------------------------------+
//|                              RollingAutocorrRegimeOscillator.mq5 |
//|                                           Author: Adeolu Gbadebo |
//+------------------------------------------------------------------+
#property copyright "Adeolu Gbadebo"
#property link      ""
#property version   "1.00"
#property description "Rolling lag-N autocorrelation of returns, tracked over time as a regime oscillator with significance bands."

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2

#property indicator_label1  "Raw ACF"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSilver
#property indicator_style1  STYLE_DOT
#property indicator_width1  1

#property indicator_label2  "Smoothed ACF"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_width2  2

//--- inputs
input int    InpWindowSize   = 50;    // Rolling window size (return observations) for the ACF estimate
input int    InpLag          = 1;     // Return lag correlated against (bars)
input int    InpSmoothPeriod = 5;     // EMA smoothing period applied to the raw ACF reading
input double InpConfidenceZ  = 1.96;  // Z-score for the significance band (1.96 approx 95%)
input bool   InpUseLogReturns= true;  // Use log returns instead of simple returns

//--- buffers
double RawACFBuffer[];
double SmoothACFBuffer[];

double g_smoothFactor;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                        |
//+------------------------------------------------------------------+
int OnInit()
{
   if(InpWindowSize < 5)
   {
      Print("RollingAutocorrRegimeOscillator: InpWindowSize must be at least 5");
      return INIT_PARAMETERS_INCORRECT;
   }
   if(InpLag < 1 || InpLag >= InpWindowSize)
   {
      Print("RollingAutocorrRegimeOscillator: InpLag must be >=1 and < InpWindowSize");
      return INIT_PARAMETERS_INCORRECT;
   }

   SetIndexBuffer(0, RawACFBuffer,    INDICATOR_DATA);
   SetIndexBuffer(1, SmoothACFBuffer, INDICATOR_DATA);

   ArraySetAsSeries(RawACFBuffer,    false);
   ArraySetAsSeries(SmoothACFBuffer, false);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   IndicatorSetString(INDICATOR_SHORTNAME,
      StringFormat("Rolling ACF Regime (N=%d, lag=%d)", InpWindowSize, InpLag));
   IndicatorSetInteger(INDICATOR_DIGITS, 3);

   double band = InpConfidenceZ / MathSqrt((double)InpWindowSize);
   IndicatorSetInteger(INDICATOR_LEVELS, 3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, 0.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 1, band);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 2, -band);
   IndicatorSetString(INDICATOR_LEVELTEXT, 1, "Significant (trending)");
   IndicatorSetString(INDICATOR_LEVELTEXT, 2, "Significant (mean-reverting)");

   g_smoothFactor = 2.0 / (InpSmoothPeriod + 1.0);

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Pearson correlation between two equal-length arrays              |
//+------------------------------------------------------------------+
double PearsonCorrelation(const double &x[], const double &y[], const int n)
{
   double sumX = 0.0, sumY = 0.0;
   for(int i = 0; i < n; i++)
   {
      sumX += x[i];
      sumY += y[i];
   }
   double meanX = sumX / n;
   double meanY = sumY / n;

   double cov = 0.0, varX = 0.0, varY = 0.0;
   for(int i = 0; i < n; i++)
   {
      double dx = x[i] - meanX;
      double dy = y[i] - meanY;
      cov  += dx * dy;
      varX += dx * dx;
      varY += dy * dy;
   }

   if(varX <= 0.0 || varY <= 0.0)
      return 0.0;

   return cov / MathSqrt(varX * varY);
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
   int need = InpWindowSize + InpLag + 1; // price points required for one ACF reading
   if(rates_total < need)
      return 0;

   int start;
   if(prev_calculated == 0)
   {
      start = need - 1;
      for(int i = 0; i < start; i++)
      {
         RawACFBuffer[i]    = EMPTY_VALUE;
         SmoothACFBuffer[i] = EMPTY_VALUE;
      }
   }
   else
   {
      start = prev_calculated - 1;
      if(start < need - 1)
         start = need - 1;
   }

   double x[], y[];
   ArrayResize(x, InpWindowSize);
   ArrayResize(y, InpWindowSize);

   for(int i = start; i < rates_total; i++)
   {
      // Build InpWindowSize+InpLag returns ending at bar i, then split into
      // X (returns at t) and Y (returns at t-Lag) for t = i-InpWindowSize+1 .. i
      int firstPriceIdx = i - (InpWindowSize + InpLag) + 1; // oldest price needed
      if(firstPriceIdx < 1)
      {
         RawACFBuffer[i]    = EMPTY_VALUE;
         SmoothACFBuffer[i] = EMPTY_VALUE;
         continue;
      }

      for(int k = 0; k < InpWindowSize; k++)
      {
         int tIdx = i - InpWindowSize + 1 + k; // bar index for return at time t
         double rt    = InpUseLogReturns ? MathLog(close[tIdx]    / close[tIdx - 1])
                                          : (close[tIdx]    - close[tIdx - 1]);
         double rtLag = InpUseLogReturns ? MathLog(close[tIdx - InpLag] / close[tIdx - InpLag - 1])
                                          : (close[tIdx - InpLag] - close[tIdx - InpLag - 1]);
         x[k] = rt;
         y[k] = rtLag;
      }

      double raw = PearsonCorrelation(x, y, InpWindowSize);
      RawACFBuffer[i] = raw;

      double prevSmooth = (i > start) ? SmoothACFBuffer[i - 1] : EMPTY_VALUE;
      if(i == 0 || prevSmooth == EMPTY_VALUE)
         SmoothACFBuffer[i] = raw;
      else
         SmoothACFBuffer[i] = prevSmooth + g_smoothFactor * (raw - prevSmooth);
   }

   return rates_total;
}
//+------------------------------------------------------------------+
