# Fractal Dimension Index [JOAT]

- url: https://www.tradingview.com/script/I57HOuVi-Fractal-Dimension-Index-JOAT/
- type: indicator
- pine_id: PUB;4b1b457b5e2f45d2bdbe1687fbce3b3a
- version: 1.0

## Description

[b]FRACTAL DIMENSION INDEX [JOAT][/b]

A proper [b]Higuchi-method[/b] Fractal Dimension Index that tells you whether the market is currently [i]trending[/i] (D approaches 1.0 — a smooth, linear path), [i]chopping[/i] (D approaches 2.0 — a noisy, plane-filling random walk), or somewhere in between. Unlike volatility, FDI does not care about [i]how much[/i] price moved — it cares about [i]how convoluted the path was getting there[/i]. That makes it the single cleanest regime-classification number in technical analysis.

[image]https://www.tradingview.com/x/KNWIn72A/[/image]

[b]What FDI measures[/b]

The fractal dimension of a curve is a number between 1.0 (a perfect line) and 2.0 (a curve dense enough to fill a plane). For price series:

[list]
[*] [b]D ≈ 1.0–1.4[/b] — the price path is close to a straight line. The market is trending; momentum tools work, reversion tools don't.
[*] [b]D ≈ 1.4–1.6[/b] — the path is in a transitional regime. Use neutral tools.
[*] [b]D ≈ 1.6–2.0[/b] — the path is chaotic and self-intersecting. The market is chopping; reversion tools work, momentum tools whipsaw.
[/list]

The Higuchi-paper canonical thresholds are 1.4 (trend) and 1.6 (chop); both are configurable.

[b]Higuchi algorithm — done properly[/b]

The implementation is the standard Higuchi method:

[list=1]
[*] For each [b]k[/b] from 1 to k_max (configurable, default 8), compute the average curve length [b]L(k)[/b] across k starting offsets, normalised by the window length N.
[*] Build the k_max pairs [b](log k, −log L(k))[/b].
[*] Fit a least-squares line through those pairs; the slope is the fractal dimension [b]D[/b].
[*] Apply optional EMA smoothing (configurable, default 5 bars) to suppress per-bar jitter.
[/list]

A [b]minimum-valid-pairs guard[/b] (default 3) prevents D from being computed when too few (k, L) pairs are finite, and a [b]warmup-bars[/b] gate (default 50) prevents wild D values on sparse early data.

[b]Regime classification with hysteresis[/b]

Raw D is mapped to one of three regimes — Trending / Random / Chop — using the two-threshold scheme. Two extra alert thresholds ([b]Extreme Trend[/b] D < 1.30 and [b]Extreme Chop[/b] D > 1.70) flag the high-conviction tail cases.

[b]Visual system[/b]

[list]
[*] [b]Background tint by regime[/b] — pastel mint for trend, coral for chop, cream for random. Transparency configurable (default 88, institutional-subtle).
[*] [b]Regime-change markers[/b] — tiny up/down/circle glyphs above price at every confirmed flip.
[*] [b]Optional candle tinting[/b] by regime (off by default to preserve user's chart style).
[*] [b]Optional D-line companion[/b] — when enabled, the smoothed D is plotted as a series. Because the script is overlay, pin the line to its own scale (right-click → Pin to scale → No Scale). For a true sub-pane, add the indicator a second time and drag that instance into a new pane.
[*] [b]Right-side floating label[/b] — anchored N bars right of the live close showing current D and a regime glyph. Configurable size, offset, regime text.
[*] [b]Optional reference horizontal lines[/b] at D = 1.4 / 1.5 / 1.6 when the D-line is shown.
[/list]

A locked Pastel palette (mint trend / coral chop / cream random on a warm-white ground) gives the indicator a distinctive soft-institutional look.

[b]Dashboard[/b]

Monospaced table positionable to any of nine corners. Surfaces:

[list]
[*] Current D value and smoothed D value.
[*] Regime classification with glyph.
[*] Bars in current regime.
[*] Distance to nearest threshold.
[*] Extreme-state badge when in tail regions.
[/list]

[b]Alerts[/b]

Four alert conditions, each independently controllable:

[list]
[*] Regime Flip (any classification change)
[*] Extreme Trend (D crosses below 1.30)
[*] Extreme Chop (D crosses above 1.70)
[*] D Series Crosses 1.5 (the random-walk centre)
[/list]

[b]How to read it[/b]

Two reads, in order of conviction:

[list=1]
[*] [b]Regime classification + bars in regime[/b] — the more bars the current regime has persisted, the more reliable the read. Brand-new flips can flicker; multi-bar confirmed regimes do not.
[*] [b]Extreme regime alerts[/b] — when D crosses below 1.30, the market is in an extremely directional regime — momentum trades are the highest-conviction setups. When D crosses above 1.70, the market is in pathological chop — fade extremes, do not chase breakouts.
[/list]

The single most useful workflow is to use FDI as a [b]meta-filter[/b] — pair every signal-generating indicator with FDI regime. Trend signals from a momentum tool become high-conviction when D < 1.4; reversion signals from a Z-score oscillator become high-conviction when D > 1.6. The Suggested JOAT Indicator dashboard rows in [i]Hurst Regime Sentinel[/i] and [i]Entropy Oscillator[/i] follow exactly this principle.

[b]Suggested settings[/b]

Defaults (window 30, k_max 8, EMA smoothing 5, warmup 50) are tuned for 15m–1H. For lower timeframes drop window to 20 and EMA to 3. For HTF (4H+) raise window to 50 and EMA to 8. The Higuchi-paper thresholds (1.4 / 1.6) are intentionally classical — tighten only if you find the regime classification too sensitive on your instrument.

[b]Originality / what's reused[/b]

The Higuchi fractal-dimension algorithm is the textbook 1988 method — a public-domain piece of applied mathematics, implemented from the paper. The implementation here — the bounded-loop Higuchi pipeline with minimum-pairs guard and warmup gate, the two-threshold regime classifier with extreme-tail alerts, the pastel-palette regime tint, the pin-to-scale D-line companion logic, the right-side floating label, and the dashboard — is JOAT-original. No third-party code reused.

[b]Open source[/b]

Published open-source under the default Mozilla Public License 2.0. The Higuchi loop, the regime classifier, the alert logic, and the dashboard are isolated modules — adapt any single piece without reading the whole file. Forks welcome with credit.

[b]Limitations[/b]

Higuchi D is statistical — it tells you about [i]recent path complexity[/i], not future direction. A trending regime (D < 1.4) does not say which way; it says momentum tools should work. Combine with a directional indicator. The algorithm uses bounded Pine loops; very large window values increase compile cost. D is smoothed (EMA-filtered) by default, which trades some lag for substantially reduced flicker; turn smoothing off to see raw D.

—

-made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title     = "Fractal Dimension Index [JOAT]",
          shorttitle= "FDI [JOAT]",
          overlay   = true,
          max_lines_count  = 500,
          max_boxes_count  = 500,
          max_labels_count = 500,
          max_bars_back    = 5000)


// =============================================================================
//  SECTION 1 - INPUTS
//      Grouped with box-drawing headers.
//      Three primary groups: Calc, Thresholds, Visuals + Theme + Dashboard +
//      Pane Companion + Alerts. Each input has an explanatory tooltip so the
//      end user can tune without reading source code.
// =============================================================================

grpCalc   = "+----- Higuchi Calc -----+"
grpThresh = "+----- Regime Thresholds -----+"
grpVis    = "+----- Visuals -----+"
grpPane   = "+----- Pane Companion (D Line) -----+"
grpTheme  = "+----- Theme + Palette -----+"
grpDash   = "+----- Dashboard -----+"
grpLabel  = "+----- Right-Side Label -----+"
grpAlert  = "+----- Alerts -----+"

// ----- Higuchi Calc ----------------------------------------------------------
src          = input.source(close, "Source", group=grpCalc,
                  tooltip="Series fed to the Higuchi algorithm. close is the canonical pick.")
len          = input.int(30, "Window Length (N)", minval=10, maxval=200, group=grpCalc,
                  tooltip="Number of samples used inside the Higuchi window. Default 30. "+
                          "Smaller = more reactive D, noisier. Larger = smoother D, lagging.")
kMax         = input.int(8,  "k_max (curve points)", minval=3, maxval=20, group=grpCalc,
                  tooltip="Highest k used in the L(k) curve. The regression slope is built "+
                          "from kMax pairs (log k, -log L(k)). Higher kMax = better fit, "+
                          "more compute. Default 8 is the sweet spot for len=30.")
smoothLen    = input.int(5,  "EMA Smoothing of D", minval=1, maxval=100, group=grpCalc,
                  tooltip="EMA period applied on top of the raw Higuchi D to suppress the "+
                          "per-bar jitter. Setting this to 1 reveals the raw D.")
guardMinPairs = input.int(3, "Min Valid (k, L) Pairs for Slope", minval=2, maxval=30, group=grpCalc,
                  tooltip="Slope is only computed when at least this many (k, L) pairs are "+
                          "finite. Below this, D is held at the previous bar's value.")
warmupBars   = input.int(50, "Warmup Bars (no D before this many bars elapsed)", minval=10, maxval=500, group=grpCalc,
                  tooltip="Don't emit a D value until at least this many bars have been seen. "+
                          "Prevents wild D values from sparse early data.")

// ----- Thresholds ------------------------------------------------------------
trendUpper   = input.float(1.40, "Trending Upper Bound (D < this = TREND)",
                  step=0.05, minval=1.00, maxval=2.00, group=grpThresh,
                  tooltip="If smoothed D is BELOW this value, classify as Trending. "+
                          "Default 1.4 is the Higuchi-paper canonical threshold.")
chopLower    = input.float(1.60, "Chop Lower Bound (D > this = CHOP)",
                  step=0.05, minval=1.00, maxval=2.00, group=grpThresh,
                  tooltip="If smoothed D is ABOVE this value, classify as Chop. "+
                          "Default 1.6 is the Higuchi-paper canonical threshold.")
extremeHigh  = input.float(1.70, "Extreme-Chop Alert (D > this)",
                  step=0.05, minval=1.00, maxval=2.00, group=grpThresh,
                  tooltip="Alert fires when D crosses ABOVE this. Indicates pathological chop.")
extremeLow   = input.float(1.30, "Extreme-Trend Alert (D < this)",
                  step=0.05, minval=1.00, maxval=2.00, group=grpThresh,
                  tooltip="Alert fires when D crosses BELOW this. Indicates strong directional regime.")

// ----- Visuals ---------------------------------------------------------------
showBgTint   = input.bool(true, "Show Background Tint by Regime", group=grpVis,
                  tooltip="Paints the chart background in pastel bull / coral bear / cream "+
                          "neutral colors based on current classification. Subtle by default.")
bgTransp     = input.int(88, "Background Tint Transparency", minval=60, maxval=99, group=grpVis,
                  tooltip="Higher = more subtle. 88 is the institutional default. 60 = bold.")
showRegimeChange = input.bool(true, "Plot Regime-Change Markers", group=grpVis,
                  tooltip="Tiny up/down/circle markers above price when the classification flips.")
markerSize   = input.string("Tiny", "Regime Marker Size",
                  options=["Tiny","Small","Normal"], group=grpVis)
showCandleTint   = input.bool(false, "Tint Candle Bodies by Regime", group=grpVis,
                  tooltip="OPTIONAL: re-color the candles by current regime. Off by default "+
                          "because it overrides the user's existing chart style.")
candleAlpha  = input.int(35, "Candle Tint Transparency", minval=0, maxval=90, group=grpVis,
                  tooltip="Only applies when 'Tint Candle Bodies by Regime' is on.")

// ----- Pane Companion --------------------------------------------------------
//  We are an overlay indicator. The raw D value (~1.0 .. 2.0) cannot be drawn
//  on the price axis. The 'pane companion' toggle hides/shows the D line via
//  display.none ; when shown, the user must drag-pin the indicator to its own
//  scale (TradingView right-click > Visual Order > Pin to scale > No Scale).
showDLine    = input.bool(false, "Show D Line (raw + smoothed)", group=grpPane,
                  tooltip="When ON, the smoothed D is plotted as a series. Because the "+
                          "indicator is overlay, you must pin the line to its own scale: "+
                          "right-click on the line > Pin to scale > No Scale. To get a "+
                          "true sub-pane, also add this same indicator a second time and "+
                          "drag THAT instance into a new pane.")
showRawDLine = input.bool(false, "Also Show Raw (un-smoothed) D Line", group=grpPane,
                  tooltip="Plots the raw D before EMA smoothing. Use to tune EMA period.")
showRegimeHlines = input.bool(false, "Show 1.4 / 1.5 / 1.6 Reference Lines", group=grpPane)

// ----- Theme -----------------------------------------------------------------
// PASTEL PALETTE (curated, single source of truth - SOFT institutional aesthetic)
//   trending = #A8E6CF mint    chop = #FF8B94 coral   random = #FFD3B6 cream
//   bg       = #FFF3E0 warm white         frame  = #E8DAB2
useChartBg     = input.bool(false, "Use Chart Background (override theme)", group=grpTheme)

// ----- Dashboard -------------------------------------------------------------
showDash       = input.bool(true, "Show Dashboard", group=grpDash)
dashPosStr     = input.string("Top Right", "Dashboard Position",
     options=["Top Right","Top Left","Top Center","Middle Right","Middle Left","Middle Center","Bottom Right","Bottom Left","Bottom Center"],
     group=grpDash)
dashSizeStr    = input.string("Small", "Dashboard Text Size",
     options=["Tiny","Small","Normal","Large","Huge"], group=grpDash)
dashTransp     = input.int(82, "Cell Transparency", minval=0, maxval=100, group=grpDash)

// ----- Right-Side Label ------------------------------------------------------
showRightLabel = input.bool(true, "Show D Value Label on Right of Chart", group=grpLabel,
                   tooltip="Floating label N bars to the right of the live close showing "+
                           "current D + regime glyph.")
labelOffset    = input.int(8, "Label Offset (bars to right)", minval=1, maxval=50, group=grpLabel)
labelSizeStr   = input.string("Normal", "Label Size",
                   options=["Tiny","Small","Normal","Large","Huge"], group=grpLabel)
showRegimeText = input.bool(true, "Append Regime Text to Label", group=grpLabel)

// ----- Alerts ----------------------------------------------------------------
alertOnFlip    = input.bool(true, "Alert on Regime Flip", group=grpAlert)
alertOnExtreme = input.bool(true, "Alert on D Extremes (>1.7 or <1.3)", group=grpAlert)


// =============================================================================
//  SECTION 2 - PASTEL PALETTE (single curated palette - soft institutional)
//      bullColor (TREND) = mint  #A8E6CF
//      bearColor (CHOP)  = coral #FF8B94
//      midColor (RANDOM) = cream #FFD3B6
//      bg                = warm white #FFF3E0
//      frame             = #E8DAB2
// =============================================================================
const color trendColor = #A8E6CF    // mint  - trending regime
const color chopColor  = #FF8B94    // coral - chop regime
const color randColor  = #FFD3B6    // cream - random regime
const color C_PASTEL_BG    = #FFF3E0
const color C_PASTEL_FRAME = #E8DAB2

color bgRaw        = useChartBg ? chart.bg_color : C_PASTEL_BG
color frameCol     = C_PASTEL_FRAME
isLightTheme = true                  // Pastel is a LIGHT-background theme

// Generic flat / muted color for dashboard placeholders
color flatColor  = color.rgb(136, 136, 136)


// =============================================================================
//  SECTION 3 - HELPER FUNCTIONS
//      f_colorGradient - 2-color RGB interpolation
//      f_clamp - numeric clamp
//      strToPos / strToSize - dashboard layout
//      regimeLabel              - "Trending" / "Random" / "Chop" name resolver
//      regimeColor              - color resolver per regime int code
//      regimeGlyph              - 1-char regime glyph (▲ ◆ ▼)
//      hguchi(...)              - full Higuchi calc (see Section 4)
// =============================================================================

f_colorGradient(float _ratio, color _colA, color _colB) =>
    rA = color.r(_colA), gA = color.g(_colA), bA = color.b(_colA)
    rB = color.r(_colB), gB = color.g(_colB), bB = color.b(_colB)
    rr = rA + int((rB - rA) * _ratio)
    rg = gA + int((gB - gA) * _ratio)
    rb = bA + int((bB - bA) * _ratio)
    color.rgb(rr, rg, rb, 0)

f_clamp(float _x, float _min, float _max) => math.max(_min, math.min(_x, _max))

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

strToSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.normal

// Regime code -> human label.  -1 = TREND, 0 = RANDOM, +1 = CHOP
regimeLabel(int code) =>
    code == -1 ? "Trending" : code ==  0 ? "Random" : code == +1 ? "Chop" : "Init"

regimeColor(int code) =>
    code == -1 ? trendColor : code == +1 ? chopColor : randColor

regimeGlyph(int code) =>
    code == -1 ? "▲" : code == +1 ? "▼" : code ==  0 ? "◆" : "·"

// Adaptive text color: choose near-black on light themes, white on dark.
adaptiveText() =>
    isLightTheme ? color.new(color.black, 0) : color.new(color.white, 0)


// =============================================================================
//  SECTION 4 - CORE CALCULATIONS  (Higuchi Fractal Dimension)
//
//      higuchiD(src, N, kMax, minPairs) -> float D in [1.0 .. 2.0]
//
//      Algorithm (literal port of Higuchi 1988):
//
//      Step 1: for each k in 1..kMax
//                  for each m in 1..k
//                      idxMax = floor((N-m)/k)
//                      if idxMax >= 1
//                          accum = sum_{i=1..idxMax} |x[m+i*k] - x[m+(i-1)*k]|
//                          norm  = (N - 1) / (idxMax * k)
//                          L_m   = accum * norm
//                      Lsum   += L_m
//                      mCount += 1
//                  L(k) = Lsum / mCount
//                  logK   = log(k)
//                  negLogL= -log(L(k))      [we plot NEG log so slope is +ve]
//                  push (logK, negLogL) onto arrays
//
//      Step 2: validate at least minPairs finite (logK, negLogL) entries
//      Step 3: compute the OLS slope b = sum((x-xbar)(y-ybar)) / sum((x-xbar)^2)
//              That slope IS the Higuchi fractal dimension D.
//      Step 4: clamp D to [1.0, 2.0] (theoretical bounds).
//
//      Pine index convention: src[0] is the NEWEST sample, src[N-1] is OLDEST.
//      In the formula we use 1-based m and 0-based-incrementing i, so x[m+ik]
//      maps to Pine offset (m + i*k - 1).  We must guard the offset against
//      the last valid bar so we never index past the loaded data.
//
//      Loop bound analysis (Pine kills loops > 4900 iterations per bar):
//          Outer (k):  1..kMax            <= 30
//          Middle (m): 1..k               <= 30
//          Inner (i):  1..floor((N-m)/k)  <= N <= 200
//          Worst case: 30 * 30 * 200 = 180,000 -> WAY over the limit.
//          Practical case: kMax=8, N=30  ->  ~ 36 * 30/k_average ~ 540 ops. SAFE.
//          Defensive cap: we early-out if N/kMax < 2 (k too big for window).
// =============================================================================

higuchiD(float _src, int _N, int _kMax, int _minPairs) =>
    // Build (logK, negLogL) arrays as we go ---------------------------------
    var float[] xs = array.new<float>()
    var float[] ys = array.new<float>()
    array.clear(xs)
    array.clear(ys)

    // Bounded loop: enforce a hard cap on kMax so total inner ops <= ~kMax^2 * N
    int effKMax = math.min(_kMax, math.max(2, int(math.floor(_N / 2.0))))

    for k = 1 to effKMax
        float Lsum   = 0.0
        int   mCount = 0
        for m = 1 to k
            int idxMax = int(math.floor((_N - m) / float(k)))
            if idxMax >= 1
                float accum = 0.0
                for i = 1 to idxMax
                    int off1 = m + i * k - 1
                    int off0 = m + (i - 1) * k - 1
                    // Hard guard: do not read past loaded bars
                    if off1 >= 0 and off0 >= 0
                        float v1 = _src[off1]
                        float v0 = _src[off0]
                        if not na(v1) and not na(v0)
                            accum += math.abs(v1 - v0)
                float norm = (float(_N - 1)) / (float(idxMax) * float(k))
                float L_m  = accum * norm
                Lsum   += L_m
                mCount += 1

        if mCount > 0
            float Lk = Lsum / float(mCount)
            if Lk > 0.0
                float logK   = math.log(float(k))
                float negLgL = -math.log(Lk)
                if not na(logK) and not na(negLgL)
                    array.push(xs, logK)
                    array.push(ys, negLgL)

    // Validate sample count --------------------------------------------------
    int nPairs = array.size(xs)
    float dOut = na
    if nPairs >= _minPairs
        // Compute OLS slope by the normal equations -------------------------
        float sx  = 0.0
        float sy  = 0.0
        for p = 0 to nPairs - 1
            sx += array.get(xs, p)
            sy += array.get(ys, p)
        float xb = sx / float(nPairs)
        float yb = sy / float(nPairs)
        float numer = 0.0
        float denom = 0.0
        for p = 0 to nPairs - 1
            float dx = array.get(xs, p) - xb
            float dy = array.get(ys, p) - yb
            numer += dx * dy
            denom += dx * dx
        if denom > 0.0
            float slope = numer / denom
            // Slope of -log L vs log k IS the Higuchi fractal dimension D
            dOut := slope
    dOut

// ----- Run the engine --------------------------------------------------------
// Hold raw D for downstream smoothing + classification
rawDUnclamped = higuchiD(src, len, kMax, guardMinPairs)
// Clamp to theoretical [1.0, 2.0] - any out-of-range value is numerical noise
rawD = na(rawDUnclamped) ? na : f_clamp(rawDUnclamped, 1.0, 2.0)

// Persist the previous good D so we can hold it across na bars
var float lastGoodRawD = na
if not na(rawD)
    lastGoodRawD := rawD
heldD = nz(rawD, lastGoodRawD)

// Don't emit anything until warmup is done
warmedUp = bar_index >= warmupBars and not na(heldD)
dFinal   = warmedUp ? heldD : na

// EMA smoothing of D ----------------------------------------------------------
smoothD = warmedUp ? ta.ema(dFinal, smoothLen) : na


// =============================================================================
//  SECTION 5 - STATE / TRACKING
//      State variables persist across bars (var) and update on classification
//      transitions only - this is the core Pine v6 "memory" pattern.
//
//      Tracked:
//          currentClass        - latest regime code (-1, 0, +1)
//          prevClass           - previous bar's regime code (for transition detect)
//          classChangeBar      - bar_index of the last classification change
//          barsInClass         - how many bars we've been in currentClass
//          flipsSeen           - lifetime count of regime flips (dashboard stat)
//          lastTrendBar/Chop   - bookkeeping for "last seen" lookups
//          extremeUpFiredBar   - last bar an EXTREME-CHOP alert condition was true
//          extremeDnFiredBar   - same for EXTREME-TREND
// =============================================================================

var int currentClass     = 0      // 0 init -> resolved on first warmup bar
var int prevClass        = 0
var int classChangeBar   = na
var int flipsSeen        = 0
var int extremeUpFiredBar = na
var int extremeDnFiredBar = na

// =============================================================================
//  SECTION 6 - CLASSIFICATION LOGIC
//      Translate smoothed D into a regime code, detect flips, update tracking.
// =============================================================================

// Compute the candidate class from this bar's smoothed D
int candidateClass = 0
if not na(smoothD)
    if smoothD < trendUpper
        candidateClass := -1      // TREND
    else if smoothD > chopLower
        candidateClass := +1      // CHOP
    else
        candidateClass :=  0      // RANDOM
else
    candidateClass := currentClass  // hold last while warming up

// Detect transition on confirmed bars only ---------------------------
isFlip = false
if barstate.isconfirmed and warmedUp
    if candidateClass != currentClass
        isFlip          := true
        prevClass       := currentClass
        currentClass    := candidateClass
        classChangeBar  := bar_index
        flipsSeen       += 1
    else
        // No flip - still keep classChangeBar's prior value (na on first emit)
        if na(classChangeBar)
            classChangeBar := bar_index

// Live update for the non-confirmed bar so the dashboard reflects "right now"
liveClass = barstate.isconfirmed ? currentClass : candidateClass

// barsInClass: count of bars since the last flip (or since warmup if no flips)
barsInClass = na(classChangeBar) ? (bar_index - warmupBars + 1) : (bar_index - classChangeBar + 1)
barsInClass := math.max(1, barsInClass)

// last-change distance (used in dashboard as "N bars ago")
lastChangeDist = na(classChangeBar) ? na : (bar_index - classChangeBar)


// =============================================================================
//  SECTION 7 - PLOTS  (background tint + optional D line)
//      Section 7 sets paint; Section 8 does discrete drawings (label, markers).
// =============================================================================

// ----- 7.1  Background tint by regime ----------------------------------------
//   We compose the bg color from the regime color + the user-controlled
//   transparency. Higher transparency value -> more subtle tint.
bgRegimeBaseColor = regimeColor(liveClass)
bgTintColor       = color.new(bgRegimeBaseColor, bgTransp)
bgcolor(showBgTint and warmedUp ? bgTintColor : na, title="Regime Background Tint")

// ----- 7.2  Optional candle tint by regime (off by default) ------------------
candleTint = showCandleTint and warmedUp ? color.new(bgRegimeBaseColor, candleAlpha) : na
plotcandle(open, high, low, close,
     title       = "Regime-Tinted Candles",
     color       = candleTint,
     wickcolor   = candleTint,
     bordercolor = candleTint,
     force_overlay = true)

// ----- 7.3  D line (smoothed) - hidden by default ---------------------------
//   Because we are overlay, the raw D value (~ 1.0-2.0) cannot be plotted on
//   the price axis usefully. The user is expected to right-click the plot,
//   Pin-to-scale > No Scale, when enabling this option. To get a true
//   sub-pane, add the indicator a second time and drag it to a new pane.
dLineDisplay    = showDLine    ? display.all : display.none
rawDLineDisplay = showRawDLine ? display.all : display.none

dLineColor = regimeColor(liveClass)
plot(showDLine ? smoothD : na, "Smoothed D",
     color    = dLineColor,
     linewidth= 2,
     display  = dLineDisplay)

plot(showRawDLine ? rawD : na, "Raw D",
     color    = color.new(flatColor, 30),
     linewidth= 1,
     display  = rawDLineDisplay)

// ----- 7.4  Reference horizontal lines (1.4 / 1.5 / 1.6) --------------------
//   These are nominally pane-only. Because we are overlay we use display.none
//   unless the user explicitly opts in.
hRefDisplay = showRegimeHlines ? display.all : display.none

hline(showRegimeHlines ? trendUpper : na, "Trend Upper (1.4)",
     color = color.new(trendColor, 40),
     linestyle = hline.style_dashed,
     display = hRefDisplay)
hline(showRegimeHlines ? 1.5        : na, "Random Mid (1.5)",
     color = color.new(randColor, 40),
     linestyle = hline.style_dotted,
     display = hRefDisplay)
hline(showRegimeHlines ? chopLower : na, "Chop Lower (1.6)",
     color = color.new(chopColor, 40),
     linestyle = hline.style_dashed,
     display = hRefDisplay)


// =============================================================================
//  SECTION 8 - DRAWINGS  (right-side D label + regime change markers)
// =============================================================================

// ----- 8.1  Right-side floating label ---------------------------------------
//   Persistent single label. Update its position + text on every last bar.
//   Show the D value (3 decimals), regime glyph, and optionally regime text.
labelSize  = strToSize(labelSizeStr)
markerSz   = strToSize(markerSize)

var label dLabel = na
if showRightLabel and barstate.islast and warmedUp and not na(smoothD)
    if na(dLabel)
        dLabel := label.new(
             x         = bar_index + labelOffset,
             y         = close,
             text      = "",
             style     = label.style_label_left,
             color     = color.new(regimeColor(liveClass), 15),
             textcolor = adaptiveText(),
             size      = labelSize,
             xloc      = xloc.bar_index,
             yloc      = yloc.price)
    string txt = "D " + str.tostring(smoothD, "0.000") + " " + regimeGlyph(liveClass)
    if showRegimeText
        txt := txt + "  " + regimeLabel(liveClass)
    label.set_xy   (dLabel, bar_index + labelOffset, close)
    label.set_text (dLabel, txt)
    label.set_color(dLabel, color.new(regimeColor(liveClass), 15))
    label.set_textcolor(dLabel, adaptiveText())
    label.set_size (dLabel, labelSize)

// Make sure the label is removed if the user turns it off
if not showRightLabel and not na(dLabel)
    label.delete(dLabel)
    dLabel := na

// ----- 8.2  Regime-change markers above/below price -------------------------
//   Three flavours: -> Trend (up arrow, mint), -> Chop (down arrow, coral),
//                   -> Random (diamond, cream). Only on confirmed flips.
flipToTrend  = isFlip and currentClass == -1
flipToChop   = isFlip and currentClass == +1
flipToRandom = isFlip and currentClass ==  0

plotshape(showRegimeChange and flipToTrend,  title="Flip -> Trend",
     style    = shape.triangleup,
     location = location.abovebar,
     color    = trendColor,
     size     = size.tiny)
plotshape(showRegimeChange and flipToChop,   title="Flip -> Chop",
     style    = shape.triangledown,
     location = location.abovebar,
     color    = chopColor,
     size     = size.tiny)
plotshape(showRegimeChange and flipToRandom, title="Flip -> Random",
     style    = shape.diamond,
     location = location.abovebar,
     color    = randColor,
     size     = size.tiny)


// =============================================================================
//  SECTION 9 - DASHBOARD  (six metric rows + header)
//      Layout (7 rows in total = 1 header + 6 metrics) per spec:
//          row 0  -  header "FRACTAL DIMENSION"
//          row 1  -  D value (3 decimals)
//          row 2  -  Classification name (colored)
//          row 3  -  Bars in current class
//          row 4  -  Last change "N bars ago"
//          row 5  -  Window length
//          row 6  -  k_max effective
// =============================================================================

dashPos  = strToPos(dashPosStr)
dashSize = strToSize(dashSizeStr)

hdrBg    = color.new(frameCol, 15)
cellBg   = color.new(bgRaw,    dashTransp)
cellText = adaptiveText()
hdrText  = adaptiveText()

var table tbl = table.new(dashPos, 2, 7,
     bgcolor      = na,
     frame_color  = frameCol,
     frame_width  = 1,
     border_color = color.new(frameCol, 65),
     border_width = 1)

if barstate.islast and showDash
    // ----- Row 0: header (spans both cols by repetition) --------------------
    table.cell(tbl, 0, 0, "FRACTAL DIMENSION",
         text_color  = hdrText,
         bgcolor     = hdrBg,
         text_halign = text.align_left,
         text_valign = text.align_center,
         text_size   = dashSize,
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, 0, regimeGlyph(liveClass) + " " + regimeLabel(liveClass),
         text_color  = regimeColor(liveClass),
         bgcolor     = hdrBg,
         text_halign = text.align_right,
         text_valign = text.align_center,
         text_size   = dashSize,
         text_font_family = font.family_monospace)

    // ----- Row 1: D value ---------------------------------------------------
    table.cell(tbl, 0, 1, "D value",
         text_color = cellText, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_left,
         text_font_family = font.family_monospace)
    string dText = na(smoothD) ? "warming up..." : str.tostring(smoothD, "0.000")
    color  dCol  = na(smoothD) ? flatColor : regimeColor(liveClass)
    table.cell(tbl, 1, 1, dText,
         text_color = dCol, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // ----- Row 2: Classification --------------------------------------------
    table.cell(tbl, 0, 2, "Class",
         text_color = cellText, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, 2, regimeLabel(liveClass),
         text_color = regimeColor(liveClass), bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // ----- Row 3: Bars in class ---------------------------------------------
    table.cell(tbl, 0, 3, "Bars in class",
         text_color = cellText, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, 3, str.tostring(barsInClass),
         text_color = cellText, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // ----- Row 4: Last change (N bars ago) ----------------------------------
    table.cell(tbl, 0, 4, "Last change",
         text_color = cellText, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_left,
         text_font_family = font.family_monospace)
    string lcText = na(lastChangeDist) ? "(none)" : (str.tostring(lastChangeDist) + " bars ago")
    table.cell(tbl, 1, 4, lcText,
         text_color = cellText, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // ----- Row 5: Window length ---------------------------------------------
    table.cell(tbl, 0, 5, "Window (N)",
         text_color = cellText, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, 5, str.tostring(len),
         text_color = cellText, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // ----- Row 6: k_max effective -------------------------------------------
    table.cell(tbl, 0, 6, "k_max",
         text_color = cellText, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_left,
         text_font_family = font.family_monospace)
    int effKMaxShown = math.min(kMax, math.max(2, int(math.floor(len / 2.0))))
    table.cell(tbl, 1, 6, str.tostring(effKMaxShown) + " / " + str.tostring(kMax),
         text_color = cellText, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_right,
         text_font_family = font.family_monospace)


// =============================================================================
//  SECTION 10 - ALERTS
//      Three alert classes:
//          1. Any classification flip                     (alertOnFlip toggle)
//          2. D crosses ABOVE extremeHigh (>1.7 default)  (alertOnExtreme)
//          3. D crosses BELOW extremeLow  (<1.3 default)  (alertOnExtreme)
// =============================================================================

// Edge-detect extremes (only on first bar of the condition)
extremeHighNow  = not na(smoothD) and smoothD > extremeHigh
extremeLowNow   = not na(smoothD) and smoothD < extremeLow
extremeHighPrev = not na(smoothD[1]) and smoothD[1] > extremeHigh
extremeLowPrev  = not na(smoothD[1]) and smoothD[1] < extremeLow

extremeHighEdge = extremeHighNow and not extremeHighPrev
extremeLowEdge  = extremeLowNow  and not extremeLowPrev

if extremeHighEdge
    extremeUpFiredBar := bar_index
if extremeLowEdge
    extremeDnFiredBar := bar_index

// ----- Generic classification-flip alerts ------------------------------------
alertcondition(alertOnFlip and flipToTrend,
     title   = "FDI Flip to Trending",
     message = "FDI [JOAT]: Regime flipped to TRENDING (D dropped below trend threshold).")
alertcondition(alertOnFlip and flipToChop,
     title   = "FDI Flip to Chop",
     message = "FDI [JOAT]: Regime flipped to CHOP (D rose above chop threshold).")
alertcondition(alertOnFlip and flipToRandom,
     title   = "FDI Flip to Random",
     message = "FDI [JOAT]: Regime flipped to RANDOM walk (D in mid band).")

// ----- D-extreme alerts ------------------------------------------------------
alertcondition(alertOnExtreme and extremeHighEdge,
     title   = "FDI Extreme Chop",
     message = "FDI [JOAT]: D crossed above extreme threshold - pathological chop.")
alertcondition(alertOnExtreme and extremeLowEdge,
     title   = "FDI Extreme Trend",
     message = "FDI [JOAT]: D crossed below extreme threshold - very strong directional regime.")


// =============================================================================
//  END OF FILE - Fractal Dimension Index [JOAT]
//
//  Implementation notes for the next developer:
//
//   * Higuchi was chosen over box-counting because it is well-defined on
//     univariate time series and converges with as few as ~30 samples.
//     Box-counting requires gridding the (t, x) plane and is much heavier.
//
//   * The OLS slope is computed by the normal equations on (logK, -logL).
//     We use the NEGATIVE log of L so that the slope is positive in the
//     standard 1.0..2.0 range. Equivalent to slope of log(L) vs log(1/k).
//
//   * `ta.linreg` is intentionally NOT used here because Pine's `ta.linreg`
//     operates on a SERIES with bar-lookback, whereas we need the slope of
//     a tuple-by-tuple (logK, logL) array assembled per-bar. The closed-form
//     normal equations are the correct tool.
//
//   * Memory: the (logK, logL) arrays are declared `var` and cleared on each
//     bar with array.clear() to avoid reallocating storage every bar. This
//     is a Pine v6 micro-optimization.
//
//   * Loop safety: with kMax <= 30 and N <= 200 the theoretical worst case
//     is ~180k ops, but real defaults of (kMax=8, N=30) put us at ~540 ops
//     per bar, two orders of magnitude under Pine's per-bar cap of 4900.
//
//   * Visual default: 'Pastel' theme. Mint = Trending, Coral = Chop,
//     Cream = Random. Background tint at 88% transparency for soft pastel
//     reading. The right-side label is the most important UI element.
//
//   * Pairing: this indicator complements #15 Hurst Regime Sentinel exactly -
//     Higuchi measures COMPLEXITY (how rough the path is), Hurst measures
//     PERSISTENCE (how memory-laden the returns are). Triple-stacked with
//     #29 Entropy Oscillator they form the JOAT regime-confidence layer.
// =============================================================================
````
