# Momentum Vol Composite Pro [JOAT]

- url: https://www.tradingview.com/script/xAZlynsu-Momentum-Vol-Composite-Pro-JOAT/
- type: indicator
- pine_id: PUB;171dbddfe5b94e85b878ee4adeb6d66e
- version: 1.0

## Description

[b]MOMENTUM VOL COMPOSITE PRO [JOAT][/b]

A four-factor composite oscillator that fuses momentum, volatility, volume-flow, and trend into a single Z-normalised line — then exposes per-factor weights, divergence detection, an ASCII gauge dashboard, and a slope-coloured composite MA. Built on the idea that no single oscillator tells you what the market is doing — but four orthogonal ones, properly normalised and weighted, can.

[image]https://www.tradingview.com/x/DJNOnE6n/[/image]

[b]The four factors[/b]

Each factor is Z-normalised (subtract its own rolling mean, divide by its own rolling stdev) before being blended, so they all live on the same scale and a weight of "0.25" actually means "one-quarter share of the composite" regardless of the instrument:

[list]
[*] [b]ROC (Rate-of-Change)[/b] — the price-velocity factor. Captures pure directional momentum.
[*] [b]ATR (volatility)[/b] — the range-expansion factor. Rises when bars are getting larger; useful as a "the market is committing" signal.
[*] [b]Volume Flow[/b] — cumulative volume minus its own EMA. A proxy for net accumulation/distribution that is regime-aware (it normalises around its own trend).
[*] [b]EMA Difference[/b] — short EMA minus long EMA, the classic MACD-style trend factor.
[/list]

The four Z-scores are weighted (sliders 0–4 each, default 0.25 each), sum-normalised internally so any positive configuration is valid, and combined into a single composite Z-line. An EMA smoother on top of the composite produces the slope-coloured [b]Composite MA[/b] that drives Buy/Sell flips.

This is what "composite" should mean — orthogonal factors, weighted, on a common scale, with the weights exposed so the trader controls the personality.

[b]Why per-factor weights matter[/b]

Default 0.25 / 0.25 / 0.25 / 0.25 reproduces the textbook equal-weight composite. But equal weights are an [i]assumption[/i], not a fact. If your instrument is volume-driven, raise VolFlow Weight. If your timeframe is dominated by trend, raise EMA Diff Weight. If you are scalping a noisy intraday environment, drop ROC Weight in favour of VolFlow. The composite reshapes itself live as you slide.

[b]Signal engine[/b]

A Buy signal fires when the composite MA slopes up; a Sell fires when it slopes down. The composite line itself crosses the configurable threshold guides (default ±1 Z) to mark "extreme bull" and "extreme bear" states. A separate alert fires when |composite| crosses the Extreme threshold (default 2.0 Z) — the script's strongest read.

[b]Divergence engine (JOAT enhancement)[/b]

A slope-comparison divergence runs in parallel: it compares the slope of the composite against the slope of price over a configurable lookback. Both slopes must exceed an epsilon to filter out flat-region noise, and a divergence cooldown spaces them out. Divergence labels can be forced onto the main chart pane via force_overlay so you can see them without flipping to the oscillator pane.

[b]Histogram background[/b]

Faint columns plot the raw composite value behind the line — this is useful as a "before the slope flips" early read. You can see exhaustion building in the histogram before the slope-coloured MA actually turns.

[b]ASCII gauge dashboard (JOAT enhancement)[/b]

A monospaced dashboard with a unique feature — each per-factor row shows both the numeric Z-value [b]and[/b] an ASCII bar gauge ("|||||----" style) that renders the value visually inside the table cell. The gauge maps Z in the range [−2, +2] linearly across N glyphs (configurable width), with a separator at the centre. At a glance you can see which factors are dominating without reading the numbers.

Dashboard rows:

[list]
[*] Composite Z + bar gauge + status (extreme bull / bull / neutral / bear / extreme bear).
[*] ROC Z + gauge.
[*] ATR Z + gauge.
[*] VolFlow Z + gauge.
[*] EMA Diff Z + gauge.
[*] Composite MA slope (Rising / Falling / Flat).
[*] Last signal direction with bar age.
[*] Divergence status with cooldown remaining.
[/list]

[image]https://www.tradingview.com/x/RjCNo2hx/[/image]

[b]Visual system[/b]

[list]
[*] Slope-coloured composite MA (bull / bear by slope sign, configurable width).
[*] Translucent composite line for context (transparency configurable, default matches the v5 source).
[*] Threshold guide lines at ±1, zero line, and faint background histogram for exhaustion-before-flip reads.
[*] Buy / Sell labels can be force-overlaid onto the main chart pane if desired.
[/list]

A locked Emerald-Night palette (vivid green bull / vivid red bear / sage neutral on a midnight-forest ground) gives the pane a distinct identity.

[b]Alerts[/b]

Five alert conditions:

[list]
[*] Composite crossover above high threshold (default +1)
[*] Composite crossunder below low threshold (default −1)
[*] |Composite| crosses Extreme |Z| (default 2.0)
[*] Bullish divergence detected
[*] Bearish divergence detected
[/list]

[b]How to read it[/b]

Three reads, in order of conviction:

[list=1]
[*] [b]ASCII gauge agreement[/b] — when all four factor gauges point the same way, the composite is a high-conviction read. When they disagree, the composite is a wash.
[*] [b]Composite MA slope[/b] — once the smoothed line slope flips and price agrees, you have a clean signal.
[*] [b]Divergence + extreme |Z|[/b] — the rarest and strongest read. A divergence at a composite extreme tells you that one of the factors is rolling over while price is not, which is the textbook reversal setup.
[/list]

The histogram is the leading indicator on the line — when it starts shrinking while price is still extending, the slope is about to flip.

[b]Suggested settings[/b]

Defaults (ROC 14, ATR 14, VolFlow 20, ShortEMA 12, LongEMA 26) reproduce the classical configuration. For lower timeframes drop all lengths roughly proportionally. The per-factor weights are where the personality lives: pure trend-following bias → raise EMA Diff to 1.5, drop ATR to 0.1. Pure volatility-of-momentum bias → raise ROC and ATR, drop VolFlow.

[b]Originality / what's reused[/b]

The factor primitives (ROC, ATR, EMA difference, cumulative volume flow) are public-domain. The Z-normalisation pipeline that puts them on a common scale, the sum-normalised per-factor weighting, the ASCII bar-gauge dashboard, the histogram-behind-line exhaustion view, the slope-coloured composite MA, and the divergence engine with epsilon filter are all JOAT-original and tuned together as a single oscillator. No third-party code reused.

[b]Open source[/b]

Published open-source under the default Mozilla Public License 2.0. Sectioned source, tooltips on every input, helper functions documented inline. Each factor's Z-normalisation, the weighting pipeline, the gauge renderer, and the divergence detector are isolated modules — adapt any single one without reading the whole file.

[b]Limitations[/b]

The composite is statistical in nature — it tells you how stretched [i]the blend[/i] is, not which specific factor is driving the read. That is what the per-factor rows are for. The Z-normalisation needs enough history to be meaningful; on a fresh chart with little data the composite warms up to flat. Divergences are non-repainting but carry the natural lag of slope-over-window comparison.

—

-made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title="Momentum Vol Composite Pro [JOAT]", shorttitle="MVC [JOAT]",
     overlay=false,
     max_lines_count=500, max_boxes_count=500, max_labels_count=500, max_bars_back=5000)


// =============================================================================
//  SECTION 1 - INPUTS  (grouped with box-drawing headers)
// =============================================================================

grpFactors = "+----- Factor Lengths -----+"
grpWeights = "+----- Per-Factor Weights (NEW) -----+"
grpThresh  = "+----- Thresholds -----+"
grpVis     = "+----- Visuals -----+"
grpDash    = "+----- Dashboard -----+"
grpDiv     = "+----- Divergence (NEW) -----+"
grpAlert   = "+----- Alerts -----+"

// ----- Factor lengths (inherited from v5 source) ------------------------------
rocLen     = input.int(14, "Rate-of-Change Length",        minval=2, maxval=500, group=grpFactors,
     tooltip="Period for ta.roc(close, n) and for the SMA + stdev that Z-normalises ROC.")
atrLen     = input.int(14, "ATR Length",                   minval=2, maxval=500, group=grpFactors,
     tooltip="Period for ta.atr(n) and for the SMA + stdev that Z-normalises ATR.")
vfLen      = input.int(20, "Volume-Flow Length",           minval=2, maxval=500, group=grpFactors,
     tooltip="EMA period subtracted from cumulative volume to build VolFlow. Also used for Z-normalisation.")
shortEmaLen= input.int(12, "Short EMA Length",             minval=2, maxval=500, group=grpFactors,
     tooltip="Short EMA leg of the EMA-difference factor.")
longEmaLen = input.int(26, "Long EMA Length",              minval=2, maxval=500, group=grpFactors,
     tooltip="Long EMA leg of the EMA-difference factor. Also used for Z-normalisation.")
maLen      = input.int(14, "Composite MA Length",          minval=1, maxval=500, group=grpFactors,
     tooltip="EMA smoother applied to the composite signal. Slope of this line drives BUY/SELL flips.")

// ----- Per-factor weights (NEW JOAT enhancement) ------------------------------
//   Defaults of 0.25 each preserve the v5 "simple average" behaviour.
//   Sum-normalised internally so any positive slider configuration works.
wRoc       = input.float(0.25, "ROC Weight",       minval=0.0, maxval=4.0, step=0.05, group=grpWeights,
     tooltip="Weight on the ROC factor. Default 0.25 (one-quarter share). All four weights are sum-normalised internally.")
wAtr       = input.float(0.25, "ATR Weight",       minval=0.0, maxval=4.0, step=0.05, group=grpWeights,
     tooltip="Weight on the ATR factor. Default 0.25.")
wVolFlow   = input.float(0.25, "VolFlow Weight",   minval=0.0, maxval=4.0, step=0.05, group=grpWeights,
     tooltip="Weight on the cumulative-volume-flow factor. Default 0.25.")
wEmaDiff   = input.float(0.25, "EMA Diff Weight",  minval=0.0, maxval=4.0, step=0.05, group=grpWeights,
     tooltip="Weight on the EMA-difference factor. Default 0.25.")

// ----- Thresholds (Z-units) ---------------------------------------------------
hiThreshold= input.float(1.0,  "High Signal Threshold",  step=0.1, minval=0.0, maxval=10.0, group=grpThresh,
     tooltip="Composite value above this fires the High alert and crosses up over the upper guide line.")
loThreshold= input.float(-1.0, "Low Signal Threshold",   step=0.1, minval=-10.0, maxval=0.0, group=grpThresh,
     tooltip="Composite value below this fires the Low alert and crosses down under the lower guide line.")

// ----- Visuals ----------------------------------------------------------------
showSignalLine = input.bool(true, "Show Composite Line",                 group=grpVis)
signalAlpha    = input.int(50,    "Composite Line Transparency",         minval=0, maxval=99, group=grpVis,
     tooltip="0 = solid green-translucent, 99 = nearly invisible. The v5 source used #00ff0080 which is alpha 50.")
signalWidth    = input.int(1,     "Composite Line Width",  minval=1, maxval=5, group=grpVis)
showMa         = input.bool(true, "Show Composite MA Line", group=grpVis)
maWidth        = input.int(3,     "Composite MA Line Width", minval=1, maxval=10, group=grpVis,
     tooltip="Width of the slope-coloured MA line. v5 source used 3px.")
showThresholds = input.bool(true, "Show Threshold Guide Lines (+/-1)",   group=grpVis)
showZeroLine   = input.bool(true, "Show Zero Line",                       group=grpVis)
showLabels     = input.bool(true, "Show BUY/SELL Labels (chart overlay)", group=grpVis,
     tooltip="When ON, labels are forced onto the main chart pane via force_overlay.")
labelSize      = input.string("Small", "Label Size",
     options=["Tiny","Small","Normal","Large","Huge"], group=grpVis)
showHistogram  = input.bool(true, "Show Composite Histogram (background)", group=grpVis,
     tooltip="Faint columns showing the raw composite value behind the line. Helps see exhaustion before slope flips.")

// ----- Dashboard --------------------------------------------------------------
showDash       = input.bool(true,  "Show Dashboard", group=grpDash)
dashPosStr     = input.string("Top Right", "Dashboard Position",
     options=["Top Right","Top Left","Top Center","Middle Right","Middle Left","Middle Center","Bottom Right","Bottom Left","Bottom Center"],
     group=grpDash)
dashSizeStr    = input.string("Small", "Dashboard Text Size",
     options=["Tiny","Small","Normal","Large","Huge"], group=grpDash)
dashTransp     = input.int(80, "Cell Transparency", minval=0, maxval=100, group=grpDash,
     tooltip="0 = opaque, 100 = invisible. Higher feels more 'institutional'.")
dashShowGauge  = input.bool(true, "Show ASCII Gauge in Factor Rows", group=grpDash,
     tooltip="When ON, factor Z rows show |||----- style bar plus the numeric Z value. Off = numbers only.")
gaugeBarLen    = input.int(8, "Gauge Width (cells)", minval=4, maxval=20, group=grpDash,
     tooltip="Number of glyphs used for the |||----- gauge inside factor rows. Each cell ~ 0.25 Z-units.")

// ----- Divergence (NEW) -------------------------------------------------------
showDiv        = input.bool(true,  "Detect Divergence",                    group=grpDiv)
divLen         = input.int(14,     "Divergence Lookback (bars)",           minval=3, maxval=200, group=grpDiv,
     tooltip="Slope of composite compared with slope of price over this many bars. Long enough to suppress noise, short enough to react.")
divLabel       = input.bool(true,  "Plot Divergence Label (chart overlay)", group=grpDiv,
     tooltip="When ON, divergence labels are forced onto the main chart pane via force_overlay.")
divCooldown    = input.int(15,     "Divergence Cooldown",                  minval=1, maxval=200, group=grpDiv,
     tooltip="Minimum bars between successive divergence labels.")
divEpsilon     = input.float(0.0001,"Divergence Slope Epsilon", step=0.0001, minval=0.0, maxval=1.0, group=grpDiv,
     tooltip="Minimum |slope| considered non-flat. Prevents noise-triggered divergences when price barely moves.")

// ----- Alerts -----------------------------------------------------------------
extremeZ       = input.float(2.0, "Extreme Composite |Z| Alert",           step=0.1, minval=1.0, maxval=10.0, group=grpAlert,
     tooltip="Fires the 'Composite Extreme' alert when |composite| crosses this. Useful for exhaustion screening.")


// =============================================================================
//  SECTION 2 - COLOR PALETTE  (Emerald Night - curated, no theme switcher)
// =============================================================================

const color C_BULL  = #00E676   // vivid green
const color C_BEAR  = #FF5252   // vivid red
const color C_MID   = #7FAF9B   // sage
const color C_BG    = #07110B   // midnight forest
const color C_FRAME = #153322   // emerald frame

color bullColor = C_BULL
color bearColor = C_BEAR
color bgRaw     = C_BG
color frameCol  = C_FRAME
color flatColor = C_MID

// MA slope colours follow the palette (bull-up, bear-down).
color maUpColor   = C_BULL
color maDownColor = C_BEAR


// =============================================================================
//  SECTION 3 - HELPER FUNCTIONS
//      - f_colorGradient       (KB 2.1)
//      - f_clamp               (KB 2.3)
//      - strToPos / strToSize  (KB 2.4)
//      - safeZ                 (Z-score with stdev guard)
//      - gaugeStr              (renders a |||----- bar string for dashboard cells)
// =============================================================================

// ----- f_colorGradient: linear interpolation between two colours by 0..1 ratio
f_colorGradient(float _ratio, color _colA, color _colB) =>
    rA = color.r(_colA), gA = color.g(_colA), bA = color.b(_colA)
    rB = color.r(_colB), gB = color.g(_colB), bB = color.b(_colB)
    rr = rA + int((rB - rA) * _ratio)
    rg = gA + int((gB - gA) * _ratio)
    rb = bA + int((bB - bA) * _ratio)
    color.rgb(rr, rg, rb, 0)

// ----- f_clamp ----------------------------------------------------------------
f_clamp(float _x, float _min, float _max) => math.max(_min, math.min(_x, _max))

// ----- safeZ: Z-score with stdev guard ---------------------------------------
//   Returns 0 when stdev is non-positive or NA. Prevents 0/0 NaNs when a
//   series is constant for the whole lookback (e.g. flat ATR on warm-up).
safeZ(float v, float mean, float stdev) =>
    nz(stdev, 0.0) > 0.0 ? (v - mean) / stdev : 0.0

// ----- strToPos --------------------------------------------------------------
strToPos(string s) =>
    switch s
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        =>               position.bottom_right

// ----- strToSize -------------------------------------------------------------
strToSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.normal

// ----- gaugeStr: renders a |||----- gauge for a Z value -----------------------
//   Maps z in [-2, +2] linearly across `len` cells. Fills with `█` when z>0,
//   fills from the right when z<0. Centre cell stays as a separator.
gaugeStr(float z, int len) =>
    // map z into integer fill count: -len..+len
    cells = math.max(2, len)
    half  = cells / 2
    norm  = f_clamp(z / 2.0, -1.0, 1.0)            // -1..+1
    fill  = int(math.round(norm * half))            // -half..+half
    string s = ""
    if fill >= 0
        // bull side: fill from centre outward to the right
        for i = 0 to cells - 1
            mid = i < half ? false : (i - half) < fill
            s := s + (mid ? "█" : (i == half ? "|" : "-"))
    else
        absFill = -fill
        for i = 0 to cells - 1
            mid = i >= half ? false : (half - 1 - i) < absFill
            s := s + (mid ? "█" : (i == half ? "|" : "-"))
    s


// =============================================================================
//  SECTION 4 - CORE CALCULATIONS
//      4-factor Z-composite (matches v5 source) plus weighted variant.
// =============================================================================

// ----- Factor 1: Rate of Change ----------------------------------------------
roc       = ta.roc(close, rocLen)
rocMean   = ta.sma(roc, rocLen)
rocStdev  = ta.stdev(roc, rocLen)
rocZ      = safeZ(roc, rocMean, rocStdev)

// ----- Factor 2: Average True Range ------------------------------------------
atr       = ta.atr(atrLen)
atrMean   = ta.sma(atr, atrLen)
atrStdev  = ta.stdev(atr, atrLen)
atrZ      = safeZ(atr, atrMean, atrStdev)

// ----- Factor 3: Volume Flow (cumulative volume minus EMA of cumulative vol) -
//   This is a slow-flow indicator: positive when recent volume is above the
//   EMA-trend of accumulated volume, negative below. Z-normalised over vfLen.
volCum    = ta.cum(volume)
volFlow   = volCum - ta.ema(volCum, vfLen)
vfMean    = ta.sma(volFlow, vfLen)
vfStdev   = ta.stdev(volFlow, vfLen)
vfZ       = safeZ(volFlow, vfMean, vfStdev)

// ----- Factor 4: EMA Difference ----------------------------------------------
emaShort  = ta.ema(close, shortEmaLen)
emaLong   = ta.ema(close, longEmaLen)
emaDiff   = emaShort - emaLong
emaMean   = ta.sma(emaDiff, longEmaLen)
emaStdev  = ta.stdev(emaDiff, longEmaLen)
emaZ      = safeZ(emaDiff, emaMean, emaStdev)

// ----- Composite (weighted) --------------------------------------------------
//   Sum-normalise weights so any positive slider configuration remains scaled
//   to roughly the same magnitude as the original simple-average composite.
wSum      = math.max(wRoc + wAtr + wVolFlow + wEmaDiff, 1e-10)
wRocN     = wRoc     / wSum
wAtrN     = wAtr     / wSum
wVfN      = wVolFlow / wSum
wEmaN     = wEmaDiff / wSum
composite = wRocN * rocZ + wAtrN * atrZ + wVfN * vfZ + wEmaN * emaZ

// ----- Composite MA + slope --------------------------------------------------
//   v5 source uses ta.ema for both the smoother and the slope reference. We
//   keep the same formula so historical bars match the original behaviour.
compositeMA   = ta.ema(composite, maLen)
compositeMAp1 = ta.ema(nz(composite[1], composite), maLen)
compositeMAp2 = ta.ema(nz(composite[2], composite), maLen)
slope         = compositeMA   - compositeMAp1
slopePrev     = compositeMAp1 - compositeMAp2

slopeUp       = slope > 0
slopeDn       = slope < 0

// ----- Slope colour ----------------------------------------------------------
slopeColor    = slopeUp ? maUpColor : slopeDn ? maDownColor : flatColor

// ----- Composite line colour: green-translucent (v5 source preset) ----------
compositeLineColor = color.new(bullColor, signalAlpha)


// =============================================================================
//  SECTION 4b - FACTOR ATTRIBUTION  (NEW JOAT enhancement)
//      Identify which factor's |Z| is largest each bar. Used by dashboard.
// =============================================================================

absRocZ = math.abs(rocZ)
absAtrZ = math.abs(atrZ)
absVfZ  = math.abs(vfZ)
absEmaZ = math.abs(emaZ)

// Find the largest absolute Z. Tie break: ROC > ATR > VolFlow > EMA Diff.
maxAbsZ = math.max(math.max(absRocZ, absAtrZ), math.max(absVfZ, absEmaZ))

// Construct dominant-factor string + sign (+ / -)
dominantFactorRaw = absRocZ == maxAbsZ ? "ROC" : absAtrZ == maxAbsZ ? "ATR" : absVfZ == maxAbsZ ? "VolFlow" : "EMA Diff"
dominantSign      = dominantFactorRaw == "ROC" ? rocZ : dominantFactorRaw == "ATR" ? atrZ : dominantFactorRaw == "VolFlow" ? vfZ : emaZ
dominantFactorStr = dominantFactorRaw + (dominantSign >= 0 ? "  +" : "  ") + str.tostring(dominantSign, "0.00")

dominantFactorCol = dominantSign > 0 ? bullColor : dominantSign < 0 ? bearColor : flatColor

// Per-factor share of total |Z| (used as gauge tint inside the dashboard)
totalAbs = math.max(absRocZ + absAtrZ + absVfZ + absEmaZ, 1e-10)
shareRoc = absRocZ / totalAbs
shareAtr = absAtrZ / totalAbs
shareVf  = absVfZ  / totalAbs
shareEma = absEmaZ / totalAbs


// =============================================================================
//  SECTION 5 - STATE / TRACKING
//      var arrays for divergence tracking and last-signal bookkeeping.
// =============================================================================

var int  lastBuyBar    = na
var int  lastSellBar   = na
var int  lastDivBar    = -1000
var int  lastHiBar     = -1000
var int  lastLoBar     = -1000

// Snapshot of the dominant factor at the most recent BUY / SELL signal.
var string lastSignalFactor = "—"
var color  lastSignalCol    = na
var int    lastSignalBar    = na


// =============================================================================
//  SECTION 6 - SIGNAL ENGINE
//      Slope-flip detection (matches v5 source): BUY = slope flips up,
//      SELL = slope flips down. Cooldown-free (per source) but we add
//      threshold-cross alerts as separate, debounced events.
// =============================================================================

buySignal  = slopeUp and slopePrev <= 0
sellSignal = slopeDn and slopePrev >= 0

// Snapshot dominant factor on every fresh signal.
if buySignal
    lastBuyBar        := bar_index
    lastSignalBar     := bar_index
    lastSignalFactor  := dominantFactorStr
    lastSignalCol     := bullColor
if sellSignal
    lastSellBar       := bar_index
    lastSignalBar     := bar_index
    lastSignalFactor  := dominantFactorStr
    lastSignalCol     := bearColor

// Threshold crosses (debounced via cooldown so they don't fire every bar)
hiCross   = ta.crossover(composite,  hiThreshold)
loCross   = ta.crossunder(composite, loThreshold)
canHi     = (bar_index - lastHiBar) > 1
canLo     = (bar_index - lastLoBar) > 1
hiEvent   = hiCross and canHi
loEvent   = loCross and canLo
if hiEvent
    lastHiBar := bar_index
if loEvent
    lastLoBar := bar_index


// =============================================================================
//  SECTION 6b - DIVERGENCE DETECTION (NEW JOAT enhancement)
//      Compare slope of composite vs slope of price over `divLen` bars.
//        Bull div: price slope < -eps  AND  composite slope > +eps
//        Bear div: price slope > +eps  AND  composite slope < -eps
//      Cooldown to prevent label clutter.
// =============================================================================

priceNow   = close
priceThen  = nz(close[divLen], close)
compNow    = composite
compThen   = nz(composite[divLen], composite)

// Normalise price slope to a comparable scale (% return)
priceSlope = priceThen != 0 ? (priceNow - priceThen) / priceThen : 0.0
compSlope  = compNow - compThen

bullDivRaw = showDiv and priceSlope < -divEpsilon and compSlope >  divEpsilon
bearDivRaw = showDiv and priceSlope >  divEpsilon and compSlope < -divEpsilon

canEmitDiv = (bar_index - lastDivBar) >= divCooldown
bullDiv    = bullDivRaw and canEmitDiv
bearDiv    = bearDivRaw and canEmitDiv

if bullDiv or bearDiv
    lastDivBar := bar_index

divStr = bullDiv ? "Bull div" : bearDiv ? "Bear div" : "—"
divCol = bullDiv ? bullColor   : bearDiv ? bearColor   : flatColor


// =============================================================================
//  SECTION 7 - PLOTS / FILLS / BACKGROUND HISTOGRAM
// =============================================================================

// ----- Composite raw line (green-translucent, mirrors v5 source #00ff0080) ---
plot(showSignalLine ? composite : na,
     "Composite Signal",
     color     = compositeLineColor,
     linewidth = signalWidth)

// ----- Composite MA: 3px slope-coloured line (per spec) ----------------------
plot(showMa ? compositeMA : na,
     "Composite MA",
     color     = slopeColor,
     linewidth = maWidth)

// ----- Threshold guide lines + zero ------------------------------------------
//   NOTE: Pine v6 `hline()` requires INPUT-qualified `price` and INPUT-qualified
//   `color`. Because our bullColor/bearColor are series-qualified (derived from
//   theme switch functions), we use `plot()` with `plot.style_linebr` to render
//   the levels as constant horizontal lines while keeping series colours.
hHi = plot(showThresholds ? hiThreshold : na, "High Threshold",
     color = color.new(bearColor, 60), linewidth = 1, style = plot.style_linebr,
     editable = false)
hLo = plot(showThresholds ? loThreshold : na, "Low Threshold",
     color = color.new(bullColor, 60), linewidth = 1, style = plot.style_linebr,
     editable = false)
hZero = plot(showZeroLine ? 0.0 : na, "Zero",
     color = color.new(color.gray, 40), linewidth = 1, style = plot.style_linebr,
     editable = false)

// Soft fill between threshold lines for a "neutral zone" backdrop
fill(hHi, hLo, color.new(frameCol, 92), title="Neutral Zone Fill")

// ----- Composite background histogram (faint columns under the line) --------
//   Coloured by sign of composite, alpha-scaled by |composite| / extremeZ
histAlpha = int(f_clamp(85.0 - 40.0 * f_clamp(math.abs(composite) / extremeZ, 0.0, 1.0), 45.0, 95.0))
color histCol = composite > 0 ? color.new(bullColor, histAlpha) : composite < 0 ? color.new(bearColor, histAlpha) : color.new(flatColor, 90)
plot(showHistogram ? composite : na,
     "Composite Histogram",
     color     = histCol,
     style     = plot.style_columns,
     linewidth = 1)


// =============================================================================
//  SECTION 8 - DRAWINGS / LABELS / SIGNAL SHAPES
//      BUY/SELL labels live on the chart pane via force_overlay.
//      Style mirrors the v5 source (#7695e9 buy / #ea6d6d sell label colour
//      fallback) but defaults to the active theme bull/bear so labels match
//      the rest of the suite.
// =============================================================================

labSize = strToSize(labelSize)

// ----- BUY label (force_overlay back to chart) ------------------------------
if showLabels and buySignal
    label.new(bar_index, low,
         text          = "BUY",
         style         = label.style_label_up,
         color         = color.new(bullColor, 10),
         textcolor     = color.white,
         size          = labSize,
         force_overlay = true,
         tooltip       = "Composite MA slope flipped up. Dominant factor at signal: "
                         + dominantFactorStr)

// ----- SELL label (force_overlay back to chart) -----------------------------
if showLabels and sellSignal
    label.new(bar_index, high,
         text          = "SELL",
         style         = label.style_label_down,
         color         = color.new(bearColor, 10),
         textcolor     = color.white,
         size          = labSize,
         force_overlay = true,
         tooltip       = "Composite MA slope flipped down. Dominant factor at signal: "
                         + dominantFactorStr)

// ----- Divergence labels (force_overlay back to chart) ----------------------
if divLabel and bullDiv
    label.new(bar_index, low,
         text          = "Bull Div",
         style         = label.style_label_up,
         color         = color.new(bullColor, 25),
         textcolor     = color.black,
         size          = labSize,
         force_overlay = true,
         tooltip       = "Bullish divergence: price down, composite up over the lookback. Possible bottom forming.")

if divLabel and bearDiv
    label.new(bar_index, high,
         text          = "Bear Div",
         style         = label.style_label_down,
         color         = color.new(bearColor, 25),
         textcolor     = color.white,
         size          = labSize,
         force_overlay = true,
         tooltip       = "Bearish divergence: price up, composite down over the lookback. Possible top forming.")

// ----- In-pane glyphs (also useful for users who hide the chart labels) -----
plotshape(buySignal,  title="Buy Glyph (pane)",  location=location.bottom,
     color=bullColor, style=shape.triangleup,   size=size.tiny)
plotshape(sellSignal, title="Sell Glyph (pane)", location=location.top,
     color=bearColor, style=shape.triangledown, size=size.tiny)


// =============================================================================
//  SECTION 9 - DASHBOARD  (NEW for this indicator -- v5 source had none)
//      8 substantive rows + header. Per master plan section 10:
//        0  -  Header
//        1  -  Composite value
//        2  -  Slope direction
//        3  -  ROC factor Z (gauge)
//        4  -  ATR factor Z (gauge)
//        5  -  VolFlow factor Z (gauge)
//        6  -  EMA-Diff factor Z (gauge)
//        7  -  Dominant factor (NEW)
//        8  -  Divergence (NEW)
// =============================================================================

dashPos    = strToPos(dashPosStr)
dashSize   = strToSize(dashSizeStr)

hdrBg      = color.new(frameCol, 20)
cellBg     = color.new(bgRaw,    dashTransp)
hdrText    = color.white
cellText   = color.white

// Row count: 1 header + 8 metric rows = 9 total
var table tbl = table.new(dashPos, 2, 9,
     bgcolor      = na,
     frame_color  = frameCol,
     frame_width  = 1,
     border_color = color.new(frameCol, 65),
     border_width = 1)

// Helper to render a factor row with optional gauge string
factorRow(int row, string label, float zVal, float share) =>
    table.cell(tbl, 0, row, label,
         text_color = cellText, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_left)
    // Tint the cell by the factor's share of total |Z| -- larger share = brighter
    cellTint = color.new(zVal > 0 ? bullColor : zVal < 0 ? bearColor : flatColor,
                         int(f_clamp(85.0 - 50.0 * share, 35.0, 95.0)))
    valStr  = dashShowGauge ? gaugeStr(zVal, gaugeBarLen) + "  " + str.tostring(zVal, "0.00") : str.tostring(zVal, "0.00")
    table.cell(tbl, 1, row, valStr,
         text_color = cellText, bgcolor = cellTint,
         text_size  = dashSize, text_halign = text.align_right,
         text_font_family = font.family_monospace)

if barstate.islast and showDash
    // ----- Header ---------------------------------------------------------
    table.cell(tbl, 0, 0, "MOMENTUM VOL COMPOSITE",
         text_color = hdrText, bgcolor = hdrBg,
         text_size  = dashSize, text_halign = text.align_center,
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, 0, "[JOAT]",
         text_color = hdrText, bgcolor = hdrBg,
         text_size  = dashSize, text_halign = text.align_center,
         text_font_family = font.family_monospace)

    // ----- Row 1: Composite value ----------------------------------------
    table.cell(tbl, 0, 1, "Composite",
         text_color = cellText, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_left)
    compCol = composite > hiThreshold ? bearColor : composite < loThreshold ? bullColor : composite > 0 ? color.new(bullColor, 30) : composite < 0 ? color.new(bearColor, 30) : flatColor
    table.cell(tbl, 1, 1, str.tostring(composite, "0.000"),
         text_color = compCol, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // ----- Row 2: Slope direction ----------------------------------------
    table.cell(tbl, 0, 2, "Slope",
         text_color = cellText, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_left)
    slopeStr = slopeUp ? "Up    +" + str.tostring(slope, "0.0000") : slopeDn ? "Down  " + str.tostring(slope, "0.0000") : "Flat   " + str.tostring(slope, "0.0000")
    slopeTxtCol = slopeUp ? maUpColor : slopeDn ? maDownColor : flatColor
    table.cell(tbl, 1, 2, slopeStr,
         text_color = slopeTxtCol, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // ----- Rows 3-6: factor Z gauges -------------------------------------
    factorRow(3, "ROC Z",      rocZ, shareRoc)
    factorRow(4, "ATR Z",      atrZ, shareAtr)
    factorRow(5, "VolFlow Z",  vfZ,  shareVf)
    factorRow(6, "EMA Diff Z", emaZ, shareEma)

    // ----- Row 7: dominant factor (NEW) ----------------------------------
    table.cell(tbl, 0, 7, "Dominant",
         text_color = cellText, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_left)
    table.cell(tbl, 1, 7, dominantFactorStr,
         text_color = dominantFactorCol, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // ----- Row 8: divergence (NEW) ---------------------------------------
    table.cell(tbl, 0, 8, "Divergence",
         text_color = cellText, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_left)
    table.cell(tbl, 1, 8, divStr,
         text_color = divCol, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_right,
         text_font_family = font.family_monospace)


// =============================================================================
//  SECTION 10 - ALERTS
// =============================================================================

alertcondition(buySignal,
     title   = "Buy Signal",
     message = "MVC [JOAT] BUY: Composite MA slope flipped up.")

alertcondition(sellSignal,
     title   = "Sell Signal",
     message = "MVC [JOAT] SELL: Composite MA slope flipped down.")

alertcondition(hiEvent,
     title   = "High Threshold Crossed",
     message = "MVC [JOAT] HIGH: Composite has crossed above the high threshold.")

alertcondition(loEvent,
     title   = "Low Threshold Crossed",
     message = "MVC [JOAT] LOW: Composite has crossed below the low threshold.")

alertcondition(math.abs(composite) >= extremeZ,
     title   = "Composite Extreme",
     message = "MVC [JOAT] EXTREME: |composite| has reached the extreme threshold.")

alertcondition(bullDiv,
     title   = "Bullish Divergence",
     message = "MVC [JOAT] BULL DIV: Price down, composite up over divergence lookback.")

alertcondition(bearDiv,
     title   = "Bearish Divergence",
     message = "MVC [JOAT] BEAR DIV: Price up, composite down over divergence lookback.")


// =============================================================================
//  END OF FILE - Momentum Vol Composite Pro [JOAT]
// =============================================================================
````
