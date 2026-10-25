//+------------------------------------------------------------------+
//|                                          SensibleGuide_MTF_H1.mq5|
// |                                                                  |                                                                
//+------------------------------------------------------------------+
#property version     "2.00"
#property description "Multi-timeframe confluence (H4/D1/W1) for H1. BUY/SELL arrows."
#property description "Signals on closed bars only. For educational purposes only."
#property indicator_chart_window
#property indicator_buffers 12
#property indicator_plots   2

#property indicator_label1  "Buy"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLime
#property indicator_width1  3
#property indicator_label2  "Sell"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_width2  3

//+------------------------------------------------------------------+
//| Types and inputs                                                 |
//+------------------------------------------------------------------+
enum ENUM_MTF_MODE
{
   MTF_OFF        = 0,   // Off
   MTF_NO_COUNTER = 1,   // No counter-trend on TF B and TF C
   MTF_ALIGNED    = 2    // Aligned with the trend on TF B and TF C
};

input group "=== Trend H1 (EMA alignment; EMAs are not drawn) ==="
input int    InpEMA1         = 10;     // EMA 1
input int    InpEMA2         = 20;     // EMA 2
input int    InpEMA3         = 50;     // EMA 3 (also S/R)
input int    InpEMA4         = 100;    // EMA 4 (also S/R)
input int    InpEMA5         = 200;    // EMA 5 (also S/R)
input bool   InpRequireTrend = true;   // Signals only in the direction of the H1 trend
input int    InpMinTrend     = 3;      // Minimum H1 trend score (0-4 aligned pairs)

input group "=== Multi-timeframe (PERIOD_CURRENT = disabled) ==="
input ENUM_TIMEFRAMES InpTF_A = PERIOD_H4;   // TF A: confirmation (EMAs + swings)
input ENUM_TIMEFRAMES InpTF_B = PERIOD_D1;   // TF B: screening (EMAs + swings + Fib + bias)
input ENUM_TIMEFRAMES InpTF_C = PERIOD_W1;   // TF C: macro (EMAs + swings + bias)
input ENUM_TIMEFRAMES InpTF_D = PERIOD_D1;   // TF D: previous day high/low
input int    InpHTF_EMA1     = 50;     // Higher-TF EMA: 1
input int    InpHTF_EMA2     = 100;    // Higher-TF EMA: 2
input int    InpHTF_EMA3     = 200;    // Higher-TF EMA: 3
input int    InpHTFSwingStr  = 3;      // Swing strength on higher TFs
input int    InpHTFSwings    = 6;      // Number of recent swings per higher TF
input int    InpFibBars      = 30;     // Fibonacci: window on TF B (bars)
input double InpFibMinATR    = 10.0;   // Fibonacci: minimum move (x H1 ATR)
input ENUM_MTF_MODE InpMTFMode = MTF_NO_COUNTER; // Multi-timeframe trend filter
input int    InpHTFBars      = 1000;   // History loaded per higher TF
input bool   InpBlockOnMissingData = false; // Block signals if a higher-TF dataset is unavailable

input group "=== Support / Resistance (confluence) ==="
input double InpRoundPips    = 100;    // Round-number level step (pips)
input int    InpSwingStr     = 5;      // H1 swing strength (bars on each side)
input int    InpSwingBack    = 240;    // H1 swing lookback (bars = 10 days)
input int    InpBBPeriod     = 20;     // Bollinger: period
input double InpBBDev        = 2.0;    // Bollinger: deviations
input double InpZoneATR      = 0.6;    // Zone width (x H1 ATR)
input int    InpMinKinds     = 2;      // Minimum number of converging S/R kinds
input int    InpMinHTFKinds  = 1;      // Of which at least from higher TFs

input group "=== Signal ==="
input double InpMinCandleATR = 0.4;    // Minimum candle size (x ATR)
input int    InpCooldown     = 4;      // Pause between signals (H1 bars)

input group "=== Risk and money management ==="
input int    InpATRPeriod    = 14;     // ATR period
input double InpStopATRPct   = 100;    // Minimum stop (% of ATR)
input double InpMaxStopATR   = 2.5;    // Maximum accepted stop (x ATR)
input double InpMinRRR       = 1.5;    // Minimum reward/risk ratio (after spread)
input int    InpTargetKinds  = 2;      // Converging S/R kinds required for the target
input double InpMaxTPATR     = 20.0;   // Maximum target distance (x ATR)
input double InpTPBufferATR  = 0.1;    // TP placed before the level (x ATR)
input double InpMaxSpreadRatio = 0.2;  // Maximum spread as a fraction of the stop (0 = off)

input group "=== Session (broker server time) ==="
input bool   InpSessionOn    = false;  // Session filter
input int    InpSessionStartH = 7;     // Start hour (inclusive)
input int    InpSessionEndH  = 21;     // End hour (exclusive)

input group "=== Display and alerts ==="
input int    InpMaxBars      = 2000;   // Number of history bars evaluated
input bool   InpShowZones    = true;   // Draw strong S/R zones
input int    InpMaxZones     = 6;      // Maximum number of zones drawn
input int    InpZoneBars     = 60;     // Zone length (bars)
input bool   InpShowTradeLines = true; // Entry/SL/TP lines for the last signal
input bool   InpAlert        = true;   // Pop-up alert
input bool   InpPush         = false;  // Push notification
input bool   InpEmail        = false;  // Email
input bool   InpDebug        = true;   // Print scan statistics to the Experts log

//+------------------------------------------------------------------+
//| Constants                                                        |
//+------------------------------------------------------------------+
#define K_RND 0    // round-number level
#define K_SWG 1    // swing on the chart timeframe
#define K_MA  2    // EMA on the chart timeframe
#define K_BB  3    // Bollinger
#define K_FIB 4    // Fibonacci (TF B)
#define K_HMA 5    // EMA from higher TFs
#define K_HSW 6    // swing from higher TFs
#define K_PDH 7    // previous day high/low
#define KM_HTF 0xF0          // mask of kinds coming from higher TFs
#define LEVEL_CAP   768
#define ST_BARS  0     // bars evaluated
#define ST_SESS  1     // skipped: outside session
#define ST_SMALL 2     // skipped: candle too small
#define ST_COOL  3     // skipped: cooldown
#define ST_CAND  4     // candidates: pattern + trend OK
#define ST_MTF   5     // rejected: higher-TF trend filter
#define ST_CONF  6     // rejected: not enough S/R confluence
#define ST_STOP  7     // rejected: stop too wide
#define ST_SPR   8     // rejected: spread too high
#define ST_TGT   9     // rejected: no valid target
#define ST_RRR   10    // rejected: reward/risk too low
#define ST_BUY   11    // BUY signals
#define ST_SELL  12    // SELL signals
#define ST_SIZE  13

//+------------------------------------------------------------------+
//| Structures                                                       |
//+------------------------------------------------------------------+
struct SLevel { double price; int kind; int side; };   // side: +1 support only, -1 resistance only, 0 both
struct STrade { int dir; double entry; double sl; double tp; double rrr; double dist; int kinds; datetime t; };

bool IsValid(const double v) { return (v > 0.0 && v < 1.0e100); }

//+------------------------------------------------------------------+
//| Higher-timeframe data (only closed bars are used)                |
//+------------------------------------------------------------------+
class CHtf
{
public:
   ENUM_TIMEFRAMES tf;
   bool      active;      // configured and valid
   bool      ready;       // data loaded
   bool      wantEMA;
   bool      wantSwing;
   int       hE[3];
   int       swStr;
   int       n;
   int       nsw;
   int       per;         // seconds
   datetime  lastBar;
   MqlRates  r[];         // chronological (oldest first)
   double    e1[], e2[], e3[];
   int       swConf[];    // index of the bar at which the swing is confirmed
   double    swPrice[];

   CHtf()
   {
      tf = PERIOD_CURRENT; active = false; ready = false;
      wantEMA = false; wantSwing = false; swStr = 3;
      n = 0; nsw = 0; per = 0; lastBar = 0;
      for(int k = 0; k < 3; k++) hE[k] = INVALID_HANDLE;
   }

   ~CHtf()
   {
      for(int k = 0; k < 3; k++)
         if(hE[k] != INVALID_HANDLE) IndicatorRelease(hE[k]);
   }

   bool Init(const ENUM_TIMEFRAMES t, const bool ema, const bool swing,
             const int p1, const int p2, const int p3, const int ss)
   {
      tf = t; wantEMA = ema; wantSwing = swing; swStr = ss;
      active = false; ready = false;
      if(t == PERIOD_CURRENT) return true;                    // disabled, not an error
      per = PeriodSeconds(t);
      if(per <= PeriodSeconds(_Period))
      {
         PrintFormat("SGC: TF %s is not higher than the chart (%s) - disabled.",
                     EnumToString(t), EnumToString((ENUM_TIMEFRAMES)_Period));
         return true;
      }
      if(wantEMA)
      {
         int p[3];
         p[0] = p1; p[1] = p2; p[2] = p3;
         for(int k = 0; k < 3; k++)
         {
            hE[k] = iMA(_Symbol, t, p[k], 0, MODE_EMA, PRICE_CLOSE);
            if(hE[k] == INVALID_HANDLE)
            {
               PrintFormat("SGC: iMA(%s, %d) failed, error %d", EnumToString(t), p[k], GetLastError());
               return false;
            }
         }
      }
      active = true;
      return true;
   }

   //--- reloads the data; on failure keeps the old set intact
   bool Refresh(const int want)
   {
      if(!active) return false;
      MqlRates probe[];
      CopyRates(_Symbol, tf, 0, 1, probe);                   // triggers series build / download if needed
      int cnt = MathMin(want, Bars(_Symbol, tf));
      if(wantEMA)
         for(int k = 0; k < 3; k++)
         {
            int bc = BarsCalculated(hE[k]);
            if(bc <= 0) return false;
            cnt = MathMin(cnt, bc);
         }
      if(cnt < 30) return false;

      MqlRates tr[];
      ArraySetAsSeries(tr, false);
      if(CopyRates(_Symbol, tf, 0, cnt, tr) != cnt) return false;

      double t1[], t2[], t3[];
      if(wantEMA)
      {
         ArraySetAsSeries(t1, false); ArraySetAsSeries(t2, false); ArraySetAsSeries(t3, false);
         if(CopyBuffer(hE[0], 0, 0, cnt, t1) != cnt) return false;
         if(CopyBuffer(hE[1], 0, 0, cnt, t2) != cnt) return false;
         if(CopyBuffer(hE[2], 0, 0, cnt, t3) != cnt) return false;
      }

      ArrayResize(r, cnt);
      for(int k = 0; k < cnt; k++) r[k] = tr[k];
      if(wantEMA)
      {
         ArrayCopy(e1, t1); ArrayCopy(e2, t2); ArrayCopy(e3, t3);
      }
      n = cnt;
      lastBar = r[n - 1].time;
      if(wantSwing) FindSwings();
      ready = true;
      return true;
   }

   void FindSwings()
   {
      nsw = 0;
      ArrayResize(swConf, 2 * n);
      ArrayResize(swPrice, 2 * n);
      const int s = swStr;
      for(int k = s; k < n - s; k++)
      {
         bool sh = true, sl = true;
         for(int j = 1; j <= s && (sh || sl); j++)
         {
            if(r[k].high <= r[k - j].high || r[k].high < r[k + j].high) sh = false;
            if(r[k].low  >= r[k - j].low  || r[k].low  > r[k + j].low)  sl = false;
         }
         if(sh) { swConf[nsw] = k + s; swPrice[nsw] = r[k].high; nsw++; }
         if(sl) { swConf[nsw] = k + s; swPrice[nsw] = r[k].low;  nsw++; }
      }
   }

   //--- index of the last CLOSED bar up to time tClose (-1 if none)
   int Closed(const datetime tClose)
   {
      int lo = 0, hi = n - 1, res = -1;
      while(lo <= hi)
      {
         const int mid = (lo + hi) >> 1;
         if((long)r[mid].time + per <= (long)tClose) { res = mid; lo = mid + 1; }
         else hi = mid - 1;
      }
      return res;
   }

   //--- number of swings confirmed up to bar j
   int SwingCount(const int j)
   {
      int lo = 0, hi = nsw - 1, res = 0;
      while(lo <= hi)
      {
         const int mid = (lo + hi) >> 1;
         if(swConf[mid] <= j) { res = mid + 1; lo = mid + 1; }
         else hi = mid - 1;
      }
      return res;
   }

   //--- +1 = uptrend (e1>e2>e3), -1 = downtrend, 0 = mixed
   int Bias(const int j)
   {
      if(!wantEMA || j < 0 || j >= n) return 0;
      const double a = e1[j], b = e2[j], c = e3[j];
      if(!IsValid(a) || !IsValid(b) || !IsValid(c)) return 0;
      if(a > b && b > c) return 1;
      if(a < b && b < c) return -1;
      return 0;
   }
};

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
double bEMA1[], bEMA2[], bEMA3[], bEMA4[], bEMA5[];
double bBuy[], bSell[];
double bATR[], bBBu[], bBBl[], bSL[], bTP[];

int    g_hE[5];
int    g_hATR = INVALID_HANDLE;
int    g_hBB  = INVALID_HANDLE;
CHtf  *g_h[4];                       // A, B, C, D

SLevel g_lv[];
int    g_n = 0;
STrade g_last;
double g_pip = 0.0;
int    g_warm = 250;
bool   g_needFull = false;
uint   g_tickInit = 0;
datetime g_alertT = 0;
const string g_pfx = "SGC_";

int    g_zonesDrawn = 0;
int    g_st[ST_SIZE];               // scan statistics (funnel)

//+------------------------------------------------------------------+
//| Utilities                                                        |
//+------------------------------------------------------------------+
int Bits(int m)
{
   int c = 0;
   while(m > 0) { c += (m & 1); m >>= 1; }
   return c;
}

string KindNames(const int mask)
{
   string n[8] = {"Rnd", "Swg", "MA", "BB", "Fib", "hMA", "hSw", "PDH"};
   string s = "";
   for(int k = 0; k < 8; k++)
      if((mask & (1 << k)) != 0) s += (s == "" ? "" : "+") + n[k];
   return (s == "" ? "-" : s);
}

string TfName(const ENUM_TIMEFRAMES t) { return StringSubstr(EnumToString(t), 7); }

void AddLevel(const double p, const int kind, const int side)
{
   if(g_n >= LEVEL_CAP || !IsValid(p)) return;
   g_lv[g_n].price = p;
   g_lv[g_n].kind  = kind;
   g_lv[g_n].side  = side;
   g_n++;
}

//--- mask of S/R kinds located within distance <= tol of p
int KindMask(const double p, const double tol, const int side)
{
   int mask = 0;
   for(int k = 0; k < g_n; k++)
   {
      if(side != 0 && g_lv[k].side == -side) continue;
      if(MathAbs(g_lv[k].price - p) <= tol) mask |= (1 << g_lv[k].kind);
   }
   return mask;
}

//--- how many consecutive EMA pairs are aligned in direction dir
int TrendScore(const int i, const int dir)
{
   double e[5];
   e[0] = bEMA1[i]; e[1] = bEMA2[i]; e[2] = bEMA3[i]; e[3] = bEMA4[i]; e[4] = bEMA5[i];
   int sc = 0;
   for(int k = 0; k < 4; k++)
   {
      if(dir > 0) { if(e[k] > e[k + 1]) sc++; }
      else        { if(e[k] < e[k + 1]) sc++; }
   }
   return sc;
}

bool InSession(const datetime t)
{
   if(!InpSessionOn) return true;
   MqlDateTime dt;
   TimeToStruct(t, dt);
   if(InpSessionStartH < InpSessionEndH) return (dt.hour >= InpSessionStartH && dt.hour < InpSessionEndH);
   return (dt.hour >= InpSessionStartH || dt.hour < InpSessionEndH);
}

bool RecentSignal(const int i)
{
   const int from = MathMax(0, i - InpCooldown);
   for(int k = from; k < i; k++)
      if(bBuy[k] != EMPTY_VALUE || bSell[k] != EMPTY_VALUE) return true;
   return false;
}

double SpreadPrice(const int i, const int last, const int &spread[])
{
   long sp = spread[i];
   if(sp <= 0 && i == last) sp = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   return (double)sp * _Point;
}

//--- candlesticks
bool IsHammer(const int i, const double &o[], const double &h[], const double &l[], const double &c[])
{
   const double rg = h[i] - l[i];
   if(rg <= 0.0) return false;
   const double body = MathAbs(c[i] - o[i]);
   const double lw = MathMin(o[i], c[i]) - l[i];
   const double uw = h[i] - MathMax(o[i], c[i]);
   return (lw >= 2.0 * body && lw >= 0.5 * rg && uw <= 0.25 * rg);
}

bool IsStar(const int i, const double &o[], const double &h[], const double &l[], const double &c[])
{
   const double rg = h[i] - l[i];
   if(rg <= 0.0) return false;
   const double body = MathAbs(c[i] - o[i]);
   const double lw = MathMin(o[i], c[i]) - l[i];
   const double uw = h[i] - MathMax(o[i], c[i]);
   return (uw >= 2.0 * body && uw >= 0.5 * rg && lw <= 0.25 * rg);
}

bool BullPattern(const int i, const double &o[], const double &h[], const double &l[], const double &c[])
{
   if(IsHammer(i, o, h, l, c)) return true;
   if(c[i] > o[i] && c[i - 1] < o[i - 1] && c[i] >= o[i - 1] && o[i] <= c[i - 1]) return true;   // engulfing
   if(IsHammer(i - 1, o, h, l, c) && c[i] > o[i] && c[i] > c[i - 1]) return true;               // confirmed hammer
   return false;
}

bool BearPattern(const int i, const double &o[], const double &h[], const double &l[], const double &c[])
{
   if(IsStar(i, o, h, l, c)) return true;
   if(c[i] < o[i] && c[i - 1] > o[i - 1] && c[i] <= o[i - 1] && o[i] >= c[i - 1]) return true;
   if(IsStar(i - 1, o, h, l, c) && c[i] < o[i] && c[i] < c[i - 1]) return true;
   return false;
}

//+------------------------------------------------------------------+
//| S/R level list for closed bar i                                  |
//+------------------------------------------------------------------+
void BuildLevels(const int i, const datetime tClose, const double &high[], const double &low[], const double &close[])
{
   g_n = 0;
   const double atr = bATR[i];

   // 1) round-number levels
   const double step = InpRoundPips * g_pip;
   if(step > 0.0)
   {
      const double base = MathFloor(close[i] / step) * step;
      for(int k = -2; k <= 3; k++) AddLevel(base + k * step, K_RND, 0);
   }

   // 2) chart-timeframe swings (confirmed only: k+s <= i-1)
   const int s = InpSwingStr;
   const int kFrom = i - 1 - s;
   const int kTo   = MathMax(s, i - InpSwingBack);
   for(int k = kFrom; k >= kTo; k--)
   {
      bool sh = true, sl = true;
      for(int j = 1; j <= s && (sh || sl); j++)
      {
         if(high[k] <= high[k - j] || high[k] < high[k + j]) sh = false;
         if(low[k]  >= low[k - j]  || low[k]  > low[k + j])  sl = false;
      }
      if(sh) AddLevel(high[k], K_SWG, 0);
      if(sl) AddLevel(low[k],  K_SWG, 0);
   }

   // 3) long EMAs of the chart timeframe
   AddLevel(bEMA3[i], K_MA, 0);
   AddLevel(bEMA4[i], K_MA, 0);
   AddLevel(bEMA5[i], K_MA, 0);

   // 4) Bollinger
   AddLevel(bBBl[i], K_BB, +1);
   AddLevel(bBBu[i], K_BB, -1);

   // 5) higher TFs A, B, C: EMAs + swings
   for(int q = 0; q < 3; q++)
   {
      CHtf *h = g_h[q];
      if(h == NULL || !h.active || !h.ready) continue;
      const int j = h.Closed(tClose);
      if(j < 0) continue;
      if(h.wantEMA)
      {
         AddLevel(h.e1[j], K_HMA, 0);
         AddLevel(h.e2[j], K_HMA, 0);
         AddLevel(h.e3[j], K_HMA, 0);
      }
      if(h.wantSwing)
      {
         const int c = h.SwingCount(j);
         const int f = MathMax(0, c - InpHTFSwings);
         for(int m = c - 1; m >= f; m--) AddLevel(h.swPrice[m], K_HSW, 0);
      }
   }

   // 6) Fibonacci on the last major swing of TF B
   CHtf *hb = g_h[1];
   if(hb != NULL && hb.active && hb.ready)
   {
      const int j = hb.Closed(tClose);
      if(j >= 0)
      {
         const int from = MathMax(0, j - InpFibBars + 1);
         int hi = from, lo = from;
         for(int k = from; k <= j; k++)
         {
            if(hb.r[k].high >= hb.r[hi].high) hi = k;
            if(hb.r[k].low  <= hb.r[lo].low)  lo = k;
         }
         const double hiP = hb.r[hi].high, loP = hb.r[lo].low;
         const double range = hiP - loP;
         if(range >= InpFibMinATR * atr)
         {
            double fr[4];
            fr[0] = 0.236; fr[1] = 0.382; fr[2] = 0.5; fr[3] = 0.618;
            for(int q = 0; q < 4; q++)
               AddLevel((lo < hi) ? hiP - fr[q] * range : loP + fr[q] * range, K_FIB, 0);
         }
      }
   }

   // 7) previous day high/low
   CHtf *hd = g_h[3];
   if(hd != NULL && hd.active && hd.ready)
   {
      const int j = hd.Closed(tClose);
      if(j >= 0)
      {
         AddLevel(hd.r[j].high, K_PDH, 0);
         AddLevel(hd.r[j].low,  K_PDH, 0);
      }
   }
}

//--- nearest major target in direction dir, within maxDist
double NextTarget(const double entry, const int dir, const double tol, const double maxDist)
{
   double best = 0.0, bestD = 0.0;
   for(int k = 0; k < g_n; k++)
   {
      const double p = g_lv[k].price;
      const double d = (p - entry) * dir;
      if(d <= tol || d > maxDist) continue;
      if(g_lv[k].side == dir) continue;                       // support-only levels cannot be a long target
      if(Bits(KindMask(p, tol, -dir)) < InpTargetKinds) continue;
      if(best == 0.0 || d < bestD) { best = p; bestD = d; }
   }
   return best;
}

//--- multi-timeframe trend filter (TF B and C); missing data is ignored unless InpBlockOnMissingData
bool MtfAllows(const int dir, const datetime tClose)
{
   if(InpMTFMode == MTF_OFF) return true;
   for(int q = 1; q <= 2; q++)
   {
      CHtf *h = g_h[q];
      if(h == NULL || !h.active) continue;
      if(!h.ready) { if(InpBlockOnMissingData) return false; continue; }
      const int j = h.Closed(tClose);
      if(j < 0)    { if(InpBlockOnMissingData) return false; continue; }
      const int b = h.Bias(j);
      if(InpMTFMode == MTF_NO_COUNTER) { if(b == -dir) return false; }
      else                              { if(b != dir)  return false; }
   }
   return true;
}

//+------------------------------------------------------------------+
//| Builds and validates the trade; writes the buffers               |
//| Returns 0 = signal, else reject reason (1 confluence, 2 stop,    |
//| 3 spread, 4 target, 5 reward/risk)                               |
//+------------------------------------------------------------------+
int TryTrade(const int dir, const int i, const double atr, const double sp,
              const datetime &time[], const double &high[], const double &low[], const double &close[])
{
   const double tol = InpZoneATR * atr;
   const double touch = (dir > 0) ? MathMin(low[i], low[i - 1]) : MathMax(high[i], high[i - 1]);
   const int mask = KindMask(touch, tol, dir);
   if(Bits(mask) < InpMinKinds || Bits(mask & KM_HTF) < InpMinHTFKinds) return 1;

   const double entry = close[i];
   double dist = MathMax(InpStopATRPct / 100.0 * atr, MathAbs(entry - touch) + 0.1 * atr);
   if(dist > InpMaxStopATR * atr) return 2;
   dist += sp;                                                   // spread cost included in the risk
   if(InpMaxSpreadRatio > 0.0 && sp > InpMaxSpreadRatio * dist) return 3;

   double tp = NextTarget(entry, dir, tol, InpMaxTPATR * atr);
   if(tp == 0.0) return 4;
   tp -= dir * InpTPBufferATR * atr;
   const double reward = (tp - entry) * dir - sp;
   if(reward <= 0.0) return 4;
   const double rrr = reward / dist;
   if(rrr < InpMinRRR) return 5;

   const double sl = entry - dir * dist;
   if(dir > 0) bBuy[i]  = low[i]  - 0.3 * atr;
   else        bSell[i] = high[i] + 0.3 * atr;
   bSL[i] = sl;
   bTP[i] = tp;

   g_last.dir = dir; g_last.entry = entry; g_last.sl = sl; g_last.tp = tp;
   g_last.rrr = rrr; g_last.dist = dist; g_last.kinds = mask; g_last.t = time[i];
   return 0;
}

//+------------------------------------------------------------------+
//| Closed-bar evaluation (cheap filters first)                      |
//+------------------------------------------------------------------+
void EvalBar(const int i, const int last, const datetime &time[], const double &open[],
             const double &high[], const double &low[], const double &close[], const int &spread[])
{
   bBuy[i] = EMPTY_VALUE; bSell[i] = EMPTY_VALUE; bSL[i] = EMPTY_VALUE; bTP[i] = EMPTY_VALUE;

   const double atr = bATR[i];
   if(!IsValid(atr)) return;
   g_st[ST_BARS]++;
   if(!InSession(time[i]))                          { g_st[ST_SESS]++;  return; }
   if(high[i] - low[i] < InpMinCandleATR * atr)     { g_st[ST_SMALL]++; return; }
   if(RecentSignal(i))                              { g_st[ST_COOL]++;  return; }

   bool wantBuy  = BullPattern(i, open, high, low, close) && (!InpRequireTrend || TrendScore(i, +1) >= InpMinTrend);
   bool wantSell = BearPattern(i, open, high, low, close) && (!InpRequireTrend || TrendScore(i, -1) >= InpMinTrend);
   if(!wantBuy && !wantSell) return;
   g_st[ST_CAND] += (wantBuy ? 1 : 0) + (wantSell ? 1 : 0);

   const datetime tClose = time[i] + PeriodSeconds();
   if(wantBuy  && !MtfAllows(+1, tClose)) { wantBuy  = false; g_st[ST_MTF]++; }
   if(wantSell && !MtfAllows(-1, tClose)) { wantSell = false; g_st[ST_MTF]++; }
   if(!wantBuy && !wantSell) return;

   BuildLevels(i, tClose, high, low, close);                     // expensive: only for candidates
   const double sp = SpreadPrice(i, last, spread);
   if(wantBuy)
   {
      const int rc = TryTrade(+1, i, atr, sp, time, high, low, close);
      if(rc == 0) { g_st[ST_BUY]++; return; }
      g_st[ST_CONF + rc - 1]++;
   }
   if(wantSell)
   {
      const int rc = TryTrade(-1, i, atr, sp, time, high, low, close);
      if(rc == 0) g_st[ST_SELL]++;
      else        g_st[ST_CONF + rc - 1]++;
   }
}

//+------------------------------------------------------------------+
//| Chart objects (created once, then only updated)                  |
//+------------------------------------------------------------------+
void UpsertRect(const string name, const datetime t1, const double p1, const datetime t2,
                const double p2, const color clr, const string tip)
{
   if(ObjectFind(0, name) < 0)
   {
      if(!ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, p1, t2, p2)) return;
      ObjectSetInteger(0, name, OBJPROP_FILL, true);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   }
   else
   {
      ObjectSetInteger(0, name, OBJPROP_TIME, 0, t1);
      ObjectSetDouble(0, name, OBJPROP_PRICE, 0, p1);
      ObjectSetInteger(0, name, OBJPROP_TIME, 1, t2);
      ObjectSetDouble(0, name, OBJPROP_PRICE, 1, p2);
   }
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetString(0, name, OBJPROP_TOOLTIP, tip);
}

void UpsertLine(const string name, const datetime t1, const datetime t2, const double p,
                const color clr, const string tip)
{
   if(ObjectFind(0, name) < 0)
   {
      if(!ObjectCreate(0, name, OBJ_TREND, 0, t1, p, t2, p)) return;
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   }
   else
   {
      ObjectSetInteger(0, name, OBJPROP_TIME, 0, t1);
      ObjectSetDouble(0, name, OBJPROP_PRICE, 0, p);
      ObjectSetInteger(0, name, OBJPROP_TIME, 1, t2);
      ObjectSetDouble(0, name, OBJPROP_PRICE, 1, p);
   }
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetString(0, name, OBJPROP_TOOLTIP, tip);
}

void DrawZones(const int last, const datetime &time[], const double &close[])
{
   int used = 0;
   if(InpShowZones)
   {
      const double tol = InpZoneATR * bATR[last];
      const double px = close[last];
      double cp[64];
      int cnt = 0;
      for(int k = 0; k < g_n && cnt < 64; k++)
      {
         const double p = g_lv[k].price;
         if(Bits(KindMask(p, tol, 0)) < InpMinKinds) continue;
         bool dup = false;
         for(int j = 0; j < cnt; j++)
            if(MathAbs(cp[j] - p) <= tol) { dup = true; break; }
         if(!dup) cp[cnt++] = p;
      }
      const datetime t1 = time[MathMax(0, last - InpZoneBars)];
      const datetime t2 = time[last] + PeriodSeconds() * 10;
      for(int z = 0; z < InpMaxZones && cnt > 0; z++)
      {
         int bi = 0;
         for(int j = 1; j < cnt; j++)
            if(MathAbs(cp[j] - px) < MathAbs(cp[bi] - px)) bi = j;
         const double p = cp[bi];
         UpsertRect(g_pfx + "Z" + IntegerToString(z), t1, p + tol, t2, p - tol,
                    (p < px) ? C'46,139,87' : C'205,92,92',
                    "S/R zone: " + KindNames(KindMask(p, tol, 0)) + " @ " + DoubleToString(p, _Digits));
         used++;
         cp[bi] = cp[cnt - 1];
         cnt--;
      }
   }
   for(int z = used; z < g_zonesDrawn; z++) ObjectDelete(0, g_pfx + "Z" + IntegerToString(z));
   g_zonesDrawn = used;
}

void UpdateTradeLines(const datetime &time[], const int rates_total)
{
   const string nm[3] = {"TE", "TS", "TT"};
   if(g_last.dir == 0 || !InpShowTradeLines)
   {
      for(int k = 0; k < 3; k++) ObjectDelete(0, g_pfx + nm[k]);
      return;
   }
   const datetime t2 = time[rates_total - 1] + PeriodSeconds() * 15;
   UpsertLine(g_pfx + "TE", g_last.t, t2, g_last.entry, clrSilver,    "Entry " + DoubleToString(g_last.entry, _Digits));
   UpsertLine(g_pfx + "TS", g_last.t, t2, g_last.sl,    clrTomato,    "SL "    + DoubleToString(g_last.sl, _Digits));
   UpsertLine(g_pfx + "TT", g_last.t, t2, g_last.tp,    clrLimeGreen, "TP "    + DoubleToString(g_last.tp, _Digits));
}

//+------------------------------------------------------------------+
//| Higher-timeframe data                                            |
//+------------------------------------------------------------------+
//--- true if any dataset became available during this call
bool RefreshHTF()
{
   bool becameReady = false;
   for(int q = 0; q < 4; q++)
   {
      CHtf *h = g_h[q];
      if(h == NULL || !h.active) continue;
      const datetime cur = (datetime)SeriesInfoInteger(_Symbol, h.tf, SERIES_LASTBAR_DATE);
      if(h.ready && cur == h.lastBar) continue;
      const bool was = h.ready;
      h.Refresh(InpHTFBars);
      if(!was && h.ready) becameReady = true;
   }
   return becameReady;
}

bool AllHtfReady()
{
   for(int q = 0; q < 4; q++)
   {
      CHtf *h = g_h[q];
      if(h != NULL && h.active && !h.ready) return false;
   }
   return true;
}

//+------------------------------------------------------------------+
bool ValidateInputs()
{
   if(!(InpEMA1 > 0 && InpEMA1 < InpEMA2 && InpEMA2 < InpEMA3 && InpEMA3 < InpEMA4 && InpEMA4 < InpEMA5))
   { Print("SGC: chart-timeframe EMAs must be strictly ascending."); return false; }
   if(!(InpHTF_EMA1 > 0 && InpHTF_EMA1 < InpHTF_EMA2 && InpHTF_EMA2 < InpHTF_EMA3))
   { Print("SGC: higher-TF EMAs must be strictly ascending."); return false; }
   if(InpSwingStr < 1 || InpHTFSwingStr < 1 || InpSwingBack < 20 || InpHTFSwings < 1)
   { Print("SGC: invalid swing parameters."); return false; }
   if(InpATRPeriod < 1 || InpBBPeriod < 2 || InpBBDev <= 0.0)
   { Print("SGC: invalid ATR/Bollinger parameters."); return false; }
   if(InpZoneATR <= 0.0 || InpMinKinds < 1 || InpMinKinds > 8 || InpMinHTFKinds < 0 || InpTargetKinds < 1)
   { Print("SGC: invalid confluence parameters."); return false; }
   if(InpStopATRPct <= 0.0 || InpMaxStopATR <= 0.0 || InpMinRRR <= 0.0 || InpMaxTPATR <= 0.0)
   { Print("SGC: invalid risk parameters."); return false; }
   if(InpMinTrend < 0 || InpMinTrend > 4 || InpCooldown < 0 || InpMaxBars < 300 || InpHTFBars < 100 || InpFibBars < 5)
   { Print("SGC: invalid general parameters."); return false; }
   return true;
}

//+------------------------------------------------------------------+
int OnInit()
{
   if(!ValidateInputs()) return INIT_PARAMETERS_INCORRECT;

   g_pip = (_Digits == 3 || _Digits == 5) ? _Point * 10.0 : _Point;
   g_warm = InpEMA5 + 50;
   g_tickInit = GetTickCount();
   g_needFull = false;
   g_zonesDrawn = 0;
   ZeroMemory(g_last);
   ArrayInitialize(g_st, 0);
   ArrayResize(g_lv, LEVEL_CAP);

   SetIndexBuffer(0,  bBuy,  INDICATOR_DATA);           // BUY arrow
   SetIndexBuffer(1,  bSell, INDICATOR_DATA);           // SELL arrow
   SetIndexBuffer(2,  bEMA1, INDICATOR_CALCULATIONS);   // EMAs: calculation only, not drawn
   SetIndexBuffer(3,  bEMA2, INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,  bEMA3, INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,  bEMA4, INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,  bEMA5, INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,  bATR,  INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,  bBBu,  INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,  bBBl,  INDICATOR_CALCULATIONS);
   SetIndexBuffer(10, bSL,   INDICATOR_CALCULATIONS);   // SL of the last signal (for EA / iCustom)
   SetIndexBuffer(11, bTP,   INDICATOR_CALCULATIONS);   // TP of the last signal
   ArraySetAsSeries(bEMA1, false); ArraySetAsSeries(bEMA2, false); ArraySetAsSeries(bEMA3, false);
   ArraySetAsSeries(bEMA4, false); ArraySetAsSeries(bEMA5, false); ArraySetAsSeries(bBuy, false);
   ArraySetAsSeries(bSell, false); ArraySetAsSeries(bATR, false);  ArraySetAsSeries(bBBu, false);
   ArraySetAsSeries(bBBl, false);  ArraySetAsSeries(bSL, false);   ArraySetAsSeries(bTP, false);

   PlotIndexSetInteger(0, PLOT_ARROW, 233);             // up arrow
   PlotIndexSetInteger(1, PLOT_ARROW, 234);             // down arrow
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   int per[5];
   per[0] = InpEMA1; per[1] = InpEMA2; per[2] = InpEMA3; per[3] = InpEMA4; per[4] = InpEMA5;

   for(int k = 0; k < 5; k++) g_hE[k] = INVALID_HANDLE;
   for(int k = 0; k < 5; k++)
   {
      g_hE[k] = iMA(_Symbol, _Period, per[k], 0, MODE_EMA, PRICE_CLOSE);
      if(g_hE[k] == INVALID_HANDLE) { PrintFormat("SGC: iMA(%d) failed, error %d", per[k], GetLastError()); return INIT_FAILED; }
   }
   g_hATR = iATR(_Symbol, _Period, InpATRPeriod);
   g_hBB  = iBands(_Symbol, _Period, InpBBPeriod, 0, InpBBDev, PRICE_CLOSE);
   if(g_hATR == INVALID_HANDLE || g_hBB == INVALID_HANDLE)
   { PrintFormat("SGC: iATR/iBands failed, error %d", GetLastError()); return INIT_FAILED; }

   for(int q = 0; q < 4; q++) g_h[q] = NULL;
   ENUM_TIMEFRAMES tfs[4];
   tfs[0] = InpTF_A; tfs[1] = InpTF_B; tfs[2] = InpTF_C; tfs[3] = InpTF_D;
   for(int q = 0; q < 4; q++)
   {
      g_h[q] = new CHtf();
      if(g_h[q] == NULL) return INIT_FAILED;
      const bool full = (q < 3);       // A, B, C: EMAs + swings;  D: previous day high/low only
      if(!g_h[q].Init(tfs[q], full, full, InpHTF_EMA1, InpHTF_EMA2, InpHTF_EMA3, InpHTFSwingStr)) return INIT_FAILED;
   }

   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   IndicatorSetString(INDICATOR_SHORTNAME, "SG MTF H1");
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   for(int k = 0; k < 5; k++)
      if(g_hE[k] != INVALID_HANDLE) { IndicatorRelease(g_hE[k]); g_hE[k] = INVALID_HANDLE; }
   if(g_hATR != INVALID_HANDLE) { IndicatorRelease(g_hATR); g_hATR = INVALID_HANDLE; }
   if(g_hBB  != INVALID_HANDLE) { IndicatorRelease(g_hBB);  g_hBB  = INVALID_HANDLE; }
   for(int q = 0; q < 4; q++)
      if(CheckPointer(g_h[q]) == POINTER_DYNAMIC) { delete g_h[q]; g_h[q] = NULL; }
   ObjectsDeleteAll(0, g_pfx);
   ChartRedraw();
}

//--- prints the scan funnel so it is clear which filter rejects the setups
void DebugReport()
{
   if(!InpDebug) return;
   string htf = "";
   for(int q = 0; q < 4; q++)
   {
      CHtf *h = g_h[q];
      if(h == NULL || !h.active) continue;
      htf += " " + TfName(h.tf) + (h.ready ? "(" + IntegerToString(h.n) + " bars)" : "(NOT READY)");
   }
   PrintFormat("SGC scan | higher TFs:%s", htf);
   PrintFormat("SGC scan | bars=%d candidates=%d | skipped: session=%d small-candle=%d cooldown=%d | rejected: MTF=%d confluence=%d stop=%d spread=%d target=%d RRR=%d | SIGNALS: BUY=%d SELL=%d",
               g_st[ST_BARS], g_st[ST_CAND], g_st[ST_SESS], g_st[ST_SMALL], g_st[ST_COOL],
               g_st[ST_MTF], g_st[ST_CONF], g_st[ST_STOP], g_st[ST_SPR], g_st[ST_TGT], g_st[ST_RRR],
               g_st[ST_BUY], g_st[ST_SELL]);
}

//--- when data is not ready: do not force a full recalculation if history already exists
int Retry(const int prev, const int total) { return (prev > 0 && prev <= total) ? prev : 0; }

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[], const double &high[],
                const double &low[], const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
{
   if(rates_total < g_warm + 10) return 0;
   if(BarsCalculated(g_hE[4]) < rates_total || BarsCalculated(g_hATR) < rates_total ||
      BarsCalculated(g_hBB) < rates_total) return Retry(prev_calculated, rates_total);

   const bool fresh = (prev_calculated <= 0 || prev_calculated > rates_total);
   const int to_copy = fresh ? rates_total : rates_total - prev_calculated + 1;
   if(CopyBuffer(g_hE[0], 0, 0, to_copy, bEMA1) < to_copy) return Retry(prev_calculated, rates_total);
   if(CopyBuffer(g_hE[1], 0, 0, to_copy, bEMA2) < to_copy) return Retry(prev_calculated, rates_total);
   if(CopyBuffer(g_hE[2], 0, 0, to_copy, bEMA3) < to_copy) return Retry(prev_calculated, rates_total);
   if(CopyBuffer(g_hE[3], 0, 0, to_copy, bEMA4) < to_copy) return Retry(prev_calculated, rates_total);
   if(CopyBuffer(g_hE[4], 0, 0, to_copy, bEMA5) < to_copy) return Retry(prev_calculated, rates_total);
   if(CopyBuffer(g_hATR,  0, 0, to_copy, bATR)  < to_copy) return Retry(prev_calculated, rates_total);
   if(CopyBuffer(g_hBB,   1, 0, to_copy, bBBu)  < to_copy) return Retry(prev_calculated, rates_total);
   if(CopyBuffer(g_hBB,   2, 0, to_copy, bBBl)  < to_copy) return Retry(prev_calculated, rates_total);

   // forming bar: no signals
   bBuy[rates_total - 1] = EMPTY_VALUE;  bSell[rates_total - 1] = EMPTY_VALUE;
   bSL[rates_total - 1]  = EMPTY_VALUE;  bTP[rates_total - 1]   = EMPTY_VALUE;

   // higher-TF data; at startup wait briefly for history synchronization
   if(RefreshHTF()) g_needFull = true;
   if(!AllHtfReady() && (GetTickCount() - g_tickInit) < 8000) return 0;

   const int last = rates_total - 2;                        // last closed bar
   const bool full = fresh || g_needFull;
   int start;
   if(full)
   {
      g_needFull = false;
      ArrayInitialize(bBuy,  EMPTY_VALUE);
      ArrayInitialize(bSell, EMPTY_VALUE);
      ArrayInitialize(bSL,   EMPTY_VALUE);
      ArrayInitialize(bTP,   EMPTY_VALUE);
      ZeroMemory(g_last);
      ArrayInitialize(g_st, 0);
      start = MathMax(rates_total - InpMaxBars, g_warm + 2);
   }
   else
      start = prev_calculated - 1;

   if(start > last) return rates_total;                     // tick within the same bar: nothing to do

   for(int i = start; i <= last; i++)
      EvalBar(i, last, time, open, high, low, close, spread);
   if(full) DebugReport();

   // optional chart elements for the last closed bar
   if(InpShowZones)
   {
      BuildLevels(last, time[last] + PeriodSeconds(), high, low, close);
      DrawZones(last, time, close);
   }
   UpdateTradeLines(time, rates_total);
   ChartRedraw();

   // alert only for new signals (not while loading history)
   if(!full && g_last.dir != 0 && g_last.t == time[last] && g_alertT != time[last])
   {
      g_alertT = time[last];
      const string msg = _Symbol + " " + TfName((ENUM_TIMEFRAMES)_Period) + ": " +
                         (g_last.dir > 0 ? "BUY" : "SELL") +
                         " | Entry " + DoubleToString(g_last.entry, _Digits) +
                         " SL " + DoubleToString(g_last.sl, _Digits) +
                         " TP " + DoubleToString(g_last.tp, _Digits) +
                         " | RRR 1:" + DoubleToString(g_last.rrr, 1) +
                         " | " + KindNames(g_last.kinds);
      Print("SGC ", msg);
      if(InpAlert) Alert(msg);
      if(InpPush)  SendNotification(msg);
      if(InpEmail) SendMail("Sensible Guide MTF signal", msg);
   }
   return rates_total;
}
//+------------------------------------------------------------------+
