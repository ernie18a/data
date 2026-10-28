//+------------------------------------------------------------------+
//|                                              TrueCostReport.mq5  |
//|        What one round trip actually costs on YOUR broker, and    |
//|        how far your backtest's assumption is from it             |
//+------------------------------------------------------------------+
#property copyright "TrueCostReport"
#property version   "1.00"
#property description "Measures what a round trip really costs on your account: the live"
#property description "spread sampled from ticks, the swap for both sides including the"
#property description "triple-charge day, and the commission read from your own deals."
#property description ""
#property description "Then it shows the same spread as the M1 bar field reports it - the"
#property description "number most filters and simulators use, and which understates the"
#property description "real quote by a factor you can watch on screen."
#property description ""
#property description "Read-only: it never opens, closes or modifies a position."
#property strict

//+------------------------------------------------------------------+
//| WHY THIS EXISTS                                                   |
//|                                                                   |
//| Cost is the one input to a trading system that is knowable        |
//| exactly, and it is almost always estimated wrongly - always in    |
//| the direction that flatters the strategy.                         |
//|                                                                   |
//| The usual source of a spread figure is the `spread` field of a    |
//| price bar, because it is the one that is easy to reach from a     |
//| script or a backtest. That field is a PER-BAR SUMMARY, not the    |
//| quote at any instant. Measured on XAUUSD: the live spread was 20  |
//| points across 60 consecutive readings while the M1 bar field had  |
//| a median of 6. A factor of 3.3.                                   |
//|                                                                   |
//| Anything built on that field inherits the error. A spread filter  |
//| set to "skip if spread > 15" never fires, because the number it   |
//| reads is a third of the truth - so it lets through precisely the  |
//| moments it exists to block. A backtest charging that spread       |
//| reports a system that is cheaper to run than the real one.        |
//|                                                                   |
//| The second half of the cost is the part almost no simulator       |
//| charges at all: swap. It is asymmetric - one side usually pays    |
//| while the other collects - and one weekday is charged three       |
//| times. On a system that holds positions overnight this is not a   |
//| detail. Measured on gold, per 0.01 lot per night: -0.805 long,    |
//| +0.327 short, and Wednesday triple. A basket of four legs each    |
//| way costs about 1.92 a night simply to exist, which over a year   |
//| exceeds most of the edges people are trying to capture.           |
//|                                                                   |
//| So this EA measures all three - spread, swap, commission - on     |
//| YOUR broker and YOUR symbol, states the round trip in account     |
//| currency, and puts the bar-field number next to it so the size of |
//| the usual error is visible rather than argued about.              |
//|                                                                   |
//| WHAT IT DOES NOT DO                                               |
//|                                                                   |
//| It does not model slippage, which cannot be measured without      |
//| trading, and it does not tell you whether a strategy is viable.   |
//| It measures the toll. What you carry over it is your business.    |
//+------------------------------------------------------------------+

input group "=== Measurement ==="
input int    InpSampleSeconds = 90;     // Seconds to sample the live spread
input double InpLots          = 0.01;   // Lot size to price the cost for
input int    InpBarsToCompare = 120;    // M1 bars for the bar-field comparison
input int    InpDealDays      = 30;     // Days of deals to read commission from

input group "=== Display ==="
input bool   InpShowPanel     = true;   // Draw the panel on the chart
input int    InpCorner        = 0;      // Corner: 0 TL, 1 TR, 2 BL, 3 BR
input int    InpFontSize      = 9;      // Panel font size
input color  InpColorText     = clrGainsboro;
input color  InpColorGood     = clrMediumSeaGreen;
input color  InpColorWarn     = clrOrange;
input color  InpColorBad      = clrTomato;

#define PREFIX "TCR_"

//--- one place for everything measured
struct Cost
{
   bool     done;
   string   problem;

   int      samples;          // how many ticks were looked at
   int      distinct;         // how many DIFFERENT quotes were seen
   double   liveMedianPts;    // median live spread, in points
   double   liveMinPts;
   double   liveMaxPts;

   int      barsRead;
   double   barMedianPts;     // median of the M1 bar spread field
   double   ratio;            // live / bar

   double   pointValue;       // account currency per point at InpLots
   double   spreadCost;       // one round trip, in account currency
   double   commissionPerLot; // from real deals, round turn
   double   commissionCost;
   double   totalRoundTrip;
   double   backtestRoundTrip;// what the bar field would have charged

   double   swapLong;         // per InpLots per night, account currency
   double   swapShort;
   string   swapModeName;
   bool     swapKnown;
   int      tripleDay;        // day of week charged three times
   double   carryBothSides;   // holding one lot each way, per night
};

Cost   g_c;
double g_samples[];
int    g_panelLines = 0;
datetime g_start = 0;
bool   g_sampling = false;

//+------------------------------------------------------------------+
//| Account currency per POINT at InpLots.                            |
//| From tick value and tick size rather than contract size: a CFD    |
//| index, a metal and a currency pair disagree about what "contract  |
//| size" means, and a symbol whose profit currency is not the        |
//| account currency needs a conversion the tick value already holds. |
//+------------------------------------------------------------------+
double PointValue()
{
   double tv = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double pt = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(tv <= 0.0 || ts <= 0.0 || pt <= 0.0)
      return 0.0;
   return InpLots * tv * pt / ts;
}

//+------------------------------------------------------------------+
//| Median of an array. Sorted in place - the caller does not need    |
//| the original order back.                                          |
//+------------------------------------------------------------------+
double Median(double &a[])
{
   int n = ArraySize(a);
   if(n == 0)
      return 0.0;
   ArraySort(a);
   if(n % 2 == 1)
      return a[n / 2];
   return (a[n / 2 - 1] + a[n / 2]) / 2.0;
}

//+------------------------------------------------------------------+
//| The commission your broker actually charged, per lot, round turn. |
//|                                                                   |
//| Taken from your own closed deals rather than from any symbol      |
//| property, because commission is an ACCOUNT term, not a symbol     |
//| one: two accounts on the same broker and the same symbol can pay  |
//| different commission. There is no field to read it from.          |
//|                                                                   |
//| Zero is a legitimate answer on a spread-only account, and is      |
//| reported as such rather than as "unknown".                        |
//+------------------------------------------------------------------+
double CommissionPerLot(bool &found)
{
   found = false;
   datetime from = TimeTradeServer() - (datetime)InpDealDays * 86400;
   if(!HistorySelect(from, TimeTradeServer() + 86400))
      return 0.0;

   double comm = 0.0, vol = 0.0;
   int total = HistoryDealsTotal();
   for(int i = 0; i < total; i++)
   {
      ulong t = HistoryDealGetTicket(i);
      if(t == 0)
         continue;
      if(HistoryDealGetString(t, DEAL_SYMBOL) != _Symbol)
         continue;
      long entry = HistoryDealGetInteger(t, DEAL_ENTRY);
      if(entry != DEAL_ENTRY_IN && entry != DEAL_ENTRY_OUT && entry != DEAL_ENTRY_OUT_BY)
         continue;
      double v = HistoryDealGetDouble(t, DEAL_VOLUME);
      if(v <= 0.0)
         continue;
      comm += MathAbs(HistoryDealGetDouble(t, DEAL_COMMISSION));
      vol  += v;
   }
   if(vol <= 0.0)
      return 0.0;
   found = true;
   return comm / vol;         // both legs are in the sum, so this is round turn
}

//+------------------------------------------------------------------+
//| Swap for both sides, expressed in account currency for InpLots.   |
//|                                                                   |
//| SYMBOL_SWAP_LONG / SHORT are quoted in whatever SYMBOL_SWAP_MODE  |
//| says, and the modes are not interchangeable. Reading a points     |
//| value as if it were money - or the reverse - produces a confident |
//| wrong number, so anything this function cannot convert exactly is |
//| reported as not converted instead of being guessed.               |
//+------------------------------------------------------------------+
void SwapPerNight(Cost &c)
{
   c.swapKnown = false;
   c.swapLong = 0.0;
   c.swapShort = 0.0;
   c.tripleDay = (int)SymbolInfoInteger(_Symbol, SYMBOL_SWAP_ROLLOVER3DAYS);

   long mode = SymbolInfoInteger(_Symbol, SYMBOL_SWAP_MODE);
   double sl = SymbolInfoDouble(_Symbol, SYMBOL_SWAP_LONG);
   double ss = SymbolInfoDouble(_Symbol, SYMBOL_SWAP_SHORT);

   switch((int)mode)
   {
      case SYMBOL_SWAP_MODE_DISABLED:
         c.swapModeName = "disabled";
         c.swapKnown = true;
         return;

      case SYMBOL_SWAP_MODE_POINTS:
         c.swapModeName = "points";
         c.swapLong  = sl * c.pointValue;
         c.swapShort = ss * c.pointValue;
         c.swapKnown = true;
         break;

      case SYMBOL_SWAP_MODE_CURRENCY_DEPOSIT:
         // already in the deposit currency, quoted per one lot
         c.swapModeName = "deposit currency per lot";
         c.swapLong  = sl * InpLots;
         c.swapShort = ss * InpLots;
         c.swapKnown = true;
         break;

      case SYMBOL_SWAP_MODE_CURRENCY_SYMBOL:
         c.swapModeName = "base currency per lot (not converted)";
         c.swapLong  = sl * InpLots;
         c.swapShort = ss * InpLots;
         c.swapKnown = (AccountInfoString(ACCOUNT_CURRENCY) ==
                        SymbolInfoString(_Symbol, SYMBOL_CURRENCY_BASE));
         break;

      case SYMBOL_SWAP_MODE_CURRENCY_MARGIN:
         c.swapModeName = "margin currency per lot (not converted)";
         c.swapLong  = sl * InpLots;
         c.swapShort = ss * InpLots;
         c.swapKnown = (AccountInfoString(ACCOUNT_CURRENCY) ==
                        SymbolInfoString(_Symbol, SYMBOL_CURRENCY_MARGIN));
         break;

      default:
         // the interest and reopen modes depend on the position price and on
         // the broker's year convention: not convertible from symbol data alone
         c.swapModeName = "interest/reopen mode - see the broker's terms";
         c.swapKnown = false;
         break;
   }
   c.carryBothSides = c.swapLong + c.swapShort;
}

//+------------------------------------------------------------------+
//| The M1 bar spread field, for the comparison.                      |
//+------------------------------------------------------------------+
void BarSpread(Cost &c)
{
   c.barsRead = 0;
   c.barMedianPts = 0.0;

   MqlRates r[];
   ArraySetAsSeries(r, false);
   int want = InpBarsToCompare;
   int got = 0;
   // CopyRates returns NOTHING - not "as many as available" - when asked for
   // more bars than the terminal holds, so the request is halved rather than
   // concluding from one empty answer that there is no history.
   while(want >= 10)
   {
      got = CopyRates(_Symbol, PERIOD_M1, 0, want, r);
      if(got > 0)
         break;
      want /= 2;
   }
   if(got <= 0)
      return;

   double v[];
   ArrayResize(v, got);
   for(int i = 0; i < got; i++)
      v[i] = (double)r[i].spread;
   c.barsRead = got;
   c.barMedianPts = Median(v);
}

//+------------------------------------------------------------------+
//| Everything that does not need the sampling loop.                  |
//+------------------------------------------------------------------+
void Finish(Cost &c)
{
   int n = ArraySize(g_samples);
   if(n == 0)
   {
      c.problem = "no ticks arrived in " + IntegerToString(InpSampleSeconds) +
                  "s - is the market open?";
      c.done = true;
      return;
   }

   // IS THE MARKET ACTUALLY OPEN? Found by running this EA on a Sunday, which is
   // exactly the check it was missing.
   //
   // With the market closed the terminal keeps handing out the last tick it saw,
   // so the sampling loop collects hundreds of readings and every one of them is
   // the same frozen weekend quote. On the symbol this was written for that quote
   // was 50 points against a working-hours median of 20 - a number that looks like
   // a measurement, is stable, and is wrong by two and a half times.
   //
   // The test uses the trap it documents: TimeCurrent() is the time of the LAST
   // TICK and freezes with the market, while TimeTradeServer() keeps running. The
   // gap between them is therefore exactly how stale the quote is.
   long stale = (long)(TimeTradeServer() - TimeCurrent());
   if(stale > 600)
   {
      c.problem = StringFormat("market appears closed - the last tick is %.1f hours old. "
                               "The spread you would measure now is the frozen weekend "
                               "quote, not the cost of trading. Re-run during a session.",
                               stale / 3600.0);
      c.done = true;
      return;
   }

   // Distinct quotes matter more than the raw count. A feed that repeats the
   // same value hundreds of times has been decimated somewhere, and a median
   // over those repeats describes the decimation rather than the market.
   double sorted[];
   ArrayCopy(sorted, g_samples);
   ArraySort(sorted);
   int distinct = 1;
   for(int i = 1; i < n; i++)
      if(MathAbs(sorted[i] - sorted[i - 1]) > 1e-9)
         distinct++;

   c.samples = n;
   c.distinct = distinct;
   c.liveMedianPts = Median(sorted);
   c.liveMinPts = sorted[0];
   c.liveMaxPts = sorted[n - 1];

   c.pointValue = PointValue();
   BarSpread(c);
   c.ratio = (c.barMedianPts > 0.0 ? c.liveMedianPts / c.barMedianPts : 0.0);

   bool haveComm = false;
   c.commissionPerLot = CommissionPerLot(haveComm);
   c.commissionCost = c.commissionPerLot * InpLots;

   c.spreadCost = c.liveMedianPts * c.pointValue;
   c.totalRoundTrip = c.spreadCost + c.commissionCost;
   c.backtestRoundTrip = c.barMedianPts * c.pointValue + c.commissionCost;

   SwapPerNight(c);
   c.done = true;
}

//+------------------------------------------------------------------+
//| Panel                                                             |
//+------------------------------------------------------------------+
void ClearPanel()
{
   ObjectsDeleteAll(0, PREFIX);
   g_panelLines = 0;
}

void Line(string text, color col)
{
   string name = PREFIX + IntegerToString(g_panelLines);
   int y = 16 + g_panelLines * (InpFontSize + 6);
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, InpCorner);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, 12);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpFontSize);
   ObjectSetInteger(0, name, OBJPROP_COLOR, col);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetString(0, name, OBJPROP_FONT, "Consolas");
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   g_panelLines++;
}

string DayName(int d)
{
   string n[] = {"Sunday", "Monday", "Tuesday", "Wednesday",
                 "Thursday", "Friday", "Saturday"};
   if(d < 0 || d > 6)
      return "unknown";
   return n[d];
}

void DrawPanel(const Cost &c)
{
   ClearPanel();
   if(!InpShowPanel)
      return;

   string cur = AccountInfoString(ACCOUNT_CURRENCY);

   if(!c.done)
   {
      int left = InpSampleSeconds - (int)(TimeLocal() - g_start);
      Line(StringFormat("TRUE COST  %s  -  sampling the live spread, %ds left",
                        _Symbol, MathMax(0, left)), InpColorText);
      Line(StringFormat("  %d ticks so far", ArraySize(g_samples)), InpColorText);
      ChartRedraw();
      return;
   }
   if(c.problem != "")
   {
      Line("TRUE COST - cannot measure", InpColorBad);
      Line(c.problem, InpColorBad);
      ChartRedraw();
      return;
   }

   Line(StringFormat("TRUE COST  %s  at %.2f lots", _Symbol, InpLots), InpColorText);
   Line("", InpColorText);
   Line(StringFormat("live spread   median %6.1f pts   (min %.0f, max %.0f)",
                     c.liveMedianPts, c.liveMinPts, c.liveMaxPts), InpColorText);
   Line(StringFormat("              from %d ticks, %d distinct quotes",
                     c.samples, c.distinct),
        (c.distinct < 5 ? InpColorWarn : InpColorText));
   Line(StringFormat("M1 bar field  median %6.1f pts   over %d bars",
                     c.barMedianPts, c.barsRead), InpColorText);

   color cr = (c.ratio >= 2.0 ? InpColorBad
               : (c.ratio >= 1.3 ? InpColorWarn : InpColorGood));
   if(c.ratio > 0.0)
      Line(StringFormat("RATIO         live is %.2fx the bar field", c.ratio), cr);
   Line("", InpColorText);

   Line(StringFormat("one round trip     %8.4f %s   (spread %.4f + commission %.4f)",
                     c.totalRoundTrip, cur, c.spreadCost, c.commissionCost), InpColorText);
   Line(StringFormat("a backtest on the bar field would charge  %.4f %s",
                     c.backtestRoundTrip, cur), cr);
   Line("", InpColorText);

   if(c.swapKnown)
   {
      Line(StringFormat("swap per night     long %+8.4f   short %+8.4f  %s",
                        c.swapLong, c.swapShort, cur), InpColorText);
      Line(StringFormat("                   %s is charged three times",
                        DayName(c.tripleDay)), InpColorText);
      color cc = (c.carryBothSides < 0.0 ? InpColorWarn : InpColorText);
      Line(StringFormat("holding both sides %+8.4f per night  = %+8.2f per year",
                        c.carryBothSides, c.carryBothSides * 365.0), cc);
   }
   else
      Line("swap: " + c.swapModeName + " - not converted, see broker terms",
           InpColorWarn);

   ChartRedraw();
}

//+------------------------------------------------------------------+
void PrintReport(const Cost &c)
{
   string cur = AccountInfoString(ACCOUNT_CURRENCY);
   if(c.problem != "")
   {
      Print("TrueCostReport: ", c.problem);
      return;
   }

   PrintFormat("TrueCostReport: %s at %.2f lots, account currency %s",
               _Symbol, InpLots, cur);
   PrintFormat("  live spread: median %.1f points from %d ticks (%d distinct quotes), "
               "min %.0f max %.0f",
               c.liveMedianPts, c.samples, c.distinct, c.liveMinPts, c.liveMaxPts);
   PrintFormat("  M1 bar spread field: median %.1f points over %d bars",
               c.barMedianPts, c.barsRead);
   if(c.ratio > 0.0)
      PrintFormat("  THE LIVE SPREAD IS %.2f TIMES THE BAR FIELD", c.ratio);
   PrintFormat("  one round trip costs %.4f %s (spread %.4f + commission %.4f)",
               c.totalRoundTrip, cur, c.spreadCost, c.commissionCost);
   PrintFormat("  a filter or a backtest reading the bar field would charge %.4f - "
               "a difference of %.4f per trade",
               c.backtestRoundTrip, c.totalRoundTrip - c.backtestRoundTrip);

   if(c.swapKnown)
   {
      PrintFormat("  swap per night at %.2f lots: long %+.4f, short %+.4f (%s), "
                  "%s charged three times",
                  InpLots, c.swapLong, c.swapShort, c.swapModeName, DayName(c.tripleDay));
      PrintFormat("  holding one position each way costs %+.4f a night, %+.2f a year",
                  c.carryBothSides, c.carryBothSides * 365.0);
   }
   else
      Print("  swap mode is '", c.swapModeName,
            "' - not convertible from symbol data alone, read the broker's terms");

   if(c.distinct < 5)
      Print("  WARNING: only ", c.distinct, " distinct quotes in ", c.samples,
            " ticks. Either the market is very quiet, or this feed is decimated - "
            "in the second case the median describes the decimation, not the market. "
            "Re-run during an active session.");
   if(c.ratio >= 2.0)
      Print("  WARNING: the bar field understates the live spread by more than 2x on "
            "this symbol. Any spread filter or cost model built on it is wrong by "
            "that factor, and wrong in the direction that flatters the strategy.");
}

//+------------------------------------------------------------------+
int OnInit()
{
   ZeroMemory(g_c);
   ArrayResize(g_samples, 0);
   g_start = TimeLocal();
   g_sampling = true;
   // Sampling has to be time-based, not tick-based: OnTick fires only when the
   // market moves, and a quiet symbol would never finish. A fast timer also
   // catches quote changes that do not move the last price.
   EventSetMillisecondTimer(200);
   DrawPanel(g_c);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   ClearPanel();
   ChartRedraw();
}

void OnTimer()
{
   if(g_sampling)
   {
      MqlTick t;
      if(SymbolInfoTick(_Symbol, t) && t.ask > 0.0 && t.bid > 0.0)
      {
         double pt = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         if(pt > 0.0)
         {
            int n = ArraySize(g_samples);
            ArrayResize(g_samples, n + 1);
            g_samples[n] = (t.ask - t.bid) / pt;
         }
      }
      if((int)(TimeLocal() - g_start) >= InpSampleSeconds)
      {
         g_sampling = false;
         Finish(g_c);
         PrintReport(g_c);
         EventKillTimer();
         EventSetTimer(5);      // the panel keeps refreshing, sampling does not
      }
   }
   DrawPanel(g_c);
}
//+------------------------------------------------------------------+
