//+------------------------------------------------------------------+
//|                                 MACD TradingView Style for MT5   |
//|                                       Copyright 2026, Littefrido |
//|                         https://www.mql5.com/en/users/littefrido |
//+------------------------------------------------------------------+
#property copyright "Littefrido"
#property link      "https://www.mql5.com/en/users/littefrido"
#property version   "1.01"
#property description "MACD indicator styled after TradingView's implementation."
#property description "Features a 4-color histogram (dark/light green and coral/red)"
#property description "and a Signal line seeded with SMA — identical to Pine Script's ta.ema() initialisation,"
#property description "ensuring values match TradingView bar-for-bar."

//---- MACD TradingView Style
//---- 4-color histogram: DarkGreen (rising above 0), LimeGreen (falling above 0),
//----                    LightCoral (rising toward 0), Red (falling below 0)
//---- Signal line initialised with SMA seed — matches Pine Script ta.ema() exactly
//---- EMA calculated internally — no external indicator dependencies

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   3

//--- Plot 1: MACD Line
#property indicator_label1  "MACD"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- Plot 2: Signal Line
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- Plot 3: 4-Color Histogram
//--- Color index: 0=DarkGreen, 1=LimeGreen, 2=LightCoral, 3=Red
#property indicator_label3  "Histogram"
#property indicator_type3   DRAW_COLOR_HISTOGRAM
#property indicator_color3  clrDarkGreen, clrLimeGreen, clrLightCoral, clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  5

//--- Input parameters
input int                InpFastEMA   = 12;          // Fast EMA Length
input int                InpSlowEMA   = 26;          // Slow EMA Length
input int                InpSignalSMA = 9;           // Signal EMA Length
input ENUM_APPLIED_PRICE InpPrice     = PRICE_CLOSE; // Source

//--- Indicator buffers (visible)
double MACDBuffer[];
double SignalBuffer[];
double HistogramBuffer[];
double ColorBuffer[];   // Color index for histogram (INDICATOR_COLOR_INDEX)

//--- Internal calculation buffers (hidden)
double FastEMABuffer[];
double SlowEMABuffer[];



//+------------------------------------------------------------------+
//| Return histogram color index (TradingView logic)                 |
//|  0 = DarkGreen  — histogram > 0 and rising                      |
//|  1 = LimeGreen  — histogram > 0 and falling                     |
//|  2 = LightCoral — histogram < 0 and rising (toward zero)        |
//|  3 = Red        — histogram < 0 and falling                     |
//+------------------------------------------------------------------+
int GetHistogramColor(double cur, double prev)
  {
   if(cur > 0)
      return (cur >= prev) ? 0 : 1;
   if(cur < 0)
      return (cur <= prev) ? 3 : 2;
   return 1; // zero — colour irrelevant (bar not drawn)
  }

//+------------------------------------------------------------------+
//| Initialisation                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Bind visible buffers
   SetIndexBuffer(0, MACDBuffer,      INDICATOR_DATA);
   SetIndexBuffer(1, SignalBuffer,    INDICATOR_DATA);
   SetIndexBuffer(2, HistogramBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, ColorBuffer,     INDICATOR_COLOR_INDEX);

//--- Bind internal calculation buffers (not plotted)
   SetIndexBuffer(4, FastEMABuffer,   INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, SlowEMABuffer,   INDICATOR_CALCULATIONS);

//--- Empty value: 0.0 (histogram bar disappears when value is zero)
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0.0);

//--- Dynamic short name shown in the indicator sub-window
   IndicatorSetString(INDICATOR_SHORTNAME,
                      "MACD TV(" + IntegerToString(InpFastEMA)   + "," +
                      IntegerToString(InpSlowEMA)   + "," +
                      IntegerToString(InpSignalSMA) + ")");

   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Main calculation                                                 |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//--- Need enough bars for SlowEMA + Signal warm-up
   if(rates_total < InpSlowEMA + InpSignalSMA + 1)
      return 0;

//--- EMA multipliers
   double alphaFast   = 2.0 / (InpFastEMA   + 1);
   double alphaSlow   = 2.0 / (InpSlowEMA   + 1);
   double alphaSignal = 2.0 / (InpSignalSMA + 1);

//--- Determine recalculation start bar
   int start;
   if(prev_calculated == 0)
     {
      ArrayInitialize(FastEMABuffer,   0);
      ArrayInitialize(SlowEMABuffer,   0);
      ArrayInitialize(MACDBuffer,      0);
      ArrayInitialize(SignalBuffer,    0);
      ArrayInitialize(HistogramBuffer, 0);
      ArrayInitialize(ColorBuffer,     0);

      //--- Seed FastEMA with SMA of first InpFastEMA bars
      double sumFast = 0.0;
      for(int i = 0; i < InpFastEMA; i++)
         sumFast += price[i];
      FastEMABuffer[InpFastEMA - 1] = sumFast / InpFastEMA;

      //--- Seed SlowEMA with SMA of first InpSlowEMA bars
      double sumSlow = 0.0;
      for(int i = 0; i < InpSlowEMA; i++)
         sumSlow += price[i];
      SlowEMABuffer[InpSlowEMA - 1] = sumSlow / InpSlowEMA;

      start = InpSlowEMA;
     }
   else
     {
      start = prev_calculated - 1;
      if(start < InpSlowEMA)
         start = InpSlowEMA;
     }

//--- 1. Fast and Slow EMA (recursive from seed)
   for(int i = start; i < rates_total; i++)
     {
      double p = price[i];
      FastEMABuffer[i] = alphaFast * p + (1.0 - alphaFast) * FastEMABuffer[i-1];
      SlowEMABuffer[i] = alphaSlow * p + (1.0 - alphaSlow) * SlowEMABuffer[i-1];
     }

//--- 2. MACD line = FastEMA - SlowEMA
   for(int i = start; i < rates_total; i++)
      MACDBuffer[i] = FastEMABuffer[i] - SlowEMABuffer[i];

//--- 3. Signal line = EMA(InpSignalSMA) of MACD
//    Seeded with SMA of first InpSignalSMA MACD values — mirrors Pine Script ta.ema()
   int seedBar = InpSlowEMA - 1 + InpSignalSMA - 1;

   for(int i = start; i < rates_total; i++)
     {
      if(i < seedBar)
        {
         SignalBuffer[i] = 0.0;
        }
      else
         if(i == seedBar)
           {
            //--- SMA seed
            double sum = 0.0;
            for(int j = InpSlowEMA - 1; j <= i; j++)
               sum += MACDBuffer[j];
            SignalBuffer[i] = sum / InpSignalSMA;
           }
         else
           {
            //--- EMA recursion
            SignalBuffer[i] = alphaSignal * MACDBuffer[i] + (1.0 - alphaSignal) * SignalBuffer[i-1];
           }
     }

//--- 4. Histogram and colors
   for(int i = start; i < rates_total; i++)
     {
      HistogramBuffer[i] = MACDBuffer[i] - SignalBuffer[i];
      double prev        = (i > 0) ? HistogramBuffer[i-1] : HistogramBuffer[i];
      ColorBuffer[i]     = (double)GetHistogramColor(HistogramBuffer[i], prev);
     }

   return rates_total;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
