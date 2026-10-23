//+------------------------------------------------------------------+
//|                                            Market Session Pro+.mq5 |
//|  Global market sessions: lines/boxes, countdown labels, panel,    |
//|  and forward chart scrolling.                                     |
//|                                                                   |
//|  TIME MODEL                                                       |
//|   * Market times are entered in UTC *standard* (non-DST) time.    |
//|   * If "Auto DST" is on, US / EU / AU daylight saving is applied  |
//|     automatically per market (NY, Toronto = US; London, Euronext, |
//|     Frankfurt, Zurich = EU; Sydney = AU).                         |
//|   * The chart's own (server) clock is the reference for every     |
//|     countdown, so a label/panel countdown always matches where    |
//|     the line sits on the chart. The broker GMT offset only decides|
//|     which real-world hour a line represents (auto or manual).     |
//|   * Every market also has its own +/- hours adjustment.           |
//+------------------------------------------------------------------+
#property copyright   "ClassicalTrading | www.mql5.com/en/users/classicaltrading/"
#property link        "https://www.mql5.com/en/users/classicaltrading/"
#property version     "2.00"
#property description "Market Session Pro+ - session lines/boxes, open/close markers, countdown timers, resizable panel, forward scroll."
#property indicator_chart_window
#property indicator_plots   0
#property indicator_buffers 0

#include <Canvas\Canvas.mqh>

#define MS_COUNT 14
#define PFX      "MSI_"

//--- enums
enum ENUM_MS_DRAW
  {
   MS_DRAW_LINES = 0, // Vertical lines
   MS_DRAW_BOXES = 1  // Lines + boxes (boxes = 50% lighter shade of the line colour)
  };

enum ENUM_MS_BOX
  {
   MS_BOX_OVERLAP = 0, // Overlap (every box full chart height)
   MS_BOX_STACKED = 1  // Stacked (each market gets its own band, no overlap)
  };

enum ENUM_MS_DST
  {
   MS_DST_NONE = 0, // No DST
   MS_DST_US   = 1, // US rules
   MS_DST_EU   = 2, // EU rules
   MS_DST_AU   = 3  // Australia (southern) rules
  };

enum ENUM_MS_OFFSET
  {
   MS_OFF_AUTO   = 0, // Auto-detect (server time vs PC clock)
   MS_OFF_MANUAL = 1  // Manual
  };

//+------------------------------------------------------------------+
//| INPUTS                                                            |
//+------------------------------------------------------------------+
input group "=== Time zone ==="
input ENUM_MS_OFFSET InpOffsetMode = MS_OFF_AUTO; // Broker GMT offset mode
input double InpBrokerGMT    = 2.0;    // Manual: broker GMT offset in WINTER/standard time (hours)
input ENUM_MS_DST InpBrokerDST = MS_DST_US; // Manual: broker adds +1h during this DST (US = NY-close brokers)
input int    InpFineMinutes  = 0;      // Fine-tune: minutes added to the offset (+/-)
input bool   InpAutoDST      = true;   // Apply daylight saving automatically
input bool   InpSkipWeekends = true;   // Skip Saturday / Sunday sessions

input group "=== Chart drawing ==="
input ENUM_MS_DRAW InpDrawMode  = MS_DRAW_LINES; // Start state: lines only or lines + boxes. The GUI "Boxes" button toggles boxes live
input bool   InpShowCloseLine   = true;          // Draw close lines (start state - the GUI button toggles it live)
input int    InpOpenWidth       = 2;             // Open line width (whole pixels only)
input int    InpCloseWidth      = 1;             // Close line width (MT5 draws dash/dot only at width 1)
input ENUM_LINE_STYLE InpOpenStyle  = STYLE_SOLID; // Open line style
input ENUM_LINE_STYLE InpCloseStyle = STYLE_DASH;  // Close line style
input bool   InpSnapOpenToBar   = true;          // Snap open lines to the first bar at/after the open time
input bool   InpTransparentLines = true;         // Semi-transparent lines (candle highs/lows show through). Off = classic solid lines
input int    InpLineOpacity     = 55;            // Line opacity in % (lower = more transparent). Used when transparent lines are on
input bool   InpBehind          = false;         // Classic (non-transparent) mode only: close lines behind candles
input ENUM_MS_BOX InpBoxLayout  = MS_BOX_STACKED;// Boxes mode: overlap or stacked
input bool   InpBoxFilled       = true;          // Boxes mode: filled (turn off if overlapping)
input int    InpDaysBack        = 1;             // Days of past sessions to draw (minimum)
input bool   InpLinesToChartStart = true;        // Repeat sessions back as far as the chart is visible (scrolling back extends them)
input int    InpMaxDaysBack     = 90;            // Safety cap for the above (days back). Raise for very zoomed-out charts
input int    InpDaysForward     = 2;             // Days of future sessions to draw
input bool   InpFutureNextOnly  = true;          // Only the NEXT upcoming session of each market (no 2nd future copy)

input group "=== Chart look ==="
input bool   InpWhiteChart      = true;          // Set chart to colour-on-white, grid hidden (grid colour black). Original look restored when the indicator is removed

input group "=== Labels on chart ==="
input bool   InpShowLabels      = false;         // Start state: chart labels visible (off = hidden). The GUI "Labels" button toggles them
input bool   InpShowCloseLabels = false;         // Extra "closes in" chart label at close of the next not-yet-open market
input bool   InpShowTimeTags    = false;         // Start state: show open-close times [HH:MM-HH:MM] inside the chart labels. GUI button toggles it
input bool   InpLabelsAtTop     = true;          // Start state: labels + open/close markers at the TOP of the chart (off = bottom, markers then sit on the very bottom edge). GUI button toggles it
input bool   InpLabelsVertical  = false;         // Start state: vertical chart labels. GUI button toggles it
input int    InpVertLabelMax    = 100;           // Vertical labels: max label length in px (longer text is cut and ends with ...)
input bool   InpShowButtons     = true;          // Show the quick-click GUI buttons
input int    InpLabelFontSize   = 8;             // Label text size
input string InpLabelFont       = "Arial";       // Label font
input bool   InpLabelAutoText   = false;         // Auto black/white label text (off = always the colour below)
input color  InpLabelTextColor  = clrBlack;      // Label text colour (used when auto is off)
input int    InpLabelPad        = 4;             // Label padding (px)
input bool   InpLabelSeconds    = false;         // Show seconds in labels
input int    InpLaneMargin      = 2;             // Gap between chart labels and the top edge of the chart (px)
input int    InpBottomReserve   = 24;            // Bottom mode: keep chart labels this many px above the bottom edge (time axis)

input group "=== Forward scrolling ==="
input bool   InpForwardScroll   = true;          // Enable chart shift / future space
input int    InpShiftPercent    = 25;            // Open space on the right in % of the chart width (10-50). 0 = derive it from the hours below
input int    InpScrollHours     = 12;            // Only when the % above is 0: hours of future space to make available
input bool   InpAutoZoom        = true;          // Only when the % above is 0: zoom out automatically if needed to fit
input int    InpChartScale      = 2;             // Chart zoom level applied on first attach (0-5; 2 = about 33% of the zoom range). -1 = leave as is
input ENUM_TIMEFRAMES InpDefaultTF = PERIOD_M5;  // Timeframe switched to on first attach (Current = don't switch)

input group "=== Info panel ==="
input bool   InpShowPanel       = true;          // Show panel
input ENUM_BASE_CORNER InpPanelCorner = CORNER_LEFT_UPPER; // Panel corner
input int    InpPanelX          = 10;            // Panel X distance
input int    InpPanelY          = 25;            // Panel Y distance
input bool   InpAutoFit         = true;          // Initial size: automatically fit ALL text and ALL enabled markets (width/height below then act as minimums)
input int    InpPanelW          = 300;           // Panel width (px) - minimum when auto-fit is on
input int    InpPanelH          = 200;           // Panel height (px) - minimum when auto-fit is on
input bool   InpResizable       = true;          // Drag the corner handle to resize
input bool   InpRememberSize    = true;          // Remember resized size per chart
input int    InpPanelFontSize   = 8;             // Panel text size
input string InpPanelFont       = "Arial";       // Panel font
input color  InpPanelBg         = C'25,28,36';   // Panel background
input color  InpPanelBorder     = clrDimGray;    // Panel border
input color  InpPanelText       = clrSilver;     // Panel text colour
input color  InpPanelHeaderText = clrWhite;      // Panel header text colour
input color  InpActiveBg        = C'20,90,45';   // Active session row background
input color  InpActiveText      = clrWhite;      // Active session row text
input bool   InpPanelSort       = true;          // Sort: active first, then soonest to open

//--- Markets (times = UTC standard time, HH:MM)
input group "New York"
input bool   NY_On    = true;
input string NY_Name  = "New York";
input string NY_Open  = "13:00";
input string NY_Close = "22:00";
input color  NY_Clr   = clrDodgerBlue;
input double NY_Adj   = 0.0;      // Extra hours shift

input group "Shanghai"
input bool   SH_On    = true;
input string SH_Name  = "Shanghai";
input string SH_Open  = "01:00";
input string SH_Close = "09:00";
input color  SH_Clr   = clrRed;
input double SH_Adj   = 0.0;

input group "Euronext"
input bool   EU_On    = true;
input string EU_Name  = "Euronext";
input string EU_Open  = "06:00";
input string EU_Close = "15:30";
input color  EU_Clr   = clrMediumOrchid;
input double EU_Adj   = 0.0;

input group "Tokyo"
input bool   TK_On    = true;
input string TK_Name  = "Tokyo";
input string TK_Open  = "00:00";
input string TK_Close = "09:00";
input color  TK_Clr   = clrHotPink;
input double TK_Adj   = 0.0;

input group "Shenzhen"
input bool   SZ_On    = true;
input string SZ_Name  = "Shenzhen";
input string SZ_Open  = "01:30";
input string SZ_Close = "07:00";
input color  SZ_Clr   = clrOrange;
input double SZ_Adj   = 0.0;

input group "Mumbai"
input bool   MB_On    = true;
input string MB_Name  = "Mumbai";
input string MB_Open  = "03:30";
input string MB_Close = "11:30";
input color  MB_Clr   = clrGoldenrod;
input double MB_Adj   = 0.0;

input group "Hong Kong"
input bool   HK_On    = true;
input string HK_Name  = "Hong Kong";
input string HK_Open  = "01:00";
input string HK_Close = "09:00";
input color  HK_Clr   = clrTurquoise;
input double HK_Adj   = 0.0;

input group "London"
input bool   LN_On    = true;
input string LN_Name  = "London";
input string LN_Open  = "08:00";
input string LN_Close = "17:00";
input color  LN_Clr   = clrSpringGreen;
input double LN_Adj   = 0.0;

input group "Toronto"
input bool   TO_On    = true;
input string TO_Name  = "Toronto";
input string TO_Open  = "13:00";
input string TO_Close = "22:00";
input color  TO_Clr   = clrSienna;
input double TO_Adj   = 0.0;

input group "Zurich"
input bool   ZR_On    = true;
input string ZR_Name  = "Zurich";
input string ZR_Open  = "08:00";
input string ZR_Close = "16:00";
input color  ZR_Clr   = clrSalmon;
input double ZR_Adj   = 0.0;

input group "Frankfurt"
input bool   FR_On    = true;
input string FR_Name  = "Frankfurt";
input string FR_Open  = "07:00";
input string FR_Close = "15:00";
input color  FR_Clr   = clrYellow;
input double FR_Adj   = 0.0;

input group "Sydney"
input bool   SY_On    = true;
input string SY_Name  = "Sydney";
input string SY_Open  = "21:00";
input string SY_Close = "06:00";
input color  SY_Clr   = clrDarkKhaki;
input double SY_Adj   = 0.0;

input group "Custom market 1 (optional)"
input bool   C1_On    = false;
input string C1_Name  = "Custom 1";
input string C1_Open  = "12:00";
input string C1_Close = "20:00";
input color  C1_Clr   = clrWhite;
input double C1_Adj   = 0.0;
input ENUM_MS_DST C1_DST = MS_DST_NONE;

input group "Custom market 2 (optional)"
input bool   C2_On    = false;
input string C2_Name  = "Custom 2";
input string C2_Open  = "22:00";   // may wrap past midnight
input string C2_Close = "06:00";
input color  C2_Clr   = clrViolet;
input double C2_Adj   = 0.0;
input ENUM_MS_DST C2_DST = MS_DST_NONE;

//+------------------------------------------------------------------+
//| GLOBALS                                                           |
//+------------------------------------------------------------------+
struct SMarket
  {
   bool   on;
   string name;
   int    openSec;
   int    closeSec;
   color  clr;
   double adj;
   int    dst;
  };

struct SSess
  {
   int      mk;
   datetime o;
   datetime c;
   datetime od;    // where the open line is actually drawn (snapped)
   bool     nxt;   // true = the next not-yet-open session of this market
  };

SMarket  g_mk[MS_COUNT];
SSess    g_ss[];
int      g_ssN     = 0;
int      g_prevN   = 0;

datetime g_utcNow  = 0;
long     g_offSec  = 0;
datetime g_nowB    = 0;
datetime g_lastTc   = 0;   // server timestamp of the latest tick seen
ulong    g_lastTcMs = 0;   // local ms counter when that tick was first seen

// panel geometry / state
int      g_pw = 300, g_ph = 200;
int      g_px = 0, g_py = 0;
int      g_hx = 0, g_hy = 0, g_hs = 12;
int      g_edgeX = 0, g_edgeY = 0;
bool     g_left = true, g_upper = true;
bool     g_drag = false, g_locked = false, g_userScroll = true;

// label lane layout scratch
struct SLbl
  {
   string name;
   string txt;    // text as drawn (may be shortened in vertical mode)
   string full;   // complete text (tooltip)
   color  clr;
   int    x1;
   int    x2;
   int    w;
   int    h;
   int    row;
   bool   vis;
  };
SLbl     g_lb[];          // on-chart labels
int      g_lbN = 0;
int      g_lblBase = 0;   // lowest y available to chart labels (just above the strip)
int      g_W = 0, g_H = 0, g_lh = 16, g_txtH = 12;
int      g_maxRows = 1, g_capH = 100;
int      g_by = 0, g_by2 = 0, g_pbot = 0;                      // y of the top / bottom button rows, panel bottom
double   g_lineTop = 0, g_lineBot = 0;                         // price span of the session lines
double   g_pmax = 0, g_pmin = 0, g_pmid = 0;
bool     g_zDirty = false;        // a line was (re)created -> re-create labels/panel so they sit on top
bool     g_showClose = true, g_lblTop = false, g_lblVert = false, g_showTags = true, g_hideLbl = true, g_showBoxes = false;   // live GUI toggles

int      g_backUsed = 0;          // days back the sessions currently cover

// open markers (triangle + stacked rectangles at the chart edge, one stack per distinct open time)
int      g_mgN = 0;               // number of marker stacks
int      g_mgX[];                 // x pixel of each stack
int      g_mgCnt[];               // markets opening there
int      g_mgY1[], g_mgY2[];      // vertical extent (hit-test)
string   g_mgTip[];               // tooltip rows joined by newline
color    g_mgClr[];               // colours, MK_CAP per stack
int      g_mgCls[];               // 1 = this item is a session CLOSE (0 = open), MK_CAP per stack
int      g_mkOff = 0;             // height reserved for the markers (labels move away from the edge by this)
int      g_mkPrevN = 0;
int      g_mkPrevRects[];

// chart properties changed by the white scheme (originals are saved so they can be restored)
int g_lookProps[] = {CHART_COLOR_BACKGROUND, CHART_COLOR_FOREGROUND, CHART_COLOR_GRID, CHART_COLOR_CHART_UP,
                     CHART_COLOR_CHART_DOWN, CHART_COLOR_CANDLE_BULL, CHART_COLOR_CANDLE_BEAR,
                     CHART_COLOR_CHART_LINE, CHART_SHOW_GRID};

// hover description for the transparent lines
string   g_lnTip[];          // description per painted line (parallel to the line list)
int      g_hvX[];            // x pixel per painted line
int      g_hvN    = 0;
int      g_hvRows = 0;       // rows of the hover box currently shown

// transparent line overlay (one ARGB bitmap covering the chart area)
CCanvas  g_cv;
bool     g_cvOk  = false;
int      g_cvW   = 0, g_cvH = 0;
string   g_cvSig = "";

#define LANE_PAD 2
#define BTN_H    18
#define MK_TRI   12      // open-marker: height of the triangle slot (px)
#define MK_RECT  6       // open-marker: height of one stacked rectangle slot (px)
#define MK_MAXSTACK 8    // markers: max objects drawn per stack (triangle + rectangles)
#define MK_CAP   (2 * MS_COUNT)   // markers: max open+close events kept per stack
#define BTN_W    150

//+------------------------------------------------------------------+
//| Helpers: time                                                     |
//+------------------------------------------------------------------+
int ParseHM(string s)
  {
   StringTrimLeft(s);
   StringTrimRight(s);
   string p[];
   if(StringSplit(s, ':', p) != 2)
      return -1;
   int h = (int)StringToInteger(p[0]);
   int m = (int)StringToInteger(p[1]);
   if(h < 0 || h > 24 || m < 0 || m > 59)
      return -1;
   return h * 3600 + m * 60;
  }

datetime MkDate(int y, int m, int d)
  {
   MqlDateTime s;
   s.year = y; s.mon = m; s.day = d;
   s.hour = 0; s.min = 0; s.sec = 0;
   s.day_of_week = 0; s.day_of_year = 0;
   return StructToTime(s);
  }

int DowOf(datetime t)
  {
   return (int)((((long)t) / 86400 + 4) % 7);   // 0 = Sunday
  }

int NthSunday(int y, int m, int n)
  {
   int dow   = DowOf(MkDate(y, m, 1));
   int first = 1 + (7 - dow) % 7;
   return first + 7 * (n - 1);
  }

int LastSunday31(int y, int m)   // months with 31 days (Mar, Oct)
  {
   int dow = DowOf(MkDate(y, m, 31));
   return 31 - dow;
  }

bool IsDST(int rule, datetime t)
  {
   if(rule == MS_DST_NONE)
      return false;
   MqlDateTime s;
   TimeToStruct(t, s);
   int y = s.year;
   datetime a, b;
   switch(rule)
     {
      case MS_DST_EU:
         a = MkDate(y, 3, LastSunday31(y, 3));
         b = MkDate(y, 10, LastSunday31(y, 10));
         return (t >= a && t < b);
      case MS_DST_US:
         a = MkDate(y, 3, NthSunday(y, 3, 2));
         b = MkDate(y, 11, NthSunday(y, 11, 1));
         return (t >= a && t < b);
      case MS_DST_AU:
         a = MkDate(y, 10, NthSunday(y, 10, 1));
         b = MkDate(y, 4, NthSunday(y, 4, 1));
         return (t >= a || t < b);
     }
   return false;
  }

string Dur(long s, bool withSec)
  {
   if(s < 0) s = 0;
   if(!withSec && s < 86400)
      s = ((s + 59) / 60) * 60;      // round up to whole minutes
   long d  = s / 86400;
   long h  = (s % 86400) / 3600;
   long m  = (s % 3600) / 60;
   long ss = s % 60;
   if(d > 0)
      return StringFormat("%dd %dh", (int)d, (int)h);
   if(withSec)
      return StringFormat("%d:%02d:%02d", (int)h, (int)m, (int)ss);
   return StringFormat("%dh %02dm", (int)h, (int)m);
  }

string OffStr()
  {
   long m = g_offSec / 60;
   string sg = (m < 0) ? "-" : "+";
   m = MathAbs(m);
   string r = "GMT" + sg + IntegerToString((int)(m / 60));
   if(m % 60 != 0)
      r += StringFormat(":%02d", (int)(m % 60));
   return r;
  }

color TextFor(color c)
  {
   int r = (int)(c & 0xFF);
   int g = (int)((c >> 8) & 0xFF);
   int b = (int)((c >> 16) & 0xFF);
   double l = 0.299 * r + 0.587 * g + 0.114 * b;
   return (l > 140.0) ? clrBlack : clrWhite;
  }

//+------------------------------------------------------------------+
//| Markets                                                           |
//+------------------------------------------------------------------+
void SetMk(int i, bool on, string nm, string o, string c, color clr, double adj, int dst)
  {
   g_mk[i].on   = on;
   g_mk[i].name = nm;
   g_mk[i].openSec  = ParseHM(o);
   g_mk[i].closeSec = ParseHM(c);
   g_mk[i].clr  = clr;
   g_mk[i].adj  = adj;
   g_mk[i].dst  = dst;
   if(on && (g_mk[i].openSec < 0 || g_mk[i].closeSec < 0))
     {
      PrintFormat("Market Session Pro+: invalid time for %s (use HH:MM). Market disabled.", nm);
      g_mk[i].on = false;
     }
  }

void LoadMarkets()
  {
   SetMk(0,  NY_On, NY_Name, NY_Open, NY_Close, NY_Clr, NY_Adj, MS_DST_US);
   SetMk(1,  SH_On, SH_Name, SH_Open, SH_Close, SH_Clr, SH_Adj, MS_DST_NONE);
   SetMk(2,  EU_On, EU_Name, EU_Open, EU_Close, EU_Clr, EU_Adj, MS_DST_EU);
   SetMk(3,  TK_On, TK_Name, TK_Open, TK_Close, TK_Clr, TK_Adj, MS_DST_NONE);
   SetMk(4,  SZ_On, SZ_Name, SZ_Open, SZ_Close, SZ_Clr, SZ_Adj, MS_DST_NONE);
   SetMk(5,  MB_On, MB_Name, MB_Open, MB_Close, MB_Clr, MB_Adj, MS_DST_NONE);
   SetMk(6,  HK_On, HK_Name, HK_Open, HK_Close, HK_Clr, HK_Adj, MS_DST_NONE);
   SetMk(7,  LN_On, LN_Name, LN_Open, LN_Close, LN_Clr, LN_Adj, MS_DST_EU);
   SetMk(8,  TO_On, TO_Name, TO_Open, TO_Close, TO_Clr, TO_Adj, MS_DST_US);
   SetMk(9,  ZR_On, ZR_Name, ZR_Open, ZR_Close, ZR_Clr, ZR_Adj, MS_DST_EU);
   SetMk(10, FR_On, FR_Name, FR_Open, FR_Close, FR_Clr, FR_Adj, MS_DST_EU);
   SetMk(11, SY_On, SY_Name, SY_Open, SY_Close, SY_Clr, SY_Adj, MS_DST_AU);
   SetMk(12, C1_On, C1_Name, C1_Open, C1_Close, C1_Clr, C1_Adj, C1_DST);
   SetMk(13, C2_On, C2_Name, C2_Open, C2_Close, C2_Clr, C2_Adj, C2_DST);
  }

void TrackTick()
  {
   datetime tc = TimeCurrent();
   if(tc != g_lastTc)
     {
      g_lastTc   = tc;
      g_lastTcMs = GetTickCount64();
     }
  }

void UpdateClock()
  {
   // Reference clock = SERVER time. TimeTradeServer() is derived from the PC clock, so a PC that
   // is 1-2 minutes off makes every countdown and line disagree with the candles. Instead we follow
   // the server timestamp of the latest tick (TimeCurrent) and advance it with a local ms counter.
   TrackTick();
   datetime srv   = (datetime)((long)g_lastTc + (long)((GetTickCount64() - g_lastTcMs) / 1000));
   datetime pcSrv = TimeTradeServer();
   if(g_lastTc == 0 || ((long)pcSrv - (long)srv) > 120)   // no recent ticks (quiet/closed): fall back
      srv = (pcSrv != 0) ? pcSrv : TimeCurrent();
   long off;
   if(InpOffsetMode == MS_OFF_AUTO)
     {
      double d = (double)((long)srv - (long)TimeGMT());
      off = (long)(MathRound(d / 900.0) * 900.0);
     }
   else
     {
      long std = (long)MathRound(InpBrokerGMT * 3600.0);
      off = std + (IsDST(InpBrokerDST, (datetime)((long)srv - std)) ? 3600 : 0);
     }
   off += (long)InpFineMinutes * 60;
   g_offSec = off;
   g_nowB   = srv;
   g_utcNow = (datetime)((long)srv - off);
  }

// Session of market i on UTC base day (today + k). Times returned in broker/chart time.
bool GetSession(int i, int k, datetime &o, datetime &c)
  {
   long day  = ((long)g_utcNow) / 86400 + k;
   long base = day * 86400;
   int os = g_mk[i].openSec;
   int cs = g_mk[i].closeSec;
   if(cs <= os) cs += 86400;
   long adj = (long)MathRound(g_mk[i].adj * 3600.0);
   // Weekday and DST are judged at the session midpoint, so a session that starts on
   // Sunday evening UTC (e.g. Sydney Monday morning) is treated as a Monday session.
   long midStd = base + (os + cs) / 2 + adj;
   int  dow    = (int)(((midStd / 86400) + 4) % 7);
   if(InpSkipWeekends && (dow == 0 || dow == 6))
      return false;
   int dst = (InpAutoDST && IsDST(g_mk[i].dst, (datetime)midStd)) ? 3600 : 0;
   o = (datetime)(base + os - dst + adj + g_offSec);
   c = (datetime)(base + cs - dst + adj + g_offSec);
   return true;
  }

// remain = seconds to close if active, else seconds to next open (-1 if none)
void GetState(int i, bool &active, long &remain)
  {
   active = false;
   remain = -1;
   datetime o, c;
   long best = LONG_MAX;
   for(int k = -2; k <= 6; k++)
     {
      if(!GetSession(i, k, o, c))
         continue;
      if(g_nowB >= o && g_nowB < c)
        {
         active = true;
         remain = (long)(c - g_nowB);
         return;
        }
      if(o > g_nowB && (long)(o - g_nowB) < best)
         best = (long)(o - g_nowB);
     }
   if(best != LONG_MAX)
      remain = best;
  }

void BuildSessions()
  {
   int back = MathMax(0, InpDaysBack);
   int fwd  = MathMax(0, InpDaysForward);
   if(InpLinesToChartStart)
     {
      // reach back to the leftmost visible bar
      int fv = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
      datetime tl = iTime(_Symbol, _Period, fv);
      if(tl > 0 && tl < g_nowB)
         back = MathMax(back, (int)MathMin((double)MathMax(1, InpMaxDaysBack),
                                           MathCeil((double)(g_nowB - tl) / 86400.0)));
     }
   g_backUsed = back;
   ArrayResize(g_ss, MS_COUNT * (back + fwd + 4));
   g_ssN = 0;
   long from = (long)g_nowB - (long)back * 86400;
   long to   = (long)g_nowB + MathMax((long)fwd * 86400, (long)InpScrollHours * 3600 + 3600);
   datetime o, c;
   for(int i = 0; i < MS_COUNT; i++)
     {
      if(!g_mk[i].on) continue;
      for(int k = -(back + 1); k <= fwd + 1; k++)
        {
         if(!GetSession(i, k, o, c)) continue;
         if((long)c < from || (long)o > to) continue;
         g_ss[g_ssN].mk  = i;
         g_ss[g_ssN].o   = o;
         g_ss[g_ssN].c   = c;
         g_ss[g_ssN].od  = o;
         g_ss[g_ssN].nxt = false;
         g_ssN++;
        }
     }

   // Forward limit: per market only ONE not-yet-open session is "next".
   int best[MS_COUNT];
   for(int i = 0; i < MS_COUNT; i++)
      best[i] = -1;
   for(int n = 0; n < g_ssN; n++)
      if(g_ss[n].o > g_nowB)
        {
         int m = g_ss[n].mk;
         if(best[m] < 0 || g_ss[n].o < g_ss[best[m]].o)
            best[m] = n;
        }
   int w = 0;
   for(int n = 0; n < g_ssN; n++)
     {
      bool fut = (g_ss[n].o > g_nowB);
      bool nx  = (best[g_ss[n].mk] == n);
      if(fut && !nx && InpFutureNextOnly)
         continue;
      if(w != n)
         g_ss[w] = g_ss[n];
      g_ss[w].nxt = nx;
      w++;
     }
   g_ssN = w;
  }

//+------------------------------------------------------------------+
//| Object helpers                                                    |
//+------------------------------------------------------------------+
void HideObj(string n)
  {
   if(ObjectFind(0, n) >= 0)
      ObjectSetInteger(0, n, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
  }

void EnsureEdit(string n, int win = 0)
  {
   if(ObjectFind(0, n) >= 0) return;
   ObjectCreate(0, n, OBJ_EDIT, win, 0, 0);
   ObjectSetInteger(0, n, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, n, OBJPROP_READONLY, true);
   ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, n, OBJPROP_HIDDEN, true);
  }

void EnsureRect(string n, int win = 0)
  {
   if(ObjectFind(0, n) >= 0) return;
   ObjectCreate(0, n, OBJ_RECTANGLE_LABEL, win, 0, 0);
   ObjectSetInteger(0, n, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, n, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, n, OBJPROP_HIDDEN, true);
  }

void PutEdit(string n, int x, int y, int w, int h, string txt, color tc, color bg, color bd,
             int fs, string font, ENUM_ALIGN_MODE al, int win = 0)
  {
   EnsureEdit(n, win);
   ObjectSetInteger(0, n, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
   ObjectSetInteger(0, n, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, n, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, n, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, n, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, n, OBJPROP_COLOR, tc);
   ObjectSetInteger(0, n, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, n, OBJPROP_BORDER_COLOR, bd);
   ObjectSetInteger(0, n, OBJPROP_FONTSIZE, fs);
   ObjectSetInteger(0, n, OBJPROP_ALIGN, al);
   ObjectSetString(0, n, OBJPROP_FONT, font);
   ObjectSetString(0, n, OBJPROP_TEXT, txt);
  }

void PutRect(string n, int x, int y, int w, int h, color bg, color bd, int win = 0)
  {
   EnsureRect(n, win);
   ObjectSetInteger(0, n, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
   ObjectSetInteger(0, n, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, n, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, n, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, n, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, n, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, n, OBJPROP_COLOR, bd);
  }

//+------------------------------------------------------------------+
//| Extra object helpers (rotated text, buttons)                      |
//+------------------------------------------------------------------+
void EnsureText(string n)
  {
   if(ObjectFind(0, n) >= 0) return;
   ObjectCreate(0, n, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, n, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, n, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
   ObjectSetDouble(0, n, OBJPROP_ANGLE, 90.0);
   ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, n, OBJPROP_HIDDEN, true);
  }

// Rotated (reads bottom-to-top) text. Anchor = upper-left of the un-rotated text, so the text
// grows UPWARD from (x,y) and its body extends to the RIGHT of x.
void PutTextV(string n, int x, int y, string txt, color tc)
  {
   EnsureText(n);
   ObjectSetInteger(0, n, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
   ObjectSetInteger(0, n, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, n, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, n, OBJPROP_COLOR, tc);
   ObjectSetInteger(0, n, OBJPROP_FONTSIZE, InpLabelFontSize);
   ObjectSetString(0, n, OBJPROP_FONT, InpLabelFont);
   ObjectSetString(0, n, OBJPROP_TEXT, txt);
  }

void PutButton(string n, int x, int y, int w, int h, string txt, color bg, string tip)
  {
   if(ObjectFind(0, n) < 0)
     {
      ObjectCreate(0, n, OBJ_BUTTON, 0, 0, 0);
      ObjectSetInteger(0, n, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, n, OBJPROP_HIDDEN, true);
     }
   ObjectSetInteger(0, n, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
   ObjectSetInteger(0, n, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, n, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, n, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, n, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, n, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, n, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, n, OBJPROP_BORDER_COLOR, clrDimGray);
   ObjectSetInteger(0, n, OBJPROP_FONTSIZE, 8);
   ObjectSetString(0, n, OBJPROP_FONT, "Arial");
   ObjectSetString(0, n, OBJPROP_TEXT, txt);
   ObjectSetString(0, n, OBJPROP_TOOLTIP, tip);
   ObjectSetInteger(0, n, OBJPROP_STATE, false);
  }

//+------------------------------------------------------------------+
//| Chart forward scrolling                                           |
//+------------------------------------------------------------------+
void SetupChartScroll(bool applyScale)
  {
   if(!InpForwardScroll)
      return;
   ChartSetInteger(0, CHART_SHIFT, true);
   if(applyScale && InpChartScale >= 0)
      ChartSetInteger(0, CHART_SCALE, MathMin(5, InpChartScale));

   if(InpShiftPercent >= 10)
     {
      // fixed open space on the right, as a % of the chart width
      ChartSetDouble(0, CHART_SHIFT_SIZE, MathMin(50, InpShiftPercent));
     }
   else
     {
      // open space derived from InpScrollHours
      double ahead = MathMax(1.0, InpScrollHours * 3600.0 / (double)PeriodSeconds()) + 2.0;
      int oldScale = (int)ChartGetInteger(0, CHART_SCALE);
      int scale    = oldScale;
      double vis   = (double)ChartGetInteger(0, CHART_WIDTH_IN_BARS);
      if(vis < 10) vis = 10;

      if(InpAutoZoom)
         while(scale > 0 && vis * 0.5 < ahead)
           {
            scale--;
            vis *= 2.0;
           }
      if(scale != oldScale)
         ChartSetInteger(0, CHART_SCALE, scale);

      double pct = MathCeil(ahead / vis * 100.0);
      pct = MathMax(10.0, MathMin(50.0, pct));
      ChartSetDouble(0, CHART_SHIFT_SIZE, pct);

      if(ahead > vis * 0.5)
         PrintFormat("Market Session Pro+: %d h ahead does not fully fit on %s at the smallest zoom "
                     "(max 50%% chart shift). Use a higher timeframe to see the full range.",
                     InpScrollHours, EnumToString((ENUM_TIMEFRAMES)Period()));
     }

   ChartNavigate(0, CHART_END, 0);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Session drawing                                                   |
//+------------------------------------------------------------------+
// MT5 has no bars while a symbol is not trading, so an object placed in such a gap is drawn on
// the last bar BEFORE it (e.g. yesterday's final minute). Move the open to the first bar at/after it.
datetime SnapOpen(datetime t)
  {
   if(!InpSnapOpenToBar) return t;
   datetime last = iTime(_Symbol, _Period, 0);
   if(last == 0 || t >= last) return t;
   int sh = iBarShift(_Symbol, _Period, t, false);
   if(sh < 0) return t;
   datetime bt = iTime(_Symbol, _Period, sh);
   if(bt == 0 || t < bt + PeriodSeconds()) return t;   // t falls inside a bar
   if(sh > 0) return iTime(_Symbol, _Period, sh - 1);   // gap: use next existing bar
   return t;
  }

void PutVLine(string n, datetime t, color c, ENUM_LINE_STYLE st, int w, bool back, string tip, bool full)
  {
   if(ObjectFind(0, n) < 0)
     {
      ObjectCreate(0, n, OBJ_TREND, 0, t, g_lineTop, t, g_lineBot);
      ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, n, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, n, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, n, OBJPROP_RAY_LEFT, false);
      g_zDirty = true;   // newest object is drawn on top: labels/panel must be re-created after it
      full = true;
     }
   // both points every time so the line keeps spanning the chart when the price scale changes
   ObjectSetInteger(0, n, OBJPROP_TIME, 0, t);
   ObjectSetDouble(0, n, OBJPROP_PRICE, 0, g_lineTop);
   ObjectSetInteger(0, n, OBJPROP_TIME, 1, t);
   ObjectSetDouble(0, n, OBJPROP_PRICE, 1, g_lineBot);
   if(full)
     {
      ObjectSetInteger(0, n, OBJPROP_COLOR, c);
      ObjectSetInteger(0, n, OBJPROP_STYLE, st);
      ObjectSetInteger(0, n, OBJPROP_WIDTH, MathMax(1, w));
      ObjectSetInteger(0, n, OBJPROP_BACK, back);
      ObjectSetString(0, n, OBJPROP_TOOLTIP, tip);
     }
  }

void PutBox(string n, datetime t1, double p1, datetime t2, double p2, color c, string tip, bool full)
  {
   bool exists = (ObjectFind(0, n) >= 0);
   if(!exists)
     {
      ObjectCreate(0, n, OBJ_RECTANGLE, 0, t1, p1, t2, p2);
      ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, n, OBJPROP_HIDDEN, true);
      full = true;
     }
   ObjectSetInteger(0, n, OBJPROP_TIME, 0, t1);
   ObjectSetDouble(0, n, OBJPROP_PRICE, 0, p1);
   ObjectSetInteger(0, n, OBJPROP_TIME, 1, t2);
   ObjectSetDouble(0, n, OBJPROP_PRICE, 1, p2);
   if(full)
     {
      ObjectSetInteger(0, n, OBJPROP_COLOR, c);
      ObjectSetInteger(0, n, OBJPROP_FILL, InpBoxFilled);
      ObjectSetInteger(0, n, OBJPROP_BACK, true);
      ObjectSetInteger(0, n, OBJPROP_WIDTH, 1);
      ObjectSetString(0, n, OBJPROP_TOOLTIP, tip);
     }
  }

// 50% lighter shade: each RGB channel moves half-way to white
color Lighten50(color c)
  {
   int r = (int)(c & 0xFF);
   int g = (int)((c >> 8) & 0xFF);
   int b = (int)((c >> 16) & 0xFF);
   r += (255 - r) / 2;
   g += (255 - g) / 2;
   b += (255 - b) / 2;
   return (color)(r | (g << 8) | (b << 16));
  }

void DelLbl(string n)
  {
   ObjectDelete(0, n);
   ObjectDelete(0, n + "T");   // rotated text part (vertical mode)
  }

void DelSess(int n)
  {
   string b = PFX + "S" + IntegerToString(n);
   ObjectDelete(0, b + "_O");
   ObjectDelete(0, b + "_C");
   ObjectDelete(0, b + "_B");
   ObjectDelete(0, b + "_BT");
   DelLbl(b + "_LO");
   DelLbl(b + "_LC");
  }

// Removes everything that must sit ABOVE the lines, so it is re-created after them.
void DeleteUiObjects()
  {
   ObjectsDeleteAll(0, PFX + "S", -1, OBJ_EDIT);
   ObjectsDeleteAll(0, PFX + "S", -1, OBJ_RECTANGLE_LABEL);
   ObjectsDeleteAll(0, PFX + "S", -1, OBJ_LABEL);
   ObjectsDeleteAll(0, PFX + "P_");
   ObjectsDeleteAll(0, PFX + "B_");
  }

void CalcGeom()
  {
   g_W    = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   g_H    = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   g_pmax = ChartGetDouble(0, CHART_PRICE_MAX, 0);
   g_pmin = ChartGetDouble(0, CHART_PRICE_MIN, 0);
   g_pmid = (g_pmax + g_pmin) * 0.5;
   double rng = MathMax(g_pmax - g_pmin, _Point * 10);
   g_lineTop = g_pmax + 3.0 * rng;                 // far beyond the visible range: acts as a full-height line
   g_lineBot = MathMax(0.0, g_pmin - 3.0 * rng);
  }

//+------------------------------------------------------------------+
//| Lines (always) + boxes (optional)                                 |
//+------------------------------------------------------------------+
// One ARGB bitmap covers the chart area; the session lines are painted onto it with an alpha value,
// so candle highs/lows stay visible through them (native MT5 line objects cannot be transparent).
void PaintLines(datetime &lt[], color &lc[], int &ls[], int &lw[], int n)
  {
   if(g_W <= 0 || g_H <= 0)
      return;
   string nm = PFX + "CV";

   if(!g_cvOk || ObjectFind(0, nm) < 0)
     {
      g_cv.Destroy();
      if(!g_cv.CreateBitmapLabel(0, 0, nm, 0, 0, g_W, g_H, COLOR_FORMAT_ARGB_NORMALIZE))
        {
         g_cvOk = false;
         return;
        }
      g_cvOk  = true;
      g_cvW   = g_W;
      g_cvH   = g_H;
      g_cvSig = "";
      ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, nm, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, nm, OBJPROP_BACK, false);
      g_zDirty = true;      // labels / panel must be re-created above the new bitmap
     }
   if(g_W != g_cvW || g_H != g_cvH)
     {
      g_cv.Resize(g_W, g_H);
      g_cvW = g_W;
      g_cvH = g_H;
     }

   // only repaint when something moved (positions, size, set of lines)
   int    xs[];
   ArrayResize(xs, n);
   string sig = IntegerToString(g_W) + "x" + IntegerToString(g_H) + "|" + IntegerToString(InpLineOpacity);
   for(int i = 0; i < n; i++)
     {
      int x = 0, y = 0;
      if(!ChartTimePriceToXY(0, 0, lt[i], g_pmid, x, y))
         x = -100000;
      xs[i] = x;
      sig += "|" + IntegerToString(x) + ":" + IntegerToString(ls[i]) + ":" + IntegerToString(lw[i]) +
             ":" + IntegerToString((int)lc[i]);
     }
   ArrayResize(g_hvX, n);
   for(int i = 0; i < n; i++)
      g_hvX[i] = xs[i];
   g_hvN = n;
   if(sig == g_cvSig)
      return;
   g_cvSig = sig;

   g_cv.Erase(0x00000000);
   uchar a = (uchar)MathRound(255.0 * MathMax(0, MathMin(100, InpLineOpacity)) / 100.0);
   for(int i = 0; i < n; i++)
     {
      int x = xs[i];
      if(x < -10 || x > g_W + 10)
         continue;
      uint col = ColorToARGB(lc[i], a);
      int  wd  = MathMax(1, lw[i]);
      int  x0  = x - (wd - 1) / 2;

      int pat[];
      switch(ls[i])
        {
         case STYLE_DASH:       ArrayResize(pat, 2); pat[0] = 6; pat[1] = 4; break;
         case STYLE_DOT:        ArrayResize(pat, 2); pat[0] = 2; pat[1] = 3; break;
         case STYLE_DASHDOT:    ArrayResize(pat, 4); pat[0] = 6; pat[1] = 3; pat[2] = 2; pat[3] = 3; break;
         case STYLE_DASHDOTDOT: ArrayResize(pat, 6); pat[0] = 6; pat[1] = 3; pat[2] = 2; pat[3] = 3; pat[4] = 2; pat[5] = 3; break;
         default:               ArrayResize(pat, 0);
        }

      for(int k = 0; k < wd; k++)
        {
         if(ArraySize(pat) == 0)
           {
            g_cv.LineVertical(x0 + k, 0, g_H - 1, col);
            continue;
           }
         int y = 0, p = 0, np = ArraySize(pat);
         while(y < g_H)
           {
            int len = pat[p % np];
            if(p % 2 == 0)
               g_cv.LineVertical(x0 + k, y, MathMin(y + len - 1, g_H - 1), col);
            y += len;
            p++;
           }
        }
     }
   g_cv.Update(false);
  }

// Short description of one session line: "New York OPEN (09.29 13:00-22:00)"
string SessTip(int n, bool open)
  {
   int m = g_ss[n].mk;
   datetime o = g_ss[n].o, c = g_ss[n].c;
   return g_mk[m].name + (open ? " OPEN (" : " CLOSE (") + StringSubstr(TimeToString(o, TIME_DATE), 5, 5) + " " +
          TimeToString(o, TIME_MINUTES) + "-" + TimeToString(c, TIME_MINUTES) + ")";
  }

void DrawLines(bool full)
  {
   double pmax = g_pmax, pmin = g_pmin;

   // lines collected for the transparent bitmap
   datetime lt[];
   color    lc[];
   int      ls[], lw[];
   int      ln = 0;
   ArrayResize(lt, g_ssN * 2 + 2);
   ArrayResize(lc, g_ssN * 2 + 2);
   ArrayResize(ls, g_ssN * 2 + 2);
   ArrayResize(lw, g_ssN * 2 + 2);
   ArrayResize(g_lnTip, g_ssN * 2 + 2);

   int band[MS_COUNT];
   int nEn = 0;
   for(int i = 0; i < MS_COUNT; i++)
      band[i] = g_mk[i].on ? nEn++ : -1;
   double bandH = (nEn > 0) ? (pmax - pmin) / nEn : (pmax - pmin);

   for(int n = 0; n < g_ssN; n++)
     {
      int m = g_ss[n].mk;
      datetime o = g_ss[n].o, c = g_ss[n].c;
      datetime oD = SnapOpen(o);   // where the open is drawn
      g_ss[n].od = oD;
      color clr = g_mk[m].clr;
      string b = PFX + "S" + IntegerToString(n);
      string tip = g_mk[m].name + "  " + TimeToString(o, TIME_DATE | TIME_MINUTES) + " - " +
                   TimeToString(c, TIME_DATE | TIME_MINUTES) + " (broker time)";

      // Lines are drawn in BOTH draw modes
      if(InpTransparentLines)
        {
         g_lnTip[ln] = SessTip(n, true);
         lt[ln] = oD; lc[ln] = clr; ls[ln] = (int)InpOpenStyle; lw[ln] = InpOpenWidth; ln++;
         if(g_showClose)
           {
            g_lnTip[ln] = SessTip(n, false);
            lt[ln] = c; lc[ln] = clr; ls[ln] = (int)InpCloseStyle; lw[ln] = InpCloseWidth; ln++;
           }
        }
      else
        {
         PutVLine(b + "_O", oD, clr, InpOpenStyle, InpOpenWidth, false, tip, full);
         if(g_showClose)
            PutVLine(b + "_C", c, clr, InpCloseStyle, InpCloseWidth, InpBehind, tip, full);
         else
            ObjectDelete(0, b + "_C");
        }

      // Boxes are an addition, in a 50% lighter shade of the line colour
      if(g_showBoxes)
        {
         double top = pmax, bot = pmin;
         if(InpBoxLayout == MS_BOX_STACKED && band[m] >= 0)
           {
            top = pmax - band[m] * bandH;
            bot = top - bandH;
           }
         PutBox(b + "_B", oD, top, c, bot, Lighten50(clr), tip, full);
        }
      else
         ObjectDelete(0, b + "_B");
     }

   if(InpTransparentLines)
      PaintLines(lt, lc, ls, lw, ln);

   for(int n = g_ssN; n < g_prevN; n++)
      DelSess(n);
   g_prevN = g_ssN;
  }

//+------------------------------------------------------------------+
//| Chart labels (on the chart) + time-stamp tags (bottom strip)       |
//+------------------------------------------------------------------+
// Shortens txt so it is at most maxW px wide (current TextSetFont) and ends with "..."
string FitText(string txt, int maxW)
  {
   uint w = 0, h = 0;
   maxW = MathMax(10, maxW);
   TextGetSize(txt, w, h);
   if((int)w <= maxW)
      return txt;
   int lo = 0, hi = StringLen(txt);
   while(lo < hi)
     {
      int mid = (lo + hi + 1) / 2;
      TextGetSize(StringSubstr(txt, 0, mid) + "...", w, h);
      if((int)w <= maxW) lo = mid;
      else               hi = mid - 1;
     }
   if(lo <= 0)
      return "...";
   string r = StringSubstr(txt, 0, lo);
   StringTrimRight(r);
   return r + "...";
  }

void AddLabel(string name, datetime t, string txt, color clr, bool alignRight)
  {
   int idx = g_lbN;
   g_lbN++;
   g_lb[idx].name = name;
   g_lb[idx].txt  = txt;
   g_lb[idx].full = txt;
   g_lb[idx].clr  = clr;
   g_lb[idx].vis  = false;
   g_lb[idx].row  = 0;

   int x, y;
   if(!ChartTimePriceToXY(0, 0, t, g_pmid, x, y))
      return;
   uint tw = 0, th = 0;
   TextGetSize(txt, tw, th);

   int w, h;
   if(g_lblVert)
     {
      // vertical labels: never longer than InpVertLabelMax px (and never taller than the chart allows);
      // longer text is cut and ends with "..." instead of disappearing
      int lim = MathMin(MathMax(20, InpVertLabelMax), g_capH);
      string sh = FitText(txt, lim - 2 * InpLabelPad);
      TextGetSize(sh, tw, th);
      g_lb[idx].txt = sh;
      w = g_lh;
      h = (int)tw + 2 * InpLabelPad;
      if(h > g_capH) return;
     }
   else
     {
      w = (int)tw + 2 * InpLabelPad;
      h = g_lh;
     }
   int x1 = alignRight ? x - w - 2 : x + 2;
   int x2 = x1 + w;
   if(x2 < 0 || x1 > g_W)
      return;

   int r = 0;
   if(!g_lblVert)
     {
      // horizontal boxes: next free row (rows grow away from the chart edge)
      while(r < g_maxRows)
        {
         bool conflict = false;
         for(int j = 0; j < idx; j++)
            if(g_lb[j].vis && g_lb[j].row == r && x1 < g_lb[j].x2 + 1 && x2 > g_lb[j].x1 - 1)
              {
               conflict = true;
               break;
              }
         if(!conflict) break;
         r++;
        }
      if(r >= g_maxRows)
         return;
     }
   else
     {
      // vertical boxes are narrow: slide sideways (away from their line) until free
      int step = w + 1;
      int bx1 = x1;
      while(r < 40)
        {
         int sx1 = alignRight ? x1 - r * step : x1 + r * step;
         int sx2 = sx1 + w;
         bool conflict = false;
         for(int j = 0; j < idx; j++)
            if(g_lb[j].vis && sx1 < g_lb[j].x2 + 1 && sx2 > g_lb[j].x1 - 1)
              {
               conflict = true;
               break;
              }
         if(!conflict)
           {
            bx1 = sx1;
            break;
           }
         r++;
        }
      if(r >= 40)
         return;
      x1 = bx1;
      x2 = x1 + w;
      if(x2 < 0 || x1 > g_W)
         return;
     }

   g_lb[idx].x1  = x1;
   g_lb[idx].x2  = x2;
   g_lb[idx].w   = w;
   g_lb[idx].h   = h;
   g_lb[idx].row = r;
   g_lb[idx].vis = true;
  }

void LayoutLabels()
  {
   g_lbN = 0;
   ArrayResize(g_lb, g_ssN * 2 + 2);

   uint tw = 0, th = 0;
   TextSetFont(InpLabelFont, -InpLabelFontSize * 10);
   TextGetSize("Ag", tw, th);
   g_txtH    = (int)th;
   g_lh      = (int)th + 4;
   g_maxRows = MathMax(1, (g_H * 2 / 5) / (g_lh + 1));
   g_capH    = MathMax(40, g_H * 45 / 100);
   g_lblBase = g_H - MathMax(MathMax(InpLaneMargin, InpBottomReserve), g_lblTop ? 0 : g_mkOff + 2);   // labels stay above the time axis / bottom markers
   bool showLbl = !g_hideLbl;

   for(int n = 0; n < g_ssN; n++)
     {
      int m = g_ss[n].mk;
      datetime o = g_ss[n].o, c = g_ss[n].c, oD = g_ss[n].od;
      color clr = g_mk[m].clr;
      string b = PFX + "S" + IntegerToString(n);
      long toO = (long)(o - g_nowB);
      long toC = (long)(c - g_nowB);
      bool started = (toO <= 0);
      bool ended   = (toC <= 0);

      // open-close clock time (chart/broker time), added to the label when "Times" is on
      string tm = g_showTags ? " [" + TimeToString(o, TIME_MINUTES) + "-" + TimeToString(c, TIME_MINUTES) + "]" : "";

      // chart label: started/finished sessions + only the NEXT upcoming session of a market
      if(showLbl && (started || g_ss[n].nxt))
        {
         string t;
         if(!started)     t = g_mk[m].name + " opens " + Dur(toO, InpLabelSeconds) + tm;
         else if(!ended)  t = g_mk[m].name + " open - " + Dur(toC, InpLabelSeconds) + " left" + tm;
         else             t = g_mk[m].name + tm;
         // upcoming markets hang to the right of their open line, started ones to the left
         AddLabel(b + "_LO", oD, t, clr, started);
        }
      else
         DelLbl(b + "_LO");

      if(showLbl && InpShowCloseLabels && !started && g_ss[n].nxt)
        {
         string t2 = g_mk[m].name + " closes " + Dur(toC, InpLabelSeconds);
         if(g_showTags) t2 += " [" + TimeToString(c, TIME_MINUTES) + "]";
         AddLabel(b + "_LC", c, t2, clr, true);
        }
      else
         DelLbl(b + "_LC");
     }
  }

// returns true if a label object had to be newly created (then panel/buttons are re-created above it)
bool RenderLabels()
  {
   bool created = false;
   for(int j = 0; j < g_lbN; j++)
     {
      string nm = g_lb[j].name;
      if(!g_lb[j].vis)
        {
         HideObj(nm);
         HideObj(nm + "T");
         continue;
        }
      color clr = g_lb[j].clr;
      color tc  = InpLabelAutoText ? TextFor(clr) : InpLabelTextColor;
      if(ObjectFind(0, nm) < 0) created = true;
      if(!g_lblVert)
        {
         int y = g_lblTop ? (InpLaneMargin + g_mkOff + g_lb[j].row * (g_lh + 1))
                          : (g_lblBase - g_lh - g_lb[j].row * (g_lh + 1));
         PutEdit(nm, g_lb[j].x1, y, g_lb[j].w, g_lh, g_lb[j].txt, tc, clr, clr,
                 InpLabelFontSize, InpLabelFont, ALIGN_CENTER);
        }
      else
        {
         int y = g_lblTop ? (InpLaneMargin + g_mkOff) : (g_lblBase - g_lb[j].h);
         PutRect(nm, g_lb[j].x1, y, g_lb[j].w, g_lb[j].h, clr, clr);
         PutTextV(nm + "T", g_lb[j].x1 + (g_lb[j].w - g_txtH) / 2, y + g_lb[j].h - InpLabelPad,
                  g_lb[j].txt, tc);
         ObjectSetString(0, nm, OBJPROP_TOOLTIP, g_lb[j].full);        // hover shows the full text
         ObjectSetString(0, nm + "T", OBJPROP_TOOLTIP, g_lb[j].full);
        }
     }
   return created;
  }

//+------------------------------------------------------------------+
//| Open markers (triangle + rectangles) and box names                 |
//+------------------------------------------------------------------+
void PutGlyph(string n, int x, int y, string txt, color c, int fs, string font)
  {
   if(ObjectFind(0, n) < 0)
     {
      ObjectCreate(0, n, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, n, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, n, OBJPROP_HIDDEN, true);
      ObjectSetString(0, n, OBJPROP_TOOLTIP, "\n");     // no default object-name tooltip (our own box is shown instead)
     }
   ObjectSetInteger(0, n, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, n, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
   ObjectSetInteger(0, n, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, n, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, n, OBJPROP_COLOR, c);
   ObjectSetInteger(0, n, OBJPROP_FONTSIZE, fs);
   ObjectSetString(0, n, OBJPROP_FONT, font);
   ObjectSetString(0, n, OBJPROP_TEXT, txt);
  }

// Adds one open (or close) event to the marker stack at its x position (creating the stack if needed)
void AddMarkerItem(int n, bool isClose)
  {
   datetime t = isClose ? g_ss[n].c : g_ss[n].od;
   int x = 0, y = 0;
   if(!ChartTimePriceToXY(0, 0, t, g_pmid, x, y))
      return;
   if(x < -8 || x > g_W + 8)
      return;
   int g = -1;
   for(int k = 0; k < g_mgN; k++)
      if(MathAbs(g_mgX[k] - x) <= 2)
        {
         g = k;
         break;
        }
   if(g < 0)
     {
      if(g_mgN >= ArraySize(g_mgX))
         return;
      g = g_mgN++;
      g_mgX[g]   = x;
      g_mgCnt[g] = 0;
      g_mgTip[g] = "";
     }
   if(g_mgCnt[g] >= MK_CAP)
      return;
   int k = g * MK_CAP + g_mgCnt[g];
   g_mgClr[k] = g_mk[g_ss[n].mk].clr;
   g_mgCls[k] = isClose ? 1 : 0;
   g_mgTip[g] += (g_mgCnt[g] > 0 ? "\n" : "") + SessTip(n, !isClose);
   g_mgCnt[g]++;
  }

// Groups the session opens AND closes by x position (one stack per distinct time) and reserves the edge space.
// Must run after DrawLines (uses the snapped open positions) and before LayoutLabels.
void BuildMarkerGroups()
  {
   g_mgN   = 0;
   g_mkOff = 0;
   int cap = MathMin(2 * g_ssN + 1, 400);
   ArrayResize(g_mgX, cap);
   ArrayResize(g_mgCnt, cap);
   ArrayResize(g_mgY1, cap);
   ArrayResize(g_mgY2, cap);
   ArrayResize(g_mgTip, cap);
   ArrayResize(g_mgClr, cap * MK_CAP);
   ArrayResize(g_mgCls, cap * MK_CAP);

   for(int n = 0; n < g_ssN; n++)          // opens first, so a stack's triangle is an open where there is one
      AddMarkerItem(n, false);
   if(g_showClose)
      for(int n = 0; n < g_ssN; n++)
         AddMarkerItem(n, true);

   int maxItems = 1;
   for(int g = 0; g < g_mgN; g++)
      maxItems = MathMax(maxItems, MathMin(g_mgCnt[g], MK_MAXSTACK));
   if(g_mgN > 0)
      g_mkOff = MK_TRI + MK_RECT * (maxItems - 1) + 2;

   int yB = g_H - 1;                       // bottom: the very bottom edge of the chart (over the time-axis ticks)
   int yT = InpLaneMargin;                 // top
   for(int g = 0; g < g_mgN; g++)
     {
      int items = MathMin(g_mgCnt[g], MK_MAXSTACK);
      int hh = MK_TRI + MK_RECT * (items - 1);
      if(g_lblTop) { g_mgY1[g] = yT;      g_mgY2[g] = yT + hh; }
      else         { g_mgY1[g] = yB - hh; g_mgY2[g] = yB; }
     }
  }

// Triangle pointing into the chart (down when the markers are at the top, up at the bottom).
// Filled triangle = a session OPENS there. A ring (white centre) = a session only CLOSES there.
// Further markets at the same time are stacked as small rectangles on the edge side of the triangle:
// filled = opens, white with a coloured border = closes.
bool RenderMarkers()
  {
   bool created = false;
   string glyph = ShortToString((ushort)(g_lblTop ? 0x25BC : 0x25B2));
   for(int g = 0; g < g_mgN; g++)
     {
      int items = MathMin(g_mgCnt[g], MK_MAXSTACK);
      int x = g_mgX[g];
      string b = PFX + "SMK" + IntegerToString(g);
      int cy = g_lblTop ? g_mgY1[g] + MK_RECT * (items - 1) + MK_TRI / 2
                        : g_mgY1[g] + MK_TRI / 2;
      if(ObjectFind(0, b + "_0") < 0) created = true;
      bool cls0 = (g_mgCls[g * MK_CAP] == 1);
      PutGlyph(b + "_0b", x, cy, glyph, clrBlack, 12, "Arial");                       // black outline
      PutGlyph(b + "_0",  x, cy, glyph, g_mgClr[g * MK_CAP], 10, "Arial");
      if(cls0)
         PutGlyph(b + "_0w", x, cy, glyph, clrWhite, 5, "Arial");                     // white centre = ring
      else
         ObjectDelete(0, b + "_0w");
      for(int r = 0; r < items - 1; r++)
        {
         string rn = b + "_r" + IntegerToString(r);
         int k  = g * MK_CAP + r + 1;
         int ry = g_lblTop ? g_mgY1[g] + MK_RECT * r
                           : g_mgY2[g] - MK_RECT * (r + 1) + 1;
         bool isNew = (ObjectFind(0, rn) < 0);
         if(g_mgCls[k] == 1)
            PutRect(rn, x - 4, ry, 9, MK_RECT - 1, clrWhite, g_mgClr[k]);
         else
            PutRect(rn, x - 4, ry, 9, MK_RECT - 1, g_mgClr[k], clrBlack);
         if(isNew)
           {
            created = true;
            ObjectSetString(0, rn, OBJPROP_TOOLTIP, "\n");
           }
        }
     }
   // remove markers that are no longer needed
   for(int g = 0; g < g_mkPrevN; g++)
     {
      string b = PFX + "SMK" + IntegerToString(g);
      int keep = 0;
      if(g >= g_mgN)
        {
         ObjectDelete(0, b + "_0b");
         ObjectDelete(0, b + "_0");
         ObjectDelete(0, b + "_0w");
        }
      else
         keep = MathMin(g_mgCnt[g], MK_MAXSTACK) - 1;
      for(int r = keep; r < g_mkPrevRects[g]; r++)
         ObjectDelete(0, b + "_r" + IntegerToString(r));
     }
   g_mkPrevN = g_mgN;
   ArrayResize(g_mkPrevRects, g_mgN + 1);
   for(int g = 0; g < g_mgN; g++)
      g_mkPrevRects[g] = MathMin(g_mgCnt[g], MK_MAXSTACK) - 1;
   return created;
  }

// Session name in black, roughly in the middle of the visible part of each box
bool RenderBoxNames()
  {
   bool created = false;
   int band[MS_COUNT];
   int nEn = 0;
   for(int i = 0; i < MS_COUNT; i++)
      band[i] = g_mk[i].on ? nEn++ : -1;
   double bandH = (nEn > 0) ? (g_pmax - g_pmin) / nEn : (g_pmax - g_pmin);
   TextSetFont(InpLabelFont, -InpLabelFontSize * 10);

   for(int n = 0; n < g_ssN; n++)
     {
      string nm = PFX + "S" + IntegerToString(n) + "_BT";
      bool ok = false;
      if(g_showBoxes)
        {
         int m = g_ss[n].mk;
         int xa = 0, ya = 0, xb = 0, yb = 0, xc = 0, yc = 0;
         double pr = (band[m] >= 0) ? g_pmax - (band[m] + 0.5) * bandH : g_pmid;
         if(ChartTimePriceToXY(0, 0, g_ss[n].od, g_pmid, xa, ya) &&
            ChartTimePriceToXY(0, 0, g_ss[n].c,  g_pmid, xb, yb) &&
            ChartTimePriceToXY(0, 0, g_ss[n].od, pr, xc, yc))
           {
            int L = MathMax(xa, 0), R = MathMin(xb, g_W);
            if(R - L >= 30)
              {
               if(ObjectFind(0, nm) < 0) created = true;
               PutGlyph(nm, (L + R) / 2, yc, FitText(g_mk[m].name, R - L - 6), clrBlack, InpLabelFontSize, InpLabelFont);
               ok = true;
              }
           }
        }
      if(!ok)
         ObjectDelete(0, nm);
     }
   return created;
  }

//+------------------------------------------------------------------+
//| Panel                                                             |
//+------------------------------------------------------------------+
void CreatePanelObjects()
  {
   EnsureRect(PFX + "P_BG");
   EnsureEdit(PFX + "P_H1");
   EnsureEdit(PFX + "P_H2");
   for(int r = 0; r < MS_COUNT; r++)
     {
      string s = IntegerToString(r);
      EnsureRect(PFX + "P_S" + s);
      EnsureEdit(PFX + "P_N" + s);
      EnsureEdit(PFX + "P_T" + s);
     }
   EnsureRect(PFX + "P_HND");
   ObjectSetString(0, PFX + "P_HND", OBJPROP_TOOLTIP, "Drag to resize");
  }

void HidePanel()
  {
   HideObj(PFX + "P_BG");
   HideObj(PFX + "P_H1");
   HideObj(PFX + "P_H2");
   HideObj(PFX + "P_HND");
   for(int r = 0; r < MS_COUNT; r++)
     {
      string s = IntegerToString(r);
      HideObj(PFX + "P_S" + s);
      HideObj(PFX + "P_N" + s);
      HideObj(PFX + "P_T" + s);
     }
  }

void LayoutPanel()
  {
   int W = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int H = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   g_pw = MathMax(180, MathMin(g_pw, W - 4));
   g_ph = MathMax(80,  MathMin(g_ph, H - 4));
   g_left  = (InpPanelCorner == CORNER_LEFT_UPPER  || InpPanelCorner == CORNER_LEFT_LOWER);
   g_upper = (InpPanelCorner == CORNER_LEFT_UPPER  || InpPanelCorner == CORNER_RIGHT_UPPER);
   g_edgeX = g_left  ? InpPanelX : W - InpPanelX;
   g_edgeY = g_upper ? InpPanelY : H - InpPanelY;
   g_px = g_left  ? g_edgeX : g_edgeX - g_pw;
   int bo  = InpShowButtons ? (BTN_H + 2) : 0;       // one button row above the panel, one below
   int phe = InpShowPanel ? g_ph : 0;
   if(g_upper)
     {
      g_by   = g_edgeY;
      g_py   = g_edgeY + bo;
      g_pbot = g_py + phe;
     }
   else
     {
      g_pbot = g_edgeY - bo;
      g_py   = g_pbot - phe;
      g_by   = g_py - bo;
     }
   g_by2 = g_pbot + 2;
   g_hx = g_left  ? g_px + g_pw - g_hs : g_px;
   g_hy = g_upper ? g_py + g_ph - g_hs : g_py;
  }

void UpdatePanel()
  {
   if(!InpShowPanel)
     {
      HidePanel();
      return;
     }
   LayoutPanel();

   int  idx[MS_COUNT];
   bool act[MS_COUNT];
   long rem[MS_COUNT];
   long key[MS_COUNT];
   int  n = 0;
   for(int i = 0; i < MS_COUNT; i++)
     {
      if(!g_mk[i].on) continue;
      idx[n] = i;
      GetState(i, act[n], rem[n]);
      key[n] = act[n] ? rem[n] : 10000000000 + (rem[n] < 0 ? 9000000000 : rem[n]);
      n++;
     }
   if(InpPanelSort)
      for(int a = 0; a < n - 1; a++)
         for(int b = 0; b < n - 1 - a; b++)
            if(key[b] > key[b + 1])
              {
               int  ti = idx[b]; idx[b] = idx[b + 1]; idx[b + 1] = ti;
               bool tb = act[b]; act[b] = act[b + 1]; act[b + 1] = tb;
               long tr = rem[b]; rem[b] = rem[b + 1]; rem[b + 1] = tr;
               long tk = key[b]; key[b] = key[b + 1]; key[b + 1] = tk;
              }

   uint tw = 0, th = 0;
   TextSetFont(InpPanelFont, -InpPanelFontSize * 10);
   TextGetSize("Ag", tw, th);
   int rowH = (int)th + 3;
   int pad  = 6;
   int fs   = InpPanelFontSize;

   PutRect(PFX + "P_BG", g_px, g_py, g_pw, g_ph, InpPanelBg, InpPanelBorder);

   int x0    = g_px + pad;
   int inner = g_pw - 2 * pad;
   int colW1 = inner * 45 / 100;
   int colW2 = inner - colW1;

   int y = g_py + pad;
   PutEdit(PFX + "P_H1", x0, y, colW1, rowH, "Market Session Pro+ v2.0", InpPanelHeaderText,
           InpPanelBg, InpPanelBg, fs, InpPanelFont, ALIGN_LEFT);
   PutEdit(PFX + "P_H2", x0 + colW1, y, colW2, rowH,
           "Broker " + TimeToString(g_nowB, TIME_SECONDS) + " (" + OffStr() + ")", InpPanelHeaderText,
           InpPanelBg, InpPanelBg, fs, InpPanelFont, ALIGN_RIGHT);

   int y0      = g_py + pad + rowH + 2;
   int avail   = (g_py + g_ph - pad) - y0;
   int maxRows = MathMax(0, avail / rowH);
   int shown   = n;
   bool more   = false;
   if(n > maxRows)
     {
      more  = (maxRows > 0);
      shown = MathMax(0, maxRows - 1);
      if(maxRows == 0) shown = 0;
     }

   for(int r = 0; r < MS_COUNT; r++)
     {
      string s  = IntegerToString(r);
      string nS = PFX + "P_S" + s;
      string nN = PFX + "P_N" + s;
      string nT = PFX + "P_T" + s;
      int ry = y0 + r * rowH;

      if(r < shown)
        {
         int m = idx[r];
         color bg = act[r] ? InpActiveBg : InpPanelBg;
         color tc = act[r] ? InpActiveText : InpPanelText;
         string st;
         if(rem[r] < 0)       st = "-";
         else if(act[r])      st = "Closes " + Dur(rem[r], true);
         else                 st = "Opens " + Dur(rem[r], true);
         PutRect(nS, x0, ry, 4, rowH, g_mk[m].clr, g_mk[m].clr);
         PutEdit(nN, x0 + 6, ry, colW1 - 6, rowH, g_mk[m].name, tc, bg, bg, fs, InpPanelFont, ALIGN_LEFT);
         PutEdit(nT, x0 + colW1, ry, colW2, rowH, st, tc, bg, bg, fs, InpPanelFont, ALIGN_RIGHT);
        }
      else if(more && r == shown)
        {
         HideObj(nS);
         HideObj(nT);
         PutEdit(nN, x0 + 6, ry, inner - 6, rowH,
                 "+" + IntegerToString(n - shown) + " more - drag corner to resize",
                 InpPanelText, InpPanelBg, InpPanelBg, fs, InpPanelFont, ALIGN_LEFT);
        }
      else
        {
         HideObj(nS);
         HideObj(nN);
         HideObj(nT);
        }
     }

   if(InpResizable)
     {
      PutRect(PFX + "P_HND", g_hx, g_hy, g_hs, g_hs, clrGray, clrWhite);
      ObjectSetString(0, PFX + "P_HND", OBJPROP_TOOLTIP, "Drag to resize");
     }
   else
      HideObj(PFX + "P_HND");
  }

//+------------------------------------------------------------------+
//| GUI buttons (stacked under / over the panel)                      |
//+------------------------------------------------------------------+
void UpdateButtons()
  {
   string nH = PFX + "B_HID";
   string nL = PFX + "B_LBL";
   string nV = PFX + "B_VRT";
   string nC = PFX + "B_CLS";
   string nT = PFX + "B_TAG";
   string nB = PFX + "B_BOX";
   if(!InpShowButtons)
     {
      HideObj(nH); HideObj(nL); HideObj(nV); HideObj(nC); HideObj(nT); HideObj(nB);
      return;
     }
   LayoutPanel();
   color neutral = C'45,50,64';
   color bad     = C'90,45,45';

   // top row (above the panel): everything about the labels
   int bw3 = MathMax(66, (g_pw - 4) / 3);
   int x3  = g_left ? g_px : g_px + g_pw - (3 * bw3 + 4);
   PutButton(nH, x3, g_by, bw3, BTN_H,
             g_hideLbl ? "Labels: OFF" : "Labels: ON",
             g_hideLbl ? bad : InpActiveBg,
             "Click: " + (g_hideLbl ? "show" : "hide completely") + " the chart labels");
   PutButton(nL, x3 + (bw3 + 2), g_by, bw3, BTN_H,
             g_lblTop ? "Pos: TOP" : "Pos: BOTTOM", neutral,
             "Click: move all chart labels to the " + (g_lblTop ? "bottom" : "top") + " of the chart");
   PutButton(nV, x3 + 2 * (bw3 + 2), g_by, bw3, BTN_H,
             g_lblVert ? "Text: VERT." : "Text: HORIZ.", neutral,
             "Click: switch label boxes to " + (g_lblVert ? "horizontal" : "vertical"));

   // bottom row (below the panel): lines and times
   int bw2 = MathMax(66, (g_pw - 4) / 3);
   int x2  = g_left ? g_px : g_px + g_pw - (3 * bw2 + 4);
   PutButton(nC, x2, g_by2, bw2, BTN_H,
             g_showClose ? "Close lines: ON" : "Close lines: OFF",
             g_showClose ? InpActiveBg : bad,
             "Click: switch the session close lines " + (g_showClose ? "off" : "on"));
   PutButton(nB, x2 + (bw2 + 2), g_by2, bw2, BTN_H,
             g_showBoxes ? "Boxes: ON" : "Boxes: OFF",
             g_showBoxes ? InpActiveBg : bad,
             "Click: " + (g_showBoxes ? "hide" : "show") + " the session boxes (with the session name)");
   PutButton(nT, x2 + 2 * (bw2 + 2), g_by2, bw2, BTN_H,
             g_showTags ? "Times: ON" : "Times: OFF",
             g_showTags ? InpActiveBg : bad,
             "Click: " + (g_showTags ? "remove" : "add") + " the open-close times [HH:MM-HH:MM] in the chart labels");
  }

//+------------------------------------------------------------------+
//| Refresh                                                           |
//+------------------------------------------------------------------+
// Order matters: lines first, then everything that must be drawn over them
// (MT5 draws objects in creation order, so a newly created line would otherwise cover old labels).
void Redraw(bool full)
  {
   CalcGeom();
   DrawLines(full);
   if(g_zDirty)
     {
      DeleteUiObjects();
      g_zDirty = false;
     }
   BuildMarkerGroups();          // before the labels: they move away from the edge by the marker height
   LayoutLabels();
   bool c1 = RenderLabels();
   bool c2 = RenderMarkers();
   bool c3 = RenderBoxNames();
   if(c1 || c2 || c3)
     {
      // new objects were created: re-create panel + buttons after them so they stay on top
      ObjectsDeleteAll(0, PFX + "P_");
      ObjectsDeleteAll(0, PFX + "B_");
     }
   UpdatePanel();
   UpdateButtons();
  }

void Refresh()
  {
   UpdateClock();
   BuildSessions();
   Redraw(true);
   ChartRedraw(0);
  }

string SizeKey(string s)
  {
   return "MSI_" + s + "_" + IntegerToString(ChartID());
  }

void HideHover()
  {
   if(g_hvRows <= 0)
      return;
   for(int i = 0; i < g_hvRows; i++)
      ObjectDelete(0, PFX + "H_TIP" + IntegerToString(i));
   g_hvRows = 0;
   ChartRedraw(0);
  }

// Shows the description of whatever is under the mouse: an open marker, or (transparent mode) a line.
// One row per market, stacked underneath each other in a small light-yellow box.
void HoverLines(int mx, int my)
  {
   if(g_drag || mx < 0 || my < 0 || mx >= g_W || my >= g_H)
     {
      HideHover();
      return;
     }
   string rows[];
   ArrayResize(rows, 0);
   int cnt = 0;

   // 1) open markers
   for(int g = 0; g < g_mgN; g++)
      if(MathAbs(g_mgX[g] - mx) <= 6 && my >= g_mgY1[g] - 2 && my <= g_mgY2[g] + 2)
        {
         cnt = StringSplit(g_mgTip[g], 10, rows);
         break;
        }

   // 2) transparent lines (classic lines have their own native tooltips)
   if(cnt == 0 && InpTransparentLines)
      for(int i = 0; i < g_hvN && i < ArraySize(g_lnTip); i++)
         if(MathAbs(g_hvX[i] - mx) <= 4)
           {
            ArrayResize(rows, cnt + 1);
            rows[cnt++] = g_lnTip[i];
           }

   if(cnt == 0)
     {
      HideHover();
      return;
     }
   int shown = MathMin(cnt, 10);
   if(cnt > shown)
      rows[shown - 1] = "+" + IntegerToString(cnt - shown + 1) + " more...";

   uint tw = 0, th = 0;
   TextSetFont(InpLabelFont, -InpLabelFontSize * 10);
   int maxW = 0;
   for(int i = 0; i < shown; i++)
     {
      TextGetSize(rows[i], tw, th);
      maxW = MathMax(maxW, (int)tw);
     }
   // edit boxes render text a little wider than TextGetSize reports, so leave headroom (otherwise the end is clipped)
   int w  = MathMin(maxW * 115 / 100 + 16, g_W - 4);
   int rh = (int)th + 5;
   int hh = rh * shown - (shown - 1);
   int x  = mx + 14;
   int y  = my + 16;
   if(x + w > g_W)  x = mx - w - 14;
   if(x < 0)        x = 0;
   if(y + hh > g_H) y = my - hh - 8;
   if(y < 0)        y = 0;
   for(int i = 0; i < shown; i++)
      PutEdit(PFX + "H_TIP" + IntegerToString(i), x, y + i * (rh - 1), w, rh, rows[i], clrBlack,
              C'255,255,225', C'150,150,100', InpLabelFontSize, InpLabelFont, ALIGN_LEFT);
   for(int i = shown; i < g_hvRows; i++)
      ObjectDelete(0, PFX + "H_TIP" + IntegerToString(i));
   g_hvRows = shown;
   ChartRedraw(0);
  }

void SaveChartLook()
  {
   if(GlobalVariableCheck(SizeKey("OC0")))
      return;                                   // originals already stored (e.g. timeframe switch)
   for(int i = 0; i < ArraySize(g_lookProps); i++)
      GlobalVariableSet(SizeKey("OC" + IntegerToString(i)),
                        (double)ChartGetInteger(0, (ENUM_CHART_PROPERTY_INTEGER)g_lookProps[i]));
  }

void ApplyChartLook()
  {
   SaveChartLook();
   ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrWhite);
   ChartSetInteger(0, CHART_COLOR_FOREGROUND, clrBlack);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, C'0,150,80');
   ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, C'220,40,40');
   ChartSetInteger(0, CHART_COLOR_CHART_UP, C'0,150,80');
   ChartSetInteger(0, CHART_COLOR_CHART_DOWN, C'220,40,40');
   ChartSetInteger(0, CHART_COLOR_CHART_LINE, clrBlack);
   ChartSetInteger(0, CHART_SHOW_GRID, false);
   ChartSetInteger(0, CHART_COLOR_GRID, clrBlack);
  }

void RestoreChartLook()
  {
   if(!GlobalVariableCheck(SizeKey("OC0")))
      return;
   for(int i = 0; i < ArraySize(g_lookProps); i++)
     {
      string k = SizeKey("OC" + IntegerToString(i));
      if(GlobalVariableCheck(k))
        {
         ChartSetInteger(0, (ENUM_CHART_PROPERTY_INTEGER)g_lookProps[i], (long)GlobalVariableGet(k));
         GlobalVariableDel(k);
        }
     }
  }

void SaveToggles()
  {
   GlobalVariableSet(SizeKey("LT"), g_lblTop ? 1 : 0);
   GlobalVariableSet(SizeKey("LV"), g_lblVert ? 1 : 0);
   GlobalVariableSet(SizeKey("CL"), g_showClose ? 1 : 0);
   GlobalVariableSet(SizeKey("TG"), g_showTags ? 1 : 0);
   GlobalVariableSet(SizeKey("HL"), g_hideLbl ? 1 : 0);
   GlobalVariableSet(SizeKey("BX"), g_showBoxes ? 1 : 0);
  }

//+------------------------------------------------------------------+
//| Initial panel size: wide enough for every text (names, header,    |
//| countdowns, the 6 buttons), tall enough for every enabled market  |
//| row so no "+N more" line appears.                                 |
//+------------------------------------------------------------------+
void FitPanelSize(int &w, int &h)
  {
   uint tw = 0, th = 0;
   TextSetFont(InpPanelFont, -InpPanelFontSize * 10);
   TextGetSize("Ag", tw, th);
   int rowH = (int)th + 3;
   int pad  = 6;

   // widest market name (+ colour stripe), widest header / countdown text
   int n = 0, wName = 0, wStat = 0;
   for(int i = 0; i < MS_COUNT; i++)
     {
      if(!g_mk[i].on) continue;
      n++;
      TextGetSize(g_mk[i].name, tw, th);
      wName = MathMax(wName, (int)tw + 6);
     }
   n = MathMax(n, 1);
   TextGetSize("Market Session Pro+ v2.0", tw, th);
   wName = MathMax(wName, (int)tw);
   TextGetSize("Closes 88:88:88", tw, th);
   wStat = (int)tw;
   TextGetSize("Opens 88:88:88", tw, th);
   wStat = MathMax(wStat, (int)tw);
   TextGetSize("Broker 88:88:88 (GMT+10:30)", tw, th);
   wStat = MathMax(wStat, (int)tw);

   // edit boxes render text a little wider than TextGetSize reports -> headroom
   int c1 = wName * 115 / 100 + 16;
   int c2 = wStat * 115 / 100 + 16;
   // the panel splits its inner width 45% / 55% between the two columns
   int inner = MathMax((c1 * 100 + 44) / 45, (c2 * 100 + 54) / 55);
   w = inner + 2 * pad;

   // the GUI buttons are 3 per row and share the panel width
   if(InpShowButtons)
     {
      string bt[] = {"Labels: OFF", "Pos: BOTTOM", "Text: HORIZ.", "Close lines: OFF", "Boxes: OFF", "Times: OFF"};
      TextSetFont("Arial", -80);
      int wb = 0;
      for(int k = 0; k < ArraySize(bt); k++)
        {
         TextGetSize(bt[k], tw, th);
         wb = MathMax(wb, (int)tw);
        }
      w = MathMax(w, 3 * (wb + 20) + 4);
     }

   // header row + one row per enabled market + room for the resize handle
   h = pad + rowH + 2 + n * rowH + (InpResizable ? g_hs + 2 : pad);
  }

//+------------------------------------------------------------------+
//| Standard events                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetString(INDICATOR_SHORTNAME, "Market Session Pro+");
   Print("Market Session Pro+ v2.00 loaded");
   LoadMarkets();

   g_pw = InpPanelW;
   g_ph = InpPanelH;
   if(InpAutoFit)
     {
      int fw = 0, fh = 0;
      FitPanelSize(fw, fh);
      g_pw = MathMax(g_pw, fw);
      g_ph = MathMax(g_ph, fh);
     }
   if(InpRememberSize && InpResizable)      // a size the user dragged to wins over the auto size
     {
      if(GlobalVariableCheck(SizeKey("PW"))) g_pw = (int)GlobalVariableGet(SizeKey("PW"));
      if(GlobalVariableCheck(SizeKey("PH"))) g_ph = (int)GlobalVariableGet(SizeKey("PH"));
     }

   g_showClose = InpShowCloseLine;
   g_lblTop    = InpLabelsAtTop;
   g_lblVert   = InpLabelsVertical;
   g_showTags  = InpShowTimeTags;
   g_hideLbl   = !InpShowLabels;                   // labels hidden by default
   g_showBoxes = (InpDrawMode == MS_DRAW_BOXES);
   int why = UninitializeReason();   // keep GUI toggles across timeframe switches / recompiles
   if(why == REASON_CHARTCHANGE || why == REASON_RECOMPILE)
     {
      if(GlobalVariableCheck(SizeKey("LT"))) g_lblTop    = (GlobalVariableGet(SizeKey("LT")) > 0.5);
      if(GlobalVariableCheck(SizeKey("LV"))) g_lblVert   = (GlobalVariableGet(SizeKey("LV")) > 0.5);
      if(GlobalVariableCheck(SizeKey("CL"))) g_showClose = (GlobalVariableGet(SizeKey("CL")) > 0.5);
      if(GlobalVariableCheck(SizeKey("TG"))) g_showTags  = (GlobalVariableGet(SizeKey("TG")) > 0.5);
      if(GlobalVariableCheck(SizeKey("HL"))) g_hideLbl   = (GlobalVariableGet(SizeKey("HL")) > 0.5);
      if(GlobalVariableCheck(SizeKey("BX"))) g_showBoxes = (GlobalVariableGet(SizeKey("BX")) > 0.5);
     }

   g_userScroll = (bool)ChartGetInteger(0, CHART_MOUSE_SCROLL);
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);

   if(InpWhiteChart)
      ApplyChartLook();

   // first attach only: switch to the default timeframe (the indicator reloads on the new timeframe,
   // where "pending" makes it apply the default zoom). Later timeframe changes by the user are left alone.
   bool fresh   = (why == REASON_PROGRAM);
   bool pending = GlobalVariableCheck(SizeKey("TFP"));
   if(pending)
      GlobalVariableDel(SizeKey("TFP"));
   if(fresh && InpDefaultTF != PERIOD_CURRENT && (ENUM_TIMEFRAMES)_Period != InpDefaultTF)
     {
      GlobalVariableSet(SizeKey("TFP"), 1);
      if(ChartSetSymbolPeriod(0, _Symbol, InpDefaultTF))
         return INIT_SUCCEEDED;
      GlobalVariableDel(SizeKey("TFP"));
     }
   SetupChartScroll(fresh || pending);
   if(InpShowPanel)
      CreatePanelObjects();

   EventSetTimer(1);
   Refresh();
   PrintFormat("Market Session Pro+ clocks: PC local=%s | GMT(PC)=%s | TradeServer=%s | LastTick=%s | offset used=%s",
               TimeToString(TimeLocal(), TIME_DATE | TIME_SECONDS),
               TimeToString(TimeGMT(), TIME_DATE | TIME_SECONDS),
               TimeToString(TimeTradeServer(), TIME_DATE | TIME_SECONDS),
               TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS),
               OffStr());
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   SaveToggles();
   if(g_cvOk)
     {
      g_cv.Destroy();
      g_cvOk = false;
     }
   ObjectsDeleteAll(0, PFX);
   if(reason == REASON_REMOVE && InpWhiteChart)
      RestoreChartLook();
   ChartSetInteger(0, CHART_MOUSE_SCROLL, g_userScroll);
   ChartRedraw(0);
  }

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[],
                const double &close[], const long &tick_volume[], const long &volume[],
                const int &spread[])
  {
   TrackTick();
   return rates_total;
  }

void OnTimer()
  {
   Refresh();
  }

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_CHART_CHANGE)
     {
      int oldBack = g_backUsed;
      if(InpLinesToChartStart)
         BuildSessions();          // chart scrolled / zoomed: extend or trim the sessions to the visible range
      Redraw(g_backUsed != oldBack);
      ChartRedraw(0);
      return;
     }

   if(id == CHARTEVENT_MOUSE_MOVE)
      HoverLines((int)lparam, (int)dparam);

   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      bool hit = true;
      if(sparam == PFX + "B_HID")
         g_hideLbl = !g_hideLbl;
      else if(sparam == PFX + "B_LBL")
         g_lblTop = !g_lblTop;
      else if(sparam == PFX + "B_VRT")
        {
         g_lblVert = !g_lblVert;
         g_zDirty  = true;        // horizontal and vertical labels are different object types: rebuild
        }
      else if(sparam == PFX + "B_CLS")
         g_showClose = !g_showClose;
      else if(sparam == PFX + "B_TAG")
         g_showTags = !g_showTags;
      else if(sparam == PFX + "B_BOX")
         g_showBoxes = !g_showBoxes;
      else
         hit = false;
      if(hit)
        {
         SaveToggles();
         Redraw(true);
         ChartRedraw(0);
        }
      return;
     }

   if(id == CHARTEVENT_MOUSE_MOVE && InpShowPanel && InpResizable)
     {
      int  mx   = (int)lparam;
      int  my   = (int)dparam;
      uint fl   = (uint)StringToInteger(sparam);
      bool down = ((fl & 1) != 0);
      bool over = (mx >= g_hx - 4 && mx <= g_hx + g_hs + 4 &&
                   my >= g_hy - 4 && my <= g_hy + g_hs + 4);

      if(!g_drag)
        {
         if(over && !g_locked)
           {
            ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
            g_locked = true;
           }
         else if(!over && g_locked)
           {
            ChartSetInteger(0, CHART_MOUSE_SCROLL, g_userScroll);
            g_locked = false;
           }
         if(over && down)
            g_drag = true;
        }
      else
        {
         if(!down)
           {
            g_drag = false;
            if(InpRememberSize)
              {
               GlobalVariableSet(SizeKey("PW"), g_pw);
               GlobalVariableSet(SizeKey("PH"), g_ph);
              }
            if(!over && g_locked)
              {
               ChartSetInteger(0, CHART_MOUSE_SCROLL, g_userScroll);
               g_locked = false;
              }
           }
         else
           {
            int W = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
            int H = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
            int nw = g_left  ? (mx - g_edgeX) + g_hs / 2 : (g_edgeX - mx) + g_hs / 2;
            int nh = g_upper ? (my - g_py) + g_hs / 2 : (g_pbot - my) + g_hs / 2;
            g_pw = MathMax(180, MathMin(nw, W - 10));
            g_ph = MathMax(80,  MathMin(nh, H - 10));
            UpdatePanel();
            UpdateButtons();
            ChartRedraw(0);
           }
        }
     }
  }
//+------------------------------------------------------------------+
