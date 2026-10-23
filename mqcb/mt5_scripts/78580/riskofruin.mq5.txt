//+------------------------------------------------------------------+
//|                                                   RiskOfRuin.mq5 |
//|                                                     YuRa Trading |
//|                                          https://yuratrading.com |
//+------------------------------------------------------------------+
//| The chance your account blows up before your edge pays off,      |
//| measured on your own closed trades.                              |
//|                                                                  |
//| The script reads the closed trades in your account history,      |
//| normalises each to an R-multiple (net result divided by average  |
//| absolute loss), and then simulates many hypothetical future runs |
//| at a risk-per-trade you choose. In each run it draws R-multiples |
//| from your history at random with replacement, compounds the      |
//| equity trade by trade, and marks the run as "ruined" if the      |
//| equity ever falls below the ruin floor.                          |
//|                                                                  |
//|   P(ruin)      - share of runs that hit the floor                |
//|   P(profit)    - share of runs that end above the start          |
//|   median end   - the typical final balance                       |
//|   95% range    - the middle 95% of ending balances               |
//|                                                                  |
//| Normalising to R-multiples means the sim is independent of the   |
//| dollar size you traded in history - all that carries over is the |
//| shape of your win/loss distribution. The risk % you type now is  |
//| what the simulation sizes every future trade with.               |
//|                                                                  |
//| Read-only: the script never sends an order.                      |
//+------------------------------------------------------------------+
#property copyright   "YuRa Trading"
#property link        "https://yuratrading.com"
#property version     "1.00"
#property description "Risk of ruin from your own closed trades: resamples your trade history and reports the"
#property description "chance of hitting a chosen drawdown floor at a chosen risk per trade. Read-only."
#property script_show_inputs

#include <Generic\HashMap.mqh>

//--- input parameters
input long   InpMagic        = -1;     // Magic number (-1 = all trades, 0 = manual trades)
input string InpSymbol       = "";     // Symbol (empty = all symbols)
input int    InpDays         = 0;      // Only trades closed in the last N days (0 = whole history)
input double InpRiskPct      = 1.0;    // Risk per trade, % of equity (0.01 to 25.0)
input double InpRuinPct      = 50.0;   // Ruin floor, % of starting equity (10.0 to 95.0)
input int    InpTradesAhead  = 0;      // Future trades per run (0 = same as history size)
input int    InpRuns         = 10000;  // Simulated runs (1,000 to 100,000)
input int    InpMinTrades    = 30;     // Fewest history trades for a verdict

//+------------------------------------------------------------------+
//| Result of the simulation                                         |
//+------------------------------------------------------------------+
struct SRuinResult
  {
   int               trades;        // historical trades used
   int               runs;          // simulated runs
   int               aheadTrades;   // future trades per run
   double            avgAbsLoss;    // the R-multiple divisor
   double            avgR;          // historical average R per trade
   double            p_ruin;        // share of runs that hit the ruin floor
   double            p_profit;      // share of runs ending above the start
   double            medianEnd;     // median ending equity (fraction of start)
   double            lo95End;       // 2.5 percentile of ending equity
   double            hi95End;       // 97.5 percentile of ending equity
  };

//+------------------------------------------------------------------+
//| Random numbers: xorshift64*, fast, and the same seed gives the   |
//| same answer every time the script runs on the same history      |
//+------------------------------------------------------------------+
class CRandom
  {
private:
   ulong             m_state;
public:
   void              Seed(const ulong seed) { m_state = seed; }
   int               Index(const int count);
  };

//+------------------------------------------------------------------+
//| Uniform random integer in [0, count)                             |
//+------------------------------------------------------------------+
int CRandom::Index(const int count)
  {
   m_state ^= m_state >> 12;
   m_state ^= m_state << 25;
   m_state ^= m_state >> 27;
   return((int)(((m_state * 2685821657736338717) >> 11) % (ulong)count));
  }

//+------------------------------------------------------------------+
//| Net result of every closed trade that passes the filters         |
//+------------------------------------------------------------------+
int LoadNets(const long magic, const string symbol, const int days, double &nets[])
  {
   ArrayResize(nets, 0);
   if(!HistorySelect(0, TimeCurrent() + 86400))
      return(-1);
   int total = HistoryDealsTotal();
//--- one slot per position: the deals of a position add up to one trade
   CHashMap<ulong, int> index;
   ulong    pos_id[];
   long     pos_magic[];
   string   pos_symbol[];
   datetime pos_close[];
   double   pos_net[];
   int n = 0;
   for(int i = 0; i < total; i++)
     {
      ulong deal = HistoryDealGetTicket(i);
      if(deal == 0)
         continue;
      //--- skip deposits, withdrawals and charges booked outside trades
      long type = HistoryDealGetInteger(deal, DEAL_TYPE);
      if(type != DEAL_TYPE_BUY && type != DEAL_TYPE_SELL)
         continue;
      ulong id = (ulong)HistoryDealGetInteger(deal, DEAL_POSITION_ID);
      int k;
      if(!index.TryGetValue(id, k))
        {
         k = n++;
         index.Add(id, k);
         ArrayResize(pos_id, n, 1024);
         ArrayResize(pos_magic, n, 1024);
         ArrayResize(pos_symbol, n, 1024);
         ArrayResize(pos_close, n, 1024);
         ArrayResize(pos_net, n, 1024);
         pos_id[k]     = id;
         pos_magic[k]  = HistoryDealGetInteger(deal, DEAL_MAGIC);   // the opening deal's magic
         pos_symbol[k] = HistoryDealGetString(deal, DEAL_SYMBOL);
         pos_close[k]  = 0;
         pos_net[k]    = 0;
        }
      //--- any deal that is not an entry (OUT, OUT_BY, INOUT) moves the close time
      if(HistoryDealGetInteger(deal, DEAL_ENTRY) != DEAL_ENTRY_IN)
        {
         datetime t = (datetime)HistoryDealGetInteger(deal, DEAL_TIME);
         if(t > pos_close[k])
            pos_close[k] = t;
        }
      pos_net[k] += HistoryDealGetDouble(deal, DEAL_PROFIT) + HistoryDealGetDouble(deal, DEAL_COMMISSION)
                    + HistoryDealGetDouble(deal, DEAL_FEE) + HistoryDealGetDouble(deal, DEAL_SWAP);
     }
//--- keep closed positions that pass the filters
   datetime from = days > 0 ? TimeCurrent() - (datetime)days * 86400 : 0;
   int m = 0;
   ArrayResize(nets, 0, n);
   for(int k = 0; k < n; k++)
     {
      if(pos_close[k] == 0 || PositionSelectByTicket(pos_id[k]))
         continue;
      if(pos_close[k] < from)
         continue;
      if(magic >= 0 && pos_magic[k] != magic)
         continue;
      if(symbol != "" && pos_symbol[k] != symbol)
         continue;
      ArrayResize(nets, m + 1, n);
      nets[m++] = pos_net[k];
     }
   return(m);
  }

//+------------------------------------------------------------------+
//| Average absolute loss across the trades (zero if no losses)      |
//+------------------------------------------------------------------+
double AverageAbsLoss(const double &nets[])
  {
   int n = ArraySize(nets);
   double sum = 0;
   int losses = 0;
   for(int i = 0; i < n; i++)
      if(nets[i] < 0)
        {
         sum += -nets[i];
         losses++;
        }
   if(losses == 0)
      return(0.0);
   return(sum / losses);
  }

//+------------------------------------------------------------------+
//| Value at fraction p of a sorted array, interpolated              |
//+------------------------------------------------------------------+
double Percentile(const double &sorted[], const double p)
  {
   int n = ArraySize(sorted);
   if(n == 0)
      return(0);
   double pos = p * (n - 1);
   int lo = (int)MathFloor(pos);
   int hi = MathMin(lo + 1, n - 1);
   return(sorted[lo] + (sorted[hi] - sorted[lo]) * (pos - lo));
  }

//+------------------------------------------------------------------+
//| Simulate many future runs on bootstrapped R-multiples            |
//+------------------------------------------------------------------+
void Simulate(const double &rMultiples[], const int runs, const int ahead,
              const double riskFrac, const double ruinFloor, SRuinResult &result)
  {
   int n = ArraySize(rMultiples);
   result.trades = n;
   result.runs = runs;
   result.aheadTrades = ahead;
//--- historical average R
   double sumR = 0;
   for(int i = 0; i < n; i++)
      sumR += rMultiples[i];
   result.avgR = (n > 0) ? sumR / n : 0.0;
   if(n == 0)
      return;

   CRandom rng;
   rng.Seed(0x9E3779B97F4A7C15);
   double endEquity[];
   ArrayResize(endEquity, runs);
   int ruined = 0;
   int profits = 0;
   for(int k = 0; k < runs; k++)
     {
      double equity = 1.0;
      bool hit = false;
      for(int t = 0; t < ahead; t++)
        {
         double r = rMultiples[rng.Index(n)];
         // next equity = equity * (1 + riskFrac * r)
         // when risk% * r <= -100%, equity goes to zero or negative; clamp at 0
         double growth = 1.0 + riskFrac * r;
         if(growth < 0.0)
            growth = 0.0;
         equity *= growth;
         if(equity <= ruinFloor)
           {
            hit = true;
            equity = ruinFloor;             // park the sim at the floor
            // once ruined, stop compounding; most desks also stop trading
            break;
           }
        }
      if(hit)
         ruined++;
      if(equity > 1.0)
         profits++;
      endEquity[k] = equity;
     }
   result.p_ruin   = (double)ruined  / runs;
   result.p_profit = (double)profits / runs;
   ArraySort(endEquity);
   result.medianEnd = Percentile(endEquity, 0.50);
   result.lo95End   = Percentile(endEquity, 0.025);
   result.hi95End   = Percentile(endEquity, 0.975);
  }

//+------------------------------------------------------------------+
//| Format a fraction of start as a percentage change                |
//+------------------------------------------------------------------+
string PctChange(const double frac)
  {
   double pct = (frac - 1.0) * 100.0;
   return((pct >= 0 ? "+" : "") + DoubleToString(pct, 1) + "%");
  }

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- check the inputs
   if(InpRuns < 1000 || InpRuns > 100000)
     {
      Print("Risk of ruin: resamples must be 1,000 to 100,000");
      return;
     }
   if(InpRiskPct < 0.01 || InpRiskPct > 25.0)
     {
      Print("Risk of ruin: risk per trade must be between 0.01% and 25%");
      return;
     }
   if(InpRuinPct < 10.0 || InpRuinPct > 95.0)
     {
      Print("Risk of ruin: ruin floor must be between 10% and 95%");
      return;
     }
   if(InpMinTrades < 2 || InpDays < 0 || InpTradesAhead < 0)
     {
      Print("Risk of ruin: fewest trades 2 or more, days 0 or more, trades-ahead 0 or more");
      return;
     }

   string scope = InpMagic < 0 ? "all trades" : (InpMagic == 0 ? "manual trades" : "magic " + IntegerToString(InpMagic));
   if(InpSymbol != "")
      scope += ", " + InpSymbol;
   scope += InpDays > 0 ? ", last " + IntegerToString(InpDays) + " days" : ", whole history";

//--- read the trades
   double nets[];
   int n = LoadNets(InpMagic, InpSymbol, InpDays, nets);
   if(n < 0)
     {
      Print("Risk of ruin: could not read the account history");
      return;
     }

//--- turn each trade into an R-multiple
   double rMultiples[];
   double avgAbsLoss = 0.0;
   int rCount = 0;
   if(n > 0)
     {
      avgAbsLoss = AverageAbsLoss(nets);
      if(avgAbsLoss > 0.0)
        {
         ArrayResize(rMultiples, n);
         for(int i = 0; i < n; i++)
            rMultiples[i] = nets[i] / avgAbsLoss;
         rCount = n;
        }
     }

   int ahead = (InpTradesAhead > 0) ? InpTradesAhead : rCount;

//--- word the output
   string lines[];
   int count = 0;
   ArrayResize(lines, 10);
   lines[count++] = StringFormat("Risk of ruin (%s)", scope);

   if(n == 0)
     {
      lines[count++] = "No closed trades match these settings.";
     }
   else if(avgAbsLoss <= 0.0)
     {
      lines[count++] = StringFormat("%d trades, but none are losses - cannot build R-multiples.", n);
      lines[count++] = "Add some loss history, or test a strategy that actually risks.";
     }
   else if(ahead < 1)
     {
      lines[count++] = "Trades-ahead resolved to zero - set InpTradesAhead or add history.";
     }
   else
     {
      SRuinResult r;
      double riskFrac  = InpRiskPct / 100.0;
      double ruinFloor = 1.0 - InpRuinPct / 100.0;    // e.g. 50% ruin -> floor 0.50
      Simulate(rMultiples, InpRuns, ahead, riskFrac, ruinFloor, r);
      r.avgAbsLoss = avgAbsLoss;

      string ccy = " " + AccountInfoString(ACCOUNT_CURRENCY);
      lines[count++] = StringFormat("%d trades, avg R %.3f, risking %.2f%% per trade, %d trades ahead, %d runs.",
                                    r.trades, r.avgR, InpRiskPct, r.aheadTrades, r.runs);
      lines[count++] = StringFormat("Avg absolute loss used as R unit: %.2f%s.",
                                    r.avgAbsLoss, ccy);
      lines[count++] = StringFormat("Chance of hitting the %.0f%% drawdown floor: %.2f%%.",
                                    InpRuinPct, r.p_ruin * 100.0);
      lines[count++] = StringFormat("Chance of ending profitable: %.1f%%.",
                                    r.p_profit * 100.0);
      lines[count++] = StringFormat("Median ending balance: %s of start.",
                                    PctChange(r.medianEnd));
      lines[count++] = StringFormat("95%% range of ending balance: %s to %s.",
                                    PctChange(r.lo95End), PctChange(r.hi95End));
      if(n < InpMinTrades)
         lines[count++] = StringFormat("Fewer than %d trades: the distribution the sim draws from is itself noisy.", InpMinTrades);
      else if(r.p_ruin >= 0.5)
         lines[count++] = "Risk is too high for this edge - more than half of runs hit the floor.";
      else if(r.p_ruin >= 0.1)
         lines[count++] = "Ruin is a realistic outcome at this size - most desks cap well below here.";
      else if(r.avgR <= 0)
         lines[count++] = "Average R is non-positive: no risk size turns this history into a long-run winner.";
      else
         lines[count++] = "At this size the ruin tail is small - the long-run growth rate decides what is left over.";
      lines[count++] = StringFormat("Based on %d simulated runs. Past results do not guarantee future results.", r.runs);
     }

//--- show it in the Experts journal and on the chart
   string text = "";
   for(int i = 0; i < count; i++)
     {
      Print(lines[i]);
      text += lines[i] + "\n";
     }
   Comment(text);                               // run again with other settings, or Comment("") to clear
  }
//+------------------------------------------------------------------+
