//+------------------------------------------------------------------+
//|                                          ATS_Liquidity_City.mq5 |
//|                                          Andy Trading Solutions  |
//+------------------------------------------------------------------+
//| Where are the stops resting, and which ones got taken?           |
//|                                                                  |
//| Liquidity pools:                                                 |
//|  - every confirmed swing high / low that price has not traded    |
//|    through yet (a swing is confirmed after N closed bars on each |
//|    side, so nothing repaints)                                    |
//|  - swing highs (lows) within a small ATR tolerance of each other |
//|    count as EQUAL highs (lows): a bigger pool                    |
//|  - yesterday's high and low (server day), alive for today only   |
//| A pool is SWEPT when a bar trades beyond it. If that same bar    |
//| closes back on the other side, it is marked "grabbed & rejected".|
//|                                                                  |
//| The panel is a neon city drawn on a CCanvas: the price is a      |
//| flying car, sell stops are towers below it, buy stops floating   |
//| platforms above it (higher = more ATRs away, wider = more stops),|
//| a searchlight lights them up and a ticker runs today's catch.    |
//| CCanvas does not blend semi-transparent shapes, so every glow is |
//| mixed by hand against the sky colour.                            |
//|                                                                  |
//| Indicator only: it never opens, modifies or closes trades.       |
//+------------------------------------------------------------------+
#property copyright   "Andy Trading Solutions"
#property link        "https://www.mql5.com/en/users/andyxi"
#property version     "1.00"
#property description "Liquidity pools (untouched swing highs and lows, equal highs and lows, yesterday's high and low) and their sweeps, with a neon city panel. Non-repainting. Built for gold, works on any symbol and timeframe."
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_label1  "High pool swept"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrDeepSkyBlue
#property indicator_width1  2
#property indicator_label2  "Low pool swept"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrOrange
#property indicator_width2  2

#include <Canvas\Canvas.mqh>

//--- inputs
input int    InpPivot     = 5;      // Swing strength: bars on each side
input int    InpLookback  = 400;    // Bars scanned for pools
input double InpEqualATR  = 0.10;   // Equal highs/lows tolerance, x ATR(14)
input bool   InpDayLevels = true;   // Include yesterday's high and low
input bool   InpLines     = true;   // Draw the pools on the chart
input bool   InpAlert     = false;  // Popup when a pool is swept
input bool   InpShowPanel = true;   // Show the city panel
input int    InpPanelX    = 20;     // Panel X
input int    InpPanelY    = 30;     // Panel Y

//--- buffers: 0/1 sweep arrows, 2/3 nearest active pool above/below (for an Expert Advisor)
double bUp[], bDn[], bNearUp[], bNearDn[];

//--- one liquidity pool
struct SPool
  {
   int      dir;       // +1 above price (buy stops), -1 below (sell stops)
   double   level;
   int      born;      // bar index of the swing (or of the day start)
   int      swept;     // bar index of the sweep, -1 while active
   bool     rejected;  // the sweeping bar closed back on the other side
   int      strength;  // 1 + equal swings resting at the same level
   bool     day;       // yesterday's high/low
   int      expires;   // day levels only: last bar of the day
   datetime st;        // time of the sweep bar
  };
SPool    g_p[];
int      g_n = 0;

datetime g_lastBar = 0, g_lastAlert = 0;
double   g_atr = 0, g_last = 0;
datetime g_dayStart = 0;
int      g_f = 0;               // index of the forming bar at the last calculation
const string OBJ = "ATSLC_";

//--- panel
CCanvas  g_cv;
const string CV_NAME = "ATSLC_PANEL";
const string BT_MIN  = "ATSLC_MIN";
bool     g_min = false;
double   g_k = 1.0, g_fs = 1.0;
const int W = 360;
int      g_H = 560;

//+------------------------------------------------------------------+
//| Initialisation                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, bUp, INDICATOR_DATA);
   SetIndexBuffer(1, bDn, INDICATOR_DATA);
   SetIndexBuffer(2, bNearUp, INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, bNearDn, INDICATOR_CALCULATIONS);
   PlotIndexSetInteger(0, PLOT_ARROW, 234);
   PlotIndexSetInteger(1, PLOT_ARROW, 233);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   IndicatorSetString(INDICATOR_SHORTNAME, "ATS Liquidity City");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   if(InpShowPanel)
     {
      int dpi = (int)TerminalInfoInteger(TERMINAL_SCREEN_DPI);
      g_k = MathMax(1.0, MathMin(3.0, dpi / 96.0));
      g_min = GlobalVariableCheck("ATSLC_min") && GlobalVariableGet("ATSLC_min") > 0.5;
      BuildPanel();
      EventSetMillisecondTimer(200);          // searchlight and ticker move 5 times a second
     }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Clean up                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   g_cv.Destroy();
   ObjectDelete(0, BT_MIN);
   ObjectsDeleteAll(0, OBJ);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Add a pool                                                       |
//+------------------------------------------------------------------+
void AddPool(const int dir, const double level, const int born, const bool day, const int expires)
  {
   if(g_n >= ArraySize(g_p)) ArrayResize(g_p, g_n + 64);
   g_p[g_n].dir = dir; g_p[g_n].level = level; g_p[g_n].born = born; g_p[g_n].swept = -1;
   g_p[g_n].rejected = false; g_p[g_n].strength = 1; g_p[g_n].day = day; g_p[g_n].expires = expires; g_p[g_n].st = 0;
   g_n++;
  }

//+------------------------------------------------------------------+
//| Main calculation: pools and sweeps are rebuilt on every new bar  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
  {
   int P = MathMax(2, InpPivot);
   if(rates_total < 3 * P + 30) return(0);
   int f = rates_total - 1;
   g_last = close[f];

   if(time[f] != g_lastBar || prev_calculated == 0)
     {
      g_lastBar = time[f];
      int from = MathMax(P + 15, rates_total - InpLookback);
      for(int i = MathMax(0, from - 2 * P); i < rates_total; i++)
        { bUp[i] = EMPTY_VALUE; bDn[i] = EMPTY_VALUE; bNearUp[i] = EMPTY_VALUE; bNearDn[i] = EMPTY_VALUE; }
      if(prev_calculated == 0)
         for(int i = 0; i < from; i++) { bUp[i] = EMPTY_VALUE; bDn[i] = EMPTY_VALUE; bNearUp[i] = EMPTY_VALUE; bNearDn[i] = EMPTY_VALUE; }

      //--- ATR(14), Wilder smoothing
      double atr[]; ArrayResize(atr, rates_total);
      atr[0] = high[0] - low[0];
      for(int i = 1; i < rates_total; i++)
        {
         double tr = MathMax(high[i] - low[i], MathMax(MathAbs(high[i] - close[i - 1]), MathAbs(low[i] - close[i - 1])));
         atr[i] = atr[i - 1] + (tr - atr[i - 1]) / 14.0;
        }
      g_atr = atr[f - 1];

      //--- swing pools: a swing at j is known only at j + P (closed bars)
      g_n = 0;
      for(int j = from; j <= f - 1 - P; j++)
        {
         bool ph = true, pl = true;
         for(int k = 1; k <= P && (ph || pl); k++)
           {
            if(high[j - k] >= high[j] || high[j + k] > high[j]) ph = false;
            if(low[j - k] <= low[j] || low[j + k] < low[j]) pl = false;
           }
         if(ph) AddPool(1, high[j], j, false, -1);
         if(pl) AddPool(-1, low[j], j, false, -1);
        }
      //--- yesterday's high and low, alive for one server day
      if(InpDayLevels)
        {
         int d0 = from;
         while(d0 < rates_total)
           {
            datetime day = time[d0] - time[d0] % 86400;
            int d1 = d0; while(d1 + 1 < rates_total && time[d1 + 1] - time[d1 + 1] % 86400 == day) d1++;
            //--- previous day inside the chart data
            int p1 = d0 - 1; if(p1 < 0) { d0 = d1 + 1; continue; }
            datetime pday = time[p1] - time[p1] % 86400;
            int p0 = p1; while(p0 - 1 >= 0 && time[p0 - 1] - time[p0 - 1] % 86400 == pday) p0--;
            double ph = high[p0], pl = low[p0];
            for(int k = p0; k <= p1; k++) { ph = MathMax(ph, high[k]); pl = MathMin(pl, low[k]); }
            AddPool(1, ph, d0, true, d1);
            AddPool(-1, pl, d0, true, d1);
            d0 = d1 + 1;
           }
        }
      //--- sweeps: first closed bar that trades beyond the level after the pool is known
      for(int q = 0; q < g_n; q++)
        {
         int start = g_p[q].day ? g_p[q].born : g_p[q].born + P + 1;
         int end = g_p[q].day ? MathMin(g_p[q].expires, f - 1) : f - 1;
         for(int i = start; i <= end; i++)
           {
            bool hit = g_p[q].dir > 0 ? high[i] > g_p[q].level : low[i] < g_p[q].level;
            if(!hit) continue;
            g_p[q].swept = i; g_p[q].st = time[i];
            g_p[q].rejected = g_p[q].dir > 0 ? close[i] < g_p[q].level : close[i] > g_p[q].level;
            if(g_p[q].dir > 0) bUp[i] = high[i] + 0.3 * atr[i];
            else               bDn[i] = low[i] - 0.3 * atr[i];
            break;
           }
        }
      //--- equal highs / lows: active swing pools resting within the tolerance of each other
      for(int a = 0; a < g_n; a++)
        {
         if(g_p[a].day) continue;
         for(int b = 0; b < g_n; b++)
           {
            if(a == b || g_p[b].day || g_p[b].dir != g_p[a].dir) continue;
            int aEnd = g_p[a].swept < 0 ? f : g_p[a].swept, bEnd = g_p[b].swept < 0 ? f : g_p[b].swept;
            bool overlap = g_p[b].born < aEnd && g_p[a].born < bEnd;
            if(overlap && MathAbs(g_p[a].level - g_p[b].level) <= InpEqualATR * atr[g_p[a].born]) g_p[a].strength++;
           }
        }
      //--- nearest active pools, for an Expert Advisor
      double nu = 0, nd = 0;
      for(int q = 0; q < g_n; q++)
        {
         if(!Active(q, f)) continue;
         if(g_p[q].dir > 0 && g_p[q].level > close[f - 1] && (nu == 0 || g_p[q].level < nu)) nu = g_p[q].level;
         if(g_p[q].dir < 0 && g_p[q].level < close[f - 1] && (nd == 0 || g_p[q].level > nd)) nd = g_p[q].level;
        }
      bNearUp[f] = nu > 0 ? nu : EMPTY_VALUE;
      bNearDn[f] = nd > 0 ? nd : EMPTY_VALUE;
      g_dayStart = time[f] - time[f] % 86400;
      g_f = f;

      if(InpLines) DrawLines(time, f);
      if(InpAlert && prev_calculated > 0) AlertNew(time, f);
     }

   if(InpShowPanel && prev_calculated == 0) Draw();
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| A pool is active if not swept and (day levels) not expired       |
//+------------------------------------------------------------------+
bool Active(const int q, const int f)
  {
   if(g_p[q].swept >= 0) return false;
   if(g_p[q].day && g_p[q].expires < f) return false;
   return true;
  }

//+------------------------------------------------------------------+
//| Chart lines: active pools to now, swept pools to the sweep bar   |
//+------------------------------------------------------------------+
void DrawLines(const datetime &time[], const int f)
  {
   ObjectsDeleteAll(0, OBJ);
   for(int q = 0; q < g_n; q++)
     {
      bool act = Active(q, f);
      if(!act && g_p[q].swept < 0) continue;                        // expired day level, never touched
      if(!act && f - g_p[q].swept > 300) continue;                  // keep the chart clean
      int e = act ? f : g_p[q].swept;
      string nm = OBJ + IntegerToString(q);
      ObjectCreate(0, nm, OBJ_TREND, 0, time[g_p[q].born], g_p[q].level, time[e], g_p[q].level);
      color c = g_p[q].day ? clrGold : (g_p[q].dir > 0 ? clrDeepSkyBlue : clrOrange);
      if(!act) c = clrGray;
      ObjectSetInteger(0, nm, OBJPROP_COLOR, c);
      ObjectSetInteger(0, nm, OBJPROP_STYLE, act ? STYLE_SOLID : STYLE_DOT);
      ObjectSetInteger(0, nm, OBJPROP_WIDTH, act ? MathMin(4, 1 + g_p[q].strength) : 1);
      ObjectSetInteger(0, nm, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, nm, OBJPROP_BACK, true);
      ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, nm, OBJPROP_HIDDEN, true);
      string tip = (g_p[q].day ? (g_p[q].dir > 0 ? "Yesterday's high " : "Yesterday's low ") :
                   (g_p[q].strength > 1 ? (g_p[q].dir > 0 ? "Equal highs x" : "Equal lows x") + IntegerToString(g_p[q].strength) + " " :
                   (g_p[q].dir > 0 ? "Swing high " : "Swing low "))) + DoubleToString(g_p[q].level, _Digits) +
                   (act ? "  - waiting" : (g_p[q].rejected ? "  - grabbed & rejected" : "  - swept"));
      ObjectSetString(0, nm, OBJPROP_TOOLTIP, tip);
      //--- active pool: its name on the line, at the current bar
      if(act)
        {
         string kind = g_p[q].day ? (g_p[q].dir > 0 ? "YDAY HIGH" : "YDAY LOW") :
                       (g_p[q].strength > 1 ? StringFormat("EQUAL %s x%d", g_p[q].dir > 0 ? "HIGHS" : "LOWS", g_p[q].strength) :
                       (g_p[q].dir > 0 ? "SWING HIGH" : "SWING LOW"));
         Label(nm + "t", time[f], g_p[q].level + 0.10 * g_atr, kind + "  " + DoubleToString(g_p[q].level, _Digits), c, ANCHOR_RIGHT_LOWER, tip);
        }
      //--- swept pool: one word on the arrow, grab (closed back inside) or break (closed beyond)
      else
        {
         int i = g_p[q].swept;
         double ay = g_p[q].dir > 0 ? bUp[i] : bDn[i];
         if(ay == EMPTY_VALUE) continue;
         ay += g_p[q].dir * 0.12 * g_atr;
         Label(nm + "s", time[i], ay, g_p[q].rejected ? "grab" : "break",
               g_p[q].rejected ? (g_p[q].dir > 0 ? clrDeepSkyBlue : clrOrange) : clrGray,
               g_p[q].dir > 0 ? ANCHOR_LOWER : ANCHOR_UPPER, tip);
        }
     }
  }

//+------------------------------------------------------------------+
//| Small chart label                                                |
//+------------------------------------------------------------------+
void Label(const string nm, const datetime t, const double p, const string s, const color c,
           const ENUM_ANCHOR_POINT anchor, const string tip)
  {
   ObjectCreate(0, nm, OBJ_TEXT, 0, t, p);
   ObjectSetString (0, nm, OBJPROP_TEXT, s);
   ObjectSetString (0, nm, OBJPROP_FONT, "Bahnschrift");
   ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, 7);
   ObjectSetInteger(0, nm, OBJPROP_COLOR, c);
   ObjectSetInteger(0, nm, OBJPROP_ANCHOR, anchor);
   ObjectSetInteger(0, nm, OBJPROP_BACK, true);
   ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, nm, OBJPROP_HIDDEN, true);
   ObjectSetString (0, nm, OBJPROP_TOOLTIP, tip);
  }

//+------------------------------------------------------------------+
//| One popup per new sweep on the last closed bar                   |
//+------------------------------------------------------------------+
void AlertNew(const datetime &time[], const int f)
  {
   for(int q = 0; q < g_n; q++)
      if(g_p[q].swept == f - 1 && time[f - 1] > g_lastAlert)
        {
         Alert(StringFormat("ATS Liquidity City %s: %s %s %s", _Symbol, g_p[q].dir > 0 ? "high" : "low",
                            DoubleToString(g_p[q].level, _Digits), g_p[q].rejected ? "grabbed & rejected" : "swept"));
         g_lastAlert = time[f - 1];
        }
  }

//+------------------------------------------------------------------+
//| The scan keeps turning                                           |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(!InpShowPanel) return;
   g_last = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   Draw();
   ChartRedraw();
  }

//+==================================================================+
//| PANEL - "Liquidity City"                                         |
//| Night in a neon city. The price is a flying car at mid-height.   |
//| Sell stops below are skyscrapers whose roof sits at the level;   |
//| buy stops above are floating platforms. Yesterday's high/low are |
//| golden holo-billboards. A searchlight sweeps the sky and lights  |
//| every pool it touches; a ticker runs today's catch.              |
//+==================================================================+
color cCyan = C'0,236,255', cMag = C'255,46,196', cGold = C'255,204,64', cInk = C'226,236,255', cDim = C'120,110,190';

int  X(const double v) { return (int)MathRound(v * g_k); }
uint A(const color c)  { return ColorToARGB(c, 255); }

//+------------------------------------------------------------------+
//| Linear mix of two colours (t = 0 -> a, t = 1 -> b)               |
//+------------------------------------------------------------------+
color Mix(const color a, const color b, double t)
  {
   t = MathMax(0.0, MathMin(1.0, t));
   int r  = (int)(( a        & 0xFF) * (1 - t) + ( b        & 0xFF) * t);
   int g  = (int)(((a >> 8)  & 0xFF) * (1 - t) + ((b >> 8)  & 0xFF) * t);
   int bl = (int)(((a >> 16) & 0xFF) * (1 - t) + ((b >> 16) & 0xFF) * t);
   return (color)(r | (g << 8) | (bl << 16));
  }

//+------------------------------------------------------------------+
//| Night sky at logical row y (every glow is mixed against it)      |
//+------------------------------------------------------------------+
color SkyAt(const double y)
  {
   double t = MathMax(0.0, MathMin(1.0, (y - 56) / 380.0));
   return t < 0.6 ? Mix(C'10,6,34', C'44,14,78', t / 0.6) : Mix(C'44,14,78', C'96,20,96', (t - 0.6) / 0.4);
  }

//+------------------------------------------------------------------+
//| Text and shapes in logical pixels                                |
//+------------------------------------------------------------------+
void Txt(const double x, const double y, const string s, const int px, const color c,
         const string face = "Bahnschrift", const uint al = TA_LEFT | TA_TOP, const uint flags = FW_BOLD)
  {
   g_cv.FontSet(face, (int)MathRound(px * g_k * g_fs), flags);
   g_cv.TextOut(X(x), X(y), s, A(c), al);
  }
//--- neon text: two soft halos mixed with what is behind, then the bright core
void Neon(const double x, const double y, const string s, const int px, const color c, const color behind, const uint al = TA_LEFT | TA_TOP)
  {
   color h1 = Mix(behind, c, 0.25), h2 = Mix(behind, c, 0.5);
   for(int dx = -2; dx <= 2; dx += 4) for(int dy = -2; dy <= 2; dy += 4) Txt(x + dx * 0.6, y + dy * 0.6, s, px, h1, "Bahnschrift", al, FW_BLACK);
   Txt(x + 0.6, y, s, px, h2, "Bahnschrift", al, FW_BLACK);
   Txt(x, y, s, px, Mix(c, clrWhite, 0.35), "Bahnschrift", al, FW_BLACK);
  }
void Box(const double x1, const double y1, const double x2, const double y2, const color c)
  {
   g_cv.FillRectangle(X(x1), X(y1), X(x2), X(y2), A(c));
  }
void Line(const double x1, const double y1, const double x2, const double y2, const color c, const double th)
  {
   g_cv.LineThick(X(x1), X(y1), X(x2), X(y2), A(c), MathMax(1, X(th)), STYLE_SOLID, LINE_END_ROUND);
  }
void Disc(const double x, const double y, const double r, const color c)
  {
   g_cv.FillCircle(X(x), X(y), MathMax(1, X(r)), A(c));
  }

//+------------------------------------------------------------------+
//| Skyscraper with lit windows; roof = the pool level               |
//+------------------------------------------------------------------+
void Tower(const double x, const double w, const double roof, const double ground, const color neon, const double lit, const int seed, const string price)
  {
   color bg = SkyAt(roof);
   Box(x - 3, roof - 3, x + w + 3, roof, Mix(bg, neon, 0.25 + 0.2 * lit));        // glow on the roof line
   color body = Mix(C'34,18,70', neon, 0.16 + 0.3 * lit);
   Box(x, roof, x + w, ground, body);
   Box(x, roof, x + w, roof + 2, Mix(neon, clrWhite, 0.2 + 0.4 * lit));           // neon roof edge = the level
   Box(x, roof, x + 1.5, ground, Mix(body, neon, 0.6));                           // neon side edges
   Box(x + w - 1.5, roof, x + w, ground, Mix(body, neon, 0.4));
   for(double wy = roof + 7; wy < ground - 4; wy += 7)
      for(double wx = x + 4; wx < x + w - 4; wx += 6)
        {
         bool on = wy < roof + 10 || ((int)(wx * 7 + wy * 3 + seed) % 5) < 3;      // top floor always lit
         if(on) Box(wx, wy, wx + 2.5, wy + 3, Mix(C'90,80,130', C'255,236,170', 0.35 + 0.65 * lit));
        }
   Line(x + w / 2, roof, x + w / 2, roof - 7, Mix(body, neon, 0.7), 1);           // antenna
   Disc(x + w / 2, roof - 8, 1.6, (GetTickCount() / 500 + seed) % 2 == 0 ? cMag : C'90,20,70');
   Txt(x + w / 2, roof - 11, price, 7, Mix(neon, clrWhite, 0.45), "Bahnschrift", TA_CENTER | TA_BOTTOM, FW_BOLD);
  }

//+------------------------------------------------------------------+
//| Floating platform (buy stops above price)                        |
//+------------------------------------------------------------------+
void Platform(const double cx, const double y, const double w, const color neon, const double lit, const string price)
  {
   Txt(cx, y - 9, price, 7, Mix(neon, clrWhite, 0.45), "Bahnschrift", TA_CENTER | TA_BOTTOM, FW_BOLD);
   color bg = SkyAt(y);
   g_cv.FillEllipse(X(cx - w / 2 - 3), X(y - 3), X(cx + w / 2 + 3), X(y + 9), A(Mix(bg, neon, 0.2 + 0.3 * lit)));   // under-glow
   Box(cx - w / 2, y, cx + w / 2, y + 4, Mix(C'40,30,80', neon, 0.3 + 0.5 * lit));
   Box(cx - w / 2, y, cx + w / 2, y + 1, Mix(bg, neon, 0.8 + 0.2 * lit));
   Box(cx - w / 4, y - 7, cx + w / 4, y, Mix(C'30,22,64', neon, 0.2 + 0.4 * lit));
   for(double tx = cx - w / 2 + 4; tx < cx + w / 2 - 2; tx += 8)                    // thrusters
      Line(tx, y + 4, tx, y + 9 + 3 * lit, Mix(bg, C'255,150,60', 0.4 + 0.6 * lit), 1.4);
  }

//+------------------------------------------------------------------+
//| Golden holo-billboard (yesterday's high or low)                  |
//+------------------------------------------------------------------+
void Billboard(const double cx, const double y, const string s, const double lit, const string price)
  {
   color bg = SkyAt(y);
   Txt(cx, y - 10, price, 7, Mix(cGold, clrWhite, 0.3), "Bahnschrift", TA_CENTER | TA_BOTTOM, FW_BOLD);
   Box(cx - 30, y - 8, cx + 30, y + 8, Mix(bg, cGold, 0.18 + 0.2 * lit));
   Box(cx - 30, y - 8, cx + 30, y - 7, Mix(bg, cGold, 0.9));
   Box(cx - 30, y + 7, cx + 30, y + 8, Mix(bg, cGold, 0.9));
   Txt(cx, y, s, 8, Mix(cGold, clrWhite, 0.2 + 0.4 * lit), "Bahnschrift", TA_CENTER | TA_VCENTER, FW_BLACK);
  }

//+------------------------------------------------------------------+
//| Flying car = the price                                           |
//+------------------------------------------------------------------+
void Car(const double cx, const double cy)
  {
   color bg = SkyAt(cy);
   Line(cx - 60, cy + 3, cx - 20, cy + 3, Mix(bg, cCyan, 0.35), 2);               // light trail
   Line(cx - 40, cy + 6, cx - 20, cy + 6, Mix(bg, cMag, 0.35), 1.5);
   g_cv.FillEllipse(X(cx - 20), X(cy - 3), X(cx + 20), X(cy + 8), A(C'220,226,240'));
   g_cv.FillEllipse(X(cx - 10), X(cy - 9), X(cx + 10), X(cy + 2), A(C'40,200,240'));
   Box(cx - 16, cy + 6, cx + 16, cy + 8, cMag);
   Disc(cx + 19, cy + 2, 2, C'255,250,200');
  }

//+------------------------------------------------------------------+
//| Build (or rebuild) the canvas and the minimise button            |
//+------------------------------------------------------------------+
void BuildPanel()
  {
   g_cv.Destroy();
   g_H = g_min ? 56 : 560;
   if(!g_cv.CreateBitmapLabel(0, 0, CV_NAME, InpPanelX, InpPanelY, X(W), X(g_H), COLOR_FORMAT_ARGB_NORMALIZE))
      return;
   ObjectSetInteger(0, CV_NAME, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, CV_NAME, OBJPROP_SELECTABLE, false);
   ObjectSetString (0, CV_NAME, OBJPROP_TOOLTIP, "\n");
   g_cv.FontSet("Bahnschrift", 100);
   int fw, fh; g_cv.TextSize("Hg", fw, fh);
   if(fh > 0) g_fs = 133.0 / fh;
   //--- the button is recreated AFTER the canvas: objects created later are drawn on top
   ObjectDelete(0, BT_MIN);
   ObjectCreate(0, BT_MIN, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, BT_MIN, OBJPROP_XDISTANCE, InpPanelX + X(W - 32));
   ObjectSetInteger(0, BT_MIN, OBJPROP_YDISTANCE, InpPanelY + X(14));
   ObjectSetInteger(0, BT_MIN, OBJPROP_XSIZE, X(22));
   ObjectSetInteger(0, BT_MIN, OBJPROP_YSIZE, X(22));
   ObjectSetString (0, BT_MIN, OBJPROP_TEXT, g_min ? "+" : "-");
   ObjectSetString (0, BT_MIN, OBJPROP_FONT, "Bahnschrift");
   ObjectSetInteger(0, BT_MIN, OBJPROP_FONTSIZE, 11);
   ObjectSetInteger(0, BT_MIN, OBJPROP_COLOR, cCyan);
   ObjectSetInteger(0, BT_MIN, OBJPROP_BGCOLOR, C'30,10,60');
   ObjectSetInteger(0, BT_MIN, OBJPROP_BORDER_COLOR, cMag);
   ObjectSetInteger(0, BT_MIN, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, BT_MIN, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, BT_MIN, OBJPROP_STATE, false);
   ObjectSetString (0, BT_MIN, OBJPROP_TOOLTIP, "Minimise / restore the city");
  }

//+------------------------------------------------------------------+
//| Draw everything                                                  |
//+------------------------------------------------------------------+
void Draw()
  {
   if(ObjectFind(0, CV_NAME) < 0) BuildPanel();
   g_cv.Erase(0);
   //--- title bar
   for(int py = 0; py <= X(56); py++) g_cv.Line(0, py, X(W) - 1, py, A(Mix(C'6,4,22', C'20,8,44', py / (56.0 * g_k))));
   Neon(16, 8, "LIQUIDITY CITY", 20, cCyan, C'10,6,30');
   Txt(18, 36, "ANDY TRADING SOLUTIONS  //  " + _Symbol + " " + StringSubstr(EnumToString(_Period), 7), 8, cMag, "Bahnschrift", TA_LEFT | TA_TOP, FW_BOLD);
   Box(0, 55, W, 56, cMag);
   if(g_min) { g_cv.Update(); return; }

   //--- dark street level under everything, then sky, moon, distant skyline, neon grid floor
   Box(0, 56, W, g_H, C'6,4,18');
   double top = 56, ground = 404, mid = 230, span = 160;
   for(int py = X(top); py <= X(ground); py++) g_cv.Line(0, py, X(W) - 1, py, A(SkyAt(py / g_k)));
   Disc(W - 62, 96, 22, Mix(SkyAt(96), C'255,120,210', 0.35));
   Disc(W - 62, 96, 17, Mix(SkyAt(96), C'255,200,240', 0.55));
   for(int b = 0; b < 14; b++)                                                    // far skyline: low, flat, no windows
     {
      double bx = b * 27 - 6, bh = 18 + (b * 53) % 42;
      Box(bx, ground - bh, bx + 22, ground, Mix(SkyAt(ground - bh), C'8,4,20', 0.35));
     }
   Box(0, ground, W, ground + 22, C'14,6,32');
   for(int gx = -8; gx <= 8; gx++) Line(W / 2 + gx * 8, ground, W / 2 + gx * 34, ground + 22, Mix(C'14,6,32', cMag, 0.55), 1);
   for(int gy = 0; gy < 3; gy++) Line(0, ground + 4 + gy * 7, W, ground + 4 + gy * 7, Mix(C'14,6,32', cMag, 0.45), 1);

   //--- searchlight from the ground, swinging left-right
   double t = (GetTickCount() % 6000) / 6000.0;
   double beam = -M_PI / 2 + 0.9 * MathSin(2 * M_PI * t);                          // angle, straight up = -pi/2
   double bx0 = W / 2, by0 = ground;
   for(int k = -4; k <= 4; k++)
     {
      double a = beam + k * 0.018;
      double ex = bx0 + 420 * MathCos(a), ey = by0 + 420 * MathSin(a);
      Line(bx0, by0, ex, ey, Mix(SkyAt(mid), C'180,240,255', 0.22 - MathAbs(k) * 0.035), 2);
     }

   //--- active pools on each side, nearest first
   int f = g_f;
   int nUp = 0, nDn = 0;
   double nearUp = 0, nearDn = 0; int sUp = 0, sDn = 0; bool dUp = false, dDn = false;
   int    vq[]; double vd[]; int nv = 0;
   ArrayResize(vq, g_n); ArrayResize(vd, g_n);
   for(int q = 0; q < g_n; q++)
     {
      if(g_p[q].swept >= 0) continue;
      if(g_p[q].day && g_p[q].expires < f) continue;
      double dist = (g_p[q].level - g_last) * g_p[q].dir;
      if(dist <= 0) continue;
      if(g_p[q].dir > 0) { nUp++; if(nearUp == 0 || g_p[q].level < nearUp) { nearUp = g_p[q].level; sUp = g_p[q].strength; dUp = g_p[q].day; } }
      else               { nDn++; if(nearDn == 0 || g_p[q].level > nearDn) { nearDn = g_p[q].level; sDn = g_p[q].strength; dDn = g_p[q].day; } }
      vq[nv] = q; vd[nv] = g_atr > 0 ? dist / g_atr : 99; nv++;
     }
   for(int i = 1; i < nv; i++)                                                    // sort by distance
      for(int j = i; j > 0 && vd[j] < vd[j - 1]; j--)
        { double td = vd[j]; vd[j] = vd[j - 1]; vd[j - 1] = td; int tq = vq[j]; vq[j] = vq[j - 1]; vq[j - 1] = tq; }
   //--- the scale stretches so the nearest pool on each side is always in the city
   double far = 0;
   if(nearUp > 0 && g_atr > 0) far = MathMax(far, (nearUp - g_last) / g_atr);
   if(nearDn > 0 && g_atr > 0) far = MathMax(far, (g_last - nearDn) / g_atr);
   double R = MathMax(3.0, MathMin(12.0, MathCeil(far * 1.25)));
   //--- nearest pools go to the edges, away from the car; farther ones fill the middle
   double xs[7] = {18, 298, 64, 252, 110, 206, 158};
   int iu = 0, id = 0;
   for(int v = 0; v < nv; v++)
     {
      int q = vq[v];
      if(vd[v] > R) continue;
      if((g_p[q].dir > 0 ? iu : id) >= 7) continue;                                // 7 lots per side
      int slot = g_p[q].dir > 0 ? iu++ : id++;
      double y = g_p[q].dir > 0 ? mid - 140 * MathPow(vd[v] / R, 0.7) : mid + 150 * MathPow(vd[v] / R, 0.7);
      double x = xs[slot];
      double a = MathArctan2(y - by0, x + 20 - bx0);                                 // is the searchlight on it?
      double lit = MathMax(0.0, 1.0 - MathAbs(a - beam) / 0.25);
      color neon = g_p[q].strength > 1 ? cMag : cCyan;
      string px = DoubleToString(g_p[q].level, _Digits);
      if(g_p[q].day)
         Billboard(x + 20, y, g_p[q].dir > 0 ? "YDAY HIGH" : "YDAY LOW", lit, px);
      else if(g_p[q].dir < 0)
         Tower(x, 22 + 8 * MathMin(3, g_p[q].strength), y, ground, neon, lit, q, px);
      else
         Platform(x + 20, y, 26 + 10 * MathMin(3, g_p[q].strength), neon, lit, px);
     }
   //--- the price: a flying car cruising at mid-height
   Line(0, mid + 12, W, mid + 12, Mix(SkyAt(mid), cCyan, 0.18), 1);
   Car(W / 2, mid);
   Txt(W / 2 + 26, mid - 6, DoubleToString(g_last, _Digits), 10, cInk, "Bahnschrift", TA_LEFT | TA_TOP, FW_BOLD);
   Txt(8, 62, "BUY STOPS FLOAT ABOVE", 7, cDim);
   Txt(W - 8, 62, StringFormat("SCALE %.0f ATR", R), 7, cDim, "Bahnschrift", TA_RIGHT | TA_TOP);
   Box(8, ground + 6, 138, ground + 18, C'10,4,24');                              // street sign on the pavement
   Box(8, ground + 6, 138, ground + 7, cMag);
   Txt(73, ground + 12, "SELL STOPS SLEEP BELOW", 7, cDim, "Bahnschrift", TA_CENTER | TA_VCENTER);
   //--- pools beyond the scale are not lost, just out of sight
   if(nUp > iu) Txt(8, 74, StringFormat("+%d higher, off the map", nUp - iu), 7, Mix(cDim, cCyan, 0.4));
   if(nDn > id) Txt(W - 8, ground + 12, StringFormat("+%d deeper, off the map", nDn - id), 7, Mix(cDim, cMag, 0.4), "Bahnschrift", TA_RIGHT | TA_VCENTER);

   //--- readouts
   double y = 434;
   Box(10, y, W / 2 - 4, y + 52, C'12,6,30'); Box(W / 2 + 4, y, W - 10, y + 52, C'12,6,30');
   Box(10, y, W / 2 - 4, y + 1, cCyan);        Box(W / 2 + 4, y, W - 10, y + 1, cMag);
   Txt(18, y + 5, "NEAREST ABOVE", 8, cDim);
   Txt(W / 2 + 12, y + 5, "NEAREST BELOW", 8, cDim);
   Txt(18, y + 17, nearUp > 0 ? DoubleToString(nearUp, _Digits) : "none", 15, cCyan, "Bahnschrift", TA_LEFT | TA_TOP, FW_BLACK);
   Txt(W / 2 + 12, y + 17, nearDn > 0 ? DoubleToString(nearDn, _Digits) : "none", 15, cMag, "Bahnschrift", TA_LEFT | TA_TOP, FW_BLACK);
   if(nearUp > 0 && g_atr > 0)
      Txt(18, y + 37, StringFormat("+%.1f ATR  %s", (nearUp - g_last) / g_atr, dUp ? "YDAY HIGH" : (sUp > 1 ? StringFormat("EQUAL x%d", sUp) : "SWING")), 8, cGold);
   if(nearDn > 0 && g_atr > 0)
      Txt(W / 2 + 12, y + 37, StringFormat("-%.1f ATR  %s", (g_last - nearDn) / g_atr, dDn ? "YDAY LOW" : (sDn > 1 ? StringFormat("EQUAL x%d", sDn) : "SWING")), 8, cGold);

   //--- today's catch on a scrolling ticker
   y = 494;
   Box(10, y, W - 10, y + 54, C'8,4,20');
   Box(10, y, W - 10, y + 1, cGold);
   int caught = 0; string tape = "";
   for(int q = 0; q < g_n; q++)
     {
      if(g_p[q].swept < 0 || g_p[q].st < g_dayStart) continue;
      caught++;
      tape += StringFormat("  >>  %s %s %s %s", TimeToString(g_p[q].st, TIME_MINUTES), g_p[q].dir > 0 ? "HIGH" : "LOW",
                           DoubleToString(g_p[q].level, _Digits), g_p[q].rejected ? "GRABBED + REJECTED" : "TAKEN");
     }
   Txt(18, y + 6, StringFormat("TAKEN TODAY: %d", caught), 10, cGold, "Bahnschrift", TA_LEFT | TA_TOP, FW_BLACK);
   Txt(W - 18, y + 7, StringFormat("POOLS  %d UP  /  %d DOWN", nUp, nDn), 8, cDim, "Bahnschrift", TA_RIGHT | TA_TOP);
   if(tape == "") tape = "  >>  no pool taken yet today";
   g_cv.FontSet("Bahnschrift", (int)MathRound(9 * g_k * g_fs), FW_BOLD);
   int tw, th; g_cv.TextSize(tape, tw, th);
   double len = tw / g_k + 40;
   double off = MathMod(GetTickCount() / 25.0, MathMax(len, W));                    // scroll to the left
   for(double sx = 18 - off; sx < W; sx += MathMax(len, W))
      Txt(sx, y + 28, tape, 9, cCyan, "Bahnschrift", TA_LEFT | TA_TOP, FW_BOLD);
   Box(0, y + 1, 10, y + 54, C'8,4,20'); Box(W - 10, y + 1, W, y + 54, C'8,4,20');   // clip the tape at the edges
   Txt(W / 2, g_H - 5, "a map of where stops rest - not a forecast", 7, C'130,120,170', "Bahnschrift", TA_CENTER | TA_BOTTOM, FW_NORMAL);
   g_cv.Update();
  }

//+------------------------------------------------------------------+
//| Minimise / restore                                               |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == BT_MIN)
     {
      g_min = !g_min;
      GlobalVariableSet("ATSLC_min", g_min ? 1.0 : 0.0);
      BuildPanel();
      Draw();
      ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
