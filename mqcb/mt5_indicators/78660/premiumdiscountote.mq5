//+------------------------------------------------------------------+
//|                                           PremiumDiscountOTE.mq5 |
//|   ICT dealing range: premium / discount, OTE, standard deviations |
//|   and the IPDA 20 / 40 / 60-day ranges                            |
//|                                       Muhammad Muqeem Korejo      |
//+------------------------------------------------------------------+
//
// Dealing range: from the older of the last confirmed swing high and
// swing low up to now. Its top is the highest high and its bottom the
// lowest low since that swing, so the range grows when price makes a
// new extreme, and a newly confirmed swing starts a new range.
// A swing high is a high above the highs of N candles on each side
// (N = swing strength); it is confirmed when its N right candles have
// closed. A swing low is the mirror.
// Leg: up when the bottom came before the top, down when the top came
// first.
// Levels (R = top - bottom):
//   Equilibrium (EQ) = 50 %: above it is premium, below it is discount.
//   OTE (optimal trade entry) = the 62 % - 79 % retracement of the leg,
//     with the 70.5 % line. It lies in discount for an up leg and in
//     premium for a down leg.
//   Standard deviations (ICT projections): the range height projected
//     beyond the end of the leg, -1, -2, -2.5 and -4 by default.
// IPDA data ranges: highest high and lowest low of the last 20, 40 and
// 60 completed trading days. A short day that starts after 18:00 (the
// Sunday evening open of GMT+0 servers) counts with the next day.
// Buffers for Expert Advisors (iCustom, not drawn). A closed candle keeps
// the values it had at its close, so nothing repaints:
//   0 range top, 1 range bottom, 2 equilibrium, 3 OTE 62 %, 4 OTE 79 %,
//   5 leg (+1 up, -1 down), 6 zone of the close (+1 premium, -1 discount,
//   0 at equilibrium, +2 / -2 inside the OTE band), 7 / 8 IPDA 20-day high / low,
//   9 / 10 IPDA 40-day high / low, 11 / 12 IPDA 60-day high / low.
//   EMPTY_VALUE when there is no value.
// Read-only: the indicator never trades.
//
#property copyright   "Muhammad Muqeem Korejo"
#property link        "https://www.mql5.com/en/users/korejo123"
#property version     "1.00"
#property description "ICT dealing range: premium and discount zones, equilibrium, the OTE band (62 - 79 %, 70.5 %),"
#property description "standard deviation projections and the IPDA 20 / 40 / 60-day ranges."
#property description "Confirmed swings only (no repaint). Alerts and buffers for EAs. Read-only: never trades."
#property indicator_chart_window
#property indicator_buffers 13
#property indicator_plots   13
#property indicator_type1   DRAW_NONE
#property indicator_label1  "Range top"
#property indicator_type2   DRAW_NONE
#property indicator_label2  "Range bottom"
#property indicator_type3   DRAW_NONE
#property indicator_label3  "Equilibrium"
#property indicator_type4   DRAW_NONE
#property indicator_label4  "OTE 62%"
#property indicator_type5   DRAW_NONE
#property indicator_label5  "OTE 79%"
#property indicator_type6   DRAW_NONE
#property indicator_label6  "Leg (+1 up, -1 down)"
#property indicator_type7   DRAW_NONE
#property indicator_label7  "Zone (+1 premium, -1 discount, 2 OTE)"
#property indicator_type8   DRAW_NONE
#property indicator_label8  "IPDA 20 high"
#property indicator_type9   DRAW_NONE
#property indicator_label9  "IPDA 20 low"
#property indicator_type10  DRAW_NONE
#property indicator_label10 "IPDA 40 high"
#property indicator_type11  DRAW_NONE
#property indicator_label11 "IPDA 40 low"
#property indicator_type12  DRAW_NONE
#property indicator_label12 "IPDA 60 high"
#property indicator_type13  DRAW_NONE
#property indicator_label13 "IPDA 60 low"

input int    InpSwing         = 10;              // Swing strength (candles on each side)
input bool   InpOTE           = true;            // OTE band (62 - 79 %) and the 70.5 % line
input bool   InpFibs          = false;           // More retracements (23.6, 38.2, 61.8, 78.6 %)
input bool   InpDeviations    = true;            // Standard deviation projections
input string InpDevLevels     = "-1,-2,-2.5,-4"; // Deviations (in range heights)
input bool   InpIPDA20        = true;            // IPDA 20-day range
input bool   InpIPDA40        = true;            // IPDA 40-day range
input bool   InpIPDA60        = true;            // IPDA 60-day range
input int    InpBars          = 3000;            // Bars to scan
input bool   InpLabels        = true;            // Names and prices at the right edge
input bool   InpStatus        = true;            // Status line in the chart corner
input color  InpPremiumColor  = C'252,222,222';  // Premium colour
input color  InpDiscountColor = C'214,240,221';  // Discount colour
input color  InpOTEColor      = C'255,236,186';  // OTE colour
input color  InpLineColor     = clrDimGray;      // Equilibrium and 70.5 % colour
input color  InpDevColor      = C'105,105,190';  // Deviation colour
input color  InpIPDAColor     = C'120,140,170';  // IPDA colour
input color  InpTextColor     = clrDimGray;      // Text colour
input bool   InpAlertRange    = false;           // Alert on a new dealing range
input bool   InpAlertOTE      = false;           // Alert when price comes into the OTE band
input bool   InpAlertEQ       = false;           // Alert when a candle closes across equilibrium
input bool   InpPush          = false;           // Alerts also as push notification
input bool   InpEmail         = false;           // Alerts also by e-mail

#define PREFIX    "PDOTE_"
#define MAX_DEVS  8
#define DAYS_KEPT 70

//--- levels of one state of the range
struct Levels
  {
   bool              ok;
   double            top;
   double            bottom;
   int               topIdx;
   int               botIdx;
   int               leg;        // +1 up, -1 down
   double            eq;
   double            o62;
   double            o705;
   double            o79;
  };

double   g_bTop[], g_bBot[], g_bEq[], g_b62[], g_b79[], g_bLeg[], g_bZone[];
double   g_b20h[], g_b20l[], g_b40h[], g_b40l[], g_b60h[], g_b60l[];
double   g_dev[MAX_DEVS];
int      g_devN       = 0;
int      g_lastClosed = -1;
datetime g_closedTime = 0;
bool     g_live       = false;
bool     g_dirty      = true;
datetime g_lastBar    = 0;
uint     g_drawTick   = 0;
string   g_drawn[];
//--- swings and the dealing range of the closed candles
int      g_shIdx = -1, g_slIdx = -1;
int      g_anchor = -1;
double   g_rTop = 0, g_rBot = 0;
int      g_topIdx = -1, g_botIdx = -1;
bool     g_oteTouched = false;
int      g_side = 0;
//--- IPDA: completed trading days (oldest first) and the day being built
double   g_dHi[], g_dLo[];
datetime g_dStart[];
int      g_dn = 0;
datetime g_curDay = 0, g_curStart = 0;
double   g_curHi = 0, g_curLo = 0;
bool     g_curEvening = false;
int      g_dayIdx = -1;                    // last candle added to the days
double   g_ipH[3], g_ipL[3];
datetime g_ipT[3];
int      g_ipDays[3] = {20, 40, 60};
//--- what was drawn last
Levels   g_shown;
int      g_shownAnchor = -2;
string   g_status = "";
bool     g_draw = true;                   // false in a Strategy Tester run without visualization

//+------------------------------------------------------------------+
//| Inputs and buffers                                               |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpSwing < 1 || InpSwing > 50 || InpBars < 100)
     {
      Print("Premium Discount OTE: swing strength 1 - 50, bars 100 or more");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(!ParseDeviations(InpDevLevels))
     {
      Print("Premium Discount OTE: deviations must be numbers separated by commas, for example -1,-2,-2.5,-4");
      return INIT_PARAMETERS_INCORRECT;
     }
   SetIndexBuffer(0, g_bTop, INDICATOR_DATA);
   SetIndexBuffer(1, g_bBot, INDICATOR_DATA);
   SetIndexBuffer(2, g_bEq, INDICATOR_DATA);
   SetIndexBuffer(3, g_b62, INDICATOR_DATA);
   SetIndexBuffer(4, g_b79, INDICATOR_DATA);
   SetIndexBuffer(5, g_bLeg, INDICATOR_DATA);
   SetIndexBuffer(6, g_bZone, INDICATOR_DATA);
   SetIndexBuffer(7, g_b20h, INDICATOR_DATA);
   SetIndexBuffer(8, g_b20l, INDICATOR_DATA);
   SetIndexBuffer(9, g_b40h, INDICATOR_DATA);
   SetIndexBuffer(10, g_b40l, INDICATOR_DATA);
   SetIndexBuffer(11, g_b60h, INDICATOR_DATA);
   SetIndexBuffer(12, g_b60l, INDICATOR_DATA);
   for(int b = 0; b < 13; b++)
      PlotIndexSetDouble(b, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   IndicatorSetString(INDICATOR_SHORTNAME, "Premium Discount OTE");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   g_shown.ok = false;
   //--- a test without visualization shows no chart: only the buffers are calculated there
   g_draw = !(MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE));
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
//| Zoom or window size changed: draw again on the next tick         |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_CHART_CHANGE)
      g_dirty = true;
  }

//+------------------------------------------------------------------+
//| Closed candles: days, swings, range, buffers; forming candle:    |
//| the live range (its high can only grow, its low only fall)       |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
  {
   int need = 2 * InpSwing + 3;
   if(rates_total < need + 2)
      return 0;
   bool full = (prev_calculated == 0 || g_lastClosed < 0 || g_lastClosed > rates_total - 2 || time[g_lastClosed] != g_closedTime);
   int  first = MathMax(need, rates_total - InpBars);
   if(full)
     {
      ArrayInitialize(g_bTop, EMPTY_VALUE);
      ArrayInitialize(g_bBot, EMPTY_VALUE);
      ArrayInitialize(g_bEq, EMPTY_VALUE);
      ArrayInitialize(g_b62, EMPTY_VALUE);
      ArrayInitialize(g_b79, EMPTY_VALUE);
      ArrayInitialize(g_bLeg, EMPTY_VALUE);
      ArrayInitialize(g_bZone, EMPTY_VALUE);
      ArrayInitialize(g_b20h, EMPTY_VALUE);
      ArrayInitialize(g_b20l, EMPTY_VALUE);
      ArrayInitialize(g_b40h, EMPTY_VALUE);
      ArrayInitialize(g_b40l, EMPTY_VALUE);
      ArrayInitialize(g_b60h, EMPTY_VALUE);
      ArrayInitialize(g_b60l, EMPTY_VALUE);
      g_shIdx      = -1;
      g_slIdx      = -1;
      g_anchor     = -1;
      g_oteTouched = false;
      g_side       = 0;
      g_dn         = 0;
      g_curDay     = 0;
      for(int w = 0; w < 3; w++)
        {
         g_ipH[w] = EMPTY_VALUE;
         g_ipL[w] = EMPTY_VALUE;
         g_ipT[w] = 0;
        }
      //--- the IPDA days need about 65 trading days before the first calculated candle
      int dayBars = (PeriodSeconds() <= 86400 ? 86400 / PeriodSeconds() : 0);
      g_dayIdx     = (dayBars > 0 ? MathMax(0, first - 66 * dayBars) : rates_total) - 1;
      g_lastClosed = first - 1;
      g_live       = false;
      g_dirty      = true;
     }
   //--- trading days of the closed candles before the scanned window
   while(g_dayIdx < first - 1 && g_dayIdx < rates_total - 2)
     {
      g_dayIdx++;
      AddDayCandle(time[g_dayIdx], high[g_dayIdx], low[g_dayIdx]);
     }
   bool alerts = g_live;
   for(int k = g_lastClosed + 1; k <= rates_total - 2; k++)
     {
      bool last = (k == rates_total - 2);
      if(g_dayIdx < k)
        {
         g_dayIdx = k;
         AddDayCandle(time[k], high[k], low[k]);
        }
      Levels before;
      MakeLevels(before);
      //--- the range grows with this candle, then a confirmed swing may start a new one
      if(g_anchor >= 0)
        {
         if(high[k] > g_rTop)
           {
            g_rTop   = high[k];
            g_topIdx = k;
           }
         if(low[k] < g_rBot)
           {
            g_rBot   = low[k];
            g_botIdx = k;
           }
        }
      bool fresh = ConfirmSwing(k, high, low);
      Levels now;
      MakeLevels(now);
      if(fresh)
        {
         g_oteTouched = false;
         g_side       = 0;
         if(alerts && last && InpAlertRange && now.ok)
            Notify(StringFormat("new %s dealing range %s - %s", now.leg > 0 ? "bullish (up leg)" : "bearish (down leg)",
                                DoubleToString(now.bottom, _Digits), DoubleToString(now.top, _Digits)));
        }
      else
         if(before.ok)
           {
            //--- the OTE band of the range before this candle: first touch of the range
            if(!g_oteTouched && low[k] <= MathMax(before.o62, before.o79) && high[k] >= MathMin(before.o62, before.o79) &&
               ((before.leg > 0 && high[k] <= before.top) || (before.leg < 0 && low[k] >= before.bottom)))
              {
               g_oteTouched = true;
               if(alerts && last && InpAlertOTE)
                  Notify(StringFormat("price is in the OTE band %s - %s", DoubleToString(MathMin(before.o62, before.o79), _Digits),
                                      DoubleToString(MathMax(before.o62, before.o79), _Digits)));
              }
           }
      if(now.ok)
        {
         int side = Zone(now, close[k]);
         side = (side > 0 ? 1 : (side < 0 ? -1 : 0));
         if(side != 0 && g_side != 0 && side != g_side && alerts && last && InpAlertEQ)
            Notify(StringFormat("candle closed %s equilibrium %s", side > 0 ? "above" : "below", DoubleToString(now.eq, _Digits)));
         if(side != 0)
            g_side = side;
        }
      SetBuffers(k, now, close[k]);
      g_lastClosed = k;
      g_closedTime = time[k];
     }
   //--- forming candle: the live range, not stored
   Levels live;
   MakeLevels(live);
   int f = rates_total - 1;
   if(live.ok)
     {
      if(high[f] > live.top)
        {
         live.top    = high[f];
         live.topIdx = f;
        }
      if(low[f] < live.bottom)
        {
         live.bottom = low[f];
         live.botIdx = f;
        }
      FillLevels(live);
     }
   SetBuffers(f, live, close[f]);
   //--- drawing: on a new candle at once, when the live range moved at most 4 times a second
   bool newBar = (time[f] != g_lastBar);
   if(newBar)
     {
      g_lastBar = time[f];
      g_dirty   = true;
     }
   if(!Same(live, g_shown) || g_anchor != g_shownAnchor)
      g_dirty = true;
   string status = StatusText(live, close[f]);
   if(status != g_status)
      g_dirty = true;
   uint now = GetTickCount();
   if(g_draw && g_dirty && (newBar || now - g_drawTick >= 250))
     {
      Draw(live, time, f, status);
      g_shown       = live;
      g_shownAnchor = g_anchor;
      g_status      = status;
      g_dirty       = false;
      g_drawTick    = now;
     }
   g_live = true;
   return rates_total;
  }

//+------------------------------------------------------------------+
//| Candle k closed: is candle k - N a swing? A new swing can start   |
//| a new dealing range (returns true then)                          |
//+------------------------------------------------------------------+
bool ConfirmSwing(const int k, const double &high[], const double &low[])
  {
   int p = k - InpSwing;
   if(p - InpSwing < 0)
      return false;
   bool isHigh = true, isLow = true;
   for(int j = 1; j <= InpSwing && (isHigh || isLow); j++)
     {
      //--- strictly beyond the left side, not beyond by the right side (a flat top counts once)
      if(high[p] <= high[p - j] || high[p] < high[p + j])
         isHigh = false;
      if(low[p] >= low[p - j] || low[p] > low[p + j])
         isLow = false;
     }
   if(isHigh)
      g_shIdx = p;
   if(isLow)
      g_slIdx = p;
   if(!(isHigh || isLow) || g_shIdx < 0 || g_slIdx < 0)
      return false;
   int a = MathMin(g_shIdx, g_slIdx);
   if(a == g_anchor)
      return false;
   //--- new dealing range: highest high and lowest low from the older swing to this candle
   g_anchor = a;
   g_rTop   = high[a];
   g_rBot   = low[a];
   g_topIdx = a;
   g_botIdx = a;
   for(int i = a + 1; i <= k; i++)
     {
      if(high[i] > g_rTop)
        {
         g_rTop   = high[i];
         g_topIdx = i;
        }
      if(low[i] < g_rBot)
        {
         g_rBot   = low[i];
         g_botIdx = i;
        }
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Levels of the stored range                                       |
//+------------------------------------------------------------------+
void MakeLevels(Levels &v)
  {
   v.ok = false;
   if(g_anchor < 0)
      return;
   v.top    = g_rTop;
   v.bottom = g_rBot;
   v.topIdx = g_topIdx;
   v.botIdx = g_botIdx;
   FillLevels(v);
  }

void FillLevels(Levels &v)
  {
   double r = v.top - v.bottom;
   v.ok = (r > 0);
   if(!v.ok)
      return;
   v.leg  = (v.botIdx <= v.topIdx ? 1 : -1);
   v.eq   = v.bottom + r * 0.5;
   if(v.leg > 0)
     {
      v.o62  = v.top - r * 0.62;
      v.o705 = v.top - r * 0.705;
      v.o79  = v.top - r * 0.79;
     }
   else
     {
      v.o62  = v.bottom + r * 0.62;
      v.o705 = v.bottom + r * 0.705;
      v.o79  = v.bottom + r * 0.79;
     }
  }

//--- +1 premium, -1 discount, 0 at equilibrium, +2 / -2 inside the OTE band.
//--- Price and level differences are whole hundredths of a point, so a tolerance of
//--- 0.005 point decides a price exactly on a level the same way every time
int Zone(const Levels &v, const double price)
  {
   double tol  = _Point * 0.005;
   int    zone = (price > v.eq + tol ? 1 : (price < v.eq - tol ? -1 : 0));
   if(price >= MathMin(v.o62, v.o79) - tol && price <= MathMax(v.o62, v.o79) + tol)
      zone *= 2;
   return zone;
  }

bool Same(const Levels &a, const Levels &b)
  {
   if(a.ok != b.ok)
      return false;
   if(!a.ok)
      return true;
   return (a.top == b.top && a.bottom == b.bottom && a.leg == b.leg);
  }

//+------------------------------------------------------------------+
//| Buffers of candle k                                              |
//+------------------------------------------------------------------+
void SetBuffers(const int k, const Levels &v, const double c)
  {
   if(v.ok)
     {
      g_bTop[k] = v.top;
      g_bBot[k] = v.bottom;
      g_bEq[k]  = v.eq;
      g_b62[k]  = v.o62;
      g_b79[k]  = v.o79;
      g_bLeg[k]  = v.leg;
      g_bZone[k] = Zone(v, c);
     }
   else
     {
      g_bTop[k]  = EMPTY_VALUE;
      g_bBot[k]  = EMPTY_VALUE;
      g_bEq[k]   = EMPTY_VALUE;
      g_b62[k]   = EMPTY_VALUE;
      g_b79[k]   = EMPTY_VALUE;
      g_bLeg[k]  = EMPTY_VALUE;
      g_bZone[k] = EMPTY_VALUE;
     }
   g_b20h[k] = g_ipH[0];
   g_b20l[k] = g_ipL[0];
   g_b40h[k] = g_ipH[1];
   g_b40l[k] = g_ipL[1];
   g_b60h[k] = g_ipH[2];
   g_b60l[k] = g_ipL[2];
  }

//+------------------------------------------------------------------+
//| A closed candle for the IPDA trading days                        |
//+------------------------------------------------------------------+
void AddDayCandle(const datetime t, const double h, const double l)
  {
   if(PeriodSeconds() > 86400)
      return;
   datetime day = t - t % 86400;
   if(g_curDay == 0)
     {
      StartDay(day, t, h, l);
      return;
     }
   if(day == g_curDay)
     {
      g_curHi = MathMax(g_curHi, h);
      g_curLo = MathMin(g_curLo, l);
      return;
     }
   //--- a short evening session (for example the Sunday open of GMT+0 servers) joins the next day
   if(g_curEvening && day - g_curDay == 86400)
     {
      g_curDay     = day;
      g_curEvening = false;
      g_curHi      = MathMax(g_curHi, h);
      g_curLo      = MathMin(g_curLo, l);
      return;
     }
   //--- the day is complete
   if(g_dn >= ArraySize(g_dHi))
     {
      ArrayResize(g_dHi, g_dn + 32, 32);
      ArrayResize(g_dLo, g_dn + 32, 32);
      ArrayResize(g_dStart, g_dn + 32, 32);
     }
   g_dHi[g_dn]    = g_curHi;
   g_dLo[g_dn]    = g_curLo;
   g_dStart[g_dn] = g_curStart;
   g_dn++;
   if(g_dn > DAYS_KEPT + 30)
     {
      int drop = g_dn - DAYS_KEPT;
      for(int i = 0; i < DAYS_KEPT; i++)
        {
         g_dHi[i]    = g_dHi[i + drop];
         g_dLo[i]    = g_dLo[i + drop];
         g_dStart[i] = g_dStart[i + drop];
        }
      g_dn = DAYS_KEPT;
     }
   UpdateIPDA();
   g_dirty = true;
   StartDay(day, t, h, l);
  }

void StartDay(const datetime day, const datetime t, const double h, const double l)
  {
   g_curDay     = day;
   g_curStart   = t;
   g_curHi      = h;
   g_curLo      = l;
   g_curEvening = (PeriodSeconds() < 86400 && t - day >= 18 * 3600);
  }

//+------------------------------------------------------------------+
//| IPDA 20 / 40 / 60: the last N completed trading days             |
//+------------------------------------------------------------------+
void UpdateIPDA()
  {
   for(int w = 0; w < 3; w++)
     {
      int n = g_ipDays[w];
      if(g_dn < n)
        {
         g_ipH[w] = EMPTY_VALUE;
         g_ipL[w] = EMPTY_VALUE;
         g_ipT[w] = 0;
         continue;
        }
      double hi = g_dHi[g_dn - n], lo = g_dLo[g_dn - n];
      for(int i = g_dn - n + 1; i < g_dn; i++)
        {
         hi = MathMax(hi, g_dHi[i]);
         lo = MathMin(lo, g_dLo[i]);
        }
      g_ipH[w] = hi;
      g_ipL[w] = lo;
      g_ipT[w] = g_dStart[g_dn - n];
     }
  }

//+------------------------------------------------------------------+
//| "-1,-2,-2.5,-4" -> 1, 2, 2.5, 4 (range heights)                   |
//+------------------------------------------------------------------+
bool ParseDeviations(const string text)
  {
   g_devN = 0;
   string s = text;
   StringReplace(s, " ", "");
   if(s == "")
      return true;
   string parts[];
   int n = StringSplit(s, ',', parts);
   for(int i = 0; i < n; i++)
     {
      if(parts[i] == "")
         continue;
      for(int c = 0; c < StringLen(parts[i]); c++)
        {
         ushort ch = StringGetCharacter(parts[i], c);
         if(!((ch >= '0' && ch <= '9') || ch == '.' || ch == '-' || ch == '+'))
            return false;
        }
      double v = MathAbs(StringToDouble(parts[i]));
      if(v <= 0 || v > 20)
         return false;
      if(g_devN < MAX_DEVS)
         g_dev[g_devN++] = v;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Status text (a label holds 63 characters)                        |
//+------------------------------------------------------------------+
string StatusText(const Levels &v, const double price)
  {
   if(!v.ok)
      return "Dealing range: waiting for two confirmed swings";
   int    z    = Zone(v, price);
   string zone = (z > 0 ? "PREMIUM" : (z < 0 ? "DISCOUNT" : "EQUILIBRIUM"));
   if(MathAbs(z) == 2)
      zone += " + OTE";
   return (v.leg > 0 ? "Up leg" : "Down leg") + ": price in " + zone;
  }

//+------------------------------------------------------------------+
//| Zones, lines and labels                                          |
//+------------------------------------------------------------------+
void Draw(const Levels &v, const datetime &time[], const int f, const string status)
  {
   string keep[];
   int    cnt   = 0;
   //--- the zones end about 72 pixels right of the last candle at every zoom, room for the labels
   int scale = (int)ChartGetInteger(0, CHART_SCALE);
   if(scale < 0)
      scale = 0;
   if(scale > 5)
      scale = 5;
   int      ext  = MathMax(4, (int)MathRound(72.0 / (1 << scale)));
   datetime tEnd = time[f] + PeriodSeconds() * ext;
   if(v.ok && g_anchor >= 0 && g_anchor <= f)
     {
      datetime t1 = time[g_anchor];
      double   r  = v.top - v.bottom;
      string   rng = DoubleToString(v.bottom, _Digits) + " - " + DoubleToString(v.top, _Digits);
      if(InpOTE)
        {
         double hiO = MathMax(v.o62, v.o79), loO = MathMin(v.o62, v.o79);
         if(v.leg > 0)
           {
            //--- up leg: the OTE band lies in discount, split the discount box around it (no overlapping fills)
            Box("PZ", t1, v.top, tEnd, v.eq, InpPremiumColor, "Premium " + rng, keep, cnt);
            Box("DZ1", t1, v.eq, tEnd, hiO, InpDiscountColor, "Discount " + rng, keep, cnt);
            Box("OTE", t1, hiO, tEnd, loO, InpOTEColor, "OTE 62 - 79 % " + DoubleToString(loO, _Digits) + " - " + DoubleToString(hiO, _Digits), keep, cnt);
            Box("DZ2", t1, loO, tEnd, v.bottom, InpDiscountColor, "Discount " + rng, keep, cnt);
           }
         else
           {
            Box("DZ", t1, v.eq, tEnd, v.bottom, InpDiscountColor, "Discount " + rng, keep, cnt);
            Box("PZ1", t1, loO, tEnd, v.eq, InpPremiumColor, "Premium " + rng, keep, cnt);
            Box("OTE", t1, hiO, tEnd, loO, InpOTEColor, "OTE 62 - 79 % " + DoubleToString(loO, _Digits) + " - " + DoubleToString(hiO, _Digits), keep, cnt);
            Box("PZ2", t1, v.top, tEnd, hiO, InpPremiumColor, "Premium " + rng, keep, cnt);
           }
         Line("L705", t1, tEnd, v.o705, InpLineColor, STYLE_DOT, "OTE 70.5 % " + DoubleToString(v.o705, _Digits), keep, cnt);
         if(InpLabels)
            Text("T705", tEnd, v.o705, "OTE 70.5%", ANCHOR_RIGHT_LOWER, keep, cnt);
        }
      else
        {
         Box("PZ", t1, v.top, tEnd, v.eq, InpPremiumColor, "Premium " + rng, keep, cnt);
         Box("DZ", t1, v.eq, tEnd, v.bottom, InpDiscountColor, "Discount " + rng, keep, cnt);
        }
      Line("LEQ", t1, tEnd, v.eq, InpLineColor, STYLE_DASH, "Equilibrium (50 %) " + DoubleToString(v.eq, _Digits), keep, cnt);
      if(InpLabels)
        {
         Text("TPZ", tEnd, v.top, "Premium", ANCHOR_RIGHT_UPPER, keep, cnt);
         Text("TDZ", tEnd, v.bottom, "Discount", ANCHOR_RIGHT_LOWER, keep, cnt);
         Text("TEQ", tEnd, v.eq, "EQ 50%", ANCHOR_RIGHT_LOWER, keep, cnt);
        }
      //--- more retracements, measured like the OTE from the end of the leg
      if(InpFibs)
        {
         double fib[4] = {0.236, 0.382, 0.618, 0.786};
         for(int i = 0; i < 4; i++)
           {
            double p = (v.leg > 0 ? v.top - r * fib[i] : v.bottom + r * fib[i]);
            string id = "F" + IntegerToString(i);
            Line(id, t1, tEnd, p, InpLineColor, STYLE_DOT, DoubleToString(fib[i] * 100, 1) + " % " + DoubleToString(p, _Digits), keep, cnt);
            if(InpLabels)
               Text("T" + id, tEnd, p, DoubleToString(fib[i] * 100, 1) + "%", ANCHOR_RIGHT_LOWER, keep, cnt);
           }
        }
      //--- standard deviations beyond the end of the leg
      if(InpDeviations)
        {
         int      endIdx = (v.leg > 0 ? v.topIdx : v.botIdx);
         datetime tLeg   = time[MathMax(0, MathMin(endIdx, f))];
         for(int i = 0; i < g_devN; i++)
           {
            double p = (v.leg > 0 ? v.top + r * g_dev[i] : v.bottom - r * g_dev[i]);
            if(p <= 0)
               continue;
            string id = "SD" + IntegerToString(i);
            string nm = "-" + DoubleToString(g_dev[i], (MathAbs(g_dev[i] - MathRound(g_dev[i])) < 1e-9 ? 0 : 1)) + " SD";
            Line(id, tLeg, tEnd, p, InpDevColor, STYLE_DOT, nm + " " + DoubleToString(p, _Digits), keep, cnt);
            if(InpLabels)
               Text("T" + id, tEnd, p, nm, ANCHOR_RIGHT_LOWER, keep, cnt);
           }
        }
     }
   //--- IPDA data ranges; windows with the same high (or low) share one line and one label.
   //--- A label near the top or bottom edge goes to the inner side of its line, so it is not cut
   double vMax = ChartGetDouble(0, CHART_PRICE_MAX, 0);
   double vMin = ChartGetDouble(0, CHART_PRICE_MIN, 0);
   double pad  = (vMax > vMin ? (vMax - vMin) * 0.04 : 0);
   bool on[3];
   on[0] = InpIPDA20;
   on[1] = InpIPDA40;
   on[2] = InpIPDA60;
   for(int side = 0; side < 2; side++)
      for(int w = 0; w < 3; w++)
        {
         double p = (side == 0 ? g_ipH[w] : g_ipL[w]);
         if(!on[w] || p == EMPTY_VALUE || g_ipT[w] == 0)
            continue;
         bool shown = false;
         for(int e = 0; e < w && !shown; e++)
            shown = (on[e] && (side == 0 ? g_ipH[e] : g_ipL[e]) == p);
         if(shown)
            continue;
         //--- the longest window with this price gives the start of the line
         string names = IntegerToString(g_ipDays[w]);
         datetime t0 = g_ipT[w];
         for(int e = w + 1; e < 3; e++)
            if(on[e] && (side == 0 ? g_ipH[e] : g_ipL[e]) == p)
              {
               names += "/" + IntegerToString(g_ipDays[e]);
               t0 = g_ipT[e];
              }
         string id = (side == 0 ? "IH" : "IL") + IntegerToString(g_ipDays[w]);
         string hl = (side == 0 ? "high" : "low");
         Line(id, t0, tEnd, p, InpIPDAColor, STYLE_DASHDOT, "IPDA " + names + "-day " + hl + " " + DoubleToString(p, _Digits), keep, cnt);
         if(InpLabels)
           {
            bool above = (side == 0);
            if(pad > 0 && above && p + pad > vMax)
               above = false;
            if(pad > 0 && !above && p - pad < vMin)
               above = true;
            Text("T" + id, tEnd, p, "IPDA " + names + (side == 0 ? " H" : " L"), above ? ANCHOR_RIGHT_LOWER : ANCHOR_RIGHT_UPPER,
                 keep, cnt);
           }
        }
   if(InpStatus)
     {
      Status(status);
      Keep(keep, cnt, PREFIX + "STATUS");
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

void Keep(string &list[], int &cnt, const string name)
  {
   if(cnt >= ArraySize(list))
      ArrayResize(list, cnt + 32);
   list[cnt++] = name;
  }

//+------------------------------------------------------------------+
//| Chart objects                                                    |
//+------------------------------------------------------------------+
void Box(const string id, const datetime t1, const double p1, const datetime t2, const double p2, const color clr,
         const string tip, string &keep[], int &cnt)
  {
   string name = PREFIX + id;
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
   Keep(keep, cnt, name);
  }

void Line(const string id, const datetime t1, const datetime t2, const double price, const color clr,
          const ENUM_LINE_STYLE style, const string tip, string &keep[], int &cnt)
  {
   string name = PREFIX + id;
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_TREND, 0, t1, price, t2, price);
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
     }
   ObjectSetInteger(0, name, OBJPROP_TIME, 0, t1);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 0, price);
   ObjectSetInteger(0, name, OBJPROP_TIME, 1, t2);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 1, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
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

void Status(const string text)
  {
   string name = PREFIX + "STATUS";
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, 8);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, 8);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
      ObjectSetString(0, name, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
     }
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, InpTextColor);
  }

//+------------------------------------------------------------------+
//| Popup, push and e-mail alerts                                    |
//+------------------------------------------------------------------+
void Notify(const string what)
  {
   string text = "Premium Discount OTE " + _Symbol + " " + StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period), 7) + ": " + what;
   Alert(text);
   if(InpPush)
      SendNotification(text);
   if(InpEmail)
      SendMail("Premium Discount OTE " + _Symbol, text);
  }
//+------------------------------------------------------------------+
