//+------------------------------------------------------------------+
//|                                                  OrderBlocks.mq5 |
//|   Order Blocks and Breaker Blocks (Smart Money Concepts)          |
//|                                       Muhammad Muqeem Korejo      |
//+------------------------------------------------------------------+
//
// Order block (OB): the last opposite candle before a move that breaks
// market structure.
//   Bullish OB: a closed candle breaks above the last confirmed swing high.
//     In the leg before the break, the last down candle at (or just before)
//     the lowest point is the order block.
//   Bearish OB: the mirror - a close below the last swing low, the last up
//     candle at (or just before) the highest point of the leg.
// A swing high is a high above the highs of N candles on each side
// (N = swing strength). It is known only when its N right candles have
// closed, and a break needs a closed candle, so a block never appears
// early and never repaints.
// Zone: the whole candle (high - low) or only its body (open - close).
// Mitigation (input):
//   Touch - the block is used up when price comes back into it,
//   Half  - when price reaches its 50 % line,
//   Break - the block stays active until it is broken.
// A candle that closes beyond the far side of a block breaks it. A broken
// block becomes a breaker block of the other direction (a broken bullish
// block turns into resistance, a broken bearish block into support) until
// a candle closes back through it.
// Optional filter: the move from the block to the breaking close must be
// at least X x ATR(14).
// Buffers for Expert Advisors (iCustom, not drawn):
//   0 / 1 = top / bottom of the newest active bullish order block,
//   2 / 3 = top / bottom of the newest active bearish order block,
//   EMPTY_VALUE when there is none.
// Read-only: the indicator never trades.
//
#property copyright   "Muhammad Muqeem Korejo"
#property link        "https://www.mql5.com/en/users/korejo123"
#property version     "1.00"
#property description "Order Blocks and Breaker Blocks (Smart Money Concepts): the last opposite candle"
#property description "before a break of market structure, with three mitigation rules (touch, 50 %, break)"
#property description "and breaker blocks when a block fails. Closed candles only (no repaint)."
#property description "Alerts and buffers for EAs. Read-only: never trades."
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4
#property indicator_type1   DRAW_NONE
#property indicator_label1  "Bullish OB top"
#property indicator_type2   DRAW_NONE
#property indicator_label2  "Bullish OB bottom"
#property indicator_type3   DRAW_NONE
#property indicator_label3  "Bearish OB top"
#property indicator_type4   DRAW_NONE
#property indicator_label4  "Bearish OB bottom"

enum ENUM_OB_ZONE
  {
   OB_WICK = 0,   // Whole candle (high - low)
   OB_BODY = 1    // Candle body only (open - close)
  };

enum ENUM_OB_MITIGATION
  {
   MIT_TOUCH = 0, // Touch: price comes back into the block
   MIT_HALF  = 1, // Half: price reaches the 50 % line
   MIT_BREAK = 2  // Break: only a close through the block ends it
  };

input int                InpSwing       = 10;               // Swing strength (candles on each side)
input ENUM_OB_ZONE       InpZone        = OB_WICK;          // Block zone
input ENUM_OB_MITIGATION InpMitigation  = MIT_TOUCH;        // Block is used up at
input double             InpMinMoveATR  = 0.0;              // Breaking move at least x ATR(14) (0 = no filter)
input int                InpBars        = 2000;             // Bars to scan
input int                InpMaxActive   = 3;                // Active blocks shown per direction
input bool               InpShowUsed    = true;             // Show used and broken blocks as grey boxes
input int                InpMaxUsed     = 6;                // Used / broken blocks shown
input bool               InpBreakers    = true;             // Broken blocks become breaker blocks
input int                InpMaxBreakers = 3;                // Breaker blocks shown
input bool               InpLabels      = true;             // Names on active blocks and breakers
input color              InpBullColor   = C'166,214,190';   // Bullish block colour
input color              InpBearColor   = C'242,182,182';   // Bearish block colour
input color              InpUsedColor   = C'225,225,225';   // Used / broken block colour
input color              InpBreakColor  = C'190,200,240';   // Breaker block colour
input color              InpTextColor   = clrDimGray;       // Label colour
input bool               InpAlertNew    = false;            // Alert on a new block
input bool               InpAlertTouch  = false;            // Alert when price comes back to a block
input bool               InpPush        = false;            // Alerts also as push notification
input bool               InpEmail       = false;            // Alerts also by e-mail

#define ATR_PERIOD 14
#define PREFIX     "OBLK_"
#define ST_ACTIVE  0
#define ST_USED    1
#define ST_BROKEN  2

struct Block
  {
   datetime          t0;        // the order block candle (the id)
   datetime          t1;        // left edge of the box (a breaker starts at its break)
   double            top;
   double            bottom;
   int               dir;       // +1 bullish (support), -1 bearish (resistance)
   bool              breaker;   // a broken block, now of the other direction
   int               state;     // ST_ACTIVE, ST_USED, ST_BROKEN
   bool              touched;
   datetime          tEnd;      // when it was used or broken
  };

double   g_bullTop[], g_bullBot[], g_bearTop[], g_bearBot[];
Block    g_b[];
int      g_n          = 0;
int      g_lastClosed = -1;      // last closed bar already processed
datetime g_closedTime = 0;       // its time (another time there = the history has changed)
bool     g_live       = false;   // false while the history is calculated (no alerts)
bool     g_dirty      = true;
datetime g_lastBar    = 0;
string   g_drawn[];
//--- last confirmed swings (bar index, level) and whether a close has broken them
int      g_shIdx = -1, g_slIdx = -1;
double   g_shLvl = 0,  g_slLvl = 0;
bool     g_shBroken = true, g_slBroken = true;

//+------------------------------------------------------------------+
//| Buffers                                                          |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpSwing < 1 || InpSwing > 50 || InpBars < 100 || InpMinMoveATR < 0 ||
      InpMaxActive < 0 || InpMaxActive > 100 || InpMaxUsed < 0 || InpMaxUsed > 100 ||
      InpMaxBreakers < 0 || InpMaxBreakers > 100)
     {
      Print("Order Blocks: swing strength 1 - 50, bars 100 or more, counts 0 - 100, ATR filter 0 or more");
      return INIT_PARAMETERS_INCORRECT;
     }
   SetIndexBuffer(0, g_bullTop, INDICATOR_DATA);
   SetIndexBuffer(1, g_bullBot, INDICATOR_DATA);
   SetIndexBuffer(2, g_bearTop, INDICATOR_DATA);
   SetIndexBuffer(3, g_bearBot, INDICATOR_DATA);
   for(int b = 0; b < 4; b++)
      PlotIndexSetDouble(b, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   IndicatorSetString(INDICATOR_SHORTNAME, "Order Blocks");
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
//| Closed candles: swings, breaks, blocks; forming candle: touches  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
  {
   int need = MathMax(ATR_PERIOD + 2, 2 * InpSwing + 2) + 5;
   if(rates_total < need + 2)
      return 0;
   if(prev_calculated == 0 || g_lastClosed < 0 || g_lastClosed > rates_total - 2 || time[g_lastClosed] != g_closedTime)
     {
      //--- full calculation (first run or new history)
      ArrayInitialize(g_bullTop, EMPTY_VALUE);
      ArrayInitialize(g_bullBot, EMPTY_VALUE);
      ArrayInitialize(g_bearTop, EMPTY_VALUE);
      ArrayInitialize(g_bearBot, EMPTY_VALUE);
      ArrayResize(g_b, 0, 256);
      g_n          = 0;
      g_shIdx      = -1;
      g_slIdx      = -1;
      g_shBroken   = true;
      g_slBroken   = true;
      g_lastClosed = MathMax(need, rates_total - InpBars) - 1;
      g_live       = false;
      g_dirty      = true;
     }
   bool alerts = g_live;
   for(int k = g_lastClosed + 1; k <= rates_total - 2; k++)
     {
      bool last = (k == rates_total - 2);
      UpdateBlocks(k, high, low, close, time, true, alerts && last);
      ConfirmSwing(k, high, low);
      DetectBreak(k, open, high, low, close, time, alerts && last);
      SetBuffers(k);
      if(g_n > 3000)
         Compact();
      g_lastClosed = k;
      g_closedTime = time[k];
     }
   //--- the forming candle can touch a block (it never creates or breaks one)
   UpdateBlocks(rates_total - 1, high, low, close, time, false, alerts);
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
//| Candle k closed: is candle k - N a swing high or a swing low?     |
//+------------------------------------------------------------------+
void ConfirmSwing(const int k, const double &high[], const double &low[])
  {
   int p = k - InpSwing;
   if(p - InpSwing < 0)
      return;
   bool isHigh = true, isLow = true;
   for(int j = 1; j <= InpSwing && (isHigh || isLow); j++)
     {
      //--- strictly above the left side, not below the right side (a flat top counts once)
      if(high[p] <= high[p - j] || high[p] < high[p + j])
         isHigh = false;
      if(low[p] >= low[p - j] || low[p] > low[p + j])
         isLow = false;
     }
   if(isHigh)
     {
      g_shIdx    = p;
      g_shLvl    = high[p];
      g_shBroken = false;
     }
   if(isLow)
     {
      g_slIdx    = p;
      g_slLvl    = low[p];
      g_slBroken = false;
     }
  }

//+------------------------------------------------------------------+
//| Candle k closed beyond the last swing: a new order block         |
//+------------------------------------------------------------------+
void DetectBreak(const int k, const double &open[], const double &high[], const double &low[],
                 const double &close[], const datetime &time[], const bool alert)
  {
   //--- bullish break of the last swing high
   if(!g_shBroken && g_shIdx >= 0 && g_shIdx < k && close[k] > g_shLvl)
     {
      g_shBroken = true;
      //--- lowest point of the leg between the swing high and the break
      int m = g_shIdx + 1;
      for(int i = g_shIdx + 1; i <= k; i++)
         if(low[i] < low[m])
            m = i;
      //--- the last down candle at or before that point
      int j = m;
      while(j > g_shIdx && close[j] >= open[j])
         j--;
      if(j <= g_shIdx)
         j = m;
      double top    = (InpZone == OB_BODY ? MathMax(open[j], close[j]) : high[j]);
      double bottom = (InpZone == OB_BODY ? MathMin(open[j], close[j]) : low[j]);
      if(MoveOk(k, close[k] - bottom, high, low, close))
         AddBlock(time[j], time[j], top, bottom, 1, false, alert);
     }
   //--- bearish break of the last swing low
   if(!g_slBroken && g_slIdx >= 0 && g_slIdx < k && close[k] < g_slLvl)
     {
      g_slBroken = true;
      int m = g_slIdx + 1;
      for(int i = g_slIdx + 1; i <= k; i++)
         if(high[i] > high[m])
            m = i;
      int j = m;
      while(j > g_slIdx && close[j] <= open[j])
         j--;
      if(j <= g_slIdx)
         j = m;
      double top    = (InpZone == OB_BODY ? MathMax(open[j], close[j]) : high[j]);
      double bottom = (InpZone == OB_BODY ? MathMin(open[j], close[j]) : low[j]);
      if(MoveOk(k, top - close[k], high, low, close))
         AddBlock(time[j], time[j], top, bottom, -1, false, alert);
     }
  }

//+------------------------------------------------------------------+
//| Size filter: the breaking move at least InpMinMoveATR x ATR(14)  |
//+------------------------------------------------------------------+
bool MoveOk(const int k, const double move, const double &high[], const double &low[], const double &close[])
  {
   if(InpMinMoveATR <= 0)
      return true;
   if(k - ATR_PERIOD < 1)
      return false;
   double sum = 0;
   for(int i = k - ATR_PERIOD + 1; i <= k; i++)
      sum += MathMax(high[i], close[i - 1]) - MathMin(low[i], close[i - 1]);
   double atr = sum / ATR_PERIOD;
   return (atr > 0 && move >= InpMinMoveATR * atr);
  }

//+------------------------------------------------------------------+
//| Store a block (or a breaker)                                     |
//+------------------------------------------------------------------+
void AddBlock(const datetime t0, const datetime t1, const double top, const double bottom, const int dir,
              const bool breaker, const bool alert)
  {
   if(top <= bottom)
      return;
   //--- the same candle can be found again by a later break: keep it once
   for(int i = g_n - 1; i >= 0 && i >= g_n - 20; i--)
      if(g_b[i].t0 == t0 && g_b[i].dir == dir && g_b[i].breaker == breaker)
         return;
   if(g_n >= ArraySize(g_b))
      ArrayResize(g_b, g_n + 256, 256);
   g_b[g_n].t0      = t0;
   g_b[g_n].t1      = t1;
   g_b[g_n].top     = top;
   g_b[g_n].bottom  = bottom;
   g_b[g_n].dir     = dir;
   g_b[g_n].breaker = breaker;
   g_b[g_n].state   = ST_ACTIVE;
   g_b[g_n].touched = false;
   g_b[g_n].tEnd    = 0;
   g_n++;
   g_dirty = true;
   if(alert && InpAlertNew)
      Notify(StringFormat("new %s %s %s - %s", dir > 0 ? "bullish" : "bearish", breaker ? "breaker block" : "order block",
                          DoubleToString(bottom, _Digits), DoubleToString(top, _Digits)));
  }

//+------------------------------------------------------------------+
//| Candle k: touches, mitigation, breaks (breaks need a close)       |
//+------------------------------------------------------------------+
void UpdateBlocks(const int k, const double &high[], const double &low[], const double &close[],
                  const datetime &time[], const bool closed, const bool alert)
  {
   int n = g_n;                       // breakers created here are checked from the next candle on
   for(int i = n - 1; i >= 0; i--)
     {
      if(g_b[i].state == ST_BROKEN || time[k] <= g_b[i].t1)
         continue;
      double top = g_b[i].top, bottom = g_b[i].bottom, mid = (top + bottom) / 2.0;
      int    dir = g_b[i].dir;
      //--- a close beyond the far side breaks the block (also a used one)
      if(closed && ((dir > 0 && close[k] < bottom) || (dir < 0 && close[k] > top)))
        {
         if(g_b[i].state == ST_ACTIVE)
            g_b[i].tEnd = time[k];
         g_b[i].state = ST_BROKEN;
         g_dirty      = true;
         if(InpBreakers && !g_b[i].breaker)
            AddBlock(g_b[i].t0, time[k], top, bottom, -dir, true, alert);
         continue;
        }
      if(g_b[i].state != ST_ACTIVE)
         continue;
      bool inside = (dir > 0 ? low[k] <= top : high[k] >= bottom);
      if(!inside)
         continue;
      if(!g_b[i].touched)
        {
         g_b[i].touched = true;
         if(alert && InpAlertTouch)
            Notify(StringFormat("price is back at the %s %s %s - %s", dir > 0 ? "bullish" : "bearish",
                                g_b[i].breaker ? "breaker block" : "order block",
                                DoubleToString(bottom, _Digits), DoubleToString(top, _Digits)));
        }
      //--- breakers stay until a close through them; order blocks are used up by the mitigation rule
      if(g_b[i].breaker || InpMitigation == MIT_BREAK)
         continue;
      bool used = (InpMitigation == MIT_TOUCH) || (dir > 0 ? low[k] <= mid : high[k] >= mid);
      if(used)
        {
         g_b[i].state = ST_USED;
         g_b[i].tEnd  = time[k];
         g_dirty      = true;
        }
     }
  }

//+------------------------------------------------------------------+
//| Buffers of candle k: the newest active order block per direction |
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
      if(g_b[i].state != ST_ACTIVE || g_b[i].breaker)
         continue;
      if(g_b[i].dir > 0 && !bull)
        {
         g_bullTop[k] = g_b[i].top;
         g_bullBot[k] = g_b[i].bottom;
         bull = true;
        }
      if(g_b[i].dir < 0 && !bear)
        {
         g_bearTop[k] = g_b[i].top;
         g_bearBot[k] = g_b[i].bottom;
         bear = true;
        }
     }
  }

//+------------------------------------------------------------------+
//| Keep the newest ended blocks and at most 1000 active ones        |
//+------------------------------------------------------------------+
void Compact()
  {
   int ended = 0;
   for(int i = 0; i < g_n; i++)
      if(g_b[i].state != ST_ACTIVE)
         ended++;
   int skipEnded  = ended - MathMax(InpMaxUsed + InpMaxBreakers, 50);
   int skipActive = (g_n - ended) - 1000;
   int w = 0;
   for(int i = 0; i < g_n; i++)
     {
      if(g_b[i].state != ST_ACTIVE)
        {
         if(skipEnded > 0)
           {
            skipEnded--;
            continue;
           }
        }
      else
         if(skipActive > 0)
           {
            skipActive--;
            continue;
           }
      g_b[w++] = g_b[i];
     }
   g_n = w;
  }

//+------------------------------------------------------------------+
//| Boxes: active blocks, breakers and used blocks (newest first)    |
//+------------------------------------------------------------------+
void Draw(const datetime lastBar)
  {
   string now[];
   int    cnt = 0;
   datetime right = lastBar + PeriodSeconds() * 10;
   int bull = 0, bear = 0, used = 0, brk = 0;
   for(int i = g_n - 1; i >= 0; i--)
     {
      bool     show = false;
      color    clr  = InpUsedColor;
      datetime t2   = right;
      string   text = "";
      string   kind = (g_b[i].dir > 0 ? "bullish" : "bearish");
      string   tip  = "";
      if(g_b[i].breaker)
        {
         if(g_b[i].state == ST_ACTIVE && InpBreakers && brk < InpMaxBreakers)
           {
            brk++;
            show = true;
            clr  = InpBreakColor;
            text = (g_b[i].dir > 0 ? "Bull breaker" : "Bear breaker");
            tip  = (g_b[i].dir > 0 ? "Bullish breaker (broken bearish OB)" : "Bearish breaker (broken bullish OB)");
           }
        }
      else
         if(g_b[i].state == ST_ACTIVE)
           {
            if(g_b[i].dir > 0 && bull < InpMaxActive)
              {
               bull++;
               show = true;
               clr  = InpBullColor;
               text = "Bull OB";
              }
            if(g_b[i].dir < 0 && bear < InpMaxActive)
              {
               bear++;
               show = true;
               clr  = InpBearColor;
               text = "Bear OB";
              }
            tip = "Active " + kind + " order block";
           }
         else
            if(InpShowUsed && used < InpMaxUsed)
              {
               used++;
               show = true;
               t2   = g_b[i].tEnd;
               tip  = (g_b[i].state == ST_USED ? "Used " : "Broken ") + kind + " order block";
              }
      if(!show)
         continue;
      string name = PREFIX + IntegerToString((long)g_b[i].t0) + (g_b[i].dir > 0 ? "_B" : "_S") + (g_b[i].breaker ? "K" : "");
      Box(name, g_b[i].t1, g_b[i].top, t2, g_b[i].bottom, clr,
          tip + " " + DoubleToString(g_b[i].bottom, _Digits) + " - " + DoubleToString(g_b[i].top, _Digits));
      ArrayResize(now, cnt + 2, 64);
      now[cnt++] = name;
      //--- names of active blocks at the right end, where no candles are yet
      if(InpLabels && text != "")
        {
         Label(name + "_T", t2, g_b[i].top, text);
         now[cnt++] = name + "_T";
        }
     }
   ArrayResize(now, cnt);
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
void Box(const string name, const datetime t1, const double p1, const datetime t2, const double p2, const color clr,
         const string tip)
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
   ObjectSetString(0, name, OBJPROP_TOOLTIP, tip);
  }

//+------------------------------------------------------------------+
//| Small text above the top right corner of a box                   |
//+------------------------------------------------------------------+
void Label(const string name, const datetime t, const double price, const string text)
  {
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_TEXT, 0, t, price);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 7);
      ObjectSetString(0, name, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
     }
   ObjectSetInteger(0, name, OBJPROP_TIME, 0, t);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 0, price);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, InpTextColor);
  }

//+------------------------------------------------------------------+
//| Popup, push and e-mail alerts                                    |
//+------------------------------------------------------------------+
void Notify(const string what)
  {
   string text = "Order Blocks " + _Symbol + " " + StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period), 7) + ": " + what;
   Alert(text);
   if(InpPush)
      SendNotification(text);
   if(InpEmail)
      SendMail("Order Blocks " + _Symbol, text);
  }
//+------------------------------------------------------------------+
