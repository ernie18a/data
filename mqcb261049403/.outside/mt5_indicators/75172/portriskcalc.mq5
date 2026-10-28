//+------------------------------------------------------------------+
//|                                                 PortRiskCalc.mq5 |
//|                                       Copyright 2026, AbacuQuant |
//|                     https://www.abacuquant.com/portfolio-builder |
//+------------------------------------------------------------------+
#property copyright "AbacuQuant"
#property link      "https://www.abacuquant.com/portfolio-builder?utm_source=mql5&utm_medium=codebase&utm_campaign=port_risk_calc"
#property version    "1.00"
#property description "Computes historical correlation and combined margin risk across a list of instruments and reports the results in the Experts tab and on the chart."
#property indicator_chart_window
#property indicator_plots 0

#define MAX_SYMS 10   // Maximum number of instruments this tool supports at once.
#define MAX_BARS 500  // Maximum lookback length kept per instrument.

//--- inputs -----------------------------------------------------------------
input string          InpSymbols       = "EURUSD,GBPUSD,XAUUSD,USDJPY"; // Comma-separated symbol list (2-10 symbols)
input string          InpLots          = "0.10,0.10,0.10,0.10";        // Comma-separated lot per symbol, same order as InpSymbols
input ENUM_TIMEFRAMES InpTimeframe     = PERIOD_D1;                    // Timeframe used to build the return series
input int             InpLookbackBars  = 200;                          // Closed bars used per instrument (capped at 500)
input double          InpMarginWarnPct = 30.0;                         // Combined margin alert threshold, % of account equity
input int             InpRefreshSec    = 60;                           // Seconds between recalculations
input bool             InpShowPanel    = true;                         // Show the report with Comment() on the chart

//--- globals ------------------------------------------------------------------
string g_symbols[MAX_SYMS];          // Parsed, validated instrument list
double g_lots[MAX_SYMS];             // Lot size per instrument, aligned with g_symbols
int    g_count       = 0;            // Number of valid instruments after parsing
double g_matrix[MAX_SYMS][MAX_BARS]; // Bar-to-bar % returns per instrument, most recent first
int    g_barsUsed    = 0;            // Common number of overlapping bars available this cycle
bool   g_alerted     = false;        // True once the margin alert has fired for the current crossing

//+------------------------------------------------------------------+
//| Splits a comma-separated string into a trimmed string array.      |
//+------------------------------------------------------------------+
int SplitCsv(const string csv, string &out[])
  {
   int n = StringSplit(csv, ',', out);
   for(int i = 0; i < n; i++)
     {
      StringTrimLeft(out[i]);
      StringTrimRight(out[i]);
     }
   return n;
  }

//+------------------------------------------------------------------+
//| Parses InpSymbols/InpLots, validates each symbol is available in  |
//| Market Watch, and fills the global g_symbols/g_lots arrays. Caps  |
//| the list at MAX_SYMS and requires at least 2 valid symbols.       |
//+------------------------------------------------------------------+
bool ParseInputs()
  {
   string symArr[], lotArr[];
   int nSym = SplitCsv(InpSymbols, symArr);
   int nLot = SplitCsv(InpLots, lotArr);

   if(nSym < 2)
     {
      Print("PortRiskCalc: need at least 2 symbols in InpSymbols.");
      return false;
     }
   if(nSym > MAX_SYMS)
     {
      Print("PortRiskCalc: ", nSym, " symbols given, only the first ", MAX_SYMS, " will be used.");
      nSym = MAX_SYMS;
     }

   g_count = 0;
   for(int i = 0; i < nSym; i++)
     {
      string sym = symArr[i];
      if(!SymbolSelect(sym, true))
        {
         Print("PortRiskCalc: symbol not available, skipped: ", sym);
         continue;
        }
      double lot = (i < nLot) ? StringToDouble(lotArr[i]) : 0.10;
      if(lot <= 0.0)
         lot = 0.10;

      g_symbols[g_count] = sym;
      g_lots[g_count]    = lot;
      g_count++;
     }

   if(g_count < 2)
     {
      Print("PortRiskCalc: fewer than 2 valid symbols after validation, cannot compute correlation.");
      return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Pearson correlation coefficient between the return series stored  |
//| in g_matrix rows rowA and rowB, over the first n bars. Returns    |
//| 0.0 if either series has zero variance (flat prices).             |
//+------------------------------------------------------------------+
double PearsonCorrelation(int rowA, int rowB, int n)
  {
   double meanA = 0.0, meanB = 0.0;
   for(int i = 0; i < n; i++)
     {
      meanA += g_matrix[rowA][i];
      meanB += g_matrix[rowB][i];
     }
   meanA /= n;
   meanB /= n;

   double cov = 0.0, varA = 0.0, varB = 0.0;
   for(int i = 0; i < n; i++)
     {
      double da = g_matrix[rowA][i] - meanA;
      double db = g_matrix[rowB][i] - meanB;
      cov  += da * db;
      varA += da * da;
      varB += db * db;
     }
   if(varA <= 0.0 || varB <= 0.0)
      return 0.0;
   return cov / MathSqrt(varA * varB);
  }

//+------------------------------------------------------------------+
//| Loads closing prices for one symbol (skipping the still-forming   |
//| current bar) and converts them into a bar-to-bar percentage       |
//| return series. Returns false if fewer than 30 bars are available. |
//+------------------------------------------------------------------+
bool LoadReturns(const string symbol, double &returns[])
  {
   double closeArr[];
   ArraySetAsSeries(closeArr, true);
   int bars = MathMin(InpLookbackBars, MAX_BARS);
   int copied = CopyClose(symbol, InpTimeframe, 1, bars, closeArr);
   if(copied < 30)
     {
      Print("PortRiskCalc: not enough history for ", symbol, " (", copied, " bars).");
      return false;
     }
   ArrayResize(returns, copied - 1);
   for(int i = 0; i < copied - 1; i++)
      returns[i] = (closeArr[i] - closeArr[i + 1]) / closeArr[i + 1] * 100.0;
   return true;
  }

//+------------------------------------------------------------------+
//| Estimated margin, in account currency, to open `lot` lots of      |
//| `symbol` at the current ask price. Returns 0.0 if the broker      |
//| cannot price the symbol right now.                                |
//+------------------------------------------------------------------+
double SymbolMargin(const string symbol, double lot)
  {
   double price = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double margin = 0.0;
   if(price <= 0.0 || !OrderCalcMargin(ORDER_TYPE_BUY, symbol, lot, price, margin))
      return 0.0;
   return margin;
  }

//+------------------------------------------------------------------+
//| Rebuilds the return series for every instrument, recomputes the   |
//| correlation matrix and the combined margin load, prints the       |
//| report, updates the on-chart Comment(), and fires the margin      |
//| alert once per fresh threshold crossing.                          |
//+------------------------------------------------------------------+
void Recalculate()
  {
   if(g_count < 2)
      return;

   int commonLen = MathMin(InpLookbackBars, MAX_BARS) - 1;
   for(int i = 0; i < g_count; i++)
     {
      double r[];
      if(!LoadReturns(g_symbols[i], r))
        {
         if(InpShowPanel)
            Comment("PortRiskCalc: waiting for enough price history for ", g_symbols[i], "...");
         return;
        }
      int len = MathMin(ArraySize(r), commonLen);
      if(len < commonLen)
         commonLen = len;
      for(int b = 0; b < len && b < MAX_BARS; b++)
         g_matrix[i][b] = r[b];
     }
   g_barsUsed = commonLen;

   if(g_barsUsed < 30)
     {
      if(InpShowPanel)
         Comment("PortRiskCalc: not enough overlapping history yet (", g_barsUsed, " bars).");
      return;
     }

   //--- correlation matrix + running average -----------------------------
   double corrSum   = 0.0;
   int    corrPairs = 0;
   string report = "=== Portfolio Correlation & Risk Calculator ===\n";
   report += "Timeframe: " + EnumToString(InpTimeframe) + "   Lookback: " + IntegerToString(g_barsUsed) + " bars\n\n";
   report += "Correlation matrix:\n";

   for(int i = 0; i < g_count; i++)
     {
      report += StringFormat("%-8s", g_symbols[i]);
      for(int j = 0; j < g_count; j++)
        {
         double c = (i == j) ? 1.0 : PearsonCorrelation(i, j, g_barsUsed);
         if(j > i)
           {
            corrSum += c;
            corrPairs++;
           }
         report += StringFormat("  %+.2f", c);
        }
      report += "\n";
     }

   double avgCorr = (corrPairs > 0) ? corrSum / corrPairs : 0.0;
   report += "\nAverage pairwise correlation: " + DoubleToString(avgCorr, 2) + "\n";

   //--- combined margin load ------------------------------------------------
   double totalMargin = 0.0;
   for(int i = 0; i < g_count; i++)
      totalMargin += SymbolMargin(g_symbols[i], g_lots[i]);

   double equity  = AccountInfoDouble(ACCOUNT_EQUITY);
   double loadPct = (equity > 0.0) ? totalMargin / equity * 100.0 : 0.0;

   report += "\nEstimated combined margin: " + DoubleToString(totalMargin, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY);
   report += "\nDeposit load: " + DoubleToString(loadPct, 1) + "% of equity\n";

   if(loadPct >= InpMarginWarnPct)
     {
      report += "\n*** WARNING: deposit load is above the " + DoubleToString(InpMarginWarnPct, 0) + "% threshold. ***\n";
      if(!g_alerted)
        {
         Alert(StringFormat(
            "PortRiskCalc: combined deposit load is %.1f%%, above your %.0f%% threshold. " +
            "See audited diversified-portfolio examples at https://www.abacuquant.com/portfolio-builder?utm_source=mql5&utm_medium=alert&utm_campaign=port_risk_calc",
            loadPct, InpMarginWarnPct));
         g_alerted = true;
        }
     }
   else
      g_alerted = false; // Allow the alert to fire again on the next crossing.

   report += "\n---\nFree tool by AbacuQuant. Full methodology, verified multi-strategy portfolios and\n";
   report += "24-month audited backtests: https://www.abacuquant.com/portfolio-builder?utm_source=mql5&utm_medium=codebase&utm_campaign=port_risk_calc\n";

   if(InpShowPanel)
      Comment(report);
   Print(report);
  }

//+------------------------------------------------------------------+
//| Indicator initialization: parses inputs, runs one calculation     |
//| immediately, and starts the periodic refresh timer.               |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!ParseInputs())
      return(INIT_PARAMETERS_INCORRECT);

   Recalculate();
   EventSetTimer(MathMax(InpRefreshSec, 5));
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Indicator deinitialization: stops the timer and clears the panel. |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   Comment("");
  }

//+------------------------------------------------------------------+
//| Timer event: periodic recalculation. Correlation and margin load  |
//| do not need tick-level freshness, so a timer is used instead of   |
//| recomputing on every price tick.                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   Recalculate();
  }

//+------------------------------------------------------------------+
//| Standard indicator calculation event. No plot buffers are used    |
//| (indicator_plots 0 above); all the work happens in OnTimer().     |
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
   return(rates_total);
  }
//+------------------------------------------------------------------+