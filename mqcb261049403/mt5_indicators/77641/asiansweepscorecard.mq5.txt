//+------------------------------------------------------------------+
//|                                         AsianSweepScorecard.mq5  |
//|                                                      Ali Rajput  |
//|                                                                  |
//| Asian range liquidity sweeps, with a scorecard of how every      |
//| signal actually ended.                                           |
//|                                                                  |
//| 1. The Asian session builds a range (server time inputs).        |
//| 2. In the trade window a closed bar wicks through one side of    |
//|    the range and closes back inside: a sweep.                    |
//| 3. A later bar closes beyond the sweep bar's opposite end        |
//|    within a few bars: the signal. Entry is the next bar's open,  |
//|    stop beyond the sweep wick, target a multiple of the risk.    |
//| 4. Each signal is then followed bar by bar until it hits the     |
//|    stop, the target, or the day-close hour. The spread of the    |
//|    entry bar is charged as a cost. The panel sums the results    |
//|    in R.                                                         |
//|                                                                  |
//| Only closed bars are used. A signal never moves once drawn.      |
//| Buffers 0-9 can be read with iCustom() from an Expert Advisor.   |
//+------------------------------------------------------------------+
#property copyright   "Ali Rajput"
#property version     "1.00"
#property description "Asian range sweep signals with a built-in result scorecard (in R)."
#property indicator_chart_window
#property indicator_buffers 10
#property indicator_plots   4

#property indicator_label1  "Buy signal"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrDodgerBlue
#property indicator_width1  2
#property indicator_label2  "Sell signal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrOrangeRed
#property indicator_width2  2
#property indicator_label3  "Asian high"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSilver
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Asian low"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrSilver
#property indicator_style4  STYLE_DOT

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//|                                                                  |
//| No input groups on purpose: MQL5 counts every "input group" as   |
//| a parameter of iCustom(), which shifts all values after it. With |
//| plain inputs an EA passes them in the order listed here.         |
//+------------------------------------------------------------------+
input int             InpAsiaStartHour   = 1;          // Asian range start hour
input int             InpAsiaEndHour     = 9;          // Asian range end hour (exclusive)
input int             InpTradeStartHour  = 9;          // First hour a sweep can count
input int             InpTradeEndHour    = 18;         // No new sweeps from this hour
input int             InpDayCloseHour    = 22;         // Open signals are closed at this hour

input int             InpATRPeriod       = 14;         // ATR period
input double          InpMinSweepATR     = 0.10;       // Wick must pass the range side by this many ATR
input int             InpConfirmBars     = 4;          // Bars allowed for the confirmation close
input double          InpMinRangeATR     = 1.5;        // Skip days with a narrower Asian range (ATR multiples)
input double          InpMaxRangeATR     = 12.0;       // Skip days with a wider Asian range (ATR multiples)
input int             InpMaxSignalsDay   = 1;          // Signals allowed per day
input bool            InpUseTrend        = false;      // Keep only sweeps that agree with the trend EMA
input ENUM_TIMEFRAMES InpTrendTF         = PERIOD_H1;  // Trend timeframe
input int             InpTrendEMA        = 50;         // Trend EMA period

input double          InpSLBufferATR     = 0.20;       // Stop beyond the sweep wick (ATR multiples)
input double          InpMinSLATR        = 0.50;       // Skip signals with a closer stop (ATR multiples)
input double          InpMaxSLATR        = 4.00;       // Skip signals with a farther stop (ATR multiples)
input double          InpRewardRatio     = 2.0;        // Target as a multiple of the risk
input int             InpDaysBack        = 120;        // Days of history scored
input int             InpDrawDays        = 20;         // Days with boxes and trade lines drawn

input bool            InpShowPanel       = true;       // Show the scorecard panel
input ENUM_BASE_CORNER InpPanelCorner    = CORNER_LEFT_UPPER; // Panel corner
input color           InpBoxColor        = clrGainsboro; // Asian range box colour
input bool            InpAlertPopup      = true;       // Popup alert on a new signal
input bool            InpAlertPush       = false;      // Push notification on a new signal

//+------------------------------------------------------------------+
//| Indicator buffers                                                |
//+------------------------------------------------------------------+
double BufBuy[];                                       // 0: entry price on a buy signal bar
double BufSell[];                                      // 1: entry price on a sell signal bar
double BufHigh[];                                      // 2: locked Asian high
double BufLow[];                                       // 3: locked Asian low
double BufSL[];                                        // 4: stop of the signal on that bar
double BufTP[];                                        // 5: target of the signal on that bar
double BufScN[];                                       // 6: scorecard, closed signals (last closed bar)
double BufScWins[];                                    // 7: scorecard, winning signals
double BufScSumR[];                                    // 8: scorecard, total result in R
double BufScLossR[];                                   // 9: scorecard, sum of losing results in R (positive)

//+------------------------------------------------------------------+
//| Result record of one signal                                      |
//+------------------------------------------------------------------+
struct SignalResult
  {
   bool     isBuy;                                     // direction
   double   r;                                         // result in R after cost
   bool     open;                                      // still running
  };

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
const string PFX          = "ASS_";                    // chart object prefix
int      g_atrHandle      = INVALID_HANDLE;            // ATR on the chart timeframe
int      g_emaHandle      = INVALID_HANDLE;            // EMA on the trend timeframe
datetime g_lastBarTime    = 0;                         // last bar the scan ran on
datetime g_lastAlertTime  = 0;                         // signal bar already alerted
SignalResult g_res[];                                  // results of the scored window
int      g_daysValid      = 0;                         // days with a tradable range
int      g_breaks         = 0;                         // range sides broken by a close
int      g_sweeps         = 0;                         // sweeps seen
int      g_skipped        = 0;                         // sweeps with no confirmation or a bad stop
string   g_rows[9];                                    // last panel text, printed at the end of a test

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, BufBuy,  INDICATOR_DATA);
   SetIndexBuffer(1, BufSell, INDICATOR_DATA);
   SetIndexBuffer(2, BufHigh, INDICATOR_DATA);
   SetIndexBuffer(3, BufLow,  INDICATOR_DATA);
   SetIndexBuffer(4, BufSL,   INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, BufTP,   INDICATOR_CALCULATIONS);
   SetIndexBuffer(6, BufScN,     INDICATOR_CALCULATIONS);
   SetIndexBuffer(7, BufScWins,  INDICATOR_CALCULATIONS);
   SetIndexBuffer(8, BufScSumR,  INDICATOR_CALCULATIONS);
   SetIndexBuffer(9, BufScLossR, INDICATOR_CALCULATIONS);
   PlotIndexSetInteger(0, PLOT_ARROW, 233);
   PlotIndexSetInteger(1, PLOT_ARROW, 234);
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 12);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -12);
   for(int p = 0; p < 4; p++)
      PlotIndexSetDouble(p, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   IndicatorSetString(INDICATOR_SHORTNAME, "Asian Sweep Scorecard");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   if(InpAsiaStartHour >= InpAsiaEndHour || InpTradeStartHour >= InpTradeEndHour)
     {
      Print("Session hours must satisfy start < end inside one server day.");
      return(INIT_PARAMETERS_INCORRECT);
     }

   g_atrHandle = iATR(_Symbol, _Period, InpATRPeriod);
   if(g_atrHandle == INVALID_HANDLE)
      return(INIT_FAILED);
   if(InpUseTrend)
     {
      g_emaHandle = iMA(_Symbol, InpTrendTF, InpTrendEMA, 0, MODE_EMA, PRICE_CLOSE);
      if(g_emaHandle == INVALID_HANDLE)
         return(INIT_FAILED);
     }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   //--- in the strategy tester, leave the scorecard in the journal
   if(MQLInfoInteger(MQL_TESTER))
      for(int k = 0; k < 9; k++)
         Print(g_rows[k]);
   ObjectsDeleteAll(0, PFX);
   if(g_atrHandle != INVALID_HANDLE)
      IndicatorRelease(g_atrHandle);
   if(g_emaHandle != INVALID_HANDLE)
      IndicatorRelease(g_emaHandle);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| DayOf / HourOf                                                   |
//| Calendar helpers on server time                                  |
//+------------------------------------------------------------------+
int DayOf(const datetime t)
  {
   MqlDateTime dt;
   TimeToStruct(t, dt);
   return(dt.year * 10000 + dt.mon * 100 + dt.day);
  }

int HourOf(const datetime t)
  {
   MqlDateTime dt;
   TimeToStruct(t, dt);
   return(dt.hour);
  }

//+------------------------------------------------------------------+
//| TrendAt                                                          |
//| +1 / -1 from the last closed trend bar before time t, 0 if off,  |
//| 2 if the data is not there yet                                   |
//+------------------------------------------------------------------+
int TrendAt(const datetime t)
  {
   if(!InpUseTrend)
      return(0);
   datetime closedBar = t - PeriodSeconds(InpTrendTF);
   double   ema[1], cl[1];
   if(CopyBuffer(g_emaHandle, 0, closedBar, 1, ema) < 1 || CopyClose(_Symbol, InpTrendTF, closedBar, 1, cl) < 1)
      return(2);
   return(cl[0] > ema[0] ? 1 : -1);
  }

//+------------------------------------------------------------------+
//| DrawRect / DrawSeg / DrawText                                    |
//| Small chart object helpers                                       |
//+------------------------------------------------------------------+
void DrawRect(const string name, datetime t1, double p1, datetime t2, double p2, color c)
  {
   ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, p1, t2, p2);
   ObjectSetInteger(0, name, OBJPROP_COLOR, c);
   ObjectSetInteger(0, name, OBJPROP_FILL, true);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

void DrawSeg(const string name, datetime t1, double p, datetime t2, color c, ENUM_LINE_STYLE st)
  {
   ObjectCreate(0, name, OBJ_TREND, 0, t1, p, t2, p);
   ObjectSetInteger(0, name, OBJPROP_COLOR, c);
   ObjectSetInteger(0, name, OBJPROP_STYLE, st);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

void DrawText(const string name, datetime t, double p, const string txt, color c, ENUM_ANCHOR_POINT anchor)
  {
   ObjectCreate(0, name, OBJ_TEXT, 0, t, p);
   ObjectSetString(0, name, OBJPROP_TEXT, txt);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, name, OBJPROP_COLOR, c);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, anchor);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//| FollowSignal                                                     |
//| Walk forward from the entry bar until stop, target or day close. |
//| Returns the exit bar index, rates_total if still open.           |
//+------------------------------------------------------------------+
int FollowSignal(const int entryBar, const int rates_total, const bool isBuy,
                 const double entry, const double sl, const double tp,
                 const datetime &time[], const double &open[], const double &high[],
                 const double &low[], const double &close[], double &exitPrice)
  {
   int day = DayOf(time[entryBar]);
   for(int j = entryBar; j < rates_total - 1; j++)
     {
      //--- day close hour or a new day: out at that bar's open
      if(j > entryBar && (DayOf(time[j]) != day || HourOf(time[j]) >= InpDayCloseHour))
        {
         exitPrice = open[j];
         return(j);
        }
      bool hitSL = isBuy ? low[j] <= sl : high[j] >= sl;
      bool hitTP = isBuy ? high[j] >= tp : low[j] <= tp;
      //--- both inside one bar: count the stop, the conservative reading
      if(hitSL)
        {
         exitPrice = sl;
         return(j);
        }
      if(hitTP)
        {
         exitPrice = tp;
         return(j);
        }
     }
   exitPrice = close[rates_total - 2];
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Scan                                                             |
//| Rebuild signals, results and drawings from closed bars           |
//+------------------------------------------------------------------+
int Scan(const int rates_total, const datetime &time[], const double &open[],
         const double &high[], const double &low[], const double &close[],
         const int &spread[], const double &atr[])
  {
   ObjectsDeleteAll(0, PFX);
   ArrayResize(g_res, 0);
   g_daysValid = g_breaks = g_sweeps = g_skipped = 0;

   datetime scoreFrom = time[rates_total - 1] - InpDaysBack * 86400;
   datetime drawFrom  = time[rates_total - 1] - InpDrawDays * 86400;
   int      lastSignalBar = -1;

   //--- per-day state
   int      day = 0, signalsToday = 0, rangeBars = 0;
   double   runHi = 0.0, runLo = 0.0;
   bool     locked = false, valid = false, hiUsed = true, loUsed = true;
   datetime asiaStart = 0;

   //--- pending sweep and running signal
   int      pendDir = 0, pendBars = 0;
   double   pendTrigger = 0.0, pendExtreme = 0.0;
   int      busyUntil = -1;

   int first = 0;
   while(first < rates_total - 1 && time[first] < scoreFrom)
      first++;

   for(int i = first; i < rates_total - 1; i++)
     {
      int d = DayOf(time[i]), h = HourOf(time[i]);

      //--- new server day: reset the range
      if(d != day)
        {
         day = d;
         signalsToday = 0;
         rangeBars = 0;
         locked = valid = false;
         hiUsed = loUsed = true;
         pendDir = 0;
        }

      //--- build the Asian range
      if(h >= InpAsiaStartHour && h < InpAsiaEndHour)
        {
         if(rangeBars == 0)
           {
            runHi = high[i];
            runLo = low[i];
            asiaStart = time[i];
           }
         runHi = MathMax(runHi, high[i]);
         runLo = MathMin(runLo, low[i]);
         rangeBars++;
         continue;
        }

      //--- lock it on the first bar after the session
      if(!locked && h >= InpAsiaEndHour)
        {
         locked = true;
         double a = (i > 0) ? atr[i - 1] : 0.0;
         valid = (rangeBars >= 4 && a > 0.0 && runHi - runLo >= InpMinRangeATR * a && runHi - runLo <= InpMaxRangeATR * a);
         hiUsed = loUsed = !valid;
         if(valid)
           {
            g_daysValid++;
            if(time[i] >= drawFrom)
               DrawRect(PFX + "box" + (string)(long)asiaStart, asiaStart, runHi, time[i], runLo, InpBoxColor);
           }
        }
      if(valid && h < InpDayCloseHour)
        {
         BufHigh[i] = runHi;
         BufLow[i]  = runLo;
        }
      if(!valid || i <= busyUntil)
         continue;

      //--- a sweep is waiting: confirm it, drop it, or keep waiting
      if(pendDir != 0)
        {
         pendBars++;
         bool failed = (pendDir == 1) ? close[i] < pendExtreme : close[i] > pendExtreme;
         if(pendBars > InpConfirmBars || failed || h >= InpTradeEndHour)
           {
            pendDir = 0;
            g_skipped++;
            continue;
           }
         bool confirmed = (pendDir == 1) ? close[i] > pendTrigger : close[i] < pendTrigger;
         if(!confirmed)
            continue;

         bool   isBuy = (pendDir == 1);
         double a     = atr[i];
         double entry = open[i + 1];
         double sl    = isBuy ? pendExtreme - InpSLBufferATR * a : pendExtreme + InpSLBufferATR * a;
         double risk  = isBuy ? entry - sl : sl - entry;
         pendDir = 0;
         if(a <= 0.0 || risk < InpMinSLATR * a || risk > InpMaxSLATR * a)
           {
            g_skipped++;
            continue;
           }
         double tp = isBuy ? entry + InpRewardRatio * risk : entry - InpRewardRatio * risk;

         //--- signal on the confirmation bar, readable by an EA at shift 1
         if(isBuy)
            BufBuy[i] = entry;
         else
            BufSell[i] = entry;
         BufSL[i] = sl;
         BufTP[i] = tp;
         signalsToday++;
         lastSignalBar = i;

         //--- follow it to the exit and score it in R, spread charged
         double exitPrice = 0.0;
         int    exitBar   = FollowSignal(i + 1, rates_total, isBuy, entry, sl, tp, time, open, high, low, close, exitPrice);
         double cost      = spread[i] * _Point;
         double r         = ((isBuy ? exitPrice - entry : entry - exitPrice) - cost) / risk;
         int    n         = ArraySize(g_res);
         ArrayResize(g_res, n + 1);
         g_res[n].isBuy = isBuy;
         g_res[n].r     = r;
         g_res[n].open  = (exitBar >= rates_total);
         busyUntil      = MathMin(exitBar, rates_total - 1);

         if(time[i] >= drawFrom)
           {
            datetime tEnd = time[MathMin(exitBar, rates_total - 1)];
            string   id   = PFX + (string)(long)time[i];
            DrawSeg(id + "_sl", time[i + 1], sl, tEnd, clrOrangeRed, STYLE_DOT);
            DrawSeg(id + "_tp", time[i + 1], tp, tEnd, clrSeaGreen, STYLE_DOT);
            DrawSeg(id + "_en", time[i + 1], entry, tEnd, clrGray, STYLE_SOLID);
            string txt = g_res[n].open ? "open" : StringFormat("%+.2fR", r);
            DrawText(id + "_r", tEnd, isBuy ? tp : sl, txt, r > 0.0 ? clrSeaGreen : clrOrangeRed, ANCHOR_LEFT_LOWER);
           }
         continue;
        }

      //--- look for a sweep of either side inside the trade window
      if(h < InpTradeStartHour || h >= InpTradeEndHour || signalsToday >= InpMaxSignalsDay)
         continue;
      double a = atr[i];
      if(a <= 0.0)
         continue;
      if(!hiUsed)
        {
         if(high[i] > runHi + InpMinSweepATR * a && close[i] < runHi)
           {
            hiUsed = true;
            g_sweeps++;
            int tr = TrendAt(time[i] + PeriodSeconds(_Period));
            if(tr == 0 || tr == -1)
              {
               pendDir = -1;
               pendTrigger = low[i];
               pendExtreme = high[i];
               pendBars = 0;
               continue;
              }
           }
         else
            if(close[i] > runHi)
              {
               hiUsed = true;
               g_breaks++;
              }
        }
      if(!loUsed)
        {
         if(low[i] < runLo - InpMinSweepATR * a && close[i] > runLo)
           {
            loUsed = true;
            g_sweeps++;
            int tr = TrendAt(time[i] + PeriodSeconds(_Period));
            if(tr == 0 || tr == 1)
              {
               pendDir = 1;
               pendTrigger = high[i];
               pendExtreme = low[i];
               pendBars = 0;
              }
           }
         else
            if(close[i] < runLo)
              {
               loUsed = true;
               g_breaks++;
              }
        }
     }
   return(lastSignalBar);
  }

//+------------------------------------------------------------------+
//| StatLine                                                         |
//| One row of the scorecard for buys (1), sells (-1) or all (0)     |
//+------------------------------------------------------------------+
string StatLine(const string label, const int dir)
  {
   int    n = 0, wins = 0;
   double sum = 0.0, gp = 0.0, gl = 0.0;
   for(int k = 0; k < ArraySize(g_res); k++)
     {
      if(g_res[k].open || (dir == 1 && !g_res[k].isBuy) || (dir == -1 && g_res[k].isBuy))
         continue;
      n++;
      sum += g_res[k].r;
      if(g_res[k].r > 0.0)
        {
         wins++;
         gp += g_res[k].r;
        }
      else
         gl -= g_res[k].r;
     }
   if(n == 0)
      return(StringFormat("%-6s no closed signals", label));
   string pf = (gl > 0.0) ? StringFormat("%.2f", gp / gl) : "n/a";
   return(StringFormat("%-6s %3d  win %5.1f%%  PF %s  avg %+.2fR  total %+.1fR",
                       label, n, 100.0 * wins / n, pf, sum / n, sum));
  }

//+------------------------------------------------------------------+
//| DrawPanel                                                        |
//| Scorecard in a chart corner, colours taken from the chart        |
//+------------------------------------------------------------------+
void DrawPanel()
  {
   string rows[9];
   rows[0] = StringFormat("Asian Sweep Scorecard  %s %s, last %d days", _Symbol, StringSubstr(EnumToString(_Period), 7), InpDaysBack);
   rows[1] = StringFormat("Valid ranges %d   side breaks %d   sweeps %d", g_daysValid, g_breaks, g_sweeps);
   int open = 0;
   for(int k = 0; k < ArraySize(g_res); k++)
      if(g_res[k].open)
         open++;
   rows[2] = StringFormat("Signals %d   skipped sweeps %d   open now %d", ArraySize(g_res), g_skipped, open);
   rows[3] = StatLine("All", 0);
   rows[4] = StatLine("Buys", 1);
   rows[5] = StatLine("Sells", -1);
   rows[6] = StringFormat("Target %.1fR, stop %.2f ATR past wick, exit %02d:00", InpRewardRatio, InpSLBufferATR, InpDayCloseHour);
   rows[7] = "Spread charged. Stop counted first if both hit.";
   rows[8] = "Past signals only, not a forecast.";
   ArrayCopy(g_rows, rows);
   if(!InpShowPanel)
      return;

   color bg = (color)ChartGetInteger(0, CHART_COLOR_BACKGROUND);
   color fg = (color)ChartGetInteger(0, CHART_COLOR_FOREGROUND);
   bool  top = (InpPanelCorner == CORNER_LEFT_UPPER || InpPanelCorner == CORNER_RIGHT_UPPER);
   //--- size the box from the longest row, so it fits at any screen scaling
   int maxW = 0, maxH = 0;
   TextSetFont("Consolas", -90);
   for(int k = 0; k < 9; k++)
     {
      uint tw = 0, th = 0;
      TextGetSize(rows[k], tw, th);
      maxW = MathMax(maxW, (int)tw);
      maxH = MathMax(maxH, (int)th);
     }
   int   rowH = MathMax(16, maxH + 3), w = maxW + 20, hgt = 9 * rowH + 12;

   string bgName = PFX + "panel_bg";
   ObjectCreate(0, bgName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, bgName, OBJPROP_CORNER, InpPanelCorner);
   ObjectSetInteger(0, bgName, OBJPROP_XDISTANCE, (InpPanelCorner == CORNER_LEFT_UPPER || InpPanelCorner == CORNER_LEFT_LOWER) ? 8 : 8 + w);
   ObjectSetInteger(0, bgName, OBJPROP_YDISTANCE, top ? 20 : 20 + hgt);
   ObjectSetInteger(0, bgName, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, bgName, OBJPROP_YSIZE, hgt);
   ObjectSetInteger(0, bgName, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, bgName, OBJPROP_COLOR, fg);
   ObjectSetInteger(0, bgName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, bgName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, bgName, OBJPROP_HIDDEN, true);

   for(int k = 0; k < 9; k++)
     {
      string nm = PFX + "panel_" + (string)k;
      ObjectCreate(0, nm, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, nm, OBJPROP_CORNER, InpPanelCorner);
      ObjectSetInteger(0, nm, OBJPROP_ANCHOR, top ? ANCHOR_LEFT_UPPER : ANCHOR_LEFT_LOWER);
      ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, (InpPanelCorner == CORNER_LEFT_UPPER || InpPanelCorner == CORNER_LEFT_LOWER) ? 16 : w - 8);
      ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, top ? 26 + k * rowH : 26 + (8 - k) * rowH);
      ObjectSetString(0, nm, OBJPROP_TEXT, rows[k]);
      ObjectSetString(0, nm, OBJPROP_FONT, "Consolas");
      ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, 9);
      ObjectSetInteger(0, nm, OBJPROP_COLOR, fg);
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
   if(rates_total < InpATRPeriod + 10)
      return(0);

   //--- everything depends on closed bars only: work once per new bar
   if(prev_calculated > 0 && time[rates_total - 1] == g_lastBarTime)
      return(rates_total);

   if(BarsCalculated(g_atrHandle) < rates_total)
      return(0);
   if(InpUseTrend && BarsCalculated(g_emaHandle) <= 0)
      return(0);

   double atr[];
   if(CopyBuffer(g_atrHandle, 0, 0, rates_total, atr) < rates_total)
      return(0);

   ArrayInitialize(BufBuy, EMPTY_VALUE);
   ArrayInitialize(BufSell, EMPTY_VALUE);
   ArrayInitialize(BufHigh, EMPTY_VALUE);
   ArrayInitialize(BufLow, EMPTY_VALUE);
   ArrayInitialize(BufSL, EMPTY_VALUE);
   ArrayInitialize(BufTP, EMPTY_VALUE);
   ArrayInitialize(BufScN, EMPTY_VALUE);
   ArrayInitialize(BufScWins, EMPTY_VALUE);
   ArrayInitialize(BufScSumR, EMPTY_VALUE);
   ArrayInitialize(BufScLossR, EMPTY_VALUE);

   int lastSignal = Scan(rates_total, time, open, high, low, close, spread, atr);

   //--- scorecard totals on the last closed bar, for an EA to read at shift 1
   int    n = 0, wins = 0;
   double sumR = 0.0, lossR = 0.0;
   for(int k = 0; k < ArraySize(g_res); k++)
     {
      if(g_res[k].open)
         continue;
      n++;
      sumR += g_res[k].r;
      if(g_res[k].r > 0.0)
         wins++;
      else
         lossR -= g_res[k].r;
     }
   BufScN[rates_total - 2]     = n;
   BufScWins[rates_total - 2]  = wins;
   BufScSumR[rates_total - 2]  = sumR;
   BufScLossR[rates_total - 2] = lossR;
   DrawPanel();
   ChartRedraw();

   //--- alert once, only for a signal on the bar that just closed
   bool firstRun = (g_lastBarTime == 0);
   g_lastBarTime = time[rates_total - 1];
   if(!firstRun && lastSignal == rates_total - 2 && time[lastSignal] != g_lastAlertTime)
     {
      g_lastAlertTime = time[lastSignal];
      bool   isBuy = (BufBuy[lastSignal] != EMPTY_VALUE);
      string msg   = StringFormat("%s %s: Asian sweep %s signal, SL %s, TP %s", _Symbol,
                                  StringSubstr(EnumToString(_Period), 7), isBuy ? "BUY" : "SELL",
                                  DoubleToString(BufSL[lastSignal], _Digits), DoubleToString(BufTP[lastSignal], _Digits));
      if(InpAlertPopup)
         Alert(msg);
      if(InpAlertPush)
         SendNotification(msg);
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
