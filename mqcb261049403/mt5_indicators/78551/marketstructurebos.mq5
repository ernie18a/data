//+------------------------------------------------------------------+
//|                                           MarketStructureBOS.mq5 |
//|   Market structure: swing points, BOS and CHoCH (no repaint)      |
//|                                       Muhammad Muqeem Korejo      |
//+------------------------------------------------------------------+
//
// Market structure in the way of Smart Money Concepts (SMC):
//   Swing high: a high above the highs of the N candles on each side.
//   Swing low : a low below the lows of the N candles on each side.
//   A swing counts only when its N right candles are closed, so nothing
//   repaints. Each swing gets a label: HH / LH (higher or lower than the
//   last swing high) and HL / LL (higher or lower than the last swing low).
//   BOS (break of structure): a candle closes beyond the last swing in
//   the direction of the trend - the trend goes on.
//   CHoCH (change of character): a candle closes beyond the last swing
//   against the trend - the trend turns.
// Each break is drawn as a line from the swing to the breaking candle
// with a BOS or CHoCH label. The break can be by close (default) or by
// wick. Alerts on BOS and CHoCH (popup, push, e-mail).
// Buffers for Expert Advisors (iCustom, not drawn):
//   0 = trend (+1 up, -1 down, 0 none yet),
//   1 = last swing high, 2 = last swing low (EMPTY_VALUE when none).
// Read-only: the indicator never trades.
//
#property copyright   "Muhammad Muqeem Korejo"
#property link        "https://www.mql5.com/en/users/korejo123"
#property version     "1.00"
#property description "Market structure (SMC): swing highs and lows with HH / HL / LH / LL labels,"
#property description "BOS (break of structure) and CHoCH (change of character) lines and labels."
#property description "Swings count only after their right candles close: no repaint."
#property description "Alerts on BOS and CHoCH, trend buffer for EAs. Read-only: never trades."
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3
#property indicator_type1   DRAW_NONE
#property indicator_label1  "Trend"
#property indicator_type2   DRAW_NONE
#property indicator_label2  "Last swing high"
#property indicator_type3   DRAW_NONE
#property indicator_label3  "Last swing low"

input int    InpSwing      = 5;                 // Swing strength (candles on each side)
input bool   InpCloseBreak = true;              // Break by close (false = by wick)
input int    InpBars       = 3000;              // Bars to scan
input int    InpMaxBreaks  = 30;                // BOS / CHoCH shown
input bool   InpShowSwings = true;              // Show HH / HL / LH / LL labels
input int    InpMaxSwings  = 40;                // Swing labels shown
input color  InpBullColor  = clrDodgerBlue;     // Bullish break colour
input color  InpBearColor  = clrCrimson;        // Bearish break colour
input color  InpSwingColor = clrDimGray;        // Swing label colour
input int    InpFontSize   = 8;                 // Label font size
input bool   InpAlerts     = false;             // Alert on BOS / CHoCH
input bool   InpPush       = false;             // Alerts also as push notification
input bool   InpEmail      = false;             // Alerts also by e-mail

#define PREFIX "MSBOS_"

struct Brk
  {
   datetime          tSwing;    // swing candle
   datetime          tBreak;    // breaking candle
   double            level;
   int               dir;       // +1 bullish break, -1 bearish break
   bool              choch;
  };

struct Swg
  {
   datetime          t;
   double            price;
   bool              high;
   string            tag;       // HH, LH, HL, LL
  };

double   g_trend[], g_sh[], g_sl[];
Brk      g_b[];
Swg      g_s[];
int      g_nb = 0, g_ns = 0;
int      g_lastClosed = -1;
int      g_dir = 0;                         // current trend
double   g_shPrice = 0, g_slPrice = 0;      // last swing high / low
datetime g_shTime = 0, g_slTime = 0;
bool     g_shUsed = true, g_slUsed = true;  // already broken
bool     g_live = false;
bool     g_dirty = true;

//+------------------------------------------------------------------+
//| Buffers                                                          |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpSwing < 1 || InpBars < 50 || InpMaxBreaks < 0 || InpMaxSwings < 0 || InpFontSize < 5)
     {
      Print("Market Structure: swing 1 or more, bars 50 or more, counts 0 or more, font 5 or more");
      return INIT_PARAMETERS_INCORRECT;
     }
   SetIndexBuffer(0, g_trend, INDICATOR_DATA);
   SetIndexBuffer(1, g_sh, INDICATOR_DATA);
   SetIndexBuffer(2, g_sl, INDICATOR_DATA);
   for(int b = 0; b < 3; b++)
      PlotIndexSetDouble(b, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   IndicatorSetString(INDICATOR_SHORTNAME, "Market Structure (" + IntegerToString(InpSwing) + ")");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Remove the drawings                                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, PREFIX);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Closed candles only: swings, breaks, buffers                     |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
  {
   int N = InpSwing;
   if(rates_total < 2 * N + 5)
      return 0;
   int first = MathMax(N, rates_total - InpBars);
   if(prev_calculated == 0 || g_lastClosed < 0 || g_lastClosed > rates_total - 2)
     {
      ArrayInitialize(g_trend, EMPTY_VALUE);
      ArrayInitialize(g_sh, EMPTY_VALUE);
      ArrayInitialize(g_sl, EMPTY_VALUE);
      ArrayResize(g_b, 0, 64);
      ArrayResize(g_s, 0, 64);
      g_nb = g_ns = 0;
      g_dir = 0;
      g_shPrice = g_slPrice = 0;
      g_shTime = g_slTime = 0;
      g_shUsed = g_slUsed = true;
      g_lastClosed = first + N - 1;
      g_live  = false;
      g_dirty = true;
      ObjectsDeleteAll(0, PREFIX);
     }
   bool alerts = g_live;
   for(int k = g_lastClosed + 1; k <= rates_total - 2; k++)
     {
      //--- the candle N bars back is a swing now that its right side is closed
      int p = k - N;
      if(p - N >= first)
        {
         if(IsSwingHigh(p, N, high))
            AddSwing(time[p], high[p], true);
         if(IsSwingLow(p, N, low))
            AddSwing(time[p], low[p], false);
        }
      //--- breaks of the last swing high / low by candle k
      double upPrice = (InpCloseBreak ? close[k] : high[k]);
      double dnPrice = (InpCloseBreak ? close[k] : low[k]);
      if(!g_shUsed && upPrice > g_shPrice)
         AddBreak(1, time[k], alerts && k == rates_total - 2);
      if(!g_slUsed && dnPrice < g_slPrice)
         AddBreak(-1, time[k], alerts && k == rates_total - 2);
      SetBuffers(k);
      g_lastClosed = k;
     }
   SetBuffers(rates_total - 1);
   if(g_dirty)
     {
      Draw();
      g_dirty = false;
     }
   g_live = true;
   return rates_total;
  }

//+------------------------------------------------------------------+
//| Higher than the N candles on each side (equal on the left only)  |
//+------------------------------------------------------------------+
bool IsSwingHigh(const int p, const int N, const double &high[])
  {
   for(int j = 1; j <= N; j++)
      if(high[p - j] > high[p] || high[p + j] >= high[p])
         return false;
   return true;
  }

//+------------------------------------------------------------------+
//| Lower than the N candles on each side (equal on the left only)   |
//+------------------------------------------------------------------+
bool IsSwingLow(const int p, const int N, const double &low[])
  {
   for(int j = 1; j <= N; j++)
      if(low[p - j] < low[p] || low[p + j] <= low[p])
         return false;
   return true;
  }

//+------------------------------------------------------------------+
//| New swing: label against the last swing of the same kind         |
//+------------------------------------------------------------------+
void AddSwing(const datetime t, const double price, const bool isHigh)
  {
   string tag;
   if(isHigh)
     {
      tag       = (g_shTime == 0 ? "H" : (price > g_shPrice ? "HH" : "LH"));
      g_shPrice = price;
      g_shTime  = t;
      g_shUsed  = false;
     }
   else
     {
      tag       = (g_slTime == 0 ? "L" : (price > g_slPrice ? "HL" : "LL"));
      g_slPrice = price;
      g_slTime  = t;
      g_slUsed  = false;
     }
   if(g_ns >= ArraySize(g_s))
      ArrayResize(g_s, g_ns + 64, 64);
   g_s[g_ns].t     = t;
   g_s[g_ns].price = price;
   g_s[g_ns].high  = isHigh;
   g_s[g_ns].tag   = tag;
   g_ns++;
   g_dirty = true;
   if(g_ns > 2000)
     {
      ArrayRemove(g_s, 0, 1000);
      g_ns -= 1000;
     }
  }

//+------------------------------------------------------------------+
//| BOS or CHoCH of the last swing high (dir +1) or low (dir -1)     |
//+------------------------------------------------------------------+
void AddBreak(const int dir, const datetime tBreak, const bool alert)
  {
   bool choch = (g_dir != 0 && g_dir != dir);
   if(g_nb >= ArraySize(g_b))
      ArrayResize(g_b, g_nb + 64, 64);
   g_b[g_nb].tSwing = (dir > 0 ? g_shTime : g_slTime);
   g_b[g_nb].tBreak = tBreak;
   g_b[g_nb].level  = (dir > 0 ? g_shPrice : g_slPrice);
   g_b[g_nb].dir    = dir;
   g_b[g_nb].choch  = choch;
   g_nb++;
   if(dir > 0)
      g_shUsed = true;
   else
      g_slUsed = true;
   g_dir   = dir;
   g_dirty = true;
   if(alert && InpAlerts)
      Notify(StringFormat("%s %s at %s", dir > 0 ? "bullish" : "bearish", choch ? "CHoCH" : "BOS",
                          DoubleToString(g_b[g_nb - 1].level, _Digits)));
   if(g_nb > 2000)
     {
      ArrayRemove(g_b, 0, 1000);
      g_nb -= 1000;
     }
  }

//+------------------------------------------------------------------+
//| Trend and the last swing levels on candle k                      |
//+------------------------------------------------------------------+
void SetBuffers(const int k)
  {
   g_trend[k] = g_dir;
   g_sh[k]    = (g_shTime > 0 ? g_shPrice : EMPTY_VALUE);
   g_sl[k]    = (g_slTime > 0 ? g_slPrice : EMPTY_VALUE);
  }

//+------------------------------------------------------------------+
//| Lines and labels of the newest breaks and swings                 |
//+------------------------------------------------------------------+
void Draw()
  {
   ObjectsDeleteAll(0, PREFIX);
   for(int i = MathMax(0, g_nb - InpMaxBreaks); i < g_nb; i++)
     {
      string name = PREFIX + "B" + IntegerToString((long)g_b[i].tBreak) + (g_b[i].dir > 0 ? "u" : "d");
      color  clr  = (g_b[i].dir > 0 ? InpBullColor : InpBearColor);
      ObjectCreate(0, name, OBJ_TREND, 0, g_b[i].tSwing, g_b[i].level, g_b[i].tBreak, g_b[i].level);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_STYLE, g_b[i].choch ? STYLE_SOLID : STYLE_DASH);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      //--- the label sits on the other side of the line than the swing label
      datetime mid = g_b[i].tSwing + (g_b[i].tBreak - g_b[i].tSwing) / 2;
      Label(name + "t", mid, g_b[i].level, g_b[i].choch ? "CHoCH" : "BOS", clr,
            g_b[i].dir > 0 ? ANCHOR_UPPER : ANCHOR_LOWER);
     }
   if(InpShowSwings)
      for(int i = MathMax(0, g_ns - InpMaxSwings); i < g_ns; i++)
         Label(PREFIX + "S" + IntegerToString((long)g_s[i].t) + (g_s[i].high ? "h" : "l"), g_s[i].t, g_s[i].price,
               g_s[i].tag, InpSwingColor, g_s[i].high ? ANCHOR_LOWER : ANCHOR_UPPER);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| One text label at a price                                        |
//+------------------------------------------------------------------+
void Label(const string name, const datetime t, const double price, const string text, const color clr,
           const ENUM_ANCHOR_POINT anchor)
  {
   ObjectCreate(0, name, OBJ_TEXT, 0, t, price);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpFontSize);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, anchor);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//| Alert, push and e-mail                                           |
//+------------------------------------------------------------------+
void Notify(const string text)
  {
   string msg = "Market Structure " + _Symbol + " " + StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period), 7) + ": " + text;
   Alert(msg);
   if(InpPush)
      SendNotification(msg);
   if(InpEmail)
      SendMail("Market Structure " + _Symbol, msg);
  }
//+------------------------------------------------------------------+
