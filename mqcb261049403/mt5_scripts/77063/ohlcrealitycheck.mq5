//+------------------------------------------------------------------+
//|                                            OHLCRealityCheck.mq5  |
//|                                        Copyright 2026, Petr Kostal|
//|                                             https://www.mql5.com  |
//+------------------------------------------------------------------+
//| At what stop distance does 1-minute OHLC modelling start lying?   |
//|                                                                   |
//| The script opens a virtual bracketed trade on every M1 bar - one  |
//| level above the bar open, one below, both the same distance away  |
//| - and walks forward until price reaches one of them.              |
//|                                                                   |
//| Usually the bar that ends the trade touches only one level and    |
//| there is nothing to argue about. Sometimes it touches both. Then  |
//| the ORDER decides whether the trade won or lost, and the tester's |
//| 1-minute OHLC mode does not know the order - it assumes one:      |
//| Open-Low-High-Close on a bullish bar, Open-High-Low-Close on a    |
//| bearish one. The real ticks do know it.                           |
//|                                                                   |
//| The catch is that this depends entirely on how wide the bracket   |
//| is. A swing trade with a stop hundreds of points away is almost   |
//| never in doubt. A scalp with a tight stop often is. So the script |
//| sweeps several widths and prints the curve, which answers the     |
//| question that actually matters: below which stop distance should  |
//| you stop trusting an OHLC backtest on this symbol?                |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Petr Kostal"
#property link      "https://www.mql5.com"
#property version   "3.10"
#property script_show_inputs
#property description "Sweeps several stop distances and reports, for each, how often 1-minute OHLC modelling would resolve a bracketed trade the wrong way round compared with the real ticks."

input string InpSymbol      = "";                      // Symbol (empty = chart symbol)
input int    InpDays        = 30;                      // Days back to analyse
input string InpBrackets    = "20,50,100,200,500,1000"; // Stop distances to test, in points
input int    InpHorizonBars = 240;                     // Give each trade this many M1 bars to resolve
input int    InpStepBars    = 1;                       // Open a trade every N bars (raise it to go faster)
input bool   InpWriteCSV    = true;                    // Write the mis-resolved trades to a CSV file

//--- one whole day of ticks, cached; contested bars arrive in time order,
//--- so a day-sized cache turns tens of thousands of history calls into a few
datetime g_dayStart = 0;
datetime g_dayEnd   = 0;
MqlTick  g_dayTicks[];
int      g_dayCount = 0;

//--- result of one sweep step
struct PassResult
{
   long entries;
   long resolved;
   long unresolved;
   long clean;
   long contested;
   long agree;
   long disagree;
   long noProof;
};

//+------------------------------------------------------------------+
//| Make sure the day that contains barTime is in the cache           |
//+------------------------------------------------------------------+
bool LoadDay(const string symbol, const datetime barTime)
{
   if(g_dayCount > 0 && barTime >= g_dayStart && barTime < g_dayEnd)
      return true;

   g_dayStart = barTime - (barTime % 86400);
   g_dayEnd   = g_dayStart + 86400;

   g_dayCount = CopyTicksRange(symbol, g_dayTicks, COPY_TICKS_ALL,
                               (ulong)g_dayStart * 1000,
                               (ulong)g_dayEnd * 1000 - 1);
   if(g_dayCount < 0) g_dayCount = 0;
   return (g_dayCount > 0);
}

//+------------------------------------------------------------------+
//| Index of the first cached tick at or after the given second       |
//+------------------------------------------------------------------+
int FirstTickAtOrAfter(const datetime when)
{
   int lo = 0, hi = g_dayCount;
   while(lo < hi)
   {
      int mid = (lo + hi) / 2;
      if(g_dayTicks[mid].time < when) lo = mid + 1;
      else                            hi = mid;
   }
   return lo;
}

//+------------------------------------------------------------------+
//| +1 upper first, -1 lower first, 0 the ticks prove neither         |
//+------------------------------------------------------------------+
int RealFirstTouch(const datetime barTime, const double upper, const double lower)
{
   datetime barEnd = barTime + 60;

   for(int i = FirstTickAtOrAfter(barTime); i < g_dayCount; i++)
   {
      if(g_dayTicks[i].time >= barEnd) break;

      double price = g_dayTicks[i].bid;
      if(price <= 0.0) price = g_dayTicks[i].last;
      if(price <= 0.0) continue;

      if(price >= upper) return +1;
      if(price <= lower) return -1;
   }
   return 0;
}

//+------------------------------------------------------------------+
//| What 1-minute OHLC modelling assumes about this bar               |
//+------------------------------------------------------------------+
int ModelFirstTouch(const double open, const double close)
{
   return (close >= open) ? -1 : +1;
}

//+------------------------------------------------------------------+
//| One sweep step: every bar gets a bracket of this width            |
//+------------------------------------------------------------------+
void RunPass(const string symbol, const MqlRates &rates[], const int total,
             const double bracket, const int horizon, const int digits,
             const double point, const int csv, PassResult &r)
{
   r.entries = 0; r.resolved = 0; r.unresolved = 0; r.clean = 0;
   r.contested = 0; r.agree = 0; r.disagree = 0; r.noProof = 0;

   int last = total - 1;
   int step = (InpStepBars < 1) ? 1 : InpStepBars;

   for(int i = 0; i <= last - horizon; i += step)
   {
      r.entries++;

      double entry = rates[i].open;
      double upper = entry + bracket;
      double lower = entry - bracket;

      int  closingBar = -1;
      bool bothSides  = false;

      for(int j = i; j <= i + horizon; j++)
      {
         bool up = (rates[j].high >= upper);
         bool dn = (rates[j].low  <= lower);
         if(!up && !dn) continue;

         closingBar = j;
         bothSides  = (up && dn);
         break;
      }

      if(closingBar < 0)
      {
         r.unresolved++;
         continue;
      }

      r.resolved++;

      if(!bothSides)
      {
         r.clean++;
         continue;
      }

      r.contested++;

      int modelFirst = ModelFirstTouch(rates[closingBar].open, rates[closingBar].close);

      LoadDay(symbol, rates[closingBar].time);
      int realFirst = RealFirstTouch(rates[closingBar].time, upper, lower);

      if(realFirst == 0)      { r.noProof++;  continue; }
      if(realFirst == modelFirst) { r.agree++; continue; }

      r.disagree++;

      if(csv != INVALID_HANDLE)
         FileWrite(csv,
                   DoubleToString(bracket / point, 0),
                   TimeToString(rates[i].time, TIME_DATE | TIME_MINUTES),
                   DoubleToString(entry, digits),
                   TimeToString(rates[closingBar].time, TIME_DATE | TIME_MINUTES),
                   IntegerToString(closingBar - i),
                   (modelFirst > 0 ? "upper" : "lower"),
                   (realFirst  > 0 ? "upper" : "lower"));
   }
}

//+------------------------------------------------------------------+
void OnStart()
{
   string symbol = (InpSymbol == "") ? _Symbol : InpSymbol;

   if(!SymbolSelect(symbol, true))
   {
      PrintFormat("The symbol %s is not available on this account.", symbol);
      return;
   }

   int days = InpDays;
   if(days < 1)   days = 1;
   if(days > 365) days = 365;

   int horizon = InpHorizonBars;
   if(horizon < 1)    horizon = 1;
   if(horizon > 5000) horizon = 5000;

   double point  = SymbolInfoDouble(symbol, SYMBOL_POINT);
   int    digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   if(point <= 0.0)
   {
      PrintFormat("The symbol %s reports a point size of zero.", symbol);
      return;
   }

   //--- the stop distances to sweep
   string parts[];
   int    count = StringSplit(InpBrackets, ',', parts);
   if(count <= 0)
   {
      Print("No stop distances given. Fill in InpBrackets, for example 20,50,100,200.");
      return;
   }

   datetime to   = TimeCurrent();
   datetime from = to - (datetime)days * 86400;

   MqlRates rates[];
   ArraySetAsSeries(rates, false);
   int total = CopyRates(symbol, PERIOD_M1, from, to, rates);
   if(total <= horizon + 10)
   {
      PrintFormat("Only %d M1 bars are available. Download more history for %s.", total, symbol);
      return;
   }

   int csv = INVALID_HANDLE;
   if(InpWriteCSV)
   {
      string name = StringFormat("OHLCRealityCheck_%s.csv", symbol);
      csv = FileOpen(name, FILE_WRITE | FILE_CSV | FILE_ANSI, ';');
      if(csv != INVALID_HANDLE)
         FileWrite(csv, "bracket_points", "entry_time", "entry_price",
                        "closing_bar", "bars_open", "model_says", "ticks_say");
   }

   Print("--------------------------------------------------------------------");
   PrintFormat("OHLC Reality Check %s - the last %d days, %d M1 bars",
               symbol, days, total);
   PrintFormat("Every bar opens a bracketed trade with %d bars to resolve.", horizon);
   Print("--------------------------------------------------------------------");
   Print("");
   Print("  stop     trades  resolved  contested   wrong   wrong out of all");
   Print("  -----------------------------------------------------------------");

   double firstSafe = 0.0;   // narrowest stop where nothing flipped

   for(int p = 0; p < count; p++)
   {
      double pts = StringToDouble(parts[p]);
      if(pts <= 0.0) continue;

      double bracket = pts * point;

      PassResult r;
      RunPass(symbol, rates, total, bracket, horizon, digits, point, csv, r);

      if(r.resolved == 0)
      {
         PrintFormat("  %5.0f pt  %8d   nothing resolved inside the horizon", pts, (int)r.entries);
         continue;
      }

      double contestedPct = 100.0 * r.contested / r.resolved;
      double wrongPct     = 100.0 * r.disagree  / r.resolved;

      PrintFormat("  %5.0f pt  %8d  %8d  %7d (%4.1f%%)  %5d        %5.2f%%",
                  pts, (int)r.entries, (int)r.resolved,
                  (int)r.contested, contestedPct, (int)r.disagree, wrongPct);

      if(r.disagree == 0 && firstSafe == 0.0)
         firstSafe = pts;
      if(r.disagree > 0)
         firstSafe = 0.0;   // a wider stop flipped again, so there is no clean floor yet
   }

   if(csv != INVALID_HANDLE)
   {
      FileClose(csv);
      PrintFormat("  (the mis-resolved trades are listed in MQL5\\Files\\OHLCRealityCheck_%s.csv)", symbol);
   }

   Print("");
   Print("--------------------------------------------------------------------");
   Print("Read the last column as the share of ALL trades a 1-minute OHLC");
   Print("backtest would score the wrong way round: a win written down as a");
   Print("loss, or a loss written down as a win.");
   Print("");
   if(firstSafe > 0.0)
      PrintFormat("From about %.0f points upwards nothing flipped on this sample.", firstSafe);
   Print("The tighter the stop, the more the tester is describing its own");
   Print("modelling rather than the market. If your strategy's edge per trade");
   Print("is smaller than the figure in the last column, the backtest cannot");
   Print("tell you whether the edge is real. Re-run it on every tick.");
   Print("--------------------------------------------------------------------");
}
//+------------------------------------------------------------------+
