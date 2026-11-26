//+------------------------------------------------------------------+
//| TransactionCostCollector.mq5                                     |
//| Patrick M. Njoroge                                               |
//| https://www.mql5.com/en/users/patricknjoroge743                  |
//+------------------------------------------------------------------+
#property copyright "Patrick M. Njoroge"
#property link      "https://www.mql5.com/en/users/patricknjoroge743"
#property version   "3.00"
#property strict
#property script_show_inputs

//--- Collects transaction cost data for a symbol: spread distributions
//--- under four distinct weighting schemes, swap rates, execution
//--- constraints, and an audit of the broker-stored bar spread field.
//---
//--- Every spread statistic is derived from real ticks via
//--- CopyTicksRange. The broker-stored per-bar spread field is read
//--- only so that its behavior can be measured against the ticks that
//--- formed the same bar; it is never used as a cost estimate.
//---
//--- Run as a Script on any chart of the target symbol. The chart
//--- timeframe is irrelevant; the execution timeframe is an input.
//--- Output: <terminal_data_path>/MQL5/Files/<symbol>_costs.csv
//--- All emitted bytes are ASCII so the CSV parses as UTF-8.

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input int             InpDays         = 30;          // Lookback window in calendar days
input ENUM_TIMEFRAMES InpExecTF       = PERIOD_H1;   // Execution timeframe for conditional sampling
input bool            InpAuditBarField= true;        // Audit broker-stored M1 spread against ticks
input int             InpMaxDwellSec  = 60;          // Cap on per-tick dwell time in seconds
input int             InpRetryMs      = 200;         // Sleep between tick download retries
input int             InpMaxRetries   = 25;          // Retries per day before declaring the day empty
input string          InpOutputFile   = "";          // Override filename (blank = <symbol>_costs.csv)

//+------------------------------------------------------------------+
//| Internal constants                                               |
//+------------------------------------------------------------------+
#define CSV_SEP        ","      // CSV field separator
#define NA_FIELD       ""       // Placeholder for empty unit/note fields
#define MAX_SPREAD_BIN 5000     // Histogram cap in points; larger spreads clamp here
#define SEC_PER_DAY    86400    // Seconds in one calendar day

//+------------------------------------------------------------------+
//| Accumulates spread mass under four weighting schemes plus the    |
//| diagnostics needed to detect silent sampling failure.            |
//+------------------------------------------------------------------+
class CSpreadStats
  {
public:
   //--- Histograms indexed by spread in points
   long              hist_tick[];       // Weight 1 per tick
   double            hist_time[];       // Weight = dwell seconds until next tick
   long              hist_exec[];       // Weight 1 per execution-timeframe boundary
   long              hist_bar[];        // Weight 1 per broker-stored M1 bar value

   //--- Per-hour tick-weighted accumulators (broker time)
   long              hour_cnt[24];
   double            hour_sum_pts[24];

   //--- Sampling diagnostics
   long              n_ticks;           // Ticks accepted into hist_tick
   long              n_invalid;         // Ticks rejected as one-sided or crossed
   long              n_clamped;         // Ticks whose spread exceeded MAX_SPREAD_BIN
   long              n_exec_points;     // Execution boundaries with a prevailing quote
   long              n_exec_missed;     // Boundaries skipped because the tick gap was too wide
   double            total_dwell_sec;   // Sum of capped dwell weights
   double            capped_dwell_sec;  // Dwell mass lost to the InpMaxDwellSec cap
   int               days_requested;
   int               days_with_ticks;
   long              first_tick_msc;
   long              last_tick_msc;

   //--- Audit of the broker-stored bar spread field against its own ticks
   long              audit_bars;        // M1 bars with at least one tick
   long              audit_eq_min;      // Stored value equals tick minimum
   long              audit_eq_open;     // Stored value equals first tick of the bar
   long              audit_eq_close;    // Stored value equals last tick of the bar
   long              audit_eq_max;      // Stored value equals tick maximum
   double            audit_sum_stored;  // Sum of stored spreads over audited bars
   double            audit_sum_tickmean;// Sum of per-bar tick-mean spreads
   double            audit_sum_tickmax; // Sum of per-bar tick-max spreads

                     CSpreadStats(void) { Reset(); }

   //--- Allocate histograms and zero every counter
   void              Reset(void)
     {
      ArrayResize(hist_tick, MAX_SPREAD_BIN + 1);
      ArrayResize(hist_time, MAX_SPREAD_BIN + 1);
      ArrayResize(hist_exec, MAX_SPREAD_BIN + 1);
      ArrayResize(hist_bar,  MAX_SPREAD_BIN + 1);
      ArrayInitialize(hist_tick, 0);
      ArrayInitialize(hist_time, 0.0);
      ArrayInitialize(hist_exec, 0);
      ArrayInitialize(hist_bar,  0);
      ArrayInitialize(hour_cnt,  0);
      ArrayInitialize(hour_sum_pts, 0.0);

      n_ticks          = 0;
      n_invalid        = 0;
      n_clamped        = 0;
      n_exec_points    = 0;
      n_exec_missed    = 0;
      total_dwell_sec  = 0.0;
      capped_dwell_sec = 0.0;
      days_requested   = 0;
      days_with_ticks  = 0;
      first_tick_msc   = 0;
      last_tick_msc    = 0;

      audit_bars         = 0;
      audit_eq_min       = 0;
      audit_eq_open      = 0;
      audit_eq_close     = 0;
      audit_eq_max       = 0;
      audit_sum_stored   = 0.0;
      audit_sum_tickmean = 0.0;
      audit_sum_tickmax  = 0.0;
     }
  };

//+------------------------------------------------------------------+
//| Forward declarations                                             |
//+------------------------------------------------------------------+
void   WriteCsvRow(int fh, string section, string key, string value,
                   string unit, string note);
string CsvSafe(string s);
void   CollectSymbolProperties(int fh, string symbol);
void   CollectExecutionConstraints(int fh, string symbol);
void   CollectSwapInfo(int fh, string symbol);
void   CollectCommissionInfo(int fh);
bool   SampleTicks(string symbol, CSpreadStats &st);
int    CopyDayTicks(string symbol, datetime day_start, datetime day_end,
                    MqlTick &ticks[]);
void   AuditBarField(string symbol, datetime day_start, datetime day_end,
                     const MqlTick &ticks[], int n, double point,
                     CSpreadStats &st);
long   PercentileLong(const long &hist[], long n, double q);
long   PercentileDouble(const double &hist[], double total, double q);
void   WriteDistributionLong(int fh, string sec, const long &hist[],
                             long n, double pip_factor, string note);
void   WriteDistributionDouble(int fh, string sec, const double &hist[],
                               double total, double pip_factor, string note);
void   WriteDiagnostics(int fh, const CSpreadStats &st);
void   WriteSessionSpread(int fh, const CSpreadStats &st, double pip_factor);
void   WriteAudit(int fh, const CSpreadStats &st);

//+------------------------------------------------------------------+
//| Script entry point                                               |
//+------------------------------------------------------------------+
void OnStart()
  {
   string symbol = Symbol();
   int    digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double point  = SymbolInfoDouble(symbol, SYMBOL_POINT);

   if(point <= 0.0)
     {
      Print("ERROR: SYMBOL_POINT is not positive for ", symbol);
      return;
     }

//--- Points per pip: 10 for 5-digit and 3-digit quotes, otherwise 1
   double pip_factor = (digits == 3 || digits == 5) ? 10.0 : 1.0;

//--- Prepare output file; FILE_ANSI is safe because every byte is ASCII
   string fname = InpOutputFile != "" ? InpOutputFile : symbol + "_costs.csv";
   int fh = FileOpen(fname, FILE_WRITE | FILE_CSV | FILE_ANSI, ',');
   if(fh == INVALID_HANDLE)
     {
      Print("ERROR: cannot open output file: ", fname, " err=", GetLastError());
      return;
     }

   FileWrite(fh, "section" + CSV_SEP + "key" + CSV_SEP + "value" +
             CSV_SEP + "unit" + CSV_SEP + "note");

//--- Static broker properties; the terminal is the only source for these
   CollectSymbolProperties(fh, symbol);
   CollectExecutionConstraints(fh, symbol);
   CollectSwapInfo(fh, symbol);
   CollectCommissionInfo(fh);

//--- Tick sampling
   CSpreadStats st;
   bool ok = SampleTicks(symbol, st);

   WriteDiagnostics(fh, st);

   if(!ok)
     {
      WriteCsvRow(fh, "status", "error", "tick_sampling_failed", NA_FIELD,
                  "no spread sections written; sections above remain valid");
      FileClose(fh);
      Print("ERROR: tick sampling returned no usable ticks.");
      return;
     }

//--- Four distributions. Each is a different estimator of a different
//--- quantity; the labels are explicit so downstream code cannot
//--- silently substitute one for another.
   WriteDistributionLong(fh, "spread_tick_weighted", st.hist_tick,
                         st.n_ticks, pip_factor,
                         "one weight per tick; over-weights high-activity hours");

   WriteDistributionDouble(fh, "spread_time_weighted", st.hist_time,
                           st.total_dwell_sec, pip_factor,
                           "weight = dwell seconds; unconditional quote distribution");

   WriteDistributionLong(fh, "spread_exec_conditional", st.hist_exec,
                         st.n_exec_points, pip_factor,
                         "prevailing quote at each " +
                         EnumToString(InpExecTF) + " boundary; use this for cost modeling");

   if(InpAuditBarField && st.audit_bars > 0)
     {
      WriteDistributionLong(fh, "spread_bar_field", st.hist_bar,
                            st.audit_bars, pip_factor,
                            "broker-stored M1 field; reported for comparison only");
      WriteAudit(fh, st);
     }

   WriteSessionSpread(fh, st, pip_factor);
   WriteCsvRow(fh, "status", "ok", "complete", NA_FIELD, "");

   FileClose(fh);

   Print("TransactionCostCollector: wrote ", fname);
   Print("  Lookback days     : ", InpDays,
         " (days with ticks: ", st.days_with_ticks, ")");
   Print("  Ticks accepted    : ", st.n_ticks,
         "  invalid: ", st.n_invalid, "  clamped: ", st.n_clamped);
   Print("  Exec samples      : ", st.n_exec_points,
         "  missed boundaries: ", st.n_exec_missed);
   if(st.audit_bars > 0)
      Print("  M1 bars audited   : ", st.audit_bars);
  }

//+------------------------------------------------------------------+
//| Replace characters that would break the flat CSV layout          |
//+------------------------------------------------------------------+
string CsvSafe(string s)
  {
   StringReplace(s, ",",  ";");
   StringReplace(s, "\"", "'");
   StringReplace(s, "\n", " ");
   StringReplace(s, "\r", " ");
   return(s);
  }

//+------------------------------------------------------------------+
//| Write a single CSV row in the standard five-column format        |
//+------------------------------------------------------------------+
void WriteCsvRow(int fh, string section, string key, string value,
                 string unit, string note)
  {
   FileWrite(fh, CsvSafe(section) + CSV_SEP + CsvSafe(key) + CSV_SEP +
             CsvSafe(value) + CSV_SEP + CsvSafe(unit) + CSV_SEP + CsvSafe(note));
  }

//+------------------------------------------------------------------+
//| Write core symbol properties                                     |
//+------------------------------------------------------------------+
void CollectSymbolProperties(int fh, string symbol)
  {
   string sec    = "symbol_properties";
   int    digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double point  = SymbolInfoDouble(symbol, SYMBOL_POINT);
   double pip    = (digits == 3 || digits == 5) ? 10.0 : 1.0;

   WriteCsvRow(fh, sec, "symbol", symbol, NA_FIELD, "");
   WriteCsvRow(fh, sec, "digits", (string)digits, NA_FIELD, "");
   WriteCsvRow(fh, sec, "point", DoubleToString(point, 10), "price", "");
   WriteCsvRow(fh, sec, "pip_factor", DoubleToString(pip, 1), "points_per_pip",
               "10 for 5-digit and 3-digit; 1 otherwise");
   WriteCsvRow(fh, sec, "tick_size",
               DoubleToString(SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE), 10),
               "price", "");
   WriteCsvRow(fh, sec, "tick_value",
               DoubleToString(SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE), 6),
               "account_currency_per_lot", "");
   WriteCsvRow(fh, sec, "tick_value_profit",
               DoubleToString(SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE_PROFIT), 6),
               "account_currency_per_lot", "used for profitable side");
   WriteCsvRow(fh, sec, "tick_value_loss",
               DoubleToString(SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE_LOSS), 6),
               "account_currency_per_lot", "used for losing side");
   WriteCsvRow(fh, sec, "contract_size",
               DoubleToString(SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE), 2),
               "units", "");
   WriteCsvRow(fh, sec, "currency_base",
               SymbolInfoString(symbol, SYMBOL_CURRENCY_BASE), NA_FIELD, "");
   WriteCsvRow(fh, sec, "currency_profit",
               SymbolInfoString(symbol, SYMBOL_CURRENCY_PROFIT), NA_FIELD, "");
   WriteCsvRow(fh, sec, "currency_margin",
               SymbolInfoString(symbol, SYMBOL_CURRENCY_MARGIN), NA_FIELD, "");
  }

//+------------------------------------------------------------------+
//| Write the constraints that bound order placement and sizing      |
//| These bind triple-barrier stop distances and bet-size rounding.  |
//+------------------------------------------------------------------+
void CollectExecutionConstraints(int fh, string symbol)
  {
   string sec = "execution_constraints";

   WriteCsvRow(fh, sec, "stops_level",
               (string)SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL),
               "points",
               "minimum SL/TP distance from market; closer orders are rejected");
   WriteCsvRow(fh, sec, "freeze_level",
               (string)SymbolInfoInteger(symbol, SYMBOL_TRADE_FREEZE_LEVEL),
               "points",
               "orders inside this band cannot be modified or closed");
   WriteCsvRow(fh, sec, "volume_min",
               DoubleToString(SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN), 4),
               "lots", "");
   WriteCsvRow(fh, sec, "volume_max",
               DoubleToString(SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX), 4),
               "lots", "");
   WriteCsvRow(fh, sec, "volume_step",
               DoubleToString(SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP), 4),
               "lots", "bet sizes must round to a multiple of this");
   WriteCsvRow(fh, sec, "volume_limit",
               DoubleToString(SymbolInfoDouble(symbol, SYMBOL_VOLUME_LIMIT), 4),
               "lots", "0 means no aggregate limit on this symbol");
   WriteCsvRow(fh, sec, "filling_mode",
               (string)SymbolInfoInteger(symbol, SYMBOL_FILLING_MODE),
               "bitmask", "1=FOK 2=IOC; 0 means market execution only");
   WriteCsvRow(fh, sec, "trade_exemode",
               EnumToString((ENUM_SYMBOL_TRADE_EXECUTION)
                            SymbolInfoInteger(symbol, SYMBOL_TRADE_EXEMODE)),
               NA_FIELD, "");
   WriteCsvRow(fh, sec, "trade_mode",
               EnumToString((ENUM_SYMBOL_TRADE_MODE)
                            SymbolInfoInteger(symbol, SYMBOL_TRADE_MODE)),
               NA_FIELD, "");
   WriteCsvRow(fh, sec, "margin_initial",
               DoubleToString(SymbolInfoDouble(symbol, SYMBOL_MARGIN_INITIAL), 4),
               "account_currency_per_lot",
               "0 means margin is derived from contract size and leverage");
  }

//+------------------------------------------------------------------+
//| Write swap rate information                                      |
//+------------------------------------------------------------------+
void CollectSwapInfo(int fh, string symbol)
  {
   string sec       = "swap";
   int    swap_mode = (int)SymbolInfoInteger(symbol, SYMBOL_SWAP_MODE);
   string mode_str  = "unknown";

   switch(swap_mode)
     {
      case SYMBOL_SWAP_MODE_POINTS:
         mode_str = "points";
         break;
      case SYMBOL_SWAP_MODE_CURRENCY_SYMBOL:
         mode_str = "currency_symbol";
         break;
      case SYMBOL_SWAP_MODE_CURRENCY_MARGIN:
         mode_str = "currency_margin";
         break;
      case SYMBOL_SWAP_MODE_CURRENCY_DEPOSIT:
         mode_str = "currency_deposit";
         break;
      case SYMBOL_SWAP_MODE_INTEREST_CURRENT:
         mode_str = "interest_current";
         break;
      case SYMBOL_SWAP_MODE_INTEREST_OPEN:
         mode_str = "interest_open";
         break;
      case SYMBOL_SWAP_MODE_REOPEN_CURRENT:
         mode_str = "reopen_current";
         break;
      case SYMBOL_SWAP_MODE_REOPEN_BID:
         mode_str = "reopen_bid";
         break;
      default:
         mode_str = "disabled_or_unknown";
         break;
     }

   WriteCsvRow(fh, sec, "swap_long",
               DoubleToString(SymbolInfoDouble(symbol, SYMBOL_SWAP_LONG), 6),
               mode_str, "per night");
   WriteCsvRow(fh, sec, "swap_short",
               DoubleToString(SymbolInfoDouble(symbol, SYMBOL_SWAP_SHORT), 6),
               mode_str, "per night");
   WriteCsvRow(fh, sec, "swap_mode", mode_str, NA_FIELD,
               "see SYMBOL_SWAP_MODE enum");
   WriteCsvRow(fh, sec, "swap_3day",
               (string)SymbolInfoInteger(symbol, SYMBOL_SWAP_ROLLOVER3DAYS),
               "weekday", "0=Sun 6=Sat; triple swap charged on this weekday");
  }

//+------------------------------------------------------------------+
//| Write the commission diagnostic and its derivation procedure     |
//+------------------------------------------------------------------+
void CollectCommissionInfo(int fh)
  {
   string sec = "commission";
   WriteCsvRow(fh, sec, "commission_blocked_now",
               DoubleToString(AccountInfoDouble(ACCOUNT_COMMISSION_BLOCKED), 4),
               "account_currency",
               "ACCOUNT_COMMISSION_BLOCKED; near zero with no open position");
   WriteCsvRow(fh, sec, "derivation_note",
               "Open then close a reference trade of known volume; sum "
               "HISTORY_DEAL_COMMISSION over both deals for the round trip; "
               "divide by the reference lot volume for per-lot per-side",
               NA_FIELD, "");
  }

//+------------------------------------------------------------------+
//| Copy one day of tick data with retry                             |
//| CopyTicksRange returns -1 while the terminal is still fetching,  |
//| so a single failed call must not be read as an empty day.        |
//+------------------------------------------------------------------+
int CopyDayTicks(string symbol, datetime day_start, datetime day_end,
                 MqlTick &ticks[])
  {
   for(int attempt = 0; attempt <= InpMaxRetries; attempt++)
     {
      ResetLastError();
      int copied = CopyTicksRange(symbol, ticks, COPY_TICKS_INFO,
                                  (ulong)day_start * 1000,
                                  (ulong)day_end   * 1000);
      if(copied >= 0)
         return(copied);

      int err = GetLastError();
      if(err != ERR_HISTORY_TIMEOUT && err != ERR_HISTORY_LOAD_ERRORS)
        {
         PrintFormat("CopyTicksRange failed for %s at %s: err=%d",
                     symbol, TimeToString(day_start, TIME_DATE), err);
         return(-1);
        }
      Sleep(InpRetryMs);
     }

   PrintFormat("CopyTicksRange timed out for %s at %s after %d retries",
               symbol, TimeToString(day_start, TIME_DATE), InpMaxRetries);
   return(-1);
  }

//+------------------------------------------------------------------+
//| Walk the lookback window one day at a time and fill every        |
//| accumulator in a single pass over the ticks.                     |
//+------------------------------------------------------------------+
bool SampleTicks(string symbol, CSpreadStats &st)
  {
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   if(point <= 0.0)
      return(false);

   int exec_sec = PeriodSeconds(InpExecTF);
   if(exec_sec <= 0)
      exec_sec = 3600;

   long max_dwell_msc = (long)InpMaxDwellSec * 1000;
   if(max_dwell_msc <= 0)
      max_dwell_msc = 60000;

   datetime now      = TimeCurrent();
   datetime from_all = now - (datetime)InpDays * SEC_PER_DAY;

//--- State carried across day boundaries so that the execution-
//--- conditional sampler is not reset at midnight.
   long prev_msc     = 0;      // Timestamp of the previous accepted tick
   int  prev_sp      = -1;     // Spread in points of the previous accepted tick
   long next_bound   = 0;      // Next execution boundary in seconds, 0 = unset

   for(datetime day_start = from_all; day_start < now; day_start += SEC_PER_DAY)
     {
      datetime day_end = day_start + SEC_PER_DAY;
      if(day_end > now)
         day_end = now;

      st.days_requested++;

      MqlTick ticks[];
      int copied = CopyDayTicks(symbol, day_start, day_end, ticks);
      if(copied <= 0)
         continue;

      st.days_with_ticks++;

      for(int i = 0; i < copied; i++)
        {
         double bid = ticks[i].bid;
         double ask = ticks[i].ask;

         //--- Reject one-sided or crossed quotes rather than silently dropping them
         if(bid <= 0.0 || ask <= 0.0 || ask < bid)
           {
            st.n_invalid++;
            continue;
           }

         int sp = (int)MathRound((ask - bid) / point);
         if(sp < 0)
            sp = 0;
         if(sp > MAX_SPREAD_BIN)
           {
            sp = MAX_SPREAD_BIN;
            st.n_clamped++;
           }

         long tmsc = (long)ticks[i].time_msc;

         //--- Tick-weighted mass
         st.hist_tick[sp]++;
         st.n_ticks++;
         if(st.first_tick_msc == 0)
            st.first_tick_msc = tmsc;
         st.last_tick_msc = tmsc;

         //--- Hour-of-day tick-weighted mass, broker time
         MqlDateTime dt;
         TimeToStruct((datetime)(tmsc / 1000), dt);
         st.hour_cnt[dt.hour]++;
         st.hour_sum_pts[dt.hour] += (double)sp;

         //--- Time-weighted mass: the previous quote prevailed until now.
         //--- Capping prevents a single weekend gap from dominating.
         if(prev_msc > 0 && prev_sp >= 0)
           {
            long gap = tmsc - prev_msc;
            if(gap > 0)
              {
               long used = gap;
               if(used > max_dwell_msc)
                 {
                  st.capped_dwell_sec += (double)(gap - max_dwell_msc) / 1000.0;
                  used = max_dwell_msc;
                 }
               double w = (double)used / 1000.0;
               st.hist_time[prev_sp] += w;
               st.total_dwell_sec    += w;
              }
           }

         //--- Execution-conditional mass: the quote prevailing at each
         //--- boundary of the execution timeframe. A boundary reached
         //--- across a gap wider than the dwell cap is recorded as
         //--- missed rather than imputed from a stale quote.
         long tsec = tmsc / 1000;
         if(next_bound == 0)
            next_bound = ((tsec / exec_sec) + 1) * (long)exec_sec;

         while(tsec >= next_bound)
           {
            if(prev_sp >= 0 && prev_msc > 0 &&
               (next_bound * 1000 - prev_msc) <= max_dwell_msc)
              {
               st.hist_exec[prev_sp]++;
               st.n_exec_points++;
              }
            else
               st.n_exec_missed++;

            next_bound += (long)exec_sec;
           }

         prev_msc = tmsc;
         prev_sp  = sp;
        }

      if(InpAuditBarField)
         AuditBarField(symbol, day_start, day_end, ticks, copied, point, st);
     }

   return(st.n_ticks > 0);
  }

//+------------------------------------------------------------------+
//| Reconstruct each M1 bar from its own ticks and compare against   |
//| the broker-stored spread field. This measures the field's        |
//| semantics on this broker and build instead of assuming them.     |
//+------------------------------------------------------------------+
void AuditBarField(string symbol, datetime day_start, datetime day_end,
                   const MqlTick &ticks[], int n, double point,
                   CSpreadStats &st)
  {
   MqlRates rates[];
   int bars = CopyRates(symbol, PERIOD_M1, day_start, day_end, rates);
   if(bars <= 0)
      return;

   int ti = 0;                                   // Cursor into the tick array

   for(int b = 0; b < bars; b++)
     {
      long bar_start_msc = (long)rates[b].time * 1000;
      long bar_end_msc   = bar_start_msc + 60000;

      //--- Advance to the first tick inside this bar
      while(ti < n && (long)ticks[ti].time_msc < bar_start_msc)
         ti++;

      int    sp_min = -1, sp_max = -1, sp_open = -1, sp_close = -1;
      double sp_sum = 0.0;
      long   sp_cnt = 0;
      int    tj     = ti;

      while(tj < n && (long)ticks[tj].time_msc < bar_end_msc)
        {
         double bid = ticks[tj].bid;
         double ask = ticks[tj].ask;
         if(bid > 0.0 && ask > 0.0 && ask >= bid)
           {
            int sp = (int)MathRound((ask - bid) / point);
            if(sp < 0)
               sp = 0;
            if(sp_open < 0)
               sp_open = sp;
            sp_close = sp;
            if(sp_min < 0 || sp < sp_min)
               sp_min = sp;
            if(sp > sp_max)
               sp_max = sp;
            sp_sum += (double)sp;
            sp_cnt++;
           }
         tj++;
        }

      if(sp_cnt == 0)
         continue;

      int stored = (int)rates[b].spread;

      st.audit_bars++;
      if(stored == sp_min)
         st.audit_eq_min++;
      if(stored == sp_open)
         st.audit_eq_open++;
      if(stored == sp_close)
         st.audit_eq_close++;
      if(stored == sp_max)
         st.audit_eq_max++;

      st.audit_sum_stored   += (double)stored;
      st.audit_sum_tickmean += sp_sum / (double)sp_cnt;
      st.audit_sum_tickmax  += (double)sp_max;

      int sb = stored;
      if(sb < 0)
         sb = 0;
      if(sb > MAX_SPREAD_BIN)
         sb = MAX_SPREAD_BIN;
      st.hist_bar[sb]++;
     }
  }

//+------------------------------------------------------------------+
//| Nearest-rank percentile from an integer-weighted histogram       |
//+------------------------------------------------------------------+
long PercentileLong(const long &hist[], long n, double q)
  {
   if(n <= 0)
      return(-1);

   long rank = (long)MathCeil(q * (double)n);
   if(rank < 1)
      rank = 1;

   long cum  = 0;
   int  bins = ArraySize(hist);
   for(int k = 0; k < bins; k++)
     {
      cum += hist[k];
      if(cum >= rank)
         return((long)k);
     }
   return((long)(bins - 1));
  }

//+------------------------------------------------------------------+
//| Nearest-rank percentile from a real-weighted histogram           |
//+------------------------------------------------------------------+
long PercentileDouble(const double &hist[], double total, double q)
  {
   if(total <= 0.0)
      return(-1);

   double rank = q * total;
   double cum  = 0.0;
   int    bins = ArraySize(hist);
   for(int k = 0; k < bins; k++)
     {
      cum += hist[k];
      if(cum >= rank)
         return((long)k);
     }
   return((long)(bins - 1));
  }

//+------------------------------------------------------------------+
//| Write moments and percentiles of an integer-weighted histogram   |
//+------------------------------------------------------------------+
void WriteDistributionLong(int fh, string sec, const long &hist[],
                           long n, double pip_factor, string note)
  {
   if(n <= 0)
     {
      WriteCsvRow(fh, sec, "samples", "0", "count", "no data in window");
      return;
     }

   double sum = 0.0, sum_sq = 0.0;
   int    bins = ArraySize(hist);
   for(int k = 0; k < bins; k++)
     {
      double c = (double)hist[k];
      sum    += (double)k * c;
      sum_sq += (double)k * (double)k * c;
     }
   double mean = sum / (double)n;
   double var  = (sum_sq / (double)n) - (mean * mean);
   double sd   = MathSqrt(MathMax(var, 0.0));

   WriteCsvRow(fh, sec, "samples", (string)n, "count", note);
   WriteCsvRow(fh, sec, "mean_points", DoubleToString(mean, 4), "points", "");
   WriteCsvRow(fh, sec, "std_points",  DoubleToString(sd, 4),   "points", "");
   WriteCsvRow(fh, sec, "p25_points", (string)PercentileLong(hist, n, 0.25), "points", "");
   WriteCsvRow(fh, sec, "p50_points", (string)PercentileLong(hist, n, 0.50), "points", "");
   WriteCsvRow(fh, sec, "p75_points", (string)PercentileLong(hist, n, 0.75), "points", "");
   WriteCsvRow(fh, sec, "p90_points", (string)PercentileLong(hist, n, 0.90), "points", "");
   WriteCsvRow(fh, sec, "p95_points", (string)PercentileLong(hist, n, 0.95), "points", "");
   WriteCsvRow(fh, sec, "p99_points", (string)PercentileLong(hist, n, 0.99), "points", "");
   WriteCsvRow(fh, sec, "mean_pips", DoubleToString(mean / pip_factor, 4), "pips", "");
   WriteCsvRow(fh, sec, "p50_pips",
               DoubleToString((double)PercentileLong(hist, n, 0.50) / pip_factor, 4), "pips", "");
   WriteCsvRow(fh, sec, "p95_pips",
               DoubleToString((double)PercentileLong(hist, n, 0.95) / pip_factor, 4), "pips", "");
   WriteCsvRow(fh, sec, "p99_pips",
               DoubleToString((double)PercentileLong(hist, n, 0.99) / pip_factor, 4), "pips", "");
  }

//+------------------------------------------------------------------+
//| Write moments and percentiles of a real-weighted histogram       |
//+------------------------------------------------------------------+
void WriteDistributionDouble(int fh, string sec, const double &hist[],
                             double total, double pip_factor, string note)
  {
   if(total <= 0.0)
     {
      WriteCsvRow(fh, sec, "weight_seconds", "0", "seconds", "no data in window");
      return;
     }

   double sum = 0.0, sum_sq = 0.0;
   int    bins = ArraySize(hist);
   for(int k = 0; k < bins; k++)
     {
      double w = hist[k];
      sum    += (double)k * w;
      sum_sq += (double)k * (double)k * w;
     }
   double mean = sum / total;
   double var  = (sum_sq / total) - (mean * mean);
   double sd   = MathSqrt(MathMax(var, 0.0));

   WriteCsvRow(fh, sec, "weight_seconds", DoubleToString(total, 1), "seconds", note);
   WriteCsvRow(fh, sec, "mean_points", DoubleToString(mean, 4), "points", "");
   WriteCsvRow(fh, sec, "std_points",  DoubleToString(sd, 4),   "points", "");
   WriteCsvRow(fh, sec, "p25_points", (string)PercentileDouble(hist, total, 0.25), "points", "");
   WriteCsvRow(fh, sec, "p50_points", (string)PercentileDouble(hist, total, 0.50), "points", "");
   WriteCsvRow(fh, sec, "p75_points", (string)PercentileDouble(hist, total, 0.75), "points", "");
   WriteCsvRow(fh, sec, "p90_points", (string)PercentileDouble(hist, total, 0.90), "points", "");
   WriteCsvRow(fh, sec, "p95_points", (string)PercentileDouble(hist, total, 0.95), "points", "");
   WriteCsvRow(fh, sec, "p99_points", (string)PercentileDouble(hist, total, 0.99), "points", "");
   WriteCsvRow(fh, sec, "mean_pips", DoubleToString(mean / pip_factor, 4), "pips", "");
  }

//+------------------------------------------------------------------+
//| Write sampling diagnostics so that partial coverage is visible   |
//+------------------------------------------------------------------+
void WriteDiagnostics(int fh, const CSpreadStats &st)
  {
   string sec = "sampling_diagnostics";

   WriteCsvRow(fh, sec, "days_requested", (string)st.days_requested, "days", "");
   WriteCsvRow(fh, sec, "days_with_ticks", (string)st.days_with_ticks, "days",
               "compare against days_requested before trusting any statistic");
   WriteCsvRow(fh, sec, "exec_timeframe", EnumToString(InpExecTF), NA_FIELD, "");
   WriteCsvRow(fh, sec, "ticks_accepted", (string)st.n_ticks, "ticks", "");
   WriteCsvRow(fh, sec, "ticks_invalid", (string)st.n_invalid, "ticks",
               "one-sided or crossed quotes excluded from every statistic");
   WriteCsvRow(fh, sec, "ticks_clamped", (string)st.n_clamped, "ticks",
               "spread exceeded the histogram cap; upper percentiles are floors if nonzero");
   WriteCsvRow(fh, sec, "histogram_cap", (string)MAX_SPREAD_BIN, "points", "");
   WriteCsvRow(fh, sec, "exec_samples", (string)st.n_exec_points, "boundaries", "");
   WriteCsvRow(fh, sec, "exec_missed", (string)st.n_exec_missed, "boundaries",
               "boundaries with no quote within the dwell cap; market closed or feed gap");
   WriteCsvRow(fh, sec, "dwell_cap_seconds", (string)InpMaxDwellSec, "seconds", "");
   WriteCsvRow(fh, sec, "dwell_seconds_total",
               DoubleToString(st.total_dwell_sec, 1), "seconds", "");
   WriteCsvRow(fh, sec, "dwell_seconds_capped",
               DoubleToString(st.capped_dwell_sec, 1), "seconds",
               "mass removed by the dwell cap; mostly weekend and holiday gaps");

   if(st.first_tick_msc > 0)
     {
      WriteCsvRow(fh, sec, "first_tick_time",
                  TimeToString((datetime)(st.first_tick_msc / 1000),
                               TIME_DATE | TIME_MINUTES), "broker_time", "");
      WriteCsvRow(fh, sec, "last_tick_time",
                  TimeToString((datetime)(st.last_tick_msc / 1000),
                               TIME_DATE | TIME_MINUTES), "broker_time", "");
     }
  }

//+------------------------------------------------------------------+
//| Report what the broker-stored bar spread field actually contains |
//+------------------------------------------------------------------+
void WriteAudit(int fh, const CSpreadStats &st)
  {
   string sec = "bar_field_audit";
   double nb  = (double)st.audit_bars;

   WriteCsvRow(fh, sec, "m1_bars_audited", (string)st.audit_bars, "bars",
               "M1 bars with at least one valid tick in the window");
   WriteCsvRow(fh, sec, "pct_equal_tick_min",
               DoubleToString(100.0 * st.audit_eq_min / nb, 2), "percent",
               "share of bars where the stored field equals the tick minimum");
   WriteCsvRow(fh, sec, "pct_equal_tick_open",
               DoubleToString(100.0 * st.audit_eq_open / nb, 2), "percent", "");
   WriteCsvRow(fh, sec, "pct_equal_tick_close",
               DoubleToString(100.0 * st.audit_eq_close / nb, 2), "percent", "");
   WriteCsvRow(fh, sec, "pct_equal_tick_max",
               DoubleToString(100.0 * st.audit_eq_max / nb, 2), "percent", "");
   WriteCsvRow(fh, sec, "mean_stored_points",
               DoubleToString(st.audit_sum_stored / nb, 4), "points", "");
   WriteCsvRow(fh, sec, "mean_tickmean_points",
               DoubleToString(st.audit_sum_tickmean / nb, 4), "points", "");
   WriteCsvRow(fh, sec, "mean_tickmax_points",
               DoubleToString(st.audit_sum_tickmax / nb, 4), "points", "");

   double stored_mean = st.audit_sum_stored / nb;
   if(stored_mean > 0.0)
     {
      WriteCsvRow(fh, sec, "ratio_tickmean_over_stored",
                  DoubleToString((st.audit_sum_tickmean / nb) / stored_mean, 4),
                  "ratio",
                  "understatement factor of the stored field against the M1 tick mean");
      WriteCsvRow(fh, sec, "ratio_tickmax_over_stored",
                  DoubleToString((st.audit_sum_tickmax / nb) / stored_mean, 4),
                  "ratio", "same comparison against the M1 tick maximum");
     }

   WriteCsvRow(fh, sec, "interpretation",
               "A high pct_equal_tick_min confirms the field stores the "
               "bar minimum. The semantics are undocumented and have "
               "changed across terminal builds; re-run this audit rather "
               "than assuming a fixed relationship",
               NA_FIELD, "");
  }

//+------------------------------------------------------------------+
//| Write tick-weighted mean spread by hour of day in broker time    |
//+------------------------------------------------------------------+
void WriteSessionSpread(int fh, const CSpreadStats &st, double pip_factor)
  {
   string sec = "spread_by_hour";
   for(int h = 0; h < 24; h++)
     {
      if(st.hour_cnt[h] <= 0)
         continue;

      double mean_pts = st.hour_sum_pts[h] / (double)st.hour_cnt[h];
      WriteCsvRow(fh, sec, StringFormat("hour_%02d", h),
                  DoubleToString(mean_pts / pip_factor, 4), "pips",
                  "broker_time; tick-weighted; n=" + (string)st.hour_cnt[h]);
     }
  }
//+------------------------------------------------------------------+
