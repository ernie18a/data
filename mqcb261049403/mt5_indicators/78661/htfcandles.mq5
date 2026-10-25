//+------------------------------------------------------------------+
//|                                                   HTFCandles.mq5 |
//|   Higher timeframe candles (ICT Power of Three) next to the chart |
//|                                       Muhammad Muqeem Korejo      |
//+------------------------------------------------------------------+
//
// Draws the last candles of one or two higher timeframes to the right of
// the chart, at their real prices, so the higher timeframe candle can be
// watched while it forms (ICT Power of Three: accumulation near the open,
// manipulation away from it, distribution in the direction of the day).
// - Auto pairs: M1 -> M15 + H1, M2 - M5 -> H1 + H4, M6 - M30 -> H4 + D1,
//   H1 - H3 -> D1 + W1, H4 - H12 -> W1 + MN, D1 -> MN.
// - The candles are built from the chart's own candles, so no data of
//   another timeframe is needed: open of the first candle, close of the
//   last, highest high, lowest low. Server time: H1 - H12 from the start of
//   the hour, D1 from 00:00, W1 from Sunday, MN from the 1st.
// - Live candle: dashed lines from its open, high and low back to the
//   chart candle where they were made, the time left until it closes and
//   whether price is above or below its open.
// - Optional: the high and low of the previous candle on the chart.
// Buffers for Expert Advisors (first higher timeframe, iCustom, not drawn):
//   0 open, 1 high, 2 low of the higher timeframe candle so far (up to and
//   including this chart candle, no look-ahead), 3 / 4 / 5 high / low /
//   close of the previous higher timeframe candle. EMPTY_VALUE when there
//   is none.
// Read-only: the indicator never trades.
//
#property copyright   "Muhammad Muqeem Korejo"
#property link        "https://www.mql5.com/en/users/korejo123"
#property version     "1.00"
#property description "Higher timeframe candles next to your chart (ICT Power of Three): one or two timeframes,"
#property description "auto pairs (M15 -> H4 + D1 ...), live candle with lines to where its open, high and low were"
#property description "made, countdown, above / below open. Built from the chart's own candles. Alerts and buffers"
#property description "for EAs. Read-only: never trades."
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   6
#property indicator_type1   DRAW_NONE
#property indicator_label1  "HTF open"
#property indicator_type2   DRAW_NONE
#property indicator_label2  "HTF high so far"
#property indicator_type3   DRAW_NONE
#property indicator_label3  "HTF low so far"
#property indicator_type4   DRAW_NONE
#property indicator_label4  "Previous HTF high"
#property indicator_type5   DRAW_NONE
#property indicator_label5  "Previous HTF low"
#property indicator_type6   DRAW_NONE
#property indicator_label6  "Previous HTF close"

input ENUM_TIMEFRAMES InpTF1        = PERIOD_CURRENT;  // Higher timeframe 1 (current = auto)
input int             InpCount1     = 4;               // Finished candles of timeframe 1
input bool            InpUseTF2     = true;            // Show a second higher timeframe
input ENUM_TIMEFRAMES InpTF2        = PERIOD_CURRENT;  // Higher timeframe 2 (current = auto)
input int             InpCount2     = 3;               // Finished candles of timeframe 2
input int             InpCandlePx   = 14;              // Candle width (pixels, kept at every zoom)
input int             InpGapPx      = 6;               // Gap between candles (pixels)
input int             InpOffsetPx   = 24;              // Distance from the last chart candle (pixels)
input bool            InpOrigin     = true;            // Live candle: lines to its open / high / low
input bool            InpTimeLabels = true;            // Time under each candle
input bool            InpPrevHL     = false;           // Previous candle high / low on the chart (timeframe 1)
input bool            InpShift      = true;            // Turn chart shift on for room (restored on removal)
input int             InpBars       = 5000;            // Bars for the buffers
input color           InpBullColor  = C'38,166,154';   // Bullish candle colour
input color           InpBearColor  = C'239,83,80';    // Bearish candle colour
input color           InpWickColor  = clrDimGray;      // Wick colour
input color           InpLineColor  = clrDarkGray;     // Lines colour
input color           InpTextColor  = clrDimGray;      // Text colour
input bool            InpAlertNew   = false;           // Alert when a timeframe 1 candle opens
input bool            InpAlertOpen  = false;           // Alert when a candle closes across the timeframe 1 open
input bool            InpPush       = false;           // Alerts also as push notification
input bool            InpEmail      = false;           // Alerts also by e-mail

#define PREFIX    "HTFC_"
#define MAX_CNDL  12

struct HCandle
  {
   datetime          start;      // bucket start (server time)
   double            o;
   double            h;
   double            l;
   double            c;
   int               firstIdx;   // chart candles of the open, high and low
   int               hiIdx;
   int               loIdx;
  };

struct HSet
  {
   bool              on;
   ENUM_TIMEFRAMES   tf;
   int               count;      // finished candles to show
   int               n;          // candles found (finished + live)
   HCandle           c[MAX_CNDL];
  };

double   g_bOpen[], g_bHigh[], g_bLow[], g_bPrevH[], g_bPrevL[], g_bPrevC[];
HSet     g_set[2];
//--- buffers: the timeframe 1 candle of the closed chart candles
int      g_lastClosed = -1;
datetime g_closedTime = 0;
HCandle  g_cur, g_prev;
bool     g_hasCur = false, g_hasPrev = false;
bool     g_live = false;
datetime g_lastBar = 0;
uint     g_drawTick = 0;
bool     g_dirty = true;
string   g_drawn[];
//--- chart shift as it was before
bool     g_shiftSet = false;
long     g_oldShift = 0;
double   g_oldShiftSize = 0;
//--- alerts
datetime g_alertNew = 0;
int      g_openSide = 0;
//--- month cache for BucketStart
datetime g_mFrom = 0, g_mTo = 0;
bool     g_draw = true;               // false in a Strategy Tester run without visualization

//+------------------------------------------------------------------+
//| Inputs, timeframes and buffers                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpCount1 < 0 || InpCount1 > MAX_CNDL - 1 || InpCount2 < 0 || InpCount2 > MAX_CNDL - 1 || InpCandlePx < 4 ||
      InpCandlePx > 80 || InpGapPx < 0 || InpGapPx > 60 || InpOffsetPx < 4 || InpOffsetPx > 300 || InpBars < 100)
     {
      Print("HTF Candles: candles 0 - 11, width 4 - 80 px, gap 0 - 60 px, distance 4 - 300 px, bars 100 or more");
      return INIT_PARAMETERS_INCORRECT;
     }
   g_set[0].tf    = (InpTF1 == PERIOD_CURRENT ? AutoTF(1) : InpTF1);
   g_set[0].count = InpCount1;
   g_set[1].tf    = (InpTF2 == PERIOD_CURRENT ? AutoTF(2) : InpTF2);
   g_set[1].count = InpCount2;
   g_set[0].on    = Fits(g_set[0].tf);
   g_set[1].on    = InpUseTF2 && Fits(g_set[1].tf) && g_set[1].tf != g_set[0].tf;
   for(int s = 0; s < 2; s++)
      g_set[s].n = 0;
   g_draw = !(MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE));
   if(!g_set[0].on)
      PrintFormat("HTF Candles: %s is not a higher timeframe that fits %s (the chart must be D1 or lower and divide it)",
                  TFName(g_set[0].tf), TFName((ENUM_TIMEFRAMES)_Period));
   SetIndexBuffer(0, g_bOpen, INDICATOR_DATA);
   SetIndexBuffer(1, g_bHigh, INDICATOR_DATA);
   SetIndexBuffer(2, g_bLow, INDICATOR_DATA);
   SetIndexBuffer(3, g_bPrevH, INDICATOR_DATA);
   SetIndexBuffer(4, g_bPrevL, INDICATOR_DATA);
   SetIndexBuffer(5, g_bPrevC, INDICATOR_DATA);
   for(int b = 0; b < 6; b++)
      PlotIndexSetDouble(b, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   IndicatorSetString(INDICATOR_SHORTNAME, "HTF Candles");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Remove the drawings, give the chart shift back                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, PREFIX);
   if(g_shiftSet)
     {
      ChartSetInteger(0, CHART_SHIFT, g_oldShift);
      ChartSetDouble(0, CHART_SHIFT_SIZE, g_oldShiftSize);
     }
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Buffers from the closed candles; drawing of both sets             |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
  {
   if(rates_total < 3)
      return 0;
   bool full = (prev_calculated == 0 || g_lastClosed < 0 || g_lastClosed > rates_total - 2 || time[g_lastClosed] != g_closedTime);
   if(full)
     {
      ArrayInitialize(g_bOpen, EMPTY_VALUE);
      ArrayInitialize(g_bHigh, EMPTY_VALUE);
      ArrayInitialize(g_bLow, EMPTY_VALUE);
      ArrayInitialize(g_bPrevH, EMPTY_VALUE);
      ArrayInitialize(g_bPrevL, EMPTY_VALUE);
      ArrayInitialize(g_bPrevC, EMPTY_VALUE);
      g_hasCur  = false;
      g_hasPrev = false;
      g_live    = false;
      g_dirty   = true;
      //--- start where a timeframe 1 candle begins, so the first one is complete
      int first = MathMax(1, rates_total - InpBars);
      if(g_set[0].on)
         while(first < rates_total - 2 && BucketStart(time[first], g_set[0].tf) == BucketStart(time[first - 1], g_set[0].tf))
            first++;
      g_lastClosed = first - 1;
     }
   bool alerts = g_live;
   if(g_set[0].on)
     {
      for(int k = g_lastClosed + 1; k <= rates_total - 2; k++)
        {
         AddCandle(k, time[k], open[k], high[k], low[k], close[k]);
         SetBuffers(k, g_cur, g_hasPrev);
         //--- a close across the open of the timeframe 1 candle (once per direction and candle)
         if(alerts && k == rates_total - 2 && InpAlertOpen && k > 0 && g_cur.firstIdx < k)
           {
            int side = (close[k] > g_cur.o ? 1 : (close[k] < g_cur.o ? -1 : 0));
            int was  = (close[k - 1] > g_cur.o ? 1 : (close[k - 1] < g_cur.o ? -1 : 0));
            if(side != 0 && was != 0 && side != was && side != g_openSide)
              {
               g_openSide = side;
               Notify(StringFormat("candle closed %s the %s open %s", side > 0 ? "above" : "below", TFName(g_set[0].tf),
                                   DoubleToString(g_cur.o, _Digits)));
              }
           }
         g_lastClosed = k;
         g_closedTime = time[k];
        }
      //--- forming candle: the timeframe 1 candle with it, not stored
      int f = rates_total - 1;
      HCandle live = g_cur;
      bool    prev = g_hasPrev;
      HCandle pc   = g_prev;
      datetime bs  = BucketStart(time[f], g_set[0].tf);
      if(!g_hasCur || bs != g_cur.start)
        {
         if(g_hasCur)
           {
            pc   = g_cur;
            prev = true;
           }
         StartCandle(live, bs, f, open[f], high[f], low[f], close[f]);
         if(alerts && InpAlertNew && g_alertNew != bs && g_hasCur)
           {
            g_alertNew = bs;
            g_openSide = 0;
            Notify(StringFormat("new %s candle, open %s", TFName(g_set[0].tf), DoubleToString(open[f], _Digits)));
           }
        }
      else
         GrowCandle(live, f, high[f], low[f], close[f]);
      g_bOpen[f]  = live.o;
      g_bHigh[f]  = live.h;
      g_bLow[f]   = live.l;
      g_bPrevH[f] = (prev ? pc.h : EMPTY_VALUE);
      g_bPrevL[f] = (prev ? pc.l : EMPTY_VALUE);
      g_bPrevC[f] = (prev ? pc.c : EMPTY_VALUE);
     }
   else
     {
      //--- no fitting timeframe: the buffers stay empty
      for(int k = MathMax(0, g_lastClosed + 1); k < rates_total; k++)
        {
         g_bOpen[k]  = EMPTY_VALUE;
         g_bHigh[k]  = EMPTY_VALUE;
         g_bLow[k]   = EMPTY_VALUE;
         g_bPrevH[k] = EMPTY_VALUE;
         g_bPrevL[k] = EMPTY_VALUE;
         g_bPrevC[k] = EMPTY_VALUE;
        }
      g_lastClosed = rates_total - 2;
      g_closedTime = time[g_lastClosed];
     }
   //--- drawing: everything on a new chart candle, the live candles at most 4 times a second;
   //--- nothing to draw in a test without visualization (the buffers are still calculated)
   int  f      = rates_total - 1;
   bool newBar = (time[f] != g_lastBar);
   uint now    = GetTickCount();
   if(g_draw && (newBar || g_dirty || now - g_drawTick >= 250))
     {
      if(newBar)
         g_lastBar = time[f];
      ChartShift();
      for(int s = 0; s < 2; s++)
         if(g_set[s].on)
            Collect(g_set[s], time, open, high, low, close, rates_total);
      Draw(time, f);
      g_drawTick = now;
      g_dirty    = false;
     }
   g_live = true;
   return rates_total;
  }

//+------------------------------------------------------------------+
//| Buffers: the timeframe 1 candle of the closed chart candles       |
//+------------------------------------------------------------------+
void AddCandle(const int k, const datetime t, const double o, const double h, const double l, const double c)
  {
   datetime bs = BucketStart(t, g_set[0].tf);
   if(!g_hasCur || bs != g_cur.start)
     {
      if(g_hasCur)
        {
         g_prev    = g_cur;
         g_hasPrev = true;
        }
      StartCandle(g_cur, bs, k, o, h, l, c);
      g_hasCur   = true;
      g_openSide = 0;
      return;
     }
   GrowCandle(g_cur, k, h, l, c);
  }

void StartCandle(HCandle &x, const datetime bs, const int k, const double o, const double h, const double l, const double c)
  {
   x.start    = bs;
   x.o        = o;
   x.h        = h;
   x.l        = l;
   x.c        = c;
   x.firstIdx = k;
   x.hiIdx    = k;
   x.loIdx    = k;
  }

void GrowCandle(HCandle &x, const int k, const double h, const double l, const double c)
  {
   if(h > x.h)
     {
      x.h     = h;
      x.hiIdx = k;
     }
   if(l < x.l)
     {
      x.l     = l;
      x.loIdx = k;
     }
   x.c = c;
  }

void SetBuffers(const int k, const HCandle &x, const bool prev)
  {
   g_bOpen[k]  = x.o;
   g_bHigh[k]  = x.h;
   g_bLow[k]   = x.l;
   g_bPrevH[k] = (prev ? g_prev.h : EMPTY_VALUE);
   g_bPrevL[k] = (prev ? g_prev.l : EMPTY_VALUE);
   g_bPrevC[k] = (prev ? g_prev.c : EMPTY_VALUE);
  }

//+------------------------------------------------------------------+
//| The last finished candles + the live one of one set, built back- |
//| wards from the last chart candle (oldest first in s.c[])         |
//+------------------------------------------------------------------+
void Collect(HSet &s, const datetime &time[], const double &open[], const double &high[], const double &low[],
             const double &close[], const int rates_total)
  {
   int      want = s.count + 1;
   HCandle  tmp[MAX_CNDL];
   int      n = 0;
   datetime bs = 0;
   bool     complete = false;
   for(int k = rates_total - 1; k >= 0; k--)
     {
      datetime b = BucketStart(time[k], s.tf);
      if(n == 0 || b != bs)
        {
         if(n == want)
           {
            complete = true;           // the oldest candle we keep has its first chart candle
            break;
           }
         bs = b;
         StartCandle(tmp[n], b, k, open[k], high[k], low[k], close[k]);
         n++;
         continue;
        }
      //--- going backwards: this chart candle is older, so it gives the open
      HCandle x = tmp[n - 1];
      if(high[k] >= x.h)
        {
         x.h     = high[k];
         x.hiIdx = k;
        }
      if(low[k] <= x.l)
        {
         x.l     = low[k];
         x.loIdx = k;
        }
      x.o        = open[k];
      x.firstIdx = k;
      tmp[n - 1] = x;
     }
   //--- without older history the oldest candle may be cut: drop it
   if(!complete && n > 1)
      n--;
   //--- oldest first; the close of each is the close of its last chart candle
   s.n = n;
   for(int i = 0; i < n; i++)
      s.c[i] = tmp[n - 1 - i];
   for(int i = 0; i < n; i++)
     {
      datetime nextStart = (i + 1 < n ? s.c[i + 1].start : 0);
      int      lastIdx   = rates_total - 1;
      if(nextStart != 0)
         lastIdx = s.c[i + 1].firstIdx - 1;
      if(lastIdx >= 0 && lastIdx < rates_total)
         s.c[i].c = close[lastIdx];
     }
  }

//+------------------------------------------------------------------+
//| Candles, labels and lines                                        |
//+------------------------------------------------------------------+
void Draw(const datetime &time[], const int f)
  {
   string keep[];
   int    cnt = 0;
   long   ps  = PeriodSeconds();
   int    px, wB, gB, oB;
   Geometry(px, wB, gB, oB);
   int    pitch = wB + gB;
   int    base  = oB;
   //--- visible price range: titles and time labels stay inside it
   double vMax = ChartGetDouble(0, CHART_PRICE_MAX, 0);
   double vMin = ChartGetDouble(0, CHART_PRICE_MIN, 0);
   double pad  = (vMax > vMin ? (vMax - vMin) * 0.04 : 0);
   for(int s = 0; s < 2; s++)
     {
      if(!g_set[s].on || g_set[s].n == 0)
         continue;
      HSet   st   = g_set[s];
      string tf   = TFName(st.tf);
      double top  = st.c[0].h, bot = st.c[0].l;
      for(int i = 1; i < st.n; i++)
        {
         top = MathMax(top, st.c[i].h);
         bot = MathMin(bot, st.c[i].l);
        }
      //--- time labels only as often as they fit (the live candle always has one)
      int width = (int)(StringLen(StartText(st.c[0].start, st.tf)) * 5.5) + 6;
      int step  = MathMax(1, (width + pitch * px - 1) / (pitch * px));
      bool   lowIn = (pad == 0 || bot - pad > vMin);
      double lblY  = (lowIn ? bot : vMin);
      for(int i = 0; i < st.n; i++)
        {
         HCandle  x    = st.c[i];
         int      left = base + i * pitch;
         datetime tL   = time[f] + (datetime)(left * ps);
         datetime tR   = time[f] + (datetime)((left + wB) * ps);
         datetime tM   = time[f] + (datetime)((left + wB / 2) * ps);
         string   id   = IntegerToString(s) + "_" + IntegerToString(i);
         bool     bull = (x.c >= x.o);
         double   bTop = MathMax(x.o, x.c), bBot = MathMin(x.o, x.c);
         string   tip  = StringFormat("%s %s  O %s  H %s  L %s  C %s", tf, StartText(x.start, st.tf), DoubleToString(x.o, _Digits),
                                      DoubleToString(x.h, _Digits), DoubleToString(x.l, _Digits), DoubleToString(x.c, _Digits));
         //--- the wick in two parts, above and below the body, so it never crosses the body
         if(x.h > bTop)
            Line("WU" + id, tM, x.h, tM, bTop, InpWickColor, STYLE_SOLID, 1, tip, keep, cnt);
         if(x.l < bBot)
            Line("WD" + id, tM, bBot, tM, x.l, InpWickColor, STYLE_SOLID, 1, tip, keep, cnt);
         Box("B" + id, tL, bTop, tR, bBot, bull ? InpBullColor : InpBearColor, tip, keep, cnt);
         if(InpTimeLabels && (st.n - 1 - i) % step == 0)
            Text("T" + id, tM, lblY, StartText(x.start, st.tf), lowIn ? ANCHOR_UPPER : ANCHOR_LOWER, keep, cnt);
        }
      //--- title of the set: timeframe, time left of the live candle, above / below its open
      HCandle lv   = st.c[st.n - 1];
      double  last = lv.c;
      string  pos  = (last > lv.o ? "above open" : (last < lv.o ? "below open" : "at open"));
      bool    topIn = (pad == 0 || top + pad < vMax);
      Text("H" + IntegerToString(s), time[f] + (datetime)(base * ps), topIn ? top : vMax,
           tf + "  " + LeftText(lv.start, st.tf, time[f]) + "  " + pos, topIn ? ANCHOR_LEFT_LOWER : ANCHOR_LEFT_UPPER, keep, cnt);
      //--- live candle of timeframe 1: lines back to where its open, high and low were made
      if(s == 0 && InpOrigin && lv.firstIdx >= 0 && lv.firstIdx <= f)
        {
         int      left = base + (st.n - 1) * pitch;
         datetime tL   = time[f] + (datetime)(left * ps);
         datetime tM   = time[f] + (datetime)((left + wB / 2) * ps);
         Line("OO", time[lv.firstIdx], lv.o, tL, lv.o, InpLineColor, STYLE_DASH, 1, tf + " open " + DoubleToString(lv.o, _Digits), keep, cnt);
         if(lv.hiIdx >= 0 && lv.hiIdx <= f)
            Line("OH", time[lv.hiIdx], lv.h, tM, lv.h, InpLineColor, STYLE_DOT, 1, tf + " high " + DoubleToString(lv.h, _Digits), keep, cnt);
         if(lv.loIdx >= 0 && lv.loIdx <= f)
            Line("OL", time[lv.loIdx], lv.l, tM, lv.l, InpLineColor, STYLE_DOT, 1, tf + " low " + DoubleToString(lv.l, _Digits), keep, cnt);
        }
      //--- previous candle of timeframe 1: its high and low on the chart
      if(s == 0 && InpPrevHL && st.n >= 2)
        {
         HCandle  pv   = st.c[st.n - 2];
         int      pi   = MathMax(0, MathMin(pv.firstIdx, f));
         datetime tEnd = time[f] + (datetime)((base - 1) * ps);
         Line("PH", time[pi], pv.h, tEnd, pv.h, InpLineColor, STYLE_DASHDOT, 1, "Previous " + tf + " high " + DoubleToString(pv.h, _Digits), keep, cnt);
         Line("PL", time[pi], pv.l, tEnd, pv.l, InpLineColor, STYLE_DASHDOT, 1, "Previous " + tf + " low " + DoubleToString(pv.l, _Digits), keep, cnt);
        }
      base += st.n * pitch + 2 * gB + 2;
     }
   //--- remove what is no longer drawn
   for(int i = 0; i < ArraySize(g_drawn); i++)
     {
      bool still = false;
      for(int j = 0; j < cnt && !still; j++)
         still = (keep[j] == g_drawn[i]);
      if(!still)
         ObjectDelete(0, g_drawn[i]);
     }
   ArrayResize(g_drawn, cnt);
   for(int j = 0; j < cnt; j++)
      g_drawn[j] = keep[j];
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Chart shift on and wide enough for the candles. Checked at every |
//| drawing, because zoom and window size change the room; it only   |
//| grows, and the old values come back when the indicator is removed|
//+------------------------------------------------------------------+
void ChartShift()
  {
   if(!InpShift)
      return;
   long bars = ChartGetInteger(0, CHART_WIDTH_IN_BARS);
   if(bars <= 0)
      return;
   int px, wB, gB, oB;
   Geometry(px, wB, gB, oB);
   int need = oB + 4;
   for(int s = 0; s < 2; s++)
      if(g_set[s].on)
         need += (g_set[s].count + 1) * (wB + gB) + 2 * gB + 2;
   double pct = MathMin(50.0, MathMax(10.0, 100.0 * need / (double)bars));
   if(!g_shiftSet)
     {
      g_oldShift     = ChartGetInteger(0, CHART_SHIFT);
      g_oldShiftSize = ChartGetDouble(0, CHART_SHIFT_SIZE);
      g_shiftSet     = true;
     }
   if(ChartGetInteger(0, CHART_SHIFT) == 0)
      ChartSetInteger(0, CHART_SHIFT, true);
   if(ChartGetDouble(0, CHART_SHIFT_SIZE) < pct - 0.5)
      ChartSetDouble(0, CHART_SHIFT_SIZE, pct);
  }

//+------------------------------------------------------------------+
//| Pixels per chart bar at the current zoom, and the candle width,  |
//| gap and distance in bars (the width is even, so the wick sits on |
//| a bar in the middle)                                             |
//+------------------------------------------------------------------+
void Geometry(int &px, int &wBars, int &gBars, int &oBars)
  {
   int scale = (int)ChartGetInteger(0, CHART_SCALE);
   if(scale < 0)
      scale = 0;
   if(scale > 5)
      scale = 5;
   px    = 1 << scale;
   wBars = (int)MathRound(InpCandlePx / (2.0 * px)) * 2;
   if(wBars < 2)
      wBars = 2;
   gBars = (int)MathRound(InpGapPx / (double)px);
   if(gBars < 1)
      gBars = 1;
   oBars = (int)MathRound(InpOffsetPx / (double)px);
   if(oBars < 2)
      oBars = 2;
  }

//+------------------------------------------------------------------+
//| Zoom or window size changed: draw again on the next tick         |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_CHART_CHANGE)
      g_dirty = true;
  }

//+------------------------------------------------------------------+
//| Timeframe helpers                                                |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES AutoTF(const int which)
  {
   int s = PeriodSeconds();
   if(s <= 60)
      return (which == 1 ? PERIOD_M15 : PERIOD_H1);
   if(s <= 300)
      return (which == 1 ? PERIOD_H1 : PERIOD_H4);
   if(s <= 1800)
      return (which == 1 ? PERIOD_H4 : PERIOD_D1);
   if(s <= 10800)
      return (which == 1 ? PERIOD_D1 : PERIOD_W1);
   if(s <= 43200)
      return (which == 1 ? PERIOD_W1 : PERIOD_MN1);
   if(s <= 86400)
      return (which == 1 ? PERIOD_MN1 : PERIOD_CURRENT);
   return PERIOD_CURRENT;
  }

//--- the chart (D1 or lower) must divide the higher timeframe
bool Fits(const ENUM_TIMEFRAMES tf)
  {
   if(tf == PERIOD_CURRENT)
      return false;
   long cs = PeriodSeconds();
   if(cs > 86400)
      return false;
   if(tf == PERIOD_W1 || tf == PERIOD_MN1)
      return (86400 % cs == 0);
   long hs = PeriodSeconds(tf);
   return (hs > cs && hs % cs == 0 && 86400 % hs == 0);
  }

datetime BucketStart(const datetime t, const ENUM_TIMEFRAMES tf)
  {
   if(tf == PERIOD_MN1)
     {
      if(t >= g_mFrom && t < g_mTo)
         return g_mFrom;
      MqlDateTime d;
      TimeToStruct(t, d);
      d.day  = 1;
      d.hour = 0;
      d.min  = 0;
      d.sec  = 0;
      g_mFrom = StructToTime(d);
      if(d.mon == 12)
        {
         d.mon = 1;
         d.year++;
        }
      else
         d.mon++;
      g_mTo = StructToTime(d);
      return g_mFrom;
     }
   long day = (long)t - (long)t % 86400;
   if(tf == PERIOD_W1)
     {
      int dow = (int)((day / 86400 + 4) % 7);   // 1 January 1970 was a Thursday; 0 = Sunday
      return (datetime)(day - (long)dow * 86400);
     }
   long sec = PeriodSeconds(tf);
   return (datetime)((long)t - (long)t % sec);
  }

string TFName(const ENUM_TIMEFRAMES tf)
  {
   if(tf == PERIOD_CURRENT)
      return "none";
   return StringSubstr(EnumToString(tf), 7);
  }

//--- short time of a candle: 08:00, Mon 20, 19 Oct, Oct 2026
string StartText(const datetime t, const ENUM_TIMEFRAMES tf)
  {
   MqlDateTime d;
   TimeToStruct(t, d);
   string mon[12] = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
   string dow[7]  = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
   if(tf == PERIOD_MN1)
      return mon[d.mon - 1];
   if(tf == PERIOD_W1)
      return IntegerToString(d.day) + " " + mon[d.mon - 1];
   if(tf == PERIOD_D1)
      return dow[d.day_of_week];
   return StringFormat("%02d:%02d", d.hour, d.min);
  }

//--- time left until the live candle closes: 1:23:45, 2d 03h
string LeftText(const datetime start, const ENUM_TIMEFRAMES tf, const datetime lastBar)
  {
   datetime end;
   if(tf == PERIOD_MN1)
     {
      BucketStart(start, tf);
      end = g_mTo;
     }
   else
      end = start + (tf == PERIOD_W1 ? 7 * 86400 : PeriodSeconds(tf));
   datetime now = TimeCurrent();
   if(now < lastBar)
      now = lastBar;
   long left = (long)end - (long)now;
   if(left <= 0)
      return "closing";
   if(left >= 86400)
      return StringFormat("%dd %02dh left", (int)(left / 86400), (int)(left % 86400 / 3600));
   return StringFormat("%d:%02d:%02d left", (int)(left / 3600), (int)(left % 3600 / 60), (int)(left % 60));
  }

//+------------------------------------------------------------------+
//| Chart objects                                                    |
//+------------------------------------------------------------------+
void Keep(string &list[], int &cnt, const string name)
  {
   if(cnt >= ArraySize(list))
      ArrayResize(list, cnt + 32);
   list[cnt++] = name;
  }

void Box(const string id, const datetime t1, const double p1, const datetime t2, const double p2, const color clr,
         const string tip, string &keep[], int &cnt)
  {
   string name = PREFIX + id;
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, p1, t2, p2);
      ObjectSetInteger(0, name, OBJPROP_FILL, true);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
     }
   ObjectSetInteger(0, name, OBJPROP_TIME, 0, t1);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 0, p1);
   ObjectSetInteger(0, name, OBJPROP_TIME, 1, t2);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 1, p2);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetString(0, name, OBJPROP_TOOLTIP, tip);
   Keep(keep, cnt, name);
  }

void Line(const string id, const datetime t1, const double p1, const datetime t2, const double p2, const color clr,
          const ENUM_LINE_STYLE style, const int width, const string tip, string &keep[], int &cnt)
  {
   string name = PREFIX + id;
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_TREND, 0, t1, p1, t2, p2);
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
     }
   ObjectSetInteger(0, name, OBJPROP_TIME, 0, t1);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 0, p1);
   ObjectSetInteger(0, name, OBJPROP_TIME, 1, t2);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 1, p2);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetString(0, name, OBJPROP_TOOLTIP, tip);
   Keep(keep, cnt, name);
  }

void Text(const string id, const datetime t, const double price, const string text, const ENUM_ANCHOR_POINT anchor,
          string &keep[], int &cnt)
  {
   string name = PREFIX + id;
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_TEXT, 0, t, price);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 7);
      ObjectSetString(0, name, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
     }
   ObjectSetInteger(0, name, OBJPROP_TIME, 0, t);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 0, price);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, anchor);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, InpTextColor);
   Keep(keep, cnt, name);
  }

//+------------------------------------------------------------------+
//| Popup, push and e-mail alerts                                    |
//+------------------------------------------------------------------+
void Notify(const string what)
  {
   string text = "HTF Candles " + _Symbol + " " + StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period), 7) + ": " + what;
   Alert(text);
   if(InpPush)
      SendNotification(text);
   if(InpEmail)
      SendMail("HTF Candles " + _Symbol, text);
  }
//+------------------------------------------------------------------+
