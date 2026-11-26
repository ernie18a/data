# Calibrated Supertrend  Strength-Graded & Multi-Timeframe

- url: https://www.tradingview.com/script/uR0UxHwz-Calibrated-Supertrend-Strength-Graded-Multi-Timeframe/
- type: indicator
- pine_id: PUB;a894a9285f0344869d238442ca4eb024
- version: 4.0

## Description

## Calibrated Supertrend — Confirmed, Strength-Graded & Multi-Timeframe (ST ARC)

### What it is

A Supertrend rebuilt to fix the three things that frustrate everyone who uses the
plain version, and to tell you **how trustworthy each trend flip is** before you act
on it. A classic Supertrend uses a **fixed ATR multiplier** (an arbitrary guess that
whipsaws in volatile markets and lags in calm ones), it **flips on noise** (every
marginal poke through the band reverses it), and it gives you **no sense of quality**
(a great flip and a junk flip look identical). ST ARC addresses all three, then
scores every flip 0–100 and — crucially — **calibrates that score to what actually
happened on this symbol**, so the number is accountable rather than decorative.

It runs on **any symbol, asset class, timeframe and market**. The raw data source
and every optional feed are user-selectable; nothing is hard-coded to a market.

### Why these components are combined (mashup rationale)

Each layer removes one specific, nameable failure of the plain Supertrend and feeds
the next — none is decorative:

1. **Adaptive multiplier** — the band width is no longer fixed. The ATR multiplier
   becomes a series that scales with a **volatility rank** (how high current ATR
   sits versus its own recent history): wider when volatility is high to cut
   whipsaw, tighter when calm, and wider still when trend **efficiency** is low
   (choppy tape). The ATR *length* can also adapt to the measured dominant cycle.
2. **Confirmation gate (de-whipsaw)** — a raw flip is only **confirmed** when the
   close breaches the prior band by a minimum fraction of ATR *and* a minimum number
   of bars have passed since the last flip, evaluated on closed bars
   (non-repainting). This fixes the "flips on noise" problem.
3. **Regime classifier** — efficiency ratio + trend strength + a volatility-cluster
   measure label the market Trend / Range / Volatile, so flips are trusted or
   discounted by context.
4. **Multi-timeframe agreement** — three higher-timeframe Supertrends (multiples of
   your chart timeframe) are read with no repainting and counted for agreement; a
   signal that all higher timeframes oppose can be vetoed.
5. **Flip-strength score + conviction with hard vetoes** — at each flip a 0–100
   strength is built from breach depth, trend strength, efficiency, MTF agreement,
   regime alignment, volume thrust and volume delta, then gated by hard vetoes
   (volatility spike, higher timeframes opposed, a fresh flip inside a chop regime,
   cross-asset conflict). The output is one verdict plus a strength grade.

Remove any single layer and a specific Supertrend failure returns — that is the
justification for combining them.

### How it is original
ST ARC keeps a **self-calibrating quality engine**. It records every confirmed flip
and, a fixed window later, checks whether price actually ran a **favourable target
(measured in ATR)** in the flip's direction — i.e. whether the trade *worked*, not
merely whether the line avoided re-flipping. From that it reports, on the dashboard
and on each flip label, the **realized win-rate of past flips at each strength tier**
on this very symbol, plus the average favourable excursion. It can even **auto-learn
the strength threshold** at which flips have historically met a target win-rate and
use that as the action filter. A stock Supertrend tells you nothing about the quality
of its own signals; this one is accountable to its own track record.

### What it plots

- A single **Supertrend line** on price, green up / red down, with the flip triangle
  **colour-graded by strength** (strong = solid, weak = faded) and a small
  **strength label** on each flip (score + grade).
- An optional **second, slower Supertrend** (thinner line, contrasting colour,
  diamond markers) for fast/slow confluence, with a DUAL agreement readout.
- A compact **dashboard**: verdict, regime, direction, the live adaptive multiplier
  and ATR length, the flip state with its strength and that tier's realized
  win-rate, MTF agreement, the calibration stat, dominant cycle, a risk-based size
  reference and any active veto.

### How to use it

1. Trade with the line: long bias while it is below price (green), short while above
   (red). The line is a natural trailing stop.
2. Act on **confirmed flips** (the triangles), not raw touches, and weight them by
   the **strength score** — strong flips in a Trend regime with higher-timeframe
   agreement are the high-quality ones; weak flips in a chop regime are the ones to
   skip.
3. Use the **conviction / strength gates** and any active **veto** as a filter; the
   optional **auto-learned strength cutoff** suppresses the verdict on flips weaker
   than the level that has historically met your target win-rate.
4. The size shown is an ATR-based reference for journaling, not an order.
5. Alerts cover confirmed flips, the conviction verdict, raw flips and the secondary
   Supertrend.

### Settings (use on any asset / market)

- **Raw data source** — `hl2`, `hlc3`, `close`, `ohlc4`, or point it at **another
  indicator's plot**. This is what lets it work on any instrument or on your own
  series.
- **Supertrend core** — ATR length (with optional dominant-cycle adaptive length)
  and base multiplier.
- **Adaptive multiplier** — volatility-rank lookback, calm/volatile scaling and an
  optional chop-widening term.
- **Confirmation** — minimum breach in ATR, minimum bars between flips, non-repaint
  on close.
- **Calibration** — the judging window and the favourable target (in ATR) that
  defines a "good" flip; the auto-learn cutoff and its target win-rate.
- **Regime / MTF / conviction weights / secondary Supertrend** — all exposed.
- **Optional feeds (blank = off):** a *volatility-index symbol* (spike veto) and a
  *cross-asset symbol* (confluence). Both blank by default, so the script is fully
  self-contained on any market.

### Notes

- It is a **study / indicator**, not a strategy, and it places no orders.
- Confirmed flips are evaluated on bar close to avoid intrabar repainting;
  higher-timeframe reads use confirmed values.

---

### Disclaimer

This script is provided for educational and informational purposes only. It is a
technical-analysis study, not financial, investment, or trading advice, and not a
recommendation or solicitation to buy or sell any instrument. No indicator can
predict markets; past behaviour and any historical statistics shown (including the
flip win-rates) do not guarantee future results. Trading involves substantial risk of
loss. You are solely responsible for your own decisions — do your own research and
consider consulting a licensed financial professional before trading. The author
accepts no liability for any loss arising from use of this script.

## Source Code

````pine
// =============================================================================
// Calibrated Supertrend — Confirmed, Strength-Graded & Multi-Timeframe  Pine v6
// shorttitle: ST ARC
// ----------------------------------------------------------------------------
// A plain Supertrend has three well-known failures, and this fixes each one:
//   1. Its ATR multiplier is a fixed guess — too tight in volatile regimes
//      (constant whipsaw), too loose in calm ones (gives profit back). HERE the
//      multiplier is a SERIES that scales with a volatility-rank: it widens when
//      volatility is high and tightens when it is calm, and can widen further in
//      choppy (low-efficiency) tape.
//   2. It flips on noise — every marginal poke through the band reverses it. HERE
//      a flip is only CONFIRMED when the close breaches the prior band by a
//      minimum fraction of ATR and a minimum number of bars have passed since the
//      last flip (a de-whipsaw gate), evaluated on closed bars (non-repainting).
//   3. It has no context — it looks identical in a clean trend and in chop. HERE a
//      REGIME label (efficiency ratio + trend strength + volatility-cluster) and
//      non-repainting MULTI-TIMEFRAME agreement tell you when flips are
//      trustworthy, and a transparent CONVICTION score with hard vetoes folds it
//      into one verdict.
//   4. It adapts only AFTER the fact — even a volatility-ranked multiplier widens
//      once volatility has already shown up. HERE an optional PATH-DEPENDENT
//      VOLATILITY scaler reads the recent return path (activity clustering +
//      leverage + upside convexity) and pre-scales the band so it can widen
//      BEFORE the move and re-tighten as it calms. Off by default — when off it
//      is identical to before.
//
// WHY THESE PIECES ARE COMBINED (mashup rationale): the adaptive multiplier, the
// path-dependent scaler, the confirmation gate, the regime label and the MTF
// agreement are not decorative — remove any one and a specific, nameable failure
// of the plain Supertrend returns (whipsaw, late/loose stops, reacting late,
// fading a trend, flipping in chop). Each consumes the output of the previous
// layer and feeds the verdict.
//
// ORIGINALITY: on top of the Supertrend it keeps a self-calibrating EMPIRICAL
// FLIP-RELIABILITY tracker — from THIS symbol's own history it reports what
// fraction of confirmed flips were still in force N bars later, plus the average
// move after a flip. The thresholds are accountable, not assumed.
//
// Works on ANY symbol / timeframe / market. The raw data source and all optional
// feeds are user-selectable; nothing is hard-coded to a market.
//
// This is a study/indicator, not a strategy and not financial advice.
// =============================================================================

//@version=6
indicator("Calibrated Supertrend — Confirmed, Strength-Graded & Multi-Timeframe", shorttitle="ST ARC", overlay=true,
     max_lines_count=200, max_labels_count=200, precision=2)

// =============================================================================
// HELPERS  (UDFs may only use their args + built-ins, never globals)
// =============================================================================
f_clamp(x, lo, hi) => math.max(lo, math.min(hi, x))
chk(b)  => b ? "✓" : "✗"
sgn(x)  => x >= 0 ? "+" : ""
f_pos(s) => s=="top_left"?position.top_left : s=="bottom_right"?position.bottom_right : s=="bottom_left"?position.bottom_left : position.top_right
f_fetch(sym) => request.security(sym, timeframe.period, close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

// Standard-normal CDF (rational polynomial approximation; args + built-ins only).
f_normCdf(x) =>
    float t = 1.0 / (1.0 + 0.2316419 * math.abs(x))
    float d = 0.3989422804014327 * math.exp(-x * x / 2.0)
    float p = d * t * (0.319381530 + t*(-0.356563782 + t*(1.781477937 + t*(-1.821255978 + t*1.330274429))))
    x >= 0 ? 1.0 - p : p

// Bulk-volume-classified bar delta. Instead of the all-or-nothing tick rule
// (whole bar = buy if close>=open, else sell), split this bar's volume into a
// BUY FRACTION = CDF of the standardized price change, so a marginal bar adds a
// small signed delta and a large-range bar a strong one:  delta = V*(2*frac-1).
// Re-evaluates in whatever context it is called — the chart bar, OR each
// lower-timeframe bar inside request.security_lower_tf. Args + built-ins only.
f_bvcDelta(simple int len) =>
    float dP  = close - close[1]
    float sg  = ta.stdev(close - close[1], len)
    float z   = sg > 0 ? dP / sg : 0.0
    float buy = f_normCdf(z)
    nz(volume, 0.0) * (2.0 * buy - 1.0)

// Higher-timeframe Supertrend DIRECTION (built-in). Returns -1 up / +1 down.
f_htfdir(simple float fac, simple int per) =>
    [_st, d] = ta.supertrend(fac, per)
    d

// Build a timeframe string that is a multiple of the chart timeframe.
f_tfstr(simple int mult) =>
    secs = timeframe.in_seconds() * mult
    out = secs < 60        ? str.tostring(int(secs)) + "S"
       : secs < 86400      ? str.tostring(int(secs / 60))
       : secs < 604800     ? str.tostring(int(secs / 86400)) + "D"
       :                      str.tostring(int(secs / 604800)) + "W"
    out

// =============================================================================
// INPUTS
// =============================================================================
gCore   = "1 · Data Source & Supertrend"
src_in  = input.source(hl2,  "Raw data source", group=gCore, tooltip="The series the band is built from. Pick hl2 / hlc3 / close / ohlc4 or point it at ANOTHER indicator's plot. Works on any symbol, asset class or market.")
atrLen  = input.int   (10,   "ATR length", minval=1, maxval=100, group=gCore, tooltip="ATR period for the band width (Pine needs a simple length here). The MULTIPLIER is what adapts.")
baseMult= input.float (3.0,  "Base ATR multiplier", minval=0.5, maxval=12.0, step=0.1, group=gCore)
useAdaptLen=input.bool(true, "Adaptive ATR length (dominant cycle)", group=gCore, tooltip="Pick the ATR length from a Fibonacci ladder using the measured dominant cycle instead of a fixed number.")
atrCycMlt=input.float (0.5,  "  Cycle → length factor", minval=0.2, maxval=2.0, step=0.05, group=gCore)

gAdapt  = "2 · Adaptive Multiplier"
adaptOn = input.bool  (true, "Scale multiplier by volatility rank", group=gAdapt, tooltip="Widen the band when volatility is historically high (cut whipsaw); tighten it when calm.")
rankLen = input.int   (200,  "  Volatility-rank lookback", minval=30, maxval=1000, group=gAdapt)
multLoK = input.float (0.80, "  Scale @ calm (× base)", minval=0.3, maxval=1.5, step=0.05, group=gAdapt)
multHiK = input.float (1.80, "  Scale @ volatile (× base)", minval=1.0, maxval=4.0, step=0.05, group=gAdapt)
useChop = input.bool  (true, "Widen further in choppy tape", group=gAdapt, tooltip="When trend efficiency is low (chop), widen the band to avoid flip-flop.")
chopK   = input.float (0.60, "  Chop widen strength", minval=0.0, maxval=2.0, step=0.05, group=gAdapt)

gPdv    = "3 · Path-Dependent Volatility (anticipatory band)"
pdvOn   = input.bool (true , "Scale band by path-dependent volatility", group=gPdv, tooltip="Optional anticipatory layer. Reads the recent return PATH — activity clustering (fast vs slow average of squared returns), leverage (recent down-moves widen the band) and upside convexity (strong up-moves widen it a touch) — into one factor on the band distance, so the band can pre-widen BEFORE volatility arrives and re-tighten as it calms, instead of waiting for the volatility-rank to catch up. OFF (default) = identical band to before.")
pdvW    = input.float(0.50,  "  Influence weight (0 = off … 1 = full)", minval=0.0, maxval=1.0, step=0.05, group=gPdv, tooltip="Blend between the existing band and the path-scaled band. 0 reproduces the prior band even when enabled; 1 applies the full clamped factor.")
pdvFast = input.int  (10,    "  Fast path window (activity / drift)", minval=2, maxval=50, group=gPdv)
pdvSlow = input.int  (60,    "  Slow path window (baseline activity)", minval=10, maxval=250, group=gPdv)
pdvLev  = input.float(0.30,  "  Leverage strength (down-move widens)", minval=0.0, maxval=1.0, step=0.05, group=gPdv)
pdvCvx  = input.float(0.15,  "  Upside convexity (up-move widens)", minval=0.0, maxval=1.0, step=0.05, group=gPdv)
pdvLo   = input.float(0.70,  "  Min factor (floor)", minval=0.4, maxval=1.0, step=0.05, group=gPdv)
pdvHi   = input.float(1.80,  "  Max factor (cap)", minval=1.0, maxval=3.0, step=0.1, group=gPdv)

gConf   = "4 · Flip Confirmation (de-whipsaw)"
confK   = input.float (0.25, "Min breach to confirm (× ATR)", minval=0.0, maxval=3.0, step=0.05, group=gConf, tooltip="A raw flip is only CONFIRMED if the close breaches the prior band by at least this many ATRs.")
minHold = input.int   (2,    "Min bars since last flip", minval=0, maxval=50, group=gConf)
confirmClose=input.bool(true,"Evaluate signals on bar close (non-repaint)", group=gConf)

gReg    = "5 · Regime"
adxLen  = input.int   (14,   "ADX / DMI length", minval=2, maxval=60, group=gReg)
adxTrd  = input.float (20.0, "ADX trend threshold", minval=5, maxval=50, group=gReg)
erLen   = input.int   (14,   "Efficiency-ratio length", minval=2, maxval=60, group=gReg)
erTrd   = input.float (0.35, "ER trend threshold", minval=0.05, maxval=0.95, step=0.01, group=gReg)
regMaLn = input.int   (50,   "Trend MA length", minval=5, maxval=400, group=gReg)
normLen = input.int   (100,  "Vol-cluster normalize length", minval=20, maxval=500, group=gReg)
clustDecay=input.float(0.20, "Vol-cluster decay", minval=0.02, maxval=0.9, step=0.01, group=gReg, tooltip="Decay of the self-exciting volatility-cluster intensity. Lower = longer memory.")
clustThr= input.float (1.5,  "Vol-cluster z threshold", minval=0.5, maxval=4.0, step=0.1, group=gReg)
chopSrc = input.string("Efficiency ratio", "Trend-quality source", options=["Efficiency ratio","Fractal dimension","Blend"], group=gReg, tooltip="Which estimator drives the trend-vs-chop test. NOTE: the fractal dimension and the efficiency ratio measure the SAME axis (how directional the move is vs how much it wiggles), so this SWAPS the estimator rather than stacking a second redundant vote. Default = efficiency ratio (behaviour unchanged). Fractal dimension reads multi-scale roughness (two half-windows vs the whole); Blend averages the two. The fractal-dimension value is always shown on the dashboard as a cross-check.")
fdiLen  = input.int   (30,   "  Fractal-dimension length (even)", minval=10, maxval=120, group=gReg, tooltip="Window for the fractal-dimension estimate. Split into two equal halves internally, so an even number is used.")

gMtf    = "6 · Multi-Timeframe Agreement"
useMtf  = input.bool  (true, "Enable MTF Supertrend agreement", group=gMtf)
htfM1   = input.int   (3,    "HTF multiple 1", minval=2, maxval=60, group=gMtf, tooltip="Higher timeframe = this many times the chart timeframe.")
htfM2   = input.int   (6,    "HTF multiple 2", minval=2, maxval=120, group=gMtf)
htfM3   = input.int   (12,   "HTF multiple 3", minval=2, maxval=240, group=gMtf)
mtfFac  = input.float (3.0,  "HTF Supertrend factor", minval=0.5, maxval=12.0, step=0.1, group=gMtf)
useHtfGate=input.bool (true, "Veto signals that all HTFs oppose", group=gMtf)

gCal    = "8 · Calibration & Flip Reliability"
evalK   = input.int   (24,   "Bars to judge a flip", minval=2, maxval=300, group=gCal, tooltip="Window after a flip over which it is judged. A flip is counted as 'good' if price ran at least the favourable target (below) in the flip's direction within this window — i.e. the trade actually worked, not merely that the line did not re-flip.")
favATR  = input.float (1.0,  "Favourable move to count a flip good (ATR)", minval=0.1, maxval=5.0, step=0.1, group=gCal)
wfRecent= input.int   (30,   "Walk-forward recent window (flips)", minval=5, maxval=500, group=gCal, tooltip="Hold-rate is also computed over just the most recent N flips and compared to the all-history rate. A recent rate well below the all-history rate means the edge is decaying out-of-sample (regime shift or overfitting) — visible instead of hidden inside a pooled lifetime average.")
minRunsN= input.int   (12,   "Min flips for runs-test", minval=6, maxval=200, group=gCal, tooltip="Minimum evaluated flips before the runs-test Z is reported. The test asks whether wins and losses are independent or CLUSTER (a streaky, regime-dependent edge).")

gSelf   = "9 · Adaptive Engine (self-calibration)"
adaptMode  = input.bool (true,  "Self-calibrating thresholds", group=gSelf, tooltip="Replace the fixed regime / breach / hold thresholds with percentiles of THIS symbol's own recent distribution, so 'trending', 'meaningful breach' and 'min hold' adapt to the instrument.")
calLen     = input.int  (300,   "  Calibration lookback", minval=50, maxval=3000, group=gSelf)
adxPctl    = input.float(55,    "  ADX trend percentile", minval=20, maxval=90, group=gSelf)
erPctl     = input.float(55,    "  Efficiency trend percentile", minval=20, maxval=90, group=gSelf)
confPctl   = input.float(40,    "  Breach-size percentile", minval=10, maxval=90, group=gSelf, tooltip="A flip must breach the band by more than this percentile of past flip breaches.")
minHoldCyc = input.float(0.25,  "  Min hold = cycle x", minval=0.05, maxval=1.0, step=0.05, group=gSelf)
useSelfTune= input.bool (false, "Self-tune base multiplier (online)", group=gSelf, tooltip="Online walk-forward: track which multiplier from a small grid has produced the fewest fast reversals on THIS symbol, and use it. Off by default - more adaptive is not always better, and this is the overfit-prone lever.")
selfMinLife= input.int  (5,     "  Bars before a flip counts as good", minval=2, maxval=50, group=gSelf)
selfMinFlips=input.int  (6,     "  Min flips before trusting a candidate", minval=3, maxval=50, group=gSelf)
selfHyst   = input.float(0.05,  "  Switch hysteresis", minval=0.0, maxval=0.5, step=0.01, group=gSelf)
usePlateau = input.bool (true,  "  Plateau-robust grid pick", group=gSelf, tooltip="When self-tuning the multiplier, prefer a value whose NEIGHBOURING grid multipliers are also good (a broad plateau) over a lone best spike. A spike that beats its neighbours is usually overfit to noise; a plateau is robust. Scored as neighbourhood mean minus k×std of the neighbours' quality.")
plateauK   = input.float(0.50,  "  Plateau penalty k", minval=0.0, maxval=2.0, step=0.05, group=gSelf, tooltip="How hard to penalise disagreement among neighbouring grid multipliers. 0 = ignore spread (just the local mean); higher = more strongly avoid fragile peaks.")

gVol    = "7 · Volume Delta (trade-side)"
useBVC  = input.bool (true, "Bulk-volume trade-side classification", group=gVol, tooltip="Classify each bar's volume into buy/sell by the CDF of its standardized price change (bulk volume classification) instead of the all-or-nothing tick rule (close>=open). Splits volume into a buy FRACTION, so marginal bars contribute a small signed delta and large-range bars a strong one — a less noisy CVD. OFF = original tick-rule delta.")
bvcLen  = input.int  (20,   "  Std-dev window for standardization", minval=5, maxval=200, group=gVol, tooltip="Lookback for the price-change standard deviation used to standardize each bar's move before the CDF. Evaluated on the volume-delta lower timeframe when intrabar data is available, else on the chart bar.")
ltfRes  = input.timeframe("1","Volume-delta lower timeframe", group=gVol, tooltip="Intrabar resolution used to build the per-bar buy/sell delta. 1 minute suits intraday NIFTY/BankNifty; raise it on higher-timeframe charts. Falls back to a chart-bar estimate when intrabar data is unavailable.")

gData   = "10 · Optional Feeds (blank = off)"
vixSym  = input.symbol("NSE:INDIAVIX", "Volatility-index symbol", group=gData, tooltip="Default is India VIX for NIFTY/BankNifty. For other markets enter your own volatility index (e.g. the relevant VIX). Blank or an invalid symbol = simply ignored, so it never breaks on assets without one.")
vixLen  = input.int   (20,   "  Vol-index z length", minval=5, maxval=200, group=gData)
vixSpk  = input.float (1.5,  "  Vol-index spike z", minval=0.5, maxval=4.0, step=0.1, group=gData)
xaSym   = input.string("",   "Cross-asset symbol", group=gData, tooltip="Optional. Correlated/inverse instrument for confluence. Set sign below. Blank = off.")
xaSign  = input.int   (1,    "  Cross-asset sign (+1 / -1)", minval=-1, maxval=1, group=gData)
xaLen   = input.int   (10,   "  Cross-asset momentum length", minval=2, maxval=100, group=gData)

gCon    = "11 · Conviction & Vetoes"
wReg    = input.float (24,   "Weight: regime alignment", group=gCon)
wMtf    = input.float (22,   "Weight: MTF agreement", group=gCon)
wClr    = input.float (18,   "Weight: band clearance", group=gCon)
wER     = input.float (16,   "Weight: trend efficiency", group=gCon)
wCvd    = input.float (12,   "Weight: volume delta", group=gCon)
wXa     = input.float (8,    "Weight: cross-asset", group=gCon)
minConv = input.int   (45,   "Min conviction to act", minval=0, maxval=100, group=gCon)
minStr  = input.int   (0,    "Min flip strength to act", minval=0, maxval=100, group=gCon, tooltip="Suppress the LONG/SHORT verdict on flips weaker than this strength. 0 = act on all flips (still graded visually).")
useAutoStr = input.bool (true , "Auto-learn strength cutoff", group=gCon, tooltip="Learn the lowest flip-strength whose past flips held at least the target rate, and use that as the min-strength gate (overrides the manual value once enough flips are seen).")
autoTarget = input.float(60,    "  Target hold-rate %", minval=40, maxval=95, group=gCon)
autoMinN   = input.int  (20,    "  Min flips before trusting cutoff", minval=5, maxval=300, group=gCon)
useChopVeto=input.bool(true, "Veto fresh flips in Range/Volatile", group=gCon)

gRisk   = "12 · Risk Context (dashboard only)"
equity  = input.float (100000, "Account equity", minval=0, group=gRisk)
riskPct = input.float (1.0,  "Risk per trade %", minval=0.0, maxval=100, step=0.1, group=gRisk)
ptValue = input.float (1.0,  "Point value / unit", minval=0.0, group=gRisk)

gPair   = "13 · Secondary Supertrend (overlay pair)"
usePair = input.bool (false, "Show a second Supertrend", group=gPair, tooltip="Overlay a second, slower fixed-multiplier Supertrend for fast/slow confluence. Drawn thinner, in a contrasting colour, with diamond flip markers.")
sec2Mult= input.float(6.0,   "Secondary ATR multiplier", minval=0.5, maxval=25.0, step=0.1, group=gPair, tooltip="Set the primary near 3x (Core group) and this near 10-15x for a slow macro trend line.")
sec2Len = input.int  (20,    "Secondary ATR length", minval=1, maxval=200, group=gPair)
secMarks= input.bool (true,  "Secondary flip markers", group=gPair)

gVis    = "14 · Dashboard & Visuals"
showLine= input.bool  (true, "Plot Supertrend line", group=gVis)
showFill= input.bool  (true, "Shade trend zone (line ↔ price)", group=gVis)
showFlip= input.bool  (true, "Confirmed flip markers", group=gVis)
showStr = input.bool  (true, "Flip-strength score labels", group=gVis)
showRaw = input.bool  (false,"Raw (unconfirmed) flip dots", group=gVis)
showReg = input.bool  (true ,"Faint regime background", group=gVis)
showTbl = input.bool  (true, "Dashboard", group=gVis)
compactTbl=input.bool (true, "  Compact dashboard", group=gVis)
showLegend=input.bool (false,"  Legend rows", group=gVis)
tblTheme= input.string("Auto","Dashboard theme", options=["Auto","Dark","Light"], group=gVis)
tblPos  = input.string("top_right","Dashboard position", options=["top_right","top_left","bottom_right","bottom_left"], group=gVis)
showId  = input.bool  (true, "Identity label", group=gVis)

// =============================================================================
// L1b — DOMINANT CYCLE (homodyne discriminator)
// =============================================================================
hl2src = (high + low) / 2.0
var float Period = 12.0
Smooth = (4*hl2src + 3*hl2src[1] + 2*hl2src[2] + hl2src[3]) / 10.0
adjc = (0.075*Period + 0.54)
Detr = (0.0962*Smooth + 0.5769*nz(Smooth[2]) - 0.5769*nz(Smooth[4]) - 0.0962*nz(Smooth[6])) * adjc
Q1   = (0.0962*Detr + 0.5769*nz(Detr[2]) - 0.5769*nz(Detr[4]) - 0.0962*nz(Detr[6])) * adjc
I1   = nz(Detr[3])
jI   = (0.0962*I1 + 0.5769*nz(I1[2]) - 0.5769*nz(I1[4]) - 0.0962*nz(I1[6])) * adjc
jQ   = (0.0962*Q1 + 0.5769*nz(Q1[2]) - 0.5769*nz(Q1[4]) - 0.0962*nz(Q1[6])) * adjc
var float I2 = 0.0
var float Q2 = 0.0
I2 := 0.2*(I1 - jQ) + 0.8*nz(I2[1])
Q2 := 0.2*(Q1 + jI) + 0.8*nz(Q2[1])
var float Re = 0.0
var float Im = 0.0
Re := 0.2*(I2*nz(I2[1]) + Q2*nz(Q2[1])) + 0.8*nz(Re[1])
Im := 0.2*(I2*nz(Q2[1]) - Q2*nz(I2[1])) + 0.8*nz(Im[1])
float pNew = Period
if Im != 0 and Re != 0
    pNew := 2.0 * math.pi / math.abs(math.atan(Im / Re))
pNew := f_clamp(pNew, 0.67*Period, 1.5*Period)
pNew := f_clamp(pNew, 6.0, 50.0)
Period := 0.2*pNew + 0.8*Period
domCycle = Period
cycRising = Detr >= nz(Detr[1], Detr)

// =============================================================================
// L3 — REGIME (efficiency ratio + ADX + volatility-cluster)
// =============================================================================
[diP, diM, adx] = ta.dmi(adxLen, adxLen)
logRet = math.abs(nz(ta.change(math.log(close))))
var float clustI = 0.0
clustI := clustI * math.exp(-clustDecay) + logRet
hMeanH = ta.sma(clustI, normLen)
hStdH  = ta.stdev(clustI, normLen)
clustZ = hStdH == 0 ? 0.0 : (clustI - hMeanH) / hStdH
volCluster = clustZ > clustThr
erChg = math.abs(src_in - src_in[erLen])
erVol = math.sum(math.abs(src_in - src_in[1]), erLen)
er = erVol == 0 ? 0.0 : erChg / erVol
// Fractal dimension (multi-scale roughness): compare the normalized range of the
// two half-windows to that of the whole. ~1 = clean/trending, ~2 = rough/choppy.
// Same axis as the efficiency ratio, so used as a SWAPPABLE estimator, not a
// stacked vote. Mapped to a 0..1 "trendiness" (1 = clean trend) for the test.
fdiHalf = int(fdiLen / 2)
fN3 = (ta.highest(high, fdiLen) - ta.lowest(low, fdiLen)) / fdiLen
fN2 = (ta.highest(high, fdiHalf) - ta.lowest(low, fdiHalf)) / fdiHalf
fN1 = (ta.highest(high, fdiHalf)[fdiHalf] - ta.lowest(low, fdiHalf)[fdiHalf]) / fdiHalf
fdiRaw = (fN1 > 0 and fN2 > 0 and fN3 > 0) ? (math.log(fN1 + fN2) - math.log(fN3)) / math.log(2.0) : 1.5
fdi = f_clamp(fdiRaw, 1.0, 2.0)
fdiTrend = f_clamp(2.0 - fdi, 0.0, 1.0)
trendiness = chopSrc == "Fractal dimension" ? fdiTrend : chopSrc == "Blend" ? 0.5 * (er + fdiTrend) : er
trendMa = ta.ema(close, regMaLn)
bull = close > trendMa
adxTrdAdapt = ta.percentile_linear_interpolation(adx, calLen, adxPctl)
erTrdAdapt  = ta.percentile_linear_interpolation(trendiness, calLen, erPctl)
adxTrdUse = adaptMode ? adxTrdAdapt : adxTrd
erTrdUse  = adaptMode ? erTrdAdapt  : erTrd
trending = adx > adxTrdUse and trendiness > erTrdUse
regimePct = math.round(f_clamp((adx/40.0)*50 + trendiness*50, 0, 100))
string regime = volCluster and not trending ? "Volatile" : trending ? (bull ? "Trend Bull" : "Trend Bear") : "Range"
isRange = regime == "Range"
isVol   = regime == "Volatile"
isTrend = trending

// =============================================================================
// FEEDS — volume delta + optional volatility index + cross-asset
// =============================================================================
volNz = nz(volume, 0.0)
volLive = ta.cum(volNz) > 0
ltfArr = request.security_lower_tf(syminfo.tickerid, ltfRes, useBVC ? f_bvcDelta(bvcLen) : (close >= open ? 1.0 : -1.0) * volNz)
ltfOk  = array.size(ltfArr) > 0
barDeltaChart = useBVC ? f_bvcDelta(bvcLen) : (close >= open ? 1.0 : -1.0) * volNz
barDelta = ltfOk ? array.sum(ltfArr) : barDeltaChart
cvd = ta.cum(barDelta)
cvdSlope = cvd - nz(cvd[5], cvd)
cvdSign = math.sign(cvdSlope)

vix = f_fetch(vixSym)
vixLive = not na(vix)
vixMean = ta.sma(vix, vixLen)
vixSD   = ta.stdev(vix, vixLen)
vixZ = (vixLive and vixSD > 0) ? (vix - vixMean) / vixSD : 0.0
vixSpike = vixLive and vixZ >= vixSpk
xaSymUse = str.length(xaSym) > 0 ? xaSym : syminfo.tickerid
xaRaw = request.security(xaSymUse, timeframe.period, close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
xa = str.length(xaSym) > 0 ? xaRaw : na
xaLive = not na(xa)
xaMom = xaLive ? math.sign(xa - nz(xa[xaLen], xa)) * xaSign : 0

// =============================================================================
// L1 — SUPERTREND ENGINE (adaptive ATR length + adaptive multiplier)
// =============================================================================
atr0 = ta.atr(atrLen)
// Fibonacci ATR ladder for the adaptive-length option (all simple ints).
atrL5  = ta.atr(5)
atrL8  = ta.atr(8)
atrL13 = ta.atr(13)
atrL21 = ta.atr(21)
atrL34 = ta.atr(34)
lenTarget = int(f_clamp(math.round(domCycle * atrCycMlt), 5, 34))
atrAdaptive = lenTarget<=6 ? atrL5 : lenTarget<=10 ? atrL8 : lenTarget<=17 ? atrL13 : lenTarget<=27 ? atrL21 : atrL34
lenShown    = lenTarget<=6 ? 5    : lenTarget<=10 ? 8    : lenTarget<=17 ? 13    : lenTarget<=27 ? 21    : 34
atrUse = useAdaptLen ? atrAdaptive : atr0
lenUse = useAdaptLen ? lenShown : atrLen

// online self-tune of the base multiplier (optional): choose the grid value that
// has produced the fewest fast reversals (whipsaws) on THIS symbol so far.
var float[] gM    = array.from(2.0, 2.5, 3.0, 3.5, 4.0)
var float[] gFL   = array.new_float(5, na)
var float[] gFU   = array.new_float(5, na)
var int[]   gDir  = array.new_int(5, 1)
var int[]   gLast = array.new_int(5, 0)
var int[]   gFlip = array.new_int(5, 0)
var int[]   gWhip = array.new_int(5, 0)
var float[] qScore = array.new_float(5, -1.0)
var float[] pScore = array.new_float(5, -2.0)
var int     selIdx = 2
if useSelfTune
    for j = 0 to 4
        m   = array.get(gM, j)
        bl  = src_in - m * atrUse
        bu  = src_in + m * atrUse
        pfl = array.get(gFL, j)
        pfu = array.get(gFU, j)
        pdr = array.get(gDir, j)
        nfl = na(pfl) ? bl : ((bl > pfl) or (close[1] < pfl) ? bl : pfl)
        nfu = na(pfu) ? bu : ((bu < pfu) or (close[1] > pfu) ? bu : pfu)
        ndr = na(pfl) ? 1 : (pdr == 1 ? (close < pfl ? -1 : 1) : (close > pfu ? 1 : -1))
        if ndr != pdr
            life = bar_index - array.get(gLast, j)
            array.set(gFlip, j, array.get(gFlip, j) + 1)
            if life < selfMinLife
                array.set(gWhip, j, array.get(gWhip, j) + 1)
            array.set(gLast, j, bar_index)
        array.set(gFL, j, nfl)
        array.set(gFU, j, nfu)
        array.set(gDir, j, ndr)
    // quality per candidate: fraction of flips that were NOT fast whipsaws
    for j = 0 to 4
        fl = array.get(gFlip, j)
        array.set(qScore, j, fl >= selfMinFlips ? 1.0 - array.get(gWhip, j) / fl : -1.0)
    // plateau-robust score: reward a candidate whose grid NEIGHBOURS are also good
    // (a broad plateau) over a lone spike (fragile / likely overfit to noise).
    // pScore = neighbourhood mean - plateauK * neighbourhood std.
    for j = 0 to 4
        qj = array.get(qScore, j)
        if qj <= -0.5
            array.set(pScore, j, -2.0)
        else
            float nSum = 0.0
            float nSm2 = 0.0
            int   nCnt = 0
            for d = -1 to 1
                k = j + d
                if k >= 0 and k <= 4
                    qk = array.get(qScore, k)
                    if qk > -0.5
                        nSum += qk
                        nSm2 += qk * qk
                        nCnt += 1
            mn = nCnt > 0 ? nSum / nCnt : qj
            vr = nCnt > 0 ? math.max(nSm2 / nCnt - mn * mn, 0.0) : 0.0
            array.set(pScore, j, usePlateau ? mn - plateauK * math.sqrt(vr) : qj)
    bestI = selIdx
    bestP = array.get(pScore, selIdx)
    for j = 0 to 4
        if array.get(pScore, j) > bestP
            bestP := array.get(pScore, j)
            bestI := j
    curP = array.get(pScore, selIdx)
    if bestP > curP + selfHyst
        selIdx := bestI
selfMult = useSelfTune ? array.get(gM, selIdx) : baseMult

// adaptive multiplier
volRank = ta.percentrank(atr0, rankLen) / 100.0
baseMultUse = useSelfTune ? selfMult : baseMult
multBase = adaptOn ? baseMultUse * f_clamp(multLoK + (multHiK - multLoK) * volRank, multLoK, multHiK) : baseMultUse
multUse = useChop ? multBase * (1.0 + chopK * (1.0 - f_clamp(trendiness, 0, 1))) : multBase
// path-dependent volatility scaler (anticipatory): read the recent return path —
// activity clustering (fast/slow EWMA of squared returns), leverage (recent
// down-moves widen) and upside convexity (recent up-moves widen) — into one
// factor on the band. Built from src_in + atrUse only. OFF -> factor 1.0.
pdvRet   = src_in - src_in[1]
pdvR2    = pdvRet * pdvRet
pdvFastV = ta.ema(pdvR2, pdvFast)
pdvSlowV = ta.ema(pdvR2, pdvSlow)
pdvActiv = pdvSlowV > 0 ? math.sqrt(pdvFastV / pdvSlowV) : 1.0
pdvDrift = ta.ema(pdvRet, pdvFast)
pdvDn    = atrUse > 0 ? pdvDrift / atrUse : 0.0
pdvLever = pdvDn < 0 ? -pdvDn * pdvLev : 0.0
pdvConvx = pdvDn > 0 ?  pdvDn * pdvCvx : 0.0
pdvFactor= f_clamp(pdvActiv + pdvLever + pdvConvx, pdvLo, pdvHi)
pdvAdj   = pdvOn ? (1.0 - pdvW) + pdvW * pdvFactor : 1.0
multUse := multUse * pdvAdj
multUse := f_clamp(multUse, 0.3, 20.0)

// classic non-repainting Supertrend recursion on the chosen source
basicLower = src_in - multUse * atrUse
basicUpper = src_in + multUse * atrUse
var float fLower = na
var float fUpper = na
fLower := na(fLower[1]) ? basicLower : ((basicLower > fLower[1]) or (close[1] < fLower[1]) ? basicLower : fLower[1])
fUpper := na(fUpper[1]) ? basicUpper : ((basicUpper < fUpper[1]) or (close[1] > fUpper[1]) ? basicUpper : fUpper[1])
var int dir = 1
dir := na(dir[1]) ? 1 : (dir[1] == 1 ? (close < fLower[1] ? -1 : 1) : (close > fUpper[1] ? 1 : -1))
stRaw = dir == 1 ? fLower : fUpper

flipUpRaw = dir == 1 and dir[1] == -1
flipDnRaw = dir == -1 and dir[1] == 1

// =============================================================================
// L2 — FLIP CONFIRMATION (breach magnitude + min bars; non-repaint on close)
// =============================================================================
var int lastFlipIdx = na
barsSinceFlip = na(lastFlipIdx) ? 100000 : bar_index - lastFlipIdx
breachUp = close - nz(fUpper[1], close)
breachDn = nz(fLower[1], close) - close
barOk = confirmClose ? barstate.isconfirmed : true
// adaptive confirmation: breach threshold = percentile of past flip breaches; hold = cycle fraction
var float[] brArr = array.new_float(0)
confKAdapt = array.size(brArr) >= 10 ? f_clamp(array.percentile_linear_interpolation(brArr, confPctl), 0.0, 3.0) : confK
confKUse   = adaptMode ? confKAdapt : confK
minHoldUse = adaptMode ? int(f_clamp(math.round(domCycle * minHoldCyc), 1, 50)) : minHold
confUp = flipUpRaw and breachUp >= confKUse * atrUse and barsSinceFlip >= minHoldUse and barOk
confDn = flipDnRaw and breachDn >= confKUse * atrUse and barsSinceFlip >= minHoldUse and barOk
if flipUpRaw or flipDnRaw
    lastFlipIdx := bar_index
    brMag = (flipUpRaw ? breachUp : breachDn) / (atrUse == 0 ? 1 : atrUse)
    if brMag > 0
        array.push(brArr, brMag)
        if array.size(brArr) > 200
            array.shift(brArr)
clearance = (dir == 1 ? close - stRaw : stRaw - close) / (atrUse == 0 ? 1 : atrUse)

// =============================================================================
// L5 — EMPIRICAL FLIP RELIABILITY (this symbol's own confirmed flips)
// =============================================================================
// judge each flip by FOLLOW-THROUGH: max favourable excursion >= target ATR
hh_e   = ta.highest(high, evalK)
ll_e   = ta.lowest(low,  evalK)
flipAgo = confUp[evalK] or confDn[evalK]
dThen   = dir[evalK]
atrF    = nz(atrUse[evalK], 0.0)
mfeAgo  = dThen > 0 ? hh_e - close[evalK] : close[evalK] - ll_e
goodAgo = atrF > 0 and mfeAgo >= favATR * atrF
var int   flipsEval = 0
var int   flipsHeld = 0
var float favSum    = 0.0
var int[] flipSeq   = array.new_int(0)
var int   wwRuns    = 0
var int   wwPrev    = -1
if barstate.isconfirmed and bar_index > evalK + 5 and flipAgo
    flipsEval += 1
    if goodAgo
        flipsHeld += 1
    favSum += atrF > 0 ? mfeAgo / atrF : 0.0
    int o = goodAgo ? 1 : 0
    array.push(flipSeq, o)
    if array.size(flipSeq) > 2000
        array.shift(flipSeq)
    if wwPrev == -1
        wwRuns := 1
    else if o != wwPrev
        wwRuns += 1
    wwPrev := o
holdRate = flipsEval > 0 ? flipsHeld / flipsEval * 100.0 : na
avgFav   = flipsEval > 0 ? favSum / flipsEval : na
// WALK-FORWARD degradation: hold-rate over the most recent flips vs all history.
// recent << all => the edge is decaying out-of-sample (regime shift / overfit),
// which a pooled lifetime average would hide.
seqN    = array.size(flipSeq)
recWant = math.min(seqN, wfRecent)
int recHit = 0
if recWant > 0
    for i = seqN - recWant to seqN - 1
        recHit += array.get(flipSeq, i)
recentRate = recWant > 0 ? 100.0 * recHit / recWant : na
wfDelta    = (not na(recentRate) and not na(holdRate)) ? recentRate - holdRate : na
// RUNS TEST on the win/loss sequence: are outcomes independent,
// or do wins/losses CLUSTER? Z<0 = too few runs (streaky, regime-dependent edge);
// |Z| < 1.96 ~ independent at 95%.
wwN1 = flipsHeld
wwN2 = flipsEval - flipsHeld
wwN  = flipsEval
wwMu = wwN > 0 ? 2.0 * wwN1 * wwN2 / wwN + 1.0 : na
wwVarNum = 2.0 * wwN1 * wwN2 * (2.0 * wwN1 * wwN2 - wwN)
wwVarDen = wwN * wwN * (wwN - 1)
wwVar = (wwN > 1 and wwVarDen != 0) ? wwVarNum / wwVarDen : na
wwSd  = (not na(wwVar) and wwVar > 0) ? math.sqrt(wwVar) : na
wwZ   = (not na(wwSd) and wwSd > 0 and wwN1 > 0 and wwN2 > 0 and wwN >= minRunsN) ? (wwRuns - wwMu) / wwSd : na

// =============================================================================
// L1c — SECONDARY (slower) SUPERTREND  — optional fast/slow pair
// =============================================================================
atrSec = ta.atr(sec2Len)
basicLowerS = src_in - sec2Mult * atrSec
basicUpperS = src_in + sec2Mult * atrSec
var float sLower = na
var float sUpper = na
sLower := na(sLower[1]) ? basicLowerS : ((basicLowerS > sLower[1]) or (close[1] < sLower[1]) ? basicLowerS : sLower[1])
sUpper := na(sUpper[1]) ? basicUpperS : ((basicUpperS < sUpper[1]) or (close[1] > sUpper[1]) ? basicUpperS : sUpper[1])
var int sDir = 1
sDir := na(sDir[1]) ? 1 : (sDir[1] == 1 ? (close < sLower[1] ? -1 : 1) : (close > sUpper[1] ? 1 : -1))
sStRaw = sDir == 1 ? sLower : sUpper
secFlipUp = sDir == 1 and sDir[1] == -1
secFlipDn = sDir == -1 and sDir[1] == 1

// =============================================================================
// MTF — higher-timeframe Supertrend direction agreement (no repaint via [1])
// =============================================================================
hd1 = useMtf ? nz(request.security(syminfo.tickerid, f_tfstr(htfM1), -f_htfdir(mtfFac, atrLen)[1], lookahead=barmerge.lookahead_off), 0.0) : 0.0
hd2 = useMtf ? nz(request.security(syminfo.tickerid, f_tfstr(htfM2), -f_htfdir(mtfFac, atrLen)[1], lookahead=barmerge.lookahead_off), 0.0) : 0.0
hd3 = useMtf ? nz(request.security(syminfo.tickerid, f_tfstr(htfM3), -f_htfdir(mtfFac, atrLen)[1], lookahead=barmerge.lookahead_off), 0.0) : 0.0
mtfBull = (hd1>0?1:0)+(hd2>0?1:0)+(hd3>0?1:0)
mtfBear = (hd1<0?1:0)+(hd2<0?1:0)+(hd3<0?1:0)
mtfAllOppose = dir>0 ? (mtfBear==3) : dir<0 ? (mtfBull==3) : false

// =============================================================================
// FLIP STRENGTH — 0-100 score latched at each flip, calibrated to realized holds
// =============================================================================
volSma20  = ta.sma(volNz, 20)
volThrust = volLive ? volNz > volSma20 * 1.2 : true
sBreachF = f_clamp((dir>0 ? breachUp : breachDn) / (atrUse==0 ? 1 : atrUse), 0, 1)
sAdxF    = f_clamp(adx / 40.0, 0, 1)
sERF     = f_clamp(trendiness, 0, 1)
sMtfF    = useMtf ? (dir>0 ? mtfBull/3.0 : dir<0 ? mtfBear/3.0 : 0.0) : 0.5
sRegF    = isTrend and ((bull and dir>0) or (not bull and dir<0)) ? 1.0 : isRange ? 0.4 : isVol ? 0.3 : 0.5
sVolF    = volThrust ? 1.0 : 0.4
sCvdF    = cvdSign==dir and dir!=0 ? 1.0 : 0.4
sDualF   = usePair ? (((dir>0 and sDir>0) or (dir<0 and sDir<0)) ? 1.0 : 0.4) : 0.6
strengthNow = math.round(f_clamp(22*sBreachF + 15*sAdxF + 13*sERF + 18*sMtfF + 15*sRegF + 7*sVolF + 6*sCvdF + 4*sDualF, 0, 100))
flipStr = (confUp or confDn) ? strengthNow : na
var float lastFlipStr = na
if confUp or confDn
    lastFlipStr := strengthNow
// calibrate: realized hold-rate per strength bucket (0=weak,1=medium,2=strong)
var int[] bkEval  = array.new_int(3, 0)
var int[] bkHeld  = array.new_int(3, 0)
var int[] binEval = array.new_int(20, 0)
var int[] binHeld = array.new_int(20, 0)
if barstate.isconfirmed and bar_index > evalK + 5 and flipAgo
    sv = nz(flipStr[evalK], 50.0)
    bk = sv>=70 ? 2 : sv>=40 ? 1 : 0
    array.set(bkEval, bk, array.get(bkEval, bk) + 1)
    if goodAgo
        array.set(bkHeld, bk, array.get(bkHeld, bk) + 1)
    bn = int(f_clamp(math.floor(sv / 5.0), 0, 19))
    array.set(binEval, bn, array.get(binEval, bn) + 1)
    if goodAgo
        array.set(binHeld, bn, array.get(binHeld, bn) + 1)
lastBk     = na(lastFlipStr) ? 1 : (lastFlipStr>=70 ? 2 : lastFlipStr>=40 ? 1 : 0)
lastBkEval = array.get(bkEval, lastBk)
lastBkRate = lastBkEval > 0 ? array.get(bkHeld, lastBk) / lastBkEval * 100.0 : na

// auto-learn cutoff: lowest threshold T whose flips with strength >= T held >= target
int totFlips = 0
for j = 0 to 19
    totFlips += array.get(binEval, j)
var float autoCut = na
if useAutoStr and totFlips >= autoMinN
    int cumE = 0
    int cumH = 0
    float cut = na
    bool stop = false
    for j = 19 to 0
        if not stop
            cumE += array.get(binEval, j)
            cumH += array.get(binHeld, j)
            rateC = cumE > 0 ? cumH / cumE * 100.0 : 0.0
            if cumE >= 5 and rateC >= autoTarget
                cut := j * 5.0
            else if cumE >= 5 and rateC < autoTarget and not na(cut)
                stop := true
    autoCut := cut
minStrUse = useAutoStr and not na(autoCut) ? autoCut : minStr

// =============================================================================
// CON — CONVICTION (scores the current stance) + hard vetoes
// =============================================================================
sReg = isTrend ? ((bull and dir>0) or (not bull and dir<0) ? 1.0 : 0.5) : isRange ? 0.45 : 0.3
sMtf = useMtf ? (dir>0 ? mtfBull/3.0 : dir<0 ? mtfBear/3.0 : 0.0) : 0.5
sClr = f_clamp(clearance / 2.0, 0, 1)
sER  = f_clamp(trendiness, 0, 1)
sCvd = cvdSign==dir and dir!=0 ? 1.0 : 0.4
sXa  = xaLive ? (xaMom==dir and dir!=0 ? 1.0 : 0.4) : 0.5

wSum = wReg+wMtf+wClr+wER+wCvd+wXa
rawConv = wReg*sReg + wMtf*sMtf + wClr*sClr + wER*sER + wCvd*sCvd + wXa*sXa
conv = dir==0 ? 0 : math.round(f_clamp(wSum>0 ? rawConv/wSum*100.0 : 0, 0, 100))
tier = conv>=75?"S" : conv>=60?"A" : conv>=45?"B" : "-"

freshFlip = confUp or confDn
vVix  = vixSpike and freshFlip
vMtf  = useHtfGate and freshFlip and mtfAllOppose
vChop = useChopVeto and freshFlip and (isRange or isVol)
vXa   = xaLive and freshFlip and xaMom!=0 and xaMom!=dir
vetoes = vVix or vMtf or vChop or vXa
vetoTxt = vVix?"vol spike" : vMtf?"HTF oppose" : vChop?"chop regime" : vXa?"cross-asset" : "none"

act = freshFlip and conv>=minConv and strengthNow>=minStrUse and not vetoes
longTrig  = act and dir>0
shortTrig = act and dir<0
verdict = freshFlip and vetoes ? "VETO" : freshFlip and conv<minConv ? "WEAK" : confUp ? "LONG" : confDn ? "SHORT" : dir>0 ? "HOLD L" : dir<0 ? "HOLD S" : "FLAT"

// =============================================================================
// RISK CONTEXT  (the Supertrend line is the natural stop)
// =============================================================================
stopPx = stRaw
stopDist = math.abs(close - stopPx)
riskCap = equity * riskPct / 100.0
perUnit = stopDist * ptValue
qty = perUnit > 0 ? math.floor(riskCap / perUnit) : 0

// =============================================================================
// ALERTS
// =============================================================================
alertcondition(confUp, "Confirmed flip UP",   "ST ARC: confirmed bullish flip")
alertcondition(confDn, "Confirmed flip DOWN", "ST ARC: confirmed bearish flip")
alertcondition(longTrig,  "LONG (conviction)", "ST ARC: LONG verdict")
alertcondition(shortTrig, "SHORT (conviction)","ST ARC: SHORT verdict")
alertcondition(flipUpRaw, "Raw flip UP",   "ST ARC: raw bullish flip")
alertcondition(flipDnRaw, "Raw flip DOWN", "ST ARC: raw bearish flip")
alertcondition(secFlipUp, "Secondary flip UP",   "ST ARC: secondary Supertrend bullish flip")
alertcondition(secFlipDn, "Secondary flip DOWN", "ST ARC: secondary Supertrend bearish flip")

// =============================================================================
// VIS — PRICE
// =============================================================================
upCol = color.new(#14b88a, 0)
dnCol = color.new(#ff5252, 0)
lineUp = plot(showLine and dir==1 ? stRaw : na, "Supertrend Up",   color=upCol, style=plot.style_linebr, linewidth=2)
lineDn = plot(showLine and dir==-1? stRaw : na, "Supertrend Down", color=dnCol, style=plot.style_linebr, linewidth=2)
pxHidden = plot(close, "px", display=display.none)
fill(lineUp, pxHidden, color=showFill and dir==1  ? color.new(#14b88a, 88) : na)
fill(lineDn, pxHidden, color=showFill and dir==-1 ? color.new(#ff5252, 88) : na)

mkUp = strengthNow>=70 ? upCol : strengthNow>=40 ? color.new(upCol,25) : color.new(upCol,55)
mkDn = strengthNow>=70 ? dnCol : strengthNow>=40 ? color.new(dnCol,25) : color.new(dnCol,55)
plotshape(showFlip and confUp ? stRaw : na, "Confirmed flip up",   shape.triangleup,   location.belowbar, mkUp, size=size.small)
plotshape(showFlip and confDn ? stRaw : na, "Confirmed flip down", shape.triangledown, location.abovebar, mkDn, size=size.small)
strG = strengthNow>=70 ? " S" : strengthNow>=40 ? " M" : " w"
if showStr and confUp
    label.new(bar_index, stRaw, str.tostring(strengthNow)+strG, yloc=yloc.belowbar, style=label.style_label_up, color=color.new(mkUp, 12), textcolor=color.white, size=size.small)
if showStr and confDn
    label.new(bar_index, stRaw, str.tostring(strengthNow)+strG, yloc=yloc.abovebar, style=label.style_label_down, color=color.new(mkDn, 12), textcolor=color.white, size=size.small)

// secondary (slower) Supertrend — thinner line, contrasting hue, diamond markers
secUpCol = color.new(#3aa0ff, 0)
secDnCol = color.new(#ffb43a, 0)
sLineUp = plot(usePair and sDir==1  ? sStRaw : na, "Secondary Up",   color=secUpCol, style=plot.style_linebr, linewidth=1)
sLineDn = plot(usePair and sDir==-1 ? sStRaw : na, "Secondary Down", color=secDnCol, style=plot.style_linebr, linewidth=1)
plotshape(usePair and secMarks and secFlipUp ? sStRaw : na, "Secondary flip up",   shape.diamond, location.belowbar, secUpCol, size=size.tiny)
plotshape(usePair and secMarks and secFlipDn ? sStRaw : na, "Secondary flip down", shape.diamond, location.abovebar, secDnCol, size=size.tiny)
plotshape(showRaw and flipUpRaw and not confUp ? stRaw : na, "Raw flip up",   shape.circle, location.belowbar, color.new(#14b88a, 35), size=size.tiny)
plotshape(showRaw and flipDnRaw and not confDn ? stRaw : na, "Raw flip down", shape.circle, location.abovebar, color.new(#ff5252, 35), size=size.tiny)

bgcolor(showReg and isTrend ? (bull?color.new(#14b88a,94):color.new(#ff5252,94)) : showReg and isVol ? color.new(color.orange,94) : na)

// =============================================================================
// VIS — DASHBOARD (adaptive light/dark)
// =============================================================================
var table dash = table.new(f_pos(tblPos), 2, 30, frame_width=1, border_width=1)
setrow(tbl, r, lbl, val, vc, lc, bg) =>
    table.cell(tbl, 0, r, lbl, text_color=lc, text_size=size.tiny,  text_halign=text.align_left,  bgcolor=bg)
    table.cell(tbl, 1, r, val, text_color=vc, text_size=size.small, text_halign=text.align_right, bgcolor=bg)

if showTbl and barstate.islast
    tLuma = 0.299*color.r(chart.bg_color) + 0.587*color.g(chart.bg_color) + 0.114*color.b(chart.bg_color)
    tIsDark = tblTheme=="Dark" ? true : tblTheme=="Light" ? false : tLuma < 140
    tBg   = tIsDark ? color.new(#0b0f17, 6) : color.new(#ffffff, 4)
    tBord = tIsDark ? color.new(#3a4250, 0) : color.new(#c2c8d0, 0)
    tLbl  = tIsDark ? #9aa3b2 : #515a67
    tVal  = tIsDark ? #f2f4f8 : #10151d
    cBull = tIsDark ? #2dd4bf : #0e9e76
    cBear = tIsDark ? #ff6b6b : #d32f2f
    cWarn = tIsDark ? #ffa94d : #b56a00
    cMute = tIsDark ? #6b7480 : #98a0ab
    table.set_frame_color(dash, tBord)
    table.set_border_color(dash, tBord)
    dirCol  = dir>0?cBull : dir<0?cBear : cMute
    verdCol = verdict=="LONG"?cBull : verdict=="SHORT"?cBear : verdict=="VETO"?cWarn : verdict=="WEAK"?cWarn : dir>0?cBull:dir<0?cBear:cMute
    regCol  = regime=="Trend Bull"?cBull : regime=="Trend Bear"?cBear : regime=="Volatile"?cWarn : cMute
    actCol  = longTrig?color.new(cBull,0) : shortTrig?color.new(cBear,0) : freshFlip and vetoes?color.new(cWarn,0) : color.new(#5b6472,0)
    actShort= longTrig?"BUY" : shortTrig?"SELL" : freshFlip and vetoes?"WAIT" : dir>0?"LONG":dir<0?"SHORT":"FLAT"
    actDet  = freshFlip ? ("flip · conv "+str.tostring(conv)+" "+tier) : ("hold · conv "+str.tostring(conv))
    multTxt = str.tostring(multUse,"0.00")+"x"+(useSelfTune?(" st"+str.tostring(selfMult,"0.0")+(usePlateau?"p":"")):"")+(pdvOn?" · pv"+str.tostring(pdvAdj,"0.00"):"")+"  (atr "+str.tostring(lenUse)+")"
    adaptTxt = (adaptMode ? (useSelfTune?"calib + self-tune":"self-calibrating") : (useSelfTune?"fixed + self-tune":"fixed")) + (useAutoStr ? (" · cut "+(na(autoCut)?"learning":(">="+str.tostring(int(autoCut))))) : "")
    strGrade = na(lastFlipStr) ? "" : (lastFlipStr>=70?"strong":lastFlipStr>=40?"med":"weak")
    strRate  = na(lastBkRate) ? "" : (" "+str.tostring(math.round(lastBkRate))+"%")
    strSuffix= na(lastFlipStr) ? "" : (" · str "+str.tostring(int(lastFlipStr))+" "+strGrade+strRate)
    flipBase = confUp?"UP confirmed" : confDn?"DN confirmed" : flipUpRaw?"UP raw" : flipDnRaw?"DN raw" : (dir>0?"up · "+str.tostring(barsSinceFlip)+"b":"dn · "+str.tostring(barsSinceFlip)+"b")
    flipTxt  = flipBase + strSuffix
    strColr  = na(lastFlipStr) ? tVal : (lastFlipStr>=70?cBull:lastFlipStr>=40?cWarn:cMute)
    mtfTxt  = useMtf?(str.tostring(mtfBull)+" up / "+str.tostring(mtfBear)+" dn of 3"):"off"
    relTxt  = na(holdRate)?"learning…":(str.tostring(flipsHeld)+"/"+str.tostring(flipsEval)+" won "+str.tostring(math.round(holdRate))+"% · "+str.tostring(avgFav,"0.0")+"R")
    wfTxt   = na(recentRate)?"learning…":("rec "+str.tostring(math.round(recentRate))+"% vs "+str.tostring(math.round(holdRate))+"%"+(na(wfDelta)?"":(" "+(wfDelta>=0?"+":"")+str.tostring(math.round(wfDelta)))))
    runsTxt = na(wwZ)?"":(" · runs z"+sgn(wwZ)+str.tostring(wwZ,"0.0")+" "+(math.abs(wwZ)<1.96?"indep":wwZ<0?"streaky":"alt"))
    calibTxt= wfTxt + runsTxt
    calibWarn= (not na(wfDelta) and wfDelta < -15) or (not na(wwZ) and wwZ <= -1.96)
    calibCol = na(recentRate)?cMute:(calibWarn?cWarn:cBull)
    cvdTxt  = (cvdSign>0?"up":cvdSign<0?"dn":"flat") + (useBVC?" ·bvc":"")
    dualTxt = usePair ? ((dir>0 and sDir>0)?"both up":(dir<0 and sDir<0)?"both down":"split") : "off"
    dualCol = usePair ? ((dir>0 and sDir>0)?cBull:(dir<0 and sDir<0)?cBear:cWarn) : cMute
    table.cell(dash, 0, 0, " > "+actShort+" ", text_color=color.white, text_size=size.small, text_halign=text.align_left,  bgcolor=actCol)
    table.cell(dash, 1, 0, actDet+" ",         text_color=color.white, text_size=size.small, text_halign=text.align_right, bgcolor=actCol)
    if compactTbl
        setrow(dash, 1,  "VERDICT",   verdict+" · "+str.tostring(conv)+" ("+tier+")", verdCol, tLbl, tBg)
        setrow(dash, 2,  "REGIME",    regime+" "+str.tostring(regimePct)+"%", regCol, tLbl, tBg)
        setrow(dash, 3,  "DIRECTION", dir>0?"up":dir<0?"down":"flat", dirCol, tLbl, tBg)
        setrow(dash, 4,  "MULTIPLIER",multTxt, tVal, tLbl, tBg)
        setrow(dash, 5,  "FLIP",      flipTxt, strColr, tLbl, tBg)
        setrow(dash, 6,  "MTF",       mtfTxt, ((dir>0 and mtfBull>=2) or (dir<0 and mtfBear>=2))?cBull:cMute, tLbl, tBg)
        setrow(dash, 7,  "RELIABILITY",relTxt, na(holdRate)?cMute:(holdRate>=55?cBull:cWarn), tLbl, tBg)
        setrow(dash, 8,  "CYCLE",     "cyc "+str.tostring(math.round(domCycle))+(cycRising?" ^":" v"), tVal, tLbl, tBg)
        setrow(dash, 9,  "SIZE",      str.tostring(qty)+" units ("+str.tostring(riskPct,"0.0")+"%)", tVal, tLbl, tBg)
        setrow(dash, 10, "VETO",      vetoTxt, vetoTxt=="none"?cMute:cWarn, tLbl, tBg)
        setrow(dash, 11, "ADAPT",     adaptTxt, adaptMode?cBull:cMute, tLbl, tBg)
        setrow(dash, 12, "DUAL",      dualTxt, dualCol, tLbl, tBg)
        setrow(dash, 13, "CALIB",     calibTxt, calibCol, tLbl, tBg)
        if showLegend
            setrow(dash, 14, "— LEGEND —","", cMute, cMute, tBg)
            setrow(dash, 15, "MULTIPLIER","ATR x, auto-scaled by volatility/chop", cMute, tLbl, tBg)
            setrow(dash, 16, "FLIP",      "confirmed = breach over adaptive ATR gate", cMute, tLbl, tBg)
            setrow(dash, 17, "MTF",       "higher-TF Supertrend agreement", cMute, tLbl, tBg)
            setrow(dash, 18, "RELIABILITY","flips that ran >= favourable target (R=ATR)", cMute, tLbl, tBg)
            setrow(dash, 19, "CALIB",     "recent vs all hold-rate + runs-test independence", cMute, tLbl, tBg)
            setrow(dash, 20, "ADAPT",     "thresholds calibrated to this symbol", cMute, tLbl, tBg)
            setrow(dash, 21, "DUAL",      "primary vs secondary Supertrend agreement", cMute, tLbl, tBg)
            setrow(dash, 22, "VETO",      "signal blocked + reason", cMute, tLbl, tBg)
    else
        setrow(dash, 1,  "VERDICT",   verdict+" · "+str.tostring(conv)+" ("+tier+")", verdCol, tLbl, tBg)
        setrow(dash, 2,  "REGIME",    regime+" "+str.tostring(regimePct)+"%", regCol, tLbl, tBg)
        setrow(dash, 3,  "DIRECTION", dir>0?"up":dir<0?"down":"flat", dirCol, tLbl, tBg)
        setrow(dash, 4,  "MULTIPLIER",multTxt, tVal, tLbl, tBg)
        setrow(dash, 5,  "VOL-RANK",  str.tostring(math.round(volRank*100))+"%", tVal, tLbl, tBg)
        setrow(dash, 6,  "TREND-Q",   str.tostring(trendiness,"0.00")+" · fdi "+str.tostring(fdi,"0.00"), trendiness>erTrdUse?cBull:cMute, tLbl, tBg)
        setrow(dash, 7,  "FLIP",      flipTxt, strColr, tLbl, tBg)
        setrow(dash, 8,  "CLEARANCE", str.tostring(clearance,"0.00")+" ATR", tVal, tLbl, tBg)
        setrow(dash, 9,  "MTF",       mtfTxt, ((dir>0 and mtfBull>=2) or (dir<0 and mtfBear>=2))?cBull:cMute, tLbl, tBg)
        setrow(dash, 10, "RELIABILITY",relTxt, na(holdRate)?cMute:(holdRate>=55?cBull:cWarn), tLbl, tBg)
        setrow(dash, 11, "CVD",       cvdTxt, cvdSign>0?cBull:cvdSign<0?cBear:cMute, tLbl, tBg)
        setrow(dash, 12, "VIX",       vixLive?("z"+sgn(vixZ)+str.tostring(vixZ,"0.0")+(vixSpike?" !":"")):"n/a", vixSpike?cWarn:vixLive?tVal:cMute, tLbl, tBg)
        setrow(dash, 13, "CROSS-AST", xaLive?(xaMom>0?"aligned":xaMom<0?"against":"flat"):"n/a", xaLive?(xaMom>0?cBull:xaMom<0?cBear:cMute):cMute, tLbl, tBg)
        setrow(dash, 14, "CYCLE",     "cyc "+str.tostring(math.round(domCycle))+(cycRising?" ^":" v"), tVal, tLbl, tBg)
        setrow(dash, 15, "SIZE",      str.tostring(qty)+" units ("+str.tostring(riskPct,"0.0")+"%)", tVal, tLbl, tBg)
        setrow(dash, 16, "VETO",      vetoTxt, vetoTxt=="none"?cMute:cWarn, tLbl, tBg)
        setrow(dash, 17, "ADAPT",     adaptTxt, adaptMode?cBull:cMute, tLbl, tBg)
        setrow(dash, 18, "DUAL",      dualTxt, dualCol, tLbl, tBg)
        setrow(dash, 19, "CALIB",     calibTxt, calibCol, tLbl, tBg)
        if showLegend
            setrow(dash, 20, "— LEGEND —","", cMute, cMute, tBg)
            setrow(dash, 21, "MULTIPLIER","ATR x, auto-scaled by volatility/chop", cMute, tLbl, tBg)
            setrow(dash, 22, "VOL-RANK",  "where ATR sits vs its own history", cMute, tLbl, tBg)
            setrow(dash, 23, "CLEARANCE", "close distance beyond the band", cMute, tLbl, tBg)
            setrow(dash, 24, "MTF",       "higher-TF Supertrend agreement", cMute, tLbl, tBg)
            setrow(dash, 25, "RELIABILITY","flips that ran >= favourable target (R=ATR)", cMute, tLbl, tBg)
            setrow(dash, 26, "CALIB",     "recent vs all hold-rate + runs-test independence", cMute, tLbl, tBg)
            setrow(dash, 27, "ADAPT",     "thresholds calibrated to this symbol", cMute, tLbl, tBg)
            setrow(dash, 28, "DUAL",      "primary vs secondary Supertrend agreement", cMute, tLbl, tBg)
            setrow(dash, 29, "VETO",      "signal blocked + reason", cMute, tLbl, tBg)

// =============================================================================
// IDENTITY
// =============================================================================
var table idTbl = table.new(position.bottom_center, 1, 1)
if showId and barstate.islast
    table.cell(idTbl, 0, 0, "ST ARC · Calibrated Supertrend   ·   " + syminfo.ticker + "  " + timeframe.period, text_color=color.new(#8a929e, 20), text_size=size.small, text_halign=text.align_center, bgcolor=color.new(color.gray, 100))
````
