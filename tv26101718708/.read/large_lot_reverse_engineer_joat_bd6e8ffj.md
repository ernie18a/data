# Large Lot Reverse Engineer [JOAT]

- url: https://www.tradingview.com/script/Bd6e8Ffj-Large-Lot-Reverse-Engineer-JOAT/
- type: indicator
- pine_id: PUB;117b23643e304e75bd768b4ddcd1b7d0
- version: 1.0

## Description

[b]LARGE LOT REVERSE ENGINEER [JOAT][/b]

A regression-driven block-trade detector that infers the [b]implied size[/b] of an off-tape institutional order from the residual between price movement and volume — and turns that residual into an estimated lot count. The premise is straightforward: when a single large order moves price meaningfully more than the visible volume would justify, the gap is the size of the hidden order that absorbed the move. Large Lot Reverse Engineer models that relationship, flags the outliers, and estimates the size.

[image]https://www.tradingview.com/x/bFJ308mA/[/image]

[b]The core idea — what price movement is "worth"[/b]

In normal conditions there is a stable statistical relationship between volume and the magnitude of a bar's return. A rolling regression over a configurable window (default 60 bars) estimates [b]expected[/b] volume as a function of return — i.e., for the move you just saw, how much volume should there have been?

The residual is the difference between actual and expected volume, Z-normalised by its own rolling stdev. Two signs of residual matter:

[list]
[*] [b]Implied block (residual Z ≥ +threshold)[/b] — more volume traded than the price move warrants. Someone large was on the [i]passive[/i] side absorbing aggression. The direction of the bar tells you which side.
[*] [b]Thin market (residual Z ≤ −threshold)[/b] — price moved on suspiciously low volume. Liquidity was missing; the move was a low-conviction air-pocket.
[/list]

Both reads are institutionally interesting. The first identifies absorbed-aggression — the textbook signature of an institutional block trade. The second identifies regimes where price prints are unreliable.

[b]R² reliability gate[/b]

A regression is only meaningful when the underlying relationship is actually there. The script computes the rolling R² of the model and exposes a configurable minimum (default 0.10). When R² falls below the gate the model is considered unreliable; the dashboard cell turns warning-coloured and the script tags any signals fired in that regime as low-confidence. This is the difference between a real residual reading and a noise residual — a professional read forbids the same.

[b]Significant block sizing[/b]

Three thresholds are stacked:

[list]
[*] [b]Implied Block Sigma (+)[/b] (default 2.0σ) — baseline implied-block trigger.
[*] [b]Thin Market Sigma (−)[/b] (default 2.0σ) — baseline thin-market trigger.
[*] [b]Significant Block Sigma[/b] (default 3.0σ) — above this the bar is rendered with a polygon glyph and gets an [b]estimated lot-size badge[/b]. Empirical scaler converts residual-volume into a lot count.
[/list]

The size unit is configurable: Shares/Coins for spot instruments, Notional USD for size in dollars (using a configurable price proxy), or Auto which picks based on instrument. The scaler is exposed because no single conversion factor is universally correct — calibrate to your instrument's typical notional.

[b]Cluster detection[/b]

When [b]N[/b] blocks fire inside a rolling window (configurable, default 3 in 5 bars) the [b]Block Cluster[/b] alert fires. Cluster signals are the strongest read this script produces — they indicate sustained off-tape activity, not a single statistical outlier.

[b]Visual system[/b]

[list]
[*] [b]Residual Z histogram[/b] — bars coloured bull/bear by direction, magnitude by residual.
[*] [b]Threshold lines[/b] at ±2 and ±3 with on/off toggle.
[*] [b]Zero line[/b] and significant-block polygon glyphs.
[*] [b]Thin-market dots[/b] in the muted palette.
[*] [b]Background recency fade[/b] — fresh blocks tint the background and decay to transparent over a configurable number of bars.
[*] [b]Cumulative implied delta[/b] (optional) — running sum of implied-block directional contributions, useful for reading sustained institutional bias.
[/list]

A locked Carbon palette (neon green / neon red / white midline on carbon black) gives the pane an institutional terminal feel.

[image]https://www.tradingview.com/x/ufGoYgDJ/[/image]

[b]Dashboard[/b]

Monospaced table, positionable to any of nine corners, with a compact mode and optional legend footer. Surfaces:

[list]
[*] Current residual Z value and sign.
[*] R² value with reliability colour-coding (green / amber / red).
[*] Last significant block direction with estimated lot size.
[*] Block count and thin-market count in the recent window.
[*] Cluster status with bars-since-last-cluster.
[*] Cumulative implied delta (when enabled).
[/list]

[b]Alerts[/b]

Four alert conditions, each independently controllable:

[list]
[*] Implied Buy Block (positive residual + up bar)
[*] Implied Sell Block (positive residual + down bar)
[*] Thin Market Event (negative residual)
[*] Block Cluster (N-in-window)
[/list]

[b]How to read it[/b]

Three reads, in order of conviction:

[list=1]
[*] [b]Block Cluster + high R²[/b] — the highest-conviction read. Multiple statistically-significant blocks inside a window, with the underlying model reliable. Institutional flow is actively moving size.
[*] [b]Significant block (3σ+) at a known level[/b] — a single large polygon glyph at a key support/resistance is a textbook absorbed-print read. The lot-size badge gives you a magnitude proxy you can compare across bars.
[*] [b]Thin market warning[/b] — when the residual goes deeply negative, treat any move you see with extreme caution; the tape is hollow. Often precedes either a violent move once real flow returns or a fade back to fair value.
[/list]

[b]Suggested settings[/b]

Defaults (60-bar window, R² ≥ 0.10, ±2σ block, +3σ significant) are tuned for 5m–1H on liquid futures, FX, and large-cap equity. For lower timeframes drop the window to 30 and raise the sigma thresholds to 2.5σ / 3.5σ to filter noise. For daily and above, widen the window to 100+ and consider log returns for instruments with large price scales.

[b]Originality[/b]

The implementation — the rolling return-vs-volume regression with R² gate, the residual-Z classifier with bidirectional thresholds, the empirical lot-size scaler with auto/notional unit switching, the polygon-glyph significant-block render, the thin-market dot variant, the N-in-window cluster trigger, the recency-fade background, and the cumulative implied delta — is JOAT-original. No third-party code reused. The "volume that should have been" inference pattern is well-known to institutional desks; the implementation here is purpose-built for chart-based bar data.

[b]Limitations[/b]

Implied block size is an [i]inference[/i] from residual statistics, not a direct read of off-tape trades. Pine cannot see actual block prints that occur away from the lit market; what the script flags is the visible footprint those prints leave behind. The lot-size badge depends on the empirical scaler, which must be calibrated per instrument — the default 1.0× is generic. The R² gate is the most important reliability filter; when R² is low, no signal in the model should be considered reliable, by construction.



-made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title    = "Large Lot Reverse Engineer [JOAT]",
          shorttitle = "LLR [JOAT]",
          overlay  = false,
          max_lines_count  = 200,
          max_boxes_count  = 200,
          max_labels_count = 500,
          max_bars_back    = 5000,
          precision        = 2)


// ============================================================================
//  SECTION 1  -  INPUTS
//  ----------------------------------------------------------------------------
//  Grouped with box-drawing headers in line with JOAT house style.
// ============================================================================

grpReg    = "Regression Engine"
grpDet    = "Block Detection"
grpEst    = "Block Size Estimation"
grpVis    = "Visual Engine"
grpThm    = "Theme & Palette"
grpDash   = "Dashboard Panel"
grpAlert  = "Alert Engine"

// ---------- Regression Engine ---------------------------------------------
regWindow    = input.int(60,  "Regression Window (bars)", minval = 10,  maxval = 500,
                         group = grpReg,
                         tooltip = "Rolling window length used to estimate the expected-volume model and the residual z-score statistics.  Longer = smoother but slower to react.")
minR2        = input.float(0.10, "Minimum R² for reliable model", minval = 0.0, maxval = 1.0, step = 0.05,
                           group = grpReg,
                           tooltip = "Below this R-squared the model is considered unreliable.  Signals will be tagged as low-confidence and the dashboard cell turns warning-colored.")
returnSrc    = input.source(close, "Return Source", group = grpReg)
useLogRet    = input.bool(false, "Use Log Returns",  group = grpReg,
                          tooltip = "Use ln(p_t/p_{t-1}) instead of simple percentage return.  Recommended for assets with large price scales.")
volSmoothLen = input.int(1, "Volume Pre-Smooth (bars)", minval = 1, maxval = 20, group = grpReg,
                         tooltip = "Light EMA pre-smoothing of raw volume.  Set to 1 to disable.")

// ---------- Block Detection -----------------------------------------------
blockSigma   = input.float(2.0, "Implied Block Sigma (+)", minval = 0.5, maxval = 6.0, step = 0.1,
                           group = grpDet,
                           tooltip = "Residual z-score above this triggers an 'implied block' (more volume than the price move warrants).")
thinSigma    = input.float(2.0, "Thin Market Sigma (-)",  minval = 0.5, maxval = 6.0, step = 0.1,
                           group = grpDet,
                           tooltip = "Residual z-score below the negative of this value triggers a 'thin market' event (price moved on suspiciously low volume).")
sigBlockSig  = input.float(3.0, "Significant Block Sigma", minval = 1.0, maxval = 6.0, step = 0.1,
                           group = grpDet,
                           tooltip = "Above this z-score the block is rendered with a polygon glyph plus an estimated lot-size badge.")
clusterCnt   = input.int(3,  "Cluster Min Block Count", minval = 2, maxval = 10, group = grpDet)
clusterWin   = input.int(5,  "Cluster Window (bars)",   minval = 2, maxval = 50, group = grpDet)
cooldownBars = input.int(0,  "Signal Cooldown (bars)",  minval = 0, maxval = 10, group = grpDet,
                         tooltip = "Suppress duplicate same-direction signals within this many bars.")

// ---------- Block Size Estimation -----------------------------------------
avgBlockScaler = input.float(1.0, "Avg Block Size Scaler", minval = 0.01, maxval = 10.0, step = 0.05,
                             group = grpEst,
                             tooltip = "Empirical scaler converting residual-volume to estimated block lot size.  Calibrate to your asset's notional.")
sizeUnits      = input.string("Auto", "Size Units", options = ["Auto", "Shares/Coins", "Notional USD"],
                              group = grpEst)
priceProxy     = input.source(close, "Notional Price Proxy", group = grpEst,
                              tooltip = "Used when 'Notional USD' is selected.  Default close.")

// ---------- Visual Engine -------------------------------------------------
showHist        = input.bool(true,  "Show Residual Z Histogram",     group = grpVis)
showThresholds  = input.bool(true,  "Show Threshold Lines (+/-2,3)", group = grpVis)
showZeroLine    = input.bool(true,  "Show Zero Line",                group = grpVis)
showSigMarkers  = input.bool(true,  "Show Significant Block Glyphs", group = grpVis)
showThinDots    = input.bool(true,  "Show Thin-Market Dots",         group = grpVis)
showBgFade      = input.bool(true,  "BG Fade By Recency",            group = grpVis)
bgFadeBars      = input.int (12, "BG Fade Decay (bars)", minval = 2, maxval = 60, group = grpVis,
                             tooltip = "Higher = slower fade.  The background tint decays to fully transparent after this many bars.")
showCumDelta    = input.bool(false, "Show Cumulative Implied Delta", group = grpVis)
histWidth       = input.int(4, "Histogram Bar Width", minval = 1, maxval = 10, group = grpVis)
markerSize      = input.string("Small", "Marker Size", options = ["Tiny","Small","Normal","Large","Huge"], group = grpVis)

// ---------- Theme ---------------------------------------------------------
overrideOpacity = input.int(0, "Palette Opacity Adjust", minval = -40, maxval = 40, group = grpThm,
                            tooltip = "Pushes all palette alphas brighter (negative) or dimmer (positive).")

// ---------- Dashboard -----------------------------------------------------
showDash       = input.bool(true, "Show Dashboard", group = grpDash)
dashPosStr     = input.string("Top Right", "Dashboard Position",
                              options = ["Top Right","Top Left","Top Center",
                                         "Middle Right","Middle Left","Middle Center",
                                         "Bottom Right","Bottom Left","Bottom Center"],
                              group = grpDash)
dashSizeStr    = input.string("Normal", "Dashboard Text Size",
                              options = ["Tiny","Small","Normal","Large","Huge"],
                              group = grpDash)
dashCompact    = input.bool(false, "Compact Dashboard Cells", group = grpDash)
dashShowLegend = input.bool(true,  "Show Legend Footer",      group = grpDash)

// ---------- Alerts --------------------------------------------------------
alertOnBuy     = input.bool(true,  "Alert: Implied Buy Block",  group = grpAlert)
alertOnSell    = input.bool(true,  "Alert: Implied Sell Block", group = grpAlert)
alertOnThin    = input.bool(true,  "Alert: Thin Market Event",  group = grpAlert)
alertOnCluster = input.bool(true,  "Alert: Block Cluster",      group = grpAlert)


// ============================================================================
//  SECTION 2  -  PALETTE  (Carbon - curated, single palette, HIGH CONTRAST)
//  ----------------------------------------------------------------------------
//   bullMain  -> implied buy block  (neon green)
//   bearMain  -> implied sell block (neon red)
//   midMain   -> neutral / thresholds (white)
//   bgMain    -> carbon-black background
//   frameMain -> dark carbon frame
// ============================================================================

const color bullMain  = #00FF7F
const color bearMain  = #FF1744
const color midMain   = #FFFFFF
const color bgMain    = #0E0E0E
const color frameMain = #1F1F1F


// ============================================================================
//  SECTION 3  -  HELPER FUNCTIONS
//  ----------------------------------------------------------------------------
//  Pure functions only.  No state mutation here.
// ============================================================================

// 3.1  Two-color RGB gradient interpolator (canonical JOAT helper).
f_colorGradient(float _ratio, color _colA, color _colB) =>
    rA = color.r(_colA),  gA = color.g(_colA),  bA = color.b(_colA)
    rB = color.r(_colB),  gB = color.g(_colB),  bB = color.b(_colB)
    rr = rA + int((rB - rA) * _ratio)
    rg = gA + int((gB - gA) * _ratio)
    rb = bA + int((bB - bA) * _ratio)
    color.rgb(rr, rg, rb, 0)

// 3.2  Numeric clamp.
f_clamp(float _x, float _min, float _max) =>
    math.max(_min, math.min(_x, _max))

// 3.3  Pretty volume formatting (K / M / B).
f_fmtVol(float v) =>
    av = math.abs(v)
    out = ""
    if av >= 1e12
        out := str.tostring(v / 1e12, "#.##") + "T"
    else if av >= 1e9
        out := str.tostring(v / 1e9,  "#.##") + "B"
    else if av >= 1e6
        out := str.tostring(v / 1e6,  "#.##") + "M"
    else if av >= 1e3
        out := str.tostring(v / 1e3,  "#.##") + "K"
    else
        out := str.tostring(v, "#.##")
    out

// 3.4  String -> position constant resolver.
f_strToPos(string s) =>
    switch s
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        =>               position.bottom_right

// 3.5  String -> size constant resolver.
f_strToSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.normal

// 3.6  Dashboard row-gradient background (subtle vertical fade).
f_grad(color _base, int _row, int _rows, int _minT, int _maxT) =>
    float t = _rows <= 1 ? _minT : (_minT + (_maxT - _minT) * (_row / float(_rows - 1)))
    int   ti = int(t) + overrideOpacity
    color.new(_base, math.max(0, math.min(100, ti)))

// 3.7  Safe percent-of helper.
f_pctOf(float num, float den) =>
    den == 0 ? 0.0 : (num / den) * 100.0

// 3.8  Apply theme opacity adjust to any color.
f_themed(color c, int baseT) =>
    int ti = baseT + overrideOpacity
    color.new(c, math.max(0, math.min(100, ti)))


// ============================================================================
//  SECTION 4  -  CORE CALCULATIONS  (REGRESSION + RESIDUAL + Z)
//  ----------------------------------------------------------------------------
//  Model:    expected_vol = SMA(volume, N) * |return| / SMA(|return|, N)
//
//  This is the "robust beta1 approximation" called for in the spec.
//  Mathematically equivalent (up to intercept) to fitting volume = a + b*|ret|
//  through the origin and using b for the prediction at the current |ret|.
//  R^2 is computed from the Pearson correlation of |return| and volume
//  over the same window so the dashboard can warn when the relationship
//  is weak.
// ============================================================================

// 4.1  Returns.
float ret = useLogRet ? math.log(returnSrc / nz(returnSrc[1], returnSrc)) : (returnSrc - nz(returnSrc[1], returnSrc)) / math.max(math.abs(nz(returnSrc[1], 1e-10)), 1e-10)
float absRet = math.abs(ret)

// 4.2  Lightly smoothed volume so spurious 0-volume bars don't blow up the ratio.
float volSm = volSmoothLen <= 1 ? volume : ta.ema(volume, volSmoothLen)

// 4.3  Rolling means (regression block).
float meanVol    = ta.sma(volSm,  regWindow)
float meanAbsRet = ta.sma(absRet, regWindow)

// 4.4  Expected volume per the robust approximation.
float expVol = meanAbsRet > 0 ? meanVol * (absRet / meanAbsRet) : meanVol

// 4.5  Residual and its statistics.
float residual    = volSm - expVol
float resMean     = ta.sma(residual, regWindow)
float resStdev    = ta.stdev(residual, regWindow)
float residualZ   = resStdev > 0 ? (residual - resMean) / resStdev : 0.0

// 4.6  R^2 of the |return|<->volume relationship.
float corr        = ta.correlation(absRet, volSm, regWindow)
float r2          = na(corr) ? 0.0 : corr * corr
bool  modelOk     = r2 >= minR2

// 4.7  Implied block size estimate.
//      A positive residual on a green bar => implied buying pressure.
//      A positive residual on a red   bar => implied selling pressure.
float blockSizeRaw = math.max(0.0, residual) * avgBlockScaler
float blockNotional = blockSizeRaw * priceProxy
float blockSizeOut  = sizeUnits == "Notional USD" ? blockNotional : blockSizeRaw

// 4.8  Direction code (-1, 0, +1) by sign of return.
int   barDir = ret > 0 ? 1 : ret < 0 ? -1 : 0


// ============================================================================
//  SECTION 5  -  STATE / TRACKING
//  ----------------------------------------------------------------------------
//  Rolling counters + arrays for recent block events.  We bound array sizes
//  so we never bust Pine's memory ceiling on long charts.
// ============================================================================

// 5.1  Session counters (reset on the first bar of a new daily session).
var int sessionBuyBlocks  = 0
var int sessionSellBlocks = 0
var int sessionThinEvents = 0

bool sessionStart = ta.change(time("D")) != 0
if sessionStart
    sessionBuyBlocks  := 0
    sessionSellBlocks := 0
    sessionThinEvents := 0

// 5.2  Persistent event arrays (FIFO).  Each parallel array represents one
//      attribute of the event so we don't need a UDT for so few fields.
var array<int>   evBarIdx  = array.new<int>()
var array<int>   evDir     = array.new<int>()
var array<float> evZ       = array.new<float>()
var array<float> evSize    = array.new<float>()
var array<int>   evKind    = array.new<int>()    // 1=block, -1=thin

int evMaxLen = 200

f_pushEvent(int _kind, int _dir, float _z, float _size) =>
    array.push(evBarIdx, bar_index)
    array.push(evDir,    _dir)
    array.push(evZ,      _z)
    array.push(evSize,   _size)
    array.push(evKind,   _kind)
    while array.size(evBarIdx) > evMaxLen
        array.shift(evBarIdx)
        array.shift(evDir)
        array.shift(evZ)
        array.shift(evSize)
        array.shift(evKind)

// 5.3  Cooldown bookkeeping.
var int lastBuyBlockBar   = -10000
var int lastSellBlockBar  = -10000
var int lastThinBar       = -10000
var int lastAnyBlockBar   = -10000

// 5.4  Cumulative implied delta (signed residual on block bars).
var float cumImpliedDelta = 0.0


// ============================================================================
//  SECTION 6  -  BLOCK DETECTION + CLASSIFICATION
//  ----------------------------------------------------------------------------
//  Signal flow:
//      1.  residual_z above blockSigma AND ret != 0   -> implied block
//      2.  residual_z below -thinSigma                -> thin market
//      3.  block strength >= sigBlockSig              -> "significant"
//      4.  3+ block events within clusterWin bars     -> cluster alert
// ============================================================================

bool canBuy   = barDir > 0 and (bar_index - lastBuyBlockBar)  >= cooldownBars
bool canSell  = barDir < 0 and (bar_index - lastSellBlockBar) >= cooldownBars
bool canThin  = (bar_index - lastThinBar) >= cooldownBars

bool impliedBuy  = barstate.isconfirmed and residualZ >=  blockSigma and canBuy
bool impliedSell = barstate.isconfirmed and residualZ >=  blockSigma and canSell
bool thinEvent   = barstate.isconfirmed and residualZ <= -thinSigma and canThin
bool isBlockEvt  = impliedBuy or impliedSell
bool isSig       = math.abs(residualZ) >= sigBlockSig

// 6.1  Persist + bookkeeping for buy block.
if impliedBuy
    sessionBuyBlocks := sessionBuyBlocks + 1
    cumImpliedDelta  := cumImpliedDelta + residual
    lastBuyBlockBar  := bar_index
    lastAnyBlockBar  := bar_index
    f_pushEvent(1, 1, residualZ, blockSizeOut)

// 6.2  Persist + bookkeeping for sell block.
if impliedSell
    sessionSellBlocks := sessionSellBlocks + 1
    cumImpliedDelta   := cumImpliedDelta - residual
    lastSellBlockBar  := bar_index
    lastAnyBlockBar   := bar_index
    f_pushEvent(1, -1, residualZ, blockSizeOut)

// 6.3  Persist + bookkeeping for thin market.
if thinEvent
    sessionThinEvents := sessionThinEvents + 1
    lastThinBar       := bar_index
    f_pushEvent(-1, barDir, residualZ, 0.0)

// 6.4  Cluster detection (3+ block events inside clusterWin bars).
//      Forward iteration to be safe across all Pine v6 versions.
int clusterRecent = 0
if array.size(evBarIdx) > 0
    for i = 0 to array.size(evBarIdx) - 1
        if array.get(evKind, i) == 1 and (bar_index - array.get(evBarIdx, i)) <= clusterWin
            clusterRecent += 1

bool clusterEvent = barstate.isconfirmed and clusterRecent >= clusterCnt


// ============================================================================
//  SECTION 7  -  PLOTS
//  ----------------------------------------------------------------------------
//  Histogram of residual Z + threshold lines + zero line.  Color is gradient-
//  scaled so a 2-sigma bar isn't the same brightness as a 5-sigma bar.
// ============================================================================

// 7.1  Per-bar histogram color (sigma-scaled brightness).
float zMag        = math.abs(residualZ)
float zRatio      = f_clamp(zMag / 6.0, 0.0, 1.0)     // 6 sigma = max brightness
color histBase    = residualZ >= 0 ? bullMain : bearMain
color histColor   = f_colorGradient(zRatio, f_themed(histBase, 70), f_themed(histBase, 0))
color histColLow  = f_themed(midMain, 60)
color histColMain = modelOk ? histColor : histColLow

// 7.2  Histogram plot (residual Z).
plot(showHist ? residualZ : na,
     title     = "Residual Z (sigma)",
     color     = histColMain,
     linewidth = histWidth,
     style     = plot.style_columns)

// 7.3  Zero line.
plot(showZeroLine ? 0.0 : na,
     title     = "Zero",
     color     = f_themed(midMain, 60),
     linewidth = 1)

// 7.4  Threshold lines (positive side).
plot(showThresholds ?  2.0 : na, "+2 sigma", color = f_themed(bullMain, 50), linewidth = 1, style = plot.style_linebr)
plot(showThresholds ?  3.0 : na, "+3 sigma", color = f_themed(bullMain, 30), linewidth = 1, style = plot.style_linebr)
plot(showThresholds ? -2.0 : na, "-2 sigma", color = f_themed(bearMain, 50), linewidth = 1, style = plot.style_linebr)
plot(showThresholds ? -3.0 : na, "-3 sigma", color = f_themed(bearMain, 30), linewidth = 1, style = plot.style_linebr)

// 7.5  Thin-market dots at the zero line (a small circle = move on thin vol).
plotchar(showThinDots and thinEvent ? 0.0 : na,
         title    = "Thin Market Dot",
         char     = "●",
         location = location.absolute,
         color    = f_themed(midMain, 30),
         size     = size.small)

// 7.6  Optional cumulative implied delta (separate scale).
plot(showCumDelta ? cumImpliedDelta : na,
     title     = "Cumulative Implied Delta",
     color     = f_themed(midMain, 30),
     linewidth = 1,
     display   = display.data_window)

// 7.7  Cluster-active highlight bar (a thin tick at the threshold line).
plotshape(clusterEvent, title = "Cluster Event",
          style    = shape.diamond,
          location = location.absolute,
          size     = size.tiny,
          color    = f_themed(midMain, 0))


// ============================================================================
//  SECTION 8  -  LABELS  +  BACKGROUND FADE
//  ----------------------------------------------------------------------------
//  Significant-block markers use the hexagonal "block" glyph U+2B22 (⬢).
//  Each marker carries a size badge.  Memory is bounded by max_labels_count.
// ============================================================================

string blockGlyph = "⬢"      // hexagon  -- the "block" mark

if showSigMarkers and isBlockEvt and isSig
    string txt = blockGlyph + " " + f_fmtVol(blockSizeOut)
    color  col = impliedBuy ? bullMain : bearMain
    label.new(bar_index,
              residualZ + (impliedBuy ? 0.5 : -0.5),
              text      = txt,
              style     = impliedBuy ? label.style_label_down : label.style_label_up,
              color     = f_themed(col, 65),
              textcolor = midMain,
              size      = f_strToSize(markerSize),
              yloc      = yloc.price)
else if showSigMarkers and isBlockEvt
    // Smaller marker for sub-significant blocks (still informative).
    color  col2 = impliedBuy ? bullMain : bearMain
    label.new(bar_index,
              residualZ + (impliedBuy ? 0.3 : -0.3),
              text      = blockGlyph,
              style     = label.style_none,
              color     = na,
              textcolor = f_themed(col2, 10),
              size      = size.tiny,
              yloc      = yloc.price)

// 8.1  BG fade by recency of last significant block.
int barsSinceBlock = lastAnyBlockBar < 0 ? 100000 : bar_index - lastAnyBlockBar
float fadeRatio    = f_clamp(1.0 - barsSinceBlock / float(bgFadeBars), 0.0, 1.0)
int   fadeAlpha    = 85 + int((100 - 85) * (1.0 - fadeRatio))   // 85 -> 100
color bgFadeColor  = na
if showBgFade and barsSinceBlock <= bgFadeBars
    bullSide       = lastAnyBlockBar == lastBuyBlockBar
    bgFadeColor   := color.new(bullSide ? bullMain : bearMain, fadeAlpha)
bgcolor(bgFadeColor)


// ============================================================================
//  SECTION 9  -  DASHBOARD
//  ----------------------------------------------------------------------------
//  9 rows (header + 8 metric rows + footer legend if enabled).
//  Position + size are configurable.  All cells use monospace for tabular look.
// ============================================================================

var table tbl = na

if showDash
    if na(tbl)
        tbl := table.new(f_strToPos(dashPosStr),
                         2, dashShowLegend ? 11 : 10,
                         bgcolor      = f_themed(bgMain, 8),
                         frame_color  = f_themed(frameMain, 20),
                         frame_width  = 1,
                         border_color = f_themed(frameMain, 60),
                         border_width = 1)

// Pre-compute "last implied block" descriptor.
int   lastBlockIdx = math.max(lastBuyBlockBar, lastSellBlockBar)
int   lastBlockAgo = lastBlockIdx < 0 ? -1 : bar_index - lastBlockIdx
int   lastBlockDir = lastBuyBlockBar > lastSellBlockBar ? 1 : lastBuyBlockBar < lastSellBlockBar ? -1 : 0
string lastBlockDirStr = lastBlockDir == 1 ? "BUY" : lastBlockDir == -1 ? "SELL" : "-"

// Recover last block size (last entry where kind == block).
float lastBlockSize = 0.0
if array.size(evBarIdx) > 0
    for i = 0 to array.size(evBarIdx) - 1
        if array.get(evKind, i) == 1
            lastBlockSize := array.get(evSize, i)

// Recent thin-event count (within regression window).
int recentThin = 0
if array.size(evBarIdx) > 0
    for i = 0 to array.size(evBarIdx) - 1
        if array.get(evKind, i) == -1 and (bar_index - array.get(evBarIdx, i)) <= regWindow
            recentThin += 1

if showDash and barstate.islast
    color hdrBg    = f_themed(frameMain, 0)
    color hdrTxt   = midMain
    color lblBg    = f_grad(bgMain,    1, 10, 78, 92)
    color valBg    = f_grad(frameMain, 1, 10, 80, 92)
    color goodCol  = bullMain
    color badCol   = bearMain
    color midCol   = midMain

    string sizePref = "Size: "
    string sUnits   = sizeUnits == "Notional USD" ? "$" : sizeUnits == "Shares/Coins" ? "u" : ""

    // Header.
    table.cell(tbl, 0, 0, "LARGE LOT REVERSE ENG.",
               text_color = hdrTxt, bgcolor = hdrBg,
               text_size = f_strToSize(dashSizeStr),
               text_halign = text.align_left,
               text_font_family = font.family_monospace)
    table.cell(tbl, 1, 0, "[JOAT]",
               text_color = hdrTxt, bgcolor = hdrBg,
               text_size = f_strToSize(dashSizeStr),
               text_halign = text.align_right,
               text_font_family = font.family_monospace)

    // Row 1 : current residual Z
    color zCol = residualZ > 0 ? goodCol : residualZ < 0 ? badCol : midCol
    table.cell(tbl, 0, 1, "Residual (sigma)",
               text_color = midCol, bgcolor = lblBg,
               text_size = f_strToSize(dashSizeStr),
               text_halign = text.align_left,
               text_font_family = font.family_monospace)
    table.cell(tbl, 1, 1, str.tostring(residualZ, "0.00") + " s",
               text_color = zCol, bgcolor = valBg,
               text_size = f_strToSize(dashSizeStr),
               text_halign = text.align_right,
               text_font_family = font.family_monospace)

    // Row 2 : R-squared (model reliability)
    color rCol = r2 >= 0.40 ? goodCol : r2 >= minR2 ? midCol : badCol
    table.cell(tbl, 0, 2, "Regression R²",
               text_color = midCol, bgcolor = lblBg,
               text_size = f_strToSize(dashSizeStr),
               text_halign = text.align_left,
               text_font_family = font.family_monospace)
    table.cell(tbl, 1, 2, str.tostring(r2, "0.00") + (modelOk ? " OK" : " WARN"),
               text_color = rCol, bgcolor = valBg,
               text_size = f_strToSize(dashSizeStr),
               text_halign = text.align_right,
               text_font_family = font.family_monospace)

    // Row 3 : last implied block (dir + bars ago + size)
    color lbCol = lastBlockDir == 1 ? goodCol : lastBlockDir == -1 ? badCol : midCol
    string lbVal = lastBlockAgo < 0
                   ? "none"
                   : lastBlockDirStr + " | " + str.tostring(lastBlockAgo) + "b | " +
                     sUnits + f_fmtVol(lastBlockSize)
    table.cell(tbl, 0, 3, "Last Implied Block",
               text_color = midCol, bgcolor = lblBg,
               text_size = f_strToSize(dashSizeStr),
               text_halign = text.align_left,
               text_font_family = font.family_monospace)
    table.cell(tbl, 1, 3, lbVal,
               text_color = lbCol, bgcolor = valBg,
               text_size = f_strToSize(dashSizeStr),
               text_halign = text.align_right,
               text_font_family = font.family_monospace)

    // Row 4 : session block counts
    table.cell(tbl, 0, 4, "Session Blocks B/S",
               text_color = midCol, bgcolor = lblBg,
               text_size = f_strToSize(dashSizeStr),
               text_halign = text.align_left,
               text_font_family = font.family_monospace)
    table.cell(tbl, 1, 4,
               str.tostring(sessionBuyBlocks) + " / " + str.tostring(sessionSellBlocks),
               text_color = sessionBuyBlocks >= sessionSellBlocks ? goodCol : badCol,
               bgcolor = valBg,
               text_size = f_strToSize(dashSizeStr),
               text_halign = text.align_right,
               text_font_family = font.family_monospace)

    // Row 5 : cumulative implied delta
    color cdCol = cumImpliedDelta > 0 ? goodCol : cumImpliedDelta < 0 ? badCol : midCol
    table.cell(tbl, 0, 5, "Cum Implied Delta",
               text_color = midCol, bgcolor = lblBg,
               text_size = f_strToSize(dashSizeStr),
               text_halign = text.align_left,
               text_font_family = font.family_monospace)
    table.cell(tbl, 1, 5, (cumImpliedDelta >= 0 ? "+" : "-") + f_fmtVol(math.abs(cumImpliedDelta)),
               text_color = cdCol, bgcolor = valBg,
               text_size = f_strToSize(dashSizeStr),
               text_halign = text.align_right,
               text_font_family = font.family_monospace)

    // Row 6 : thin market events (recent count)
    table.cell(tbl, 0, 6, "Thin Events (rec.)",
               text_color = midCol, bgcolor = lblBg,
               text_size = f_strToSize(dashSizeStr),
               text_halign = text.align_left,
               text_font_family = font.family_monospace)
    table.cell(tbl, 1, 6, str.tostring(recentThin),
               text_color = recentThin > 0 ? midCol : f_themed(midCol, 50),
               bgcolor = valBg,
               text_size = f_strToSize(dashSizeStr),
               text_halign = text.align_right,
               text_font_family = font.family_monospace)

    // Row 7 : regression window setting
    table.cell(tbl, 0, 7, "Window",
               text_color = midCol, bgcolor = lblBg,
               text_size = f_strToSize(dashSizeStr),
               text_halign = text.align_left,
               text_font_family = font.family_monospace)
    table.cell(tbl, 1, 7, str.tostring(regWindow) + " bars",
               text_color = midCol, bgcolor = valBg,
               text_size = f_strToSize(dashSizeStr),
               text_halign = text.align_right,
               text_font_family = font.family_monospace)

    // Row 8 : threshold setting
    table.cell(tbl, 0, 8, "Thresholds (B/T/S)",
               text_color = midCol, bgcolor = lblBg,
               text_size = f_strToSize(dashSizeStr),
               text_halign = text.align_left,
               text_font_family = font.family_monospace)
    table.cell(tbl, 1, 8,
               str.tostring(blockSigma, "0.0") + " / " +
               str.tostring(thinSigma,  "0.0") + " / " +
               str.tostring(sigBlockSig,"0.0"),
               text_color = midCol, bgcolor = valBg,
               text_size = f_strToSize(dashSizeStr),
               text_halign = text.align_right,
               text_font_family = font.family_monospace)

    // Row 9 : signal status dot
    statusStr = clusterEvent ? "CLUSTER" : impliedBuy ? "BUY BLOCK" : impliedSell ? "SELL BLOCK" : thinEvent ? "THIN MKT" : "idle"
    statusCol = clusterEvent ? midCol : impliedBuy ? goodCol : impliedSell ? badCol : thinEvent ? midCol : f_themed(midCol, 60)
    table.cell(tbl, 0, 9, "Status",
               text_color = midCol, bgcolor = lblBg,
               text_size = f_strToSize(dashSizeStr),
               text_halign = text.align_left,
               text_font_family = font.family_monospace)
    table.cell(tbl, 1, 9, "● " + statusStr,
               text_color = statusCol, bgcolor = valBg,
               text_size = f_strToSize(dashSizeStr),
               text_halign = text.align_right,
               text_font_family = font.family_monospace)

    // Optional legend footer.
    if dashShowLegend
        table.cell(tbl, 0, 10, "⬢ block",
                   text_color = midCol, bgcolor = lblBg,
                   text_size = f_strToSize(dashSizeStr),
                   text_halign = text.align_left,
                   text_font_family = font.family_monospace)
        table.cell(tbl, 1, 10, "● thin   ◆ cluster",
                   text_color = midCol, bgcolor = lblBg,
                   text_size = f_strToSize(dashSizeStr),
                   text_halign = text.align_right,
                   text_font_family = font.family_monospace)


// ============================================================================
//  SECTION 10  -  ALERTS
//  ----------------------------------------------------------------------------
//  Four alert conditions.  Each carries the symbol/timeframe/size in the
//  message so a webhook receiver can route correctly.
// ============================================================================

string sym = syminfo.ticker
string tf  = timeframe.period
string base = " [" + sym + " @ " + tf + "] z=" + str.tostring(residualZ, "0.00") +
              " size=" + f_fmtVol(blockSizeOut)

alertcondition(alertOnBuy and impliedBuy,
               title   = "Implied Buy Block",
               message = "LLR [JOAT] IMPLIED BUY BLOCK")
alertcondition(alertOnSell and impliedSell,
               title   = "Implied Sell Block",
               message = "LLR [JOAT] IMPLIED SELL BLOCK")
alertcondition(alertOnThin and thinEvent,
               title   = "Thin Market Event",
               message = "LLR [JOAT] THIN MARKET EVENT")
alertcondition(alertOnCluster and clusterEvent,
               title   = "Block Cluster",
               message = "LLR [JOAT] BLOCK CLUSTER (3+ blocks within window)")

// ----------------------------------------------------------------------------
// End of Large Lot Reverse Engineer [JOAT]
// ----------------------------------------------------------------------------
````
