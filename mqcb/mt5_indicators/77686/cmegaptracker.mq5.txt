//+------------------------------------------------------------------+
//|                                               CMEGapTracker.mq5  |
//|                                                      Ali Rajput  |
//|                                                                  |
//| Finds the weekend CME gap on a 24/7 chart (Bitcoin) or a normal  |
//| weekend gap (gold), keeps every unfilled gap on the chart until  |
//| price comes back to it, and scores how the gaps behaved.         |
//|                                                                  |
//| CME futures close on Friday 16:00 and open on Sunday 17:00       |
//| Chicago time. The indicator converts both moments to server time |
//| with the US and the broker's daylight saving rules, takes the    |
//| price at the Friday close and at the Sunday open, and treats the |
//| difference as the gap. A gap is filled when a closed bar trades  |
//| back to the Friday close.                                        |
//|                                                                  |
//| The scorecard also tests the classic "fade the gap" trade:       |
//| entry at the CME open toward the Friday close, stop a multiple   |
//| of the gap size away, time limit in days, spread charged.        |
//|                                                                  |
//| The gap signal only uses the Friday close and the open price of  |
//| the CME open bar, so it never changes once written.              |
//| Buffers 0-9 can be read with iCustom() from an Expert Advisor.   |
//+------------------------------------------------------------------+
#property copyright   "Ali Rajput"
#property version     "1.00"
#property description "CME weekend gaps for Bitcoin and gold: open gaps kept on the chart, fill statistics and a fade-trade scorecard."
#property indicator_chart_window
#property indicator_buffers 10
#property indicator_plots   2

#property indicator_label1  "Gap down (fade buy)"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrDodgerBlue
#property indicator_width1  2
#property indicator_label2  "Gap up (fade sell)"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrOrangeRed
#property indicator_width2  2

//+------------------------------------------------------------------+
//| Daylight saving rule of the broker's server clock                |
//+------------------------------------------------------------------+
enum ENUM_SERVER_DST
  {
   DST_NONE = 0,                                       // Fixed offset all year
   DST_EU   = 1,                                       // Europe (last Sunday of March to last Sunday of October)
   DST_US   = 2                                        // USA (second Sunday of March to first Sunday of November)
  };

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//|                                                                  |
//| No input groups on purpose: MQL5 counts every "input group" as   |
//| a parameter of iCustom(), which shifts all values after it.      |
//+------------------------------------------------------------------+
input int             InpGMTWinter       = 2;          // Server GMT offset in winter (hours)
input int             InpGMTSummer       = 3;          // Server GMT offset in summer (hours)
input ENUM_SERVER_DST InpServerDST       = DST_EU;     // Server daylight saving rule
input double          InpMinGapPct       = 0.30;       // Minimum gap size, % of price
input int             InpWeeksBack       = 104;        // Weeks of history scored
input int             InpDrawWeeks       = 26;         // Weeks with gap boxes drawn
input double          InpStopGapMult     = 1.0;        // Fade trade: stop distance as a multiple of the gap
input int             InpMaxHoldDays     = 5;          // Fade trade: exit after this many days
input bool            InpShowPanel       = true;       // Show the scorecard panel
input ENUM_BASE_CORNER InpPanelCorner    = CORNER_LEFT_UPPER; // Panel corner
input color           InpOpenGapColor    = C'255,214,170'; // Unfilled gap colour
input color           InpFilledGapColor  = clrGainsboro; // Filled gap colour
input bool            InpAlertNewGap     = true;       // Alert when a new gap opens
input bool            InpAlertFill       = true;       // Alert when an open gap is filled
input bool            InpAlertPush       = false;      // Also send push notifications

//+------------------------------------------------------------------+
//| Indicator buffers                                                |
//+------------------------------------------------------------------+
double BufFadeBuy[];                                   // 0: gap down, entry price on the CME open bar
double BufFadeSell[];                                  // 1: gap up, entry price on the CME open bar
double BufTarget[];                                    // 2: Friday close (fill level) on that bar
double BufStop[];                                      // 3: fade-trade stop on that bar
double BufOpenAbove[];                                 // 4: nearest unfilled gap level above the close
double BufOpenBelow[];                                 // 5: nearest unfilled gap level below the close
double BufScN[];                                       // 6: scorecard, closed fade trades (last closed bar)
double BufScWins[];                                    // 7: scorecard, winning fade trades
double BufScSumR[];                                    // 8: scorecard, total result in R
double BufScLossR[];                                   // 9: scorecard, sum of losing results in R (positive)

//+------------------------------------------------------------------+
//| One weekend gap                                                  |
//+------------------------------------------------------------------+
struct GapInfo
  {
   datetime openTime;                                  // bar time of the CME open
   int      openBar;                                   // bar index of the CME open
   double   friClose;                                  // price at the Friday close (fill level)
   double   sunOpen;                                   // price at the CME open
   int      fillBar;                                   // bar that filled it, -1 if still open
   datetime fillTime;                                  // open time of that bar
   double   heat;                                      // move against the fill before it filled, in gap sizes
   double   r;                                         // fade trade result in R
   bool     tradeOpen;                                 // fade trade still running
   bool     scored;                                    // inside the scored window
  };

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
const string PFX          = "CGT_";                    // chart object prefix
GapInfo  g_gaps[];                                     // gaps found in the loaded history
int      g_small          = 0;                         // weekends below the minimum size
datetime g_lastBarTime    = 0;                         // last bar the scan ran on
datetime g_lastGapAlert   = 0;                         // gap already alerted
datetime g_lastFillAlert  = 0;                         // fill already alerted
string   g_rows[10];                                   // last panel text

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, BufFadeBuy,   INDICATOR_DATA);
   SetIndexBuffer(1, BufFadeSell,  INDICATOR_DATA);
   SetIndexBuffer(2, BufTarget,    INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, BufStop,      INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, BufOpenAbove, INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, BufOpenBelow, INDICATOR_CALCULATIONS);
   SetIndexBuffer(6, BufScN,       INDICATOR_CALCULATIONS);
   SetIndexBuffer(7, BufScWins,    INDICATOR_CALCULATIONS);
   SetIndexBuffer(8, BufScSumR,    INDICATOR_CALCULATIONS);
   SetIndexBuffer(9, BufScLossR,   INDICATOR_CALCULATIONS);
   PlotIndexSetInteger(0, PLOT_ARROW, 233);
   PlotIndexSetInteger(1, PLOT_ARROW, 234);
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 14);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -14);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   IndicatorSetString(INDICATOR_SHORTNAME, "CME Gap Tracker");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   if(PeriodSeconds() > PeriodSeconds(PERIOD_H1))
      Print("CME Gap Tracker works best on H1 or lower. On higher timeframes the CME times fall inside a bar.");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, PFX);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| NthSunday / LastSunday                                           |
//| Calendar helpers for the daylight saving rules (00:00 of the day)|
//+------------------------------------------------------------------+
datetime NthSunday(const int year, const int month, const int n)
  {
   MqlDateTime dt = {};
   dt.year = year;
   dt.mon  = month;
   dt.day  = 1;
   datetime first = StructToTime(dt);
   TimeToStruct(first, dt);
   int shift = (7 - dt.day_of_week) % 7;
   return(first + (shift + 7 * (n - 1)) * 86400);
  }

datetime LastSunday(const int year, const int month)
  {
   MqlDateTime dt = {};
   dt.year = (month == 12) ? year + 1 : year;
   dt.mon  = (month == 12) ? 1 : month + 1;
   dt.day  = 1;
   datetime nextFirst = StructToTime(dt);
   TimeToStruct(nextFirst - 86400, dt);
   return(nextFirst - 86400 - dt.day_of_week * 86400);
  }

//+------------------------------------------------------------------+
//| UsDst / EuDst                                                    |
//| Is daylight saving on at this UTC time (switch hour approximate) |
//+------------------------------------------------------------------+
bool UsDst(const datetime utc)
  {
   MqlDateTime dt;
   TimeToStruct(utc, dt);
   datetime on  = NthSunday(dt.year, 3, 2) + 8 * 3600;   // 02:00 CST = 08:00 UTC
   datetime off = NthSunday(dt.year, 11, 1) + 7 * 3600;  // 02:00 CDT = 07:00 UTC
   return(utc >= on && utc < off);
  }

bool EuDst(const datetime utc)
  {
   MqlDateTime dt;
   TimeToStruct(utc, dt);
   datetime on  = LastSunday(dt.year, 3) + 3600;        // 01:00 UTC
   datetime off = LastSunday(dt.year, 10) + 3600;
   return(utc >= on && utc < off);
  }

//+------------------------------------------------------------------+
//| UtcToServer                                                      |
//| Convert a UTC moment to the broker's server clock                |
//+------------------------------------------------------------------+
datetime UtcToServer(const datetime utc)
  {
   bool summer = false;
   if(InpServerDST == DST_EU)
      summer = EuDst(utc);
   else
      if(InpServerDST == DST_US)
         summer = UsDst(utc);
   return(utc + (summer ? InpGMTSummer : InpGMTWinter) * 3600);
  }

//+------------------------------------------------------------------+
//| LastBarEndingBy / FirstBarFrom                                   |
//| Binary searches on the time array                                |
//+------------------------------------------------------------------+
int LastBarEndingBy(const datetime &time[], const int total, const datetime t)
  {
   //--- last bar whose end is at or before t
   int lo = 0, hi = total - 1, ans = -1, ps = PeriodSeconds();
   while(lo <= hi)
     {
      int mid = (lo + hi) / 2;
      if(time[mid] + ps <= t)
        {
         ans = mid;
         lo = mid + 1;
        }
      else
         hi = mid - 1;
     }
   return(ans);
  }

int FirstBarFrom(const datetime &time[], const int total, const datetime t)
  {
   //--- first bar that opens at or after t
   int lo = 0, hi = total - 1, ans = -1;
   while(lo <= hi)
     {
      int mid = (lo + hi) / 2;
      if(time[mid] >= t)
        {
         ans = mid;
         hi = mid - 1;
        }
      else
         lo = mid + 1;
     }
   return(ans);
  }

//+------------------------------------------------------------------+
//| FindGaps                                                         |
//| One candidate per weekend in the loaded history                  |
//+------------------------------------------------------------------+
void FindGaps(const int rates_total, const datetime &time[], const double &open[], const double &close[],
              const datetime scoreFrom)
  {
   ArrayResize(g_gaps, 0);
   g_small = 0;

   //--- the first Friday (UTC date) of the loaded history
   datetime day = time[0] - time[0] % 86400;
   MqlDateTime dt;
   TimeToStruct(day, dt);
   day += ((5 - dt.day_of_week + 7) % 7) * 86400;

   for(; day < time[rates_total - 1]; day += 7 * 86400)
     {
      //--- CME: Friday 16:00 and Sunday 17:00 Chicago time, in UTC
      int      ct       = UsDst(day + 12 * 3600) ? 5 : 6;
      datetime closeUtc = day + (16 + ct) * 3600;
      int      ct2      = UsDst(day + 2 * 86400 + 12 * 3600) ? 5 : 6;
      datetime openUtc  = day + 2 * 86400 + (17 + ct2) * 3600;
      datetime closeSrv = UtcToServer(closeUtc);
      datetime openSrv  = UtcToServer(openUtc);

      int a = LastBarEndingBy(time, rates_total, closeSrv);
      int b = FirstBarFrom(time, rates_total, openSrv);
      if(a < 0 || b < 0 || b <= a)
         continue;
      //--- data holes: the bars must sit close to the CME times
      if(closeSrv - time[a] > 3 * 86400 || time[b] - openSrv > 2 * 86400)
         continue;

      double fc = close[a], so = open[b];
      if(fc <= 0.0 || MathAbs(so - fc) / fc * 100.0 < InpMinGapPct)
        {
         if(time[b] >= scoreFrom)
            g_small++;               // counted in the scored window only
         continue;
        }
      int n = ArraySize(g_gaps);
      ArrayResize(g_gaps, n + 1);
      g_gaps[n].openTime  = time[b];
      g_gaps[n].openBar   = b;
      g_gaps[n].friClose  = fc;
      g_gaps[n].sunOpen   = so;
      g_gaps[n].fillBar   = -1;
      g_gaps[n].fillTime  = 0;
      g_gaps[n].heat      = 0.0;
      g_gaps[n].r         = 0.0;
      g_gaps[n].tradeOpen = true;
      g_gaps[n].scored    = false;
     }
  }

//+------------------------------------------------------------------+
//| ScoreGap                                                         |
//| Walk closed bars after the CME open: fill, heat, fade trade      |
//+------------------------------------------------------------------+
void ScoreGap(GapInfo &g, const int rates_total, const datetime &time[], const double &high[],
              const double &low[], const double &close[], const int &spread[])
  {
   bool   up     = g.sunOpen > g.friClose;
   double size   = MathAbs(g.sunOpen - g.friClose);
   double entry  = g.sunOpen;
   double stop   = up ? entry + InpStopGapMult * size : entry - InpStopGapMult * size;
   double risk   = InpStopGapMult * size;
   double cost   = spread[g.openBar] * _Point;
   datetime lim  = g.openTime + InpMaxHoldDays * 86400;
   double worst  = entry;

   for(int k = g.openBar; k < rates_total - 1; k++)
     {
      //--- fade trade, if it is still running
      if(g.tradeOpen)
        {
         bool hitSL = up ? high[k] >= stop : low[k] <= stop;
         bool hitTP = up ? low[k] <= g.friClose : high[k] >= g.friClose;
         if(hitSL)
           {
            g.r = (-risk - cost) / risk;
            g.tradeOpen = false;
           }
         else
            if(hitTP)
              {
               g.r = (size - cost) / risk;
               g.tradeOpen = false;
              }
            else
               if(time[k] >= lim)
                 {
                  g.r = ((up ? entry - close[k] : close[k] - entry) - cost) / risk;
                  g.tradeOpen = false;
                 }
        }

      //--- gap fill, and the heat taken before it
      if(g.fillBar < 0)
        {
         worst = up ? MathMax(worst, high[k]) : MathMin(worst, low[k]);
         if(up ? low[k] <= g.friClose : high[k] >= g.friClose)
           {
            g.fillBar  = k;
            g.fillTime = time[k];
            g.heat    = MathAbs(worst - entry) / size;
           }
        }
      if(!g.tradeOpen && g.fillBar >= 0)
         break;
     }
  }

//+------------------------------------------------------------------+
//| Median / Percentile                                              |
//| Order statistics of a small array                                |
//+------------------------------------------------------------------+
double Percentile(double &v[], const double p)
  {
   int n = ArraySize(v);
   if(n == 0)
      return(0.0);
   ArraySort(v);
   int idx = (int)MathFloor(p * (n - 1) + 0.5);
   return(v[MathMin(MathMax(idx, 0), n - 1)]);
  }

//+------------------------------------------------------------------+
//| FmtPrice                                                         |
//| Price with the symbol's digits                                   |
//+------------------------------------------------------------------+
string FmtPrice(const double p)
  {
   return(DoubleToString(p, _Digits));
  }

//+------------------------------------------------------------------+
//| DrawGaps                                                         |
//| Boxes, labels and the fill-level line of every open gap          |
//+------------------------------------------------------------------+
void DrawGaps(const int rates_total, const datetime &time[])
  {
   datetime drawFrom = time[rates_total - 1] - InpDrawWeeks * 7 * 86400;
   datetime rightEnd = time[rates_total - 1] + 10 * PeriodSeconds();
   for(int i = 0; i < ArraySize(g_gaps); i++)
     {
      bool filled = g_gaps[i].fillBar >= 0;
      if(g_gaps[i].openTime < drawFrom && filled)
         continue;

      string   id   = PFX + (string)(long)g_gaps[i].openTime;
      datetime tEnd = filled ? time[g_gaps[i].fillBar] : rightEnd;
      ObjectCreate(0, id, OBJ_RECTANGLE, 0, g_gaps[i].openTime, g_gaps[i].friClose, tEnd, g_gaps[i].sunOpen);
      ObjectSetInteger(0, id, OBJPROP_COLOR, filled ? InpFilledGapColor : InpOpenGapColor);
      ObjectSetInteger(0, id, OBJPROP_FILL, true);
      ObjectSetInteger(0, id, OBJPROP_BACK, true);
      ObjectSetInteger(0, id, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, id, OBJPROP_HIDDEN, true);

      double pct = (g_gaps[i].sunOpen - g_gaps[i].friClose) / g_gaps[i].friClose * 100.0;
      string txt = filled ? StringFormat("%+.2f%%  filled in %.0fh", pct, (time[g_gaps[i].fillBar] - g_gaps[i].openTime) / 3600.0)
                          : StringFormat("%+.2f%%  open, fill at %s", pct, FmtPrice(g_gaps[i].friClose));
      string lb = id + "_t";
      ObjectCreate(0, lb, OBJ_TEXT, 0, g_gaps[i].openTime, MathMax(g_gaps[i].friClose, g_gaps[i].sunOpen));
      ObjectSetString(0, lb, OBJPROP_TEXT, txt);
      ObjectSetString(0, lb, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, lb, OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(0, lb, OBJPROP_COLOR, (color)ChartGetInteger(0, CHART_COLOR_FOREGROUND));
      ObjectSetInteger(0, lb, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
      ObjectSetInteger(0, lb, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, lb, OBJPROP_HIDDEN, true);
     }
  }

//+------------------------------------------------------------------+
//| BuildPanel                                                       |
//| Scorecard text for the scored window                             |
//+------------------------------------------------------------------+
void BuildPanel(const int rates_total, const double &close[])
  {
   int    n = 0, ups = 0, filled = 0, in24 = 0, inWeek = 0, stillOpen = 0;
   int    tN = 0, tWins = 0;
   double tSum = 0.0, tGP = 0.0, tGL = 0.0;
   double hours[], heats[];
   ArrayResize(hours, 0);
   ArrayResize(heats, 0);

   for(int i = 0; i < ArraySize(g_gaps); i++)
     {
      if(!g_gaps[i].scored)
         continue;
      n++;
      if(g_gaps[i].sunOpen > g_gaps[i].friClose)
         ups++;
      if(g_gaps[i].fillBar >= 0)
        {
         filled++;
         double h = (double)(g_gaps[i].fillTime - g_gaps[i].openTime) / 3600.0;
         if(h <= 24.0)
            in24++;
         if(h <= 168.0)
            inWeek++;
         int m = ArraySize(hours);
         ArrayResize(hours, m + 1);
         ArrayResize(heats, m + 1);
         hours[m] = h;
         heats[m] = g_gaps[i].heat;
        }
      else
         stillOpen++;
      if(!g_gaps[i].tradeOpen)
        {
         tN++;
         tSum += g_gaps[i].r;
         if(g_gaps[i].r > 0.0)
           {
            tWins++;
            tGP += g_gaps[i].r;
           }
         else
            tGL -= g_gaps[i].r;
        }
     }

   //--- nearest open gaps from the last close
   double c = close[rates_total - 2], above = 0.0, below = 0.0;
   for(int i = 0; i < ArraySize(g_gaps); i++)
     {
      if(g_gaps[i].fillBar >= 0)
         continue;
      double lv = g_gaps[i].friClose;
      if(lv > c && (above == 0.0 || lv < above))
         above = lv;
      if(lv < c && (below == 0.0 || lv > below))
         below = lv;
     }

   string pf = (tGL > 0.0) ? StringFormat("%.2f", tGP / tGL) : "n/a";
   g_rows[0] = StringFormat("CME Gap Tracker  %s %s, last %d weeks", _Symbol, StringSubstr(EnumToString(_Period), 7), InpWeeksBack);
   g_rows[1] = StringFormat("Gaps >= %.2f%%: %d  (up %d, down %d)  smaller: %d", InpMinGapPct, n, ups, n - ups, g_small);
   g_rows[2] = (n > 0) ? StringFormat("Filled %d (%.0f%%)   within 24h %.0f%%   within 7 days %.0f%%",
                                      filled, 100.0 * filled / n, 100.0 * in24 / n, 100.0 * inWeek / n)
                       : "No gaps in the scored window";
   g_rows[3] = (filled > 0) ? StringFormat("Time to fill: median %.0fh   slowest 10%% over %.0fh", Percentile(hours, 0.5), Percentile(hours, 0.9))
                            : "Time to fill: n/a";
   g_rows[4] = (filled > 0) ? StringFormat("Heat before fill: median %.2fx gap, 90%% within %.2fx", Percentile(heats, 0.5), Percentile(heats, 0.9))
                            : "Heat before fill: n/a";
   g_rows[5] = (tN > 0) ? StringFormat("Fade trade: %d  win %.1f%%  PF %s  avg %+.2fR  total %+.1fR",
                                       tN, 100.0 * tWins / tN, pf, tSum / tN, tSum)
                        : "Fade trade: no closed trades";
   g_rows[6] = StringFormat("(stop %.1fx gap, target Friday close, max %d days)", InpStopGapMult, InpMaxHoldDays);
   g_rows[7] = StringFormat("Open gaps: %d   nearest above %s   below %s", stillOpen,
                            above > 0.0 ? FmtPrice(above) : "none", below > 0.0 ? FmtPrice(below) : "none");
   g_rows[8] = "Spread charged. Stop counted first if both hit.";
   g_rows[9] = "Past gaps only, not a forecast.";
  }

//+------------------------------------------------------------------+
//| DrawPanel                                                        |
//| Scorecard in a chart corner, colours taken from the chart        |
//+------------------------------------------------------------------+
void DrawPanel()
  {
   if(!InpShowPanel)
      return;
   int rowsN = ArraySize(g_rows);
   int maxW = 0, maxH = 0;
   TextSetFont("Consolas", -90);
   for(int k = 0; k < rowsN; k++)
     {
      uint tw = 0, th = 0;
      TextGetSize(g_rows[k], tw, th);
      maxW = MathMax(maxW, (int)tw);
      maxH = MathMax(maxH, (int)th);
     }
   int  rowH = MathMax(16, maxH + 3), w = maxW + 20, hgt = rowsN * rowH + 12;
   bool left = (InpPanelCorner == CORNER_LEFT_UPPER || InpPanelCorner == CORNER_LEFT_LOWER);
   bool top  = (InpPanelCorner == CORNER_LEFT_UPPER || InpPanelCorner == CORNER_RIGHT_UPPER);

   string bg = PFX + "panel_bg";
   ObjectCreate(0, bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, bg, OBJPROP_CORNER, InpPanelCorner);
   ObjectSetInteger(0, bg, OBJPROP_XDISTANCE, left ? 8 : 8 + w);
   ObjectSetInteger(0, bg, OBJPROP_YDISTANCE, top ? 20 : 20 + hgt);
   ObjectSetInteger(0, bg, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, bg, OBJPROP_YSIZE, hgt);
   ObjectSetInteger(0, bg, OBJPROP_BGCOLOR, (color)ChartGetInteger(0, CHART_COLOR_BACKGROUND));
   ObjectSetInteger(0, bg, OBJPROP_COLOR, (color)ChartGetInteger(0, CHART_COLOR_FOREGROUND));
   ObjectSetInteger(0, bg, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, bg, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, bg, OBJPROP_HIDDEN, true);

   for(int k = 0; k < rowsN; k++)
     {
      string nm = PFX + "panel_" + (string)k;
      ObjectCreate(0, nm, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, nm, OBJPROP_CORNER, InpPanelCorner);
      ObjectSetInteger(0, nm, OBJPROP_ANCHOR, top ? ANCHOR_LEFT_UPPER : ANCHOR_LEFT_LOWER);
      ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, left ? 16 : w);
      ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, top ? 26 + k * rowH : 26 + (rowsN - 1 - k) * rowH);
      ObjectSetString(0, nm, OBJPROP_TEXT, g_rows[k]);
      ObjectSetString(0, nm, OBJPROP_FONT, "Consolas");
      ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, 9);
      ObjectSetInteger(0, nm, OBJPROP_COLOR, (color)ChartGetInteger(0, CHART_COLOR_FOREGROUND));
      ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, nm, OBJPROP_HIDDEN, true);
     }
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[], const double &high[],
                const double &low[], const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
  {
   if(rates_total < 50)
      return(0);

   //--- once per new bar: a gap only needs the open of the CME bar
   if(prev_calculated > 0 && time[rates_total - 1] == g_lastBarTime)
      return(rates_total);
   bool firstRun = (g_lastBarTime == 0);
   g_lastBarTime = time[rates_total - 1];

   ArrayInitialize(BufFadeBuy, EMPTY_VALUE);
   ArrayInitialize(BufFadeSell, EMPTY_VALUE);
   ArrayInitialize(BufTarget, EMPTY_VALUE);
   ArrayInitialize(BufStop, EMPTY_VALUE);
   ArrayInitialize(BufOpenAbove, EMPTY_VALUE);
   ArrayInitialize(BufOpenBelow, EMPTY_VALUE);
   ArrayInitialize(BufScN, EMPTY_VALUE);
   ArrayInitialize(BufScWins, EMPTY_VALUE);
   ArrayInitialize(BufScSumR, EMPTY_VALUE);
   ArrayInitialize(BufScLossR, EMPTY_VALUE);
   ObjectsDeleteAll(0, PFX);

   datetime scoreFrom = time[rates_total - 1] - InpWeeksBack * 7 * 86400;
   FindGaps(rates_total, time, open, close, scoreFrom);
   int      newGapIdx = -1, newFillIdx = -1;

   for(int i = 0; i < ArraySize(g_gaps); i++)
     {
      ScoreGap(g_gaps[i], rates_total, time, high, low, close, spread);
      g_gaps[i].scored = (g_gaps[i].openTime >= scoreFrom);

      //--- signal buffers on the CME open bar
      int    b    = g_gaps[i].openBar;
      bool   up   = g_gaps[i].sunOpen > g_gaps[i].friClose;
      double size = MathAbs(g_gaps[i].sunOpen - g_gaps[i].friClose);
      if(up)
         BufFadeSell[b] = g_gaps[i].sunOpen;
      else
         BufFadeBuy[b] = g_gaps[i].sunOpen;
      BufTarget[b] = g_gaps[i].friClose;
      BufStop[b]   = up ? g_gaps[i].sunOpen + InpStopGapMult * size : g_gaps[i].sunOpen - InpStopGapMult * size;

      if(b == rates_total - 1)
         newGapIdx = i;
      if(g_gaps[i].fillBar == rates_total - 2)
         newFillIdx = i;
     }

   //--- nearest unfilled level above and below each closed bar of the scored window
   int from = MathMax(0, FirstBarFrom(time, rates_total, scoreFrom));
   for(int k = from; k < rates_total - 1; k++)
     {
      double above = EMPTY_VALUE, below = EMPTY_VALUE;
      for(int i = 0; i < ArraySize(g_gaps); i++)
        {
         if(g_gaps[i].openBar > k || (g_gaps[i].fillBar >= 0 && g_gaps[i].fillBar <= k))
            continue;
         double lv = g_gaps[i].friClose;
         if(lv > close[k] && (above == EMPTY_VALUE || lv < above))
            above = lv;
         if(lv < close[k] && (below == EMPTY_VALUE || lv > below))
            below = lv;
        }
      BufOpenAbove[k] = above;
      BufOpenBelow[k] = below;
     }

   //--- scorecard totals on the last closed bar, for an EA to read at shift 1
   int    n = 0, wins = 0;
   double sumR = 0.0, lossR = 0.0;
   for(int i = 0; i < ArraySize(g_gaps); i++)
     {
      if(!g_gaps[i].scored || g_gaps[i].tradeOpen)
         continue;
      n++;
      sumR += g_gaps[i].r;
      if(g_gaps[i].r > 0.0)
         wins++;
      else
         lossR -= g_gaps[i].r;
     }
   BufScN[rates_total - 2]     = n;
   BufScWins[rates_total - 2]  = wins;
   BufScSumR[rates_total - 2]  = sumR;
   BufScLossR[rates_total - 2] = lossR;

   DrawGaps(rates_total, time);
   BuildPanel(rates_total, close);
   DrawPanel();
   ChartRedraw();

   //--- alerts, never for history loaded at start-up
   if(!firstRun)
     {
      string msg = "";
      if(InpAlertNewGap && newGapIdx >= 0 && g_gaps[newGapIdx].openTime != g_lastGapAlert)
        {
         g_lastGapAlert = g_gaps[newGapIdx].openTime;
         double pct = (g_gaps[newGapIdx].sunOpen - g_gaps[newGapIdx].friClose) / g_gaps[newGapIdx].friClose * 100.0;
         msg = StringFormat("%s: CME gap %+.2f%%, fill level %s", _Symbol, pct, FmtPrice(g_gaps[newGapIdx].friClose));
        }
      if(InpAlertFill && newFillIdx >= 0 && g_gaps[newFillIdx].openTime != g_lastFillAlert)
        {
         g_lastFillAlert = g_gaps[newFillIdx].openTime;
         msg = StringFormat("%s: CME gap from %s filled at %s", _Symbol,
                            TimeToString(g_gaps[newFillIdx].openTime, TIME_DATE), FmtPrice(g_gaps[newFillIdx].friClose));
        }
      if(msg != "")
        {
         Alert(msg);
         if(InpAlertPush)
            SendNotification(msg);
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
