//+------------------------------------------------------------------+
//|                             ArixisBacktestRobustnessAnalyzer.mq5 |
//|         Free, open-source, READ-ONLY history analysis for MT5    |
//+------------------------------------------------------------------+
//
// WHAT THIS PROGRAM DOES
// ----------------------
// It reads the CLOSED trading history of the current account and shows
// how the historical result was produced: how much of it came from a few
// trades, how long the losing streaks were, how deep the closed-equity
// drawdown was, how results were spread over time, and how BUY and SELL
// trades behaved separately.
//
// WHAT THIS PROGRAM NEVER DOES
// ----------------------------
// It is an indicator and contains no trade-execution code at all. MetaTrader 5
// additionally forbids trade operations inside indicators, so the platform
// itself enforces the read-only behaviour. The program only reads history,
// computes numbers, draws chart labels and (on request) writes a CSV file
// into the terminal's MQL5\Files sandbox.
//
// ARCHITECTURE (read top to bottom)
// ---------------------------------
//   1. Inputs
//   2. Data structures
//   3. Reading history            AbraLoadAccountDeals()
//   4. Deals -> trades            AbraReconstruct()          (pure, tested)
//   5. Statistics                 AbraComputeStats() & co.   (pure, tested)
//   6. Formatting helpers
//   7. Dashboard                  AbraRender()
//   8. CSV export                 AbraExportCsv()
//   9. Event handlers             OnInit / OnTimer / OnChartEvent
//
// Layers 4 and 5 never touch the terminal: they take arrays and return
// numbers. That is what makes them testable with small synthetic inputs
// (see tests\ArixisRobustnessSelfTest.mq5, which includes THIS file).
//
// IMPORTANT
// ---------
// Every figure describes past observations only. Nothing here predicts
// future results, and no figure is a classification of an Expert Advisor.
//+------------------------------------------------------------------+
#property copyright   "Arixis"
#property link        "https://www.mql5.com"
#property version     "1.00"
#property description "Read-only analysis of closed trading history beyond Profit Factor:"
#property description "profit dependency, historical sensitivity, streaks, closed-equity drawdown,"
#property description "time buckets, BUY vs SELL and result distribution."
#property description "It never opens, closes or modifies orders or positions."
#property description "All figures describe history only. They are not forecasts."

// The self-test EA defines ABRA_SELFTEST_BUILD and includes this file, so
// the indicator-only properties and event handlers are excluded there.
#ifndef ABRA_SELFTEST_BUILD
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
#endif

//+------------------------------------------------------------------+
//| 1. INPUTS                                                        |
//+------------------------------------------------------------------+
enum ENUM_ABRA_BUCKET_TIME
  {
   ABRA_BUCKET_BY_CLOSE = 0,   // Close time of the trade
   ABRA_BUCKET_BY_OPEN  = 1    // Open time of the trade
  };

input group "Analysis scope"
input datetime InpFromDate          = D'1970.01.01'; // From (trade close time), 1970.01.01 = whole history
input datetime InpToDate            = D'1970.01.01'; // To (close time, 00:00 = whole day), 1970.01.01 = now
input bool     InpCurrentSymbolOnly = false;         // Analyze the chart symbol only
input bool     InpUseMagicFilter    = false;         // Filter by Magic Number
input long     InpMagicNumber       = 0;             // Magic Number (of the entry deal)
input bool     InpManualTradesOnly  = false;         // Manual trades only (entry magic = 0)

input group "Result components"
input bool     InpIncludeCommission = true;          // Include commission
input bool     InpIncludeSwap       = true;          // Include swap
input bool     InpIncludeFees       = true;          // Include fees (DEAL_FEE)

input group "Statistics"
input int                   InpMinSampleForBucketStats = 10;                  // Min trades per time bucket before PF is shown
input ENUM_ABRA_BUCKET_TIME InpBucketTime              = ABRA_BUCKET_BY_CLOSE; // Time used for year/month/weekday/hour tables
input double                InpStartingCapital         = 0.0;                 // Capital base for drawdown %, 0 = auto

input group "Output"
input bool     InpEnableCSVExport   = true;          // Show the Export CSV button

input group "Dashboard"
input int      InpPanelX            = 12;            // Panel X offset (px)
input int      InpPanelY            = 24;            // Panel Y offset (px)
input int      InpFontSize          = 10;            // Font size (8-14)

//+------------------------------------------------------------------+
//| 2. DATA STRUCTURES                                               |
//+------------------------------------------------------------------+
#define ABRA_PREFIX    "ABRA_"
#define ABRA_VOL_EPS   1e-8          // volume tolerance when a position returns to flat
#define ABRA_DIR_BUY   0
#define ABRA_DIR_SELL  1

// "Share of total net" states. A share is only printed as a percentage when
// the denominator makes it interpretable.
#define ABRA_SHARE_OK           0
#define ABRA_SHARE_NONPOSITIVE  1    // total net <= 0: "X% of a loss" has no meaning
#define ABRA_SHARE_TOO_FEW      2    // not enough observations to remove N of them

// Period granularity for concentration analysis
#define ABRA_PERIOD_DAY    0
#define ABRA_PERIOD_WEEK   1
#define ABRA_PERIOD_MONTH  2

// Time bucket tables
#define ABRA_BUCKET_YEAR     0
#define ABRA_BUCKET_MONTH    1
#define ABRA_BUCKET_WEEKDAY  2
#define ABRA_BUCKET_HOUR     3

int ABRA_TOP_N[4] = {1, 3, 5, 10};

// One raw deal copied from the terminal history. Types are stored as plain
// integers so synthetic test deals can be built without the terminal.
struct AbraDeal
  {
   ulong    ticket;
   datetime time;
   long     time_msc;
   int      type;          // ENUM_DEAL_TYPE value
   int      entry;         // ENUM_DEAL_ENTRY value
   long     position_id;
   double   volume;
   double   profit;
   double   swap;
   double   commission;
   double   fee;
   long     magic;
   string   symbol;
  };

// One reconstructed closed trade = one complete position round trip
// (from flat to flat), whatever number of deals it took.
struct AbraTrade
  {
   long     position_id;
   int      dir;           // ABRA_DIR_BUY or ABRA_DIR_SELL
   datetime open_time;     // 0 when the entry deal is not in the history
   datetime close_time;
   double   volume;        // largest absolute position size during the trip
   double   profit;
   double   swap;
   double   commission;
   double   fee;
   double   net;           // profit + the cost components selected in the inputs
   long     magic;         // magic of the ENTRY deal
   string   symbol;
   bool     orphan;        // exit found without its entry deal
  };

struct AbraFilter
  {
   datetime from_time;     // 0 = no lower bound
   datetime to_time;       // 0 = no upper bound
   bool     symbol_only;
   string   symbol;
   bool     use_magic;
   long     magic;
   bool     manual_only;
   bool     inc_commission;
   bool     inc_swap;
   bool     inc_fee;
  };

// Diagnostics of the reconstruction, shown on the dashboard so the user can
// see what was merged, skipped or could not be attributed.
struct AbraReconInfo
  {
   int      deals_total;
   int      trade_deals;
   int      other_deals;
   int      invalid_deals;      // deals with an invalid timestamp or entry type
   int      sanitized_values;   // NaN/INF numbers replaced by 0
   int      round_trips;        // all completed trips before filtering
   int      partial_exits;      // exits that reduced a position without closing it
   int      reversals;          // DEAL_ENTRY_INOUT deals (netting reversals)
   int      orphan_exits;       // exits whose entry deal is missing from history
   int      open_positions;     // positions still open (matching the symbol/magic filters)
   double   open_realized;      // amounts already realized by those open positions
   int      other_count;        // non-trade charges/adjustments in the date range
   double   other_amount;
   bool     base_valid;
   double   base_balance;       // account balance just before the first analyzed trade closed
  };

struct AbraOpenPos
  {
   long     position_id;
   double   signed_vol;         // + long, - short
   double   max_abs_vol;
   int      dir;
   datetime open_time;
   double   profit;
   double   swap;
   double   commission;
   double   fee;
   long     magic;
   string   symbol;
  };

struct AbraRemoval
  {
   bool     valid;              // false when there are not more than N trades
   double   removed_sum;
   double   net_after;
   int      share_state;
   double   share_pct;          // removed_sum / total net * 100 (best trades only)
  };

struct AbraPeriodConc
  {
   int      periods;
   bool     valid;              // needs at least two periods
   double   best_net;
   datetime best_start;
   double   net_ex_best;
   int      share_state;
   double   share_pct;
   double   worst_net;
   datetime worst_start;
   double   net_ex_worst;
  };

struct AbraStreakStats
  {
   int      longest_win;
   int      longest_loss;
   double   best_win_run_sum;   // largest cumulative profit of one winning streak
   double   worst_loss_run_sum; // largest cumulative loss of one losing streak (negative)
   int      win_runs;
   int      loss_runs;
   double   avg_win_len;
   double   avg_loss_len;
   int      loss_ge3;
   int      loss_ge5;
   int      loss_ge10;
  };

struct AbraDDStats
  {
   double   max_dd;             // largest peak-to-trough drop of the closed-equity curve
   int      peak_idx;           // -1 = the starting point of the curve
   int      bottom_idx;
   int      recovery_idx;       // -1 = not recovered
   datetime peak_time;
   datetime bottom_time;
   datetime recovery_time;
   bool     pct_valid;
   double   max_dd_pct;
   double   base;
   long     longest_uw_seconds;
   int      longest_uw_trades;
   datetime uw_start;
   datetime uw_end;
   bool     uw_ongoing;
   int      episodes;
   int      episodes_major;     // episodes at least half as deep as the maximum
  };

struct AbraSideStats
  {
   int      n;
   int      wins;
   int      losses;
   int      be;
   double   net;
   double   gp;
   double   gl;                 // gross loss as a positive magnitude
   double   best;
   double   worst;
  };

// Only simple members (no strings, no dynamic arrays), so ZeroMemory()
// resets it safely. Time bucket tables are kept in separate arrays.
struct AbraStats
  {
   int      n;
   int      wins;
   int      losses;
   int      be;
   double   net;
   double   gp;
   double   gl;
   double   avg;
   double   best;
   double   worst;
   double   avg_win;
   double   avg_loss;
   bool     pf_valid;
   double   pf;
   bool     plr_valid;
   double   plr;
   bool     stdev_valid;
   double   stdev;
   double   minimum;
   double   p05;
   double   p10;
   double   p25;
   double   median;
   double   p75;
   double   p90;
   double   p95;
   double   maximum;
   AbraRemoval     best_removed[4];
   AbraRemoval     worst_removed[4];
   AbraPeriodConc  day;
   AbraPeriodConc  week;
   AbraPeriodConc  month;
   AbraStreakStats streaks;
   AbraDDStats     dd;
   AbraSideStats   buy;
   AbraSideStats   sell;
  };

struct AbraBucket
  {
   long     key;
   string   label;
   int      n;
   int      wins;
   int      losses;
   double   net;
   double   gp;
   double   gl;
  };

//+------------------------------------------------------------------+
//| 3. READING HISTORY                                               |
//+------------------------------------------------------------------+
// Replaces NaN/INF by 0 and returns how many values were replaced. Broken
// numbers must never propagate into sums, where one NaN poisons everything.
int AbraSanitizeDeal(AbraDeal &d)
  {
   int fixed = 0;
   if(!MathIsValidNumber(d.volume))     { d.volume = 0.0;     fixed++; }
   if(!MathIsValidNumber(d.profit))     { d.profit = 0.0;     fixed++; }
   if(!MathIsValidNumber(d.swap))       { d.swap = 0.0;       fixed++; }
   if(!MathIsValidNumber(d.commission)) { d.commission = 0.0; fixed++; }
   if(!MathIsValidNumber(d.fee))        { d.fee = 0.0;        fixed++; }
   return fixed;
  }

// Copies every deal of the account history into a plain array.
// The WHOLE history is selected, not just the requested date range:
// a trade closed inside the range may have been opened before it, and its
// entry deal is needed to know its direction, magic and entry costs.
// Date filtering is applied later, on the trade close time.
bool AbraLoadAccountDeals(AbraDeal &deals[], int &sanitized, string &error)
  {
   ArrayResize(deals, 0);
   sanitized = 0;
   error = "";
   if(!HistorySelect(0, D'2100.01.01'))
     {
      error = "HistorySelect failed, error " + IntegerToString(GetLastError());
      return false;
     }
   int total = HistoryDealsTotal();
   ArrayResize(deals, total);
   int m = 0;
   for(int i = 0; i < total; i++)
     {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0)
         continue;
      AbraDeal d;
      d.ticket      = ticket;
      d.time        = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
      d.time_msc    = HistoryDealGetInteger(ticket, DEAL_TIME_MSC);
      d.type        = (int)HistoryDealGetInteger(ticket, DEAL_TYPE);
      d.entry       = (int)HistoryDealGetInteger(ticket, DEAL_ENTRY);
      d.position_id = HistoryDealGetInteger(ticket, DEAL_POSITION_ID);
      d.volume      = HistoryDealGetDouble(ticket, DEAL_VOLUME);
      d.profit      = HistoryDealGetDouble(ticket, DEAL_PROFIT);
      d.swap        = HistoryDealGetDouble(ticket, DEAL_SWAP);
      d.commission  = HistoryDealGetDouble(ticket, DEAL_COMMISSION);
      d.fee         = HistoryDealGetDouble(ticket, DEAL_FEE); // 0 when the broker does not report fees
      d.magic       = HistoryDealGetInteger(ticket, DEAL_MAGIC);
      d.symbol      = HistoryDealGetString(ticket, DEAL_SYMBOL);
      sanitized    += AbraSanitizeDeal(d);
      deals[m++]    = d;
     }
   ArrayResize(deals, m);
   return true;
  }

//+------------------------------------------------------------------+
//| 4. DEALS -> TRADES                                               |
//+------------------------------------------------------------------+
// MT5 DEAL SEMANTICS
// ------------------
// A deal is one execution. It is NOT a trade. Its DEAL_ENTRY tells what the
// execution did to the position identified by DEAL_POSITION_ID:
//   DEAL_ENTRY_IN      opens a position or adds volume to it
//   DEAL_ENTRY_OUT     reduces or closes it (a partial close is one OUT deal)
//   DEAL_ENTRY_INOUT   reversal (netting accounts): closes the position and
//                      opens the opposite one in the same execution
//   DEAL_ENTRY_OUT_BY  closed by an opposite position (hedging "Close By")
// Realized profit and swap are booked on exit deals; commissions and fees
// may appear on entry and exit deals.
//
// So "one closed trade" here means one position round trip: we follow the
// signed volume of each position id and emit a trade when it returns to 0.
// The trade collects profit, swap, commission and fee of every deal in it.
// This works identically on hedging accounts (one id per position) and on
// netting accounts (one id per symbol position; the id survives reversals,
// which is why INOUT has to split one position id into two trades).
// Balance, credit and other non-trade deals are not trades.

bool AbraIsTradeDeal(const int type)
  {
   return type == DEAL_TYPE_BUY || type == DEAL_TYPE_SELL;
  }

// Deposits, withdrawals, credit and bonus move capital; they are not
// trading results and they are not charges.
bool AbraIsCapitalMovement(const int type)
  {
   return type == DEAL_TYPE_BALANCE || type == DEAL_TYPE_CREDIT || type == DEAL_TYPE_BONUS;
  }

bool AbraInDateRange(const datetime t, const AbraFilter &f)
  {
   if(f.from_time > 0 && t < f.from_time)
      return false;
   if(f.to_time > 0 && t > f.to_time)
      return false;
   return true;
  }

// Symbol / magic / manual filters use the ENTRY deal: an EA position closed
// manually (or by the server at SL/TP) still belongs to the EA that opened it.
bool AbraMatchesSource(const string symbol, const long magic, const AbraFilter &f)
  {
   if(f.symbol_only && symbol != f.symbol)
      return false;
   if(f.use_magic && magic != f.magic)
      return false;
   if(f.manual_only && magic != 0)
      return false;
   return true;
  }

double AbraNetOf(const double profit, const double swap, const double commission,
                 const double fee, const AbraFilter &f)
  {
   double net = profit;
   if(f.inc_swap)       net += swap;
   if(f.inc_commission) net += commission;
   if(f.inc_fee)        net += fee;
   return net;
  }

long AbraDealOrderKey(const AbraDeal &d)
  {
   return (d.time_msc > 0) ? d.time_msc : (long)d.time * 1000;
  }

bool AbraDealBefore(const AbraDeal &a, const AbraDeal &b)
  {
   long ka = AbraDealOrderKey(a), kb = AbraDealOrderKey(b);
   if(ka != kb)
      return ka < kb;
   return a.ticket < b.ticket;
  }

// Stable merge sort of indices by (time in ms, ticket). The terminal usually
// returns deals in time order, but the reconstruction depends on it, so it
// is enforced rather than assumed.
void AbraSortDealOrder(const AbraDeal &deals[], int &order[])
  {
   int n = ArraySize(deals);
   ArrayResize(order, n);
   for(int i = 0; i < n; i++)
      order[i] = i;
   int tmp[];
   ArrayResize(tmp, n);
   for(int width = 1; width < n; width *= 2)
     {
      for(int lo = 0; lo < n; lo += 2 * width)
        {
         int mid = MathMin(lo + width, n), hi = MathMin(lo + 2 * width, n);
         int a = lo, b = mid, k = lo;
         while(a < mid && b < hi)
           {
            if(AbraDealBefore(deals[order[b]], deals[order[a]]))
               tmp[k++] = order[b++];
            else
               tmp[k++] = order[a++];
           }
         while(a < mid) tmp[k++] = order[a++];
         while(b < hi)  tmp[k++] = order[b++];
        }
      ArrayCopy(order, tmp);
     }
  }

int AbraFindOpen(const AbraOpenPos &open[], const long position_id)
  {
   int n = ArraySize(open);
   for(int i = 0; i < n; i++)
      if(open[i].position_id == position_id)
         return i;
   return -1;
  }

void AbraRemoveOpen(AbraOpenPos &open[], const int idx)
  {
   int n = ArraySize(open);
   if(idx < n - 1)
      open[idx] = open[n - 1];
   ArrayResize(open, n - 1);
  }

void AbraStartOpen(AbraOpenPos &p, const AbraDeal &d, const double signed_vol)
  {
   p.position_id = d.position_id;
   p.signed_vol  = signed_vol;
   p.max_abs_vol = MathAbs(signed_vol);
   p.dir         = (signed_vol >= 0.0) ? ABRA_DIR_BUY : ABRA_DIR_SELL;
   p.open_time   = d.time;
   p.profit      = 0.0;
   p.swap        = 0.0;
   p.commission  = 0.0;
   p.fee         = 0.0;
   p.magic       = d.magic;
   p.symbol      = d.symbol;
  }

// Builds the trade, applies the filters and appends it when selected.
// balance_before is the account balance before the closing deal; the first
// selected trade stores it as the automatic base for drawdown percentages.
void AbraEmitTrade(AbraTrade &trades[], AbraReconInfo &info, const AbraFilter &f,
                   const long position_id, const int dir, const datetime open_time,
                   const datetime close_time, const double volume, const double profit,
                   const double swap, const double commission, const double fee,
                   const long magic, const string symbol, const bool orphan,
                   const double balance_before)
  {
   info.round_trips++;
   if(!AbraMatchesSource(symbol, magic, f) || !AbraInDateRange(close_time, f))
      return;
   AbraTrade t;
   t.position_id = position_id;
   t.dir         = dir;
   t.open_time   = open_time;
   t.close_time  = close_time;
   t.volume      = volume;
   t.profit      = profit;
   t.swap        = swap;
   t.commission  = commission;
   t.fee         = fee;
   t.net         = AbraNetOf(profit, swap, commission, fee, f);
   t.magic       = magic;
   t.symbol      = symbol;
   t.orphan      = orphan;
   int n = ArraySize(trades);
   ArrayResize(trades, n + 1, 1024);
   trades[n] = t;
   if(!info.base_valid)
     {
      info.base_valid   = true;
      info.base_balance = balance_before;
     }
  }

// Converts deals into closed trades (see "MT5 DEAL SEMANTICS" above).
// Output trades are in closing order, because deals are walked in time order
// and a trade is emitted at the deal that closes it.
void AbraReconstruct(const AbraDeal &deals[], const AbraFilter &f,
                     AbraTrade &trades[], AbraReconInfo &info)
  {
   ZeroMemory(info);
   ArrayResize(trades, 0);
   int n = ArraySize(deals);
   info.deals_total = n;

   int order[];
   AbraSortDealOrder(deals, order);

   AbraOpenPos open[];
   double balance = 0.0;   // running account balance, used for the automatic DD % base

   for(int k = 0; k < n; k++)
     {
      AbraDeal d = deals[order[k]];
      if(d.time <= 0)
        {
         info.invalid_deals++;
         continue;
        }
      double amount = d.profit + d.swap + d.commission + d.fee;

      if(!AbraIsTradeDeal(d.type))
        {
         info.other_deals++;
         if(d.type != DEAL_TYPE_CREDIT)        // credit is not part of the balance
            balance += amount;
         if(!AbraIsCapitalMovement(d.type) && AbraInDateRange(d.time, f))
           {
            // Separate commission/charge/interest deals cannot be assigned to
            // one trade. They are reported, not silently mixed into results.
            info.other_count++;
            info.other_amount += amount;
           }
         continue;
        }

      info.trade_deals++;
      double balance_before = balance;
      balance += amount;
      double sign = (d.type == DEAL_TYPE_BUY) ? 1.0 : -1.0;
      double dv   = sign * d.volume;
      int    p    = AbraFindOpen(open, d.position_id);

      //--- entry: open a position or add to it
      if(d.entry == DEAL_ENTRY_IN)
        {
         if(p < 0)
           {
            p = ArraySize(open);
            ArrayResize(open, p + 1, 64);
            AbraStartOpen(open[p], d, 0.0);
            open[p].dir = (sign > 0.0) ? ABRA_DIR_BUY : ABRA_DIR_SELL;
           }
         open[p].signed_vol  += dv;
         open[p].max_abs_vol  = MathMax(open[p].max_abs_vol, MathAbs(open[p].signed_vol));
         open[p].profit      += d.profit;
         open[p].swap        += d.swap;
         open[p].commission  += d.commission;
         open[p].fee         += d.fee;
         continue;
        }

      //--- exit: partial or full close
      if(d.entry == DEAL_ENTRY_OUT || d.entry == DEAL_ENTRY_OUT_BY)
        {
         if(p < 0)
           {
            // Entry not in history (trimmed history or data gap). A BUY deal
            // closes a SELL position and vice versa, so the direction is still
            // known; the open time is not.
            info.orphan_exits++;
            AbraEmitTrade(trades, info, f, d.position_id,
                          (sign > 0.0) ? ABRA_DIR_SELL : ABRA_DIR_BUY, 0, d.time, d.volume,
                          d.profit, d.swap, d.commission, d.fee, d.magic, d.symbol, true,
                          balance_before);
            continue;
           }
         double before = open[p].signed_vol;
         open[p].signed_vol += dv;
         open[p].profit     += d.profit;
         open[p].swap       += d.swap;
         open[p].commission += d.commission;
         open[p].fee        += d.fee;
         // Flat, or (defensively) crossed zero on an OUT deal: the trip ends.
         if(MathAbs(open[p].signed_vol) <= ABRA_VOL_EPS || before * open[p].signed_vol < 0.0)
           {
            AbraEmitTrade(trades, info, f, open[p].position_id, open[p].dir, open[p].open_time,
                          d.time, open[p].max_abs_vol, open[p].profit, open[p].swap,
                          open[p].commission, open[p].fee, open[p].magic, open[p].symbol,
                          false, balance_before);
            AbraRemoveOpen(open, p);
           }
         else
            info.partial_exits++;
         continue;
        }

      //--- reversal: close the current trip and open the opposite one
      if(d.entry == DEAL_ENTRY_INOUT)
        {
         info.reversals++;
         if(p < 0)
           {
            // Nothing known about the closed part: book the whole deal as an
            // orphan exit and do not guess the size of the new position.
            info.orphan_exits++;
            AbraEmitTrade(trades, info, f, d.position_id,
                          (sign > 0.0) ? ABRA_DIR_SELL : ABRA_DIR_BUY, 0, d.time, d.volume,
                          d.profit, d.swap, d.commission, d.fee, d.magic, d.symbol, true,
                          balance_before);
            continue;
           }
         double close_vol = MathAbs(open[p].signed_vol);
         // Profit and swap belong to the closed part. Commission and fee are
         // shared by volume between the closed part and the new position.
         double frac = (d.volume > 0.0) ? MathMin(1.0, close_vol / d.volume) : 1.0;
         AbraEmitTrade(trades, info, f, open[p].position_id, open[p].dir, open[p].open_time,
                       d.time, open[p].max_abs_vol, open[p].profit + d.profit,
                       open[p].swap + d.swap, open[p].commission + d.commission * frac,
                       open[p].fee + d.fee * frac, open[p].magic, open[p].symbol,
                       false, balance_before);
         double remaining = d.volume - close_vol;
         if(remaining > ABRA_VOL_EPS)
           {
            AbraStartOpen(open[p], d, sign * remaining);
            open[p].commission = d.commission * (1.0 - frac);
            open[p].fee        = d.fee * (1.0 - frac);
           }
         else
            AbraRemoveOpen(open, p);
         continue;
        }

      // Unknown entry type (for example DEAL_ENTRY_STATE): not used.
      info.invalid_deals++;
     }

   //--- positions still open: excluded from the statistics, but reported
   int open_left = ArraySize(open);
   for(int i = 0; i < open_left; i++)
     {
      if(!AbraMatchesSource(open[i].symbol, open[i].magic, f))
         continue;
      info.open_positions++;
      info.open_realized += AbraNetOf(open[i].profit, open[i].swap, open[i].commission,
                                      open[i].fee, f);
     }
  }

//+------------------------------------------------------------------+
//| 5. STATISTICS                                                    |
//+------------------------------------------------------------------+
// PROFIT FACTOR = gross profit / gross loss (loss as a positive number).
// It tells how many currency units were won per unit lost, but nothing about
// how the wins were distributed. With no losing trade the ratio is a
// division by zero, not "infinitely good", so it is reported as N/A.
bool AbraProfitFactor(const double gross_profit, const double gross_loss_abs, double &pf)
  {
   pf = 0.0;
   if(gross_loss_abs <= 0.0)
      return false;
   pf = gross_profit / gross_loss_abs;
   return MathIsValidNumber(pf);
  }

// PERCENTILE with linear interpolation between closest ranks (the method of
// Excel PERCENTILE.INC and NumPy's default). For sorted x[0..n-1] the p-th
// percentile sits at position h = (n-1)*p; between two ranks we interpolate.
// The median is the 50th percentile: the middle value (odd n) or the mean of
// the two middle values (even n). Unlike the mean, it is not pulled by a few
// extreme trades.
double AbraPercentile(const double &asc[], const double p)
  {
   int n = ArraySize(asc);
   if(n == 0)
      return 0.0;
   if(n == 1)
      return asc[0];
   double h  = (n - 1) * MathMax(0.0, MathMin(1.0, p));
   int    lo = (int)MathFloor(h);
   if(lo >= n - 1)
      return asc[n - 1];
   return asc[lo] + (h - lo) * (asc[lo + 1] - asc[lo]);
  }

// TOP-N DEPENDENCY. "Net result without the best N trades" is the plainest
// way to see concentration: if removing a handful of trades erases the
// result, the history depended on rare events. It is only computed when
// MORE than N trades exist (removing all trades says nothing).
// The share (sum of top N / total net) is only meaningful when the total is
// positive. With a zero or negative total, "top 5 = 250% of a loss" is a
// number without meaning, so the state is set to NONPOSITIVE and shown N/A.
void AbraRemoveExtremes(const double &asc[], const double net, const int count,
                        const bool best, const double eps, AbraRemoval &r)
  {
   ZeroMemory(r);
   int n = ArraySize(asc);
   r.valid = (count > 0 && n > count);
   if(!r.valid)
     {
      r.share_state = ABRA_SHARE_TOO_FEW;
      r.net_after   = net;
      return;
     }
   double sum = 0.0;
   for(int k = 0; k < count; k++)
      sum += best ? asc[n - 1 - k] : asc[k];
   r.removed_sum = sum;
   r.net_after   = net - sum;
   if(net <= eps)
      r.share_state = ABRA_SHARE_NONPOSITIVE;
   else
     {
      r.share_state = ABRA_SHARE_OK;
      r.share_pct   = sum / net * 100.0;
     }
  }

// Start of the calendar period containing t (server time).
// Weeks start on Monday.
datetime AbraPeriodStart(const datetime t, const int period)
  {
   MqlDateTime s;
   TimeToStruct(t, s);
   s.hour = 0;
   s.min  = 0;
   s.sec  = 0;
   if(period == ABRA_PERIOD_MONTH)
     {
      s.day = 1;
      return StructToTime(s);
     }
   datetime day = StructToTime(s);
   if(period == ABRA_PERIOD_WEEK)
      return (datetime)(day - ((s.day_of_week + 6) % 7) * 86400);
   return day;
  }

// PERIOD CONCENTRATION. Groups results by the calendar day/week/month in
// which trades CLOSED (when the result was realized) and measures the best
// and worst period. Trades must be in closing order, which AbraReconstruct
// guarantees; consecutive trades of the same period are summed.
void AbraPeriodConcentration(const AbraTrade &tr[], const int period, const double net,
                             const double eps, AbraPeriodConc &c)
  {
   ZeroMemory(c);
   int n = ArraySize(tr);
   if(n == 0)
      return;
   datetime cur_key = AbraPeriodStart(tr[0].close_time, period);
   double   cur_sum = 0.0;
   bool     first   = true;
   for(int i = 0; i <= n; i++)
     {
      datetime key = (i < n) ? AbraPeriodStart(tr[i].close_time, period) : 0;
      if(i == n || key != cur_key)
        {
         c.periods++;
         if(first || cur_sum > c.best_net)  { c.best_net  = cur_sum; c.best_start  = cur_key; }
         if(first || cur_sum < c.worst_net) { c.worst_net = cur_sum; c.worst_start = cur_key; }
         first   = false;
         cur_key = key;
         cur_sum = 0.0;
        }
      if(i < n)
         cur_sum += tr[i].net;
     }
   c.valid        = (c.periods >= 2);
   c.net_ex_best  = net - c.best_net;
   c.net_ex_worst = net - c.worst_net;
   if(!c.valid)
      c.share_state = ABRA_SHARE_TOO_FEW;
   else
      if(net <= eps)
         c.share_state = ABRA_SHARE_NONPOSITIVE;
      else
        {
         c.share_state = ABRA_SHARE_OK;
         c.share_pct   = c.best_net / net * 100.0;
        }
  }

// Closes one run of the streak scan. run > 0 = winning run, run < 0 = losing.
void AbraCloseRun(const int run, const double run_sum, AbraStreakStats &s,
                  long &win_len_total, long &loss_len_total)
  {
   if(run > 0)
     {
      s.win_runs++;
      win_len_total += run;
      if(run > s.longest_win)
         s.longest_win = run;
      if(run_sum > s.best_win_run_sum)
         s.best_win_run_sum = run_sum;
     }
   else
      if(run < 0)
        {
         int len = -run;
         s.loss_runs++;
         loss_len_total += len;
         if(len > s.longest_loss)
            s.longest_loss = len;
         if(run_sum < s.worst_loss_run_sum)
            s.worst_loss_run_sum = run_sum;
         if(len >= 3)  s.loss_ge3++;
         if(len >= 5)  s.loss_ge5++;
         if(len >= 10) s.loss_ge10++;
        }
  }

// STREAKS. Trades are taken in closing order and classified as win (> eps),
// loss (< -eps) or break-even. A streak is a maximal run of consecutive
// trades of the same class; a break-even trade ends both kinds of streak.
// The largest cumulative loss is tracked separately from the longest losing
// streak because a short streak of large losses can hurt more than a long
// streak of small ones.
void AbraComputeStreaks(const double &x[], const double eps, AbraStreakStats &s)
  {
   ZeroMemory(s);
   int    n = ArraySize(x);
   int    run = 0;
   double run_sum = 0.0;
   long   win_total = 0, loss_total = 0;
   for(int i = 0; i < n; i++)
     {
      int cls = (x[i] > eps) ? 1 : ((x[i] < -eps) ? -1 : 0);
      if(cls != 0 && run != 0 && ((run > 0) == (cls > 0)))
        {
         run     += cls;
         run_sum += x[i];
         continue;
        }
      AbraCloseRun(run, run_sum, s, win_total, loss_total);
      run     = cls;
      run_sum = (cls != 0) ? x[i] : 0.0;
     }
   AbraCloseRun(run, run_sum, s, win_total, loss_total);
   s.avg_win_len  = (s.win_runs  > 0) ? (double)win_total  / s.win_runs  : 0.0;
   s.avg_loss_len = (s.loss_runs > 0) ? (double)loss_total / s.loss_runs : 0.0;
  }

// Records one finished drawdown episode (peak -> bottom -> recovery or end).
void AbraCloseEpisode(const AbraTrade &tr[], const datetime curve_start, const int peak_idx,
                      const int bottom_idx, const int end_idx, const bool recovered,
                      const double depth, double &depths[], AbraDDStats &dd)
  {
   int k = ArraySize(depths);
   ArrayResize(depths, k + 1, 64);
   depths[k] = depth;
   dd.episodes++;

   datetime start = (peak_idx >= 0) ? tr[peak_idx].close_time : curve_start;
   datetime end   = tr[end_idx].close_time;
   if(depth > dd.max_dd)
     {
      dd.max_dd        = depth;
      dd.peak_idx      = peak_idx;
      dd.bottom_idx    = bottom_idx;
      dd.recovery_idx  = recovered ? end_idx : -1;
      dd.peak_time     = start;
      dd.bottom_time   = tr[bottom_idx].close_time;
      dd.recovery_time = recovered ? end : 0;
     }
   long seconds = (long)(end - start);
   if(seconds > dd.longest_uw_seconds || dd.episodes == 1)
     {
      dd.longest_uw_seconds = seconds;
      dd.longest_uw_trades  = end_idx - peak_idx;
      dd.uw_start           = start;
      dd.uw_end             = end;
      dd.uw_ongoing         = !recovered;
     }
  }

// CLOSED-EQUITY DRAWDOWN. The curve is the running sum of trade results in
// closing order, starting at 0. The drawdown at any point is the distance
// below the highest value reached so far (the peak). An episode starts when
// the curve drops below its peak and ends when it gets back to it (recovery)
// or when the data ends (not recovered).
// Only CLOSED results exist in this curve: losses a position showed while it
// was open are invisible here, so floating-equity drawdown can be larger.
// Percentages use (base + peak) as the denominator and are only valid when
// that capital base is positive.
void AbraComputeDrawdown(const AbraTrade &tr[], const double base, AbraDDStats &dd)
  {
   ZeroMemory(dd);
   dd.peak_idx     = -1;
   dd.bottom_idx   = -1;
   dd.recovery_idx = -1;
   dd.base         = base;
   dd.pct_valid    = (base > 0.0);
   int n = ArraySize(tr);
   if(n == 0)
      return;
   datetime curve_start = (tr[0].open_time > 0) ? tr[0].open_time : tr[0].close_time;

   double depths[];
   double cum = 0.0, peak = 0.0, bottom = 0.0;
   int    peak_idx = -1, bottom_idx = -1;
   bool   in_dd = false;
   const double tol = 1e-9;

   for(int i = 0; i < n; i++)
     {
      cum += tr[i].net;
      if(cum >= peak - tol)
        {
         if(in_dd)
           {
            AbraCloseEpisode(tr, curve_start, peak_idx, bottom_idx, i, true,
                             peak - bottom, depths, dd);
            in_dd = false;
           }
         peak     = MathMax(peak, cum);
         peak_idx = i;
        }
      else
        {
         if(!in_dd || cum < bottom)
           {
            bottom     = cum;
            bottom_idx = i;
           }
         in_dd = true;
         double peak_equity = base + peak;
         if(dd.pct_valid && peak_equity > 0.0)
            dd.max_dd_pct = MathMax(dd.max_dd_pct, (peak - cum) / peak_equity * 100.0);
        }
     }
   if(in_dd)
      AbraCloseEpisode(tr, curve_start, peak_idx, bottom_idx, n - 1, false,
                       peak - bottom, depths, dd);

   for(int e = 0; e < ArraySize(depths); e++)
      if(depths[e] >= 0.5 * dd.max_dd - tol)
         dd.episodes_major++;
  }

void AbraAddToSide(AbraSideStats &s, const double v, const double eps)
  {
   if(s.n == 0)
     {
      s.best  = v;
      s.worst = v;
     }
   s.n++;
   s.net += v;
   if(v > eps)       { s.wins++;   s.gp += v; }
   else if(v < -eps) { s.losses++; s.gl -= v; }
   else                s.be++;
   s.best  = MathMax(s.best, v);
   s.worst = MathMin(s.worst, v);
  }

// Computes every scalar statistic. `eps` is the break-even tolerance (half
// of the smallest currency unit); `base` is the capital base for DD %.
void AbraComputeStats(const AbraTrade &tr[], const double eps, const double base, AbraStats &s)
  {
   ZeroMemory(s);
   int n = ArraySize(tr);
   s.n = n;
   AbraComputeDrawdown(tr, base, s.dd);
   for(int j = 0; j < 4; j++)
     {
      s.best_removed[j].share_state  = ABRA_SHARE_TOO_FEW;
      s.worst_removed[j].share_state = ABRA_SHARE_TOO_FEW;
     }
   if(n == 0)
      return;

   double x[];
   ArrayResize(x, n);
   AbraSideStats all;
   ZeroMemory(all);
   for(int i = 0; i < n; i++)
     {
      x[i] = tr[i].net;
      AbraAddToSide(all, x[i], eps);
      if(tr[i].dir == ABRA_DIR_BUY)
         AbraAddToSide(s.buy, x[i], eps);
      else
         AbraAddToSide(s.sell, x[i], eps);
     }
   s.wins   = all.wins;
   s.losses = all.losses;
   s.be     = all.be;
   s.net    = all.net;
   s.gp     = all.gp;
   s.gl     = all.gl;
   s.best   = all.best;
   s.worst  = all.worst;
   s.avg    = s.net / n;
   s.avg_win  = (s.wins   > 0) ?  s.gp / s.wins   : 0.0;
   s.avg_loss = (s.losses > 0) ? -s.gl / s.losses : 0.0;
   s.pf_valid = AbraProfitFactor(s.gp, s.gl, s.pf);
   // Profit/loss ratio: average winner relative to the average loser.
   s.plr_valid = (s.wins > 0 && s.losses > 0);
   s.plr       = s.plr_valid ? s.avg_win / (-s.avg_loss) : 0.0;

   // Sample standard deviation (n-1): the typical spread of single results.
   s.stdev_valid = (n >= 2);
   if(s.stdev_valid)
     {
      double ss = 0.0;
      for(int i = 0; i < n; i++)
         ss += (x[i] - s.avg) * (x[i] - s.avg);
      s.stdev = MathSqrt(ss / (n - 1));
     }

   double asc[];
   ArrayCopy(asc, x);
   ArraySort(asc);
   s.minimum = asc[0];
   s.maximum = asc[n - 1];
   s.p05     = AbraPercentile(asc, 0.05);
   s.p10     = AbraPercentile(asc, 0.10);
   s.p25     = AbraPercentile(asc, 0.25);
   s.median  = AbraPercentile(asc, 0.50);
   s.p75     = AbraPercentile(asc, 0.75);
   s.p90     = AbraPercentile(asc, 0.90);
   s.p95     = AbraPercentile(asc, 0.95);

   for(int j = 0; j < 4; j++)
     {
      AbraRemoveExtremes(asc, s.net, ABRA_TOP_N[j], true,  eps, s.best_removed[j]);
      AbraRemoveExtremes(asc, s.net, ABRA_TOP_N[j], false, eps, s.worst_removed[j]);
     }

   AbraPeriodConcentration(tr, ABRA_PERIOD_DAY,   s.net, eps, s.day);
   AbraPeriodConcentration(tr, ABRA_PERIOD_WEEK,  s.net, eps, s.week);
   AbraPeriodConcentration(tr, ABRA_PERIOD_MONTH, s.net, eps, s.month);
   AbraComputeStreaks(x, eps, s.streaks);
  }

void AbraGetPeriod(const AbraStats &s, const int p, AbraPeriodConc &c)
  {
   if(p == 0)      c = s.day;
   else if(p == 1) c = s.week;
   else            c = s.month;
  }

string AbraWeekdayName(const int dow)
  {
   switch(dow)
     {
      case 1: return "Monday";
      case 2: return "Tuesday";
      case 3: return "Wednesday";
      case 4: return "Thursday";
      case 5: return "Friday";
      case 6: return "Saturday";
      default: return "Sunday";
     }
  }

// TIME BUCKETING. Each trade is assigned to one bucket using its close time
// (default: when the result was realized) or its open time (when the
// decision was taken). All times are broker server time. Year and month
// buckets are created as they appear and then sorted; weekday (Mon..Sun)
// and hour (0..23) buckets always exist, some may be empty.
void AbraBuildBuckets(const AbraTrade &tr[], const int kind, const int time_mode,
                      const double eps, AbraBucket &b[])
  {
   ArrayResize(b, 0);
   if(kind == ABRA_BUCKET_WEEKDAY || kind == ABRA_BUCKET_HOUR)
     {
      int count = (kind == ABRA_BUCKET_WEEKDAY) ? 7 : 24;
      ArrayResize(b, count);
      for(int i = 0; i < count; i++)
        {
         b[i].key    = (kind == ABRA_BUCKET_WEEKDAY) ? (i + 1) % 7 : i;  // Monday first
         b[i].label  = (kind == ABRA_BUCKET_WEEKDAY) ? AbraWeekdayName((int)b[i].key)
                       : StringFormat("%02d:00", i);
         b[i].n = 0; b[i].wins = 0; b[i].losses = 0;
         b[i].net = 0.0; b[i].gp = 0.0; b[i].gl = 0.0;
        }
     }
   int n = ArraySize(tr);
   for(int i = 0; i < n; i++)
     {
      datetime t = (time_mode == ABRA_BUCKET_BY_OPEN && tr[i].open_time > 0)
                   ? tr[i].open_time : tr[i].close_time;
      MqlDateTime s;
      TimeToStruct(t, s);
      long key = 0;
      if(kind == ABRA_BUCKET_YEAR)         key = s.year;
      else if(kind == ABRA_BUCKET_MONTH)   key = s.year * 100 + s.mon;
      else if(kind == ABRA_BUCKET_WEEKDAY) key = s.day_of_week;
      else                                 key = s.hour;

      int idx = -1;
      for(int j = 0; j < ArraySize(b); j++)
         if(b[j].key == key) { idx = j; break; }
      if(idx < 0)
        {
         idx = ArraySize(b);
         ArrayResize(b, idx + 1, 64);
         b[idx].key   = key;
         b[idx].label = (kind == ABRA_BUCKET_YEAR) ? IntegerToString(s.year)
                        : StringFormat("%04d-%02d", s.year, s.mon);
         b[idx].n = 0; b[idx].wins = 0; b[idx].losses = 0;
         b[idx].net = 0.0; b[idx].gp = 0.0; b[idx].gl = 0.0;
        }
      double v = tr[i].net;
      b[idx].n++;
      b[idx].net += v;
      if(v > eps)       { b[idx].wins++;   b[idx].gp += v; }
      else if(v < -eps) { b[idx].losses++; b[idx].gl -= v; }
     }
   if(kind == ABRA_BUCKET_YEAR || kind == ABRA_BUCKET_MONTH)
     {
      // insertion sort by key: bucket lists are short
      for(int i = 1; i < ArraySize(b); i++)
        {
         AbraBucket cur = b[i];
         int j = i - 1;
         while(j >= 0 && b[j].key > cur.key)
           {
            b[j + 1] = b[j];
            j--;
           }
         b[j + 1] = cur;
        }
     }
  }

// SAMPLE SIZE LABELS are descriptive UX categories only. They do NOT measure
// statistical significance and say nothing about future reliability; a
// large sample of a changing market can still be unrepresentative.
string AbraSampleLabel(const int n)
  {
   if(n <= 0)   return "NO DATA";
   if(n < 30)   return "VERY SMALL SAMPLE";
   if(n < 100)  return "SMALL SAMPLE";
   if(n < 500)  return "MODERATE SAMPLE";
   return "LARGE SAMPLE";
  }

//+------------------------------------------------------------------+
//| 6. FORMATTING HELPERS                                            |
//+------------------------------------------------------------------+
int g_money_digits = 2;

string AbraGroupDigits(const string digits)
  {
   string out = "";
   int len = StringLen(digits);
   for(int i = 0; i < len; i++)
     {
      out += StringSubstr(digits, i, 1);
      int rest = len - 1 - i;
      if(rest > 0 && rest % 3 == 0)
         out += ",";
     }
   return out;
  }

// Fixed-point number with thousands separators; sign only for negatives
// unless `plus` is set.
string AbraNum(const double v, const int digits, const bool plus = false)
  {
   double r = NormalizeDouble(v, digits);
   string s = DoubleToString(MathAbs(r), digits);
   int dot = StringFind(s, ".");
   string ip = (dot < 0) ? s : StringSubstr(s, 0, dot);
   string fp = (dot < 0) ? "" : StringSubstr(s, dot);
   string sign = (r < 0.0) ? "-" : ((plus && r > 0.0) ? "+" : "");
   return sign + AbraGroupDigits(ip) + fp;
  }

string AbraMoney(const double v)       { return AbraNum(v, g_money_digits, true); }
string AbraMoneyPlain(const double v)  { return AbraNum(v, g_money_digits, false); }
string AbraInt(const long v)           { return AbraNum((double)v, 0, false); }
string AbraPct(const double v)         { return AbraNum(v, 1, false) + "%"; }

string AbraShare(const int state, const double pct)
  {
   if(state == ABRA_SHARE_OK)          return AbraPct(pct);
   if(state == ABRA_SHARE_NONPOSITIVE) return "N/A";
   return "--";
  }

string AbraTime(const datetime t)
  {
   if(t <= 0)
      return "--";
   return TimeToString(t, TIME_DATE | TIME_MINUTES);
  }

string AbraDate(const datetime t)
  {
   if(t <= 0)
      return "--";
   return TimeToString(t, TIME_DATE);
  }

string AbraDuration(const long seconds)
  {
   if(seconds < 0)
      return "--";
   long d = seconds / 86400, h = (seconds % 86400) / 3600, m = (seconds % 3600) / 60;
   if(d > 0) return IntegerToString(d) + "d " + IntegerToString(h) + "h";
   if(h > 0) return IntegerToString(h) + "h " + IntegerToString(m) + "m";
   return IntegerToString(m) + "m";
  }

string AbraPF(const bool valid, const double pf)
  {
   return valid ? DoubleToString(pf, 2) : "N/A";
  }

string AbraWinRate(const int wins, const int n)
  {
   return (n > 0) ? AbraPct(100.0 * wins / n) : "--";
  }

//+------------------------------------------------------------------+
//| GLOBAL ANALYSIS STATE                                            |
//+------------------------------------------------------------------+
AbraDeal      g_deals[];
AbraTrade     g_trades[];
AbraReconInfo g_info;
AbraStats     g_stats;
AbraBucket    g_years[];
AbraBucket    g_months[];
AbraBucket    g_weekdays[];
AbraBucket    g_hours[];
AbraFilter    g_filter;

bool     g_ready        = false;
string   g_error        = "";
string   g_status       = "Loading history...";
string   g_currency     = "";
int      g_base_source  = 0;       // 0 none, 1 input, 2 automatic
datetime g_analyzed_at  = 0;
double   g_elapsed_ms   = 0.0;
int      g_min_sample   = 10;

int      g_tab          = 0;
int      g_time_view    = ABRA_BUCKET_YEAR;
int      g_time_page    = 0;
int      g_retry        = 0;

void AbraFillFilter(AbraFilter &f)
  {
   f.from_time      = InpFromDate;
   f.to_time        = InpToDate;
   // A date entered without a time (00:00) means "through the end of that day".
   if(f.to_time > 0 && (long)f.to_time % 86400 == 0)
      f.to_time += 86399;
   f.symbol_only    = InpCurrentSymbolOnly;
   f.symbol         = _Symbol;
   f.use_magic      = InpUseMagicFilter;
   f.magic          = InpMagicNumber;
   f.manual_only    = InpManualTradesOnly;
   f.inc_commission = InpIncludeCommission;
   f.inc_swap       = InpIncludeSwap;
   f.inc_fee        = InpIncludeFees;
  }

// Full analysis. Called once at start and whenever the user presses Refresh,
// never on every tick: history does not change between ticks.
void AbraRunAnalysis()
  {
   ulong t0 = GetMicrosecondCount();
   g_error = "";
   g_ready = false;
   AbraFillFilter(g_filter);
   g_min_sample = MathMax(1, InpMinSampleForBucketStats);
   g_currency   = AccountInfoString(ACCOUNT_CURRENCY);
   int digits   = (int)AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS);
   g_money_digits = (digits >= 0 && digits <= 8) ? digits : 2;

   if(g_filter.to_time > 0 && g_filter.from_time > g_filter.to_time)
     {
      g_error = "Invalid date range: From is later than To.";
      g_status = "Not analyzed";
      return;
     }

   int sanitized = 0;
   string err;
   if(!AbraLoadAccountDeals(g_deals, sanitized, err))
     {
      g_error = err;
      g_status = "History not available";
      return;
     }
   AbraReconstruct(g_deals, g_filter, g_trades, g_info);
   g_info.sanitized_values = sanitized;

   // Break-even tolerance: half of the smallest currency unit, so that
   // results rounding to 0.00 are neither wins nor losses.
   double eps = 0.5 * MathPow(10.0, -g_money_digits);

   double base = 0.0;
   g_base_source = 0;
   if(InpStartingCapital > 0.0)
     {
      base = InpStartingCapital;
      g_base_source = 1;
     }
   else
      if(g_info.base_valid && g_info.base_balance > 0.0)
        {
         base = g_info.base_balance;
         g_base_source = 2;
        }

   AbraComputeStats(g_trades, eps, base, g_stats);
   int mode = (int)InpBucketTime;
   AbraBuildBuckets(g_trades, ABRA_BUCKET_YEAR,    mode, eps, g_years);
   AbraBuildBuckets(g_trades, ABRA_BUCKET_MONTH,   mode, eps, g_months);
   AbraBuildBuckets(g_trades, ABRA_BUCKET_WEEKDAY, mode, eps, g_weekdays);
   AbraBuildBuckets(g_trades, ABRA_BUCKET_HOUR,    mode, eps, g_hours);

   ArrayResize(g_deals, 0);    // raw deals are no longer needed
   g_ready       = true;
   g_analyzed_at = TimeLocal();
   g_elapsed_ms  = (GetMicrosecondCount() - t0) / 1000.0;
   g_time_page   = 0;
   g_status      = "Analyzed " + TimeToString(g_analyzed_at, TIME_DATE | TIME_MINUTES)
                   + "  (" + DoubleToString(g_elapsed_ms, 0) + " ms)";
  }

//+------------------------------------------------------------------+
//| 7. DASHBOARD                                                     |
//+------------------------------------------------------------------+
// Every element is a chart object named with ABRA_PREFIX. The panel is
// rebuilt completely on each change: with a few hundred objects this is
// fast and much simpler than updating objects one by one.
#define ABRA_CLR_BG      C'16,18,22'
#define ABRA_CLR_TILE    C'27,30,36'
#define ABRA_CLR_BORDER  C'70,60,36'
#define ABRA_CLR_AMBER   C'222,170,40'
#define ABRA_CLR_TEXT    C'232,232,232'
#define ABRA_CLR_DIM     C'150,156,166'
#define ABRA_CLR_POS     C'122,196,146'
#define ABRA_CLR_NEG     C'226,118,104'
#define ABRA_CLR_TAB     C'36,40,48'
#define ABRA_CLR_DARK    C'20,20,20'

#define ABRA_PANEL_W     660
#define ABRA_PAD         14
#define ABRA_ROWS        22

string ABRA_TABS[7] = {"OVERVIEW", "DEPENDENCY", "DRAWDOWN", "STREAKS", "TIME", "BUY / SELL", "DISTRIBUTION"};

double g_scale   = 1.0;
int    g_font    = 10;
int    g_obj_id  = 0;
int    g_cy      = 0;    // content cursor (unscaled y)

int AbraS(const double v) { return (int)MathRound(v * g_scale); }
int AbraRowH()            { return g_font * 2; }

string AbraNextName() { g_obj_id++; return ABRA_PREFIX + "O" + IntegerToString(g_obj_id); }

void AbraRect(const string name, const int x, const int y, const int w, const int h,
              const color bg, const color border)
  {
   ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, AbraS(x));
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, AbraS(y));
   ObjectSetInteger(0, name, OBJPROP_XSIZE, AbraS(w));
   ObjectSetInteger(0, name, OBJPROP_YSIZE, AbraS(h));
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_COLOR, border);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

// MT5 keeps at most 63 characters of an OBJ_LABEL text and silently drops
// the rest, so longer texts are drawn as several labels side by side.
#define ABRA_LABEL_MAX_CHARS 63

int AbraTextWidth(const string text, const int size, const string font);

// Draws one OBJ_LABEL (text of at most ABRA_LABEL_MAX_CHARS characters).
void AbraLabelChunk(const int x, const int y, const string text, const color clr, const int size,
                    const bool right, const string font)
  {
   string name = AbraNextName();
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, right ? ANCHOR_RIGHT_UPPER : ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, AbraS(x));
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, AbraS(y));
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
   ObjectSetString(0, name, OBJPROP_FONT, font);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

void AbraLabel(const int x, const int y, const string text, const color clr, const int size,
               const bool right = false, const string font = "Segoe UI")
  {
   // MT5 draws the word "Label" for an OBJ_LABEL with empty text, so an
   // empty cell must simply not be drawn.
   if(text == "")
      return;
   if(StringLen(text) <= ABRA_LABEL_MAX_CHARS)
     {
      AbraLabelChunk(x, y, text, clr, size, right, font);
      return;
     }
   // Split into chunks of at most 63 characters, preferably after a space,
   // and place them one after another using their measured widths.
   string chunks[];
   string rest = text;
   while(StringLen(rest) > ABRA_LABEL_MAX_CHARS)
     {
      int cut = ABRA_LABEL_MAX_CHARS;
      for(int i = ABRA_LABEL_MAX_CHARS - 1; i > 0; i--)
         if(StringGetCharacter(rest, i) == ' ') { cut = i + 1; break; }
      int k = ArraySize(chunks);
      ArrayResize(chunks, k + 1);
      chunks[k] = StringSubstr(rest, 0, cut);
      rest = StringSubstr(rest, cut);
     }
   int k = ArraySize(chunks);
   ArrayResize(chunks, k + 1);
   chunks[k] = rest;

   int total = 0;
   for(int i = 0; i < ArraySize(chunks); i++)
      total += AbraTextWidth(chunks[i], size, font);
   int px = right ? AbraS(x) - total : AbraS(x);   // left edge in screen pixels
   for(int i = 0; i < ArraySize(chunks); i++)
     {
      AbraLabelChunk((int)MathRound(px / g_scale), y, chunks[i], clr, size, false, font);
      px += AbraTextWidth(chunks[i], size, font);
     }
  }

// Pixel width of a text as a chart label draws it. A negative TextSetFont
// size is in tenths of a point and follows the OS scaling, like OBJ_LABEL.
int AbraTextWidth(const string text, const int size, const string font)
  {
   uint w = 0, h = 0;
   if(!TextSetFont(font, -size * 10) || !TextGetSize(text, w, h))
      return StringLen(text) * size;   // conservative fallback
   return (int)w;
  }

// Largest font size <= size (not below min_size) at which text fits in
// max_w unscaled pixels. Used for values only; explanatory text is wrapped.
int AbraFitSize(const string text, const int size, const int min_size, const int max_w, const string font)
  {
   int s = size;
   while(s > min_size && AbraTextWidth(text, s, font) > AbraS(max_w))
      s--;
   return s;
  }

// Unscaled width of a text, for layout arithmetic.
int AbraTextW(const string text, const int size, const string font)
  {
   return (int)MathCeil(AbraTextWidth(text, size, font) / g_scale);
  }

void AbraButton(const string name, const int x, const int y, const int w, const int h,
                const string text, const bool active)
  {
   ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, AbraS(x));
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, AbraS(y));
   ObjectSetInteger(0, name, OBJPROP_XSIZE, AbraS(w));
   ObjectSetInteger(0, name, OBJPROP_YSIZE, AbraS(h));
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, active ? ABRA_CLR_AMBER : ABRA_CLR_TAB);
   ObjectSetInteger(0, name, OBJPROP_COLOR, active ? ABRA_CLR_DARK : ABRA_CLR_TEXT);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, active ? ABRA_CLR_AMBER : ABRA_CLR_BORDER);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, AbraFitSize(text, MathMax(7, g_font - 2), 6, w - 6, "Segoe UI Semibold"));
   ObjectSetString(0, name, OBJPROP_FONT, "Segoe UI Semibold");
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_STATE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

color AbraSignColor(const double v)
  {
   double r = NormalizeDouble(v, g_money_digits);
   if(r > 0.0) return ABRA_CLR_POS;
   if(r < 0.0) return ABRA_CLR_NEG;
   return ABRA_CLR_TEXT;
  }

//--- content primitives (x/y are unscaled, relative to the panel) ---------
int AbraCX() { return InpPanelX + ABRA_PAD; }
int AbraCW() { return ABRA_PANEL_W - 2 * ABRA_PAD; }

void UiHeading(const string text)
  {
   AbraLabel(AbraCX() + 2, g_cy + 2, text, ABRA_CLR_AMBER, MathMax(7, g_font - 1), false, "Segoe UI Semibold");
   g_cy += AbraRowH();
  }

void UiNoteLine(const string line, const color clr, const int size)
  {
   AbraLabel(AbraCX() + 2, g_cy + 2, line, clr, size);
   g_cy += AbraRowH() - 3;
  }

// Explanatory text, wrapped on word boundaries to the content width so no
// sentence runs past the panel edge.
void UiNote(const string text, const color clr = ABRA_CLR_DIM)
  {
   int    size   = MathMax(7, g_font - 2);
   int    max_px = AbraS(AbraCW() - 6);
   string words[];
   int    n = StringSplit(text, ' ', words);
   string line = "";
   for(int i = 0; i < n; i++)
     {
      string next = (line == "") ? words[i] : line + " " + words[i];
      if(line != "" && (AbraTextWidth(next, size, "Segoe UI") > max_px || StringLen(next) > ABRA_LABEL_MAX_CHARS))
        {
         UiNoteLine(line, clr, size);
         line = words[i];
        }
      else
         line = next;
     }
   if(line != "")
      UiNoteLine(line, clr, size);
  }

void UiGap() { g_cy += AbraRowH() / 2; }

// Two "label ... value" pairs on one row.
void UiKV2(const string l1, const string v1, const color c1,
           const string l2 = "", const string v2 = "", const color c2 = ABRA_CLR_TEXT)
  {
   int half  = AbraCW() / 2;
   int slot1 = (half - 16) - AbraTextW(l1, g_font, "Segoe UI") - 10;
   AbraLabel(AbraCX() + 2, g_cy, l1, ABRA_CLR_DIM, g_font);
   AbraLabel(AbraCX() + half - 14, g_cy, v1, c1, AbraFitSize(v1, g_font, 7, slot1, "Segoe UI"), true);
   if(l2 != "")
     {
      int slot2 = (AbraCW() - 2) - (half + 10) - AbraTextW(l2, g_font, "Segoe UI") - 10;
      AbraLabel(AbraCX() + half + 10, g_cy, l2, ABRA_CLR_DIM, g_font);
      AbraLabel(AbraCX() + AbraCW() - 2, g_cy, v2, c2, AbraFitSize(v2, g_font, 7, slot2, "Segoe UI"), true);
     }
   g_cy += AbraRowH();
  }

// Table row: first cell left-aligned, the others right-aligned at the given
// right edges (unscaled, relative to the content left edge).
void UiRow(const string &cells[], const int &right_edges[], const color &colors[], const bool header = false)
  {
   int n = ArraySize(cells);
   int size = header ? MathMax(7, g_font - 2) : g_font;
   string font = header ? "Segoe UI Semibold" : "Segoe UI";
   int left = (n > 0) ? 2 + AbraTextW(cells[0], size, font) : 0;   // end of the previous cell
   for(int i = 0; i < n; i++)
     {
      if(i == 0)
         AbraLabel(AbraCX() + 2, g_cy, cells[i], colors[i], size, false, font);
      else
        {
         int slot = right_edges[i] - left - 8;
         AbraLabel(AbraCX() + right_edges[i], g_cy, cells[i], colors[i],
                   AbraFitSize(cells[i], size, MathMax(6, size - 3), slot, font), true, font);
         left = right_edges[i];
        }
     }
   g_cy += AbraRowH();
   if(header)
      AbraRect(AbraNextName(), AbraCX(), g_cy - 3, AbraCW(), 1, ABRA_CLR_BORDER, ABRA_CLR_BORDER);
  }

// Builds the color array for a row: `first` for the label cell, `rest` for others.
void UiColors(color &colors[], const int n, const color first, const color rest)
  {
   ArrayResize(colors, n);
   for(int i = 0; i < n; i++)
      colors[i] = (i == 0) ? first : rest;
  }

//--- header and KPI tiles --------------------------------------------------
string AbraScopeText()
  {
   string s = g_filter.symbol_only ? g_filter.symbol : "All symbols";
   if(g_filter.manual_only)
      s += " | Manual (magic 0)";
   else
      s += g_filter.use_magic ? " | Magic " + IntegerToString(g_filter.magic) : " | All magic numbers";
   string from = (g_filter.from_time > 0) ? TimeToString(g_filter.from_time, TIME_DATE) : "start";
   string to   = (g_filter.to_time   > 0) ? TimeToString(g_filter.to_time,   TIME_DATE) : "now";
   s += " | " + from + " - " + to;
   if(g_currency != "")
      s += " | " + g_currency;
   return s;
  }

void AbraTile(const int x, const int y, const int w, const int h, const string caption,
              const string value, const color value_clr, const string sub)
  {
   AbraRect(AbraNextName(), x, y, w, h, ABRA_CLR_TILE, ABRA_CLR_BORDER);
   int inner = w - 20;
   AbraLabel(x + 10, y + 6, caption, ABRA_CLR_DIM,
             AbraFitSize(caption, MathMax(7, g_font - 2), 6, inner, "Segoe UI Semibold"), false, "Segoe UI Semibold");
   AbraLabel(x + 10, y + 6 + (int)(g_font * 1.5), value, value_clr,
             AbraFitSize(value, g_font + 4, g_font, inner, "Segoe UI Semibold"), false, "Segoe UI Semibold");
   AbraLabel(x + 10, y + h - (int)(g_font * 1.7) - 2, sub, ABRA_CLR_DIM,
             AbraFitSize(sub, MathMax(7, g_font - 2), 6, inner, "Segoe UI"));
  }

void AbraRenderTiles(const int top, const int tile_h)
  {
   int gap = 8;
   int w   = (AbraCW() - 3 * gap) / 4;
   int x0  = AbraCX();
   bool has = (g_ready && g_stats.n > 0);
   const AbraRemoval r5 = g_stats.best_removed[2];   // top-5

   string net_v  = has ? AbraMoney(g_stats.net) : "--";
   string pf_v   = has ? AbraPF(g_stats.pf_valid, g_stats.pf) : "--";
   string pf_s   = !has ? "" : (g_stats.pf_valid ? "gross profit / loss" : "no losing trades");
   string wr_v   = has ? AbraWinRate(g_stats.wins, g_stats.n) : "--";
   string wr_s   = has ? "W " + AbraInt(g_stats.wins) + "  L " + AbraInt(g_stats.losses)
                   + "  BE " + AbraInt(g_stats.be) : "";
   string dd_v   = has ? AbraMoneyPlain(g_stats.dd.max_dd) : "--";
   string dd_s   = !has ? "" : (g_stats.dd.pct_valid ? AbraPct(g_stats.dd.max_dd_pct) + " closed-equity DD"
                                : "% N/A (no capital base)");
   string ls_v   = has ? IntegerToString(g_stats.streaks.longest_loss) : "--";
   string t5_v   = "--", t5_s = "";
   if(has)
     {
      if(!r5.valid)
        { t5_v = "--"; t5_s = "needs > 5 trades"; }
      else
        {
         t5_v = (r5.share_state == ABRA_SHARE_OK) ? AbraPct(r5.share_pct) + " of net" : "N/A (net <= 0)";
         t5_s = "w/o top 5: " + AbraMoney(r5.net_after);
        }
     }
   string avg_v = has ? AbraMoney(g_stats.avg) : "--";
   string avg_s = has ? "median " + AbraMoney(g_stats.median) : "";

   int y2 = top + tile_h + gap;
   AbraTile(x0,                 top, w, tile_h, "NET RESULT",   net_v, has ? AbraSignColor(g_stats.net) : ABRA_CLR_TEXT, has ? g_currency + " (closed trades)" : "");
   AbraTile(x0 + (w + gap),     top, w, tile_h, "PROFIT FACTOR", pf_v, ABRA_CLR_TEXT, pf_s);
   AbraTile(x0 + 2 * (w + gap), top, w, tile_h, "TRADES ANALYZED", has ? AbraInt(g_stats.n) : (g_ready ? "0" : "--"),
            ABRA_CLR_TEXT, g_ready ? AbraSampleLabel(g_stats.n) : "");
   AbraTile(x0 + 3 * (w + gap), top, w, tile_h, "WIN RATE", wr_v, ABRA_CLR_TEXT, wr_s);
   AbraTile(x0,                 y2, w, tile_h, "CLOSED-EQUITY MAX DD", dd_v, ABRA_CLR_TEXT, dd_s);
   AbraTile(x0 + (w + gap),     y2, w, tile_h, "LONGEST LOSING STREAK", ls_v, ABRA_CLR_TEXT, has ? "losing trades in a row" : "");
   AbraTile(x0 + 2 * (w + gap), y2, w, tile_h, "TOP-5 DEPENDENCY", t5_v, ABRA_CLR_TEXT, t5_s);
   AbraTile(x0 + 3 * (w + gap), y2, w, tile_h, "AVERAGE TRADE", avg_v, has ? AbraSignColor(g_stats.avg) : ABRA_CLR_TEXT, avg_s);
  }

//--- tabs --------------------------------------------------------------
void AbraTabOverview()
  {
   const AbraStats s = g_stats;
   UiHeading("BASIC PERFORMANCE");
   UiKV2("Net result", AbraMoney(s.net), AbraSignColor(s.net), "Gross profit", AbraMoneyPlain(s.gp), ABRA_CLR_TEXT);
   UiKV2("Gross loss", AbraMoneyPlain(-s.gl), ABRA_CLR_TEXT, "Profit factor", AbraPF(s.pf_valid, s.pf), ABRA_CLR_TEXT);
   UiKV2("Win rate", AbraWinRate(s.wins, s.n), ABRA_CLR_TEXT, "Winning trades", AbraInt(s.wins), ABRA_CLR_TEXT);
   UiKV2("Losing trades", AbraInt(s.losses), ABRA_CLR_TEXT, "Break-even trades", AbraInt(s.be), ABRA_CLR_TEXT);
   UiKV2("Average trade (exp. payoff)", AbraMoney(s.avg), AbraSignColor(s.avg), "Median trade", AbraMoney(s.median), AbraSignColor(s.median));
   UiKV2("Average winner", s.wins > 0 ? AbraMoney(s.avg_win) : "--", ABRA_CLR_TEXT,
         "Average loser", s.losses > 0 ? AbraMoney(s.avg_loss) : "--", ABRA_CLR_TEXT);
   UiKV2("Largest winner", AbraMoney(s.best), AbraSignColor(s.best), "Largest loser", AbraMoney(s.worst), AbraSignColor(s.worst));
   UiKV2("Profit / loss ratio", s.plr_valid ? DoubleToString(s.plr, 2) : "N/A", ABRA_CLR_TEXT,
         "Std. deviation", s.stdev_valid ? AbraMoneyPlain(s.stdev) : "N/A", ABRA_CLR_TEXT);
   UiGap();
   UiHeading("SAMPLE AND RECONSTRUCTION");
   UiKV2("Trades analyzed", AbraInt(s.n), ABRA_CLR_TEXT, "Sample size label", AbraSampleLabel(s.n), ABRA_CLR_AMBER);
   UiKV2("Deals scanned", AbraInt(g_info.deals_total), ABRA_CLR_TEXT, "Trade deals", AbraInt(g_info.trade_deals), ABRA_CLR_TEXT);
   UiKV2("Partial exits merged", AbraInt(g_info.partial_exits), ABRA_CLR_TEXT, "Reversals (INOUT)", AbraInt(g_info.reversals), ABRA_CLR_TEXT);
   UiKV2("Exits without entry deal", AbraInt(g_info.orphan_exits), ABRA_CLR_TEXT, "Open positions (skipped)", AbraInt(g_info.open_positions), ABRA_CLR_TEXT);
   UiKV2("Realized on open positions", AbraMoney(g_info.open_realized), ABRA_CLR_TEXT,
         "Other charges (excluded)", AbraMoney(g_info.other_amount), ABRA_CLR_TEXT);
   UiGap();
   UiNote("Win rate = winning trades / all trades; break-even trades stay in the denominator.");
   UiNote("Sample labels are descriptive only. They do not measure statistical significance.");
  }

void AbraTabDependency()
  {
   const AbraStats s = g_stats;
   int   edges[4] = {0, 250, 420, 628};
   color colors[];
   string head[4] = {"BEST TRADES REMOVED", "REMOVED SUM", "NET AFTER REMOVAL", "SHARE OF TOTAL NET"};
   UiHeading("PROFIT DEPENDENCY  (original net " + AbraMoney(s.net) + ")");
   UiColors(colors, 4, ABRA_CLR_DIM, ABRA_CLR_DIM);
   UiRow(head, edges, colors, true);
   for(int j = 0; j < 4; j++)
     {
      const AbraRemoval r = s.best_removed[j];
      string cells[4];
      cells[0] = (ABRA_TOP_N[j] == 1) ? "Best trade" : "Best " + IntegerToString(ABRA_TOP_N[j]) + " trades";
      cells[1] = r.valid ? AbraMoney(r.removed_sum) : "--";
      cells[2] = r.valid ? AbraMoney(r.net_after) : "--";
      cells[3] = AbraShare(r.share_state, r.share_pct);
      UiColors(colors, 4, ABRA_CLR_TEXT, ABRA_CLR_TEXT);
      if(r.valid) colors[2] = AbraSignColor(r.net_after);
      UiRow(cells, edges, colors);
     }
   UiGap();
   UiHeading("HISTORICAL SENSITIVITY ANALYSIS  (worst trades removed)");
   // Three columns: a share of total net is not defined for removed losses.
   int    edges3[3] = {0, 250, 420};
   string head2[3]  = {"WORST TRADES REMOVED", "REMOVED SUM", "NET AFTER REMOVAL"};
   UiColors(colors, 3, ABRA_CLR_DIM, ABRA_CLR_DIM);
   UiRow(head2, edges3, colors, true);
   for(int j = 0; j < 4; j++)
     {
      const AbraRemoval r = s.worst_removed[j];
      string cells[3];
      cells[0] = (ABRA_TOP_N[j] == 1) ? "Worst trade" : "Worst " + IntegerToString(ABRA_TOP_N[j]) + " trades";
      cells[1] = r.valid ? AbraMoney(r.removed_sum) : "--";
      cells[2] = r.valid ? AbraMoney(r.net_after) : "--";
      UiColors(colors, 3, ABRA_CLR_TEXT, ABRA_CLR_TEXT);
      if(r.valid) colors[2] = AbraSignColor(r.net_after);
      UiRow(cells, edges3, colors);
     }
   UiGap();
   UiHeading("PERIOD CONCENTRATION  (by close date)");
   int   pedges[6] = {0, 176, 250, 370, 500, 628};
   string phead[6] = {"PERIOD", "BEST", "SHARE", "NET W/O BEST", "WORST", "NET W/O WORST"};
   UiColors(colors, 6, ABRA_CLR_DIM, ABRA_CLR_DIM);
   UiRow(phead, pedges, colors, true);
   string names[3] = {"Day", "Week", "Month"};
   for(int p = 0; p < 3; p++)
     {
      AbraPeriodConc c;
      AbraGetPeriod(s, p, c);
      string cells[6];
      cells[0] = names[p] + " (" + AbraInt(c.periods) + ")";
      cells[1] = c.valid ? AbraMoney(c.best_net) : "--";
      cells[2] = AbraShare(c.share_state, c.share_pct);
      cells[3] = c.valid ? AbraMoney(c.net_ex_best) : "--";
      cells[4] = c.valid ? AbraMoney(c.worst_net) : "--";
      cells[5] = c.valid ? AbraMoney(c.net_ex_worst) : "--";
      UiColors(colors, 6, ABRA_CLR_TEXT, ABRA_CLR_TEXT);
      UiRow(cells, pedges, colors);
     }
   UiNote("N/A: total net <= 0, so a share of it has no meaning.  --: not enough trades or periods.");
   UiNote("Worst-trade removal shows sensitivity to extremes. It is not an adjusted result.");
  }

void AbraTabDrawdown()
  {
   const AbraDDStats d = g_stats.dd;
   bool has = (d.max_dd > 0.0);
   UiHeading("CLOSED-EQUITY DRAWDOWN");
   UiKV2("Maximum drawdown", AbraMoneyPlain(d.max_dd), ABRA_CLR_TEXT,
         "Maximum drawdown %", d.pct_valid ? AbraPct(d.max_dd_pct) : "N/A", ABRA_CLR_TEXT);
   UiKV2("Peak (start)", has ? AbraTime(d.peak_time) : "--", ABRA_CLR_TEXT,
         "Bottom", has ? AbraTime(d.bottom_time) : "--", ABRA_CLR_TEXT);
   UiKV2("Recovery", !has ? "--" : (d.recovery_idx >= 0 ? AbraTime(d.recovery_time) : "not recovered"), ABRA_CLR_TEXT,
         "Peak to recovery", (has && d.recovery_idx >= 0) ? AbraDuration((long)(d.recovery_time - d.peak_time)) : "--", ABRA_CLR_TEXT);
   UiKV2("Trades peak to bottom", has ? IntegerToString(d.bottom_idx - d.peak_idx) : "--", ABRA_CLR_TEXT,
         "Capital base for %", d.pct_valid ? AbraMoneyPlain(d.base) : "none", ABRA_CLR_TEXT);
   UiGap();
   UiHeading("UNDERWATER PERIODS");
   bool uw = (d.episodes > 0);
   UiKV2("Longest underwater", uw ? AbraDuration(d.longest_uw_seconds) + (d.uw_ongoing ? " (ongoing)" : "") : "--", ABRA_CLR_TEXT,
         "Trades underwater", uw ? AbraInt(d.longest_uw_trades) : "--", ABRA_CLR_TEXT);
   UiKV2("From", uw ? AbraTime(d.uw_start) : "--", ABRA_CLR_TEXT, "To", uw ? AbraTime(d.uw_end) : "--", ABRA_CLR_TEXT);
   UiKV2("Drawdown episodes", AbraInt(d.episodes), ABRA_CLR_TEXT,
         "Episodes >= 50% of max", AbraInt(d.episodes_major), ABRA_CLR_TEXT);
   string src = (g_base_source == 1) ? "input" : ((g_base_source == 2) ? "auto (balance)" : "none");
   UiKV2("Capital base source", src, ABRA_CLR_TEXT);
   UiGap();
   UiNote("Closed-equity drawdown is reconstructed from completed historical trades.", ABRA_CLR_AMBER);
   UiNote("It may differ materially from intratrade floating-equity drawdown.", ABRA_CLR_AMBER);
   UiNote("% = drop / (capital base + closed-equity peak). Deposits and withdrawals are not part of the curve.");
   UiNote("The largest % drop may belong to a different episode than the largest amount.");
  }

void AbraTabStreaks()
  {
   const AbraStreakStats k = g_stats.streaks;
   UiHeading("STREAKS  (trades in closing order)");
   UiKV2("Longest winning streak", IntegerToString(k.longest_win), ABRA_CLR_TEXT,
         "Longest losing streak", IntegerToString(k.longest_loss), ABRA_CLR_TEXT);
   UiKV2("Largest win-streak profit", AbraMoney(k.best_win_run_sum), AbraSignColor(k.best_win_run_sum),
         "Largest loss-streak loss", AbraMoney(k.worst_loss_run_sum), AbraSignColor(k.worst_loss_run_sum));
   UiKV2("Average winning streak", DoubleToString(k.avg_win_len, 2), ABRA_CLR_TEXT,
         "Average losing streak", DoubleToString(k.avg_loss_len, 2), ABRA_CLR_TEXT);
   UiKV2("Winning streaks", AbraInt(k.win_runs), ABRA_CLR_TEXT, "Losing streaks", AbraInt(k.loss_runs), ABRA_CLR_TEXT);
   UiGap();
   UiHeading("LOSING STREAK COUNTS");
   UiKV2("Losing streaks >= 3", AbraInt(k.loss_ge3), ABRA_CLR_TEXT, "Losing streaks >= 5", AbraInt(k.loss_ge5), ABRA_CLR_TEXT);
   UiKV2("Losing streaks >= 10", AbraInt(k.loss_ge10), ABRA_CLR_TEXT);
   UiGap();
   UiNote("A streak is a run of consecutive winning or losing trades in closing order.");
   UiNote("A break-even trade ends the current streak.");
   UiNote("Maximum streak length and maximum cumulative streak loss may occur in different streaks.");
  }

// Short form of AbraSampleLabel() for table cells ("LARGE SAMPLE" -> "LARGE").
string AbraSampleShort(const int n)
  {
   string s = AbraSampleLabel(n);
   StringReplace(s, " SAMPLE", "");
   return s;
  }

void AbraNonEmptyBuckets(const AbraBucket &src[], AbraBucket &dst[])
  {
   ArrayResize(dst, 0);
   for(int i = 0; i < ArraySize(src); i++)
      if(src[i].n > 0)
        {
         int k = ArraySize(dst);
         ArrayResize(dst, k + 1);
         dst[k] = src[i];
        }
  }

void AbraTabTime()
  {
   string views[4] = {"YEAR", "MONTH", "WEEKDAY", "HOUR"};
   int bw = 86, bh = AbraRowH() + 2;
   for(int i = 0; i < 4; i++)
      AbraButton(ABRA_PREFIX + "TV_" + IntegerToString(i), AbraCX() + i * (bw + 4), g_cy, bw, bh, views[i], g_time_view == i);

   // Only buckets that contain trades are listed.
   AbraBucket shown[];
   if(g_time_view == ABRA_BUCKET_YEAR)         AbraNonEmptyBuckets(g_years, shown);
   else if(g_time_view == ABRA_BUCKET_MONTH)   AbraNonEmptyBuckets(g_months, shown);
   else if(g_time_view == ABRA_BUCKET_WEEKDAY) AbraNonEmptyBuckets(g_weekdays, shown);
   else                                        AbraNonEmptyBuckets(g_hours, shown);
   int per_page = ABRA_ROWS - 4;
   int pages = MathMax(1, (ArraySize(shown) + per_page - 1) / per_page);
   g_time_page = MathMax(0, MathMin(g_time_page, pages - 1));
   if(pages > 1)
     {
      AbraButton(ABRA_PREFIX + "PG_PREV", AbraCX() + AbraCW() - 130, g_cy, 30, bh, "<", false);
      AbraLabel(AbraCX() + AbraCW() - 50, g_cy + 3, IntegerToString(g_time_page + 1) + "/" + IntegerToString(pages),
                ABRA_CLR_DIM, MathMax(7, g_font - 1), true);
      AbraButton(ABRA_PREFIX + "PG_NEXT", AbraCX() + AbraCW() - 30, g_cy, 30, bh, ">", false);
     }
   g_cy += bh + 6;

   int    edges[6] = {0, 190, 330, 430, 520, 628};
   string head[6]  = {"BUCKET", "TRADES", "NET RESULT", "WIN RATE", "PF", "SAMPLE"};
   color  colors[];
   UiColors(colors, 6, ABRA_CLR_DIM, ABRA_CLR_DIM);
   UiRow(head, edges, colors, true);
   int first = g_time_page * per_page;
   int last  = MathMin(ArraySize(shown), first + per_page);
   for(int i = first; i < last; i++)
     {
      bool low = (shown[i].n < g_min_sample);
      double pf = 0.0;
      bool pf_ok = !low && AbraProfitFactor(shown[i].gp, shown[i].gl, pf);
      string cells[6];
      cells[0] = shown[i].label;
      cells[1] = AbraInt(shown[i].n);
      cells[2] = AbraMoney(shown[i].net);
      cells[3] = AbraWinRate(shown[i].wins, shown[i].n);
      cells[4] = pf_ok ? DoubleToString(pf, 2) : (low ? "--" : "N/A");
      // Below the minimum: LOW SAMPLE. Otherwise the program's existing
      // descriptive sample-size label for the bucket's trade count.
      cells[5] = low ? "LOW SAMPLE" : AbraSampleShort(shown[i].n);
      UiColors(colors, 6, ABRA_CLR_TEXT, ABRA_CLR_TEXT);
      colors[2] = AbraSignColor(shown[i].net);
      colors[5] = low ? ABRA_CLR_AMBER : ABRA_CLR_DIM;
      UiRow(cells, edges, colors);
     }
   if(ArraySize(shown) == 0)
      UiNote("No trades in this view.");
   UiNote("Buckets by " + (InpBucketTime == ABRA_BUCKET_BY_OPEN ? "open" : "close")
          + " time (server time). PF hidden below " + IntegerToString(g_min_sample) + " trades.");
  }

void AbraTabBuySell()
  {
   const AbraSideStats b = g_stats.buy;
   const AbraSideStats s = g_stats.sell;
   int    edges[3] = {0, 430, 628};
   color  colors[];
   string head[3]  = {"METRIC", "BUY", "SELL"};
   UiHeading("BUY vs SELL  (direction of the position)");
   UiColors(colors, 3, ABRA_CLR_DIM, ABRA_CLR_DIM);
   UiRow(head, edges, colors, true);

   double pfb = 0.0, pfs = 0.0;
   bool   okb = AbraProfitFactor(b.gp, b.gl, pfb), oks = AbraProfitFactor(s.gp, s.gl, pfs);
   int    total = MathMax(1, g_stats.n);
   string metric[10] = {"Trades", "Share of all trades", "Net result", "Gross profit", "Gross loss",
                        "Win rate", "Profit factor", "Average trade", "Largest winner", "Largest loser"};
   string vb[10], vs[10];
   vb[0] = AbraInt(b.n);                       vs[0] = AbraInt(s.n);
   vb[1] = AbraPct(100.0 * b.n / total);       vs[1] = AbraPct(100.0 * s.n / total);
   vb[2] = AbraMoney(b.net);                   vs[2] = AbraMoney(s.net);
   vb[3] = AbraMoneyPlain(b.gp);               vs[3] = AbraMoneyPlain(s.gp);
   vb[4] = AbraMoneyPlain(-b.gl);              vs[4] = AbraMoneyPlain(-s.gl);
   vb[5] = AbraWinRate(b.wins, b.n);           vs[5] = AbraWinRate(s.wins, s.n);
   vb[6] = b.n > 0 ? AbraPF(okb, pfb) : "--";  vs[6] = s.n > 0 ? AbraPF(oks, pfs) : "--";
   vb[7] = b.n > 0 ? AbraMoney(b.net / b.n) : "--";
   vs[7] = s.n > 0 ? AbraMoney(s.net / s.n) : "--";
   vb[8] = b.n > 0 ? AbraMoney(b.best) : "--"; vs[8] = s.n > 0 ? AbraMoney(s.best) : "--";
   vb[9] = b.n > 0 ? AbraMoney(b.worst) : "--"; vs[9] = s.n > 0 ? AbraMoney(s.worst) : "--";
   for(int i = 0; i < 10; i++)
     {
      string cells[3];
      cells[0] = metric[i];
      cells[1] = vb[i];
      cells[2] = vs[i];
      UiColors(colors, 3, ABRA_CLR_DIM, ABRA_CLR_TEXT);
      UiRow(cells, edges, colors);
     }
   UiGap();
   UiNote("BUY and SELL are shown separately without ranking. Differences may reflect market conditions, sample size or strategy logic.");
   if(b.n < g_min_sample || s.n < g_min_sample)
      UiNote("At least one side has fewer than " + IntegerToString(g_min_sample) + " trades (LOW SAMPLE).", ABRA_CLR_AMBER);
  }

void AbraTabDistribution()
  {
   const AbraStats s = g_stats;
   UiHeading("DISTRIBUTION OF TRADE RESULTS");
   UiKV2("Mean (average trade)", AbraMoney(s.avg), AbraSignColor(s.avg), "Median trade", AbraMoney(s.median), AbraSignColor(s.median));
   UiKV2("Mean minus median", AbraMoney(s.avg - s.median), ABRA_CLR_TEXT,
         "Std. deviation", s.stdev_valid ? AbraMoneyPlain(s.stdev) : "N/A", ABRA_CLR_TEXT);
   UiGap();
   UiHeading("PERCENTILES");
   UiKV2("Minimum", AbraMoney(s.minimum), AbraSignColor(s.minimum), "Maximum", AbraMoney(s.maximum), AbraSignColor(s.maximum));
   UiKV2("5th percentile", AbraMoney(s.p05), AbraSignColor(s.p05), "95th percentile", AbraMoney(s.p95), AbraSignColor(s.p95));
   UiKV2("10th percentile", AbraMoney(s.p10), AbraSignColor(s.p10), "90th percentile", AbraMoney(s.p90), AbraSignColor(s.p90));
   UiKV2("25th percentile", AbraMoney(s.p25), AbraSignColor(s.p25), "75th percentile", AbraMoney(s.p75), AbraSignColor(s.p75));
   UiKV2("50th percentile (median)", AbraMoney(s.median), AbraSignColor(s.median));
   UiGap();
   UiNote("Percentiles use linear interpolation between ranked trade results.");
   UiNote("The p-th percentile is the value below which approximately p% of observations fall.");
   UiNote("Mean-minus-median is descriptive only and should not be interpreted alone.");
   if(s.n < 30)
      UiNote("Percentiles of fewer than 30 trades move a lot with each new trade.", ABRA_CLR_AMBER);
  }

void AbraRender()
  {
   ObjectsDeleteAll(0, ABRA_PREFIX);
   g_obj_id = 0;
   int f      = g_font;
   int x0     = InpPanelX;
   int y0     = InpPanelY;
   int row_h  = AbraRowH();
   int tile_h = (int)(f * 6.4);
   int tab_h  = (int)(f * 2.6);

   // vertical layout (unscaled)
   int y_title   = y0 + ABRA_PAD;
   int y_sub     = y_title + (int)(f * 2.6);
   int y_tiles   = y_sub + (int)(f * 2.4);
   int y_tabs    = y_tiles + 2 * tile_h + 8 + 12;
   int y_content = y_tabs + tab_h + 12;
   int y_footer  = y_content + ABRA_ROWS * row_h + 8;
   int y_disc    = y_footer + (int)(f * 2.4) + 8;
   int h         = y_disc + (int)(f * 1.8) + ABRA_PAD - y0;

   AbraRect(ABRA_PREFIX + "BG", x0, y0, ABRA_PANEL_W, h, ABRA_CLR_BG, ABRA_CLR_BORDER);
   AbraRect(AbraNextName(), x0, y0, ABRA_PANEL_W, 3, ABRA_CLR_AMBER, ABRA_CLR_AMBER);

   string title = "ARIXIS BACKTEST ROBUSTNESS ANALYZER";
   string sub   = "Closed trades | " + AbraScopeText();
   AbraLabel(AbraCX(), y_title, title, ABRA_CLR_AMBER, AbraFitSize(title, f + 4, f, AbraCW(), "Segoe UI Semibold"), false, "Segoe UI Semibold");
   AbraLabel(AbraCX(), y_sub, sub, ABRA_CLR_DIM, AbraFitSize(sub, MathMax(7, f - 1), 6, AbraCW(), "Segoe UI"));

   AbraRenderTiles(y_tiles, tile_h);

   int gap = 4, tw = (AbraCW() - 6 * gap) / 7;
   for(int i = 0; i < 7; i++)
      AbraButton(ABRA_PREFIX + "TAB_" + IntegerToString(i), AbraCX() + i * (tw + gap), y_tabs, tw, tab_h, ABRA_TABS[i], g_tab == i);

   g_cy = y_content;
   if(g_error != "")
     {
      UiHeading("ANALYSIS NOT AVAILABLE");
      UiNote(g_error, ABRA_CLR_NEG);
     }
   else if(!g_ready)
      UiNote("Reading account history...");
   else if(g_stats.n == 0)
     {
      UiHeading("NO CLOSED TRADES MATCH THE CURRENT SETTINGS");
      UiNote("Check the date range, symbol and magic filters, or load more history in the");
      UiNote("Account History tab (right-click > All History).");
      UiGap();
      UiKV2("Deals scanned", AbraInt(g_info.deals_total), ABRA_CLR_TEXT, "Trade deals", AbraInt(g_info.trade_deals), ABRA_CLR_TEXT);
      UiKV2("Round trips (all)", AbraInt(g_info.round_trips), ABRA_CLR_TEXT, "Open positions", AbraInt(g_info.open_positions), ABRA_CLR_TEXT);
     }
   else
     {
      switch(g_tab)
        {
         case 0: AbraTabOverview();     break;
         case 1: AbraTabDependency();   break;
         case 2: AbraTabDrawdown();     break;
         case 3: AbraTabStreaks();      break;
         case 4: AbraTabTime();         break;
         case 5: AbraTabBuySell();      break;
         default: AbraTabDistribution(); break;
        }
     }

   // footer: below the fixed content area, or below the content if a tab is taller
   if(g_cy + 8 > y_footer)
     {
      int shift = g_cy + 8 - y_footer;
      y_footer += shift;
      y_disc   += shift;
      h        += shift;
      ObjectSetInteger(0, ABRA_PREFIX + "BG", OBJPROP_YSIZE, AbraS(h));
     }
   AbraRect(AbraNextName(), AbraCX(), y_footer - 4, AbraCW(), 1, ABRA_CLR_BORDER, ABRA_CLR_BORDER);
   int bh = (int)(f * 2.4);
   AbraButton(ABRA_PREFIX + "BTN_REFRESH", AbraCX(), y_footer + 4, 100, bh, "REFRESH", false);
   if(InpEnableCSVExport)
      AbraButton(ABRA_PREFIX + "BTN_EXPORT", AbraCX() + 108, y_footer + 4, 110, bh, "EXPORT CSV", false);
   int status_slot = AbraCW() - 2 - (InpEnableCSVExport ? 218 : 100) - 10;
   AbraLabel(AbraCX() + AbraCW() - 2, y_footer + 8, g_status, ABRA_CLR_DIM,
             AbraFitSize(g_status, MathMax(7, f - 2), 6, status_slot, "Segoe UI"), true);
   AbraLabel(AbraCX(), y_disc, "Historical measurements only. No forecast. Read-only.", ABRA_CLR_DIM, MathMax(7, f - 2));
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| 8. CSV EXPORT                                                    |
//+------------------------------------------------------------------+
// Written with FileOpen() into <data folder>\MQL5\Files, the only place an
// MQL5 program may write. No account number, name or server is exported.
string AbraCsvCell(const string s)
  {
   if(StringFind(s, ",") < 0 && StringFind(s, "\"") < 0)
      return s;
   string q = s;
   StringReplace(q, "\"", "\"\"");
   return "\"" + q + "\"";
  }

void AbraCsv(const int h, const string a, const string b = "", const string c = "",
             const string d = "", const string e = "", const string f = "")
  {
   string line = AbraCsvCell(a);
   string rest[5];
   rest[0] = b; rest[1] = c; rest[2] = d; rest[3] = e; rest[4] = f;
   int last = -1;
   for(int i = 0; i < 5; i++)
      if(rest[i] != "")
         last = i;
   for(int i = 0; i <= last; i++)
      line += "," + AbraCsvCell(rest[i]);
   FileWriteString(h, line + "\r\n");
  }

string AbraD(const double v) { return DoubleToString(v, g_money_digits); }
string AbraShareCsv(const int state, const double pct)
  {
   if(state == ABRA_SHARE_OK)          return DoubleToString(pct, 2);
   if(state == ABRA_SHARE_NONPOSITIVE) return "N/A (total net <= 0)";
   return "N/A (too few observations)";
  }

void AbraCsvBuckets(const int h, const string title, const AbraBucket &b[])
  {
   AbraCsv(h, "");
   AbraCsv(h, "[" + title + "]");
   AbraCsv(h, "Bucket", "Trades", "Net", "Win rate %", "Profit factor", "Sample note");
   for(int i = 0; i < ArraySize(b); i++)
     {
      double pf = 0.0;
      bool low = (b[i].n < g_min_sample);
      bool ok  = !low && AbraProfitFactor(b[i].gp, b[i].gl, pf);
      AbraCsv(h, b[i].label, IntegerToString(b[i].n), AbraD(b[i].net),
              b[i].n > 0 ? DoubleToString(100.0 * b[i].wins / b[i].n, 2) : "",
              ok ? DoubleToString(pf, 4) : "N/A", low ? "LOW SAMPLE" : "");
     }
  }

bool AbraExportCsv(string &file_name)
  {
   if(!g_ready)
      return false;
   MqlDateTime t;
   TimeToStruct(TimeLocal(), t);
   file_name = StringFormat("Arixis_Backtest_Robustness_%04d%02d%02d_%02d%02d%02d.csv",
                            t.year, t.mon, t.day, t.hour, t.min, t.sec);
   int h = FileOpen(file_name, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;
   const AbraStats s = g_stats;

   AbraCsv(h, "Arixis Backtest Robustness Analyzer", "1.00");
   AbraCsv(h, "Note", "Historical measurements only. Not a forecast of future results.");
   AbraCsv(h, "");
   AbraCsv(h, "[SETTINGS]");
   AbraCsv(h, "From (close time)", g_filter.from_time > 0 ? TimeToString(g_filter.from_time) : "start of history");
   AbraCsv(h, "To (close time)", g_filter.to_time > 0 ? TimeToString(g_filter.to_time) : "now");
   AbraCsv(h, "Symbol", g_filter.symbol_only ? g_filter.symbol : "all symbols");
   AbraCsv(h, "Magic filter", g_filter.use_magic ? IntegerToString(g_filter.magic) : "off");
   AbraCsv(h, "Manual trades only", g_filter.manual_only ? "yes" : "no");
   AbraCsv(h, "Include commission", g_filter.inc_commission ? "yes" : "no");
   AbraCsv(h, "Include swap", g_filter.inc_swap ? "yes" : "no");
   AbraCsv(h, "Include fees", g_filter.inc_fee ? "yes" : "no");
   AbraCsv(h, "Time buckets by", InpBucketTime == ABRA_BUCKET_BY_OPEN ? "open time" : "close time");
   AbraCsv(h, "Min sample per bucket", IntegerToString(g_min_sample));
   AbraCsv(h, "Account currency", g_currency);
   AbraCsv(h, "Exported (local time)", TimeToString(TimeLocal(), TIME_DATE | TIME_SECONDS));

   AbraCsv(h, "");
   AbraCsv(h, "[SAMPLE]");
   AbraCsv(h, "Trades analyzed", IntegerToString(s.n));
   AbraCsv(h, "Sample label (descriptive only)", AbraSampleLabel(s.n));
   AbraCsv(h, "Deals scanned", IntegerToString(g_info.deals_total));
   AbraCsv(h, "Trade deals", IntegerToString(g_info.trade_deals));
   AbraCsv(h, "Partial exits merged", IntegerToString(g_info.partial_exits));
   AbraCsv(h, "Reversals (INOUT)", IntegerToString(g_info.reversals));
   AbraCsv(h, "Exits without entry deal", IntegerToString(g_info.orphan_exits));
   AbraCsv(h, "Open positions skipped", IntegerToString(g_info.open_positions));
   AbraCsv(h, "Realized on open positions (excluded)", AbraD(g_info.open_realized));
   AbraCsv(h, "Other charges in range (excluded)", AbraD(g_info.other_amount));
   AbraCsv(h, "Invalid deals skipped", IntegerToString(g_info.invalid_deals));
   AbraCsv(h, "NaN/INF values replaced by 0", IntegerToString(g_info.sanitized_values));

   AbraCsv(h, "");
   AbraCsv(h, "[BASIC]");
   AbraCsv(h, "Net result", AbraD(s.net));
   AbraCsv(h, "Gross profit", AbraD(s.gp));
   AbraCsv(h, "Gross loss", AbraD(-s.gl));
   AbraCsv(h, "Profit factor", s.pf_valid ? DoubleToString(s.pf, 4) : "N/A (no losing trades)");
   AbraCsv(h, "Win rate %", s.n > 0 ? DoubleToString(100.0 * s.wins / s.n, 2) : "N/A");
   AbraCsv(h, "Winning trades", IntegerToString(s.wins));
   AbraCsv(h, "Losing trades", IntegerToString(s.losses));
   AbraCsv(h, "Break-even trades", IntegerToString(s.be));
   AbraCsv(h, "Average trade", AbraD(s.avg));
   AbraCsv(h, "Expected payoff (net / trades)", AbraD(s.avg));
   AbraCsv(h, "Median trade", AbraD(s.median));
   AbraCsv(h, "Largest winner", AbraD(s.best));
   AbraCsv(h, "Largest loser", AbraD(s.worst));
   AbraCsv(h, "Average winner", s.wins > 0 ? AbraD(s.avg_win) : "N/A");
   AbraCsv(h, "Average loser", s.losses > 0 ? AbraD(s.avg_loss) : "N/A");
   AbraCsv(h, "Profit/loss ratio", s.plr_valid ? DoubleToString(s.plr, 4) : "N/A");

   AbraCsv(h, "");
   AbraCsv(h, "[PROFIT DEPENDENCY]");
   AbraCsv(h, "Best trades removed", "Removed sum", "Net after removal", "Share of total net %");
   for(int j = 0; j < 4; j++)
     {
      const AbraRemoval r = s.best_removed[j];
      AbraCsv(h, IntegerToString(ABRA_TOP_N[j]), r.valid ? AbraD(r.removed_sum) : "N/A",
              r.valid ? AbraD(r.net_after) : "N/A", AbraShareCsv(r.share_state, r.share_pct));
     }
   AbraCsv(h, "");
   AbraCsv(h, "[HISTORICAL SENSITIVITY ANALYSIS]");
   AbraCsv(h, "Worst trades removed", "Removed sum", "Net after removal");
   for(int j = 0; j < 4; j++)
     {
      const AbraRemoval r = s.worst_removed[j];
      AbraCsv(h, IntegerToString(ABRA_TOP_N[j]), r.valid ? AbraD(r.removed_sum) : "N/A",
              r.valid ? AbraD(r.net_after) : "N/A");
     }
   AbraCsv(h, "");
   AbraCsv(h, "[PERIOD CONCENTRATION]");
   AbraCsv(h, "Period", "Periods", "Best period start", "Best net", "Best share of net %", "Net excl. best");
   string names[3] = {"Day", "Week", "Month"};
   for(int p = 0; p < 3; p++)
     {
      AbraPeriodConc c;
      AbraGetPeriod(s, p, c);
      AbraCsv(h, names[p], IntegerToString(c.periods), c.valid ? AbraDate(c.best_start) : "N/A",
              c.valid ? AbraD(c.best_net) : "N/A", AbraShareCsv(c.share_state, c.share_pct),
              c.valid ? AbraD(c.net_ex_best) : "N/A");
     }
   AbraCsv(h, "Period", "Periods", "Worst period start", "Worst net", "Net excl. worst");
   for(int p = 0; p < 3; p++)
     {
      AbraPeriodConc c;
      AbraGetPeriod(s, p, c);
      AbraCsv(h, names[p], IntegerToString(c.periods), c.valid ? AbraDate(c.worst_start) : "N/A",
              c.valid ? AbraD(c.worst_net) : "N/A", c.valid ? AbraD(c.net_ex_worst) : "N/A");
     }

   AbraCsv(h, "");
   AbraCsv(h, "[CLOSED-EQUITY DRAWDOWN]");
   AbraCsv(h, "Note", "Reconstructed from completed historical results; may differ materially from intratrade floating-equity drawdown.");
   AbraCsv(h, "Maximum drawdown", AbraD(s.dd.max_dd));
   AbraCsv(h, "Maximum drawdown %", s.dd.pct_valid ? DoubleToString(s.dd.max_dd_pct, 2) : "N/A (no capital base)");
   AbraCsv(h, "Capital base", s.dd.pct_valid ? AbraD(s.dd.base) : "N/A");
   AbraCsv(h, "Peak time", s.dd.max_dd > 0 ? AbraTime(s.dd.peak_time) : "N/A");
   AbraCsv(h, "Bottom time", s.dd.max_dd > 0 ? AbraTime(s.dd.bottom_time) : "N/A");
   AbraCsv(h, "Recovery time", s.dd.max_dd > 0 ? (s.dd.recovery_idx >= 0 ? AbraTime(s.dd.recovery_time) : "not recovered") : "N/A");
   AbraCsv(h, "Longest underwater (seconds)", s.dd.episodes > 0 ? IntegerToString(s.dd.longest_uw_seconds) : "N/A");
   AbraCsv(h, "Longest underwater (trades)", s.dd.episodes > 0 ? IntegerToString(s.dd.longest_uw_trades) : "N/A");
   AbraCsv(h, "Longest underwater from", s.dd.episodes > 0 ? AbraTime(s.dd.uw_start) : "N/A");
   AbraCsv(h, "Longest underwater to", s.dd.episodes > 0 ? AbraTime(s.dd.uw_end) + (s.dd.uw_ongoing ? " (ongoing)" : "") : "N/A");
   AbraCsv(h, "Drawdown episodes", IntegerToString(s.dd.episodes));
   AbraCsv(h, "Episodes >= 50% of max", IntegerToString(s.dd.episodes_major));

   AbraCsv(h, "");
   AbraCsv(h, "[STREAKS]");
   AbraCsv(h, "Longest winning streak", IntegerToString(s.streaks.longest_win));
   AbraCsv(h, "Longest losing streak", IntegerToString(s.streaks.longest_loss));
   AbraCsv(h, "Largest winning-streak profit", AbraD(s.streaks.best_win_run_sum));
   AbraCsv(h, "Largest losing-streak loss", AbraD(s.streaks.worst_loss_run_sum));
   AbraCsv(h, "Average winning streak length", DoubleToString(s.streaks.avg_win_len, 2));
   AbraCsv(h, "Average losing streak length", DoubleToString(s.streaks.avg_loss_len, 2));
   AbraCsv(h, "Losing streaks >= 3", IntegerToString(s.streaks.loss_ge3));
   AbraCsv(h, "Losing streaks >= 5", IntegerToString(s.streaks.loss_ge5));
   AbraCsv(h, "Losing streaks >= 10", IntegerToString(s.streaks.loss_ge10));

   AbraCsv(h, "");
   AbraCsv(h, "[BUY VS SELL]");
   AbraCsv(h, "Metric", "BUY", "SELL");
   double pfb = 0.0, pfs = 0.0;
   bool okb = AbraProfitFactor(s.buy.gp, s.buy.gl, pfb), oks = AbraProfitFactor(s.sell.gp, s.sell.gl, pfs);
   AbraCsv(h, "Trades", IntegerToString(s.buy.n), IntegerToString(s.sell.n));
   AbraCsv(h, "Net result", AbraD(s.buy.net), AbraD(s.sell.net));
   AbraCsv(h, "Gross profit", AbraD(s.buy.gp), AbraD(s.sell.gp));
   AbraCsv(h, "Gross loss", AbraD(-s.buy.gl), AbraD(-s.sell.gl));
   AbraCsv(h, "Win rate %", s.buy.n > 0 ? DoubleToString(100.0 * s.buy.wins / s.buy.n, 2) : "N/A",
           s.sell.n > 0 ? DoubleToString(100.0 * s.sell.wins / s.sell.n, 2) : "N/A");
   AbraCsv(h, "Profit factor", okb ? DoubleToString(pfb, 4) : "N/A", oks ? DoubleToString(pfs, 4) : "N/A");
   AbraCsv(h, "Average trade", s.buy.n > 0 ? AbraD(s.buy.net / s.buy.n) : "N/A", s.sell.n > 0 ? AbraD(s.sell.net / s.sell.n) : "N/A");
   AbraCsv(h, "Largest winner", s.buy.n > 0 ? AbraD(s.buy.best) : "N/A", s.sell.n > 0 ? AbraD(s.sell.best) : "N/A");
   AbraCsv(h, "Largest loser", s.buy.n > 0 ? AbraD(s.buy.worst) : "N/A", s.sell.n > 0 ? AbraD(s.sell.worst) : "N/A");

   AbraCsv(h, "");
   AbraCsv(h, "[DISTRIBUTION]");
   AbraCsv(h, "Mean", AbraD(s.avg));
   AbraCsv(h, "Standard deviation (sample)", s.stdev_valid ? AbraD(s.stdev) : "N/A");
   AbraCsv(h, "Minimum", AbraD(s.minimum));
   AbraCsv(h, "P05", AbraD(s.p05));
   AbraCsv(h, "P10", AbraD(s.p10));
   AbraCsv(h, "P25", AbraD(s.p25));
   AbraCsv(h, "Median", AbraD(s.median));
   AbraCsv(h, "P75", AbraD(s.p75));
   AbraCsv(h, "P90", AbraD(s.p90));
   AbraCsv(h, "P95", AbraD(s.p95));
   AbraCsv(h, "Maximum", AbraD(s.maximum));

   AbraCsvBuckets(h, "YEARLY", g_years);
   AbraCsvBuckets(h, "MONTHLY", g_months);
   AbraCsvBuckets(h, "WEEKDAY", g_weekdays);
   AbraCsvBuckets(h, "HOURLY", g_hours);
   FileClose(h);
   return true;
  }

//+------------------------------------------------------------------+
//| 9. EVENT HANDLERS                                                |
//+------------------------------------------------------------------+
#ifndef ABRA_SELFTEST_BUILD
int OnInit()
  {
   IndicatorSetString(INDICATOR_SHORTNAME, "Arixis Backtest Robustness Analyzer");
   g_font  = MathMax(8, MathMin(14, InpFontSize));
   g_scale = MathMax(1.0, MathMin(3.0, TerminalInfoInteger(TERMINAL_SCREEN_DPI) / 96.0));
   g_ready = false;
   g_retry = 0;
   AbraFillFilter(g_filter);
   AbraRender();
   // The analysis runs from a short timer rather than inside OnInit, so the
   // terminal can finish loading the account history after a restart.
   // The timer is stopped after the first analysis; it never runs per tick.
   EventSetTimer(1);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(0, ABRA_PREFIX);
   ChartRedraw(0);
  }

void OnTimer()
  {
   g_retry++;
   bool connected = (TerminalInfoInteger(TERMINAL_CONNECTED) != 0);
   if(!connected && g_retry < 5)
      return;                        // give the terminal a few seconds to connect
   EventKillTimer();
   AbraRunAnalysis();
   AbraRender();
  }

int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[])
  {
   return rates_total;               // no buffers: all work is event-driven
  }

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id != CHARTEVENT_OBJECT_CLICK || StringFind(sparam, ABRA_PREFIX) != 0)
      return;
   if(sparam == ABRA_PREFIX + "BTN_REFRESH")
     {
      g_status = "Refreshing...";
      AbraRunAnalysis();
     }
   else if(sparam == ABRA_PREFIX + "BTN_EXPORT")
     {
      string file_name = "";
      if(AbraExportCsv(file_name))
         g_status = "Saved MQL5\\Files\\" + file_name;
      else
         g_status = "Export failed (error " + IntegerToString(GetLastError()) + ")";
      Print("Arixis Backtest Robustness Analyzer: ", g_status);
     }
   else if(StringFind(sparam, ABRA_PREFIX + "TAB_") == 0)
      g_tab = (int)StringToInteger(StringSubstr(sparam, StringLen(ABRA_PREFIX + "TAB_")));
   else if(StringFind(sparam, ABRA_PREFIX + "TV_") == 0)
     {
      g_time_view = (int)StringToInteger(StringSubstr(sparam, StringLen(ABRA_PREFIX + "TV_")));
      g_time_page = 0;
     }
   else if(sparam == ABRA_PREFIX + "PG_PREV")
      g_time_page = MathMax(0, g_time_page - 1);
   else if(sparam == ABRA_PREFIX + "PG_NEXT")
      g_time_page++;
   else
      return;
   AbraRender();
  }
#endif
//+------------------------------------------------------------------+
