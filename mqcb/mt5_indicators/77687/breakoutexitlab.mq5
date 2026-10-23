//+------------------------------------------------------------------+
//|                                             BreakoutExitLab.mq5  |
//|                                                      Ali Rajput  |
//|                                                                  |
//| Donchian (Turtle) breakouts with three exits scored side by side.|
//|                                                                  |
//| Entry: a closed bar closes beyond the highest high (lowest low)  |
//| of the previous N bars, and the bar before it did not. The trade |
//| starts at the next bar's open with a stop a multiple of ATR away.|
//|                                                                  |
//| Every entry is then followed with three different exits:        |
//|   A. ATR trail: the stop trails the best price by k x ATR        |
//|   B. Turtle exit: the stop follows the M-bar opposite channel    |
//|   C. Fixed target: a take profit at a fixed R multiple           |
//| Results are in R (1R = entry to initial stop), the entry bar's   |
//| spread is charged, and the stop counts first when a bar touches  |
//| both levels. The panel shows the three exits next to each other. |
//|                                                                  |
//| Only closed bars are used. A signal never moves once drawn.      |
//| Buffers 0-9 can be read with iCustom() from an Expert Advisor.   |
//+------------------------------------------------------------------+
#property copyright   "Ali Rajput"
#property version     "1.00"
#property description "Donchian breakouts with ATR trail, Turtle channel exit and fixed target scored side by side (in R)."
#property indicator_chart_window
#property indicator_buffers 10
#property indicator_plots   5

#property indicator_label1  "Breakout buy"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrDodgerBlue
#property indicator_width1  2
#property indicator_label2  "Breakout sell"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrOrangeRed
#property indicator_width2  2
#property indicator_label3  "Upper channel"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSilver
#property indicator_label4  "Lower channel"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrSilver
#property indicator_label5  "Trailing stop"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrDarkOrange
#property indicator_style5  STYLE_DOT

//+------------------------------------------------------------------+
//| Exit used for drawing and for the scorecard buffers              |
//+------------------------------------------------------------------+
enum ENUM_EXIT_MODE
  {
   EXIT_ATR_TRAIL = 0,                                 // A. ATR trail
   EXIT_CHANNEL   = 1,                                 // B. Turtle exit channel
   EXIT_FIXED     = 2                                  // C. Fixed target
  };

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//|                                                                  |
//| No input groups on purpose: MQL5 counts every "input group" as   |
//| a parameter of iCustom(), which shifts all values after it.      |
//+------------------------------------------------------------------+
input int             InpEntryBars       = 20;         // Entry channel, bars (Turtle System 1 = 20)
input int             InpExitBars        = 10;         // Exit channel for exit B, bars (System 1 = 10)
input int             InpATRPeriod       = 20;         // ATR period (the Turtles' N)
input double          InpStopATR         = 2.0;        // Initial stop, ATR multiples
input double          InpTrailATR        = 3.0;        // Exit A: trail distance, ATR multiples
input double          InpTargetR         = 2.0;        // Exit C: take profit, R multiples
input bool            InpUseTrend        = false;      // Keep only breakouts on the side of the trend EMA
input int             InpTrendEMA        = 200;        // Trend EMA period (chart timeframe)
input ENUM_EXIT_MODE  InpDrawExit        = EXIT_ATR_TRAIL; // Exit drawn on the chart and sent to buffers 6-9
input int             InpDaysBack        = 365;        // Days of history scored
input int             InpDrawDays        = 60;         // Days with trade lines drawn
input bool            InpShowPanel       = true;       // Show the scorecard panel
input ENUM_BASE_CORNER InpPanelCorner    = CORNER_LEFT_UPPER; // Panel corner
input bool            InpAlertPopup      = true;       // Popup alert on a new breakout
input bool            InpAlertPush       = false;      // Push notification on a new breakout

//+------------------------------------------------------------------+
//| Indicator buffers                                                |
//+------------------------------------------------------------------+
double BufBuy[];                                       // 0: planned entry on a buy breakout bar
double BufSell[];                                      // 1: planned entry on a sell breakout bar
double BufUpper[];                                     // 2: entry channel high
double BufLower[];                                     // 3: entry channel low
double BufTrail[];                                     // 4: stop of the latest trade under the drawn exit
double BufStop[];                                      // 5: initial stop on the breakout bar
double BufScN[];                                       // 6: scorecard (drawn exit), closed trades
double BufScWins[];                                    // 7: scorecard, winning trades
double BufScSumR[];                                    // 8: scorecard, total result in R
double BufScLossR[];                                   // 9: scorecard, sum of losing results in R (positive)

//+------------------------------------------------------------------+
//| One breakout and its result under the three exits                |
//+------------------------------------------------------------------+
struct Breakout
  {
   int      bar;                                       // breakout (signal) bar
   bool     isBuy;                                     // direction
   double   entry;                                     // next bar's open
   double   risk;                                      // entry to initial stop
   double   r[3];                                      // result in R for exits A, B, C
   bool     open[3];                                   // still running under that exit
   int      exitBar[3];                                // bar of the exit, -1 if open
  };

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
const string PFX          = "BEL_";                    // chart object prefix
int      g_atrHandle      = INVALID_HANDLE;            // ATR on the chart timeframe
int      g_emaHandle      = INVALID_HANDLE;            // trend EMA
datetime g_lastBarTime    = 0;                         // last bar the scan ran on
datetime g_lastAlertTime  = 0;                         // breakout already alerted
Breakout g_bo[];                                       // breakouts in the scored window
string   g_rows[10];                                   // last panel text

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, BufBuy,     INDICATOR_DATA);
   SetIndexBuffer(1, BufSell,    INDICATOR_DATA);
   SetIndexBuffer(2, BufUpper,   INDICATOR_DATA);
   SetIndexBuffer(3, BufLower,   INDICATOR_DATA);
   SetIndexBuffer(4, BufTrail,   INDICATOR_DATA);
   SetIndexBuffer(5, BufStop,    INDICATOR_CALCULATIONS);
   SetIndexBuffer(6, BufScN,     INDICATOR_CALCULATIONS);
   SetIndexBuffer(7, BufScWins,  INDICATOR_CALCULATIONS);
   SetIndexBuffer(8, BufScSumR,  INDICATOR_CALCULATIONS);
   SetIndexBuffer(9, BufScLossR, INDICATOR_CALCULATIONS);
   PlotIndexSetInteger(0, PLOT_ARROW, 233);
   PlotIndexSetInteger(1, PLOT_ARROW, 234);
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 14);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -14);
   for(int p = 0; p < 5; p++)
      PlotIndexSetDouble(p, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   IndicatorSetString(INDICATOR_SHORTNAME, "Breakout Exit Lab");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   if(InpEntryBars < 2 || InpExitBars < 2 || InpATRPeriod < 1)
      return(INIT_PARAMETERS_INCORRECT);
   g_atrHandle = iATR(_Symbol, _Period, InpATRPeriod);
   if(g_atrHandle == INVALID_HANDLE)
      return(INIT_FAILED);
   if(InpUseTrend)
     {
      g_emaHandle = iMA(_Symbol, _Period, InpTrendEMA, 0, MODE_EMA, PRICE_CLOSE);
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
   ObjectsDeleteAll(0, PFX);
   if(g_atrHandle != INVALID_HANDLE)
      IndicatorRelease(g_atrHandle);
   if(g_emaHandle != INVALID_HANDLE)
      IndicatorRelease(g_emaHandle);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| ChannelHigh / ChannelLow                                         |
//| Extreme of the n bars that end at bar 'last' (inclusive)         |
//+------------------------------------------------------------------+
double ChannelHigh(const double &high[], const int last, const int n)
  {
   double v = high[last];
   for(int k = last - n + 1; k < last; k++)
      v = MathMax(v, high[k]);
   return(v);
  }

double ChannelLow(const double &low[], const int last, const int n)
  {
   double v = low[last];
   for(int k = last - n + 1; k < last; k++)
      v = MathMin(v, low[k]);
   return(v);
  }

//+------------------------------------------------------------------+
//| RunExit                                                          |
//| Follow one breakout under one exit, fill r/open/exitBar, and     |
//| optionally the stop line of that trade into BufTrail             |
//+------------------------------------------------------------------+
void RunExit(Breakout &b, const int mode, const int rates_total, const double &open[], const double &high[],
             const double &low[], const double &close[], const double &atr[], const double cost, const bool drawLine)
  {
   bool   buy   = b.isBuy;
   double stop  = buy ? b.entry - b.risk : b.entry + b.risk;
   double tp    = buy ? b.entry + InpTargetR * b.risk : b.entry - InpTargetR * b.risk;
   double best  = b.entry;
   b.open[mode]    = true;
   b.exitBar[mode] = -1;

   for(int k = b.bar + 1; k < rates_total - 1; k++)
     {
      if(drawLine)
         BufTrail[k] = stop;

      //--- stop first: a gap through it fills at the open
      if(buy ? low[k] <= stop : high[k] >= stop)
        {
         double fill = buy ? MathMin(stop, open[k]) : MathMax(stop, open[k]);
         b.r[mode] = ((buy ? fill - b.entry : b.entry - fill) - cost) / b.risk;
         b.open[mode] = false;
         b.exitBar[mode] = k;
         return;
        }
      if(mode == EXIT_FIXED && (buy ? high[k] >= tp : low[k] <= tp))
        {
         double fill = buy ? MathMax(tp, open[k]) : MathMin(tp, open[k]);
         b.r[mode] = ((buy ? fill - b.entry : b.entry - fill) - cost) / b.risk;
         b.open[mode] = false;
         b.exitBar[mode] = k;
         return;
        }

      //--- move the stop at the close, never backwards
      best = buy ? MathMax(best, high[k]) : MathMin(best, low[k]);
      if(mode == EXIT_ATR_TRAIL && atr[k] > 0.0)
         stop = buy ? MathMax(stop, best - InpTrailATR * atr[k]) : MathMin(stop, best + InpTrailATR * atr[k]);
      if(mode == EXIT_CHANNEL && k >= InpExitBars)
         stop = buy ? MathMax(stop, ChannelLow(low, k, InpExitBars)) : MathMin(stop, ChannelHigh(high, k, InpExitBars));
     }

   //--- still open: mark it to the last close
   b.r[mode] = ((buy ? close[rates_total - 2] - b.entry : b.entry - close[rates_total - 2]) - cost) / b.risk;
  }

//+------------------------------------------------------------------+
//| ExitStats                                                        |
//| One panel row for one exit over the closed trades                |
//+------------------------------------------------------------------+
string ExitStats(const string label, const int mode, int &n, int &wins, double &sum, double &lossR)
  {
   n = 0;
   wins = 0;
   sum = 0.0;
   lossR = 0.0;
   double gp = 0.0;
   for(int i = 0; i < ArraySize(g_bo); i++)
     {
      if(g_bo[i].open[mode])
         continue;
      double r = g_bo[i].r[mode];
      n++;
      sum += r;
      if(r > 0.0)
        {
         wins++;
         gp += r;
        }
      else
         lossR -= r;
     }
   if(n == 0)
      return(StringFormat("%-11s no closed trades", label));
   string pf = (lossR > 0.0) ? StringFormat("%.2f", gp / lossR) : "n/a";
   //--- chart labels hold at most 63 characters, so the row stays short
   return(StringFormat("%-11s %3d  win %4.1f%%  PF %s  avg %+.2fR  sum %+.1fR",
                       label, n, 100.0 * wins / n, pf, sum / n, sum));
  }

//+------------------------------------------------------------------+
//| DrawTrade                                                        |
//| Entry and exit segment with the result, for the drawn exit       |
//+------------------------------------------------------------------+
void DrawTrade(const Breakout &b, const int rates_total, const datetime &time[])
  {
   int    m    = (int)InpDrawExit;
   int    eb   = (b.exitBar[m] >= 0) ? b.exitBar[m] : rates_total - 1;
   string id   = PFX + (string)(long)time[b.bar];
   ObjectCreate(0, id, OBJ_TREND, 0, time[b.bar + 1], b.entry, time[eb], b.entry);
   ObjectSetInteger(0, id, OBJPROP_COLOR, clrGray);
   ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, id, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, id, OBJPROP_HIDDEN, true);

   string txt = b.open[m] ? StringFormat("open %+.1fR", b.r[m]) : StringFormat("%+.1fR", b.r[m]);
   string lb  = id + "_r";
   ObjectCreate(0, lb, OBJ_TEXT, 0, time[eb], b.entry);
   ObjectSetString(0, lb, OBJPROP_TEXT, txt);
   ObjectSetString(0, lb, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, lb, OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, lb, OBJPROP_COLOR, b.r[m] > 0.0 ? clrSeaGreen : clrOrangeRed);
   ObjectSetInteger(0, lb, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
   ObjectSetInteger(0, lb, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, lb, OBJPROP_HIDDEN, true);
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
   int need = MathMax(InpEntryBars, InpExitBars) + InpATRPeriod + 5;
   if(rates_total < need)
      return(0);

   //--- everything depends on closed bars only: work once per new bar
   if(prev_calculated > 0 && time[rates_total - 1] == g_lastBarTime)
      return(rates_total);
   if(BarsCalculated(g_atrHandle) < rates_total)
      return(0);
   if(InpUseTrend && BarsCalculated(g_emaHandle) < rates_total)
      return(0);

   double atr[], ema[];
   if(CopyBuffer(g_atrHandle, 0, 0, rates_total, atr) < rates_total)
      return(0);
   if(InpUseTrend && CopyBuffer(g_emaHandle, 0, 0, rates_total, ema) < rates_total)
      return(0);

   bool firstRun = (g_lastBarTime == 0);
   g_lastBarTime = time[rates_total - 1];

   ArrayInitialize(BufBuy, EMPTY_VALUE);
   ArrayInitialize(BufSell, EMPTY_VALUE);
   ArrayInitialize(BufUpper, EMPTY_VALUE);
   ArrayInitialize(BufLower, EMPTY_VALUE);
   ArrayInitialize(BufTrail, EMPTY_VALUE);
   ArrayInitialize(BufStop, EMPTY_VALUE);
   ArrayInitialize(BufScN, EMPTY_VALUE);
   ArrayInitialize(BufScWins, EMPTY_VALUE);
   ArrayInitialize(BufScSumR, EMPTY_VALUE);
   ArrayInitialize(BufScLossR, EMPTY_VALUE);
   ObjectsDeleteAll(0, PFX);
   ArrayResize(g_bo, 0);

   datetime scoreFrom = time[rates_total - 1] - InpDaysBack * 86400;
   datetime drawFrom  = time[rates_total - 1] - InpDrawDays * 86400;
   int      lastSignal = -1, lastDrawn = -1;

   //--- channels of the previous N bars, and fresh breakouts on closed bars
   for(int i = InpEntryBars + 1; i < rates_total - 1; i++)
     {
      double up = ChannelHigh(high, i - 1, InpEntryBars);
      double dn = ChannelLow(low, i - 1, InpEntryBars);
      BufUpper[i] = up;
      BufLower[i] = dn;
      if(atr[i] <= 0.0)
         continue;

      double upPrev = ChannelHigh(high, i - 2, InpEntryBars);
      double dnPrev = ChannelLow(low, i - 2, InpEntryBars);
      bool   buy    = close[i] > up && close[i - 1] <= upPrev;
      bool   sell   = close[i] < dn && close[i - 1] >= dnPrev;
      if(!buy && !sell)
         continue;
      if(InpUseTrend && ((buy && close[i] < ema[i]) || (sell && close[i] > ema[i])))
         continue;

      //--- arrows on the whole history, so no signal ever disappears
      double riskAll = InpStopATR * atr[i];
      if(buy)
         BufBuy[i] = open[i + 1];
      else
         BufSell[i] = open[i + 1];
      BufStop[i] = buy ? open[i + 1] - riskAll : open[i + 1] + riskAll;
      lastSignal = i;
      if(time[i] < scoreFrom)
         continue;

      int n = ArraySize(g_bo);
      ArrayResize(g_bo, n + 1);
      g_bo[n].bar   = i;
      g_bo[n].isBuy = buy;
      g_bo[n].entry = open[i + 1];
      g_bo[n].risk  = InpStopATR * atr[i];
      double cost   = spread[i] * _Point;
      for(int m = 0; m < 3; m++)
         RunExit(g_bo[n], m, rates_total, open, high, low, close, atr, cost, false);

      if(time[i] >= drawFrom)
        {
         DrawTrade(g_bo[n], rates_total, time);
         lastDrawn = n;
        }
     }

   //--- stop line of the latest drawn trade, so the chart is not a tangle
   if(lastDrawn >= 0)
      RunExit(g_bo[lastDrawn], (int)InpDrawExit, rates_total, open, high, low, close, atr,
              spread[g_bo[lastDrawn].bar] * _Point, true);

   //--- panel rows and scorecard buffers
   int    nA, wA, nB, wB, nC, wC;
   double sA, lA, sB, lB, sC, lC;
   int    opens = 0;
   for(int i = 0; i < ArraySize(g_bo); i++)
      if(g_bo[i].open[(int)InpDrawExit])
         opens++;
   g_rows[0] = StringFormat("Breakout Exit Lab  %s %s, last %d days", _Symbol, StringSubstr(EnumToString(_Period), 7), InpDaysBack);
   g_rows[1] = StringFormat("Entry: close beyond %d-bar channel, stop %.1f ATR(%d)", InpEntryBars, InpStopATR, InpATRPeriod);
   int longs = 0;
   for(int i = 0; i < ArraySize(g_bo); i++)
      if(g_bo[i].isBuy)
         longs++;
   g_rows[2] = StringFormat("Breakouts %d (long %d, short %d)   open now %d", ArraySize(g_bo), longs, ArraySize(g_bo) - longs, opens);
   g_rows[3] = StringFormat("Same entries, 3 exits: A ATR trail, B %d-bar channel, C target", InpExitBars);
   g_rows[4] = ExitStats(StringFormat("A trail %.1f", InpTrailATR), EXIT_ATR_TRAIL, nA, wA, sA, lA);
   g_rows[5] = ExitStats(StringFormat("B chan %d", InpExitBars), EXIT_CHANNEL, nB, wB, sB, lB);
   g_rows[6] = ExitStats(StringFormat("C tgt %.1fR", InpTargetR), EXIT_FIXED, nC, wC, sC, lC);
   int    dm = (int)InpDrawExit, ln = 0, sn2 = 0;
   double lr = 0.0, sr = 0.0;
   for(int i = 0; i < ArraySize(g_bo); i++)
     {
      if(g_bo[i].open[dm])
         continue;
      if(g_bo[i].isBuy)
        {
         ln++;
         lr += g_bo[i].r[dm];
        }
      else
        {
         sn2++;
         sr += g_bo[i].r[dm];
        }
     }
   g_rows[7] = StringFormat("Exit %s (drawn): longs %d sum %+.1fR, shorts %d sum %+.1fR",
                            dm == EXIT_ATR_TRAIL ? "A" : (dm == EXIT_CHANNEL ? "B" : "C"), ln, lr, sn2, sr);
   g_rows[8] = "Spread charged. Stop counted first if both hit.";
   g_rows[9] = "Past signals only, not a forecast.";

   int    sn = (InpDrawExit == EXIT_ATR_TRAIL) ? nA : (InpDrawExit == EXIT_CHANNEL ? nB : nC);
   int    sw = (InpDrawExit == EXIT_ATR_TRAIL) ? wA : (InpDrawExit == EXIT_CHANNEL ? wB : wC);
   double ss = (InpDrawExit == EXIT_ATR_TRAIL) ? sA : (InpDrawExit == EXIT_CHANNEL ? sB : sC);
   double sl = (InpDrawExit == EXIT_ATR_TRAIL) ? lA : (InpDrawExit == EXIT_CHANNEL ? lB : lC);
   BufScN[rates_total - 2]     = sn;
   BufScWins[rates_total - 2]  = sw;
   BufScSumR[rates_total - 2]  = ss;
   BufScLossR[rates_total - 2] = sl;

   DrawPanel();
   ChartRedraw();

   //--- alert once, only for a breakout on the bar that just closed
   if(!firstRun && lastSignal == rates_total - 2 && time[lastSignal] != g_lastAlertTime)
     {
      g_lastAlertTime = time[lastSignal];
      bool   isBuy = (BufBuy[lastSignal] != EMPTY_VALUE);
      string msg   = StringFormat("%s %s: %d-bar breakout %s, stop %s", _Symbol, StringSubstr(EnumToString(_Period), 7),
                                  InpEntryBars, isBuy ? "BUY" : "SELL", DoubleToString(BufStop[lastSignal], _Digits));
      if(InpAlertPopup)
         Alert(msg);
      if(InpAlertPush)
         SendNotification(msg);
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
