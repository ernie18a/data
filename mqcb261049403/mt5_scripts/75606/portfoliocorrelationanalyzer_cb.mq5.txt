//+------------------------------------------------------------------+
//| PortfolioCorrelationAnalyzer.mq5                        v1.30    |
//| Portfolio analytics for accounts that run several EAs: how much  |
//| drawdown the combination actually saves compared with running    |
//| the same systems apart.                                          |
//|                                                                  |
//| Groups closed trades by magic number, buckets P/L into monthly,  |
//| weekly or daily periods (InpGrain), prints per-magic drawdowns,  |
//| the compression ratio, the pairwise Pearson correlation matrix,  |
//| a Monte Carlo reshuffle of combined period returns, and exports  |
//| period-P/L and correlation CSV files to MQL5\Files, and draws    |
//| the correlation matrix on the chart as a heat map panel.         |
//| Reported set = magics with at least InpMinTrades closed trades;  |
//| the combined portfolio uses the same set (like-for-like).        |
//+------------------------------------------------------------------+
#property copyright "Seckin Erkut - free to use and modify"
#property version   "1.30"
#property description "Read-only portfolio analytics for accounts running several EAs."
#property description "Groups closed trades by magic number, then reports standalone vs"
#property description "combined drawdown, the pairwise correlation matrix, and a Monte"
#property description "Carlo reshuffle. Draws the correlation heat map on the chart."
#property description "It never places, modifies or closes an order."
#property script_show_inputs

//+------------------------------------------------------------------+
//| Embedded drawing layer (VAPanel v1.10) - single-file CodeBase    |
//| build. The standalone VAPanel.mqh is the same code.              |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| VAPanel.mqh                                             v1.10    |
//| Minimal chart-object drawing layer for read-only analytics       |
//| scripts. No CCanvas, no bitmaps, no external libraries.          |
//|                                                                  |
//| Every object carries a caller-supplied prefix. VAPanelClear()    |
//| removes the whole prefix before a redraw, so a second run of the |
//| same script never stacks objects on top of the first.            |
//+------------------------------------------------------------------+

#define VAP_FONT      "Consolas"
#define VAP_FONT_ALT  "Arial"

//--- palette (MARKA section 2, bluesteel)
#define VAP_INK       VAColor( 20,  28,  44)   // panel body
#define VAP_INK_DARK  VAColor( 13,  19,  33)   // title bar
#define VAP_EDGE      VAColor( 62,  76,  98)   // hairline border
#define VAP_TEXT      VAColor(160, 180, 205)   // grey text
#define VAP_ACCENT    VAColor(140, 186, 236)   // accent text
#define VAP_MUTED     VAColor(104, 138, 182)   // muted accent
#define VAP_FIELD     VAColor(214, 219, 226)   // neutral plot field

//--- diverging ramp end points. Deliberately desaturated: a 400 px
//--- block of saturated colour next to a dark chart is tiring to read.
#define VAP_NEG_R  58
#define VAP_NEG_G  96
#define VAP_NEG_B 178
#define VAP_MID_R 214
#define VAP_MID_G 219
#define VAP_MID_B 226
#define VAP_POS_R 172
#define VAP_POS_G  52
#define VAP_POS_B  56

//+------------------------------------------------------------------+
//| MQL5 stores colour as 0x00BBGGRR                                 |
//+------------------------------------------------------------------+
color VAColor(const int r, const int g, const int b)
  {
   return (color)(r + (g << 8) + (b << 16));
  }
//+------------------------------------------------------------------+
//| Remove every object whose name starts with prefix. Called at the |
//| START of a draw, never at the end: the panel must survive after  |
//| OnStart() returns.                                               |
//+------------------------------------------------------------------+
void VAPanelClear(const string prefix)
  {
   for(int i = ObjectsTotal(0, -1, -1) - 1; i >= 0; i--)
     {
      string nm = ObjectName(0, i, -1, -1);
      if(StringFind(nm, prefix) == 0) ObjectDelete(0, nm);
     }
  }
//+------------------------------------------------------------------+
bool VAPanelRect(const string name, const int x, const int y,
                 const int w, const int h, const color bg,
                 const bool border = false, const color brd = clrNONE)
  {
   if(ObjectFind(0, name) < 0)
      if(!ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0)) return false;
   ObjectSetInteger(0, name, OBJPROP_CORNER,      CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE,   x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE,   y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE,       w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE,       h);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR,     bg);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_COLOR,       border ? brd : bg);
   ObjectSetInteger(0, name, OBJPROP_WIDTH,       1);
   ObjectSetInteger(0, name, OBJPROP_BACK,        false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE,  false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED,    false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,      true);
   ObjectSetInteger(0, name, OBJPROP_ZORDER,      0);
   return true;
  }
//+------------------------------------------------------------------+
bool VAPanelLabel(const string name, const int x, const int y,
                  const string text, const color clr, const int size = 8,
                  const string font = VAP_FONT,
                  const ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT_UPPER)
  {
   if(ObjectFind(0, name) < 0)
      if(!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0)) return false;
   ObjectSetInteger(0, name, OBJPROP_CORNER,     CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE,  x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE,  y);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR,     anchor);
   ObjectSetInteger(0, name, OBJPROP_COLOR,      clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE,   size);
   ObjectSetInteger(0, name, OBJPROP_BACK,       false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED,   false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,     true);
   ObjectSetInteger(0, name, OBJPROP_ZORDER,     1);
   ObjectSetString(0, name, OBJPROP_FONT, font);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   return true;
  }
//+------------------------------------------------------------------+
//| Diverging colour ramp. t = -1 blue | 0 neutral | +1 red.         |
//| Same reading as the published heat map: strong colour means the  |
//| pair moves together (or exactly opposite), pale means unrelated. |
//+------------------------------------------------------------------+
color VAPanelRamp(const double t)
  {
   double v = t;
   if(v < -1.0) v = -1.0;
   if(v >  1.0) v =  1.0;
   int r, g, b;
   if(v >= 0.0)
     {
      r = (int)MathRound(VAP_MID_R + (VAP_POS_R - VAP_MID_R) * v);
      g = (int)MathRound(VAP_MID_G + (VAP_POS_G - VAP_MID_G) * v);
      b = (int)MathRound(VAP_MID_B + (VAP_POS_B - VAP_MID_B) * v);
     }
   else
     {
      double a = -v;
      r = (int)MathRound(VAP_MID_R + (VAP_NEG_R - VAP_MID_R) * a);
      g = (int)MathRound(VAP_MID_G + (VAP_NEG_G - VAP_MID_G) * a);
      b = (int)MathRound(VAP_MID_B + (VAP_NEG_B - VAP_MID_B) * a);
     }
   return VAColor(r, g, b);
  }
//+------------------------------------------------------------------+
//| Horizontal -1 .. +1 legend strip. Returns its real pixel width.  |
//+------------------------------------------------------------------+
int VAPanelLegend(const string prefix, const int x, const int y,
                  const int w, const int h, const int steps = 40)
  {
   int cw = (int)MathMax(1, w / steps);
   for(int s = 0; s < steps; s++)
     {
      double t = -1.0 + 2.0 * s / (double)(steps - 1);
      VAPanelRect(prefix + "lg" + (string)s, x + s * cw, y, cw, h, VAPanelRamp(t));
     }
   int wide = steps * cw;
   VAPanelLabel(prefix + "lgmin", x,            y + h + 3, "-1", VAP_TEXT, 7);
   VAPanelLabel(prefix + "lgmid", x + wide/2,   y + h + 3, "0",  VAP_TEXT, 7, VAP_FONT, ANCHOR_UPPER);
   VAPanelLabel(prefix + "lgmax", x + wide,     y + h + 3, "+1", VAP_TEXT, 7, VAP_FONT, ANCHOR_RIGHT_UPPER);
   return wide;
  }
//+------------------------------------------------------------------+
void VAPanelTitle(const string prefix, const int x, const int y,
                  const int w, const string title, const string right = "")
  {
   VAPanelRect(prefix + "tbar",  x, y, w, 24, VAP_INK_DARK);
   VAPanelRect(prefix + "ttick", x + 8, y + 7, 3, 10, VAP_ACCENT);
   VAPanelLabel(prefix + "ttxt", x + 18, y + 6, title, VAP_ACCENT, 8, VAP_FONT_ALT);
   if(right != "")
      VAPanelLabel(prefix + "trgt", x + w - 10, y + 6, right, VAP_MUTED, 8,
                   VAP_FONT_ALT, ANCHOR_RIGHT_UPPER);
  }
//+------------------------------------------------------------------+
void VAPanelFinish()
  {
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+

#define VAP_PFX "VAX_CORR_"

enum ENUM_PNL_GRAIN
  {
   GRAIN_MONTHLY = 0,   // Monthly
   GRAIN_WEEKLY  = 1,   // Weekly (weeks start Monday)
   GRAIN_DAILY   = 2    // Daily
  };

input ENUM_PNL_GRAIN InpGrain    = GRAIN_MONTHLY; // P/L bucketing granularity
input int    InpMCRuns      = 2000;   // Monte Carlo reshuffle runs
input int    InpMinTrades   = 20;     // ignore magics with fewer closed trades
input double InpRefBalance  = 10000;  // reference balance for percent output
input bool   InpExportCSV   = true;   // write CSV files to MQL5\Files
input bool   InpDrawPanel   = true;   // draw the correlation heat map on the chart
input bool   InpMaskMagics  = false;  // label systems S01, S02 ... instead of magic numbers
input int    InpPanelX      = 20;     // panel left offset (px)
input int    InpPanelY      = 20;     // panel top offset (px)
input int    InpPanelMaxPx  = 460;    // max heat map side (px); cell size adapts
input int    InpPanelMaxSys = 64;     // skip the panel above this many systems (object load)
input int    InpMCSeed      = 0;      // Monte Carlo seed; 0 = random, any other value = repeatable

long     g_magics[];        // unique magic numbers (sorted)
long     g_keys[];          // unique period keys (sorted)
double   g_pnl[];           // [magic x period] flattened: idx = m*nK + k
int      g_trades[];        // closed-trade count per magic
int      g_rep[];           // indices of reported magics
double   g_comb[];          // combined period P/L (reported magics only)

//+------------------------------------------------------------------+
long GrainKey(const datetime t)
  {
   if(InpGrain == GRAIN_MONTHLY)
     {
      MqlDateTime dt; TimeToStruct(t, dt);
      return (long)dt.year*100 + dt.mon;
     }
   long dayIdx = (long)t / 86400;
   if(InpGrain == GRAIN_DAILY) return dayIdx;
   MqlDateTime dt; TimeToStruct(t, dt);
   int shift = (dt.day_of_week == 0) ? 6 : dt.day_of_week - 1; // to Monday
   return dayIdx - shift;
  }
//+------------------------------------------------------------------+
string KeyToStr(const long key)
  {
   if(InpGrain == GRAIN_MONTHLY)
      return StringFormat("%04d.%02d", (int)(key/100), (int)(key%100));
   datetime t = (datetime)(key * 86400);
   string s = TimeToString(t, TIME_DATE);
   if(InpGrain == GRAIN_WEEKLY) return "w-" + s;
   return s;
  }
//+------------------------------------------------------------------+
string GrainName()
  {
   if(InpGrain == GRAIN_MONTHLY) return "monthly";
   if(InpGrain == GRAIN_WEEKLY)  return "weekly";
   return "daily";
  }
//+------------------------------------------------------------------+
int FindOrAppendLong(long &arr[], const long v)
  {
   int n = ArraySize(arr);
   for(int i = 0; i < n; i++) if(arr[i] == v) return i;
   ArrayResize(arr, n + 1);
   arr[n] = v;
   return n;
  }
//+------------------------------------------------------------------+
void SortLong(long &arr[])
  {
   int n = ArraySize(arr);
   for(int i = 1; i < n; i++)
     {
      long key = arr[i]; int j = i - 1;
      while(j >= 0 && arr[j] > key) { arr[j+1] = arr[j]; j--; }
      arr[j+1] = key;
     }
  }
//+------------------------------------------------------------------+
double MaxDD(const double &cum[])
  {
   double peak = 0.0, dd = 0.0;
   for(int i = 0; i < ArraySize(cum); i++)
     {
      if(cum[i] > peak) peak = cum[i];
      double d = peak - cum[i];
      if(d > dd) dd = d;
     }
   return dd;
  }
//+------------------------------------------------------------------+
double Pearson(const double &x[], const double &y[])
  {
   int n = ArraySize(x);
   if(n < 2) return 0.0;
   double mx = 0, my = 0;
   for(int i = 0; i < n; i++) { mx += x[i]; my += y[i]; }
   mx /= n; my /= n;
   double sxy = 0, sxx = 0, syy = 0;
   for(int i = 0; i < n; i++)
     {
      double dx = x[i] - mx, dy = y[i] - my;
      sxy += dx*dy; sxx += dx*dx; syy += dy*dy;
     }
   if(sxx <= 0 || syy <= 0) return 0.0;
   return sxy / MathSqrt(sxx*syy);
  }
//+------------------------------------------------------------------+
double PercentileOf(const double &sorted[], const double v)
  {
   int n = ArraySize(sorted), c = 0;
   for(int i = 0; i < n; i++) if(sorted[i] <= v) c++;
   return n > 0 ? (double)c/n : 0.0;
  }
//+------------------------------------------------------------------+
//| Axis label for a reported system: masked ordinal or raw magic.   |
//+------------------------------------------------------------------+
string SysLabel(const int rank, const long magic)
  {
   if(InpMaskMagics) return StringFormat("S%02d", rank + 1);
   return (string)magic;
  }
//+------------------------------------------------------------------+
//| Correlation heat map panel.                                      |
//| rho[] is the flattened nR x nR matrix already computed above, so |
//| the panel never recomputes anything - it only paints.            |
//+------------------------------------------------------------------+
void DrawCorrPanel(const double &rho[], const int nR, const double avgAbs,
                   const int pairs, const double shareLow)
  {
   //--- object load guard: the grid costs nR^2 rectangles. Past a few
   //--- thousand the terminal redraw becomes visibly slow, so above the
   //--- limit the CSV export is the better route and the panel is skipped.
   if(nR > InpPanelMaxSys)
     {
      PrintFormat("Panel skipped: %d systems would need %d cells (limit %d systems). "
                  "Use PCA_CorrMatrix.csv for the heat map, or raise InpPanelMaxSys.",
                  nR, nR*nR, InpPanelMaxSys);
      return;
     }

   //--- small portfolios get bigger cells so the panel is never half empty;
   //--- large ones shrink toward 3 px so the grid still fits the chart
   int cellCap = (nR <= 12) ? 28 : 16;
   int cell = InpPanelMaxPx / nR;
   if(cell > cellCap) cell = cellCap;
   if(cell < 3)       cell = 3;
   int grid = cell * nR;

   int padL = 46, padTitle = 24, padAxis = 16, padR = 18, padB = 96;
   int padT = padTitle + padAxis;
   int panW = padL + grid + padR;
   if(panW < 240) panW = 240;          // legend strip and title bar must fit
   int panH = padT + grid + padB;
   int x0 = InpPanelX, y0 = InpPanelY;

   VAPanelRect(VAP_PFX + "body", x0, y0, panW, panH, VAP_INK, true, VAP_EDGE);
   //--- short title on the left, grain on the right: the two can never
   //--- collide even at the 240 px minimum width. Counts and averages
   //--- live in the stats block under the legend.
   VAPanelTitle(VAP_PFX, x0, y0, panW, "PORTFOLIO CORRELATION",
                GrainName() + " P/L");

   int gx = x0 + padL, gy = y0 + padT;
   VAPanelRect(VAP_PFX + "plot", gx - 1, gy - 1, grid + 2, grid + 2, VAP_FIELD);

   for(int a = 0; a < nR; a++)
      for(int b = 0; b < nR; b++)
         VAPanelRect(StringFormat("%sc%d_%d", VAP_PFX, a, b),
                     gx + b*cell, gy + a*cell, cell, cell, VAPanelRamp(rho[a*nR + b]));

   //--- both axes are labelled; a matrix with only one labelled side is
   //--- guesswork for the reader. Labels thin out so they never collide.
   int every = (int)MathCeil(nR / 14.0);
   if(every < 1) every = 1;
   if(every * cell < 22) every = (int)MathCeil(22.0 / cell);
   for(int a = 0; a < nR; a += every)
     {
      string lab = SysLabel(a, g_magics[g_rep[a]]);
      VAPanelLabel(StringFormat("%sry%d", VAP_PFX, a), gx - 6, gy + a*cell + cell/2,
                   lab, VAP_TEXT, 7, VAP_FONT, ANCHOR_RIGHT_UPPER);
      VAPanelLabel(StringFormat("%srx%d", VAP_PFX, a), gx + a*cell + cell/2, gy - padAxis + 2,
                   lab, VAP_TEXT, 7, VAP_FONT, ANCHOR_UPPER);
     }

   //--- legend on one line, stats on the next: the panel stays content-wide
   int legY = gy + grid + 14;
   VAPanelLegend(VAP_PFX, gx, legY, 156, 9);
   VAPanelLabel(VAP_PFX + "stat1", gx, legY + 26,
                StringFormat("%d systems   %d pairs", nR, pairs),
                VAP_TEXT, 8, VAP_FONT_ALT);
   VAPanelLabel(VAP_PFX + "stat2", gx, legY + 44,
                StringFormat("avg |rho| %.2f   %.0f%% below 0.30", avgAbs, 100.0*shareLow),
                VAP_ACCENT, 8, VAP_FONT_ALT);
   VAPanelLabel(VAP_PFX + "mark", x0 + panW - 10, y0 + panH - 17,
                "VETERAN ARMY", VAP_MUTED, 7, VAP_FONT_ALT, ANCHOR_RIGHT_UPPER);
   VAPanelFinish();
   PrintFormat("Heat map drawn: %d x %d px, cell %d px, %d objects%s.",
               panW, panH, cell, nR*nR + 2*(int)MathCeil(nR/(double)every) + 52,
               InpMaskMagics ? ", systems masked" : "");
   Print("Panel objects stay on the chart after the script ends. "
         "Rerun with InpDrawPanel = false to remove them.");
  }
//+------------------------------------------------------------------+
void OnStart()
  {
   //--- input validation: every one of these would otherwise produce
   //--- a divide-by-zero, an out-of-range read or a meaningless table
   int    mcRuns = InpMCRuns;
   int    minTr  = InpMinTrades;
   double refBal = InpRefBalance;
   if(mcRuns < 100)   { PrintFormat("InpMCRuns %d is too low - using 100.", InpMCRuns);        mcRuns = 100;   }
   if(mcRuns > 100000){ PrintFormat("InpMCRuns %d is too high - using 100000.", InpMCRuns);    mcRuns = 100000;}
   if(minTr  < 1)     { PrintFormat("InpMinTrades %d is invalid - using 1.", InpMinTrades);    minTr  = 1;     }
   if(refBal <= 0.0)  { PrintFormat("InpRefBalance %.2f is invalid - using 10000.", InpRefBalance); refBal = 10000.0; }

   //--- always clear our own objects, even when the panel is switched
   //--- off, so a previous run never leaves a stale panel behind
   VAPanelClear(VAP_PFX);

   if(!HistorySelect(0, TimeCurrent()))
     { Print("HistorySelect failed"); return; }

   //--- pass 1: collect closing deals, unique magics and period keys
   int total = HistoryDealsTotal();
   long tmpMagic[]; long tmpKey[]; double tmpProfit[]; bool tmpClose[];
   for(int i = 0; i < total; i++)
     {
      ulong tk = HistoryDealGetTicket(i);
      if(tk == 0) continue;
      long dtype = HistoryDealGetInteger(tk, DEAL_TYPE);
      if(dtype != DEAL_TYPE_BUY && dtype != DEAL_TYPE_SELL) continue;
      //--- EVERY buy/sell deal is taken, entry deals included. Most brokers
      //--- charge commission on the entry as well as on the exit; counting
      //--- only exit deals silently understates cost and overstates net.
      long entry = HistoryDealGetInteger(tk, DEAL_ENTRY);
      long mg = HistoryDealGetInteger(tk, DEAL_MAGIC);
      double pr = HistoryDealGetDouble(tk, DEAL_PROFIT)
                + HistoryDealGetDouble(tk, DEAL_SWAP)
                + HistoryDealGetDouble(tk, DEAL_COMMISSION);
      long key = GrainKey((datetime)HistoryDealGetInteger(tk, DEAL_TIME));
      bool isClose = (entry == DEAL_ENTRY_OUT || entry == DEAL_ENTRY_INOUT
                      || entry == DEAL_ENTRY_OUT_BY);
      int n = ArraySize(tmpMagic);
      ArrayResize(tmpMagic, n+1); ArrayResize(tmpKey, n+1);
      ArrayResize(tmpProfit, n+1); ArrayResize(tmpClose, n+1);
      tmpMagic[n] = mg; tmpKey[n] = key; tmpProfit[n] = pr; tmpClose[n] = isClose;
      FindOrAppendLong(g_magics, mg);
      FindOrAppendLong(g_keys, key);
     }
   SortLong(g_magics); SortLong(g_keys);
   int nM = ArraySize(g_magics), nK = ArraySize(g_keys);
   int minB = (InpGrain == GRAIN_MONTHLY) ? 6 : (InpGrain == GRAIN_WEEKLY) ? 12 : 30;
   if(nM < 2 || nK < minB)
     {
      PrintFormat("Need at least 2 magics and %d %s periods. Found %d magics / %d periods.",
                  minB, GrainName(), nM, nK);
      return;
     }

   //--- pass 2: fill period matrix and trade counts
   ArrayResize(g_pnl, nM*nK); ArrayInitialize(g_pnl, 0.0);
   ArrayResize(g_trades, nM); ArrayInitialize(g_trades, 0);
   for(int i = 0; i < ArraySize(tmpMagic); i++)
     {
      int m = FindOrAppendLong(g_magics, tmpMagic[i]);
      int k = FindOrAppendLong(g_keys, tmpKey[i]);
      g_pnl[m*nK + k] += tmpProfit[i];
      if(tmpClose[i]) g_trades[m]++;   // count round turns, not raw deals
     }

   //--- reported set
   for(int m = 0; m < nM; m++)
      if(g_trades[m] >= minTr)
        {
         int r = ArraySize(g_rep);
         ArrayResize(g_rep, r+1);
         g_rep[r] = m;
        }
   int nR = ArraySize(g_rep);
   Print("=== Portfolio Correlation Analyzer v1.30 ===============");
   PrintFormat("Granularity: %s | magics found: %d | reported (>= %d trades): %d | periods: %d",
               GrainName(), nM, minTr, nR, nK);
   if(nR < 2)
     { Print("Fewer than 2 magics pass the min-trades filter. Lower InpMinTrades and rerun."); return; }
   for(int r = 0; r < nR; r++)
      if(g_magics[g_rep[r]] == 0)
        { Print("NOTE: magic 0 is included. On most terminals that bucket holds manual trades and any EA left on the default magic - it is not necessarily one system."); break; }

   //--- combined period series (reported magics only)
   ArrayResize(g_comb, nK); ArrayInitialize(g_comb, 0.0);
   for(int r = 0; r < nR; r++)
     {
      int m = g_rep[r];
      for(int k = 0; k < nK; k++) g_comb[k] += g_pnl[m*nK + k];
     }

   //--- sparsity advisory for fine grains
   if(InpGrain != GRAIN_MONTHLY)
     {
      long zc = 0;
      for(int r = 0; r < nR; r++)
        {
         int m = g_rep[r];
         for(int k = 0; k < nK; k++) if(g_pnl[m*nK + k] == 0.0) zc++;
        }
      double zshare = (double)zc / (double)(nR*nK);
      if(zshare > 0.5)
         PrintFormat("NOTE: %.0f%% of %s cells are zero (no trades). Sparse series pull correlations toward 0; for slow systems prefer weekly or monthly.",
                     100.0*zshare, GrainName());
     }

   //--- standalone vs combined drawdown (period resolution)
   double sumSolo = 0.0;
   for(int r = 0; r < nR; r++)
     {
      int m = g_rep[r];
      double cum[]; ArrayResize(cum, nK);
      double c = 0.0;
      for(int k = 0; k < nK; k++) { c += g_pnl[m*nK + k]; cum[k] = c; }
      double dd = MaxDD(cum);
      sumSolo += dd;
      PrintFormat("magic %-12I64d trades %-5d net %10.2f  maxDD %10.2f",
                  g_magics[m], g_trades[m], c, dd);
     }
   double combCum[]; ArrayResize(combCum, nK);
   double cc = 0.0;
   for(int k = 0; k < nK; k++) { cc += g_comb[k]; combCum[k] = cc; }
   double combDD = MaxDD(combCum);
   Print("--------------------------------------------------------");
   PrintFormat("Sum of %d standalone maxDD : %12.2f", nR, sumSolo);
   PrintFormat("Combined portfolio maxDD   : %12.2f", combDD);
   if(combDD > 0)
      PrintFormat("COMPRESSION RATIO          : %12.1fx", sumSolo/combDD);
   else
      Print("Combined drawdown is zero - compression ratio not defined.");

   //--- correlation matrix (reported magics only)
   PrintFormat("--- Pairwise Pearson correlation (%s P/L) ---------", GrainName());
   string hdr = "          ";
   for(int r = 0; r < nR; r++) hdr += StringFormat(" %6I64d", g_magics[g_rep[r]]);
   Print(hdr);
   double sumAbs = 0.0; int pairs = 0; int lowPairs = 0; double best = -2.0; int bi = -1, bj = -1;
   double rhoM[]; ArrayResize(rhoM, nR*nR); ArrayInitialize(rhoM, 0.0);
   double xa[]; ArrayResize(xa, nK);
   double xb[]; ArrayResize(xb, nK);
   for(int ra = 0; ra < nR; ra++)
     {
      int a = g_rep[ra];
      for(int k = 0; k < nK; k++) xa[k] = g_pnl[a*nK + k];
      string row = StringFormat("%-10I64d", g_magics[a]);
      for(int rb = 0; rb < nR; rb++)
        {
         int b = g_rep[rb];
         for(int k = 0; k < nK; k++) xb[k] = g_pnl[b*nK + k];
         double rho = Pearson(xa, xb);
         rhoM[ra*nR + rb] = rho;
         row += StringFormat(" %6.2f", rho);
         if(rb > ra)
           {
            sumAbs += MathAbs(rho); pairs++;
            if(MathAbs(rho) < 0.30) lowPairs++;
            if(rho > best) { best = rho; bi = a; bj = b; }
           }
        }
      Print(row);
     }
   double avgAbs = 0.0, shareLow = 0.0;
   if(pairs > 0)
     {
      avgAbs   = sumAbs / pairs;
      shareLow = (double)lowPairs / pairs;
      PrintFormat("Average |rho| over %d pairs : %.3f", pairs, avgAbs);
      PrintFormat("Pairs with |rho| below 0.30: %d of %d (%.0f%%)", lowPairs, pairs, 100.0*shareLow);
      PrintFormat("Most correlated pair       : %I64d vs %I64d (rho = %.2f)",
                  g_magics[bi], g_magics[bj], best);
     }

   //--- chart panel (paints the matrix computed above; recomputes nothing)
   if(InpDrawPanel && pairs > 0) DrawCorrPanel(rhoM, nR, avgAbs, pairs, shareLow);

   //--- Monte Carlo: reshuffle combined period returns
   //--- a fixed seed makes the percentiles repeatable; two runs of the
   //--- same history then produce the same numbers, which matters when
   //--- the figure ends up in a report
   MathSrand(InpMCSeed != 0 ? InpMCSeed : (int)GetTickCount());
   double dds[]; ArrayResize(dds, mcRuns);
   double work[]; ArrayResize(work, nK);
   double cum2[]; ArrayResize(cum2, nK);
   for(int run = 0; run < mcRuns; run++)
     {
      ArrayCopy(work, g_comb);
      for(int k = nK-1; k > 0; k--)
        {
         int j = MathRand() % (k+1);
         double t = work[k]; work[k] = work[j]; work[j] = t;
        }
      double c = 0.0;
      for(int k = 0; k < nK; k++) { c += work[k]; cum2[k] = c; }
      dds[run] = MaxDD(cum2);
     }
   ArraySort(dds);
   double p50 = dds[(int)(0.50*(mcRuns-1))];
   double p90 = dds[(int)(0.90*(mcRuns-1))];
   double p95 = dds[(int)(0.95*(mcRuns-1))];
   PrintFormat("--- Monte Carlo (%s-return reshuffle) -------------", GrainName());
   PrintFormat("runs %d | DD p50 %.2f | p90 %.2f | p95 %.2f (%.1f%% of %.0f)",
               mcRuns, p50, p90, p95, 100.0*p95/refBal, refBal);
   PrintFormat("Single-path DD sits at the %.0f%% percentile of the MC cloud",
               100.0*PercentileOf(dds, combDD));

   //--- CSV export
   if(InpExportCSV)
     {
      //--- prefixed so the files never collide with another tool's export
      string pnlName = "PCA_MonthlyPnl.csv";
      if(InpGrain == GRAIN_WEEKLY) pnlName = "PCA_WeeklyPnl.csv";
      if(InpGrain == GRAIN_DAILY)  pnlName = "PCA_DailyPnl.csv";
      int h = FileOpen(pnlName, FILE_WRITE|FILE_CSV|FILE_ANSI, ';');
      if(h != INVALID_HANDLE)
        {
         string line = "period";
         for(int r = 0; r < nR; r++) line += ";" + SysLabel(r, g_magics[g_rep[r]]);
         FileWrite(h, line);
         for(int k = 0; k < nK; k++)
           {
            line = KeyToStr(g_keys[k]);
            for(int r = 0; r < nR; r++)
               line += ";" + DoubleToString(g_pnl[g_rep[r]*nK + k], 2);
            FileWrite(h, line);
           }
         FileClose(h);
         Print("Exported MQL5\\Files\\" + pnlName);
        }
      int h2 = FileOpen("PCA_CorrMatrix.csv", FILE_WRITE|FILE_CSV|FILE_ANSI, ';');
      if(h2 != INVALID_HANDLE)
        {
         string line = "system";
         for(int r = 0; r < nR; r++) line += ";" + SysLabel(r, g_magics[g_rep[r]]);
         FileWrite(h2, line);
         for(int ra = 0; ra < nR; ra++)
           {
            //--- reuse the matrix printed above: one source of truth, so the
            //--- CSV, the log table and the heat map can never disagree
            line = SysLabel(ra, g_magics[g_rep[ra]]);
            for(int rb = 0; rb < nR; rb++)
               line += ";" + DoubleToString(rhoM[ra*nR + rb], 3);
            FileWrite(h2, line);
           }
         FileClose(h2);
         Print("Exported MQL5\\Files\\PCA_CorrMatrix.csv (heatmap-ready)");
        }
     }
   Print("=== done ===============================================");
  }
//+------------------------------------------------------------------+
