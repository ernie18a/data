//+------------------------------------------------------------------+
//|                                       ArixisMarketRegimeMap.mq5  |
//|                              Arixis Market Regime Map - v1.00    |
//+------------------------------------------------------------------+
//
//  WHAT THIS IS
//    A closed-bar DESCRIPTION of the market environment in two separate
//    dimensions:
//      * directional regime : TREND_UP, TREND_DOWN, RANGE, TRANSITION
//      * volatility regime  : COMPRESSION, NORMAL, EXPANSION
//    plus a few continuous measurements and two clearly labelled heuristics.
//
//  WHAT THIS IS NOT
//    Not a trading signal, not a forecast, not optimised for profit.
//    The indicator has NO trading authority: it never sends, modifies or
//    closes orders or positions, uses no DLLs, no WebRequest, no files and
//    no terminal global variables.
//
//  SPECIFICATION
//    Every formula below implements the project's frozen mathematical
//    specification. Tags such as [S3.2] refer to its sections; tags such
//    as [API 4] refer to the public buffer contract. Both are summarised
//    in the comments next to the code they describe.
//
//  PUBLIC BUFFERS (read with CopyBuffer at shift 1)
//     0 REGIME              0 UNKNOWN, 1 TREND_UP, 2 TREND_DOWN, 3 RANGE, 4 TRANSITION
//     1 DIRECTION           +1 TREND_UP, -1 TREND_DOWN, 0 otherwise
//     2 VOL_REGIME          0 UNKNOWN, 1 COMPRESSION, 2 NORMAL, 3 EXPANSION
//     3 TREND_STRENGTH      0..100, noise-adjusted path efficiency
//     4 CONFIDENCE          0..100, heuristic distance from a state boundary
//     5 STABILITY           0..100, share of the last N bars in the current state
//     6 TRANSITION_PRESSURE 0..100, heuristic adverse drift-change evidence
//     7 TREND_Z             regression trend z-score (signed)
//     8 CHANGE_Z            drift-change z-score (signed)
//     9 VOL_PERCENTILE      0..100, rank of recent range among its own history
//    10 BARS_IN_REGIME      length of the current REGIME run (0 if UNKNOWN)
//    11 QUALITY_FLAGS       bitmask, see FLAG_* below (0 = fully valid bar)
//
//  NON-REPAINT CONTRACT [S9]
//    * Only CLOSED bars are classified. The forming bar holds EMPTY_VALUE
//      in every public buffer.
//    * Every value at bar t uses only bars <= t (trailing windows only).
//    * Features are finite-window functions recomputed from their window
//      (no running accumulators), so a bar's value does not depend on how
//      it was reached (full vs incremental calculation).
//
//  READING THE BUFFERS FROM ANOTHER PROGRAM
//    Use iCustom() + CopyBuffer() and read shift 1 (last closed bar).
//    Category codes are exact small integers: read with (int)MathRound(x).
//+------------------------------------------------------------------+
#property copyright   "Arixis Market Regime Map (open source)"
#property version     "1.00"
#property description "Non-repainting description of the market regime on closed bars:"
#property description "trend up / trend down / range / transition, and volatility compression / normal / expansion."
#property description "Descriptive only - not a trading signal, not a forecast."
#property description "Read buffers at shift 1. Forming bar = EMPTY_VALUE."

#property indicator_separate_window
#property indicator_minimum 0.0
#property indicator_maximum 1.0
#property indicator_height  46
#property indicator_buffers 23
#property indicator_plots   14

//--- the two strip plots (plots 12 and 13); colours are set in OnInit
#property indicator_type13  DRAW_COLOR_HISTOGRAM2
#property indicator_type14  DRAW_COLOR_HISTOGRAM2

//+------------------------------------------------------------------+
//| Public codes (frozen API v1)                                     |
//+------------------------------------------------------------------+
#define REGIME_UNKNOWN      0
#define REGIME_TREND_UP     1
#define REGIME_TREND_DOWN   2
#define REGIME_RANGE        3
#define REGIME_TRANSITION   4

#define VOL_UNKNOWN         0
#define VOL_COMPRESSION     1
#define VOL_NORMAL          2
#define VOL_EXPANSION       3

#define FLAG_INSUFFICIENT_HISTORY_DIRECTION   1
#define FLAG_INSUFFICIENT_HISTORY_VOLATILITY  2
#define FLAG_NONPOSITIVE_PRICE                4
#define FLAG_FLAT_PRICE                       8
#define FLAG_EXCESS_ZERO_RETURNS             16
#define FLAG_INCONSISTENT_BAR                32
#define FLAG_ENTRY_VETOED                    64

#define ARMM_VERSION "1.00"

//+------------------------------------------------------------------+
//| Inputs. Order of inputs 1..8 is part of the iCustom() contract.  |
//| NOTE: no "input group" declarations are used, because iCustom()  |
//| counts each group as a positional parameter and would shift the  |
//| documented input positions.                                      |
//+------------------------------------------------------------------+
//--- Model (changes the outputs)
input int    InpHorizonBars     = 30;    // Horizon N, bars (structural; a default, not an optimum)
input int    InpVolMemoryBars   = 250;   // Volatility memory L, bars (structural)
input double InpTrendEntryZ     = 2.0;   // Trend entry threshold, z units
input double InpTrendExitZ      = 1.0;   // Trend exit threshold, z units (< entry)
input double InpChangeEntryZ    = 2.5;   // Drift-change entry threshold, z units
input double InpChangeExitZ     = 1.0;   // Drift-change exit threshold, z units (< entry)
input double InpCompressionPct  = 15.0;  // Compression entry percentile (exit = entry + 20)
input double InpExpansionPct    = 85.0;  // Expansion entry percentile (exit = entry - 20)


//--- Display (never changes the outputs)
input bool   InpShowStrip       = true;          // Show regime strip in the subwindow
input bool   InpShowPanel       = true;          // Show dashboard panel on the chart
input ENUM_BASE_CORNER InpPanelCorner = CORNER_LEFT_UPPER; // Panel corner
input int    InpPanelX          = 12;            // Panel X offset, pixels
input int    InpPanelY          = 24;            // Panel Y offset, pixels
input bool   InpMinimalMode     = false;         // Minimal panel (regime + volatility only)
input bool   InpShadeChart      = false;         // Shade chart background by regime
input int    InpShadeMaxBars    = 300;           // Shading: most recent closed bars only
input int    InpShadeOpacityPct = 14;            // Shading strength, % blend into background
input int    InpStripWidth      = 3;             // Strip bar width, pixels
input color  InpColorTrendUp    = C'0,150,136';  // Colour: TREND_UP
input color  InpColorTrendDown  = C'229,92,74';  // Colour: TREND_DOWN
input color  InpColorRange      = C'120,132,148';// Colour: RANGE
input color  InpColorTransition = C'240,170,40'; // Colour: TRANSITION
input color  InpColorUnknown    = C'70,74,80';   // Colour: UNKNOWN
input color  InpColorCompress   = C'160,200,240';// Colour: COMPRESSION
input color  InpColorNormal     = C'80,130,200'; // Colour: NORMAL
input color  InpColorExpansion  = C'20,50,140';  // Colour: EXPANSION
input int    InpStabilityLowPct = 40;            // Stability text: LOW below this %
input int    InpStabilityHighPct= 75;            // Stability text: HIGH from this %


//--- Diagnostics (never changes the outputs)
input bool   InpDiagnostics     = false;         // Print calculation range, timing and memory to the Experts log

//+------------------------------------------------------------------+
//| Buffers                                                          |
//+------------------------------------------------------------------+
//--- public (0..11)
double BufRegime[];        // 0
double BufDirection[];     // 1
double BufVolRegime[];     // 2
double BufTrendStrength[]; // 3
double BufConfidence[];    // 4  heuristic
double BufStability[];     // 5
double BufPressure[];      // 6  heuristic
double BufTrendZ[];        // 7
double BufChangeZ[];       // 8
double BufVolPercentile[]; // 9
double BufBarsInRegime[];  // 10
double BufQualityFlags[];  // 11
//--- visual (12..17) - not part of the public contract
double BufStripRegHi[], BufStripRegLo[], BufStripRegClr[];
double BufStripVolHi[], BufStripVolLo[], BufStripVolClr[];
//--- calculation (18..22) - per-bar caches, each a pure function of its own bar(s)
double CalcLogClose[];     // ln C_t (0 for an invalid bar; never read through a valid window)
double CalcLogTR[];        // log true range l_t [S4.1]
double CalcVolLevel[];     // v_t = mean of the last n_V log true ranges [S4.1]
double CalcNonPosCount[];  // number of bars <= t with a non-positive price (exact integer)
double CalcInconsCount[];  // number of bars <= t whose High/Low do not bracket Open/Close

//+------------------------------------------------------------------+
//| Derived model constants (set in OnInit)                          |
//+------------------------------------------------------------------+
int    gN, gL, gNF, gNP, gNS, gNV;
int    gDirWindow;          // max(n_S, n_F + n_P, N - 1): bars of look-back for direction [S10.1]
int    gVolWindow;          // n_V + L: bars of look-back for the volatility state
double gKappa;              // exact null std factor of the OLS slope [S3.2]
double gSlopeDen;           // S_N = N(N^2 - 1)/12
double gEffFloor;           // e0 = 1/sqrt(N - 1), random-walk efficiency floor [S8.1]
double gThIn, gThOut, gBetaIn, gBetaOut;
double gPcIn, gPcOut, gPeIn, gPeOut;
const double gZeroFracMax = 0.5;     // z_max [S10.2]
double gSlopeW[];           // w_m = m(N-m)/(2 S_N), m = 1..N-1 (index m-1)
double gRetBuf[];           // scratch: weighted returns (leave-one-out of B)
double gRet[];              // the last n_S log returns of the bar being computed (index 0 = oldest)

//--- volatility percentile cache (performance only; never changes a result):
//    the L previous volatility levels kept in ascending order, so that the
//    mid-rank needs two binary searches instead of L comparisons [S4.2]
double gSortedVol[];
int    gSortedFrom = -1;    // bar index of the oldest level held (-1 = nothing held)

string gPrefix;             // chart-object prefix of this instance
bool   gVisualsAllowed = false;
datetime gLastPanelBar = 0;

//+------------------------------------------------------------------+
//| Initialisation                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- validate inputs; never clamp silently [API 5]
   if(InpHorizonBars < 12 || InpHorizonBars > 500)
      return Fail("Horizon N must be in [12, 500]");
   if(InpVolMemoryBars < 50 || InpVolMemoryBars > 5000)
      return Fail("Volatility memory L must be in [50, 5000]");
   if(!(InpTrendEntryZ > 0.0 && InpTrendExitZ >= 0.0 && InpTrendExitZ < InpTrendEntryZ))
      return Fail("Trend thresholds must satisfy 0 <= exit < entry");
   if(!(InpChangeEntryZ > 0.0 && InpChangeExitZ >= 0.0 && InpChangeExitZ < InpChangeEntryZ))
      return Fail("Change thresholds must satisfy 0 <= exit < entry");
   if(!(InpCompressionPct > 0.0 && InpExpansionPct < 100.0 &&
        InpCompressionPct + 20.0 <= InpExpansionPct - 20.0))
      return Fail("Percentile bands must satisfy 0 < compression, compression+20 <= expansion-20, expansion < 100");

   //--- windows, all derived from N [S2.1, S7]
   gN  = InpHorizonBars;
   gL  = InpVolMemoryBars;
   gNF = MathMax(3, gN / 3);
   gNP = gN;
   gNS = 3 * gN;
   gNV = MathMax(3, gN / 2);
   gDirWindow = MathMax(gNS, MathMax(gNF + gNP, gN - 1));
   gVolWindow = gNV + gL;

   gSlopeDen = gN * ((double)gN * gN - 1.0) / 12.0;
   gKappa    = MathSqrt(6.0 * ((double)gN * gN + 1.0) / (5.0 * gN * ((double)gN * gN - 1.0)));
   gEffFloor = 1.0 / MathSqrt(gN - 1.0);
   ArrayResize(gSlopeW, gN - 1);
   for(int m = 1; m <= gN - 1; m++)
      gSlopeW[m - 1] = (double)(m * (gN - m)) / (2.0 * gSlopeDen);
   ArrayResize(gRetBuf, MathMax(gNS, gNF + gNP));
   ArrayResize(gRet, gNS);
   ArrayResize(gSortedVol, gL);
   gSortedFrom = -1;

   gThIn = InpTrendEntryZ;   gThOut = InpTrendExitZ;
   gBetaIn = InpChangeEntryZ; gBetaOut = InpChangeExitZ;
   gPcIn = InpCompressionPct / 100.0;  gPcOut = (InpCompressionPct + 20.0) / 100.0;
   gPeIn = InpExpansionPct / 100.0;    gPeOut = (InpExpansionPct - 20.0) / 100.0;

   //--- buffers
   SetIndexBuffer(0,  BufRegime,        INDICATOR_DATA);
   SetIndexBuffer(1,  BufDirection,     INDICATOR_DATA);
   SetIndexBuffer(2,  BufVolRegime,     INDICATOR_DATA);
   SetIndexBuffer(3,  BufTrendStrength, INDICATOR_DATA);
   SetIndexBuffer(4,  BufConfidence,    INDICATOR_DATA);
   SetIndexBuffer(5,  BufStability,     INDICATOR_DATA);
   SetIndexBuffer(6,  BufPressure,      INDICATOR_DATA);
   SetIndexBuffer(7,  BufTrendZ,        INDICATOR_DATA);
   SetIndexBuffer(8,  BufChangeZ,       INDICATOR_DATA);
   SetIndexBuffer(9,  BufVolPercentile, INDICATOR_DATA);
   SetIndexBuffer(10, BufBarsInRegime,  INDICATOR_DATA);
   SetIndexBuffer(11, BufQualityFlags,  INDICATOR_DATA);
   SetIndexBuffer(12, BufStripRegHi,    INDICATOR_DATA);
   SetIndexBuffer(13, BufStripRegLo,    INDICATOR_DATA);
   SetIndexBuffer(14, BufStripRegClr,   INDICATOR_COLOR_INDEX);
   SetIndexBuffer(15, BufStripVolHi,    INDICATOR_DATA);
   SetIndexBuffer(16, BufStripVolLo,    INDICATOR_DATA);
   SetIndexBuffer(17, BufStripVolClr,   INDICATOR_COLOR_INDEX);
   SetIndexBuffer(18, CalcLogClose,     INDICATOR_CALCULATIONS);
   SetIndexBuffer(19, CalcLogTR,        INDICATOR_CALCULATIONS);
   SetIndexBuffer(20, CalcVolLevel,     INDICATOR_CALCULATIONS);
   SetIndexBuffer(21, CalcNonPosCount,  INDICATOR_CALCULATIONS);
   SetIndexBuffer(22, CalcInconsCount,  INDICATOR_CALCULATIONS);

   //--- public plots 0..11: DRAW_NONE, visible in the Data Window
   string names[12] = {"Regime", "Direction", "Vol regime", "Trend strength", "Confidence (heuristic)",
                       "Stability", "Transition pressure (heuristic)", "Trend z", "Change z",
                       "Vol percentile", "Bars in regime", "Quality flags"};
   for(int p = 0; p < 12; p++)
     {
      PlotIndexSetInteger(p, PLOT_DRAW_TYPE, DRAW_NONE);
      PlotIndexSetString(p, PLOT_LABEL, names[p]);
      PlotIndexSetDouble(p, PLOT_EMPTY_VALUE, EMPTY_VALUE);
      PlotIndexSetInteger(p, PLOT_SHOW_DATA, true);
     }
   //--- strip plots 12 (regime row) and 13 (volatility row)
   PlotIndexSetInteger(12, PLOT_DRAW_TYPE, InpShowStrip ? DRAW_COLOR_HISTOGRAM2 : DRAW_NONE);
   PlotIndexSetString(12, PLOT_LABEL, "Regime strip");
   PlotIndexSetInteger(12, PLOT_SHOW_DATA, false);
   PlotIndexSetInteger(12, PLOT_LINE_WIDTH, MathMax(1, InpStripWidth));
   PlotIndexSetInteger(12, PLOT_COLOR_INDEXES, 5);
   PlotIndexSetInteger(12, PLOT_LINE_COLOR, REGIME_UNKNOWN,    InpColorUnknown);
   PlotIndexSetInteger(12, PLOT_LINE_COLOR, REGIME_TREND_UP,   InpColorTrendUp);
   PlotIndexSetInteger(12, PLOT_LINE_COLOR, REGIME_TREND_DOWN, InpColorTrendDown);
   PlotIndexSetInteger(12, PLOT_LINE_COLOR, REGIME_RANGE,      InpColorRange);
   PlotIndexSetInteger(12, PLOT_LINE_COLOR, REGIME_TRANSITION, InpColorTransition);
   PlotIndexSetDouble(12, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   PlotIndexSetInteger(13, PLOT_DRAW_TYPE, InpShowStrip ? DRAW_COLOR_HISTOGRAM2 : DRAW_NONE);
   PlotIndexSetString(13, PLOT_LABEL, "Volatility strip");
   PlotIndexSetInteger(13, PLOT_SHOW_DATA, false);
   PlotIndexSetInteger(13, PLOT_LINE_WIDTH, MathMax(1, InpStripWidth));
   PlotIndexSetInteger(13, PLOT_COLOR_INDEXES, 4);
   PlotIndexSetInteger(13, PLOT_LINE_COLOR, VOL_UNKNOWN,     InpColorUnknown);
   PlotIndexSetInteger(13, PLOT_LINE_COLOR, VOL_COMPRESSION, InpColorCompress);
   PlotIndexSetInteger(13, PLOT_LINE_COLOR, VOL_NORMAL,      InpColorNormal);
   PlotIndexSetInteger(13, PLOT_LINE_COLOR, VOL_EXPANSION,   InpColorExpansion);
   PlotIndexSetDouble(13, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   IndicatorSetInteger(INDICATOR_DIGITS, 4);
   IndicatorSetString(INDICATOR_SHORTNAME,
                      StringFormat("Arixis Regime Map %s (%d,%d)", ARMM_VERSION, gN, gL));

   //--- visuals only when attached to a chart window (not when created by iCustom)
   gVisualsAllowed = (ChartWindowFind() >= 0);
   gPrefix = StringFormat("ARMM_%d_%d_%d_", gN, gL, MathMax(0, ChartWindowFind()));
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
int Fail(const string why)
  {
   Print("Arixis Market Regime Map: invalid inputs - ", why);
   return INIT_PARAMETERS_INCORRECT;
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, gPrefix);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Main calculation                                                 |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[], const double &high[],
                const double &low[], const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
  {
   ulong t0 = GetMicrosecondCount();
   if(rates_total < 2)
      return 0;

   //--- index 0 = oldest bar (chronological order) everywhere in this file
   ArraySetAsSeries(time, false);  ArraySetAsSeries(open, false);
   ArraySetAsSeries(high, false);  ArraySetAsSeries(low, false);
   ArraySetAsSeries(close, false);

   //--- closed bars are 0 .. rates_total-2; bar rates_total-1 is forming.
   //    On a full pass start at 0; otherwise recompute from the bar that was
   //    forming at the previous call (it has now closed). Each bar depends
   //    only on its inputs and on the stored values of bar t-1, so the
   //    incremental path gives exactly the same values as a full pass.
   int first = (prev_calculated <= 0) ? 0 : prev_calculated - 1;
   if(prev_calculated <= 0)
      gSortedFrom = -1;              // full pass: the percentile cache is rebuilt from the buffers
   int lastClosed = rates_total - 2;
   for(int t = first; t <= lastClosed; t++)
      ComputeBar(t, open, high, low, close);

   //--- forming bar: never classified [S9.2]
   SetBarEmpty(rates_total - 1);
   CalcLogClose[rates_total - 1] = 0.0;
   CalcLogTR[rates_total - 1] = 0.0;
   CalcVolLevel[rates_total - 1] = EMPTY_VALUE;
   CalcNonPosCount[rates_total - 1] = 0.0;
   CalcInconsCount[rates_total - 1] = 0.0;

   int computed = MathMax(0, lastClosed - first + 1);
   if(InpDiagnostics)
      PrintFormat("ARMM_DIAG rates_total=%d prev_calculated=%d first=%d computed=%d usec=%I64u mem_mb=%d",
                  rates_total, prev_calculated, first, computed, GetMicrosecondCount() - t0,
                  MQLInfoInteger(MQL_MEMORY_USED));

   //--- visuals read the buffers only; they never feed back into the model
   if(gVisualsAllowed && lastClosed >= 0 && (computed > 0 || gLastPanelBar == 0))
     {
      if(InpShowPanel)
         DrawPanel(lastClosed, time);
      if(InpShadeChart)
         DrawShading(lastClosed, time, high);
      gLastPanelBar = time[lastClosed];
      ChartRedraw(0);
     }
   return rates_total;
  }

//+------------------------------------------------------------------+
//| One closed bar t                                                 |
//+------------------------------------------------------------------+
void ComputeBar(const int t, const double &open[], const double &high[],
                const double &low[], const double &close[])
  {
   //--- 1. per-bar caches -------------------------------------------
   bool nonPos  = (open[t] <= 0.0 || high[t] <= 0.0 || low[t] <= 0.0 || close[t] <= 0.0);
   bool incons  = (high[t] < MathMax(open[t], close[t]) || low[t] > MathMin(open[t], close[t]));
   CalcNonPosCount[t] = (t > 0 ? CalcNonPosCount[t - 1] : 0.0) + (nonPos ? 1.0 : 0.0);
   CalcInconsCount[t] = (t > 0 ? CalcInconsCount[t - 1] : 0.0) + (incons ? 1.0 : 0.0);
   CalcLogClose[t] = nonPos ? 0.0 : MathLog(close[t]);
   //    log true range: max(h_t, c_{t-1}) - min(l_t, c_{t-1}) [S4.1]
   if(t >= 1 && !nonPos && CountIn(CalcNonPosCount, t - 1, t - 1) == 0)
     {
      double pc = CalcLogClose[t - 1];
      CalcLogTR[t] = MathMax(MathLog(high[t]), pc) - MathMin(MathLog(low[t]), pc);
     }
   else
      CalcLogTR[t] = 0.0;

   int flags = 0;

   //--- 2. trend strength: noise-adjusted efficiency over N closes [S3.5, S8.1]
   BufTrendStrength[t] = EMPTY_VALUE;
   if(t >= gN - 1 && WindowClean(t - gN + 1, t))
     {
      double path = 0.0;
      for(int k = t - gN + 2; k <= t; k++)
         path += MathAbs(CalcLogClose[k] - CalcLogClose[k - 1]);
      if(path > 0.0)
        {
         double er = MathAbs(CalcLogClose[t] - CalcLogClose[t - gN + 1]) / path;
         double x  = (er - gEffFloor) / (1.0 - gEffFloor);
         BufTrendStrength[t] = 100.0 * MathMax(0.0, MathMin(1.0, x));
        }
     }

   //--- 3. directional measurements [S3] ----------------------------
   double T = 0, B = 0, Ts = 0, Bs = 0;
   bool dirValid = false;
   BufTrendZ[t] = EMPTY_VALUE;
   BufChangeZ[t] = EMPTY_VALUE;
   if(t < gDirWindow)
      flags |= FLAG_INSUFFICIENT_HISTORY_DIRECTION;
   else if(!WindowClean(t - gDirWindow, t))
      flags |= WindowFlags(t - gDirWindow, t);
   else
     {
      double sigma, zeroFrac;
      ReturnScale(t, sigma, zeroFrac);
      if(sigma <= 0.0)
         flags |= FLAG_FLAT_PRICE;
      else
        {
         TrendStatistics(t, sigma, T, Ts);
         ChangeStatistics(t, sigma, B, Bs);
         BufTrendZ[t] = T;
         BufChangeZ[t] = B;
         if(zeroFrac > gZeroFracMax)
            flags |= FLAG_EXCESS_ZERO_RETURNS;
         else
            dirValid = true;
        }
     }

   //--- 4. directional state machine [S6.1] --------------------------
   int prev  = (t > 0) ? (int)MathRound(BufRegime[t - 1]) : REGIME_UNKNOWN;
   int state = REGIME_UNKNOWN;
   BufConfidence[t] = EMPTY_VALUE;
   BufPressure[t] = EMPTY_VALUE;
   if(dirValid)
     {
      state = DirectionStep(prev, T, B, Ts, Bs);
      if(DirectionStep(prev, T, B, T, B) != state)
         flags |= FLAG_ENTRY_VETOED;           // informational [API 4]
      double margin, adverse;
      DecisionMargins(state, T, B, margin, adverse);
      BufConfidence[t] = 100.0 * MathMax(0.0, 2.0 * Phi(margin) - 1.0);
      BufPressure[t]   = 100.0 * (2.0 * Phi(adverse) - 1.0);
     }
   BufRegime[t] = state;
   BufDirection[t] = (state == REGIME_TREND_UP) ? 1.0 : (state == REGIME_TREND_DOWN ? -1.0 : 0.0);
   if(state == REGIME_UNKNOWN)
      BufBarsInRegime[t] = 0.0;
   else
      BufBarsInRegime[t] = (prev == state && t > 0) ? BufBarsInRegime[t - 1] + 1.0 : 1.0;

   //    stability: share of the last N states equal to the current one [S8.3]
   BufStability[t] = EMPTY_VALUE;
   if(state != REGIME_UNKNOWN && t >= gDirWindow + gN - 1)
     {
      int same = 0;
      for(int k = t - gN + 1; k <= t; k++)
         if((int)MathRound(BufRegime[k]) == state)
            same++;
      BufStability[t] = 100.0 * same / gN;
     }

   //--- 5. volatility [S4, S6.3] -------------------------------------
   CalcVolLevel[t] = EMPTY_VALUE;
   if(t >= gNV && WindowClean(t - gNV, t))
     {
      double s = 0.0;
      for(int k = t - gNV + 1; k <= t; k++)
         s += CalcLogTR[k];
      CalcVolLevel[t] = s / gNV;
     }
   int prevVol = (t > 0) ? (int)MathRound(BufVolRegime[t - 1]) : VOL_UNKNOWN;
   int vstate = VOL_UNKNOWN;
   BufVolPercentile[t] = EMPTY_VALUE;
   if(t < gVolWindow)
      flags |= FLAG_INSUFFICIENT_HISTORY_VOLATILITY;
   else if(!WindowClean(t - gVolWindow, t))
      flags |= WindowFlags(t - gVolWindow, t);
   else
     {
      double P = MidrankPercentile(t);
      BufVolPercentile[t] = 100.0 * P;
      if(CalcVolLevel[t] <= 0.0)
         flags |= FLAG_FLAT_PRICE;
      else
         vstate = VolatilityStep(prevVol, P);
     }
   BufVolRegime[t] = vstate;
   BufQualityFlags[t] = flags;

   //--- 6. strip (visual only) ----------------------------------------
   BufStripRegHi[t] = 0.95; BufStripRegLo[t] = 0.55; BufStripRegClr[t] = state;
   BufStripVolHi[t] = 0.42; BufStripVolLo[t] = 0.08; BufStripVolClr[t] = vstate;
  }

//+------------------------------------------------------------------+
//| sigma_t: sample std (n-1) of the last n_S log returns, and the   |
//| fraction of those returns that are exactly zero [S3.1, S10.2]    |
//+------------------------------------------------------------------+
void ReturnScale(const int t, double &sigma, double &zeroFrac)
  {
   double sum = 0.0;
   int zeros = 0;
   for(int i = 0; i < gNS; i++)
     {
      int k = t - gNS + 1 + i;
      double r = CalcLogClose[k] - CalcLogClose[k - 1];
      gRet[i] = r;                 // kept for TrendStatistics/ChangeStatistics of this bar
      sum += r;
      if(r == 0.0)
         zeros++;
     }
   double mean = sum / gNS;
   double ss = 0.0;
   for(int i = 0; i < gNS; i++)
      ss += (gRet[i] - mean) * (gRet[i] - mean);
   sigma = MathSqrt(ss / (gNS - 1));
   zeroFrac = (double)zeros / gNS;
  }

//+------------------------------------------------------------------+
//| T (OLS slope of log close on bar index / its exact random-walk   |
//| null std) and T* (same with the single most supportive return    |
//| removed) [S3.2, S3.4]                                            |
//+------------------------------------------------------------------+
void TrendStatistics(const int t, const double sigma, double &T, double &Tstar)
  {
   //--- slope from the closes: b = sum (k - (N-1)/2) c_{t-N+1+k} / S_N
   double half = (gN - 1) / 2.0;
   double acc = 0.0;
   for(int k = 0; k < gN; k++)
      acc += CalcLogClose[t - gN + 1 + k] * (k - half);
   double b = acc / gSlopeDen;
   T = b / (sigma * gKappa);

   //--- the same slope as a weighted sum of returns: b = sum w_m r_m
   //    (r_{t-N+1+m} is gRet[n_S - N + m], filled by ReturnScale for this bar)
   int base = gNS - gN;
   double b2 = 0.0;
   for(int m = 1; m <= gN - 1; m++)
      b2 += gRet[base + m] * gSlopeW[m - 1];
   double s = Sign(b2);
   double best = -DBL_MAX;
   for(int m = 1; m <= gN - 1; m++)
     {
      double c = gRet[base + m] * gSlopeW[m - 1] * s;
      if(c > best)
         best = c;
     }
   double bstar = b2 - s * MathMax(best, 0.0);
   Tstar = bstar / (sigma * gKappa);
  }

//+------------------------------------------------------------------+
//| B (mean of the last n_F returns minus mean of the n_P returns    |
//| before them, standardised) and B* (leave-one-out) [S3.3, S3.4]   |
//+------------------------------------------------------------------+
void ChangeStatistics(const int t, const double sigma, double &B, double &Bstar)
  {
   double se = sigma * MathSqrt(1.0 / gNF + 1.0 / gNP);
   //--- returns r_k for k = t-n+1 .. t are gRet[n_S - n + i] (filled by ReturnScale)
   int n = gNF + gNP;
   int base = gNS - n;
   double sf = 0.0, sp = 0.0;
   for(int i = gNP; i < n; i++)            // fast window: the last n_F returns
      sf += gRet[base + i];
   for(int i = 0; i < gNP; i++)            // prior window: the n_P returns before them
      sp += gRet[base + i];
   B = (sf / gNF - sp / gNP) / se;

   //--- coefficient form: -1/n_P on the prior window, +1/n_F on the fast window
   double aPrior = -1.0 / gNP, aFast = 1.0 / gNF;
   double d2 = 0.0;
   for(int i = 0; i < n; i++)
     {
      gRetBuf[i] = gRet[base + i] * ((i < gNP) ? aPrior : aFast);
      d2 += gRetBuf[i];
     }
   double s = Sign(d2);
   double best = -DBL_MAX;
   for(int i = 0; i < n; i++)
      if(gRetBuf[i] * s > best)
         best = gRetBuf[i] * s;
   Bstar = (d2 - s * MathMax(best, 0.0)) / se;
  }

//+------------------------------------------------------------------+
//| Directional state machine (exact transcription of [S6.1])        |
//+------------------------------------------------------------------+
int DirectionStep(const int s, const double T, const double B, const double Ts, const double Bs)
  {
   //--- entry predicates: calibrated statistic crosses the entry threshold AND
   //    the leave-one-out statistic still reaches the exit level (veto form)
   bool up = (T >=  gThIn && Ts >=  gThOut);
   bool dn = (T <= -gThIn && Ts <= -gThOut);
   bool cu = (B >=  gBetaIn && Bs >=  gBetaOut);
   bool cd = (B <= -gBetaIn && Bs <= -gBetaOut);

   if(s == REGIME_UNKNOWN || s == REGIME_RANGE)
     {
      if(up && !cd) return REGIME_TREND_UP;
      if(dn && !cu) return REGIME_TREND_DOWN;
      if(cu || cd)  return REGIME_TRANSITION;
      return REGIME_RANGE;
     }
   if(s == REGIME_TREND_UP)
     {
      if(cd)          return REGIME_TRANSITION;   // significant deceleration / reversal
      if(dn)          return REGIME_TREND_DOWN;
      if(T < gThOut)  return REGIME_RANGE;        // evidence faded below the exit level
      return REGIME_TREND_UP;
     }
   if(s == REGIME_TREND_DOWN)
     {
      if(cu)          return REGIME_TRANSITION;
      if(up)          return REGIME_TREND_UP;
      if(T > -gThOut) return REGIME_RANGE;
      return REGIME_TREND_DOWN;
     }
   //--- TRANSITION: resolves when the medium horizon confirms the change
   //    direction, or when the change evidence decays below its exit level
   if(B > 0.0 && up) return REGIME_TREND_UP;
   if(B < 0.0 && dn) return REGIME_TREND_DOWN;
   if(MathAbs(B) < gBetaOut)
      return up ? REGIME_TREND_UP : (dn ? REGIME_TREND_DOWN : REGIME_RANGE);
   return REGIME_TRANSITION;
  }

//+------------------------------------------------------------------+
//| Confidence margin m and adverse change evidence a [S8.2, S8.4]   |
//+------------------------------------------------------------------+
void DecisionMargins(const int state, const double T, const double B, double &m, double &a)
  {
   if(state == REGIME_TREND_UP)
     { m = MathMin(T - gThOut, B + gBetaIn);   a = MathMax(0.0, -B); }
   else if(state == REGIME_TREND_DOWN)
     { m = MathMin(-T - gThOut, gBetaIn - B);  a = MathMax(0.0, B); }
   else if(state == REGIME_RANGE)
     { m = MathMin(gThIn - MathAbs(T), gBetaIn - MathAbs(B)); a = MathAbs(B); }
   else
     { m = MathAbs(B) - gBetaOut;              a = MathAbs(B); }
  }

//+------------------------------------------------------------------+
//| Volatility state machine [S6.3]                                  |
//+------------------------------------------------------------------+
int VolatilityStep(const int s, const double P)
  {
   if(s == VOL_COMPRESSION)
     {
      if(P >= gPeIn) return VOL_EXPANSION;
      return (P < gPcOut) ? VOL_COMPRESSION : VOL_NORMAL;
     }
   if(s == VOL_EXPANSION)
     {
      if(P <= gPcIn) return VOL_COMPRESSION;
      return (P > gPeOut) ? VOL_EXPANSION : VOL_NORMAL;
     }
   //--- UNKNOWN or NORMAL
   if(P <= gPcIn) return VOL_COMPRESSION;
   if(P >= gPeIn) return VOL_EXPANSION;
   return VOL_NORMAL;
  }

//+------------------------------------------------------------------+
//| Mid-rank of v_t among v_{t-L} .. v_{t-1} (current value excluded)|
//|   P = (#{v_s < v_t} + 0.5 * #{v_s == v_t}) / L                   |
//|                                                                  |
//| Implementation: the L reference levels are kept sorted. When the |
//| window moves by one bar, the level that leaves is replaced by    |
//| the one that enters and moved to its sorted place. Then          |
//|   #{v_s <  v_t} = LowerBound(v_t),  #{v_s <= v_t} = UpperBound(v_t) |
//| use exactly the same comparisons as a direct count, so P is      |
//| bit-for-bit identical; only the work per bar is smaller.         |
//+------------------------------------------------------------------+
double MidrankPercentile(const int t)
  {
   int from = t - gL;                       // window = bars from .. t-1
   if(gSortedFrom == from - 1)
      SlideSortedWindow(CalcVolLevel[from - 1], CalcVolLevel[t - 1]);
   else if(gSortedFrom != from)
     {
      ArrayCopy(gSortedVol, CalcVolLevel, 0, from, gL);   // (re)build: any other jump
      ArraySort(gSortedVol);
     }
   gSortedFrom = from;

   double cur = CalcVolLevel[t];
   int less = LowerBound(cur);
   int equal = UpperBound(cur) - less;
   return (less + 0.5 * equal) / gL;
  }

//--- replace `out` (leaving the window) by `in` (entering) and keep the array sorted
void SlideSortedWindow(const double out, const double in)
  {
   int k = LowerBound(out);                 // a position holding `out`
   if(in >= out)
      while(k + 1 < gL && gSortedVol[k + 1] < in)
        { gSortedVol[k] = gSortedVol[k + 1]; k++; }
   else
      while(k > 0 && gSortedVol[k - 1] > in)
        { gSortedVol[k] = gSortedVol[k - 1]; k--; }
   gSortedVol[k] = in;
  }

//--- number of sorted levels strictly below x
int LowerBound(const double x)
  {
   int lo = 0, hi = gL;
   while(lo < hi)
     {
      int mid = (lo + hi) >> 1;
      if(gSortedVol[mid] < x) lo = mid + 1; else hi = mid;
     }
   return lo;
  }

//--- number of sorted levels below or equal to x
int UpperBound(const double x)
  {
   int lo = 0, hi = gL;
   while(lo < hi)
     {
      int mid = (lo + hi) >> 1;
      if(gSortedVol[mid] <= x) lo = mid + 1; else hi = mid;
     }
   return lo;
  }

//+------------------------------------------------------------------+
//| Helpers                                                          |
//+------------------------------------------------------------------+
double Sign(const double x) { return (x > 0.0) ? 1.0 : ((x < 0.0) ? -1.0 : 0.0); }

//--- number of flagged bars in [a, b] from an exact cumulative count
int CountIn(const double &cum[], const int a, const int b)
  {
   double before = (a > 0) ? cum[a - 1] : 0.0;
   return (int)MathRound(cum[b] - before);
  }

bool WindowClean(const int a, const int b)
  {
   return CountIn(CalcNonPosCount, a, b) == 0 && CountIn(CalcInconsCount, a, b) == 0;
  }

int WindowFlags(const int a, const int b)
  {
   int f = 0;
   if(CountIn(CalcNonPosCount, a, b) > 0) f |= FLAG_NONPOSITIVE_PRICE;
   if(CountIn(CalcInconsCount, a, b) > 0) f |= FLAG_INCONSISTENT_BAR;
   return f;
  }

//--- standard normal CDF, Phi(x) = (1 + erf(x/sqrt 2)) / 2
double Phi(const double x) { return 0.5 * (1.0 + Erf(x / MathSqrt(2.0))); }

//--- erf by the everywhere-positive series (Abramowitz & Stegun 7.1.6):
//    erf(x) = 2/sqrt(pi) * exp(-x^2) * sum_n 2^n x^(2n+1) / (1*3*...*(2n+1)).
//    No cancellation; relative error ~1e-15. For |x| > 6, erf = +-1 to double precision.
double Erf(const double x)
  {
   if(x == 0.0)
      return x;                 // erf(+-0) = +-0; without this the series below never meets its stop test
   if(x < 0.0)
      return -Erf(-x);
   if(x > 6.0)
      return 1.0;
   double x2 = x * x, term = x, sum = x;
   for(int n = 1; n < 1000; n++)
     {
      term *= 2.0 * x2 / (2.0 * n + 1.0);
      sum += term;
      if(term < 1e-17 * sum)
         break;
     }
   return 2.0 / MathSqrt(M_PI) * MathExp(-x2) * sum;
  }

void SetBarEmpty(const int t)
  {
   BufRegime[t] = EMPTY_VALUE;        BufDirection[t] = EMPTY_VALUE;
   BufVolRegime[t] = EMPTY_VALUE;     BufTrendStrength[t] = EMPTY_VALUE;
   BufConfidence[t] = EMPTY_VALUE;    BufStability[t] = EMPTY_VALUE;
   BufPressure[t] = EMPTY_VALUE;      BufTrendZ[t] = EMPTY_VALUE;
   BufChangeZ[t] = EMPTY_VALUE;       BufVolPercentile[t] = EMPTY_VALUE;
   BufBarsInRegime[t] = EMPTY_VALUE;  BufQualityFlags[t] = EMPTY_VALUE;
   BufStripRegHi[t] = EMPTY_VALUE;    BufStripRegLo[t] = EMPTY_VALUE;  BufStripRegClr[t] = 0;
   BufStripVolHi[t] = EMPTY_VALUE;    BufStripVolLo[t] = EMPTY_VALUE;  BufStripVolClr[t] = 0;
  }

//+------------------------------------------------------------------+
//| VISUALS - read buffers only                                      |
//+------------------------------------------------------------------+
string RegimeText(const int s)
  {
   switch(s)
     {
      case REGIME_TREND_UP:   return "TREND UP";
      case REGIME_TREND_DOWN: return "TREND DOWN";
      case REGIME_RANGE:      return "RANGE";
      case REGIME_TRANSITION: return "TRANSITION";
     }
   return "UNKNOWN";
  }

string VolText(const int s)
  {
   switch(s)
     {
      case VOL_COMPRESSION: return "COMPRESSION";
      case VOL_NORMAL:      return "NORMAL";
      case VOL_EXPANSION:   return "EXPANSION";
     }
   return "UNKNOWN";
  }

color RegimeColor(const int s)
  {
   switch(s)
     {
      case REGIME_TREND_UP:   return InpColorTrendUp;
      case REGIME_TREND_DOWN: return InpColorTrendDown;
      case REGIME_RANGE:      return InpColorRange;
      case REGIME_TRANSITION: return InpColorTransition;
     }
   return InpColorUnknown;
  }

//--- the reason shown next to UNKNOWN, from the quality flags
string UnknownReason(const int flags, const int t, const bool volatility)
  {
   if(!volatility && (flags & FLAG_INSUFFICIENT_HISTORY_DIRECTION) != 0)
      return StringFormat("warm-up %d/%d bars", t + 1, gDirWindow + 1);
   if(volatility && (flags & FLAG_INSUFFICIENT_HISTORY_VOLATILITY) != 0)
      return StringFormat("warm-up %d/%d bars", t + 1, gVolWindow + 1);
   if((flags & FLAG_NONPOSITIVE_PRICE) != 0) return "non-positive price";
   if((flags & FLAG_INCONSISTENT_BAR) != 0)  return "inconsistent bar";
   if((flags & FLAG_FLAT_PRICE) != 0)        return "flat price";
   if(!volatility && (flags & FLAG_EXCESS_ZERO_RETURNS) != 0) return "price too coarse";
   return "no data";
  }

bool IsDarkBackground()
  {
   color bg = (color)ChartGetInteger(0, CHART_COLOR_BACKGROUND);
   int r = (int)(bg & 0xFF), g = (int)((bg >> 8) & 0xFF), b = (int)((bg >> 16) & 0xFF);
   return (0.299 * r + 0.587 * g + 0.114 * b) < 128.0;
  }

color Blend(const color fg, const color bg, const double w)
  {
   int r = (int)MathRound((fg & 0xFF) * w + (bg & 0xFF) * (1.0 - w));
   int g = (int)MathRound(((fg >> 8) & 0xFF) * w + ((bg >> 8) & 0xFF) * (1.0 - w));
   int b = (int)MathRound(((fg >> 16) & 0xFF) * w + ((bg >> 16) & 0xFF) * (1.0 - w));
   return (color)(r | (g << 8) | (b << 16));
  }

void PanelLabel(const string id, const int x, const int y, const string text,
                const color clr, const int size, const string font)
  {
   string name = gPrefix + id;
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
     }
   //--- the anchor is always the top edge of the text; Y() converts top-based
   //    positions into distances from the bottom for the lower corners
   bool right = (InpPanelCorner == CORNER_RIGHT_UPPER || InpPanelCorner == CORNER_RIGHT_LOWER);
   ENUM_ANCHOR_POINT anchor = right ? ANCHOR_RIGHT_UPPER : ANCHOR_LEFT_UPPER;
   ObjectSetInteger(0, name, OBJPROP_CORNER, InpPanelCorner);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, anchor);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, font);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
  }

void DrawPanel(const int t, const datetime &time[])
  {
   bool dark = IsDarkBackground();
   color bg     = (color)ChartGetInteger(0, CHART_COLOR_BACKGROUND);
   color panel  = Blend(dark ? clrWhite : clrBlack, bg, 0.06);
   color text   = dark ? C'225,228,232' : C'30,34,40';
   color muted  = dark ? C'140,146,155' : C'110,116,125';

   int state  = (int)MathRound(BufRegime[t]);
   int vstate = (int)MathRound(BufVolRegime[t]);
   int flags  = (int)MathRound(BufQualityFlags[t]);

   string regime = RegimeText(state);
   if(state == REGIME_UNKNOWN)
      regime += " - " + UnknownReason(flags, t, false);
   else
      regime += StringFormat("  (%d bars)", (int)BufBarsInRegime[t]);
   string vol = VolText(vstate);
   if(vstate == VOL_UNKNOWN)
      vol += " - " + UnknownReason(flags, t, true);
   else
      vol += StringFormat("  (pct %d)", (int)MathRound(BufVolPercentile[t]));

   //--- rows: label, value, value colour
   string lab[8], val[8];
   color  vcl[8];
   int rows = 0;
   lab[rows] = "REGIME";     val[rows] = regime; vcl[rows++] = RegimeColor(state);
   lab[rows] = "VOLATILITY"; val[rows] = vol;    vcl[rows++] = text;
   if(!InpMinimalMode)
     {
      lab[rows] = "TREND STRENGTH"; val[rows] = Score(BufTrendStrength[t], "");           vcl[rows++] = text;
      lab[rows] = "CONFIDENCE";     val[rows] = Score(BufConfidence[t], "  heuristic");   vcl[rows++] = text;
      lab[rows] = "STABILITY";      val[rows] = StabilityText(BufStability[t]);           vcl[rows++] = text;
      lab[rows] = "TRANSITION PRESSURE"; val[rows] = Score(BufPressure[t], "  heuristic"); vcl[rows++] = text;
     }

   //--- layout from measured text sizes (display only): the label column is as wide as
   //    the widest label, rows are as tall as the tallest text, so labels and values cannot overlap
   //    at any font scaling; 150 px / 380 px are kept as minimums so the panel does not jitter
   string title = "ARIXIS  MARKET REGIME MAP";
   string sub   = StringFormat("N=%d  L=%d  -  v%s", gN, gL, ARMM_VERSION);
   string foot  = "closed bar " + TimeToString(time[t], TIME_DATE | TIME_MINUTES) + "  -  description, not a signal";
   int padX = 10, padY = 8, gapCol = 16, gapRow = 4;
   int titleW, titleH, subW, subH, footW, footH, w, h;
   TextPx(title, "Segoe UI Semibold", 10, titleW, titleH);
   TextPx(sub, "Segoe UI", 8, subW, subH);
   TextPx(foot, "Segoe UI", 7, footW, footH);
   int labelW = 150, valueW = 0, lineH = 0;
   for(int i = 0; i < rows; i++)
     {
      TextPx(lab[i], "Segoe UI", 8, w, h);
      labelW = MathMax(labelW, w + gapCol);
      lineH  = MathMax(lineH, h);
      TextPx(val[i], "Segoe UI Semibold", 9, w, h);
      valueW = MathMax(valueW, w);
      lineH  = MathMax(lineH, h);
     }
   lineH = MathMax(18, lineH + gapRow);
   int ySub  = titleH + 2;                       // offsets from the panel's inner top edge
   int yRows = ySub + subH + 8;
   int yFoot = yRows + rows * lineH + 2;
   int width = MathMax(380, 2 * padX + MathMax(MathMax(titleW, subW), MathMax(labelW + valueW, footW)));
   int height = 2 * padY + yFoot + footH;
   bool right = (InpPanelCorner == CORNER_RIGHT_UPPER || InpPanelCorner == CORNER_RIGHT_LOWER);
   bool lower = (InpPanelCorner == CORNER_LEFT_LOWER || InpPanelCorner == CORNER_RIGHT_LOWER);

   string box = gPrefix + "bg";
   if(ObjectFind(0, box) < 0)
     {
      ObjectCreate(0, box, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, box, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, box, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, box, OBJPROP_BORDER_TYPE, BORDER_FLAT);
     }
   ObjectSetInteger(0, box, OBJPROP_CORNER, InpPanelCorner);
   ObjectSetInteger(0, box, OBJPROP_XDISTANCE, right ? InpPanelX + width : InpPanelX);
   ObjectSetInteger(0, box, OBJPROP_YDISTANCE, lower ? InpPanelY + height : InpPanelY);
   ObjectSetInteger(0, box, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, box, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, box, OBJPROP_BGCOLOR, panel);
   ObjectSetInteger(0, box, OBJPROP_COLOR, Blend(muted, bg, 0.5));

   //--- y positions are measured from the panel's top edge, mirrored for lower corners
   int top = InpPanelY + padY;
   int x0  = right ? InpPanelX + width - padX : InpPanelX + padX;
   int x1  = right ? InpPanelX + width - padX - labelW : InpPanelX + padX + labelW;
   PanelLabel("title", x0, Y(top, lower, height), title, text, 10, "Segoe UI Semibold");
   PanelLabel("sub", x0, Y(top + ySub, lower, height), sub, muted, 8, "Segoe UI");
   for(int i = 0; i < 6; i++)
     {
      if(i < rows)
        {
         int y = top + yRows + i * lineH;
         PanelLabel("l" + (string)i, x0, Y(y, lower, height), lab[i], muted, 8, "Segoe UI");
         PanelLabel("v" + (string)i, x1, Y(y, lower, height), val[i], vcl[i], 9, "Segoe UI Semibold");
        }
      else
        {
         ObjectDelete(0, gPrefix + "l" + (string)i);
         ObjectDelete(0, gPrefix + "v" + (string)i);
        }
     }
   PanelLabel("foot", x0, Y(top + yFoot, lower, height), foot, muted, 7, "Segoe UI");
  }

//--- rendered text size in pixels for a label font. OBJ_LABEL sizes follow the system's display
//    scaling; TextSetFont with a positive size does not and with a negative size (tenths of a
//    point) does, so the larger of the two is used. Display only.
void TextPx(const string s, const string font, const int pt, int &w, int &h)
  {
   uint w1 = 0, h1 = 0, w2 = 0, h2 = 0;
   TextSetFont(font, pt);
   TextGetSize(s, w1, h1);
   TextSetFont(font, -pt * 10);
   TextGetSize(s, w2, h2);
   w = (int)MathMax(w1, w2);
   h = (int)MathMax(h1, h2);
  }

//--- for lower corners, distance is measured from the bottom edge
int Y(const int yFromTop, const bool lower, const int height)
  {
   if(!lower)
      return yFromTop;
   return InpPanelY + height - (yFromTop - InpPanelY);
  }

string Score(const double v, const string suffix)
  {
   if(v == EMPTY_VALUE)
      return "-";
   return StringFormat("%d / 100%s", (int)MathRound(v), suffix);
  }

string StabilityText(const double v)
  {
   if(v == EMPTY_VALUE)
      return "-";
   string band = (v < InpStabilityLowPct) ? "LOW" : (v < InpStabilityHighPct ? "MEDIUM" : "HIGH");
   return StringFormat("%s  (%d%%)", band, (int)MathRound(v));
  }

//--- optional background shading: one rectangle per regime run among the
//    most recent InpShadeMaxBars closed bars (object count stays small)
void DrawShading(const int t, const datetime &time[], const double &high[])
  {
   ObjectsDeleteAll(0, gPrefix + "sh");
   color bg = (color)ChartGetInteger(0, CHART_COLOR_BACKGROUND);
   double w = MathMax(0, MathMin(100, InpShadeOpacityPct)) / 100.0;
   int from = MathMax(0, t - MathMax(1, InpShadeMaxBars) + 1);
   double top = 0.0;
   for(int k = from; k <= t; k++)
      top = MathMax(top, high[k]);
   top *= 10.0;
   int runStart = from;
   for(int k = from; k <= t; k++)
     {
      int s = (int)MathRound(BufRegime[k]);
      bool last = (k == t) || ((int)MathRound(BufRegime[k + 1]) != s);
      if(!last)
         continue;
      if(s != REGIME_UNKNOWN)
        {
         string name = gPrefix + "sh" + (string)runStart;
         ObjectCreate(0, name, OBJ_RECTANGLE, 0, time[runStart], 0.0, time[k + 1], top);
         ObjectSetInteger(0, name, OBJPROP_COLOR, Blend(RegimeColor(s), bg, w));
         ObjectSetInteger(0, name, OBJPROP_FILL, true);
         ObjectSetInteger(0, name, OBJPROP_BACK, true);
         ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
        }
      runStart = k + 1;
     }
  }

//--- redraw the panel when the chart colours or size change
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_CHART_CHANGE && gVisualsAllowed)
      gLastPanelBar = 0;   // forces a panel refresh on the next calculation
  }
//+------------------------------------------------------------------+
