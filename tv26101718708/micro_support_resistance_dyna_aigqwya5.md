# Micro Support Resistance [DYNA]

- url: https://www.tradingview.com/script/AigQwyA5-Micro-Support-Resistance-DYNA/
- type: indicator
- pine_id: PUB;2f8676c9473045cc926ee3a8858c0ae5
- version: 1.0

## Description

Micro Support Resistance automatically identifies the most important short-term support and resistance levels on your chart. It finds swing highs and swing lows, clusters nearby price reactions together, and draws clean horizontal lines where price is most likely to react next.

Most traders draw support and resistance by hand, which is slow and subjective. This indicator does it for you in real time, updating as new pivots form. It also shows you which levels are strongest -- thicker lines mean more touches, so you can instantly tell the difference between a fresh untested level and a well-established zone that price has bounced off multiple times. When price breaks through a level, the indicator automatically removes it so only active, relevant zones remain on your chart.


[b]Key Features[/b]

[list]
[*] [b]Automatic Pivot Detection[/b] -- Identifies swing highs and swing lows using a configurable lookback window, so levels are always based on actual price structure
[*] [b]Smart Clustering[/b] -- Merges nearby levels within an ATR-based threshold into a single zone, avoiding cluttered charts with redundant lines
[*] [b]Touch Count Visualization[/b] -- Line thickness grows with each touch, giving you an instant read on level strength without any interpretation
[*] [b]Automatic Level Invalidation[/b] -- When price closes through a support or resistance level, it is removed from the chart. No stale or broken levels cluttering your view
[*] [b]Distance-Based Decay[/b] -- Levels that drift too far from current price automatically lose touches and eventually disappear, keeping all level slots focused on actionable zones near price
[*] [b]Dynamic Level Management[/b] -- Keeps only the strongest levels on screen. When new pivots form, weak untested levels are replaced automatically
[*] [b]First-Approach Alerts[/b] -- Get notified the moment price first reaches a key level, not on every bar it stays nearby
[*] [b]Data Export[/b] -- All level values appear in the TradingView data window and are included in CSV exports for further analysis
[/list]


[b]How It Works[/b]

As price moves across your chart, the indicator continuously scans for swing highs and swing lows on confirmed bars. When it detects a confirmed pivot -- a point where price reversed direction with bars on both sides confirming the swing -- it checks whether this level is near any existing support or resistance zone. If it is, the existing level absorbs the new touch and its line gets thicker. If not, a new level is drawn. When price closes through a level decisively, that level is automatically invalidated and removed.

Green lines mark support zones where price has bounced upward. Red lines mark resistance zones where price has been rejected downward. Each line carries a small label showing its level number and touch count -- for example, "S1 (3)" is the first support level with three touches, and "R2 (1)" is the second resistance level with a single touch. Thicker lines correspond to higher touch counts, so a bold line with "S1 (4)" is a well-tested support, while a thin line with "R3 (1)" is a fresh, untested resistance. If a green line disappears, it means price closed below that support and the level is no longer valid.

[image]https://www.tradingview.com/x/PfyMYnPe/[/image]
[i]Micro Support Resistance on a 3-minute chart. Green support lines and red resistance lines are drawn automatically, with thicker lines indicating more touches.[/i]


[b]Line Thickness and Level Strength[/b]

The visual weight of each line tells you how significant the level is. One touch produces a thin hairline. Two touches make it slightly thicker. Three or four touches produce a bold, unmistakable line that commands attention. This means you never need to count bounces or remember which levels have been tested -- the chart shows you directly.

When the maximum number of levels is reached on either side (support or resistance), the indicator automatically removes the weakest level to make room for a new one. Levels that have been broken through -- where price has closed on the other side -- are also removed automatically. This keeps your chart clean and focused on the levels that actually matter right now.

[image]https://www.tradingview.com/x/uDb3JOda/[/image]
[i]Notice the difference in line thickness: S2 (3) is a thick, well-tested support, while R1 (1) is a thin single-touch resistance.[/i]


[b]Settings[/b]

The default settings work well for most intraday charts on the 1-minute to 15-minute timeframe. The Pivot Lookback controls how many bars on each side are required to confirm a swing -- the default of 5 captures short-term micro-structure. Increase it to 7 or 10 for slightly broader levels on 30-minute or 1-hour charts.

The Cluster Threshold determines how close two levels need to be before they are merged into one. It uses a multiple of the 14-period ATR, so it automatically adapts to different instruments and volatility conditions. The default of 0.5 provides a good balance between merging nearby levels and keeping distinct zones separate. Lower it if you want finer granularity; raise it if you see too many lines stacked close together.

Max Levels Per Side caps how many support and resistance lines appear at once. The default of 3 keeps the chart clean. You can increase it up to 10 if you want to see more of the price structure.

The Decay Distance setting controls how far a level can be from price before it starts losing relevance. Levels beyond this ATR multiple lose one touch per confirmed bar. Once a level's touches reach zero, it is removed and the slot opens up for a fresh nearby level. The default of 10x ATR keeps levels focused on the current trading range while ensuring slots stay populated. Increase it if you want levels to persist longer on swing or position trades.


[b]Alerts[/b]

[list]
[*] [b]Approaching Support[/b] -- Fires once when price first comes within a configurable percentage of a support level. Does not repeat while price remains in the approach zone. [i]"Micro Support Resistance [DYNA]: Price is approaching a support level. Watch for a potential bounce or breakdown."[/i]
[*] [b]Approaching Resistance[/b] -- Fires once when price first comes within a configurable percentage of a resistance level. Does not repeat while price remains in the approach zone. [i]"Micro Support Resistance [DYNA]: Price is approaching a resistance level. Watch for a potential rejection or breakout."[/i]
[/list]

To set up alerts: click the TradingView Alerts button, select "Micro Support Resistance [DYNA]" from the indicator dropdown, choose "Any alert() function call" as the condition, and set your preferred notification method.


[b]Best Practices[/b]

[list]
[*] Use on lower timeframes (1m to 15m) for scalping and intraday setups. The levels are designed to capture micro-structure, not weekly zones.
[*] Pay attention to thick lines -- levels with 3 or more touches tend to produce stronger reactions when retested.
[*] Combine with a momentum or volume indicator to judge whether a level will hold or break.
[*] If your chart looks too busy, reduce Max Levels Per Side or increase the Cluster Threshold to merge nearby zones.
[*] Set approach alerts so you can step away from the screen and still catch the moments that matter.
[/list]


[b]Part of the DYNA Ecosystem[/b]

Micro Support Resistance is a free indicator built with the same design standards as the DYNA premium suite. For complete trade management with automatic stop loss, break-even, trailing stops, and multi-target systems, explore the full DYNA indicator collection.


[b]Disclaimer[/b]

This indicator is a technical analysis and educational tool only -- it is not financial advice and makes no guarantee of any outcome. Past performance does not predict future results. Always do your own research and use proper position sizing and risk management.


[i]Created by Varun Nidhi · [url=https://varunnidhi.com]varunnidhi.com[/url]
A free DYNA indicator — self-contained, no repainting.[/i]

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
// Micro Support Resistance [DYNA]
// Auto-detects short-term support and resistance levels from recent pivot
// highs and lows. Clusters nearby levels and draws the strongest ones with
// line thickness proportional to the number of touches.
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Micro Support Resistance [DYNA]", shorttitle = "MicroSR [DYNA]", overlay = true, max_labels_count = 500, max_lines_count = 500)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 1: COLOR PALETTE
// ══════════════════════════════════════════════════════════════════════════════

color BULL_COLOR    = #26a69a
color BEAR_COLOR    = #ef5350
color NEUTRAL_COLOR = #787b86
color WARNING_COLOR = #ff9800

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 2: INPUTS
// ══════════════════════════════════════════════════════════════════════════════

// --- Core Settings ---
string GRP_CORE = "Core Settings"
int    i_pivotLookback    = input.int(5,   "Pivot Lookback",              minval = 1,   maxval = 20,   group = GRP_CORE, tooltip = "Number of bars to the left and right used to detect swing highs and lows.")
float  i_clusterThreshold = input.float(0.5, "Cluster Threshold (ATR x)", minval = 0.01, maxval = 2.0, step = 0.01, group = GRP_CORE, tooltip = "Levels within this multiple of ATR(14) are merged into one cluster.")
int    i_maxLevels        = input.int(3,   "Max Levels Per Side",         minval = 1,   maxval = 10,   group = GRP_CORE, tooltip = "Maximum number of support and resistance levels to display.")
float  i_approachPct      = input.float(0.2, "Approach Alert % Distance", minval = 0.05, maxval = 1.0, step = 0.05, group = GRP_CORE, tooltip = "Price is considered 'approaching' a level when within this percentage distance.")
float  i_decayDist        = input.float(10.0, "Decay Distance (ATR x)",  minval = 1.0,  maxval = 20.0, step = 0.5,  group = GRP_CORE, tooltip = "Levels farther than this ATR multiple from price lose one touch per bar. Keeps levels relevant to current price action.")

// --- Visual ---
string GRP_VIS = "Visual"
bool   i_showSupport    = input.bool(true, "Show Support Levels",    group = GRP_VIS, tooltip = "Draw support level lines on the chart.")
bool   i_showResistance = input.bool(true, "Show Resistance Levels", group = GRP_VIS, tooltip = "Draw resistance level lines on the chart.")
bool   i_showLabels     = input.bool(true, "Show Level Labels",      group = GRP_VIS, tooltip = "Show touch-count labels next to each level line.")

// --- Alerts ---
string GRP_ALERT = "Alerts"
bool   i_alertSupport    = input.bool(true, "Alert: Approaching Support",    group = GRP_ALERT, tooltip = "Enable alert when price first approaches a support level.")
bool   i_alertResistance = input.bool(true, "Alert: Approaching Resistance", group = GRP_ALERT, tooltip = "Enable alert when price first approaches a resistance level.")

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3: CORE LOGIC
// ══════════════════════════════════════════════════════════════════════════════

// --- ATR for clustering distance ---
float atrVal = ta.atr(14)
float clusterDist = nz(atrVal) == 0 ? 0.0001 : i_clusterThreshold * atrVal

// --- Persistent level storage ---
var array<float> supportLevels    = array.new_float()
var array<int>   supportTouches   = array.new_int()
var array<float> resistanceLevels = array.new_float()
var array<int>   resistanceTouches = array.new_int()

// --- Persistent alert state (for first-approach detection) ---
var bool wasApproachingSupport    = false
var bool wasApproachingResistance = false

// --- Persistent line & label storage ---
var array<line>  supportLines     = array.new_line()
var array<line>  resistanceLines  = array.new_line()
var array<label> supportLabels    = array.new_label()
var array<label> resistanceLabels = array.new_label()

// --- Pivot detection ---
float pivHigh = ta.pivothigh(high, i_pivotLookback, i_pivotLookback)
float pivLow  = ta.pivotlow(low,   i_pivotLookback, i_pivotLookback)

// --- Helper: add or cluster a level into an array pair ---
// Returns true if arrays were modified
addOrCluster(array<float> levels, array<int> touches, float newLevel, float dist, int maxLvl) =>
    bool clustered = false
    // Check existing levels for a cluster match
    if array.size(levels) > 0
        for i = 0 to array.size(levels) - 1
            float existing = array.get(levels, i)
            if math.abs(existing - newLevel) <= dist
                // Merge: update level to weighted average, increment touches
                int t = array.get(touches, i)
                float avgLevel = (existing * t + newLevel) / (t + 1)
                array.set(levels, i, avgLevel)
                array.set(touches, i, t + 1)
                clustered := true
                break
    // If no cluster match, add as new level
    if not clustered
        if array.size(levels) < maxLvl
            array.push(levels, newLevel)
            array.push(touches, 1)
        else
            // Replace the level with the fewest touches
            int minTouches = array.min(touches)
            int minIdx = array.indexof(touches, minTouches)
            if minIdx >= 0
                array.set(levels, minIdx, newLevel)
                array.set(touches, minIdx, 1)
    true

// --- Helper: remove levels that price has decisively broken through ---
invalidateBrokenLevels(array<float> levels, array<int> touches, float priceRef, bool isSupport) =>
    if array.size(levels) > 0
        for i = array.size(levels) - 1 to 0
            float lvl = array.get(levels, i)
            bool broken = isSupport ? priceRef < lvl : priceRef > lvl
            if broken
                array.remove(levels, i)
                array.remove(touches, i)
    true

// --- Helper: decay touch counts for levels too far from current price ---
decayStaleLevels(array<float> levels, array<int> touches, float priceRef, float atr, float decayMult) =>
    float decayThreshold = decayMult * math.max(atr, syminfo.mintick)
    if array.size(levels) > 0
        for i = array.size(levels) - 1 to 0
            float lvl = array.get(levels, i)
            if math.abs(priceRef - lvl) > decayThreshold
                int t = array.get(touches, i) - 1
                if t <= 0
                    array.remove(levels, i)
                    array.remove(touches, i)
                else
                    array.set(touches, i, t)
    true

// --- Process pivots, invalidate, and decay (confirmed bars only) ---
if barstate.isconfirmed
    // Add new resistance pivot (swing high)
    if not na(pivHigh)
        addOrCluster(resistanceLevels, resistanceTouches, pivHigh, clusterDist, i_maxLevels)
    // Add new support pivot (swing low)
    if not na(pivLow)
        addOrCluster(supportLevels, supportTouches, pivLow, clusterDist, i_maxLevels)
    // Remove levels that price has closed through
    invalidateBrokenLevels(supportLevels, supportTouches, close, true)
    invalidateBrokenLevels(resistanceLevels, resistanceTouches, close, false)
    // Decay distant levels: reduce touch count by 1 per bar if too far from price
    decayStaleLevels(supportLevels, supportTouches, close, atrVal, i_decayDist)
    decayStaleLevels(resistanceLevels, resistanceTouches, close, atrVal, i_decayDist)

// --- Alert proximity detection (uses confirmed bar to avoid repainting) ---
bool approachingSupport    = false
bool approachingResistance = false

float approachFrac = i_approachPct / 100.0

if array.size(supportLevels) > 0
    for i = 0 to array.size(supportLevels) - 1
        float lvl = array.get(supportLevels, i)
        if lvl > 0
            if math.abs(close[1] - lvl) / lvl < approachFrac
                approachingSupport := true
                break

if array.size(resistanceLevels) > 0
    for i = 0 to array.size(resistanceLevels) - 1
        float lvl = array.get(resistanceLevels, i)
        if lvl > 0
            if math.abs(close[1] - lvl) / lvl < approachFrac
                approachingResistance := true
                break

// --- Detect first-approach transitions (alert only on new approach, not continuous) ---
bool supportTransition    = approachingSupport and not wasApproachingSupport
bool resistanceTransition = approachingResistance and not wasApproachingResistance

if barstate.isconfirmed
    wasApproachingSupport    := approachingSupport
    wasApproachingResistance := approachingResistance

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4: VISUAL LAYER
// ══════════════════════════════════════════════════════════════════════════════

// --- Clear previous lines and labels ---
if array.size(supportLines) > 0
    for i = 0 to array.size(supportLines) - 1
        line.delete(array.get(supportLines, i))
    array.clear(supportLines)

if array.size(resistanceLines) > 0
    for i = 0 to array.size(resistanceLines) - 1
        line.delete(array.get(resistanceLines, i))
    array.clear(resistanceLines)

if array.size(supportLabels) > 0
    for i = 0 to array.size(supportLabels) - 1
        label.delete(array.get(supportLabels, i))
    array.clear(supportLabels)

if array.size(resistanceLabels) > 0
    for i = 0 to array.size(resistanceLabels) - 1
        label.delete(array.get(resistanceLabels, i))
    array.clear(resistanceLabels)

// --- Draw support levels ---
if i_showSupport and array.size(supportLevels) > 0
    for i = 0 to array.size(supportLevels) - 1
        float lvl    = array.get(supportLevels, i)
        int   tCount = array.get(supportTouches, i)
        int   w      = math.min(tCount, 4)
        line  l      = line.new(bar_index - 20, lvl, bar_index + 50, lvl, color = BULL_COLOR, width = w, style = line.style_solid)
        array.push(supportLines, l)
        if i_showLabels
            label lb = label.new(bar_index + 52, lvl, "S" + str.tostring(i + 1) + " (" + str.tostring(tCount) + ")", color = color.new(BULL_COLOR, 80), textcolor = BULL_COLOR, style = label.style_label_left, size = size.small)
            array.push(supportLabels, lb)

// --- Draw resistance levels ---
if i_showResistance and array.size(resistanceLevels) > 0
    for i = 0 to array.size(resistanceLevels) - 1
        float lvl    = array.get(resistanceLevels, i)
        int   tCount = array.get(resistanceTouches, i)
        int   w      = math.min(tCount, 4)
        line  l      = line.new(bar_index - 20, lvl, bar_index + 50, lvl, color = BEAR_COLOR, width = w, style = line.style_solid)
        array.push(resistanceLines, l)
        if i_showLabels
            label lb = label.new(bar_index + 52, lvl, "R" + str.tostring(i + 1) + " (" + str.tostring(tCount) + ")", color = color.new(BEAR_COLOR, 80), textcolor = BEAR_COLOR, style = label.style_label_left, size = size.small)
            array.push(resistanceLabels, lb)

// --- Export level values via plot (visible in data window & CSV export) ---
safeGet(array<float> arr, int idx) =>
    idx < array.size(arr) ? array.get(arr, idx) : na

plot(safeGet(supportLevels, 0), "Support 1",    BULL_COLOR, display = display.data_window)
plot(safeGet(supportLevels, 1), "Support 2",    BULL_COLOR, display = display.data_window)
plot(safeGet(supportLevels, 2), "Support 3",    BULL_COLOR, display = display.data_window)
plot(safeGet(supportLevels, 3), "Support 4",    BULL_COLOR, display = display.data_window)
plot(safeGet(supportLevels, 4), "Support 5",    BULL_COLOR, display = display.data_window)
plot(safeGet(supportLevels, 5), "Support 6",    BULL_COLOR, display = display.data_window)
plot(safeGet(supportLevels, 6), "Support 7",    BULL_COLOR, display = display.data_window)
plot(safeGet(supportLevels, 7), "Support 8",    BULL_COLOR, display = display.data_window)
plot(safeGet(supportLevels, 8), "Support 9",    BULL_COLOR, display = display.data_window)
plot(safeGet(supportLevels, 9), "Support 10",   BULL_COLOR, display = display.data_window)

plot(safeGet(resistanceLevels, 0), "Resistance 1",  BEAR_COLOR, display = display.data_window)
plot(safeGet(resistanceLevels, 1), "Resistance 2",  BEAR_COLOR, display = display.data_window)
plot(safeGet(resistanceLevels, 2), "Resistance 3",  BEAR_COLOR, display = display.data_window)
plot(safeGet(resistanceLevels, 3), "Resistance 4",  BEAR_COLOR, display = display.data_window)
plot(safeGet(resistanceLevels, 4), "Resistance 5",  BEAR_COLOR, display = display.data_window)
plot(safeGet(resistanceLevels, 5), "Resistance 6",  BEAR_COLOR, display = display.data_window)
plot(safeGet(resistanceLevels, 6), "Resistance 7",  BEAR_COLOR, display = display.data_window)
plot(safeGet(resistanceLevels, 7), "Resistance 8",  BEAR_COLOR, display = display.data_window)
plot(safeGet(resistanceLevels, 8), "Resistance 9",  BEAR_COLOR, display = display.data_window)
plot(safeGet(resistanceLevels, 9), "Resistance 10", BEAR_COLOR, display = display.data_window)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5: ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(supportTransition and i_alertSupport, title = "Approaching Support", message = "Micro Support Resistance [DYNA]: Price is approaching a support level. Watch for a potential bounce or breakdown.")
alertcondition(resistanceTransition and i_alertResistance, title = "Approaching Resistance", message = "Micro Support Resistance [DYNA]: Price is approaching a resistance level. Watch for a potential rejection or breakout.")
````
