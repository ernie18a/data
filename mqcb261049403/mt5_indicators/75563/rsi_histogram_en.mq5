//+------------------------------------------------------------------+
//|                                             RSI Histogram EN.mq5 |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                                    forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "2.10"
#property strict
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 5
#property indicator_plots   2

#property indicator_label1  "RSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_width1  2

#property indicator_label2  "RSI Histogram"
#property indicator_type2   DRAW_COLOR_HISTOGRAM
#property indicator_color2  clrLime,clrRed,clrGold
#property indicator_width2  3

input group "=== RSI ==="
input bool               Show_RSI        = true;             // Show the RSI line
input int                RSI_Period      = 14;                // RSI period
input ENUM_APPLIED_PRICE RSI_Price       = PRICE_CLOSE;       // Applied price
input color               RSI_Color      = clrDodgerBlue;     // RSI line color
input int                RSI_Width       = 2;                 // RSI line width

input group "=== Histogram ==="
input bool     Show_Histogram   = true;                       // Show the histogram
input int      Histogram_Width  = 3;                          // Histogram bar width
input double   Momentum_Filter  = 0.01;                       // Minimum RSI change threshold to switch color
input color    Color_Up         = clrLime;                    // Color when RSI is rising
input color    Color_Down       = clrRed;                     // Color when RSI is falling
input color    Color_Flat       = clrGold;                    // Color when RSI is flat

input group "=== Levels ==="
input bool     Show_Levels   = true;                          // Show horizontal levels
input double   Upper_Level   = 70.0;                          // Upper level
input double   Middle_Level  = 50.0;                          // Middle level
input double   Lower_Level   = 30.0;                          // Lower level

input group "=== Performance ==="
input int      Maximum_Bars  = 10000;                         // 0 = no limit (calculate on full history)

//--- indicator buffers
double RSIBuffer[];
double HistogramBuffer[];
double HistogramColors[];
double AvgGain[];
double AvgLoss[];

int RSIPer;

//+------------------------------------------------------------------+
//| Returns the applied price according to the RSI_Price input        |
//+------------------------------------------------------------------+
double AppliedPrice(const int i,
                     const double &open[],
                     const double &high[],
                     const double &low[],
                     const double &close[])
  {
   switch(RSI_Price)
     {
      case PRICE_OPEN:     return(open[i]);
      case PRICE_HIGH:     return(high[i]);
      case PRICE_LOW:      return(low[i]);
      case PRICE_MEDIAN:   return((high[i] + low[i]) / 2.0);
      case PRICE_TYPICAL:  return((high[i] + low[i] + close[i]) / 3.0);
      case PRICE_WEIGHTED: return((high[i] + low[i] + 2.0 * close[i]) / 4.0);
      default:             return(close[i]);
     }
  }

//+------------------------------------------------------------------+
int OnInit()
  {
//--- validate and sanitize inputs so a bad user value never crashes
//--- or destabilizes the calculation
   RSIPer = (RSI_Period < 1) ? 14 : RSI_Period;
   if(RSI_Period < 1)
      Print("RSI Histogram: invalid RSI_Period, using default value 14.");

   int rsiWidth = (int)MathMax(1, MathMin(5, RSI_Width));
   int histWidth = (int)MathMax(1, MathMin(5, Histogram_Width));

   SetIndexBuffer(0, RSIBuffer,       INDICATOR_DATA);
   SetIndexBuffer(1, HistogramBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, HistogramColors, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(3, AvgGain,         INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, AvgLoss,         INDICATOR_CALCULATIONS);

   ArraySetAsSeries(RSIBuffer,       false);
   ArraySetAsSeries(HistogramBuffer, false);
   ArraySetAsSeries(HistogramColors, false);
   ArraySetAsSeries(AvgGain,         false);
   ArraySetAsSeries(AvgLoss,         false);

//--- use a sensible default color if the user leaves it unset/clrNONE
   color rsiColor = (RSI_Color == clrNONE) ? clrDodgerBlue : RSI_Color;

   PlotIndexSetInteger(0, PLOT_DRAW_TYPE,  Show_RSI ? DRAW_LINE : DRAW_NONE);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, rsiWidth);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, rsiColor);
   PlotIndexSetString (0, PLOT_LABEL,      "RSI(" + IntegerToString(RSIPer) + ")");

   PlotIndexSetInteger(1, PLOT_DRAW_TYPE,  Show_Histogram ? DRAW_COLOR_HISTOGRAM : DRAW_NONE);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, histWidth);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, 0, Color_Up);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, 1, Color_Down);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, 2, Color_Flat);
   PlotIndexSetDouble  (1, PLOT_EMPTY_VALUE, EMPTY_VALUE);

//--- normalize levels (in case they were entered in the wrong order)
   double lo = Lower_Level, mid = Middle_Level, up = Upper_Level;
   if(lo > up) { double t = lo; lo = up; up = t; }
   if(mid < lo) mid = lo;
   if(mid > up) mid = up;
   lo  = MathMax(0.0,  MathMin(100.0, lo));
   mid = MathMax(0.0,  MathMin(100.0, mid));
   up  = MathMax(0.0,  MathMin(100.0, up));

   if(Show_Levels)
     {
      IndicatorSetInteger(INDICATOR_LEVELS, 3);
      IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, lo);
      IndicatorSetDouble(INDICATOR_LEVELVALUE, 1, mid);
      IndicatorSetDouble(INDICATOR_LEVELVALUE, 2, up);
     }
   else
      IndicatorSetInteger(INDICATOR_LEVELS, 0);

   IndicatorSetInteger(INDICATOR_DIGITS, 2);
   IndicatorSetString (INDICATOR_SHORTNAME, "RSI Histogram(" + IntegerToString(RSIPer) + ")");

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| (Re)seeds the Wilder averages using a simple average of the last  |
//| RSIPer price changes ending at seedIndex.                         |
//| Used both for the initial calculation and when Maximum_Bars       |
//| limits the window, so the recursive average never starts from a  |
//| wrong / zeroed state.                                             |
//+------------------------------------------------------------------+
void SeedAt(const int seedIndex,
            const double &open[], const double &high[],
            const double &low[],  const double &close[])
  {
   double gain = 0.0, loss = 0.0;
   for(int i = seedIndex - RSIPer + 1; i <= seedIndex; i++)
     {
      double d = AppliedPrice(i, open, high, low, close) - AppliedPrice(i - 1, open, high, low, close);
      if(d > 0) gain += d; else loss += -d;
     }
   AvgGain[seedIndex] = gain / RSIPer;
   AvgLoss[seedIndex] = loss / RSIPer;
   RSIBuffer[seedIndex] = (AvgLoss[seedIndex] > 0.0)
                           ? 100.0 - 100.0 / (1.0 + AvgGain[seedIndex] / AvgLoss[seedIndex])
                           : (AvgGain[seedIndex] > 0.0 ? 100.0 : 50.0);
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
   int calcStart = RSIPer;
   if(rates_total <= calcStart)
      return(0);

   int start;

   if(prev_calculated <= calcStart || prev_calculated > rates_total)
     {
      // full (re)initialization -- also guards against a shrunk history
      // (e.g. after a symbol/timeframe change) where prev_calculated
      // could otherwise point past the end of the current arrays
      for(int i = 0; i < rates_total; i++)
        {
         RSIBuffer[i]       = 0.0;
         HistogramBuffer[i] = EMPTY_VALUE;
         HistogramColors[i] = 2;
         AvgGain[i]          = 0.0;
         AvgLoss[i]          = 0.0;
        }
      SeedAt(calcStart, open, high, low, close);
      start = calcStart + 1;
     }
   else
      start = prev_calculated - 1;

   // optional performance cap: re-seed inside the visible window instead
   // of simply skipping bars (skipping would break the recursive average)
   if(Maximum_Bars > 0 && rates_total - start > Maximum_Bars)
     {
      int windowStart = rates_total - Maximum_Bars;
      if(windowStart > calcStart && windowStart > start)
        {
         SeedAt(windowStart, open, high, low, close);
         start = windowStart + 1;
        }
     }

   for(int i = start; i < rates_total && !IsStopped(); i++)
     {
      double d = AppliedPrice(i, open, high, low, close) - AppliedPrice(i - 1, open, high, low, close);
      AvgGain[i] = (AvgGain[i-1] * (RSIPer - 1) + (d > 0 ? d : 0.0)) / RSIPer;
      AvgLoss[i] = (AvgLoss[i-1] * (RSIPer - 1) + (d < 0 ? -d : 0.0)) / RSIPer;
      RSIBuffer[i] = (AvgLoss[i] > 0.0)
                     ? 100.0 - 100.0 / (1.0 + AvgGain[i] / AvgLoss[i])
                     : (AvgGain[i] > 0.0 ? 100.0 : 50.0);

      HistogramBuffer[i] = EMPTY_VALUE;
      HistogramColors[i] = 2;

      if(Show_Histogram)
        {
         double diff = RSIBuffer[i] - RSIBuffer[i-1];
         HistogramBuffer[i] = RSIBuffer[i];
         if(diff > Momentum_Filter)       HistogramColors[i] = 0; // rising
         else if(diff < -Momentum_Filter) HistogramColors[i] = 1; // falling
         else                              HistogramColors[i] = 2; // flat
        }
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
