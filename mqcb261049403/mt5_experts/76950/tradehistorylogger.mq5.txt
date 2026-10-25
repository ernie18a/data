#property copyright "TradeHistoryLogger"
#property version   "1.00"
#property description "Logs every closed position to CSV with the market context at BOTH"
#property description "entry and exit: RSI, Stochastic, EMA distance, Bollinger %B, ATR"
#property description "and ADX on M1 and M15, so you can infer from data the rules of an"
#property description "EA that does not state them."
#property description ""
#property description "Read-only: it never opens, closes or modifies a position."
#property description ""
#property description "NOTE: m1bar_spread_pts is the M1 bar summary, not the quote at"
#property description "execution. It understates the spread - do not use it as a cost."
#property strict

input string InpSymbol           = "";                          // Symbol to track. Empty = the chart's own symbol
input string InpCsvFileName      = "trade_history.csv";  // Output file, written to this terminal's MQL5\Files
input int    InpCheckIntervalSec = 60;                          // How often the history is scanned, in seconds
input long   InpMagicFilter      = 0;                           // If non-zero, log ONLY this magic number
input string InpExcludeMagics   = "";                          // Magic numbers to skip, comma separated (empty = all)
input int    InpBackfillHours    = 0;                           // Backfill hours, NEW file only (0 = start from now)

// The LIVE symbol. An empty InpSymbol means "this chart's symbol", and that is the
// default on purpose: hard-coding "XAUUSD" stopped working the first time the broker
// changed, because there gold is called XAUUSD.s. The logger kept running, reported no
// error, and silently logged nothing at all - it was filtering deals by a symbol that does
// not exist on that account. A filter that finds nothing looks exactly like a quiet market.
string g_symbol = "";

// Dedup is by POSITION_ID SET MEMBERSHIP, not by a "last processed" time or id watermark. Both of
// those were tried and both had the same class of bug: any ordering assumption (id order, or close
// time strictly increasing) breaks when the observed EA holds a losing hedge leg open long after newer
// legs already closed, or when multiple legs close within the same one-second timestamp resolution
// (both observed in practice - a -$10.54 loss and two same-second closes were silently dropped before
// this was caught). A plain "have I already logged this exact position_id" set has no such assumption.
long g_loggedPositionIds[];

// Magic numbers of the user's own EAs that also trade XAUUSD on this account (from their source
// projects under Documents\EA Grid*) - history from these leaks into an unfiltered XAUUSD scan even
// after they've stopped being actively traded. the observed EA itself is closed-source so its magic(s)
// aren't known in advance; excluding these known ones is more robust than guessing the observed EA.
// EXCLUSION, not inclusion. If you are studying an EA whose magic numbers you do not
// know, listing the magics of YOUR OWN advisors and logging everything else is more robust
// than trying to guess the other one's: an EA can use more than one magic number, and
// chasing them directly means you find out you missed one only after the analysis.
// Add a magic here the day you attach a new advisor: if you forget, its trades land in the
// file as if they belonged to the EA you are studying.
long g_excluded[];   // filled in OnInit from InpExcludeMagics

//--- Indicator instrumentation -------------------------------------------------------------------
// Two timeframes are sampled: M1 (the vendor advertises this as an "M1 scalping strategy") and M15
// (the chart the observed EA is actually attached to). Which one the internal logic really keys off is
// exactly the open question, so both are recorded and the data decides.
#define TF_COUNT 2
ENUM_TIMEFRAMES g_tfs[TF_COUNT]     = {PERIOD_M1, PERIOD_M15};
string          g_tfNames[TF_COUNT] = {"m1", "m15"};

int h_rsi[TF_COUNT], h_stoch[TF_COUNT], h_ema20[TF_COUNT], h_ema50[TF_COUNT];
int h_bands[TF_COUNT], h_atr[TF_COUNT], h_adx[TF_COUNT];

// One sample of "what the market looked like" at a given instant on a given timeframe.
struct MarketSnapshot
{
   bool   valid;
   double rsi;        // RSI(14)
   double stoch;      // Stochastic(5,3,3) main line
   double ema20Dist;  // (close - EMA20) in points: sign tells which side of the mean price sat on
   double ema50Dist;  // (close - EMA50) in points
   double bbPctB;     // Bollinger(20,2) %B: 0 = at lower band, 1 = at upper band, outside = breakout
   double atr;        // ATR(14) in points: the volatility regime at that moment
   double adx;        // ADX(14): trend strength, to separate trending from ranging conditions
};

//+------------------------------------------------------------------+
int OnInit()
{

   // The exclusion list comes from the inputs, not from the source: everyone has their own
   // advisors. Empty means "log everything", which is what a new user expects to happen.
   {
      string pezzi[];
      int n = StringSplit(InpExcludeMagics, ',', pezzi);
      for(int i = 0; i < n; i++)
      {
         string v = pezzi[i];
         StringTrimLeft(v);
         StringTrimRight(v);
         if(v == "")
            continue;
         int k = ArraySize(g_excluded);
         ArrayResize(g_excluded, k + 1);
         g_excluded[k] = StringToInteger(v);
      }
      if(ArraySize(g_excluded) > 0)
         Print("TradeHistoryLogger: skipping ", ArraySize(g_excluded), " magic number(s).");
   }
   g_symbol = (InpSymbol == "" ? _Symbol : InpSymbol);
   Print("Logger: simbolo seguito = ", g_symbol,
         (InpSymbol == "" ? " (dal grafico)" : " (da InpSymbol)"));

   if(!CreateIndicatorHandles())
      Print("WARNING: some indicator handles failed to initialise - enrichment columns may be blank. err=", GetLastError());

   if(!FileIsExist(InpCsvFileName))
   {
      if(InpBackfillHours > 0)
      {
         // Deliberate backfill: re-log everything already closed within the requested window. Used to
         // (re)capture recent history with the enrichment columns after a schema change.
         Print("Logger: first run with InpBackfillHours=", InpBackfillHours, " - will backfill that window.");
      }
      else
      {
         // Normal fresh start: mark everything already closed as "seen" without writing rows, so the
         // account's pre-existing history (possibly months of unrelated trades) isn't dumped in.
         int skipped = SeedAlreadyClosedAsBaseline();
         Print("Logger: first run, baselined ", skipped, " already-closed position(s) - history before now will NOT be backfilled.");
      }

      // FILE_TXT, not FILE_CSV: rows are pre-joined comma strings, and FILE_CSV mode wraps any string
      // containing the delimiter in quotes - which corrupts the first column ("81234 instead of 81234)
      // and silently breaks dedup on the next read. Plain text mode writes exactly what we build.
      int h = FileOpen(InpCsvFileName, FILE_WRITE|FILE_TXT|FILE_ANSI);
      if(h == INVALID_HANDLE)
      {
         Print("ERROR: cannot create ", InpCsvFileName, ", err=", GetLastError());
         return INIT_FAILED;
      }
      WriteCsvHeader(h);
      FileClose(h);
      Print("Logger: created new CSV ", InpCsvFileName);
   }
   else
   {
      int loaded = LoadLoggedPositionIdsFromCsv();
      Print("Logger: resuming, ", loaded, " previously logged position(s) loaded from CSV.");
   }

   EventSetTimer(InpCheckIntervalSec);
   ScanAndLogClosedPositions(); // catch up immediately on attach, don't wait for first timer tick
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   ReleaseIndicatorHandles();
}

//+------------------------------------------------------------------+
void OnTick() {}

//+------------------------------------------------------------------+
void OnTimer()
{
   ScanAndLogClosedPositions();
}

//+------------------------------------------------------------------+
//| Indicator handle lifecycle                                        |
//+------------------------------------------------------------------+
bool CreateIndicatorHandles()
{
   bool ok = true;
   for(int t = 0; t < TF_COUNT; t++)
   {
      h_rsi[t]   = iRSI(g_symbol, g_tfs[t], 14, PRICE_CLOSE);
      h_stoch[t] = iStochastic(g_symbol, g_tfs[t], 5, 3, 3, MODE_SMA, STO_LOWHIGH);
      h_ema20[t] = iMA(g_symbol, g_tfs[t], 20, 0, MODE_EMA, PRICE_CLOSE);
      h_ema50[t] = iMA(g_symbol, g_tfs[t], 50, 0, MODE_EMA, PRICE_CLOSE);
      h_bands[t] = iBands(g_symbol, g_tfs[t], 20, 0, 2.0, PRICE_CLOSE);
      h_atr[t]   = iATR(g_symbol, g_tfs[t], 14);
      h_adx[t]   = iADX(g_symbol, g_tfs[t], 14);

      if(h_rsi[t] == INVALID_HANDLE || h_stoch[t] == INVALID_HANDLE || h_ema20[t] == INVALID_HANDLE ||
         h_ema50[t] == INVALID_HANDLE || h_bands[t] == INVALID_HANDLE || h_atr[t] == INVALID_HANDLE ||
         h_adx[t] == INVALID_HANDLE)
         ok = false;
   }
   return ok;
}

void ReleaseIndicatorHandles()
{
   for(int t = 0; t < TF_COUNT; t++)
   {
      IndicatorRelease(h_rsi[t]);
      IndicatorRelease(h_stoch[t]);
      IndicatorRelease(h_ema20[t]);
      IndicatorRelease(h_ema50[t]);
      IndicatorRelease(h_bands[t]);
      IndicatorRelease(h_atr[t]);
      IndicatorRelease(h_adx[t]);
   }
}

//+------------------------------------------------------------------+
//| Retroactive market-context sampling                               |
//+------------------------------------------------------------------+
// Reads one indicator buffer value at the bar containing `shift`. Returns false if unavailable
// (e.g. the bar is older than the locally cached history), so the caller can emit a blank cell
// rather than a misleading zero.
bool BufferValueAt(int handle, int bufferIndex, int shift, double &out)
{
   if(handle == INVALID_HANDLE || shift < 0)
      return false;
   double buf[];
   if(CopyBuffer(handle, bufferIndex, shift, 1, buf) < 1)
      return false;
   out = buf[0];
   return true;
}

// Samples every tracked indicator on timeframe `tfIdx` at the bar containing `when`.
// All values come from the bar the trade actually happened on - not "now" - so this works
// retroactively on trades that closed hours or days ago.
bool GetSnapshot(int tfIdx, datetime when, MarketSnapshot &s)
{
   s.valid = false;

   int shift = iBarShift(g_symbol, g_tfs[tfIdx], when, false);
   if(shift < 0)
      return false;

   double closeArr[];
   if(CopyClose(g_symbol, g_tfs[tfIdx], shift, 1, closeArr) < 1)
      return false;
   double closePrice = closeArr[0];

   double point = SymbolInfoDouble(g_symbol, SYMBOL_POINT);
   if(point <= 0)
      point = 0.01; // XAUUSD fallback; only affects the scale of the *_dist columns

   double ema20 = 0, ema50 = 0, upper = 0, lower = 0;
   bool okAll = true;

   okAll = BufferValueAt(h_rsi[tfIdx],   0, shift, s.rsi)   && okAll;
   okAll = BufferValueAt(h_stoch[tfIdx], 0, shift, s.stoch) && okAll;
   okAll = BufferValueAt(h_atr[tfIdx],   0, shift, s.atr)   && okAll;
   okAll = BufferValueAt(h_adx[tfIdx],   0, shift, s.adx)   && okAll;

   if(BufferValueAt(h_ema20[tfIdx], 0, shift, ema20))
      s.ema20Dist = (closePrice - ema20) / point;
   else
      okAll = false;

   if(BufferValueAt(h_ema50[tfIdx], 0, shift, ema50))
      s.ema50Dist = (closePrice - ema50) / point;
   else
      okAll = false;

   // iBands buffers: 0 = base line, 1 = upper, 2 = lower
   if(BufferValueAt(h_bands[tfIdx], 1, shift, upper) && BufferValueAt(h_bands[tfIdx], 2, shift, lower))
   {
      double width = upper - lower;
      s.bbPctB = (width > 0) ? (closePrice - lower) / width : 0.5;
   }
   else
      okAll = false;

   // ATR is reported in points too, so volatility is comparable across the *_dist columns.
   if(okAll)
      s.atr = s.atr / point;

   s.valid = okAll;
   return okAll;
}

// Spread (in points) on the bar a trade opened on - a cheap proxy for execution conditions, and the
// most likely reason the Asian session would behave differently from London/NY.
// WARNING - this matters more to whoever reads the CSV than to whoever reads the code.
//
// This value comes from the M1 bar's spread field, which is a PER-BAR SUMMARY and NOT the
// quote at the instant the order was executed. Measured on XAUUSD on 2026.09.04: the live
// spread was 20 points across 60 consecutive readings, while the M1 bar field had a median
// of 6. A factor of 3.3.
//
// For a position that is already closed, the instantaneous spread of that moment is not
// recoverable from any source, so the column stays - but it is called m1bar_spread_pts and
// not spread_open_pts, because as an estimate of execution cost it is wrong by three times.
// The real cost is already inside the profit, swap and commission columns: those are what
// the broker actually applied.
bool GetSpreadAt(datetime when, int &spreadPoints)
{
   int shift = iBarShift(g_symbol, PERIOD_M1, when, false);
   if(shift < 0)
      return false;
   MqlRates rates[];
   if(CopyRates(g_symbol, PERIOD_M1, shift, 1, rates) < 1)
      return false;
   spreadPoints = (int)rates[0].spread;
   return true;
}

//+------------------------------------------------------------------+
//| CSV schema                                                        |
//+------------------------------------------------------------------+
void WriteCsvHeader(int h)
{
   string cols = "position_id,magic,direction,volume,open_time,open_price,close_time,close_price,"
                 "profit,swap,commission,duration_min,open_hour_server,open_dow,m1bar_spread_pts";

   // Entry context first, then exit context, each timeframe grouped together.
   for(int phase = 0; phase < 2; phase++)
   {
      string p = (phase == 0) ? "e" : "x"; // e = entry, x = exit
      for(int t = 0; t < TF_COUNT; t++)
      {
         string pre = p + "_" + g_tfNames[t] + "_";
         cols += "," + pre + "rsi";
         cols += "," + pre + "stoch";
         cols += "," + pre + "ema20d";
         cols += "," + pre + "ema50d";
         cols += "," + pre + "bbpctb";
         cols += "," + pre + "atr";
         cols += "," + pre + "adx";
      }
   }
   FileWriteString(h, cols + "\r\n");
}

// Formats a snapshot field, emitting an empty cell (not 0) when the value couldn't be computed,
// so analysis can tell "no data" apart from a genuine zero reading.
string Fmt(bool valid, double value, int digits)
{
   return valid ? DoubleToString(value, digits) : "";
}

string SnapshotToCsv(const MarketSnapshot &s)
{
   return "," + Fmt(s.valid, s.rsi,       2)
        + "," + Fmt(s.valid, s.stoch,     2)
        + "," + Fmt(s.valid, s.ema20Dist, 1)
        + "," + Fmt(s.valid, s.ema50Dist, 1)
        + "," + Fmt(s.valid, s.bbPctB,    4)
        + "," + Fmt(s.valid, s.atr,       1)
        + "," + Fmt(s.valid, s.adx,       2);
}

//+------------------------------------------------------------------+
//| Filtering                                                         |
//+------------------------------------------------------------------+
bool IsExcludedMagic(long magic)
{
   if(InpMagicFilter != 0)
      return magic != InpMagicFilter;
   if(ArraySize(g_excluded) == 0)
      return false;
   for(int i = 0; i < ArraySize(g_excluded); i++)
      if(g_excluded[i] == magic)
         return true;
   return false;
}

bool AlreadyLogged(long positionId)
{
   for(int i = 0; i < ArraySize(g_loggedPositionIds); i++)
      if(g_loggedPositionIds[i] == positionId)
         return true;
   return false;
}

void MarkLogged(long positionId)
{
   int n = ArraySize(g_loggedPositionIds);
   ArrayResize(g_loggedPositionIds, n + 1);
   g_loggedPositionIds[n] = positionId;
}

//+------------------------------------------------------------------+
// Used only on a fresh CSV with no backfill requested: marks whatever is already closed as
// already-logged without writing rows for it, so the new log starts clean.
int SeedAlreadyClosedAsBaseline()
{
   if(!HistorySelect(TimeCurrent() - 2*24*3600, TimeCurrent()))
      return 0;

   int count = 0;
   int total = HistoryDealsTotal();
   for(int i = 0; i < total; i++)
   {
      ulong dealTicket = HistoryDealGetTicket(i);
      if(dealTicket == 0)
         continue;
      if(HistoryDealGetString(dealTicket, DEAL_SYMBOL) != g_symbol)
         continue;
      if((ENUM_DEAL_ENTRY)HistoryDealGetInteger(dealTicket, DEAL_ENTRY) != DEAL_ENTRY_OUT)
         continue;
      if(IsExcludedMagic(HistoryDealGetInteger(dealTicket, DEAL_MAGIC)))
         continue;

      long positionId = (long)HistoryDealGetInteger(dealTicket, DEAL_POSITION_ID);
      if(AlreadyLogged(positionId))
         continue;
      MarkLogged(positionId);
      count++;
   }
   return count;
}

//+------------------------------------------------------------------+
// Reads every position_id already present in the CSV (skipping the header and any bookkeeping rows
// with position_id <= 0) into g_loggedPositionIds, so dedup survives restarts.
// Reads whole lines in plain TXT mode and splits manually - column-counting in FILE_CSV mode proved
// unreliable in practice (it silently returned 0 instead of the true value).
int LoadLoggedPositionIdsFromCsv()
{
   int h = FileOpen(InpCsvFileName, FILE_READ|FILE_TXT|FILE_ANSI);
   if(h == INVALID_HANDLE)
      return 0;

   bool skippedHeader = false;
   int count = 0;
   while(!FileIsEnding(h))
   {
      string line = FileReadString(h);
      if(StringLen(line) == 0)
         continue;
      if(!skippedHeader)
      {
         skippedHeader = true;
         continue;
      }

      string parts[];
      if(StringSplit(line, ',', parts) < 1)
         continue;
      long positionId = (long)StringToInteger(parts[0]);
      if(positionId <= 0) // bookkeeping/marker row, not a real position
         continue;
      if(!AlreadyLogged(positionId))
      {
         MarkLogged(positionId);
         count++;
      }
   }
   FileClose(h);
   return count;
}

//+------------------------------------------------------------------+
// Scans closed-history deals for g_symbol and appends any position not already logged.
//
// TWO PHASES ON PURPOSE. LogClosedPosition() calls HistorySelectByPosition(), which REPLACES the
// global history selection this function is iterating over - so calling it inside the scan loop
// silently destroys the iteration: from the second match onward, HistoryDealGetTicket(i) indexes
// into that one position's tiny deal set instead of the 48h window, and everything after the first
// new position is missed. The visible symptom was exactly one position getting logged per OnTimer
// tick (originally, and wrongly, blamed on MT5's async history sync). Collect every candidate id
// first, then do the per-position lookups once the scan is complete.
void ScanAndLogClosedPositions()
{
   // Bounded to a rolling 48h window (or InpBackfillHours if larger) rather than "from account
   // inception": this account has months of history, and requesting further back triggers an async
   // server fetch that is slow to complete for a large account. the observed EA positions can stay
   // open for many hours (a losing hedge leg held open waiting to turn profitable), so 48h is a
   // comfortable margin.
   int windowHours = (InpBackfillHours > 48) ? InpBackfillHours : 48;
   if(!HistorySelect(TimeCurrent() - windowHours*3600, TimeCurrent()))
   {
      Print("WARNING: HistorySelect failed, err=", GetLastError());
      return;
   }

   // --- Phase 1: collect candidate position ids (no HistorySelectByPosition calls in here) ---
   long candidates[];
   int total = HistoryDealsTotal();
   for(int i = 0; i < total; i++)
   {
      ulong dealTicket = HistoryDealGetTicket(i);
      if(dealTicket == 0)
         continue;
      if(HistoryDealGetString(dealTicket, DEAL_SYMBOL) != g_symbol)
         continue;
      if((ENUM_DEAL_ENTRY)HistoryDealGetInteger(dealTicket, DEAL_ENTRY) != DEAL_ENTRY_OUT)
         continue;
      if(IsExcludedMagic(HistoryDealGetInteger(dealTicket, DEAL_MAGIC)))
         continue;

      long positionId = (long)HistoryDealGetInteger(dealTicket, DEAL_POSITION_ID);
      if(AlreadyLogged(positionId))
         continue;
      if(IsInArray(candidates, positionId)) // partial closes produce several OUT deals per position
         continue;

      int n = ArraySize(candidates);
      ArrayResize(candidates, n + 1);
      candidates[n] = positionId;
   }

   // --- Phase 2: now it's safe to re-select history per position ---
   for(int c = 0; c < ArraySize(candidates); c++)
   {
      LogClosedPosition(candidates[c]);
      MarkLogged(candidates[c]);
   }
}

bool IsInArray(const long &arr[], long value)
{
   for(int i = 0; i < ArraySize(arr); i++)
      if(arr[i] == value)
         return true;
   return false;
}

//+------------------------------------------------------------------+
// Reconstructs one closed position from all its deals (opening + closing, possibly partial fills),
// samples the market context at entry and exit, and appends a single summary row to the CSV.
void LogClosedPosition(long positionId)
{
   if(!HistorySelectByPosition(positionId))
      return;

   int total = HistoryDealsTotal();
   if(total == 0)
      return;

   datetime openTime = 0, closeTime = 0;
   double openPrice = 0, closePrice = 0;
   double profit = 0, swap = 0, commission = 0, volume = 0;
   string direction = "";
   long magic = 0;
   bool haveOpen = false;

   for(int i = 0; i < total; i++)
   {
      ulong dealTicket = HistoryDealGetTicket(i);
      if(dealTicket == 0)
         continue;

      ENUM_DEAL_ENTRY entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(dealTicket, DEAL_ENTRY);
      profit     += HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
      swap       += HistoryDealGetDouble(dealTicket, DEAL_SWAP);
      commission += HistoryDealGetDouble(dealTicket, DEAL_COMMISSION);

      if(entry == DEAL_ENTRY_IN && !haveOpen)
      {
         openTime  = (datetime)HistoryDealGetInteger(dealTicket, DEAL_TIME);
         openPrice = HistoryDealGetDouble(dealTicket, DEAL_PRICE);
         volume    = HistoryDealGetDouble(dealTicket, DEAL_VOLUME);
         direction = (HistoryDealGetInteger(dealTicket, DEAL_TYPE) == DEAL_TYPE_BUY) ? "buy" : "sell";
         magic     = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
         haveOpen  = true;
      }
      if(entry == DEAL_ENTRY_OUT)
      {
         closeTime  = (datetime)HistoryDealGetInteger(dealTicket, DEAL_TIME);
         closePrice = HistoryDealGetDouble(dealTicket, DEAL_PRICE);
      }
   }

   if(!haveOpen || closeTime == 0)
   {
      Print("WARNING: could not fully reconstruct position_id=", positionId, " (skipped, will retry next scan).");
      return;
   }

   // Safety-net re-check: the scan loop's exclusion check looks at the CLOSING deal's magic, but the
   // magic actually recorded here comes from the OPENING deal - the two can differ (e.g. a position
   // closed manually gets magic=0 on the OUT deal even though the EA that opened it had its own magic
   // on the IN deal), which let a Nova position slip through the scan-loop filter before this was added.
   // Excluding here, using the same magic that would be written, is what actually decides correctly.
   if(IsExcludedMagic(magic))
   {
      Print("Logger: position_id=", positionId, " magic=", magic, " excluded (matches an own-EA magic) - not logged.");
      return;
   }

   int durationMin = (int)((closeTime - openTime) / 60);

   MqlDateTime dt;
   TimeToStruct(openTime, dt);

   int spreadPts = -1;
   bool haveSpread = GetSpreadAt(openTime, spreadPts);

   string row = IntegerToString(positionId)
              + "," + IntegerToString(magic)
              + "," + direction
              + "," + DoubleToString(volume, 2)
              + "," + TimeToString(openTime, TIME_DATE|TIME_SECONDS)
              + "," + DoubleToString(openPrice, 2)
              + "," + TimeToString(closeTime, TIME_DATE|TIME_SECONDS)
              + "," + DoubleToString(closePrice, 2)
              + "," + DoubleToString(profit, 2)
              + "," + DoubleToString(swap, 2)
              + "," + DoubleToString(commission, 2)
              + "," + IntegerToString(durationMin)
              + "," + IntegerToString(dt.hour)
              + "," + IntegerToString(dt.day_of_week)
              + "," + (haveSpread ? IntegerToString(spreadPts) : "");

   MarketSnapshot snap;
   for(int phase = 0; phase < 2; phase++)         // 0 = entry, 1 = exit
   {
      datetime when = (phase == 0) ? openTime : closeTime;
      for(int t = 0; t < TF_COUNT; t++)
      {
         GetSnapshot(t, when, snap);              // leaves snap.valid=false on failure -> blank cells
         row += SnapshotToCsv(snap);
      }
   }

   // FILE_TXT for the same reason as the header: FILE_CSV would quote the whole comma-containing row.
   int h = FileOpen(InpCsvFileName, FILE_READ|FILE_WRITE|FILE_TXT|FILE_ANSI);
   if(h == INVALID_HANDLE)
   {
      Print("ERROR: cannot open ", InpCsvFileName, " for append, err=", GetLastError());
      return;
   }
   FileSeek(h, 0, SEEK_END);
   FileWriteString(h, row + "\r\n");
   FileClose(h);

   Print("Logger: position_id=", positionId, " magic=", magic, " ", direction, " ", DoubleToString(volume,2),
         " profit=", DoubleToString(profit,2), " duration=", durationMin, "min",
         " hour=", dt.hour, " enriched=", (snap.valid ? "yes" : "partial"));
}
