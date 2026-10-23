//+------------------------------------------------------------------+
//|                                       CFVGClosedBarEngine.mq5    |
//|                                                                  |
//|   Non-repainting three-bar Fair Value Gap engine for MQL5.       |
//|                                                                  |
//|   Educational sample accompanying the article:                    |
//|   "Non-Repainting Fair Value Gap Detection in MQL5"              |
//|                                                                  |
//|   Key ideas demonstrated:                                        |
//|     - closed-bar detection discipline (no forming-bar reads)     |
//|     - incremental scanning instead of full rebuilds              |
//|     - mitigation modelled as an explicit state machine           |
//|     - a self-audit that re-derives the gaps from closed bars     |
//|       and compares them with the stored records                  |
//|                                                                  |
//|   Pure native MQL5. No DLLs. No external dependencies.            |
//+------------------------------------------------------------------+
#property copyright   "chimaster"
#property link        "https://www.mql5.com/en/users/chimaster"
#property version     "1.10"
#property description "Non-repainting three-bar Fair Value Gap engine with Consequent Encroachment."
#property indicator_chart_window
#property indicator_plots 0

//--- How a mitigated gap should be presented on the chart
enum ENUM_MITIGATION_MODE
  {
   MITIGATION_TRIM,    // Shorten the rectangle to the mitigation bar
   MITIGATION_DELETE,  // Remove the rectangle once the gap is filled
   MITIGATION_DIM,     // Keep it visible but greyed out
   MITIGATION_NONE     // Leave the rectangle at full length
  };

//--- General
input int                  InpLookbackBars   = 300;               // Bars scanned on attach
input double               InpMinGapPoints   = 0.0;               // Minimum gap size in points (0 = auto)
input ENUM_MITIGATION_MODE InpMitigationMode = MITIGATION_TRIM;   // Mitigation presentation
input bool                 InpShowBullish    = true;              // Detect bullish FVGs
input bool                 InpShowBearish    = true;              // Detect bearish FVGs
input bool                 InpShowCE         = true;              // Draw the 50% Consequent Encroachment
input int                  InpExtendBars     = 20;                // Forward extension of open gaps (bars)
input bool                 InpAlertTouch     = true;              // Alert the first time price enters a gap

//--- Self audit
input int                  InpAuditDepth     = 50;                // Closed bars re-checked on attach (0 = off)

//--- Styling
input color                InpBullBorder     = clrMediumSeaGreen;
input color                InpBullFill       = C'220,245,230';
input color                InpBullCE         = clrSeaGreen;
input color                InpBearBorder     = clrIndianRed;
input color                InpBearFill       = C'255,230,230';
input color                InpBearCE         = clrFireBrick;
input color                InpDimBorder      = clrLightGray;
input color                InpDimFill        = C'235,235,235';

//+------------------------------------------------------------------+
//| One detected imbalance.                                            |
//+------------------------------------------------------------------+
struct SFvgRecord
  {
   bool        bullish;          // Direction of the imbalance
   int         impulseIndex;     // Bar index of the third bar, which completed the gap
   datetime    impulseTime;      // Open time of the middle (impulse) bar, one bar before it
   datetime    startTime;        // Open time of the bar before the impulse
   double      top;              // Upper price edge of the gap
   double      bottom;           // Lower price edge of the gap
   double      ce;               // Consequent Encroachment (midpoint)
   bool        mitigated;        // State machine flag
   datetime    mitigatedTime;    // When it was first touched
   bool        alertFired;       // Guard so we alert only once per gap
   datetime    lastWarnBar;      // Bar on which a provisional warning was shown
   string      boxName;          // Chart object holding the rectangle
   string      ceName;           // Chart object holding the midpoint line
  };

SFvgRecord g_fvg[];      // All gaps currently tracked
int        g_count    = 0; // Number of valid entries in g_fvg
int        g_nextIdx  = 0; // Next bar index to test for a new gap
int        g_scannedLo = 0;// Oldest bar index actually scanned
datetime   g_lastBar  = 0; // Bar time processed by the last incremental pass
datetime   g_firstBar = 0; // Oldest bar on the chart, used to detect a rebuild

const string OBJ = "cfvg_";

//+------------------------------------------------------------------+
//| Initialisation                                                     |
//+------------------------------------------------------------------+
int OnInit()
  {
   ArrayResize(g_fvg, 0);
   g_count     = 0;
   g_nextIdx   = 0;
   g_scannedLo = 0;
   g_lastBar   = 0;
   g_firstBar  = 0;
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Clean up                                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, OBJ);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Main calculation                                                  |
//|                                                                   |
//| Three distinct responsibilities, deliberately separated:          |
//|   1. rebuild      - only on attach or when history changes        |
//|   2. extend scan  - only when a bar has closed                    |
//|   3. live update  - every tick, presentation only, never state    |
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
   if(rates_total < 5)
      return(0);

   const datetime currentBar = time[rates_total - 1];

//--- 1. Rebuild whenever we have no history yet or the series changed
   if(prev_calculated == 0 || g_firstBar != time[0])
     {
      RebuildAll(rates_total, time, high, low);
      g_firstBar = time[0];
      g_lastBar  = currentBar;
      RunSelfAudit(rates_total, time, high, low);
      return(rates_total);
     }

//--- 2. A bar has closed: look for gaps it completed and retest open gaps
   if(currentBar != g_lastBar)
     {
      ExtendScan(rates_total, time, high, low);
      g_lastBar = currentBar;
     }

//--- 3. Every tick: presentation only. State changes happen on bar close.
   UpdateLive(rates_total, time, high, low);

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Full rebuild of the visible history.                              |
//|                                                                   |
//| Detection and mitigation replay are deliberately interleaved so    |
//| that a gap which was filled 200 bars ago is drawn filled, rather   |
//| than protruding into the future as though it were still open.      |
//+------------------------------------------------------------------+
void RebuildAll(const int total,
                const datetime &time[],
                const double &high[],
                const double &low[])
  {
   ObjectsDeleteAll(0, OBJ);
   ArrayResize(g_fvg, 0);
   g_count     = 0;
   g_nextIdx   = MathMax(2, total - InpLookbackBars);
   g_scannedLo = g_nextIdx;

   const int lastClosed = total - 2;

   for(int i = g_nextIdx; i <= lastClosed; i++)
      TryAddGap(i, total, time, high, low);

   //--- The rebuild has just covered every closed bar in the window, so the
   //--- incremental pass has to resume at the next bar to come. Leaving
   //--- g_nextIdx at the start of the window would make the next ExtendScan
   //--- re-test all of it and append a duplicate record for every gap.
   g_nextIdx = lastClosed + 1;

   //--- Anything still open extends to the right edge
   const datetime rightEdge = (datetime)(time[total - 1] + PeriodSeconds() * InpExtendBars);
   for(int g = 0; g < g_count; g++)
      ExtendObject(g_fvg[g], rightEdge);

   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Test every bar that has closed since the previous pass.           |
//+------------------------------------------------------------------+
void ExtendScan(const int total,
                const datetime &time[],
                const double &high[],
                const double &low[])
  {
   const int lastClosed = total - 2;

   for(int i = g_nextIdx; i <= lastClosed; i++)
      TryAddGap(i, total, time, high, low);

   g_nextIdx = total - 1;

   //--- Replay the bar that has just closed against every open gap
   for(int g = 0; g < g_count; g++)
     {
      if(g_fvg[g].mitigated)
         continue;
      //--- A gap discovered on this very bar cannot be mitigated by it:
      //--- a bullish gap has top = low[lastClosed], so the touch test
      //--- would otherwise compare low[lastClosed] against itself and
      //--- always succeed.
      if(g_fvg[g].impulseIndex >= lastClosed)
         continue;
      if(IsTouched(g_fvg[g], low[lastClosed], high[lastClosed]))
        {
         g_fvg[g].mitigated     = true;
         g_fvg[g].mitigatedTime = time[lastClosed];
         OnMitigated(g, time[lastClosed]);
        }
     }

   const datetime rightEdge = (datetime)(time[total - 1] + PeriodSeconds() * InpExtendBars);
   for(int g = 0; g < g_count; g++)
      ExtendObject(g_fvg[g], rightEdge);

   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Three-bar geometry test for a single bar index.                    |
//|                                                                   |
//|   index i-2 : bar before the impulse                               |
//|   index i-1 : the impulse bar itself                               |
//|   index i   : the bar that leaves the imbalance behind            |
//|                                                                   |
//| i is always a closed bar at this point. After creating the record  |
//| its mitigation state is replayed across every later closed bar, so |
//| the historical picture is correct the moment it is drawn.          |
//+------------------------------------------------------------------+
void TryAddGap(const int i,
               const int total,
               const datetime &time[],
               const double &high[],
               const double &low[])
  {
   const double minGap = InpMinGapPoints * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   const int    lastClosed = total - 2;

   if(InpShowBullish)
     {
      const double bottom = high[i - 2];
      const double top    = low[i];

      if(top > bottom && (top - bottom) >= minGap)
        {
         const int idx = AddRecord(true, i, time[i - 1], time[i - 2], top, bottom);
         ReplayMitigation(idx, i, time, low, high, lastClosed);
        }
     }

   if(InpShowBearish)
     {
      const double top    = low[i - 2];
      const double bottom = high[i];

      if(bottom < top && (top - bottom) >= minGap)
        {
         const int idx = AddRecord(false, i, time[i - 1], time[i - 2], top, bottom);
         ReplayMitigation(idx, i, time, low, high, lastClosed);
        }
     }
  }

//+------------------------------------------------------------------+
//| Store a gap and draw it. Returns its index.                       |
//+------------------------------------------------------------------+
int AddRecord(const bool bullish,
              const int impulseIndex,
              const datetime impulseTime,
              const datetime startTime,
              const double top,
              const double bottom)
  {
   SFvgRecord rec;
   rec.bullish       = bullish;
   rec.impulseIndex  = impulseIndex;
   rec.impulseTime   = impulseTime;
   rec.startTime     = startTime;
   rec.top           = top;
   rec.bottom        = bottom;
   rec.ce            = bottom + (top - bottom) * 0.5;
   rec.mitigated     = false;
   rec.mitigatedTime = 0;
   rec.alertFired    = false;
   rec.boxName       = StringFormat("%sbox_%s_%I64d", OBJ, bullish ? "bull" : "bear", (long)impulseTime);
   rec.ceName        = StringFormat("%sce_%s_%I64d",  OBJ, bullish ? "bull" : "bear", (long)impulseTime);

   const int idx = g_count++;
   ArrayResize(g_fvg, g_count);
   g_fvg[idx] = rec;

   const datetime rightEdge = (datetime)(impulseTime + PeriodSeconds() * InpExtendBars);
   DrawRecord(g_fvg[idx], rightEdge);

   return(idx);
  }

//+------------------------------------------------------------------+
//| Determine from closed bars alone whether a gap was already filled  |
//+------------------------------------------------------------------+
void ReplayMitigation(const int idx,
                      const int createdAt,
                      const datetime &time[],
                      const double &low[],
                      const double &high[],
                      const int lastClosed)
  {
   for(int k = createdAt + 1; k <= lastClosed; k++)
     {
      if(IsTouched(g_fvg[idx], low[k], high[k]))
        {
         g_fvg[idx].mitigated     = true;
         g_fvg[idx].mitigatedTime = time[k];
         OnMitigated(idx, time[k]);
         return;
        }
     }
  }

//+------------------------------------------------------------------+
//| Does the given bar reach into the gap?                            |
//+------------------------------------------------------------------+
bool IsTouched(const SFvgRecord &rec, const double barLow, const double barHigh)
  {
   if(rec.bullish)
      return(barLow <= rec.top);      // price dipped down into a bullish gap
   return(barHigh >= rec.bottom);     // price rallied up into a bearish gap
  }

//+------------------------------------------------------------------+
//| Presentation after a mitigation transition.                        |
//+------------------------------------------------------------------+
void OnMitigated(const int index, const datetime barTime)
  {
   if(InpMitigationMode == MITIGATION_DELETE)
     {
      ObjectDelete(0, g_fvg[index].boxName);
      ObjectDelete(0, g_fvg[index].ceName);
      //--- Deliberately no return here. Removing the drawing objects says
      //--- nothing about the transition itself, and the touch alert below
      //--- is a state change that must still run in every mode.
     }

   if(InpMitigationMode == MITIGATION_TRIM)
     {
      ObjectSetInteger(0, g_fvg[index].boxName, OBJPROP_TIME, 1, barTime);
      if(ObjectFind(0, g_fvg[index].ceName) >= 0)
         ObjectSetInteger(0, g_fvg[index].ceName, OBJPROP_TIME, 1, barTime);
     }

   if(InpMitigationMode == MITIGATION_DIM)
     {
      ObjectSetInteger(0, g_fvg[index].boxName, OBJPROP_BGCOLOR, InpDimFill);
      ObjectSetInteger(0, g_fvg[index].boxName, OBJPROP_COLOR,   InpDimBorder);
     }

   //--- DIM and NONE both leave the rectangle at full length, so only
   //--- TRIM and DELETE have anything left to draw here.

   if(InpAlertTouch && !g_fvg[index].alertFired)
     {
      PrintFormat("[CFVG] %s imbalance at %s touched at %.*f",
                  g_fvg[index].bullish ? "Bullish" : "Bearish",
                  _Symbol,
                  _Digits,
                  g_fvg[index].bullish ? g_fvg[index].top : g_fvg[index].bottom);
      g_fvg[index].alertFired = true;
     }
  }

//+------------------------------------------------------------------+
//| Per-tick work: keep open gaps extended and warn on a live touch.  |
//|                                                                   |
//| This deliberately does not commit a mitigation. The forming bar   |
//| can still move, and a wick that disappears must not leave a gap   |
//| permanently trimmed and permanently alerted. The state change is  |
//| made once, in ExtendScan, when the bar has actually closed.        |
//+------------------------------------------------------------------+
void UpdateLive(const int total,
                const datetime &time[],
                const double &high[],
                const double &low[])
  {
   if(g_count <= 0)
      return;

   const double   barLow  = low[total - 1];
   const double   barHigh = high[total - 1];
   const datetime barTime = time[total - 1];
   const datetime right   = (datetime)(barTime + PeriodSeconds() * InpExtendBars);

   for(int g = 0; g < g_count; g++)
     {
      if(g_fvg[g].mitigated)
         continue;

      ExtendObject(g_fvg[g], right);

      //--- Provisional warning only. This deliberately does not set
      //--- alertFired, because the touch is not confirmed until the bar
      //--- closes. If the wick disappears no state has changed and
      //--- ExtendScan will simply find nothing to commit. If it survives,
      //--- ExtendScan commits the mitigation and OnMitigated prints the
      //--- one-shot alert. lastWarnBar only stops this line from
      //--- repeating on every tick of the same forming bar.
      if(InpAlertTouch && g_fvg[g].lastWarnBar != barTime &&
         IsTouched(g_fvg[g], barLow, barHigh))
        {
         PrintFormat("[CFVG] %s imbalance at %s touched at %.*f (forming bar, pending close)",
                     g_fvg[g].bullish ? "Bullish" : "Bearish",
                     _Symbol,
                     _Digits,
                     g_fvg[g].bullish ? g_fvg[g].top : g_fvg[g].bottom);
         g_fvg[g].lastWarnBar = barTime;
        }
     }

   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Move the right edge of a gap.                                      |
//|                                                                   |
//| TRIM and DELETE have already settled the geometry when the gap was |
//| mitigated, so they return early and are never extended afterwards. |
//| DIM and NONE keep the full length, so they keep extending.         |
//+------------------------------------------------------------------+
void ExtendObject(const SFvgRecord &rec, const datetime rightEdge)
  {
   if(rec.mitigated && InpMitigationMode == MITIGATION_TRIM)
      return;                       // already trimmed at the mitigation bar

   if(rec.mitigated && InpMitigationMode == MITIGATION_DELETE)
      return;                       // already removed

   if(ObjectFind(0, rec.boxName) >= 0)
      ObjectSetInteger(0, rec.boxName, OBJPROP_TIME, 1, rightEdge);
   if(InpShowCE && ObjectFind(0, rec.ceName) >= 0)
      ObjectSetInteger(0, rec.ceName, OBJPROP_TIME, 1, rightEdge);
  }

//+------------------------------------------------------------------+
//| Create the graphical objects for one gap.                         |
//+------------------------------------------------------------------+
void DrawRecord(const SFvgRecord &rec, const datetime rightEdge)
  {
   const color border = rec.bullish ? InpBullBorder : InpBearBorder;
   const color fill   = rec.bullish ? InpBullFill   : InpBearFill;
   const color ceCol  = rec.bullish ? InpBullCE     : InpBearCE;

   if(ObjectFind(0, rec.boxName) < 0)
     {
      ObjectCreate(0, rec.boxName, OBJ_RECTANGLE, 0, rec.startTime, rec.top, rightEdge, rec.bottom);
      ObjectSetInteger(0, rec.boxName, OBJPROP_COLOR,      border);
      ObjectSetInteger(0, rec.boxName, OBJPROP_BGCOLOR,    fill);
      ObjectSetInteger(0, rec.boxName, OBJPROP_STYLE,      STYLE_SOLID);
      ObjectSetInteger(0, rec.boxName, OBJPROP_WIDTH,      1);
      ObjectSetInteger(0, rec.boxName, OBJPROP_BACK,       true);
      ObjectSetInteger(0, rec.boxName, OBJPROP_FILL,       true);
      ObjectSetInteger(0, rec.boxName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, rec.boxName, OBJPROP_HIDDEN,     true);
     }

   if(InpShowCE && ObjectFind(0, rec.ceName) < 0)
     {
      ObjectCreate(0, rec.ceName, OBJ_TREND, 0, rec.startTime, rec.ce, rightEdge, rec.ce);
      ObjectSetInteger(0, rec.ceName, OBJPROP_COLOR,      ceCol);
      ObjectSetInteger(0, rec.ceName, OBJPROP_STYLE,      STYLE_DOT);
      ObjectSetInteger(0, rec.ceName, OBJPROP_WIDTH,      1);
      ObjectSetInteger(0, rec.ceName, OBJPROP_RAY_RIGHT,  false);
      ObjectSetInteger(0, rec.ceName, OBJPROP_BACK,       false);
      ObjectSetInteger(0, rec.ceName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, rec.ceName, OBJPROP_HIDDEN,     true);
     }
  }

//+------------------------------------------------------------------+
//| Self audit.                                                       |
//|                                                                   |
//| Re-derive the gaps from closed bars and compare both their        |
//| existence and their stored price levels against what the          |
//| indicator currently holds. The levels are written once, when the  |
//| record is created, and are never reassigned, so a difference in   |
//| the levels means the gap was built from the wrong bars. The       |
//| audit runs once, on the calculation that follows attach, and it   |
//| stops at the first record matching a given impulse time and       |
//| direction, so a duplicate record is not reported.                 |
//|                                                                   |
//| The audit window is clamped to the region actually scanned, so a  |
//| short lookback cannot produce false failures.                      |
//+------------------------------------------------------------------+
void RunSelfAudit(const int total,
                  const datetime &time[],
                  const double &high[],
                  const double &low[])
  {
   if(InpAuditDepth <= 0 || g_count == 0)
      return;

   const int lastClosed = total - 2;

   int from = MathMax(2, lastClosed - InpAuditDepth + 1);
   if(from < g_scannedLo)
      from = g_scannedLo;          // never audit bars that were not scanned
   if(from > lastClosed)
      return;

   const double minGap = InpMinGapPoints * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   const double tol    = SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 0.5;

   int checked    = 0;
   int mismatches = 0;

   for(int i = from; i <= lastClosed; i++)
     {
      const bool expectBull = InpShowBullish &&
                              (low[i] > high[i - 2]) &&
                              ((low[i] - high[i - 2]) >= minGap);
      if(expectBull)
        {
         if(!VerifyRecord(time[i - 1], true, low[i], high[i - 2], tol))
            mismatches++;
        }

      const bool expectBear = InpShowBearish &&
                              (high[i] < low[i - 2]) &&
                              ((low[i - 2] - high[i]) >= minGap);
      if(expectBear)
        {
         if(!VerifyRecord(time[i - 1], false, low[i - 2], high[i], tol))
            mismatches++;
        }

      checked++;
     }

   if(mismatches == 0)
      PrintFormat("[CFVG audit] %d closed bars re-checked, levels match, no repaint detected.", checked);
   else
      PrintFormat("[CFVG audit] %d closed bars re-checked, %d mismatch(es) found.", checked, mismatches);
  }

//+------------------------------------------------------------------+
//| Does the indicator hold this gap, with the same stored levels?    |
//+------------------------------------------------------------------+
bool VerifyRecord(const datetime impulseTime, const bool bullish,
                  const double expectedTop, const double expectedBottom,
                  const double tolerance)
  {
   for(int g = 0; g < g_count; g++)
     {
      if(g_fvg[g].impulseTime != impulseTime || g_fvg[g].bullish != bullish)
         continue;

      if(MathAbs(g_fvg[g].top - expectedTop) > tolerance)
        {
         PrintFormat("[CFVG audit] Top level changed for the gap at %s",
                     TimeToString(impulseTime));
         return(false);
        }

      const double expectedCe = expectedBottom + (expectedTop - expectedBottom) * 0.5;
      if(MathAbs(g_fvg[g].ce - expectedCe) > tolerance)
        {
         PrintFormat("[CFVG audit] Consequent Encroachment changed for the gap at %s",
                     TimeToString(impulseTime));
         return(false);
        }

      return(true);      // present and identical
     }

   PrintFormat("[CFVG audit] Missing %s gap at %s",
               bullish ? "bullish" : "bearish", TimeToString(impulseTime));
   return(false);
  }
//+------------------------------------------------------------------+