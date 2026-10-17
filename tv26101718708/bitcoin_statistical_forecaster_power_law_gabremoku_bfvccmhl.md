# Bitcoin Statistical Forecaster + Power Law [Gabremoku]

- url: https://www.tradingview.com/script/bfVCcMhL-Bitcoin-Statistical-Forecaster-Power-Law-Gabremoku/
- type: indicator
- pine_id: PUB;52b381ac5fcd4c5f98a37b76c8ac22c0
- version: 1.0

## Description

Bitcoin Statistical Forecaster + Power Law combines two analytical layers into a single BTC-focused overlay.

The first layer is a statistical analog forecaster. It scans historical Bitcoin data and searches for the closest matches to the most recent pattern using a weighted multi-feature distance model based on candle structure, volatility, momentum, trend distance, and structural position relative to the Bitcoin power-law range.

The second layer is a long-term Bitcoin power-law framework built from three structural curves: Floor, Mid-Stair, and Fair Value. These curves are plotted directly from the power-law formula and are not altered by the forecasting engine.

The script is not a simple mashup of two unrelated tools. The power-law layer is used as structural context inside the forecaster itself: it contributes to analog selection, regime comparison, optional forecast anchoring, and optional probability adjustment. The goal is to make historical pattern matching more aware of where price is located inside Bitcoin’s broader long-term structure.

How the forecast works:

The script compares the latest pattern against historical BTC windows.

It keeps the best analogs according to the selected similarity method.

These analogs are separated into Bull, Central, and Bear groups using the final return at the selected forecast horizon.

For each step in the projection, each scenario path is built from the weighted average of its own analog group, so the paths remain internally coherent instead of mixing bullish and bearish trajectories.

An optional structural bias can softly pull projected prices toward the power-law range over time. This effect fades in progressively across the forecast horizon, so near-term projections are not abruptly distorted.

Scenario probabilities are derived from the same percentile thresholds used to build the Bull, Central, and Bear paths. This keeps the displayed percentages aligned with the projected paths shown on the chart.

The script is designed for daily Bitcoin charts and works best when enough historical data is available. It is a probabilistic context tool, not a prediction guarantee, and it should be used together with risk management and independent market analysis.

Suggested usage:

Use the power-law curves to identify long-term structural position.

Use the forecast paths to estimate how similar historical BTC conditions evolved.

Compare current price location, structural regime, and scenario probabilities before forming a directional bias.

Treat the output as a contextual model, not as a standalone trading signal.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Gabremoku

//@version=6
indicator("Bitcoin Statistical Forecaster + Power Law [Gabremoku]", overlay=true, max_lines_count=500, max_labels_count=300, max_bars_back=5000)

//══════════════════════════════════════════════════════════════════════════════
// OVERVIEW
//══════════════════════════════════════════════════════════════════════════════
// Two complementary analytical layers, tightly integrated on a single overlay.
//
// ── 1) BTC POWER LAW ────────────────────────────────────────────────────────
//   Three long-term structural curves: price = A × days_since_genesis ^ B
//     * Floor     — long-term historical support baseline (coefficient A_floor)
//     * Mid-Stair — arithmetic midpoint: (Fair + Floor) / 2
//     * Fair      — long-term "fair value" central tendency (coefficient A_fair)
//   These curves are plotted as-is and are NOT modified by the forecaster.
//   They provide structural context for analog selection and optional
//   mean-reversion bias inside the forecast engine.
//
// ── 2) STATISTICAL FORECASTER ───────────────────────────────────────────────
//   Scans BTC history for the N patterns most similar to the last
//   `patternLength` bars (reference window ends at the current bar).
//   Similarity is a weighted multi-feature distance covering candle
//   structure, volatility, momentum, MA-distance and power-law position.
//
//   Best analogs are split into three scenario groups by their total
//   return at the end of the forecast horizon:
//     • Bull    — top 25% by final return
//     • Central — middle 50%
//     • Bear    — bottom 25%
//
//   For each step h = 1..forecastHorizon the projected price of each
//   scenario is the weighted average of that group's historical trajectories,
//   anchored at current close. Paths are internally coherent: every point
//   on the bull path comes from the same set of bullish analogs.
//
//   An optional structural bias (f_structuralAnchor) nudges projected prices
//   toward the power-law band. It fades in linearly over the horizon
//   (0 at h=1, full at h=forecastHorizon) so near-term steps are unaffected.
//
//   Scenario probabilities (bull/central/bear %) are computed from the same
//   p25/p75 thresholds that define the groups — labels always match the paths.

//══════════════════════════════════════════════════════════════════════════════
// INPUTS
//══════════════════════════════════════════════════════════════════════════════

// ── Core: pattern matching geometry ──────────────────────────────────────────
grp0 = "Core"
patternLength        = input.int(24, "Pattern Length", minval=10, maxval=80, group=grp0)               // number of bars in each analog window
forecastHorizon      = input.int(20, "Forecast Horizon", minval=5, maxval=40, group=grp0)              // bars to project forward from current bar
maxHistoryBarsToScan = input.int(2500, "Max History Bars To Scan", minval=300, maxval=5000, group=grp0) // depth of the history scan
topMatches           = input.int(12, "Top Matches", minval=3, maxval=30, group=grp0)                   // how many best analogs to keep
minGapBetweenMatches = input.int(12, "Min Gap Between Matches", minval=1, maxval=200, group=grp0)      // prevents overlapping analogs in the list
excludeRecentBars    = input.int(25, "Exclude Recent Bars", minval=5, maxval=300, group=grp0)          // skips the most recent history (avoids near-lookahead)

// ── Similarity: per-feature weights for the distance function ─────────────────
grp1 = "Similarity"
similarityMode       = input.string("Weighted L1", "Similarity Mode", options=["Weighted L1", "Weighted L2"], group=grp1) // L1 = sum of |diffs|; L2 = Euclidean (more sensitive to outliers)
weightReturn         = input.float(1.50, "Weight Return", minval=0.0, maxval=5.0, step=0.1, group=grp1)       // 1-bar log return
weightBody           = input.float(0.90, "Weight Body", minval=0.0, maxval=5.0, step=0.1, group=grp1)         // candle body as fraction of range
weightWicks          = input.float(0.60, "Weight Wicks", minval=0.0, maxval=5.0, step=0.1, group=grp1)        // upper + lower shadow fractions
weightVolatility     = input.float(1.00, "Weight Volatility", minval=0.0, maxval=5.0, step=0.1, group=grp1)   // bar range / ATR14
weightMomentum       = input.float(1.10, "Weight Momentum", minval=0.0, maxval=5.0, step=0.1, group=grp1)     // 5-bar cumulative return
weightTrend          = input.float(0.60, "Weight Trend Distance", minval=0.0, maxval=5.0, step=0.1, group=grp1) // (close − MA50) / ATR14

// ── Filters: optional regime-matching pre-filters (checked before computing distance) ──
grp2 = "Filters"
useTrendFilter       = input.bool(false, "Use Trend Filter", group=grp2)               // reject analogs with very different average trend
useVolatilityFilter  = input.bool(false, "Use Volatility Filter", group=grp2)          // reject analogs with very different volatility level
trendTolerance       = input.float(2.00, "Trend Tolerance", minval=0.1, maxval=5.0, step=0.1, group=grp2)      // max allowed |histTrend − refTrend|
volatilityTolerance  = input.float(1.80, "Volatility Tolerance", minval=0.1, maxval=5.0, step=0.1, group=grp2) // max allowed ATR% ratio (as multiplier)
useAdaptiveFallback  = input.bool(true, "Use Adaptive Fallback", group=grp2)           // doubles tolerances if fewer than minRequiredMatches are found

// ── Visuals: line styles, colors and gradient fill ───────────────────────────
grp3 = "Visuals"
showCentralForecast  = input.bool(true, "Show Central Forecast", group=grp3)
showBullBearBands    = input.bool(true, "Show Bull/Bear Scenarios", group=grp3)
showForecastFill     = input.bool(true, "Show Soft Forecast Fill", group=grp3)
fillLayers           = input.int(4, "Gradient Fill Layers", minval=2, maxval=8, group=grp3)         // more layers = smoother gradient between scenario and central
showMatchMarkers     = input.bool(false, "Show Match Markers On History", group=grp3)                // debug: marks each analog's end point on the chart
showEndLabels        = input.bool(true, "Show End Labels", group=grp3)
forecastSmoothing    = input.float(0.35, "Forecast Smoothing", minval=0.0, maxval=0.85, step=0.05, group=grp3) // EMA alpha on paths; 0 = raw, higher = smoother
fillOpacityOuter     = input.int(92, "Fill Opacity Outer", minval=0, maxval=100, group=grp3)        // opacity of the outermost fill band
fillOpacityInner     = input.int(80, "Fill Opacity Inner", minval=0, maxval=100, group=grp3)        // opacity of the innermost fill band (near central)
centralColor         = input.color(color.rgb(33, 150, 243), "Central Color", group=grp3)
bullColor            = input.color(color.rgb(0, 200, 83), "Bullish Color", group=grp3)
bearColor            = input.color(color.rgb(255, 82, 82), "Bearish Color", group=grp3)
lineWidthCentral     = input.int(3, "Central Line Width", minval=1, maxval=5, group=grp3)
lineWidthScenarios   = input.int(2, "Bull/Bear Line Width", minval=1, maxval=5, group=grp3)
endLabelSizeInput    = input.string("Normal", "End Label Size", options=["Tiny", "Small", "Normal"], group=grp3)

// ── Probabilities: scenario weight and threshold settings ─────────────────────
grp4 = "Probabilities"
useWeightedProb          = input.bool(true, "Use Weighted Empirical Probabilities", group=grp4)              // weight each analog by (1/score)^power; otherwise equal weight
weightPower              = input.float(1.0, "Similarity Weight Power", minval=0.2, maxval=3.0, step=0.1, group=grp4) // exponent on 1/score; higher = stronger best-match dominance
probabilityATRMultiplier = input.float(1.25, "ATR % Multiplier For Scenario Threshold", minval=0.2, maxval=5.0, step=0.05, group=grp4) // used only for P25-P75 dashboard row
minReturnThreshold       = input.float(0.02, "Minimum Scenario Threshold", minval=0.001, maxval=0.20, step=0.001, group=grp4)         // floor for the ATR-based P25-P75 cuts

// ── Safety: guard rails ───────────────────────────────────────────────────────
grp5 = "Safety"
dailyOnlyMode      = input.bool(true, "Daily Only Mode", group=grp5)              // suppresses forecast output on non-daily timeframes
minRequiredMatches = input.int(3, "Min Required Matches", minval=2, maxval=20, group=grp5) // below this the forecast is not drawn

grp6 = "🪧 Dashboard"
showDashboard      = input.bool(true, "Show Dashboard", group=grp6)
dashPosInput       = input.string("Bottom Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grp6)
dashTextSizeInput  = input.string("Small", "Dashboard Text Size", options=["Tiny", "Small", "Normal"], group=grp6)

grp7 = "BTC Halving"
showHalvings       = input.bool(true, "Show BTC Halving Markers", group=grp7)
showPastHalvings   = input.bool(true, "Show Past Halvings", group=grp7)
showFutureHalvings = input.bool(true, "Show Future Estimated Halving", group=grp7)
showHalvingLines   = input.bool(true, "Show BTC Halving Vertical Lines", group=grp7)
halvingColorPast   = input.color(color.orange, "Past Halving Color", group=grp7)
halvingColorFuture = input.color(color.aqua, "Future Halving Color", group=grp7)
halvingLabelSizeIn = input.string("Small", "Halving Label Size", options=["Tiny", "Small", "Normal"], group=grp7)

// ── Power Law: curve coefficients and visual options ─────────────────────────
// Formula: price = A × (days_since_genesis ^ B)
// A_fair and A_floor set the vertical offset of each curve; B is the shared
// growth exponent (the slope on a log-log chart). Genesis = Bitcoin block 0.
grp8 = "BTC Power Law"
const int DEFAULT_GENESIS_TIME = 1231006505000
genesisTime     = input.time(DEFAULT_GENESIS_TIME, "Genesis Time", group=grp8)  // Jan 3 2009
A_fair          = input.float(1.16e-17, "A_fair", group=grp8)
A_floor         = input.float(0.43e-17, "A_floor", group=grp8)
B               = input.float(5.82, "B", group=grp8)
showFair        = input.bool(true, "Show Fair", group=grp8)
showFloor       = input.bool(true, "Show Floor", group=grp8)
showMidStair    = input.bool(true, "Show Mid-Stair", group=grp8)
midStairColor   = input.color(color.rgb(255, 215, 0), "Mid-Stair Color", group=grp8)
showPowerLabels = input.bool(true, "Show Labels", group=grp8)
fairColor       = input.color(color.rgb(252, 6, 6), "Fair Color", group=grp8)
floorColor      = input.color(color.rgb(33, 150, 243), "Floor Color", group=grp8)
powerLineWidth  = input.int(2, "Line Width", minval=1, maxval=5, group=grp8)

// ── Structural Forecast: power-law awareness inside the forecaster ────────────
// These weights include power-law features (distance from fair/floor, position
// in the fair-floor range, slope) in the similarity score so the model
// finds analogs that were in a structurally similar regime.
//
// useStructuralBias: after building raw paths, each step is softly nudged
// toward the power-law band via f_structuralAnchor. The nudge fades in linearly
// (0 at h=1, full at h=forecastHorizon) — no artificial jump at the start.
//
// useStructuralProb: multiplicatively adjusts scenario probabilities by regime.
// Off by default: near the floor the bull boost can equalize bull/central %.
grp9 = "Structural Forecast"
weightDistFair      = input.float(1.20, "Weight Distance From Fair", minval=0.0, maxval=5.0, step=0.1, group=grp9)          // % above/below fair value
weightDistFloor     = input.float(0.90, "Weight Distance From Floor", minval=0.0, maxval=5.0, step=0.1, group=grp9)         // % above floor
weightFairFloorPos  = input.float(1.10, "Weight Position In Fair/Floor Range", minval=0.0, maxval=5.0, step=0.1, group=grp9) // 0=at floor, 1=at fair
weightPowerSlope    = input.float(0.50, "Weight Power Law Slope", minval=0.0, maxval=5.0, step=0.1, group=grp9)              // day-over-day growth rate of the curves
useStructuralBias   = input.bool(true, "Use Structural Bias On Forecast", group=grp9)
structuralBiasPower = input.float(0.35, "Structural Bias Strength", minval=0.0, maxval=1.0, step=0.05, group=grp9)
useStructuralProb   = input.bool(false, "Use Structural Bias On Scenario Probabilities", group=grp9)

//══════════════════════════════════════════════════════════════════════════════
// UI — resolve string inputs to Pine built-in size/position constants
//══════════════════════════════════════════════════════════════════════════════
dashTextSize = size.small
if dashTextSizeInput == "Tiny"
    dashTextSize := size.tiny
else if dashTextSizeInput == "Normal"
    dashTextSize := size.normal

labelSize = size.normal
if endLabelSizeInput == "Tiny"
    labelSize := size.tiny
else if endLabelSizeInput == "Small"
    labelSize := size.small

halvingLabelSize = size.small
if halvingLabelSizeIn == "Tiny"
    halvingLabelSize := size.tiny
else if halvingLabelSizeIn == "Normal"
    halvingLabelSize := size.normal

dashPos = position.bottom_right
if dashPosInput == "Top Right"
    dashPos := position.top_right
else if dashPosInput == "Top Left"
    dashPos := position.top_left
else if dashPosInput == "Bottom Left"
    dashPos := position.bottom_left

//══════════════════════════════════════════════════════════════════════════════
// HELPERS
//══════════════════════════════════════════════════════════════════════════════

// Clamp x into [lo, hi].
clampFloat(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

// Linear interpolation between a and b at position t ∈ [0,1].
f_interp(float a, float b, float t) =>
    a + (b - a) * t

// Format a price as "$1,234.56"; returns "n/a" if the value is na.
f_formatPrice(float v) =>
    na(v) ? "n/a" : "$" + str.tostring(v, "#,###.##")

// Weighted per-feature distance contribution.
// Returns w·|a−b| for L1 or w·(a−b)² for L2; treats na inputs as 0.
featureDiff(float a, float b, float w, bool useL2) =>
    float aa = na(a) ? 0.0 : a
    float bb = na(b) ? 0.0 : b
    float d = aa - bb
    useL2 ? w * d * d : w * math.abs(d)

// Return the arithmetic mean of a float array; na if the array is empty.
f_avgFloatArray(array<float> a) =>
    int sz = array.size(a)
    float out = na
    if sz > 0
        float sum = 0.0
        for i = 0 to sz - 1
            sum += array.get(a, i)
        out := sum / sz
    out

// In-place ascending bubble sort.
f_sortFloatArray(array<float> a) =>
    int n = array.size(a)
    if n > 1
        for i = 0 to n - 2
            for j = 0 to n - i - 2
                float v1 = array.get(a, j)
                float v2 = array.get(a, j + 1)
                if v1 > v2
                    array.set(a, j, v2)
                    array.set(a, j + 1, v1)

// Return the value at percentile pct (0–1) of a pre-sorted ascending array.
f_percentileFromSorted(array<float> a, float pct) =>
    int sz = array.size(a)
    float out = na
    if sz > 0
        int idx = int(math.floor((sz - 1) * clampFloat(pct, 0.0, 1.0)))
        out := array.get(a, idx)
    out

// Delete every line in the array, then clear it.
f_clearLines(array<line> linesArr) =>
    int sz = array.size(linesArr)
    if sz > 0
        for i = 0 to sz - 1
            line.delete(array.get(linesArr, i))
    array.clear(linesArr)

// Delete every label in the array, then clear it.
f_clearLabels(array<label> labelsArr) =>
    int sz = array.size(labelsArr)
    if sz > 0
        for i = 0 to sz - 1
            label.delete(array.get(labelsArr, i))
    array.clear(labelsArr)

// Delete every linefill in the array, then clear it.
f_clearLineFills(array<linefill> fillsArr) =>
    int sz = array.size(fillsArr)
    if sz > 0
        for i = 0 to sz - 1
            linefill.delete(array.get(fillsArr, i))
    array.clear(fillsArr)

// Maintain a bounded top-K structure of (index, score) pairs.
// Inserts freely until maxKeep is reached; after that, replaces the worst
// entry only if the new score is strictly better (lower distance).
f_insertBestMatch(array<int> idxArr, array<float> scoreArr, int idx, float score, int maxKeep) =>
    int arrSize = array.size(scoreArr)
    if arrSize < maxKeep
        array.push(idxArr, idx)
        array.push(scoreArr, score)
    else
        float worstScore = array.get(scoreArr, 0)
        int worstPos = 0
        for k = 1 to arrSize - 1
            float v = array.get(scoreArr, k)
            if v > worstScore
                worstScore := v
                worstPos := k
        if score < worstScore
            array.set(idxArr, worstPos, idx)
            array.set(scoreArr, worstPos, score)

// Paired bubble sort: sort idxArr by ascending scoreArr in one pass.
f_sortByScore(array<int> idxArr, array<float> scoreArr) =>
    int n = array.size(scoreArr)
    if n > 1
        for a = 0 to n - 2
            for b = 0 to n - a - 2
                float s1 = array.get(scoreArr, b)
                float s2 = array.get(scoreArr, b + 1)
                if s1 > s2
                    float tmpS = s1
                    int tmpI = array.get(idxArr, b)
                    array.set(scoreArr, b, s2)
                    array.set(idxArr, b, array.get(idxArr, b + 1))
                    array.set(scoreArr, b + 1, tmpS)
                    array.set(idxArr, b + 1, tmpI)

// Apply a one-pass EMA smoothing to src and write the result to dst.
// alpha=0 → no change; alpha→1 → heavily smoothed (slow to respond).
f_smoothPath(array<float> src, array<float> dst, float alpha) =>
    array.clear(dst)
    int sz = array.size(src)
    if sz > 0
        float prev = array.get(src, 0)
        array.push(dst, prev)
        for i = 1 to sz - 1
            float cur = array.get(src, i)
            float sm = prev * alpha + cur * (1.0 - alpha)
            array.push(dst, sm)
            prev := sm

// Push y2 and y3 upward if any pair of levels is closer than `spacing`.
// Used to prevent end-label overlap when the three scenario paths converge.
f_adjust3Levels(float y1, float y2, float y3, float spacing) =>
    float a = y1
    float b = y2
    float c = y3
    if math.abs(b - a) < spacing
        b := a + spacing
    if math.abs(c - b) < spacing
        c := b + spacing
    if math.abs(c - a) < spacing
        c := a + spacing * 2.0
    [a, b, c]

// Return true if `candidate` is at least `gap` bars away from every entry in idxArr.
// Prevents spatially overlapping analogs in the best-match list.
f_isFarEnoughFromChosen(array<int> idxArr, int candidate, int gap) =>
    bool ok = true
    int sz = array.size(idxArr)
    if sz > 0
        for i = 0 to sz - 1
            if math.abs(array.get(idxArr, i) - candidate) < gap
                ok := false
    ok

// Evaluate the power-law curve: price = (coeff × 1e17) × days^exponent / 1e17.
// The scale factor prevents float underflow when coeff is on the order of 1e-17.
f_powerScaled(float days, float coeff, float exponent) =>
    float out = na
    float scaleFactor = 1e17
    if days > 0
        float powerTerm = math.pow(days, exponent)
        out := (coeff * scaleFactor) * powerTerm / scaleFactor
    out

// Convenience wrapper for projecting a power-law curve daysForward from genesis.
f_projectPowerCurve(float daysForward, float coeff, float exponent) =>
    daysForward > 0 ? f_powerScaled(daysForward, coeff, exponent) : na

// Soft mean-reversion anchor: blend rawPrice toward the power-law band.
// `currentPos` = current bar's fairFloorPos; determines the pull target:
//   > 1.05  → above fair value : pull down toward 90% of the fair-floor range
//   < 0.20  → near the floor   : pull up   toward 25% of the fair-floor range
//   else    → inside range     : gentle centering pull toward 60%
// `biasStrength` scales the blend; 0 = no effect, 1 = full pull.
f_structuralAnchor(float rawPrice, float fairProj, float floorProj, float biasStrength, float currentPos) =>
    float out = rawPrice
    if not na(rawPrice) and not na(fairProj) and not na(floorProj)
        float rng = math.max(fairProj - floorProj, syminfo.mintick)
        float pos = (rawPrice - floorProj) / rng
        float pull = 0.0

        if currentPos > 1.05
            pull := -(pos - 0.90)
        else if currentPos < 0.20
            pull := (0.25 - pos)
        else
            pull := -(pos - 0.60) * 0.20

        pull := clampFloat(pull, -1.0, 1.0)
        out := rawPrice + (fairProj - rawPrice) * pull * biasStrength
    out

//══════════════════════════════════════════════════════════════════════════════
// POWER LAW — compute and plot the three structural curves on every bar
//══════════════════════════════════════════════════════════════════════════════
float daysSinceGenesis = (time - genesisTime) / 86400000.0   // elapsed days from genesis block
float fairSeries     = daysSinceGenesis > 0 ? f_powerScaled(daysSinceGenesis, A_fair, B) : na
float floorSeries    = daysSinceGenesis > 0 ? f_powerScaled(daysSinceGenesis, A_floor, B) : na
float midStairSeries = not na(fairSeries) and not na(floorSeries) ? (fairSeries + floorSeries) / 2.0 : na

plot(showFair     ? fairSeries     : na, title="Fair Value",  color=fairColor,     linewidth=powerLineWidth)
plot(showFloor    ? floorSeries    : na, title="Floor Price", color=floorColor,    linewidth=powerLineWidth)
plot(showMidStair ? midStairSeries : na, title="Mid-Stair",   color=midStairColor, linewidth=powerLineWidth)

//══════════════════════════════════════════════════════════════════════════════
// BASE FEATURES — computed every bar; used both for matching and for the
// structural context features fed into the similarity distance function
//══════════════════════════════════════════════════════════════════════════════
float eps = syminfo.mintick
float rng = math.max(high - low, eps)

// Candle geometry (all normalized by the bar's high-low range)
float bodyPct      = (close - open) / rng                          // body size and direction; negative = bearish candle
float upperWickPct = (high - math.max(open, close)) / rng          // upper shadow fraction
float lowerWickPct = (math.min(open, close) - low) / rng           // lower shadow fraction
float clv          = (close - low) / rng                           // close location value: 0 = at low, 1 = at high
float ret1         = nz(close[1]) != 0.0 ? (close / close[1] - 1.0) : 0.0 // 1-bar return

// Volatility
int atrLen   = 14
float atrv   = ta.atr(atrLen)
float atrPct = close != 0.0 ? atrv / close : 0.0                   // ATR as % of price — absolute volatility level
float rangeAtr = atrv != 0.0 ? rng / atrv : 0.0                    // bar range in ATR units — relative bar size

// Trend context
int maLen       = 50
float ma        = ta.sma(close, maLen)
float distMaAtr = atrv != 0.0 ? (close - ma) / atrv : 0.0          // (close − MA50) / ATR — signed trend distance

// Momentum and candle direction
int momLen     = 5
float momentum = nz(close[momLen]) != 0.0 ? (close / close[momLen] - 1.0) : 0.0 // 5-bar cumulative return
float dirVal   = close > open ? 1.0 : close < open ? -1.0 : 0.0    // +1 bullish, −1 bearish, 0 doji

float distFairPct  = not na(fairSeries) and fairSeries != 0.0 ? (close / fairSeries - 1.0) : na
float distFloorPct  = not na(floorSeries) and floorSeries != 0.0 ? (close / floorSeries - 1.0) : na   // % above floor
float fairFloorRange = not na(fairSeries) and not na(floorSeries) ? math.max(fairSeries - floorSeries, eps) : na
float fairFloorPos  = not na(fairFloorRange) ? clampFloat((close - floorSeries) / fairFloorRange, -1.0, 3.0) : na // 0=at floor, 1=at fair, >1=above fair
float fairSlopePct  = not na(fairSeries[1]) and fairSeries[1] != 0.0 ? (fairSeries / fairSeries[1] - 1.0) : 0.0   // day-over-day growth rate of fair curve
float floorSlopePct = not na(floorSeries[1]) and floorSeries[1] != 0.0 ? (floorSeries / floorSeries[1] - 1.0) : 0.0 // day-over-day growth rate of floor curve

float trendNow  = distMaAtr
bool isDaily    = timeframe.isdaily
bool enoughBars = bar_index > (patternLength * 2 + forecastHorizon + excludeRecentBars + 100)

//══════════════════════════════════════════════════════════════════════════════
// MATCH FUNCTIONS
//══════════════════════════════════════════════════════════════════════════════

// Compute the average weighted distance between two pattern windows.
// histOffset: bars-ago index of the historical window's most recent bar.
// refOffset : bars-ago index of the reference window's most recent bar (0 = current bar).
// Returns a per-bar-averaged score; lower = more similar.
f_getPatternDistance(int histOffset, int refOffset, int len, bool useL2) =>
    float score = 0.0
    for j = 0 to len - 1
        int h = histOffset + j
        int r = refOffset + j
        score += featureDiff(ret1[h], ret1[r], weightReturn, useL2)
        score += featureDiff(bodyPct[h], bodyPct[r], weightBody, useL2)
        score += featureDiff(upperWickPct[h], upperWickPct[r], weightWicks * 0.5, useL2)
        score += featureDiff(lowerWickPct[h], lowerWickPct[r], weightWicks * 0.5, useL2)
        score += featureDiff(rangeAtr[h], rangeAtr[r], weightVolatility, useL2)
        score += featureDiff(momentum[h], momentum[r], weightMomentum, useL2)
        score += featureDiff(distMaAtr[h], distMaAtr[r], weightTrend, useL2)
        score += featureDiff(clv[h], clv[r], 0.30, useL2)
        score += featureDiff(dirVal[h], dirVal[r], 0.15, useL2)
        score += featureDiff(distFairPct[h], distFairPct[r], weightDistFair, useL2)
        score += featureDiff(distFloorPct[h], distFloorPct[r], weightDistFloor, useL2)
        score += featureDiff(fairFloorPos[h], fairFloorPos[r], weightFairFloorPos, useL2)
        score += featureDiff(fairSlopePct[h], fairSlopePct[r], weightPowerSlope * 0.5, useL2)
        score += featureDiff(floorSlopePct[h], floorSlopePct[r], weightPowerSlope * 0.5, useL2)
    useL2 ? math.sqrt(score / len) : score / len

// Optional regime pre-filter applied before the full distance computation.
// Compares the rolling average trend (distMaAtr) and volatility (atrPct)
// of the two windows. Returns false if either metric is outside tolerance.
f_regimePass(int histOffset, int refOffset, int len, bool trendFilterOn, bool volFilterOn, float trTol, float volTol) =>
    float histTrend = ta.sma(distMaAtr, len)[histOffset]
    float refTrend  = ta.sma(distMaAtr, len)[refOffset]
    float histVol   = ta.sma(atrPct, len)[histOffset]
    float refVol    = ta.sma(atrPct, len)[refOffset]
    bool trendPass = not trendFilterOn or math.abs(histTrend - refTrend) <= trTol
    float volRatio = refVol != 0.0 ? histVol / refVol : 1.0
    bool volPass   = not volFilterOn or (volRatio >= 1.0 / volTol and volRatio <= volTol)
    trendPass and volPass

// Main analog scan: walk the history from scanMin to scanMax bars ago.
// For each candidate: check regime filter → check gap constraint → compute
// distance → insert into bounded top-K. Results are sorted best-first.
// refOffset = 0 ensures the reference pattern ends at the current bar,
// so the projection anchor (close[0]) and the pattern end are aligned.
f_scanMatches(array<int> outIdx, array<float> outScore, bool trendFilterOn, bool volFilterOn, float trTol, float volTol) =>
    array.clear(outIdx)
    array.clear(outScore)

    bool useL2    = similarityMode == "Weighted L2"
    int refOffset = 0                                                               // reference pattern ends at current bar
    int scanMax   = math.min(maxHistoryBarsToScan, bar_index - patternLength - forecastHorizon - 10)
    int scanMin   = excludeRecentBars + forecastHorizon                             // each candidate must have forecastHorizon bars of future available

    if scanMax > scanMin
        for startOffset = scanMin to scanMax
            bool regimeOk = f_regimePass(startOffset, refOffset, patternLength, trendFilterOn, volFilterOn, trTol, volTol)
            bool gapOk = f_isFarEnoughFromChosen(outIdx, startOffset, minGapBetweenMatches)
            if regimeOk and gapOk
                float score = f_getPatternDistance(startOffset, refOffset, patternLength, useL2)
                f_insertBestMatch(outIdx, outScore, startOffset, score, topMatches)

        f_sortByScore(outIdx, outScore)

//══════════════════════════════════════════════════════════════════════════════
// STORAGE — persistent arrays for drawn objects and computed paths
// All line/fill/label arrays are cleared and rebuilt on every last bar.
//══════════════════════════════════════════════════════════════════════════════

// Forecast line objects
var array<line>     centralLines  = array.new_line()
var array<line>     bullLines     = array.new_line()
var array<line>     bearLines     = array.new_line()
var array<line>     bullGradLines = array.new_line()     // intermediate lines used to build the gradient fill
var array<line>     bearGradLines = array.new_line()
var array<linefill> forecastFills = array.new_linefill()

var array<label> matchLabels = array.new_label()
var array<label> endLabels   = array.new_label()

// Raw and smoothed forecast paths (one float per horizon step, h = 1..forecastHorizon)
var array<float> centralPath   = array.new_float()
var array<float> bullPath      = array.new_float()
var array<float> bearPath      = array.new_float()
var array<float> centralPathSm = array.new_float()
var array<float> bullPathSm    = array.new_float()
var array<float> bearPathSm    = array.new_float()

// Best-match data (populated by f_scanMatches + the path-building loop)
var array<int>   bestIdxs         = array.new_int()
var array<float> bestScores       = array.new_float()
var array<float> bestFinalReturns = array.new_float()   // total return of each analog at h=forecastHorizon
var array<float> bestWeights      = array.new_float()   // similarity weight of each analog

var table dash = table.new(position.bottom_right, 2, 10, border_width=1)

// Dashboard state variables
var string statusText  = "Idle"
var string regimeText  = "N/A"
var float  avgScore    = na
var float  confidence  = na
var int    validMatches = 0
var bool   fallbackUsed = false

// Scenario probability outputs
var float centralProb = na
var float bullProb    = na
var float bearProb    = na
var float lowerCut    = na   // P25 of final returns, floored by ATR threshold — dashboard P25-P75 row only
var float upperCut    = na   // P75 of final returns, floored by ATR threshold — dashboard P25-P75 row only
var float probSum     = na

// Power-law curve labels (refreshed on every last bar)
var label fairLabel     = na
var label floorLabel    = na
var label midStairLabel = na

// Structural regime state (used by the bias logic and the dashboard)
var string structuralState = "Neutral"
var color  structuralColor = color.silver

//══════════════════════════════════════════════════════════════════════════════
// BTC HALVINGS
//══════════════════════════════════════════════════════════════════════════════
var array<label> halvingLabels = array.new_label()
var array<line> halvingLines = array.new_line()

f_clearHalvingObjects() =>
    int lblSz = array.size(halvingLabels)
    if lblSz > 0
        for i = 0 to lblSz - 1
            label.delete(array.get(halvingLabels, i))
    array.clear(halvingLabels)

    int lnSz = array.size(halvingLines)
    if lnSz > 0
        for i = 0 to lnSz - 1
            line.delete(array.get(halvingLines, i))
    array.clear(halvingLines)

f_drawHalving(int eventTime, string txt, color col, bool isFuture, float yTop, float yBottom) =>
    float eventHigh = ta.valuewhen(time >= eventTime and time[1] < eventTime, high, 0)
    float labelY = isFuture ? yBottom : na(eventHigh) ? yTop : eventHigh * 1.02

    if showHalvingLines
        line ln = line.new(eventTime, yBottom, eventTime, yTop, xloc=xloc.bar_time, extend=extend.none, color=color.new(col, 60), style=line.style_dashed, width=1)
        array.push(halvingLines, ln)

    label lb = label.new(
         x=eventTime,
         y=labelY,
         text=txt,
         xloc=xloc.bar_time,
         yloc=yloc.price,
         style=isFuture ? label.style_label_up : label.style_label_down,
         textcolor=col,
         color=color.new(color.black, 78),
         size=halvingLabelSize)
    array.push(halvingLabels, lb)

//══════════════════════════════════════════════════════════════════════════════
// CALCULATION — runs only on the last bar to rebuild the entire forecast.
// Execution order:
//   1. Reset state
//   2. Determine structural regime
//   3. Scan for best analogs (with optional adaptive fallback)
//   4. Compute per-match final returns → derive p25/p75 scenario thresholds
//   5. Build coherent scenario paths (weighted avg per group, per step)
//   6. Smooth paths
//   7. Compute P25-P75 ATR-adjusted cuts (dashboard display only)
//   8. Compute scenario probabilities (aligned with path grouping)
//   9. Optional structural probability adjustment
//   10-12. Draw lines, fills and end labels
//══════════════════════════════════════════════════════════════════════════════
bool doCalc = barstate.islast

if doCalc
    // ── 1. Reset paths, drawn objects and all state variables ────────────────
    array.clear(centralPath)
    array.clear(bullPath)
    array.clear(bearPath)
    array.clear(centralPathSm)
    array.clear(bullPathSm)
    array.clear(bearPathSm)
    array.clear(bestFinalReturns)
    array.clear(bestWeights)

    f_clearLines(centralLines)
    f_clearLines(bullLines)
    f_clearLines(bearLines)
    f_clearLines(bullGradLines)
    f_clearLines(bearGradLines)
    f_clearLineFills(forecastFills)
    f_clearLabels(matchLabels)
    f_clearLabels(endLabels)
    f_clearHalvingObjects()

    avgScore     := na
    confidence   := na
    validMatches := 0
    fallbackUsed := false
    regimeText   := "N/A"
    statusText   := "Scanning"
    centralProb  := na
    bullProb     := na
    bearProb     := na
    lowerCut     := na
    upperCut     := na
    probSum      := na
    structuralState := "Neutral"
    structuralColor := color.silver

    // ── 2. Determine structural regime (for bias direction and dashboard) ────
    if not na(fairFloorPos)
        if fairFloorPos > 1.05
            structuralState := "Above Fair"
            structuralColor := bearColor
        else if fairFloorPos < 0.20
            structuralState := "Near Floor"
            structuralColor := bullColor
        else
            structuralState := "Inside Range"
            structuralColor := color.aqua

    if dailyOnlyMode and not isDaily
        statusText := "Daily Only"
    else if not enoughBars
        statusText := "Dataset Too Short"
    else
        // ── 3. Find best analogs; retry with relaxed filters if too few found ─
        f_scanMatches(bestIdxs, bestScores, useTrendFilter, useVolatilityFilter, trendTolerance, volatilityTolerance)
        validMatches := array.size(bestIdxs)

        if validMatches < minRequiredMatches and useAdaptiveFallback
            f_scanMatches(bestIdxs, bestScores, false, false, trendTolerance * 2.0, volatilityTolerance * 2.0)
            validMatches := array.size(bestIdxs)
            fallbackUsed := true

        if validMatches < minRequiredMatches
            statusText := "Few Matches"
        else
            statusText := fallbackUsed ? "Fallback Ready" : "Ready"

            // Average similarity score → confidence indicator (higher score = less confident)
            array<float> validScores = array.new_float()
            for i = 0 to array.size(bestScores) - 1
                float s = array.get(bestScores, i)
                if not na(s)
                    array.push(validScores, s)

            avgScore := f_avgFloatArray(validScores)

            if not na(avgScore)
                float confidenceRaw = avgScore > 0.0 ? 1.0 / (1.0 + avgScore * 8.0) : 1.0
                confidence := clampFloat(confidenceRaw * 100.0, 0.0, 100.0)

            // ── 4. Per-match final returns and weights ───────────────────────
            // matchFinalRets[m] = cumulative return of analog m over the full
            // forecast horizon. Used to split analogs into scenario groups.
            // bestFinalReturns/bestWeights are also stored for the P25-P75 dashboard row.
            array<float> matchFinalRets = array.new_float()
            for m = 0 to validMatches - 1
                int startOff      = array.get(bestIdxs, m)
                float baseClose   = close[startOff]
                float futureClose = close[startOff - forecastHorizon]
                float finalRet    = not na(futureClose) and baseClose != 0.0 ? (futureClose / baseClose - 1.0) : 0.0
                float score       = array.get(bestScores, m)
                float w           = useWeightedProb and not na(score) ? math.pow(1.0 / math.max(score, 0.0001), weightPower) : 1.0
                array.push(matchFinalRets, finalRet)
                if not na(futureClose) and baseClose != 0.0
                    array.push(bestFinalReturns, finalRet)
                    array.push(bestWeights, w)

            // ── 5. Scenario thresholds ───────────────────────────────────────
            // p25/p75 define the three groups used for BOTH paths and probabilities:
            //   bull    : finalRet >= p75  (top 25%)
            //   bear    : finalRet <= p25  (bottom 25%)
            //   central : everything else  (middle 50%)
            array<float> sortedFinals = array.copy(matchFinalRets)
            f_sortFloatArray(sortedFinals)
            float p25Final = f_percentileFromSorted(sortedFinals, 0.25)
            float p75Final = f_percentileFromSorted(sortedFinals, 0.75)

            // ── 6. Build coherent scenario paths ────────────────────────────
            // For each step h: project each analog's historical return onto the
            // current close, then accumulate weighted sums per scenario group.
            // The structural bias fades in over the horizon to avoid a spike at h=1.
            for h = 1 to forecastHorizon
                float sumBull = 0.0
                float wBull   = 0.0
                float sumCent = 0.0
                float wCent   = 0.0
                float sumBear = 0.0
                float wBear   = 0.0

                for m = 0 to validMatches - 1
                    int startOff = array.get(bestIdxs, m)
                    float baseClose = close[startOff]
                    float futureClose = close[startOff - h]
                    if not na(futureClose) and baseClose != 0.0
                        float stepRet = futureClose / baseClose - 1.0
                        float projPrice = close * (1.0 + stepRet)
                        float score = array.get(bestScores, m)
                        float w = useWeightedProb and not na(score) ? math.pow(1.0 / math.max(score, 0.0001), weightPower) : 1.0
                        float finalRet = array.get(matchFinalRets, m)
                        if finalRet >= p75Final
                            sumBull += projPrice * w
                            wBull   += w
                        else if finalRet <= p25Final
                            sumBear += projPrice * w
                            wBear   += w
                        else
                            sumCent += projPrice * w
                            wCent   += w

                float daysFwd   = daysSinceGenesis + h
                float fairProj  = f_projectPowerCurve(daysFwd, A_fair, B)
                float floorProj = f_projectPowerCurve(daysFwd, A_floor, B)

                float centralPrice = wCent > 0.0 ? sumCent / wCent : close
                float bullPrice    = wBull > 0.0 ? sumBull / wBull : close
                float bearPrice    = wBear > 0.0 ? sumBear / wBear : close

                // Bias fades in linearly so paths don't spike at h=1
                float biasFade = float(h) / float(forecastHorizon)
                float effBias  = structuralBiasPower * biasFade
                float cAdj = useStructuralBias ? f_structuralAnchor(centralPrice, fairProj, floorProj, effBias, nz(fairFloorPos, 0.60)) : centralPrice
                float bAdj = useStructuralBias ? f_structuralAnchor(bullPrice, fairProj, floorProj, effBias * 0.75, nz(fairFloorPos, 0.60)) : bullPrice
                float sAdj = useStructuralBias ? f_structuralAnchor(bearPrice, fairProj, floorProj, effBias * 0.75, nz(fairFloorPos, 0.60)) : bearPrice

                array.push(centralPath, cAdj)
                array.push(bullPath, bAdj)
                array.push(bearPath, sAdj)

            // ── 7. Smooth all three paths ────────────────────────────────────
            f_smoothPath(centralPath, centralPathSm, forecastSmoothing)
            f_smoothPath(bullPath, bullPathSm, forecastSmoothing)
            f_smoothPath(bearPath, bearPathSm, forecastSmoothing)

            // ── 8. ATR-adjusted P25-P75 cuts (dashboard row only) ────────────
            // lowerCut/upperCut are NOT used for path grouping; they provide an
            // ATR-anchored view of the return distribution in the P25-P75 row.
            int validFinalCount = array.size(bestFinalReturns)
            if validFinalCount > 0
                array<float> sortedFinal = array.copy(bestFinalReturns)
                f_sortFloatArray(sortedFinal)
                float dynThreshold = math.max(minReturnThreshold, atrPct * probabilityATRMultiplier)
                lowerCut := math.min(f_percentileFromSorted(sortedFinal, 0.25), -dynThreshold)
                upperCut := math.max(f_percentileFromSorted(sortedFinal, 0.75), dynThreshold)

            // ── 9. Scenario probabilities ────────────────────────────────────
            // Uses the same p25/p75 thresholds as the path grouping so the
            // displayed % directly corresponds to the fraction of weighted
            // analogs in each group. Sum is always exactly 100%.
            float wBullTot = 0.0
            float wCentTot = 0.0
            float wBearTot = 0.0
            float wAllTot  = 0.0
            for m = 0 to validMatches - 1
                float score    = array.get(bestScores, m)
                float w        = useWeightedProb and not na(score) ? math.pow(1.0 / math.max(score, 0.0001), weightPower) : 1.0
                float finalRet = array.get(matchFinalRets, m)
                if finalRet >= p75Final
                    wBullTot += w
                else if finalRet <= p25Final
                    wBearTot += w
                else
                    wCentTot += w
                wAllTot += w
            if wAllTot > 0.0
                bullProb    := wBullTot / wAllTot * 100.0
                centralProb := wCentTot / wAllTot * 100.0
                bearProb    := wBearTot / wAllTot * 100.0
                probSum     := 100.0

            // ── 10 (optional). Structural adjustment on probabilities ─────────
            // Multiplies each scenario's probability by a factor based on the
            // current power-law position. Off by default: near the floor the
            // bull boost can equalize bull and central, which looks confusing.
            if useStructuralProb and not na(fairFloorPos) and not na(bullProb) and not na(bearProb) and not na(centralProb)
                float bullAdj    = bullProb
                float bearAdj    = bearProb
                float centralAdj = centralProb

                if fairFloorPos > 1.05
                    bullAdj    := bullAdj    * (1.0 - structuralBiasPower * 0.60)
                    bearAdj    := bearAdj    * (1.0 + structuralBiasPower * 0.85)
                    centralAdj := centralAdj * (1.0 + structuralBiasPower * 0.10)
                else if fairFloorPos < 0.20
                    bullAdj    := bullAdj    * (1.0 + structuralBiasPower * 0.85)
                    bearAdj    := bearAdj    * (1.0 - structuralBiasPower * 0.60)
                    centralAdj := centralAdj * (1.0 + structuralBiasPower * 0.10)

                float totAdj = bullAdj + bearAdj + centralAdj
                if totAdj > 0.0
                    bullProb    := bullAdj    * 100.0 / totAdj
                    bearProb    := bearAdj    * 100.0 / totAdj
                    centralProb := centralAdj * 100.0 / totAdj
                    probSum := bullProb + bearProb + centralProb

            // ── 11. Draw forecast lines ──────────────────────────────────────
            if showCentralForecast and array.size(centralPathSm) == forecastHorizon
                line ln0 = line.new(bar_index, close, bar_index + 1, array.get(centralPathSm, 0), xloc=xloc.bar_index, extend=extend.none, color=centralColor, width=lineWidthCentral)
                array.push(centralLines, ln0)
                for h = 2 to forecastHorizon
                    line ln = line.new(bar_index + h - 1, array.get(centralPathSm, h - 2), bar_index + h, array.get(centralPathSm, h - 1), xloc=xloc.bar_index, extend=extend.none, color=centralColor, width=lineWidthCentral)
                    array.push(centralLines, ln)

            if showBullBearBands and array.size(bullPathSm) == forecastHorizon and array.size(bearPathSm) == forecastHorizon
                line lnBull0 = line.new(bar_index, close, bar_index + 1, array.get(bullPathSm, 0), xloc=xloc.bar_index, extend=extend.none, color=color.new(bullColor, 10), width=lineWidthScenarios, style=line.style_dashed)
                line lnBear0 = line.new(bar_index, close, bar_index + 1, array.get(bearPathSm, 0), xloc=xloc.bar_index, extend=extend.none, color=color.new(bearColor, 10), width=lineWidthScenarios, style=line.style_dashed)
                array.push(bullLines, lnBull0)
                array.push(bearLines, lnBear0)

                for h = 2 to forecastHorizon
                    line lnB = line.new(bar_index + h - 1, array.get(bullPathSm, h - 2), bar_index + h, array.get(bullPathSm, h - 1), xloc=xloc.bar_index, extend=extend.none, color=color.new(bullColor, 10), width=lineWidthScenarios, style=line.style_dashed)
                    line lnS = line.new(bar_index + h - 1, array.get(bearPathSm, h - 2), bar_index + h, array.get(bearPathSm, h - 1), xloc=xloc.bar_index, extend=extend.none, color=color.new(bearColor, 10), width=lineWidthScenarios, style=line.style_dashed)
                    array.push(bullLines, lnB)
                    array.push(bearLines, lnS)

            // ── 12. Gradient fill ────────────────────────────────────────────
            // Creates `fillLayers` intermediate lines between each scenario and
            // the central path, then fills adjacent pairs with decreasing opacity
            // to produce a soft probability-density visual.
            if showForecastFill and array.size(centralPathSm) == forecastHorizon and array.size(bullPathSm) == forecastHorizon and array.size(bearPathSm) == forecastHorizon
                for layer = 1 to fillLayers
                    float t = layer / fillLayers
                    int op = int(math.round(f_interp(fillOpacityOuter, fillOpacityInner, t)))

                    array<float> bullMid = array.new_float()
                    array<float> bearMid = array.new_float()

                    for h = 0 to forecastHorizon - 1
                        float cen = array.get(centralPathSm, h)
                        float bul = array.get(bullPathSm, h)
                        float ber = array.get(bearPathSm, h)
                        array.push(bullMid, f_interp(bul, cen, t))
                        array.push(bearMid, f_interp(ber, cen, t))

                    line bullMid0 = line.new(bar_index, close, bar_index + 1, array.get(bullMid, 0), xloc=xloc.bar_index, extend=extend.none, color=color.new(bullColor, 100), width=1)
                    array.push(bullGradLines, bullMid0)

                    line bearMid0 = line.new(bar_index, close, bar_index + 1, array.get(bearMid, 0), xloc=xloc.bar_index, extend=extend.none, color=color.new(bearColor, 100), width=1)
                    array.push(bearGradLines, bearMid0)

                    for h = 2 to forecastHorizon
                        line bullMidLn = line.new(bar_index + h - 1, array.get(bullMid, h - 2), bar_index + h, array.get(bullMid, h - 1), xloc=xloc.bar_index, extend=extend.none, color=color.new(bullColor, 100), width=1)
                        array.push(bullGradLines, bullMidLn)

                        line bearMidLn = line.new(bar_index + h - 1, array.get(bearMid, h - 2), bar_index + h, array.get(bearMid, h - 1), xloc=xloc.bar_index, extend=extend.none, color=color.new(bearColor, 100), width=1)
                        array.push(bearGradLines, bearMidLn)

                    int segCount = forecastHorizon
                    int bullBaseStart = (layer - 1) * segCount
                    int bearBaseStart = (layer - 1) * segCount

                    for s = 0 to segCount - 1
                        line bullOuter = layer == 1 ? array.get(bullLines, s) : array.get(bullGradLines, (layer - 2) * segCount + s)
                        line bullInner = array.get(bullGradLines, bullBaseStart + s)
                        linefill bf = linefill.new(bullOuter, bullInner, color.new(bullColor, op))
                        array.push(forecastFills, bf)

                        line bearOuter = layer == 1 ? array.get(bearLines, s) : array.get(bearGradLines, (layer - 2) * segCount + s)
                        line bearInner = array.get(bearGradLines, bearBaseStart + s)
                        linefill sf = linefill.new(bearOuter, bearInner, color.new(bearColor, op))
                        array.push(forecastFills, sf)

            // ── 13. End labels ───────────────────────────────────────────────
            // Levels are spaced by f_adjust3Levels to prevent overlap when paths converge.
            if showEndLabels and array.size(centralPathSm) > 0
                float lastCentral = array.get(centralPathSm, array.size(centralPathSm) - 1)
                float lastBull = array.get(bullPathSm, array.size(bullPathSm) - 1)
                float lastBear = array.get(bearPathSm, array.size(bearPathSm) - 1)

                float spacing = atrv * 0.40
                [adjBear, adjCentral, adjBull] = f_adjust3Levels(lastBear, lastCentral, lastBull, spacing)

                label lbCentral = label.new(bar_index + forecastHorizon + 1, adjCentral, "central " + (na(centralProb) ? "n/a" : str.tostring(centralProb, "#.1") + "%"), style=label.style_label_left, textcolor=centralColor, color=color.new(color.black, 78), size=labelSize)
                array.push(endLabels, lbCentral)

                if showBullBearBands
                    label lbBull = label.new(bar_index + forecastHorizon + 1, adjBull, "bull " + (na(bullProb) ? "n/a" : str.tostring(bullProb, "#.1") + "%"), style=label.style_label_left, textcolor=bullColor, color=color.new(color.black, 78), size=labelSize)
                    label lbBear = label.new(bar_index + forecastHorizon + 1, adjBear, "bear " + (na(bearProb) ? "n/a" : str.tostring(bearProb, "#.1") + "%"), style=label.style_label_left, textcolor=bearColor, color=color.new(color.black, 78), size=labelSize)
                    array.push(endLabels, lbBull)
                    array.push(endLabels, lbBear)

            // Optional: mark each analog's end point on the historical chart (debug aid)
            if showMatchMarkers
                for m = 0 to validMatches - 1
                    int startOff = array.get(bestIdxs, m)
                    label lb = label.new(bar_index - startOff, high[startOff], "m" + str.tostring(m + 1), style=label.style_label_down, textcolor=color.white, color=color.new(centralColor, 55), size=size.tiny)
                    array.push(matchLabels, lb)

            regimeText := trendNow > 0.5 ? "Uptrend" : trendNow < -0.5 ? "Downtrend" : "Range"

    // ── Halving markers drawn regardless of forecast readiness ─────────────
    if showHalvings
        int halving2012    = timestamp("UTC", 2012, 11, 28, 0, 0)
        int halving2016    = timestamp("UTC", 2016, 7,  9, 0, 0)
        int halving2020    = timestamp("UTC", 2020, 5, 11, 0, 0)
        int halving2024    = timestamp("UTC", 2024, 4, 20, 0, 0)
        int halving2028est = timestamp("UTC", 2028, 4, 20, 0, 0)  // estimated; actual date may vary ±1 week

        float yTop = ta.highest(high, math.min(bar_index + 1, 500)) * 1.08
        float yBottom = ta.lowest(low, math.min(bar_index + 1, 500)) * 0.92

        if showPastHalvings
            f_drawHalving(halving2012, "BTC Halving 2012", halvingColorPast, false, yTop, yBottom)
            f_drawHalving(halving2016, "BTC Halving 2016", halvingColorPast, false, yTop, yBottom)
            f_drawHalving(halving2020, "BTC Halving 2020", halvingColorPast, false, yTop, yBottom)
            f_drawHalving(halving2024, "BTC Halving 2024", halvingColorPast, false, yTop, yBottom)

        if showFutureHalvings
            f_drawHalving(halving2028est, "BTC Halving 2028 (est.)", halvingColorFuture, true, yTop, yBottom)

//══════════════════════════════════════════════════════════════════════════════
// POWER LAW LABELS — refresh the right-edge price labels on every last bar
//══════════════════════════════════════════════════════════════════════════════
if barstate.islast
    label.delete(fairLabel)
    label.delete(floorLabel)
    label.delete(midStairLabel)
    fairLabel     := na
    floorLabel    := na
    midStairLabel := na

    if showPowerLabels
        if showFair and not na(fairSeries)
            fairLabel := label.new(
                 bar_index,
                 fairSeries,
                 "Fair: " + f_formatPrice(fairSeries),
                 style=label.style_label_left,
                 textcolor=color.black,
                 color=fairColor,
                 size=size.normal)

        if showFloor and not na(floorSeries)
            floorLabel := label.new(
                 bar_index,
                 floorSeries,
                 "Floor: " + f_formatPrice(floorSeries),
                 style=label.style_label_left,
                 textcolor=color.white,
                 color=floorColor,
                 size=size.normal)

        if showMidStair and not na(midStairSeries)
            midStairLabel := label.new(
                 bar_index,
                 midStairSeries,
                 "Mid-Stair: " + f_formatPrice(midStairSeries),
                 style=label.style_label_left,
                 textcolor=color.black,
                 color=midStairColor,
                 size=size.normal)

//══════════════════════════════════════════════════════════════════════════════
// WARNINGS — show a prominent label when the indicator cannot run correctly
//══════════════════════════════════════════════════════════════════════════════
var label warnLabel = na

if barstate.islast
    label.delete(warnLabel)
    warnLabel := na

    string msg = ""
    if dailyOnlyMode and not isDaily
        msg := "This model is optimized for DAILY charts."
    else if not enoughBars
        msg := "Not enough bars for the selected configuration."
    else if statusText == "Few Matches"
        msg := "Too few analogs found. Try shorter patterns or looser filters."

    if str.length(msg) > 0
        warnLabel := label.new(bar_index, high, msg, style=label.style_label_down, color=color.new(color.orange, 0), textcolor=color.white, size=size.small)

//══════════════════════════════════════════════════════════════════════════════
// DASHBOARD — status panel with key model outputs
// Rows: State, Regime, Matches, Horizon, Bull/Central/Bear %, P25-P75, PL Pos, Structural Bias
//══════════════════════════════════════════════════════════════════════════════
color stateColor  = statusText == "Ready" ? color.lime : statusText == "Fallback Ready" ? color.aqua : statusText == "Scanning" ? color.yellow : color.orange
color regimeColor = regimeText == "Uptrend" ? bullColor : regimeText == "Downtrend" ? bearColor : color.silver

if barstate.isfirst
    dash := table.new(dashPos, 2, 10, border_width=1)

if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "State", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 0, statusText, text_color=stateColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 1, "Regime", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 1, regimeText, text_color=regimeColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 2, "Matches", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 2, str.tostring(validMatches), text_color=chart.fg_color, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 3, "Horizon", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 3, str.tostring(forecastHorizon), text_color=chart.fg_color, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 4, "Bull %", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 4, na(bullProb) ? "N/A" : str.tostring(bullProb, "#.1") + "%", text_color=bullColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 5, "Central %", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 5, na(centralProb) ? "N/A" : str.tostring(centralProb, "#.1") + "%", text_color=centralColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 6, "Bear %", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 6, na(bearProb) ? "N/A" : str.tostring(bearProb, "#.1") + "%", text_color=bearColor, text_halign=text.align_center, text_size=dashTextSize)

    string cutsTxt = na(lowerCut) or na(upperCut) ? "N/A" : str.tostring(lowerCut * 100.0, "#.1") + "% / " + str.tostring(upperCut * 100.0, "#.1") + "%"
    table.cell(dash, 0, 7, "P25-P75", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 7, cutsTxt, text_color=chart.fg_color, text_halign=text.align_center, text_size=dashTextSize)

    string posTxt = na(fairFloorPos) ? "N/A" : str.tostring(fairFloorPos, "#.00")
    table.cell(dash, 0, 8, "PL Pos", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 8, posTxt, text_color=structuralColor, text_halign=text.align_center, text_size=dashTextSize)

    string biasTxt = useStructuralBias ? structuralState : "Off"
    table.cell(dash, 0, 9, "Structural Bias", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 9, biasTxt, text_color=structuralColor, text_halign=text.align_center, text_size=dashTextSize)

if barstate.islast and not showDashboard
    table.clear(dash, 0, 0, 1, 9)
````
