//+------------------------------------------------------------------+
//|                              Supertrend.mq5 BY ALI KAZIM & JAWAD |
//+------------------------------------------------------------------+
#property copyright   "2026"
#property version     "2.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 7
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

input int    InpAtrPeriod     = 10;
input double InpMultiplier    = 3.0;
input bool   InpShowSignals   = true;

//--- Indicator output buffers used for drawing trend lines and signals
double BufUp[];
double BufDn[];
double BufBuy[];
double BufSell[];

//--- Internal recursive state, registered as calculation buffers (buffers
//--- 4-6) so the terminal manages their size and bar-to-bar continuity
//--- automatically, instead of manually resized/reset arrays. sTrend is
//--- stored as a double (1.0 / -1.0) because indicator buffers must be
//--- double, and cast to int only where needed for comparisons.
double sUp[];
double sDn[];
double sTrend[];

//--- ATR indicator handle used to retrieve volatility values
int hATR = INVALID_HANDLE;

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

//--- Register the recursive state as calculation buffers — the terminal
//--- keeps these correctly sized and shifted as new bars appear, which
//--- is what a plain dynamic array with manual ArrayResize() does not
//--- reliably guarantee
   SetIndexBuffer(4, sUp,    INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, sDn,    INDICATOR_CALCULATIONS);
   SetIndexBuffer(6, sTrend, INDICATOR_CALCULATIONS);

//--- Define empty values so unused buffer points are not drawn
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, EMPTY_VALUE);

//--- Set arrow symbols for buy and sell signal plots
   PlotIndexSetInteger(2, PLOT_ARROW, 233);
   PlotIndexSetInteger(3, PLOT_ARROW, 234);

   IndicatorSetString(INDICATOR_SHORTNAME,
                      "SuperTrend(" + IntegerToString(InpAtrPeriod) + "," +
                      DoubleToString(InpMultiplier, 1) + ")");

//--- Create ATR handle required for volatility calculations
   hATR = iATR(_Symbol, PERIOD_CURRENT, InpAtrPeriod);

//--- Stop initialization if ATR handle creation fails
   if(hATR == INVALID_HANDLE)
     {
      Print("iATR create failed");
      return INIT_FAILED;
     }

   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Release ATR resources when the indicator is removed
   if(hATR != INVALID_HANDLE)
      IndicatorRelease(hATR);
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
//--- Check that enough bars exist for ATR and recursive calculations
   if(rates_total < InpAtrPeriod + 2)
      return 0;

//--- Copy ATR values required for SuperTrend calculation
   double atr[];
   ArraySetAsSeries(atr, true);
   int copied = CopyBuffer(hATR, 0, 0, rates_total, atr);

//--- Safety Check: wait if ATR data is incomplete
   if(copied < rates_total)
      return 0;

//--- Use series indexing where index 0 represents the latest bar. Since
//--- sUp/sDn/sTrend are now terminal-managed calculation buffers, no
//--- manual ArrayResize()/ArrayInitialize() is needed or performed here —
//--- the terminal keeps their existing values correctly aligned as new
//--- bars appear, so previously calculated state is never lost.
   ArraySetAsSeries(high,  true);
   ArraySetAsSeries(low,   true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(BufUp,   true);
   ArraySetAsSeries(BufDn,   true);
   ArraySetAsSeries(BufBuy,  true);
   ArraySetAsSeries(BufSell, true);
   ArraySetAsSeries(sUp,    true);
   ArraySetAsSeries(sDn,    true);
   ArraySetAsSeries(sTrend, true);

//--- Calculate starting position based on previous calculations
   int start = rates_total - prev_calculated;

//--- Full recalculation: clear old values and create initial state
   if(prev_calculated <= 1)
     {
      ArrayInitialize(BufUp,   EMPTY_VALUE);
      ArrayInitialize(BufDn,   EMPTY_VALUE);
      ArrayInitialize(BufBuy,  EMPTY_VALUE);
      ArrayInitialize(BufSell, EMPTY_VALUE);
      ArrayInitialize(sUp,    0);
      ArrayInitialize(sDn,    0);
      ArrayInitialize(sTrend, 0);

      //--- Create initial SuperTrend values from the oldest valid bar
      int seed = rates_total - 2;
      double hl2seed = (high[seed] + low[seed]) / 2.0;
      sUp[seed]    = hl2seed - InpMultiplier * atr[seed];
      sDn[seed]    = hl2seed + InpMultiplier * atr[seed];
      sTrend[seed] = 1.0;

      start = seed - 1;
     }
   else
     {
      //--- Recalculate current and recently closed bars during live ticks
      if(start < 1)
         start = 1;
     }

//--- Main loop: update SuperTrend bands and trend state
   for(int i = start; i >= 0; i--)
     {
      //--- Skip invalid oldest index
      if(i >= rates_total - 1)
         continue;

      //--- Calculate midpoint price and current ATR value
      double hl2   = (high[i] + low[i]) / 2.0;
      double atrVal  = atr[i];

      //--- Ignore invalid ATR values
      if(atrVal <= 0)
         continue;

      //--- Calculate basic upper and lower ATR bands
      double basicUp = hl2 - InpMultiplier * atrVal;
      double basicDn = hl2 + InpMultiplier * atrVal;

      //--- Get previous recursive SuperTrend values
      double prevUp = sUp[i + 1];
      double prevDn = sDn[i + 1];
      double prevClose = close[i + 1];

      //--- Apply SuperTrend ratchet logic
      sUp[i] = (prevClose > prevUp) ? MathMax(basicUp, prevUp) : basicUp;
      sDn[i] = (prevClose < prevDn) ? MathMin(basicDn, prevDn) : basicDn;

      //--- Determine whether trend direction changed
      int prevTrend = (int)sTrend[i + 1];
      int trend     = prevTrend;

      if(prevTrend == -1 && close[i] > prevDn)
         trend = 1;
      else
         if(prevTrend == 1 && close[i] < prevUp)
            trend = -1;
         else
            if(prevTrend == 0)
               trend = 1;

      sTrend[i] = (double)trend;

      //--- Draw the active trend line only
      if(trend == 1)
        {
         BufUp[i] = sUp[i];
         BufDn[i] = EMPTY_VALUE;
        }
      else
        {
         BufDn[i] = sDn[i];
         BufUp[i] = EMPTY_VALUE;
        }

      //--- Reset signal buffers before checking new signals
      BufBuy[i]  = EMPTY_VALUE;
      BufSell[i] = EMPTY_VALUE;

      //--- Show arrows only after trend confirmation
      if(InpShowSignals && i > 1)
        {
         if(trend == 1 && prevTrend == -1)
            BufBuy[i]  = sUp[i];
         else
            if(trend == -1 && prevTrend == 1)
               BufSell[i] = sDn[i];
        }
     }

   return rates_total;
  }
//+------------------------------------------------------------------+