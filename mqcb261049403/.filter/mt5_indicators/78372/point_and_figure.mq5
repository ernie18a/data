//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                           Point and Figure.mq5   |
//|                                        Copyright 2026, zorbacc   |
//|                                           https://www.mql5.com   |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, zorbacc"
#property link        "https://www.mql5.com/en/users/zorbacc"
#property version     "4.10"
#property description "Point & Figure: lime squares = X (rising), red squares = O (falling), navy border."
#property description "Navy panel in the main window: signal, trade plan, entry conditions, P&F structure."
#property description "Works on any symbol / timeframe. Signal buffer: +1 BUY, -1 SELL, 0 none."
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_NONE
#property indicator_label1  "PF Signal"

//--- enumerations
enum ENUM_BOX_MODE
  {
   BOX_FIXED_POINTS = 0,   // Fixed (points)
   BOX_ATR          = 1    // ATR based (adapts to symbol / timeframe)
  };

enum ENUM_PF_SOURCE
  {
   PF_CLOSE    = 0,        // Close price
   PF_HIGHLOW  = 1         // High / Low
  };

enum ENUM_PF_PATTERN
  {
   PAT_NONE = 0,
   PAT_DTB,                // Double top breakout
   PAT_DBB,                // Double bottom breakdown
   PAT_TTB,                // Triple top breakout
   PAT_TBB,                // Triple bottom breakdown
   PAT_BULL_CAT,           // Bullish catapult
   PAT_BEAR_CAT,           // Bearish catapult
   PAT_TRIANGLE            // Triangle (consolidation)
  };

enum ENUM_PANEL_POS
  {
   PNL_LEFT_TOP     = 0,   // Top left
   PNL_RIGHT_TOP    = 1,   // Top right
   PNL_LEFT_BOTTOM  = 2,   // Bottom left
   PNL_RIGHT_BOTTOM = 3    // Bottom right
  };

enum ENUM_PANEL_MODE
  {
   PMODE_FULL    = 0,      // Full
   PMODE_COMPACT = 1,      // Compact
   PMODE_MIN     = 2       // Minimal
  };

enum ENUM_SECTION_CLR
  {
   SC_SKY     = 0,   // Sky blue
   SC_GOLD    = 1,   // Gold
   SC_ORANGE  = 2,   // Orange
   SC_LIME    = 3,   // Lime green
   SC_AQUA    = 4,   // Aqua
   SC_PINK    = 5,   // Pink
   SC_MAGENTA = 6,   // Magenta
   SC_VIOLET  = 7,   // Violet
   SC_SILVER  = 8,   // Silver
   SC_WHITE   = 9    // White
  };

//--- inputs
input group "=== Point & Figure ==="
input ENUM_BOX_MODE   InpBoxMode      = BOX_ATR;          // Box size mode
input int             InpBoxPoints    = 50;               // Box size (points) - fixed mode
input int             InpATRPeriod    = 14;               // ATR period - ATR mode
input ENUM_TIMEFRAMES InpATRTf        = PERIOD_CURRENT;   // ATR timeframe - ATR mode
input double          InpATRMult      = 1.0;              // ATR multiplier - ATR mode
input int             InpReversal     = 3;                // Reversal (number of boxes)
input ENUM_PF_SOURCE  InpSource       = PF_CLOSE;         // Price source
input int             InpHistoryBars  = 3000;             // Max. history bars used
input bool            InpClosedOnly   = true;             // Closed bars only (stable signals)

input group "=== Display (P&F window) ==="
input color           InpColorX       = clrLime;          // X squares color (rising)
input color           InpColorO       = clrRed;           // O squares color (falling)
input int             InpMaxColumns   = 40;               // Max. columns displayed
input int             InpColWidth     = 3;                // Column width (chart bars)
input int             InpLeftShift    = 8;                // Shift to the left (bars) from the last bar
input double          InpGapPct       = 20.0;             // Gap between squares (% of box)
input bool            InpShowBorder   = true;             // Border around squares
input color           InpBorderColor  = clrNavy;          // Border color
input int             InpBorderWidth  = 2;                // Border width (pixels, reduced automatically in small windows)
input int             InpMaxObjects   = 5000;             // Object limit (squares + borders)
input int             InpWindowHeight = 0;                // P&F window height (pixels), 0 = leave as is
input bool            InpShowPrice    = true;             // Current price line

input group "=== Info panel (main window) ==="
input bool            InpShowPanel      = true;           // Show panel
input ENUM_PANEL_POS  InpPanelPos       = PNL_LEFT_TOP;   // Panel position
input ENUM_PANEL_MODE InpPanelMode      = PMODE_FULL;     // Initial mode (panel button: Full/Compact/Minimal)
input int             InpPanelX         = 12;             // Horizontal margin (px)
input int             InpPanelY         = 28;             // Vertical margin (px)
input color           InpPanelBg        = clrNavy;        // Panel background color
input ENUM_SECTION_CLR InpSectionColor  = SC_SKY;         // Section title color
input int             InpPanelRefreshMs = 250;            // Panel refresh (ms)
input double          InpPanelScale     = 1.0;            // Panel size (1.0 = normal, 1.5 = +50%, 2.0 = double)
input double          InpTextScale      = 1.0;            // Text size (1.0 = normal, 1.3 = +30%, 1.6 = +60%)

input group "=== Entry signals ==="
input bool            InpRequireHL    = true;             // Filter: higher low (BUY) / lower high (SELL)
input bool            InpOnlyFlips    = true;             // Signal only when direction changes
input double          InpRR           = 1.5;              // Risk/Reward ratio for TP
input int             InpSLBuffer     = 0;                // SL buffer (points), 0 = auto (20% of box)
input bool            InpShowPatterns = true;             // Show P&F pattern names (P&F window)
input color           InpPatternColor = clrWhite;         // Pattern text color

input group "=== Risk management (panel + alerts) ==="
input double          InpRiskPct        = 1.0;            // Risk per trade (% of balance) for lot size
input double          InpMaxRiskPips    = 0.0;            // Warn: SL larger than (pips), 0 = auto (6 boxes)
input double          InpMaxChasePips   = 0.0;            // Warn: price ran past breakout by (pips), 0 = auto (1 box)
input double          InpMaxSpreadPips  = 0.0;            // Warn: spread larger than (pips), 0 = auto (0.3 box)

input group "=== Filters for cleaner signals ==="
input bool            InpUseTrendMA   = true;             // Trend filter: BUY only above EMA, SELL only below EMA
input int             InpMAPeriod     = 200;              // EMA period (on current timeframe)
input bool            InpUseADX       = true;             // ADX filter: ignore sideways market
input int             InpADXPeriod    = 14;               // ADX period
input double          InpADXMin       = 20.0;             // Minimum ADX for a signal
input bool            InpUseSession   = true;             // Session filter (server time)
input int             InpStartHour    = 9;                // Start hour (server time)
input int             InpEndHour      = 21;               // End hour (server time)

input group "=== Support / Resistance ==="
input int             InpSRLookback   = 40;               // Number of columns analysed
input bool            InpShowSRLines  = true;             // Draw R1/R2/S1/S2 lines + labels on the MAIN chart
input color           InpResistColor  = clrRed;           // Resistance line color
input color           InpSupportColor = C'0,150,60';      // Support line color
input color           InpResistLabelBg  = C'200,30,30';   // Resistance label background (red)
input color           InpSupportLabelBg = C'0,150,60';    // Support label background (green)
input color           InpSRLabelText    = clrWhite;       // Label text color
input int             InpSRLineWidth  = 3;                // Line width (1-5)
input int             InpSRLabelSize  = 10;               // Label font size
input int             InpSRLabelRight = 8;                // Label distance from the right edge (px)

input group "=== Alerts ==="
input bool            InpAlertSignals  = true;            // Alert on BUY/SELL signal
input bool            InpAlertPatterns = false;           // Alert on pattern
input bool            InpAlertColumn   = false;           // Alert on new column (X/O)
input bool            InpAlertPopup    = true;            // Popup window
input bool            InpAlertSound    = false;           // Sound
input string          InpSoundFile     = "alert.wav";     // Sound file
input bool            InpAlertPush     = false;           // Push notification (mobile)
input bool            InpAlertEmail    = false;           // E-mail

// section title color chosen from the text list
color SectionColor()
  {
   switch(InpSectionColor)
     {
      case SC_SKY:     return C'80,210,255';
      case SC_GOLD:    return C'255,210,64';
      case SC_ORANGE:  return C'255,150,50';
      case SC_LIME:    return C'120,235,90';
      case SC_AQUA:    return C'0,230,230';
      case SC_PINK:    return C'255,140,190';
      case SC_MAGENTA: return C'255,80,255';
      case SC_VIOLET:  return C'185,140,255';
      case SC_SILVER:  return C'200,200,210';
      case SC_WHITE:   return clrWhite;
     }
   return C'80,210,255';
  }

//+------------------------------------------------------------------+
//| Constants / structures / global variables                        |
//+------------------------------------------------------------------+
#define PREFIX "PFB_"        // objects in the P&F window
#define PNL    "PFP_"        // panel objects (main window)
#define SRL    "PFSR_"       // support/resistance lines + labels (main chart)

// reasons why a breakout does not become a signal
#define BLK_HL    1
#define BLK_EMA   2
#define BLK_ADX   4
#define BLK_SES   8
#define BLK_FLIP  16

// panel size (logical pixels at 96 DPI)
#define P_W       470
#define P_H_FULL  420
#define P_H_COMP  234
#define P_H_MIN   82
#define P_X1      12
#define P_X2      242
#define P_CW      216

enum PV_SLOT
  {
   PV_HDR = 0, PV_BANNER, PV_STATUS, PV_VERDICT, PV_SUB,
   PV_ENTRY, PV_SL, PV_TP, PV_RR, PV_LOT,
   PV_EMA, PV_ADX, PV_SES, PV_SPR, PV_ATR,
   PV_BOX, PV_COL, PV_EXT, PV_REV, PV_BOB, PV_BOS, PV_STR,
   PV_R2, PV_R1, PV_S1, PV_S2,
   PV_H0, PV_H1, PV_H2, PV_HR0, PV_HR1, PV_HR2,
   PV_FL, PV_FR,
   PV_COUNT
  };

struct PFCol
  {
   int      dir;     // +1 = X, -1 = O
   int      top;     // top box level
   int      bot;     // bottom box level
   int      sig;     // raw breakout: +1 buy, -1 sell, 0 none
   int      eff;     // effective ENTRY signal (after filters)
   int      pat;     // pattern (ENUM_PF_PATTERN)
   int      blk;     // filters that blocked the breakout (BLK_*)
   int      trig;    // index of the bar where the breakout happened (-1 = none)
   int      b0;      // index of the bar where the column started
   datetime t0;      // time of the bar where the column started
   datetime tTrig;   // time of the breakout bar
   double   pTrig;   // price level of the breakout
  };

PFCol    g_cols[];
int      g_n          = 0;
int      g_boxPts     = 50;
int      g_boxAuto    = 0;       // last ATR-derived box (hysteresis)
double   g_pip        = 0.0001;
int      g_hATR       = INVALID_HANDLE;   // ATR for the box (ATR mode)
int      g_hATRc      = INVALID_HANDLE;   // ATR on the current timeframe (informative)
int      g_hMA        = INVALID_HANDLE;
int      g_hADX       = INVALID_HANDLE;
double   g_sigBuf[];
double   g_maBuf[];
double   g_adxBuf[];
int      g_fOff       = 0;      // index (non-series) of the first element of g_maBuf / g_adxBuf
double   g_emaV       = 0.0;    // informative values for the panel
double   g_adxV       = 0.0;
double   g_atrV       = 0.0;

// sanitized inputs
int      g_rev        = 3;
int      g_W          = 3;
int      g_shift      = 8;
int      g_maxCols    = 40;
int      g_maxObj     = 5000;
int      g_hist       = 3000;
double   g_gap        = 20.0;
int      g_maP        = 200;
int      g_adxP       = 14;
int      g_srLook     = 40;

int      g_win        = -1;     // separate window of the indicator
string   g_lastSig    = "";
bool     g_needRecalc = true;
int      g_lastTotal  = 0;
datetime g_lastBarT   = 0;
int      g_drawn      = 0;      // drawn columns
int      g_subH       = 0;      // height (px) of the P&F window at the last redraw
bool     g_hSet       = false;  // window height already applied
double   g_lastPrice  = 0.0;
double   g_scLo       = 0.0;    // fixed vertical scale of the P&F window
double   g_scHi       = 0.0;
double   g_res[];
double   g_sup[];
int      g_nr         = 0;
int      g_ns         = 0;

// alerts
bool     g_firstRun   = true;
string   g_alSig      = "";
string   g_alPat      = "";
string   g_alCol      = "";
string   g_srKey      = "";     // last drawn S/R state (avoids useless object updates)

// panel
bool     g_panelBuilt = false;
bool     g_chartDirty = false;
int      g_pmode      = 0;
double   g_scale      = 1.0;
int      g_pcount     = 0;
string   g_pn[];
string   g_pt[];
color    g_pc[];
int      g_pl[];
int      g_pk[];
int      g_px[];
int      g_py[];
int      g_pw[];
int      g_ph[];
int      g_v[PV_COUNT];
int      g_bg         = -1;
int      g_btn        = -1;
int      g_cw         = 0;
int      g_chh        = 0;
uint     g_lastUiMs   = 0;
string   g_fT         = "Arial Bold";
string   g_fB         = "Arial Bold";
string   g_up, g_dn, g_dot, g_dia, g_mid;

//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, g_sigBuf, INDICATOR_DATA);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetInteger(0, PLOT_SHOW_DATA, false);   // hide the 0.00000 value in the separate window
   IndicatorSetString(INDICATOR_SHORTNAME, " ");   // no text in the separate window
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   g_pip = (_Digits == 3 || _Digits == 5) ? _Point * 10.0 : _Point;
   if(g_pip <= 0.0)
      g_pip = _Point;

   //--- sanitized inputs (protect against invalid values)
   g_rev     = MathMax(1, InpReversal);
   g_W       = (int)MathMax(1, MathMin(20, InpColWidth));
   g_shift   = (int)MathMax(0, MathMin(500, InpLeftShift));
   g_maxCols = (int)MathMax(1, MathMin(500, InpMaxColumns));
   g_maxObj  = (int)MathMax(100, MathMin(50000, InpMaxObjects));
   g_hist    = MathMax(50, InpHistoryBars);
   g_gap     = MathMax(0.0, MathMin(80.0, InpGapPct));
   g_maP     = MathMax(2, InpMAPeriod);
   g_adxP    = MathMax(2, InpADXPeriod);
   g_srLook  = MathMax(2, InpSRLookback);

   double dpi = (double)TerminalInfoInteger(TERMINAL_SCREEN_DPI);
   g_scale = (dpi >= 96.0) ? MathMin(3.0, dpi / 96.0) : 1.0;
   g_scale *= MathMax(0.5, MathMin(4.0, InpPanelScale));   // panel size (input)

   g_up  = ShortToString(0x25B2);
   g_dn  = ShortToString(0x25BC);
   g_dot = ShortToString(0x25CF);
   g_dia = "!";
   g_mid = ShortToString(0x00B7);

   if(InpBoxMode == BOX_ATR)
     {
      g_hATR = iATR(_Symbol, InpATRTf, MathMax(2, InpATRPeriod));
      if(g_hATR == INVALID_HANDLE)
         return(INIT_FAILED);
     }
   if(InpUseTrendMA)
     {
      g_hMA = iMA(_Symbol, _Period, g_maP, 0, MODE_EMA, PRICE_CLOSE);
      if(g_hMA == INVALID_HANDLE)
         return(INIT_FAILED);
     }
   if(InpUseADX)
     {
      g_hADX = iADX(_Symbol, _Period, g_adxP);
      if(g_hADX == INVALID_HANDLE)
         return(INIT_FAILED);
     }
   g_hATRc = iATR(_Symbol, _Period, 14);   // informative; if it fails, the panel shows "-"

   g_boxPts      = MathMax(1, InpBoxPoints);
   g_boxAuto     = 0;
   g_firstRun    = true;
   g_needRecalc  = true;
   g_lastTotal   = 0;
   g_lastBarT    = 0;
   g_lastSig     = "";
   g_win         = -1;
   g_panelBuilt  = false;
   g_pmode       = (int)InpPanelMode;
   g_lastPrice   = 0.0;
   g_scLo        = 0.0;
   g_scHi        = 0.0;
   g_subH        = 0;
   g_hSet        = false;
   g_n           = 0;
   g_nr          = 0;
   g_ns          = 0;

   // clean up objects left behind by previous versions
   g_srKey = "";
   ObjectsDeleteAll(0, PREFIX);
   ObjectsDeleteAll(0, PNL);
   ObjectsDeleteAll(0, SRL);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(g_hATR != INVALID_HANDLE)
      IndicatorRelease(g_hATR);
   if(g_hATRc != INVALID_HANDLE)
      IndicatorRelease(g_hATRc);
   if(g_hMA != INVALID_HANDLE)
      IndicatorRelease(g_hMA);
   if(g_hADX != INVALID_HANDLE)
      IndicatorRelease(g_hADX);
   ObjectsDeleteAll(0, PREFIX);
   ObjectsDeleteAll(0, PNL);
   ObjectsDeleteAll(0, SRL);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Utilities                                                        |
//+------------------------------------------------------------------+
int Sc(const int v)
  {
   return (int)MathRound(v * g_scale);
  }

// panel font size, multiplied by InpTextScale
int Fs(const int size)
  {
   return (int)MathMax(6, MathRound(size * MathMax(0.5, MathMin(3.0, InpTextScale))));
  }

color Mix(const color a, const color b, const double t)
  {
   int ra = (int)a & 0xFF, ga = ((int)a >> 8) & 0xFF, ba = ((int)a >> 16) & 0xFF;
   int rb = (int)b & 0xFF, gb = ((int)b >> 8) & 0xFF, bb = ((int)b >> 16) & 0xFF;
   int r  = (int)MathRound(ra + (rb - ra) * t);
   int g  = (int)MathRound(ga + (gb - ga) * t);
   int bl = (int)MathRound(ba + (bb - ba) * t);
   return (color)(r | (g << 8) | (bl << 16));
  }

string Px(const double p)
  {
   return DoubleToString(p, _Digits);
  }

string SP(const double pips)
  {
   double v = MathRound(pips * 10.0) / 10.0;
   string s = (v >= 0.0) ? "+" : "-";
   return s + DoubleToString(MathAbs(v), 1) + "p";
  }

string TStr(const datetime t)
  {
   MqlDateTime d;
   TimeToStruct(t, d);
   return StringFormat("%02d.%02d %02d:%02d", d.day, d.mon, d.hour, d.min);
  }

string TfName()
  {
   string s = EnumToString((ENUM_TIMEFRAMES)_Period);
   return StringSubstr(s, 7);   // strips "PERIOD_"
  }

// start == end means "always in session"
// the hour filter only makes sense on intraday timeframes (bar open hour); on D1/W1/MN1 it would block everything
bool SessionApplies()
  {
   return (InpUseSession && PeriodSeconds() <= 14400);
  }

bool InSession(const int hour)
  {
   if(InpStartHour == InpEndHour)
      return true;
   if(InpStartHour < InpEndHour)
      return (hour >= InpStartHour && hour < InpEndHour);
   return (hour >= InpStartHour || hour < InpEndHour);
  }

int LotDigits()
  {
   double st = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   int    d  = 0;
   if(st <= 0.0)
      return 2;
   while(d < 8 && MathAbs(st - MathRound(st)) > 1e-8)
     {
      st *= 10.0;
      d++;
     }
   return d;
  }

string AgeText(const int bars)
  {
   if(bars <= 0)
      return "on current bar";
   long   sec = (long)bars * (long)PeriodSeconds();
   string d;
   if(sec < 7200)
      d = IntegerToString(sec / 60) + " min";
   else
      if(sec < 172800)
         d = DoubleToString((double)sec / 3600.0, 1) + " h";
      else
         d = DoubleToString((double)sec / 86400.0, 1) + " d";
   return IntegerToString(bars) + (bars == 1 ? " bar" : " bars") + " ago (" + d + ")";
  }

//--- thresholds: an explicit input wins, otherwise they scale with the box size
double BoxPips()
  {
   return g_boxPts * _Point / g_pip;
  }

double MaxRiskP()
  {
   return (InpMaxRiskPips > 0.0) ? InpMaxRiskPips : 6.0 * BoxPips();
  }

double MaxChaseP()
  {
   return (InpMaxChasePips > 0.0) ? InpMaxChasePips : 1.0 * BoxPips();
  }

double MaxSpreadP()
  {
   return (InpMaxSpreadPips > 0.0) ? InpMaxSpreadPips : 0.3 * BoxPips();
  }

double SLBufferPrice()
  {
   int pts = (InpSLBuffer > 0) ? InpSLBuffer : (int)MathMax(1, MathRound(0.2 * g_boxPts));
   return pts * _Point;
  }

//+------------------------------------------------------------------+
//| Box level for a price (computed in whole points)                 |
//+------------------------------------------------------------------+
int Level(const double price)
  {
   long pts = (long)MathRound(price / _Point);
   return (int)MathFloor((double)pts / (double)g_boxPts);
  }

// rounds a raw ATR-based box to a "nice" value (1, 1.5, 2, 2.5, 3, 4, 5, 6, 8, 10 x 10^k pips)
int NiceBoxPts(const double rawPts)
  {
   double pipPts = g_pip / _Point;
   double pips   = rawPts / pipPts;
   if(pips <= 0.0)
      return 1;
   double m[10] = {1.0, 1.5, 2.0, 2.5, 3.0, 4.0, 5.0, 6.0, 8.0, 10.0};
   double base  = MathPow(10.0, MathFloor(MathLog10(pips)));
   double mant  = pips / base;
   int    best  = 0;
   double bd    = DBL_MAX;
   for(int i = 0; i < 10; i++)
     {
      double d = MathAbs(MathLog(mant / m[i]));
      if(d < bd)
        {
         bd   = d;
         best = i;
        }
     }
   return (int)MathMax(1, MathRound(m[best] * base * pipPts));
  }

//+------------------------------------------------------------------+
void AddCol(const int dir, const int bot, const int top, const int bar, const datetime t)
  {
   ArrayResize(g_cols, g_n + 1, 2048);
   g_cols[g_n].dir   = dir;
   g_cols[g_n].bot   = bot;
   g_cols[g_n].top   = top;
   g_cols[g_n].sig   = 0;
   g_cols[g_n].eff   = 0;
   g_cols[g_n].pat   = PAT_NONE;
   g_cols[g_n].blk   = 0;
   g_cols[g_n].trig  = -1;
   g_cols[g_n].b0    = bar;
   g_cols[g_n].t0    = t;
   g_cols[g_n].tTrig = 0;
   g_cols[g_n].pTrig = 0.0;
   g_n++;
  }

//+------------------------------------------------------------------+
//| Automatic calculation of the Point & Figure columns              |
//+------------------------------------------------------------------+
void BuildPF(const datetime &time[], const double &high[], const double &low[],
             const double &close[], const int total, const int startRaw)
  {
   g_n = 0;
   ArrayResize(g_cols, 0, 2048);

   int lastBar = InpClosedOnly ? total - 2 : total - 1;
   int start   = startRaw;

   // Anchoring: the history start only moves at the beginning of a day (not on every bar),
   // so the P&F structure and the signals stay stable during the day.
   if(start > 0)
     {
      int lim = MathMin(lastBar - 40, start + 1500);
      for(int s = start; s <= lim; s++)
         if((long)time[s] / 86400 != (long)time[s - 1] / 86400)
           {
            start = s;
            break;
           }
     }
   if(lastBar <= start)
      return;

   int rev  = g_rev;
   int base = Level(close[start]);

   for(int i = start + 1; i <= lastBar; i++)
     {
      double h = (InpSource == PF_HIGHLOW) ? high[i] : close[i];
      double l = (InpSource == PF_HIGHLOW) ? low[i]  : close[i];
      int hL = Level(h);
      int lL = Level(l);

      if(g_n == 0)
        {
         if(hL > base)
            AddCol(1, base, hL, i, time[i]);
         else
            if(lL < base)
               AddCol(-1, lL, base, i, time[i]);
         continue;
        }

      int j = g_n - 1;
      if(g_cols[j].dir == 1)
        {
         if(hL > g_cols[j].top)
            g_cols[j].top = hL;                                   // X extension
         else
            if(lL <= g_cols[j].top - rev)
               AddCol(-1, lL, g_cols[j].top - 1, i, time[i]);     // reversal -> O
        }
      else
        {
         if(lL < g_cols[j].bot)
            g_cols[j].bot = lL;                                   // O extension
         else
            if(hL >= g_cols[j].bot + rev)
               AddCol(1, g_cols[j].bot + 1, hL, i, time[i]);      // reversal -> X
        }

      // bar on which the column first exceeds the previous column of the same type (breakout)
      j = g_n - 1;
      if(j >= 2 && g_cols[j].trig < 0)
        {
         double bp = g_boxPts * _Point;
         if(g_cols[j].dir == 1 && g_cols[j].top > g_cols[j - 2].top)
           {
            g_cols[j].trig  = i;
            g_cols[j].tTrig = time[i];
            g_cols[j].pTrig = (g_cols[j - 2].top + 1) * bp;
           }
         else
            if(g_cols[j].dir == -1 && g_cols[j].bot < g_cols[j - 2].bot)
              {
               g_cols[j].trig  = i;
               g_cols[j].tTrig = time[i];
               g_cols[j].pTrig = g_cols[j - 2].bot * bp;
              }
        }
     }
  }

//+------------------------------------------------------------------+
//| Filters (returns a mask of the filters NOT met; 0 = ok)          |
//+------------------------------------------------------------------+
int FilterMask(const int dir, const int bar, const datetime &time[], const double &close[], const int total)
  {
   if(bar < 0 || bar >= total)
      return (BLK_HL | BLK_EMA | BLK_ADX | BLK_SES);

   int m  = 0;
   int ix = bar - g_fOff;

   if(InpUseTrendMA && g_hMA != INVALID_HANDLE)
     {
      if(ix < 0 || ix >= ArraySize(g_maBuf))
         m |= BLK_EMA;
      else
        {
         if(dir > 0 && !(close[bar] > g_maBuf[ix]))
            m |= BLK_EMA;
         if(dir < 0 && !(close[bar] < g_maBuf[ix]))
            m |= BLK_EMA;
        }
     }
   if(InpUseADX && g_hADX != INVALID_HANDLE)
     {
      if(ix < 0 || ix >= ArraySize(g_adxBuf))
         m |= BLK_ADX;
      else
         if(g_adxBuf[ix] < InpADXMin)
            m |= BLK_ADX;
     }
   if(SessionApplies())
     {
      MqlDateTime dt;
      TimeToStruct(time[bar], dt);
      if(!InSession(dt.hour))
         m |= BLK_SES;
     }
   return m;
  }

//+------------------------------------------------------------------+
//| Entry signals and classic patterns                               |
//+------------------------------------------------------------------+
void Analyze(const datetime &time[], const double &close[], const int total)
  {
   int lastSig = 0;
   for(int j = 0; j < g_n; j++)
     {
      g_cols[j].sig = 0;
      g_cols[j].eff = 0;
      g_cols[j].pat = PAT_NONE;
      g_cols[j].blk = 0;

      if(j >= 2)
        {
         if(g_cols[j].dir == 1 && g_cols[j].top > g_cols[j - 2].top)
           {
            g_cols[j].sig = 1;
            g_cols[j].pat = PAT_DTB;
            if(j >= 4 && g_cols[j - 2].top == g_cols[j - 4].top)
               g_cols[j].pat = PAT_TTB;
            // bullish catapult: after a triple top breakout, a pullback that stays
            // above the triple top level, then a new breakout
            if(g_cols[j - 2].pat == PAT_TTB && g_cols[j - 1].bot >= g_cols[j - 4].top)
               g_cols[j].pat = PAT_BULL_CAT;
           }
         else
            if(g_cols[j].dir == -1 && g_cols[j].bot < g_cols[j - 2].bot)
              {
               g_cols[j].sig = -1;
               g_cols[j].pat = PAT_DBB;
               if(j >= 4 && g_cols[j - 2].bot == g_cols[j - 4].bot)
                  g_cols[j].pat = PAT_TBB;
               if(g_cols[j - 2].pat == PAT_TBB && g_cols[j - 1].top <= g_cols[j - 4].bot)
                  g_cols[j].pat = PAT_BEAR_CAT;
              }
        }

      // triangle: lower highs + higher lows over the last 5 columns
      if(g_cols[j].pat == PAT_NONE && j >= 4)
        {
         bool tri = true;
         int  lt = INT_MAX, lb = INT_MIN;
         for(int k = j - 4; k <= j; k++)
           {
            if(g_cols[k].dir == 1)
              {
               if(g_cols[k].top >= lt) { tri = false; break; }
               lt = g_cols[k].top;
              }
            else
              {
               if(g_cols[k].bot <= lb) { tri = false; break; }
               lb = g_cols[k].bot;
              }
           }
         if(tri)
            g_cols[j].pat = PAT_TRIANGLE;
        }

      // ENTRY signal = breakout + (optional) structure filter + filters
      if(g_cols[j].sig != 0)
        {
         int sg  = g_cols[j].sig;
         int blk = 0;
         if(InpRequireHL)
           {
            bool okHL;
            if(j < 3)
               okHL = false;
            else
               if(sg == 1)
                  okHL = (g_cols[j - 1].bot > g_cols[j - 3].bot);   // pullback with a higher low
               else
                  okHL = (g_cols[j - 1].top < g_cols[j - 3].top);   // pullback with a lower high
            if(!okHL)
               blk |= BLK_HL;
         }
         blk |= FilterMask(sg, g_cols[j].trig, time, close, total);
         if(blk == 0)
           {
            if(InpOnlyFlips && sg == lastSig)
               blk = BLK_FLIP;
            else
               g_cols[j].eff = sg;
            lastSig = sg;
           }
         g_cols[j].blk = blk;
        }
     }
  }

//+------------------------------------------------------------------+
// base name (no direction) - used where BUY/SELL is already shown
string PatShort(const int p)
  {
   switch(p)
     {
      case PAT_DTB:      return "Double top breakout";
      case PAT_DBB:      return "Double bottom breakdown";
      case PAT_TTB:      return "Triple top breakout";
      case PAT_TBB:      return "Triple bottom breakdown";
      case PAT_BULL_CAT: return "Bullish catapult";
      case PAT_BEAR_CAT: return "Bearish catapult";
      case PAT_TRIANGLE: return "Triangle";
     }
   return "";
  }

// full name with the trade direction: in P&F a "bottom breakdown" is a SELL (support broken),
// a "top breakout" is a BUY (resistance broken)
string PatName(const int p)
  {
   switch(p)
     {
      case PAT_DTB:
      case PAT_TTB:
      case PAT_BULL_CAT: return PatShort(p) + " (BUY)";
      case PAT_DBB:
      case PAT_TBB:
      case PAT_BEAR_CAT: return PatShort(p) + " (SELL)";
      case PAT_TRIANGLE: return PatShort(p) + " (neutral)";
     }
   return "";
  }

void JoinAdd(string &r, const string s)
  {
   if(r != "")
      r += ", ";
   r += s;
  }

string BlkText(const int m)
  {
   string r = "";
   if((m & BLK_HL) != 0)   JoinAdd(r, "structure (higher low / lower high)");
   if((m & BLK_EMA) != 0)  JoinAdd(r, "EMA");
   if((m & BLK_ADX) != 0)  JoinAdd(r, "ADX");
   if((m & BLK_SES) != 0)  JoinAdd(r, "session");
   if((m & BLK_FLIP) != 0) JoinAdd(r, "same direction as previous signal");
   if(r == "")
      r = "-";
   return r;
  }

//+------------------------------------------------------------------+
//| Time of a chart slot (bar index); extrapolated outside history   |
//+------------------------------------------------------------------+
datetime SlotTime(const datetime &time[], const int total, const int idx)
  {
   long ps   = (long)PeriodSeconds();
   int  last = total - 1;
   if(idx < 0)
      return (datetime)((long)time[0] + (long)idx * ps);
   if(idx <= last)
      return time[idx];
   return (datetime)((long)time[last] + (long)(idx - last) * ps);
  }

// fractional slot: the fraction is measured INSIDE the bar slot, so square widths
// stay identical even when the columns cross weekends / session gaps
datetime SlotTimeF(const datetime &time[], const int total, const double idx)
  {
   double fl = MathFloor(idx);
   int    i0 = (int)fl;
   double fr = idx - fl;
   long   t  = (long)SlotTime(time, total, i0);
   if(fr > 0.0)
     {
      t += (long)MathRound(fr * (double)PeriodSeconds());
      if(i0 >= 0 && i0 < total - 1)
        {
         long tn = (long)time[i0 + 1];
         if(t >= tn)
            t = tn - 1;      // never cross into the next bar (e.g. short months on MN1)
        }
     }
   return (datetime)t;
  }

//+------------------------------------------------------------------+
//| Trade plan for the active signal                                 |
//+------------------------------------------------------------------+
double CalcLot(const double riskDist, double &riskMoney)
  {
   riskMoney = 0.0;
   double bal = AccountInfoDouble(ACCOUNT_BALANCE);
   if(bal <= 0.0 || InpRiskPct <= 0.0 || riskDist <= 0.0)
      return 0.0;
   riskMoney = bal * InpRiskPct / 100.0;
   double tv = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE_LOSS);
   if(tv <= 0.0)
      tv = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(tv <= 0.0 || ts <= 0.0)
      return 0.0;
   double lossPerLot = riskDist / ts * tv;
   if(lossPerLot <= 0.0)
      return 0.0;
   double lot = riskMoney / lossPerLot;
   double st  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double mn  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double mx  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   if(st > 0.0)
      lot = MathFloor(lot / st + 1e-9) * st;
   if(lot < mn)
      return 0.0;
   if(mx > 0.0 && lot > mx)
      lot = mx;
   return NormalizeDouble(lot, LotDigits());
  }

bool Plan(const int j, const double bid, const double ask,
          double &entry, double &sl, double &tp, double &riskP, double &lot, double &riskMoney)
  {
   if(j < 1 || j >= g_n || g_cols[j].eff == 0)
      return false;
   bool   buy = (g_cols[j].eff > 0);
   double bp  = g_boxPts * _Point;
   double buf = SLBufferPrice();
   entry = buy ? ask : bid;
   sl    = buy ? g_cols[j - 1].bot * bp - buf
               : (g_cols[j - 1].top + 1) * bp + buf;
   double risk = MathAbs(entry - sl);
   if(risk <= 0.0)
      return false;
   tp    = buy ? entry + risk * InpRR : entry - risk * InpRR;
   sl    = NormalizeDouble(sl, _Digits);
   tp    = NormalizeDouble(tp, _Digits);
   riskP = risk / g_pip;
   lot   = CalcLot(risk, riskMoney);
   return true;
  }

//+------------------------------------------------------------------+
//| Support / resistance for the panel (nearest levels to the price) |
//+------------------------------------------------------------------+
void AddUnique(double &arr[], int &n, const double v, const double tol)
  {
   for(int i = 0; i < n; i++)
      if(MathAbs(arr[i] - v) < tol * 0.5)
         return;
   ArrayResize(arr, n + 1);
   arr[n] = v;
   n++;
  }

void CalcSR(const double cur)
  {
   g_nr = 0;
   g_ns = 0;
   if(g_n < 1)
      return;

   double bp = g_boxPts * _Point;
   double r[];
   double s[];
   int nr = 0, ns = 0;
   ArrayResize(r, 0);
   ArrayResize(s, 0);

   int from = MathMax(0, g_n - g_srLook);
   for(int j = from; j < g_n; j++)
     {
      if(g_cols[j].dir == 1)
        {
         double p = (g_cols[j].top + 1) * bp;       // upper edge of the highest X
         if(p > cur)
            AddUnique(r, nr, p, bp);
        }
      else
        {
         double p = g_cols[j].bot * bp;             // lower edge of the lowest O
         if(p < cur)
            AddUnique(s, ns, p, bp);
        }
     }
   if(nr > 1) ArraySort(r);
   if(ns > 1) ArraySort(s);

   g_nr = MathMin(2, nr);
   g_ns = MathMin(2, ns);
   ArrayResize(g_res, g_nr);
   ArrayResize(g_sup, g_ns);
   for(int q = 0; q < g_nr; q++)
      g_res[q] = r[q];                  // nearest resistance first
   for(int q2 = 0; q2 < g_ns; q2++)
      g_sup[q2] = s[ns - 1 - q2];       // nearest support first
  }

//+------------------------------------------------------------------+
//| Drawing primitives (P&F window)                                  |
//+------------------------------------------------------------------+
void DrawRect(const string name, datetime t1, double p1, datetime t2, double p2,
              color clr, bool fill = true, int width = 1)
  {
   if(!ObjectCreate(0, name, OBJ_RECTANGLE, g_win, t1, p1, t2, p2))
      return;
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FILL, fill);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

void DrawText(const string name, datetime t, double p, const string txt, color clr,
              ENUM_ANCHOR_POINT anchor, int size = 8)
  {
   if(!ObjectCreate(0, name, OBJ_TEXT, g_win, t, p))
      return;
   ObjectSetString(0, name, OBJPROP_TEXT, txt);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, anchor);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

// current price line (dashed, with a text label)
void DrawPriceLine(const string name, datetime t1, datetime t2, double p, color clr, const string txt)
  {
   if(ObjectCreate(0, name, OBJ_TREND, g_win, t1, p, t2, p))
     {
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, true);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
     }
   DrawText(name + "_t", t1, p, txt, clr, ANCHOR_LEFT_LOWER, 8);
  }

void UpdatePriceLine(const double p)
  {
   if(!InpShowPrice || g_win < 0)
      return;
   if(MathAbs(p - g_lastPrice) < _Point * 0.5)
      return;
   if(ObjectFind(0, PREFIX + "PRICE") < 0)
      return;

   // price close to / outside the fixed vertical scale -> force a full redraw (rescales)
   double bp = g_boxPts * _Point;
   if(g_scHi > g_scLo && (p < g_scLo + bp || p > g_scHi - bp))
     {
      g_lastSig    = "";
      g_needRecalc = true;
      return;
     }

   ObjectSetDouble(0, PREFIX + "PRICE", OBJPROP_PRICE, 0, p);
   ObjectSetDouble(0, PREFIX + "PRICE", OBJPROP_PRICE, 1, p);
   ObjectSetDouble(0, PREFIX + "PRICE_t", OBJPROP_PRICE, p);
   ObjectSetString(0, PREFIX + "PRICE_t", OBJPROP_TEXT, Px(p));
   g_lastPrice  = p;
   g_chartDirty = true;
  }

//+------------------------------------------------------------------+
//| Support / resistance lines + labels on the MAIN chart            |
//+------------------------------------------------------------------+
void SetSRObject(const string nm, const double price, const color clr, const string txt, const datetime t)
  {
   int w = (int)MathMax(1, MathMin(5, InpSRLineWidth));

   // horizontal line (main chart = window 0)
   if(ObjectFind(0, nm) < 0)
     {
      if(!ObjectCreate(0, nm, OBJ_HLINE, 0, 0, price))
         return;
      ObjectSetInteger(0, nm, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, nm, OBJPROP_BACK, true);          // behind the candles
      ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, nm, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, nm, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
     }
   ObjectSetInteger(0, nm, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, nm, OBJPROP_WIDTH, w);
   ObjectSetDouble(0, nm, OBJPROP_PRICE, 0, price);

   // label "R1  1.12100": filled box (OBJ_EDIT), pinned to the right side, placed by PlaceSRLabels()
   string tn = nm + "_t";
   bool   isRes = (StringFind(nm, "_R") >= 0);
   if(ObjectFind(0, tn) < 0)
     {
      if(!ObjectCreate(0, tn, OBJ_EDIT, 0, 0, 0))
         return;
      ObjectSetString(0, tn, OBJPROP_FONT, "Arial Bold");
      ObjectSetInteger(0, tn, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, tn, OBJPROP_ALIGN, ALIGN_CENTER);
      ObjectSetInteger(0, tn, OBJPROP_READONLY, true);
      ObjectSetInteger(0, tn, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, tn, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, tn, OBJPROP_BACK, false);
      ObjectSetInteger(0, tn, OBJPROP_ZORDER, 10);
      ObjectSetInteger(0, tn, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
     }
   color bg = isRes ? InpResistLabelBg : InpSupportLabelBg;
   ObjectSetInteger(0, tn, OBJPROP_FONTSIZE, (int)MathMax(6, InpSRLabelSize));
   ObjectSetInteger(0, tn, OBJPROP_COLOR, InpSRLabelText);
   ObjectSetInteger(0, tn, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, tn, OBJPROP_BORDER_COLOR, bg);
   ObjectSetString(0, tn, OBJPROP_TEXT, txt);
  }

// positions the label boxes: right side of the chart, vertically centred on the level
void PlaceSRLabels()
  {
   if(!InpShowSRLines)
      return;
   double pmax = ChartGetDouble(0, CHART_PRICE_MAX, 0);
   double pmin = ChartGetDouble(0, CHART_PRICE_MIN, 0);
   int    cw   = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
   int    ch   = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);
   if(pmax <= pmin || cw <= 0 || ch <= 0)
      return;
   double dp = (double)TerminalInfoInteger(TERMINAL_SCREEN_DPI);
   dp = (dp >= 96.0) ? MathMin(3.0, dp / 96.0) : 1.0;       // DPI only (not the panel scale input)
   int fs   = (int)MathMax(6, InpSRLabelSize);
   int boxH = (int)MathRound((fs * 2 + 6) * dp);
   int right = cw - (int)MathRound(MathMax(0, InpSRLabelRight) * dp);
   if(ChartGetInteger(0, CHART_SHOW_PRICE_SCALE) != 0)
      right -= (int)MathRound(70 * dp);   // keep clear of the price scale (same offset as the panel)
   string names[4] = {"R1", "R2", "S1", "S2"};
   for(int i = 0; i < 4; i++)
     {
      string tn = SRL + names[i] + "_t";
      if(ObjectFind(0, tn) < 0)
         continue;
      double price = ObjectGetDouble(0, SRL + names[i], OBJPROP_PRICE, 0);   // level = the H-line price
      string txt   = ObjectGetString(0, tn, OBJPROP_TEXT);
      int boxW = (int)MathRound((StringLen(txt) * fs * 0.72 + 18) * dp);
      int y = (int)MathRound((pmax - price) / (pmax - pmin) * ch) - boxH / 2;
      bool vis = (price <= pmax && price >= pmin);
      ObjectSetInteger(0, tn, OBJPROP_XSIZE, boxW);
      ObjectSetInteger(0, tn, OBJPROP_YSIZE, boxH);
      ObjectSetInteger(0, tn, OBJPROP_XDISTANCE, MathMax(0, right - boxW));
      ObjectSetInteger(0, tn, OBJPROP_YDISTANCE, vis ? y : -1000);
     }
  }

void DelSRObject(const string nm)
  {
   ObjectDelete(0, nm);
   ObjectDelete(0, nm + "_t");
  }

// updates only when a level or the last bar time changes
void DrawSRLines(const datetime &time[], const int total)
  {
   if(!InpShowSRLines)
     {
      if(g_srKey != "")
        {
         ObjectsDeleteAll(0, SRL);
         g_srKey = "";
         g_chartDirty = true;
        }
      return;
     }

   datetime t = time[total - 1];
   string key = IntegerToString((long)t) + "|";
   for(int q = 0; q < 2; q++)
      key += ((q < g_nr) ? Px(g_res[q]) : "-") + ";";
   key += "|";
   for(int q2 = 0; q2 < 2; q2++)
      key += ((q2 < g_ns) ? Px(g_sup[q2]) : "-") + ";";
   if(key == g_srKey)
     {
      PlaceSRLabels();                     // chart scrolled / rescaled -> keep labels on their levels
      g_chartDirty = true;
      return;
     }
   g_srKey = key;

   for(int a = 0; a < 2; a++)
     {
      string nr = SRL + "R" + IntegerToString(a + 1);
      if(a < g_nr)
         SetSRObject(nr, g_res[a], InpResistColor, "R" + IntegerToString(a + 1) + "  " + Px(g_res[a]), t);
      else
         DelSRObject(nr);

      string ns = SRL + "S" + IntegerToString(a + 1);
      if(a < g_ns)
         SetSRObject(ns, g_sup[a], InpSupportColor, "S" + IntegerToString(a + 1) + "  " + Px(g_sup[a]), t);
      else
         DelSRObject(ns);
     }
   PlaceSRLabels();
   g_chartDirty = true;
  }

//+------------------------------------------------------------------+
//| Full redraw of the P&F chart (separate window)                   |
//+------------------------------------------------------------------+
void Redraw(const datetime &time[], const int total, const double cur)
  {
   ObjectsDeleteAll(0, PREFIX);
   g_drawn = 0;
   if(g_n < 1 || g_win < 0)
     {
      ChartRedraw();
      return;
     }

   int    last     = total - 1;
   int    W        = g_W;
   double bp       = g_boxPts * _Point;
   int    firstCol = MathMax(0, g_n - g_maxCols);
   double gX       = (double)W * g_gap / 200.0; // horizontal gap (in bar slots)
   int    perBox   = InpShowBorder ? 2 : 1;

   //--- pre-pass: how many pixels would one box get? (decides box-by-box or solid column drawing)
   int pMin = INT_MAX, pMax = INT_MIN;
   for(int jp = g_n - 1; jp >= firstCol; jp--)
     {
      int kp = g_n - 1 - jp;
      if(last + 1 - g_shift - (kp + 1) * W < 0)
         break;
      pMin = MathMin(pMin, g_cols[jp].bot);
      pMax = MathMax(pMax, g_cols[jp].top);
     }
   int    hpx0   = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, g_win);
   double span0  = (pMin == INT_MAX) ? 0.0 : (double)(pMax - pMin + 1 + 6);
   bool   solid  = (hpx0 > 0 && span0 > 0.0 && (double)hpx0 / span0 < 4.0);   // boxes thinner than 4 px
   if(solid)
      perBox = 1;

   //--- pass 1: decide which columns fit (newest first, so the oldest are dropped)
   int firstDraw = g_n;
   int used      = 0;
   int minL = INT_MAX, maxL = INT_MIN;
   for(int j = g_n - 1; j >= firstCol; j--)
     {
      int k    = g_n - 1 - j;                        // 0 = newest column
      int left = last + 1 - g_shift - (k + 1) * W;
      if(left < 0)
         break;
      int need = solid ? 1 : (g_cols[j].top - g_cols[j].bot + 1) * perBox;
      if(firstDraw < g_n && used + need > g_maxObj)
         break;
      used += need;
      firstDraw = j;
      minL = MathMin(minL, g_cols[j].bot);
      maxL = MathMax(maxL, g_cols[j].top);
     }

   //--- vertical scale of the separate window: fits the displayed columns
   if(minL == INT_MAX)
     {
      minL = Level(cur);
      maxL = minL;
     }
   double lo = MathMin(minL * bp, cur) - bp * 3.0;
   double hi = MathMax((maxL + 1) * bp, cur) + bp * 3.0;
   g_scLo = lo;
   g_scHi = hi;
   IndicatorSetDouble(INDICATOR_MINIMUM, lo);
   IndicatorSetDouble(INDICATOR_MAXIMUM, hi);

   //--- adapt gap and border to the real pixel height of one box (small windows stay readable)
   int    hpx   = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, g_win);
   g_subH       = hpx;
   double pxBox = (hpx > 0 && hi > lo) ? (double)hpx * bp / (hi - lo) : 12.0;
   int    bw    = (int)MathMin((double)MathMax(1, InpBorderWidth), MathFloor(pxBox / 5.0));
   bool   border = (InpShowBorder && bw >= 1);
   double gP    = (pxBox >= 7.0) ? bp * g_gap / 200.0 : 0.0;   // vertical gap (price)

   //--- pass 2: draw
   int drawn = 0;
   for(int j2 = firstDraw; j2 < g_n; j2++)
     {
      int k    = g_n - 1 - j2;
      int left = last + 1 - g_shift - (k + 1) * W;
      if(left < 0)
         continue;
      drawn++;

      datetime t1 = SlotTime(time, total, left);
      datetime a  = SlotTimeF(time, total, left + gX);
      datetime b  = SlotTimeF(time, total, left + W - gX);
      color    clr = (g_cols[j2].dir == 1) ? InpColorX : InpColorO;

      if(solid)
        {
         // too many boxes for the window height: one solid rectangle per column (readable + light)
         DrawRect(PREFIX + "C" + IntegerToString(j2), a, g_cols[j2].bot * bp, b, (g_cols[j2].top + 1) * bp,
                  clr, true, 1);
        }
      else
      for(int L = g_cols[j2].bot; L <= g_cols[j2].top; L++)
        {
         string bn = PREFIX + "B" + IntegerToString(j2) + "_" + IntegerToString(L);
         DrawRect(bn, a, L * bp + gP, b, (L + 1) * bp - gP, clr, true, 1);
         if(border)          // border (unfilled rectangle drawn over the fill)
            DrawRect(bn + "_b", a, L * bp + gP, b, (L + 1) * bp - gP,
                     InpBorderColor, false, bw);
        }

      // pattern names
      if(InpShowPatterns && g_cols[j2].pat != PAT_NONE)
        {
         int  p = g_cols[j2].pat;
         bool show = (p == PAT_DTB || p == PAT_DBB) ? (g_cols[j2].eff != 0) : true;
         if(show)
           {
            double upper = (g_cols[j2].top + 1) * bp;
            double lower = g_cols[j2].bot * bp;
            bool bearish = (p == PAT_DBB || p == PAT_TBB || p == PAT_BEAR_CAT);
            if(bearish)
               DrawText(PREFIX + "P" + IntegerToString(j2), t1, lower - bp * 1.5, PatName(p),
                        InpPatternColor, ANCHOR_LEFT_UPPER, 7);
            else
               DrawText(PREFIX + "P" + IntegerToString(j2), t1, upper + bp * 1.5, PatName(p),
                        InpPatternColor, ANCHOR_LEFT_LOWER, 7);
           }
        }
     }
   g_drawn = drawn;

   if(InpShowPrice)
     {
      datetime tp1 = SlotTime(time, total, MathMax(0, last + 1 - g_shift - drawn * W));
      datetime tp2 = SlotTime(time, total, last + 1 - g_shift);
      DrawPriceLine(PREFIX + "PRICE", tp1, tp2, cur, clrSilver, Px(cur));
      g_lastPrice = cur;
     }

   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| PANEL (main window)                                              |
//+------------------------------------------------------------------+
int PNew(const int kind, const int lx, const int ly, const int w, const int h, const int lvl)
  {
   int i = g_pcount;
   ArrayResize(g_pn, i + 1);
   ArrayResize(g_pt, i + 1);
   ArrayResize(g_pc, i + 1);
   ArrayResize(g_pl, i + 1);
   ArrayResize(g_pk, i + 1);
   ArrayResize(g_px, i + 1);
   ArrayResize(g_py, i + 1);
   ArrayResize(g_pw, i + 1);
   ArrayResize(g_ph, i + 1);
   g_pn[i] = PNL + IntegerToString(i);
   g_pt[i] = "";
   g_pc[i] = clrNONE;
   g_pl[i] = lvl;
   g_pk[i] = kind;
   g_px[i] = lx;
   g_py[i] = ly;
   g_pw[i] = w;
   g_ph[i] = h;
   g_pcount++;
   return i;
  }

void PCommon(const string nm)
  {
   ObjectSetInteger(0, nm, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, nm, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, nm, OBJPROP_BACK, false);
  }

int PRect(const int lx, const int ly, const int w, const int h, const color bg, const color bd, const int lvl)
  {
   int i = PNew(2, lx, ly, w, h, lvl);
   string nm = g_pn[i];
   ObjectCreate(0, nm, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   PCommon(nm);
   ObjectSetInteger(0, nm, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, nm, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, nm, OBJPROP_COLOR, bd);
   g_pc[i] = bg;
   return i;
  }

int PText(const string txt, const int lx, const int ly, const bool right, const color clr,
          const int size, const string font, const int lvl)
  {
   int i = PNew(right ? 1 : 0, lx, ly, 0, 0, lvl);
   string nm = g_pn[i];
   ObjectCreate(0, nm, OBJ_LABEL, 0, 0, 0);
   PCommon(nm);
   ObjectSetString(0, nm, OBJPROP_TEXT, (txt == "") ? " " : txt);   // empty text = default "Label" in MT5
   ObjectSetString(0, nm, OBJPROP_FONT, font);
   ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, Fs(size));
   ObjectSetInteger(0, nm, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, nm, OBJPROP_ANCHOR, right ? ANCHOR_RIGHT_UPPER : ANCHOR_LEFT_UPPER);
   g_pt[i] = (txt == "") ? " " : txt;
   g_pc[i] = clr;
   return i;
  }

int PButton(const int lx, const int ly, const int w, const int h, const int lvl)
  {
   int i = PNew(3, lx, ly, w, h, lvl);
   string nm = g_pn[i];
   ObjectCreate(0, nm, OBJ_BUTTON, 0, 0, 0);
   PCommon(nm);
   ObjectSetString(0, nm, OBJPROP_TEXT, "");
   ObjectSetString(0, nm, OBJPROP_FONT, g_fT);
   ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, Fs(8));
   ObjectSetInteger(0, nm, OBJPROP_COLOR, C'235,240,255');
   ObjectSetInteger(0, nm, OBJPROP_BGCOLOR, C'38,52,160');
   ObjectSetInteger(0, nm, OBJPROP_BORDER_COLOR, C'110,128,225');
   ObjectSetInteger(0, nm, OBJPROP_STATE, false);
   return i;
  }

void PSection(const string title, const int x, const int y, const int w,
              const color accent, const color line, const int lvl)
  {
   PText(title, x, y, false, accent, 8, g_fB, lvl);
   PRect(x, y + 17, w, 1, line, line, lvl);
  }

int PRow(const string label, const int x, const int y, const int w,
         const color dim, const color val, const int lvl)
  {
   PText(label, x, y, false, dim, 9, g_fT, lvl);
   return PText("", x + w, y, true, val, 9, g_fT, lvl);
  }

// updates text/color only when they changed (no flicker, no useless calls)
void PSet(const int slot, const string txt, const color clr)
  {
   if(slot < 0 || slot >= g_pcount)
      return;
   string tx = (txt == "") ? " " : txt;
   if(g_pt[slot] != tx)
     {
      ObjectSetString(0, g_pn[slot], OBJPROP_TEXT, tx);
      g_pt[slot]   = tx;
      g_chartDirty = true;
     }
   if(g_pc[slot] != clr)
     {
      ObjectSetInteger(0, g_pn[slot], OBJPROP_COLOR, clr);
      g_pc[slot]   = clr;
      g_chartDirty = true;
     }
  }

void PBg(const int slot, const color clr)
  {
   if(slot < 0 || slot >= g_pcount)
      return;
   if(g_pc[slot] != clr)
     {
      ObjectSetInteger(0, g_pn[slot], OBJPROP_BGCOLOR, clr);
      g_pc[slot]   = clr;
      g_chartDirty = true;
     }
  }

int PanelH()
  {
   if(g_pmode == 0)
      return P_H_FULL;
   if(g_pmode == 1)
      return P_H_COMP;
   return P_H_MIN;
  }

void Layout()
  {
   if(!g_panelBuilt)
      return;
   g_cw  = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
   g_chh = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);

   int  pw = Sc(P_W), ph = Sc(PanelH());
   int  mx = Sc(InpPanelX), my = Sc(InpPanelY);
   bool right  = (InpPanelPos == PNL_RIGHT_TOP || InpPanelPos == PNL_RIGHT_BOTTOM);
   bool bottom = (InpPanelPos == PNL_LEFT_BOTTOM || InpPanelPos == PNL_RIGHT_BOTTOM);
   if(right && ChartGetInteger(0, CHART_SHOW_PRICE_SCALE) != 0)
      mx += Sc(70);                       // leave room for the price scale

   int ox = right ? g_cw - pw - mx : mx;
   int oy = bottom ? g_chh - ph - my : my;
   if(ox < 0) ox = 0;
   if(oy < 0) oy = 0;

   for(int i = 0; i < g_pcount; i++)
     {
      ObjectSetInteger(0, g_pn[i], OBJPROP_XDISTANCE, ox + Sc(g_px[i]));
      ObjectSetInteger(0, g_pn[i], OBJPROP_YDISTANCE, oy + Sc(g_py[i]));
      if(g_pk[i] >= 2)
        {
         ObjectSetInteger(0, g_pn[i], OBJPROP_XSIZE, Sc(g_pw[i]));
         ObjectSetInteger(0, g_pn[i], OBJPROP_YSIZE, (i == g_bg) ? ph : Sc(g_ph[i]));
        }
     }
  }

void ApplyMode()
  {
   if(!g_panelBuilt)
      return;
   for(int i = 0; i < g_pcount; i++)
     {
      bool vis = (g_pmode <= g_pl[i]);
      ObjectSetInteger(0, g_pn[i], OBJPROP_TIMEFRAMES, vis ? OBJ_ALL_PERIODS : OBJ_NO_PERIODS);
     }
   string t = (g_pmode == 0) ? "View: Full" : (g_pmode == 1 ? "View: Compact" : "View: Mini");
   ObjectSetString(0, g_pn[g_btn], OBJPROP_TEXT, t);
   Layout();
  }

void BuildPanel()
  {
   ObjectsDeleteAll(0, PNL);
   g_pcount = 0;
   for(int k = 0; k < PV_COUNT; k++)
      g_v[k] = -1;

   color bg     = InpPanelBg;
   color head   = Mix(bg, clrBlack, 0.38);
   color line   = Mix(bg, clrWhite, 0.26);
   color accent = SectionColor();           // section titles
   color dim    = clrWhite;
   color val    = clrWhite;
   color banNeu = C'38,52,160';

   g_bg = PRect(0, 0, P_W, P_H_FULL, bg, line, 2);

   //--- header
   PRect(1, 1, P_W - 2, 29, head, head, 2);
   PText("POINT & FIGURE", 12, 6, false, clrWhite, 11, g_fB, 2);
   g_v[PV_HDR] = PText("", 368, 8, true, dim, 9, g_fT, 2);
   g_btn = PButton(376, 5, 82, 20, 2);

   //--- status banner
   g_v[PV_BANNER]  = PRect(1, 30, P_W - 2, 44, banNeu, banNeu, 2);
   g_v[PV_STATUS]  = PText("", 12, 35, false, clrWhite, 13, g_fB, 2);
   g_v[PV_VERDICT] = PText("", P_W - 12, 39, true, clrWhite, 9, g_fB, 2);
   g_v[PV_SUB]     = PText("", 12, 57, false, clrWhite, 8, g_fT, 2);

   //--- left: trade plan + entry conditions
   PSection("TRADE PLAN", P_X1, 82, P_CW, accent, line, 1);
   g_v[PV_ENTRY] = PRow("Entry (live price)", P_X1, 102, P_CW, dim, val, 1);
   g_v[PV_SL]    = PRow("Stop loss (SL)", P_X1, 119, P_CW, dim, val, 1);
   g_v[PV_TP]    = PRow("Take profit (TP)", P_X1, 136, P_CW, dim, val, 1);
   g_v[PV_RR]    = PRow("Risk / Reward", P_X1, 153, P_CW, dim, val, 1);
   g_v[PV_LOT]   = PRow(StringFormat("Lot @ %.1f%% risk", InpRiskPct), P_X1, 170, P_CW, dim, val, 1);

   PSection("ENTRY CONDITIONS", P_X1, 193, P_CW, accent, line, 0);
   g_v[PV_EMA] = PRow(StringFormat("EMA %d (trend)", g_maP), P_X1, 213, P_CW, dim, val, 0);
   g_v[PV_ADX] = PRow(StringFormat("ADX %d (min %.0f)", g_adxP, InpADXMin), P_X1, 230, P_CW, dim, val, 0);
   g_v[PV_SES] = PRow(StringFormat("Session %02d-%02d", InpStartHour, InpEndHour), P_X1, 247, P_CW, dim, val, 0);
   g_v[PV_SPR] = PRow("Spread", P_X1, 264, P_CW, dim, val, 0);
   g_v[PV_ATR] = PRow("ATR 14 (" + TfName() + ")", P_X1, 281, P_CW, dim, val, 0);

   //--- right: P&F structure + support/resistance
   PSection("P&F STRUCTURE", P_X2, 82, P_CW, accent, line, 1);
   g_v[PV_BOX] = PRow("Box / reversal", P_X2, 102, P_CW, dim, val, 1);
   g_v[PV_COL] = PRow("Current column", P_X2, 119, P_CW, dim, val, 1);
   g_v[PV_EXT] = PRow("Continuation", P_X2, 136, P_CW, dim, val, 1);
   g_v[PV_REV] = PRow("Reversal", P_X2, 153, P_CW, dim, val, 1);
   g_v[PV_BOB] = PRow("Breakout BUY", P_X2, 170, P_CW, dim, val, 1);
   g_v[PV_BOS] = PRow("Breakout SELL", P_X2, 187, P_CW, dim, val, 1);
   g_v[PV_STR] = PRow("Structure", P_X2, 204, P_CW, dim, val, 1);

   PSection("SUPPORT / RESISTANCE", P_X2, 227, P_CW, accent, line, 0);
   g_v[PV_R2] = PRow("Resistance 2", P_X2, 247, P_CW, dim, val, 0);
   g_v[PV_R1] = PRow("Resistance 1", P_X2, 264, P_CW, dim, val, 0);
   g_v[PV_S1] = PRow("Support 1", P_X2, 281, P_CW, dim, val, 0);
   g_v[PV_S2] = PRow("Support 2", P_X2, 298, P_CW, dim, val, 0);

   //--- signal history (full width)
   PSection("LAST SIGNALS", P_X1, 321, P_W - 24, accent, line, 0);
   for(int h = 0; h < 3; h++)
     {
      g_v[PV_H0 + h]  = PText("", P_X1, 341 + h * 17, false, val, 9, g_fT, 0);
      g_v[PV_HR0 + h] = PText("", P_W - 12, 341 + h * 17, true, dim, 9, g_fT, 0);
     }

   //--- footer
   g_v[PV_FL] = PText("", P_X1, 399, false, dim, 8, g_fT, 0);
   g_v[PV_FR] = PText("", P_W - 12, 399, true, dim, 8, g_fT, 0);

   g_panelBuilt = true;
   ApplyMode();
  }

//+------------------------------------------------------------------+
//| Market structure from the latest P&F highs / lows                |
//+------------------------------------------------------------------+
string StructText(int &sign)
  {
   sign = 0;
   int nt = 0, nb = 0, t1 = 0, t2 = 0, b1 = 0, b2 = 0;
   for(int j = g_n - 1; j >= 0 && (nt < 2 || nb < 2); j--)
     {
      if(g_cols[j].dir == 1)
        {
         if(nt == 0)
            t1 = g_cols[j].top;
         else
            if(nt == 1)
               t2 = g_cols[j].top;
         nt++;
        }
      else
        {
         if(nb == 0)
            b1 = g_cols[j].bot;
         else
            if(nb == 1)
               b2 = g_cols[j].bot;
         nb++;
        }
     }
   if(nt < 2 || nb < 2)
      return "insufficient data";
   bool hh = (t1 > t2), lh = (t1 < t2), hl = (b1 > b2), ll = (b1 < b2);
   if(hh && hl) { sign = 1;  return "Uptrend"; }
   if(lh && ll) { sign = -1; return "Downtrend"; }
   if(hh && ll) return "Expanding";
   if(lh && hl) return "Contracting";
   if(hh) { sign = 1;  return "Higher highs"; }
   if(ll) { sign = -1; return "Lower lows"; }
   if(hl) { sign = 1;  return "Higher lows"; }
   if(lh) { sign = -1; return "Lower highs"; }
   return "Sideways";
  }

void SetLevelRow(const int slot, const double lvl, const double bid, const color clr)
  {
   if(lvl <= 0.0)
     {
      PSet(slot, "-", clrWhite);
      return;
     }
   PSet(slot, Px(lvl) + "   " + SP((lvl - bid) / g_pip), clr);
  }

//+------------------------------------------------------------------+
//| Panel values update                                              |
//+------------------------------------------------------------------+
void UpdatePanel(const double bid, const double ask)
  {
   if(!g_panelBuilt)
      return;

   color cGood = C'96,226,136', cBad = C'255,104,104', cWarn = C'255,200,80', cNeu = clrWhite;
   color cVal  = clrWhite, cDim = clrWhite;
   color cRes  = clrWhite;
   color cSup  = clrWhite;

   double bp      = g_boxPts * _Point;
   int    j       = g_n - 1;
   bool   has     = (g_n >= 1);
   int    dirC    = has ? g_cols[j].dir : 0;
   bool   act     = (has && g_cols[j].eff != 0);
   bool   blkd    = (has && !act && g_cols[j].sig != 0);
   double spreadP = (ask - bid) / g_pip;
   double maxRisk = MaxRiskP(), maxChase = MaxChaseP(), maxSpr = MaxSpreadP();
   string ccy     = AccountInfoString(ACCOUNT_CURRENCY);

   //--- header
   PSet(g_v[PV_HDR], _Symbol + "  " + TfName() + "   " + Px(bid), cNeu);

   //--- status banner + plan
   string st = "", sub = "", ver = "";
   color  banClr = C'38,52,160', verClr = clrWhite;
   double entry = 0.0, sl = 0.0, tp = 0.0, riskP = 0.0, lot = 0.0, riskMoney = 0.0;
   bool   plan = false, buy = false;

   if(!has)
     {
      st  = g_dot + "  NOT ENOUGH DATA";
      sub = "Waiting for P&F columns to form";
     }
   else
      if(act)
        {
         buy  = (g_cols[j].eff > 0);
         plan = Plan(j, bid, ask, entry, sl, tp, riskP, lot, riskMoney);
         bool   slHit = plan && (buy ? (bid <= sl) : (ask >= sl));
         double lvl   = g_cols[j].pTrig;
         double chase = buy ? (ask - lvl) / g_pip : (lvl - bid) / g_pip;
         st     = buy ? g_up + "  BUY" : g_dn + "  SELL";
         banClr = buy ? C'0,122,72' : C'176,36,52';
         int    bars = g_lastTotal - 1 - g_cols[j].trig;
         sub = PatName(g_cols[j].pat) + "   " + g_mid + "   " + AgeText(bars);

         if(slHit)
           {
            ver = "SL HIT - INVALID";
            verClr = cWarn;
            banClr = C'86,92,128';
           }
         else
            if(chase > maxChase)
              {
               ver = "LATE " + SP(chase) + " past breakout";
               verClr = cWarn;
              }
            else
               if(spreadP > maxSpr)
                 {
                  ver = "HIGH SPREAD " + DoubleToString(spreadP, 1) + "p";
                  verClr = cWarn;
                 }
               else
                  if(plan && riskP > maxRisk)
                    {
                     ver = "HIGH RISK " + DoubleToString(riskP, 1) + "p";
                     verClr = cWarn;
                    }
                  else
                    {
                     ver = "VALID ENTRY";
                     verClr = clrWhite;
                    }
        }
      else
         if(blkd)
           {
            st     = g_dia + "  " + (g_cols[j].sig > 0 ? "BUY" : "SELL") + " BREAKOUT BLOCKED";
            banClr = C'122,88,18';
            sub    = "Reason: " + BlkText(g_cols[j].blk);
           }
         else
           {
            st  = g_dot + "  NO SIGNAL";
            if(g_cols[j].pat != PAT_NONE)
               sub = PatName(g_cols[j].pat);
            else
               sub = (dirC == 1) ? "X column" : "O column";
            sub += "   " + g_mid + "   waiting for breakout";
           }

   PBg(g_v[PV_BANNER], banClr);
   PSet(g_v[PV_STATUS], st, clrWhite);
   PSet(g_v[PV_VERDICT], ver, verClr);
   PSet(g_v[PV_SUB], sub, clrWhite);

   //--- trade plan
   if(plan)
     {
      PSet(g_v[PV_ENTRY], Px(entry) + (buy ? "   ASK" : "   BID"), cVal);
      PSet(g_v[PV_SL], Px(sl) + "   " + SP((sl - entry) / g_pip), (riskP > maxRisk) ? cWarn : cVal);
      PSet(g_v[PV_TP], Px(tp) + "   " + SP((tp - entry) / g_pip), cVal);
      PSet(g_v[PV_RR], DoubleToString(riskP, 1) + "p / " + DoubleToString(riskP * InpRR, 1) + "p   (1:" +
           DoubleToString(InpRR, 1) + ")", cVal);
      if(lot > 0.0)
         PSet(g_v[PV_LOT], DoubleToString(lot, LotDigits()) + "   (" + DoubleToString(riskMoney, 0) + " " + ccy + ")", cVal);
      else
         PSet(g_v[PV_LOT], "below minimum lot", cWarn);
     }
   else
     {
      PSet(g_v[PV_ENTRY], "-", cDim);
      PSet(g_v[PV_SL], "-", cDim);
      PSet(g_v[PV_TP], "-", cDim);
      PSet(g_v[PV_RR], "-", cDim);
      PSet(g_v[PV_LOT], "-", cDim);
     }

   //--- entry conditions (evaluated for the direction of the current column)
   if(InpUseTrendMA && g_emaV > 0.0)
     {
      double dE = (bid - g_emaV) / g_pip;
      bool   ok = (dirC > 0) ? (dE > 0.0) : (dE < 0.0);
      color  cc = (dirC == 0) ? cNeu : (ok ? cGood : cBad);
      PSet(g_v[PV_EMA], g_dot + " " + (dE >= 0.0 ? "above " : "below ") + DoubleToString(MathAbs(dE), 1) + "p", cc);
     }
   else
      PSet(g_v[PV_EMA], InpUseTrendMA ? "-" : "OFF", cDim);

   if(InpUseADX && g_adxV > 0.0)
      PSet(g_v[PV_ADX], g_dot + " " + DoubleToString(g_adxV, 1), (g_adxV >= InpADXMin) ? cGood : cBad);
   else
      PSet(g_v[PV_ADX], InpUseADX ? "-" : "OFF", cDim);

   if(SessionApplies())
     {
      MqlDateTime dt;
      TimeToStruct(TimeTradeServer(), dt);
      bool inS = InSession(dt.hour);
      PSet(g_v[PV_SES], g_dot + " " + (inS ? "OPEN " : "CLOSED ") + StringFormat("%02d:%02d", dt.hour, dt.min),
           inS ? cGood : cBad);
     }
   else
      PSet(g_v[PV_SES], InpUseSession ? "n/a (timeframe)" : "OFF", cDim);

   PSet(g_v[PV_SPR], g_dot + " " + DoubleToString(spreadP, 1) + "p (max " + DoubleToString(maxSpr, 1) + "p)",
        (spreadP <= maxSpr) ? cGood : cWarn);

   if(g_atrV > 0.0)
     {
      double atrP = g_atrV / g_pip;
      string t = DoubleToString(atrP, 1) + "p";
      if(plan && atrP > 0.0)
         t += "   risk " + DoubleToString(riskP / atrP, 1) + "x";
      PSet(g_v[PV_ATR], t, cVal);
     }
   else
      PSet(g_v[PV_ATR], "-", cDim);

   //--- P&F structure
   if(has)
     {
      int rev = g_rev;
      PSet(g_v[PV_BOX], DoubleToString(g_boxPts * _Point / g_pip, 1) + "p   " + g_mid + "   rev " +
           IntegerToString(rev), cVal);

      int hgt = g_cols[j].top - g_cols[j].bot + 1;
      PSet(g_v[PV_COL], (dirC == 1 ? g_up + " X   " : g_dn + " O   ") + IntegerToString(hgt) +
           (hgt == 1 ? " box" : " boxes"), (dirC == 1) ? cGood : cBad);

      double lvE = 0.0, lvR = 0.0;
      string pE = "", pR = "";
      if(dirC == 1)
        {
         lvE = (g_cols[j].top + 1) * bp;
         pE  = ">= ";
         lvR = (g_cols[j].top - rev + 1) * bp;
         pR  = "< ";
        }
      else
        {
         lvE = g_cols[j].bot * bp;
         pE  = "< ";
         lvR = (g_cols[j].bot + rev) * bp;
         pR  = ">= ";
        }
      PSet(g_v[PV_EXT], pE + Px(lvE) + "   " + SP((lvE - bid) / g_pip), cVal);
      PSet(g_v[PV_REV], pR + Px(lvR) + "   " + SP((lvR - bid) / g_pip), cVal);

      // levels where the next breakout appears (raw, before filters)
      double lvB = 0.0, lvS = 0.0;
      bool   doneB = false, doneS = false;
      if(dirC == 1)
        {
         if(j >= 2)
           {
            if(g_cols[j].top > g_cols[j - 2].top)
               doneB = true;
            else
               lvB = (g_cols[j - 2].top + 1) * bp;
           }
         if(j >= 1)
            lvS = g_cols[j - 1].bot * bp;
        }
      else
        {
         if(j >= 2)
           {
            if(g_cols[j].bot < g_cols[j - 2].bot)
               doneS = true;
            else
               lvS = g_cols[j - 2].bot * bp;
           }
         if(j >= 1)
            lvB = (g_cols[j - 1].top + 1) * bp;
        }
      if(doneB)
         PSet(g_v[PV_BOB], "TRIGGERED", cGood);
      else
         if(lvB > 0.0)
            PSet(g_v[PV_BOB], ">= " + Px(lvB) + "   " + SP((lvB - bid) / g_pip), cVal);
         else
            PSet(g_v[PV_BOB], "-", cDim);
      if(doneS)
         PSet(g_v[PV_BOS], "TRIGGERED", cBad);
      else
         if(lvS > 0.0)
            PSet(g_v[PV_BOS], "< " + Px(lvS) + "   " + SP((lvS - bid) / g_pip), cVal);
         else
            PSet(g_v[PV_BOS], "-", cDim);

      int    sg = 0;
      string sx = StructText(sg);
      PSet(g_v[PV_STR], sx, (sg > 0) ? cGood : ((sg < 0) ? cBad : cNeu));
     }
   else
     {
      PSet(g_v[PV_BOX], "-", cDim);
      PSet(g_v[PV_COL], "-", cDim);
      PSet(g_v[PV_EXT], "-", cDim);
      PSet(g_v[PV_REV], "-", cDim);
      PSet(g_v[PV_BOB], "-", cDim);
      PSet(g_v[PV_BOS], "-", cDim);
      PSet(g_v[PV_STR], "-", cDim);
     }

   //--- support / resistance
   SetLevelRow(g_v[PV_R2], (g_nr > 1) ? g_res[1] : 0.0, bid, cRes);
   SetLevelRow(g_v[PV_R1], (g_nr > 0) ? g_res[0] : 0.0, bid, cRes);
   SetLevelRow(g_v[PV_S1], (g_ns > 0) ? g_sup[0] : 0.0, bid, cSup);
   SetLevelRow(g_v[PV_S2], (g_ns > 1) ? g_sup[1] : 0.0, bid, cSup);

   //--- signal history
   int shown = 0;
   for(int q = g_n - 1; q >= 0 && shown < 3; q--)
     {
      if(g_cols[q].eff == 0)
         continue;
      bool b = (g_cols[q].eff > 0);
      PSet(g_v[PV_H0 + shown], (b ? g_up + " BUY   " : g_dn + " SELL  ") + TStr(g_cols[q].tTrig), b ? cGood : cBad);
      PSet(g_v[PV_HR0 + shown], PatShort(g_cols[q].pat) + "   @ " + Px(g_cols[q].pTrig), cNeu);
      shown++;
     }
   for(int q2 = shown; q2 < 3; q2++)
     {
      PSet(g_v[PV_H0 + q2], "-", cDim);
      PSet(g_v[PV_HR0 + q2], "", cDim);
     }

   //--- footer
   PSet(g_v[PV_FL], IntegerToString(g_n) + " columns   " + g_mid + "   " + (InpClosedOnly ? "closed bars" : "real time"), cDim);
   PSet(g_v[PV_FR], "server time " + TimeToString(TimeTradeServer(), TIME_SECONDS), cDim);
  }

//+------------------------------------------------------------------+
//| Chart events: panel mode button + re-layout on resize            |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   //--- P&F window resized -> redraw so gap/border fit the new box height (no tick needed)
   if(id == CHARTEVENT_CHART_CHANGE && g_win >= 0 && g_n > 0 && g_lastTotal > 0)
     {
      int hs = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, g_win);
      if(hs > 0 && hs != g_subH)
        {
         datetime tt[];
         int nt = CopyTime(_Symbol, _Period, 0, g_lastTotal, tt);
         if(nt == g_lastTotal)
           {
            double cur = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            if(cur <= 0.0)
               cur = g_lastPrice;
            if(cur > 0.0)
               Redraw(tt, nt, cur);
           }
         else
            g_lastSig = "";
        }
     }

   if(id == CHARTEVENT_CHART_CHANGE)
     {
      PlaceSRLabels();
      ChartRedraw();
     }

   if(!g_panelBuilt)
      return;
   if(id == CHARTEVENT_OBJECT_CLICK && g_btn >= 0 && sparam == g_pn[g_btn])
     {
      g_pmode = (g_pmode + 1) % 3;
      ObjectSetInteger(0, g_pn[g_btn], OBJPROP_STATE, false);
      ApplyMode();
      ChartRedraw();
      return;
     }
   if(id == CHARTEVENT_CHART_CHANGE)
     {
      int w = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
      int h = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);
      if(w != g_cw || h != g_chh)
        {
         Layout();
         ChartRedraw();
        }
     }
  }

//+------------------------------------------------------------------+
//| Alerts                                                           |
//+------------------------------------------------------------------+
void SendAlert(const string msg)
  {
   string m = "P&F " + _Symbol + " " + TfName() + ": " + msg;
   if(InpAlertPopup) Alert(m);
   if(InpAlertSound) PlaySound(InpSoundFile);
   if(InpAlertPush)
     {
      string pm = m;
      if(StringLen(pm) > 250)
         pm = StringSubstr(pm, 0, 250);      // push notifications are limited to 255 characters
      SendNotification(pm);
     }
   if(InpAlertEmail) SendMail("Point & Figure alert", m);
  }

void CheckAlerts(const int total)
  {
   if(g_n < 1)
      return;
   int    j  = g_n - 1;
   string kS = "", kP = "", kC = "";
   if(g_cols[j].eff != 0)
      kS = IntegerToString(g_cols[j].eff) + "|" + IntegerToString((long)g_cols[j].tTrig);
   if(g_cols[j].pat != PAT_NONE && g_cols[j].eff == 0)
      kP = IntegerToString(g_cols[j].pat) + "|" + IntegerToString((long)g_cols[j].t0);
   kC = IntegerToString(g_cols[j].dir) + "|" + IntegerToString((long)g_cols[j].t0);

   if(g_firstRun)
     {
      g_alSig = kS;
      g_alPat = kP;
      g_alCol = kC;
      g_firstRun = false;
      return;
     }

   // new column
   if(kC != g_alCol)
     {
      g_alCol = kC;
      double bp = g_boxPts * _Point;
      if(InpAlertColumn && total - 1 - g_cols[j].b0 <= 2)
         SendAlert(StringFormat("new %s column (%s - %s)",
                                g_cols[j].dir == 1 ? "X (rising)" : "O (falling)",
                                DoubleToString(g_cols[j].bot * bp, _Digits),
                                DoubleToString((g_cols[j].top + 1) * bp, _Digits)));
     }

   // entry signal (alerted once per breakout, only if fresh)
   if(kS != "" && kS != g_alSig)
     {
      g_alSig = kS;
      if(InpAlertSignals && j >= 1 && total - 1 - g_cols[j].trig <= 2)
        {
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         if(bid > 0.0 && ask > 0.0)
           {
            double entry = 0.0, sl = 0.0, tp = 0.0, riskP = 0.0, lot = 0.0, riskMoney = 0.0;
            if(Plan(j, bid, ask, entry, sl, tp, riskP, lot, riskMoney))
              {
               bool   buy = (g_cols[j].eff > 0);
               string msg = StringFormat("%s - %s | Entry ~%s | SL %s (%.1f pips) | TP %s (RR 1:%.1f)",
                                         buy ? "BUY ENTRY" : "SELL ENTRY", PatShort(g_cols[j].pat),
                                         Px(entry), Px(sl), riskP, Px(tp), InpRR);
               if(lot > 0.0)
                  msg += StringFormat(" | Lot %s", DoubleToString(lot, LotDigits()));
               double spreadP = (ask - bid) / g_pip;
               if(spreadP > MaxSpreadP())
                  msg += StringFormat(" | WARNING spread %.1f pips", spreadP);
               if(riskP > MaxRiskP())
                  msg += StringFormat(" | WARNING high risk %.1f pips", riskP);
               SendAlert(msg);
              }
           }
        }
     }

   // pattern
   if(kP != "" && kP != g_alPat)
     {
      g_alPat = kP;
      if(InpAlertPatterns && total - 1 - g_cols[j].b0 <= 2)
         SendAlert("pattern: " + PatName(g_cols[j].pat));
     }
  }

//+------------------------------------------------------------------+
//| Loading the filters (EMA / ADX) - only the needed window         |
//+------------------------------------------------------------------+
bool CopyFilter(const int h, double &buf[], const int n, const bool full)
  {
   if(full || ArraySize(buf) != n)
     {
      if(BarsCalculated(h) < n)
         return false;
      ArraySetAsSeries(buf, false);
      if(CopyBuffer(h, 0, 0, n, buf) < n)
         return false;
      return true;
     }
   double t[];
   if(CopyBuffer(h, 0, 0, 1, t) < 1)       // intrabar: only the last value is refreshed
      return false;
   buf[n - 1] = t[0];
   return true;
  }

//+------------------------------------------------------------------+
//| Full calculation: box, filters, columns, signals                 |
//+------------------------------------------------------------------+
bool Calculate(const datetime &time[], const double &high[], const double &low[],
               const double &close[], const int total, const bool full)
  {
   //--- box size
   if(InpBoxMode == BOX_ATR)
     {
      double a[];
      if(g_hATR != INVALID_HANDLE && BarsCalculated(g_hATR) > 0 &&
         CopyBuffer(g_hATR, 0, 1, 1, a) >= 1 && a[0] > 0.0)
        {
         double rawPts = a[0] * MathMax(0.1, InpATRMult) / _Point;
         int    cand   = NiceBoxPts(rawPts);
         // hysteresis: keep the current box unless the ATR moved by more than 25%
         if(g_boxAuto > 0 && MathAbs(rawPts - g_boxAuto) / (double)g_boxAuto < 0.25)
            cand = g_boxAuto;
         g_boxAuto = cand;
        }
      if(g_boxAuto <= 0)
         return false;                  // ATR not ready yet -> retry on the next tick
      g_boxPts = g_boxAuto;
     }
   else
      g_boxPts = MathMax(1, InpBoxPoints);

   //--- history window
   int startRaw = MathMax(0, total - g_hist);
   int nCopy    = total - startRaw;
   g_fOff       = startRaw;

   if(g_hMA != INVALID_HANDLE && !CopyFilter(g_hMA, g_maBuf, nCopy, full))
      return false;
   if(g_hADX != INVALID_HANDLE && !CopyFilter(g_hADX, g_adxBuf, nCopy, full))
      return false;

   //--- columns + signals
   BuildPF(time, high, low, close, total, startRaw);
   Analyze(time, close, total);

   //--- informative values for the panel (last closed bar)
   int back = InpClosedOnly ? 2 : 1;
   g_emaV = (g_hMA != INVALID_HANDLE && nCopy >= back && ArraySize(g_maBuf) >= back) ? g_maBuf[ArraySize(g_maBuf) - back] : 0.0;
   g_adxV = (g_hADX != INVALID_HANDLE && nCopy >= back && ArraySize(g_adxBuf) >= back) ? g_adxBuf[ArraySize(g_adxBuf) - back] : 0.0;
   g_atrV = 0.0;
   if(g_hATRc != INVALID_HANDLE)
     {
      double t[];
      if(CopyBuffer(g_hATRc, 0, InpClosedOnly ? 1 : 0, 1, t) >= 1)
         g_atrV = t[0];
     }
   return true;
  }

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(rates_total < 30)
      return(0);
   int total = rates_total;

   //--- separate window of the indicator (may still be unavailable on the first run)
   int win = ChartWindowFind();
   if(win != g_win)
     {
      g_win = win;
      if(win >= 0)
        {
         g_lastSig    = "";
         g_needRecalc = true;
         if(InpWindowHeight > 0 && !g_hSet)
           {
            ChartSetInteger(0, CHART_HEIGHT_IN_PIXELS, win, (long)MathMax(80, InpWindowHeight));
            g_hSet = true;
           }
        }
     }

   bool newBar = (prev_calculated == 0 || total != g_lastTotal || time[total - 1] != g_lastBarT);
   bool recalc = (newBar || g_needRecalc || !InpClosedOnly);

   if(recalc)
     {
      if(!Calculate(time, high, low, close, total, newBar))
         return(prev_calculated);          // data not available yet -> retry on the next tick
      g_lastTotal = total;
      g_lastBarT  = time[total - 1];

      //--- signal buffer (for EA / iCustom): +1 BUY, -1 SELL, 0 none
      if(prev_calculated == 0 || prev_calculated > total)
         ArrayInitialize(g_sigBuf, 0.0);
      else
         for(int i = prev_calculated; i < total; i++)
            g_sigBuf[i] = 0.0;
      g_sigBuf[total - 1] = (g_n > 0) ? (double)g_cols[g_n - 1].eff : 0.0;

      //--- redraw P&F only when something changes
      if(g_win >= 0)
        {
         string sig = IntegerToString(total) + "|" + IntegerToString((long)time[total - 1]) + "|" +
                      IntegerToString(g_boxPts) + "|" + IntegerToString(g_n);
         if(g_n > 0)
            sig += "|" + IntegerToString(g_cols[g_n - 1].top) + "|" + IntegerToString(g_cols[g_n - 1].bot) +
                   "|" + IntegerToString(g_cols[g_n - 1].dir);
         if(sig != g_lastSig)
           {
            double cur = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            if(cur <= 0.0)
               cur = close[total - 1];
            g_lastSig = sig;
            Redraw(time, total, cur);
           }
         g_needRecalc = false;
        }
      else
         g_needRecalc = true;

      CheckAlerts(total);
     }

   //--- panel + "live" elements (frequency limited)
   uint now = GetTickCount();
   if(recalc || (uint)(now - g_lastUiMs) >= (uint)MathMax(100, InpPanelRefreshMs))
     {
      g_lastUiMs = now;
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      if(bid <= 0.0)
         bid = close[total - 1];
      if(ask <= 0.0)
         ask = bid;

      if(g_n > 0)
        {
         CalcSR(bid);
         if(g_win >= 0)
            UpdatePriceLine(bid);
        }
      else
         g_nr = g_ns = 0;
      DrawSRLines(time, total);

      if(InpShowPanel)
        {
         if(!g_panelBuilt)
            BuildPanel();
         UpdatePanel(bid, ask);
        }
      if(g_chartDirty)
        {
         ChartRedraw();
         g_chartDirty = false;
        }
     }
   return(total);
  }
//+------------------------------------------------------------------+
