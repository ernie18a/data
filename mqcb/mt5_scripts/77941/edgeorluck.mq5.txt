//+------------------------------------------------------------------+
//|                                                   EdgeOrLuck.mq5 |
//|                                                     YuRa Trading |
//|                                          https://yuratrading.com |
//+------------------------------------------------------------------+
//| Is your average trade an edge, or could it still be luck?        |
//|                                                                  |
//| The script reads the closed trades in your account history and   |
//| resamples them 10,000 times (a bootstrap): it draws as many      |
//| trades as you have, at random and with replacement, and records  |
//| their average. The middle 95% of those averages is the range     |
//| your true average trade most likely sits in.                     |
//|                                                                  |
//|   whole range above zero  -> on this sample the edge looks real  |
//|   range includes zero     -> the result could still be luck      |
//|   whole range below zero  -> the losses are larger than luck     |
//|                                                                  |
//| A trade is every deal of one position, counted once the position |
//| is closed. Net = profit + commission + fee + swap, as charged by |
//| your broker. Read-only: the script never sends an order.         |
//+------------------------------------------------------------------+
#property copyright   "YuRa Trading"
#property link        "https://yuratrading.com"
#property version     "1.00"
#property description "Edge or luck: resamples your closed trades 10,000 times to find the 95% range of the"
#property description "average trade and the chance that the true average is below zero. Read-only."
#property script_show_inputs

#include <Generic\HashMap.mqh>

//--- input parameters
input long   InpMagic     = -1;     // Magic number (-1 = all trades, 0 = manual trades)
input string InpSymbol    = "";     // Symbol (empty = all symbols)
input int    InpDays      = 0;      // Only trades closed in the last N days (0 = whole history)
input int    InpRuns      = 10000;  // Resamples (1,000 to 100,000)
input int    InpMinTrades = 30;     // Fewest trades for a verdict

//+------------------------------------------------------------------+
//| Result of the bootstrap                                          |
//+------------------------------------------------------------------+
struct SEdgeResult
  {
   int               trades;        // number of closed trades
   double            mean;          // average net result per trade
   double            lo95;          // bottom of the 95% range of the average
   double            hi95;          // top of the 95% range of the average
   double            p_below;       // share of resamples whose average is below zero
  };

//+------------------------------------------------------------------+
//| Random numbers: xorshift64*, fast, and the same seed gives the   |
//| same answer every time the script runs on the same history       |
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
//| The bootstrap: resample the trades, record each average          |
//+------------------------------------------------------------------+
void Bootstrap(const double &x[], const int runs, SEdgeResult &result)
  {
   int n = ArraySize(x);
   result.trades = n;
   result.mean = result.lo95 = result.hi95 = result.p_below = 0;
   if(n == 0)
      return;
   for(int i = 0; i < n; i++)
      result.mean += x[i];
   result.mean /= n;
//--- draw n trades with replacement, many times over
   CRandom rng;
   rng.Seed(0x9E3779B97F4A7C15);
   double means[];
   ArrayResize(means, runs);
   int below = 0;
   for(int k = 0; k < runs; k++)
     {
      double sum = 0;
      for(int i = 0; i < n; i++)
         sum += x[rng.Index(n)];                // any trade, possibly the same one twice
      means[k] = sum / n;
      if(means[k] < 0)
         below++;
     }
//--- the middle 95% of the averages, and the share below zero
   result.p_below = (double)below / runs;
   ArraySort(means);
   result.lo95 = Percentile(means, 0.025);
   result.hi95 = Percentile(means, 0.975);
  }

//+------------------------------------------------------------------+
//| Money with an explicit sign                                      |
//+------------------------------------------------------------------+
string Money(const double value)
  {
   return((value > 0 ? "+" : "") + DoubleToString(value, 2));
  }

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- check the inputs
   if(InpRuns < 1000 || InpRuns > 100000 || InpMinTrades < 2 || InpDays < 0)
     {
      Print("Edge or luck: resamples must be 1,000 to 100,000, fewest trades 2 or more, days 0 or more");
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
      Print("Edge or luck: could not read the account history");
      return;
     }
//--- run the test and word the verdict
   string lines[];
   int count = 0;
   ArrayResize(lines, 8);
   lines[count++] = "Edge or luck (" + scope + ")";
   if(n == 0)
      lines[count++] = "No closed trades match these settings.";
   else
     {
      SEdgeResult r;
      Bootstrap(nets, InpRuns, r);
      string ccy = " " + AccountInfoString(ACCOUNT_CURRENCY);
      lines[count++] = StringFormat("%d trades. Average trade %s%s.", n, Money(r.mean), ccy);
      lines[count++] = StringFormat("95%% range of the average trade: %s to %s%s", Money(r.lo95), Money(r.hi95), ccy);
      lines[count++] = StringFormat("Chance the true average is below zero: %.1f%%", r.p_below * 100.0);
      if(n < InpMinTrades)
         lines[count++] = StringFormat("Fewer than %d trades: too few to tell an edge from luck yet.", InpMinTrades);
      else
         if(r.lo95 > 0)
            lines[count++] = "The 95% range is above zero: on this sample the edge looks real.";
         else
            if(r.hi95 < 0)
               lines[count++] = "The 95% range is below zero: the losses are larger than luck explains.";
            else
               lines[count++] = "The 95% range includes zero: this result could still be luck.";
      lines[count++] = StringFormat("Based on %d resamples of these trades. Past results do not guarantee future results.", InpRuns);
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
