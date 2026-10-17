# ScalpMap - EMA Pivot Targets

- url: https://www.tradingview.com/script/va5Of1CN-ScalpMap-EMA-Pivot-Targets/
- type: indicator
- pine_id: PUB;58ed5961adc74b2d821b7bc5a5e144fb
- version: 5.0

## Description

[b]ScalpMap[/b] is a lightweight target-mapping tool designed for NQ scalping. It highlights nearby pivot-derived scalp levels on the correct side of EMA bias.

[b]Asset designed for:[/b]
[i]NQ / MNQ futures[/i]

[b]Recommended timeframe:[/b]
[i]15 seconds to 1 minute, depending on volatility.[/i]

In higher volatility conditions, lower timeframes may provide more responsive levels.
In lower volatility conditions, higher timeframes may help reduce noise.

The tool uses EMA34 as the main directional filter. When price is trading above the EMA with sufficient separation, the bias favours long-side setups. When price is trading below the EMA with sufficient separation, the bias favours short-side setups.

[b]The plotted levels are generated from two pivot layers:[/b]
[list=1]
[*]Tight close-based pivots for local structure.
[*]Wider wick-based pivots for larger rejection points.
[/list]
Pivot levels are filtered to reduce clutter and avoid plotting multiple levels too close together. Levels can also flip from resistance to support, or support to resistance, after confirmed close-through behaviour. This helps the tool focus on the most relevant levels around current price.

[b]Core trade logic:[/b]
[list=1]
[*]Take trades only on the correct side of the EMA.
[*]Avoid entries directly into clustered levels where price is likely to chop producing lower R trades whilst the EMA is rounding.
[*]Look for cleaner impulse scalp opportunities when price breaks through level and has open space toward the next spread-out target.
[/list]

[b]Visual guide:[/b]
[list]
[*]Blue levels mark upper targets / resistance-side levels.
[*]Red levels mark lower targets / support-side levels.
[*]The orange line is the EMA34 bias line.
[/list]

[i]This script is intended as a visual decision-support tool only. It does not provide buy or sell signals and should be used together with your own trade plan and risk management.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © godzcopilot

//@version=6
indicator("ScalpMap - EMA Pivot Targets", "ScalpMap", overlay=true)

// ScalpMap - EMA Pivot Targets (memory-optimized build)
//
// This tool maps nearby pivot-derived scalp targets and plots EMA34 as a
// visual directional reference.
//
// General use:
// - Use EMA34 as the visual directional filter.
// - Look for long setups when price is above EMA34.
// - Look for short setups when price is below EMA34.
// - Avoid entries directly into tightly clustered levels, as price may chop or stall.
// - Better impulse scalp setups often occur after price breaks through a nearby level
//   and has clear space toward the next spread-out target.
//
// V0.4 OPTIMIZATION NOTES
// - Removed unused pivot metadata.
// - Changed string IDs/sides to lighter integer/bool values.
// - Removed unused pivot ageing logic.
// - Changed array management to persistent scratch arrays.
// - Reduced repeated pivot scanning.
// - Added early loop exits.
// - Trimmed historical buffers.

// V0.5 BUG FIX
// - Fixed an issue where colour flipping would classify targets incorrectly

// ============================================================================
// Inputs
// ============================================================================
float version = input.float(0.5, "Version", options = [0.5])

const string GROUP_PIVOTS = "Pivot Targets"

int pivotLookback = input.int(5, "Tight Close Lookback", minval=1, group=GROUP_PIVOTS)
int pivotWideLookback = input.int(20, "Wide Wick Lookback", minval=1, group=GROUP_PIVOTS)
float pivotMinSwing = input.float(10.0, "Minimum Swing Distance", minval=0.0, step=0.25, group=GROUP_PIVOTS)

// ============================================================================
// Constants
// ============================================================================

const string SIDE_HIGH = "HIGH"
const string SIDE_LOW = "LOW"

const int TARGET_COUNT = 5
const int MAX_KEEP = 50
const float EXT_STEP_FLOOR_PTS = 5.0

// ============================================================================
// Custom types
// ============================================================================

// Stored completed bar used by the pivot scanner.
// c = close, h = high, l = low.
type ProcBar
    float c
    float h
    float l

// Pivot object.
//
// id           = unique integer handle (used for sorting bookkeeping).
// price        = pivot or extension level.
// strikes      = number of confirmed close-crosses through the level.
// lastAbove    = whether the last processed close was above the pivot.
// isExtension  = true for synthetic/projected levels, false for real pivots.
type Pivot
    int id
    float price
    int strikes
    bool lastAbove
    bool isExtension

// ============================================================================
// Persistent state
// ============================================================================

var array<ProcBar> procBars = array.new<ProcBar>()
var array<Pivot> highPivots = array.new<Pivot>()
var array<Pivot> lowPivots = array.new<Pivot>()
var array<float> trHistory = array.new<float>()

// Reusable target-selection buffers. Each bar/tick these are rebuilt relative to
// LIVE price: relAbove* holds the nearest levels above price, relBelow* the
// nearest below. Filled in a single pass over the pivot arrays. Persistent (var)
// + cleared per pass = no per-bar allocation.
var array<int> relAboveIds = array.new<int>()
var array<float> relAbovePrices = array.new<float>()
var array<float> relAboveDists = array.new<float>()
var array<int> relBelowIds = array.new<int>()
var array<float> relBelowPrices = array.new<float>()
var array<float> relBelowDists = array.new<float>()

var int pid = 0
// Latest extension step (ATR-derived), persisted from the bar-finalized block so
// the live target selection can project synthetic fill levels if a side is
// momentarily short of TARGET_COUNT real levels.
var float lastStep = EXT_STEP_FLOOR_PTS

// ============================================================================
// Pivot state helpers
// ============================================================================

// A pivot is retired after two confirmed close-crosses.
// Strike 0 = fresh level.
// Strike 1 = flipped support/resistance.
// Strike 2 = cleared/retired.
f_isRetired(Pivot p) =>
    p.strikes >= 2

// Returns the active functional side of the pivot.
//
// If price last closed above the pivot, the pivot acts as support below price.
// If price last closed below the pivot, the pivot acts as resistance above price.
//
// Cross-based (hysteresis) classification, used ONLY by the universe's extension
// generator to decide how many real levels each side already has before topping
// it up. The displayed targets are selected separately and live (see the live
// target selection), so this lag does not reach the chart.
f_currentSideOf(Pivot p) =>
    p.lastAbove ? SIDE_LOW : SIDE_HIGH

// Checks one pivot array for nearby live levels.
// Used to prevent creating duplicate / tightly overlapping pivots.
f_passInArray(float price, array<Pivot> pivots, float minSwing) =>
    bool ok = true
    int n = array.size(pivots)

    if n > 0
        for i = 0 to n - 1
            Pivot p = array.get(pivots, i)

            if not f_isRetired(p) and math.abs(p.price - price) < minSwing
                ok := false
                break

    ok

// Global duplicate filter.
// New pivots/extensions must be far enough from both high and low pivot arrays.
f_pass(float price, array<Pivot> highs, array<Pivot> lows, float minSwing) =>
    f_passInArray(price, highs, minSwing) and f_passInArray(price, lows, minSwing)

// Processes close-crosses through pivots.
//
// Only completed closes are used. Wicks do not add strikes.
// Each time the completed close moves from one side of the pivot to the other,
// the pivot receives one strike.
f_processStrikes(array<Pivot> pivots, float closeValue) =>
    int n = array.size(pivots)

    if n > 0
        for i = 0 to n - 1
            Pivot p = array.get(pivots, i)

            if not f_isRetired(p)
                bool aboveNow = closeValue > p.price
                bool belowNow = closeValue < p.price

                if (aboveNow or belowNow) and aboveNow != p.lastAbove
                    p.strikes := p.strikes + 1

                if aboveNow
                    p.lastAbove := true
                else if belowNow
                    p.lastAbove := false

// Keeps pivot arrays capped so the script remains light enough for TradingView.
//
// Retired levels are intentionally LEFT in the array (just hidden by
// f_isRetired). They occupy slots toward MAX_KEEP, which is what forces the
// oldest live levels to age out via array.pop — the mechanism that clears stale
// "used" structure and opens space ahead of an impulse. Do NOT purge retired
// levels eagerly; that defeats this aging and leaves old levels lingering.
f_trimPivots(array<Pivot> pivots) =>
    while array.size(pivots) > MAX_KEEP
        array.pop(pivots)

// ============================================================================
// Pivot detection
// ============================================================================

// Processes one pivot-detection layer.
//
// close layer:
// - Uses completed candle closes.
// - Better for tighter local structure.
//
// wick layer:
// - Uses completed candle highs/lows.
// - Better for larger rejection points and wider swing structure.
//
// A pivot confirms only after the selected lookback has completed on both sides.
f_processLayer(int lookback, bool useWick, float closeValue, int pidIn) =>
    int pidOut = pidIn

    // Candidate bar is lookback bars back from the latest stored completed bar.
    int i = array.size(procBars) - lookback - 1

    if i >= lookback
        ProcBar cand = array.get(procBars, i)

        float candHigh = useWick ? cand.h : cand.c
        float candLow = useWick ? cand.l : cand.c

        bool isHigh = true
        bool isLow = true

        // Candidate must be higher/lower than all left and right comparison bars.
        for k = 1 to lookback
            ProcBar leftBar = array.get(procBars, i - k)
            ProcBar rightBar = array.get(procBars, i + k)

            float leftHigh = useWick ? leftBar.h : leftBar.c
            float rightHigh = useWick ? rightBar.h : rightBar.c
            float leftLow = useWick ? leftBar.l : leftBar.c
            float rightLow = useWick ? rightBar.l : rightBar.c

            if leftHigh >= candHigh or rightHigh >= candHigh
                isHigh := false

            if leftLow <= candLow or rightLow <= candLow
                isLow := false

        bool passHigh = f_pass(candHigh, highPivots, lowPivots, pivotMinSwing)
        bool passLow = f_pass(candLow, highPivots, lowPivots, pivotMinSwing)

        // Add confirmed high pivot.
        if isHigh and passHigh
            pidOut := pidOut + 1

            array.unshift(
                 highPivots,
                 Pivot.new(
                     pidOut,
                     candHigh,
                     0,
                     closeValue > candHigh,
                     false
                 )
             )

            f_trimPivots(highPivots)

        // Add confirmed low pivot.
        if isLow and passLow
            pidOut := pidOut + 1

            array.unshift(
                 lowPivots,
                 Pivot.new(
                     pidOut,
                     candLow,
                     0,
                     closeValue > candLow,
                     false
                 )
             )

            f_trimPivots(lowPivots)

    pidOut

// ============================================================================
// Extension levels
// ============================================================================

// Scans one pivot array for the furthest valid real pivot on the requested side.
//
// The anchor is used to project additional synthetic target levels when there
// are not enough live targets available on that side.
//
// Extensions are counted as available levels, but do not become new anchors.
// This prevents extension levels from recursively building more extensions.
f_scanExtensionAnchor(array<Pivot> pivots, string targetSide, int sign, float anchorIn, int countIn) =>
    float anchorOut = anchorIn
    int countOut = countIn

    int n = array.size(pivots)

    if n > 0
        for i = 0 to n - 1
            Pivot p = array.get(pivots, i)

            if not f_isRetired(p) and f_currentSideOf(p) == targetSide
                countOut := countOut + 1

                // Only real pivots can act as anchors.
                // Synthetic extension levels count as levels, but do not anchor more extensions.
                if not p.isExtension
                    if na(anchorOut) or sign * p.price > sign * anchorOut
                        anchorOut := p.price

    [anchorOut, countOut]

// Adds synthetic extension targets when there are fewer than TARGET_COUNT live targets.
//
// Normal behaviour:
// - Use the furthest valid real pivot as the anchor.
//
// ATH / ATL fallback:
// - If no real pivot anchor exists on that side, use current price as the seed.
// - This ensures the script still plots useful targets when price trades beyond
//   all known structure.
f_processExtensionSide(bool highSide, float closeValue, float atrValue, int pidIn) =>
    int pidOut = pidIn

    string targetSide = highSide ? SIDE_HIGH : SIDE_LOW
    int sign = highSide ? 1 : -1

    float anchor = na
    int count = 0

    [anchorAfterHighs, countAfterHighs] = f_scanExtensionAnchor(highPivots, targetSide, sign, anchor, count)
    [anchorAfterLows, countAfterLows] = f_scanExtensionAnchor(lowPivots, targetSide, sign, anchorAfterHighs, countAfterHighs)

    anchor := anchorAfterLows
    count := countAfterLows

    // ATH / ATL fallback.
    // If price has cleared all known pivots on this side, seed extensions from price.
    bool usingSyntheticSeed = na(anchor)

    if usingSyntheticSeed
        anchor := closeValue
        count := 0

    float step = math.max(nz(atrValue), EXT_STEP_FLOOR_PTS)

    // Try enough attempts to fill the side even if minSwing rejects nearby candidates.
    // Exit as soon as the side is full — on a steady-state bar the side is already
    // full of live targets, so this breaks on the first iteration instead of
    // grinding all 60 attempts every bar.
    for k = 1 to 60
        if count >= TARGET_COUNT
            break

        float extensionPrice = anchor + sign * step * k

        if f_pass(extensionPrice, highPivots, lowPivots, pivotMinSwing)
            pidOut := pidOut + 1

            Pivot entry = Pivot.new(
                 pidOut,
                 extensionPrice,
                 0,
                 closeValue > extensionPrice,
                 true
             )

            if highSide
                array.unshift(highPivots, entry)
                f_trimPivots(highPivots)
            else
                array.unshift(lowPivots, entry)
                f_trimPivots(lowPivots)

            count := count + 1

    pidOut

// ============================================================================
// Target selection (live, distance-sorted nearest-N above/below price)
// ============================================================================

// Inserts (id, price, dist) into a distance-sorted top-TARGET_COUNT list.
//
// Side-agnostic: the caller has already decided which side's buffers to pass.
// Strict `<` insertion preserves first-seen order on ties, matching the original
// build order (high pivots scanned before low pivots).
f_insertSorted(int id, float price, float dist, array<int> ids, array<float> prices, array<float> dists) =>
    bool inserted = false

    int n = array.size(dists)

    if n > 0
        for i = 0 to n - 1
            if not inserted and dist < array.get(dists, i)
                array.insert(ids, i, id)
                array.insert(prices, i, price)
                array.insert(dists, i, dist)
                inserted := true

    if not inserted
        array.push(ids, id)
        array.push(prices, price)
        array.push(dists, dist)

    while array.size(dists) > TARGET_COUNT
        array.pop(ids)
        array.pop(prices)
        array.pop(dists)

// Pads a side's nearest-first price list up to TARGET_COUNT with synthetic,
// display-only levels. Projects from the furthest real level already present
// (or from price if the side is empty) outward by `step` so the new levels stay
// in distance order. sign = +1 projects up (above price), -1 projects down.
f_fillSide(array<float> prices, float refPrice, int sign, float step) =>
    int have = array.size(prices)

    if have < TARGET_COUNT
        float base = have > 0 ? array.get(prices, have - 1) : refPrice
        float s = math.max(nz(step), EXT_STEP_FLOOR_PTS)

        for k = 1 to TARGET_COUNT - have
            array.push(prices, base + sign * s * k)

// Routes one live pivot into the above/below buffer by its position relative to
// LIVE price (distance-sorted, nearest-first, capped at TARGET_COUNT). This is
// the display selection: a level above price is a resistance target, below is a
// support target, decided by current price with no lag.
f_routeRelevant(Pivot p, float refPrice) =>
    if not f_isRetired(p)
        float dist = math.abs(p.price - refPrice)

        if p.price > refPrice
            f_insertSorted(p.id, p.price, dist, relAboveIds, relAbovePrices, relAboveDists)
        else
            f_insertSorted(p.id, p.price, dist, relBelowIds, relBelowPrices, relBelowDists)

// Builds BOTH sides' nearest-target lists in a single pass over the pivot arrays,
// relative to LIVE price. relAbove* = nearest levels above price, relBelow* =
// nearest below. Scanned once per call total rather than once per side.
f_buildRelevantBothSides(float refPrice) =>
    array.clear(relAboveIds)
    array.clear(relAbovePrices)
    array.clear(relAboveDists)
    array.clear(relBelowIds)
    array.clear(relBelowPrices)
    array.clear(relBelowDists)

    int nh = array.size(highPivots)

    if nh > 0
        for i = 0 to nh - 1
            f_routeRelevant(array.get(highPivots, i), refPrice)

    int nl = array.size(lowPivots)

    if nl > 0
        for i = 0 to nl - 1
            f_routeRelevant(array.get(lowPivots, i), refPrice)

    // Guarantee exactly TARGET_COUNT targets per side: if the universe is
    // momentarily short on a side (e.g. a fast intrabar push at ATH cleared the
    // overhead levels), project synthetic display-only levels stepped beyond the
    // furthest real one (or from price itself if the side is empty). These are
    // NOT added to the pivot universe — purely to keep the map balanced live.
    f_fillSide(relAbovePrices, refPrice, 1, lastStep)
    f_fillSide(relBelowPrices, refPrice, -1, lastStep)

// Returns the nearest-first price at `index` from a selection buffer, or na.
f_targetPrice(array<float> prices, int index) =>
    array.size(prices) > index ? array.get(prices, index) : na

// ============================================================================
// ATR helper
// ============================================================================

// Calculates a simple average of the most recent true range values.
// Used for extension spacing only.
f_avgTr(array<float> values) =>
    int n = array.size(values)
    int k = math.min(14, n)

    float total = 0.0

    if k > 0
        for i = n - k to n - 1
            total := total + array.get(values, i)

    k > 0 ? total / k : 0.0

// ============================================================================
// EMA34 visual guide
// ============================================================================

// EMA34 is plotted as a directional reference only.
// The pivot target engine does not depend on EMA calculations.
float ema34 = ta.ema(close, 34)

// ============================================================================
// Bar-finalized processing
// ============================================================================

// Main engine runs once per newly opened bar using the previous completed bar.
//
// This keeps pivot confirmation, strikes, ATR history and slot changes based on
// completed candle data rather than unstable live-bar movement.
if barstate.isnew and bar_index > 0
    float previousTr = bar_index > 1
         ? math.max(
             high[1] - low[1],
             math.max(
                 math.abs(high[1] - close[2]),
                 math.abs(low[1] - close[2])
             )
         )
         : high[1] - low[1]

    array.push(trHistory, previousTr)

    if array.size(trHistory) > 50
        array.shift(trHistory)

    float atr14 = f_avgTr(trHistory)

    // Persist the extension step for live synthetic-fill projection.
    lastStep := math.max(nz(atr14), EXT_STEP_FLOOR_PTS)

    // Update strike state using the previous completed close.
    f_processStrikes(highPivots, close[1])
    f_processStrikes(lowPivots, close[1])

    // Store previous completed bar for pivot detection.
    array.push(procBars, ProcBar.new(close[1], high[1], low[1]))

    int maxLookback = math.max(pivotLookback, pivotWideLookback)

    while array.size(procBars) > maxLookback * 2 + 60
        array.shift(procBars)

    // Detect close-based local pivots and wick-based wider pivots.
    pid := f_processLayer(pivotLookback, false, close[1], pid)
    pid := f_processLayer(pivotWideLookback, true, close[1], pid)

    // Add projected extension levels if each side has fewer than TARGET_COUNT live targets.
    pid := f_processExtensionSide(true, close[1], atr14, pid)
    pid := f_processExtensionSide(false, close[1], atr14, pid)

// ============================================================================
// Live target selection
// ============================================================================

// Runs every bar/tick (NOT gated to bar open) so the displayed targets stay
// balanced around LIVE price: the nearest TARGET_COUNT levels above price and
// the nearest TARGET_COUNT below, padded with synthetic projections if a side is
// momentarily short. This is what guarantees "5 above + 5 below at all times".
f_buildRelevantBothSides(close)

float pivotH1 = f_targetPrice(relAbovePrices, 0)
float pivotH2 = f_targetPrice(relAbovePrices, 1)
float pivotH3 = f_targetPrice(relAbovePrices, 2)
float pivotH4 = f_targetPrice(relAbovePrices, 3)
float pivotH5 = f_targetPrice(relAbovePrices, 4)

float pivotL1 = f_targetPrice(relBelowPrices, 0)
float pivotL2 = f_targetPrice(relBelowPrices, 1)
float pivotL3 = f_targetPrice(relBelowPrices, 2)
float pivotL4 = f_targetPrice(relBelowPrices, 3)
float pivotL5 = f_targetPrice(relBelowPrices, 4)

// Break the plotted line for one bar when a target level changes.
// This avoids visually connecting unrelated target levels.
float plotH1 = not na(pivotH1) and not na(pivotH1[1]) and pivotH1 != pivotH1[1] ? na : pivotH1
float plotH2 = not na(pivotH2) and not na(pivotH2[1]) and pivotH2 != pivotH2[1] ? na : pivotH2
float plotH3 = not na(pivotH3) and not na(pivotH3[1]) and pivotH3 != pivotH3[1] ? na : pivotH3
float plotH4 = not na(pivotH4) and not na(pivotH4[1]) and pivotH4 != pivotH4[1] ? na : pivotH4
float plotH5 = not na(pivotH5) and not na(pivotH5[1]) and pivotH5 != pivotH5[1] ? na : pivotH5

float plotL1 = not na(pivotL1) and not na(pivotL1[1]) and pivotL1 != pivotL1[1] ? na : pivotL1
float plotL2 = not na(pivotL2) and not na(pivotL2[1]) and pivotL2 != pivotL2[1] ? na : pivotL2
float plotL3 = not na(pivotL3) and not na(pivotL3[1]) and pivotL3 != pivotL3[1] ? na : pivotL3
float plotL4 = not na(pivotL4) and not na(pivotL4[1]) and pivotL4 != pivotL4[1] ? na : pivotL4
float plotL5 = not na(pivotL5) and not na(pivotL5[1]) and pivotL5 != pivotL5[1] ? na : pivotL5

// ============================================================================
// Plots
// ============================================================================

// Selection is structural: H targets are always above live price, L targets
// always below — so static colors are correct by construction, no live recolor
// needed. Above = resistance (blue), below = support (salmon).
const color COLOR_RESISTANCE = #5ab8ff
const color COLOR_SUPPORT = #ff8b73

plot(ema34, "EMA34", color=#ffb000, linewidth=2)

plot(plotH1, "Pivot H1", color=COLOR_RESISTANCE, linewidth=1, style=plot.style_linebr)
plot(plotH2, "Pivot H2", color=COLOR_RESISTANCE, linewidth=1, style=plot.style_linebr)
plot(plotH3, "Pivot H3", color=COLOR_RESISTANCE, linewidth=1, style=plot.style_linebr)
plot(plotH4, "Pivot H4", color=COLOR_RESISTANCE, linewidth=1, style=plot.style_linebr)
plot(plotH5, "Pivot H5", color=COLOR_RESISTANCE, linewidth=1, style=plot.style_linebr)

plot(plotL1, "Pivot L1", color=COLOR_SUPPORT, linewidth=1, style=plot.style_linebr)
plot(plotL2, "Pivot L2", color=COLOR_SUPPORT, linewidth=1, style=plot.style_linebr)
plot(plotL3, "Pivot L3", color=COLOR_SUPPORT, linewidth=1, style=plot.style_linebr)
plot(plotL4, "Pivot L4", color=COLOR_SUPPORT, linewidth=1, style=plot.style_linebr)
plot(plotL5, "Pivot L5", color=COLOR_SUPPORT, linewidth=1, style=plot.style_linebr)
````
