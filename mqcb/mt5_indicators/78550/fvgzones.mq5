//+------------------------------------------------------------------+
//|                                                     FVGZones.mq5 |
//|   Fair Value Gaps (FVG): unfilled imbalance zones on the chart    |
//|                                       Muhammad Muqeem Korejo      |
//+------------------------------------------------------------------+
//
// A fair value gap (FVG, imbalance) is a three-candle pattern where price
// moved so fast that the wicks of candle 1 and candle 3 do not overlap:
//   Bullish FVG: the low of candle 3 is above the high of candle 1.
//   Bearish FVG: the high of candle 3 is below the low of candle 1.
// The space between them is a zone that price often comes back to.
// The indicator:
//   - draws every gap as a box from candle 2 to the right while it is
//     unfilled, with its 50 % line (consequent encroachment);
//   - follows how much of the gap price has filled since it formed;
//   - ends the box when the gap is filled (100 % by default, or the
//     percent you set) and can keep filled gaps as grey boxes;
//   - can alert on a new gap and when price first comes back into a gap.
// Gaps are found on closed candles only, so they never repaint.
// Small gaps can be skipped with a minimum size in ATR or in points.
// Buffers for Expert Advisors (iCustom, not drawn):
//   0 / 1 = top / bottom of the newest unfilled bullish gap,
//   2 / 3 = top / bottom of the newest unfilled bearish gap,
//   EMPTY_VALUE when there is none.
// Read-only: the indicator never trades.
//
#property copyright   "Muhammad Muqeem Korejo"
#property link        "https://www.mql5.com/en/users/korejo123"
#property version     "1.00"
#property description "Fair Value Gaps (FVG): draws the unfilled three-candle imbalance zones,"
#property description "follows how much of each gap is filled and ends the box when it is filled."
#property description "50 % line, size filter in ATR or points, alerts on new gaps and on touches."
#property description "Closed candles only (no repaint). Buffers for EAs. Read-only: never trades."
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4
#property indicator_type1   DRAW_NONE
#property indicator_label1  "Bullish FVG top"
#property indicator_type2   DRAW_NONE
#property indicator_label2  "Bullish FVG bottom"
#property indicator_type3   DRAW_NONE
#property indicator_label3  "Bearish FVG top"
#property indicator_type4   DRAW_NONE
#property indicator_label4  "Bearish FVG bottom"

input int    InpBars        = 1500;              // Bars to scan
input double InpMinSizeATR  = 0.25;              // Minimum gap size, x ATR(14) (0 = no filter)
input int    InpMinPoints   = 0;                 // Minimum gap size, points (0 = no filter)
input int    InpFillPercent = 100;               // A gap counts as filled at this percent (50 = 50 % line)
input int    InpMaxActive   = 10;                // Unfilled gaps shown per direction
input bool   InpShowFilled  = false;             // Keep filled gaps as boxes
input int    InpMaxFilled   = 20;                // Filled gaps shown
input bool   InpShowMidline = true;              // Draw the 50 % line
input color  InpBullColor   = C'38,166,154';     // Bullish gap colour
input color  InpBearColor   = C'239,83,80';      // Bearish gap colour
input color  InpFilledColor = C'200,200,200';    // Filled gap colour
input color  InpMidColor    = clrDimGray;        // 50 % line colour
input bool   InpAlertNew    = false;             // Alert on a new gap
input bool   InpAlertTouch  = false;             // Alert when price comes back into a gap
input bool   InpPush        = false;             // Alerts also as push notification
input bool   InpEmail       = false;             // Alerts also by e-mail

#define ATR_PERIOD 14
#define PREFIX     "FVGZ_"

struct Zone
  {
   datetime          t1;        // candle 2: left edge of the box
   double            top;
   double            bottom;
   int               dir;       // +1 bullish, -1 bearish
   double            reach;     // deepest price inside the gap so far
   bool              touched;
   bool              filled;
   datetime          tFill;
  };

double   g_bullTop[], g_bullBot[], g_bearTop[], g_bearBot[];
Zone     g_z[];
int      g_n          = 0;
int      g_lastClosed = -1;     // last closed bar already processed
bool     g_live       = false;  // false while the history is calculated (no alerts)
bool     g_dirty      = true;   // the boxes must be drawn again
datetime g_lastBar    = 0;
string   g_drawn[];             // object names drawn last time

//+------------------------------------------------------------------+
//| Buffers                                                          |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpBars < 50 || InpFillPercent < 1 || InpFillPercent > 100 || InpMaxActive < 0 || InpMaxFilled < 0 ||
      InpMinSizeATR < 0 || InpMinPoints < 0)
     {
      Print("FVG Zones: bars 50 or more, fill percent 1 - 100, counts and sizes 0 or more");
      return INIT_PARAMETERS_INCORRECT;
     }
   SetIndexBuffer(0, g_bullTop, INDICATOR_DATA);
   SetIndexBuffer(1, g_bullBot, INDICATOR_DATA);
   SetIndexBuffer(2, g_bearTop, INDICATOR_DATA);
   SetIndexBuffer(3, g_bearBot, INDICATOR_DATA);
   for(int b = 0; b < 4; b++)
      PlotIndexSetDouble(b, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   IndicatorSetString(INDICATOR_SHORTNAME, "FVG Zones");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Remove the boxes                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, PREFIX);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Closed candles: find gaps and fills; forming candle: fills only  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
  {
   if(rates_total < ATR_PERIOD + 10)
      return 0;
   int first = MathMax(ATR_PERIOD + 3, rates_total - InpBars);
   if(prev_calculated == 0 || g_lastClosed < 0 || g_lastClosed > rates_total - 2)
     {
      //--- full calculation (first run or new history)
      ArrayInitialize(g_bullTop, EMPTY_VALUE);
      ArrayInitialize(g_bullBot, EMPTY_VALUE);
      ArrayInitialize(g_bearTop, EMPTY_VALUE);
      ArrayInitialize(g_bearBot, EMPTY_VALUE);
      ArrayResize(g_z, 0, 256);
      g_n          = 0;
      g_lastClosed = first - 1;
      g_live       = false;
      g_dirty      = true;
     }
   bool alerts = g_live;
   for(int k = g_lastClosed + 1; k <= rates_total - 2; k++)
     {
      UpdateFills(k, high, low, time, alerts && k == rates_total - 2);
      if(k - 2 >= first)
         Detect(k, high, low, close, time, alerts && k == rates_total - 2);
      SetBuffers(k);
      g_lastClosed = k;
     }
   //--- the forming candle can fill or touch a gap (it never creates one)
   UpdateFills(rates_total - 1, high, low, time, alerts);
   SetBuffers(rates_total - 1);
   if(time[rates_total - 1] != g_lastBar)
     {
      g_lastBar = time[rates_total - 1];
      g_dirty   = true;
     }
   if(g_dirty)
     {
      Draw(time[rates_total - 1]);
      g_dirty = false;
     }
   g_live = true;
   return rates_total;
  }

//+------------------------------------------------------------------+
//| Gap of candles k-2, k-1, k (candle k closed)                     |
//+------------------------------------------------------------------+
void Detect(const int k, const double &high[], const double &low[], const double &close[],
            const datetime &time[], const bool alert)
  {
   int    a = k - 2;
   double top = 0, bottom = 0;
   int    dir = 0;
   if(low[k] > high[a])
     {
      dir    = 1;
      top    = low[k];
      bottom = high[a];
     }
   else
      if(high[k] < low[a])
        {
         dir    = -1;
         top    = low[a];
         bottom = high[k];
        }
   if(dir == 0)
      return;
   double size = top - bottom;
   if(InpMinPoints > 0 && size < InpMinPoints * _Point)
      return;
   if(InpMinSizeATR > 0)
     {
      //--- ATR of the candles before the gap (candle 2 itself is left out)
      double sum = 0;
      for(int j = a - ATR_PERIOD + 1; j <= a; j++)
         sum += MathMax(high[j], close[j - 1]) - MathMin(low[j], close[j - 1]);
      double atr = sum / ATR_PERIOD;
      if(atr > 0 && size < InpMinSizeATR * atr)
         return;
     }
   if(g_n >= ArraySize(g_z))
      ArrayResize(g_z, g_n + 256, 256);
   g_z[g_n].t1      = time[k - 1];
   g_z[g_n].top     = top;
   g_z[g_n].bottom  = bottom;
   g_z[g_n].dir     = dir;
   g_z[g_n].reach   = (dir > 0 ? top : bottom);
   g_z[g_n].touched = false;
   g_z[g_n].filled  = false;
   g_z[g_n].tFill   = 0;
   g_n++;
   g_dirty = true;
   if(alert && InpAlertNew)
      Notify(StringFormat("new %s FVG %s - %s", dir > 0 ? "bullish" : "bearish",
                          DoubleToString(bottom, _Digits), DoubleToString(top, _Digits)));
   if(g_n > 3000)
      Compact();
  }

//+------------------------------------------------------------------+
//| How far candle k reached into each unfilled gap                  |
//+------------------------------------------------------------------+
void UpdateFills(const int k, const double &high[], const double &low[], const datetime &time[], const bool alert)
  {
   for(int i = g_n - 1; i >= 0; i--)
     {
      if(g_z[i].filled || time[k] <= g_z[i].t1)
         continue;
      double size = g_z[i].top - g_z[i].bottom;
      if(size <= 0)
         continue;
      bool   inside = false;
      double part   = 0;
      if(g_z[i].dir > 0 && low[k] < g_z[i].top)
        {
         inside        = true;
         g_z[i].reach  = MathMin(g_z[i].reach, low[k]);
         part          = (g_z[i].top - g_z[i].reach) / size;
        }
      if(g_z[i].dir < 0 && high[k] > g_z[i].bottom)
        {
         inside        = true;
         g_z[i].reach  = MathMax(g_z[i].reach, high[k]);
         part          = (g_z[i].reach - g_z[i].bottom) / size;
        }
      if(!inside)
         continue;
      if(!g_z[i].touched)
        {
         g_z[i].touched = true;
         if(alert && InpAlertTouch)
            Notify(StringFormat("price is back in the %s FVG %s - %s", g_z[i].dir > 0 ? "bullish" : "bearish",
                                DoubleToString(g_z[i].bottom, _Digits), DoubleToString(g_z[i].top, _Digits)));
        }
      if(part * 100.0 >= InpFillPercent - 1e-9)
        {
         g_z[i].filled = true;
         g_z[i].tFill  = time[k];
         g_dirty       = true;
        }
     }
  }

//+------------------------------------------------------------------+
//| Buffers of candle k: the newest unfilled gap of each direction   |
//+------------------------------------------------------------------+
void SetBuffers(const int k)
  {
   g_bullTop[k] = EMPTY_VALUE;
   g_bullBot[k] = EMPTY_VALUE;
   g_bearTop[k] = EMPTY_VALUE;
   g_bearBot[k] = EMPTY_VALUE;
   bool bull = false, bear = false;
   for(int i = g_n - 1; i >= 0 && !(bull && bear); i--)
     {
      if(g_z[i].filled)
         continue;
      if(g_z[i].dir > 0 && !bull)
        {
         g_bullTop[k] = g_z[i].top;
         g_bullBot[k] = g_z[i].bottom;
         bull = true;
        }
      if(g_z[i].dir < 0 && !bear)
        {
         g_bearTop[k] = g_z[i].top;
         g_bearBot[k] = g_z[i].bottom;
         bear = true;
        }
     }
  }

//+------------------------------------------------------------------+
//| Keep the newest unfilled gaps and the newest filled ones only    |
//+------------------------------------------------------------------+
void Compact()
  {
   int keepFilled = MathMax(InpMaxFilled, 1), filledSeen = 0, w = 0;
   for(int i = g_n - 1; i >= 0; i--)
      if(g_z[i].filled)
         filledSeen++;
   int skipFilled = filledSeen - keepFilled;
   for(int i = 0; i < g_n; i++)
     {
      if(g_z[i].filled && skipFilled > 0)
        {
         skipFilled--;
         continue;
        }
      g_z[w++] = g_z[i];
     }
   g_n = w;
  }

//+------------------------------------------------------------------+
//| Boxes: newest unfilled gaps per direction (+ filled gaps)        |
//+------------------------------------------------------------------+
void Draw(const datetime lastBar)
  {
   string now[];
   int    cnt = 0;
   datetime right = lastBar + PeriodSeconds() * 3;
   int bull = 0, bear = 0, filled = 0;
   for(int i = g_n - 1; i >= 0; i--)
     {
      bool show = false;
      color clr = InpFilledColor;
      datetime t2 = right;
      if(!g_z[i].filled)
        {
         if(g_z[i].dir > 0 && bull < InpMaxActive)
           {
            bull++;
            show = true;
            clr  = InpBullColor;
           }
         if(g_z[i].dir < 0 && bear < InpMaxActive)
           {
            bear++;
            show = true;
            clr  = InpBearColor;
           }
        }
      else
         if(InpShowFilled && filled < InpMaxFilled)
           {
            filled++;
            show = true;
            t2   = g_z[i].tFill;
           }
      if(!show)
         continue;
      string name = PREFIX + IntegerToString((long)g_z[i].t1) + (g_z[i].dir > 0 ? "_B" : "_S");
      Box(name, g_z[i].t1, g_z[i].top, t2, g_z[i].bottom, clr);
      ArrayResize(now, cnt + 2, 64);
      now[cnt++] = name;
      if(InpShowMidline && !g_z[i].filled)
        {
         Mid(name + "_M", g_z[i].t1, t2, (g_z[i].top + g_z[i].bottom) / 2.0, InpMidColor);
         now[cnt++] = name + "_M";
        }
      else
         ObjectDelete(0, name + "_M");
     }
   ArrayResize(now, cnt);
   //--- remove the boxes that are not shown any more
   for(int i = 0; i < ArraySize(g_drawn); i++)
     {
      bool still = false;
      for(int j = 0; j < cnt && !still; j++)
         still = (now[j] == g_drawn[i]);
      if(!still)
         ObjectDelete(0, g_drawn[i]);
     }
   ArrayResize(g_drawn, cnt);
   for(int j = 0; j < cnt; j++)
      g_drawn[j] = now[j];
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| One filled rectangle behind the candles                          |
//+------------------------------------------------------------------+
void Box(const string name, const datetime t1, const double p1, const datetime t2, const double p2, const color clr)
  {
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, p1, t2, p2);
      ObjectSetInteger(0, name, OBJPROP_FILL, true);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
     }
   ObjectSetInteger(0, name, OBJPROP_TIME, 0, t1);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 0, p1);
   ObjectSetInteger(0, name, OBJPROP_TIME, 1, t2);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 1, p2);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
  }

//+------------------------------------------------------------------+
//| Dotted 50 % line of a gap                                        |
//+------------------------------------------------------------------+
void Mid(const string name, const datetime t1, const datetime t2, const double price, const color clr)
  {
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_TREND, 0, t1, price, t2, price);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
     }
   ObjectSetInteger(0, name, OBJPROP_TIME, 0, t1);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 0, price);
   ObjectSetInteger(0, name, OBJPROP_TIME, 1, t2);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 1, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
  }

//+------------------------------------------------------------------+
//| Alert, push and e-mail                                           |
//+------------------------------------------------------------------+
void Notify(const string text)
  {
   string msg = "FVG Zones " + _Symbol + " " + StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period), 7) + ": " + text;
   Alert(msg);
   if(InpPush)
      SendNotification(msg);
   if(InpEmail)
      SendMail("FVG Zones " + _Symbol, msg);
  }
//+------------------------------------------------------------------+
