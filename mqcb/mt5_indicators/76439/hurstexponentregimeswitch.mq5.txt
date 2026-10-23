//+------------------------------------------------------------------+
//|                                    HurstExponentRegimeSwitch.mq5 |
//|                                                  ADEDAYO GBADEBO |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "ADEDAYO GBADEBO"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Estimates the rolling Hurst exponent via rescaled-range (R/S)"
#property description "analysis and classifies the current market regime as trending,"
#property description "random-walk, or mean-reverting."

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
#property indicator_minimum 0.0
#property indicator_maximum 1.0

//--- Plot 1: Hurst exponent line (color-coded by regime)
#property indicator_label1  "Hurst Exponent"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDodgerBlue,clrSilver,clrCrimson
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- Plot 2: Trending threshold line
#property indicator_label2  "Trend Threshold"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_DOT
#property indicator_width2  1

//--- Plot 3: Mean-reversion threshold line
#property indicator_label3  "Reversion Threshold"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_style3  STYLE_DOT
#property indicator_width3  1

//--- Inputs
input int                InpLookback           = 200;         // R/S analysis window (bars)
input int                InpMinChunk           = 8;            // Minimum chunk size for R/S sub-sampling
input int                InpChunkSteps         = 6;            // Number of chunk-size doublings to test
input int                InpSmoothPeriod       = 5;            // EMA smoothing period applied to raw Hurst value
input double             InpTrendThreshold     = 0.55;         // Hurst level above which regime = trending
input double             InpReversionThreshold = 0.45;         // Hurst level below which regime = mean-reverting
input ENUM_APPLIED_PRICE InpAppliedPrice       = PRICE_CLOSE;  // Price source used for the R/S calculation

//--- Indicator buffers
double HurstBuffer[];     // smoothed Hurst exponent (plotted)
double ColorBuffer[];     // color index for plot 1 (0=trend,1=neutral,2=reversion)
double UpperBuffer[];     // trend threshold constant line
double LowerBuffer[];     // reversion threshold constant line
double RawHurstBuffer[];  // unsmoothed Hurst value (calculation only, not plotted)

//+------------------------------------------------------------------+
//| Custom indicator initialization function                          |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, HurstBuffer,    INDICATOR_DATA);
   SetIndexBuffer(1, ColorBuffer,    INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, UpperBuffer,    INDICATOR_DATA);
   SetIndexBuffer(3, LowerBuffer,    INDICATOR_DATA);
   SetIndexBuffer(4, RawHurstBuffer, INDICATOR_CALCULATIONS);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, InpLookback);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, InpLookback);
   PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, InpLookback);

   if(InpMinChunk < 4)
     {
      Print("HurstExponentRegimeSwitch: InpMinChunk must be >= 4. Adjusting to 4.");
     }
   if(InpChunkSteps < 2)
     {
      Print("HurstExponentRegimeSwitch: InpChunkSteps must be >= 2. Adjusting to 2.");
     }

   IndicatorSetString(INDICATOR_SHORTNAME, "Hurst Exponent Regime Switch (" + IntegerToString(InpLookback) + ")");
   IndicatorSetInteger(INDICATOR_DIGITS, 3);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Return the applied price for a given bar                          |
//+------------------------------------------------------------------+
double GetAppliedPrice(const ENUM_APPLIED_PRICE ap,
                        const double o, const double h,
                        const double l, const double c)
  {
   switch(ap)
     {
      case PRICE_OPEN:     return(o);
      case PRICE_HIGH:     return(h);
      case PRICE_LOW:      return(l);
      case PRICE_MEDIAN:   return((h + l) / 2.0);
      case PRICE_TYPICAL:  return((h + l + c) / 3.0);
      case PRICE_WEIGHTED: return((h + l + 2.0 * c) / 4.0);
      case PRICE_CLOSE:
      default:             return(c);
     }
  }

//+------------------------------------------------------------------+
//| Rescaled-range (R/S) Hurst exponent estimate for one window        |
//| endIdx  : index of the last bar in the window (array is oldest=0)  |
//| lookback: number of bars in the window                             |
//+------------------------------------------------------------------+
double CalculateHurst(const double &price[], const int endIdx,
                       const int lookback, const int minChunkIn, const int chunkStepsIn)
  {
   int minChunk   = (minChunkIn   < 4) ? 4 : minChunkIn;
   int chunkSteps = (chunkStepsIn < 2) ? 2 : chunkStepsIn;

   double logN[];
   double logRS[];
   ArrayResize(logN,  chunkSteps);
   ArrayResize(logRS, chunkSteps);
   int points = 0;

   int windowStart = endIdx - lookback + 1;

   for(int step = 0; step < chunkSteps; step++)
     {
      int chunkSize = minChunk * (1 << step);   // minChunk * 2^step
      if(chunkSize > lookback / 2)
         break;

      int numChunks = lookback / chunkSize;
      if(numChunks < 2)
         continue;

      double rsSum = 0.0;
      int    rsCount = 0;

      for(int c = 0; c < numChunks; c++)
        {
         int segStart = windowStart + c * chunkSize;
         int segEnd   = segStart + chunkSize - 1;

         //--- mean of the segment
         double mean = 0.0;
         for(int j = segStart; j <= segEnd; j++)
            mean += price[j];
         mean /= chunkSize;

         //--- cumulative deviation series -> range, plus deviation stdev
         double cumDev  = 0.0;
         double maxCum  = -DBL_MAX;
         double minCum  =  DBL_MAX;
         double sumSq   = 0.0;

         for(int j = segStart; j <= segEnd; j++)
           {
            double dev = price[j] - mean;
            cumDev += dev;
            if(cumDev > maxCum) maxCum = cumDev;
            if(cumDev < minCum) minCum = cumDev;
            sumSq += dev * dev;
           }

         double range = maxCum - minCum;
         double stdev = MathSqrt(sumSq / chunkSize);

         if(stdev > 0.0)
           {
            rsSum += (range / stdev);
            rsCount++;
           }
        }

      if(rsCount > 0)
        {
         double avgRS = rsSum / rsCount;
         if(avgRS > 0.0)
           {
            logN[points]  = MathLog((double)chunkSize);
            logRS[points] = MathLog(avgRS);
            points++;
           }
        }
     }

   if(points < 2)
      return(0.5);   // not enough sub-samples -- report neutral (random-walk) value

   //--- least-squares regression slope of log(R/S) on log(n) = Hurst exponent
   double sumX = 0.0, sumY = 0.0, sumXY = 0.0, sumXX = 0.0;
   for(int k = 0; k < points; k++)
     {
      sumX  += logN[k];
      sumY  += logRS[k];
      sumXY += logN[k] * logRS[k];
      sumXX += logN[k] * logN[k];
     }

   double denom = points * sumXX - sumX * sumX;
   if(denom == 0.0)
      return(0.5);

   double slope = (points * sumXY - sumX * sumY) / denom;

   if(slope < 0.0) slope = 0.0;
   if(slope > 1.0) slope = 1.0;

   return(slope);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                                |
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
   if(rates_total < InpLookback + 2)
      return(0);

   //--- build the working price series once per call
   double price[];
   ArrayResize(price, rates_total);
   for(int i = 0; i < rates_total; i++)
      price[i] = GetAppliedPrice(InpAppliedPrice, open[i], high[i], low[i], close[i]);

   int start = (prev_calculated > 1) ? prev_calculated - 1 : InpLookback;
   if(start < InpLookback)
      start = InpLookback;

   double alpha = 2.0 / (InpSmoothPeriod + 1.0);

   for(int i = start; i < rates_total; i++)
     {
      double h = CalculateHurst(price, i, InpLookback, InpMinChunk, InpChunkSteps);
      RawHurstBuffer[i] = h;

      if(i == InpLookback || prev_calculated == 0)
         HurstBuffer[i] = h;
      else
         HurstBuffer[i] = alpha * h + (1.0 - alpha) * HurstBuffer[i - 1];

      UpperBuffer[i] = InpTrendThreshold;
      LowerBuffer[i] = InpReversionThreshold;

      if(HurstBuffer[i] >= InpTrendThreshold)
         ColorBuffer[i] = 0.0;      // trending / persistent regime
      else if(HurstBuffer[i] <= InpReversionThreshold)
         ColorBuffer[i] = 2.0;      // mean-reverting / anti-persistent regime
      else
         ColorBuffer[i] = 1.0;      // random-walk / neutral regime
     }

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
  }
//+------------------------------------------------------------------+
