//+------------------------------------------------------------------+
//| DataGrabber_Lite_v102.mq5                                        |
//|                                              kouaAlgo Bot Factory |
//|           Multi-TF Data Grabber — Lite v1.05 (export Script)       |
//+------------------------------------------------------------------+
//| What it does:                                                    |
//|   Free CodeBase funnel: exports OHLC + tick volume + 4 core       |
//|   indicators (MA, RSI, MACD, ATR) for the chart symbol into three |
//|   separate CSV files (M1, M15, H1). Closed bars only.            |
//| What it never does:                                              |
//|   No trading calls, no signals, no DLL.                          |
//|   Progress dashboard = temporary chart objects, auto-removed.    |
//|   No labels, no features, no news, no spread, no split,          |
//|   no append mode, no multi-symbol (PRO only).                    |
//+------------------------------------------------------------------+
#property copyright "kouaAlgo"
#property link      "https://www.mql5.com"
#property version   "1.05"
#property description "Multi-TF Data Grabber Lite v1.05 — free CSV export (M1/M15/H1, 4 indicators) with dashboard progress UI. Auto-retries if a bar rolls mid-export."
#property description "Closed bars only. Never trades, no signals."
#property strict
#property script_show_inputs

//+------------------------------------------------------------------+
//| Named constants — no magic numbers                               |
//+------------------------------------------------------------------+
const string GRABBER_VERSION    = "1.05";
const string PRODUCT_TAG        = "DataGrabber Lite";

const int    CHUNK_MIN          = 500;            // SPEC §15 / §16.2
const int    CHUNK_MAX          = 10000;
const datetime MIN_HISTORY_DATE = D'2000.01.01';  // SPEC §16.1

//--- v1.05: automatic retry. The core aborts LOUD when a base bar rolls
//--- mid-export (§3.3, protects determinism); the adapter simply restarts
//--- the export with a fresh freeze — the user never sees the failure.
const int    EXPORT_MAX_ATTEMPTS = 5;
const int    RETRY_MIN_REMAIN_SEC = 50;   // v1.05: retry immediately when this
// many seconds remain in the M1 bar

//+------------------------------------------------------------------+
//| Inputs — SPEC §16.2 (exact names / types / defaults)            |
//+------------------------------------------------------------------+
input group "Date Range"
input datetime InpDateFrom = D'2022.01.01';  // From (broker server time)
input datetime InpDateTo   = 0;              // To (0 = last closed bar)

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input group "Indicators (core four, fixed parameters per SPEC §5)"
input bool   InpUseMA   = true;              // MA(20)
input bool   InpUseRSI  = true;              // RSI(14)
input bool   InpUseMACD = true;              // MACD(12,26,9)
input bool   InpUseATR  = true;              // ATR(14)

input group "Output"
input int    InpChunkBars = 2000;            // Bars per chunk, 500..10000


// GRABBER_LITE must be defined BEFORE the inlined core section below: it is the
// compile-time gate that drops all PRO code (single core, no maintenance fork — SPEC §1).
#define GRABBER_LITE

//+------------------------------------------------------------------+
//| CORE — inlined below (MTFDataCore v1.05). Single-file build:     |
//| no #include, one-click install. The core reads the Inp* inputs   |
//| declared above directly and provides exactly the eight Grabber   |
//| functions below. Full contract: Docs/PHASE2-NOTES.md §3.         |
//|                                                                  |
//|   bool   Grabber_Begin(const string symbol, string &err)         |
//|   long   Grabber_TotalBars(const string symbol)                  |
//|   bool   Grabber_ExportChunk(const string symbol,                |
//|                              const int chunk_index,              |
//|                              const int chunk_bars,               |
//|                              int &rows_out, int &skipped_out,    |
//|                              string &err)                        |
//|   bool   Grabber_Finish(const string symbol, int &rows_total,    |
//|                          int &skipped_total, string &err)        |
//|   void   Grabber_Abort()                                         |
//|   int    Grabber_FileCount()                                     |
//|   string Grabber_FilePath(const int index)                       |
//|   int    Grabber_ColumnCount()                                   |
//+------------------------------------------------------------------+
//--- CORE SECTION: MTFDataCore v1.05 inlined below (was: #include <MTFDataCore.mqh>)
//+------------------------------------------------------------------+
//| MTFDataCore.mqh                                                  |
//| Multi-TF Data Grabber — shared core library v1.05                |
//|                                                                  |
//| Batch data-export engine: aligned multi-timeframe OHLCV,          |
//| indicators, engineered features and post-hoc labels → CSV.       |
//| Script-driven (OnStart). No trading, no per-tick work, no UI.    |
//|                                                                  |
//| Compile-time gates (define BEFORE the core section):             |
//|   GRABBER_LITE        → Lite build: fixed 11-column single-TF     |
//|                        schema; PRO-only code compiled out.        |
//|   GRABBER_NO_CALENDAR → for MetaEditor < build 1930 where        |
//|                        CalendarValueHistory does not exist;       |
//|                        news flag degrades to 0 + warning.         |
//|                                                                  |
//| Guarantees (SPEC v1.00):                                         |
//| - Every market read references CLOSED bars only (no lookahead).  |
//| - HTF alignment = last COMPLETED HTF bar at-or-before the base  |
//|   bar time (SPEC §3.2).                                          |
//| - Labels are computed post-hoc; rows near the right edge carry   |
//|   empty labels with labels_ok=0 (SPEC §7).                       |
//| - Calendar event times compare directly against bar times: per   |
//|   MQL5 docs all calendar times are trade-server time.            |
//+------------------------------------------------------------------+

//--- version marker for QA gate
#define MTF_CORE_VERSION "1.05"

//--- CSV format (§2)
#define MTF_COL_SEP         ";"
#define MTF_CRLF            "\r\n"
#define MTF_PRICE_DIGITS    6

//--- structural limits
#define MTF_MAX_SYMBOLS     10
#define MTF_MAX_HTF         3
#define MTF_MAX_TF          4          // base + up to 3 HTF
#define MTF_IND_COUNT       7          // MA, RSI, MACD, ATR, BB, Stoch, ADX
#define MTF_IND_COLS        13         // indicator columns per TF block
#define MTF_CUSTOM_SLOTS    2

//--- fixed indicator parameters (§5 — frozen by spec, not inputs)
#define MTF_P_MA            20
#define MTF_P_RSI           14
#define MTF_P_MACD_FAST     12
#define MTF_P_MACD_SLOW     26
#define MTF_P_MACD_SIGNAL   9
#define MTF_P_ATR           14
#define MTF_P_BB            20
#define MTF_P_BB_DEV        2.0
#define MTF_P_STOCH_K       14
#define MTF_P_STOCH_D       3
#define MTF_P_STOCH_SLOW    3
#define MTF_P_ADX           14

//--- warmup: closed bars required before the first exported row (§5)
#define MTF_BASE_WARMUP_FEAT 114       // max(6, 114) for logret_5 + atr_pct_100
#define MTF_ATR_PCT_WINDOW   100

//--- news / spread / labels
#define MTF_NEWS_WINDOW_SEC  1800      // ±30 minutes
#define MTF_SPREAD_HIST      100       // fallback median window (bars)

//--- time constants (named: no magic numbers)
#define MTF_SEC_PER_DAY      86400
#define MTF_D1_WEEKEND_GAP   129600    // 36h: D1 weekend-gap detector for exact bar-close math
#define MTF_CAL_FALLBACK_SEC 31536000  // 365 days: calendar lookback when date_from == 0

//--- history-sync wait (M1 fix: SERIES_SYNCHRONIZED before Bars() is trusted)
#define MTF_SYNC_TIMEOUT_MS  30000     // max wait per (symbol, TF) for history to arrive
#define MTF_SYNC_POLL_MS     500       // poll interval while waiting

//--- ATR regime thresholds (§6 — spec literals)
#define MTF_VOLREG_LO        33.333
#define MTF_VOLREG_HI        66.667

//--- input ranges (§16)
#define MTF_CHUNK_MIN        500
#define MTF_CHUNK_MAX        10000
#define MTF_CHUNK_DEFAULT    2000
#define MTF_LABEL_MIN        1
#define MTF_LABEL_MAX        50
#define MTF_LABEL_DEFAULT    5
#define MTF_SH_CACHE_STRIDE  10000 // flat m_sh_cache stride == MTF_CHUNK_MAX (static, no ArrayResize)

//--- indicator slot order: 0=MA 1=RSI 2=MACD 3=ATR 4=BB 5=Stoch 6=ADX
int    MTF_IND_BUFS[MTF_IND_COUNT] = {1, 1, 2, 1, 3, 2, 3};
int    MTF_IND_COL0[MTF_IND_COUNT] = {0, 1, 2, 4, 5, 8, 10};
int    MTF_IND_WARM[MTF_IND_COUNT] = {20, 15, 40, 15, 20, 20, 33};
string MTF_IND_NAMES[MTF_IND_COLS] = {"ma20","rsi14","macd_main","macd_signal","atr14",
                                      "bb_mid","bb_upper","bb_lower","stoch_k","stoch_d",
                                      "adx14","plus_di14","minus_di14"
                                     };
int    MTF_COL2IND[MTF_IND_COLS]   = {0, 1, 2, 2, 3, 4, 4, 4, 5, 5, 6, 6, 6};

//--- column kinds (single descriptor drives header AND row → order can never drift)
enum MTF_COLKIND
  {
   CK_TIME=0, CK_SYMBOL,
   CK_OPEN, CK_HIGH, CK_LOW, CK_CLOSE, CK_TICKVOL,
   CK_IND,        // sub = 0..12 (MTF_IND_NAMES)
   CK_CUSTOM,     // sub = 0..1  (custom slot)
   CK_LOGRET1, CK_LOGRET5, CK_BODY, CK_UWICK, CK_LWICK,
   CK_ATRPCT, CK_VOLREG, CK_RANGEATR,
   CK_HOUR, CK_WEEKDAY, CK_SESSION,
   CK_NEWS, CK_GAP, CK_SPREAD,
   CK_FUTRET, CK_NEXTDIR, CK_FUTHIGH, CK_FUTLOW, CK_LABELSOK,
   CK_SPLIT
  };

enum MTF_SESSION
  {
   MTF_SESS_ASIAN=0,
   MTF_SESS_LONDON=1,
   MTF_SESS_NEWYORK=2,
   MTF_SESS_OFF=3
  };

//--- one column descriptor
struct MTFColumn
  {
   int               kind;   // MTF_COLKIND
   int               tf;     // TF block index: 0=base, 1..3=HTF
   int               sub;    // indicator col 0..12 / custom slot 0..1
  };

//--- full export configuration (filled by the Script from its inputs)
struct MTFGrabberConfig
  {
   string            symbols;           // "AUTO" or comma-separated list (PRO)
   ENUM_TIMEFRAMES   base_tf;
   datetime          date_from;         // 0 = oldest available
   datetime          date_to;           // 0 = up to last closed bar
   bool              use_ma;
   bool              use_rsi;
   bool              use_macd;
   bool              use_atr;
   bool              use_bb;
   bool              use_stoch;
   bool              use_adx;
   string            custom1_name;      // "" = disabled
   int               custom1_buffer;
   int               custom1_tfmode;    // 0 = base only, 1 = all TFs
   string            custom2_name;
   int               custom2_buffer;
   int               custom2_tfmode;
   bool              use_features;      // §6
   bool              use_time_features; // hour/weekday/session
   bool              use_news;          // §9
   bool              use_spread;        // §11
   bool              use_labels;        // §7
   int               label_horizon;     // 1..50
   datetime          split_date;        // 0 = no split (all train)
   bool              append_mode;       // §10
   int               chunk_bars;        // 500..10000
   bool              ml_ready;          // force §13 bundle
  };

//--- one OHLCV bar
struct MTFBarOHLC
  {
   double            open;
   double            high;
   double            low;
   double            close;
   long              tick_volume;
  };

//--- one fully aligned data row (column order lives in m_cols, not here)
struct MTFRow
  {
   datetime          time;                 // base bar open, server time
   MTFBarOHLC        ohlc[MTF_MAX_TF];     // 0=base, 1..3=HTF
   double            ind[MTF_MAX_TF][MTF_IND_COLS];
   double            custom[MTF_CUSTOM_SLOTS][MTF_MAX_TF];
   // features (§6)
   double            logret_1;
   double            logret_5;
   double            body_ratio;
   double            upper_wick_ratio;
   double            lower_wick_ratio;
   double            atr_pct_100;
   double            range_atr;
   int               vol_regime;
   // time features (§8)
   int               hour;
   int               weekday;
   int               session;              // MTF_SESSION
   // news / gaps / spread
   int               news_high_impact;
   int               gap_bars;
   double            spread_points;
   // labels (§7) — has_* = false means "empty field" in CSV
   double            futret_n;
   bool              has_futret;
   int               next_dir;
   bool              has_nextdir;
   double            fut_high_n;
   bool              has_futhigh;
   double            fut_low_n;
   bool              has_futlow;
   int               labels_ok;
   string            split;                // "train" / "test"
  };

//--- per-TF bulk-copied chunk data.
//--- SERIES ORDER CONTRACT: index i always holds shift (shift_base + i),
//--- i.e. index 0 = the newest copied bar. The position-form Copy* calls
//--- below place the OLDEST bar at physical index 0 of a plain array
//--- (MQL5 Reference: as-series property is ignored on copy), so every
//--- scratch array is forced with ArraySetAsSeries(..., true) BEFORE the
//--- copy to honour this contract. All downstream indexing (li, lj,
//--- m_sh_cache, label windows) depends on it.
struct MTFTFData
  {
   MqlRates          rates[];
   double            ind[][MTF_IND_COLS];  // [local_shift][indicator col]
   double            custom[][MTF_CUSTOM_SLOTS];
   int               shift_base;
   int               count;
  };

//--- export statistics → DataGrabber/last_status.json (Phase-4 panel)
struct MTFExportStats
  {
   string            symbol;
   string            base_tf;
   string            file;
   long              rows;
   long              skipped_rows;
   datetime          started;
   datetime          finished;
   string            warnings[];
  };

//+------------------------------------------------------------------+
//| Timeframe suffix for column names (§3.1): m1..mn1, lowercase     |
//+------------------------------------------------------------------+
string MTF_TfSuffix(const ENUM_TIMEFRAMES tf)
  {
   switch(tf)
     {
      case PERIOD_M1:
         return "m1";
      case PERIOD_M5:
         return "m5";
      case PERIOD_M15:
         return "m15";
      case PERIOD_M30:
         return "m30";
      case PERIOD_H1:
         return "h1";
      case PERIOD_H4:
         return "h4";
      case PERIOD_D1:
         return "d1";
      case PERIOD_W1:
         return "w1";
      case PERIOD_MN1:
         return "mn1";
     }
   return "tf" + IntegerToString(PeriodSeconds(tf));
  }

//+------------------------------------------------------------------+
//| Filename timestamp: YYYYMMDD_HHMMSS (server time)                |
//+------------------------------------------------------------------+
string MTF_StampNow(void)
  {
   string s = TimeToString(TimeTradeServer(), TIME_DATE | TIME_SECONDS);
   StringReplace(s, ".", "");
   StringReplace(s, " ", "_");
   StringReplace(s, ":", "");
   return s;
  }

//+------------------------------------------------------------------+
//| Export file name (§10). Append mode uses a fixed name.           |
//+------------------------------------------------------------------+
string MTF_BuildFileName(const string symbol, const string tf_sfx,
                         const bool append_mode, const bool lite)
  {
   if(lite)
      return StringFormat("%s_%s_%s.csv", symbol, tf_sfx, MTF_StampNow());
   if(append_mode)
      return StringFormat("%s_%s.csv", symbol, tf_sfx);
   return StringFormat("%s_%s_%s.csv", symbol, tf_sfx, MTF_StampNow());
  }

//+------------------------------------------------------------------+
//| MTF_EnsureDir — create every level of a relative dir path. The   |
//| FolderCreate() return value is intentionally ignored (it also    |
//| reports failure when the folder already exists); a genuinely     |
//| missing directory surfaces as a loud FileOpen error afterwards.  |
//+------------------------------------------------------------------+
void MTF_EnsureDir(const string dir)
  {
   int pos = 0;
   while(true)
     {
      int p = StringFind(dir, "/", pos);
      string sub = (p < 0 ? dir : StringSubstr(dir, 0, p));
      if(StringLen(sub) > 0)
         FolderCreate(sub);
      if(p < 0)
         break;
      pos = p + 1;
     }
  }

//+------------------------------------------------------------------+
//| CCsvWriter — header / append / naming per SPEC §2 + §10          |
//| Separator ';', CRLF, no BOM, header written only for new files.  |
//| Append mode: validates existing header width, finds last data    |
//| time, never rewrites the header, never backfills old labels.     |
//+------------------------------------------------------------------+
class CCsvWriter
  {
private:
   int               m_handle;
   string            m_path;

   int               CountFields(const string line)
     {
      int n = 1;
      int len = StringLen(line);
      for(int i = 0; i < len; i++)
         if(StringGetCharacter(line, (ushort)i) == ';')
            n++;
      return n;
     }

   string            ReadFirstLine(const int rh)
     {
      FileSeek(rh, 0, SEEK_SET);
      return FileReadString(rh);
     }

   // Returns the last non-empty data line (no trailing CR).
   string            ReadLastDataLine(const int rh, const long fsize)
     {
      long pos = fsize - 1;
      string ch;
      while(pos > 0) // skip trailing CR/LF
        {
         FileSeek(rh, pos, SEEK_SET);
         ch = FileReadString(rh, 1);
         if(ch == "\n" || ch == "\r")
            pos--;
         else
            break;
        }
      long line_end = pos;
      while(pos > 0)
        {
         FileSeek(rh, pos - 1, SEEK_SET);
         ch = FileReadString(rh, 1);
         if(ch == "\n")
            break;
         pos--;
        }
      FileSeek(rh, pos, SEEK_SET);
      string line = FileReadString(rh, (int)(line_end - pos + 1));
      int len = StringLen(line); // strip trailing CR of CRLF
      if(len > 0 && StringGetCharacter(line, (ushort)(len - 1)) == 13)
         line = StringSubstr(line, 0, len - 1);
      return line;
     }

public:
                     CCsvWriter(void) { m_handle = INVALID_HANDLE; m_path = ""; }
                    ~CCsvWriter(void) { Close(); }

   void              Close(void)
     {
      if(m_handle != INVALID_HANDLE)
        {
         FileClose(m_handle);
         m_handle = INVALID_HANDLE;
        }
     }

   string            Path(void) const { return m_path; }
   bool              IsOpen(void) const { return m_handle != INVALID_HANDLE; }

   // New export: truncate + write header once.
   bool              OpenNew(const string dir, const string filename,
                             const string header_line, string &err)
     {
      Close();
      MTF_EnsureDir(dir);
      m_path = dir + "/" + filename;
      m_handle = FileOpen(m_path, FILE_WRITE | FILE_TXT | FILE_ANSI);
      if(m_handle == INVALID_HANDLE)
        {
         err = "FileOpen(write) failed: " + m_path + " err=" + IntegerToString(GetLastError());
         return false;
        }
      if(!WriteLine(header_line))
        {
         err = "header write failed: " + m_path;
         Close();
         return false;
        }
      return true;
     }

   // Append: existing file → validate header width, extract last data
   // time; missing/empty file → write header like OpenNew.
   bool              OpenAppend(const string dir, const string filename,
                                const string header_line, const int expected_cols,
                                datetime &last_time, string &err)
     {
      Close();
      MTF_EnsureDir(dir);
      m_path = dir + "/" + filename;
      last_time = 0;
      bool exists = FileIsExist(m_path);
      long fsize = 0;
      if(exists)
        {
         int rh = FileOpen(m_path, FILE_READ | FILE_TXT | FILE_ANSI);
         if(rh == INVALID_HANDLE)
           {
            err = "cannot read existing file: " + m_path;
            return false;
           }
         fsize = (long)FileSize(rh);
         if(fsize > 0)
           {
            string first = ReadFirstLine(rh);
            int cols = CountFields(first);
            if(cols != expected_cols)
              {
               FileClose(rh);
               err = StringFormat("append aborted: existing header has %d columns, current schema has %d — refusing to corrupt the file",
                                  cols, expected_cols);
               return false;
              }
            string last = ReadLastDataLine(rh, fsize);
            FileClose(rh);
            if(last != "")
              {
               int p = StringFind(last, MTF_COL_SEP);
               string ts = (p > 0 ? StringSubstr(last, 0, p) : last);
               last_time = StringToTime(ts);
               if(last_time == 0)
                 {
                  err = "cannot parse last time in existing file: " + m_path;
                  return false;
                 }
              }
           }
         else
            FileClose(rh);
        }
      m_handle = FileOpen(m_path, FILE_READ | FILE_WRITE | FILE_TXT | FILE_ANSI);
      if(m_handle == INVALID_HANDLE)
        {
         err = "FileOpen(append) failed: " + m_path + " err=" + IntegerToString(GetLastError());
         return false;
        }
      FileSeek(m_handle, 0, SEEK_END);
      if(!exists || fsize == 0)
        {
         if(!WriteLine(header_line))
           {
            err = "header write failed: " + m_path;
            Close();
            return false;
           }
        }
      return true;
     }

   // Writes one pre-joined line + CRLF. Returns false on I/O failure.
   bool              WriteLine(const string line)
     {
      if(m_handle == INVALID_HANDLE)
         return false;
      uint n = FileWriteString(m_handle, line + MTF_CRLF);
      return n > 0;
     }
  };

//+------------------------------------------------------------------+
//| CMTFDataCore — indicator handles, HTF alignment, row collection, |
//| labels, chunked export. One instance per (symbol, base TF).       |
//+------------------------------------------------------------------+
class CMTFDataCore
  {
private:
   MTFGrabberConfig  m_cfg;
   string            m_symbol;
   ENUM_TIMEFRAMES   m_base_tf;
   string            m_base_sfx;
   int               m_base_sec;
   ENUM_TIMEFRAMES   m_htf[MTF_MAX_HTF];
   string            m_htf_sfx[MTF_MAX_HTF];
   int               m_htf_count;
   double            m_point;

   int               m_h[MTF_MAX_TF][MTF_IND_COUNT];     // indicator handles
   int               m_hc[MTF_MAX_TF][MTF_CUSTOM_SLOTS]; // iCustom handles
   bool              m_use[MTF_IND_COUNT];

   MTFTFData         m_tfd[MTF_MAX_TF];                  // bulk chunk data
   int               m_sh_cache[MTF_MAX_HTF * MTF_SH_CACHE_STRIDE]; // flat HTF-shift cache: [hi*STRIDE + bar]
   bool              m_htf_ok[MTF_MAX_HTF];
   MTFColumn         m_cols[];                           // schema (header + rows)
   int               m_ext;                              // extra older base bars per chunk
   int               m_chunk_lo;                         // newest series shift in chunk

   // cross-chunk state
   datetime          m_prev_time;                        // for gap_bars
   double            m_spread_hist[MTF_SPREAD_HIST];
   int               m_spread_hist_n;
   bool              m_spread_warned;
   MTFRow            m_carry[];                          // label-pending tail rows
   datetime          m_news_events[];                    // sorted high-impact times
   bool              m_news_ok;
   string            m_warnings[];
   long              m_rows_done;
   long              m_skipped;
   uint              m_t0;
   int               m_label_n;                          // active horizon (0 = labels off)
   // chunked-export session state (BeginExport -> ExportChunk* -> FinishExport)
   bool              m_exp_active;
   int               m_exp_s_newest;                     // newest exported shift
   int               m_exp_s_oldest;                     // oldest exported shift
   int               m_exp_chunk_bars;
   long              m_exp_n_chunks;
   datetime          m_exp_t_end;                        // frozen forming-bar open (§3.3 roll guard)
   datetime          m_exp_data_from;                    // open time of oldest exported bar (Phase-4 panel)
   datetime          m_exp_data_to;                      // close time of newest exported bar (Phase-4 panel)

   //--- internals
   void              AddWarning(const string w);
   void              AddCol(const int kind, const int tf, const int sub);
   bool              CreateHandles(string &err);
   void              ReleaseHandles(void);
   int               MaxIndWarmup(void);
   bool              CopyChunkInd(const int tf_idx, const int shift_lo, const int count, string &err);
   bool              CopyChunkBase(const int shift_lo, const int shift_hi, string &err);
   bool              CopyChunkTF(const int tf_idx, const int shift_lo, const int count, string &err);
   bool              CollectRowShift(const int shift, MTFRow &row);
   double            SpreadForBar(const datetime bar_time);
   double            SpreadMedian(void);
   int               NewsFlag(const datetime bar_time);
   bool              CheckFrozenRange(string &err);
   void              WaitHistorySync(const ENUM_TIMEFRAMES tf); // M1: SERIES_SYNCHRONIZED wait + loud warning
#ifndef GRABBER_LITE
#ifndef GRABBER_NO_CALENDAR
   void              FetchNewsEvents(void);
#else
   void              FetchNewsEvents(void); // degraded stub (old MetaEditor)
#endif
   static int        SymbolCurrencies(const string symbol, string &cur[]);
#endif
   string            ColName(const MTFColumn &col) const;
   string            RowField(const MTFRow &row, const MTFColumn &col) const;
   string            SessionName(const int sess) const;

public:
                     CMTFDataCore(void);
                    ~CMTFDataCore(void) { Shutdown(); }

   bool              Init(const MTFGrabberConfig &cfg, const string symbol,
                          const ENUM_TIMEFRAMES base_tf, const ENUM_TIMEFRAMES &htf[],
                          const int htf_count, string &err);
   void              Shutdown(void);

   // schema
   bool              BuildColumns(string &err);
   int               ColumnCount(void) const { return ArraySize(m_cols); }
   string            HeaderLine(void) const;
   string            RowLine(const MTFRow &row) const;
   string            BaseSuffix(void) const { return m_base_sfx; }

   // one aligned row for a closed base bar opening at bar_time
   bool              CollectRow(const datetime bar_time, MTFRow &row);
   // post-pass labels on oldest→newest rows (SPEC §7)
   void              ComputeLabels(MTFRow &rows[], const int horizon);
   // HTF alignment (SPEC §3.2); -1 = no completed bar available
   int               AlignHTFShift(const datetime bar_time, const int htf_idx);

   // script-driven chunked export primitives
   long              BeginExport(CCsvWriter &writer, MTFExportStats &stats, string &err);
   bool              ExportChunk(CCsvWriter &writer, const long chunk_index,
                                 int &rows_out, int &skipped_out, string &err);
   bool              CloseExport(CCsvWriter &writer, MTFExportStats &stats, string &err);
   bool              FinishExport(CCsvWriter &writer, MTFExportStats &stats, string &err);
   void              AbortExport(CCsvWriter &writer);
   bool              ExportActive(void) const { return m_exp_active; }
   long              ExportChunks(void) const { return m_exp_n_chunks; }
   int               ExpChunkBars(void) const { return m_exp_chunk_bars; } // authoritative chunk grid (L2 check)
   bool              WriteStatusJson(const MTFExportStats &stats, string &err);
   void              WriteSimpleStatus(const string status); // Phase-4 panel lifecycle marker

   // stats / diagnostics
   long              RowsDone(void) const { return m_rows_done; }
   long              SkippedRows(void) const { return m_skipped; }
   int               WarningCount(void) const { return ArraySize(m_warnings); }
   string            Warning(const int i) const { return m_warnings[i]; }

   //--- static helpers used by the Scripts
   static void       ApplyMLReady(MTFGrabberConfig &cfg);
   static bool       ValidateConfig(MTFGrabberConfig &cfg, string &warn, string &err);
   static int        DefaultHTFs(const ENUM_TIMEFRAMES base_tf, ENUM_TIMEFRAMES &htf[]);
  };

//+------------------------------------------------------------------+
//| ctor — handles start as INVALID_HANDLE                           |
//+------------------------------------------------------------------+
CMTFDataCore::CMTFDataCore(void)
  {
   m_symbol = "";
   m_base_tf = PERIOD_CURRENT;
   m_base_sfx = "";
   m_base_sec = 0;
   m_htf_count = 0;
   m_point = 0;
   for(int t = 0; t < MTF_MAX_TF; t++)
     {
      for(int k = 0; k < MTF_IND_COUNT; k++)
         m_h[t][k] = INVALID_HANDLE;
      for(int c = 0; c < MTF_CUSTOM_SLOTS; c++)
         m_hc[t][c] = INVALID_HANDLE;
     }
   for(int h = 0; h < MTF_MAX_HTF; h++)
      m_htf_ok[h] = false;
   for(int k = 0; k < MTF_IND_COUNT; k++)
      m_use[k] = false;
   m_chunk_lo = 0;
   m_prev_time = 0;
   m_spread_hist_n = 0;
   m_spread_warned = false;
   m_news_ok = false;
   m_rows_done = 0;
   m_skipped = 0;
   m_t0 = 0;
   m_label_n = 0;
   m_ext = 0;
   m_exp_active = false;
   m_exp_s_newest = 0;
   m_exp_s_oldest = 0;
   m_exp_chunk_bars = 0;
   m_exp_n_chunks = 0;
   m_exp_t_end = 0;
   m_exp_data_from = 0;
   m_exp_data_to = 0;
   ArrayResize(m_cols, 0);
   ArrayResize(m_carry, 0);
   ArrayResize(m_news_events, 0);
   ArrayResize(m_warnings, 0);
  }

//+------------------------------------------------------------------+
//| Init — create handles once per (symbol, TF set), build schema    |
//+------------------------------------------------------------------+
bool CMTFDataCore::Init(const MTFGrabberConfig &cfg, const string symbol,
                        const ENUM_TIMEFRAMES base_tf, const ENUM_TIMEFRAMES &htf[],
                        const int htf_count, string &err)
  {
   Shutdown();
   ArrayResize(m_warnings, 0);
   err = "";

   if(cfg.date_from != 0 && cfg.date_to != 0 && cfg.date_from > cfg.date_to)
     {
      err = "date_from > date_to";
      return false;
     }

   m_cfg = cfg;
   m_symbol = symbol;
   m_base_tf = base_tf;
   m_base_sfx = MTF_TfSuffix(base_tf);
   m_base_sec = PeriodSeconds(base_tf);
   if(m_base_sec <= 0)
     {
      err = "bad base timeframe";
      return false;
     }

   m_htf_count = 0;
   for(int i = 0; i < htf_count && i < MTF_MAX_HTF; i++)
     {
      if(PeriodSeconds(htf[i]) <= 0)
        {
         err = "bad HTF timeframe";
         return false;
        }
      m_htf[m_htf_count] = htf[i];
      m_htf_sfx[m_htf_count] = MTF_TfSuffix(htf[i]);
      m_htf_count++;
     }

   m_point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
   if(m_point <= 0)
     {
      err = "unknown symbol or no market data: " + symbol;
      return false;
     }

   m_use[0] = cfg.use_ma;
   m_use[1] = cfg.use_rsi;
   m_use[2] = cfg.use_macd;
   m_use[3] = cfg.use_atr;
   m_use[4] = cfg.use_bb;
   m_use[5] = cfg.use_stoch;
   m_use[6] = cfg.use_adx;

#ifdef GRABBER_LITE
   m_label_n = 0;
#else
   m_label_n = cfg.use_labels ? cfg.label_horizon : 0;
#endif

// extra older base bars copied per chunk (features + indicator warmup)
   m_ext = MaxIndWarmup();
#ifndef GRABBER_LITE
   if(cfg.use_features && MTF_BASE_WARMUP_FEAT > m_ext)
      m_ext = MTF_BASE_WARMUP_FEAT;
#endif

   if(!CreateHandles(err))
     {
      Shutdown();
      return false;
     }
   if(!BuildColumns(err))
     {
      Shutdown();
      return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
void CMTFDataCore::Shutdown(void)
  {
   ReleaseHandles();
  }

//+------------------------------------------------------------------+
void CMTFDataCore::ReleaseHandles(void)
  {
   for(int t = 0; t < MTF_MAX_TF; t++)
     {
      for(int k = 0; k < MTF_IND_COUNT; k++)
        {
         if(m_h[t][k] != INVALID_HANDLE)
           {
            IndicatorRelease(m_h[t][k]);
            m_h[t][k] = INVALID_HANDLE;
           }
        }
      for(int c = 0; c < MTF_CUSTOM_SLOTS; c++)
        {
         if(m_hc[t][c] != INVALID_HANDLE)
           {
            IndicatorRelease(m_hc[t][c]);
            m_hc[t][c] = INVALID_HANDLE;
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Create every (TF, indicator) handle once — never inside loops    |
//+------------------------------------------------------------------+
bool CMTFDataCore::CreateHandles(string &err)
  {
   ReleaseHandles();
   ENUM_TIMEFRAMES tfs[MTF_MAX_TF];
   tfs[0] = m_base_tf;
   for(int i = 0; i < m_htf_count; i++)
      tfs[i + 1] = m_htf[i];
   int tf_total = 1 + m_htf_count;

   for(int t = 0; t < tf_total; t++)
     {
      if(m_use[0])
         m_h[t][0] = iMA(m_symbol, tfs[t], MTF_P_MA, 0, MODE_SMA, PRICE_CLOSE);
      if(m_use[1])
         m_h[t][1] = iRSI(m_symbol, tfs[t], MTF_P_RSI, PRICE_CLOSE);
      if(m_use[2])
         m_h[t][2] = iMACD(m_symbol, tfs[t], MTF_P_MACD_FAST, MTF_P_MACD_SLOW,
                           MTF_P_MACD_SIGNAL, PRICE_CLOSE);
      if(m_use[3])
         m_h[t][3] = iATR(m_symbol, tfs[t], MTF_P_ATR);
      if(m_use[4])
         m_h[t][4] = iBands(m_symbol, tfs[t], MTF_P_BB, 0, MTF_P_BB_DEV, PRICE_CLOSE);
      if(m_use[5])
         m_h[t][5] = iStochastic(m_symbol, tfs[t], MTF_P_STOCH_K, MTF_P_STOCH_D,
                                 MTF_P_STOCH_SLOW, MODE_SMA, STO_LOWHIGH);
      if(m_use[6])
         m_h[t][6] = iADX(m_symbol, tfs[t], MTF_P_ADX);

      for(int k = 0; k < MTF_IND_COUNT; k++)
        {
         if(m_use[k] && m_h[t][k] == INVALID_HANDLE)
           {
            err = StringFormat("indicator handle failed: ind=%d tf_index=%d err=%d",
                               k, t, GetLastError());
            return false;
           }
        }

#ifndef GRABBER_LITE
      for(int c = 0; c < MTF_CUSTOM_SLOTS; c++)
        {
         string nm = (c == 0 ? m_cfg.custom1_name : m_cfg.custom2_name);
         int mode  = (c == 0 ? m_cfg.custom1_tfmode : m_cfg.custom2_tfmode);
         if(nm != "" && (mode == 1 || t == 0))
           {
            m_hc[t][c] = iCustom(m_symbol, tfs[t], nm);
            if(m_hc[t][c] == INVALID_HANDLE)
               AddWarning("custom" + IntegerToString(c + 1) + "_handle_failed name=" + nm);
           }
        }
#endif
     }
   return true;
  }

//+------------------------------------------------------------------+
int CMTFDataCore::MaxIndWarmup(void)
  {
   int w = 0;
   for(int k = 0; k < MTF_IND_COUNT; k++)
      if(m_use[k] && MTF_IND_WARM[k] > w)
         w = MTF_IND_WARM[k];
   return w;
  }

//+------------------------------------------------------------------+
void CMTFDataCore::AddWarning(const string w)
  {
   int sz = ArraySize(m_warnings);
   ArrayResize(m_warnings, sz + 1);
   m_warnings[sz] = w;
  }

//+------------------------------------------------------------------+
void CMTFDataCore::AddCol(const int kind, const int tf, const int sub)
  {
   int sz = ArraySize(m_cols);
   ArrayResize(m_cols, sz + 1);
   m_cols[sz].kind = kind;
   m_cols[sz].tf = tf;
   m_cols[sz].sub = sub;
  }

//+------------------------------------------------------------------+
//| ApplyMLReady — force the §13 bundle (symbols stay user-owned)    |
//+------------------------------------------------------------------+
void CMTFDataCore::ApplyMLReady(MTFGrabberConfig &cfg)
  {
#ifndef GRABBER_LITE
   cfg.base_tf = PERIOD_M15;
   cfg.use_ma = true;
   cfg.use_rsi = true;
   cfg.use_macd = true;
   cfg.use_atr = true;
   cfg.use_bb = true;
   cfg.use_stoch = true;
   cfg.use_adx = true;
   cfg.custom1_name = "";
   cfg.custom2_name = "";
   cfg.use_features = true;
   cfg.use_time_features = true;
   cfg.use_news = true;
   cfg.use_spread = true;
   cfg.use_labels = true;
   cfg.label_horizon = MTF_LABEL_DEFAULT;
   cfg.split_date = D'2025.01.01';
   cfg.date_from = D'2022.01.01';
   cfg.date_to = 0;
   cfg.append_mode = false;
   cfg.chunk_bars = MTF_CHUNK_DEFAULT;
#endif
  }

//+------------------------------------------------------------------+
//| ValidateConfig — deterministic: bad ranges are clamped + warned, |
//| hard errors stop the export.                                     |
//+------------------------------------------------------------------+
bool CMTFDataCore::ValidateConfig(MTFGrabberConfig &cfg, string &warn, string &err)
  {
   warn = "";
   err = "";
   if(cfg.date_from != 0 && cfg.date_to != 0 && cfg.date_from > cfg.date_to)
     {
      err = "InpDateFrom > InpDateTo";
      return false;
     }
   if(cfg.chunk_bars < MTF_CHUNK_MIN)
     {
      cfg.chunk_bars = MTF_CHUNK_MIN;
      warn += "chunk_bars_clamped_to_500;";
     }
   if(cfg.chunk_bars > MTF_CHUNK_MAX)
     {
      cfg.chunk_bars = MTF_CHUNK_MAX;
      warn += "chunk_bars_clamped_to_10000;";
     }
   if(cfg.label_horizon < MTF_LABEL_MIN)
     {
      cfg.label_horizon = MTF_LABEL_MIN;
      warn += "label_horizon_clamped_to_1;";
     }
   if(cfg.label_horizon > MTF_LABEL_MAX)
     {
      cfg.label_horizon = MTF_LABEL_MAX;
      warn += "label_horizon_clamped_to_50;";
     }
   if(cfg.custom1_buffer < 0)
      cfg.custom1_buffer = 0;
   if(cfg.custom1_buffer > 63)
      cfg.custom1_buffer = 63;
   if(cfg.custom2_buffer < 0)
      cfg.custom2_buffer = 0;
   if(cfg.custom2_buffer > 63)
      cfg.custom2_buffer = 63;
   if(cfg.custom1_tfmode < 0 || cfg.custom1_tfmode > 1)
      cfg.custom1_tfmode = 0;
   if(cfg.custom2_tfmode < 0 || cfg.custom2_tfmode > 1)
      cfg.custom2_tfmode = 0;
#ifndef GRABBER_LITE
   if(cfg.use_features && !cfg.use_atr)
     {
      cfg.use_atr = true; // features (§6) are defined on ATR(14)
      warn += "use_features_requires_atr_atr_enabled;";
     }
#endif
   return true;
  }

//+------------------------------------------------------------------+
//| DefaultHTFs — first 3 TFs above base on the spec ladder (§3.1)   |
//+------------------------------------------------------------------+
int CMTFDataCore::DefaultHTFs(const ENUM_TIMEFRAMES base_tf, ENUM_TIMEFRAMES &htf[])
  {
   ENUM_TIMEFRAMES ladder[9] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_M30,
                                PERIOD_H1, PERIOD_H4, PERIOD_D1, PERIOD_W1, PERIOD_MN1
                               };
   int bi = -1;
   for(int i = 0; i < 9; i++)
     {
      if(ladder[i] == base_tf)
        {
         bi = i;
         break;
        }
     }
   ArrayResize(htf, 0);
   if(bi < 0)
      return 0;
   for(int i = bi + 1; i < 9 && ArraySize(htf) < MTF_MAX_HTF; i++)
     {
      int sz = ArraySize(htf);
      ArrayResize(htf, sz + 1);
      htf[sz] = ladder[i];
     }
   return ArraySize(htf);
  }

//+------------------------------------------------------------------+
//| BuildColumns — the single source of truth for column ORDER.      |
//| Header and every row are rendered from m_cols, so they can       |
//| never drift apart. Disabled indicators keep their column         |
//| (empty field) to freeze the schema.                              |
//+------------------------------------------------------------------+
bool CMTFDataCore::BuildColumns(string &err)
  {
   ArrayResize(m_cols, 0);
   err = "";
#ifdef GRABBER_LITE
// Fixed 11-column schema (§14)
   AddCol(CK_TIME, 0, 0);
   AddCol(CK_OPEN, 0, 0);
   AddCol(CK_HIGH, 0, 0);
   AddCol(CK_LOW, 0, 0);
   AddCol(CK_CLOSE, 0, 0);
   AddCol(CK_TICKVOL, 0, 0);
   AddCol(CK_IND, 0, 0); // ma20
   AddCol(CK_IND, 0, 1); // rsi14
   AddCol(CK_IND, 0, 2); // macd_main
   AddCol(CK_IND, 0, 3); // macd_signal
   AddCol(CK_IND, 0, 4); // atr14
#else
   AddCol(CK_TIME, 0, 0);
   AddCol(CK_SYMBOL, 0, 0);
   int tf_total = 1 + m_htf_count;
   for(int t = 0; t < tf_total; t++)
     {
      AddCol(CK_OPEN, t, 0);
      AddCol(CK_HIGH, t, 0);
      AddCol(CK_LOW, t, 0);
      AddCol(CK_CLOSE, t, 0);
      AddCol(CK_TICKVOL, t, 0);
      for(int c = 0; c < MTF_IND_COLS; c++)
         AddCol(CK_IND, t, c);
     }
// iCustom columns go after the last TF block (§4)
   for(int cs = 0; cs < MTF_CUSTOM_SLOTS; cs++)
     {
      string nm = (cs == 0 ? m_cfg.custom1_name : m_cfg.custom2_name);
      if(nm == "")
         continue;
      int mode = (cs == 0 ? m_cfg.custom1_tfmode : m_cfg.custom2_tfmode);
      if(mode == 1)
        {
         for(int t = 0; t < tf_total; t++)
            AddCol(CK_CUSTOM, t, cs);
        }
      else
         AddCol(CK_CUSTOM, 0, cs);
     }
   AddCol(CK_LOGRET1, 0, 0);
   AddCol(CK_LOGRET5, 0, 0);
   AddCol(CK_BODY, 0, 0);
   AddCol(CK_UWICK, 0, 0);
   AddCol(CK_LWICK, 0, 0);
   AddCol(CK_ATRPCT, 0, 0);
   AddCol(CK_VOLREG, 0, 0);
   AddCol(CK_RANGEATR, 0, 0);
   AddCol(CK_HOUR, 0, 0);
   AddCol(CK_WEEKDAY, 0, 0);
   AddCol(CK_SESSION, 0, 0);
   AddCol(CK_NEWS, 0, 0);
   AddCol(CK_GAP, 0, 0);
   AddCol(CK_SPREAD, 0, 0);
   AddCol(CK_FUTRET, 0, 0);
   AddCol(CK_NEXTDIR, 0, 0);
   AddCol(CK_FUTHIGH, 0, 0);
   AddCol(CK_FUTLOW, 0, 0);
   AddCol(CK_LABELSOK, 0, 0);
   AddCol(CK_SPLIT, 0, 0);
#endif
   return true;
  }

//+------------------------------------------------------------------+
string CMTFDataCore::ColName(const MTFColumn &col) const
  {
#ifdef GRABBER_LITE
// Lite schema (§14): bare names, no TF suffix
   switch(col.kind)
     {
      case CK_TIME:
         return "time";
      case CK_OPEN:
         return "open";
      case CK_HIGH:
         return "high";
      case CK_LOW:
         return "low";
      case CK_CLOSE:
         return "close";
      case CK_TICKVOL:
         return "tick_volume";
      case CK_IND:
         return MTF_IND_NAMES[col.sub];
     }
   return "";
#else
   string sfx = (col.tf == 0 ? m_base_sfx : m_htf_sfx[col.tf - 1]);
   switch(col.kind)
     {
      case CK_TIME:
         return "time";
      case CK_SYMBOL:
         return "symbol";
      case CK_OPEN:
         return "open_" + sfx;
      case CK_HIGH:
         return "high_" + sfx;
      case CK_LOW:
         return "low_" + sfx;
      case CK_CLOSE:
         return "close_" + sfx;
      case CK_TICKVOL:
         return "tick_volume_" + sfx;
      case CK_IND:
         return MTF_IND_NAMES[col.sub] + "_" + sfx;
      case CK_CUSTOM:
        {
         string nm = "custom" + IntegerToString(col.sub + 1);
         int mode = (col.sub == 0 ? m_cfg.custom1_tfmode : m_cfg.custom2_tfmode);
         if(mode == 1)
            nm += "_" + sfx;
         return nm;
        }
      case CK_LOGRET1:
         return "logret_1";
      case CK_LOGRET5:
         return "logret_5";
      case CK_BODY:
         return "body_ratio";
      case CK_UWICK:
         return "upper_wick_ratio";
      case CK_LWICK:
         return "lower_wick_ratio";
      case CK_ATRPCT:
         return "atr_pct_100";
      case CK_VOLREG:
         return "vol_regime";
      case CK_RANGEATR:
         return "range_atr";
      case CK_HOUR:
         return "hour";
      case CK_WEEKDAY:
         return "weekday";
      case CK_SESSION:
         return "session";
      case CK_NEWS:
         return "news_high_impact";
      case CK_GAP:
         return "gap_bars";
      case CK_SPREAD:
         return "spread_points";
      case CK_FUTRET:
         return "futret_5";
      case CK_NEXTDIR:
         return "next_dir";
      case CK_FUTHIGH:
         return "fut_high_5";
      case CK_FUTLOW:
         return "fut_low_5";
      case CK_LABELSOK:
         return "labels_ok";
      case CK_SPLIT:
         return "split";
     }
#endif
   return "";
  }

//+------------------------------------------------------------------+
string CMTFDataCore::HeaderLine(void) const
  {
   int n = ArraySize(m_cols);
   string line = "";
   for(int i = 0; i < n; i++)
     {
      if(i > 0)
         line += MTF_COL_SEP;
      line += ColName(m_cols[i]);
     }
   return line;
  }

//+------------------------------------------------------------------+
string CMTFDataCore::SessionName(const int sess) const
  {
   switch(sess)
     {
      case MTF_SESS_ASIAN:
         return "asian";
      case MTF_SESS_LONDON:
         return "london";
      case MTF_SESS_NEWYORK:
         return "newyork";
     }
   return "off";
  }

//+------------------------------------------------------------------+
//| RowField — one CSV field. Missing values → empty field (never    |
//| the words NaN/NULL, never fake zeros).                           |
//+------------------------------------------------------------------+
string CMTFDataCore::RowField(const MTFRow &row, const MTFColumn &col) const
  {
   switch(col.kind)
     {
      case CK_TIME:
         return TimeToString(row.time, TIME_DATE | TIME_MINUTES);
      case CK_SYMBOL:
         return m_symbol;
      case CK_OPEN:
         return DoubleToString(row.ohlc[col.tf].open, MTF_PRICE_DIGITS);
      case CK_HIGH:
         return DoubleToString(row.ohlc[col.tf].high, MTF_PRICE_DIGITS);
      case CK_LOW:
         return DoubleToString(row.ohlc[col.tf].low, MTF_PRICE_DIGITS);
      case CK_CLOSE:
         return DoubleToString(row.ohlc[col.tf].close, MTF_PRICE_DIGITS);
      case CK_TICKVOL:
         return IntegerToString(row.ohlc[col.tf].tick_volume);
      case CK_IND:
        {
         int k = MTF_COL2IND[col.sub];
         if(!m_use[k])
            return ""; // disabled indicator keeps an empty column
         double v = row.ind[col.tf][col.sub];
         if(v == EMPTY_VALUE)
            return "";
         return DoubleToString(v, MTF_PRICE_DIGITS);
        }
      case CK_CUSTOM:
        {
         double v = row.custom[col.sub][col.tf];
         if(v == EMPTY_VALUE)
            return "";
         return DoubleToString(v, MTF_PRICE_DIGITS);
        }
#ifndef GRABBER_LITE
      case CK_LOGRET1:
         if(!m_cfg.use_features)
            return "";
         return DoubleToString(row.logret_1, MTF_PRICE_DIGITS);
      case CK_LOGRET5:
         if(!m_cfg.use_features)
            return "";
         return DoubleToString(row.logret_5, MTF_PRICE_DIGITS);
      case CK_BODY:
         if(!m_cfg.use_features)
            return "";
         return DoubleToString(row.body_ratio, MTF_PRICE_DIGITS);
      case CK_UWICK:
         if(!m_cfg.use_features)
            return "";
         return DoubleToString(row.upper_wick_ratio, MTF_PRICE_DIGITS);
      case CK_LWICK:
         if(!m_cfg.use_features)
            return "";
         return DoubleToString(row.lower_wick_ratio, MTF_PRICE_DIGITS);
      case CK_ATRPCT:
         if(!m_cfg.use_features)
            return "";
         return DoubleToString(row.atr_pct_100, MTF_PRICE_DIGITS);
      case CK_VOLREG:
         if(!m_cfg.use_features)
            return "";
         return IntegerToString(row.vol_regime);
      case CK_RANGEATR:
         if(!m_cfg.use_features)
            return "";
         return DoubleToString(row.range_atr, MTF_PRICE_DIGITS);
      case CK_HOUR:
         if(!m_cfg.use_time_features)
            return "";
         return IntegerToString(row.hour);
      case CK_WEEKDAY:
         if(!m_cfg.use_time_features)
            return "";
         return IntegerToString(row.weekday);
      case CK_SESSION:
         if(!m_cfg.use_time_features)
            return "";
         return SessionName(row.session);
      case CK_NEWS:
         if(!m_cfg.use_news)
            return "";
         return IntegerToString(row.news_high_impact);
      case CK_GAP:
         return IntegerToString(row.gap_bars);
      case CK_SPREAD:
         if(!m_cfg.use_spread)
            return "";
         return DoubleToString(row.spread_points, 1);
      case CK_FUTRET:
         if(!row.has_futret)
            return "";
         return DoubleToString(row.futret_n, MTF_PRICE_DIGITS);
      case CK_NEXTDIR:
         if(!row.has_nextdir)
            return "";
         return IntegerToString(row.next_dir);
      case CK_FUTHIGH:
         if(!row.has_futhigh)
            return "";
         return DoubleToString(row.fut_high_n, MTF_PRICE_DIGITS);
      case CK_FUTLOW:
         if(!row.has_futlow)
            return "";
         return DoubleToString(row.fut_low_n, MTF_PRICE_DIGITS);
      case CK_LABELSOK:
         if(!m_cfg.use_labels)
            return "";
         return IntegerToString(row.labels_ok);
      case CK_SPLIT:
         return row.split;
#endif
     }
   return "";
  }

//+------------------------------------------------------------------+
string CMTFDataCore::RowLine(const MTFRow &row) const
  {
   int n = ArraySize(m_cols);
   string line = "";
   for(int i = 0; i < n; i++)
     {
      if(i > 0)
         line += MTF_COL_SEP;
      line += RowField(row, m_cols[i]);
     }
   return line;
  }

//+------------------------------------------------------------------+
//| MTF_HTFBarClose — exact close time of one HTF bar (SPEC §3.2).  |
//| PeriodSeconds() is a fiction for MN1 (fixed 30 days vs real      |
//| 28..31-day months) and overstates D1 closes across weekends, so |
//| the close is derived from the next newer bar's open instead:     |
//| exact for M1..H4, W1 and MN1 (contiguous series, DST-safe), and  |
//| weekend-aware for D1 (Friday's close is Saturday 00:00).         |
//+------------------------------------------------------------------+
datetime MTF_HTFBarClose(const string symbol, const ENUM_TIMEFRAMES tf, const int shift)
  {
   datetime o = iTime(symbol, tf, shift);
   if(o == 0)
      return 0;
   if(shift <= 0)
      return o + PeriodSeconds(tf); // forming bar: approximation only (callers step away from it)
   datetime next_open = iTime(symbol, tf, shift - 1);
   if(next_open == 0)
      return 0;
   if(tf == PERIOD_D1 && next_open - o > MTF_D1_WEEKEND_GAP)
      return o + MTF_SEC_PER_DAY; // weekend gap: Friday's close, not Monday's open
   return next_open;
  }

//+------------------------------------------------------------------+
//| AlignHTFShift — SPEC §3.2: last COMPLETED HTF bar at-or-before   |
//| bar_time. Never the forming bar. -1 = none available (row skips).|
//| Completion is tested against the bar's EXACT close (see above), |
//| never against open + PeriodSeconds().                            |
//+------------------------------------------------------------------+
int CMTFDataCore::AlignHTFShift(const datetime bar_time, const int htf_idx)
  {
   if(htf_idx < 0 || htf_idx >= m_htf_count)
      return -1;
   ResetLastError();
   int s = iBarShift(m_symbol, m_htf[htf_idx], bar_time, false);
   if(s < 0)
      return -1;
   datetime c = MTF_HTFBarClose(m_symbol, m_htf[htf_idx], s);
   if(c == 0)
      return -1;
   if(c > bar_time)
      s++; // containing bar not complete yet → step back to the last completed one
   datetime c2 = MTF_HTFBarClose(m_symbol, m_htf[htf_idx], s);
   if(c2 == 0 || c2 > bar_time)
      return -1;
   return s;
  }

//+------------------------------------------------------------------+
//| CopyChunkInd — bulk-copy every enabled indicator buffer for one  |
//| TF over [shift_lo, shift_lo+count). Series order in the arrays   |
//| (see the MTFTFData contract above).                              |
//+------------------------------------------------------------------+
bool CMTFDataCore::CopyChunkInd(const int tf_idx, const int shift_lo,
                                const int count, string &err)
  {
   ArrayResize(m_tfd[tf_idx].ind, count);
   ArrayResize(m_tfd[tf_idx].custom, count);
   for(int i = 0; i < count; i++)
     {
      for(int c = 0; c < MTF_IND_COLS; c++)
         m_tfd[tf_idx].ind[i][c] = EMPTY_VALUE;
      m_tfd[tf_idx].custom[i][0] = EMPTY_VALUE;
      m_tfd[tf_idx].custom[i][1] = EMPTY_VALUE;
     }
   for(int k = 0; k < MTF_IND_COUNT; k++)
     {
      if(!m_use[k])
         continue;
      int h = m_h[tf_idx][k];
      int nb = MTF_IND_BUFS[k];
      int c0 = MTF_IND_COL0[k];
      for(int b = 0; b < nb; b++)
        {
         double buf[];
         ArraySetAsSeries(buf, true); // buf[0] = shift shift_lo (newest); see contract above
         int got = CopyBuffer(h, b, shift_lo, count, buf);
         if(got != count)
           {
            err = StringFormat("CopyBuffer failed: tf_index=%d ind=%d buffer=%d got=%d want=%d err=%d",
                               tf_idx, k, b, got, count, GetLastError());
            return false;
           }
         for(int i = 0; i < count; i++)
            m_tfd[tf_idx].ind[i][c0 + b] = buf[i];
        }
     }
#ifndef GRABBER_LITE
   for(int c = 0; c < MTF_CUSTOM_SLOTS; c++)
     {
      int h = m_hc[tf_idx][c];
      if(h == INVALID_HANDLE)
         continue;
      int cb = (c == 0 ? m_cfg.custom1_buffer : m_cfg.custom2_buffer);
      double buf[];
      ArraySetAsSeries(buf, true); // buf[0] = shift shift_lo (newest); see contract above
      int got = CopyBuffer(h, cb, shift_lo, count, buf);
      if(got != count)
        {
         err = StringFormat("CopyBuffer custom%d failed: got=%d want=%d err=%d",
                            c + 1, got, count, GetLastError());
         return false;
        }
      for(int i = 0; i < count; i++)
         m_tfd[tf_idx].custom[i][c] = buf[i];
     }
#endif
   m_tfd[tf_idx].shift_base = shift_lo;
   m_tfd[tf_idx].count = count;
   return true;
  }

//+------------------------------------------------------------------+
//| CopyChunkBase — base rates + indicators, extended by m_ext older |
//| bars so features (logret_5, atr_pct_100) never reach past the    |
//| copied window.                                                   |
//+------------------------------------------------------------------+
bool CMTFDataCore::CopyChunkBase(const int shift_lo, const int shift_hi, string &err)
  {
   int want = (shift_hi + m_ext) - shift_lo + 1;
   MqlRates tmp[];
   ArraySetAsSeries(tmp, true); // tmp[0] = shift shift_lo (newest); see contract above
   ResetLastError();
   int got = CopyRates(m_symbol, m_base_tf, shift_lo, want, tmp);
   if(got < 0)
     {
      err = "CopyRates base failed, err=" + IntegerToString(GetLastError());
      return false;
     }
   int need = shift_hi - shift_lo + 1;
   if(got < need)
     {
      err = StringFormat("CopyRates base short: got=%d need=%d err=%d",
                         got, need, GetLastError());
      return false;
     }
   ArrayResize(m_tfd[0].rates, got);
   for(int i = 0; i < got; i++)
      m_tfd[0].rates[i] = tmp[i];
   m_tfd[0].shift_base = shift_lo;
   m_tfd[0].count = got;
   m_chunk_lo = shift_lo;
   return CopyChunkInd(0, shift_lo, got, err);
  }

//+------------------------------------------------------------------+
bool CMTFDataCore::CopyChunkTF(const int tf_idx, const int shift_lo,
                               const int count, string &err)
  {
   MqlRates tmp[];
   ArraySetAsSeries(tmp, true); // tmp[0] = shift shift_lo (newest); see contract above
   ResetLastError();
   int got = CopyRates(m_symbol, m_htf[tf_idx - 1], shift_lo, count, tmp);
   if(got != count)
     {
      err = StringFormat("CopyRates HTF %s failed: got=%d want=%d err=%d",
                         m_htf_sfx[tf_idx - 1], got, count, GetLastError());
      return false;
     }
   ArrayResize(m_tfd[tf_idx].rates, got);
   for(int i = 0; i < got; i++)
      m_tfd[tf_idx].rates[i] = tmp[i];
   m_tfd[tf_idx].shift_base = shift_lo;
   m_tfd[tf_idx].count = count;
   return CopyChunkInd(tf_idx, shift_lo, count, err);
  }

//+------------------------------------------------------------------+
//| CollectRowShift — fill one aligned row for a base series shift.  |
//| Returns false when the row must be skipped (SPEC §5: EMPTY_VALUE |
//| in a required indicator, or no completed HTF bar).               |
//+------------------------------------------------------------------+
bool CMTFDataCore::CollectRowShift(const int shift, MTFRow &row)
  {
   int li = shift - m_chunk_lo;
   if(li < 0 || li >= m_tfd[0].count)
      return false;

   MqlRates r = m_tfd[0].rates[li];
   row.time = r.time;
   row.ohlc[0].open = r.open;
   row.ohlc[0].high = r.high;
   row.ohlc[0].low = r.low;
   row.ohlc[0].close = r.close;
   row.ohlc[0].tick_volume = r.tick_volume;

// base indicators (§5: EMPTY_VALUE in a required one → skip row)
   for(int c = 0; c < MTF_IND_COLS; c++)
     {
      int k = MTF_COL2IND[c];
      if(!m_use[k])
        {
         row.ind[0][c] = EMPTY_VALUE;
         continue;
        }
      double v = m_tfd[0].ind[li][c];
      if(v == EMPTY_VALUE)
         return false;
      row.ind[0][c] = v;
     }

// HTF blocks
   for(int hi = 0; hi < m_htf_count; hi++)
     {
      if(!m_htf_ok[hi])
         return false;
      int sh = m_sh_cache[hi * MTF_SH_CACHE_STRIDE + li];
      if(sh < 0)
         return false;
      int lj = sh - m_tfd[hi + 1].shift_base;
      if(lj < 0 || lj >= m_tfd[hi + 1].count)
         return false;
      MqlRates hr = m_tfd[hi + 1].rates[lj];
      row.ohlc[hi + 1].open = hr.open;
      row.ohlc[hi + 1].high = hr.high;
      row.ohlc[hi + 1].low = hr.low;
      row.ohlc[hi + 1].close = hr.close;
      row.ohlc[hi + 1].tick_volume = hr.tick_volume;
      for(int c = 0; c < MTF_IND_COLS; c++)
        {
         int k = MTF_COL2IND[c];
         if(!m_use[k])
           {
            row.ind[hi + 1][c] = EMPTY_VALUE;
            continue;
           }
         double v = m_tfd[hi + 1].ind[lj][c];
         if(v == EMPTY_VALUE)
            return false;
         row.ind[hi + 1][c] = v;
        }
     }

#ifndef GRABBER_LITE
// iCustom slots: EMPTY_VALUE → empty field (no row skip; customs may
// legitimately output EMPTY at edges)
   int tf_total = 1 + m_htf_count;
   for(int t = 0; t < tf_total; t++)
     {
      int lt = (t == 0) ? li : (m_sh_cache[(t - 1) * MTF_SH_CACHE_STRIDE + li] - m_tfd[t].shift_base);
      for(int cs = 0; cs < MTF_CUSTOM_SLOTS; cs++)
        {
         string nm = (cs == 0 ? m_cfg.custom1_name : m_cfg.custom2_name);
         int mode = (cs == 0 ? m_cfg.custom1_tfmode : m_cfg.custom2_tfmode);
         if(nm == "" || m_hc[t][cs] == INVALID_HANDLE || (mode == 0 && t != 0))
           {
            row.custom[cs][t] = EMPTY_VALUE;
            continue;
           }
         if(lt < 0 || lt >= m_tfd[t].count)
            row.custom[cs][t] = EMPTY_VALUE;
         else
            row.custom[cs][t] = m_tfd[t].custom[lt][cs];
        }
     }

// features (§6) — all on the closed base bar
   if(m_cfg.use_features)
     {
      int nbuf = m_tfd[0].count;
      if(li + 5 >= nbuf)
         return false;
      double c0 = m_tfd[0].rates[li].close;
      double c1 = m_tfd[0].rates[li + 1].close;
      double c5 = m_tfd[0].rates[li + 5].close;
      if(c0 <= 0 || c1 <= 0 || c5 <= 0)
         return false;
      row.logret_1 = MathLog(c0 / c1);
      row.logret_5 = MathLog(c0 / c5);
      double body = MathAbs(c0 - r.open);
      double range = r.high - r.low;
      if(range > 0)
        {
         row.body_ratio = body / range;
         row.upper_wick_ratio = (r.high - MathMax(r.open, c0)) / range;
         row.lower_wick_ratio = (MathMin(r.open, c0) - r.low) / range;
        }
      else
        {
         row.body_ratio = 0;
         row.upper_wick_ratio = 0;
         row.lower_wick_ratio = 0;
        }
      // atr percentile over up to 100 ATR values including the current one
      int wn = nbuf - li;
      if(wn > MTF_ATR_PCT_WINDOW)
         wn = MTF_ATR_PCT_WINDOW;
      if(wn < 2)
         return false;
      double cur_atr = m_tfd[0].ind[li][4]; // atr14 column
      if(cur_atr == EMPTY_VALUE)
         return false;
      int less = 0;
      for(int wgt = 0; wgt < wn; wgt++)
        {
         double v = m_tfd[0].ind[li + wgt][4];
         if(v == EMPTY_VALUE)
            return false;
         if(v < cur_atr)
            less++;
        }
      row.atr_pct_100 = (double)less / (double)(wn - 1) * 100.0;
      row.vol_regime = (row.atr_pct_100 < MTF_VOLREG_LO) ? 0 : ((row.atr_pct_100 > MTF_VOLREG_HI) ? 2 : 1);
      row.range_atr = (cur_atr > 0) ? range / cur_atr : 0.0;
     }

// time features (§8 — broker server time)
   if(m_cfg.use_time_features)
     {
      MqlDateTime dt;
      TimeToStruct(row.time, dt);
      row.hour = dt.hour;
      row.weekday = dt.day_of_week; // 0=Sunday … 6=Saturday
      if(dt.hour <= 7)
         row.session = MTF_SESS_ASIAN;
      else
         if(dt.hour <= 12)
            row.session = MTF_SESS_LONDON;
         else
            if(dt.hour <= 21)
               row.session = MTF_SESS_NEWYORK;
            else
               row.session = MTF_SESS_OFF;
     }

// news flag (§9)
   row.news_high_impact = NewsFlag(row.time);

// gap bars (§10) — no fake rows for missing bars; the next real bar
// records how many base periods were skipped
   if(m_prev_time == 0)
      row.gap_bars = 0;
   else
     {
      row.gap_bars = (int)((row.time - m_prev_time) / m_base_sec) - 1;
      if(row.gap_bars < 0)
         row.gap_bars = 0;
     }
   m_prev_time = row.time;

// real spread (§11)
   row.spread_points = m_cfg.use_spread ? SpreadForBar(row.time) : 0.0;

// labels are filled later by ComputeLabels(); split now (§12)
   row.has_futret = false;
   row.has_nextdir = false;
   row.has_futhigh = false;
   row.has_futlow = false;
   row.labels_ok = 0;
   if(m_cfg.split_date == 0)
      row.split = "train";
   else
      row.split = (row.time < m_cfg.split_date ? "train" : "test");
#endif
   return true;
  }

//+------------------------------------------------------------------+
//| CollectRow — public single-row API: one aligned row for the      |
//| closed base bar opening at bar_time. (The script-driven chunked  |
//| path — BeginExport/ExportChunk — is the production exporter;     |
//| this is for inspection / QA.)                                   |
//+------------------------------------------------------------------+
bool CMTFDataCore::CollectRow(const datetime bar_time, MTFRow &row)
  {
   int s = iBarShift(m_symbol, m_base_tf, bar_time, false);
   if(s < 0)
      return false;
   datetime bt = iTime(m_symbol, m_base_tf, s);
   if(bt != bar_time)
      return false; // not an exact bar open
   string err;
   if(ArraySize(m_tfd[0].rates) == 0 || s < m_chunk_lo || s >= m_chunk_lo + m_tfd[0].count)
     {
      if(!CopyChunkBase(s, s, err))
         return false;
      for(int hi = 0; hi < m_htf_count; hi++)
        {
         int sh = AlignHTFShift(bar_time, hi);
         m_sh_cache[hi * MTF_SH_CACHE_STRIDE] = sh;
         if(sh < 0)
           {
            m_htf_ok[hi] = false;
            continue;
           }
         m_htf_ok[hi] = true;
         if(!CopyChunkTF(hi + 1, sh, 1, err))
            return false;
        }
     }
   return CollectRowShift(s, row);
  }

//+------------------------------------------------------------------+
//| SpreadForBar — mean (ask-bid)/point over real ticks in           |
//| [T, T+P_base). Fallback chain (§11): median of the last 100      |
//| bars with ticks → 0.0 + one warning.                             |
//+------------------------------------------------------------------+
double CMTFDataCore::SpreadForBar(const datetime bar_time)
  {
#ifndef GRABBER_LITE
   if(m_cfg.use_spread)
     {
      MqlTick ticks[];
      ResetLastError();
      int n = CopyTicksRange(m_symbol, ticks, COPY_TICKS_INFO,
                             (ulong)bar_time * 1000,
                             (ulong)(bar_time + m_base_sec) * 1000);
      if(n > 0)
        {
         double sum = 0.0;
         int cnt = 0;
         for(int i = 0; i < n; i++)
           {
            if(ticks[i].ask > 0 && ticks[i].bid > 0 && ticks[i].ask >= ticks[i].bid)
              {
               sum += (ticks[i].ask - ticks[i].bid) / m_point;
               cnt++;
              }
           }
         if(cnt > 0)
           {
            double avg = sum / cnt;
            if(m_spread_hist_n < MTF_SPREAD_HIST)
               m_spread_hist[m_spread_hist_n++] = avg;
            else
              {
               for(int i = 0; i < MTF_SPREAD_HIST - 1; i++)
                  m_spread_hist[i] = m_spread_hist[i + 1];
               m_spread_hist[MTF_SPREAD_HIST - 1] = avg;
              }
            return avg;
           }
        }
      if(!m_spread_warned)
        {
         AddWarning("spread_fallback");
         m_spread_warned = true;
        }
      return SpreadMedian();
     }
#endif
   return 0.0;
  }

//+------------------------------------------------------------------+
double CMTFDataCore::SpreadMedian(void)
  {
   int n = m_spread_hist_n;
   if(n <= 0)
      return 0.0;
   double tmp[];
   ArrayResize(tmp, n);
   for(int i = 0; i < n; i++)
      tmp[i] = m_spread_hist[i];
   ArraySort(tmp);
   if(n % 2 == 1)
      return tmp[n / 2];
   return (tmp[n / 2 - 1] + tmp[n / 2]) / 2.0;
  }

#ifndef GRABBER_LITE
//+------------------------------------------------------------------+
//| SymbolCurrencies — "XAUUSD.pro" → {XAU, USD} (§9)               |
//+------------------------------------------------------------------+
int CMTFDataCore::SymbolCurrencies(const string symbol, string &cur[])
  {
   string base = symbol;
   int p = -1;
   int f1 = StringFind(base, ".");
   int f2 = StringFind(base, "_");
   int f3 = StringFind(base, "-");
   if(f1 >= 0)
      p = f1;
   if(f2 >= 0 && (p < 0 || f2 < p))
      p = f2;
   if(f3 >= 0 && (p < 0 || f3 < p))
      p = f3;
   if(p > 0)
      base = StringSubstr(base, 0, p);
   int len = StringLen(base);
   ArrayResize(cur, 2);
   if(len >= 6)
     {
      cur[0] = StringSubstr(base, 0, 3);
      cur[1] = StringSubstr(base, len - 3, 3);
      return 2;
     }
   if(len >= 3)
     {
      cur[0] = StringSubstr(base, 0, 3);
      return 1;
     }
   return 0;
  }

#ifndef GRABBER_NO_CALENDAR
//+------------------------------------------------------------------+
//| FetchNewsEvents — high-impact event times for the symbol's       |
//| currencies, sorted. Calendar times are trade-server time per     |
//| MQL5 docs → compared directly with bar times (no conversion).   |
//| Any failure → empty list + calendar_unavailable warning; the     |
//| export never stops and no data is invented (§9 fail-safe).        |
//+------------------------------------------------------------------+
void CMTFDataCore::FetchNewsEvents(void)
  {
   ArrayResize(m_news_events, 0);
   m_news_ok = false;
   string cur[];
   int nc = SymbolCurrencies(m_symbol, cur);
   if(nc == 0)
     {
      AddWarning("calendar_unavailable");
      return;
     }
   datetime from = m_cfg.date_from;
   if(from == 0)
     {
      int bt = Bars(m_symbol, m_base_tf);
      from = (bt > 1 ? iTime(m_symbol, m_base_tf, bt - 1) : TimeTradeServer() - MTF_CAL_FALLBACK_SEC);
     }
   datetime to = TimeTradeServer();
   for(int c = 0; c < nc; c++)
     {
      MqlCalendarValue vals[];
      ResetLastError();
      int n = CalendarValueHistory(vals, from, to, NULL, cur[c]);
      if(n < 0)
        {
         AddWarning("calendar_unavailable");
         ArrayResize(m_news_events, 0);
         return;
        }
      for(int i = 0; i < n; i++)
        {
         MqlCalendarEvent ev;
         if(!CalendarEventById(vals[i].event_id, ev))
            continue;
         if(ev.importance != CALENDAR_IMPORTANCE_HIGH)
            continue;
         int sz = ArraySize(m_news_events);
         ArrayResize(m_news_events, sz + 1);
         m_news_events[sz] = vals[i].time;
        }
     }
   ArraySort(m_news_events);
   int w = 0; // dedupe
   for(int i = 0; i < ArraySize(m_news_events); i++)
     {
      if(i == 0 || m_news_events[i] != m_news_events[i - 1])
        {
         m_news_events[w] = m_news_events[i];
         w++;
        }
     }
   ArrayResize(m_news_events, w);
   m_news_ok = true;
  }
#else
//+------------------------------------------------------------------+
//| Degraded stub for MetaEditor < build 1930 (no calendar API).     |
//+------------------------------------------------------------------+
void CMTFDataCore::FetchNewsEvents(void)
  {
   ArrayResize(m_news_events, 0);
   m_news_ok = false;
   AddWarning("calendar_unavailable");
  }
#endif

//+------------------------------------------------------------------+
//| NewsFlag — 1 when a high-impact event falls within ±30 min of    |
//| the bar open, else 0.                                            |
//+------------------------------------------------------------------+
int CMTFDataCore::NewsFlag(const datetime bar_time)
  {
   if(!m_cfg.use_news || !m_news_ok)
      return 0;
   int n = ArraySize(m_news_events);
   if(n == 0)
      return 0;
   datetime t0 = bar_time - MTF_NEWS_WINDOW_SEC;
   int lo = 0, hi = n - 1, ans = -1; // first event >= t0
   while(lo <= hi)
     {
      int mid = (lo + hi) / 2;
      if(m_news_events[mid] < t0)
         lo = mid + 1;
      else
        {
         ans = mid;
         hi = mid - 1;
        }
     }
   if(ans < 0)
      return 0;
   for(int i = ans; i < n; i++)
     {
      long d = (long)m_news_events[i] - (long)bar_time;
      if(d > MTF_NEWS_WINDOW_SEC)
         break;
      if(d >= -MTF_NEWS_WINDOW_SEC)
         return 1;
     }
   return 0;
  }
#endif // GRABBER_LITE

//+------------------------------------------------------------------+
//| ComputeLabels — post-pass on oldest→newest rows (SPEC §7).       |
//| avail = number of newer exported rows. Empty fields +            |
//| labels_ok=0 wherever the future is not available.                |
//+------------------------------------------------------------------+
void CMTFDataCore::ComputeLabels(MTFRow &rows[], const int horizon)
  {
   int n = ArraySize(rows);
   if(n == 0 || horizon <= 0)
      return;
   for(int i = 0; i < n; i++)
     {
      int avail = (n - 1) - i;
      rows[i].has_futret = false;
      rows[i].has_nextdir = false;
      rows[i].has_futhigh = false;
      rows[i].has_futlow = false;
      rows[i].labels_ok = 0;
      if(avail >= horizon)
        {
         double c0 = rows[i].ohlc[0].close;
         double cN = rows[i + horizon].ohlc[0].close;
         if(c0 > 0 && cN > 0)
           {
            rows[i].futret_n = MathLog(cN / c0);
            rows[i].has_futret = true;
           }
         double hh = rows[i + 1].ohlc[0].high;
         double ll = rows[i + 1].ohlc[0].low;
         for(int k = 2; k <= horizon; k++)
           {
            if(rows[i + k].ohlc[0].high > hh)
               hh = rows[i + k].ohlc[0].high;
            if(rows[i + k].ohlc[0].low < ll)
               ll = rows[i + k].ohlc[0].low;
           }
         rows[i].fut_high_n = hh;
         rows[i].has_futhigh = true;
         rows[i].fut_low_n = ll;
         rows[i].has_futlow = true;
        }
      if(avail >= 1)
        {
         rows[i].next_dir = (rows[i + 1].ohlc[0].close > rows[i].ohlc[0].close) ? 1 : 0;
         rows[i].has_nextdir = true;
        }
      if(rows[i].has_futret && rows[i].has_nextdir &&
         rows[i].has_futhigh && rows[i].has_futlow)
         rows[i].labels_ok = 1;
     }
  }

//+------------------------------------------------------------------+
//| MTF_WaitSeriesSync — M1 fix. For PRO multi-symbol runs, Bars() |
//| on a symbol whose history is still streaming returns a partial  |
//| count → silently short/ragged CSVs. Wait until the series is    |
//| synchronized (SERIES_SYNCHRONIZED — long-established API) or    |
//| the timeout elapses. Timeout → false + warn text; the export    |
//| proceeds on whatever history is available (never a silent hang, |
//| never a silent partial file). IsStopped() aborts the wait.      |
//+------------------------------------------------------------------+
bool MTF_WaitSeriesSync(const string symbol, const ENUM_TIMEFRAMES tf, string &warn)
  {
   warn = "";
   ResetLastError();
   long synced = SeriesInfoInteger(symbol, tf, SERIES_SYNCHRONIZED);
   if(GetLastError() != 0)
     {
      warn = "history_sync_unavailable_" + symbol + "_" + MTF_TfSuffix(tf);
      return false;
     }
   if(synced != 0)
      return true; // already synchronized: no wait at all
   Bars(symbol, tf); // trigger the history download, then poll
   int waited = 0;
   while(waited < MTF_SYNC_TIMEOUT_MS)
     {
      if(IsStopped())
        {
         warn = "history_sync_aborted_by_user_" + symbol + "_" + MTF_TfSuffix(tf);
         return false;
        }
      Sleep(MTF_SYNC_POLL_MS);
      waited += MTF_SYNC_POLL_MS;
      ResetLastError();
      synced = SeriesInfoInteger(symbol, tf, SERIES_SYNCHRONIZED);
      if(GetLastError() == 0 && synced != 0)
         return true;
     }
   warn = "history_sync_timeout_" + symbol + "_" + MTF_TfSuffix(tf);
   return false;
  }

//+------------------------------------------------------------------+
//| BeginExport — freeze the range, open the file, fetch news.      |
//| Returns the exportable closed-bar count, or -1 + err on failure. |
//| Follow with ExportChunk(0..K-1) oldest→newest, then FinishExport.|
//+------------------------------------------------------------------+
long CMTFDataCore::BeginExport(CCsvWriter &writer, MTFExportStats &stats, string &err)
  {
   m_rows_done = 0;
   m_skipped = 0;
   m_prev_time = 0;
   m_spread_hist_n = 0;
   m_spread_warned = false;
   ArrayResize(m_carry, 0);
   m_exp_active = false;
   m_t0 = GetTickCount();
   err = "";

   stats.symbol = m_symbol;
   stats.base_tf = m_base_sfx;
   stats.file = "";
   stats.rows = 0;
   stats.skipped_rows = 0;
   stats.started = TimeTradeServer();
   stats.finished = 0;
   ArrayResize(stats.warnings, 0);

//--- 0. M1 fix: wait for the base series to synchronize BEFORE Bars()
//--- is trusted (multi-symbol PRO runs on symbols whose history is
//--- still streaming would otherwise export silently short CSVs).
//--- Placed before the T_end freeze so the §3.3 roll guard still
//--- covers any bar that opens during the wait.
   WaitHistorySync(m_base_tf);

//--- 1. freeze the right edge: export only T < T_end (§3.3)
   datetime t_end = iTime(m_symbol, m_base_tf, 0);
   if(t_end == 0)
     {
      err = "iTime(forming bar) failed, err=" + IntegerToString(GetLastError());
      return -1;
     }
   m_exp_t_end = t_end; // roll guard: every chunk re-verifies the freeze (see ExportChunk)
   datetime date_to = t_end;
   if(m_cfg.date_to != 0 && m_cfg.date_to < t_end)
      date_to = m_cfg.date_to;

   int bars_total = Bars(m_symbol, m_base_tf);
   if(bars_total < 2)
     {
      err = "no history for " + m_symbol;
      return -1;
     }
   int s_max = bars_total - 1; // oldest shift

//--- 2. newest exportable shift: newest bar with T < date_to (and < t_end)
   int s_newest = 1;
   if(date_to < t_end)
     {
      int sh = iBarShift(m_symbol, m_base_tf, date_to, false);
      if(sh < 0)
        {
         err = "date_to is older than available history";
         return -1;
        }
      datetime bt = iTime(m_symbol, m_base_tf, sh);
      if(bt == 0)
        {
         err = "iTime failed, err=" + IntegerToString(GetLastError());
         return -1;
        }
      s_newest = (bt < date_to ? sh : sh + 1);
      if(s_newest < 1)
         s_newest = 1;
     }

//--- 3. oldest exportable shift: oldest bar with T >= date_from
   int s_oldest_req = s_max;
   if(m_cfg.date_from > 0)
     {
      int sh = iBarShift(m_symbol, m_base_tf, m_cfg.date_from, false);
      if(sh >= 0)
        {
         datetime bt = iTime(m_symbol, m_base_tf, sh);
         if(bt == 0)
           {
            err = "iTime failed, err=" + IntegerToString(GetLastError());
            return -1;
           }
         s_oldest_req = (bt >= m_cfg.date_from ? sh : sh - 1);
         if(s_oldest_req > s_max)
            s_oldest_req = s_max;
        }
      // sh < 0 → date_from older than all history: keep s_max
     }

//--- 4. warmup: the first row needs need_old older closed bars (§5)
   int need_old = m_ext;
   int s_oldest;
   if(s_oldest_req + need_old <= s_max)
     {
      s_oldest = s_oldest_req; // full warmup available
     }
   else
     {
      s_oldest = s_max - need_old; // oldest fully-warmed bar
      if(s_oldest < s_newest)
        {
         s_oldest = s_newest; // degraded: history shorter than warmup
         AddWarning("history_short_no_full_warmup");
        }
      else
         if(m_cfg.date_from > 0)
            AddWarning("history_starts_at=" +
                       TimeToString(iTime(m_symbol, m_base_tf, s_oldest), TIME_DATE | TIME_MINUTES));
     }

//--- 5. HTF warmup: earliest base bar needs enough completed HTF bars
   int w_ind = MaxIndWarmup();
   for(int hi = 0; hi < m_htf_count; hi++)
     {
      WaitHistorySync(m_htf[hi]); // M1 fix: sync wait per HTF as well
      int htf_bars = Bars(m_symbol, m_htf[hi]);
      if(htf_bars < 2)
        {
         AddWarning("htf_no_history_" + m_htf_sfx[hi]);
         continue;
        }
      while(s_oldest > s_newest)
        {
         datetime T0 = iTime(m_symbol, m_base_tf, s_oldest);
         if(T0 == 0)
            break;
         int sh = AlignHTFShift(T0, hi);
         if(sh >= 0 && sh + w_ind <= htf_bars - 1)
            break;
         s_oldest--;
        }
      datetime Tchk = iTime(m_symbol, m_base_tf, s_oldest);
      if(Tchk != 0)
        {
         int sh = AlignHTFShift(Tchk, hi);
         if(sh < 0 || sh + w_ind > htf_bars - 1)
            AddWarning("htf_history_short_" + m_htf_sfx[hi]);
        }
     }

   long n_bars = (long)s_oldest - (long)s_newest + 1;
   if(n_bars <= 0)
     {
      err = "no bars in the selected range";
      return -1;
     }

//--- 6. news events (PRO)
#ifndef GRABBER_LITE
   if(m_cfg.use_news)
      FetchNewsEvents();
#endif

//--- 7. open the file
#ifdef GRABBER_LITE
   string dir = "DataGrabber/Lite";
   bool is_lite = true;
#else
   string dir = "DataGrabber";
   bool is_lite = false;
#endif
   string fname = MTF_BuildFileName(m_symbol, m_base_sfx, m_cfg.append_mode, is_lite);
   bool ok;
#ifndef GRABBER_LITE
   datetime t_last = 0;
   if(m_cfg.append_mode)
     {
      ok = writer.OpenAppend(dir, fname, HeaderLine(), ColumnCount(), t_last, err);
      if(ok && t_last > 0)
        {
         m_prev_time = t_last; // first appended row measures its gap vs the file's last bar (§10)
         // export only bars with T > t_last
         int shl = iBarShift(m_symbol, m_base_tf, t_last, false);
         if(shl >= 1)
           {
            int s_old2 = s_oldest;
            if(shl - 1 < s_old2)
               s_old2 = shl - 1;
            if(s_old2 < s_newest)
              {
               AddWarning("append_nothing_new");
               n_bars = 0;
              }
            else
              {
               s_oldest = s_old2;
               n_bars = (long)s_oldest - (long)s_newest + 1;
              }
           }
        }
     }
   else
      ok = writer.OpenNew(dir, fname, HeaderLine(), err);
#else
   ok = writer.OpenNew(dir, fname, HeaderLine(), err);
#endif
   if(!ok)
      return -1;
   stats.file = writer.Path();

   m_exp_s_newest = s_newest;
   m_exp_s_oldest = s_oldest;
//--- Phase-4 panel: freeze the data-range timestamps now, while the
//--- shifts are known-good. Shifts stay valid only while the §3.3
//--- roll guard holds, so resolving them later (at FinishExport) could lie.
   m_exp_data_from = iTime(m_symbol, m_base_tf, s_oldest);
   m_exp_data_to = iTime(m_symbol, m_base_tf, s_newest);
   if(m_exp_data_to > 0)
      m_exp_data_to += PeriodSeconds(m_base_tf); // close time of the newest bar
   m_exp_chunk_bars = m_cfg.chunk_bars;
   m_exp_n_chunks = (n_bars + m_exp_chunk_bars - 1) / m_exp_chunk_bars;
   m_exp_active = true;
   WriteSimpleStatus("running"); // Phase-4 panel: export in progress
   return n_bars;
  }

//+------------------------------------------------------------------+
//| CheckFrozenRange — §3.3 roll guard. The shift grid frozen in     |
//| BeginExport stays valid only while no new base bar opens. A roll |
//| mid-export would silently shift every later chunk by one bar and |
//| break the determinism guarantee, so the export fails LOUD here   |
//| instead of drifting. The user simply reruns the script.          |
//+------------------------------------------------------------------+
bool CMTFDataCore::CheckFrozenRange(string &err)
  {
   if(iTime(m_symbol, m_base_tf, 0) != m_exp_t_end)
     {
      err = "new base bar opened during export — the frozen range is stale (§3.3); rerun the export";
      return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| WaitHistorySync — M1 fix wrapper: poll SERIES_SYNCHRONIZED for  |
//| one TF; on timeout/failure record a LOUD warning (core warnings |
//| list + Experts log) so a partial-data export is never silent.   |
//+------------------------------------------------------------------+
void CMTFDataCore::WaitHistorySync(const ENUM_TIMEFRAMES tf)
  {
   string w;
   if(MTF_WaitSeriesSync(m_symbol, tf, w))
      return;
   AddWarning(w);
   Print("Warning: Multi-TF Data Grabber [", m_symbol, " ", MTF_TfSuffix(tf), "]: ", w,
         " — continuing with the history available now (may be partial).");
  }

//+------------------------------------------------------------------+
//| ExportChunk — process one chunk (chunk_index 0-based, oldest    |
//| first). Call each index exactly once, oldest→newest, for exact   |
//| gap_bars and label carry-over. rows_out/skipped_out count what   |
//| THIS chunk flushed.                                              |
//+------------------------------------------------------------------+
bool CMTFDataCore::ExportChunk(CCsvWriter &writer, const long chunk_index,
                               int &rows_out, int &skipped_out, string &err)
  {
   rows_out = 0;
   skipped_out = 0;
   err = "";
   if(!m_exp_active)
     {
      err = "export not started (call BeginExport first)";
      return false;
     }
   if(chunk_index < 0 || chunk_index >= m_exp_n_chunks)
     {
      err = StringFormat("chunk_index %d out of range [0,%d)",
                         (int)chunk_index, (int)m_exp_n_chunks);
      return false;
     }
   if(!CheckFrozenRange(err))
      return false;

   int chunk = m_exp_chunk_bars;
   int c_hi = m_exp_s_oldest - (int)(chunk_index * chunk); // oldest shift in chunk
   int c_lo = c_hi - chunk + 1;                            // newest shift in chunk
   if(c_lo < m_exp_s_newest)
      c_lo = m_exp_s_newest;
   if(!CopyChunkBase(c_lo, c_hi, err))
      return false;

   int nrows = c_hi - c_lo + 1;
   for(int hi = 0; hi < m_htf_count; hi++)
     {
      int sh_min = -1, sh_max = -1;
      for(int j = 0; j < nrows; j++)
        {
         datetime T = m_tfd[0].rates[j].time;
         int sh = AlignHTFShift(T, hi);
         m_sh_cache[hi * MTF_SH_CACHE_STRIDE + j] = sh;
         if(sh >= 0)
           {
            if(sh_min < 0 || sh < sh_min)
               sh_min = sh;
            if(sh_max < 0 || sh > sh_max)
               sh_max = sh;
           }
        }
      if(sh_min < 0)
        {
         m_htf_ok[hi] = false; // every row of this chunk will skip
         continue;
        }
      m_htf_ok[hi] = true;
      if(!CopyChunkTF(hi + 1, sh_min, sh_max - sh_min + 1, err))
         return false;
     }
   if(!CheckFrozenRange(err)) // no bar rolled during the bulk copies above
      return false;

   MTFRow rows[];
   ArrayResize(rows, 0);
   for(int j = nrows - 1; j >= 0; j--) // oldest → newest
     {
      MTFRow row;
      if(CollectRowShift(c_lo + j, row))
        {
         int sz = ArraySize(rows);
         ArrayResize(rows, sz + 1);
         rows[sz] = row;
         m_rows_done++;
         rows_out++;
        }
      else
        {
         m_skipped++;
         skipped_out++;
        }
     }

// labels: carry-over tail keeps chunk boundaries exact (§7)
   int nc = ArraySize(m_carry);
   int nr = ArraySize(rows);
   MTFRow combined[];
   ArrayResize(combined, nc + nr);
   for(int i = 0; i < nc; i++)
      combined[i] = m_carry[i];
   for(int i = 0; i < nr; i++)
      combined[nc + i] = rows[i];

   int total_combined = ArraySize(combined);
   int flush_n;
#ifndef GRABBER_LITE
   ComputeLabels(combined, m_label_n);
   if(chunk_index == m_exp_n_chunks - 1)
      flush_n = total_combined; // final chunk: tail keeps empty edge labels
   else
      flush_n = total_combined - m_label_n;
#else
   flush_n = total_combined;
#endif
   if(flush_n < 0)
      flush_n = 0;
   for(int i = 0; i < flush_n; i++)
     {
      if(!writer.WriteLine(RowLine(combined[i])))
        {
         err = "file write failed: " + writer.Path();
         return false;
        }
     }
   ArrayResize(m_carry, 0);
   for(int i = flush_n; i < total_combined; i++)
     {
      int sz = ArraySize(m_carry);
      ArrayResize(m_carry, sz + 1);
      m_carry[sz] = combined[i];
     }
   return true;
  }

//+------------------------------------------------------------------+
//| CloseExport — flush any label-pending tail, close the file and  |
//| fill stats. Does NOT write last_status.json (see FinishExport).  |
//+------------------------------------------------------------------+
bool CMTFDataCore::CloseExport(CCsvWriter &writer, MTFExportStats &stats, string &err)
  {
   err = "";
   if(m_exp_active && ArraySize(m_carry) > 0)
     {
      // Defensive: normally empty — the final chunk already flushed
      // everything with correct empty edge labels.
#ifndef GRABBER_LITE
      ComputeLabels(m_carry, m_label_n);
#endif
      for(int i = 0; i < ArraySize(m_carry); i++)
        {
         if(!writer.WriteLine(RowLine(m_carry[i])))
           {
            err = "file write failed: " + writer.Path();
            writer.Close();
            m_exp_active = false;
            return false;
           }
        }
      ArrayResize(m_carry, 0);
     }
   writer.Close();
   m_exp_active = false;
   stats.rows = m_rows_done;
   stats.skipped_rows = m_skipped;
   stats.finished = TimeTradeServer();
   ArrayResize(stats.warnings, ArraySize(m_warnings));
   for(int i = 0; i < ArraySize(m_warnings); i++)
      stats.warnings[i] = m_warnings[i];
   return true;
  }

//+------------------------------------------------------------------+
//| FinishExport — CloseExport + write DataGrabber/last_status.json |
//+------------------------------------------------------------------+
bool CMTFDataCore::FinishExport(CCsvWriter &writer, MTFExportStats &stats, string &err)
  {
   if(!CloseExport(writer, stats, err))
      return false;
   return WriteStatusJson(stats, err);
  }

//+------------------------------------------------------------------+
//| AbortExport — close the file without finalizing (user stop).    |
//| Handles stay alive for a later BeginExport on the same instance.|
//+------------------------------------------------------------------+
void CMTFDataCore::AbortExport(CCsvWriter &writer)
  {
   if(m_exp_active)
      WriteSimpleStatus("error"); // Phase-4 panel: the export did not finish
   writer.Close();
   ArrayResize(m_carry, 0);
   m_exp_active = false;
  }

//+------------------------------------------------------------------+
//| WriteStatusJson — DataGrabber/last_status.json for the Phase-4   |
//| panel indicator. Pure ASCII, no BOM.                              |
//+------------------------------------------------------------------+
bool CMTFDataCore::WriteStatusJson(const MTFExportStats &stats, string &err)
  {
   err = "";
//--- Phase-4 panel: data-range timestamps frozen in BeginExport (§3.3-safe)
   string data_from = "", data_to = "";
   if(m_exp_data_from > 0)
      data_from = TimeToString(m_exp_data_from, TIME_DATE | TIME_MINUTES);
   if(m_exp_data_to > 0)
      data_to = TimeToString(m_exp_data_to, TIME_DATE | TIME_MINUTES);
   string w = "{\"status\":\"done\",";
   w += "\"file\":\"" + stats.file + "\",";
   w += "\"symbol\":\"" + stats.symbol + "\",";
   w += "\"base_tf\":\"" + stats.base_tf + "\",";
   w += "\"rows\":" + IntegerToString(stats.rows) + ",";
   w += "\"columns\":" + IntegerToString(ColumnCount()) + ",";
   w += "\"skipped_rows\":" + IntegerToString(stats.skipped_rows) + ",";
   w += "\"data_from\":\"" + data_from + "\",";
   w += "\"data_to\":\"" + data_to + "\",";
   w += "\"started\":\"" + TimeToString(stats.started, TIME_DATE | TIME_MINUTES) + "\",";
   w += "\"finished\":\"" + TimeToString(stats.finished, TIME_DATE | TIME_MINUTES) + "\",";
   w += "\"warnings\":[";
   for(int i = 0; i < ArraySize(stats.warnings); i++)
     {
      if(i > 0)
         w += ",";
      w += "\"" + stats.warnings[i] + "\"";
     }
   w += "]}";
   MTF_EnsureDir("DataGrabber");
   int h = FileOpen("DataGrabber/last_status.json", FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
     {
      err = "status json open failed, err=" + IntegerToString(GetLastError());
      return false;
     }
   FileWriteString(h, w);
   FileClose(h);
   return true;
  }

//+------------------------------------------------------------------+
//| WriteSimpleStatus — minimal lifecycle marker for the Phase-4     |
//| panel: {"status":"running"|"error", symbol, base_tf, started}.   |
//| Best-effort only: never fails an export over the panel file.     |
//+------------------------------------------------------------------+
void CMTFDataCore::WriteSimpleStatus(const string status)
  {
   MTF_EnsureDir("DataGrabber");
   int h = FileOpen("DataGrabber/last_status.json", FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return;
   string w = "{\"status\":\"" + status + "\",";
   w += "\"symbol\":\"" + m_symbol + "\",";
   w += "\"base_tf\":\"" + m_base_sfx + "\",";
   w += "\"started\":\"" + TimeToString(TimeTradeServer(), TIME_DATE | TIME_MINUTES) + "\"}";
   FileWriteString(h, w);
   FileClose(h);
  }

//+------------------------------------------------------------------+
//| FLAT ADAPTER — the eight Grabber_* functions the product Scripts |
//| (DataGrabber_PRO.mq5 / DataGrabber_Lite.mq5) call. Built on top  |
//| of CMTFDataCore/CCsvWriter above; the Scripts are NOT modified.  |
//|                                                                  |
//| The adapter reads the script's Inp* inputs directly (they are    |
//| declared in the script BEFORE this include).                      |
//| Define GRABBER_NO_ADAPTER before the include to compile the core  |
//| standalone without the script contract.                          |
//+------------------------------------------------------------------+
#ifndef GRABBER_NO_ADAPTER

//--- L1: core warnings (e.g. "custom1_handle_failed" from a misspelled
//--- iCustom name) live in the core warnings list → last_status.json → the
//--- panel. A misconfiguration must also be loud in the Experts log, so
//--- every finished run prints its warning list here (fail-soft kept:
//--- the export still completes with empty custom columns).
void Grabber_PrintWarnings(const string tag, const string &w[])
  {
   int n = ArraySize(w);
   for(int i = 0; i < n; i++)
      Print("Warning: ", tag, ": ", w[i]);
  }

//--- fill MTFGrabberConfig from the importing script's Inp* inputs
void Grabber_FillConfig(MTFGrabberConfig &cfg)
  {
#ifdef GRABBER_LITE
   cfg.symbols = "AUTO";
   cfg.base_tf = PERIOD_M1; // placeholder: the Lite adapter sets one TF per core
   cfg.date_from = InpDateFrom;
   cfg.date_to = InpDateTo;
   cfg.use_ma = InpUseMA;
   cfg.use_rsi = InpUseRSI;
   cfg.use_macd = InpUseMACD;
   cfg.use_atr = InpUseATR;
   cfg.use_bb = false;
   cfg.use_stoch = false;
   cfg.use_adx = false;
   cfg.custom1_name = "";
   cfg.custom1_buffer = 0;
   cfg.custom1_tfmode = 0;
   cfg.custom2_name = "";
   cfg.custom2_buffer = 0;
   cfg.custom2_tfmode = 0;
   cfg.use_features = false;
   cfg.use_time_features = false;
   cfg.use_news = false;
   cfg.use_spread = false;
   cfg.use_labels = false;
   cfg.label_horizon = MTF_LABEL_DEFAULT;
   cfg.split_date = 0;
   cfg.append_mode = false;
   cfg.chunk_bars = InpChunkBars;
   cfg.ml_ready = false;
#else
   cfg.symbols = InpSymbols;
   cfg.base_tf = InpBaseTF;
   cfg.date_from = InpDateFrom;
   cfg.date_to = InpDateTo;
   cfg.use_ma = InpUseMA;
   cfg.use_rsi = InpUseRSI;
   cfg.use_macd = InpUseMACD;
   cfg.use_atr = InpUseATR;
   cfg.use_bb = InpUseBB;
   cfg.use_stoch = InpUseStoch;
   cfg.use_adx = InpUseADX;
   cfg.custom1_name = InpCustom1Name;
   cfg.custom1_buffer = InpCustom1Buffer;
   cfg.custom1_tfmode = InpCustom1TFMode;
   cfg.custom2_name = InpCustom2Name;
   cfg.custom2_buffer = InpCustom2Buffer;
   cfg.custom2_tfmode = InpCustom2TFMode;
   cfg.use_features = InpUseFeatures;
   cfg.use_time_features = InpUseTimeFeatures;
   cfg.use_news = InpUseNews;
   cfg.use_spread = InpUseSpread;
   cfg.use_labels = InpUseLabels;
   cfg.label_horizon = InpLabelHorizon;
   cfg.split_date = InpSplitDate;
   cfg.append_mode = InpAppendMode;
   cfg.chunk_bars = InpChunkBars;
   cfg.ml_ready = InpMLReady;
#endif
  }

#ifdef GRABBER_LITE
//====================  LITE adapter (3 TF files: M1, M15, H1)  ====================
#define GRABBER_LITE_TFS 3
ENUM_TIMEFRAMES g_lite_tfs[GRABBER_LITE_TFS] = {PERIOD_M1, PERIOD_M15, PERIOD_H1};
CMTFDataCore   g_lite_core[GRABBER_LITE_TFS];
CCsvWriter     g_lite_writer[GRABBER_LITE_TFS];
MTFExportStats g_lite_stats[GRABBER_LITE_TFS];
long           g_lite_n[GRABBER_LITE_TFS];    // exportable bars per TF
long           g_lite_off[GRABBER_LITE_TFS];  // virtual offsets in the concatenated sequence
string         g_lite_files[GRABBER_LITE_TFS];
long           g_lite_total = 0;
bool           g_lite_active = false;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Grabber_Abort()
  {
   for(int t = 0; t < GRABBER_LITE_TFS; t++)
     {
      g_lite_core[t].AbortExport(g_lite_writer[t]);
      g_lite_core[t].Shutdown();
     }
   g_lite_active = false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Grabber_Begin(const string symbol, string &err)
  {
   Grabber_Abort();
   err = "";
   MTFGrabberConfig cfg;
   Grabber_FillConfig(cfg);
   string warn, verr;
   if(!CMTFDataCore::ValidateConfig(cfg, warn, verr))
     {
      err = verr;
      return false;
     }
   if(warn != "")
      Print("Warning: core: ", warn);
   g_lite_total = 0;
   ENUM_TIMEFRAMES nohtf[];
   for(int t = 0; t < GRABBER_LITE_TFS; t++)
     {
      cfg.base_tf = g_lite_tfs[t];
      if(!g_lite_core[t].Init(cfg, symbol, cfg.base_tf, nohtf, 0, err))
        {
         Grabber_Abort();
         return false;
        }
      long nb = g_lite_core[t].BeginExport(g_lite_writer[t], g_lite_stats[t], err);
      if(nb < 0)
        {
         Grabber_Abort();
         return false;
        }
      g_lite_n[t] = nb;
      g_lite_off[t] = g_lite_total;
      g_lite_total += nb;
      g_lite_files[t] = g_lite_writer[t].Path();
     }
   g_lite_active = true;
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long Grabber_TotalBars(const string symbol)
  {
   if(!g_lite_active)
      return -1;
   return g_lite_total;
  }

// A global chunk may straddle a TF boundary. Every LOCAL chunk is assigned
// to the global chunk containing its first virtual bar → each local chunk is
// exported exactly once, none are missed, none repeat.
bool Grabber_ExportChunk(const string symbol, const int chunk_index,
                         const int chunk_bars, int &rows_out,
                         int &skipped_out, string &err)
  {
   rows_out = 0;
   skipped_out = 0;
   err = "";
   if(!g_lite_active)
     {
      err = "export not started (call Grabber_Begin first)";
      return false;
     }
// L2: the parameter must match the core's authoritative grid. All
// three Lite cores share one cfg, so checking the first core's grid
// covers the whole run. A divergence would misalign the virtual chunk
// mapping — fail loud, never drift silently.
   int grid_bars = g_lite_core[0].ExpChunkBars();
   if(chunk_bars != grid_bars)
     {
      err = StringFormat("chunk_bars mismatch: script passes %d but the export grid is %d — chunks would misalign",
                         chunk_bars, grid_bars);
      return false;
     }
   long cb = chunk_bars;
   long v0 = (long)chunk_index * cb;
   long v1 = v0 + cb;
   if(v1 > g_lite_total)
      v1 = g_lite_total;
   for(int t = 0; t < GRABBER_LITE_TFS; t++)
     {
      long n = g_lite_n[t];
      long kcount = (n + cb - 1) / cb;
      for(long j = 0; j < kcount; j++)
        {
         long ls = g_lite_off[t] + j * cb; // virtual position of local chunk j's first bar
         if(ls >= v0 && ls < v1)
           {
            int r = 0, s = 0;
            if(!g_lite_core[t].ExportChunk(g_lite_writer[t], j, r, s, err))
               return false;
            rows_out += r;
            skipped_out += s;
           }
        }
     }
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Grabber_Finish(const string symbol, int &rows_total,
                    int &skipped_total, string &err)
  {
   rows_total = 0;
   skipped_total = 0;
   err = "";
   if(!g_lite_active)
     {
      err = "export not started (call Grabber_Begin first)";
      return false;
     }
// aggregate the three TF exports into one status record
   MTFExportStats agg;
   agg.symbol = symbol;
   agg.base_tf = "lite";
   agg.file = "";
   agg.rows = 0;
   agg.skipped_rows = 0;
   agg.started = g_lite_stats[0].started;
   agg.finished = 0;
   ArrayResize(agg.warnings, 0);
   string files = "";
   for(int t = 0; t < GRABBER_LITE_TFS; t++)
     {
      string e2;
      if(!g_lite_core[t].CloseExport(g_lite_writer[t], g_lite_stats[t], e2))
        {
         err = e2;
         Grabber_Abort();
         return false;
        }
      agg.rows += g_lite_stats[t].rows;
      agg.skipped_rows += g_lite_stats[t].skipped_rows;
      if(files != "")
         files += ";";
      files += g_lite_stats[t].file;
      for(int i = 0; i < ArraySize(g_lite_stats[t].warnings); i++)
        {
         int sz = ArraySize(agg.warnings);
         ArrayResize(agg.warnings, sz + 1);
         agg.warnings[sz] = g_lite_stats[t].warnings[i];
        }
     }
   agg.file = files;
   agg.finished = TimeTradeServer();
   g_lite_active = false;
// L4: saturate instead of truncating (long → int). Totals beyond
// INT_MAX are unreachable in practice (M1 since 2000 ≈ 12M rows), but
// a wrap-around must never happen silently.
   rows_total = (agg.rows > INT_MAX ? INT_MAX : (int)agg.rows);
   skipped_total = (agg.skipped_rows > INT_MAX ? INT_MAX : (int)agg.skipped_rows);
   if(ArraySize(agg.warnings) > 0)
      Grabber_PrintWarnings("DataGrabber Lite", agg.warnings); // L1: warnings loud in the Experts log too
   return g_lite_core[0].WriteStatusJson(agg, err);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Grabber_FileCount()
  {
   return GRABBER_LITE_TFS;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Grabber_FilePath(const int index)
  {
   if(index < 0 || index >= GRABBER_LITE_TFS)
      return "";
   return g_lite_files[index];
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Grabber_ColumnCount()
  {
   return g_lite_core[0].ColumnCount(); // 11 per SPEC §14
  }

#else
//====================  PRO adapter (one file per symbol)  ====================
CMTFDataCore   g_pro_core;
CCsvWriter     g_pro_writer;
MTFExportStats g_pro_stats;
string         g_pro_file = "";
long           g_pro_total = 0;
bool           g_pro_active = false;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Grabber_Abort()
  {
   g_pro_core.AbortExport(g_pro_writer);
   g_pro_core.Shutdown();
   g_pro_active = false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Grabber_Begin(const string symbol, string &err)
  {
   Grabber_Abort();
   err = "";
   MTFGrabberConfig cfg;
   Grabber_FillConfig(cfg);
   if(cfg.ml_ready)
      CMTFDataCore::ApplyMLReady(cfg); // SPEC §13 (symbols untouched)
   string warn, verr;
   if(!CMTFDataCore::ValidateConfig(cfg, warn, verr))
     {
      err = verr;
      return false;
     }
   if(warn != "")
      Print("Warning: core: ", warn);
   ENUM_TIMEFRAMES htf[];
   int htf_n = CMTFDataCore::DefaultHTFs(cfg.base_tf, htf); // SPEC §3.1
   if(!g_pro_core.Init(cfg, symbol, cfg.base_tf, htf, htf_n, err))
      return false;
   long total = g_pro_core.BeginExport(g_pro_writer, g_pro_stats, err);
   if(total < 0)
     {
      g_pro_core.Shutdown();
      return false;
     }
   g_pro_total = total;
   g_pro_file = g_pro_writer.Path();
   g_pro_active = true;
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long Grabber_TotalBars(const string symbol)
  {
   if(!g_pro_active)
      return -1;
   return g_pro_total;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Grabber_ExportChunk(const string symbol, const int chunk_index,
                         const int chunk_bars, int &rows_out,
                         int &skipped_out, string &err)
  {
   rows_out = 0;
   skipped_out = 0;
   err = "";
   if(!g_pro_active)
     {
      err = "export not started (call Grabber_Begin first)";
      return false;
     }
// L2: the parameter must match the core's authoritative grid. The
// script derives its chunk COUNT from the same validated InpChunkBars,
// so any divergence here would misalign chunks — fail loud, never
// drift silently.
   int grid_bars = g_pro_core.ExpChunkBars();
   if(chunk_bars != grid_bars)
     {
      err = StringFormat("chunk_bars mismatch: script passes %d but the export grid is %d — chunks would misalign",
                         chunk_bars, grid_bars);
      return false;
     }
   return g_pro_core.ExportChunk(g_pro_writer, chunk_index, rows_out, skipped_out, err);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Grabber_Finish(const string symbol, int &rows_total,
                    int &skipped_total, string &err)
  {
   rows_total = 0;
   skipped_total = 0;
   err = "";
   if(!g_pro_active)
     {
      err = "export not started (call Grabber_Begin first)";
      return false;
     }
   bool ok = g_pro_core.FinishExport(g_pro_writer, g_pro_stats, err);
// L4: saturate instead of truncating (long → int) — a wrap-around
// must never happen silently.
   long rd = g_pro_core.RowsDone();
   long sk = g_pro_core.SkippedRows();
   rows_total = (rd > INT_MAX ? INT_MAX : (int)rd);
   skipped_total = (sk > INT_MAX ? INT_MAX : (int)sk);
   g_pro_active = false;
   if(ok && ArraySize(g_pro_stats.warnings) > 0)
      Grabber_PrintWarnings("DataGrabber PRO", g_pro_stats.warnings); // L1: warnings loud in the Experts log too
   return ok;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Grabber_FileCount()
  {
   return 1;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Grabber_FilePath(const int index)
  {
   if(index != 0)
      return "";
   return g_pro_file;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Grabber_ColumnCount()
  {
   return g_pro_core.ColumnCount(); // 94 at ML-Ready defaults (§4)
  }
#endif // GRABBER_LITE

#endif // GRABBER_NO_ADAPTER
//+------------------------------------------------------------------+
//| End of MTFDataCore.mqh v1.05                                     |
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//| Format a duration (seconds) as HH:MM:SS                          |
//+------------------------------------------------------------------+
string FormatDuration(const ulong seconds)
  {
   ulong h = seconds / 3600;
   ulong m = (seconds % 3600) / 60;
   ulong s = seconds % 60;
   return StringFormat("%02d:%02d:%02d", (int)h, (int)m, (int)s);
  }

//+------------------------------------------------------------------+
//| Short text for a runtime error code (never silent)               |
//+------------------------------------------------------------------+
string DescribeError(const int code)
  {
   switch(code)
     {
      case 0:
         return "no error";
      case 4301:
         return "unknown symbol";
      case 4302:
         return "symbol not selected in Market Watch";
      case 4401:
         return "requested history not found";
      case 4405:
         return "error loading history";
      case 4407:
         return "history data not available";
      default:
         return StringFormat("runtime error %d", code);
     }
  }

//+------------------------------------------------------------------+
//| Fatal input checks — READ-ONLY (MQL5 inputs are constant).       |
//| Clamping lives in the core (FillConfig -> ValidateConfig);       |
//| this only fails fast on fatal errors.                            |
//+------------------------------------------------------------------+
bool CheckInputsFatal()
  {
   if(InpDateTo != 0 && InpDateTo < InpDateFrom)
     {
      PrintFormat("Error: InpDateTo=%s is before InpDateFrom=%s.",
                  TimeToString(InpDateTo, TIME_DATE | TIME_SECONDS),
                  TimeToString(InpDateFrom, TIME_DATE | TIME_SECONDS));
      return false;
     }
   if(!InpUseMA && !InpUseRSI && !InpUseMACD && !InpUseATR)
      Print("Warning: all four indicators are disabled — indicator columns will be written empty (schema stays stable per SPEC §4).");
   return true;
  }

//+------------------------------------------------------------------+
//| Does the symbol exist at the broker? (checked, never silent)     |
//+------------------------------------------------------------------+
bool SymbolExists(const string name)
  {
   ResetLastError();
   double point = SymbolInfoDouble(name, SYMBOL_POINT);
   int err = GetLastError();
   if(err != 0)
     {
      PrintFormat("Warning: symbol '%s' skipped — %s.", name, DescribeError(err));
      return false;
     }
   if(point <= 0.0)
     {
      PrintFormat("Warning: symbol '%s' skipped — invalid point size.", name);
      return false;
     }
//--- make sure the symbol is selected so history reads do not fail
   if(!SymbolSelect(name, true))
      PrintFormat("Warning: symbol '%s' could not be selected in Market Watch — history reads may fail.", name);
   return true;
  }

//+------------------------------------------------------------------+
//| DASHBOARD UI — temporary chart objects, ALL removed on exit.     |
//| Set UI_DASHBOARD=false for the classic Comment() progress line,  |
//| UI_SOUND=false for a silent run.                                 |
//+------------------------------------------------------------------+
const bool     UI_DASHBOARD     = true;
const bool     UI_SOUND         = true;
const string   UI_PREFIX        = "DGL_UI_";

const int      UI_W             = 560;
const int      UI_H             = 350;
const int      UI_PAD           = 24;
const int      UI_BAR_Y         = 196;
const int      UI_BAR_H         = 26;
const int      UI_DONE_HOLD_SEC = 15;     // auto-close delay after success

const int      UI_ST_WAIT       = 0;
const int      UI_ST_DONE       = 1;
const int      UI_ST_FAIL       = 2;

const color    UI_C_BG          = C'15,19,27';
const color    UI_C_HDR         = C'24,30,42';
const color    UI_C_BORDER      = C'48,58,78';
const color    UI_C_BARBG       = C'35,43,58';
const color    UI_C_ACCENT      = C'41,182,246';
const color    UI_C_AMBER       = C'255,193,7';
const color    UI_C_GREEN       = C'46,204,113';
const color    UI_C_RED         = C'231,76,60';
const color    UI_C_WHITE       = C'236,240,245';
const color    UI_C_GRAY        = C'140,150,165';

int            g_ui_x           = 0;
int            g_ui_y           = 0;
bool           g_ui_open        = false;
string         g_ui_err         = "";     // last failure reason (shown on the FAILED screen)

//--- Arabic phrases built from Unicode code points (source-encoding safe)
string UI_FromCodes(const ushort &c[])
  {
   string s = "";
   int n = ArraySize(c);
   for(int i = 0; i < n; i++)
      s += ShortToString(c[i]);
   return s;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string UI_Obj(const string id)
  {
   return UI_PREFIX + id;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UI_Panel(const string id, const int x, const int y, const int w, const int h,
              const color fill, const color border)
  {
   string n = UI_Obj(id);
   if(ObjectFind(0, n) < 0)
      if(!ObjectCreate(0, n, OBJ_RECTANGLE_LABEL, 0, 0, 0))
         return;
   ObjectSetInteger(0, n, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, n, OBJPROP_XDISTANCE, g_ui_x + x);
   ObjectSetInteger(0, n, OBJPROP_YDISTANCE, g_ui_y + y);
   ObjectSetInteger(0, n, OBJPROP_XSIZE, MathMax(1, w));
   ObjectSetInteger(0, n, OBJPROP_YSIZE, MathMax(1, h));
   ObjectSetInteger(0, n, OBJPROP_BGCOLOR, fill);
   ObjectSetInteger(0, n, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, n, OBJPROP_COLOR, border);
   ObjectSetInteger(0, n, OBJPROP_BACK, false);
   ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, n, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, n, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UI_Text(const string id, const int x, const int y, const string text,
             const color clr, const int size, const string font,
             const ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT_UPPER)
  {
   string n = UI_Obj(id);
   if(ObjectFind(0, n) < 0)
      if(!ObjectCreate(0, n, OBJ_LABEL, 0, 0, 0))
         return;
   ObjectSetInteger(0, n, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, n, OBJPROP_ANCHOR, anchor);
   ObjectSetInteger(0, n, OBJPROP_XDISTANCE, g_ui_x + x);
   ObjectSetInteger(0, n, OBJPROP_YDISTANCE, g_ui_y + y);
   ObjectSetString(0, n, OBJPROP_TEXT, text);
   ObjectSetString(0, n, OBJPROP_FONT, font);
   ObjectSetInteger(0, n, OBJPROP_FONTSIZE, size);
   ObjectSetInteger(0, n, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, n, OBJPROP_BACK, false);
   ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, n, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, n, OBJPROP_HIDDEN, true);
  }

//--- big headline area (state-dependent)
void UI_Headline(const int state, const string detail)
  {
   int cx = UI_W / 2;
   if(state == UI_ST_WAIT)
     {
      int dots = (int)((GetTickCount() / 500) % 4);
      string d = "";
      for(int i = 0; i < dots; i++)
         d += ".";
      UI_Text("chk", cx, 50, "", UI_C_AMBER, 10, "Wingdings", ANCHOR_UPPER);
      UI_Text("h1", cx, 60, "PLEASE WAIT", UI_C_AMBER, 24, "Arial Black", ANCHOR_UPPER);
      UI_Text("h2", cx, 104, "Please wait until the process is complete", UI_C_WHITE, 17, "Arial", ANCHOR_UPPER);
      UI_Text("h3", cx, 142, "Exporting data" + d, UI_C_GRAY, 10, "Arial", ANCHOR_UPPER);
      UI_Text("h4", cx, 162, "Do not close this chart or the terminal until the process finishes",
              UI_C_GRAY, 9, "Arial", ANCHOR_UPPER);
     }
   else
      if(state == UI_ST_DONE)
        {
         UI_Text("chk", cx, 48, ShortToString(252), UI_C_GREEN, 42, "Wingdings", ANCHOR_UPPER);
         UI_Text("h1", cx, 100, "DONE", UI_C_GREEN, 30, "Arial Black", ANCHOR_UPPER);
         UI_Text("h2", cx, 142, "Export completed successfully", UI_C_WHITE, 16, "Arial Bold", ANCHOR_UPPER);
         UI_Text("h3", cx, 166, "EXPORT COMPLETED SUCCESSFULLY", UI_C_GREEN, 9, "Arial Bold", ANCHOR_UPPER);
         UI_Text("h4", cx, 180, detail, UI_C_GRAY, 9, "Arial", ANCHOR_UPPER);
        }
      else
        {
         string why = g_ui_err;
         if(StringLen(why) > 78)
            why = StringSubstr(why, 0, 75) + "...";
         if(why == "")
            why = "See the Experts tab for details";
         UI_Text("chk", cx, 48, ShortToString(251), UI_C_RED, 42, "Wingdings", ANCHOR_UPPER);
         UI_Text("h1", cx, 100, "FAILED", UI_C_RED, 30, "Arial Black", ANCHOR_UPPER);
         UI_Text("h2", cx, 142, "Export failed — check the Experts log", UI_C_WHITE, 16, "Arial Bold", ANCHOR_UPPER);
         UI_Text("h3", cx, 166, "EXPORT DID NOT COMPLETE", UI_C_RED, 9, "Arial Bold", ANCHOR_UPPER);
         UI_Text("h4", cx, 180, why, UI_C_GRAY, 9, "Arial", ANCHOR_UPPER);
        }
  }

//--- build the dashboard
void UI_Open(const string symbol)
  {
   if(!UI_DASHBOARD)
      return;
   long cw = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   long chh = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   g_ui_x = (int)MathMax(10, (cw - UI_W) / 2);
   g_ui_y = (int)MathMax(10, (chh - UI_H) / 2);
   g_ui_err = "";
   ObjectsDeleteAll(0, UI_PREFIX);

   UI_Panel("bg", 0, 0, UI_W, UI_H, UI_C_BG, UI_C_BORDER);
   UI_Panel("hdr", 1, 1, UI_W - 2, 44, UI_C_HDR, UI_C_HDR);
   UI_Panel("acc", 1, 45, UI_W - 2, 3, UI_C_ACCENT, UI_C_ACCENT);
   UI_Text("title", UI_PAD, 13, PRODUCT_TAG + "  v" + GRABBER_VERSION, UI_C_WHITE, 12, "Arial Bold");
   UI_Text("sym", UI_W - UI_PAD, 13, symbol, UI_C_ACCENT, 12, "Arial Bold", ANCHOR_RIGHT_UPPER);

   UI_Panel("barbg", UI_PAD, UI_BAR_Y, UI_W - 2 * UI_PAD, UI_BAR_H, UI_C_BARBG, UI_C_BORDER);
   UI_Panel("barfill", UI_PAD + 1, UI_BAR_Y + 1, 1, UI_BAR_H - 2, UI_C_BARBG, UI_C_BARBG);
   UI_Text("pct", UI_W / 2, UI_BAR_Y + 4, "Preparing...", UI_C_WHITE, 11, "Arial Bold", ANCHOR_UPPER);

   int c2 = UI_W / 2 + 10;
   UI_Text("l_chunk", UI_PAD, 238, "Chunk", UI_C_GRAY, 9, "Arial");
   UI_Text("l_rows", UI_PAD, 260, "Rows", UI_C_GRAY, 9, "Arial");
   UI_Text("l_skip", UI_PAD, 282, "Skipped", UI_C_GRAY, 9, "Arial");
   UI_Text("l_elap", c2, 238, "Elapsed", UI_C_GRAY, 9, "Arial");
   UI_Text("l_eta", c2, 260, "ETA", UI_C_GRAY, 9, "Arial");
   UI_Text("l_bars", c2, 282, "Bars", UI_C_GRAY, 9, "Arial");
   UI_Text("v_chunk", UI_PAD + 80, 236, "-", UI_C_WHITE, 10, "Arial Bold");
   UI_Text("v_rows", UI_PAD + 80, 258, "-", UI_C_WHITE, 10, "Arial Bold");
   UI_Text("v_skip", UI_PAD + 80, 280, "-", UI_C_WHITE, 10, "Arial Bold");
   UI_Text("v_elap", c2 + 80, 236, "00:00:00", UI_C_WHITE, 10, "Arial Bold");
   UI_Text("v_eta", c2 + 80, 258, "--:--:--", UI_C_WHITE, 10, "Arial Bold");
   UI_Text("v_bars", c2 + 80, 280, "-", UI_C_WHITE, 10, "Arial Bold");

   UI_Panel("sep", UI_PAD, 308, UI_W - 2 * UI_PAD, 1, UI_C_BORDER, UI_C_BORDER);
   UI_Text("foot", UI_PAD, 322, "kouaAlgo Bot Factory", UI_C_GRAY, 8, "Arial");

   UI_Headline(UI_ST_WAIT, "");
   g_ui_open = true;
   ChartRedraw(0);
  }

//--- live progress update
void UI_Update(const string symbol, const int chunk_done, const int chunks,
               const int rows, const int skipped,
               const long bars_done, const long bars_total,
               const ulong elapsed_sec, const ulong eta_sec, const double pct)
  {
   if(!g_ui_open)
      return;
   int full = UI_W - 2 * UI_PAD - 2;
   int w = (int)MathRound(full * MathMin(100.0, MathMax(0.0, pct)) / 100.0);
   color fillc = (w > 0 ? UI_C_ACCENT : UI_C_BARBG);
   UI_Panel("barfill", UI_PAD + 1, UI_BAR_Y + 1, w, UI_BAR_H - 2, fillc, fillc);
   UI_Text("pct", UI_W / 2, UI_BAR_Y + 4, StringFormat("%.1f%%", pct), UI_C_WHITE, 11, "Arial Bold", ANCHOR_UPPER);
   UI_Text("v_chunk", UI_PAD + 80, 236, StringFormat("%d / %d", chunk_done, chunks), UI_C_WHITE, 10, "Arial Bold");
   UI_Text("v_rows", UI_PAD + 80, 258, IntegerToString(rows), UI_C_WHITE, 10, "Arial Bold");
   UI_Text("v_skip", UI_PAD + 80, 280, IntegerToString(skipped), UI_C_WHITE, 10, "Arial Bold");
   int c2 = UI_W / 2 + 10;
   UI_Text("v_elap", c2 + 80, 236, FormatDuration(elapsed_sec), UI_C_WHITE, 10, "Arial Bold");
   UI_Text("v_eta", c2 + 80, 258, (bars_done > 0 ? FormatDuration(eta_sec) : "--:--:--"), UI_C_WHITE, 10, "Arial Bold");
   UI_Text("v_bars", c2 + 80, 280, StringFormat("%I64d / %I64d", bars_done, bars_total), UI_C_WHITE, 10, "Arial Bold");
   UI_Headline(UI_ST_WAIT, "");
   ChartRedraw(0);
  }

//--- smart end-of-run sound
void UI_Sound(const int state)
  {
   if(!UI_SOUND)
      return;
   if(state == UI_ST_DONE)
     {
      PlaySound("ok.wav");
      Sleep(700);
      PlaySound("news.wav");
     }
   else
      PlaySound("stops.wav");
  }

//--- remove every dashboard object
void UI_Close()
  {
   if(!UI_DASHBOARD)
      return;
   ObjectsDeleteAll(0, UI_PREFIX);
   g_ui_open = false;
   ChartRedraw(0);
  }

//--- final screen (success / failure) + sound; waits for CLOSE or timeout
void UI_Finish(const int state, const int rows, const int skipped, const ulong elapsed_sec)
  {
   if(!UI_DASHBOARD)
     {
      UI_Sound(state);
      return;
     }
   if(!g_ui_open)
      return;
   color c = (state == UI_ST_DONE ? UI_C_GREEN : UI_C_RED);
   int full = UI_W - 2 * UI_PAD - 2;
   if(state == UI_ST_DONE)
     {
      UI_Panel("barfill", UI_PAD + 1, UI_BAR_Y + 1, full, UI_BAR_H - 2, c, c);
      UI_Text("pct", UI_W / 2, UI_BAR_Y + 4, "100.0%", UI_C_WHITE, 11, "Arial Bold", ANCHOR_UPPER);
      UI_Text("v_eta", UI_W / 2 + 90, 258, "00:00:00", UI_C_WHITE, 10, "Arial Bold");
     }
   else
      UI_Panel("barfill", UI_PAD + 1, UI_BAR_Y + 1, 1, UI_BAR_H - 2, UI_C_BARBG, UI_C_BARBG);
   UI_Text("v_elap", UI_W / 2 + 90, 236, FormatDuration(elapsed_sec), UI_C_WHITE, 10, "Arial Bold");
   UI_Headline(state, StringFormat("%d row(s) written  |  %d skipped  |  %s",
                                   rows, skipped, FormatDuration(elapsed_sec)));

   string btn = UI_Obj("btn");
   if(ObjectFind(0, btn) < 0)
      ObjectCreate(0, btn, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, btn, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, btn, OBJPROP_XDISTANCE, g_ui_x + UI_W - UI_PAD - 110);
   ObjectSetInteger(0, btn, OBJPROP_YDISTANCE, g_ui_y + 314);
   ObjectSetInteger(0, btn, OBJPROP_XSIZE, 110);
   ObjectSetInteger(0, btn, OBJPROP_YSIZE, 28);
   ObjectSetString(0, btn, OBJPROP_TEXT, "CLOSE");
   ObjectSetString(0, btn, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, btn, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, btn, OBJPROP_COLOR, UI_C_WHITE);
   ObjectSetInteger(0, btn, OBJPROP_BGCOLOR, c);
   ObjectSetInteger(0, btn, OBJPROP_BORDER_COLOR, c);
   ObjectSetInteger(0, btn, OBJPROP_STATE, false);
   ObjectSetInteger(0, btn, OBJPROP_HIDDEN, true);
   ChartRedraw(0);

   UI_Sound(state);

   ulong t0 = GetTickCount();
   int last = -1;
   while(!IsStopped())
     {
      if(ObjectGetInteger(0, btn, OBJPROP_STATE) != 0)
         break;
      int left = UI_DONE_HOLD_SEC - (int)((GetTickCount() - t0) / 1000);
      if(left <= 0)
         break;
      if(left != last)
        {
         UI_Text("foot", UI_PAD, 322, StringFormat("Closing automatically in %ds", left), UI_C_GRAY, 8, "Arial");
         ChartRedraw(0);
         last = left;
        }
      Sleep(100);
     }
   UI_Close();
  }

//+------------------------------------------------------------------+
//| Progress line — dashboard (or Comment() fallback)                |
//+------------------------------------------------------------------+
void ShowProgress(const string symbol, const int chunk_done, const int chunks,
                  const int rows, const int skipped,
                  const long bars_done, const long bars_total,
                  const ulong elapsed_sec)
  {
   double pct = 100.0;
   if(bars_total > 0)
      pct = 100.0 * (double)bars_done / (double)bars_total;
   ulong eta_sec = 0;
   if(bars_done > 0 && bars_done < bars_total)
      eta_sec = (ulong)((double)elapsed_sec * (double)(bars_total - bars_done) / (double)bars_done);

   if(UI_DASHBOARD)
     {
      UI_Update(symbol, chunk_done, chunks, rows, skipped,
                bars_done, bars_total, elapsed_sec, eta_sec, pct);
      return;
     }

   Comment(StringFormat("%s v%s — %s\nChunk %d/%d — %.1f%%\nRows: %d (skipped %d)\nElapsed %s — ETA %s",
                        PRODUCT_TAG, GRABBER_VERSION, symbol,
                        chunk_done, chunks, pct, rows, skipped,
                        FormatDuration(elapsed_sec), FormatDuration(eta_sec)));
  }

//--- v1.05: fast retry alignment. A §3.3 abort always fires right ON a bar
//--- roll, so an immediate retry is already phase-aligned — no waiting.
//--- We wait for the next bar only when the current minute is too far gone.
void AlignForRetry(const string symbol)
  {
   datetime t0 = iTime(symbol, PERIOD_M1, 0);
   if(t0 == 0)
     {
      WaitForFreshBar(symbol); // unknown position — full alignment fallback
      return;
     }
   long elapsed = (long)TimeCurrent() - (long)t0;
   if(elapsed < 0)
      elapsed = 0;
   if(60 - elapsed >= RETRY_MIN_REMAIN_SEC)
      return; // enough room left — retry immediately
   WaitForFreshBar(symbol);
  }

//+------------------------------------------------------------------+
//| v1.05 helpers: bar-roll auto-retry                                |
//+------------------------------------------------------------------+
bool IsStaleRangeError(const string err)
  {
   return StringFind(err, "frozen range is stale") >= 0;
  }

//--- wait for the next M1 bar so a retry starts at the top of a fresh
//--- minute: an export shorter than 60s then cannot roll mid-flight.
void WaitForFreshBar(const string symbol)
  {
   datetime t0 = iTime(symbol, PERIOD_M1, 0);
   if(t0 == 0)
      return; // no M1 data — nothing to align to
   ulong w0 = GetTickCount();
   while(!IsStopped())
     {
      if((GetTickCount() - w0) > 65000)
         break; // waited a full minute without a roll — proceed anyway
      if(iTime(symbol, PERIOD_M1, 0) != t0)
         break;
      Sleep(250);
     }
  }

//--- retry notice on the dashboard: reuses the h4 headline slot, which
//--- the next progress update restores to its normal text.
void UI_RetryNotice(const int attempt)
  {
   if(!g_ui_open)
      return;
   UI_Text("h4", UI_W / 2, 162,
           StringFormat("Bar rolled mid-export — automatic retry %d/%d…",
                        attempt, EXPORT_MAX_ATTEMPTS),
           UI_C_AMBER, 9, "Arial", ANCHOR_UPPER);
   ChartRedraw(0);
  }

//--- delete the partial CSVs left by an aborted attempt.
void DeletePartialFiles()
  {
   for(int f = 0; f < GRABBER_LITE_TFS; f++)
     {
      string p = Grabber_FilePath(f);
      if(p != "" && FileIsExist(p))
         FileDelete(p);
     }
  }

//+------------------------------------------------------------------+
//| v1.05: ExportSymbol = retry wrapper. A §3.3 bar-roll abort is     |
//| retried automatically with a fresh freeze; any other error fails  |
//| loud immediately — never retried, never hidden.                   |
//+------------------------------------------------------------------+
bool ExportSymbol(const string symbol, int &rows_written, int &rows_skipped)
  {
   rows_written = 0;
   rows_skipped = 0;
   for(int attempt = 1; attempt <= EXPORT_MAX_ATTEMPTS; attempt++)
     {
      if(attempt > 1)
        {
         UI_RetryNotice(attempt);
         AlignForRetry(symbol);
         if(IsStopped())
           {
            Comment("");
            return false;
           }
        }
      string err = "";
      bool stale = false;
      if(ExportSymbolAttempt(symbol, rows_written, rows_skipped, err, stale))
         return true;
      if(!stale)
         return false; // real error — already reported inside the attempt
      DeletePartialFiles();
      PrintFormat("%s: [%s] bar rolled during export — automatic retry %d/%d.",
                  PRODUCT_TAG, symbol, attempt, EXPORT_MAX_ATTEMPTS);
     }
   g_ui_err = "bar rolled on every attempt — try again in a quiet minute";
   PrintFormat("%s: [%s] export failed after %d attempts: %s",
               PRODUCT_TAG, symbol, EXPORT_MAX_ATTEMPTS, g_ui_err);
   return false;
  }

//+------------------------------------------------------------------+
//| Export the chart symbol: begin -> chunked loop -> finish         |
//| (v1.05: single attempt — the wrapper above retries bar rolls)    |
//+------------------------------------------------------------------+
bool ExportSymbolAttempt(const string symbol, int &rows_written,
                         int &rows_skipped, string &err, bool &stale)
  {
   rows_written = 0;
   rows_skipped = 0;
   stale = false;
   if(!Grabber_Begin(symbol, err))
     {
      if(IsStaleRangeError(err))
        {
         stale = true; // rolled between freeze and first chunk — retry
         return false;
        }
      g_ui_err = err;
      PrintFormat("%s: [%s] init failed: %s", PRODUCT_TAG, symbol, err);
      return false;
     }

   long total_bars = Grabber_TotalBars(symbol);
   if(total_bars < 0)
     {
      PrintFormat("%s: [%s] could not determine the exportable bar count.", PRODUCT_TAG, symbol);
      Grabber_Abort();
      return false;
     }
   if(total_bars == 0)
      PrintFormat("%s: [%s] no exportable bars in the selected range.", PRODUCT_TAG, symbol);

   int chunk_bars = InpChunkBars;
   if(chunk_bars < CHUNK_MIN)              // mirror the core clamp exactly:
      chunk_bars = CHUNK_MIN;              // the adapter's L2 grid check
   if(chunk_bars > CHUNK_MAX)              // compares this to ExpChunkBars()
      chunk_bars = CHUNK_MAX;
   int chunks = (int)((total_bars + chunk_bars - 1) / chunk_bars);

   ulong t0 = GetTickCount();
   long bars_done = 0;
   ShowProgress(symbol, 0, chunks, 0, 0, 0, total_bars, 0);   // first frame (0%)

   for(int k = 0; k < chunks; k++)
     {
      if(IsStopped())
        {
         Grabber_Abort();
         Comment("");
         PrintFormat("%s: [%s] stopped by user at chunk %d/%d — file handles closed cleanly.",
                     PRODUCT_TAG, symbol, k + 1, chunks);
         return false;
        }
      int rows = 0, skipped = 0;
      err = "";
      if(!Grabber_ExportChunk(symbol, k, chunk_bars, rows, skipped, err))
        {
         Grabber_Abort();
         Comment("");
         if(IsStaleRangeError(err))
           {
            stale = true; // §3.3 roll — the wrapper retries with a fresh freeze
            return false;
           }
         g_ui_err = err;
         PrintFormat("%s: [%s] chunk %d failed: %s", PRODUCT_TAG, symbol, k + 1, err);
         return false;
        }
      rows_written += rows;
      rows_skipped += skipped;
      bars_done = MathMin((long)(k + 1) * chunk_bars, total_bars);
      ShowProgress(symbol, k + 1, chunks, rows_written, rows_skipped,
                   bars_done, total_bars, (GetTickCount() - t0) / 1000);
     }

   Comment("");

   int fin_rows = 0, fin_skipped = 0;
   err = "";
   if(!Grabber_Finish(symbol, fin_rows, fin_skipped, err))
     {
      if(IsStaleRangeError(err))
        {
         stale = true;
         return false;
        }
      g_ui_err = err;
      PrintFormat("%s: [%s] finalize failed: %s", PRODUCT_TAG, symbol, err);
      return false;
     }
   rows_written = fin_rows;     // authoritative totals from the core
   rows_skipped = fin_skipped;

   ulong elapsed_sec = (GetTickCount() - t0) / 1000;
   PrintFormat("%s: [%s] done — %d row(s), %d skipped, %d column(s) per file, elapsed %s.",
               PRODUCT_TAG, symbol, rows_written, rows_skipped,
               Grabber_ColumnCount(), FormatDuration(elapsed_sec));
   int files = Grabber_FileCount();
   for(int f = 0; f < files; f++)
      PrintFormat("%s: [%s] file: %s", PRODUCT_TAG, symbol, Grabber_FilePath(f));
   return true;
  }

//+------------------------------------------------------------------+
//| Script entry point — Lite exports the chart symbol only          |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- 1. Fatal input checks (read-only; the core adapter applies
//---     all clamps per SPEC §16.2)
   if(!CheckInputsFatal())
      return;

//--- 2. Lite = chart symbol only (SPEC §16.2)
   string symbol = _Symbol;
   if(!SymbolExists(symbol))
     {
      Print(PRODUCT_TAG, ": chart symbol '", symbol, "' is not available — cannot export.");
      UI_Sound(UI_ST_FAIL);
      return;
     }

//--- 3. Run the export
   ulong run_start = GetTickCount();
   int rows = 0, skipped = 0;
   UI_Open(symbol);
   bool done = ExportSymbol(symbol, rows, skipped);

   Comment("");
   ulong elapsed_sec = (GetTickCount() - run_start) / 1000;
   if(done)
      PrintFormat("%s v%s finished: [%s] %d row(s) written, %d skipped, elapsed %s.",
                  PRODUCT_TAG, GRABBER_VERSION, symbol, rows, skipped,
                  FormatDuration(elapsed_sec));
   else
      PrintFormat("%s v%s did not complete for [%s] — see the messages above.",
                  PRODUCT_TAG, GRABBER_VERSION, symbol);

//--- 4. Final screen + smart sound (dashboard is always removed on exit)
   if(done)
      UI_Finish(UI_ST_DONE, rows, skipped, elapsed_sec);
   else
      if(IsStopped())
         UI_Close();
      else
         UI_Finish(UI_ST_FAIL, rows, skipped, elapsed_sec);
  }
//+------------------------------------------------------------------+
