//+------------------------------------------------------------------+
//|                             CandleBodyWickPressureOscillator.mq5 |
//|                                             Copyright Samuel Ojo |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Samuel Ojo"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Normalizes candle body strength against wick imbalance into a bounded pressure oscillator with automatic divergence flags."

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   4
#property indicator_minimum -110
#property indicator_maximum  110

//--- Plot 1: Pressure oscillator (color histogram)
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrSilver, clrDimGray
#property indicator_width1  2
#property indicator_label1  "Pressure"

//--- Plot 2: Signal line (EMA of oscillator)
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrWhite
#property indicator_width2  1
#property indicator_style2  STYLE_SOLID
#property indicator_label2  "Signal"

//--- Plot 3: Bullish divergence arrow
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrLime
#property indicator_width3  2
#property indicator_label3  "Bullish Divergence"

//--- Plot 4: Bearish divergence arrow
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_width4  2
#property indicator_label4  "Bearish Divergence"

#property indicator_level1  60.0
#property indicator_level2  -60.0
#property indicator_level3  0.0
#property indicator_levelstyle STYLE_DOT
#property indicator_levelcolor clrGray

//--- inputs
input int    InpOscPeriod          = 14;    // Averaging period for pressure oscillator
input int    InpSignalPeriod       = 9;     // EMA period for signal line
input double InpWickWeight         = 1.0;   // Weight applied to wick imbalance component
input int    InpFractalRange       = 2;     // Bars each side required to confirm a pivot
input int    InpDivergenceLookback = 50;    // Bars scanned for divergence pairs
input bool   InpShowDivergence     = true;  // Show divergence arrows

//--- indicator buffers
double OscBuffer[];
double OscColorBuffer[];
double SignalBuffer[];
double BullDivBuffer[];
double BearDivBuffer[];

//--- internal per-bar raw score storage (not a plotted buffer)
double RawScoreArr[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, OscBuffer,      INDICATOR_DATA);
   SetIndexBuffer(1, OscColorBuffer, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, SignalBuffer,   INDICATOR_DATA);
   SetIndexBuffer(3, BullDivBuffer,  INDICATOR_DATA);
   SetIndexBuffer(4, BearDivBuffer,  INDICATOR_DATA);

   ArraySetAsSeries(OscBuffer,      false);
   ArraySetAsSeries(OscColorBuffer, false);
   ArraySetAsSeries(SignalBuffer,   false);
   ArraySetAsSeries(BullDivBuffer,  false);
   ArraySetAsSeries(BearDivBuffer,  false);

   PlotIndexSetInteger(2, PLOT_ARROW, 233);
   PlotIndexSetInteger(3, PLOT_ARROW, 234);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   IndicatorSetString(INDICATOR_SHORTNAME, "Body-Wick Pressure Osc(" + IntegerToString(InpOscPeriod) + ")");
   IndicatorSetInteger(INDICATOR_DIGITS, 2);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Detect bullish / bearish divergence between price and oscillator |
//+------------------------------------------------------------------+
void DetectDivergence(const int rates_total, const double &high[], const double &low[])
{
   int scanStart = MathMax(InpFractalRange, rates_total - InpDivergenceLookback);
   int scanEnd   = rates_total - InpFractalRange - 1;

   if(scanEnd <= scanStart)
      return;

   int lowPivots[];
   int highPivots[];
   int lowCount  = 0;
   int highCount = 0;
   ArrayResize(lowPivots, 0);
   ArrayResize(highPivots, 0);

   for(int i = scanStart; i <= scanEnd; i++)
   {
      bool isLow  = true;
      bool isHigh = true;

      for(int k = 1; k <= InpFractalRange; k++)
      {
         if(low[i] > low[i-k] || low[i] > low[i+k])
            isLow = false;
         if(high[i] < high[i-k] || high[i] < high[i+k])
            isHigh = false;
      }

      if(isLow)
      {
         lowCount++;
         ArrayResize(lowPivots, lowCount);
         lowPivots[lowCount-1] = i;
      }
      if(isHigh)
      {
         highCount++;
         ArrayResize(highPivots, highCount);
         highPivots[highCount-1] = i;
      }
   }

   //--- bullish divergence: price makes a lower low, oscillator makes a higher low
   if(lowCount >= 2)
   {
      int i2 = lowPivots[lowCount-1];
      int i1 = lowPivots[lowCount-2];

      if(low[i2] < low[i1] &&
         OscBuffer[i2] != EMPTY_VALUE && OscBuffer[i1] != EMPTY_VALUE &&
         OscBuffer[i2] > OscBuffer[i1])
      {
         BullDivBuffer[i2] = OscBuffer[i2] - 15.0;
      }
   }

   //--- bearish divergence: price makes a higher high, oscillator makes a lower high
   if(highCount >= 2)
   {
      int j2 = highPivots[highCount-1];
      int j1 = highPivots[highCount-2];

      if(high[j2] > high[j1] &&
         OscBuffer[j2] != EMPTY_VALUE && OscBuffer[j1] != EMPTY_VALUE &&
         OscBuffer[j2] < OscBuffer[j1])
      {
         BearDivBuffer[j2] = OscBuffer[j2] + 15.0;
      }
   }
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
   int minBars = InpOscPeriod + InpSignalPeriod + 2 * InpFractalRange + 2;
   if(rates_total < minBars)
      return(0);

   ArrayResize(RawScoreArr, rates_total);

   int start = (prev_calculated == 0) ? 0 : prev_calculated - 1;

   //--- Step 1: raw per-bar pressure score, bounded to roughly [-1, 1]
   for(int i = start; i < rates_total; i++)
   {
      double range = high[i] - low[i];
      if(range <= 0.0)
      {
         RawScoreArr[i] = 0.0;
         continue;
      }

      double body      = close[i] - open[i];
      double bodyRatio = MathAbs(body) / range;
      double dir       = (body > 0.0) ? 1.0 : (body < 0.0 ? -1.0 : 0.0);

      double upperWick     = high[i] - MathMax(open[i], close[i]);
      double lowerWick     = MathMin(open[i], close[i]) - low[i];
      double wickImbalance = (lowerWick - upperWick) / range;

      double raw = dir * bodyRatio + InpWickWeight * wickImbalance;
      raw = raw / (1.0 + InpWickWeight);

      RawScoreArr[i] = raw;
   }

   //--- Step 2: pressure oscillator = SMA of raw score, scaled to -100..100
   for(int i = start; i < rates_total; i++)
   {
      if(i < InpOscPeriod - 1)
      {
         OscBuffer[i]      = EMPTY_VALUE;
         OscColorBuffer[i] = 0;
         continue;
      }

      double sum = 0.0;
      for(int k = 0; k < InpOscPeriod; k++)
         sum += RawScoreArr[i-k];

      double osc = (sum / InpOscPeriod) * 100.0;
      OscBuffer[i]      = osc;
      OscColorBuffer[i] = (osc >= 0.0) ? 0 : 1;
   }

   //--- Step 3: signal line, EMA of the oscillator
   double emaFactor = 2.0 / (InpSignalPeriod + 1.0);
   int    seedBar    = InpOscPeriod - 1 + InpSignalPeriod - 1;

   for(int i = start; i < rates_total; i++)
   {
      if(i < seedBar || OscBuffer[i] == EMPTY_VALUE)
      {
         SignalBuffer[i] = EMPTY_VALUE;
         continue;
      }

      if(i == seedBar || SignalBuffer[i-1] == EMPTY_VALUE)
      {
         double s = 0.0;
         for(int k = 0; k < InpSignalPeriod; k++)
            s += OscBuffer[i-k];
         SignalBuffer[i] = s / InpSignalPeriod;
      }
      else
      {
         SignalBuffer[i] = SignalBuffer[i-1] + emaFactor * (OscBuffer[i] - SignalBuffer[i-1]);
      }
   }

   //--- Step 4: clear divergence buffers for the recalculated range, then rescan
   for(int i = start; i < rates_total; i++)
   {
      BullDivBuffer[i] = EMPTY_VALUE;
      BearDivBuffer[i] = EMPTY_VALUE;
   }

   if(InpShowDivergence)
      DetectDivergence(rates_total, high, low);

   return(rates_total);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ArrayFree(RawScoreArr);
}
//+------------------------------------------------------------------+
