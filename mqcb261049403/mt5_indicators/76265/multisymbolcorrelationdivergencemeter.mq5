//+------------------------------------------------------------------+
//|                        MultiSymbolCorrelationDivergenceMeter.mq5 |
//|                                                   Adeolu Gbadebo |
//|                                    https://www.mql5.com/en/users |
//+------------------------------------------------------------------+
#property copyright "Adeolu Gbadebo"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Rolling correlation between the current symbol and a chosen reference symbol, paired with a spread z-score, to flag decoupling / divergence events."

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   4

#property indicator_level1  0.0
#property indicator_level2  0.3
#property indicator_level3  -0.3
#property indicator_levelstyle STYLE_DOT
#property indicator_levelcolor clrGray
#property indicator_minimum -1.2
#property indicator_maximum 1.2

//--- Plot 1: rolling correlation (two-color line)
#property indicator_label1  "Correlation"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver, clrWhite
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- Plot 2: spread z-score histogram
#property indicator_label2  "Spread Z-Score"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrGray
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

//--- Plot 3: divergence-up marker
#property indicator_label3  "Divergence Up"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrWhite
#property indicator_width3  2

//--- Plot 4: divergence-down marker
#property indicator_label4  "Divergence Down"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrWhite
#property indicator_width4  2

//--- inputs
input string InpRefSymbol        = "GBPUSD";  // Reference symbol used for the correlation comparison
input int    InpCorrPeriod       = 50;        // Rolling correlation lookback, in bars
input int    InpZPeriod          = 50;        // Spread mean / std-dev lookback, in bars
input double InpCorrLowThreshold = 0.30;      // |Correlation| below this level = "decoupled"
input double InpZScoreThreshold  = 2.0;       // Absolute spread z-score required to flag divergence
input bool   InpArrowsEnabled    = true;      // Show divergence break arrow markers
input color  InpNormalColor      = clrSilver; // Line color while correlation stays coupled
input color  InpBreakdownColor   = clrWhite;  // Line color while correlation is decoupled
input color  InpZScoreColor      = clrGray;   // Histogram color for the spread z-score

//--- indicator buffers
double CorrBuffer[];
double CorrColorBuffer[];
double ZScoreBuffer[];
double ArrowUpBuffer[];
double ArrowDownBuffer[];

//--- internal working arrays (not plotted)
double CurRet[];
double RefRet[];
double Spread[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, CorrBuffer,      INDICATOR_DATA);
   SetIndexBuffer(1, CorrColorBuffer, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, ZScoreBuffer,    INDICATOR_DATA);
   SetIndexBuffer(3, ArrowUpBuffer,   INDICATOR_DATA);
   SetIndexBuffer(4, ArrowDownBuffer, INDICATOR_DATA);

   ArraySetAsSeries(CorrBuffer,      false);
   ArraySetAsSeries(CorrColorBuffer, false);
   ArraySetAsSeries(ZScoreBuffer,    false);
   ArraySetAsSeries(ArrowUpBuffer,   false);
   ArraySetAsSeries(ArrowDownBuffer, false);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   PlotIndexSetInteger(2, PLOT_ARROW, 233); // up arrow
   PlotIndexSetInteger(3, PLOT_ARROW, 234); // down arrow

   PlotIndexSetString(0, PLOT_LABEL, "Correlation vs " + InpRefSymbol);
   PlotIndexSetString(1, PLOT_LABEL, "Spread Z-Score");

   IndicatorSetString(INDICATOR_SHORTNAME,
      StringFormat("MS-CorrDiv(%s,%d)", InpRefSymbol, InpCorrPeriod));
   IndicatorSetInteger(INDICATOR_DIGITS, 3);

   if(InpCorrPeriod < 5 || InpZPeriod < 5)
     {
      Print("MultiSymbolCorrelationDivergenceMeter: period inputs must be >= 5.");
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(!SymbolSelect(InpRefSymbol, true))
      Print("MultiSymbolCorrelationDivergenceMeter: could not add ", InpRefSymbol,
            " to Market Watch. Verify the symbol name for this broker.");

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Locate the reference-symbol close price aligned to a given time  |
//+------------------------------------------------------------------+
double GetRefClose(const datetime t)
  {
   int idx = iBarShift(InpRefSymbol, PERIOD_CURRENT, t, false);
   if(idx < 0)
      return(0.0);
   return(iClose(InpRefSymbol, PERIOD_CURRENT, idx));
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
   int minBars = MathMax(InpCorrPeriod, InpZPeriod) + 2;
   if(rates_total < minBars)
      return(0);

   ArrayResize(CurRet, rates_total);
   ArrayResize(RefRet, rates_total);
   ArrayResize(Spread, rates_total);

   int start;
   if(prev_calculated <= 1)
     {
      start = 1;
      ArrayInitialize(CorrBuffer,      EMPTY_VALUE);
      ArrayInitialize(ZScoreBuffer,    EMPTY_VALUE);
      ArrayInitialize(ArrowUpBuffer,   EMPTY_VALUE);
      ArrayInitialize(ArrowDownBuffer, EMPTY_VALUE);
      ArrayInitialize(CorrColorBuffer, 0);
      CurRet[0] = 0.0;
      RefRet[0] = 0.0;
      Spread[0] = 0.0;
     }
   else
      start = prev_calculated - 1;

   //--- pass 1: build per-bar returns and log-spread series
   for(int i = start; i < rates_total; i++)
     {
      double refClose = GetRefClose(time[i]);

      if(i == 0 || refClose <= 0.0 || close[i-1] <= 0.0)
        {
         CurRet[i] = 0.0;
         RefRet[i] = 0.0;
         Spread[i] = (refClose > 0.0) ? MathLog(close[i] / refClose) : (i > 0 ? Spread[i-1] : 0.0);
         continue;
        }

      double refClosePrev = GetRefClose(time[i-1]);

      CurRet[i] = (close[i] - close[i-1]) / close[i-1];
      RefRet[i] = (refClosePrev > 0.0) ? (refClose - refClosePrev) / refClosePrev : 0.0;
      Spread[i] = MathLog(close[i] / refClose);
     }

   //--- pass 2: rolling correlation, rolling z-score, divergence flags
   for(int i = start; i < rates_total; i++)
     {
      if(i < InpCorrPeriod || i < InpZPeriod)
        {
         CorrBuffer[i]      = EMPTY_VALUE;
         ZScoreBuffer[i]    = EMPTY_VALUE;
         ArrowUpBuffer[i]   = EMPTY_VALUE;
         ArrowDownBuffer[i] = EMPTY_VALUE;
         CorrColorBuffer[i] = 0;
         continue;
        }

      //--- Pearson correlation of returns over InpCorrPeriod bars
      double sumX = 0.0, sumY = 0.0, sumXY = 0.0, sumX2 = 0.0, sumY2 = 0.0;
      for(int k = i - InpCorrPeriod + 1; k <= i; k++)
        {
         sumX  += CurRet[k];
         sumY  += RefRet[k];
         sumXY += CurRet[k] * RefRet[k];
         sumX2 += CurRet[k] * CurRet[k];
         sumY2 += RefRet[k] * RefRet[k];
        }

      double n = (double)InpCorrPeriod;
      double numerator   = (n * sumXY) - (sumX * sumY);
      double denominator = MathSqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY));
      double corr = (denominator != 0.0) ? (numerator / denominator) : 0.0;
      corr = MathMax(-1.0, MathMin(1.0, corr));

      CorrBuffer[i]      = corr;
      CorrColorBuffer[i] = (MathAbs(corr) < InpCorrLowThreshold) ? 1 : 0;

      //--- z-score of the log spread over InpZPeriod bars
      double meanS = 0.0;
      for(int k = i - InpZPeriod + 1; k <= i; k++)
         meanS += Spread[k];
      meanS /= InpZPeriod;

      double varS = 0.0;
      for(int k = i - InpZPeriod + 1; k <= i; k++)
         varS += (Spread[k] - meanS) * (Spread[k] - meanS);
      varS /= InpZPeriod;
      double stdS = MathSqrt(varS);

      double z = (stdS > 0.0) ? (Spread[i] - meanS) / stdS : 0.0;
      ZScoreBuffer[i] = z;

      //--- divergence break: correlation decoupled + spread stretched
      ArrowUpBuffer[i]   = EMPTY_VALUE;
      ArrowDownBuffer[i] = EMPTY_VALUE;

      if(InpArrowsEnabled && MathAbs(corr) < InpCorrLowThreshold)
        {
         if(z <= -InpZScoreThreshold)
            ArrowUpBuffer[i] = corr;
         else if(z >= InpZScoreThreshold)
            ArrowDownBuffer[i] = corr;
        }
     }

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
