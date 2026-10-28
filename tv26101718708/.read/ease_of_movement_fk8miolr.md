# Ease of Movement+

- url: https://www.tradingview.com/script/fk8mIolr/
- type: indicator
- pine_id: PUB;1d51362192594b56a9df2c944024318f
- version: 7.0

## Description

EOM+ is an efficiency-focused rebuild of Richard Arms' Ease of Movement. Standard EOM asks a useful question — how much did price move per unit of trading effort — but its raw output is hard to read, scale-dependent, and sensitive to gaps and outliers. EOM+ keeps that core idea, addresses those weaknesses, and plots the result as a directional, colour-graded histogram.

WHAT'S DIFFERENT FROM STANDARD EOM
[list]
[*]Effort = dollar volume (close × volume) instead of raw share volume. Following Amihud's (2002) illiquidity measure, dollar volume is a more meaningful, cross-comparable measure of trading effort / price impact — and it removes the arbitrary scaling divisor the classic formula needs.
[*]Range = True Range instead of high − low, so overnight gaps are included.
[*]Optional Kaufman adaptive smoothing (KAMA): faster in trends, slower in chop, to reduce EOM's well-known false signals in ranging conditions.
[*]Raw-value winsorizing + rolling z-score standardization: extreme box-ratio spikes are clipped, and the output is standardized so readings stay comparable across symbols and regimes. The ±2σ guide lines therefore keep a consistent meaning.
[/list]

HOW TO READ IT
[list]
[*]Columns above zero = price advancing with relative ease; below zero = declining with ease.
[*]Deeper colour = stronger ease relative to the recent lookback; touching ±2σ = unusually strong by recent standards.
[*]The plotted value is a z-score (roughly ±3.5 after clipping), not a raw EOM number.
[*]Best used for confirmation and divergence against price, not as a standalone signal. It pairs naturally with a cumulative volume line (e.g. OBV) and a money-flow tool — each answers a different question, so let them confirm one another rather than stacking redundant copies.
[/list]

INPUTS
[list]
[*]Effort source (dollar volume on/off), range source (True Range on/off)
[*]Smoothing type (EMA / SMA / KAMA) and length
[*]Winsorize on/off and band, z-score lookback, display clip
[/list]

HONEST NOTES & LIMITATIONS
Of the changes above, only the dollar-volume effort term has direct academic backing (Amihud 2002). True Range, adaptive smoothing and z-scoring are principled engineering choices without EOM-specific published evidence. Like all volume oscillators, EOM+ is a lagging confirmation tool, not a predictor. This is not financial advice.

CREDITS
Ease of Movement — Richard W. Arms Jr. Dollar-volume / price-impact concept — Yakov Amihud (2002). Adaptive smoothing (Efficiency Ratio / KAMA) — Perry Kaufman. Open-source so every line can be read and verified.

## Source Code

````pine
//@version=6
// ============================================================================
//  EOM+  -  Ease of Movement, efficiency-focused rebuild (Pine Script v6)
//
//  WHAT IT DRAWS (in this pane)
//    1. A directional histogram of price-move efficiency (sign-log compressed,
//       maxAbs-scaled ease of movement). Above zero = up-ease, below = down-ease.
//    2. An optional Amihud illiquidity line: log-compressed, smoothed ILLIQ
//       rescaled to 0..1 by a rolling min-max.
//    3. Optional divergence dots between cumulative PVT (net flow) and EOM+
//       (efficiency): a green dot below for bullish, a red dot above for bearish.
//       Cumulative PVT is used internally as the swing basis but is not plotted.
//
//  ZERO IS TRUE
//    The core histogram is the raw EOM (midpoint move * range / effort), sign-log
//    compressed, then divided by its own rolling maxAbs to scale it to about
//    -1..+1 for display. There is no moving-average smoothing: the line is left
//    responsive rather than lagged. Zero means "price midpoint did not move" - an
//    absolute neutral, not a rolling mean. The earlier rolling z-score was dropped
//    on purpose: it moved zero to the recent average. Every later step here only
//    compresses or divides (sign-log, maxAbs), never subtracts a baseline, so the
//    true zero is preserved throughout. Cross-symbol comparability (the z-score's
//    other job) is intentionally given up.
//
//  FAT TAILS
//    Raw EOM is fat-tailed: its denominator carries volume, so a low-volume, wide-
//    range bar makes the ratio blow up. This is tamed by SIGN-LOG compression
//    ( sign(x) * log(1 + |x|) ): it keeps the sign and the zero, leaves small
//    values almost unchanged, and compresses large outliers - no window, no state,
//    and it preserves the true zero. This replaces the previous winsorize step.
//
//  SCOPE (kept narrow on purpose, to avoid overlap with companion tools)
//    No close-location / money-flow read -> that is MFI / Money-Flow-Profile's job.
//    Core histogram stays pure efficiency. Cumulative PVT is computed only as the
//    swing basis for the divergence dots, which flag where net flow and efficiency
//    pull apart at a swing.
//
//  HONEST LIMITATIONS
//    - Only the dollar-volume effort term has direct academic backing (Amihud
//      2002); the rest are principled engineering choices.
//    - Like all volume oscillators this is lagging confirmation, not prediction.
//    - The Amihud line is symbol-dependent: nearly flat on thick large-caps; it
//      only comes alive on thinner / more volatile symbols. It is log-compressed,
//      smoothed ILLIQ rescaled to 0..1 by a rolling min-max, so it keeps moving
//      on a slowly drifting series (percentile rank would just pin near 0/1).
//    - The divergence dots compare net flow (PVT) against efficiency (EOM+); both
//      volume-derived, early warnings, noisy in trends. Confirm against price.
//    - Everything here is inferred from OHLCV, not real order flow. Not advice.
// ============================================================================
indicator("EOM+ (efficiency)", shorttitle = "EOM+", precision = 2)

// ------------------------------ Inputs --------------------------------------
string GROUP_CALC = "Calculation"
bool   useDollarVolume = input.bool(true,  "Effort = dollar volume (Amihud)", group = GROUP_CALC)
bool   useTrueRange    = input.bool(true,  "Range = True Range (gap-aware)",  group = GROUP_CALC)
int    eomNormLook     = input.int(100, "Display scale lookback (maxAbs)", minval = 10, group = GROUP_CALC, tooltip = "The sign-log EOM is divided by its largest absolute value over this many bars to bring it into about -1..+1 for display. Divides only, so zero stays zero.")

string GROUP_AMIHUD = "Amihud line"
bool showAmihud   = input.bool(true, "Show Amihud illiquidity line (thin / volatile symbols)", group = GROUP_AMIHUD)
int  amihudLength = input.int(14, "Amihud smoothing length", minval = 1, group = GROUP_AMIHUD)
int  amihudStatLen  = input.int(50, "Amihud min-max lookback", minval = 10, group = GROUP_AMIHUD)

string GROUP_DIV = "Divergence (PVT vs EOM+)"
bool showDivergence = input.bool(true, "Mark PVT vs EOM+ divergence (dots)",  group = GROUP_DIV)
int  pivotLeft      = input.int(5,  "Pivot left bars",                     minval = 1, group = GROUP_DIV)
int  pivotRight     = input.int(5,  "Pivot right bars (confirmation lag)", minval = 1, group = GROUP_DIV)
int  maxPivotGap    = input.int(60, "Max bars between the two swings",     minval = 5, group = GROUP_DIV)

// ----------------------- Single-period raw EOM ------------------------------
// Result = midpoint move (no close-location term, to stay out of MFI's lane).
float midpointMove = ta.change(hl2)
// Range term: True Range folds in gaps; high-low does not.
float rangeTerm = useTrueRange ? ta.tr : (high - low)
// Effort term: dollar volume (Amihud) or raw share volume.
float effortTerm = useDollarVolume ? close * volume : volume
// EOM = result * range / effort, guarded against a zero effort or range.
float rawEom = (effortTerm == 0 or rangeTerm == 0) ? 0.0 : midpointMove * rangeTerm / effortTerm

// ----------------------- Sign-log compression -------------------------------
// Tame the fat-tailed box ratio: sign(x) * log(1 + |x|). Keeps the sign, leaves
// zero at zero, barely touches small values, compresses large outliers. No
// window, no state - and the true zero is preserved. Replaces winsorize.
float compressedEom = math.sign(rawEom) * math.log(1.0 + math.abs(rawEom))

// ----------------------- maxAbs normalization (display) ---------------------
// The sign-log EOM runs very small (dollar-volume effort makes raw EOM tiny),
// so it would be invisible next to the 0..1 Amihud line. Divide by the largest
// absolute value over the lookback to bring it into about -1..+1. This only
// divides (never subtracts), so the true zero is preserved (0 / anything = 0),
// and dividing by the max keeps values strictly within -1..+1. The histogram
// plots this normalized value; divergence below uses the pre-normalization
// compressedEom so its swing comparisons stay on one fixed scale.
float eomMaxAbs = ta.highest(math.abs(compressedEom), eomNormLook)
float eomValue  = eomMaxAbs != 0 ? compressedEom / eomMaxAbs : 0.0

// ------------------ Amihud illiquidity line (optional) -----------------
// Amihud (2002) ILLIQ = |return| / dollar volume = price impact per dollar
// traded = the absolute, non-directional liquidity level. A higher value = less
// liquid. Pipeline: log (compress the fat tail so one spike cannot dominate the
// range) -> SMA smooth -> min-max rescale to 0..1 over the lookback. Min-max is
// used (not percentile rank): it shows the value's absolute position between the
// recent low and high, so a slowly drifting series still shows continuous
// movement, whereas percentile rank just pins near 0/1 on a near-monotonic line.
float amihudDollarVol = close * volume
float illiqRaw    = amihudDollarVol > 0 ? math.abs(close / close[1] - 1.0) / amihudDollarVol : na
float illiqLog    = math.log(math.max(illiqRaw, 1e-12))
float illiqSmooth = ta.sma(illiqLog, amihudLength)
float illiqLo     = ta.lowest(illiqSmooth, amihudStatLen)
float illiqHi     = ta.highest(illiqSmooth, amihudStatLen)
float amihudLine = illiqHi > illiqLo ? (illiqSmooth - illiqLo) / (illiqHi - illiqLo) : 0.5

// ------------------ Cumulative PVT (for divergence only) --------------------
// True Price Volume Trend: the running total of volume signed by each bar's
// percent change. NOT plotted - used only as the swing basis for the divergence
// below, which is PVT's standard divergence series. The earlier "short minus
// long" oscillator was removed: that was a MACD-style oscillator built on PVT,
// not PVT itself, so plotting it as "PVT" would have been misleading.
float pvtChange = na(close[1]) ? 0.0 : ta.change(close) / close[1] * volume
float pvtCum    = ta.cum(pvtChange)

// --------------- Divergence: PVT (net flow) vs EOM+ (efficiency) -------------
// Anchor swings on cumulative PVT (the trending, price-like series - PVT's
// standard divergence basis), then check the new sign-log EOM at those swings.
//   Bullish: PVT makes a lower low while EOM+ makes a higher low.
//   Bearish: PVT makes a higher high while EOM+ makes a lower high.
// A swing needs pivotRight confirming bars, so a dot prints that many bars after
// the swing and then stays put (no repaint once printed).
float pivotLowPvt  = ta.pivotlow(pvtCum, pivotLeft, pivotRight)
float pivotHighPvt = ta.pivothigh(pvtCum, pivotLeft, pivotRight)

var float prevLowPvt = na
var float prevLowEom = na
var int   prevLowBar = na
bool bullishDivergence = false
if not na(pivotLowPvt)
    float thisLowEom = compressedEom[pivotRight]
    int   thisLowBar = bar_index - pivotRight
    if not na(prevLowPvt) and not na(prevLowEom) and not na(thisLowEom) and (thisLowBar - prevLowBar) <= maxPivotGap
        bullishDivergence := pivotLowPvt < prevLowPvt and thisLowEom > prevLowEom
    prevLowPvt := pivotLowPvt
    prevLowEom := thisLowEom
    prevLowBar := thisLowBar

var float prevHighPvt = na
var float prevHighEom = na
var int   prevHighBar = na
bool bearishDivergence = false
if not na(pivotHighPvt)
    float thisHighEom = compressedEom[pivotRight]
    int   thisHighBar = bar_index - pivotRight
    if not na(prevHighPvt) and not na(prevHighEom) and not na(thisHighEom) and (thisHighBar - prevHighBar) <= maxPivotGap
        bearishDivergence := pivotHighPvt > prevHighPvt and thisHighEom < prevHighEom
    prevHighPvt := pivotHighPvt
    prevHighEom := thisHighEom
    prevHighBar := thisHighBar

// -------------------------------- Plotting ----------------------------------
// Histogram colour: sign of the EOM value = direction only; fixed transparency.
color eomBarColor = eomValue >= 0 ? color.green : color.red

plot(eomValue, title = "EOM+ (sign-log)", style = plot.style_columns, color = eomBarColor)
hline(0.0, "Zero", color = color.gray, linestyle = hline.style_dashed)

// Amihud line (orange line). Drawn after the EOM columns so it sits on top of
// them: Pine draws later plots above earlier ones.
plot(showAmihud ? amihudLine : na, title = "Amihud illiquidity (line)", color = color.new(color.orange, 0), linewidth = 1)

// SAR-style divergence dots: bullish -> a green dot pinned to the bottom edge,
// bearish -> a red dot pinned to the top edge. Offset back onto the swing bar so
// each dot sits where the divergence actually formed.
plotshape(showDivergence and bullishDivergence, title = "Bullish divergence (PVT vs EOM+)", style = shape.circle, location = location.bottom, color = color.new(color.green, 0), size = size.tiny, offset = -pivotRight)
plotshape(showDivergence and bearishDivergence, title = "Bearish divergence (PVT vs EOM+)", style = shape.circle, location = location.top,    color = color.new(color.red, 0),   size = size.tiny, offset = -pivotRight)
````
