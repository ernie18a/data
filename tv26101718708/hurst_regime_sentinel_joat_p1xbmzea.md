# Hurst Regime Sentinel [JOAT]

- url: https://www.tradingview.com/script/p1XbmzEA-Hurst-Regime-Sentinel-JOAT/
- type: indicator
- pine_id: PUB;3e1e98f93df14c36b6c9612d6feeb35b
- version: 1.0

## Description

[b]HURST REGIME SENTINEL [JOAT][/b]

A proper R/S Hurst-exponent regime classifier — the single most respected statistical test for "is this market trending, mean-reverting, or random?". On top of the textbook R/S analysis, the Sentinel adds a five-class regime taxonomy (Strong MR, MR, Random, Trend, Strong Trend), a confirmation-bars filter to suppress flicker, a right-side floating Hurst badge, a regime-tinted background, and — uniquely — a [b]Suggested JOAT Indicator[/b] dashboard row that names the best-fit companion script in the JOAT suite for the current regime.

[image]https://www.tradingview.com/x/71bi6XNb/[/image]

[b]The Hurst exponent, properly[/b]

The Hurst exponent H is a number between 0 and 1 that characterises the long-run [i]persistence[/i] of a time series:

[list]
[*] [b]H < 0.5[/b] — anti-persistent / mean-reverting. The series tends to reverse its recent direction.
[*] [b]H = 0.5[/b] — random walk (Brownian motion). No memory.
[*] [b]H > 0.5[/b] — persistent / trending. The series tends to continue its recent direction.
[/list]

The classical estimator is [b]R/S analysis[/b] (rescaled range): split the window into sub-segments, compute the range of cumulative deviations from each sub-mean, normalise by the sub-stdev, average, and fit a log-log slope. This script implements that estimator over a configurable lookback (default 100, the canonical value), with optional log-return source for theoretical correctness, and an EMA smoother on top of the raw H series to give a stable regime read.

[b]Five-class regime taxonomy[/b]

The Sentinel does not just classify into trend/MR/random — it sub-classifies the trend and MR sides:

[list]
[*] [b]Strong MR[/b] — H below the strong-MR boundary (default 0.30). Severely anti-persistent. Aggressive reversion regime.
[*] [b]MR[/b] — H between strong-MR and the MR upper (default 0.40). Mean-reverting.
[*] [b]Random[/b] — H between MR upper and trend lower (default 0.55). No statistical edge from persistence assumptions.
[*] [b]Trend[/b] — H above trend lower. Trending.
[*] [b]Strong Trend[/b] — H above the strong-trend boundary (default 0.65). Strongly persistent. Aggressive momentum regime.
[/list]

A [b]Minimum-bars-to-confirm[/b] filter (default 3 bars) suppresses regime flicker; a change must persist this many bars before it is committed.

[b]Suggested JOAT Indicator row (unique)[/b]

The dashboard exposes a [b]Suggested Indicator[/b] row that names the best-fit companion script from the JOAT suite for the current regime. The user can pick which suggestions appear (defaults: [i]Volatility Reversion Bands Pro[/i] for MR, [i]Quantum Trend Matrix[/i] for Trend, [i]Liquidity Magnet Pro[/i] for Random — but every other JOAT indicator is selectable). This converts the abstract regime read into a concrete next action: when the regime changes, the script tells you which other tool in the suite to put on the chart.

[b]Visual system[/b]

[list]
[*] [b]Right-side floating label[/b] — anchored N bars to the right of the latest bar with current H value, regime, and sub-class.
[*] [b]Regime-change labels[/b] — drawn at the bar where a confirmed regime change occurs.
[*] [b]Background tint by regime[/b] — violet for MR, teal for Trend, untinted for Random. Strong sub-classes use a stronger (lower-transparency) alpha than mild sub-classes. Both alphas are configurable.
[*] [b]Optional Hurst line companion[/b] — when enabled, plots the H series scaled to a configurable fraction of the visible price range. Use to visually track H movement over time. Off by default for a clean chart.
[*] [b]Optional reference levels[/b] at 0.40 / 0.50 / 0.55 when the line is shown.
[/list]

A locked Mystic palette (teal trend / violet MR / white random on a midnight-blue ground) gives the chart a distinctive structural identity.

[b]Dashboard[/b]

Monospaced table positionable to any of nine corners. Surfaces:

[list]
[*] Current H value (raw and smoothed).
[*] Regime classification with glyph.
[*] Sub-class (Strong MR / MR / Random / Trend / Strong Trend).
[*] Bars in current regime.
[*] Distance from H to nearest threshold.
[*] Suggested JOAT Indicator row (toggleable).
[*] Source series in use (Close / HL2 / HLC3 / OHLC4 / Log Returns).
[/list]

[image]https://www.tradingview.com/x/ISbkCGbe/[/image]

[b]Alerts[/b]

Multiple alert conditions, each independently controllable:

[list]
[*] Regime changed to MR / Random / Trend
[*] Sub-class changed to Strong MR / Strong Trend
[*] H crosses 0.50 (random-walk centre)
[/list]

[b]How to read it[/b]

Three reads, in order of conviction:

[list=1]
[*] [b]Sub-class entry (Strong MR or Strong Trend)[/b] — the highest-conviction read. The market has decisively committed to a persistence regime; the suggested companion indicator becomes high-conviction.
[*] [b]Regime change confirmed[/b] (after the minimum-bars filter) — meaningful enough to switch toolkits. If you were trading momentum and the script now reads MR, your edge has just rotated.
[*] [b]H crossing 0.50[/b] — the structural fault line. Above, persistence is positive; below, it is negative. Even without a sub-class entry, a clean cross of 0.50 is a regime warning.
[/list]

[b]Suggested settings[/b]

Defaults (lookback 100, EMA smoothing 14, MR upper 0.40, trend lower 0.55, strong boundaries 0.30 / 0.65) are tuned for daily and 4H charts on liquid markets — the timeframes where R/S analysis is statistically most meaningful. For 1H and below the indicator works but the H estimate becomes noisier; raise the EMA smoother to compensate. For very long horizons (1W+) increase lookback to 200.

[b]Originality / what's reused[/b]

The R/S Hurst estimator is the textbook 1951 method — public-domain statistics, implemented from the original Hurst paper. The implementation here — the bounded-loop R/S computation with sub-segment averaging, the five-class regime taxonomy with strong sub-classes, the confirmation-bars regime-change filter, the regime-driven background tint with mild/strong alpha tiers, the optional scaled Hurst-line overlay, the right-side floating badge, and the suggested-JOAT-indicator dashboard row — is JOAT-original. No third-party code reused.

[b]Open source[/b]

Published open-source under the default Mozilla Public License 2.0. The R/S loop, the regime classifier, the suggested-indicator router, and the dashboard are isolated modules. Forks welcome with credit.

[b]Limitations[/b]

Hurst R/S is statistical — it describes the recent past, it does not predict the future. The estimator carries the natural noise of finite-sample R/S; the EMA smoother is there to suppress flicker but cannot eliminate underlying noise on short lookbacks. The "Suggested JOAT Indicator" row is a heuristic mapping from regime to tool, not a prediction that any specific signal from that tool will fire — it tells you which corner of the toolkit to look at; the tool itself tells you when to act.

—

-made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title             = "Hurst Regime Sentinel [JOAT]",
          shorttitle        = "HRS [JOAT]",
          overlay           = true,
          max_lines_count   = 500,
          max_labels_count  = 500,
          max_boxes_count   = 500,
          max_bars_back     = 5000)

// =============================================================================
//  SECTION 1 - INPUTS
// =============================================================================

grpCalc    = "+======== Hurst Calculation ========+"
grpThresh  = "+======== Regime Thresholds ========+"
grpVisuals = "+======== Visuals ========+"
grpBG      = "+======== Background Tint ========+"
grpLine    = "+======== Hurst Line / Pane ========+"
grpSugg    = "+======== Suggested JOAT Indicator ========+"
grpDash    = "+======== Dashboard ========+"
grpAlerts  = "+======== Alerts ========+"

// --- Calculation ----------------------------------------------------------
hurstLen      = input.int   (defval = 100,  title = "Hurst Lookback (N)",
     minval = 20, maxval = 1000, group = grpCalc,
     tooltip = "Number of bars used to compute R/S Hurst. The classic value is 100. Smaller = more reactive but noisier. Pine loops are bounded so very large values increase compile cost.")

smoothLen     = input.int   (defval = 14,   title = "Hurst Smoothing EMA",
     minval = 1,  maxval = 200, group = grpCalc,
     tooltip = "EMA length applied to raw Hurst readings. Filters noise and gives a more stable regime classification.")

srcChoice     = input.string(defval = "Close",  title = "Source Series",
     options = ["Close","HL2","HLC3","OHLC4","Log Returns"], group = grpCalc,
     tooltip = "Series fed to Hurst. Log returns is most theoretically correct but Close is the most intuitive on charts.")

minWarmupBars = input.int   (defval = 50,   title = "Minimum Warmup Bars",
     minval = 1, maxval = 500, group = grpCalc,
     tooltip = "Bars to wait before the indicator reports any classification. Avoids regimes being assigned on too-thin data.")

// --- Regime thresholds ----------------------------------------------------
mrUpper       = input.float (defval = 0.40, title = "Mean-Revert Upper (H < this = MR)",
     minval = 0.10, maxval = 0.50, step = 0.01, group = grpThresh,
     tooltip = "Hurst values BELOW this number are classified as Mean-Reverting. Default = 0.40 per institutional convention.")

randomCenter  = input.float (defval = 0.50, title = "Random Walk Center",
     minval = 0.30, maxval = 0.70, step = 0.01, group = grpThresh,
     tooltip = "Reference Hurst value for a pure random walk (Brownian motion). 0.50 is the theoretical value.")

trendLower    = input.float (defval = 0.55, title = "Trend Lower (H > this = Trend)",
     minval = 0.50, maxval = 0.90, step = 0.01, group = grpThresh,
     tooltip = "Hurst values ABOVE this number are classified as Trending. Default = 0.55. Values between mrUpper and trendLower are Random.")

strongMR      = input.float (defval = 0.30, title = "Strong MR Boundary (H < this = Strong)",
     minval = 0.05, maxval = 0.45, step = 0.01, group = grpThresh,
     tooltip = "Strong Mean-Reverting sub-class threshold. Default = 0.30. Below this means extremely choppy / anti-persistent.")

strongTrend   = input.float (defval = 0.65, title = "Strong Trend Boundary (H > this = Strong)",
     minval = 0.55, maxval = 0.95, step = 0.01, group = grpThresh,
     tooltip = "Strong Trending sub-class threshold. Default = 0.65. Above this means strong persistent / trending behaviour.")

regimeMinBars = input.int   (defval = 3,    title = "Minimum Bars to Confirm Regime Change",
     minval = 1, maxval = 50, group = grpThresh,
     tooltip = "Suppresses flicker. A change must persist this many bars before it is committed.")

// --- Theme / visuals ------------------------------------------------------
// MYSTIC PALETTE (curated, single source of truth)
//   trending  = #00CED1 (teal)
//   mean-rev  = #9400D3 (violet)
//   random    = #F0F8FF (white)
//   bg        = #191970 (midnight blue)
//   frame     = #241A3A

showRegimeLabel = input.bool(defval = true,  title = "Show Right-Side Hurst Label",  group = grpVisuals,
     tooltip = "Pin a small floating label on the most recent bar showing H value + regime + sub-class.")

showChangeLabel = input.bool(defval = true,  title = "Show Regime Change Labels",   group = grpVisuals,
     tooltip = "Draw a label at the bar where a regime/sub-class change is confirmed.")

labelOffset     = input.int (defval = 5,     title = "Right-Side Label Offset (bars)",
     minval = 0, maxval = 50, group = grpVisuals,
     tooltip = "How many bars to the right of the last bar the floating label is anchored.")

// --- Background tint ------------------------------------------------------
showBg          = input.bool(defval = true,  title = "Tint Chart Background by Regime", group = grpBG,
     tooltip = "MR regime tints blue, Trend regime tints orange, Random is untinted. Strong sub-classes use a stronger alpha.")

bgAlphaWeak     = input.int (defval = 93,    title = "Mild Sub-Class Transparency",
     minval = 70, maxval = 99, group = grpBG,
     tooltip = "0 = opaque, 99 = nearly invisible. Mild sub-classes use this softer value so they do not overpower price.")

bgAlphaStrong   = input.int (defval = 88,    title = "Strong Sub-Class Transparency",
     minval = 60, maxval = 99, group = grpBG,
     tooltip = "Stronger sub-classes (Strong MR / Strong Trend) draw with this slightly more opaque alpha.")

// Tint colors derived from Mystic palette: violet for MR, teal for Trend
color mrTintCol    = #9400D3
color trendTintCol = #00CED1

// --- Hurst pane line ------------------------------------------------------
showHurstLine   = input.bool(defval = false, title = "Show Hurst Line (as overlay companion)", group = grpLine,
     tooltip = "Overlays a scaled Hurst line on the price chart for visual reference. By default off so the chart stays clean.")

hurstLineScale  = input.float(defval = 0.10, title = "Hurst Line Scale (chart fraction)",
     minval = 0.01, maxval = 1.0, step = 0.01, group = grpLine,
     tooltip = "Vertical extent of the Hurst line as a fraction of the visible price range. Smaller = compact.")

showLevels      = input.bool(defval = true, title = "Show Reference Levels (0.40 / 0.50 / 0.55)", group = grpLine,
     tooltip = "Draw dotted horizontal reference levels at the regime threshold values. Only meaningful when the Hurst line is shown.")

// --- Suggested JOAT row ---------------------------------------------------
showSuggest     = input.bool(defval = true, title = "Show Suggested JOAT Indicator Row", group = grpSugg,
     tooltip = "Dashboard row that names the best-fit indicator in the JOAT suite for the current regime.")

suggMR          = input.string(defval = "Volatility Reversion Bands Pro", title = "MR Regime Suggestion",
     options = [
         "Volatility Reversion Bands Pro","Z-Score Flow Pro","Tension Flow RR",
         "Momentum Vol Composite Pro","Smart SR Zones","Liquidity Magnet Pro",
         "Neural Kernel Bands","Quantum Trend Matrix","Liquid Reversal Engine",
         "Quant SMC Pro","Order Flow Footprint","CVD Delta Divergence",
         "Iceberg Detector","Sweep and Cluster","Aggressive Whale Prints",
         "Whale Absorption Profile","Large Lot Reverse Engineer","Liquidity Heatmap MTF"
     ], group = grpSugg)

suggRandom      = input.string(defval = "Smart SR Zones", title = "Random Regime Suggestion",
     options = [
         "Volatility Reversion Bands Pro","Z-Score Flow Pro","Tension Flow RR",
         "Momentum Vol Composite Pro","Smart SR Zones","Liquidity Magnet Pro",
         "Neural Kernel Bands","Quantum Trend Matrix","Liquid Reversal Engine",
         "Quant SMC Pro","Order Flow Footprint","CVD Delta Divergence",
         "Iceberg Detector","Sweep and Cluster","Aggressive Whale Prints",
         "Whale Absorption Profile","Large Lot Reverse Engineer","Liquidity Heatmap MTF"
     ], group = grpSugg)

suggTrend       = input.string(defval = "Neural Kernel Bands", title = "Trend Regime Suggestion",
     options = [
         "Volatility Reversion Bands Pro","Z-Score Flow Pro","Tension Flow RR",
         "Momentum Vol Composite Pro","Smart SR Zones","Liquidity Magnet Pro",
         "Neural Kernel Bands","Quantum Trend Matrix","Liquid Reversal Engine",
         "Quant SMC Pro","Order Flow Footprint","CVD Delta Divergence",
         "Iceberg Detector","Sweep and Cluster","Aggressive Whale Prints",
         "Whale Absorption Profile","Large Lot Reverse Engineer","Liquidity Heatmap MTF"
     ], group = grpSugg)

// --- Dashboard ------------------------------------------------------------
showDash      = input.bool   (defval = true,         title = "Show Dashboard",     group = grpDash)
dashPosStr    = input.string (defval = "Top Right",  title = "Dashboard Position",
     options = ["Top Right","Top Left","Top Center","Middle Right","Middle Left","Middle Center","Bottom Right","Bottom Left","Bottom Center"], group = grpDash)
dashSizeStr   = input.string (defval = "Normal",     title = "Dashboard Size",
     options = ["Tiny","Small","Normal","Large","Huge"], group = grpDash)
dashFrameTr   = input.int    (defval = 65,           title = "Dashboard Frame Transparency",
     minval = 0,  maxval = 95,  group = grpDash)
dashShowLeg   = input.bool   (defval = true,         title = "Show Legend Footer", group = grpDash)

// --- Alerts ---------------------------------------------------------------
alertChange   = input.bool(defval = true, title = "Alert on Regime Change",      group = grpAlerts)
alertCross    = input.bool(defval = true, title = "Alert on Hurst Crossing 0.5", group = grpAlerts)
alertStrong   = input.bool(defval = true, title = "Alert on Strong Regime Entered", group = grpAlerts)
alertSubChg   = input.bool(defval = true, title = "Alert on Sub-Class Change",   group = grpAlerts)

// =============================================================================
//  SECTION 2 - MYSTIC PALETTE (single curated palette)
// =============================================================================
//  Semantics for the Hurst Sentinel:
//      C_BULL  = trending regime  -> teal      #00CED1
//      C_BEAR  = mean-revert      -> violet    #9400D3
//      C_MID   = random walk      -> white     #F0F8FF
//      C_BG    = chart bg / dash  -> midnight  #191970
//      C_FRAME = dashboard frame  -> deep      #241A3A
// -----------------------------------------------------------------------------
const color C_BULL  = #00CED1
const color C_BEAR  = #9400D3
const color C_MID   = #F0F8FF
const color C_BG    = #191970
const color C_FRAME_BASE = #241A3A

// Auxiliary palette
color C_TEXT      = color.new(#FFFFFF, 0)
color C_TEXT_DIM  = color.new(#FFFFFF, 30)
color C_FRAME     = color.new(C_FRAME_BASE, dashFrameTr)
color C_HEADER_BG = color.new(C_BG, math.max(0, dashFrameTr - 25))
color C_ROW_BG    = color.new(C_BG, 80)
color C_ROW_BG2   = color.new(C_BG, 75)

// =============================================================================
//  SECTION 3 - HELPER FUNCTIONS
// =============================================================================

// 3.1 Linear two-color RGB gradient (KB 2.1)
f_colorGradient(float _ratio, color _colA, color _colB) =>
    rA = color.r(_colA), gA = color.g(_colA), bA = color.b(_colA)
    rB = color.r(_colB), gB = color.g(_colB), bB = color.b(_colB)
    rr = rA + int((rB - rA) * _ratio)
    rg = gA + int((gB - gA) * _ratio)
    rb = bA + int((bB - bA) * _ratio)
    color.rgb(rr, rg, rb, 0)

// 3.2 Three-stop gradient (mid pivot at 0.5)
f_gradient3(float _ratio, color _a, color _b, color _c) =>
    color outc = _a
    if _ratio <= 0.5
        outc := f_colorGradient(_ratio * 2.0, _a, _b)
    else
        outc := f_colorGradient((_ratio - 0.5) * 2.0, _b, _c)
    outc

// 3.3 Clamp helper (KB 2.3)
f_clamp(float _x, float _lo, float _hi) => math.max(_lo, math.min(_x, _hi))

// 3.4 String -> table position (KB 2.4)
f_strToPos(string s) =>
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

// 3.5 String -> text size (KB 2.4)
f_strToSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.normal

// 3.6 Build a "#####" mask of length n (for f_fmt precision)
f_hashMask(int n) =>
    string s = ""
    for _i = 0 to math.max(0, n - 1)
        s += "#"
    s

// 3.7 Format float to short string
f_fmt(float v, int prec) =>
    na(v) ? "n/a" : str.tostring(v, "#." + f_hashMask(prec))

// 3.8 Format percentage  (v in [0,1] -> "##.##%")
f_pct(float v) =>
    na(v) ? "n/a" : str.tostring(v * 100.0, "#.##") + "%"

// 3.9 Source-series resolver
f_srcSeries(string s) =>
    float out = close
    if      s == "Close"
        out := close
    else if s == "HL2"
        out := hl2
    else if s == "HLC3"
        out := hlc3
    else if s == "OHLC4"
        out := ohlc4
    else if s == "Log Returns"
        out := close > 0 and close[1] > 0 ? math.log(close / close[1]) : 0.0
    out

// 3.10 *** HURST EXPONENT (R/S METHOD) ***                      (KB 2.12)
// Approximation tailored for Pine v6's bounded loops. Computes the rescaled
// range R / S over the last `len` observations of `src` and returns
// log(R/S) / log(len). The series mean is removed before accumulating the
// cumulative deviation. S is the population standard deviation of the
// detrended series. Safe-guards: division by zero, log of zero, len < 2.
f_hurstRS(float src, int len) =>
    float h = 0.5
    if len >= 2
        // 1) Mean of the window
        avg = ta.sma(src, len)
        // 2) Running cumulative deviation, max & min, sum of squared deviations
        float sumDev = 0.0
        float cumDev = 0.0
        float maxC   = -1e15
        float minC   =  1e15
        for i = 0 to len - 1
            d       = nz(src[i]) - avg
            cumDev += d
            if cumDev > maxC
                maxC := cumDev
            if cumDev < minC
                minC := cumDev
            sumDev += d * d
        // 3) Rescaled range
        R  = maxC - minC
        S  = math.sqrt(sumDev / len)
        rs = S > 0.0 ? R / S : 1.0
        // 4) Hurst exponent estimate
        if rs > 0.0 and len > 1
            h := math.log(rs) / math.log(len)
        else
            h := 0.5
    h

// 3.11 Regime classifier: -1 MR, 0 Random, +1 Trend
f_regime(float h, float mrU, float trL) =>
    int r = 0
    if      h < mrU
        r := -1
    else if h > trL
        r := 1
    else
        r := 0
    r

// 3.12 Sub-class numeric code mapping
// -2 = Strong MR, -1 = Mild MR, 0 = Random, +1 = Mild Trend, +2 = Strong Trend
f_subClass(float h, float mrU, float trL, float sMR, float sTR) =>
    int s = 0
    if      h < sMR
        s := -2
    else if h < mrU
        s := -1
    else if h <= trL
        s := 0
    else if h < sTR
        s := 1
    else
        s := 2
    s

// 3.13 Sub-class name resolver
f_subClassName(int s) =>
    string nm = "Random"
    if      s == -2
        nm := "Strong MR"
    else if s == -1
        nm := "Mild MR"
    else if s ==  0
        nm := "Random"
    else if s ==  1
        nm := "Mild Trend"
    else if s ==  2
        nm := "Strong Trend"
    nm

// 3.14 Regime name resolver
f_regimeName(int r) =>
    string nm = "Random"
    if      r == -1
        nm := "Mean-Revert"
    else if r ==  1
        nm := "Trending"
    nm

// 3.15 Confidence: 2 * |H - 0.5|, clamped to [0,1]
f_confidence(float h) =>
    f_clamp(2.0 * math.abs(h - 0.5), 0.0, 1.0)

// =============================================================================
//  SECTION 4 - CORE CALCULATIONS
// =============================================================================

// 4.1 Resolve source series
srcUsed = f_srcSeries(srcChoice)

// 4.2 Hurst exponent (raw + smoothed)
hurstRaw    = f_hurstRS(srcUsed, hurstLen)
hurstClamped = f_clamp(nz(hurstRaw, 0.5), 0.0, 1.0)
hurstSmooth = ta.ema(hurstClamped, smoothLen)

// 4.3 Warmup gate: do not classify until we have enough bars + a non-na smooth
warmedUp    = bar_index >= minWarmupBars and not na(hurstSmooth)

// 4.4 Regime + sub-class
regimeRaw   = warmedUp ? f_regime(hurstSmooth, mrUpper, trendLower)             : 0
subClassRaw = warmedUp ? f_subClass(hurstSmooth, mrUpper, trendLower, strongMR, strongTrend) : 0

// 4.5 Confidence
confidence  = warmedUp ? f_confidence(hurstSmooth) : 0.0

// =============================================================================
//  SECTION 5 - STATE / REGIME TRACKING
// =============================================================================

// 5.1 Persistent regime state (after the change-confirmation hysteresis)
var int currentRegime    = 0
var int currentSubClass  = 0
var int regimeStartBar   = 0
var int subClassStartBar = 0
var int lastChangeBar    = na
var int lastSubChgBar    = na
var int prevConfirmedReg = 0
var int prevConfirmedSub = 0

// 5.2 Hysteresis counters - require regimeMinBars of consistent new state
var int regimeStableCnt  = 0
var int subClassStableCnt= 0
var int pendingRegime    = 0
var int pendingSubClass  = 0

if warmedUp
    // First-time initialization
    if barstate.isfirst or bar_index == minWarmupBars
        currentRegime    := regimeRaw
        currentSubClass  := subClassRaw
        regimeStartBar   := bar_index
        subClassStartBar := bar_index
        pendingRegime    := regimeRaw
        pendingSubClass  := subClassRaw
        regimeStableCnt  := regimeMinBars
        subClassStableCnt:= regimeMinBars

    // Track pending regime: if raw differs from confirmed, start counting
    if regimeRaw != currentRegime
        if regimeRaw == pendingRegime
            regimeStableCnt := regimeStableCnt + 1
        else
            pendingRegime   := regimeRaw
            regimeStableCnt := 1
        if regimeStableCnt >= regimeMinBars
            // Commit the change
            prevConfirmedReg := currentRegime
            currentRegime    := pendingRegime
            regimeStartBar   := bar_index
            lastChangeBar    := bar_index
            regimeStableCnt  := 0
    else
        // Raw matches confirmed - reset pending counter
        pendingRegime   := currentRegime
        regimeStableCnt := 0

    // Same hysteresis flow for sub-class
    if subClassRaw != currentSubClass
        if subClassRaw == pendingSubClass
            subClassStableCnt := subClassStableCnt + 1
        else
            pendingSubClass   := subClassRaw
            subClassStableCnt := 1
        if subClassStableCnt >= regimeMinBars
            prevConfirmedSub := currentSubClass
            currentSubClass  := pendingSubClass
            subClassStartBar := bar_index
            lastSubChgBar    := bar_index
            subClassStableCnt:= 0
    else
        pendingSubClass   := currentSubClass
        subClassStableCnt := 0

// 5.3 Derived state values for plotting / dashboard
barsInRegime     = bar_index - regimeStartBar
barsInSubClass   = bar_index - subClassStartBar
barsSinceLastChg = na(lastChangeBar)   ? na : bar_index - lastChangeBar
barsSinceSubChg  = na(lastSubChgBar)   ? na : bar_index - lastSubChgBar

// =============================================================================
//  SECTION 6 - REGIME CHANGE DETECTION
// =============================================================================

// 6.1 Detect bars where the confirmed regime or sub-class CHANGED this bar
regimeChanged    = warmedUp and ta.change(currentRegime)   != 0
subClassChanged  = warmedUp and ta.change(currentSubClass) != 0

// 6.2 Hurst crosses the random-walk axis (0.5 by default)
hurstCrossUp     = warmedUp and ta.crossover (hurstSmooth, randomCenter)
hurstCrossDown   = warmedUp and ta.crossunder(hurstSmooth, randomCenter)

// 6.3 Strong-regime ENTRY (sub-class transitioned to Strong MR or Strong Trend)
strongMRentered    = warmedUp and currentSubClass ==  -2 and ta.change(currentSubClass) != 0
strongTrendEntered = warmedUp and currentSubClass ==   2 and ta.change(currentSubClass) != 0
strongEntered      = strongMRentered or strongTrendEntered

// 6.4 Regime + sub-class change descriptors (for labels / alerts)
regimeFromName = f_regimeName(prevConfirmedReg)
regimeToName   = f_regimeName(currentRegime)
subFromName    = f_subClassName(prevConfirmedSub)
subToName      = f_subClassName(currentSubClass)

// =============================================================================
//  SECTION 7 - PLOTS, FILLS, LEVELS
// =============================================================================

// 7.1 Regime-driven cell / line color (used in dashboard + labels)
regimeColor = currentRegime == -1 ? C_BEAR : currentRegime ==  1 ? C_BULL : C_MID

subClassColor = currentSubClass == -2 ? C_BEAR : currentSubClass == -1 ? color.new(C_BEAR, 30) : currentSubClass ==  0 ? C_MID : currentSubClass ==  1 ? color.new(C_BULL, 30) : C_BULL

// 7.2 OPTIONAL Hurst overlay line
// We scale the smoothed Hurst onto the visible price range so the user can
// place this companion overlay above the price chart if desired. The line is
// hidden by default to keep the chart minimal.
priceMid     = (high + low) / 2.0
priceRange   = ta.highest(high, math.max(20, hurstLen)) - ta.lowest(low, math.max(20, hurstLen))
scaledHurst  = priceMid + (hurstSmooth - 0.5) * priceRange * hurstLineScale * 2.0

plot(showHurstLine ? scaledHurst : na,
     title = "Hurst (smoothed, scaled)",
     color = color.new(subClassColor, 0),
     linewidth = 2,
     style = plot.style_line)

// 7.3 Reference levels (drawn as horizontal lines scaled to the same range)
randomScaled = priceMid
mrLineScaled = priceMid + (mrUpper      - 0.5) * priceRange * hurstLineScale * 2.0
trLineScaled = priceMid + (trendLower   - 0.5) * priceRange * hurstLineScale * 2.0
sMRScaled    = priceMid + (strongMR     - 0.5) * priceRange * hurstLineScale * 2.0
sTRScaled    = priceMid + (strongTrend  - 0.5) * priceRange * hurstLineScale * 2.0

plot(showHurstLine and showLevels ? randomScaled : na, title = "H = 0.50 (random)",
     color = color.new(C_MID,  40), style = plot.style_circles, linewidth = 1)
plot(showHurstLine and showLevels ? mrLineScaled : na, title = "H = mrUpper",
     color = color.new(C_BEAR, 50), style = plot.style_circles, linewidth = 1)
plot(showHurstLine and showLevels ? trLineScaled : na, title = "H = trendLower",
     color = color.new(C_BULL, 50), style = plot.style_circles, linewidth = 1)
plot(showHurstLine and showLevels ? sMRScaled : na, title = "H = strongMR",
     color = color.new(C_BEAR, 30), style = plot.style_cross,   linewidth = 1)
plot(showHurstLine and showLevels ? sTRScaled : na, title = "H = strongTrend",
     color = color.new(C_BULL, 30), style = plot.style_cross,   linewidth = 1)

// 7.4 Pure plot of the raw Hurst value (always available for inspection &
// allows users to add their own plot styling). Hidden as default plot only
// shows up if user explicitly enables in the indicator settings via TV UI.
plot(hurstSmooth, title = "Hurst (smoothed, 0-1)", display = display.data_window, color = color.new(C_MID, 0))
plot(hurstRaw,    title = "Hurst (raw, 0-1)",      display = display.data_window, color = color.new(C_MID, 40))
plot(confidence,  title = "Confidence (0-1)",      display = display.data_window, color = color.new(C_BULL, 0))
plot(currentRegime,   title = "Regime (-1/0/+1)",  display = display.data_window, color = color.new(C_BULL, 0))
plot(currentSubClass, title = "SubClass (-2..+2)", display = display.data_window, color = color.new(C_BULL, 0))

// =============================================================================
//  SECTION 8 - BACKGROUND TINT + RIGHT-SIDE LABEL
// =============================================================================

// 8.1 Compute regime tint color with sub-class-dependent alpha
isStrongSub  = currentSubClass == -2 or currentSubClass == 2
bgAlphaUsed  = isStrongSub ? bgAlphaStrong : bgAlphaWeak

regimeTintCol = currentRegime == -1 ? color.new(mrTintCol,    bgAlphaUsed) : currentRegime ==  1 ? color.new(trendTintCol, bgAlphaUsed) : na

bgcolor(showBg ? regimeTintCol : na, title = "Regime BG Tint")

// 8.2 Floating right-side Hurst label - draws ONE label only on the last bar
var label hurstLbl = na

if barstate.islast and showRegimeLabel
    if not na(hurstLbl)
        label.delete(hurstLbl)
    txt = "H " + f_fmt(hurstSmooth, 3) + "\n" +
          f_regimeName(currentRegime) + " | " + f_subClassName(currentSubClass) + "\n" +
          "Conf " + f_pct(confidence)
    yPos = close
    lblStyle = currentRegime ==  1 ? label.style_label_left : currentRegime == -1 ? label.style_label_left : label.style_label_left
    hurstLbl := label.new(bar_index + labelOffset, yPos,
         text       = txt,
         style      = lblStyle,
         color      = color.new(regimeColor, 30),
         textcolor  = color.new(#FFFFFF, 0),
         size       = size.small,
         textalign  = text.align_left,
         tooltip    = "Hurst Regime Sentinel (HRS) [JOAT]\n"
                     + "Lookback N=" + str.tostring(hurstLen)
                     + ", Smoothing EMA=" + str.tostring(smoothLen)
                     + "\nThresholds: MR < " + f_fmt(mrUpper, 2)
                     + " | Random " + f_fmt(mrUpper, 2) + ".." + f_fmt(trendLower, 2)
                     + " | Trend > " + f_fmt(trendLower, 2)
                     + "\nStrong MR < " + f_fmt(strongMR, 2)
                     + " | Strong Trend > " + f_fmt(strongTrend, 2))

// 8.3 Regime-change inline labels (drawn at the bar of the confirmed change)
if showChangeLabel and regimeChanged
    chgTxt = regimeFromName + " -> " + regimeToName
    chgCol = currentRegime ==  1 ? C_BULL : currentRegime == -1 ? C_BEAR : C_MID
    label.new(bar_index, low,
         text       = "HRS\n" + chgTxt,
         style      = label.style_label_up,
         color      = color.new(chgCol, 25),
         textcolor  = color.new(#FFFFFF, 0),
         size       = size.tiny,
         yloc       = yloc.belowbar,
         tooltip    = "Regime classification changed.\n"
                     + "Prev = " + regimeFromName + "\n"
                     + "Now  = " + regimeToName + "\n"
                     + "H    = " + f_fmt(hurstSmooth, 3)
                     + "\nSub-class = " + subToName)

if showChangeLabel and subClassChanged and not regimeChanged
    // Show subclass shifts even when the parent regime didn't flip
    chgTxt2 = subFromName + " -> " + subToName
    chgCol2 = currentSubClass >=  1 ? C_BULL : currentSubClass <= -1 ? C_BEAR : C_MID
    label.new(bar_index, low,
         text       = "HRS sub\n" + chgTxt2,
         style      = label.style_label_up,
         color      = color.new(chgCol2, 60),
         textcolor  = color.new(#FFFFFF, 0),
         size       = size.tiny,
         yloc       = yloc.belowbar,
         tooltip    = "Hurst sub-class updated (parent regime unchanged).\n"
                     + "Prev = " + subFromName + "\n"
                     + "Now  = " + subToName + "\n"
                     + "H    = " + f_fmt(hurstSmooth, 3))

// =============================================================================
//  SECTION 9 - DASHBOARD
// =============================================================================

dashPos  = f_strToPos(dashPosStr)
dashSize = f_strToSize(dashSizeStr)

// 9.1 Header bg color reflects current regime
hdrBg = currentRegime ==  1 ? color.new(C_BULL, 60) : currentRegime == -1 ? color.new(C_BEAR, 60) : color.new(C_MID,  70)

// 9.2 Sub-class cell color
subCellCol = currentSubClass == -2 ? color.new(C_BEAR, 30) : currentSubClass == -1 ? color.new(C_BEAR, 55) : currentSubClass ==  0 ? color.new(C_MID,  60) : currentSubClass ==  1 ? color.new(C_BULL, 55) : color.new(C_BULL, 30)

// 9.3 Suggested JOAT indicator resolver
suggestedName = currentRegime == -1 ? suggMR : currentRegime ==  1 ? suggTrend : suggRandom

// 9.4 Confidence cell color: gradient from mid to regime-color
confCellCol = color.new(f_colorGradient(confidence, C_MID, regimeColor), 50)

// 9.5 Bars-in-regime "freshness" cell color
freshCellCol = barsInRegime < 5  ? color.new(C_MID, 35) : barsInRegime < 20 ? color.new(regimeColor, 60) : color.new(regimeColor, 80)

// 9.6 Build the table - eight rows incl. header, optional ninth = legend
nRows = (showSuggest ? 9 : 8) + (dashShowLeg ? 1 : 0)

var table dash = table.new(position.top_right, 2, 10,
     bgcolor      = na,
     frame_color  = C_FRAME,
     frame_width  = 1,
     border_color = color.new(C_FRAME, 50),
     border_width = 1)

if barstate.isfirst
    dash := table.new(dashPos, 2, nRows,
         bgcolor      = na,
         frame_color  = C_FRAME,
         frame_width  = 1,
         border_color = color.new(C_FRAME, 50),
         border_width = 1)

if showDash and barstate.islast
    // ------------------------------------------------------------------
    // Row 0 - Header
    // ------------------------------------------------------------------
    table.cell(dash, 0, 0, "HURST REGIME",
         text_color = C_TEXT, bgcolor = hdrBg,
         text_size  = dashSize, text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(dash, 1, 0, "HRS",
         text_color = C_TEXT, bgcolor = hdrBg,
         text_size  = dashSize, text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // ------------------------------------------------------------------
    // Row 1 - Hurst H value (smoothed, 3 decimals)
    // ------------------------------------------------------------------
    hurstTxt = warmedUp ? f_fmt(hurstSmooth, 3) : "warming"
    table.cell(dash, 0, 1, "Hurst H",
         text_color = C_TEXT_DIM, bgcolor = C_ROW_BG,
         text_size  = dashSize, text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(dash, 1, 1, hurstTxt,
         text_color = C_TEXT, bgcolor = color.new(regimeColor, 55),
         text_size  = dashSize, text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // ------------------------------------------------------------------
    // Row 2 - Regime (color-coded)
    // ------------------------------------------------------------------
    regTxt = warmedUp ? f_regimeName(currentRegime) : "warming"
    table.cell(dash, 0, 2, "Regime",
         text_color = C_TEXT_DIM, bgcolor = C_ROW_BG,
         text_size  = dashSize, text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(dash, 1, 2, regTxt,
         text_color = C_TEXT, bgcolor = color.new(regimeColor, 35),
         text_size  = dashSize, text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // ------------------------------------------------------------------
    // Row 3 - Confidence
    // ------------------------------------------------------------------
    confTxt = warmedUp ? f_pct(confidence) : "warming"
    table.cell(dash, 0, 3, "Confidence",
         text_color = C_TEXT_DIM, bgcolor = C_ROW_BG,
         text_size  = dashSize, text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(dash, 1, 3, confTxt,
         text_color = C_TEXT, bgcolor = confCellCol,
         text_size  = dashSize, text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // ------------------------------------------------------------------
    // Row 4 - Sub-class
    // ------------------------------------------------------------------
    subTxt = warmedUp ? f_subClassName(currentSubClass) : "warming"
    table.cell(dash, 0, 4, "Sub-Class",
         text_color = C_TEXT_DIM, bgcolor = C_ROW_BG,
         text_size  = dashSize, text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(dash, 1, 4, subTxt,
         text_color = C_TEXT, bgcolor = subCellCol,
         text_size  = dashSize, text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // ------------------------------------------------------------------
    // Row 5 - Bars in Regime
    // ------------------------------------------------------------------
    inRegTxt = warmedUp ? str.tostring(barsInRegime) + "b" : "--"
    table.cell(dash, 0, 5, "Bars in Regime",
         text_color = C_TEXT_DIM, bgcolor = C_ROW_BG,
         text_size  = dashSize, text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(dash, 1, 5, inRegTxt,
         text_color = C_TEXT, bgcolor = freshCellCol,
         text_size  = dashSize, text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // ------------------------------------------------------------------
    // Row 6 - Last Regime Change
    // ------------------------------------------------------------------
    lastChgTxt = na(barsSinceLastChg) ? "--" : str.tostring(barsSinceLastChg) + "b ago"
    table.cell(dash, 0, 6, "Last Change",
         text_color = C_TEXT_DIM, bgcolor = C_ROW_BG,
         text_size  = dashSize, text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(dash, 1, 6, lastChgTxt,
         text_color = C_TEXT, bgcolor = color.new(C_BG, 60),
         text_size  = dashSize, text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // ------------------------------------------------------------------
    // Row 7 - Hurst Lookback & smoothing (small reference)
    // ------------------------------------------------------------------
    paramsTxt = "N=" + str.tostring(hurstLen) + " S=" + str.tostring(smoothLen)
    table.cell(dash, 0, 7, "Calc Params",
         text_color = C_TEXT_DIM, bgcolor = C_ROW_BG2,
         text_size  = dashSize, text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(dash, 1, 7, paramsTxt,
         text_color = C_TEXT, bgcolor = color.new(C_BG, 70),
         text_size  = dashSize, text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // ------------------------------------------------------------------
    // Row 8 - Suggested JOAT indicator (optional)
    // ------------------------------------------------------------------
    if showSuggest
        suggBg = currentRegime == -1 ? color.new(C_BEAR, 65) : currentRegime ==  1 ? color.new(C_BULL, 65) : color.new(C_MID,  65)
        table.cell(dash, 0, 8, "Use Now",
             text_color = C_TEXT_DIM, bgcolor = C_ROW_BG,
             text_size  = dashSize, text_halign = text.align_left,
             text_font_family = font.family_monospace)
        table.cell(dash, 1, 8, suggestedName,
             text_color = C_TEXT, bgcolor = suggBg,
             text_size  = dashSize, text_halign = text.align_right,
             text_font_family = font.family_monospace)

    // ------------------------------------------------------------------
    // Row last - Legend footer (optional)
    // ------------------------------------------------------------------
    if dashShowLeg
        legRow = showSuggest ? 9 : 8
        legendTxt = "MR<" + f_fmt(mrUpper, 2) + "  Trend>" + f_fmt(trendLower, 2) + "  H=0.5 random"
        table.cell(dash, 0, legRow, legendTxt,
             text_color = C_TEXT_DIM, bgcolor = color.new(C_BG, 75),
             text_size  = size.tiny,   text_halign = text.align_left,
             text_font_family = font.family_monospace)
        table.cell(dash, 1, legRow, "v1.0",
             text_color = C_TEXT_DIM, bgcolor = color.new(C_BG, 75),
             text_size  = size.tiny,   text_halign = text.align_right,
             text_font_family = font.family_monospace)

// =============================================================================
//  SECTION 10 - ALERTS
// =============================================================================

// 10.1 Regime change (top-level: MR / Random / Trend transitions)
alertcondition(alertChange and regimeChanged,
     title   = "HRS - Regime Changed",
     message = "HRS [JOAT] regime changed. Sym={{ticker}} TF={{interval}} H={{plot_0}}")

// 10.2 Sub-class change (finer than regime change)
alertcondition(alertSubChg and subClassChanged,
     title   = "HRS - Sub-Class Changed",
     message = "HRS [JOAT] sub-class changed. Sym={{ticker}} TF={{interval}} H={{plot_0}}")

// 10.3 Hurst crosses the 0.5 random-walk axis (up)
alertcondition(alertCross and hurstCrossUp,
     title   = "HRS - Hurst Crossed Above 0.5",
     message = "HRS [JOAT] Hurst crossed above 0.50 - trending bias rising. Sym={{ticker}} TF={{interval}}")

// 10.4 Hurst crosses the 0.5 random-walk axis (down)
alertcondition(alertCross and hurstCrossDown,
     title   = "HRS - Hurst Crossed Below 0.5",
     message = "HRS [JOAT] Hurst crossed below 0.50 - mean-revert bias rising. Sym={{ticker}} TF={{interval}}")

// 10.5 Strong MR sub-class entered
alertcondition(alertStrong and strongMRentered,
     title   = "HRS - Strong MR Entered",
     message = "HRS [JOAT] entered STRONG MEAN-REVERT regime. Sym={{ticker}} TF={{interval}}")

// 10.6 Strong Trend sub-class entered
alertcondition(alertStrong and strongTrendEntered,
     title   = "HRS - Strong Trend Entered",
     message = "HRS [JOAT] entered STRONG TREND regime. Sym={{ticker}} TF={{interval}}")

// 10.7 Any strong-regime entry (convenience)
alertcondition(alertStrong and strongEntered,
     title   = "HRS - Any Strong Regime Entered",
     message = "HRS [JOAT] entered a STRONG regime (MR or Trend). Sym={{ticker}} TF={{interval}}")

// =============================================================================
//  END OF FILE - Hurst Regime Sentinel [JOAT]
// =============================================================================
````
