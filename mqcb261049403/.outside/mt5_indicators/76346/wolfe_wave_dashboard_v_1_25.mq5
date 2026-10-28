//+------------------------------------------------------------------+
//|                                     Wolfe Wave Dashboard.mq5     |
//|                                                                  |
//|                Professional Trading Utility for MetaTrader 5     |
//|                            Copyright (c) 2026 Marian Beceanu     |
//|                        https://www.mql5.com/en/users/zorbacc     |
//|                              Email: marian.beceanu@gmail.com     |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Wolfe Wave Dashboard"
#property version   "1.25"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   0

//--------------------------- INPUTS ----------------------------------
input group "=== Dashboard Settings ==="
input string  InpSymbols        = "EURUSD,GBPUSD,USDCAD,USDJPY"; // Symbols (comma separated, up to 20)
input string  InpSymbolPrefix   = "";     // Symbol Prefix
input string  InpSymbolSuffix   = "";     // Symbol Suffix
input bool    InpEnableM1       = false;  // Enable M1
input bool    InpEnableM5       = true;   // Enable M5
input bool    InpEnableM15      = true;   // Enable M15
input bool    InpEnableM30      = true;   // Enable M30
input bool    InpEnableH1       = true;   // Enable H1
input bool    InpEnableH4       = true;   // Enable H4
input bool    InpEnableD1       = true;   // Enable D1
input bool    InpEnableW1       = true;   // Enable W1
input bool    InpEnableMN       = false;  // Enable MN1
input int     InpVisibleRows    = 12;     // Visible dashboard rows
input int     InpScanSeconds    = 30;     // Scan interval (seconds) - higher = less CPU
input int     InpDashboardScale = 100;    // Dashboard Scale % (100=normal)
input int     InpFontSize       = 9;      // Dashboard Font Size

input group "=== Performance Settings ==="
input int     InpMaxScansPerTick = 12;    // Max symbol/timeframe scans per timer tick (0 = all at once)
input bool    InpVerboseLogging  = false; // Verbose logging (Experts log)

input group "=== Wolfe Wave Settings ==="
input int     InpPivotStrength   = 3;     // Pivot Strength (bars each side)
input int     InpMinPatternBars  = 15;    // Min Pattern Bars
input int     InpMaxPatternBars  = 150;   // Max Pattern Bars
input int     InpMaxHistoryBars  = 200;   // Max History Bars (lower = faster)
input double  InpLineTolerance   = 0.25;  // Line Tolerance (fraction of pattern height)
input double  InpConvergenceMin  = 0.10;  // Convergence Min
input bool    InpHideAfterTarget = true;  // Remove pattern once price reaches the 1-4 target line

input group "=== Chart Display Settings ==="
input bool    InpShowArrows      = true;
input bool    InpShowLabels      = true;
input bool    InpShowTargetLine  = true;
input color   InpBullColor       = clrLime;
input color   InpBearColor       = clrRed;
input color   InpFillColor       = clrYellow;
input color   InpLineColor       = clrBlack;
input color   InpTargetColor     = clrDodgerBlue;

input group "=== Alert Settings ==="
input string  InpAlertTitle      = "Wolfe Wave Dashboard";
input bool    InpPopupAlert      = true;
input bool    InpSoundAlert      = true;
input string  InpSoundFile       = "alert2.wav";
input bool    InpEmailAlert      = false;
input bool    InpPushAlert       = true;

//--------------------------- BUFFERS ----------------------------------
double DummyBuffer[];

//--------------------------- TYPES -------------------------------------
struct PivotPoint
{
   int      idx;
   datetime time;
   double   price;
   int      type; // 1 = high, -1 = low
};

struct WolfePattern
{
   string   symbol;
   ENUM_TIMEFRAMES tf;
   string   tfName;
   bool     bullish;
   bool     valid;
   double   p1,p2,p3,p4,p5;
   datetime t1,t2,t3,t4,t5;
   double   slope13, slope24;
   int      age;
   bool     alerted;
   datetime lastBarTime; // last CLOSED bar time - allows skipping full re-scan
};

//--------------------------- GLOBALS -----------------------------------
string          g_symbols[];
ENUM_TIMEFRAMES g_timeframes[];
string          g_tfNames[];
WolfePattern    g_patterns[];
string          g_prefix = "";
string          g_suffix = "";

// Effective (clamped) settings
int             g_pivotStrength;
double          g_dashScale;
int             g_fontSize;
int             g_maxHistoryBars;
int             g_visibleRows;
int             g_minPatternBars;
int             g_maxPatternBars;
int             g_maxScansPerTick;

// Chunked scanning
int             g_scanCursor   = 0;

// Dashboard render cache
bool            g_headerDrawn      = false;
int             g_lastRenderedRows = -1;
int             g_sortedIdx[];
int             g_sortedTotal      = 0;
bool            g_dashDirty        = true;

// Cache last drawn text/color so we only touch objects when content really changes
string          g_lastText[][7];
color           g_lastBg[][7];
color           g_lastTxt[][7];

// Avg TTT persistent stats
string          g_statKey[];
double          g_statSum[];
int             g_statCount[];
string          g_statFileName = "WolfeWaveDashboard_TTT.csv";

bool            g_warnedDisconnected = false;
bool            g_symbolsPending    = false;
int             g_symbolRetryCount  = 0;
const int       G_MAX_SYMBOL_RETRIES = 15;
bool            g_anyTransientFailure = false;
bool            g_marketWatchFull = false;
const int       ERR_MARKET_SELECT_LIMIT_CODE = 4306;

// Hard safety limits
const int       G_MAX_COMBOS_SAFE = 120;   // above this we force stronger chunking

//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, DummyBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);

   g_prefix = InpSymbolPrefix;
   g_suffix = InpSymbolSuffix;
   StringTrimLeft(g_prefix);  StringTrimRight(g_prefix);
   StringTrimLeft(g_suffix);  StringTrimRight(g_suffix);

   // Clamp all tunable inputs to safe ranges
   g_pivotStrength   = (int)MathMax(1, MathMin(10, InpPivotStrength));
   g_maxHistoryBars  = (int)MathMax(50, MathMin(500, InpMaxHistoryBars));
   g_visibleRows     = (int)MathMax(1, MathMin(30, InpVisibleRows));
   g_minPatternBars  = (int)MathMax(5, InpMinPatternBars);
   g_maxPatternBars  = (int)MathMax(g_minPatternBars + 5, MathMin(300, InpMaxPatternBars));
   g_dashScale       = MathMax(50, MathMin(250, InpDashboardScale)) / 100.0;
   g_fontSize        = (int)MathMax(6, MathMin(20, InpFontSize));
   g_maxScansPerTick = (InpMaxScansPerTick <= 0) ? 0 : (int)MathMax(1, MathMin(40, InpMaxScansPerTick));

   g_scanCursor        = 0;
   g_headerDrawn       = false;
   g_lastRenderedRows  = -1;
   g_warnedDisconnected = false;
   g_dashDirty         = true;

   LoadTTTStats();

   ParseSymbols();
   BuildTimeframeList();
   BuildPatternSlots();

   // Prepare text/color cache for dashboard (avoids unnecessary ObjectSet calls)
   ArrayResize(g_lastText, g_visibleRows);
   ArrayResize(g_lastBg,   g_visibleRows);
   ArrayResize(g_lastTxt,  g_visibleRows);
   for(int r=0; r<g_visibleRows; r++)
   {
      for(int c=0; c<7; c++)
      {
         g_lastText[r][c] = "";
         g_lastBg[r][c]   = clrNONE;
         g_lastTxt[r][c]  = clrNONE;
      }
   }

   g_symbolsPending   = false;
   g_symbolRetryCount = 0;
   if((ArraySize(g_symbols) == 0 || g_anyTransientFailure) && !g_marketWatchFull && ArraySize(g_timeframes) > 0)
   {
      g_symbolsPending = true;
      Print("WolfeWaveDashboard: not all symbols resolved yet - will retry automatically on the timer.");
   }
   else if(g_marketWatchFull)
   {
      Print("WolfeWaveDashboard: Market Watch is full - free some symbols (Ctrl+M). No automatic retries.");
   }

   if(ArraySize(g_timeframes) == 0)
      Print("WolfeWaveDashboard: no timeframe enabled - dashboard will stay empty.");

   int totalCombos = ArraySize(g_symbols) * ArraySize(g_timeframes);
   if(totalCombos > G_MAX_COMBOS_SAFE)
   {
      PrintFormat("WolfeWaveDashboard: %d combinations is high. Forcing stronger chunking to keep terminal responsive.", totalCombos);
      if(g_maxScansPerTick == 0 || g_maxScansPerTick > 8)
         g_maxScansPerTick = 8;
   }
   else if(totalCombos > 60)
   {
      PrintFormat("WolfeWaveDashboard: %d combinations - scanning is chunked (%d per tick).", totalCombos, (g_maxScansPerTick<=0 ? totalCombos : g_maxScansPerTick));
   }

   EventKillTimer();
   EventSetTimer((int)MathMax(10, InpScanSeconds));   // minimum 10 seconds for safety

   // Initial population (one-time cost at attach)
   int initBudget = (g_maxScansPerTick <= 0) ? ArraySize(g_patterns) : MathMin(g_maxScansPerTick * 3, ArraySize(g_patterns));
   for(int i=0; i<initBudget; i++)
      ScanOne(i);
   // If more slots remain, the normal timer will finish them gradually
   g_scanCursor = initBudget % MathMax(1, ArraySize(g_patterns));

   DrawDashboard();
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   ObjectsDeleteAll(0, "WWD_");
}

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                 const double &open[], const double &high[], const double &low[], const double &close[],
                 const long &tick_volume[], const long &volume[], const int &spread[])
{
   // Empty on purpose - all work is done on the timer to avoid per-tick load
   return(rates_total);
}

//+------------------------------------------------------------------+
void OnTimer()
{
   if(!TerminalInfoInteger(TERMINAL_CONNECTED))
   {
      if(InpVerboseLogging && !g_warnedDisconnected)
      {
         Print("WolfeWaveDashboard: terminal disconnected, scanning paused.");
         g_warnedDisconnected = true;
      }
      return;
   }
   g_warnedDisconnected = false;

   // Bounded symbol retry
   if(g_symbolsPending)
   {
      g_symbolRetryCount++;
      int prevSymbolCount = ArraySize(g_symbols);
      ParseSymbols();
      bool gainedSymbols = (ArraySize(g_symbols) != prevSymbolCount);

      if(ArraySize(g_symbols) > 0 && !g_anyTransientFailure)
      {
         if(gainedSymbols)
         {
            BuildPatternSlots();
            g_scanCursor       = 0;
            g_headerDrawn      = false;
            g_lastRenderedRows = -1;
            ArrayResize(g_lastText, g_visibleRows);
            ArrayResize(g_lastBg,   g_visibleRows);
            ArrayResize(g_lastTxt,  g_visibleRows);
            for(int i=0; i<ArraySize(g_patterns); i++)
               ScanOne(i);
         }
         PrintFormat("WolfeWaveDashboard: symbols resolved after %d retr%s.",
                      g_symbolRetryCount, (g_symbolRetryCount==1?"y":"ies"));
         g_symbolsPending = false;
      }
      else if(gainedSymbols)
      {
         BuildPatternSlots();
         g_scanCursor       = 0;
         g_headerDrawn      = false;
         g_lastRenderedRows = -1;
         for(int i=0; i<ArraySize(g_patterns); i++)
            ScanOne(i);
      }

      if(g_symbolsPending && g_marketWatchFull)
      {
         Print("WolfeWaveDashboard: Market Watch full - stopping retries.");
         g_symbolsPending = false;
      }
      else if(g_symbolsPending && g_symbolRetryCount >= G_MAX_SYMBOL_RETRIES)
      {
         PrintFormat("WolfeWaveDashboard: gave up after %d retries - some symbols still unresolved.", g_symbolRetryCount);
         g_symbolsPending = false;
      }
   }

   ScanBatch();

   if(g_dashDirty)
   {
      DrawDashboard();
      g_dashDirty = false;
   }
}

//+------------------------------------------------------------------+
void ParseSymbols()
{
   string raw = InpSymbols;
   string parts[];
   int n = StringSplit(raw, ',', parts);
   ArrayResize(g_symbols, 0, 20);
   g_anyTransientFailure = false;
   g_marketWatchFull     = false;

   if(n > 20)
      PrintFormat("WolfeWaveDashboard: only the first 20 symbols are used (%d entered).", n);

   for(int i=0; i<n && i<20; i++)
   {
      string s = parts[i];
      StringTrimLeft(s);
      StringTrimRight(s);
      if(StringLen(s)==0) continue;
      string full = g_prefix + s + g_suffix;
      if(StringLen(full) == 0) continue;

      // skip duplicates
      bool dup = false;
      for(int j=0; j<ArraySize(g_symbols); j++)
         if(g_symbols[j] == full) { dup = true; break; }
      if(dup) continue;

      if(!SymbolSelect(full, true))
      {
         int    err      = GetLastError();
         ResetLastError();
         bool   isCustom = false;
         bool   exists   = SymbolExist(full, isCustom);
         bool   limitHit = (err == ERR_MARKET_SELECT_LIMIT_CODE);

         if(limitHit)
            g_marketWatchFull = true;
         else if(exists)
            g_anyTransientFailure = true;

         string reason;
         if(limitHit)
            reason = "Market Watch FULL - remove unused symbols (Ctrl+M).";
         else if(exists)
            reason = "Exists but select failed - will auto-retry.";
         else
            reason = "Does NOT exist on this server - check name/prefix/suffix.";

         PrintFormat("WolfeWaveDashboard: symbol '%s' not selected (err=%d, exists=%s). %s",
                      full, err, (exists?"yes":"no"), reason);
         continue;
      }

      int sz = ArraySize(g_symbols);
      ArrayResize(g_symbols, sz+1, 20);
      g_symbols[sz] = full;
   }

   if(ArraySize(g_symbols) == 0)
      Print("WolfeWaveDashboard: no valid symbols - dashboard empty.");
}

//+------------------------------------------------------------------+
void BuildTimeframeList()
{
   ArrayResize(g_timeframes, 0);
   ArrayResize(g_tfNames, 0);
   AddTF(InpEnableM1,  PERIOD_M1,  "M1");
   AddTF(InpEnableM5,  PERIOD_M5,  "M5");
   AddTF(InpEnableM15, PERIOD_M15, "M15");
   AddTF(InpEnableM30, PERIOD_M30, "M30");
   AddTF(InpEnableH1,  PERIOD_H1,  "H1");
   AddTF(InpEnableH4,  PERIOD_H4,  "H4");
   AddTF(InpEnableD1,  PERIOD_D1,  "D1");
   AddTF(InpEnableW1,  PERIOD_W1,  "W1");
   AddTF(InpEnableMN,  PERIOD_MN1, "MN");
}

void AddTF(bool enabled, ENUM_TIMEFRAMES tf, string name)
{
   if(!enabled) return;
   int sz = ArraySize(g_timeframes);
   ArrayResize(g_timeframes, sz+1);
   ArrayResize(g_tfNames, sz+1);
   g_timeframes[sz] = tf;
   g_tfNames[sz]    = name;
}

//+------------------------------------------------------------------+
int FindOrAddStat(string key)
{
   for(int i=0; i<ArraySize(g_statKey); i++)
      if(g_statKey[i] == key) return i;

   int n = ArraySize(g_statKey);
   ArrayResize(g_statKey,   n+1, 32);
   ArrayResize(g_statSum,   n+1, 32);
   ArrayResize(g_statCount, n+1, 32);
   g_statKey[n]   = key;
   g_statSum[n]   = 0.0;
   g_statCount[n] = 0;
   return n;
}

//+------------------------------------------------------------------+
void LoadTTTStats()
{
   ArrayResize(g_statKey,   0, 32);
   ArrayResize(g_statSum,   0, 32);
   ArrayResize(g_statCount, 0, 32);

   if(!FileIsExist(g_statFileName)) return;

   int fh = FileOpen(g_statFileName, FILE_READ|FILE_CSV|FILE_ANSI, ',');
   if(fh == INVALID_HANDLE) return;

   if(!FileIsEnding(fh)) FileReadString(fh);
   if(!FileIsEnding(fh)) FileReadString(fh);
   if(!FileIsEnding(fh)) FileReadString(fh);

   while(!FileIsEnding(fh))
   {
      string key = FileReadString(fh);
      if(StringLen(key) == 0) break;
      double sum = FileReadNumber(fh);
      int    cnt = (int)FileReadNumber(fh);
      int idx = FindOrAddStat(key);
      g_statSum[idx]   = sum;
      g_statCount[idx] = cnt;
   }
   FileClose(fh);
}

//+------------------------------------------------------------------+
void SaveTTTStats()
{
   int fh = FileOpen(g_statFileName, FILE_WRITE|FILE_CSV|FILE_ANSI, ',');
   if(fh == INVALID_HANDLE) return;

   FileWrite(fh, "key", "sum", "count");
   for(int i=0; i<ArraySize(g_statKey); i++)
      FileWrite(fh, g_statKey[i], g_statSum[i], g_statCount[i]);

   FileClose(fh);
}

//+------------------------------------------------------------------+
void RecordTTTSample(string sym, string tfName, int barsToTarget)
{
   if(barsToTarget < 0) return;
   string key = sym + "|" + tfName;
   int idx = FindOrAddStat(key);
   g_statSum[idx]   += barsToTarget;
   g_statCount[idx] += 1;
   SaveTTTStats();
}

//+------------------------------------------------------------------+
string GetAvgTTTText(string sym, string tfName)
{
   string key = sym + "|" + tfName;
   for(int i=0; i<ArraySize(g_statKey); i++)
   {
      if(g_statKey[i] == key)
      {
         if(g_statCount[i] <= 0) return "-";
         double avg = g_statSum[i] / g_statCount[i];
         return IntegerToString((int)MathRound(avg)) + " (" + IntegerToString(g_statCount[i]) + ")";
      }
   }
   return "-";
}

//+------------------------------------------------------------------+
void BuildPatternSlots()
{
   int total = ArraySize(g_symbols) * ArraySize(g_timeframes);
   ArrayResize(g_patterns, total);
   int k=0;
   for(int i=0;i<ArraySize(g_symbols);i++)
   {
      for(int j=0;j<ArraySize(g_timeframes);j++)
      {
         g_patterns[k].symbol      = g_symbols[i];
         g_patterns[k].tf          = g_timeframes[j];
         g_patterns[k].tfName      = g_tfNames[j];
         g_patterns[k].valid       = false;
         g_patterns[k].alerted     = false;
         g_patterns[k].lastBarTime = 0;
         k++;
      }
   }
}

//+------------------------------------------------------------------+
void ScanBatch()
{
   int total = ArraySize(g_patterns);
   if(total <= 0) return;

   int budget = (g_maxScansPerTick <= 0) ? total : MathMin(g_maxScansPerTick, total);

   for(int done=0; done<budget; done++)
   {
      int i = g_scanCursor;
      g_scanCursor = (g_scanCursor + 1) % total;
      ScanOne(i);
   }
}

//+------------------------------------------------------------------+
void ScanOne(int i)
{
   string sym = g_patterns[i].symbol;
   ENUM_TIMEFRAMES tf = g_patterns[i].tf;

   datetime latestBar = iTime(sym, tf, 0);
   if(latestBar == 0)
   {
      if(g_patterns[i].valid) g_dashDirty = true;
      g_patterns[i].valid       = false;
      g_patterns[i].lastBarTime = 0;
      return;
   }

   // Most important performance guard: skip full work if no new closed bar
   if(g_patterns[i].lastBarTime != 0 && latestBar == g_patterns[i].lastBarTime)
      return;

   g_dashDirty = true;

   WolfePattern found;
   found.valid = false;
   int barsToTarget = -1;
   bool wasValid = g_patterns[i].valid;

   bool ok = DetectPattern(sym, tf, found, barsToTarget);
   g_patterns[i].lastBarTime = latestBar;

   if(ok)
   {
      if(!g_patterns[i].valid || g_patterns[i].t5 != found.t5 || g_patterns[i].bullish != found.bullish)
         found.alerted = false;
      else
         found.alerted = g_patterns[i].alerted;

      found.symbol      = g_patterns[i].symbol;
      found.tf          = g_patterns[i].tf;
      found.tfName      = g_patterns[i].tfName;
      found.valid       = true;
      found.lastBarTime = latestBar;
      g_patterns[i]     = found;

      if(!g_patterns[i].alerted)
      {
         FireAlert(g_patterns[i]);
         g_patterns[i].alerted = true;
      }
   }
   else
   {
      if(wasValid && barsToTarget >= 0)
         RecordTTTSample(sym, g_patterns[i].tfName, barsToTarget);

      g_patterns[i].valid = false;
   }
}

//+------------------------------------------------------------------+
//| Detect most recent valid Wolfe Wave - heavily optimized           |
//+------------------------------------------------------------------+
bool DetectPattern(string sym, ENUM_TIMEFRAMES tf, WolfePattern &out, int &barsToTarget)
{
   barsToTarget = -1;
   int bars = g_maxHistoryBars;

   MqlRates rates[];
   ResetLastError();
   int cr = CopyRates(sym, tf, 1, bars, rates);   // start at 1 = closed bars only
   if(cr <= 0)
   {
      if(InpVerboseLogging)
         PrintFormat("WolfeWaveDashboard: no data for %s %s (err=%d).", sym, EnumToString(tf), GetLastError());
      return false;
   }

   int n = cr;
   if(n < g_pivotStrength*2 + 5) return false;

   ArraySetAsSeries(rates, false); // oldest first

   // === KEY OPTIMIZATION ===
   // We only ever evaluate the most recent 5 pivots, and a valid pattern
   // cannot be wider than g_maxPatternBars. Therefore searching the entire
   // history is wasteful. Limit the pivot scan to a tight recent window.
   int searchWindow = g_maxPatternBars + g_pivotStrength * 4 + 30;
   int startSearch  = MathMax(g_pivotStrength, n - searchWindow);
   int endSearch    = n - g_pivotStrength;
   if(endSearch <= startSearch) return false;

   PivotPoint rawPivots[];
   int rp = 0;
   ArrayResize(rawPivots, 0, 48);   // modest reserve

   for(int i = startSearch; i < endSearch; i++)
   {
      double h = rates[i].high;
      double l = rates[i].low;

      // High pivot - early break
      bool isHigh = true;
      for(int k=1; k<=g_pivotStrength; k++)
      {
         if(h <= rates[i-k].high || h <= rates[i+k].high)
         {
            isHigh = false;
            break;
         }
      }

      if(isHigh)
      {
         ArrayResize(rawPivots, rp+1, 48);
         rawPivots[rp].idx   = i;
         rawPivots[rp].time  = rates[i].time;
         rawPivots[rp].price = h;
         rawPivots[rp].type  = 1;
         rp++;
         continue;   // cannot be both high and low
      }

      // Low pivot - early break
      bool isLow = true;
      for(int k=1; k<=g_pivotStrength; k++)
      {
         if(l >= rates[i-k].low || l >= rates[i+k].low)
         {
            isLow = false;
            break;
         }
      }

      if(isLow)
      {
         ArrayResize(rawPivots, rp+1, 48);
         rawPivots[rp].idx   = i;
         rawPivots[rp].time  = rates[i].time;
         rawPivots[rp].price = l;
         rawPivots[rp].type  = -1;
         rp++;
      }
   }

   if(rp < 5) return false;

   PivotPoint pivots[];
   CleanPivots(rawPivots, pivots);
   int cnt = ArraySize(pivots);
   if(cnt < 5) return false;

   double pointSize = SymbolInfoDouble(sym, SYMBOL_POINT);
   if(pointSize <= 0.0) pointSize = 0.00001;

   // Only the freshest 5-pivot combination is considered
   int start = cnt - 5;
   PivotPoint p1 = pivots[start];
   PivotPoint p2 = pivots[start+1];
   PivotPoint p3 = pivots[start+2];
   PivotPoint p4 = pivots[start+3];
   PivotPoint p5 = pivots[start+4];

   bool bullish = (p1.type==-1 && p2.type==1 && p3.type==-1 && p4.type==1 && p5.type==-1);
   bool bearish = (p1.type== 1 && p2.type==-1 && p3.type== 1 && p4.type==-1 && p5.type== 1);
   if(!bullish && !bearish) return false;

   if(bullish)
   {
      if(!(p3.price < p1.price && p4.price < p2.price)) return false;
   }
   else
   {
      if(!(p3.price > p1.price && p4.price > p2.price)) return false;
   }

   int width = p5.idx - p1.idx;
   if(width < g_minPatternBars || width > g_maxPatternBars) return false;

   if(p3.idx == p1.idx || p4.idx == p2.idx) return false;

   double slope13 = (p3.price - p1.price) / (double)(p3.idx - p1.idx);
   double slope24 = (p4.price - p2.price) / (double)(p4.idx - p2.idx);
   if(MathAbs(slope13 - slope24) < 1e-12) return false;

   double denom = slope24 - slope13;
   double x_int = (p1.price - p2.price - slope13*p1.idx + slope24*p2.idx) / denom;
   if(x_int <= p5.idx) return false; // must converge in the future

   double hi = MathMax(MathMax(p1.price, p2.price), MathMax(p3.price, MathMax(p4.price, p5.price)));
   double lo = MathMin(MathMin(p1.price, p2.price), MathMin(p3.price, MathMin(p4.price, p5.price)));
   double patternHeight = hi - lo;
   if(patternHeight <= pointSize) return false;

   double convergenceAngle = MathAbs(slope13 - slope24) * width / patternHeight;
   if(convergenceAngle < InpConvergenceMin) return false;

   double line13_at5 = p1.price + slope13 * (p5.idx - p1.idx);
   double dist5 = MathAbs(p5.price - line13_at5) / patternHeight;
   if(dist5 > InpLineTolerance) return false;

   // Target reached check - scan from point 5 to the end of available data
   if(InpHideAfterTarget)
   {
      double slope14 = (p4.price - p1.price) / (double)(p4.idx - p1.idx);
      bool targetReached = false;
      for(int chk = p5.idx; chk <= n-1; chk++)
      {
         double targetAtChk = p1.price + slope14 * (chk - p1.idx);
         if(bullish ? (rates[chk].high >= targetAtChk) : (rates[chk].low <= targetAtChk))
         {
            targetReached = true;
            barsToTarget  = chk - p5.idx;
            break;
         }
      }
      if(targetReached) return false;
   }

   out.bullish = bullish;
   out.p1=p1.price; out.p2=p2.price; out.p3=p3.price; out.p4=p4.price; out.p5=p5.price;
   out.t1=p1.time;  out.t2=p2.time;  out.t3=p3.time;  out.t4=p4.time;  out.t5=p5.time;
   out.slope13 = slope13; out.slope24 = slope24;
   out.age = (n-1) - p5.idx;
   out.valid = true;
   return true;
}

//+------------------------------------------------------------------+
void CleanPivots(PivotPoint &src[], PivotPoint &dst[])
{
   ArrayResize(dst, 0, 32);
   for(int i=0; i<ArraySize(src); i++)
   {
      int sz = ArraySize(dst);
      if(sz>0 && dst[sz-1].type == src[i].type)
      {
         if(src[i].type==1)
         {
            if(src[i].price > dst[sz-1].price) dst[sz-1] = src[i];
         }
         else
         {
            if(src[i].price < dst[sz-1].price) dst[sz-1] = src[i];
         }
      }
      else
      {
         ArrayResize(dst, sz+1, 32);
         dst[sz] = src[i];
      }
   }
}

//+------------------------------------------------------------------+
void FireAlert(const WolfePattern &p)
{
   string dir = p.bullish ? "BULLISH WOLFE WAVE (BUY)" : "BEARISH WOLFE WAVE (SELL)";
   string msg = InpAlertTitle + ": " + p.symbol + " " + dir + " on " + p.tfName;

   if(InpPopupAlert) Alert(msg);
   if(InpSoundAlert) PlaySound(InpSoundFile);
   if(InpEmailAlert) SendMail(InpAlertTitle, msg);
   if(InpPushAlert)  SendNotification(msg);
}

//+------------------------------------------------------------------+
void DrawDashboard()
{
   int sub = ChartWindowFind();
   if(sub < 0) sub = 0;

   // Base layout scaled
   int baseColX[7] = {5,90,170,260,400,460,535};
   int baseColW[7] = {80,75,85,135,55,70,80};
   int baseRowH    = 16;
   int baseRowStep = 18;
   int baseHeaderY = 4;
   int baseFirstY  = 22;

   int colX[7], colW[7];
   for(int c=0;c<7;c++)
   {
      colX[c] = (int)MathRound(baseColX[c] * g_dashScale);
      colW[c] = (int)MathRound(baseColW[c] * g_dashScale);
   }
   int rowH    = (int)MathRound(baseRowH    * g_dashScale);
   int rowStep = (int)MathRound(baseRowStep * g_dashScale);
   int headerY = (int)MathRound(baseHeaderY * g_dashScale);
   int firstY  = (int)MathRound(baseFirstY  * g_dashScale);

   // Headers - always ensure they exist (so they appear together with pattern rows)
   {
      string headers[7] = {"Symbol","Timeframe","Direction","Pattern","Age","Avg TTT","Chart"};
      for(int c=0;c<7;c++)
         CreateButton("WWD_HDR_"+IntegerToString(c), headers[c], colX[c], headerY, colW[c], rowH,
                      clrWhite, clrDimGray, sub, g_fontSize, true, false);
      g_headerDrawn = true;
   }

   BuildSortedIndex();

   int rows = MathMin(g_sortedTotal, g_visibleRows);

   for(int r=0; r<rows; r++)
   {
      WolfePattern p = g_patterns[g_sortedIdx[r]];
      int y = firstY + r*rowStep;

      color bg     = p.bullish ? InpBullColor : InpBearColor;
      color txtClr = p.bullish ? clrBlack : clrWhite;
      string dirTxt = p.bullish ? "Bullish" : "Bearish";
      string patTxt = p.bullish ? "Bullish Wolfe" : "Bearish Wolfe";
      string avgTtt = GetAvgTTTText(p.symbol, p.tfName);

      string texts[7];
      texts[0] = p.symbol;
      texts[1] = p.tfName;
      texts[2] = dirTxt;
      texts[3] = patTxt;
      texts[4] = IntegerToString(p.age);
      texts[5] = avgTtt;
      texts[6] = "Open";

      color bgs[7]  = {bg, bg, bg, bg, bg, bg, clrDodgerBlue};
      color txts[7] = {txtClr, txtClr, txtClr, txtClr, txtClr, txtClr, clrWhite};
      bool  click[7]= {false, false, false, false, false, false, true};

      string rowId = IntegerToString(r);
      for(int c=0; c<7; c++)
      {
         // Only touch the object if something actually changed
         bool needUpdate = (texts[c] != g_lastText[r][c] ||
                            bgs[c]   != g_lastBg[r][c]   ||
                            txts[c]  != g_lastTxt[r][c]);

         if(needUpdate || ObjectFind(0, "WWD_ROW_"+rowId+"_"+IntegerToString(c)) < 0)
         {
            CreateButton("WWD_ROW_"+rowId+"_"+IntegerToString(c),
                         texts[c], colX[c], y, colW[c], rowH,
                         txts[c], bgs[c], sub, g_fontSize, (c==6), click[c]);
            g_lastText[r][c] = texts[c];
            g_lastBg[r][c]   = bgs[c];
            g_lastTxt[r][c]  = txts[c];
         }
      }
   }

   // Clear trailing rows that are no longer needed
   if(g_lastRenderedRows > rows)
   {
      for(int r=rows; r<g_lastRenderedRows; r++)
      {
         string rowId = IntegerToString(r);
         for(int c=0;c<7;c++)
         {
            string name = "WWD_ROW_"+rowId+"_"+IntegerToString(c);
            if(ObjectFind(0, name) >= 0)
            {
               ObjectSetString(0, name, OBJPROP_TEXT, "");
               g_lastText[r][c] = "";
            }
         }
      }
   }
   g_lastRenderedRows = rows;

   ChartRedraw(0);
}

//+------------------------------------------------------------------+
void BuildSortedIndex()
{
   int total = ArraySize(g_patterns);
   ArrayResize(g_sortedIdx, total, 32);

   int cnt = 0;
   for(int i=0;i<total;i++)
      if(g_patterns[i].valid) { g_sortedIdx[cnt] = i; cnt++; }

   ArrayResize(g_sortedIdx, cnt);
   g_sortedTotal = cnt;

   // Insertion sort by age (freshest first)
   for(int a=1; a<cnt; a++)
   {
      int key    = g_sortedIdx[a];
      int keyAge = g_patterns[key].age;
      int b      = a-1;
      while(b>=0 && g_patterns[g_sortedIdx[b]].age > keyAge)
      {
         g_sortedIdx[b+1] = g_sortedIdx[b];
         b--;
      }
      g_sortedIdx[b+1] = key;
   }
}

//+------------------------------------------------------------------+
void CreateButton(string name, string text, int x, int y, int w, int h,
                   color txtClr, color bgClr, int sub, int fontSize, bool bold, bool clickable)
{
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_BUTTON, sub, 0, 0);

   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString (0, name, OBJPROP_TEXT, text);
   ObjectSetString (0, name, OBJPROP_FONT, bold ? "Arial Bold" : "Arial");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, name, OBJPROP_COLOR, txtClr);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bgClr);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, clrBlack);
   ObjectSetInteger(0, name, OBJPROP_STATE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, clickable ? 1 : 0);
}

//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id != CHARTEVENT_OBJECT_CLICK) return;

   if(StringFind(sparam, "WWD_HDR_") == 0)
   {
      ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
      return;
   }

   if(StringFind(sparam, "WWD_ROW_") != 0) return;

   string tmp = StringSubstr(sparam, 8);
   int us = StringFind(tmp, "_");
   if(us < 0) return;
   int rowNum = (int)StringToInteger(StringSubstr(tmp, 0, us));
   int colNum = (int)StringToInteger(StringSubstr(tmp, us+1));

   ObjectSetInteger(0, sparam, OBJPROP_STATE, false);

   if(colNum != 6) return;   // only "Open" column is actionable

   if(rowNum < 0 || rowNum >= g_sortedTotal) return;
   WolfePattern p = g_patterns[g_sortedIdx[rowNum]];

   ResetLastError();
   long chartId = ChartOpen(p.symbol, p.tf);
   if(chartId == 0)
   {
      Print("WolfeWaveDashboard: could not open chart for ", p.symbol, " ", p.tfName,
            " (error ", GetLastError(), ")");
      return;
   }
   ChartSetInteger(chartId, CHART_BRING_TO_TOP, true);

   // Wait briefly for history sync (max ~2 seconds)
   ulong waitStart = GetTickCount();
   while(!SeriesInfoInteger(p.symbol, p.tf, SERIES_SYNCHRONIZED) && GetTickCount()-waitStart < 2000)
      Sleep(40);

   DrawPatternOnChart(chartId, p);

   int shift1 = iBarShift(p.symbol, p.tf, p.t1, false);
   if(shift1 >= 0)
   {
      ChartSetInteger(chartId, CHART_AUTOSCROLL, false);
      ChartSetInteger(chartId, CHART_FIRST_VISIBLE_BAR, shift1 + 20);
   }

   ChartRedraw(chartId);
}

//+------------------------------------------------------------------+
void DrawPatternOnChart(long chartId, const WolfePattern &p)
{
   ObjectsDeleteAll(chartId, "WWD_PAT_");
   color mainColor = p.bullish ? InpBullColor : InpBearColor;

   CreateTrend(chartId, "WWD_PAT_L13", p.t1, p.p1, p.t3, p.p3, InpLineColor, STYLE_SOLID, false);
   CreateTrend(chartId, "WWD_PAT_L24", p.t2, p.p2, p.t4, p.p4, InpLineColor, STYLE_SOLID, false);

   ObjectCreate(chartId, "WWD_PAT_TRI", OBJ_TRIANGLE, 0, p.t1, p.p1, p.t3, p.p3, p.t5, p.p5);
   ObjectSetInteger(chartId, "WWD_PAT_TRI", OBJPROP_COLOR, InpFillColor);
   ObjectSetInteger(chartId, "WWD_PAT_TRI", OBJPROP_FILL, true);
   ObjectSetInteger(chartId, "WWD_PAT_TRI", OBJPROP_BACK, true);
   ObjectSetInteger(chartId, "WWD_PAT_TRI", OBJPROP_SELECTABLE, false);

   if(InpShowLabels)
   {
      CreatePointLabel(chartId, "WWD_PAT_T1", p.t1, p.p1, "1", mainColor);
      CreatePointLabel(chartId, "WWD_PAT_T2", p.t2, p.p2, "2", mainColor);
      CreatePointLabel(chartId, "WWD_PAT_T3", p.t3, p.p3, "3", mainColor);
      CreatePointLabel(chartId, "WWD_PAT_T4", p.t4, p.p4, "4", mainColor);
      CreatePointLabel(chartId, "WWD_PAT_T5", p.t5, p.p5, "5", mainColor);
   }

   if(InpShowArrows)
   {
      string arrowName = "WWD_PAT_ARROW";
      ObjectCreate(chartId, arrowName, OBJ_ARROW, 0, p.t5, p.p5);
      ObjectSetInteger(chartId, arrowName, OBJPROP_ARROWCODE, p.bullish ? 233 : 234);
      ObjectSetInteger(chartId, arrowName, OBJPROP_COLOR, mainColor);
      ObjectSetInteger(chartId, arrowName, OBJPROP_WIDTH, 4);

      CreatePointLabel(chartId, "WWD_PAT_ENTRYTXT", p.t5, p.p5,
                       p.bullish ? "BUY ENTRY" : "SELL ENTRY", mainColor);
   }

   if(InpShowTargetLine)
   {
      CreateTrend(chartId, "WWD_PAT_TARGET", p.t1, p.p1, p.t4, p.p4, InpTargetColor, STYLE_DASH, true);
   }

   ChartRedraw(chartId);
}

void CreateTrend(long chartId, string name, datetime t1, double p1, datetime t2, double p2, color clr, int style, bool rayRight)
{
   if(ObjectFind(chartId, name) >= 0) ObjectDelete(chartId, name);
   ObjectCreate(chartId, name, OBJ_TREND, 0, t1, p1, t2, p2);
   ObjectSetInteger(chartId, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(chartId, name, OBJPROP_STYLE, style);
   ObjectSetInteger(chartId, name, OBJPROP_WIDTH, 2);
   ObjectSetInteger(chartId, name, OBJPROP_RAY_RIGHT, rayRight);
   ObjectSetInteger(chartId, name, OBJPROP_RAY_LEFT, false);
   ObjectSetInteger(chartId, name, OBJPROP_SELECTABLE, false);
}

void CreatePointLabel(long chartId, string name, datetime t, double price, string text, color clr)
{
   if(ObjectFind(chartId, name) >= 0) ObjectDelete(chartId, name);
   ObjectCreate(chartId, name, OBJ_TEXT, 0, t, price);
   ObjectSetString(chartId, name, OBJPROP_TEXT, text);
   ObjectSetInteger(chartId, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(chartId, name, OBJPROP_FONTSIZE, 9);
   ObjectSetInteger(chartId, name, OBJPROP_ANCHOR, ANCHOR_LOWER);
   ObjectSetInteger(chartId, name, OBJPROP_SELECTABLE, false);
}
//+------------------------------------------------------------------+