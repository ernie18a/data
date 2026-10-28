//+------------------------------------------------------------------+
//|                                    AdvancedHarmonicScanner.mq5   |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Advanced Harmonic Scanner"
#property link      "https://www.mql5.com"
#property version   "1.01"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   0

//--- Input groups
input group "=== ZigZag (Wave) Settings ==="
input int    InpPrdMaj         = 21;             // Major Wave Length (min 5)
input int    InpPrdMin         = 8;              // Minor Wave Length (min 2)
input double InpFibTolerance   = 8.0;            // Fibonacci Tolerance (%)

input group "=== RSI & Entry Settings ==="
input int    InpRsiLen         = 14;             // RSI Length
input double InpRsiOB          = 70.0;           // RSI Overbought
input double InpRsiOS          = 30.0;           // RSI Oversold

input group "=== UI & History Settings ==="
input bool   InpShowHist       = true;           // Keep Historical Patterns
input int    InpProjBars       = 20;             // Target Line Length (Bars)
input color  InpColBull        = C'41,98,255';   // Bullish Pattern Color
input color  InpColBear        = C'242,54,69';   // Bearish Pattern Color

//--- Structural types (Renamed to HarmonicPoint to avoid MQL5 keyword collision)
struct HarmonicPoint
{
   int      bar_idx;
   datetime time;
   double   p;
   int      d;      // 1 = High, -1 = Low
};

struct ZigZagTracker
{
   HarmonicPoint conf_pts[6];
   int           count;
   int           last_dir;
   double        live_p;
};

//--- Global Variables
#define OBJ_PREFIX "HARM_"
int           hRsi = INVALID_HANDLE;
double        g_rsiBuffer[];

ZigZagTracker zz_maj;
ZigZagTracker zz_min;
datetime      g_last_C_time = 0;
int           g_obj_id = 0;

string g_curr_objects[];

//+------------------------------------------------------------------+
//| Helpers                                                          |
//+------------------------------------------------------------------+
bool InRange(double val, double target, double tol)
{
   return (MathAbs(val - target) <= tol);
}

void ClearCurrentObjects()
{
   int total = ArraySize(g_curr_objects);
   for(int i = 0; i < total; i++)
   {
      ObjectDelete(0, g_curr_objects[i]);
   }
   ArrayResize(g_curr_objects, 0);
}

void TrackObject(string name)
{
   int sz = ArraySize(g_curr_objects);
   ArrayResize(g_curr_objects, sz + 1);
   g_curr_objects[sz] = name;
}

//+------------------------------------------------------------------+
//| ZigZag Maintenance                                               |
//+------------------------------------------------------------------+
void ShiftPoints(ZigZagTracker &zz)
{
   for(int i = 5; i > 0; i--)
   {
      zz.conf_pts[i] = zz.conf_pts[i - 1];
   }
}

void UpdateZZ(ZigZagTracker &zz, double ph, double pl, int b_index, datetime b_time, double live_h, double live_l, int curr_index, datetime curr_time)
{
   if(ph != EMPTY_VALUE)
   {
      if(zz.last_dir == 1)
      {
         if(ph > zz.live_p)
         {
            zz.live_p = ph;
            if(zz.count > 0)
            {
               zz.conf_pts[0].p       = ph;
               zz.conf_pts[0].bar_idx = b_index;
               zz.conf_pts[0].time    = b_time;
            }
         }
      }
      else
      {
         ShiftPoints(zz);
         zz.conf_pts[0].bar_idx = b_index;
         zz.conf_pts[0].time    = b_time;
         zz.conf_pts[0].p       = ph;
         zz.conf_pts[0].d       = 1;
         zz.last_dir            = 1;
         zz.live_p              = ph;
         if(zz.count < 6) zz.count++;
      }
   }

   if(pl != EMPTY_VALUE)
   {
      if(zz.last_dir == -1)
      {
         if(pl < zz.live_p)
         {
            zz.live_p = pl;
            if(zz.count > 0)
            {
               zz.conf_pts[0].p       = pl;
               zz.conf_pts[0].bar_idx = b_index;
               zz.conf_pts[0].time    = b_time;
            }
         }
      }
      else
      {
         ShiftPoints(zz);
         zz.conf_pts[0].bar_idx = b_index;
         zz.conf_pts[0].time    = b_time;
         zz.conf_pts[0].p       = pl;
         zz.conf_pts[0].d       = -1;
         zz.last_dir            = -1;
         zz.live_p              = pl;
         if(zz.count < 6) zz.count++;
      }
   }

   // Real-time tracking for Point D
   if(zz.count > 0)
   {
      if(zz.last_dir == 1)
      {
         if(live_h > zz.conf_pts[0].p)
         {
            zz.conf_pts[0].p       = live_h;
            zz.conf_pts[0].bar_idx = curr_index;
            zz.conf_pts[0].time    = curr_time;
         }
      }
      else if(zz.last_dir == -1)
      {
         if(live_l < zz.conf_pts[0].p)
         {
            zz.conf_pts[0].p       = live_l;
            zz.conf_pts[0].bar_idx = curr_index;
            zz.conf_pts[0].time    = curr_time;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Pattern Classifier                                               |
//+------------------------------------------------------------------+
string GetPattern(bool has_x, double ab_xa, double bc_ab, double xd_xa, double cd_ab, double tol)
{
   string pat = "Invalid";
   if(has_x)
   {
      if(InRange(ab_xa, 0.618, tol) && (InRange(bc_ab, 0.382, tol) || InRange(bc_ab, 0.886, tol)) && InRange(xd_xa, 0.786, tol))
         pat = "GARTLEY";
      else if((InRange(ab_xa, 0.382, tol) || InRange(ab_xa, 0.500, tol)) && InRange(xd_xa, 0.886, tol))
         pat = "BAT";
      else if(InRange(ab_xa, 0.786, tol) && (InRange(xd_xa, 1.272, tol) || InRange(xd_xa, 1.618, tol)))
         pat = "BUTTERFLY";
      else if((InRange(ab_xa, 0.382, tol) || InRange(ab_xa, 0.618, tol)) && InRange(xd_xa, 1.618, tol))
         pat = "CRAB";
   }

   if(pat == "Invalid" && InRange(cd_ab, 1.0, tol) && bc_ab >= (0.382 - tol) && bc_ab <= (0.886 + tol))
      pat = "AB=CD";

   return pat;
}

void EvaluateTracker(const ZigZagTracker &zz, double tol, string &pat, bool &is_bull, bool &has_x)
{
   pat     = "Invalid";
   is_bull = false;
   has_x   = false;

   if(zz.count >= 4)
   {
      HarmonicPoint pD = zz.conf_pts[0];
      HarmonicPoint pC = zz.conf_pts[1];
      HarmonicPoint pB = zz.conf_pts[2];
      HarmonicPoint pA = zz.conf_pts[3];
      has_x            = (zz.count >= 5);
      HarmonicPoint pX;
      if(has_x) pX = zz.conf_pts[4];

      double ab = MathAbs(pB.p - pA.p);
      double bc = MathAbs(pC.p - pB.p);
      double cd = MathAbs(pD.p - pC.p);
      double xa = has_x ? MathAbs(pA.p - pX.p) : 0.0;
      double xd = has_x ? MathAbs(pD.p - pX.p) : 0.0;

      double ab_xa = (xa > 0.0) ? (ab / xa) : 0.0;
      double bc_ab = (ab > 0.0) ? (bc / ab) : 0.0;
      double xd_xa = (xa > 0.0) ? (xd / xa) : 0.0;
      double cd_ab = (ab > 0.0) ? (cd / ab) : 0.0;

      is_bull = (pD.d == -1);
      pat = GetPattern(has_x, ab_xa, bc_ab, xd_xa, cd_ab, tol);
   }
}

//+------------------------------------------------------------------+
//| Pivot High/Low Detectors                                         |
//+------------------------------------------------------------------+
double PivotHigh(const double &high[], int idx, int left, int right)
{
   if(idx - right < 0 || idx - right - left < 0) return EMPTY_VALUE;
   int p = idx - right;
   double mid = high[p];
   for(int i = 1; i <= left; i++)
   {
      if(high[p - i] >= mid) return EMPTY_VALUE;
   }
   for(int i = 1; i <= right; i++)
   {
      if(high[p + i] > mid) return EMPTY_VALUE;
   }
   return mid;
}

double PivotLow(const double &low[], int idx, int left, int right)
{
   if(idx - right < 0 || idx - right - left < 0) return EMPTY_VALUE;
   int p = idx - right;
   double mid = low[p];
   for(int i = 1; i <= left; i++)
   {
      if(low[p - i] <= mid) return EMPTY_VALUE;
   }
   for(int i = 1; i <= right; i++)
   {
      if(low[p + i] < mid) return EMPTY_VALUE;
   }
   return mid;
}

//+------------------------------------------------------------------+
//| Graphic Drawing Helpers                                          |
//+------------------------------------------------------------------+
void DrawLine(string name, datetime t1, double p1, datetime t2, double p2, color c, int width, ENUM_LINE_STYLE style)
{
   ObjectCreate(0, name, OBJ_TREND, 0, t1, p1, t2, p2);
   ObjectSetInteger(0, name, OBJPROP_COLOR, c);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   TrackObject(name);
}

void DrawLabel(string name, datetime t, double p, string txt, color c, color txt_col, ENUM_ANCHOR_POINT anchor)
{
   ObjectCreate(0, name, OBJ_TEXT, 0, t, p);
   ObjectSetString(0, name, OBJPROP_TEXT, txt);
   ObjectSetInteger(0, name, OBJPROP_COLOR, c);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, anchor);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial Bold");
   TrackObject(name);
}

//+------------------------------------------------------------------+
//| Initialization Function                                          |
//+------------------------------------------------------------------+
int OnInit()
{
   zz_maj.count = 0; zz_maj.last_dir = 0; zz_maj.live_p = 0.0;
   zz_min.count = 0; zz_min.last_dir = 0; zz_min.live_p = 0.0;

   hRsi = iRSI(_Symbol, _Period, InpRsiLen, PRICE_CLOSE);
   if(hRsi == INVALID_HANDLE)
   {
      Print("Failed to create RSI Handle.");
      return INIT_FAILED;
   }

   ArrayResize(g_curr_objects, 0);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Deinitialization Function                                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, OBJ_PREFIX);
   if(hRsi != INVALID_HANDLE)
      IndicatorRelease(hRsi);
}

//+------------------------------------------------------------------+
//| Iteration / Calculation Function                                 |
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
   if(rates_total < MathMax(InpPrdMaj, InpPrdMin) + 5)
      return 0;

   ArraySetAsSeries(g_rsiBuffer, false);
   if(CopyBuffer(hRsi, 0, 0, rates_total, g_rsiBuffer) <= 0)
      return prev_calculated;

   int start = prev_calculated - 1;
   if(start < 1)
   {
      start = 1;
      zz_maj.count = 0; zz_maj.last_dir = 0; zz_maj.live_p = 0.0;
      zz_min.count = 0; zz_min.last_dir = 0; zz_min.live_p = 0.0;
      ObjectsDeleteAll(0, OBJ_PREFIX);
   }

   double tol = InpFibTolerance / 100.0;

   for(int i = start; i < rates_total; i++)
   {
      double ph_maj = PivotHigh(high, i, InpPrdMaj, 1);
      double pl_maj = PivotLow(low, i, InpPrdMaj, 1);
      double ph_min = PivotHigh(high, i, InpPrdMin, 1);
      double pl_min = PivotLow(low, i, InpPrdMin, 1);

      datetime prev_time = time[i - 1];
      datetime curr_time = time[i];

      UpdateZZ(zz_maj, ph_maj, pl_maj, i - 1, prev_time, high[i], low[i], i, curr_time);
      UpdateZZ(zz_min, ph_min, pl_min, i - 1, prev_time, high[i], low[i], i, curr_time);

      string maj_pat, min_pat;
      bool maj_bull, min_bull;
      bool maj_has_x, min_has_x;

      EvaluateTracker(zz_maj, tol, maj_pat, maj_bull, maj_has_x);
      EvaluateTracker(zz_min, tol, min_pat, min_bull, min_has_x);

      bool use_maj = (maj_pat != "Invalid") || (min_pat == "Invalid");
      ZigZagTracker active_zz = use_maj ? zz_maj : zz_min;
      string active_pat       = use_maj ? maj_pat : min_pat;
      bool active_bull        = use_maj ? maj_bull : min_bull;
      bool active_has_x       = use_maj ? maj_has_x : min_has_x;

      double cur_rsi  = g_rsiBuffer[i];
      double prev_rsi = g_rsiBuffer[i - 1];

      bool rsi_cross_up = (prev_rsi <= InpRsiOS && cur_rsi > InpRsiOS);
      bool rsi_cross_dn = (prev_rsi >= InpRsiOB && cur_rsi < InpRsiOB);

      if(active_pat != "Invalid")
      {
         HarmonicPoint pD = active_zz.conf_pts[0];
         HarmonicPoint pC = active_zz.conf_pts[1];
         HarmonicPoint pB = active_zz.conf_pts[2];
         HarmonicPoint pA = active_zz.conf_pts[3];
         HarmonicPoint pX;
         if(active_has_x) pX = active_zz.conf_pts[4];

         bool is_abcd       = (active_pat == "AB=CD");
         bool is_bull_trade = active_bull;

         bool entry_cond = (is_bull_trade && (rsi_cross_up || cur_rsi <= InpRsiOS)) ||
                           (!is_bull_trade && (rsi_cross_dn || cur_rsi >= InpRsiOB));

         if(entry_cond)
         {
            double ad_diff = MathAbs(pA.p - pD.p);
            double tp1 = is_bull_trade ? (pD.p + ad_diff * 0.382) : (pD.p - ad_diff * 0.382);
            double tp2 = is_bull_trade ? (pD.p + ad_diff * 0.618) : (pD.p - ad_diff * 0.618);
            double sl  = is_bull_trade ? (pD.p - ad_diff * 0.20)  : (pD.p + ad_diff * 0.20);

            if(pC.time != g_last_C_time)
            {
               if(!InpShowHist)
                  ClearCurrentObjects();
               else
                  ArrayResize(g_curr_objects, 0);

               g_last_C_time = pC.time;
            }
            else
            {
               ClearCurrentObjects();
            }

            color draw_col = is_bull_trade ? InpColBull : InpColBear;
            string uid = OBJ_PREFIX + IntegerToString(g_obj_id++);

            // Draw Harmonic Wings
            if(active_has_x && !is_abcd)
            {
               DrawLine(uid + "_XA", pX.time, pX.p, pA.time, pA.p, draw_col, 2, STYLE_SOLID);
               DrawLine(uid + "_XB", pX.time, pX.p, pB.time, pB.p, draw_col, 1, STYLE_DASH);
               DrawLabel(uid + "_lblX", pX.time, pX.p, "X", clrGold, clrBlack, ANCHOR_CENTER);
            }

            DrawLine(uid + "_AB", pA.time, pA.p, pB.time, pB.p, draw_col, 2, STYLE_SOLID);
            DrawLine(uid + "_BC", pB.time, pB.p, pC.time, pC.p, draw_col, 2, STYLE_SOLID);
            DrawLine(uid + "_CD", pC.time, pC.p, pD.time, pD.p, draw_col, 2, STYLE_SOLID);
            DrawLine(uid + "_AC", pA.time, pA.p, pC.time, pC.p, draw_col, 1, STYLE_DASH);
            DrawLine(uid + "_BD", pB.time, pB.p, pD.time, pD.p, draw_col, 1, STYLE_DASH);

            // Pivot Labels
            DrawLabel(uid + "_lblA", pA.time, pA.p, "A", clrGold, clrBlack, ANCHOR_CENTER);
            DrawLabel(uid + "_lblB", pB.time, pB.p, "B", clrGold, clrBlack, ANCHOR_CENTER);
            DrawLabel(uid + "_lblC", pC.time, pC.p, "C", clrGold, clrBlack, ANCHOR_CENTER);
            DrawLabel(uid + "_lblD", pD.time, pD.p, "D", clrGold, clrBlack, ANCHOR_CENTER);

            // Setup Tag
            string dir_text = is_bull_trade ? "Bull " : "Bear ";
            string arrow    = is_bull_trade ? " ▲" : " ▼";
            string tag_text = dir_text + active_pat + arrow;
            ENUM_ANCHOR_POINT anchor = is_bull_trade ? ANCHOR_LOWER : ANCHOR_UPPER;
            DrawLabel(uid + "_tag", pD.time, pD.p, tag_text, draw_col, clrWhite, anchor);

            // Projected Target Lines
            datetime future_time = time[i] + (datetime)(InpProjBars * PeriodSeconds());

            DrawLine(uid + "_tp1", pD.time, tp1, future_time, tp1, clrGreen, 2, STYLE_DASH);
            DrawLabel(uid + "_tp1_lbl", future_time, tp1, "TP1: " + DoubleToString(tp1, _Digits), clrGreen, clrWhite, ANCHOR_LEFT);

            DrawLine(uid + "_tp2", pD.time, tp2, future_time, tp2, clrGreen, 2, STYLE_DASH);
            DrawLabel(uid + "_tp2_lbl", future_time, tp2, "TP2: " + DoubleToString(tp2, _Digits), clrGreen, clrWhite, ANCHOR_LEFT);

            DrawLine(uid + "_sl", pD.time, sl, future_time, sl, clrRed, 2, STYLE_DOT);
            DrawLabel(uid + "_sl_lbl", future_time, sl, "Risk: " + DoubleToString(sl, _Digits), clrRed, clrWhite, ANCHOR_LEFT);
         }
      }
   }

   return rates_total;
}
//+------------------------------------------------------------------+