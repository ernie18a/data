//+------------------------------------------------------------------+
//|                   Adaptive Kalman Trend.mq5 BY Ali Kazim & Jawad |
//+------------------------------------------------------------------+
#property copyright   "2026"
#property version     "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   4

#property indicator_label1  "Up Trend"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLime
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "Down Trend"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

#property indicator_label3  "Buy"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrLime
#property indicator_width3  3

#property indicator_label4  "Sell"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_width4  3


input double InpProcessNoise     = 0.01;  // Process Noise (Q) - higher = more responsive
input double InpMeasurementNoise = 0.10;  // Measurement Noise (R) - higher = more smoothing
input bool   InpShowSignals      = true;

//--- Indicator output buffers used for drawing the trend line and signals
double BufUp[];
double BufDn[];
double BufBuy[];
double BufSell[];

//--- Internal recursive state, registered as calculation buffers so the
//--- terminal manages their size and bar-to-bar continuity automatically,
//--- instead of manually resized/reset arrays. kEstimate holds the
//--- Kalman-filtered price; kErrorCov holds the filter's own uncertainty
//--- about that estimate, which is what makes the gain adaptive.
double kEstimate[];
double kErrorCov[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Connect indicator buffers with their corresponding plots
   SetIndexBuffer(0, BufUp,   INDICATOR_DATA);
   SetIndexBuffer(1, BufDn,   INDICATOR_DATA);
   SetIndexBuffer(2, BufBuy,  INDICATOR_DATA);
   SetIndexBuffer(3, BufSell, INDICATOR_DATA);

//--- Register the recursive Kalman state as calculation buffers — the
//--- terminal keeps these correctly sized and shifted as new bars appear
   SetIndexBuffer(4, kEstimate, INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, kErrorCov, INDICATOR_CALCULATIONS);

//--- Define empty values so unused buffer points are not drawn
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, EMPTY_VALUE);

//--- Set arrow symbols for buy and sell signal plots
   PlotIndexSetInteger(2, PLOT_ARROW, 233);
   PlotIndexSetInteger(3, PLOT_ARROW, 234);

   IndicatorSetString(INDICATOR_SHORTNAME,
                      "AdaptiveKalmanTrend(" + DoubleToString(InpProcessNoise, 3) + "," +
                      DoubleToString(InpMeasurementNoise, 2) + ")");

//--- Validate inputs before allowing the indicator to run
   if(InpProcessNoise <= 0 || InpMeasurementNoise <= 0)
     {
      Print("InpProcessNoise and InpMeasurementNoise must both be greater than zero");
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
//--- Check that enough bars exist to seed the recursive filter
   if(rates_total < 3)
      return 0;

//--- Use series indexing where index 0 represents the latest bar. Since
//--- kEstimate/kErrorCov are terminal-managed calculation buffers, no
//--- manual ArrayResize()/ArrayInitialize() is needed here — the terminal
//--- keeps their existing values correctly aligned as new bars appear.
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(BufUp,   true);
   ArraySetAsSeries(BufDn,   true);
   ArraySetAsSeries(BufBuy,  true);
   ArraySetAsSeries(BufSell, true);
   ArraySetAsSeries(kEstimate, true);
   ArraySetAsSeries(kErrorCov, true);

//--- Determine the starting point for the calculation
   int start = rates_total - prev_calculated;

//--- Perform a full initialization on the first calculation
   if(prev_calculated <= 1)
     {
      ArrayInitialize(BufUp,   EMPTY_VALUE);
      ArrayInitialize(BufDn,   EMPTY_VALUE);
      ArrayInitialize(BufBuy,  EMPTY_VALUE);
      ArrayInitialize(BufSell, EMPTY_VALUE);
      ArrayInitialize(kEstimate, 0);
      ArrayInitialize(kErrorCov, 0);

      //--- Seed the recursive Kalman state: the oldest bar's estimate
      //--- simply starts at that bar's own closing price, with an
      //--- initial error covariance of 1.0 (a neutral starting guess)
      int seed = rates_total - 2;
      kEstimate[seed] = close[seed];
      kErrorCov[seed] = 1.0;

      start = seed - 1;
     }
   else
     {
      //--- Recalculate the current and most recently closed bar on live ticks
      if(start < 1)
         start = 1;
     }

//--- Main loop: run the Kalman predict/update cycle and derive trend state
   for(int i = start; i >= 0; i--)
     {
      //--- Skip invalid oldest index
      if(i >= rates_total - 1)
         continue;

      double prevEstimate = kEstimate[i + 1];
      double prevErrorCov = kErrorCov[i + 1];

      //--- Prediction step: assume the true value doesn't change on its
      //--- own between bars, but our uncertainty about it grows by the
      //--- process noise — this is what allows the filter to adapt
      double predictedEstimate = prevEstimate;
      double predictedErrorCov = prevErrorCov + InpProcessNoise;

      //--- Update step: blend the prediction with the new price using
      //--- the Kalman gain — a weight that automatically favors whichever
      //--- source (the prior estimate or the new price) is more reliable
      //--- right now, rather than a fixed smoothing period like an EMA
      double kalmanGain = predictedErrorCov / (predictedErrorCov + InpMeasurementNoise);

      kEstimate[i] = predictedEstimate + kalmanGain * (close[i] - predictedEstimate);
      kErrorCov[i] = (1.0 - kalmanGain) * predictedErrorCov;

      //--- Derive the trend direction from the estimate's own slope: if
      //--- the filtered value is still rising bar over bar, treat that as
      //--- an uptrend, and vice versa — this comes from the adaptive
      //--- estimate itself, not from comparing two separately-tuned lines
      int trend = (kEstimate[i] >= prevEstimate) ? 1 : -1;
      int prevTrend = (i + 2 <= rates_total - 1) ? ((kEstimate[i + 1] >= kEstimate[i + 2]) ? 1 : -1) : trend;

      //--- Draw the active trend line only
      if(trend == 1)
        {
         BufUp[i] = kEstimate[i];
         BufDn[i] = EMPTY_VALUE;
        }
      else
        {
         BufDn[i] = kEstimate[i];
         BufUp[i] = EMPTY_VALUE;
        }

      //--- Reset signal buffers before checking new signals
      BufBuy[i]  = EMPTY_VALUE;
      BufSell[i] = EMPTY_VALUE;

      //--- Draw buy/sell arrows only after a confirmed trend reversal,
      //--- excluding the newest bar or two so an arrow never appears and
      //--- then disappears once more price data comes in
      if(InpShowSignals && i > 1)
        {
         if(trend == 1 && prevTrend == -1)
            BufBuy[i]  = kEstimate[i];
         else
            if(trend == -1 && prevTrend == 1)
               BufSell[i] = kEstimate[i];
        }
     }

   return rates_total;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
