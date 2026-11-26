# Moving Average Structure Matrix

- url: https://www.tradingview.com/script/aOctBJE9-Moving-Average-Structure-Matrix/
- type: indicator
- pine_id: PUB;93b929eb49584ef5932e4ea762030133
- version: 3.0

## Description

Moving Average Structure Matrix is not a basic multi-MA ribbon.

The moving-average lines are only the visible base layer. The main contribution is a neutral MA structure layer that quantifies how the enabled moving averages are ordered, clustered, twisting, and positioned relative to the selected source.

This script is designed for traders who want quick structural context from multiple EMA/SMA lines without relying only on visual inspection. It is a context and visualization tool only. It does not provide trade-action instructions and it is not a trading system.

What it shows

- Up to 8 user-configurable EMA/SMA slots.
- A moving-average ensemble centerline.
- The high and low boundary of the enabled MA group.
- Optional fill between the MA bundle boundaries.
- A compact context table.
- Optional factual event labels.
- Neutral alert conditions for structure changes.

The MA lines are useful visually, but the structure layer is the main feature.

Core structure fields

Pairwise Stack Score

The script compares enabled moving averages pair by pair.

For each pair with different lengths, the shorter-length MA is treated as the faster MA and the longer-length MA as the slower MA.

If the faster MA is meaningfully above the slower MA, the pair contributes positively.
If the faster MA is meaningfully below the slower MA, the pair contributes negatively.
If the pair is too close to classify, it contributes as tied.

The Stack Score summarizes this pairwise ordering on an approximate -100 to +100 scale.

A positive Stack Score means shorter MAs are generally above longer MAs.
A negative Stack Score means shorter MAs are generally below longer MAs.
A value near zero means the group is mixed or tied.

Order Purity

Order Purity measures how much of the eligible pairwise structure agrees with the dominant side.

For example, a high positive Stack Score with high Order Purity describes a cleaner upward ordering of shorter and longer averages. A mixed pair structure will usually show lower purity.

Order Purity is descriptive only. It is not a forecast or a trade instruction.

Tie Ratio

Tie Ratio measures how many eligible MA pairs are too close to classify after applying the stack-separation threshold.

A higher Tie Ratio means more of the MA group is structurally tied or compressed into similar values.

Slope Consensus

Slope Consensus measures how many enabled moving averages are rising, falling, or flat over the selected slope lookback.

Each enabled MA receives a slope sign:

- rising
- falling
- flat

The Slope Score summarizes the group on an approximate -100 to +100 scale.

Bundle Width and Width Rank

The script calculates the high and low values of the enabled MA group.

Bundle Width measures the distance between those two boundaries.

Bundle Width % expresses that distance relative to the MA centroid.

Width Rank compares the current bundle width with its own recent history. This is a moving-average bundle context only. It is not a volatility regime and it does not forecast future movement.

Width context can read as:

- Clustered
- Middle width
- Wide bundle
- n/a

Twist Rate

Twist Rate describes internal reordering of the MA group.

For each eligible fast/slow pair, the script compares the current pair relationship with the previous bar's relationship. When a pair changes from one ordered side to the other, it counts as a twist.

Twist Rate summarizes how much internal crossing or reordering has occurred over the selected lookback.

This helps distinguish a clean MA structure from a churning or mixed MA group.

Fast/Slow Cohort Spread

The script can compare shorter-length and longer-length MA groups.

The fast cohort contains shorter MAs.
The slow cohort contains longer MAs.

Cohort Spread % compares the average position of the fast cohort with the average position of the slow cohort.

This gives a second view of the structure beyond individual pair comparisons.

Source-vs-Bundle location

The selected source can be:

- Above bundle
- Inside bundle
- Below bundle
- n/a

The script also calculates Bundle Position %, which describes where the source sits relative to the current MA bundle.

Values can be below 0 or above 100 when the source is outside the bundle.

Structure State

The script combines stack ordering, order purity, slope consensus, bundle width context, twist rate, and source location into a neutral state label.

Possible states include:

- Need 2+ MAs
- Need different MA lengths
- Warming up
- Ordered upward
- Ordered downward
- Upward stack / mixed slopes
- Downward stack / mixed slopes
- Churning bundle
- Clustered mixed bundle
- Flat bundle
- Transitioning upward
- Transitioning downward
- Intermixed

These states describe the current MA structure. They do not imply continuation or reversal.

Structure Age

Structure Age counts how long the current structure state has persisted.

The script uses distinct internal state IDs, so the age resets when the actual structure state changes, not just when broad direction changes.

Structure Fingerprint

The Fingerprint is a compact summary of the current MA structure.

Example:

O+ S+ Wm Pa A34

Meaning:

- O+ means positive stack polarity.
- O- means negative stack polarity.
- O0 means no clear stack polarity.
- S+ means positive slope consensus.
- S- means negative slope consensus.
- S0 means no clear slope consensus.
- Wc means clustered width.
- Wm means middle width.
- Ww means wide bundle.
- Wn means width unavailable.
- Pa means source above the bundle.
- Pi means source inside the bundle.
- Pb means source below the bundle.
- Pn means source location unavailable.
- A shows the current structure age.

The Fingerprint is a compact context summary. It is not a trade instruction.

Structure Footprint

The Footprint expands the context by combining:

- Structure age
- Previous state age
- Width motion
- Twist Rate
- Order Purity
- Tie Ratio

This helps users read how the MA group is currently organized without relying only on line spacing.

Context table

The default context table is compact and placed in the upper-right area.

Compact layout shows:

- State
- Fingerprint
- Stack Score
- Slope Score
- Width / Twist
- Price location
- Structure Age

Standard and Detailed layouts add more research fields, including:

- Footprint
- Order Purity
- Tie Ratio
- Twist Rate
- Cohort Spread
- Bundle Width %
- Width Rank
- Bundle Position %
- Enabled MA count
- Eligible pairs
- Equal-length pairs skipped
- Up / Down / Tied pair counts
- Fast / Slow cohort counts
- Centroid
- Bundle high
- Bundle low
- Active warm-up bars
- State ID
- Enabled MA names

Research fields are available in the Detailed context table without adding extra chart plots. The context table is the primary research surface.

Events and labels

Event labels are optional and off by default.

When enabled, labels are factual and neutral. They describe events such as:

- structure became ordered upward
- structure became ordered downward
- structure became intermixed
- bundle entered churning context
- bundle entered clustered width context
- bundle left clustered width context
- source moved above the MA bundle
- source moved below the MA bundle
- source crossed the MA centroid

Event markers use capped labels rather than plotshape markers, so the script stays within TradingView's plot-count limit. Older labels are removed after the user-defined label cap is reached.

Alerts

The script includes factual alert conditions for the same structure events.

Alerts respect the selected confirmed-bar behavior by default. Intrabar mode is available, but realtime values can update until the bar closes.

Customization

Users can adjust:

- source
- slope lookback
- warm-up behavior
- EMA/SMA type for each MA slot
- length for each MA slot
- color, width, transparency, and name for each MA slot
- stack separation threshold
- ordered stack threshold
- order purity threshold
- slope flat threshold
- slope consensus threshold
- width-rank lookback
- clustered / wide width thresholds
- twist lookback
- churning twist threshold
- cohort split length
- automatic cohort split
- event persistence
- event cooldown
- context table layout
- context table position
- table text size
- table colors
- marker colors
- envelope colors
- fill transparency

Visual customization does not affect calculations.

Most input values are hidden from the chart status line by default to keep the chart label compact. All inputs remain available in the Settings / Inputs tab.

Different from other tools

This script does not use ATR channels, session shading, volatility-regime classification, VWAP, volume weighting, or RSI slope divergence.

It focuses only on the geometry of an enabled EMA/SMA ensemble.

Limitations

Moving averages lag by design.

A clean MA structure does not guarantee continuation.

A churning MA structure does not imply reversal.

MA order can persist, unwind, or flip.

Default lengths are common visual reference points, not optimized settings.

Width and cluster context are descriptive of the enabled MA group and its own history.

Changing enabled MAs, lengths, or thresholds changes the structure readings.

This script is not financial advice and not a trading system.

Japanese notes

このスクリプトは単なる複数移動平均線ではなく、EMA/SMA群の並び、純度、近接度、傾きの一致、束の広がり、ねじれ、価格位置、状態の継続時間を構造として表示する可視化ツールです。売買判断や将来予測ではなく、MA群の現在の構造を把握するための補助として設計しています。

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ©SG Group
//@version=6
indicator("Moving Average Structure Matrix - Regime Transition Lab", overlay = true, format = format.price, max_bars_back = 5000, max_labels_count = 350, max_lines_count = 10, dynamic_requests = true, explicit_plot_zorder = false, behind_chart = true)

// ============================================================================
// Moving Average Structure Matrix - Regime Transition Lab
// Revision 3.2.1: small text-dot raw reclaims, display-only spacing, original-scale
// cohort membership across compact HTFs, and explicit structural config diagnostics.
// Cohort membership is decided BEFORE HTF shortening from unique original inputs.
// An effective duplicate spanning both cohorts is INVALID, never double-counted.
// All v3.2 lifecycle, paired studies, checkpoint maintenance and merged HUD remain.
// Compact HTF windows are FIXED by interval, never chosen from future outcomes.
// The chart-timeframe MA/lifecycle/episode/paired-outcome engines are retained.
// Match chart restores the former HTF configuration; unavailable HTFs stay explicit.
// Maintenance tracks EVERY reclaim independently of its displayed marker/class.
// Later holds/losses are new close-time events, NEVER edits to earlier markers.
// All v3.0 research engines remain: pair topology, deletion sensitivity, width
// attribution, completed episodes and synchronized EMA-direction event controls.
// FIRST-TOUCH SNAPSHOT remains the default introduced in v3.1.0. The previous
// closed-bundle definition remains selectable; changing it changes event counts.
// The HUD defaults to a consistent closed-chart-bar snapshot, including its HTFs.
// Ribbon geometry previews the open bar. Preview is never used to confirm events.
// Reference guides show only the latest known levels, not reconstructed history.
// No orders, price targets, guaranteed returns or recommendation probabilities.
// HTFs use the preceding complete HTF object and lookahead_on. No future data.
// Statistics describe retained observations, NOT executable trading performance.
// Paired controls use the SAME event dates: they test direction, not timing edge.
// Single-slot deletion holds pair votes/divisor fixed; it is NOT full-model refitting.
// ============================================================================

// ============================================================================
// Data objects
// ============================================================================
type RegimeState
    bool  ready               = false
    bool  directionReady      = false
    int   configurationIssue   = 0
    int   configuredFast       = 0
    int   configuredSlow       = 0
    int   configuredPairs      = 0
    int   crossCohortDuplicates= 0
    int   profileCode         = 0
    int   loadedBars          = 0
    int   geometryBars        = 0
    int   geometryNeeded      = 0
    int   warmupFloor         = 0
    int   maximumLength       = 0
    int   effectiveRank       = 0
    int   effectiveReorder    = 0
    int   effectiveSlope      = 0
    int   effectiveMotion     = 0
    int   effectiveDecel      = 0
    int   effectiveAtr        = 0
    int   effectiveStdev      = 0
    string effectiveSpec      = ""
    int   closedAt            = na
    float atrValue            = na
    int   duplicateCount      = 0
    int   configuredCount     = 0
    int   enabledCount        = 0
    bool  episodeStartKnown   = false
    int   eligiblePairs       = 0
    int   skippedPairs        = 0
    int   upPairs             = 0
    int   downPairs           = 0
    int   tiedPairs           = 0
    int   fastCount           = 0
    int   slowCount           = 0
    int   bias                = 0
    int   phase               = 0
    int   stateKey            = -1
    int   age                 = 0
    float centroid            = na
    float bundleHigh          = na
    float bundleLow           = na
    float normDenom           = na
    float widthNorm           = na
    float widthRank           = na
    float widthDelta          = na
    float widthGeometryDelta  = na
    float widthDenominatorDelta = na
    float orderCoherence      = na
    float orderPurity         = na
    float tieRatio            = na
    float reorderRate         = na
    float slopeUpBreadth      = na
    float slopeDownBreadth    = na
    float slopeFlatBreadth    = na
    float slopeEnergyRaw      = na
    float slopeEnergyScore    = na
    float slopeCoherence      = na
    float centroidSlope       = na
    float centroidAcceleration= na
    float fastCentroid        = na
    float slowCentroid        = na
    float cohortSpread        = na
    float slowSlopeCoherence  = na
    float pricePosition       = na
    float pullbackDepth       = na
    float clarity             = na
    float biasComposite       = na

type DurationStats
    int   count               = 0
    float median              = na
    float q25                 = na
    float q75                 = na
    float agePercentile       = na
    float persistence         = na
    int   atRiskCount         = 0
    int   topNextPhase        = 0
    float topNextPct          = na
    int   secondNextPhase     = 0
    float secondNextPct       = na

type OutcomeStats
    int   count               = 0
    float medianReturn        = na
    float q25Return           = na
    float q75Return           = na
    float positiveFrequency  = na
    float ciLow               = na
    float ciHigh              = na
    float medianMfe           = na
    float medianMae           = na
    float meanReturn          = na
    float meanBaseline        = na
    float medianBaseline      = na
    float meanDelta           = na
    float medianDelta         = na
    float deltaQ25            = na
    float deltaQ75            = na
    float earlyMeanDelta      = na
    float lateMeanDelta       = na
    int   earlyCount          = 0
    int   lateCount           = 0
    int   differentDirections = 0
    int   neutralBaselines    = 0

// All topology ablations delete incident pair votes from one fixed snapshot.
type TopologyStats
    bool  valid               = false
    float fastOrder           = na
    float crossOrder          = na
    float slowOrder           = na
    float agreement           = na
    float looLow              = na
    float looHigh             = na
    float largestShift        = na
    int   influentialSlot     = 0
    int   validAblations      = 0
    float recompositionError  = na

type ActiveObservation
    int   signalBar           = 0
    int   signalTime          = 0
    int   entryBar            = na
    float entryPrice          = na
    int   direction           = 0
    int   baselineDirection   = 0
    bool  robust              = false
    float mfe                 = 0.0
    float mae                 = 0.0

type CompletedObservation
    int   signalTime           = 0
    float result              = na
    float baseline            = na
    float delta               = na
    float mfe                 = na
    float mae                 = na
    bool  robust              = false
    bool  differentDirection  = false
    bool  neutralBaseline     = false

// Every reclaim gets an independent, finite close-maintenance observation.
// status: 0=pending, 1=initial hold observed, 2=checkpoint lost,
//         3=whole window held, 4=interrupted/invalid price.
// All fields mutate only on confirmed chart bars; no varip or retrospective labels.
type CheckpointWatch
    int   eventBar             = 0
    int   eventTime            = 0
    int   direction            = 0
    int   contextClass         = 1
    float level                = na
    float eventAtr             = na
    int   status               = 0
    int   observedBars         = 0
    int   heldCloses           = 0
    int   checkedAt            = na
    float lastClose            = na
    float smallestMarginAtr    = na
    bool  holdReported         = false

// ============================================================================
// Generic helpers
// ============================================================================
f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_safe_div(float numerator, float denominator) =>
    not na(numerator) and not na(denominator) and denominator != 0.0 ? numerator / denominator : na

f_num(float x) =>
    na(x) ? "n/a" : str.tostring(x, format.mintick)

f_0(float x) =>
    na(x) ? "n/a" : str.tostring(x, "0")

f_1(float x) =>
    na(x) ? "n/a" : str.tostring(x, "0.0")

f_2(float x) =>
    na(x) ? "n/a" : str.tostring(x, "0.00")

f_pct0(float x) =>
    na(x) ? "n/a" : str.tostring(x, "0") + "%"

f_pct1(float x) =>
    na(x) ? "n/a" : str.tostring(x, "0.0") + "%"

f_int(int x) =>
    na(x) ? "n/a" : str.tostring(x)

f_signed(float x) =>
    na(x) ? "n/a" : (x > 0 ? "+" : "") + str.tostring(x, "0.0")

f_signed_pct(float x) =>
    na(x) ? "n/a" : (x > 0 ? "+" : "") + str.tostring(x, "0.00") + "%"

f_signed3(float x) =>
    na(x) ? "n/a" : (x > 0.0 ? "+" : "") + str.tostring(x, "0.000")

f_meter(float value, int blocks) =>
    string result = ""
    int filled = na(value) ? 0 : int(math.round(f_clamp(value, 0.0, 100.0) * blocks / 100.0))
    for i = 0 to blocks - 1
        result += i < filled ? "▰" : "▱"
    result

f_median_int(array<int> values) =>
    int n = array.size(values)
    float result = na
    if n > 0
        array<int> work = array.copy(values)
        array.sort(work, order.ascending)
        int mid = int(math.floor(n * 0.5))
        result := n % 2 == 1 ? float(array.get(work, mid)) : (array.get(work, mid - 1) + array.get(work, mid)) * 0.5
    result

// Linear interpolation gives the average of the two middle values for p=50.
f_percentile_int(array<int> values, float percentile) =>
    float result = na
    if array.size(values) > 0
        array<int> work = array.copy(values)
        array.sort(work, order.ascending)
        float at = (array.size(work) - 1) * f_clamp(percentile, 0.0, 100.0) / 100.0
        int lo = int(math.floor(at))
        int hi = int(math.ceil(at))
        result := float(array.get(work, lo)) + (array.get(work, hi) - array.get(work, lo)) * (at - lo)
    result

f_percentile_float(array<float> values, float percentile) =>
    float result = na
    if array.size(values) > 0
        array<float> work = array.copy(values)
        array.sort(work, order.ascending)
        float at = (array.size(work) - 1) * f_clamp(percentile, 0.0, 100.0) / 100.0
        int lo = int(math.floor(at))
        int hi = int(math.ceil(at))
        result := array.get(work, lo) + (array.get(work, hi) - array.get(work, lo)) * (at - lo)
    result

f_push_capped_float(array<float> values, float value, int cap) =>
    array.push(values, value)
    if array.size(values) > cap
        array.shift(values)

f_pos(string selected) =>
    switch selected
        "Top left"      => position.top_left
        "Top center"    => position.top_center
        "Middle left"   => position.middle_left
        "Middle center" => position.middle_center
        "Middle right"  => position.middle_right
        "Bottom left"   => position.bottom_left
        "Bottom center" => position.bottom_center
        "Bottom right"  => position.bottom_right
        => position.top_right

f_size(string selected) =>
    switch selected
        "Tiny"   => size.tiny
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

f_bias_name(int bias) =>
    bias > 0 ? "BULLISH" : bias < 0 ? "BEARISH" : "NEUTRAL"

f_bias_icon(int bias) =>
    bias > 0 ? "▲" : bias < 0 ? "▼" : "◇"

f_phase_name(int phase) =>
    switch phase
        1 => "COMPRESSION"
        2 => "RELEASE"
        3 => "EXPANSION"
        4 => "PULLBACK"
        5 => "DECELERATION"
        6 => "CHURN / TRANSITION"
        => "WARMING UP"

f_phase_short(int phase) =>
    switch phase
        1 => "CMP"
        2 => "REL"
        3 => "EXP"
        4 => "PB"
        5 => "DEC"
        6 => "TRN"
        => "N/A"

f_phase_icon(int phase) =>
    switch phase
        1 => "◌"
        2 => "⚡"
        3 => "↗"
        4 => "↘"
        5 => "≋"
        6 => "⇄"
        => "·"

f_state_key(int bias, int phase) =>
    phase >= 1 and phase <= 6 ? (bias + 1) * 6 + phase - 1 : -1

f_normalize_distance(float distance, float center, float atrValue, float stdevValue, string mode) =>
    float result = na
    if mode == "ATR"
        result := f_safe_div(distance, atrValue)
    else if mode == "Percentage"
        result := not na(center) and center != 0.0 ? 100.0 * distance / math.abs(center) : na
    else
        result := f_safe_div(distance, stdevValue)
    result

f_wilson(float proportion, int sampleCount, float z) =>
    float ciLowValue = na
    float ciHighValue = na
    if sampleCount > 0 and not na(proportion)
        float n = sampleCount
        float z2 = z * z
        float denominator = 1.0 + z2 / n
        float center = (proportion + z2 / (2.0 * n)) / denominator
        float margin = z * math.sqrt((proportion * (1.0 - proportion) + z2 / (4.0 * n)) / n) / denominator
        ciLowValue := 100.0 * math.max(0.0, center - margin)
        ciHighValue := 100.0 * math.min(1.0, center + margin)
    [ciLowValue, ciHighValue]

// Only time-based standard charts can feed the event and episode studies.
// Unsupported tick/range timeframe strings are never sent to in_seconds().
bool chartTimeBased = not str.endswith(timeframe.period, "T") and not str.endswith(timeframe.period, "R")
f_tf_seconds(simple string tf) =>
    str.endswith(tf, "T") or str.endswith(tf, "R") ? float(na) : float(timeframe.in_seconds(tf))

// ============================================================================
// 1. Core configuration
// ============================================================================
gCore = "1. Core configuration"
preset            = input.string("Balanced Trend", "Structure preset", options = ["Short Horizon", "Balanced Trend", "Long Horizon", "Investor", "Custom"], group = gCore, display = display.none, tooltip = "Presets are general reference configurations, not optimized settings. Custom exposes the slot settings below.")
sourceChoice = input.string("Close", "Price source", options = ["Close", "Open", "High", "Low", "HL2", "HLC3", "OHLC4", "HLCC4"], group = gCore, display = display.none, tooltip = "Built-in chart-price sources only, so each HTF can recompute its own source. External indicator plots are intentionally not accepted. Price location, phase price gates, touches, reclaims and outcomes always use chart OHLC prices.")
float src = switch sourceChoice
    "Open" => open
    "High" => high
    "Low" => low
    "HL2" => hl2
    "HLC3" => hlc3
    "OHLC4" => ohlc4
    "HLCC4" => (high + low + 2.0 * close) * 0.25
    => close
slopeLookback     = input.int(5, "Slope lookback", minval = 1, maxval = 100, group = gCore, display = display.none)
minimumWarmupBars = input.int(80, "Minimum warm-up bars", minval = 20, maxval = 2000, group = gCore, display = display.none)
useAutoWarmup     = input.bool(true, "Use automatic warm-up floor", group = gCore, display = display.none)

// ============================================================================
// 2. Normalization and structure engine
// ============================================================================
gNorm = "2. Normalization and structure engine"
normalizationMode      = input.string("ATR", "Distance normalization", options = ["ATR", "Percentage", "Rolling stdev"], group = gNorm, display = display.none)
atrLength              = input.int(14, "ATR normalization length", minval = 2, maxval = 500, group = gNorm, display = display.none)
stdevLength            = input.int(50, "Rolling stdev length", minval = 5, maxval = 1000, group = gNorm, display = display.none)
pairSeparation         = input.float(0.030, "Pair tie threshold (normalized units)", minval = 0.0, step = 0.005, group = gNorm, display = display.none)
slopeFlatThreshold     = input.float(0.020, "Slope flat threshold (normalized units)", minval = 0.0, step = 0.005, group = gNorm, display = display.none)
slopeEnergyScale       = input.float(0.300, "Slope energy = 100 scale", minval = 0.001, step = 0.01, group = gNorm, display = display.none)
cohortBiasScale        = input.float(0.300, "Cohort spread = ±100 scale", minval = 0.001, step = 0.01, group = gNorm, display = display.none)
horizonWeightPower     = input.float(1.0, "Horizon-distance weight power", minval = 0.0, maxval = 3.0, step = 0.25, group = gNorm, display = display.none)
horizonOrderingMode    = input.string("Manual rank", "Horizon ordering", options = ["Manual rank", "Length ascending"], group = gNorm, display = display.none, tooltip = "Manual rank compares MA slots by their explicit analytical horizon, so equal-length MAs of different types can still be compared. Length ascending automatically treats shorter periods as faster and skips equal lengths.")
widthRankLookback      = input.int(250, "Bundle-width rank lookback", minval = 20, maxval = 2000, group = gNorm, display = display.none)
widthMotionBars        = input.int(3, "Bundle-width motion bars", minval = 1, maxval = 50, group = gNorm, display = display.none)
reorderLookback        = input.int(50, "Reorder-rate lookback", minval = 5, maxval = 500, group = gNorm, display = display.none)
cohortMode             = input.string("Horizon rank", "Fast/slow cohort split", options = ["Horizon rank", "Median length", "Manual length"], group = gNorm, display = display.none, tooltip = "All cohort membership is decided on the original unique MA specifications, BEFORE any HTF shortening. Horizon rank uses manual ranks, or original-length median when ordering by length. Median length uses the original unique-length median. Manual length uses the original configured period boundary. Effective shortened duplicates count once; a duplicate spanning both cohorts is reported as COHORT COLLISION, not silently assigned or double-counted.")
cohortRankSplit        = input.int(4, "Fast cohort maximum rank", minval = 1, maxval = 7, group = gNorm, display = display.none)
cohortManualLength     = input.int(50, "Fast cohort maximum length", minval = 1, maxval = 5000, group = gNorm, display = display.none, tooltip = "Manual length compares this boundary with ORIGINAL preset/custom lengths, not shortened HTF lengths. With original 5/10/20/50/100/200 and boundary 50, original slots 1-4 stay fast and 5-6 stay slow on every HTF. Same-cohort effective duplicates count once. No fast/slow cohort is an explicit configuration error, not a history wait.")

// ============================================================================
// 3. Lifecycle thresholds
// ============================================================================
gLife = "3. Lifecycle thresholds"
requireGeometricWidth = input.bool(true, "Require actual bundle widening/narrowing", group = gLife, display = display.none, tooltip = "For width-based releases and deceleration, require both total normalized width change and its geometry component to pass the threshold. Prevents denominator-only motion from qualifying as bundle expansion/contraction.")
biasThreshold             = input.float(22.0, "Bias composite threshold", minval = 0.0, maxval = 100.0, step = 1.0, group = gLife, display = display.none)
orderedThreshold          = input.float(62.0, "Directional order threshold", minval = 0.0, maxval = 100.0, step = 1.0, group = gLife, display = display.none)
slopeCoherenceThreshold   = input.float(45.0, "Directional slope coherence", minval = 0.0, maxval = 100.0, step = 1.0, group = gLife, display = display.none)
compressionRankThreshold  = input.float(18.0, "Compression width-rank maximum", minval = 0.0, maxval = 100.0, step = 1.0, group = gLife, display = display.none)
compressionEnergyMaximum  = input.float(32.0, "Compression energy maximum", minval = 0.0, maxval = 100.0, step = 1.0, group = gLife, display = display.none)
compressionOrderMaximum   = input.float(35.0, "Compression |order| maximum", minval = 0.0, maxval = 100.0, step = 1.0, group = gLife, display = display.none)
releaseOrderMinimum       = input.float(48.0, "Release direction-aligned order minimum", minval = 0.0, maxval = 100.0, step = 1.0, group = gLife, display = display.none)
releaseWidthMinimum       = input.float(0.005, "Release width expansion minimum", minval = 0.0, step = 0.005, group = gLife, display = display.none)
releaseAccelerationMin    = input.float(0.0, "Release centroid acceleration minimum", minval = 0.0, step = 0.005, group = gLife, display = display.none)
releaseOriginLookback   = input.int(3, "Compression-to-release origin window", minval = 1, maxval = 20, group = gLife, display = display.none, tooltip = "A release can originate from a compression observed within this many completed bars, allowing a brief transition bar between compression and release.")
pullbackOrderFloor        = input.float(25.0, "Pullback order-hold floor", minval = 0.0, maxval = 100.0, step = 1.0, group = gLife, display = display.none)
slowSlopeHoldThreshold    = input.float(15.0, "Slow-cohort slope-hold threshold", minval = 0.0, maxval = 100.0, step = 1.0, group = gLife, display = display.none)
decelerationLookback      = input.int(5, "Deceleration comparison bars", minval = 1, maxval = 50, group = gLife, display = display.none)
decelerationEnergyDrop    = input.float(8.0, "Deceleration energy drop", minval = 0.0, maxval = 100.0, step = 1.0, group = gLife, display = display.none)
decelerationSlopeDrop     = input.float(10.0, "Deceleration coherence drop", minval = 0.0, maxval = 100.0, step = 1.0, group = gLife, display = display.none)
decelerationWidthMinimum  = input.float(0.005, "Deceleration width contraction", minval = 0.0, step = 0.005, group = gLife, display = display.none)
churnReorderThreshold     = input.float(5.0, "Churn reorder-rate threshold", minval = 0.0, maxval = 100.0, step = 0.5, group = gLife, display = display.none)
clarityReorderPenalty     = input.float(1.5, "Clarity penalty per reorder-rate point", minval = 0.0, maxval = 10.0, step = 0.25, group = gLife, display = display.none)

// ============================================================================
// 4. Multi-timeframe matrix
// ============================================================================
f_next_higher_tf(simple string referenceTf) =>
    float seconds = f_tf_seconds(referenceTf)
    string result = "12M"
    if seconds < timeframe.in_seconds("1")
        result := "1"
    else if seconds < timeframe.in_seconds("5")
        result := "5"
    else if seconds < timeframe.in_seconds("15")
        result := "15"
    else if seconds < timeframe.in_seconds("60")
        result := "60"
    else if seconds < timeframe.in_seconds("240")
        result := "240"
    else if seconds < timeframe.in_seconds("1D")
        result := "1D"
    else if seconds < timeframe.in_seconds("1W")
        result := "1W"
    else if seconds < timeframe.in_seconds("1M")
        result := "1M"
    else if seconds < timeframe.in_seconds("3M")
        result := "3M"
    else if seconds < timeframe.in_seconds("6M")
        result := "6M"
    result

gMtf = "4. Multi-timeframe matrix"
htfHistoryMode = input.string("Calendar-bounded", "HTF window policy", options = ["Calendar-bounded", "Match chart"], group = gMtf, display = display.none, tooltip = "Calendar-bounded uses fixed shorter MA/history windows on weekly and coarser HTFs. Chart-timeframe settings are never shortened. Weekly: MA cap 52 / rank cap 52; monthly: 24/24; quarterly: 12/12; half-year: 8/8; yearly: 6/6. MA types and relative length proportions remain; cohort membership is fixed BEFORE shortening from original unique specifications. Duplicate shortened specifications count once; a shortened duplicate spanning both cohorts disables that layer with COHORT COLLISION. Other windows are capped and disclosed in each HTF tooltip. No fallback to a different timeframe or silent exclusion of unavailable layers. Match chart restores the previous full-length HTF policy. This choice can change MTF alignment and context-coded events, not local reclaim detection.")
autoMtfHierarchy = input.bool(true, "Use automatic strictly-higher hierarchy", group = gMtf, display = display.none, tooltip = "Routes through 1m/5m/15m/1h/4h/1D/1W/1M/3M/6M/12M. Example: 4h -> 1D -> 1W. Turn off to use the manual fields. A layer with no higher supported interval is marked invalid, never silently substituted.")
useAnchorTimeframe = input.bool(true, "Enable anchor timeframe", inline = "mtf1", group = gMtf, display = display.none)
anchorTimeframeInput = input.timeframe("240", "Anchor", inline = "mtf1", group = gMtf, display = display.none)
useMacroTimeframe  = input.bool(true, "Enable macro timeframe", inline = "mtf2", group = gMtf, display = display.none)
macroTimeframeInput = input.timeframe("1D", "Macro", inline = "mtf2", group = gMtf, display = display.none)
mtfCalcBars        = input.int(5000, "Requested HTF calculation bars", minval = 500, maxval = 10000, group = gMtf, display = display.none)
string anchorTimeframe = autoMtfHierarchy ? f_next_higher_tf(timeframe.period) : anchorTimeframeInput
string macroTimeframe = autoMtfHierarchy ? f_next_higher_tf(useAnchorTimeframe ? anchorTimeframe : timeframe.period) : macroTimeframeInput

// ============================================================================
// 5. Historical structure memory
// ============================================================================
gMemory = "5. Historical structure memory"
enableStructureMemory = input.bool(true, "Enable completed-episode memory", group = gMemory, display = display.none)
memorySamplesPerState  = input.int(120, "Maximum completed episodes per state", minval = 20, maxval = 300, group = gMemory, display = display.none)
minimumMemorySamples   = input.int(20, "Minimum samples before interpretation", minval = 5, maxval = 100, group = gMemory, display = display.none, tooltip = "Applied exactly. If this exceeds the retained episode cap, numerical summaries remain unavailable and the HUD shows MIN > CAP.")
persistenceHorizon     = input.int(10, "Persistence horizon (additional bars)", minval = 1, maxval = 100, group = gMemory, display = display.none)

// ============================================================================
// 6. Event outcome lab
// ============================================================================
gOutcome = "6. Event outcome lab"
studyEntryMode = input.string("Next bar open", "Observation entry reference", options = ["Next bar open", "Event bar close"], group = gOutcome, display = display.none, tooltip = "Default: freeze directions on the event close; start at the next open and include exactly H bars through their final close. Event-close mode excludes the event bar's high/low. Neither mode simulates orders, costs or fills.")
baselineFastLength = input.int(20, "Paired EMA control: fast length", minval = 1, maxval = 1000, group = gOutcome, display = display.none)
baselineSlowLength = input.int(50, "Paired EMA control: slow length", minval = 2, maxval = 2000, group = gOutcome, display = display.none)
showEvidencePanel = input.bool(false, "Show detailed evidence panel", group = gOutcome, display = display.none, tooltip = "Bottom right by default. Moves to bottom left when the main HUD occupies bottom right. Both are fixed tables; no extra price-scale labels.")
useStudyStart = input.bool(false, "Limit new observations by start date", group = gOutcome, display = display.none)
studyStartTime = input.time(timestamp("01 Jan 2020 00:00 +0000"), "Observation start date", group = gOutcome, display = display.none, tooltip = "Applied to confirmed event-bar close time. A date filter, not an automatic out-of-sample test. Indicators still warm up using earlier chart bars.")

gAudit = "6A. Pair-topology audit"
topologyOrderFloor = input.float(25.0, "Order-class boundary for ablation", minval = 0.1, maxval = 99.0, step = 1.0, group = gAudit, display = display.none)
topologyMaximumShift = input.float(25.0, "Maximum order-point shift for robust subgroup", minval = 0.0, maxval = 200.0, step = 1.0, group = gAudit, display = display.none, tooltip = "Every valid one-slot deletion must keep the event-aligned non-neutral order class, with maximum shift at or below this boundary. Does not filter raw legacy events or the full outcome study. DOES affect the stable subgroup, RAS marker class and the aligned-stable reclaim alert. Cohorts, votes and normalization stay fixed; this is not prediction confidence.")
enableOutcomeLab       = input.bool(true, "Enable forward outcome study", group = gOutcome, display = display.none)
studyEventType         = input.string("Pullback Reclaim", "Study event", options = ["Compression Release", "Pullback Reclaim", "Structural Failure", "MTF Alignment", "Expansion Entry"], group = gOutcome, display = display.none)
studyHorizon           = input.int(20, "Forward horizon (bars)", minval = 1, maxval = 250, group = gOutcome, display = display.none)
maximumOutcomeSamples  = input.int(200, "Maximum completed samples", minval = 20, maxval = 500, group = gOutcome, display = display.none)
minimumOutcomeSamples  = input.int(20, "Minimum samples before interpretation", minval = 5, maxval = 100, group = gOutcome, display = display.none, tooltip = "Applied separately to the full sample, each subgroup and each chronological half. Never silently lowered to match the cap.")
nonOverlappingSamples  = input.bool(true, "Use non-overlapping samples", group = gOutcome, display = display.none)

int activeMinimumMemorySamples = minimumMemorySamples
int activeMinimumOutcomeSamples = minimumOutcomeSamples

// ============================================================================
// 7. Events and interaction engine
// ============================================================================
gEvents = "7. Events and interaction engine"
// Closed-bar event semantics are mandatory. Only the geometry/HUD can preview.
bool confirmEventsOnClose = true
reclaimBoundaryMode = input.string("First-touch snapshot", "Reclaim boundary", options = ["First-touch snapshot", "Previous closed bundle"], group = gEvents, display = display.none, tooltip = "Default: capture the previous closed bundle on the first-touch bar, then require a later close to cross that unchanged boundary. Previous closed bundle restores v3.0's rolling, pre-bar boundary. Neither mode allows touch and reclaim on one bar. This choice changes the event study, not only the display.")
reclaimBufferTicks = input.int(0, "Reclaim clearance (minimum ticks)", minval = 0, maxval = 100, group = gEvents, display = display.none, tooltip = "A bullish reclaim closes strictly above the chosen upper boundary plus this many ticks. A bearish reclaim closes strictly below the lower boundary minus this amount. This is not a stop or target.")
maximumCycleBars = input.int(500, "Maximum directional-cycle age", minval = 10, maxval = 5000, group = gEvents, display = display.none)
minimumPhaseBarsForEvent   = input.int(1, "State bars before state-entry event", minval = 1, maxval = 20, group = gEvents, display = display.none)
oneEventPerBar             = input.bool(true, "At most one chart marker per bar", group = gEvents, display = display.none)
eventCooldownBars          = input.int(0, "Marker-only cooldown bars (no backfill)", minval = 0, maxval = 100, group = gEvents, display = display.none)
maximumEventLabels         = input.int(40, "Maximum event labels", minval = 10, maxval = 300, group = gEvents, display = display.none)
failureOrderFloor          = input.float(10.0, "Structural-failure order floor", minval = 0.0, maxval = 100.0, step = 1.0, group = gEvents, display = display.none)
failureSlowSlopeFlip       = input.float(5.0, "Structural-failure slow-slope flip", minval = 0.0, maxval = 100.0, step = 1.0, group = gEvents, display = display.none)

gMaintenance = "7B. Frozen-checkpoint maintenance"
enableCheckpointWatch = input.bool(true, "Track every reclaim checkpoint", group = gMaintenance, display = display.none, tooltip = "Freeze the actual crossed tick and event ATR for each reclaim. Observe subsequent confirmed closes, even after a new directional cycle starts. Marker filtering never selects the tracked sample. A later adverse close ends that watch; it is a new event, not a change to the original reclaim.")
checkpointHoldBars = input.int(3, "Initial consecutive closes required", minval = 1, maxval = 20, group = gMaintenance, display = display.none, tooltip = "Excludes the event candle. The first K subsequent closes must remain on the reclaim side of the same frozen checkpoint. HELD means this finite rule was observed, not a prediction.")
checkpointWatchBars = input.int(20, "Total maintenance window (bars)", minval = 1, maxval = 100, group = gMaintenance, display = display.none, tooltip = "Continue after the initial hold until this many subsequent bars. A later loss is still reported. If initial closes exceed this window, the module is explicitly disabled with a configuration warning; the setting is never silently reduced.")
notifyCheckpointHolds = input.bool(false, "Combined alert: initial checkpoint held", group = gMaintenance, display = display.none)
notifyCheckpointLosses = input.bool(true, "Combined alert: frozen checkpoint lost", group = gMaintenance, display = display.none)
showCheckpointGuide = input.bool(true, "Show latest reclaim's active checkpoint", group = gMaintenance, display = display.none, tooltip = "Dashed accent guide for the latest reclaim while its own watch remains active. If it ends, no maintenance guide is shown, even when an older watch is active. Older watches still run and can notify. This is not the current rolling MA, a stop or a target.")

// ============================================================================
// 8. Display
// ============================================================================
gDisplay = "8. Display"
showIndividualMAs       = input.bool(false, "Show individual MAs", group = gDisplay, display = display.none, tooltip = "Plots every enabled MA at its mathematically correct chart price.")
showCohortRibbon        = input.bool(true, "Show fast/slow structure ribbon", group = gDisplay, display = display.none, tooltip = "Uses the complete fast and slow research cohorts from the regime engine. This restores the original chart visual instead of the shortened responsive ribbon.")
showCentroid            = input.bool(true, "Show ensemble centerline", group = gDisplay, display = display.none)
showBundleEnvelope      = input.bool(false, "Show full MA bundle envelope", group = gDisplay, display = display.none)
showBundleFill          = input.bool(false, "Fill full MA bundle", group = gDisplay, display = display.none)
showBackgroundTint      = input.bool(false, "Show lifecycle background tint", group = gDisplay, display = display.none)
showDashboard = input.bool(true, "Show fixed structure HUD", group = gDisplay, display = display.none)
dashboardMode = input.string("Trader", "HUD detail", options = ["Clean", "Trader", "Analyst", "Research"], group = gDisplay, display = display.none, tooltip = "Trader: context, three timeframes, clarity/sensitivity, price location, exact reference levels and latest key event. Clean hides the reference-price row. Analyst adds pair blocks and width attribution. Research adds completed-episode and paired-event statistics. No engine is disabled by choosing a simpler HUD. The footer shows the newest finite checkpoint-maintenance watch when recent; other key events remain in its tooltip.")
dashboardTextSize       = input.string("Normal", "HUD text size", options = ["Tiny", "Small", "Normal", "Large"], group = gDisplay, display = display.none, tooltip = "Normal is the larger readability-first default. Tiny and Small remain available for compact layouts.")
dashboardLogoClearance = input.int(2, "Bottom HUD clearance (%)", minval = 0, maxval = 12, group = gDisplay, display = display.none, tooltip = "Invisible spacing for bottom-corner HUDs. The spacer has no background, grid or outer frame; there is no empty framed rectangle.")
useDashboardIcons       = input.bool(true, "Use HUD icons", group = gDisplay, display = display.none)
useDashboardMeters      = input.bool(true, "Use HUD meters", group = gDisplay, display = display.none)
markerDisplayMode       = input.string("Key events", "Marker display", options = ["Off", "Major only", "Key events", "All events"], group = gDisplay, display = display.none, tooltip = "Structural failure and MTF alignment are kept in the fixed HUD and alerts, but are never drawn over price. Major only shows compression releases. Key events additionally shows pullback reclaims. All events exposes first touch, expansion, compression and transition markers.")
useMarkerIcons          = input.bool(true, "Use marker icons", group = gDisplay, display = display.none)

dashboardWidthPercent = input.float(33.0, "HUD total width (%)", minval = 20.0, maxval = 80.0, step = 1.0, group = gDisplay, display = display.none, tooltip = "Three equal fixed-width columns. Merged headings retain that total width. Increase on a narrow chart, or reduce text size. Table text is not automatically scaled to device pixels.")
markerPresentation = input.string("Context symbols", "Event marker presentation", options = ["Context symbols", "Legacy cards"], group = gDisplay, display = display.none, tooltip = "Context symbols: a small text dot = R (raw reclaim without complete directional HTF alignment); RA = fully aligned enabled HTFs; RAS = alignment plus stable non-neutral fixed-vote order. R dots have their own point size and minimum display spacing. No filled triangle is used. Classes are frozen at the event, not selected by future movement. Hover for full conditions. Legacy cards keeps the old full-word style.")
markerDensityBars = input.int(12, "Marker collision window (bars)", minval = 0, maxval = 100, group = gDisplay, display = display.none, tooltip = "Context symbols only: compare with already drawn nearby markers, using a bar/ATR proxy, and try three outward lanes. If all are crowded, omit this marker immediately. No delayed or backfilled labels. Events, studies and maintenance still record it. This is not pixel-perfect collision detection across arbitrary zoom levels.")
markerLaneAtr = input.float(0.75, "Marker lane spacing (ATR)", minval = 0.15, maxval = 3.0, step = 0.05, group = gDisplay, display = display.none)
rawReclaimDotSize = input.int(9, "Raw R dot text size (points)", minval = 6, maxval = 12, group = gDisplay, display = display.none, tooltip = "Context symbols only. A plain middle-dot text glyph with no filled label body. Typographic size, NOT a pixel guarantee. RA/RAS keep the separate Marker text size.")
rawReclaimSpacingBars = input.int(6, "Raw R minimum display spacing (bars)", minval = 0, maxval = 100, group = gDisplay, display = display.none, tooltip = "Context symbols only. Minimum distance between drawn R dots, regardless of direction. Zero disables this extra thinning. RA/RAS are not gated by this input. This affects rendering only; all raw events, alerts, outcome observations and checkpoint watches are retained. Omitted dots are never drawn later.")
dashboardPosition = input.string("Bottom left", "HUD corner", options = ["Bottom left", "Top right", "Top left", "Bottom right"], group = gDisplay, display = display.none)
hudSnapshotMode = input.string("Confirmed", "HUD chart-bar snapshot", options = ["Confirmed", "Live preview"], group = gDisplay, display = display.none, tooltip = "Confirmed holds chart structure, its HTF snapshots, topology and price at the last completed chart bar. Live preview exposes the open bar and is explicitly labelled PREVIEW. Alerts, studies, checkpoints and guide levels remain close-confirmed in either mode.")
clarityLowBoundary = input.float(40.0, "Low-clarity display boundary", minval = 0.0, maxval = 100.0, step = 1.0, group = gDisplay, display = display.none, tooltip = "A display label only, not a signal filter or probability calibration.")
priceExtensionAtr = input.float(2.0, "Price extension from fast cohort (ATR)", minval = 0.25, maxval = 20.0, step = 0.25, group = gDisplay, display = display.none, tooltip = "EXTENDED means close is this far beyond the fast-cohort mean in the local bias direction, measured in the configured ATR. It is not a reversal forecast. ATR units are used even if structure normalization is Percentage or Rolling stdev.")
keyEventFreshBars = input.int(30, "Fade key event after bars", minval = 1, maxval = 500, group = gDisplay, display = display.none)
markerTextSize = input.string("Small", "Marker text size", options = ["Tiny", "Small", "Normal"], group = gDisplay, display = display.none)
markerGapAtr = input.float(0.45, "Marker clearance from wick (ATR)", minval = 0.0, maxval = 5.0, step = 0.05, group = gDisplay, display = display.none)
markerCardStyle = input.string("Dark card", "Marker style", options = ["Dark card", "Solid direction color"], group = gDisplay, display = display.none)
ribbonColorMode = input.string("Direction", "Ribbon fill meaning", options = ["Direction", "Lifecycle"], group = gDisplay, display = display.none, tooltip = "Direction keeps cyan/up and orange/down consistent. Lifecycle restores phase-specific fill colors. Mathematical cohort values are unchanged.")
adaptiveRibbonOpacity = input.bool(true, "Lighten ribbon when structure is unclear", group = gDisplay, display = display.none)
showReferenceMap = input.bool(true, "Show latest closed reference guides", group = gDisplay, display = display.none, tooltip = "Three short guides for the first qualifying close ticks beyond the upper/lower full-bundle edges and the tick-rounded slow-cohort mean. During a frozen first-touch checkpoint, only upper/lower remain captured. CURRENT SLOW still updates from the last completed chart bar. Otherwise they use the last completed chart bar. Exact values remain in the Trader HUD. They are references, not support guarantees, orders or projected future MAs.")
referenceGuideBars = input.int(10, "Reference guide length to right (bars)", minval = 2, maxval = 80, group = gDisplay, display = display.none)
referenceMaxDistanceAtr = input.float(8.0, "Hide distant guides beyond ATR", minval = 1.0, maxval = 50.0, step = 0.5, group = gDisplay, display = display.none, tooltip = "Only the drawing is omitted when far from the last close, to avoid stretching the price scale. The exact level is still shown in the HUD. Changing this does not change events.")

gNotice = "7A. Contextual notifications"
enableContextAlerts = input.bool(true, "Enable combined context alert()", group = gNotice, display = display.none, tooltip = "Create an alert using Any alert() function call. One close-only message contains all selected events on that candle, the actual event reference where applicable, timeframe context and the local structure. This option does not affect the separately selectable legacy alert conditions.")
notifyReleases = input.bool(true, "Compression releases", inline = "n1", group = gNotice, display = display.none)
notifyReclaims = input.bool(true, "Reclaims", inline = "n1", group = gNotice, display = display.none)
notifyFailures = input.bool(true, "Failures", inline = "n2", group = gNotice, display = display.none)
notifyMtf = input.bool(true, "MTF changes", inline = "n2", group = gNotice, display = display.none)
notifyTouches = input.bool(false, "First touches", inline = "n3", group = gNotice, display = display.none)
notifyExtensions = input.bool(false, "Extension entries", inline = "n3", group = gNotice, display = display.none)
notifyRoutineStates = input.bool(false, "Other state entries", group = gNotice, display = display.none)

// ============================================================================
// 9. Futuristic theme
// ============================================================================
gTheme = "9. Futuristic theme"
bullColor          = input.color(#00C2FF, "Bullish / cyan", group = gTheme, display = display.none)
bearColor          = input.color(#FF7A45, "Bearish / orange", group = gTheme, display = display.none)
neutralColor       = input.color(#8A93A6, "Neutral", group = gTheme, display = display.none)
accentColor        = input.color(#B56CFF, "Accent / violet", group = gTheme, display = display.none)
compressionColor   = input.color(#5F6B82, "Compression", group = gTheme, display = display.none)
decelerationColor  = input.color(#F2C94C, "Deceleration", group = gTheme, display = display.none)
headerBackground   = input.color(#0B1220, "Dashboard header", group = gTheme, display = display.none)
panelBackground    = input.color(#101A2E, "Dashboard panel", group = gTheme, display = display.none)
alternateBackground= input.color(#14213A, "Dashboard alternate", group = gTheme, display = display.none)
borderColor        = input.color(#284564, "Dashboard border", group = gTheme, display = display.none)
mainTextColor      = input.color(#EAF2FF, "Dashboard primary text", group = gTheme, display = display.none)
mutedTextColor     = input.color(#8FA5BF, "Dashboard muted text", group = gTheme, display = display.none)
markerTextColor    = input.color(#FFFFFF, "Marker text", group = gTheme, display = display.none)
markerTransparency= input.int(5, "Marker transparency", minval = 0, maxval = 100, group = gTheme, display = display.none)
maDefaultTransparency = input.int(35, "Preset MA transparency", minval = 0, maxval = 100, group = gTheme, display = display.none)
centroidTransparency  = input.int(10, "Centerline transparency", minval = 0, maxval = 100, group = gTheme, display = display.none)
ribbonBaseTransparency= input.int(84, "Ribbon base transparency", minval = 0, maxval = 100, group = gTheme, display = display.none)

// ============================================================================
// 10. Custom MA slots — used when preset = Custom
// ============================================================================
gMA1 = "MA 1 — Custom"
enable1 = input.bool(true, "Enable", inline = "1a", group = gMA1, display = display.none)
type1   = input.string("EMA", "Type", options = ["EMA", "SMA", "WMA", "RMA", "HMA", "DEMA", "TEMA", "VWMA", "ALMA", "KAMA"], inline = "1a", group = gMA1, display = display.none)
len1    = input.int(5, "Length", minval = 1, maxval = 4000, inline = "1b", group = gMA1, display = display.none)
rank1   = input.int(1, "Horizon rank", minval = 1, maxval = 8, inline = "1b", group = gMA1, display = display.none, tooltip = "Lower rank means a faster analytical horizon. Equal ranks are intentionally excluded from pair ordering.")
name1   = input.string("Fast 1", "Name", inline = "1c", group = gMA1, display = display.none)
color1  = input.color(#00B8FF, "Color", inline = "1c", group = gMA1, display = display.none)
width1  = input.int(1, "Width", minval = 1, maxval = 4, inline = "1d", group = gMA1, display = display.none)
transparency1 = input.int(35, "Transparency", minval = 0, maxval = 100, inline = "1d", group = gMA1, display = display.none)

gMA2 = "MA 2 — Custom"
enable2 = input.bool(true, "Enable", inline = "2a", group = gMA2, display = display.none)
type2   = input.string("EMA", "Type", options = ["EMA", "SMA", "WMA", "RMA", "HMA", "DEMA", "TEMA", "VWMA", "ALMA", "KAMA"], inline = "2a", group = gMA2, display = display.none)
len2    = input.int(10, "Length", minval = 1, maxval = 4000, inline = "2b", group = gMA2, display = display.none)
rank2   = input.int(2, "Horizon rank", minval = 1, maxval = 8, inline = "2b", group = gMA2, display = display.none, tooltip = "Lower rank means a faster analytical horizon. Equal ranks are intentionally excluded from pair ordering.")
name2   = input.string("Fast 2", "Name", inline = "2c", group = gMA2, display = display.none)
color2  = input.color(#00E0C6, "Color", inline = "2c", group = gMA2, display = display.none)
width2  = input.int(1, "Width", minval = 1, maxval = 4, inline = "2d", group = gMA2, display = display.none)
transparency2 = input.int(35, "Transparency", minval = 0, maxval = 100, inline = "2d", group = gMA2, display = display.none)

gMA3 = "MA 3 — Custom"
enable3 = input.bool(true, "Enable", inline = "3a", group = gMA3, display = display.none)
type3   = input.string("EMA", "Type", options = ["EMA", "SMA", "WMA", "RMA", "HMA", "DEMA", "TEMA", "VWMA", "ALMA", "KAMA"], inline = "3a", group = gMA3, display = display.none)
len3    = input.int(20, "Length", minval = 1, maxval = 4000, inline = "3b", group = gMA3, display = display.none)
rank3   = input.int(3, "Horizon rank", minval = 1, maxval = 8, inline = "3b", group = gMA3, display = display.none, tooltip = "Lower rank means a faster analytical horizon. Equal ranks are intentionally excluded from pair ordering.")
name3   = input.string("Fast 3", "Name", inline = "3c", group = gMA3, display = display.none)
color3  = input.color(#6C7BFF, "Color", inline = "3c", group = gMA3, display = display.none)
width3  = input.int(1, "Width", minval = 1, maxval = 4, inline = "3d", group = gMA3, display = display.none)
transparency3 = input.int(35, "Transparency", minval = 0, maxval = 100, inline = "3d", group = gMA3, display = display.none)

gMA4 = "MA 4 — Custom"
enable4 = input.bool(true, "Enable", inline = "4a", group = gMA4, display = display.none)
type4   = input.string("SMA", "Type", options = ["EMA", "SMA", "WMA", "RMA", "HMA", "DEMA", "TEMA", "VWMA", "ALMA", "KAMA"], inline = "4a", group = gMA4, display = display.none)
len4    = input.int(50, "Length", minval = 1, maxval = 4000, inline = "4b", group = gMA4, display = display.none)
rank4   = input.int(4, "Horizon rank", minval = 1, maxval = 8, inline = "4b", group = gMA4, display = display.none, tooltip = "Lower rank means a faster analytical horizon. Equal ranks are intentionally excluded from pair ordering.")
name4   = input.string("Core 1", "Name", inline = "4c", group = gMA4, display = display.none)
color4  = input.color(#B56CFF, "Color", inline = "4c", group = gMA4, display = display.none)
width4  = input.int(1, "Width", minval = 1, maxval = 4, inline = "4d", group = gMA4, display = display.none)
transparency4 = input.int(35, "Transparency", minval = 0, maxval = 100, inline = "4d", group = gMA4, display = display.none)

gMA5 = "MA 5 — Custom"
enable5 = input.bool(true, "Enable", inline = "5a", group = gMA5, display = display.none)
type5   = input.string("SMA", "Type", options = ["EMA", "SMA", "WMA", "RMA", "HMA", "DEMA", "TEMA", "VWMA", "ALMA", "KAMA"], inline = "5a", group = gMA5, display = display.none)
len5    = input.int(100, "Length", minval = 1, maxval = 4000, inline = "5b", group = gMA5, display = display.none)
rank5   = input.int(5, "Horizon rank", minval = 1, maxval = 8, inline = "5b", group = gMA5, display = display.none, tooltip = "Lower rank means a faster analytical horizon. Equal ranks are intentionally excluded from pair ordering.")
name5   = input.string("Slow 1", "Name", inline = "5c", group = gMA5, display = display.none)
color5  = input.color(#F45B9A, "Color", inline = "5c", group = gMA5, display = display.none)
width5  = input.int(1, "Width", minval = 1, maxval = 4, inline = "5d", group = gMA5, display = display.none)
transparency5 = input.int(35, "Transparency", minval = 0, maxval = 100, inline = "5d", group = gMA5, display = display.none)

gMA6 = "MA 6 — Custom"
enable6 = input.bool(true, "Enable", inline = "6a", group = gMA6, display = display.none)
type6   = input.string("SMA", "Type", options = ["EMA", "SMA", "WMA", "RMA", "HMA", "DEMA", "TEMA", "VWMA", "ALMA", "KAMA"], inline = "6a", group = gMA6, display = display.none)
len6    = input.int(200, "Length", minval = 1, maxval = 4000, inline = "6b", group = gMA6, display = display.none)
rank6   = input.int(6, "Horizon rank", minval = 1, maxval = 8, inline = "6b", group = gMA6, display = display.none, tooltip = "Lower rank means a faster analytical horizon. Equal ranks are intentionally excluded from pair ordering.")
name6   = input.string("Slow 2", "Name", inline = "6c", group = gMA6, display = display.none)
color6  = input.color(#FFAA3D, "Color", inline = "6c", group = gMA6, display = display.none)
width6  = input.int(1, "Width", minval = 1, maxval = 4, inline = "6d", group = gMA6, display = display.none)
transparency6 = input.int(35, "Transparency", minval = 0, maxval = 100, inline = "6d", group = gMA6, display = display.none)

gMA7 = "MA 7 — Custom"
enable7 = input.bool(false, "Enable", inline = "7a", group = gMA7, display = display.none)
type7   = input.string("EMA", "Type", options = ["EMA", "SMA", "WMA", "RMA", "HMA", "DEMA", "TEMA", "VWMA", "ALMA", "KAMA"], inline = "7a", group = gMA7, display = display.none)
len7    = input.int(34, "Length", minval = 1, maxval = 4000, inline = "7b", group = gMA7, display = display.none)
rank7   = input.int(7, "Horizon rank", minval = 1, maxval = 8, inline = "7b", group = gMA7, display = display.none, tooltip = "Lower rank means a faster analytical horizon. Equal ranks are intentionally excluded from pair ordering.")
name7   = input.string("Custom 7", "Name", inline = "7c", group = gMA7, display = display.none)
color7  = input.color(#7D8A99, "Color", inline = "7c", group = gMA7, display = display.none)
width7  = input.int(1, "Width", minval = 1, maxval = 4, inline = "7d", group = gMA7, display = display.none)
transparency7 = input.int(45, "Transparency", minval = 0, maxval = 100, inline = "7d", group = gMA7, display = display.none)

gMA8 = "MA 8 — Custom"
enable8 = input.bool(false, "Enable", inline = "8a", group = gMA8, display = display.none)
type8   = input.string("SMA", "Type", options = ["EMA", "SMA", "WMA", "RMA", "HMA", "DEMA", "TEMA", "VWMA", "ALMA", "KAMA"], inline = "8a", group = gMA8, display = display.none)
len8    = input.int(300, "Length", minval = 1, maxval = 4000, inline = "8b", group = gMA8, display = display.none)
rank8   = input.int(8, "Horizon rank", minval = 1, maxval = 8, inline = "8b", group = gMA8, display = display.none, tooltip = "Lower rank means a faster analytical horizon. Equal ranks are intentionally excluded from pair ordering.")
name8   = input.string("Custom 8", "Name", inline = "8c", group = gMA8, display = display.none)
color8  = input.color(#AAB4C3, "Color", inline = "8c", group = gMA8, display = display.none)
width8  = input.int(1, "Width", minval = 1, maxval = 4, inline = "8d", group = gMA8, display = display.none)
transparency8 = input.int(45, "Transparency", minval = 0, maxval = 100, inline = "8d", group = gMA8, display = display.none)

// ============================================================================
// Preset routing and MA functions
// ============================================================================

f_time_label(int value) =>
    na(value) ? "n/a" : str.format_time(value, "MM-dd HH:mm", syminfo.timezone)

f_tf_label(string value) =>
    float minutes = str.tonumber(value)
    not na(minutes) ? (minutes >= 60.0 and minutes % 60.0 == 0.0 ? str.tostring(int(minutes / 60.0)) + "h" : value + "m") : value

// Quantize the strict MA-boundary condition into its first attainable close tick.
// This keeps the displayed threshold identical to the event's actual threshold.
f_tick_ratio(float boundary) =>
    float ratio = f_safe_div(boundary, syminfo.mintick)
    float nearest = math.round(ratio)
    not na(ratio) and math.abs(ratio - nearest) < 1e-7 ? nearest : ratio

f_upper_checkpoint(float boundary) =>
    float ratio = f_tick_ratio(boundary)
    not na(ratio) ? (math.floor(ratio) + reclaimBufferTicks + 1.0) * syminfo.mintick : na

f_lower_checkpoint(float boundary) =>
    float ratio = f_tick_ratio(boundary)
    not na(ratio) ? (math.ceil(ratio) - reclaimBufferTicks - 1.0) * syminfo.mintick : na

f_checkpoint_cross(float previousClose, float currentClose, float checkpoint, int direction) =>
    float epsilon = syminfo.mintick * 1e-7
    not na(checkpoint) and not na(previousClose) and not na(currentClose) and (direction > 0 ? currentClose >= checkpoint - epsilon and previousClose < checkpoint - epsilon : direction < 0 ? currentClose <= checkpoint + epsilon and previousClose > checkpoint + epsilon : false)

f_add_event_label(bool condition, string content, int direction, float wickPrice, float atrValue, color eventColor, string detail, int stack, bool symbolOnly, array<label> store) =>
    bool emitted = false
    if condition
        bool below = direction >= 0
        bool compact = markerPresentation == "Context symbols"
        float unit = math.max(syminfo.mintick * 2.0, nz(atrValue, high - low))
        float gap = math.max(syminfo.mintick * 2.0, unit * markerGapAtr)
        float laneStep = math.max(syminfo.mintick * 2.0, unit * markerLaneAtr)
        float y = wickPrice + (below ? -1.0 : 1.0) * gap * (1.0 + stack * 1.8)
        bool laneFound = not compact or markerDensityBars == 0
        if not laneFound
            // Only prior detections participate. Never move an earlier marker.
            for lane = 0 to 2
                float candidate = y + (below ? -1.0 : 1.0) * lane * laneStep
                bool collision = false
                int oldCount = array.size(store)
                if oldCount > 0
                    for i = oldCount - 1 to 0
                        label older = array.get(store, i)
                        int separation = bar_index - label.get_x(older)
                        if separation > markerDensityBars
                            break
                        if math.abs(candidate - label.get_y(older)) < laneStep * 0.9
                            collision := true
                            break
                if not collision
                    y := candidate
                    laneFound := true
                    break
        if laneFound
            bool textDot = compact and symbolOnly
            label created = na
            if textDot
                // Plain text, not a filled geometric label. Separate calls keep
                // the int point size and legacy string size on distinct paths.
                created := label.new(bar_index, y, "·", style = label.style_none, color = na, textcolor = color.new(eventColor, markerTransparency), size = rawReclaimDotSize, textalign = text.align_center, text_font_family = font.family_monospace, force_overlay = true, text_formatting = text.format_none, tooltip = detail)
            else
                color card = markerCardStyle == "Dark card" ? headerBackground : eventColor
                color ink = markerCardStyle == "Dark card" ? eventColor : markerTextColor
                string markerStyle = below ? label.style_label_up : label.style_label_down
                created := label.new(bar_index, y, content, style = markerStyle, color = color.new(card, markerTransparency), textcolor = ink, size = f_size(markerTextSize), text_font_family = font.family_default, force_overlay = true, text_formatting = text.format_bold, tooltip = detail)
            array.push(store, created)
            if array.size(store) > maximumEventLabels
                label.delete(array.shift(store))
            emitted := true
    emitted

f_active_enable(simple int slot, simple bool customValue) =>
    bool result = customValue
    if preset != "Custom"
        result := preset == "Balanced Trend" ? slot <= 6 : slot <= 8
    result

f_active_length(simple int slot, simple int customValue) =>
    int result = customValue
    if preset == "Short Horizon"
        result := switch slot
            1 => 5
            2 => 8
            3 => 13
            4 => 21
            5 => 34
            6 => 55
            7 => 89
            => 144
    else if preset == "Balanced Trend"
        result := switch slot
            1 => 5
            2 => 10
            3 => 20
            4 => 50
            5 => 100
            6 => 200
            7 => 34
            => 300
    else if preset == "Long Horizon"
        result := switch slot
            1 => 20
            2 => 34
            3 => 50
            4 => 100
            5 => 150
            6 => 200
            7 => 300
            => 400
    else if preset == "Investor"
        result := switch slot
            1 => 20
            2 => 50
            3 => 100
            4 => 150
            5 => 200
            6 => 250
            7 => 300
            => 400
    result

f_active_type(simple int slot, simple string customValue) =>
    string result = customValue
    if preset == "Short Horizon"
        result := "EMA"
    else if preset == "Balanced Trend"
        result := slot <= 3 or slot == 7 ? "EMA" : "SMA"
    else if preset == "Long Horizon"
        result := slot <= 2 ? "EMA" : "SMA"
    else if preset == "Investor"
        result := slot == 1 ? "EMA" : "SMA"
    result

f_active_rank(simple int slot, simple int customValue) =>
    preset == "Custom" ? customValue : slot

f_kama(float source, simple int length) =>
    float direction = math.abs(source - source[length])
    float volatility = ta.sma(math.abs(ta.change(source)), length) * length
    float efficiency = not na(direction) and not na(volatility) and volatility != 0.0 ? direction / volatility : 0.0
    float fastConstant = 2.0 / 3.0
    float slowConstant = 2.0 / 31.0
    float smoothing = math.pow(efficiency * (fastConstant - slowConstant) + slowConstant, 2.0)
    var float result = na
    result := na(result[1]) ? source : result[1] + smoothing * (source - result[1])
    result

f_ma(float source, simple string maType, simple int length) =>
    switch maType
        "SMA"  => ta.sma(source, length)
        "WMA"  => ta.wma(source, length)
        "RMA"  => ta.rma(source, length)
        "HMA"  =>
            int halfLength = int(math.max(1, math.round(length * 0.5)))
            int sqrtLength = int(math.max(1, math.round(math.sqrt(length))))
            ta.wma(2.0 * ta.wma(source, halfLength) - ta.wma(source, length), sqrtLength)
        "DEMA" =>
            float emaA = ta.ema(source, length)
            float emaB = ta.ema(emaA, length)
            2.0 * emaA - emaB
        "TEMA" =>
            float emaA = ta.ema(source, length)
            float emaB = ta.ema(emaA, length)
            float emaC = ta.ema(emaB, length)
            3.0 * emaA - 3.0 * emaB + emaC
        "VWMA" => ta.vwma(source, length)
        "ALMA" => ta.alma(source, length, 0.85, 6.0)
        "KAMA" => f_kama(source, length)
        => ta.ema(source, length)

// Active slot configuration after preset routing.
bool activeEnable1 = f_active_enable(1, enable1)
int activeLen1 = f_active_length(1, len1)
string activeType1 = f_active_type(1, type1)
int activeRank1 = f_active_rank(1, rank1)
float ma1 = activeEnable1 ? f_ma(src, activeType1, activeLen1) : na
bool activeEnable2 = f_active_enable(2, enable2)
int activeLen2 = f_active_length(2, len2)
string activeType2 = f_active_type(2, type2)
int activeRank2 = f_active_rank(2, rank2)
float ma2 = activeEnable2 ? f_ma(src, activeType2, activeLen2) : na
bool activeEnable3 = f_active_enable(3, enable3)
int activeLen3 = f_active_length(3, len3)
string activeType3 = f_active_type(3, type3)
int activeRank3 = f_active_rank(3, rank3)
float ma3 = activeEnable3 ? f_ma(src, activeType3, activeLen3) : na
bool activeEnable4 = f_active_enable(4, enable4)
int activeLen4 = f_active_length(4, len4)
string activeType4 = f_active_type(4, type4)
int activeRank4 = f_active_rank(4, rank4)
float ma4 = activeEnable4 ? f_ma(src, activeType4, activeLen4) : na
bool activeEnable5 = f_active_enable(5, enable5)
int activeLen5 = f_active_length(5, len5)
string activeType5 = f_active_type(5, type5)
int activeRank5 = f_active_rank(5, rank5)
float ma5 = activeEnable5 ? f_ma(src, activeType5, activeLen5) : na
bool activeEnable6 = f_active_enable(6, enable6)
int activeLen6 = f_active_length(6, len6)
string activeType6 = f_active_type(6, type6)
int activeRank6 = f_active_rank(6, rank6)
float ma6 = activeEnable6 ? f_ma(src, activeType6, activeLen6) : na
bool activeEnable7 = f_active_enable(7, enable7)
int activeLen7 = f_active_length(7, len7)
string activeType7 = f_active_type(7, type7)
int activeRank7 = f_active_rank(7, rank7)
float ma7 = activeEnable7 ? f_ma(src, activeType7, activeLen7) : na
bool activeEnable8 = f_active_enable(8, enable8)
int activeLen8 = f_active_length(8, len8)
string activeType8 = f_active_type(8, type8)
int activeRank8 = f_active_rank(8, rank8)
float ma8 = activeEnable8 ? f_ma(src, activeType8, activeLen8) : na

f_slot_label(int slot) =>
    switch slot
        1 => preset == "Custom" ? name1 : activeType1 + " " + str.tostring(activeLen1)
        2 => preset == "Custom" ? name2 : activeType2 + " " + str.tostring(activeLen2)
        3 => preset == "Custom" ? name3 : activeType3 + " " + str.tostring(activeLen3)
        4 => preset == "Custom" ? name4 : activeType4 + " " + str.tostring(activeLen4)
        5 => preset == "Custom" ? name5 : activeType5 + " " + str.tostring(activeLen5)
        6 => preset == "Custom" ? name6 : activeType6 + " " + str.tostring(activeLen6)
        7 => preset == "Custom" ? name7 : activeType7 + " " + str.tostring(activeLen7)
        8 => preset == "Custom" ? name8 : activeType8 + " " + str.tostring(activeLen8)
        => "n/a"

// Identical MA specifications are a single analytical input, even if several
// visual slots request them. Different MA types at equal lengths remain valid.
f_unique_for_lengths(array<int> lengths) =>
    array<bool> enabled = array.from(activeEnable1, activeEnable2, activeEnable3, activeEnable4, activeEnable5, activeEnable6, activeEnable7, activeEnable8)
    array<string> types = array.from(activeType1, activeType2, activeType3, activeType4, activeType5, activeType6, activeType7, activeType8)
    for slot = 1 to 7
        if array.get(enabled, slot)
            for earlier = 0 to slot - 1
                if array.get(enabled, earlier) and array.get(lengths, earlier) == array.get(lengths, slot) and array.get(types, earlier) == array.get(types, slot)
                    array.set(enabled, slot, false)
                    break
    enabled

f_unique_enables() =>
    f_unique_for_lengths(array.from(activeLen1, activeLen2, activeLen3, activeLen4, activeLen5, activeLen6, activeLen7, activeLen8))

// Cohort membership is a property of the ORIGINAL configuration. Shortening an
// HTF's calculation periods must not move a long-horizon member into the fast set.
// One shared function is used by the core and the chart-topology decomposition.
f_original_cohort_flags() =>
    array<int> originalLengths = array.from(activeLen1, activeLen2, activeLen3, activeLen4, activeLen5, activeLen6, activeLen7, activeLen8)
    array<int> originalRanks = array.from(activeRank1, activeRank2, activeRank3, activeRank4, activeRank5, activeRank6, activeRank7, activeRank8)
    array<bool> originalEnabled = f_unique_enables()
    array<int> uniqueLengths = array.new<int>()
    for slot = 0 to 7
        if array.get(originalEnabled, slot)
            array.push(uniqueLengths, array.get(originalLengths, slot))
    float originalMedian = f_median_int(uniqueLengths)
    array<bool> inFast = array.new<bool>(8, false)
    for slot = 0 to 7
        if array.get(originalEnabled, slot)
            int originalLength = array.get(originalLengths, slot)
            bool byRank = horizonOrderingMode == "Manual rank" ? array.get(originalRanks, slot) <= cohortRankSplit : originalLength <= originalMedian
            bool member = cohortMode == "Horizon rank" ? byRank : cohortMode == "Median length" ? originalLength <= originalMedian : originalLength <= cohortManualLength
            array.set(inFast, slot, member)
    inFast

// All counts here are CONFIGURED counts, independent of MA warm-up or missing
// prices. A structural impossibility must not be displayed as a history wait.
// Code: 0=OK, 1=<2 unique, 2=no eligible pair, 3=no fast, 4=no slow,
//       5=one shortened specification represents members of BOTH cohorts.
f_cohort_configuration(array<int> effectiveLengths, array<bool> effectiveEnabled, array<bool> originalFast) =>
    array<bool> originalEnabled = f_unique_enables()
    array<string> types = array.from(activeType1, activeType2, activeType3, activeType4, activeType5, activeType6, activeType7, activeType8)
    array<int> ranks = array.from(activeRank1, activeRank2, activeRank3, activeRank4, activeRank5, activeRank6, activeRank7, activeRank8)
    int fastMembers = 0
    int slowMembers = 0
    int comparablePairs = 0
    int mixedDuplicates = 0
    for slot = 0 to 7
        if array.get(effectiveEnabled, slot)
            fastMembers += array.get(originalFast, slot) ? 1 : 0
            slowMembers += array.get(originalFast, slot) ? 0 : 1
        else if slot > 0 and array.get(originalEnabled, slot)
            // Effective de-duplication keeps the first matching specification.
            // Do not count that same MA twice just to manufacture two cohorts.
            for earlier = 0 to slot - 1
                if array.get(effectiveEnabled, earlier) and array.get(effectiveLengths, earlier) == array.get(effectiveLengths, slot) and array.get(types, earlier) == array.get(types, slot)
                    if array.get(originalFast, earlier) != array.get(originalFast, slot)
                        mixedDuplicates += 1
                    break
    for i = 0 to 6
        for j = i + 1 to 7
            if array.get(effectiveEnabled, i) and array.get(effectiveEnabled, j)
                bool sameHorizon = horizonOrderingMode == "Manual rank" ? array.get(ranks, i) == array.get(ranks, j) : array.get(effectiveLengths, i) == array.get(effectiveLengths, j)
                comparablePairs += sameHorizon ? 0 : 1
    int issue = mixedDuplicates > 0 ? 5 : fastMembers + slowMembers < 2 ? 1 : fastMembers == 0 ? 3 : slowMembers == 0 ? 4 : comparablePairs == 0 ? 2 : 0
    array.from(fastMembers, slowMembers, comparablePairs, mixedDuplicates, issue)

f_configuration_name(int issue) =>
    switch issue
        1 => "NEED 2 UNIQUE MAs"
        2 => "NO ORDER PAIRS"
        3 => "NO FAST COHORT"
        4 => "NO SLOW COHORT"
        5 => "COHORT COLLISION"
        => "CONFIGURATION OK"

f_configuration_hint(int issue) =>
    switch issue
        1 => "Enable at least two different MA specifications. Identical type/period inputs count only once. Compact HTF rounding may collapse different original periods; Match chart restores full periods."
        2 => "No comparable horizons remain. Use different manual ranks or different effective periods when ordering by length. Shortened equal periods are excluded in Length ascending mode."
        3 => "No retained original member belongs to FAST. Check the original-length boundary, cohort ranks or unique original-length median. More price history will not fix this setting."
        4 => "No retained original member belongs to SLOW. Check the original-length boundary, cohort ranks or unique original-length median. More price history will not fix this setting."
        5 => "HTF shortening made one same-type/period MA represent original members of both cohorts. This layer is explicitly disabled. Use Match chart or separate the original periods/cohort layout. Duplicate votes are not added and no timeframe is substituted."
        => "Both cohorts and at least one eligible pair are configured. Full readiness still requires complete MA, slope, normalization and history data."

// Interval policy, not a fit to available/future data. No hidden timeframe swap.
f_htf_profile(simple string tf) =>
    float seconds = f_tf_seconds(tf)
    int profile = 0
    if htfHistoryMode == "Calendar-bounded" and not na(seconds)
        profile := seconds >= timeframe.in_seconds("12M") ? 5 : seconds >= timeframe.in_seconds("6M") ? 4 : seconds >= timeframe.in_seconds("3M") ? 3 : seconds >= timeframe.in_seconds("1M") ? 2 : seconds >= timeframe.in_seconds("1W") ? 1 : 0
    profile

f_profile_cap(simple int profile) =>
    profile == 1 ? 52 : profile == 2 ? 24 : profile == 3 ? 12 : profile == 4 ? 8 : profile == 5 ? 6 : 4000

f_profile_name(int profile) =>
    profile == 1 ? "W-52" : profile == 2 ? "M-24" : profile == 3 ? "Q-12" : profile == 4 ? "H-8" : profile == 5 ? "Y-6" : "MATCH"

f_profile_maximum() =>
    int longest = math.max(activeEnable1 ? activeLen1 : 1, activeEnable2 ? activeLen2 : 1, activeEnable3 ? activeLen3 : 1, activeEnable4 ? activeLen4 : 1, activeEnable5 ? activeLen5 : 1, activeEnable6 ? activeLen6 : 1, activeEnable7 ? activeLen7 : 1, activeEnable8 ? activeLen8 : 1)
    longest

f_profile_length(simple int original, simple int profile) =>
    int cap = f_profile_cap(profile)
    int longest = f_profile_maximum()
    profile == 0 or longest <= cap ? original : int(math.max(1, math.round(float(original) * cap / longest)))

// ============================================================================
// Core regime-state engine
// ============================================================================
f_regime_state(simple int profile) =>
    RegimeState state = RegimeState.new()
    // Simple, fixed effective parameters. No per-bar length changes.
    int cap = f_profile_cap(profile)
    int slopeCap = profile <= 1 ? 5 : profile == 2 ? 3 : profile <= 4 ? 2 : 1
    int reorderCap = profile == 1 ? 26 : profile == 2 ? 12 : profile == 3 ? 6 : profile == 4 ? 4 : 3
    int atrCap = profile <= 2 ? 14 : profile == 3 ? 6 : profile == 4 ? 4 : 3
    int rankWindow = profile == 0 ? widthRankLookback : math.min(widthRankLookback, cap)
    int reorderWindow = profile == 0 ? reorderLookback : math.min(reorderLookback, reorderCap)
    int slopeWindow = profile == 0 ? slopeLookback : math.min(slopeLookback, slopeCap)
    int motionWindow = profile == 0 ? widthMotionBars : math.min(widthMotionBars, math.min(3, slopeCap))
    int decelWindow = profile == 0 ? decelerationLookback : math.min(decelerationLookback, slopeCap)
    int atrWindow = profile == 0 ? atrLength : math.min(atrLength, atrCap)
    int stdevWindow = profile == 0 ? stdevLength : math.min(stdevLength, cap)
    int floorWindow = profile == 0 ? minimumWarmupBars : math.min(minimumWarmupBars, cap)
    int length1 = f_profile_length(activeLen1, profile)
    float value1 = activeEnable1 ? f_ma(src, activeType1, length1) : na
    int length2 = f_profile_length(activeLen2, profile)
    float value2 = activeEnable2 ? f_ma(src, activeType2, length2) : na
    int length3 = f_profile_length(activeLen3, profile)
    float value3 = activeEnable3 ? f_ma(src, activeType3, length3) : na
    int length4 = f_profile_length(activeLen4, profile)
    float value4 = activeEnable4 ? f_ma(src, activeType4, length4) : na
    int length5 = f_profile_length(activeLen5, profile)
    float value5 = activeEnable5 ? f_ma(src, activeType5, length5) : na
    int length6 = f_profile_length(activeLen6, profile)
    float value6 = activeEnable6 ? f_ma(src, activeType6, length6) : na
    int length7 = f_profile_length(activeLen7, profile)
    float value7 = activeEnable7 ? f_ma(src, activeType7, length7) : na
    int length8 = f_profile_length(activeLen8, profile)
    float value8 = activeEnable8 ? f_ma(src, activeType8, length8) : na

    array<float> values = array.from(value1, value2, value3, value4, value5, value6, value7, value8)
    array<int> lengths = array.from(length1, length2, length3, length4, length5, length6, length7, length8)
    array<bool> enables = f_unique_for_lengths(lengths)
    array<int> ranks = array.from(activeRank1, activeRank2, activeRank3, activeRank4, activeRank5, activeRank6, activeRank7, activeRank8)
    // These inputs are fixed for this call/context. Cache configuration only;
    // price values, slopes, geometry and events continue to calculate every bar.
    var array<bool> originalFast = f_original_cohort_flags()
    var array<int> cohortLayout = f_cohort_configuration(lengths, enables, originalFast)
    int configuredFast = array.get(cohortLayout, 0)
    int configuredSlow = array.get(cohortLayout, 1)
    int configuredPairs = array.get(cohortLayout, 2)
    int crossCohortDuplicates = array.get(cohortLayout, 3)
    int configurationIssue = array.get(cohortLayout, 4)

    int enabledCount = 0
    int configuredCount = 0
    int maximumLength = 0
    float valueSum = 0.0
    for i = 0 to 7
        bool enabled = array.get(enables, i)
        float value = array.get(values, i)
        if enabled
            configuredCount += 1
            int activeLength = array.get(lengths, i)
            maximumLength := int(math.max(maximumLength, activeLength))
            if not na(value)
                enabledCount += 1
                valueSum += value

    float centroid = enabledCount > 0 ? valueSum / enabledCount : na
    float atrValue = ta.atr(atrWindow)
    float stdevValue = ta.stdev(src, stdevWindow)
    float normDenom = normalizationMode == "ATR" ? atrValue : normalizationMode == "Percentage" ? (not na(centroid) ? math.abs(centroid) : na) : stdevValue

    float bundleHigh = na
    float bundleLow = na
    if enabledCount > 0
        for i = 0 to 7
            if array.get(enables, i)
                float value = array.get(values, i)
                if not na(value)
                    bundleHigh := na(bundleHigh) ? value : math.max(bundleHigh, value)
                    bundleLow := na(bundleLow) ? value : math.min(bundleLow, value)

    float bundleWidth = not na(bundleHigh) and not na(bundleLow) ? bundleHigh - bundleLow : na
    float widthNorm = f_normalize_distance(bundleWidth, centroid, atrValue, stdevValue, normalizationMode)
    // Rank only complete-ensemble geometry. Restart readiness after missing data.
    bool completeGeometry = configuredCount >= 2 and enabledCount == configuredCount and not na(normDenom) and normDenom > 0.0
    float rankInput = completeGeometry ? widthNorm : na
    float widthRank = ta.percentrank(rankInput, rankWindow)
    var int fullGeometryBars = 0
    fullGeometryBars := completeGeometry ? nz(fullGeometryBars[1], 0) + 1 : 0
    float widthDelta = not na(widthNorm) and not na(widthNorm[motionWindow]) ? widthNorm - widthNorm[motionWindow] : na
    // Exact path-specific decomposition: first vary width at the current divisor,
    // then attribute the rest to divisor motion. The two terms sum to widthDelta.
    float unitFactor = normalizationMode == "Percentage" ? 100.0 : 1.0
    float widthGeometryDelta = completeGeometry and not na(bundleWidth[motionWindow]) ? unitFactor * (bundleWidth - bundleWidth[motionWindow]) / normDenom : na
    float widthDenominatorDelta = not na(widthDelta) and not na(widthGeometryDelta) ? widthDelta - widthGeometryDelta : na

    float slope1 = f_normalize_distance(value1 - value1[slopeWindow], centroid, atrValue, stdevValue, normalizationMode)
    float slope2 = f_normalize_distance(value2 - value2[slopeWindow], centroid, atrValue, stdevValue, normalizationMode)
    float slope3 = f_normalize_distance(value3 - value3[slopeWindow], centroid, atrValue, stdevValue, normalizationMode)
    float slope4 = f_normalize_distance(value4 - value4[slopeWindow], centroid, atrValue, stdevValue, normalizationMode)
    float slope5 = f_normalize_distance(value5 - value5[slopeWindow], centroid, atrValue, stdevValue, normalizationMode)
    float slope6 = f_normalize_distance(value6 - value6[slopeWindow], centroid, atrValue, stdevValue, normalizationMode)
    float slope7 = f_normalize_distance(value7 - value7[slopeWindow], centroid, atrValue, stdevValue, normalizationMode)
    float slope8 = f_normalize_distance(value8 - value8[slopeWindow], centroid, atrValue, stdevValue, normalizationMode)
    array<float> slopes = array.from(slope1, slope2, slope3, slope4, slope5, slope6, slope7, slope8)

    int slopeCount = 0
    int risingCount = 0
    int fallingCount = 0
    int flatCount = 0
    float signedSlopeSum = 0.0
    float absoluteSlopeSum = 0.0
    for i = 0 to 7
        if array.get(enables, i)
            float slopeValue = array.get(slopes, i)
            if not na(slopeValue)
                slopeCount += 1
                signedSlopeSum += slopeValue
                absoluteSlopeSum += math.abs(slopeValue)
                if slopeValue > slopeFlatThreshold
                    risingCount += 1
                else if slopeValue < -slopeFlatThreshold
                    fallingCount += 1
                else
                    flatCount += 1

    float slopeUpBreadth = slopeCount > 0 ? 100.0 * risingCount / slopeCount : na
    float slopeDownBreadth = slopeCount > 0 ? 100.0 * fallingCount / slopeCount : na
    float slopeFlatBreadth = slopeCount > 0 ? 100.0 * flatCount / slopeCount : na
    float slopeEnergyRaw = slopeCount > 0 ? absoluteSlopeSum / slopeCount : na
    float slopeEnergyScore = not na(slopeEnergyRaw) ? f_clamp(100.0 * slopeEnergyRaw / slopeEnergyScale, 0.0, 100.0) : na
    float slopeCoherence = absoluteSlopeSum > 0.0 ? 100.0 * signedSlopeSum / absoluteSlopeSum : 0.0

    float centroidSlope = f_normalize_distance(centroid - centroid[slopeWindow], centroid, atrValue, stdevValue, normalizationMode)
    float centroidAcceleration = not na(centroidSlope) and not na(centroidSlope[decelWindow]) ? centroidSlope - centroidSlope[decelWindow] : na

    float weightedSignSum = 0.0
    float totalPairWeight = 0.0
    float upWeight = 0.0
    float downWeight = 0.0
    float tiedWeight = 0.0
    int eligiblePairs = 0
    int skippedPairs = 0
    int upPairs = 0
    int downPairs = 0
    int tiedPairs = 0
    int reordersThisBar = 0
    var array<int> lastNonNeutralPairSign = array.new<int>(64, 0)

    for i = 0 to 6
        for j = i + 1 to 7
            bool pairEnabled = array.get(enables, i) and array.get(enables, j)
            if pairEnabled
                int rankI = array.get(ranks, i)
                int rankJ = array.get(ranks, j)
                int lengthI = array.get(lengths, i)
                int lengthJ = array.get(lengths, j)
                bool equalHorizon = horizonOrderingMode == "Manual rank" ? rankI == rankJ : lengthI == lengthJ
                if equalHorizon
                    skippedPairs += 1
                else
                    float valueI = array.get(values, i)
                    float valueJ = array.get(values, j)
                    if not na(valueI) and not na(valueJ)
                        eligiblePairs += 1
                        bool iIsFaster = horizonOrderingMode == "Manual rank" ? rankI < rankJ : lengthI < lengthJ
                        float fastValue = iIsFaster ? valueI : valueJ
                        float slowValue = iIsFaster ? valueJ : valueI
                        float normalizedDifference = f_normalize_distance(fastValue - slowValue, centroid, atrValue, stdevValue, normalizationMode)
                        int currentSign = na(normalizedDifference) ? 0 : normalizedDifference > pairSeparation ? 1 : normalizedDifference < -pairSeparation ? -1 : 0
                        float horizonDistance = horizonOrderingMode == "Manual rank" ? float(math.abs(rankI - rankJ)) : 1.0 + math.abs(math.log(float(lengthI) / float(lengthJ)))
                        float pairWeight = math.pow(horizonDistance, horizonWeightPower)
                        totalPairWeight += pairWeight
                        weightedSignSum += pairWeight * currentSign
                        if currentSign > 0
                            upPairs += 1
                            upWeight += pairWeight
                        else if currentSign < 0
                            downPairs += 1
                            downWeight += pairWeight
                        else
                            tiedPairs += 1
                            tiedWeight += pairWeight

                        int pairId = i * 8 + j
                        int previousNonNeutral = array.get(lastNonNeutralPairSign, pairId)
                        if currentSign != 0
                            if previousNonNeutral != 0 and currentSign != previousNonNeutral
                                reordersThisBar += 1
                            array.set(lastNonNeutralPairSign, pairId, currentSign)

    float orderCoherence = totalPairWeight > 0.0 ? 100.0 * weightedSignSum / totalPairWeight : na
    float orderPurity = totalPairWeight > 0.0 ? 100.0 * math.max(upWeight, downWeight) / totalPairWeight : na
    float tieRatio = totalPairWeight > 0.0 ? 100.0 * tiedWeight / totalPairWeight : na
    float reorderSum = math.sum(float(reordersThisBar), reorderWindow)
    float reorderRate = eligiblePairs > 0 and bar_index >= reorderWindow ? 100.0 * reorderSum / (eligiblePairs * reorderWindow) : na

    float fastValueSum = 0.0
    float slowValueSum = 0.0
    float slowSignedSlope = 0.0
    float slowAbsoluteSlope = 0.0
    int fastCount = 0
    int slowCount = 0
    for i = 0 to 7
        if array.get(enables, i)
            float value = array.get(values, i)
            if not na(value)
                bool isFast = array.get(originalFast, i)
                if isFast
                    fastValueSum += value
                    fastCount += 1
                else
                    slowValueSum += value
                    slowCount += 1
                    float slopeValue = array.get(slopes, i)
                    if not na(slopeValue)
                        slowSignedSlope += slopeValue
                        slowAbsoluteSlope += math.abs(slopeValue)

    float fastCentroid = fastCount > 0 ? fastValueSum / fastCount : na
    float slowCentroid = slowCount > 0 ? slowValueSum / slowCount : na
    float cohortSpread = not na(fastCentroid) and not na(slowCentroid) ? f_normalize_distance(fastCentroid - slowCentroid, centroid, atrValue, stdevValue, normalizationMode) : na
    float slowSlopeCoherence = slowAbsoluteSlope > 0.0 ? 100.0 * slowSignedSlope / slowAbsoluteSlope : 0.0

    float pricePosition = not na(bundleWidth) and bundleWidth > 0.0 ? 100.0 * (close - bundleLow) / bundleWidth : na
    float cohortBiasScore = not na(cohortSpread) ? f_clamp(100.0 * cohortSpread / cohortBiasScale, -100.0, 100.0) : 0.0
    float biasComposite = not na(orderCoherence) and not na(slopeCoherence) ? 0.45 * orderCoherence + 0.30 * slopeCoherence + 0.25 * cohortBiasScore : na
    int bias = na(biasComposite) ? 0 : biasComposite > 0.0 and biasComposite >= biasThreshold ? 1 : biasComposite < 0.0 and biasComposite <= -biasThreshold ? -1 : 0

    float clarityBase = not na(orderCoherence) and not na(orderPurity) and not na(tieRatio) and not na(slopeEnergyScore) ? 0.38 * math.abs(orderCoherence) + 0.22 * orderPurity + 0.20 * math.abs(slopeCoherence) + 0.15 * slopeEnergyScore + 0.05 * (100.0 - tieRatio) : na
    float clarity = not na(clarityBase) ? f_clamp(clarityBase - nz(reorderRate, 0.0) * clarityReorderPenalty, 0.0, 100.0) : na

    int autoWarmup = int(math.max(maximumLength + slopeWindow, math.max(rankWindow, reorderWindow)))
    int activeWarmup = useAutoWarmup ? int(math.max(floorWindow, autoWarmup)) : floorWindow
    int completeHistoryNeeded = int(math.max(rankWindow + 1, math.max(slopeWindow + decelWindow + 1, reorderWindow + 1)))
    bool directionReady = configurationIssue == 0 and completeGeometry and eligiblePairs > 0 and slopeCount == configuredCount and fastCount > 0 and slowCount > 0 and fullGeometryBars >= math.max(slopeWindow + 1, reorderWindow + 1) and bar_index >= activeWarmup and not na(reorderRate) and not na(biasComposite)
    bool ready = configurationIssue == 0 and completeGeometry and eligiblePairs > 0 and slopeCount == configuredCount and fastCount > 0 and slowCount > 0 and fullGeometryBars >= completeHistoryNeeded and bar_index >= activeWarmup and not na(widthRank) and not na(reorderRate) and not na(biasComposite)

    bool compressionRaw = ready and widthRank <= compressionRankThreshold and slopeEnergyScore <= compressionEnergyMaximum and math.abs(orderCoherence) <= compressionOrderMaximum and reorderRate < churnReorderThreshold
    int compressionBarsAgo = ta.barssince(compressionRaw)
    bool recentCompression = not na(compressionBarsAgo) and compressionBarsAgo > 0 and compressionBarsAgo <= releaseOriginLookback
    bool directionalOrder = bias == 1 ? orderCoherence >= orderedThreshold : bias == -1 ? orderCoherence <= -orderedThreshold : false
    bool directionalSlope = bias == 1 ? slopeCoherence >= slopeCoherenceThreshold : bias == -1 ? slopeCoherence <= -slopeCoherenceThreshold : false
    bool releaseOrder = bias != 0 and orderCoherence * bias >= releaseOrderMinimum
    bool accelerationAligned = bias == 1 ? centroidAcceleration >= releaseAccelerationMin : bias == -1 ? centroidAcceleration <= -releaseAccelerationMin : false
    bool releaseRaw = ready and bias != 0 and recentCompression and releaseOrder and widthDelta >= releaseWidthMinimum and (not requireGeometricWidth or widthGeometryDelta >= releaseWidthMinimum) and accelerationAligned

    bool insideBundle = ready and close <= bundleHigh and close >= bundleLow
    bool orderHeld = bias == 1 ? orderCoherence >= pullbackOrderFloor : bias == -1 ? orderCoherence <= -pullbackOrderFloor : false
    bool slowSlopeHeld = bias == 1 ? slowSlopeCoherence >= slowSlopeHoldThreshold : bias == -1 ? slowSlopeCoherence <= -slowSlopeHoldThreshold : false
    bool pullbackRaw = ready and bias != 0 and insideBundle and orderHeld and slowSlopeHeld and not releaseRaw

    bool priceOnDirectionalSide = bias == 1 ? close >= centroid : bias == -1 ? close <= centroid : false
    bool expansionRaw = ready and bias != 0 and directionalOrder and directionalSlope and priceOnDirectionalSide and not releaseRaw and not pullbackRaw

    bool energyFalling = not na(slopeEnergyScore[decelWindow]) and slopeEnergyScore <= slopeEnergyScore[decelWindow] - decelerationEnergyDrop
    bool coherenceFalling = not na(slopeCoherence[decelWindow]) and math.abs(slopeCoherence) <= math.abs(slopeCoherence[decelWindow]) - decelerationSlopeDrop
    bool widthContracting = not na(widthDelta) and widthDelta <= -decelerationWidthMinimum and (not requireGeometricWidth or widthGeometryDelta <= -decelerationWidthMinimum)
    bool decelerationRaw = ready and bias != 0 and orderHeld and (energyFalling or coherenceFalling or widthContracting) and not releaseRaw and not pullbackRaw

    int phase = 0
    if ready
        phase := compressionRaw ? 1 : releaseRaw ? 2 : pullbackRaw ? 4 : decelerationRaw ? 5 : expansionRaw ? 3 : 6

    int stateKey = ready ? f_state_key(bias, phase) : -1
    var int stateAge = 0
    var bool episodeStartKnown = false
    if not ready
        stateAge := 0
        episodeStartKnown := false
    else if na(stateKey[1]) or stateKey[1] < 0
        stateAge := 1
        episodeStartKnown := false
    else if stateKey != stateKey[1]
        stateAge := 1
        episodeStartKnown := true
    else
        stateAge := nz(stateAge[1], 0) + 1

    float pullbackDepth = na
    if ready and not na(pricePosition)
        pullbackDepth := bias == 1 ? f_clamp(100.0 - pricePosition, 0.0, 200.0) : bias == -1 ? f_clamp(pricePosition, 0.0, 200.0) : f_clamp(math.abs(pricePosition - 50.0) * 2.0, 0.0, 200.0)

    state.ready := ready
    state.directionReady := directionReady
    state.configurationIssue := configurationIssue
    state.configuredFast := configuredFast
    state.configuredSlow := configuredSlow
    state.configuredPairs := configuredPairs
    state.crossCohortDuplicates := crossCohortDuplicates
    state.profileCode := profile
    state.loadedBars := bar_index + 1
    state.geometryBars := fullGeometryBars
    state.geometryNeeded := completeHistoryNeeded
    state.warmupFloor := activeWarmup + 1
    state.maximumLength := maximumLength
    state.effectiveRank := rankWindow
    state.effectiveReorder := reorderWindow
    state.effectiveSlope := slopeWindow
    state.effectiveMotion := motionWindow
    state.effectiveDecel := decelWindow
    state.effectiveAtr := atrWindow
    state.effectiveStdev := stdevWindow
    var string effectiveSpec = ""
    if barstate.isfirst
        array<string> specTypes = array.from(activeType1, activeType2, activeType3, activeType4, activeType5, activeType6, activeType7, activeType8)
        for slot = 0 to 7
            if array.get(enables, slot)
                effectiveSpec += (effectiveSpec == "" ? "" : ", ") + (array.get(originalFast, slot) ? "F:" : "S:") + array.get(specTypes, slot) + str.tostring(array.get(lengths, slot))
    state.effectiveSpec := effectiveSpec
    state.closedAt := time_close
    state.atrValue := atrValue
    int requestedSlots = (activeEnable1 ? 1 : 0) + (activeEnable2 ? 1 : 0) + (activeEnable3 ? 1 : 0) + (activeEnable4 ? 1 : 0) + (activeEnable5 ? 1 : 0) + (activeEnable6 ? 1 : 0) + (activeEnable7 ? 1 : 0) + (activeEnable8 ? 1 : 0)
    state.duplicateCount := requestedSlots - configuredCount
    state.configuredCount := configuredCount
    state.enabledCount := enabledCount
    state.episodeStartKnown := episodeStartKnown
    state.eligiblePairs := eligiblePairs
    state.skippedPairs := skippedPairs
    state.upPairs := upPairs
    state.downPairs := downPairs
    state.tiedPairs := tiedPairs
    state.fastCount := fastCount
    state.slowCount := slowCount
    state.bias := bias
    state.phase := phase
    state.stateKey := stateKey
    state.age := stateAge
    state.centroid := centroid
    state.bundleHigh := bundleHigh
    state.bundleLow := bundleLow
    state.normDenom := normDenom
    state.widthNorm := widthNorm
    state.widthRank := widthRank
    state.widthDelta := widthDelta
    state.widthGeometryDelta := widthGeometryDelta
    state.widthDenominatorDelta := widthDenominatorDelta
    state.orderCoherence := orderCoherence
    state.orderPurity := orderPurity
    state.tieRatio := tieRatio
    state.reorderRate := reorderRate
    state.slopeUpBreadth := slopeUpBreadth
    state.slopeDownBreadth := slopeDownBreadth
    state.slopeFlatBreadth := slopeFlatBreadth
    state.slopeEnergyRaw := slopeEnergyRaw
    state.slopeEnergyScore := slopeEnergyScore
    state.slopeCoherence := slopeCoherence
    state.centroidSlope := centroidSlope
    state.centroidAcceleration := centroidAcceleration
    state.fastCentroid := fastCentroid
    state.slowCentroid := slowCentroid
    state.cohortSpread := cohortSpread
    state.slowSlopeCoherence := slowSlopeCoherence
    state.pricePosition := pricePosition
    state.pullbackDepth := pullbackDepth
    state.clarity := clarity
    state.biasComposite := biasComposite
    state

f_confirmed_regime_state() =>
    RegimeState live = f_regime_state(f_htf_profile(timeframe.period))
    // Pine v6 requires history to be taken from the UDT object itself.
    // Returning live[1] supplies the fully confirmed preceding HTF object.
    live[1]

// Chart context and confirmed higher-timeframe contexts.
RegimeState chartState = f_regime_state(0)
RegimeState previousChartState = chartState[1]
if na(previousChartState)
    previousChartState := RegimeState.new()
float chartSeconds = f_tf_seconds(timeframe.period)
float anchorSeconds = f_tf_seconds(anchorTimeframe)
float macroSeconds = f_tf_seconds(macroTimeframe)
bool anchorValid = useAnchorTimeframe and not na(anchorSeconds) and not na(chartSeconds) and anchorSeconds > chartSeconds
bool macroAboveChart = useMacroTimeframe and not na(macroSeconds) and not na(chartSeconds) and macroSeconds > chartSeconds
bool macroValid = macroAboveChart and (not useAnchorTimeframe or not anchorValid or macroSeconds > anchorSeconds)

RegimeState anchorState = RegimeState.new()
RegimeState macroState = RegimeState.new()
if anchorValid
    anchorState := request.security(syminfo.tickerid, anchorTimeframe, f_confirmed_regime_state(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on, calc_bars_count = mtfCalcBars)
    if na(anchorState)
        anchorState := RegimeState.new()
if macroValid
    macroState := request.security(syminfo.tickerid, macroTimeframe, f_confirmed_regime_state(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on, calc_bars_count = mtfCalcBars)
    if na(macroState)
        macroState := RegimeState.new()

// ============================================================================
// MTF synthesis
// ============================================================================
int configuredMtfLayers = (useAnchorTimeframe ? 1 : 0) + (useMacroTimeframe ? 1 : 0)
bool mtfConfigurationValid = (not useAnchorTimeframe or anchorValid) and (not useMacroTimeframe or macroValid)
bool requestedLayersReady = chartState.ready and mtfConfigurationValid and (not anchorValid or anchorState.ready) and (not macroValid or macroState.ready)
bool anchorBiasAligned = not anchorValid or (anchorState.ready and chartState.bias != 0 and anchorState.bias == chartState.bias)
bool macroBiasAligned = not macroValid or (macroState.ready and chartState.bias != 0 and macroState.bias == chartState.bias)
bool fullAlignment = configuredMtfLayers > 0 and mtfConfigurationValid and requestedLayersReady and chartState.bias != 0 and anchorBiasAligned and macroBiasAligned
int alignedDirection = fullAlignment ? chartState.bias : 0
bool alignmentGained = fullAlignment and alignedDirection != nz(alignedDirection[1], 0)
bool alignmentLost = nz(alignedDirection[1], 0) != 0 and alignedDirection != alignedDirection[1]

string mtfContext = "CHART ONLY"
if configuredMtfLayers > 0
    if not mtfConfigurationValid
        mtfContext := "INVALID HIERARCHY"
    else if not requestedLayersReady
        mtfContext := "WAITING HTF CLOSE"
    else if fullAlignment and chartState.phase == 4
        mtfContext := "HTF-ALIGNED PULLBACK"
    else if fullAlignment and chartState.phase == 2
        mtfContext := "FULL-ALIGN RELEASE"
    else if fullAlignment
        mtfContext := "FULL ALIGNMENT"
    else if chartState.bias != 0 and ((anchorValid and anchorState.bias == -chartState.bias) or (macroValid and macroState.bias == -chartState.bias))
        mtfContext := "COUNTERTREND"
    else
        mtfContext := "MIXED STRUCTURE"

// ============================================================================
// Pair-topology attribution and fixed-vote single-slot deletion audit
// ============================================================================
f_order_class(float value) =>
    na(value) ? 0 : value >= topologyOrderFloor ? 1 : value <= -topologyOrderFloor ? -1 : 0

f_topology_audit(RegimeState state) =>
    TopologyStats audit = TopologyStats.new()
    if state.ready
        array<float> values = array.from(ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8)
        array<bool> enabled = f_unique_enables()
        array<int> lengths = array.from(activeLen1, activeLen2, activeLen3, activeLen4, activeLen5, activeLen6, activeLen7, activeLen8)
        array<int> ranks = array.from(activeRank1, activeRank2, activeRank3, activeRank4, activeRank5, activeRank6, activeRank7, activeRank8)
        array<float> incidentSigned = array.new<float>(8, 0.0)
        array<float> incidentWeight = array.new<float>(8, 0.0)
        array<float> blockSigned = array.new<float>(3, 0.0)
        array<float> blockWeight = array.new<float>(3, 0.0)
        var array<bool> fastSlot = f_original_cohort_flags()
        float totalSigned = 0.0
        float totalWeight = 0.0
        float factor = normalizationMode == "Percentage" ? 100.0 : 1.0
        for i = 0 to 6
            for j = i + 1 to 7
                if array.get(enabled, i) and array.get(enabled, j)
                    int rankI = array.get(ranks, i)
                    int rankJ = array.get(ranks, j)
                    int lenI = array.get(lengths, i)
                    int lenJ = array.get(lengths, j)
                    bool sameHorizon = horizonOrderingMode == "Manual rank" ? rankI == rankJ : lenI == lenJ
                    if not sameHorizon
                        bool iFaster = horizonOrderingMode == "Manual rank" ? rankI < rankJ : lenI < lenJ
                        float gap = (array.get(values, i) - array.get(values, j)) * (iFaster ? 1.0 : -1.0) * factor / state.normDenom
                        int vote = gap > pairSeparation ? 1 : gap < -pairSeparation ? -1 : 0
                        float distance = horizonOrderingMode == "Manual rank" ? float(math.abs(rankI - rankJ)) : 1.0 + math.abs(math.log(float(lenI) / float(lenJ)))
                        float weight = math.pow(distance, horizonWeightPower)
                        float signedWeight = weight * vote
                        totalSigned += signedWeight
                        totalWeight += weight
                        array.set(incidentSigned, i, array.get(incidentSigned, i) + signedWeight)
                        array.set(incidentSigned, j, array.get(incidentSigned, j) + signedWeight)
                        array.set(incidentWeight, i, array.get(incidentWeight, i) + weight)
                        array.set(incidentWeight, j, array.get(incidentWeight, j) + weight)
                        bool iFast = array.get(fastSlot, i)
                        bool jFast = array.get(fastSlot, j)
                        int block = iFast and jFast ? 0 : not iFast and not jFast ? 2 : 1
                        array.set(blockSigned, block, array.get(blockSigned, block) + signedWeight)
                        array.set(blockWeight, block, array.get(blockWeight, block) + weight)
        if totalWeight > 0.0
            audit.valid := true
            audit.fastOrder := f_safe_div(100.0 * array.get(blockSigned, 0), array.get(blockWeight, 0))
            audit.crossOrder := f_safe_div(100.0 * array.get(blockSigned, 1), array.get(blockWeight, 1))
            audit.slowOrder := f_safe_div(100.0 * array.get(blockSigned, 2), array.get(blockWeight, 2))
            float fullOrder = 100.0 * totalSigned / totalWeight
            audit.recompositionError := math.abs(fullOrder - state.orderCoherence)
            int referenceClass = f_order_class(fullOrder)
            int agreeing = 0
            // A deletion is meaningful only when at least two slots remain and
            // the remaining slots contain at least one eligible pair.
            if state.enabledCount >= 3
                for slot = 0 to 7
                    if array.get(enabled, slot)
                        float remainingWeight = totalWeight - array.get(incidentWeight, slot)
                        if remainingWeight > totalWeight * 1e-10
                            float deletedOrder = f_clamp(100.0 * (totalSigned - array.get(incidentSigned, slot)) / remainingWeight, -100.0, 100.0)
                            float shift = math.abs(deletedOrder - fullOrder)
                            audit.validAblations += 1
                            agreeing += f_order_class(deletedOrder) == referenceClass ? 1 : 0
                            audit.looLow := na(audit.looLow) ? deletedOrder : math.min(audit.looLow, deletedOrder)
                            audit.looHigh := na(audit.looHigh) ? deletedOrder : math.max(audit.looHigh, deletedOrder)
                            if na(audit.largestShift) or shift > audit.largestShift
                                audit.largestShift := shift
                                audit.influentialSlot := slot + 1
                audit.agreement := audit.validAblations > 0 ? 100.0 * agreeing / audit.validAblations : na
    audit

TopologyStats topologyStats = f_topology_audit(chartState)
bool topologyInvariantOk = not topologyStats.valid or topologyStats.recompositionError <= 1e-6
bool topologyRobust = topologyStats.valid and topologyInvariantOk and topologyStats.validAblations == chartState.enabledCount and topologyStats.agreement >= 100.0 - 1e-8 and topologyStats.largestShift <= topologyMaximumShift and f_order_class(chartState.orderCoherence) != 0

// Closed HUD snapshots are a display policy, not an extra lag in event detection.
bool holdHudSnapshot = hudSnapshotMode == "Confirmed" and not barstate.isconfirmed
RegimeState closedChartState = barstate.isconfirmed ? chartState : previousChartState
RegimeState hudState = holdHudSnapshot ? previousChartState : chartState
RegimeState hudAnchor = holdHudSnapshot ? anchorState[1] : anchorState
RegimeState hudMacro = holdHudSnapshot ? macroState[1] : macroState
TopologyStats hudTopology = holdHudSnapshot ? topologyStats[1] : topologyStats
if na(hudAnchor)
    hudAnchor := RegimeState.new()
if na(hudMacro)
    hudMacro := RegimeState.new()
if na(hudTopology)
    hudTopology := TopologyStats.new()
float hudClose = holdHudSnapshot ? close[1] : close
float lastClosedPrice = barstate.isconfirmed ? close : close[1]
int closedReferenceBar = barstate.isconfirmed ? bar_index : bar_index - 1

// ============================================================================
// Bounded completed-episode memory: durations and destinations share a window
// ============================================================================
int STATE_COUNT = 18
int PHASE_COUNT = 6
var matrix<int> durationMatrix = matrix.new<int>(STATE_COUNT, memorySamplesPerState, 0)
var matrix<int> nextPhaseMatrix = matrix.new<int>(STATE_COUNT, memorySamplesPerState, 0)
var array<int> durationCounts = array.new<int>(STATE_COUNT, 0)
var array<int> durationWritePositions = array.new<int>(STATE_COUNT, 0)
var matrix<int> stateNextPhaseCounts = matrix.new<int>(STATE_COUNT, PHASE_COUNT, 0)

f_store_episode(int key, int duration, int destinationPhase) =>
    if enableStructureMemory and key >= 0 and key < STATE_COUNT and duration > 0 and destinationPhase >= 1 and destinationPhase <= PHASE_COUNT
        int writePosition = array.get(durationWritePositions, key)
        int previousDestination = matrix.get(nextPhaseMatrix, key, writePosition)
        if previousDestination > 0
            int oldCount = matrix.get(stateNextPhaseCounts, key, previousDestination - 1)
            matrix.set(stateNextPhaseCounts, key, previousDestination - 1, oldCount - 1)
        matrix.set(durationMatrix, key, writePosition, duration)
        matrix.set(nextPhaseMatrix, key, writePosition, destinationPhase)
        matrix.set(stateNextPhaseCounts, key, destinationPhase - 1, matrix.get(stateNextPhaseCounts, key, destinationPhase - 1) + 1)
        array.set(durationWritePositions, key, (writePosition + 1) % memorySamplesPerState)
        array.set(durationCounts, key, int(math.min(array.get(durationCounts, key) + 1, memorySamplesPerState)))

// The first visible episode and episodes interrupted by a data gap have unknown
// start/end boundaries; they are excluded, not counted as complete observations.
if barstate.isconfirmed and chart.is_standard and chartTimeBased and enableStructureMemory and chartState.ready and previousChartState.ready and previousChartState.episodeStartKnown and chartState.stateKey != previousChartState.stateKey
    f_store_episode(previousChartState.stateKey, previousChartState.age, chartState.phase)

f_duration_statistics(int key, int currentAge) =>
    DurationStats stats = DurationStats.new()
    if enableStructureMemory and chart.is_standard and chartTimeBased and key >= 0 and key < STATE_COUNT
        int count = array.get(durationCounts, key)
        stats.count := count
        if count > 0
            array<int> completedDurations = array.new<int>()
            int ageRankCount = 0
            int persistsFurtherCount = 0
            for sample = 0 to count - 1
                int duration = matrix.get(durationMatrix, key, sample)
                array.push(completedDurations, duration)
                if duration <= currentAge
                    ageRankCount += 1
                if duration >= currentAge
                    stats.atRiskCount += 1
                    if duration >= currentAge + persistenceHorizon
                        persistsFurtherCount += 1
            // Raw counts remain visible; numerical interpretation is withheld
            // until the corresponding denominator meets its own minimum.
            if count >= activeMinimumMemorySamples
                stats.median := f_percentile_int(completedDurations, 50.0)
                stats.q25 := f_percentile_int(completedDurations, 25.0)
                stats.q75 := f_percentile_int(completedDurations, 75.0)
                stats.agePercentile := 100.0 * ageRankCount / count
            if stats.atRiskCount >= activeMinimumMemorySamples
                stats.persistence := 100.0 * persistsFurtherCount / stats.atRiskCount
            int bestPhase = 0
            int secondPhase = 0
            int bestCount = 0
            int secondCount = 0
            for candidate = 1 to PHASE_COUNT
                int candidateCount = matrix.get(stateNextPhaseCounts, key, candidate - 1)
                if candidateCount > bestCount
                    secondCount := bestCount
                    secondPhase := bestPhase
                    bestCount := candidateCount
                    bestPhase := candidate
                else if candidateCount > secondCount
                    secondCount := candidateCount
                    secondPhase := candidate
            if count >= activeMinimumMemorySamples
                stats.topNextPhase := bestPhase
                stats.topNextPct := bestCount > 0 ? 100.0 * bestCount / count : na
                stats.secondNextPhase := secondPhase
                stats.secondNextPct := secondCount > 0 ? 100.0 * secondCount / count : na
    stats

DurationStats durationStats = DurationStats.new()
if barstate.islast and hudState.ready
    durationStats := f_duration_statistics(hudState.stateKey, hudState.age)
    if not hudState.episodeStartKnown
        durationStats.agePercentile := na
        durationStats.persistence := na
        durationStats.atRiskCount := 0

bool memoryInvariantOk = true
if barstate.islast and enableStructureMemory
    for key = 0 to STATE_COUNT - 1
        int totalDestinations = 0
        for destination = 0 to PHASE_COUNT - 1
            int cellCount = matrix.get(stateNextPhaseCounts, key, destination)
            totalDestinations += cellCount
            memoryInvariantOk := memoryInvariantOk and cellCount >= 0
        memoryInvariantOk := memoryInvariantOk and totalDestinations == array.get(durationCounts, key)

// ============================================================================
// Confirmed event engine. Observation/alert time is never changed by rendering.
// ============================================================================
bool eventGate = barstate.isconfirmed and chart.is_standard and chartTimeBased
bool knownStateEntry = chartState.ready and chartState.episodeStartKnown and chartState.age == minimumPhaseBarsForEvent
bool releasePhaseEvent = eventGate and knownStateEntry and chartState.phase == 2
bool expansionPhaseEvent = eventGate and knownStateEntry and chartState.phase == 3
bool compressionPhaseEvent = eventGate and knownStateEntry and chartState.phase == 1
bool transitionPhaseEvent = eventGate and knownStateEntry and chartState.phase == 6

var int directionalCycle = 0
var int cycleStartBar = na
var int cycleTouchBar = na
var bool cycleTouched = false
var bool cycleReclaimed = false
var float cycleTouchHigh = na
var float cycleTouchLow = na
var float cycleTouchSlow = na
var int cycleTouchReferenceTime = na
bool firstTouchEvent = false
bool reclaimEvent = false
bool structuralFailureEvent = false
bool cycleExpiredEvent = false
int failureDirection = 0
int firstTouchDirection = 0
int reclaimDirection = 0
float eventReclaimLevel = na
float eventTouchHigh = na
float eventTouchLow = na
float eventFailureLevel = na
bool useFrozenReclaim = reclaimBoundaryMode == "First-touch snapshot"

if barstate.isconfirmed
    if not chartState.ready or not chart.is_standard or not chartTimeBased
        directionalCycle := 0
        cycleStartBar := na
        cycleTouchBar := na
        cycleTouched := false
        cycleReclaimed := false
        cycleTouchHigh := na
        cycleTouchLow := na
        cycleTouchSlow := na
        cycleTouchReferenceTime := na
    else
        // Finish the OLD cycle before allowing a new release/expansion to start.
        if directionalCycle != 0 and not na(cycleStartBar) and bar_index > cycleStartBar
            bool oppositeBias = chartState.bias == -directionalCycle
            bool priceBreach = not na(previousChartState.slowCentroid) and (directionalCycle == 1 ? close < previousChartState.slowCentroid : close > previousChartState.slowCentroid)
            bool orderWeakened = directionalCycle == 1 ? chartState.orderCoherence < failureOrderFloor or chartState.slowSlopeCoherence <= -failureSlowSlopeFlip : chartState.orderCoherence > -failureOrderFloor or chartState.slowSlopeCoherence >= failureSlowSlopeFlip
            bool failureCondition = oppositeBias or (priceBreach and orderWeakened)
            bool cycleExpired = bar_index - cycleStartBar > maximumCycleBars
            if failureCondition
                structuralFailureEvent := true
                failureDirection := -directionalCycle
                // A pure bias reversal does not imply this price was crossed.
                eventFailureLevel := priceBreach and orderWeakened ? previousChartState.slowCentroid : na
            cycleExpiredEvent := cycleExpired and not failureCondition
            if failureCondition or cycleExpired
                directionalCycle := 0
                cycleStartBar := na
                cycleTouchBar := na
                cycleTouched := false
                cycleReclaimed := false
                cycleTouchHigh := na
                cycleTouchLow := na
                cycleTouchSlow := na
                cycleTouchReferenceTime := na
            else if previousChartState.ready
                // Touch uses the complete bundle already known at this bar's open.
                bool touchesPriorBundle = low <= previousChartState.bundleHigh and high >= previousChartState.bundleLow
                if not cycleTouched and touchesPriorBundle and chartState.bias == directionalCycle
                    firstTouchEvent := true
                    firstTouchDirection := directionalCycle
                    cycleTouched := true
                    cycleTouchBar := bar_index
                    cycleTouchHigh := previousChartState.bundleHigh
                    cycleTouchLow := previousChartState.bundleLow
                    cycleTouchSlow := previousChartState.slowCentroid
                    cycleTouchReferenceTime := previousChartState.closedAt
                    eventTouchHigh := cycleTouchHigh
                    eventTouchLow := cycleTouchLow
                bool laterThanTouch = cycleTouched and not na(cycleTouchBar) and bar_index > cycleTouchBar
                float upperCheckpoint = f_upper_checkpoint(useFrozenReclaim ? cycleTouchHigh : previousChartState.bundleHigh)
                float lowerCheckpoint = f_lower_checkpoint(useFrozenReclaim ? cycleTouchLow : previousChartState.bundleLow)
                float reclaimCheckpoint = directionalCycle == 1 ? upperCheckpoint : lowerCheckpoint
                bool crossesCheckpoint = f_checkpoint_cross(close[1], close, reclaimCheckpoint, directionalCycle)
                bool orderStillHeld = chartState.orderCoherence * directionalCycle >= pullbackOrderFloor
                // The checkpoint is known before the reclaim candle closes.
                // In frozen mode it cannot drift past a stationary price.
                // Touch and reclaim cannot be inferred on the same OHLC candle.
                if laterThanTouch and not cycleReclaimed and chartState.bias == directionalCycle and crossesCheckpoint and orderStillHeld
                    reclaimEvent := true
                    reclaimDirection := directionalCycle
                    eventReclaimLevel := reclaimCheckpoint
                    cycleReclaimed := true
        bool startRelease = releasePhaseEvent and chartState.bias != 0
        bool startExpansion = expansionPhaseEvent and chartState.bias != 0 and (directionalCycle == 0 or chartState.bias != directionalCycle or cycleReclaimed)
        if startRelease or startExpansion
            directionalCycle := chartState.bias
            cycleStartBar := bar_index
            cycleTouchBar := na
            cycleTouched := false
            cycleReclaimed := false
            cycleTouchHigh := na
            cycleTouchLow := na
            cycleTouchSlow := na
            cycleTouchReferenceTime := na

bool mtfAlignmentGainEvent = eventGate and alignmentGained
bool mtfAlignmentLossEvent = eventGate and alignmentLost

// ============================================================================
// Event outcome lab: synchronized, frozen-direction, equal-window comparisons
// ============================================================================
float baselineFast = ta.ema(close, baselineFastLength)
float baselineSlow = ta.ema(close, baselineSlowLength)
int baselineDirectionNow = baselineFast > baselineSlow ? 1 : baselineFast < baselineSlow ? -1 : 0
bool baselineConfigurationValid = baselineFastLength < baselineSlowLength
bool baselineReady = baselineConfigurationValid and bar_index >= baselineSlowLength and not na(baselineFast) and not na(baselineSlow)
bool studyChartSupported = chart.is_standard and chartTimeBased
bool nextOpenEntry = studyEntryMode == "Next bar open"
var array<ActiveObservation> activeObservations = array.new<ActiveObservation>()
var array<CompletedObservation> completedObservations = array.new<CompletedObservation>()
var int studyCandidates = 0
var int studyOverlapSkips = 0
var int studyInvalidSkips = 0
var int studyDiscarded = 0
var int studyAccepted = 0
var int studyCompleted = 0
var int firstStudySignalTime = na
float lastMaturedResult = na
float lastMaturedDelta = na

bool studyEvent = false
int studyDirection = 0
if studyEventType == "Compression Release"
    studyEvent := releasePhaseEvent
    studyDirection := chartState.bias
else if studyEventType == "Pullback Reclaim"
    studyEvent := reclaimEvent
    studyDirection := reclaimDirection
else if studyEventType == "Structural Failure"
    studyEvent := structuralFailureEvent
    studyDirection := failureDirection
else if studyEventType == "MTF Alignment"
    studyEvent := mtfAlignmentGainEvent
    studyDirection := chartState.bias
else
    studyEvent := expansionPhaseEvent
    studyDirection := chartState.bias

if barstate.isconfirmed and enableOutcomeLab
    int activeCount = array.size(activeObservations)
    if activeCount > 0
        // Reverse traversal is bounded by H+1 observations, never chart history.
        for sample = activeCount - 1 to 0
            ActiveObservation observation = array.get(activeObservations, sample)
            bool removeObservation = false
            bool validPrices = studyChartSupported and not na(open) and not na(high) and not na(low) and not na(close) and open > 0.0 and low > 0.0 and high >= low and close > 0.0
            if not validPrices
                studyDiscarded += 1
                removeObservation := true
            else
                if na(observation.entryBar) and nextOpenEntry and bar_index > observation.signalBar
                    observation.entryBar := bar_index
                    observation.entryPrice := open
                if not na(observation.entryBar) and not na(observation.entryPrice) and observation.entryPrice > 0.0
                    int heldBars = nextOpenEntry ? bar_index - observation.entryBar + 1 : bar_index - observation.entryBar
                    // No observation is processed on its signal bar. In event-
                    // close mode, the signal bar's OHLC excursion is excluded.
                    if heldBars > 0
                        float upMove = 100.0 * (high / observation.entryPrice - 1.0)
                        float downMove = 100.0 * (1.0 - low / observation.entryPrice)
                        float favorable = observation.direction > 0 ? upMove : downMove
                        float adverse = observation.direction > 0 ? downMove : upMove
                        observation.mfe := math.max(observation.mfe, favorable)
                        observation.mae := math.max(observation.mae, adverse)
                        if heldBars >= studyHorizon
                            float rawMovement = 100.0 * (close / observation.entryPrice - 1.0)
                            CompletedObservation result = CompletedObservation.new()
                            result.signalTime := observation.signalTime
                            result.result := observation.direction * rawMovement
                            result.baseline := observation.baselineDirection * rawMovement
                            result.delta := result.result - result.baseline
                            result.mfe := observation.mfe
                            result.mae := observation.mae
                            result.robust := observation.robust
                            result.differentDirection := observation.direction != observation.baselineDirection
                            result.neutralBaseline := observation.baselineDirection == 0
                            array.push(completedObservations, result)
                            if array.size(completedObservations) > maximumOutcomeSamples
                                array.shift(completedObservations)
                            studyCompleted += 1
                            lastMaturedResult := result.result
                            lastMaturedDelta := result.delta
                            removeObservation := true
            if removeObservation
                array.remove(activeObservations, sample)

    bool inStudyWindow = not useStudyStart or (not na(time_close) and time_close >= studyStartTime)
    if studyEvent and studyDirection != 0 and inStudyWindow
        studyCandidates += 1
        bool overlapAllowed = not nonOverlappingSamples or array.size(activeObservations) == 0
        bool eventDataValid = studyChartSupported and baselineReady and not na(close) and close > 0.0 and topologyInvariantOk
        if not eventDataValid
            studyInvalidSkips += 1
        else if not overlapAllowed
            studyOverlapSkips += 1
        else if array.size(activeObservations) >= studyHorizon + 1
            studyInvalidSkips += 1
        else
            ActiveObservation observation = ActiveObservation.new()
            observation.signalBar := bar_index
            observation.signalTime := na(time_close) ? time : time_close
            observation.direction := studyDirection
            observation.baselineDirection := baselineDirectionNow
            // The ablation subgroup label is frozen here, not assigned after
            // seeing a future return. The full study always retains both groups.
            observation.robust := topologyRobust and f_order_class(chartState.orderCoherence) == studyDirection
            if not nextOpenEntry
                observation.entryBar := bar_index
                observation.entryPrice := close
            array.push(activeObservations, observation)
            studyAccepted += 1
            if na(firstStudySignalTime)
                firstStudySignalTime := na(time_close) ? time : time_close

// Lifetime accounting is independent of the rolling completed-sample cap.
bool studyConservationOk = studyCandidates == studyAccepted + studyOverlapSkips + studyInvalidSkips and studyAccepted == studyCompleted + array.size(activeObservations) + studyDiscarded

// group: 0 = all accepted observations, 1 = robust at event, 2 = all others.
// The latter group may include insufficient topology, not only fragile states.
f_outcome_statistics(int group) =>
    OutcomeStats stats = OutcomeStats.new()
    array<float> returns = array.new<float>()
    array<float> baselines = array.new<float>()
    array<float> deltas = array.new<float>()
    array<float> mfes = array.new<float>()
    array<float> maes = array.new<float>()
    int count = array.size(completedObservations)
    int positives = 0
    if count > 0
        for sample = 0 to count - 1
            CompletedObservation result = array.get(completedObservations, sample)
            bool useSample = group == 0 or (group == 1 and result.robust) or (group == 2 and not result.robust)
            if useSample
                array.push(returns, result.result)
                array.push(baselines, result.baseline)
                array.push(deltas, result.delta)
                array.push(mfes, result.mfe)
                array.push(maes, result.mae)
                positives += result.result > 0.0 ? 1 : 0
                stats.differentDirections += result.differentDirection ? 1 : 0
                stats.neutralBaselines += result.neutralBaseline ? 1 : 0
    stats.count := array.size(returns)
    // Minimum applies separately to the full set and each subgroup.
    if stats.count >= activeMinimumOutcomeSamples
        stats.medianReturn := f_percentile_float(returns, 50.0)
        stats.q25Return := f_percentile_float(returns, 25.0)
        stats.q75Return := f_percentile_float(returns, 75.0)
        stats.medianMfe := f_percentile_float(mfes, 50.0)
        stats.medianMae := f_percentile_float(maes, 50.0)
        stats.meanReturn := array.avg(returns)
        stats.meanBaseline := array.avg(baselines)
        stats.medianBaseline := f_percentile_float(baselines, 50.0)
        stats.meanDelta := array.avg(deltas)
        stats.medianDelta := f_percentile_float(deltas, 50.0)
        stats.deltaQ25 := f_percentile_float(deltas, 25.0)
        stats.deltaQ75 := f_percentile_float(deltas, 75.0)
        float proportion = float(positives) / stats.count
        stats.positiveFrequency := proportion * 100.0
        // This is only a nominal binomial interval. Non-overlapping observations
        // can still be serially dependent. Suppress it when overlap is enabled.
        if nonOverlappingSamples
            [lowCi, highCi] = f_wilson(proportion, stats.count, 1.96)
            stats.ciLow := lowCi
            stats.ciHigh := highCi
        int earlyCount = int(math.floor(stats.count * 0.5))
        int lateCount = stats.count - earlyCount
        stats.earlyCount := earlyCount
        stats.lateCount := lateCount
        // Chronological halves of the retained window: a stability diagnostic,
        // NOT a holdout test, optimization or an independently validated edge.
        if earlyCount >= activeMinimumOutcomeSamples and lateCount >= activeMinimumOutcomeSamples
            float earlySum = 0.0
            float lateSum = 0.0
            for sample = 0 to stats.count - 1
                if sample < earlyCount
                    earlySum += array.get(deltas, sample)
                else
                    lateSum += array.get(deltas, sample)
            stats.earlyMeanDelta := earlySum / earlyCount
            stats.lateMeanDelta := lateSum / lateCount
    stats

OutcomeStats outcomeStats = OutcomeStats.new()
OutcomeStats robustOutcomeStats = OutcomeStats.new()
OutcomeStats otherOutcomeStats = OutcomeStats.new()
if barstate.islast and enableOutcomeLab
    outcomeStats := f_outcome_statistics(0)
    if dashboardMode == "Research" or showEvidencePanel
        robustOutcomeStats := f_outcome_statistics(1)
        otherOutcomeStats := f_outcome_statistics(2)

// ============================================================================
// Operational context: descriptions, not trade instructions or probabilities.
// ============================================================================
f_bias_color(int bias) =>
    bias > 0 ? bullColor : bias < 0 ? bearColor : neutralColor

f_direction_word(int direction) =>
    direction > 0 ? "UP" : direction < 0 ? "DOWN" : "NEUTRAL"

f_phase_ui(int phase) =>
    phase == 6 ? "TRANSITION" : phase == 0 ? "WARMING" : f_phase_name(phase)

f_context_description(RegimeState local, RegimeState anchor, RegimeState macro) =>
    string result = "BUILDING STRUCTURE"
    if local.configurationIssue != 0
        result := "LOCAL: " + f_configuration_name(local.configurationIssue)
    else if local.ready
        if not mtfConfigurationValid
            result := "CHECK TIMEFRAME HIERARCHY"
        else if configuredMtfLayers == 0
            result := "LOCAL " + f_direction_word(local.bias) + " / CHART ONLY"
        else if useAnchorTimeframe and anchor.configurationIssue != 0
            result := "ANCHOR: " + f_configuration_name(anchor.configurationIssue)
        else if useMacroTimeframe and macro.configurationIssue != 0
            result := "MACRO: " + f_configuration_name(macro.configurationIssue)
        else if (useAnchorTimeframe and not anchor.ready) or (useMacroTimeframe and not macro.ready)
            int readyLayers = (useAnchorTimeframe and anchor.ready ? 1 : 0) + (useMacroTimeframe and macro.ready ? 1 : 0)
            result := "LOCAL " + f_direction_word(local.bias) + " / HTF " + str.tostring(readyLayers) + "/" + str.tostring(configuredMtfLayers) + " READY"
        else
            int commonHigher = useAnchorTimeframe ? anchor.bias : macro.bias
            bool higherAgreement = (not useAnchorTimeframe or anchor.bias == commonHigher) and (not useMacroTimeframe or macro.bias == commonHigher)
            if not higherAgreement
                result := "LOCAL " + f_direction_word(local.bias) + " / HTFs MIXED"
            else if commonHigher == 0
                result := "LOCAL " + f_direction_word(local.bias) + " / HTFs NEUTRAL"
            else if local.bias == commonHigher
                // Alignment does not depend on the local lifecycle phase.
                result := "ALIGNED " + f_direction_word(local.bias)
            else
                result := "LOCAL " + f_direction_word(local.bias) + " / HTF " + f_direction_word(commonHigher)
    result

f_context_conflict(RegimeState local, RegimeState anchor, RegimeState macro) =>
    local.ready and local.bias != 0 and mtfConfigurationValid and ((useAnchorTimeframe and anchor.ready and anchor.bias == -local.bias) or (useMacroTimeframe and macro.ready and macro.bias == -local.bias))

f_join_notice(string existing, string nextText) =>
    existing == "" ? nextText : existing + " | " + nextText

float currentFastDistanceAtr = chartState.ready ? f_safe_div(close - chartState.fastCentroid, chartState.atrValue) : na
int extensionDirection = chartState.ready and not na(currentFastDistanceAtr) and chartState.bias != 0 and currentFastDistanceAtr * chartState.bias >= priceExtensionAtr ? chartState.bias : 0
bool extensionEntered = eventGate and previousChartState.ready and extensionDirection != 0 and extensionDirection != nz(extensionDirection[1], 0)
bool alignedStableReclaim = reclaimEvent and fullAlignment and topologyRobust and f_order_class(chartState.orderCoherence) == reclaimDirection

// Classes describe only observed event-time conditions, never expected outcomes.
int reclaimContextClass = reclaimEvent ? (alignedStableReclaim ? 3 : fullAlignment ? 2 : 1) : 0
f_reclaim_class(int contextClass) =>
    contextClass == 3 ? "RAS" : contextClass == 2 ? "RA" : "R"

// ============================================================================
// Independent frozen-checkpoint maintenance. All reclaims, no marker selection.
// Each watch ends at its first adverse CLOSE or its finite window; no intrabar fills.
// ============================================================================
bool checkpointConfigurationValid = checkpointHoldBars <= checkpointWatchBars
var array<CheckpointWatch> checkpointWatches = array.new<CheckpointWatch>()
var CheckpointWatch latestCheckpoint = na
var int checkpointCandidates = 0
var int checkpointStarted = 0
var int checkpointSkipped = 0
var int checkpointLost = 0
var int checkpointWindowHeld = 0
var int checkpointInterrupted = 0
var int checkpointInitialHeld = 0
bool checkpointHoldEvent = false
bool checkpointLossEvent = false
string checkpointHoldNotice = ""
string checkpointLossNotice = ""
int checkpointHoldsThisBar = 0
int checkpointLossesThisBar = 0
if barstate.isconfirmed and enableCheckpointWatch
    int watchCount = array.size(checkpointWatches)
    if watchCount > 0
        for i = watchCount - 1 to 0
            CheckpointWatch watch = array.get(checkpointWatches, i)
            bool removeWatch = false
            if not chart.is_standard or not chartTimeBased or not chartState.ready or na(close)
                watch.status := 4
                watch.checkedAt := time_close
                checkpointInterrupted += 1
                removeWatch := true
            else if bar_index > watch.eventBar
                watch.observedBars := bar_index - watch.eventBar
                watch.checkedAt := time_close
                watch.lastClose := close
                float signedMargin = watch.direction * (close - watch.level)
                float marginAtr = f_safe_div(signedMargin, watch.eventAtr)
                if not na(marginAtr)
                    watch.smallestMarginAtr := na(watch.smallestMarginAtr) ? marginAtr : math.min(watch.smallestMarginAtr, marginAtr)
                bool stillHeld = signedMargin >= -syminfo.mintick * 1e-7
                string identity = f_reclaim_class(watch.contextClass) + " " + f_direction_word(watch.direction) + " @ " + f_num(watch.level) + " from " + f_time_label(watch.eventTime)
                // Loss takes priority, including on the final observation bar.
                if not stillHeld
                    watch.status := 2
                    checkpointLost += 1
                    checkpointLossEvent := true
                    checkpointLossesThisBar += 1
                    if checkpointLossesThisBar <= 3
                        checkpointLossNotice := f_join_notice(checkpointLossNotice, identity)
                    removeWatch := true
                else
                    watch.heldCloses += 1
                    if not watch.holdReported and watch.heldCloses >= checkpointHoldBars
                        watch.holdReported := true
                        watch.status := 1
                        checkpointInitialHeld += 1
                        checkpointHoldEvent := true
                        checkpointHoldsThisBar += 1
                        if checkpointHoldsThisBar <= 3
                            checkpointHoldNotice := f_join_notice(checkpointHoldNotice, identity)
                    if watch.observedBars >= checkpointWatchBars
                        watch.status := 3
                        checkpointWindowHeld += 1
                        removeWatch := true
            if removeWatch
                array.remove(checkpointWatches, i)
    if reclaimEvent
        checkpointCandidates += 1
        bool validWatch = checkpointConfigurationValid and not na(eventReclaimLevel) and reclaimDirection != 0 and array.size(checkpointWatches) < checkpointWatchBars + 1
        if validWatch
            CheckpointWatch watch = CheckpointWatch.new()
            watch.eventBar := bar_index
            watch.eventTime := time_close
            watch.direction := reclaimDirection
            watch.contextClass := reclaimContextClass
            watch.level := eventReclaimLevel
            watch.eventAtr := chartState.atrValue
            watch.checkedAt := time_close
            watch.lastClose := close
            // Event close does NOT count as one of the subsequent holding closes.
            array.push(checkpointWatches, watch)
            latestCheckpoint := watch
            checkpointStarted += 1
        else
            checkpointSkipped += 1
bool checkpointAccountingOk = checkpointCandidates == checkpointStarted + checkpointSkipped and checkpointStarted == checkpointLost + checkpointWindowHeld + checkpointInterrupted + array.size(checkpointWatches)
if checkpointHoldsThisBar > 3
    checkpointHoldNotice += " | +" + str.tostring(checkpointHoldsThisBar - 3) + " other checkpoints"
if checkpointLossesThisBar > 3
    checkpointLossNotice += " | +" + str.tostring(checkpointLossesThisBar - 3) + " other checkpoints"

f_checkpoint_status(CheckpointWatch watch) =>
    string result = "NO RECLAIM WATCH"
    if not na(watch)
        result := watch.status == 2 ? "CHECKPOINT LOST" : watch.status == 3 ? "WINDOW HELD" : watch.status == 4 ? "WATCH INTERRUPTED" : watch.holdReported ? "INITIAL HOLD MET" : "HOLD " + str.tostring(watch.heldCloses) + "/" + str.tostring(checkpointHoldBars)
    result

// ============================================================================
// Base events and checkpoint notices go into a bounded ledger. Transitions do not
// overwrite the key-event card. Concurrent events are not lost in the tooltip.
// ============================================================================
var array<string> recentEventLedger = array.new<string>()
f_record_event(bool occurs, string eventName, int direction, float actualLevel) =>
    if occurs
        string record = f_time_label(time_close) + " | " + eventName + (direction == 0 ? "" : " " + f_direction_word(direction)) + (na(actualLevel) ? "" : " @ " + f_num(actualLevel))
        array.push(recentEventLedger, record)
        if array.size(recentEventLedger) > 12
            array.shift(recentEventLedger)

f_record_event(transitionPhaseEvent, "TRANSITION", 0, na)
f_record_event(compressionPhaseEvent, "COMPRESSION", 0, na)
f_record_event(expansionPhaseEvent, "EXPANSION", chartState.bias, na)
f_record_event(mtfAlignmentLossEvent, "MTF ALIGNMENT LOST", 0, na)
f_record_event(mtfAlignmentGainEvent, "MTF ALIGNMENT", chartState.bias, na)
f_record_event(firstTouchEvent, "FIRST TOUCH", firstTouchDirection, firstTouchDirection > 0 ? eventTouchHigh : eventTouchLow)
f_record_event(reclaimEvent, f_reclaim_class(reclaimContextClass) + " RECLAIM", reclaimDirection, eventReclaimLevel)
f_record_event(structuralFailureEvent, "CYCLE FAILURE", failureDirection, eventFailureLevel)
f_record_event(releasePhaseEvent, "RELEASE", chartState.bias, na)
f_record_event(cycleExpiredEvent, "CYCLE EXPIRED", 0, na)
f_record_event(checkpointHoldEvent, "CHECKPOINT INITIAL HOLD: " + checkpointHoldNotice, 0, na)
f_record_event(checkpointLossEvent, "CHECKPOINT LOST: " + checkpointLossNotice, 0, na)

var string lastEventText = "NO COMPLETED EVENT"
var int lastEventDirection = 0
var int lastEventOriginBar = na
var int lastConcurrentEvents = 0
var string lastKeyEventText = "NO KEY EVENT"
var int lastKeyEventDirection = 0
var int lastKeyEventBar = na
int eventsThisBar = (structuralFailureEvent ? 1 : 0) + (releasePhaseEvent ? 1 : 0) + (reclaimEvent ? 1 : 0) + (firstTouchEvent ? 1 : 0) + (mtfAlignmentGainEvent ? 1 : 0) + (mtfAlignmentLossEvent ? 1 : 0) + (expansionPhaseEvent ? 1 : 0) + (compressionPhaseEvent ? 1 : 0) + (transitionPhaseEvent ? 1 : 0)
if eventsThisBar > 0
    lastEventOriginBar := bar_index
    lastConcurrentEvents := eventsThisBar
    lastEventText := structuralFailureEvent ? "CYCLE FAILURE" : releasePhaseEvent ? "RELEASE" : reclaimEvent ? f_reclaim_class(reclaimContextClass) + " RECLAIM" : firstTouchEvent ? "FIRST TOUCH" : mtfAlignmentGainEvent ? "MTF ALIGNED" : mtfAlignmentLossEvent ? "MTF ALIGN LOST" : expansionPhaseEvent ? "EXPANSION" : compressionPhaseEvent ? "COMPRESSION" : "TRANSITION"
    lastEventDirection := structuralFailureEvent ? failureDirection : releasePhaseEvent or expansionPhaseEvent or mtfAlignmentGainEvent ? chartState.bias : reclaimEvent ? reclaimDirection : firstTouchEvent ? firstTouchDirection : 0
    if eventsThisBar > (transitionPhaseEvent ? 1 : 0)
        lastKeyEventText := lastEventText
        lastKeyEventDirection := lastEventDirection
        lastKeyEventBar := bar_index

// ============================================================================
// Marker presentation. Suppressed markers are never queued or backfilled.
// ============================================================================
bool showMajorMarkers = markerDisplayMode == "Major only" or markerDisplayMode == "Key events" or markerDisplayMode == "All events"
bool showKeyMarkers = markerDisplayMode == "Key events" or markerDisplayMode == "All events"
bool showAllMarkers = markerDisplayMode == "All events"
var int lastDisplayedEventBar = na
var int lastRawReclaimMarkerBar = na
var int suppressedMarkerCount = 0
bool cooldownClear = na(lastDisplayedEventBar) or bar_index - lastDisplayedEventBar > eventCooldownBars
bool eligibleRelease = showMajorMarkers and releasePhaseEvent
bool eligibleReclaim = showKeyMarkers and reclaimEvent
bool eligibleTouch = showAllMarkers and firstTouchEvent
bool eligibleExpansion = showAllMarkers and expansionPhaseEvent
bool eligibleCompression = showAllMarkers and compressionPhaseEvent
bool eligibleTransition = showAllMarkers and transitionPhaseEvent
int markerRank = eligibleRelease ? 1 : eligibleReclaim ? 2 : eligibleTouch ? 3 : eligibleExpansion ? 4 : eligibleCompression ? 5 : eligibleTransition ? 6 : 0
bool drawRelease = cooldownClear and eligibleRelease and (not oneEventPerBar or markerRank == 1)
bool rawReclaimSpacingClear = markerPresentation != "Context symbols" or reclaimContextClass != 1 or rawReclaimSpacingBars == 0 or na(lastRawReclaimMarkerBar) or bar_index - lastRawReclaimMarkerBar >= rawReclaimSpacingBars
bool drawReclaim = cooldownClear and eligibleReclaim and rawReclaimSpacingClear and (not oneEventPerBar or markerRank == 2)
bool drawTouch = cooldownClear and eligibleTouch and (not oneEventPerBar or markerRank == 3)
bool drawExpansion = cooldownClear and eligibleExpansion and (not oneEventPerBar or markerRank == 4)
bool drawCompression = cooldownClear and eligibleCompression and (not oneEventPerBar or markerRank == 5)
bool drawTransition = cooldownClear and eligibleTransition and (not oneEventPerBar or markerRank == 6)
int eligibleMarkers = (eligibleRelease ? 1 : 0) + (eligibleReclaim ? 1 : 0) + (eligibleTouch ? 1 : 0) + (eligibleExpansion ? 1 : 0) + (eligibleCompression ? 1 : 0) + (eligibleTransition ? 1 : 0)
string releaseText = (useMarkerIcons ? (chartState.bias > 0 ? "↑ " : "↓ ") : "") + (markerPresentation == "Context symbols" ? "REL" : "RELEASE")
string reclaimText = (useMarkerIcons ? (reclaimDirection > 0 ? "↑ " : "↓ ") : "") + (markerPresentation == "Context symbols" ? f_reclaim_class(reclaimContextClass) : "RECLAIM")
string touchText = (useMarkerIcons ? (firstTouchDirection > 0 ? "↑ " : "↓ ") : "") + "TOUCH"
string expansionText = (useMarkerIcons ? (chartState.bias > 0 ? "↑ " : "↓ ") : "") + (markerPresentation == "Context symbols" ? "EXP" : "EXPAND")
string markerContext = "Confirmed at " + f_time_label(time_close) + " (exchange timezone).\n" + f_context_description(chartState, anchorState, macroState) + "\nLocal phase: " + f_phase_name(chartState.phase) + "\nClarity: " + f_0(chartState.clarity) + "/100 (heuristic, not a probability).\nMarker offset is for readability, not an execution price.\nHTF policy: " + htfHistoryMode + "; anchor " + f_profile_name(anchorState.profileCode) + "; macro " + f_profile_name(macroState.profileCode)
string reclaimLegend = "Class frozen at the event: R = raw reclaim without full enabled-HTF alignment; RA = full alignment; RAS = full alignment AND stable non-neutral order under fixed-vote single-MA deletion. These are conditions, NOT profit grades.\nAll classes stay in the raw event study and checkpoint maintenance."
var array<label> eventLabels = array.new<label>()
int stack = 0
bool emittedRelease = f_add_event_label(drawRelease, releaseText, chartState.bias, chartState.bias > 0 ? low : high, chartState.atrValue, f_bias_color(chartState.bias), "Compression release.\n" + markerContext, stack, false, eventLabels)
stack += emittedRelease ? 1 : 0
bool emittedReclaim = f_add_event_label(drawReclaim, reclaimText, reclaimDirection, reclaimDirection > 0 ? low : high, chartState.atrValue, f_bias_color(reclaimDirection), "Class: " + f_reclaim_class(reclaimContextClass) + "\n" + reclaimLegend + "\nReclaim definition: " + reclaimBoundaryMode + "\nActual crossed checkpoint: " + f_num(eventReclaimLevel) + "\nTouch occurred on an earlier bar.\n" + markerContext, stack, reclaimContextClass == 1, eventLabels)
stack += emittedReclaim ? 1 : 0
if barstate.isconfirmed and emittedReclaim and markerPresentation == "Context symbols" and reclaimContextClass == 1
    lastRawReclaimMarkerBar := bar_index
bool emittedTouch = f_add_event_label(drawTouch, touchText, firstTouchDirection, firstTouchDirection > 0 ? low : high, chartState.atrValue, accentColor, "Touched pre-bar bundle: " + f_num(eventTouchLow) + " to " + f_num(eventTouchHigh) + "\n" + markerContext, stack, false, eventLabels)
stack += emittedTouch ? 1 : 0
bool emittedExpansion = f_add_event_label(drawExpansion, expansionText, chartState.bias, chartState.bias > 0 ? low : high, chartState.atrValue, f_bias_color(chartState.bias), "Expansion state entry.\n" + markerContext, stack, false, eventLabels)
stack += emittedExpansion ? 1 : 0
bool emittedCompression = f_add_event_label(drawCompression, markerPresentation == "Context symbols" ? "CMP" : "COMPRESS", 0, low, chartState.atrValue, mutedTextColor, "Compression state entry.\n" + markerContext, stack, false, eventLabels)
stack += emittedCompression ? 1 : 0
bool emittedTransition = f_add_event_label(drawTransition, markerPresentation == "Context symbols" ? "TRN" : "TRANSITION", 0, low, chartState.atrValue, neutralColor, "Transition state entry.\n" + markerContext, stack, false, eventLabels)
int drawnMarkers = (emittedRelease ? 1 : 0) + (emittedReclaim ? 1 : 0) + (emittedTouch ? 1 : 0) + (emittedExpansion ? 1 : 0) + (emittedCompression ? 1 : 0) + (emittedTransition ? 1 : 0)
if barstate.isconfirmed
    suppressedMarkerCount += eligibleMarkers - drawnMarkers
    if drawnMarkers > 0
        lastDisplayedEventBar := bar_index
// Failure, MTF and checkpoint-maintenance events remain off the price candles.

// All legacy alert conditions remain independent of HUD and marker options.
alertcondition(releasePhaseEvent, "MA structure compression release", "Confirmed MA compression release on {{ticker}} {{interval}}. Descriptive event, not a trade instruction.")
alertcondition(expansionPhaseEvent, "MA structure expansion entered", "Confirmed MA expansion state on {{ticker}} {{interval}}.")
alertcondition(firstTouchEvent, "First MA bundle touch", "Confirmed first touch of the previously known MA bundle on {{ticker}} {{interval}}.")
alertcondition(reclaimEvent, "MA bundle reclaim", "Confirmed reclaim after an earlier touch on {{ticker}} {{interval}}. Check the selected reclaim-boundary definition.")
alertcondition(structuralFailureEvent, "MA structural failure", "Confirmed weakening/failure of the prior MA directional cycle on {{ticker}} {{interval}}.")
alertcondition(mtfAlignmentGainEvent, "MTF structure alignment gained", "Confirmed directional alignment of enabled MA timeframes on {{ticker}} {{interval}}.")
alertcondition(mtfAlignmentLossEvent, "MTF structure alignment lost", "Previous MA timeframe alignment ended or reversed on {{ticker}} {{interval}}.")
alertcondition(compressionPhaseEvent, "MA structure compression entered", "Confirmed MA compression state on {{ticker}} {{interval}}.")
alertcondition(transitionPhaseEvent, "MA structure transition entered", "Confirmed MA transition state on {{ticker}} {{interval}}.")
alertcondition(alignedStableReclaim, "Reclaim with aligned HTFs and stable order", "A confirmed reclaim coincides with enabled HTF alignment and stable fixed-vote one-MA-out order on {{ticker}} {{interval}}. These are descriptive conditions, not a probability of profit.")
alertcondition(extensionEntered, "MA fast-cohort extension entered", "Close first exceeded the configured fast-cohort ATR distance in the local structure direction on {{ticker}} {{interval}}. This does not forecast a reversal.")

alertcondition(checkpointHoldEvent, "Frozen reclaim checkpoint initially held", "The configured number of later confirmed closes held a frozen reclaim checkpoint on {{ticker}} {{interval}}. Finite observed condition, not a prediction.")
alertcondition(checkpointLossEvent, "Frozen reclaim checkpoint lost", "A later confirmed close lost one or more previously reclaimed frozen checkpoints on {{ticker}} {{interval}}. Separate event: original reclaim markers are not changed.")

if enableContextAlerts and eventGate
    string notices = ""
    if notifyFailures and structuralFailureEvent
        notices := f_join_notice(notices, "CYCLE FAILURE " + f_direction_word(failureDirection) + (na(eventFailureLevel) ? " (bias reversed)" : " / prior slow mean " + f_num(eventFailureLevel)))
    if notifyReleases and releasePhaseEvent
        notices := f_join_notice(notices, "RELEASE " + f_direction_word(chartState.bias))
    if notifyReclaims and reclaimEvent
        notices := f_join_notice(notices, f_reclaim_class(reclaimContextClass) + " RECLAIM " + f_direction_word(reclaimDirection) + " / crossed " + f_num(eventReclaimLevel) + " / " + reclaimBoundaryMode)
    if notifyTouches and firstTouchEvent
        notices := f_join_notice(notices, "FIRST TOUCH " + f_direction_word(firstTouchDirection) + " / band " + f_num(eventTouchLow) + ".." + f_num(eventTouchHigh))
    if notifyMtf and mtfAlignmentGainEvent
        notices := f_join_notice(notices, "MTF ALIGNMENT " + f_direction_word(chartState.bias))
    if notifyMtf and mtfAlignmentLossEvent
        notices := f_join_notice(notices, "PRIOR MTF ALIGNMENT ENDED")
    if notifyExtensions and extensionEntered
        notices := f_join_notice(notices, "EXTENSION " + f_direction_word(extensionDirection) + " / fast gap " + f_signed(currentFastDistanceAtr) + " ATR")
    if notifyRoutineStates and (expansionPhaseEvent or compressionPhaseEvent or transitionPhaseEvent)
        notices := f_join_notice(notices, f_phase_ui(chartState.phase) + " STATE")
    if notifyCheckpointHolds and checkpointHoldEvent
        notices := f_join_notice(notices, "FROZEN CHECKPOINT INITIAL HOLD: " + checkpointHoldNotice)
    if notifyCheckpointLosses and checkpointLossEvent
        notices := f_join_notice(notices, "FROZEN CHECKPOINT LOST: " + checkpointLossNotice)
    if notices != ""
        string message = "MA Structure Matrix by SG Group | " + syminfo.tickerid + " " + f_tf_label(timeframe.period) + " | closed " + f_time_label(time_close) + "\n" + notices + "\n" + f_context_description(chartState, anchorState, macroState) + " | close " + f_num(close) + " | phase " + f_phase_ui(chartState.phase) + "\nClarity " + f_0(chartState.clarity) + "/100 | deletion agreement " + f_pct0(topologyStats.agreement) + " | max order shift " + f_1(topologyStats.largestShift) + "\nHTF policy " + htfHistoryMode + "; anchor " + f_profile_name(anchorState.profileCode) + "; macro " + f_profile_name(macroState.profileCode) + "\nDescriptive structure events; not orders, targets or guaranteed outcomes."
        alert(message, alert.freq_once_per_bar_close)

// ============================================================================
// Price plots: same full cohorts; candle-first opacity and no price-scale tags.
// ============================================================================
bool cohortVisualReady = chartState.ready and not na(chartState.fastCentroid) and not na(chartState.slowCentroid)
color activeBiasColor = f_bias_color(chartState.bias)
color phaseColor = chartState.phase == 1 ? compressionColor : chartState.phase == 2 ? accentColor : chartState.phase == 5 ? decelerationColor : chartState.phase == 6 ? neutralColor : activeBiasColor
color ribbonColor = ribbonColorMode == "Direction" ? activeBiasColor : phaseColor
int ribbonTransparency = int(f_clamp(ribbonBaseTransparency + (adaptiveRibbonOpacity ? (100.0 - nz(chartState.clarity, 0.0)) * 0.06 : 0.0), 0.0, 100.0))

plot(showIndividualMAs and activeEnable1 ? ma1 : na, "MA 1", color.new(color1, preset == "Custom" ? transparency1 : maDefaultTransparency), preset == "Custom" ? width1 : 1, style = plot.style_linebr, display = display.pane + display.data_window, force_overlay = true)
plot(showIndividualMAs and activeEnable2 ? ma2 : na, "MA 2", color.new(color2, preset == "Custom" ? transparency2 : maDefaultTransparency), preset == "Custom" ? width2 : 1, style = plot.style_linebr, display = display.pane + display.data_window, force_overlay = true)
plot(showIndividualMAs and activeEnable3 ? ma3 : na, "MA 3", color.new(color3, preset == "Custom" ? transparency3 : maDefaultTransparency), preset == "Custom" ? width3 : 1, style = plot.style_linebr, display = display.pane + display.data_window, force_overlay = true)
plot(showIndividualMAs and activeEnable4 ? ma4 : na, "MA 4", color.new(color4, preset == "Custom" ? transparency4 : maDefaultTransparency), preset == "Custom" ? width4 : 1, style = plot.style_linebr, display = display.pane + display.data_window, force_overlay = true)
plot(showIndividualMAs and activeEnable5 ? ma5 : na, "MA 5", color.new(color5, preset == "Custom" ? transparency5 : maDefaultTransparency), preset == "Custom" ? width5 : 1, style = plot.style_linebr, display = display.pane + display.data_window, force_overlay = true)
plot(showIndividualMAs and activeEnable6 ? ma6 : na, "MA 6", color.new(color6, preset == "Custom" ? transparency6 : maDefaultTransparency), preset == "Custom" ? width6 : 1, style = plot.style_linebr, display = display.pane + display.data_window, force_overlay = true)
plot(showIndividualMAs and activeEnable7 ? ma7 : na, "MA 7", color.new(color7, preset == "Custom" ? transparency7 : maDefaultTransparency), preset == "Custom" ? width7 : 1, style = plot.style_linebr, display = display.pane + display.data_window, force_overlay = true)
plot(showIndividualMAs and activeEnable8 ? ma8 : na, "MA 8", color.new(color8, preset == "Custom" ? transparency8 : maDefaultTransparency), preset == "Custom" ? width8 : 1, style = plot.style_linebr, display = display.pane + display.data_window, force_overlay = true)
plot(showCentroid and chartState.ready ? chartState.centroid : na, "Ensemble centerline", color.new(activeBiasColor, centroidTransparency), 2, style = plot.style_linebr, display = display.pane + display.data_window, force_overlay = true)
fastPlot = plot(showCohortRibbon and cohortVisualReady ? chartState.fastCentroid : na, "Fast cohort centroid", color.new(activeBiasColor, 15), 2, style = plot.style_linebr, display = display.pane + display.data_window, force_overlay = true)
slowPlot = plot(showCohortRibbon and cohortVisualReady ? chartState.slowCentroid : na, "Slow cohort centroid", color.new(activeBiasColor, 30), 1, style = plot.style_linebr, display = display.pane + display.data_window, force_overlay = true)
fill(fastPlot, slowPlot, color = showCohortRibbon and cohortVisualReady ? color.new(ribbonColor, ribbonTransparency) : na, title = "Structure ribbon", fillgaps = false)
bundleHighPlot = plot(showBundleEnvelope and chartState.ready ? chartState.bundleHigh : na, "Bundle high", color.new(neutralColor, 55), 1, style = plot.style_linebr, display = display.pane + display.data_window, force_overlay = true)
bundleLowPlot = plot(showBundleEnvelope and chartState.ready ? chartState.bundleLow : na, "Bundle low", color.new(neutralColor, 55), 1, style = plot.style_linebr, display = display.pane + display.data_window, force_overlay = true)
fill(bundleHighPlot, bundleLowPlot, color = showBundleEnvelope and showBundleFill and chartState.ready ? color.new(phaseColor, 94) : na, title = "Full bundle fill", fillgaps = false)
color lifecycleTint = showBackgroundTint and chartState.ready ? color.new(phaseColor, 96) : na
bgcolor(lifecycleTint, title = "Lifecycle tint", force_overlay = true)

// ============================================================================
// Current-reference map. No historical projection and no floating price labels.
// Exact prices live in fixed HUD cells; short lines cannot overlap those texts.
// ============================================================================
bool frozenReferenceActive = useFrozenReclaim and directionalCycle != 0 and cycleTouched and not na(cycleTouchHigh) and not na(cycleTouchLow)
bool mapDataReady = closedChartState.ready and chart.is_standard and chartTimeBased
float mapUpper = mapDataReady ? f_upper_checkpoint(frozenReferenceActive ? cycleTouchHigh : closedChartState.bundleHigh) : na
float mapLower = mapDataReady ? f_lower_checkpoint(frozenReferenceActive ? cycleTouchLow : closedChartState.bundleLow) : na
// Slow guide always uses the latest CLOSED slow cohort; only upper/lower freeze.
// This is the reference available to the NEXT bar, not a stand-alone failure rule.
float mapSlow = mapDataReady ? math.round_to_mintick(closedChartState.slowCentroid) : na
int mapSourceTime = frozenReferenceActive ? cycleTouchReferenceTime : closedChartState.closedAt
float nextReclaimCheckpoint = directionalCycle > 0 ? mapUpper : directionalCycle < 0 ? mapLower : na
float closedFastDistanceAtr = closedChartState.ready ? f_safe_div(lastClosedPrice - closedChartState.fastCentroid, closedChartState.atrValue) : na
string mapSourceName = frozenReferenceActive ? "FROZEN TOUCH" : "CLOSED BUNDLE"
string checkpointState = not mapDataReady ? "NO PRICE REFERENCES" : directionalCycle == 0 ? "NO ACTIVE CYCLE" : not cycleTouched ? "FIRST TOUCH WATCH " + f_direction_word(directionalCycle) : cycleReclaimed ? "RECLAIM COMPLETED " + f_direction_word(directionalCycle) : "RECLAIM WATCH " + f_direction_word(directionalCycle)

f_update_guide(line id, float level, color ink, bool frozen, bool allowed) =>
    line result = id
    bool inRange = allowed and not na(level) and not na(lastClosedPrice) and not na(closedChartState.atrValue) and closedChartState.atrValue > 0.0 and math.abs(level - lastClosedPrice) <= referenceMaxDistanceAtr * closedChartState.atrValue
    if inRange
        if na(result)
            result := line.new(bar_index, level, bar_index + referenceGuideBars, level, xloc = xloc.bar_index, extend = extend.none, color = ink, style = frozen ? line.style_solid : line.style_dotted, width = frozen ? 2 : 1, force_overlay = true)
        else
            line.set_xy1(result, bar_index, level)
            line.set_xy2(result, bar_index + referenceGuideBars, level)
            line.set_color(result, ink)
            line.set_style(result, frozen ? line.style_solid : line.style_dotted)
            line.set_width(result, frozen ? 2 : 1)
    else if not na(result)
        line.delete(result)
        result := na
    result

var line upperGuide = na
var line lowerGuide = na
var line slowGuide = na
if barstate.islast
    upperGuide := f_update_guide(upperGuide, mapUpper, color.new(bullColor, 18), frozenReferenceActive, showReferenceMap and mapDataReady)
    lowerGuide := f_update_guide(lowerGuide, mapLower, color.new(bearColor, 18), frozenReferenceActive, showReferenceMap and mapDataReady)
    slowGuide := f_update_guide(slowGuide, mapSlow, color.new(accentColor, 25), false, showReferenceMap and mapDataReady)

bool latestCheckpointExists = enableCheckpointWatch and not na(latestCheckpoint)
bool latestCheckpointActive = latestCheckpointExists and (latestCheckpoint.status == 0 or latestCheckpoint.status == 1)
float latestCheckpointGapAtr = latestCheckpointExists ? f_safe_div(latestCheckpoint.direction * (latestCheckpoint.lastClose - latestCheckpoint.level), latestCheckpoint.eventAtr) : na
var line maintenanceGuide = na
if barstate.islast
    maintenanceGuide := f_update_guide(maintenanceGuide, latestCheckpointActive ? latestCheckpoint.level : na, accentColor, false, showCheckpointGuide and latestCheckpointActive and mapDataReady)
    if not na(maintenanceGuide)
        line.set_style(maintenanceGuide, line.style_dashed)
        line.set_width(maintenanceGuide, 2)

// ============================================================================
// Fixed operational HUD: five information rows in Trader mode, no empty frame.
// ============================================================================
f_hud_cell(table target, int column, int row, string value, color ink, color background, string fontSize, string tip) =>
    // Update the existing cell, preserving its width and its merged-cell geometry.
    table.cell_set_text(target, column, row, value)
    table.cell_set_text_color(target, column, row, ink)
    table.cell_set_bgcolor(target, column, row, background)
    table.cell_set_text_size(target, column, row, fontSize)
    table.cell_set_tooltip(target, column, row, tip)

f_layer_card(string name, string tf, RegimeState state, bool enabled, bool valid, bool showAge) =>
    string value = "OFF"
    if enabled
        if not valid
            value := "INVALID TF"
        else if state.geometryNeeded == 0
            value := "NO CLOSED DATA"
        else if state.configurationIssue != 0
            value := f_configuration_name(state.configurationIssue)
        else if not state.ready
            value := (state.directionReady ? f_direction_word(state.bias) + " / " : "") + "WARM " + str.tostring(math.min(state.geometryBars, state.geometryNeeded)) + "/" + str.tostring(state.geometryNeeded)
        else
            value := (useDashboardIcons ? f_bias_icon(state.bias) + " " : f_direction_word(state.bias) + " ") + f_phase_ui(state.phase) + (showAge ? " " + (state.episodeStartKnown ? "" : ">=") + str.tostring(state.age) + "b" : "")
    name + " " + f_tf_label(tf) + (enabled and valid and state.profileCode > 0 ? " [" + f_profile_name(state.profileCode) + "]" : "") + "\n" + value

f_layer_tip(string name, string tf, RegimeState state, bool enabled, bool valid) =>
    string result = not enabled ? name + " is disabled." : not valid ? name + " requires a strictly higher supported timeframe. No substitute was used." : name + " " + f_tf_label(tf)
    if enabled and valid
        result += "\nProfile: " + f_profile_name(state.profileCode) + "; policy: " + (name == "Local" ? "Unchanged chart settings" : htfHistoryMode)
        result += "\nConfiguration: " + f_configuration_name(state.configurationIssue) + "\n" + f_configuration_hint(state.configurationIssue)
        result += "\nCohorts are fixed from ORIGINAL unique specifications before shortening. Mode: " + cohortMode + "; original manual boundary: " + str.tostring(cohortManualLength) + "; rank boundary: " + str.tostring(cohortRankSplit)
        result += "\nConfigured FAST/SLOW: " + str.tostring(state.configuredFast) + "/" + str.tostring(state.configuredSlow) + "; comparable pairs: " + str.tostring(state.configuredPairs) + "; cross-cohort shortened duplicate conflicts: " + str.tostring(state.crossCohortDuplicates)
        result += "\nEffective unique MAs (F=fast, S=slow): " + state.effectiveSpec
        result += "\nLongest MA: " + str.tostring(state.maximumLength) + "; width rank: " + str.tostring(state.effectiveRank) + "; reorder: " + str.tostring(state.effectiveReorder)
        result += "\nSlope: " + str.tostring(state.effectiveSlope) + "; width motion: " + str.tostring(state.effectiveMotion) + "; deceleration: " + str.tostring(state.effectiveDecel)
        result += "\nATR: " + str.tostring(state.effectiveAtr) + "; stdev: " + str.tostring(state.effectiveStdev)
        result += "\nComplete-geometry bars: " + str.tostring(state.geometryBars) + "/" + str.tostring(state.geometryNeeded) + "; loaded bars: " + str.tostring(state.loadedBars) + "; total-bar floor: " + str.tostring(state.warmupFloor)
        result += "\nAvailable/unique MAs: " + str.tostring(state.enabledCount) + "/" + str.tostring(state.configuredCount) + "; duplicate effective specifications excluded: " + str.tostring(state.duplicateCount)
        result += "\nEffective windows are fixed before observing the series, not dynamically shortened to force readiness. Warm counter measures only complete geometry; other readiness conditions also apply. Missing data or invalid cohorts can prevent readiness. Request cap: " + str.tostring(mtfCalcBars) + " HTF bars."
        result += "\nState bar closes at: " + f_time_label(state.closedAt) + " (" + syminfo.timezone + ")"
        result += "\nDirection: " + (state.directionReady ? f_bias_name(state.bias) : "Not ready") + "; lifecycle: " + (state.ready ? f_phase_name(state.phase) : "Not ready")
        result += "\nObserved age: " + (state.episodeStartKnown ? "" : ">=") + str.tostring(state.age) + " bars; bias: " + f_signed(state.biasComposite) + "; order: " + f_signed(state.orderCoherence) + "; slope: " + f_signed(state.slopeCoherence)
        result += "\nHigher layers use completed HTF objects. Partial direction is not full lifecycle readiness and NEVER qualifies full alignment. Compact-profile scores use their disclosed windows; do not treat them as matched-horizon estimates."
    result

bool hudHasReferences = dashboardMode != "Clean"
bool hudHasAudit = dashboardMode == "Analyst" or dashboardMode == "Research"
bool hudHasResearch = dashboardMode == "Research"
int hudBaseRows = hudHasReferences ? 6 : 5
int hudContentRows = hudBaseRows + (hudHasAudit ? 2 : 0) + (hudHasResearch ? 2 : 0)
int hudEventRow = hudBaseRows - 1
var table regimeHud = table.new(f_pos(dashboardPosition), 3, hudContentRows + 1, bgcolor = na, frame_width = 0, border_width = 0)
if barstate.isfirst and showDashboard
    // Populate every cell BEFORE merging. All future updates use cell setters.
    for row = 0 to hudContentRows
        for column = 0 to 2
            table.cell(regimeHud, column, row, "", width = dashboardWidthPercent / 3.0, bgcolor = na, text_size = f_size(dashboardTextSize), text_halign = text.align_center, text_valign = text.align_center, text_font_family = font.family_default, text_formatting = text.format_bold)
    table.merge_cells(regimeHud, 0, 0, 1, 0)
    table.merge_cells(regimeHud, 0, 1, 2, 1)
    table.merge_cells(regimeHud, 0, hudEventRow, 1, hudEventRow)
    for column = 0 to 2
        table.cell_set_height(regimeHud, column, hudContentRows, str.startswith(dashboardPosition, "Bottom") ? float(dashboardLogoClearance) : 0.1)
        table.cell_set_text_size(regimeHud, column, hudContentRows, size.tiny)

if barstate.islast
    if showDashboard
        string hudSize = f_size(dashboardTextSize)
        string heroSize = dashboardTextSize == "Tiny" ? size.small : dashboardTextSize == "Small" ? size.normal : size.large
        bool preview = hudSnapshotMode == "Live preview" and not barstate.isconfirmed
        color biasInk = hudState.configurationIssue != 0 ? bearColor : hudState.ready ? f_bias_color(hudState.bias) : mutedTextColor
        bool conflict = f_context_conflict(hudState, hudAnchor, hudMacro)
        string mainContext = f_context_description(hudState, hudAnchor, hudMacro)
        color contextInk = conflict ? decelerationColor : str.startswith(mainContext, "ALIGNED") ? biasInk : mainTextColor
        string health = ""
        if not chart.is_standard or not chartTimeBased
            health := "STANDARD TIME BARS REQUIRED"
        else if not topologyInvariantOk or not memoryInvariantOk or not studyConservationOk or not checkpointAccountingOk
            health := "AUDIT ERROR - CHECK DATA"
        else if hudState.configurationIssue != 0
            health := "LOCAL: " + f_configuration_name(hudState.configurationIssue)
        else if useAnchorTimeframe and anchorValid and hudAnchor.configurationIssue != 0
            health := "ANCHOR: " + f_configuration_name(hudAnchor.configurationIssue)
        else if useMacroTimeframe and macroValid and hudMacro.configurationIssue != 0
            health := "MACRO: " + f_configuration_name(hudMacro.configurationIssue)
        else if (enableOutcomeLab and minimumOutcomeSamples > maximumOutcomeSamples) or (enableStructureMemory and minimumMemorySamples > memorySamplesPerState)
            health := "STUDY MINIMUM EXCEEDS CAP"
        else if enableOutcomeLab and not baselineConfigurationValid
            health := "CHECK EMA CONTROL LENGTHS"
        else if enableCheckpointWatch and not checkpointConfigurationValid
            health := "HOLD BARS EXCEED WATCH WINDOW"
        if health != ""
            mainContext := health
            contextInk := bearColor
        string statusTip = "Version 3.2.1 by SG Group.\nHUD mode: " + hudSnapshotMode + "\nA Confirmed HUD holds chart state, topology, price and the HTFs observed at that completed chart bar. The open ribbon is a LIVE geometry preview.\nReference guides always use closed data or a frozen first-touch snapshot, even in Live preview mode.\nUnique/available MA slots: " + str.tostring(hudState.configuredCount) + "/" + str.tostring(hudState.enabledCount) + "\nDuplicate MA specifications ignored: " + str.tostring(hudState.duplicateCount) + "\nEvents and studies are disabled on unsupported charts.\nPresets/thresholds are not optimized per market."
        statusTip += "\nHTF policy: " + htfHistoryMode + ". Weekly/coarser compact profiles are visible in the layer names; local settings are retained. Original cohort membership is retained across shortened HTFs; structural configuration errors are distinct from WARM. Unavailable enabled layers do not count as neutral or aligned.\nMarker legend: small text dot=R; RA=full HTF alignment; RAS=full alignment plus stable fixed-vote order. The R-only spacing filter changes no recorded event or watch. Event-time conditions, not expected-return grades.\nHUD total width is fixed by input. Merged cells are initialized once and never cleared/repopulated during tick updates."
        f_hud_cell(regimeHud, 0, 0, "MA STRUCTURE  3.2.1", accentColor, headerBackground, size.small, statusTip)
        f_hud_cell(regimeHud, 2, 0, syminfo.ticker + " " + f_tf_label(timeframe.period), mainTextColor, headerBackground, size.small, statusTip)
        f_hud_cell(regimeHud, 0, 1, mainContext, contextInk, headerBackground, heroSize, "This is timeframe context, not a buy/sell recommendation.\nOne opposite HTF is a conflict; disagreeing HTFs are explicitly MIXED.\nAligned direction remains aligned in compression, deceleration and transition phases.\n" + statusTip)
        f_hud_cell(regimeHud, 0, 2, f_layer_card("LOCAL", timeframe.period, hudState, true, true, true), biasInk, panelBackground, hudSize, f_layer_tip("Local", timeframe.period, hudState, true, true) + (preview ? "\nTHIS CHART STATE IS AN UNCONFIRMED PREVIEW." : "\nThis chart state is closed."))
        f_hud_cell(regimeHud, 1, 2, f_layer_card("ANCHOR", anchorTimeframe, hudAnchor, useAnchorTimeframe, anchorValid, false), useAnchorTimeframe and anchorValid ? (hudAnchor.configurationIssue != 0 ? bearColor : hudAnchor.ready ? f_bias_color(hudAnchor.bias) : mutedTextColor) : mutedTextColor, alternateBackground, hudSize, f_layer_tip("Anchor", anchorTimeframe, hudAnchor, useAnchorTimeframe, anchorValid))
        f_hud_cell(regimeHud, 2, 2, f_layer_card("MACRO", macroTimeframe, hudMacro, useMacroTimeframe, macroValid, false), useMacroTimeframe and macroValid ? (hudMacro.configurationIssue != 0 ? bearColor : hudMacro.ready ? f_bias_color(hudMacro.bias) : mutedTextColor) : mutedTextColor, panelBackground, hudSize, f_layer_tip("Macro", macroTimeframe, hudMacro, useMacroTimeframe, macroValid))

        bool enoughDeletion = hudTopology.valid and hudTopology.validAblations == hudState.enabledCount and hudTopology.validAblations > 0
        bool neutralOrder = f_order_class(hudState.orderCoherence) == 0
        bool stableOrder = enoughDeletion and not neutralOrder and hudTopology.agreement >= 100.0 - 1e-8 and hudTopology.largestShift <= topologyMaximumShift and hudTopology.recompositionError <= 1e-6
        string sensitivityLabel = not enoughDeletion ? "ORDER AUDIT N/A" : neutralOrder ? "NEUTRAL ORDER" : stableOrder ? "STABLE ORDER" : "SENSITIVE ORDER"
        int heldDeletionCount = enoughDeletion ? int(math.round(hudTopology.agreement * hudTopology.validAblations / 100.0)) : 0
        string clarityLabel = hudState.configurationIssue != 0 ? "CONFIG" : not hudState.ready ? "WARMING" : hudState.clarity < clarityLowBoundary ? "LOW" : hudState.clarity < math.max(clarityLowBoundary, 65.0) ? "MIXED" : "ORDERED"
        string clarityText = "CLARITY " + clarityLabel + "\n" + (hudState.ready ? (useDashboardMeters ? f_meter(hudState.clarity, 3) + " " : "") + f_0(hudState.clarity) + "/100" : "n/a")
        string clarityTip = "Heuristic clarity, not confidence, success probability or a rank against other scripts.\nPurity: " + f_pct0(hudState.orderPurity) + "\nTies: " + f_pct0(hudState.tieRatio) + "\nReorders: " + f_pct1(hudState.reorderRate) + "\nSlope energy: " + f_0(hudState.slopeEnergyScore) + "/100\nLOW display threshold: " + f_0(clarityLowBoundary)
        string sensitivityTip = "Fixed-vote leave-one-MA-out audit.\nClass agreement: " + f_pct0(hudTopology.agreement) + "\nValid deletions: " + str.tostring(hudTopology.validAblations) + "\nLargest order-point shift: " + f_1(hudTopology.largestShift) + "\nDeleted-order range: " + f_signed(hudTopology.looLow) + " to " + f_signed(hudTopology.looHigh) + "\nMost influential MA: " + f_slot_label(hudTopology.influentialSlot) + "\nPair votes, normalization and cohort membership are fixed. STABLE ORDER does not mean low market risk. Neutral order is labelled separately even when deletion agreement is 100%."
        float hudFastGap = hudState.ready ? f_safe_div(hudClose - hudState.fastCentroid, hudState.atrValue) : na
        bool hudExtended = hudState.bias != 0 and not na(hudFastGap) and hudFastGap * hudState.bias >= priceExtensionAtr
        string pricePlace = hudState.configurationIssue != 0 ? "CONFIG ERROR" : not hudState.ready ? "WARMING" : hudClose > hudState.bundleHigh ? "ABOVE BUNDLE" : hudClose < hudState.bundleLow ? "BELOW BUNDLE" : "INSIDE BUNDLE"
        string priceText = (hudExtended ? "EXTENDED" : pricePlace) + "\n" + (not hudState.ready ? "n/a" : "FAST " + f_signed(hudFastGap) + " ATR")
        string priceTip = (preview ? "Preview price: " : "Closed price: ") + f_num(hudClose) + "\nActual close versus full MA bundle: " + pricePlace + "\nSigned distance from fast-cohort mean: " + f_signed3(hudFastGap) + " ATR\nPositive means above the fast mean; negative means below.\nExtension uses the local bias direction and threshold " + f_1(priceExtensionAtr) + " ATR. It does not predict mean reversion.\nATR units use ATR(" + str.tostring(atrLength) + "), independent of the engine's normalization option."
        f_hud_cell(regimeHud, 0, 3, clarityText, hudState.ready and hudState.clarity < clarityLowBoundary ? decelerationColor : mainTextColor, alternateBackground, hudSize, clarityTip)
        f_hud_cell(regimeHud, 1, 3, sensitivityLabel + "\n" + (enoughDeletion ? str.tostring(heldDeletionCount) + "/" + str.tostring(hudTopology.validAblations) + " unchanged" : "insufficient pairs"), not enoughDeletion or neutralOrder ? mutedTextColor : stableOrder ? accentColor : decelerationColor, panelBackground, hudSize, sensitivityTip)
        f_hud_cell(regimeHud, 2, 3, priceText, hudExtended ? decelerationColor : mainTextColor, alternateBackground, hudSize, priceTip)

        string referenceTip = "Reference source: " + mapSourceName + "\nSource MA bar closed at: " + f_time_label(mapSourceTime) + " (exchange timezone)\n" + checkpointState + "\nReclaim definition: " + reclaimBoundaryMode + "\nUpper/lower are the FIRST tradable close ticks strictly beyond the MA edge plus the configured clearance. A close at the displayed tick qualifies as the price condition. Actual crossing and structural conditions are also required.\nCURRENT SLOW always uses the most recent closed slow cohort, even when upper/lower touch boundaries are frozen. Its displayed value is tick-rounded; failure uses the unrounded previous-bar value.\nTick clearance on upper/lower: " + str.tostring(reclaimBufferTicks) + " ticks\nUpper checkpoint: " + f_num(mapUpper) + "\nCurrent closed slow-cohort reference: " + f_num(mapSlow) + "\nLower checkpoint: " + f_num(mapLower) + "\nA pending reclaim also requires a later-bar actual price cross, matching local bias and held pair order; touching the price alone is insufficient.\nFailure uses current structure plus the previous closed slow cohort, or a bias reversal. CURRENT SLOW is therefore NOT a stop-loss or the full failure rule.\nGuides outside " + f_1(referenceMaxDistanceAtr) + " ATR are hidden visually, not removed from this table.\nThese are current reference values, not historical projections or future MA estimates."
        if hudHasReferences
            string upperTitle = frozenReferenceActive and directionalCycle > 0 and not cycleReclaimed ? "RECLAIM CLOSE >=" : "UPPER CLOSE >="
            string lowerTitle = frozenReferenceActive and directionalCycle < 0 and not cycleReclaimed ? "RECLAIM CLOSE <=" : "LOWER CLOSE <="
            f_hud_cell(regimeHud, 0, 4, upperTitle + "\n" + f_num(mapUpper), bullColor, panelBackground, hudSize, referenceTip)
            f_hud_cell(regimeHud, 1, 4, "CURRENT SLOW\n" + f_num(mapSlow), accentColor, alternateBackground, hudSize, referenceTip)
            f_hud_cell(regimeHud, 2, 4, lowerTitle + "\n" + f_num(mapLower), bearColor, panelBackground, hudSize, referenceTip)

        int keyAge = na(lastKeyEventBar) ? na : closedReferenceBar - lastKeyEventBar
        bool recentKey = not na(keyAge) and keyAge <= keyEventFreshBars
        string eventName = lastKeyEventText + (lastKeyEventDirection == 0 ? "" : " " + (useDashboardIcons ? f_bias_icon(lastKeyEventDirection) : f_direction_word(lastKeyEventDirection))) + (na(keyAge) ? "" : " · " + str.tostring(keyAge) + "b" + (recentKey ? "" : " OLD"))
        string watchText = mapDataReady ? (frozenReferenceActive ? "FROZEN " : "ROLLING ") + (directionalCycle == 0 ? "BUNDLE" : cycleReclaimed ? "RECLAIM COMPLETE" : cycleTouched ? "RECLAIM WATCH" : "TOUCH WATCH") : "REFERENCES UNAVAILABLE"
        string ledgerTip = "Last key event (routine transitions do not replace it): " + eventName + "\nLast base-structure event: " + lastEventText + "\nConcurrent base-structure events at latest base event bar: " + str.tostring(lastConcurrentEvents) + "\nDisplay-suppressed markers: " + str.tostring(suppressedMarkerCount) + "\nAll recorded events, newest first (exchange timezone):"
        int ledgerCount = array.size(recentEventLedger)
        if ledgerCount > 0
            for i = ledgerCount - 1 to 0
                ledgerTip += "\n" + array.get(recentEventLedger, i)
        ledgerTip += "\n\n" + referenceTip + "\nAll alerts and studies use confirmed events irrespective of marker/HUD settings."
        string footerText = eventName + "\n" + watchText
        color footerInk = recentKey ? (lastKeyEventDirection == 0 ? accentColor : f_bias_color(lastKeyEventDirection)) : mutedTextColor
        string maintenanceTip = "Frozen-checkpoint maintenance: every raw reclaim is tracked independently of marker display, current cycle and event class.\nInitial requirement: " + str.tostring(checkpointHoldBars) + " later consecutive closes; total window: " + str.tostring(checkpointWatchBars) + " bars. Event bar excluded. First adverse CLOSE ends the watch.\nStarted/pending/lost/window-held/interrupted/skipped: " + str.tostring(checkpointStarted) + "/" + str.tostring(array.size(checkpointWatches)) + "/" + str.tostring(checkpointLost) + "/" + str.tostring(checkpointWindowHeld) + "/" + str.tostring(checkpointInterrupted) + "/" + str.tostring(checkpointSkipped) + "\nCounts are operational accounting, not a win rate. Initial hold and later loss may both happen for one watch. No bar's original marker or class is changed."
        if latestCheckpointExists
            int checkpointAge = closedReferenceBar - latestCheckpoint.eventBar
            bool checkpointRecent = checkpointAge <= checkpointWatchBars + keyEventFreshBars
            maintenanceTip += "\nNewest: " + f_reclaim_class(latestCheckpoint.contextClass) + " " + f_direction_word(latestCheckpoint.direction) + " from " + f_time_label(latestCheckpoint.eventTime) + " @ " + f_num(latestCheckpoint.level)
            maintenanceTip += "\nState: " + f_checkpoint_status(latestCheckpoint) + "; observed later bars: " + str.tostring(latestCheckpoint.observedBars) + "; held closes: " + str.tostring(latestCheckpoint.heldCloses)
            maintenanceTip += "\nLast checked: " + f_time_label(latestCheckpoint.checkedAt) + "; last checked close: " + f_num(latestCheckpoint.lastClose) + "; signed gap: " + f_signed3(latestCheckpointGapAtr) + " event-ATR; smallest later-close margin: " + f_signed3(latestCheckpoint.smallestMarginAtr)
            maintenanceTip += "\nATR denominator is frozen at the event. Positive gap means the close is on that event's reclaimed side. Terminal gaps stay at the terminal close; they do not update with current price. Older active watches continue but only the newest watch is shown."
            if checkpointRecent
                footerText := f_reclaim_class(latestCheckpoint.contextClass) + " " + f_direction_word(latestCheckpoint.direction) + " | " + f_checkpoint_status(latestCheckpoint) + "\n" + f_num(latestCheckpoint.level) + " | " + f_signed(latestCheckpointGapAtr) + " event-ATR | " + str.tostring(latestCheckpoint.observedBars) + "b" + (latestCheckpointActive ? "" : " END")
                footerInk := latestCheckpoint.status == 2 or latestCheckpoint.status == 4 ? decelerationColor : latestCheckpoint.holdReported ? accentColor : mainTextColor
        ledgerTip += "\n\n" + maintenanceTip + "\nCurrent cycle: " + watchText
        f_hud_cell(regimeHud, 0, hudEventRow, footerText, footerInk, headerBackground, hudSize, ledgerTip)
        string statusText = preview ? "LIVE PREVIEW" : "CLOSE SNAPSHOT"
        f_hud_cell(regimeHud, 2, hudEventRow, statusText + "\n" + (preview ? "NOT CONFIRMED" : f_time_label(hudState.closedAt) + " EXCH"), preview ? decelerationColor : mutedTextColor, headerBackground, size.small, statusTip + "\n" + ledgerTip)

        if hudHasAudit
            int auditRow = hudBaseRows
            string topologyTip = "Each block has its own total pair weight: within-fast, cross-cohort and within-slow. Not independent indicators.\nFull weighted order: " + f_signed(hudState.orderCoherence) + "\nRecomposition error: " + f_2(hudTopology.recompositionError) + "\n" + sensitivityTip
            f_hud_cell(regimeHud, 0, auditRow, "FAST ORDER\n" + f_signed(hudTopology.fastOrder), na(hudTopology.fastOrder) ? mutedTextColor : f_bias_color(f_order_class(hudTopology.fastOrder)), panelBackground, hudSize, topologyTip)
            f_hud_cell(regimeHud, 1, auditRow, "CROSS ORDER\n" + f_signed(hudTopology.crossOrder), na(hudTopology.crossOrder) ? mutedTextColor : f_bias_color(f_order_class(hudTopology.crossOrder)), alternateBackground, hudSize, topologyTip)
            f_hud_cell(regimeHud, 2, auditRow, "SLOW ORDER\n" + f_signed(hudTopology.slowOrder), na(hudTopology.slowOrder) ? mutedTextColor : f_bias_color(f_order_class(hudTopology.slowOrder)), panelBackground, hudSize, topologyTip)
            string widthTip = "Exact normalized-width change over " + str.tostring(widthMotionBars) + " bars: geometry + divisor = total. Geometry first changes width at the current divisor; divisor is the residual. This path-specific decomposition is not a unique causal attribution.\nNormalization: " + normalizationMode + "\nGeometry guard: " + (requireGeometricWidth ? "ON" : "OFF") + "\nWidth percentile rank: " + f_pct0(hudState.widthRank)
            f_hud_cell(regimeHud, 0, auditRow + 1, "WIDTH GEOMETRY\n" + f_signed3(hudState.widthGeometryDelta), mainTextColor, alternateBackground, hudSize, widthTip)
            f_hud_cell(regimeHud, 1, auditRow + 1, "WIDTH DIVISOR\n" + f_signed3(hudState.widthDenominatorDelta), mainTextColor, panelBackground, hudSize, widthTip)
            f_hud_cell(regimeHud, 2, auditRow + 1, "WIDTH TOTAL\n" + f_signed3(hudState.widthDelta), mainTextColor, alternateBackground, hudSize, widthTip)

        if hudHasResearch
            int researchRow = hudBaseRows + 2
            string memoryTip = "Completed, fully observed bias+phase episodes only. Current and left-censored episodes are excluded.\nMinimum count: " + str.tostring(activeMinimumMemorySamples) + "\nMedian [Q25,Q75]: " + f_1(durationStats.median) + " [" + f_1(durationStats.q25) + "," + f_1(durationStats.q75) + "] bars\nObserved current-age rank: " + f_pct0(durationStats.agePercentile) + "\nEpisodes reaching current age: " + str.tostring(durationStats.atRiskCount) + "\nShare lasting " + str.tostring(persistenceHorizon) + " more bars: " + f_pct0(durationStats.persistence) + "\nTop next destination: " + (durationStats.topNextPhase > 0 ? f_phase_name(durationStats.topNextPhase) + " " + f_pct0(durationStats.topNextPct) : "insufficient N") + "\nSame retained window for durations/destinations. Descriptive memory, not a survival forecast."
            string memoryN = not enableStructureMemory ? "OFF" : not studyChartSupported ? "DISABLED" : "N " + str.tostring(durationStats.count) + "/" + str.tostring(activeMinimumMemorySamples)
            f_hud_cell(regimeHud, 0, researchRow, "EPISODES\n" + memoryN, mutedTextColor, panelBackground, hudSize, memoryTip)
            f_hud_cell(regimeHud, 1, researchRow, "MEDIAN AGE\n" + f_1(durationStats.median) + " bars", mainTextColor, alternateBackground, hudSize, memoryTip)
            f_hud_cell(regimeHud, 2, researchRow, "MORE " + str.tostring(persistenceHorizon) + " BARS\n" + f_pct0(durationStats.persistence), mainTextColor, panelBackground, hudSize, memoryTip)
            string studyTip = "Event: " + studyEventType + "\nReclaim definition: " + reclaimBoundaryMode + "\nEntry: " + studyEntryMode + "; H=" + str.tostring(studyHorizon) + " bars\nEvent/EMA mean movement: " + f_signed_pct(outcomeStats.meanReturn) + "/" + f_signed_pct(outcomeStats.meanBaseline) + "\nMedian [Q25,Q75]: " + f_signed_pct(outcomeStats.medianReturn) + " [" + f_signed_pct(outcomeStats.q25Return) + "," + f_signed_pct(outcomeStats.q75Return) + "]\nRobust/other N: " + str.tostring(robustOutcomeStats.count) + "/" + str.tostring(otherOutcomeStats.count) + "\nRobust/other median: " + f_signed_pct(robustOutcomeStats.medianReturn) + "/" + f_signed_pct(otherOutcomeStats.medianReturn) + "\nEarlier/later paired delta: " + f_signed3(outcomeStats.earlyMeanDelta) + "/" + f_signed3(outcomeStats.lateMeanDelta) + " pp\nSame event dates, price windows and sample list for the EMA-direction comparison. No costs/fills. Not a timing-edge or out-of-sample test. Every subgroup/half needs its own minimum N."
            string studyN = not enableOutcomeLab ? "OFF" : not studyChartSupported ? "DISABLED" : "N " + str.tostring(outcomeStats.count) + "/" + str.tostring(activeMinimumOutcomeSamples)
            f_hud_cell(regimeHud, 0, researchRow + 1, "EVENT STUDY\n" + studyN, mutedTextColor, alternateBackground, hudSize, studyTip)
            f_hud_cell(regimeHud, 1, researchRow + 1, "EVENT MEDIAN\n" + f_signed_pct(outcomeStats.medianReturn), mainTextColor, panelBackground, hudSize, studyTip)
            f_hud_cell(regimeHud, 2, researchRow + 1, "VS EMA MEAN\n" + f_signed3(outcomeStats.meanDelta) + "pp", mainTextColor, alternateBackground, hudSize, studyTip)
        // Transparent, borderless spacer, only for bottom-corner HUDs.
        if str.startswith(dashboardPosition, "Bottom") and dashboardLogoClearance > 0
            for column = 0 to 2
                table.cell_set_height(regimeHud, column, hudContentRows, dashboardLogoClearance)

// ============================================================================
// Optional evidence table. This is an event study, not a strategy tester.
// ============================================================================
f_signed2(float value) =>
    na(value) ? "n/a" : (value > 0.0 ? "+" : "") + str.tostring(value, "0.00")

f_evidence_row(table panel, int row, string metric, string leftValue, string rightValue, string detail) =>
    color rowBackground = row % 2 == 0 ? panelBackground : alternateBackground
    f_hud_cell(panel, 0, row, metric, mutedTextColor, rowBackground, size.small, detail)
    f_hud_cell(panel, 1, row, leftValue, mainTextColor, rowBackground, size.small, detail)
    f_hud_cell(panel, 2, row, rightValue, mainTextColor, rowBackground, size.small, detail)

string evidenceCorner = dashboardPosition == "Bottom right" and showDashboard ? position.bottom_left : position.bottom_right
var table evidencePanel = table.new(evidenceCorner, 3, 16, bgcolor = na, frame_color = showEvidencePanel ? borderColor : na, frame_width = showEvidencePanel ? 1 : 0, border_color = showEvidencePanel ? borderColor : na, border_width = showEvidencePanel ? 1 : 0)
if barstate.isfirst and showEvidencePanel
    for row = 0 to 15
        for column = 0 to 2
            table.cell(evidencePanel, column, row, "", bgcolor = na, text_size = size.small, text_halign = column == 0 ? text.align_left : text.align_right, text_formatting = text.format_bold)
    table.merge_cells(evidencePanel, 0, 0, 2, 0)
    table.merge_cells(evidencePanel, 0, 15, 2, 15)
if barstate.islast
    if showEvidencePanel
        string retainedWindow = array.size(completedObservations) > 0 ? str.format_time((array.get(completedObservations, 0)).signalTime, "yyyy-MM-dd", "UTC") + " to " + str.format_time((array.get(completedObservations, array.size(completedObservations) - 1)).signalTime, "yyyy-MM-dd", "UTC") : "none"
        string panelTitle = not enableOutcomeLab ? "EVENT STUDY | OFF" : not studyChartSupported ? "EVENT STUDY | UNSUPPORTED CHART" : not baselineConfigurationValid ? "EVENT STUDY | INVALID EMA LENGTHS" : "EVENT STUDY | DESCRIPTIVE ONLY"
        f_hud_cell(evidencePanel, 0, 0, panelTitle, accentColor, headerBackground, size.small, "Paired event study; separate from frozen-checkpoint maintenance.")
        f_evidence_row(evidencePanel, 1, "METRIC", "EVENT", "EMA CONTROL", "Both directions are frozen at the event close. Same entry reference, horizon and completed sample list. Neutral EMA controls remain in the sample with zero directional movement.")
        f_evidence_row(evidencePanel, 2, "Completed / pending", str.tostring(outcomeStats.count), str.tostring(array.size(activeObservations)), "Retained event-close dates (UTC): " + retainedWindow + "\nCompleted means the retained last N observations, not independent trades. Pending outcomes are not included. Minimum numerical reporting count: " + str.tostring(activeMinimumOutcomeSamples) + ".")
        f_evidence_row(evidencePanel, 3, "Mean movement (%)", f_signed2(outcomeStats.meanReturn), f_signed2(outcomeStats.meanBaseline), "Direction times percentage price movement. No compounding, costs, slippage, position sizing or intrabar execution model.")
        f_evidence_row(evidencePanel, 4, "Median movement (%)", f_signed2(outcomeStats.medianReturn), f_signed2(outcomeStats.medianBaseline), "Linearly interpolated median, including the average of the middle two values when N is even.")
        f_evidence_row(evidencePanel, 5, "Paired delta mean / median (pp)", f_signed2(outcomeStats.meanDelta), f_signed2(outcomeStats.medianDelta), "Delta for each sample = event-directed movement minus EMA-directed movement. If both directions are equal, the sample delta is exactly zero. This is NOT the difference between two independently timed strategies.")
        f_evidence_row(evidencePanel, 6, "Paired delta Q25 / Q75 (pp)", f_signed2(outcomeStats.deltaQ25), f_signed2(outcomeStats.deltaQ75), "Empirical dispersion of individual paired differences; not confidence limits for a mean and not a predictive interval.")
        string nominalCi = nonOverlappingSamples ? f_pct0(outcomeStats.ciLow) + " / " + f_pct0(outcomeStats.ciHigh) : "OFF: overlap"
        f_evidence_row(evidencePanel, 7, "Positive share / nominal CI", f_pct1(outcomeStats.positiveFrequency), nominalCi, "Positive share is NOT a win rate. The Wilson interval assumes Bernoulli-like independent observations; even non-overlapping samples may be dependent. It is suppressed when overlapping observations are enabled.")
        f_evidence_row(evidencePanel, 8, "MFE / MAE median (%)", f_signed2(outcomeStats.medianMfe), f_signed2(outcomeStats.medianMae), "Favorable/adverse OHLC excursion from the selected entry price, floored at zero. Event-close mode excludes signal-bar OHLC; next-open mode includes exactly H later bars.")
        f_evidence_row(evidencePanel, 9, "Robust: N / median (%)", str.tostring(robustOutcomeStats.count), f_signed2(robustOutcomeStats.medianReturn), "Subgroup frozen at event close: every valid single-slot deletion preserves the event-aligned order class; largest shift <= configured threshold. This subgroup does not filter the full event study.")
        f_evidence_row(evidencePanel, 10, "Other: N / median (%)", str.tostring(otherOutcomeStats.count), f_signed2(otherOutcomeStats.medianReturn), "All other accepted events, including insufficient ablation geometry. Different dates from the robust subgroup; not a causal treatment-control comparison.")
        f_evidence_row(evidencePanel, 11, "Earlier / later delta (pp)", f_signed2(outcomeStats.earlyMeanDelta), f_signed2(outcomeStats.lateMeanDelta), "Chronological halves of the retained window. Each half needs its own minimum count. No holdout, parameter optimization, p-value or out-of-sample claim.")
        f_evidence_row(evidencePanel, 12, "Different dir / neutral EMA", str.tostring(outcomeStats.differentDirections), str.tostring(outcomeStats.neutralBaselines), "Counts on the retained complete sample set. A large N with almost no directional disagreements is not evidence of added directional value.")
        f_evidence_row(evidencePanel, 13, "Entry / horizon", nextOpenEntry ? "NEXT OPEN" : "EVENT CLOSE", str.tostring(studyHorizon) + " bars", "Directions and subgroup labels are frozen on the confirmed event bar. Reclaim definition: " + reclaimBoundaryMode + ". No future bar is accessed. Samples enter completed statistics only at maturity.")
        f_evidence_row(evidencePanel, 14, "Overlap / invalid / discarded", str.tostring(studyOverlapSkips), str.tostring(studyInvalidSkips) + " / " + str.tostring(studyDiscarded), "Overlap and invalid refer to rejected candidates. Discarded refers to accepted observations subsequently invalidated by missing/non-positive OHLC. Accepted/completed/pending accounting is checked separately.")
        string evidenceFooter = studyConservationOk and memoryInvariantOk and topologyInvariantOk ? "Accounting OK | timing edge untested | no costs" : "AUDIT ERROR | do not interpret study"
        f_hud_cell(evidencePanel, 0, 15, evidenceFooter, studyConservationOk and memoryInvariantOk and topologyInvariantOk ? mutedTextColor : bearColor, headerBackground, size.small, "Study accounting does not validate profitability.")

// Data-window-only diagnostics do not alter the price scale. Completed outcome
// values appear on their MATURITY bar, never back on the original signal bar.
plot(chartState.ready ? chartState.orderCoherence : na, "Audit: weighted pair order", display = display.data_window)
plot(topologyStats.fastOrder, "Audit: within-fast order", display = display.data_window)
plot(topologyStats.crossOrder, "Audit: cross-cohort order", display = display.data_window)
plot(topologyStats.slowOrder, "Audit: within-slow order", display = display.data_window)
plot(topologyStats.agreement, "Audit: fixed-vote deletion agreement (%)", display = display.data_window)
plot(topologyStats.largestShift, "Audit: maximum one-slot order shift", display = display.data_window)
plot(chartState.ready ? chartState.widthGeometryDelta : na, "Audit: width geometry component", display = display.data_window)
plot(chartState.ready ? chartState.widthDenominatorDelta : na, "Audit: width divisor component", display = display.data_window)
plot(lastMaturedResult, "Study: directed movement at maturity (%)", display = display.data_window)
plot(lastMaturedDelta, "Study: paired difference at maturity (pp)", display = display.data_window)
plot(studyEvent ? studyDirection : na, "Study: confirmed event direction", display = display.data_window)

// Operational diagnostics retain raw confirmed events irrespective of HUD mode.
plot(chartState.ready ? currentFastDistanceAtr : na, "Context: close minus fast cohort (ATR)", display = display.data_window)
plot(reclaimEvent ? eventReclaimLevel : na, "Event: actual reclaim checkpoint price", display = display.data_window)
plot(eventGate and extensionEntered ? chartState.bias : na, "Event: extension entered direction", display = display.data_window)

// Maintenance data appear at their observation/terminal bar, never on a prior event.
plot(latestCheckpointExists ? latestCheckpoint.level : na, "Maintenance: newest frozen checkpoint", display = display.data_window)
plot(latestCheckpointActive ? latestCheckpointGapAtr : na, "Maintenance: active checked-close margin (event ATR)", display = display.data_window)
plot(checkpointHoldEvent ? checkpointHoldsThisBar : na, "Maintenance: initial holds confirmed now", display = display.data_window)
plot(checkpointLossEvent ? checkpointLossesThisBar : na, "Maintenance: checkpoint losses confirmed now", display = display.data_window)
````
