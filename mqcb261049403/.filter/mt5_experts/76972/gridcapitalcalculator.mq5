//+------------------------------------------------------------------+
//|                                       GridCapitalCalculator.mq5  |
//|          What a grid actually costs to hold, and how often the   |
//|          move that ends it has already happened                  |
//+------------------------------------------------------------------+
#property copyright "GridCapitalCalculator"
#property version   "1.00"
#property description "Tells you what capital a grid or martingale configuration really needs:"
#property description "the floating loss of a full chain, the margin it locks up, and the exact"
#property description "adverse move that reaches your broker's stop-out level."
#property description ""
#property description "Then it counts how often a move that size has already happened on this"
#property description "symbol's own history, so the answer is a frequency and not a guess."
#property description ""
#property description "Strictly read-only: it never opens, closes or modifies any position."
#property strict

//+------------------------------------------------------------------+
//| WHY THIS EXISTS                                                   |
//|                                                                   |
//| Everyone who runs a grid asks the same question - "is my account  |
//| big enough?" - and almost everyone answers it with the wrong      |
//| number. The usual answer is the loss at the last grid level. That |
//| is not what ends the account. What ends the account is the margin |
//| level reaching the broker's stop-out threshold, which happens     |
//| while the chain is still open and still "recoverable".            |
//|                                                                   |
//| The arithmetic is not hard, but three parts of it are easy to get |
//| wrong, and each one errs in the reassuring direction:             |
//|                                                                   |
//|  - a chain of N legs one step apart does NOT float at step x N.   |
//|    The oldest leg is (N-1) steps away, the next (N-2), and so on, |
//|    so the total is step x N(N-1)/2. At 10 legs that is 45 steps   |
//|    of loss, not 10.                                               |
//|                                                                   |
//|  - the positions also LOCK UP margin while they float. Free       |
//|    margin falls for both reasons at once, and the stop-out        |
//|    compares equity against the margin, so both sides of the       |
//|    fraction move against you together.                            |
//|                                                                   |
//|  - stop-out is a percentage, not zero. An account does not need   |
//|    to lose everything. At the common 50% level, half the equity   |
//|    is already enough.                                             |
//|                                                                   |
//| So this tool computes the adverse move that reaches your stop-out |
//| level, in the price units of the instrument - and then does the   |
//| part that turns arithmetic into information: it scans the         |
//| symbol's own M1 history and counts how many times a move that     |
//| large has actually occurred. "You need 86 dollars of room" is an  |
//| abstraction. "A move of 86 dollars happened 71 times in the last  |
//| 100 days, one every 1.4 days" is a decision.                      |
//|                                                                   |
//| WHAT IT DOES NOT DO                                               |
//|                                                                   |
//| It does not tell you whether your strategy is profitable, and it  |
//| is not a backtest. It answers one question only: given this       |
//| configuration and this account, how far can price go against you  |
//| before the broker closes you, and how common is a move that far.  |
//|                                                                   |
//| It also does not model a recovery. A chain that survives is a     |
//| chain price came back to. This tool measures the excursion, which |
//| is the thing that decides whether you are still there when it     |
//| does come back.                                                   |
//+------------------------------------------------------------------+

input group "=== The grid you want to check ==="
input double InpGridStep      = 12.0;   // Distance between legs, in PRICE
input double InpLots          = 0.01;   // Lots per leg
input int    InpMaxLegs       = 4;      // Legs per chain (the cap)
input bool   InpBothSides     = true;   // A long chain AND a short chain

input group "=== Account assumptions ==="
input double InpEquity        = 0;      // Equity to assume (0 = the live one)
input double InpStopOutLevel  = 0;      // Stop-out %% (0 = ask the broker)

input group "=== History check ==="
input int    InpHistoryDays   = 100;    // Days of M1 history to scan (0 = skip)

input group "=== Display ==="
input bool   InpShowPanel     = true;   // Draw the panel on the chart
input int    InpCorner        = 0;      // Corner: 0 TL, 1 TR, 2 BL, 3 BR
input int    InpFontSize      = 9;      // Panel font size
input color  InpColorText     = clrGainsboro;
input color  InpColorWarn     = clrOrange;
input color  InpColorBad      = clrTomato;
input int    InpRefreshSec    = 10;     // Recompute every N seconds

#define PREFIX "GCC_"

//--- everything the calculation produces, in one place
struct Report
{
   bool     valid;
   string   problem;

   double   moneyPerUnit;      // account currency per 1.0 of price, at InpLots
   double   marginPerLeg;
   double   chainSpan;         // price distance from newest to oldest leg
   double   floatingFull;      // loss when the chain is full and price has just filled it
   double   marginOneChain;
   double   marginBothSides;
   double   marginUsed;        // what the broker will actually charge
   double   equity;
   double   stopOutLevel;
   double   stopOutEquity;     // equity at which the broker acts
   double   runToFill;         // adverse move that fills the chain
   double   runToStopOut;      // adverse move that reaches stop-out
   int      legsAtStopOut;     // how many legs are actually open when it happens
   double   sharePercent;      // full chain as % of equity

   int      barsScanned;
   double   daysScanned;
   int      runsDown;
   int      runsUp;
   int      runsWorst;
   double   oneEvery;          // days between events, on the worse side
};

Report g_r;
int    g_panelLines = 0;

//+------------------------------------------------------------------+
//| Account currency per 1.0 unit of price, for InpLots.              |
//|                                                                   |
//| Derived from the symbol's tick value and tick size rather than    |
//| from contract size, because that is the only formulation that is  |
//| correct for every instrument class - a CFD index, a metal and a   |
//| currency pair all disagree about what "contract size" means, and  |
//| a cross whose profit currency is not the account currency needs   |
//| a conversion the tick value already contains.                     |
//+------------------------------------------------------------------+
double MoneyPerPriceUnit()
{
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(tickSize <= 0.0 || tickValue <= 0.0)
      return 0.0;
   return InpLots * tickValue / tickSize;
}

//+------------------------------------------------------------------+
//| Margin for a single leg, asked of the terminal instead of derived.|
//| Leverage, margin rates and per-symbol margin rules differ between |
//| brokers and sometimes between sessions; OrderCalcMargin is the    |
//| only source that knows all of them.                               |
//+------------------------------------------------------------------+
double MarginPerLeg()
{
   double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   if(price <= 0.0)
      return 0.0;
   double m = 0.0;
   if(!OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, InpLots, price, m))
      return 0.0;
   return m;
}

//+------------------------------------------------------------------+
//| Margin charged when both chains are open at the same depth.       |
//|                                                                   |
//| On a hedging account the two sides usually offset: the broker     |
//| charges the larger side, not the sum. This is worth stating       |
//| because it is counter-intuitive and it moves the answer a lot -   |
//| measured on a live account, 6 long plus 2 short positions were    |
//| charged for 6, not 8.                                             |
//|                                                                   |
//| SYMBOL_MARGIN_HEDGED carries the broker's rule. Where it is zero  |
//| or equals the full contract size the offset applies; where the    |
//| account is netting there is only one position per side anyway.    |
//| When the rule cannot be read the tool assumes the EXPENSIVE case  |
//| (the sum), because an assumption about your own safety should     |
//| never be the optimistic one.                                      |
//+------------------------------------------------------------------+
double MarginBothSides(double marginOneChain, bool &offsetApplies)
{
   offsetApplies = false;
   long mode = (long)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
   if(mode != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
      return marginOneChain * 2.0;        // netting: no second chain to speak of

   double hedged = SymbolInfoDouble(_Symbol, SYMBOL_MARGIN_HEDGED);
   double contract = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   if(hedged <= 0.0 || (contract > 0.0 && MathAbs(hedged - contract) < 1e-8))
   {
      offsetApplies = true;
      return marginOneChain;              // the larger side only
   }
   return marginOneChain * 2.0;
}

//+------------------------------------------------------------------+
//| The stop-out level the broker will actually use.                  |
//| ACCOUNT_MARGIN_SO_SO is a percentage when SO_MODE is PERCENT and  |
//| a money amount when it is MONEY - the two are not interchangeable |
//| and reading one as the other silently produces nonsense.          |
//+------------------------------------------------------------------+
bool StopOutPercent(double &level)
{
   if(InpStopOutLevel > 0.0)
   {
      level = InpStopOutLevel;
      return true;
   }
   long mode = (long)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE);
   if(mode != ACCOUNT_STOPOUT_MODE_PERCENT)
      return false;
   level = AccountInfoDouble(ACCOUNT_MARGIN_SO_SO);
   return (level > 0.0);
}

//+------------------------------------------------------------------+
//| Count adverse runs of at least "size" in the close series.        |
//|                                                                   |
//| An "adverse run" for a long chain is a fall of "size" from a      |
//| running high. Once one is counted the search restarts from that   |
//| point, so a single long decline counts once rather than once per  |
//| bar - counting every bar would inflate the number by hundreds and |
//| the whole value of this figure is that it is comparable to a      |
//| number of days.                                                   |
//|                                                                   |
//| The restart is at j+1, not j: the bar that completed a run cannot |
//| also be the first bar of the next one. Restarting at j instead    |
//| changes the count by about one event in sixty at the tightest     |
//| thresholds. It is a boundary choice rather than a correctness     |
//| one, recorded here so the next reader does not treat it as a bug. |
//+------------------------------------------------------------------+
int CountRuns(const double &close[], int n, double size, bool downward)
{
   if(n < 2 || size <= 0.0)
      return 0;
   int count = 0;
   int i = 0;
   while(i < n)
   {
      double extreme = close[i];
      int j = i;
      bool hit = false;
      while(j < n)
      {
         if(downward)
         {
            if(close[j] > extreme)
               extreme = close[j];
            if(extreme - close[j] >= size)
            {
               hit = true;
               break;
            }
         }
         else
         {
            if(close[j] < extreme)
               extreme = close[j];
            if(close[j] - extreme >= size)
            {
               hit = true;
               break;
            }
         }
         j++;
      }
      if(!hit)
         break;
      count++;
      i = j + 1;
   }
   return count;
}

//+------------------------------------------------------------------+
//| The whole calculation.                                            |
//+------------------------------------------------------------------+
void Compute(Report &r)
{
   ZeroMemory(r);
   r.valid = false;

   if(InpMaxLegs < 1)          { r.problem = "InpMaxLegs must be at least 1"; return; }
   if(InpGridStep <= 0.0)      { r.problem = "InpGridStep must be greater than zero"; return; }

   r.moneyPerUnit = MoneyPerPriceUnit();
   if(r.moneyPerUnit <= 0.0)
   {
      r.problem = "Cannot read tick value/size for " + _Symbol +
                  " - open the symbol in Market Watch first";
      return;
   }
   r.marginPerLeg = MarginPerLeg();
   if(r.marginPerLeg <= 0.0)
   {
      r.problem = "OrderCalcMargin refused " + _Symbol +
                  " at " + DoubleToString(InpLots, 2) + " lots";
      return;
   }

   int n = InpMaxLegs;

   // A chain of n legs one step apart spans (n-1) steps. Its floating loss the moment the
   // last leg opens is step x (0 + 1 + ... + (n-1)) = step x n(n-1)/2, in price, times the
   // money value of one price unit. This is the sum most people replace with step x n.
   r.chainSpan    = InpGridStep * (n - 1);
   r.floatingFull = r.moneyPerUnit * InpGridStep * n * (n - 1) / 2.0;

   r.marginOneChain = r.marginPerLeg * n;
   bool offset = false;
   r.marginBothSides = MarginBothSides(r.marginOneChain, offset);
   r.marginUsed = (InpBothSides ? r.marginBothSides : r.marginOneChain);

   r.equity = (InpEquity > 0.0 ? InpEquity : AccountInfoDouble(ACCOUNT_EQUITY));
   if(r.equity <= 0.0)
   {
      r.problem = "No equity to work with - set InpEquity";
      return;
   }

   if(!StopOutPercent(r.stopOutLevel))
   {
      // The broker states stop-out in money, not percent. Rather than invent a percentage,
      // the tool says so and falls back to a level the user can override.
      r.stopOutLevel = 50.0;
      r.problem = "Broker states stop-out in money, not percent - assuming 50%. " +
                  "Set InpStopOutLevel to your own figure.";
   }
   r.stopOutEquity = r.marginUsed * r.stopOutLevel / 100.0;

   r.runToFill = r.chainSpan;
   r.sharePercent = 100.0 * (r.floatingFull + r.marginUsed) / r.equity;

   // THE ADVERSE MOVE THAT REACHES STOP-OUT.
   //
   // The obvious version of this is wrong, and wrong in a way that matters most on exactly
   // the small accounts this tool is for. Assuming the chain is always full charges the
   // margin of n legs at a moment when only two of them exist, and on a small account with a
   // wide step that produces "you are already dead" for a configuration whose real answer is
   // a perfectly ordinary move.
   //
   // The chain fills as price travels. With price M below the seed, the number of legs open
   // is k = floor(M/step)+1, capped at n. For a given k:
   //
   //     floating(M) = perUnit x ( k x M - step x k(k-1)/2 )
   //     margin      = marginPerLeg x k
   //
   // and the broker acts when equity - floating(M) <= marginPerLeg x k x stopOut/100.
   // Solving for M inside each band:
   //
   //     M(k) = [ equity - marginPerLeg x k x SO/100 + perUnit x step x k(k-1)/2 ]
   //            / ( perUnit x k )
   //
   // The answer is the first k whose M(k) actually falls inside that k's own band - i.e. the
   // solution is self-consistent, the chain really does hold k legs at that price. Solving
   // once for k=n and hoping is what produces the nonsense above.
   //
   // Note both sides of the fraction move against you at once: floating grows with M while
   // margin grows in steps as legs open. That is why stop-out arrives sooner than the
   // "loss at the last level" figure everyone quotes.
   r.runToStopOut = 0.0;
   r.legsAtStopOut = 0;
   for(int k = 1; k <= n; k++)
   {
      double legCost = r.marginPerLeg * (r.marginUsed / MathMax(r.marginOneChain, 1e-9));
      double threshold = legCost * k * r.stopOutLevel / 100.0;
      double low  = (k - 1) * InpGridStep;
      double high = (k < n ? k * InpGridStep : DBL_MAX);

      // FIRST, THE BOUNDARY: the instant leg k opens.
      //
      // This check was missing in the first published version and it can make the whole
      // calculation find nothing and report zero on a configuration that is perfectly
      // alive. Margin does not grow smoothly - it JUMPS every time a leg opens, so equity
      // can sit above the stop-out threshold an instant before and below it an instant
      // after, without ever crossing INSIDE a band. Found on a live account: equity 1,875,
      // step 6, cap 40 - solving only inside the bands found no solution at all, while the
      // stop-out really arrives at 72.00 as the thirteenth leg opens, which is exactly one
      // of those jumps.
      double floatingAtOpen = r.moneyPerUnit * (k * low - InpGridStep * k * (k - 1) / 2.0);
      if(r.equity - floatingAtOpen <= threshold)
      {
         r.runToStopOut = low;
         r.legsAtStopOut = k;
         break;
      }

      // THEN INSIDE the band, where margin is constant and equity falls smoothly.
      double mk = (r.equity - threshold
                   + r.moneyPerUnit * InpGridStep * k * (k - 1) / 2.0)
                  / (r.moneyPerUnit * k);
      if(mk >= low && mk < high)
      {
         r.runToStopOut = mk;
         r.legsAtStopOut = k;
         break;
      }
   }

   r.valid = true;
}

//+------------------------------------------------------------------+
//| How often a move that size has already happened here.             |
//|                                                                   |
//| Kept separate from Compute() because it is the slow part: it      |
//| pulls M1 bars, and on a symbol with a long history that is a lot  |
//| of them. It runs once at start, not on every refresh.             |
//+------------------------------------------------------------------+
void ScanHistory(Report &r)
{
   r.barsScanned = 0;
   if(InpHistoryDays <= 0 || !r.valid || r.runToStopOut <= 0.0)
      return;

   int wanted = InpHistoryDays * 1440;
   double close[];
   ArraySetAsSeries(close, false);

   // CopyClose returns NOTHING - not "as many as available" - when asked for more bars than
   // the terminal holds. So the request is halved until it succeeds, instead of concluding
   // from one empty answer that the symbol has no history.
   int got = 0;
   while(wanted >= 1440)
   {
      got = CopyClose(_Symbol, PERIOD_M1, 0, wanted, close);
      if(got > 0)
         break;
      wanted /= 2;
   }
   if(got <= 0)
      return;

   r.barsScanned = got;
   r.daysScanned = got / 1440.0;
   r.runsDown = CountRuns(close, got, r.runToStopOut, true);
   r.runsUp   = CountRuns(close, got, r.runToStopOut, false);
   r.runsWorst = MathMax(r.runsDown, r.runsUp);
   r.oneEvery = (r.runsWorst > 0 ? r.daysScanned / r.runsWorst : 0.0);
}

//+------------------------------------------------------------------+
//| Panel                                                             |
//+------------------------------------------------------------------+
void ClearPanel()
{
   ObjectsDeleteAll(0, PREFIX);
   g_panelLines = 0;
}

void Line(string text, color c)
{
   string name = PREFIX + IntegerToString(g_panelLines);
   int y = 16 + g_panelLines * (InpFontSize + 6);
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, InpCorner);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, 12);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpFontSize);
   ObjectSetInteger(0, name, OBJPROP_COLOR, c);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetString(0, name, OBJPROP_FONT, "Consolas");
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   g_panelLines++;
}

void DrawPanel(const Report &r)
{
   ClearPanel();
   if(!InpShowPanel)
      return;

   if(!r.valid)
   {
      Line("GRID CAPITAL - cannot compute", InpColorBad);
      Line(r.problem, InpColorBad);
      ChartRedraw();
      return;
   }

   string cur = AccountInfoString(ACCOUNT_CURRENCY);
   Line(StringFormat("GRID CAPITAL  %s  step %.2f  %.2f lots  cap %d%s",
                     _Symbol, InpGridStep, InpLots, InpMaxLegs,
                     (InpBothSides ? "  both sides" : "  one side")), InpColorText);
   Line("", InpColorText);
   Line(StringFormat("full chain spans      %10.2f  in price", r.chainSpan), InpColorText);
   Line(StringFormat("floating when full    %10.2f  %s", -r.floatingFull, cur), InpColorText);
   Line(StringFormat("margin locked up      %10.2f  %s", r.marginUsed, cur), InpColorText);
   Line(StringFormat("equity                %10.2f  %s", r.equity, cur), InpColorText);

   color cShare = (r.sharePercent >= 100.0 ? InpColorBad
                   : (r.sharePercent >= 50.0 ? InpColorWarn : InpColorText));
   Line(StringFormat("a full chain is       %9.1f%%  of equity", r.sharePercent), cShare);
   Line("", InpColorText);
   Line(StringFormat("stop-out at %.0f%% margin level, i.e. equity %.2f",
                     r.stopOutLevel, r.stopOutEquity), InpColorText);
   Line(StringFormat("ADVERSE MOVE THAT ENDS IT   %.2f  in price", r.runToStopOut),
        InpColorWarn);
   Line(StringFormat("  (with %d of %d legs open at that point)",
                     r.legsAtStopOut, InpMaxLegs), InpColorText);

   if(r.barsScanned > 0)
   {
      Line("", InpColorText);
      color cFreq = (r.oneEvery > 0.0 && r.oneEvery < 7.0 ? InpColorBad : InpColorText);
      if(r.runsWorst > 0)
         Line(StringFormat("that has happened %d times in %.0f days - one every %.1f",
                           r.runsWorst, r.daysScanned, r.oneEvery), cFreq);
      else
         Line(StringFormat("never happened in the last %.0f days of M1", r.daysScanned),
              InpColorText);
   }
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| The same thing in the Experts log, where it can be copied out.    |
//+------------------------------------------------------------------+
void PrintReport(const Report &r)
{
   if(!r.valid)
   {
      Print("GridCapitalCalculator: cannot compute - ", r.problem);
      return;
   }
   string cur = AccountInfoString(ACCOUNT_CURRENCY);

   PrintFormat("GridCapitalCalculator: %s  step %.2f  %.2f lots  cap %d legs  %s",
               _Symbol, InpGridStep, InpLots, InpMaxLegs,
               (InpBothSides ? "both sides" : "one side"));
   PrintFormat("  one price unit is worth %.4f %s at %.2f lots; one leg locks %.2f of margin",
               r.moneyPerUnit, cur, InpLots, r.marginPerLeg);
   PrintFormat("  a full chain spans %.2f in price and floats %.2f %s "
               "(step x n(n-1)/2, NOT step x n)",
               r.chainSpan, -r.floatingFull, cur);
   PrintFormat("  margin: %.2f for one chain, %.2f for both%s",
               r.marginOneChain, r.marginBothSides,
               (r.marginBothSides < r.marginOneChain * 2.0
                ? " (hedged legs offset - the broker charges the larger side)" : ""));
   PrintFormat("  equity %.2f %s, so a full chain is %.1f%% of the account",
               r.equity, cur, r.sharePercent);
   PrintFormat("  stop-out at %.0f%% of margin, i.e. when equity falls to %.2f",
               r.stopOutLevel, r.stopOutEquity);
   PrintFormat("  THE ADVERSE MOVE THAT ENDS THIS ACCOUNT: %.2f in price, "
               "with %d of %d legs open at that point",
               r.runToStopOut, r.legsAtStopOut, InpMaxLegs);
   if(r.legsAtStopOut < InpMaxLegs)
      Print("  Note: the account dies BEFORE the chain is full. The cap you set is never "
            "reached, so raising or lowering it changes nothing here.");

   if(r.barsScanned > 0)
   {
      if(r.runsWorst > 0)
         PrintFormat("  on %d M1 bars (%.0f days) a move that large happened %d times "
                     "down and %d times up - one every %.1f days",
                     r.barsScanned, r.daysScanned, r.runsDown, r.runsUp, r.oneEvery);
      else
         PrintFormat("  on %d M1 bars (%.0f days) a move that large never happened",
                     r.barsScanned, r.daysScanned);
   }
   else if(InpHistoryDays > 0)
      Print("  no M1 history available to count how often that move occurs");

   if(r.sharePercent >= 100.0)
      Print("  WARNING: a single full chain already exceeds the account. The broker closes "
            "you before any rule inside your EA can act.");
   else if(r.sharePercent >= 50.0)
      Print("  WARNING: a single full chain takes more than half the account. With both "
            "chains open there is no room for an ordinary move.");
}

//+------------------------------------------------------------------+
int OnInit()
{
   Compute(g_r);
   ScanHistory(g_r);
   PrintReport(g_r);
   DrawPanel(g_r);
   EventSetTimer(MathMax(1, InpRefreshSec));
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
   // Recompute, but do NOT re-scan history: equity moves every second, the shape of the last
   // hundred days does not. Re-reading a hundred thousand bars every ten seconds would make a
   // read-only utility the heaviest thing on the chart.
   int    bars   = g_r.barsScanned;
   double days   = g_r.daysScanned;
   int    down   = g_r.runsDown;
   int    up     = g_r.runsUp;
   double before = g_r.runToStopOut;

   Compute(g_r);

   // The counts stay valid only while the threshold they were counted at has not moved much.
   // Equity drifts, so the threshold drifts with it; past 5% the figure is re-earned rather
   // than carried forward, because a frequency quoted for the wrong size is worse than none.
   if(bars > 0 && before > 0.0 && g_r.runToStopOut > 0.0 &&
      MathAbs(g_r.runToStopOut - before) / before < 0.05)
   {
      g_r.barsScanned = bars;
      g_r.daysScanned = days;
      g_r.runsDown    = down;
      g_r.runsUp      = up;
      g_r.runsWorst   = MathMax(down, up);
      g_r.oneEvery    = (g_r.runsWorst > 0 ? days / g_r.runsWorst : 0.0);
   }
   else
      ScanHistory(g_r);

   DrawPanel(g_r);
}
//+------------------------------------------------------------------+
