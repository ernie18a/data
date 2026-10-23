//+------------------------------------------------------------------+
//|                                        ICT_StructureVisualizer.mq5|
//|            Liquidity sweep -> MSS -> FVG, drawn on the chart      |
//+------------------------------------------------------------------+
//| Signals-only indicator. No trading, no OrderSend, no DLL.         |
//|                                                                  |
//| What it draws, always on the bar where it was detected:           |
//|   - liquidity pools: previous day high/low, Asia high/low         |
//|   - liquidity sweep: pool taken, candle closes back inside        |
//|   - MSS: opposite structure broken by a displacement candle       |
//|   - FVG left by the displacement, as a rectangle                  |
//|   - entry arrow at the FVG, with status WATCHING / CONFIRMED      |
//|                                                                  |
//| Non-repainting by construction: every object is created from      |
//| CLOSED bars only and is never moved or deleted afterwards.        |
//| Recommended chart: M5 or M15.                                     |
//|                                                                  |
//| v1.01 - FVG boxes drawn as a soft tint of the chart background    |
//|         (InpFVGOpacity, 0 = outline only) so candles stay visible;|
//|         optional signal log (InpLogSignals) to verify that no     |
//|         signal is ever repainted. Text labels on every element    |
//|         (PDH/PDL/Asia H/Asia L, Sweep, MSS, FVG): InpShowLabels.  |
//| v1.10 - trade plan on every confirmed setup (entry / SL / TP and  |
//|         lot size for your risk %), honest statistics panel of the |
//|         setups on the current chart, push / e-mail alerts.        |
//| v1.20 - volume context from the broker's tick data: relative      |
//|         volume and tick delta at every sweep, optional volume     |
//|         filter for sweeps, previous-day POC (volume profile).     |
//|         NOTE: CFD brokers give TICK volume, not exchange          |
//|         contracts - shown as such, never as real order flow.     |
//| v1.21 - proof tools: export of every setup and its outcome to CSV |
//|         (InpExportCSV) and automatic chart screenshots in visual  |
//|         testing / live (InpShots) for documentation.              |
//| v1.22 - CSV is written right after the history is calculated and  |
//|         updated on every new outcome (works on a normal chart;    |
//|         no Strategy Tester needed - raise InpHistoryBars).        |
//| v1.23 - fix: a plan is created only if the SL is on the correct   |
//|         side of the entry and the risk is larger than 3x spread.  |
//| v1.24 - panel drawn as a box with its own background: readable on |
//|         any colour scheme, can be moved to any chart corner       |
//|         (InpPanelCorner), font size InpPanelFont.                 |
//+------------------------------------------------------------------+
#property copyright "Cristian Ciunae"
#property link      "https://www.mql5.com/en/users/ciunae"
#property version   "1.24"
#property description "ICT structure visualizer: liquidity sweep -> market structure shift -> FVG. Analysis only."
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

//--- plot: buy signal
#property indicator_label1  "Buy setup"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrDodgerBlue
#property indicator_width1  2
//--- plot: sell signal
#property indicator_label2  "Sell setup"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrOrangeRed
#property indicator_width2  2

//==========================================================================
// INPUTS
//==========================================================================
input group "=== Liquidity pools ==="
input bool   InpUsePDHL      = true;        // Previous day high / low
input bool   InpUseAsia      = true;        // Asia session high / low
input int    InpAsiaStart    = 1;           // Asia session start hour (server)
input int    InpAsiaEnd      = 8;           // Asia session end hour (server)

input group "=== Sweep and structure ==="
input int    InpSwingLen     = 3;           // Swing length (bars each side)
input int    InpMaxBarsToMSS = 24;          // Max bars from sweep to structure shift
input double InpDisplaceATR  = 1.0;         // Displacement candle >= x ATR
input int    InpATRPeriod    = 14;          // ATR period

input group "=== Display ==="
input bool   InpShowPools    = true;        // Draw pool lines
input int    InpPoolDays     = 3;           // Draw pool lines only for the last N days (0 = all)
input bool   InpSweepLabels  = false;       // Text on every sweep (off = only confirmed setups get text)
input bool   InpShowFVG      = true;        // Draw FVG rectangles
input int    InpFVGOpacity   = 25;          // FVG fill strength % (0 = outline only)
input bool   InpShowLabels   = true;        // Text labels on lines and zones (PDH, Asia H, FVG...)
input bool   InpShowPanel    = true;        // Status panel
input ENUM_BASE_CORNER InpPanelCorner = CORNER_LEFT_UPPER; // Panel position (chart corner)
input int    InpPanelFont    = 8;           // Panel font size
input bool   InpAlerts       = false;       // Popup alert on confirmed setup
input bool   InpPush         = false;       // Push notification to phone on confirmed setup
input bool   InpEmail        = false;       // E-mail on confirmed setup
input color  InpPoolColor    = clrGray;
input color  InpBuyColor     = clrDodgerBlue;
input color  InpSellColor    = clrOrangeRed;
input int    InpHistoryBars  = 3000;        // Bars to process
input bool   InpLogSignals   = false;       // Log signals to a CSV in MQL5/Files (repaint check)

input group "=== Volume context (broker tick volume) ==="
input bool   InpShowVolume   = true;        // Relative volume and tick delta at every sweep
input int    InpVolAvgBars   = 20;          // Bars for the average volume
input double InpMinSweepVol  = 0.0;         // Only sweeps with volume >= x times average (0 = off)
input bool   InpShowPOC      = true;        // Previous-day POC (price with the most tick volume)

input group "=== Trade plan and statistics ==="
input bool   InpShowPlan     = true;        // Draw entry / SL / TP for confirmed setups
input double InpRR           = 2.0;         // Take profit = x times the risk
input double InpRiskPct      = 1.0;         // Risk per trade, % of balance (lot size in the panel)
input int    InpSLBufferPts  = 0;           // Extra SL distance beyond the sweep extreme (points)
input int    InpEntryExpiry  = 12;          // Bars to wait for price to reach the entry, then 'missed'
input bool   InpShowStats    = true;        // Statistics of the setups on this chart

input group "=== Proof / documentation ==="
input bool   InpExportCSV    = false;       // Write every setup + outcome to MQL5/Files/ICTV_setups_<symbol>_<tf>.csv
input int    InpShots        = 0;           // Screenshots: 0 off, 1 at each confirmed setup, 2 every new bar
input int    InpShotsMax     = 200;         // Max screenshots per run
input int    InpShotWidth    = 1280;        // Screenshot width (px)
input int    InpShotHeight   = 720;         // Screenshot height (px)

//==========================================================================
// STATE
//==========================================================================
double BufBuy[], BufSell[];
int    hATR = INVALID_HANDLE;
string PFX = "ICTV_";

struct Setup
{
   bool     active;
   int      dir;          // -1 sell, +1 buy
   double   extreme;      // sweep extreme (invalidation)
   double   structLevel;  // level whose break confirms the MSS
   datetime sweepTime;
   int      sweepBar;
   string   poolName;
};
Setup S[2];               // 0 = sell, 1 = buy
int    gLastCalc = 0;
string gStatus   = "waiting for a sweep";
bool   gLive     = false;   // false while the history is (re)calculated, true for new closed bars

//--- trade plans of confirmed setups, followed bar by bar to measure the outcome
struct Plan
{
   int      dir;
   double   entry, sl, tp;
   int      confBar;
   datetime confTime;
   int      state;        // 0 waiting for entry, 1 filled, 2 TP, 3 SL, 4 missed
   string   pool;
   string   vol;          // volume context at the sweep
   datetime outTime;
};
Plan   gPlans[];
int    gStTotal = 0, gStFilled = 0, gStTP = 0, gStSL = 0, gStMissed = 0;
string gLastPlan = "";
int    gShots = 0;
bool   gDirty = false;    // setups / outcomes changed since the last CSV write

//--- volume context of the bar being processed
double gVolRatio = 0;      // tick volume of the bar / average of the previous InpVolAvgBars bars
string gSweepVol = "";     // text shown with the last sweep
datetime gPocDay = 0; double gPocPrice = 0;

//==========================================================================
// HELPERS
//==========================================================================
// mix a colour with the chart background: pct = 100 -> pure colour, 0 -> background
color Tint(color c, int pct)
{
   int ci = (int)c;
   int bi = (int)ChartGetInteger(0, CHART_COLOR_BACKGROUND);
   pct = MathMax(0, MathMin(100, pct));
   int r = ((ci & 0xFF)         * pct + (bi & 0xFF)         * (100 - pct)) / 100;
   int g = (((ci >> 8) & 0xFF)  * pct + ((bi >> 8) & 0xFF)  * (100 - pct)) / 100;
   int b = (((ci >> 16) & 0xFF) * pct + ((bi >> 16) & 0xFF) * (100 - pct)) / 100;
   return (color)(r | (g << 8) | (b << 16));
}

// one line per detected event; HIST = found while recalculating history, LIVE = found on a new closed bar
void LogSignal(const string what, const datetime barTime, const double price)
{
   if(!InpLogSignals) return;
   string fn = StringFormat("ICTV_signals_%s_%s.csv", _Symbol, EnumToString((ENUM_TIMEFRAMES)_Period));
   int h = FileOpen(fn, FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI, ';');
   if(h == INVALID_HANDLE) return;
   if(FileSize(h) == 0) FileWrite(h, "Mode", "LoggedAt", "BarTime", "Event", "Price");
   FileSeek(h, 0, SEEK_END);
   FileWrite(h, gLive ? "LIVE" : "HIST", TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS),
             TimeToString(barTime, TIME_DATE | TIME_MINUTES), what, DoubleToString(price, _Digits));
   FileClose(h);
}

//==========================================================================
int OnInit()
{
   SetIndexBuffer(0, BufBuy,  INDICATOR_DATA);
   SetIndexBuffer(1, BufSell, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_ARROW, 233);
   PlotIndexSetInteger(1, PLOT_ARROW, 234);
   PlotIndexSetDouble (0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble (1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   ArraySetAsSeries(BufBuy,  false);
   ArraySetAsSeries(BufSell, false);

   hATR = iATR(_Symbol, PERIOD_CURRENT, InpATRPeriod);
   if(hATR == INVALID_HANDLE) { Print("ATR handle failed"); return INIT_FAILED; }

   for(int d = 0; d < 2; d++) S[d].active = false;
   IndicatorSetString(INDICATOR_SHORTNAME, "ICT Structure Visualizer");
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   if(InpExportCSV) ExportSetups();
   if(hATR != INVALID_HANDLE) IndicatorRelease(hATR);
   ObjectsDeleteAll(0, PFX);
   Comment("");
}

//==========================================================================
// MAIN
//==========================================================================
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
   if(rates_total < 300) return 0;

   int start = prev_calculated - 1;
   if(prev_calculated == 0)
   {
      ArrayInitialize(BufBuy,  EMPTY_VALUE);
      ArrayInitialize(BufSell, EMPTY_VALUE);
      ObjectsDeleteAll(0, PFX);
      for(int d = 0; d < 2; d++) S[d].active = false;
      ArrayResize(gPlans, 0);
      gStTotal = gStFilled = gStTP = gStSL = gStMissed = 0;
      gLastPlan = "";
      start = MathMax(210, rates_total - InpHistoryBars);
   }
   if(start < 210) start = 210;

   double atr[];
   ArraySetAsSeries(atr, false);
   if(CopyBuffer(hATR, 0, 0, rates_total, atr) <= 0) return prev_calculated;

   gLive = (prev_calculated > 0);
   // only CLOSED bars: stop at rates_total-2
   for(int i = start; i <= rates_total - 2; i++)
   {
      BufBuy[i] = EMPTY_VALUE;
      BufSell[i] = EMPTY_VALUE;
      if(atr[i] <= 0) continue;

      gVolRatio = VolRatio(i, tick_volume);
      ProcessBar(i, time, open, high, low, close, atr[i]);
   }
   BufBuy [rates_total-1] = EMPTY_VALUE;
   BufSell[rates_total-1] = EMPTY_VALUE;

   if(InpShowPanel) DrawPanel();
   if(InpExportCSV && (prev_calculated == 0 || gDirty)) { ExportSetups(); gDirty = false; }
   if(InpShots == 2 && prev_calculated > 0 && prev_calculated < rates_total) TakeShot("bar");
   return rates_total;
}

//==========================================================================
// ONE CLOSED BAR
//==========================================================================
void ProcessBar(const int i, const datetime &time[], const double &open[],
                const double &high[], const double &low[], const double &close[], double atr)
{
   //--- 0) follow the open trade plans on this closed bar
   UpdatePlans(i, time, high, low);

   //--- 1) pools valid at this bar
   double pdh = 0, pdl = 0, ah = 0, al = 0;
   GetDailyPools(time[i], pdh, pdl);
   GetAsiaPools(i, time, high, low, ah, al);

   bool asiaOK = (PeriodSeconds() <= 3600);                 // Asia range makes no sense above H1
   bool recent = (InpPoolDays <= 0) ||
                 (time[i] >= iTime(_Symbol, PERIOD_CURRENT, 0) - (datetime)(InpPoolDays * 86400));
   if(InpShowPools && recent)
   {
      if(InpUsePDHL && pdh > 0) DrawPoolTick(i, time, pdh, "PDH");
      if(InpUsePDHL && pdl > 0) DrawPoolTick(i, time, pdl, "PDL");
      if(InpUseAsia && asiaOK && ah > 0) DrawPoolTick(i, time, ah, "Asia H");
      if(InpUseAsia && asiaOK && al > 0) DrawPoolTick(i, time, al, "Asia L");
      if(InpShowPOC)
      {
         double poc = PrevDayPOC(time[i]);
         if(poc > 0) DrawPoolTick(i, time, poc, "POC");
      }
   }

   //--- 2) sweep detection (pool taken, close back inside)
   CheckSweep(i, time, high, low, close, pdh, "PDH", -1);
   if(asiaOK) CheckSweep(i, time, high, low, close, ah,  "AsiaH", -1);
   CheckSweep(i, time, high, low, close, pdl, "PDL",  +1);
   if(asiaOK) CheckSweep(i, time, high, low, close, al,  "AsiaL", +1);

   //--- 3) structure shift + FVG
   for(int d = 0; d < 2; d++)
   {
      if(!S[d].active) continue;
      int dir = (d == 0) ? -1 : +1;

      // invalidation: sweep extreme taken out again
      if((dir < 0 && high[i] > S[d].extreme) || (dir > 0 && low[i] < S[d].extreme))
      { S[d].active = false; continue; }

      // expiry
      if(i - S[d].sweepBar > InpMaxBarsToMSS) { S[d].active = false; continue; }

      bool broken = (dir < 0) ? (close[i] < S[d].structLevel) : (close[i] > S[d].structLevel);
      if(!broken) continue;

      double range = high[i] - low[i];
      if(range < InpDisplaceATR * atr) continue;              // needs displacement

      ConfirmSetup(d, dir, i, time, high, low, close);
      S[d].active = false;
   }
}

//==========================================================================
// SWEEP
//==========================================================================
void CheckSweep(const int i, const datetime &time[], const double &high[], const double &low[],
                const double &close[], double pool, string name, int dir)
{
   if(pool <= 0) return;
   int d = (dir < 0) ? 0 : 1;
   if(S[d].active) return;

   bool swept = (dir < 0) ? (high[i] > pool && close[i] < pool)
                          : (low[i]  < pool && close[i] > pool);
   if(!swept) return;

   // optional filter: the sweep candle must show unusual activity
   if(InpMinSweepVol > 0 && gVolRatio < InpMinSweepVol) return;

   // structure level to break = last opposite swing
   double lvl = LastSwing(i, high, low, dir);
   if(lvl <= 0) return;

   gSweepVol = "";
   if(InpShowVolume)
   {
      string dTxt = TickDeltaText(time[i], time[i] + (datetime)PeriodSeconds());
      gSweepVol = StringFormat("Vol %.1fx%s", gVolRatio, dTxt);
   }

   S[d].active      = true;
   S[d].dir         = dir;
   S[d].extreme     = (dir < 0) ? high[i] : low[i];
   S[d].structLevel = lvl;
   S[d].sweepTime   = time[i];
   S[d].sweepBar    = i;
   S[d].poolName    = name;

   LogSignal(StringFormat("SWEEP %s %s", dir < 0 ? "SELL" : "BUY", name), time[i], S[d].extreme);
   string nm = PFX + "sweep_" + IntegerToString(i);
   ObjectCreate(0, nm, OBJ_ARROW, 0, time[i], S[d].extreme);
   ObjectSetInteger(0, nm, OBJPROP_ARROWCODE, dir < 0 ? 242 : 241);
   ObjectSetInteger(0, nm, OBJPROP_COLOR, dir < 0 ? InpSellColor : InpBuyColor);
   ObjectSetInteger(0, nm, OBJPROP_WIDTH, 1);
   ObjectSetString (0, nm, OBJPROP_TOOLTIP,
                    StringFormat("%s swept %s  -  watching for structure shift  %s",
                                 name, DoubleToString(pool, _Digits), gSweepVol));
   if(InpShowLabels && InpSweepLabels)
   {
      string sl = nm + "_lbl";
      ObjectCreate(0, sl, OBJ_TEXT, 0, time[i], S[d].extreme);
      ObjectSetString (0, sl, OBJPROP_TEXT, "Sweep " + name + (gSweepVol != "" ? "  " + gSweepVol : ""));
      ObjectSetInteger(0, sl, OBJPROP_COLOR, dir < 0 ? InpSellColor : InpBuyColor);
      ObjectSetInteger(0, sl, OBJPROP_FONTSIZE, 7);
      ObjectSetInteger(0, sl, OBJPROP_ANCHOR, dir < 0 ? ANCHOR_LOWER : ANCHOR_UPPER);
      ObjectSetInteger(0, sl, OBJPROP_SELECTABLE, false);
   }
   gStatus = StringFormat("%s swept (%s) - WATCHING for %s structure shift",
                          name, gSweepVol, dir < 0 ? "bearish" : "bullish");
}

// last swing low (for sell setups) / swing high (for buy setups) before bar i
double LastSwing(const int i, const double &high[], const double &low[], int dir)
{
   int n = InpSwingLen;
   for(int k = i - n - 1; k > i - 80 && k > n; k--)
   {
      bool ok = true;
      for(int j = 1; j <= n && ok; j++)
      {
         if(dir < 0) { if(low[k-j]  <= low[k]  || low[k+j]  < low[k])  ok = false; }
         else        { if(high[k-j] >= high[k] || high[k+j] > high[k]) ok = false; }
      }
      if(ok) return (dir < 0) ? low[k] : high[k];
   }
   return 0;
}

//==========================================================================
// CONFIRMED SETUP: MSS line, FVG box, entry arrow
//==========================================================================
void ConfirmSetup(const int d, const int dir, const int i, const datetime &time[],
                  const double &high[], const double &low[], const double &close[])
{
   //--- MSS level line, from the sweep to this bar
   string nm = PFX + "mss_" + IntegerToString(i);
   ObjectCreate(0, nm, OBJ_TREND, 0, S[d].sweepTime, S[d].structLevel, time[i], S[d].structLevel);
   ObjectSetInteger(0, nm, OBJPROP_COLOR, dir < 0 ? InpSellColor : InpBuyColor);
   ObjectSetInteger(0, nm, OBJPROP_STYLE, STYLE_DASH);
   ObjectSetInteger(0, nm, OBJPROP_RAY_RIGHT, false);
   ObjectSetString (0, nm, OBJPROP_TOOLTIP, "MSS - structure broken with displacement");

   string lb = PFX + "msslbl_" + IntegerToString(i);
   ObjectCreate(0, lb, OBJ_TEXT, 0, time[i], S[d].structLevel);
   ObjectSetString (0, lb, OBJPROP_TEXT, dir < 0 ? "MSS" : "MSS");
   ObjectSetInteger(0, lb, OBJPROP_COLOR, dir < 0 ? InpSellColor : InpBuyColor);
   ObjectSetInteger(0, lb, OBJPROP_FONTSIZE, 8);

   //--- FVG left by the displacement (3-bar gap)
   double fvgHi = 0, fvgLo = 0;
   bool haveFVG = false;
   if(dir < 0 && high[i] < low[i-2]) { fvgHi = low[i-2];  fvgLo = high[i]; haveFVG = true; }
   if(dir > 0 && low[i]  > high[i-2]){ fvgHi = low[i];    fvgLo = high[i-2]; haveFVG = true; }

   double entry = close[i];
   if(haveFVG)
   {
      entry = (fvgHi + fvgLo) / 2.0;
      if(InpShowFVG)
      {
         datetime t2 = time[i] + (datetime)(PeriodSeconds() * 12);
         string fn = PFX + "fvg_" + IntegerToString(i);
         ObjectCreate(0, fn, OBJ_RECTANGLE, 0, time[i-2], fvgHi, t2, fvgLo);
         color base = (dir < 0) ? InpSellColor : InpBuyColor;
         if(InpFVGOpacity > 0)
         {
            ObjectSetInteger(0, fn, OBJPROP_COLOR, Tint(base, InpFVGOpacity));   // soft tint, candles stay readable
            ObjectSetInteger(0, fn, OBJPROP_FILL, true);
         }
         else
         {
            ObjectSetInteger(0, fn, OBJPROP_COLOR, base);                         // outline only
            ObjectSetInteger(0, fn, OBJPROP_FILL, false);
            ObjectSetInteger(0, fn, OBJPROP_STYLE, STYLE_DOT);
         }
         ObjectSetInteger(0, fn, OBJPROP_BACK, true);
         ObjectSetInteger(0, fn, OBJPROP_SELECTABLE, false);
         if(InpShowLabels)
         {
            string fl = fn + "_lbl";
            ObjectCreate(0, fl, OBJ_TEXT, 0, time[i-2], fvgHi);
            ObjectSetString (0, fl, OBJPROP_TEXT, "FVG");
            ObjectSetInteger(0, fl, OBJPROP_COLOR, base);
            ObjectSetInteger(0, fl, OBJPROP_FONTSIZE, 7);
            ObjectSetInteger(0, fl, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
            ObjectSetInteger(0, fl, OBJPROP_SELECTABLE, false);
         }
         ObjectSetString (0, fn, OBJPROP_TOOLTIP, "FVG left by the displacement candle");
      }
   }

   LogSignal(StringFormat("CONFIRMED %s %s", dir < 0 ? "SELL" : "BUY", S[d].poolName), time[i], entry);

   //--- trade plan: entry at the FVG middle (or the close), SL beyond the sweep extreme, TP = RR x risk
   double sl   = (dir < 0) ? S[d].extreme + InpSLBufferPts * _Point : S[d].extreme - InpSLBufferPts * _Point;
   double risk = (dir < 0) ? sl - entry : entry - sl;       // must be positive: SL on the correct side
   double tp   = (dir < 0) ? entry - InpRR * risk : entry + InpRR * risk;
   double spr  = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * _Point;
   if(risk > MathMax(spr * 3, _Point * 10))                 // skip invalid / micro-risk plans
   {
      int n = ArraySize(gPlans);
      ArrayResize(gPlans, n + 1);
      gPlans[n].dir = dir; gPlans[n].entry = entry; gPlans[n].sl = sl; gPlans[n].tp = tp;
      gPlans[n].confBar = i; gPlans[n].confTime = time[i]; gPlans[n].state = 0;
      gPlans[n].pool = S[d].poolName; gPlans[n].vol = gSweepVol; gPlans[n].outTime = 0;
      gStTotal++;
      gDirty = true;
      if(InpShowPlan) DrawPlan(i, time, dir, entry, sl, tp);
      double lots = LotsForRisk(dir, entry, sl);
      gLastPlan = StringFormat("%s  entry %s  SL %s  TP %s  |  lot %s for %.1f%% risk",
                               dir < 0 ? "SELL" : "BUY", DoubleToString(entry, _Digits),
                               DoubleToString(sl, _Digits), DoubleToString(tp, _Digits),
                               lots > 0 ? DoubleToString(lots, 2) : "n/a", InpRiskPct);
   }

   //--- entry arrow on the confirmation bar
   if(dir < 0) BufSell[i] = high[i];
   else        BufBuy [i] = low[i];

   string en = PFX + "entry_" + IntegerToString(i);
   ObjectCreate(0, en, OBJ_TEXT, 0, time[i], dir < 0 ? high[i] : low[i]);
   ObjectSetString (0, en, OBJPROP_TEXT, StringFormat(" CONFIRMED %s (%s)",
                    dir < 0 ? "SELL" : "BUY", S[d].poolName));
   ObjectSetInteger(0, en, OBJPROP_COLOR, dir < 0 ? InpSellColor : InpBuyColor);
   ObjectSetInteger(0, en, OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, en, OBJPROP_ANCHOR, dir < 0 ? ANCHOR_LOWER : ANCHOR_UPPER);

   gStatus = StringFormat("%s setup CONFIRMED at %s (%s) - entry %s",
                          dir < 0 ? "SELL" : "BUY",
                          TimeToString(time[i], TIME_DATE | TIME_MINUTES),
                          S[d].poolName, DoubleToString(entry, _Digits));

   if(gLive)   // only for setups that appear in real time, never for history
   {
      string msg = StringFormat("%s %s: %s setup confirmed (%s). %s", _Symbol,
                                EnumToString((ENUM_TIMEFRAMES)_Period), dir < 0 ? "SELL" : "BUY",
                                S[d].poolName, gLastPlan);
      if(StringLen(msg) > 250) msg = StringSubstr(msg, 0, 250);   // push limit
      if(InpAlerts) Alert(msg);
      if(InpPush)   SendNotification(msg);
      if(InpEmail)  SendMail("ICT Structure Visualizer - " + _Symbol, msg);
      if(InpShots == 1) { if(InpShowPanel) DrawPanel(); TakeShot("setup"); }
   }
}

//==========================================================================
// VOLUME CONTEXT (broker tick volume - NOT exchange contracts)
//==========================================================================
double VolRatio(const int i, const long &tvol[])
{
   if(i < InpVolAvgBars + 1) return 0;
   double sum = 0;
   for(int k = i - InpVolAvgBars; k < i; k++) sum += (double)tvol[k];
   double avg = sum / InpVolAvgBars;
   return avg > 0 ? (double)tvol[i] / avg : 0;
}

// tick delta of one bar: buyer/seller flags if the broker provides them, otherwise up-tick minus down-tick
string TickDeltaText(datetime from, datetime to)
{
   MqlTick ticks[];
   int n = CopyTicksRange(_Symbol, ticks, COPY_TICKS_ALL, (ulong)from * 1000, (ulong)to * 1000 - 1);
   if(n < 10) return "";                                   // no tick history for this bar
   long up = 0, dn = 0; bool flags = false;
   double prev = ticks[0].bid;
   for(int k = 0; k < n; k++)
   {
      if((ticks[k].flags & TICK_FLAG_BUY) != 0)  { up++; flags = true; continue; }
      if((ticks[k].flags & TICK_FLAG_SELL) != 0) { dn++; flags = true; continue; }
      double p = ticks[k].bid;
      if(p > prev) up++; else if(p < prev) dn++;
      prev = p;
   }
   long tot = up + dn;
   if(tot == 0) return "";
   return StringFormat("  %s delta %+.0f%%", flags ? "real" : "tick",
                       100.0 * (double)(up - dn) / (double)tot);
}

// previous-day point of control: price bucket with the most M1 tick volume (cached per day)
double PrevDayPOC(datetime t)
{
   int sh = iBarShift(_Symbol, PERIOD_D1, t, false);
   if(sh < 0) return 0;
   datetime d0 = iTime(_Symbol, PERIOD_D1, sh + 1);
   if(d0 == 0) return 0;
   if(d0 == gPocDay) return gPocPrice;

   MqlRates r[];
   int n = CopyRates(_Symbol, PERIOD_M1, d0, d0 + 86400 - 1, r);
   if(n < 30) return 0;                                    // M1 history not ready: try again next bar
   gPocDay = d0; gPocPrice = 0;
   double hi = r[0].high, lo = r[0].low;
   for(int k = 1; k < n; k++) { hi = MathMax(hi, r[k].high); lo = MathMin(lo, r[k].low); }
   const int B = 60;
   double step = (hi - lo) / B;
   if(step <= 0) return 0;
   double vol[]; ArrayResize(vol, B); ArrayInitialize(vol, 0);
   for(int k = 0; k < n; k++)
   {
      int b1 = (int)MathMin(B - 1, MathFloor((r[k].low  - lo) / step));
      int b2 = (int)MathMin(B - 1, MathFloor((r[k].high - lo) / step));
      double share = (double)r[k].tick_volume / (b2 - b1 + 1);
      for(int b = b1; b <= b2; b++) vol[b] += share;
   }
   int best = ArrayMaximum(vol);
   gPocPrice = NormalizeDouble(lo + (best + 0.5) * step, _Digits);
   return gPocPrice;
}

//==========================================================================
// PROOF TOOLS
//==========================================================================
void TakeShot(const string tag)
{
   if(gShots >= InpShotsMax) return;
   ChartRedraw(0);
   string fn = StringFormat("ICTV_shots\\%s_%s_%03d_%s_%s.png", _Symbol,
                            EnumToString((ENUM_TIMEFRAMES)_Period), gShots, tag,
                            TimeToString(iTime(_Symbol, PERIOD_CURRENT, 1), TIME_DATE | TIME_MINUTES));
   StringReplace(fn, ":", "-");
   StringReplace(fn, " ", "_");
   if(ChartScreenShot(0, fn, InpShotWidth, InpShotHeight, ALIGN_RIGHT)) gShots++;
}

void ExportSetups()
{
   string fn = StringFormat("ICTV_setups_%s_%s_vol%.1f_rr%.1f.csv", _Symbol, EnumToString((ENUM_TIMEFRAMES)_Period),
                            InpMinSweepVol, InpRR);
   int h = FileOpen(fn, FILE_WRITE | FILE_CSV | FILE_ANSI, ';');
   if(h == INVALID_HANDLE) return;
   FileWrite(h, "ConfirmTime", "Dir", "Pool", "VolumeAtSweep", "Entry", "SL", "TP", "Outcome", "OutcomeTime", "R");
   string st[5] = {"waiting", "open", "TP", "SL", "missed"};
   for(int k = 0; k < ArraySize(gPlans); k++)
   {
      double r = (gPlans[k].state == 2) ? InpRR : (gPlans[k].state == 3 ? -1.0 : 0.0);
      FileWrite(h, TimeToString(gPlans[k].confTime, TIME_DATE | TIME_MINUTES), gPlans[k].dir < 0 ? "SELL" : "BUY",
                gPlans[k].pool, gPlans[k].vol, DoubleToString(gPlans[k].entry, _Digits),
                DoubleToString(gPlans[k].sl, _Digits), DoubleToString(gPlans[k].tp, _Digits),
                st[gPlans[k].state], gPlans[k].outTime > 0 ? TimeToString(gPlans[k].outTime, TIME_DATE | TIME_MINUTES) : "",
                DoubleToString(r, 1));
   }
   int closed = gStTP + gStSL;
   FileWrite(h, "");
   FileWrite(h, StringFormat("SUMMARY setups %d | filled %d | missed %d | TP %d | SL %d | win %.1f%% | net %+.1fR | RR %.1f | volume filter %.1f",
             gStTotal, gStFilled, gStMissed, gStTP, gStSL, closed > 0 ? 100.0 * gStTP / closed : 0,
             gStTP * InpRR - gStSL, InpRR, InpMinSweepVol));
   FileClose(h);
}

//==========================================================================
// TRADE PLAN
//==========================================================================
void DrawPlan(const int i, const datetime &time[], int dir, double entry, double sl, double tp)
{
   datetime t1 = time[i], t2 = time[i] + (datetime)(PeriodSeconds() * InpEntryExpiry);
   string base = PFX + "plan_" + IntegerToString((long)time[i]) + "_";
   PlanLine(base + "e", t1, t2, entry, clrSilver,      STYLE_SOLID, "Entry " + DoubleToString(entry, _Digits));
   PlanLine(base + "s", t1, t2, sl,    clrFireBrick,   STYLE_SOLID, "SL "    + DoubleToString(sl,    _Digits));
   PlanLine(base + "t", t1, t2, tp,    clrSeaGreen,    STYLE_SOLID, StringFormat("TP %.1fR ", InpRR) + DoubleToString(tp, _Digits));
}

void PlanLine(const string nm, datetime t1, datetime t2, double price, color c, int style, const string txt)
{
   ObjectCreate(0, nm, OBJ_TREND, 0, t1, price, t2, price);
   ObjectSetInteger(0, nm, OBJPROP_COLOR, c);
   ObjectSetInteger(0, nm, OBJPROP_STYLE, style);
   ObjectSetInteger(0, nm, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
   ObjectSetString (0, nm, OBJPROP_TOOLTIP, txt);
   if(InpShowLabels)
   {
      string tl = nm + "_lbl";
      ObjectCreate(0, tl, OBJ_TEXT, 0, t2, price);
      ObjectSetString (0, tl, OBJPROP_TEXT, txt);
      ObjectSetInteger(0, tl, OBJPROP_COLOR, c);
      ObjectSetInteger(0, tl, OBJPROP_FONTSIZE, 7);
      ObjectSetInteger(0, tl, OBJPROP_ANCHOR, ANCHOR_LEFT);
      ObjectSetInteger(0, tl, OBJPROP_SELECTABLE, false);
   }
}

// lot size for InpRiskPct of the current balance, using the broker's own profit calculation
double LotsForRisk(int dir, double entry, double sl)
{
   double loss1 = 0;
   ENUM_ORDER_TYPE ot = (dir < 0) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
   if(!OrderCalcProfit(ot, _Symbol, 1.0, entry, sl, loss1) || loss1 >= 0) return 0;
   double money = AccountInfoDouble(ACCOUNT_BALANCE) * InpRiskPct / 100.0;
   double step  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double vmin  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double vmax  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   if(step <= 0) return 0;
   double lots = MathFloor(money / (-loss1) / step + 1e-9) * step;
   if(lots < vmin) return 0;
   return MathMin(lots, vmax);
}

// follow every plan on a closed bar: fill at the entry, then TP or SL (both on one bar = SL, conservative)
void UpdatePlans(const int i, const datetime &time[], const double &high[], const double &low[])
{
   for(int k = 0; k < ArraySize(gPlans); k++)
   {
      if(gPlans[k].state >= 2 || i <= gPlans[k].confBar) continue;
      int dir = gPlans[k].dir;
      if(gPlans[k].state == 0)
      {
         bool touched = (dir < 0) ? (high[i] >= gPlans[k].entry) : (low[i] <= gPlans[k].entry);
         if(!touched)
         {
            if(i - gPlans[k].confBar >= InpEntryExpiry) { gPlans[k].state = 4; gStMissed++; gPlans[k].outTime = time[i]; }
            continue;
         }
         gPlans[k].state = 1; gStFilled++;
      }
      bool hitSL = (dir < 0) ? (high[i] >= gPlans[k].sl) : (low[i] <= gPlans[k].sl);
      bool hitTP = (dir < 0) ? (low[i]  <= gPlans[k].tp) : (high[i] >= gPlans[k].tp);
      if(hitSL || hitTP) gDirty = true;
      if(hitSL)      { gPlans[k].state = 3; gStSL++; gPlans[k].outTime = time[i]; MarkOutcome(k, i, time, "SL", clrFireBrick); }
      else if(hitTP) { gPlans[k].state = 2; gStTP++; gPlans[k].outTime = time[i]; MarkOutcome(k, i, time, "TP", clrSeaGreen); }
   }
}

void MarkOutcome(const int k, const int i, const datetime &time[], const string txt, color c)
{
   if(!InpShowPlan) return;
   string nm = PFX + "out_" + IntegerToString((long)gPlans[k].confTime);
   double price = (txt == "TP") ? gPlans[k].tp : gPlans[k].sl;
   ObjectCreate(0, nm, OBJ_TEXT, 0, time[i], price);
   ObjectSetString (0, nm, OBJPROP_TEXT, txt == "TP" ? StringFormat("TP hit +%.1fR", InpRR) : "SL hit -1R");
   ObjectSetInteger(0, nm, OBJPROP_COLOR, c);
   ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, 7);
   ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
}

//==========================================================================
// POOLS
//==========================================================================
void GetDailyPools(datetime t, double &pdh, double &pdl)
{
   pdh = 0; pdl = 0;
   if(!InpUsePDHL) return;
   int sh = iBarShift(_Symbol, PERIOD_D1, t, false);
   if(sh < 0) return;
   pdh = iHigh(_Symbol, PERIOD_D1, sh + 1);
   pdl = iLow (_Symbol, PERIOD_D1, sh + 1);
}

void GetAsiaPools(const int i, const datetime &time[], const double &high[], const double &low[],
                  double &ah, double &al)
{
   ah = 0; al = 0;
   if(!InpUseAsia) return;
   MqlDateTime dt; TimeToStruct(time[i], dt);
   if(dt.hour < InpAsiaEnd) return;                       // session not finished yet
   datetime day0  = time[i] - (datetime)(dt.hour * 3600 + dt.min * 60 + dt.sec);
   datetime tFrom = day0 + (datetime)(InpAsiaStart * 3600);
   datetime tTo   = day0 + (datetime)(InpAsiaEnd * 3600);

   for(int k = i; k > i - 400 && k > 0; k--)
   {
      if(time[k] < tFrom) break;
      if(time[k] >= tTo) continue;
      if(ah == 0) { ah = high[k]; al = low[k]; }
      else { ah = MathMax(ah, high[k]); al = MathMin(al, low[k]); }
   }
}

void DrawPoolTick(const int i, const datetime &time[], double price, const string label)
{
   // one line per level per trading day, from the first bar where it is valid to the end of that day
   datetime day0 = time[i] - (time[i] % 86400);
   string nm = PFX + "pool_" + label + "_" + IntegerToString((long)day0);
   if(ObjectFind(0, nm) >= 0) return;
   ObjectCreate(0, nm, OBJ_TREND, 0, time[i], price, day0 + 86400, price);
   ObjectSetInteger(0, nm, OBJPROP_COLOR, InpPoolColor);
   ObjectSetInteger(0, nm, OBJPROP_STYLE, STYLE_DOT);
   ObjectSetInteger(0, nm, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, nm, OBJPROP_BACK, true);
   ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
   ObjectSetString (0, nm, OBJPROP_TOOLTIP, label + " liquidity pool " + DoubleToString(price, _Digits));
   if(InpShowLabels)
   {
      string tl = nm + "_lbl";
      ObjectCreate(0, tl, OBJ_TEXT, 0, time[i], price);
      ObjectSetString (0, tl, OBJPROP_TEXT, label);
      ObjectSetInteger(0, tl, OBJPROP_COLOR, InpPoolColor);
      ObjectSetInteger(0, tl, OBJPROP_FONTSIZE, 7);
      ObjectSetInteger(0, tl, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);   // text sits just above the line
      ObjectSetInteger(0, tl, OBJPROP_SELECTABLE, false);
   }
}

//==========================================================================
// PANEL
//==========================================================================
void DrawPanel()
{
   string st = gStatus;
   for(int d = 0; d < 2; d++)
      if(S[d].active)
         st = StringFormat("WATCHING %s after %s sweep - waiting for structure shift",
                           d == 0 ? "SELL" : "BUY", S[d].poolName);

   string plan = (gLastPlan != "") ? "\n  Last plan: " + gLastPlan : "";
   string stats = "";
   if(InpShowStats)
   {
      int closed = gStTP + gStSL;
      double win = closed > 0 ? 100.0 * gStTP / closed : 0;
      double netR = gStTP * InpRR - gStSL;
      stats = StringFormat("\n  Stats on this chart (%d bars): %d setups | %d filled | %d missed | TP %d | SL %d | win %.0f%% | net %+.1fR"
                           "\n  (TP %.1fR, spread and swap not included - check the result on YOUR symbol and timeframe)%s",
                           InpHistoryBars, gStTotal, gStFilled, gStMissed, gStTP, gStSL, win, netR, InpRR,
                           InpMinSweepVol > 0 ? StringFormat("\n  Volume filter ON: only sweeps with >= %.1fx average tick volume", InpMinSweepVol) : "");
   }
   string txt = StringFormat("ICT Structure Visualizer  |  %s %s\n%s%s%s\n(analysis only - no trading)",
                             _Symbol, EnumToString((ENUM_TIMEFRAMES)_Period), st, plan, stats);
   StringReplace(txt, "\n  ", "\n");
   DrawPanelBox(txt);
}
//+------------------------------------------------------------------+

//--- panel as a box: background rectangle + one label per line (OBJ_LABEL max 63 chars)
void PanelWrap(const string line, string &out[])
{
   string rest = line;
   while(StringLen(rest) > 60)
   {
      int cut = 60;
      while(cut > 20 && StringGetCharacter(rest, cut) != ' ') cut--;
      if(cut <= 20) cut = 60;
      int n = ArraySize(out); ArrayResize(out, n + 1);
      out[n] = StringSubstr(rest, 0, cut);
      rest = "   " + StringTrimLeftCopy(StringSubstr(rest, cut));
   }
   int n = ArraySize(out); ArrayResize(out, n + 1); out[n] = rest;
}

string StringTrimLeftCopy(string s) { StringTrimLeft(s); return s; }

void DrawPanelBox(const string txt)
{
   string raw[]; int nr = StringSplit(txt, '\n', raw);
   string lines[]; ArrayResize(lines, 0);
   for(int i = 0; i < nr; i++) PanelWrap(raw[i], lines);
   int n = ArraySize(lines);

   //--- colours from the chart: text = good contrast with the background
   int bg = (int)ChartGetInteger(0, CHART_COLOR_BACKGROUND);
   double lum = 0.299 * (bg & 0xFF) + 0.587 * ((bg >> 8) & 0xFF) + 0.114 * ((bg >> 16) & 0xFF);
   color txtCol = lum < 128 ? clrWhiteSmoke : clrBlack;
   color boxCol = Tint(txtCol, 10);
   color brdCol = Tint(txtCol, 40);

   string font = "Arial";
   TextSetFont(font, -InpPanelFont * 10);
   uint w = 0, h = 0;
   int maxW = 0, lineH = 0;
   for(int i = 0; i < n; i++) { TextGetSize(lines[i], w, h); maxW = MathMax(maxW, (int)w); lineH = MathMax(lineH, (int)h); }
   lineH += 3;
   int pad = 8, ox = 10, oy = 20;
   int W = maxW + 2 * pad, H = n * lineH + 2 * pad;
   bool right = (InpPanelCorner == CORNER_RIGHT_UPPER || InpPanelCorner == CORNER_RIGHT_LOWER);
   bool lower = (InpPanelCorner == CORNER_LEFT_LOWER  || InpPanelCorner == CORNER_RIGHT_LOWER);

   string bx = PFX + "panel_bg";
   if(ObjectFind(0, bx) < 0) ObjectCreate(0, bx, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, bx, OBJPROP_CORNER, InpPanelCorner);
   ObjectSetInteger(0, bx, OBJPROP_XDISTANCE, right ? ox + W : ox);
   ObjectSetInteger(0, bx, OBJPROP_YDISTANCE, lower ? oy + H : oy);
   ObjectSetInteger(0, bx, OBJPROP_XSIZE, W);
   ObjectSetInteger(0, bx, OBJPROP_YSIZE, H);
   ObjectSetInteger(0, bx, OBJPROP_BGCOLOR, boxCol);
   ObjectSetInteger(0, bx, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, bx, OBJPROP_COLOR, brdCol);
   ObjectSetInteger(0, bx, OBJPROP_BACK, false);
   ObjectSetInteger(0, bx, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, bx, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, bx, OBJPROP_ZORDER, 0);

   for(int i = 0; i < 30; i++)
   {
      string ln = PFX + "panel_l" + IntegerToString(i);
      if(i >= n) { ObjectDelete(0, ln); continue; }
      if(ObjectFind(0, ln) < 0) ObjectCreate(0, ln, OBJ_LABEL, 0, 0, 0);
      int lx = pad, ly = pad + i * lineH;
      ObjectSetInteger(0, ln, OBJPROP_CORNER, InpPanelCorner);
      ObjectSetInteger(0, ln, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
      ObjectSetInteger(0, ln, OBJPROP_XDISTANCE, right ? ox + W - lx : ox + lx);
      ObjectSetInteger(0, ln, OBJPROP_YDISTANCE, lower ? oy + H - ly : oy + ly);
      ObjectSetString (0, ln, OBJPROP_TEXT, lines[i]);
      ObjectSetString (0, ln, OBJPROP_FONT, font);
      ObjectSetInteger(0, ln, OBJPROP_FONTSIZE, InpPanelFont);
      ObjectSetInteger(0, ln, OBJPROP_COLOR, i == 0 ? (lum < 128 ? clrGold : clrNavy) : txtCol);
      ObjectSetInteger(0, ln, OBJPROP_BACK, false);
      ObjectSetInteger(0, ln, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, ln, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, ln, OBJPROP_ZORDER, 1);
   }
   ChartRedraw(0);
}
