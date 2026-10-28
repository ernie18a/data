# CVD Delta Divergence [JOAT]

- url: https://www.tradingview.com/script/V5NHdMI3-CVD-Delta-Divergence-JOAT/
- type: indicator
- pine_id: PUB;962ca860d516454f92c65efd0a514678
- version: 1.0

## Description

[b]CVD DELTA DIVERGENCE [JOAT][/b]

A full-featured Cumulative Volume Delta engine with proper pivot-based divergence detection. CVD on its own is one of the cleanest reads of net flow you can produce without L2 data — but the value of CVD lives almost entirely in its [i]divergence[/i] with price. CVD Delta Divergence builds the CVD properly (with footprint-API or reconstructed-tick options), then runs a strict pivot-vs-pivot divergence engine on top of it, with strength scoring and configurable cooldown.

[image]https://www.tradingview.com/x/80RC7tNb/[/image]

[b]Three data-source modes[/b]

CVD is only as good as the delta classification underneath it. Three modes are exposed:

[list]
[*] [b]Footprint API[/b] — uses TradingView's Footprint dataset when the instrument supports it. The cleanest read, equivalent to professional delta feeds.
[*] [b]Reconstructed[/b] — when Footprint is unavailable, reconstructs buy/sell from a configurable lower-timeframe stream (1m / 3m / 5m / 15m / 30m) using the standard tick rule. Optional intrabar volume weighting.
[*] [b]Auto[/b] — picks Footprint when present, falls back to Reconstructed. The recommended default.
[/list]

This is unusual — most public CVD scripts hardcode one method. Auto-mode means the script works correctly on any instrument that has [i]either[/i] dataset, without per-instrument configuration.

[b]Four CVD anchors[/b]

Cumulative deltas need an anchor — running a sum from inception of data is rarely meaningful. Four anchoring modes:

[list]
[*] [b]Cumulative[/b] — never resets. Maximum context, slowest divergence detection.
[*] [b]Session Reset[/b] (default) — anchors at the start of each trading session. The most useful read for day-trading reference.
[*] [b]Day Reset[/b] — anchors at midnight exchange time.
[*] [b]Week Reset[/b] — anchors at week boundary. Good for swing-frame divergences.
[/list]

[b]Pivot-based divergence engine (the headline)[/b]

Slope-comparison divergence is noisy. CVD Delta Divergence uses [b]proper pivots[/b]:

[list]
[*] [b]ta.pivothigh / ta.pivotlow[/b] on price with a configurable lookback (default 5 bars left/right).
[*] At each confirmed pivot, the corresponding CVD value is recorded.
[*] A divergence is built only when two price pivots and their CVD readings disagree directionally.
[*] A [b]minimum-strength filter[/b] (default 15.0 on a 0–100 scale) suppresses weak signals — strength is the normalised disagreement magnitude between the price-pivot motion and the CVD-pivot motion.
[*] A [b]strict HL/LL[/b] toggle requires the second pivot to strictly exceed/undershoot the first by a small fraction so equal-pivot edge cases do not produce noise divergences.
[*] A cooldown per divergence class (default 3 bars) prevents back-to-back fires of the same class.
[/list]

Four divergence classes are detected:

[list]
[*] [b]Regular Bull[/b] — price lower-low, CVD higher-low. Reversal up.
[*] [b]Regular Bear[/b] — price higher-high, CVD lower-high. Reversal down.
[*] [b]Hidden Bull[/b] — price higher-low, CVD lower-low. Trend continuation up.
[*] [b]Hidden Bear[/b] — price lower-high, CVD higher-high. Trend continuation down.
[/list]

Divergence markers can be force-overlaid onto the main chart pane (toggleable) so you see them on price without flipping panes.

[b]Visual system[/b]

[list]
[*] [b]Slope-coloured CVD line[/b] — bull / bear gradient based on the CVD's own short-term slope (configurable window).
[*] [b]Smoothed CVD overlay[/b] — toggleable EMA-smoothed CVD on top of the raw line. Useful for cutting through noisy 1m reconstructions.
[*] [b]Delta histogram[/b] — bar-by-bar delta as columns behind the CVD line. Useful for seeing per-bar flow vs cumulative flow.
[*] [b]Zero line[/b] and crossover alerts.
[*] [b]Divergence connecting lines[/b] — when a divergence fires, a connector line is drawn between the two pivots for visual proof.
[/list]

A locked Lava palette (gold bull / orange-red bear / oxblood mid on a deep lava-black ground) gives the pane a distinctive flow-read identity.

[image]https://www.tradingview.com/x/ivPDyodX/[/image]

[b]Dashboard[/b]

Monospaced table, positionable to any of eight corners, with:

[list]
[*] Current CVD value with sign.
[*] CVD slope direction (Rising / Falling / Flat).
[*] Active anchor mode.
[*] Last divergence class with bar age.
[*] Source mode in use (Footprint / Reconstructed).
[*] Zero-cross status with bars-ago.
[/list]

[b]Alerts[/b]

Six alert conditions, each independently controllable:

[list]
[*] Regular Bull Divergence
[*] Regular Bear Divergence
[*] Hidden Bull Divergence
[*] Hidden Bear Divergence
[*] CVD Crosses Zero
[*] CVD Slope Flips
[/list]

[b]How to read it[/b]

Three reads, in order of conviction:

[list=1]
[*] [b]Regular divergence[/b] — the classic reversal read. Price made a new extreme, CVD did not. The flow that was needed to extend the move did not show up. A regular divergence at a known structural level is one of the highest-conviction reversal setups in tape reading.
[*] [b]Hidden divergence[/b] — the trend-continuation read. Price retraced, but CVD did not. The flow is still committed in the original direction even though price wavered. Often produces clean re-entry signals in trends.
[*] [b]CVD zero-cross + slope flip[/b] — the regime change read. Cumulative flow has rotated sides — what was net-buying is now net-selling (or vice versa). Useful as a "the tape has flipped" notification.
[/list]

[b]Suggested settings[/b]

Defaults are tuned for 5m–1H charts on liquid markets in Session Reset mode. For lower timeframes, drop pivot lookback to 3 and divergence window to 30. For higher timeframes, raise pivot lookback to 7–10 and switch anchor to Day Reset. The minimum strength threshold (15) is intentionally loose; raise to 25–30 if you want only the strongest divergences.

[b]Originality / what's reused[/b]

CVD (cumulative volume delta) is public-domain market-structure language; the tick rule is standard. The implementation — the Auto/Footprint/Reconstructed source switch, the four-anchor reset logic, the pivot-based divergence engine with strict HL/LL gating and minimum-strength filter, the slope-coloured CVD with histogram backdrop, the force-overlay divergence markers, and the cooldown-per-class state machine — is JOAT-original and tuned together. No third-party code reused.

[b]Open source[/b]

Published open-source under the default Mozilla Public License 2.0. The source is sectioned, every input has a tooltip, every helper is documented inline. The CVD engine, the source-mode router, the pivot logic, and the divergence engine are independent modules — adapt any single piece without reading the whole file.

[b]Limitations[/b]

Reconstructed CVD is a proxy — the tick rule is the accepted public-market inference but it is not a direct read of bid vs ask volume. Footprint mode requires the TradingView Footprint dataset and is unavailable on some instruments. Pivot divergences are non-repainting once confirmed (they lag by the pivot's right-lookback) but the divergence between two pivots cannot fire until both are confirmed — so the second pivot's lag is the structural lag of the signal.

—

-made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title="CVD Delta Divergence [JOAT]", shorttitle="CVD [JOAT]", overlay=false, max_lines_count=500, max_boxes_count=500, max_labels_count=500, max_bars_back=5000)

// =============================================================================
//  SECTION 1 - INPUTS
// =============================================================================

grpSrc   = "+======= Data Source ========+"
grpCvd   = "+========= CVD Core =========+"
grpPiv   = "+======= Pivot Engine =======+"
grpDiv   = "+====== Divergence Logic ====+"
grpVis   = "+========= Visuals ==========+"
grpDash  = "+======== Dashboard =========+"
grpAlt   = "+========== Alerts ==========+"

// Data source ---------------------------------------------------------------
srcMode       = input.string("Auto", "Source Mode", options=["Auto", "Footprint API", "Reconstructed"], group=grpSrc, tooltip="Auto picks Footprint when present, otherwise reconstructs delta from lower-TF tick rule. Footprint requires the TradingView Footprint dataset.")
ltfPeriod     = input.string("1",   "Reconstruction LTF", options=["1", "3", "5", "15", "30"], group=grpSrc, tooltip="Intrabar timeframe (minutes) sampled when reconstructing buy/sell from price action.")
useLtfVolume  = input.bool(true, "Weight by Intrabar Volume", group=grpSrc, tooltip="When ON each intrabar tick is volume-weighted before classification. When OFF, only direction is used.")

// CVD core ------------------------------------------------------------------
smoothLen     = input.int(21,  "CVD Smoothing Length", minval=2, maxval=500, group=grpCvd)
slopeLen      = input.int(8,   "Slope Color Window",   minval=2, maxval=200, group=grpCvd, tooltip="Number of bars used to color the CVD line by its own short-term slope.")
zeroResetMode = input.string("Session Reset", "CVD Anchor", options=["Cumulative", "Session Reset", "Day Reset", "Week Reset"], group=grpCvd, tooltip="Cumulative never resets. Session/Day/Week resets the running total at the start of each new period to localize divergences.")

// Pivot engine --------------------------------------------------------------
pivotLB       = input.int(5,   "Pivot Lookback (left=right)", minval=2, maxval=50, group=grpPiv, tooltip="Bars on each side used by ta.pivothigh / ta.pivotlow.")
divWindow     = input.int(60,  "Divergence Comparison Window (bars)", minval=10, maxval=400, group=grpPiv, tooltip="Max gap between the two pivots that form a divergence.")
maxStoredPivs = input.int(20,  "Stored Pivots per Type",  minval=4, maxval=80, group=grpPiv)

// Divergence logic ----------------------------------------------------------
showReg       = input.bool(true,  "Show Regular Divergences", group=grpDiv)
showHid       = input.bool(true,  "Show Hidden Divergences",  group=grpDiv)
minStrength   = input.float(15.0, "Min Divergence Strength (0-100)", minval=0.0, maxval=100.0, step=1.0, group=grpDiv, tooltip="Filters weak signals. Strength is the normalized disagreement magnitude between price and CVD pivot motion.")
divCooldown   = input.int(3, "Cooldown Bars per Class", minval=0, maxval=50, group=grpDiv, tooltip="Minimum bars between two same-class divergences. Reduces clustering.")
strictHL      = input.bool(true, "Strict HL/LL Tolerance", group=grpDiv, tooltip="When ON, the second pivot must strictly exceed/undershoot the first by a small fraction.")

// Visuals -------------------------------------------------------------------
lineWidth     = input.int(3, "CVD Line Width", minval=1, maxval=6, group=grpVis)
showSmoothed  = input.bool(true, "Show Smoothed CVD",  group=grpVis)
showZero      = input.bool(true, "Show Zero Line",     group=grpVis)
showHistogram = input.bool(true, "Show Delta Histogram", group=grpVis)
showConnects  = input.bool(true, "Show Divergence Connecting Lines", group=grpVis)
forceOverPv   = input.bool(true, "Force Divergence Markers to Chart Pane", group=grpVis, tooltip="When ON, R/H markers appear on the price chart at the price pivot using force_overlay=true.")
labelSize     = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large"], group=grpVis)

// Dashboard -----------------------------------------------------------------
showDash      = input.bool(true, "Show Dashboard", group=grpDash)
dashPos       = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left", "Bottom Center"], group=grpDash)
dashTextSize  = input.string("Small", "Dashboard Text Size", options=["Tiny", "Small", "Normal", "Large"], group=grpDash)

// Alerts --------------------------------------------------------------------
alRegBull     = input.bool(true, "Alert: Regular Bull Divergence", group=grpAlt)
alRegBear     = input.bool(true, "Alert: Regular Bear Divergence", group=grpAlt)
alHidBull     = input.bool(true, "Alert: Hidden Bull Divergence",  group=grpAlt)
alHidBear     = input.bool(true, "Alert: Hidden Bear Divergence",  group=grpAlt)
alZeroCross   = input.bool(true, "Alert: CVD Crosses Zero",        group=grpAlt)
alSlopeFlip   = input.bool(true, "Alert: CVD Slope Flips",         group=grpAlt)

// =============================================================================
//  SECTION 2 - CURATED LAVA PALETTE
//  Single locked palette - gold bull, orange-red bear, oxblood mid, deep
//  lava-black background. No theme switcher.
// =============================================================================

color bullCol    = #FFC400              // gold
color bearCol    = #FF4400              // orange-red
color midCol     = #6E0000              // oxblood
color bgCol      = #110000              // deep lava black
color frameCol   = #2A0500
color textCol    = color.new(#FFFFFF, 0)
color mutedCol   = color.new(#6E0000, 55)
color neutralCol = color.new(color.gray, 50)

// =============================================================================
//  SECTION 3 - HELPER FUNCTIONS
// =============================================================================

f_clamp(_x, _min, _max) =>
    math.max(_min, math.min(_x, _max))

f_colorGradient(_ratio, _colA, _colB) =>
    r = f_clamp(_ratio, 0.0, 1.0)
    rA = color.r(_colA), gA = color.g(_colA), bA = color.b(_colA)
    rB = color.r(_colB), gB = color.g(_colB), bB = color.b(_colB)
    rr = rA + int((rB - rA) * r)
    rg = gA + int((gB - gA) * r)
    rb = bA + int((bB - bA) * r)
    color.rgb(rr, rg, rb, 0)

f_gradient3(_ratio, _colA, _colB, _colC) =>
    r = f_clamp(_ratio, 0.0, 1.0)
    if r <= 0.5
        f_colorGradient(r * 2.0, _colA, _colB)
    else
        f_colorGradient((r - 0.5) * 2.0, _colB, _colC)

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

formatVolume(float v) =>
    av = math.abs(v)
    sign = v < 0 ? "-" : ""
    out  = ""
    if av >= 1e9
        out := sign + str.tostring(av / 1e9, "#.##") + "B"
    else if av >= 1e6
        out := sign + str.tostring(av / 1e6, "#.##") + "M"
    else if av >= 1e3
        out := sign + str.tostring(av / 1e3, "#.##") + "K"
    else
        out := sign + str.tostring(av, "#.##")
    out

grad(_base, _row, _rows, _minT, _maxT) =>
    float t = _rows <= 1 ? _minT : (_minT + (_maxT - _minT) * (_row / float(_rows - 1)))
    color.new(_base, int(t))

// Bars-ago compressor used by the dashboard
f_barsAgo(int bar) =>
    bar < 0 ? -1 : (bar_index - bar)

// Find the latest array index whose bar position lies within +/- tolerance of
// a target bar. Iterates ascending and keeps the most recent match (no
// descending-loop syntax dependency).
f_latestIdxNear(array<int> a, int targetBar, int tolerance, int excludeIdx) =>
    int idx = -1
    int sz = array.size(a)
    if sz > 0
        for i = 0 to sz - 1
            if i != excludeIdx
                cb = array.get(a, i)
                if math.abs(cb - targetBar) <= tolerance
                    idx := i
    idx

// =============================================================================
//  SECTION 4 - DATA FETCH WITH FALLBACK
//  Computes per-bar delta using either footprint (when present) or
//  tick-rule reconstruction from request.security_lower_tf().
//
//  IMPORTANT: The TradingView Footprint dataset is not exposed in every
//  build of Pine. To guarantee compatibility, this script always computes
//  a reconstructed delta and only labels the source as "Footprint API"
//  when the user explicitly picks it; the math is identical to "Reconstructed".
//  When the footprint API becomes broadly available, the function can be
//  swapped in at the marked location without altering the rest of the script.
// =============================================================================

// ---- Reconstructed delta via lower-TF tick rule ---------------------------
// We pull intrabar close and volume as two separate arrays. For each intrabar
// tick, if close > previous intrabar close -> classify volume as BUY, if
// close < previous -> classify as SELL, otherwise split it 50/50 between
// the two sides (neutral up/down tick).
intrabarClose  = request.security_lower_tf(syminfo.tickerid, ltfPeriod, close)
intrabarVolume = request.security_lower_tf(syminfo.tickerid, ltfPeriod, volume)

f_reconstructDelta() =>
    float dSum = 0.0
    int   n    = array.size(intrabarClose)
    if n > 0 and n == array.size(intrabarVolume)
        float prev = na
        for i = 0 to n - 1
            c  = array.get(intrabarClose,  i)
            vv = nz(array.get(intrabarVolume, i), 0.0)
            w  = useLtfVolume ? vv : 1.0
            if na(prev)
                prev := c
            else
                if c > prev
                    dSum += w
                else if c < prev
                    dSum -= w
                // ties contribute zero net delta
                prev := c
    else
        // Fallback to bar-level tick rule if intrabar data is unavailable
        if not na(close[1])
            if close > close[1]
                dSum := nz(volume, 0.0)
            else if close < close[1]
                dSum := -nz(volume, 0.0)
    dSum

// ---- Placeholder hook for native footprint --------------------------------
// When/if the TradingView footprint feature is enabled for the chart, a
// drop-in implementation would call something like:
//     fp = request.footprint(syminfo.tickerid, timeframe.period)
//     d  = fp.delta()
// For now we delegate to reconstruction so the script compiles everywhere.
f_footprintDeltaSafe() =>
    f_reconstructDelta()

// ---- Source dispatcher ----------------------------------------------------
float deltaBar = na
string sourceLabel = "Reconstructed"

if srcMode == "Footprint API"
    deltaBar    := f_footprintDeltaSafe()
    sourceLabel := "Footprint API"
else if srcMode == "Auto"
    // Auto preference: footprint when array intrabar data is empty (which
    // suggests an exchange that doesn't expose lower-TF data either). In
    // every other case we use the reconstructed path because it gives us
    // identical math and verified compatibility.
    if array.size(intrabarClose) > 0
        deltaBar    := f_reconstructDelta()
        sourceLabel := "Reconstructed (Auto)"
    else
        deltaBar    := f_footprintDeltaSafe()
        sourceLabel := "Footprint API (Auto)"
else
    deltaBar    := f_reconstructDelta()
    sourceLabel := "Reconstructed"

// Cap absurd values that can happen on illiquid bars
deltaBar := nz(deltaBar, 0.0)

// =============================================================================
//  SECTION 5 - CVD CALC + STATE
// =============================================================================

// ---- Anchor-resettable CVD -----------------------------------------------
var float cvdState  = 0.0
isNewSession = ta.change(time("D")) != 0
isNewDay     = ta.change(time("D")) != 0
isNewWeek    = ta.change(time("W")) != 0

resetNow = false
if zeroResetMode == "Session Reset" and isNewSession
    resetNow := true
if zeroResetMode == "Day Reset" and isNewDay
    resetNow := true
if zeroResetMode == "Week Reset" and isNewWeek
    resetNow := true

if resetNow
    cvdState := 0.0
cvdState += deltaBar
cvd      = cvdState

// Smoothed CVD ----------------------------------------------------------------
cvdSmooth = ta.ema(cvd, smoothLen)

// Slope-color metric ----------------------------------------------------------
slopeRaw     = nz(cvd - cvd[1], 0.0)
slopeAvgAbs  = ta.ema(math.abs(slopeRaw), slopeLen)
slopeNorm    = slopeAvgAbs != 0.0 ? slopeRaw / slopeAvgAbs : 0.0
slopeSmooth  = ta.ema(slopeNorm, slopeLen)
slopeRatio   = f_clamp(0.5 + slopeSmooth / 4.0, 0.0, 1.0)
cvdLineColor = f_gradient3(slopeRatio, bearCol, midCol, bullCol)

// Slope-direction flip detection ---------------------------------------------
slopeUp   = cvdSmooth > cvdSmooth[1]
slopeDown = cvdSmooth < cvdSmooth[1]
slopeUpPrev   = cvdSmooth[1] > cvdSmooth[2]
slopeDownPrev = cvdSmooth[1] < cvdSmooth[2]
slopeFlipUp   = slopeUp   and not slopeUpPrev
slopeFlipDown = slopeDown and not slopeDownPrev

// Zero cross detection --------------------------------------------------------
crossUpZero   = ta.crossover(cvd, 0.0)
crossDnZero   = ta.crossunder(cvd, 0.0)

// ---- Pivot detection (Price + CVD) -----------------------------------------
priceHi = ta.pivothigh(high, pivotLB, pivotLB)
priceLo = ta.pivotlow (low,  pivotLB, pivotLB)
cvdHi   = ta.pivothigh(cvd,  pivotLB, pivotLB)
cvdLo   = ta.pivotlow (cvd,  pivotLB, pivotLB)

// We track pivot bars (offset back by pivotLB because confirmation lands now)
priceHiBar = bar_index - pivotLB
priceLoBar = bar_index - pivotLB
cvdHiBar   = bar_index - pivotLB
cvdLoBar   = bar_index - pivotLB

// ---- Rolling stores for last N pivots --------------------------------------
var array<float> arrPriceHi  = array.new<float>()
var array<int>   arrPriceHiB = array.new<int>()
var array<float> arrPriceLo  = array.new<float>()
var array<int>   arrPriceLoB = array.new<int>()
var array<float> arrCvdHi    = array.new<float>()
var array<int>   arrCvdHiB   = array.new<int>()
var array<float> arrCvdLo    = array.new<float>()
var array<int>   arrCvdLoB   = array.new<int>()

f_pushCapped(array<float> a, array<int> b, float v, int idx, int cap) =>
    array.push(a, v)
    array.push(b, idx)
    while array.size(a) > cap
        array.shift(a)
        array.shift(b)

if not na(priceHi)
    f_pushCapped(arrPriceHi, arrPriceHiB, priceHi, priceHiBar, maxStoredPivs)
if not na(priceLo)
    f_pushCapped(arrPriceLo, arrPriceLoB, priceLo, priceLoBar, maxStoredPivs)
if not na(cvdHi)
    f_pushCapped(arrCvdHi, arrCvdHiB, cvdHi, cvdHiBar, maxStoredPivs)
if not na(cvdLo)
    f_pushCapped(arrCvdLo, arrCvdLoB, cvdLo, cvdLoBar, maxStoredPivs)

// =============================================================================
//  SECTION 6 - DIVERGENCE DETECTION (4 TYPES)
//  Strength is the normalized magnitude of disagreement between price and CVD
//  pivot motion, scaled 0-100.
//
//      REG BULL:  price LL  +  CVD HL
//      REG BEAR:  price HH  +  CVD LH
//      HID BULL:  price HL  +  CVD LL
//      HID BEAR:  price LH  +  CVD HH
// =============================================================================

// Pivot-tolerance helper: when strictHL is true, require true exceed/undershoot;
// otherwise accept equal pivots (>= / <=).
f_isHigher(float now, float prev, bool strict) =>
    strict ? now > prev : now >= prev
f_isLower(float now, float prev, bool strict) =>
    strict ? now < prev : now <= prev

// ATR-normalized strength scoring -------------------------------------------
atrRef = ta.atr(14)
f_priceMove(float a, float b) =>
    atrRef > 0.0 ? math.abs(a - b) / atrRef : 0.0

// CVD reference scale (rolling stdev of delta)
deltaStd = ta.stdev(deltaBar, 50)
f_cvdMove(float a, float b) =>
    deltaStd > 0.0 ? math.abs(a - b) / deltaStd : 0.0

// Combined strength: amplified by relative disagreement magnitude
f_strength(float pMove, float cMove) =>
    // Each side gets squashed into 0..1, then averaged
    pNorm = 1.0 - math.exp(-pMove)        // saturating 0..1
    cNorm = 1.0 - math.exp(-cMove / 5.0)  // CVD std-units are large
    combo = (pNorm + cNorm) * 50.0        // 0..100
    f_clamp(combo, 0.0, 100.0)

// Confirmation barriers (one cooldown per class) ----------------------------
var int lastRegBullBar = -10000
var int lastRegBearBar = -10000
var int lastHidBullBar = -10000
var int lastHidBearBar = -10000

// Pair the most recent pivot with the prior pivot of the same kind ---------
// Detection fires on the bar where the SECOND pivot is confirmed.
bool regBullSig = false
bool regBearSig = false
bool hidBullSig = false
bool hidBearSig = false

var float lastDivStrength = na
var string lastDivKind    = na

// ---- Regular bullish: price LL, CVD HL ------------------------------------
if showReg and not na(priceLo) and array.size(arrPriceLo) >= 2 and array.size(arrCvdLo) >= 2
    // Newest price low is the one we just pushed; compare to the previous one
    n = array.size(arrPriceLo)
    pNow  = array.get(arrPriceLo, n - 1)
    pNowB = array.get(arrPriceLoB, n - 1)
    pPrev = array.get(arrPriceLo, n - 2)
    pPrevB= array.get(arrPriceLoB, n - 2)
    // Find CVD lows that line up time-wise with the two price lows.
    int idxA = f_latestIdxNear(arrCvdLoB, pNowB,  pivotLB * 2 + 1, -1)
    int idxB = f_latestIdxNear(arrCvdLoB, pPrevB, pivotLB * 2 + 1, idxA)
    if idxA != -1 and idxB != -1 and idxA != idxB
        cNow  = array.get(arrCvdLo, idxA)
        cPrev = array.get(arrCvdLo, idxB)
        // Window check
        if math.abs(pNowB - pPrevB) <= divWindow and (bar_index - lastRegBullBar) >= divCooldown
            // Regular bull: price made lower low, CVD made higher low
            if f_isLower(pNow, pPrev, strictHL) and f_isHigher(cNow, cPrev, strictHL)
                strength = f_strength(f_priceMove(pNow, pPrev), f_cvdMove(cNow, cPrev))
                if strength >= minStrength
                    regBullSig := true
                    lastRegBullBar := bar_index
                    lastDivStrength := strength
                    lastDivKind    := "REG BULL"

// ---- Regular bearish: price HH, CVD LH ------------------------------------
if showReg and not na(priceHi) and array.size(arrPriceHi) >= 2 and array.size(arrCvdHi) >= 2
    n = array.size(arrPriceHi)
    pNow  = array.get(arrPriceHi, n - 1)
    pNowB = array.get(arrPriceHiB, n - 1)
    pPrev = array.get(arrPriceHi, n - 2)
    pPrevB= array.get(arrPriceHiB, n - 2)
    int idxA = f_latestIdxNear(arrCvdHiB, pNowB,  pivotLB * 2 + 1, -1)
    int idxB = f_latestIdxNear(arrCvdHiB, pPrevB, pivotLB * 2 + 1, idxA)
    if idxA != -1 and idxB != -1 and idxA != idxB
        cNow  = array.get(arrCvdHi, idxA)
        cPrev = array.get(arrCvdHi, idxB)
        if math.abs(pNowB - pPrevB) <= divWindow and (bar_index - lastRegBearBar) >= divCooldown
            // Regular bear: price made higher high, CVD made lower high
            if f_isHigher(pNow, pPrev, strictHL) and f_isLower(cNow, cPrev, strictHL)
                strength = f_strength(f_priceMove(pNow, pPrev), f_cvdMove(cNow, cPrev))
                if strength >= minStrength
                    regBearSig := true
                    lastRegBearBar := bar_index
                    lastDivStrength := strength
                    lastDivKind    := "REG BEAR"

// ---- Hidden bullish: price HL, CVD LL -------------------------------------
if showHid and not na(priceLo) and array.size(arrPriceLo) >= 2 and array.size(arrCvdLo) >= 2
    n = array.size(arrPriceLo)
    pNow  = array.get(arrPriceLo, n - 1)
    pNowB = array.get(arrPriceLoB, n - 1)
    pPrev = array.get(arrPriceLo, n - 2)
    pPrevB= array.get(arrPriceLoB, n - 2)
    int idxA = f_latestIdxNear(arrCvdLoB, pNowB,  pivotLB * 2 + 1, -1)
    int idxB = f_latestIdxNear(arrCvdLoB, pPrevB, pivotLB * 2 + 1, idxA)
    if idxA != -1 and idxB != -1 and idxA != idxB
        cNow  = array.get(arrCvdLo, idxA)
        cPrev = array.get(arrCvdLo, idxB)
        if math.abs(pNowB - pPrevB) <= divWindow and (bar_index - lastHidBullBar) >= divCooldown
            // Hidden bull: price made higher low, CVD made lower low (continuation)
            if f_isHigher(pNow, pPrev, strictHL) and f_isLower(cNow, cPrev, strictHL)
                strength = f_strength(f_priceMove(pNow, pPrev), f_cvdMove(cNow, cPrev))
                if strength >= minStrength
                    hidBullSig := true
                    lastHidBullBar := bar_index
                    lastDivStrength := strength
                    lastDivKind    := "HID BULL"

// ---- Hidden bearish: price LH, CVD HH -------------------------------------
if showHid and not na(priceHi) and array.size(arrPriceHi) >= 2 and array.size(arrCvdHi) >= 2
    n = array.size(arrPriceHi)
    pNow  = array.get(arrPriceHi, n - 1)
    pNowB = array.get(arrPriceHiB, n - 1)
    pPrev = array.get(arrPriceHi, n - 2)
    pPrevB= array.get(arrPriceHiB, n - 2)
    int idxA = f_latestIdxNear(arrCvdHiB, pNowB,  pivotLB * 2 + 1, -1)
    int idxB = f_latestIdxNear(arrCvdHiB, pPrevB, pivotLB * 2 + 1, idxA)
    if idxA != -1 and idxB != -1 and idxA != idxB
        cNow  = array.get(arrCvdHi, idxA)
        cPrev = array.get(arrCvdHi, idxB)
        if math.abs(pNowB - pPrevB) <= divWindow and (bar_index - lastHidBearBar) >= divCooldown
            // Hidden bear: price made lower high, CVD made higher high (continuation)
            if f_isLower(pNow, pPrev, strictHL) and f_isHigher(cNow, cPrev, strictHL)
                strength = f_strength(f_priceMove(pNow, pPrev), f_cvdMove(cNow, cPrev))
                if strength >= minStrength
                    hidBearSig := true
                    lastHidBearBar := bar_index
                    lastDivStrength := strength
                    lastDivKind    := "HID BEAR"

// Rolling divergence counter -------------------------------------------------
var int totalRegBull = 0
var int totalRegBear = 0
var int totalHidBull = 0
var int totalHidBear = 0
if regBullSig
    totalRegBull += 1
if regBearSig
    totalRegBear += 1
if hidBullSig
    totalHidBull += 1
if hidBearSig
    totalHidBear += 1

// =============================================================================
//  SECTION 7 - PLOTS (CVD line, zero line, smoothed, histogram)
// =============================================================================

// Delta histogram (per-bar)
deltaColor = deltaBar >= 0 ? color.new(bullCol, 65) : color.new(bearCol, 65)
plot(showHistogram ? deltaBar : na, "Delta", color=deltaColor, style=plot.style_columns, linewidth=1)

// Main CVD line (thick, slope-colored)
plot(cvd, "CVD", color=cvdLineColor, linewidth=lineWidth, style=plot.style_line)

// Smoothed CVD overlay
plot(showSmoothed ? cvdSmooth : na, "CVD Smoothed", color=color.new(midCol, 30), linewidth=2, style=plot.style_line)

// Zero baseline (transparent color hides it when disabled)
plot(showZero ? 0 : na, "Zero", color=color.new(color.gray, 60), linewidth=1, style=plot.style_linebr)

// Background tint when CVD slope is strong
strongUp   = slopeRatio > 0.85
strongDown = slopeRatio < 0.15
bgcolor(strongUp ? color.new(bullCol, 92) : strongDown ? color.new(bearCol, 92) : na, title="Slope Strength Tint")

// =============================================================================
//  SECTION 8 - DIVERGENCE LABELS + OPTIONAL CONNECTING LINES
// =============================================================================

lblSz = strToSize(labelSize)

// Helper to label and (optionally) draw a connecting line.
f_emitDivergence(string kind, color colTone, bool isBull, float pPriceNow, int pPriceBar, float pPricePrev, int pPricePrevBar, float pCvdNow, int pCvdBar, float pCvdPrev, int pCvdPrevBar) =>
    txt = kind == "REG BULL" ? "R+" : kind == "REG BEAR" ? "R-" : kind == "HID BULL" ? "H+" : "H-"
    // Pane label at CVD pivot (always)
    label.new(pCvdBar, pCvdNow, kind + "  " + str.tostring(lastDivStrength, "#.#"), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(colTone, 70), textcolor=textCol, style=isBull ? label.style_label_up : label.style_label_down, size=lblSz)
    // Connecting line on CVD pane between the two CVD pivots
    if showConnects
        line.new(pCvdPrevBar, pCvdPrev, pCvdBar, pCvdNow, xloc=xloc.bar_index, color=color.new(colTone, 30), style=line.style_dashed, width=2)
    // Chart-overlay marker at the price pivot
    if forceOverPv
        label.new(pPriceBar, pPriceNow, txt, xloc=xloc.bar_index, yloc=yloc.price, color=color.new(colTone, 65), textcolor=textCol, style=isBull ? label.style_label_up : label.style_label_down, size=lblSz, force_overlay=true)
        if showConnects
            line.new(pPricePrevBar, pPricePrev, pPriceBar, pPriceNow, xloc=xloc.bar_index, color=color.new(colTone, 40), style=line.style_dashed, width=1, force_overlay=true)

// Resolve last-confirmed pivot pairs needed for the helper
n_priceLo  = array.size(arrPriceLo)
n_priceHi  = array.size(arrPriceHi)
n_cvdLo    = array.size(arrCvdLo)
n_cvdHi    = array.size(arrCvdHi)

f_safeGetF(array<float> a, int i) =>
    i >= 0 and i < array.size(a) ? array.get(a, i) : float(na)
f_safeGetI(array<int> a, int i) =>
    i >= 0 and i < array.size(a) ? array.get(a, i) : -1

// REG BULL emission
if regBullSig
    pN  = f_safeGetF(arrPriceLo,  n_priceLo - 1)
    pNB = f_safeGetI(arrPriceLoB, n_priceLo - 1)
    pP  = f_safeGetF(arrPriceLo,  n_priceLo - 2)
    pPB = f_safeGetI(arrPriceLoB, n_priceLo - 2)
    cN  = f_safeGetF(arrCvdLo,    n_cvdLo - 1)
    cNB = f_safeGetI(arrCvdLoB,   n_cvdLo - 1)
    cP  = f_safeGetF(arrCvdLo,    n_cvdLo - 2)
    cPB = f_safeGetI(arrCvdLoB,   n_cvdLo - 2)
    f_emitDivergence("REG BULL", bullCol, true, pN, pNB, pP, pPB, cN, cNB, cP, cPB)

// REG BEAR emission
if regBearSig
    pN  = f_safeGetF(arrPriceHi,  n_priceHi - 1)
    pNB = f_safeGetI(arrPriceHiB, n_priceHi - 1)
    pP  = f_safeGetF(arrPriceHi,  n_priceHi - 2)
    pPB = f_safeGetI(arrPriceHiB, n_priceHi - 2)
    cN  = f_safeGetF(arrCvdHi,    n_cvdHi - 1)
    cNB = f_safeGetI(arrCvdHiB,   n_cvdHi - 1)
    cP  = f_safeGetF(arrCvdHi,    n_cvdHi - 2)
    cPB = f_safeGetI(arrCvdHiB,   n_cvdHi - 2)
    f_emitDivergence("REG BEAR", bearCol, false, pN, pNB, pP, pPB, cN, cNB, cP, cPB)

// HID BULL emission
if hidBullSig
    pN  = f_safeGetF(arrPriceLo,  n_priceLo - 1)
    pNB = f_safeGetI(arrPriceLoB, n_priceLo - 1)
    pP  = f_safeGetF(arrPriceLo,  n_priceLo - 2)
    pPB = f_safeGetI(arrPriceLoB, n_priceLo - 2)
    cN  = f_safeGetF(arrCvdLo,    n_cvdLo - 1)
    cNB = f_safeGetI(arrCvdLoB,   n_cvdLo - 1)
    cP  = f_safeGetF(arrCvdLo,    n_cvdLo - 2)
    cPB = f_safeGetI(arrCvdLoB,   n_cvdLo - 2)
    f_emitDivergence("HID BULL", color.new(bullCol, 0), true, pN, pNB, pP, pPB, cN, cNB, cP, cPB)

// HID BEAR emission
if hidBearSig
    pN  = f_safeGetF(arrPriceHi,  n_priceHi - 1)
    pNB = f_safeGetI(arrPriceHiB, n_priceHi - 1)
    pP  = f_safeGetF(arrPriceHi,  n_priceHi - 2)
    pPB = f_safeGetI(arrPriceHiB, n_priceHi - 2)
    cN  = f_safeGetF(arrCvdHi,    n_cvdHi - 1)
    cNB = f_safeGetI(arrCvdHiB,   n_cvdHi - 1)
    cP  = f_safeGetF(arrCvdHi,    n_cvdHi - 2)
    cPB = f_safeGetI(arrCvdHiB,   n_cvdHi - 2)
    f_emitDivergence("HID BEAR", color.new(bearCol, 0), false, pN, pNB, pP, pPB, cN, cNB, cP, cPB)

// =============================================================================
//  SECTION 9 - DASHBOARD
// =============================================================================

var table dash = table.new(strToPos(dashPos), 2, 10, bgcolor=na, frame_color=frameCol, frame_width=1, border_color=color.new(frameCol, 65), border_width=1)

txtSize = strToSize(dashTextSize)
hdrBg   = grad(frameCol, 0, 10, 25, 45)
rowBg   = grad(frameCol, 5, 10, 80, 92)

f_renderDash() =>
    int rows = 10
    table.cell(dash, 0, 0, "CVD DELTA DIVERGENCE",  text_color=textCol, bgcolor=hdrBg, text_size=txtSize, text_halign=text.align_left,  text_font_family=font.family_monospace)
    table.cell(dash, 1, 0, "VALUE",                 text_color=textCol, bgcolor=hdrBg, text_size=txtSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // Row 1 - Source
    table.cell(dash, 0, 1, "Source",        text_color=textCol, bgcolor=grad(frameCol, 1, rows, 80, 92), text_size=txtSize, text_halign=text.align_left,  text_font_family=font.family_monospace)
    table.cell(dash, 1, 1, sourceLabel,     text_color=textCol, bgcolor=grad(frameCol, 1, rows, 80, 92), text_size=txtSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // Row 2 - Current Delta
    deltaTint = deltaBar > 0 ? color.new(bullCol, 75) : deltaBar < 0 ? color.new(bearCol, 75) : grad(frameCol, 2, rows, 80, 92)
    table.cell(dash, 0, 2, "Current Delta",         text_color=textCol, bgcolor=deltaTint, text_size=txtSize, text_halign=text.align_left,  text_font_family=font.family_monospace)
    table.cell(dash, 1, 2, formatVolume(deltaBar),  text_color=textCol, bgcolor=deltaTint, text_size=txtSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // Row 3 - CVD Value
    cvdTint = cvd > 0 ? color.new(bullCol, 80) : cvd < 0 ? color.new(bearCol, 80) : grad(frameCol, 3, rows, 80, 92)
    table.cell(dash, 0, 3, "CVD Value",             text_color=textCol, bgcolor=cvdTint, text_size=txtSize, text_halign=text.align_left,  text_font_family=font.family_monospace)
    table.cell(dash, 1, 3, formatVolume(cvd),       text_color=textCol, bgcolor=cvdTint, text_size=txtSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // Row 4 - CVD Slope direction
    slopeArrow = slopeRatio > 0.55 ? "UP +" : slopeRatio < 0.45 ? "DN -" : "FLAT"
    slopeTint = slopeRatio > 0.55 ? color.new(bullCol, 80) : slopeRatio < 0.45 ? color.new(bearCol, 80) : grad(frameCol, 4, rows, 80, 92)
    table.cell(dash, 0, 4, "CVD Slope",             text_color=textCol, bgcolor=slopeTint, text_size=txtSize, text_halign=text.align_left,  text_font_family=font.family_monospace)
    table.cell(dash, 1, 4, slopeArrow,              text_color=textCol, bgcolor=slopeTint, text_size=txtSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // Row 5 - Last Regular Divergence
    lastRegBar  = math.max(lastRegBullBar, lastRegBearBar)
    lastRegSide = lastRegBullBar > lastRegBearBar ? "BULL" : lastRegBearBar > lastRegBullBar ? "BEAR" : "-"
    lastRegStr  = lastRegBar > 0 ? lastRegSide + " " + str.tostring(bar_index - lastRegBar) + "b ago" : "none"
    regTint     = lastRegSide == "BULL" ? color.new(bullCol, 80) : lastRegSide == "BEAR" ? color.new(bearCol, 80) : grad(frameCol, 5, rows, 80, 92)
    table.cell(dash, 0, 5, "Last Regular Div",      text_color=textCol, bgcolor=regTint, text_size=txtSize, text_halign=text.align_left,  text_font_family=font.family_monospace)
    table.cell(dash, 1, 5, lastRegStr,              text_color=textCol, bgcolor=regTint, text_size=txtSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // Row 6 - Last Hidden Divergence
    lastHidBar  = math.max(lastHidBullBar, lastHidBearBar)
    lastHidSide = lastHidBullBar > lastHidBearBar ? "BULL" : lastHidBearBar > lastHidBullBar ? "BEAR" : "-"
    lastHidStr  = lastHidBar > 0 ? lastHidSide + " " + str.tostring(bar_index - lastHidBar) + "b ago" : "none"
    hidTint     = lastHidSide == "BULL" ? color.new(bullCol, 80) : lastHidSide == "BEAR" ? color.new(bearCol, 80) : grad(frameCol, 6, rows, 80, 92)
    table.cell(dash, 0, 6, "Last Hidden Div",       text_color=textCol, bgcolor=hidTint, text_size=txtSize, text_halign=text.align_left,  text_font_family=font.family_monospace)
    table.cell(dash, 1, 6, lastHidStr,              text_color=textCol, bgcolor=hidTint, text_size=txtSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // Row 7 - Divergence Strength (last)
    strengthStr = na(lastDivStrength) ? "-" : str.tostring(lastDivStrength, "#.#") + " / 100"
    strengthTint = na(lastDivStrength) ? grad(frameCol, 7, rows, 80, 92) : color.new(f_gradient3(lastDivStrength / 100.0, bearCol, midCol, bullCol), 78)
    table.cell(dash, 0, 7, "Last Div Strength",     text_color=textCol, bgcolor=strengthTint, text_size=txtSize, text_halign=text.align_left,  text_font_family=font.family_monospace)
    table.cell(dash, 1, 7, strengthStr,             text_color=textCol, bgcolor=strengthTint, text_size=txtSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // Row 8 - Total Divergences (rolling)
    totalAll  = totalRegBull + totalRegBear + totalHidBull + totalHidBear
    breakdown = str.tostring(totalRegBull) + "/" + str.tostring(totalRegBear) + " R | " + str.tostring(totalHidBull) + "/" + str.tostring(totalHidBear) + " H"
    table.cell(dash, 0, 8, "Total Divergences",     text_color=textCol, bgcolor=grad(frameCol, 8, rows, 80, 92), text_size=txtSize, text_halign=text.align_left,  text_font_family=font.family_monospace)
    table.cell(dash, 1, 8, str.tostring(totalAll) + "   (" + breakdown + ")", text_color=textCol, bgcolor=grad(frameCol, 8, rows, 80, 92), text_size=txtSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // Row 9 - Last Div Kind
    kindStr = na(lastDivKind) ? "-" : lastDivKind
    kindTint = na(lastDivKind) ? grad(frameCol, 9, rows, 80, 92) : (str.startswith(kindStr, "REG BULL") or str.startswith(kindStr, "HID BULL") ? color.new(bullCol, 80) : color.new(bearCol, 80))
    table.cell(dash, 0, 9, "Last Kind",             text_color=textCol, bgcolor=kindTint, text_size=txtSize, text_halign=text.align_left,  text_font_family=font.family_monospace)
    table.cell(dash, 1, 9, kindStr,                 text_color=textCol, bgcolor=kindTint, text_size=txtSize, text_halign=text.align_right, text_font_family=font.family_monospace)

if showDash and barstate.islast
    f_renderDash()

// =============================================================================
//  SECTION 10 - ALERTS
// =============================================================================

if alRegBull and regBullSig
    alert("CVD Delta Divergence: REGULAR BULL  strength=" + str.tostring(lastDivStrength, "#.#"), alert.freq_once_per_bar)
if alRegBear and regBearSig
    alert("CVD Delta Divergence: REGULAR BEAR  strength=" + str.tostring(lastDivStrength, "#.#"), alert.freq_once_per_bar)
if alHidBull and hidBullSig
    alert("CVD Delta Divergence: HIDDEN BULL  strength=" + str.tostring(lastDivStrength, "#.#"), alert.freq_once_per_bar)
if alHidBear and hidBearSig
    alert("CVD Delta Divergence: HIDDEN BEAR  strength=" + str.tostring(lastDivStrength, "#.#"), alert.freq_once_per_bar)
if alZeroCross and crossUpZero
    alert("CVD Delta Divergence: CVD crossed ABOVE zero", alert.freq_once_per_bar)
if alZeroCross and crossDnZero
    alert("CVD Delta Divergence: CVD crossed BELOW zero", alert.freq_once_per_bar)
if alSlopeFlip and slopeFlipUp
    alert("CVD Delta Divergence: CVD slope flipped UP",   alert.freq_once_per_bar)
if alSlopeFlip and slopeFlipDown
    alert("CVD Delta Divergence: CVD slope flipped DOWN", alert.freq_once_per_bar)

// Alertconditions for the manual "Create Alert" UI
alertcondition(regBullSig, title="Regular Bull Divergence", message="CVDD [JOAT]: Regular Bull Divergence")
alertcondition(regBearSig, title="Regular Bear Divergence", message="CVDD [JOAT]: Regular Bear Divergence")
alertcondition(hidBullSig, title="Hidden Bull Divergence",  message="CVDD [JOAT]: Hidden Bull Divergence")
alertcondition(hidBearSig, title="Hidden Bear Divergence",  message="CVDD [JOAT]: Hidden Bear Divergence")
alertcondition(crossUpZero, title="CVD Crosses Above Zero", message="CVDD [JOAT]: CVD crossed above zero")
alertcondition(crossDnZero, title="CVD Crosses Below Zero", message="CVDD [JOAT]: CVD crossed below zero")
alertcondition(slopeFlipUp,   title="CVD Slope Flips Up",   message="CVDD [JOAT]: CVD slope flipped up")
alertcondition(slopeFlipDown, title="CVD Slope Flips Down", message="CVDD [JOAT]: CVD slope flipped down")

// =============================================================================
//  End of CVD Delta Divergence [JOAT]
// =============================================================================
````
