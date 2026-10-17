# [SkuldX] SFP + Auto S&R

- url: https://www.tradingview.com/script/yq3t7f79-SkuldX-SFP-Auto-S-R/
- type: indicator
- pine_id: PUB;056e825c35034a6fad6f0b6caa19b6f4
- version: 1.0

## Description

SkuldX SFP + Auto S&R — Institutional Liquidity Sweep at Validated Structure
by SkuldX Trading Systems

[b]What is it?[/b]
SkuldX SFP + Auto S&R combines two powerful concepts into a single indicator. It automatically identifies significant support and resistance levels by clustering historical pivot points — and then monitors those levels exclusively for Swing Failure Pattern events. The result is a significantly higher quality signal filter compared to standard SFP detection: every sweep you see on the chart is happening at a price level where the market has already demonstrated structural significance multiple times.

[b]The problem with standard SFP detection[/b]
A basic SFP indicator sweeps any local high or low regardless of whether that level has any structural importance. This generates many signals at noise levels that institutions have no reason to target. The most powerful SFP setups occur specifically at levels where liquidity has accumulated over time — where stop orders from multiple previous reactions are clustered and waiting to be harvested.
SkuldX SFP + Auto S&R solves this by only triggering when a sweep occurs at an automatically validated S&R cluster.

[b]How the S&R engine works[/b]
The indicator scans the configured history window and identifies all pivot highs and lows — price points where the market reversed direction with enough significance to form a clear swing. These pivots are then grouped into clusters: any two pivots within the cluster tolerance percentage of each other are merged into a single level, and their average price becomes the cluster center.
Each cluster is assigned a touch count — the total number of times price has visited that zone across both pivot formations and raw bar touches. Clusters that meet the minimum touch threshold become validated S&R levels and are drawn on the chart as horizontal lines.
The levels are sorted by touch count and only the strongest ones up to your configured maximum are shown. A label at the right edge of each line displays the price and touch count in brackets — for example 2415.50  [5T] means that level has been touched five times and carries significant institutional memory.

[b]How the SFP detection works[/b]
On every bar the indicator identifies the nearest validated S&R level above price and the nearest validated S&R level below price. It then checks whether the current candle has swept through either of those levels while closing back inside them.
Bearish SFP fires when the candle wick extends above the nearest S&R resistance level but the candle closes below it. The upper wick must meet the minimum size threshold as a percentage of the total candle range, and the breach above the level must meet the minimum breach threshold. Both conditions together ensure the sweep was meaningful rather than a minor tick-through.
Bullish SFP fires when the candle wick extends below the nearest S&R support level but the candle closes above it, with the lower wick and breach both meeting their minimum thresholds.

[b]What you see on the chart[/b]
Grey lines — validated S&R levels with touch count labels. These are your structural reference zones. The more touches a level shows, the more liquidity has accumulated there and the more significant a sweep of that level becomes.
SFP label — appears above or below the candle at the moment of detection. Shows the signal direction, the price of the swept level, and its touch count. Higher touch count at the swept level means higher probability of a sustained reversal.
Rejection zone (box) — shaded area between the wick extreme and the S&R level. This is the precise zone where stop orders were triggered and institutional positions were likely built. The zone extends to the right for a configurable number of bars.
Dashed line — marks the specific S&R level that was swept, making it easy to track which structural zone triggered the signal.

[b]Settings reference[/b]
S&R Detection group
Pivot Lookback — how many bars on each side a pivot must be the extreme to qualify. Higher values find more significant swing points but confirm later. Default 10.
Cluster Tolerance % — maximum distance between two pivots to be grouped into the same cluster. Default 0.3%. Increase for volatile instruments where price rarely touches the exact same price twice.
Min Touches for Valid Level — minimum touch count required for a cluster to be drawn and used for SFP detection. Default 2. Increase to 3 or 4 for stricter structural requirements.
Max Levels to Show — limits the number of S&R lines displayed. The strongest levels by touch count are always shown first.
S&R History Lookback — how many bars of history to scan for pivots. Default 300. Increase for higher timeframes where significant levels form slowly.

SFP Filters group
Min Wick Size % of candle — the rejection wick must be at least this percentage of the total candle range. Prevents weak rejections from triggering signals.
Min Breach Size % of level — the wick must extend at least this percentage beyond the S&R level. Ensures the sweep was meaningful enough to trigger stop orders.
Show Bullish / Bearish SFP — independent toggles for each direction.

SFP Display group
Show Labels — toggles signal labels
Show Rejection Zone — toggles the sweep zone box
Zone Extend — how many bars right the zone and line extend
Label Size / Zone Transparency / Line Width — visual customization
Bullish / Bearish Color — independent colors for each direction

[b]How to use it in practice[/b]
Reading the levels — scan the grey S&R lines before any signal appears. Levels with 4+ touches are the most significant targets. These are where institutions are most likely to engineer a sweep. When price approaches one of these levels, heighten your attention.
Reading the signal — when an SFP fires, check the touch count in the label. A sweep at a 2-touch level is interesting. A sweep at a 6-touch level is significant. The touch count is the single most important quality indicator for the setup.
Entry timing — the signal fires on candle close. The most direct entry is at the open of the next candle in the reversal direction. A more conservative approach waits for the following candle to confirm continuation before entering.
Stop placement — place the stop-loss beyond the wick tip, outside the rejection zone. The zone itself tells you where institutional positioning occurred — price returning beyond that zone invalidates the entire setup premise.
Take-profit targets — use the next S&R level in the direction of the trade as the primary target. The indicator shows you all significant levels simultaneously, making it straightforward to identify the next structural obstacle.
Calibrating for your instrument — start with default settings and observe whether signals appear at levels that look structurally significant to you visually. If too many signals appear at noise levels, increase Min Touches to 3 or raise the wick and breach thresholds. If signals are too rare, reduce Pivot Lookback or increase Cluster Tolerance.
Timeframe guidance — on 15m the lookback of 300 bars covers approximately 75 hours. On 1h it covers 12.5 days. Adjust S&R History Lookback proportionally to ensure the indicator scans enough price history to build meaningful clusters.
Part of the SkuldX Suite

SkuldX SFP + Auto S&R is designed to work alongside the full SkuldX indicator suite. The most reliable setups emerge when multiple layers of context align:
[list]
[*]A bullish SFP at a 4+ touch S&R level that coincides with the Asian Low from SkuldX Sessions carries double structural significance — both the automated cluster and the session boundary agree on the level
[*]A bearish SFP at a high-touch resistance zone with ADR Used % above 85% from SkuldX ADR Levels signals both a liquidity sweep and statistical range exhaustion simultaneously
[*]An SFP confirmed by a Bullish or Bearish Trend reading in SkuldX OI Delta — new positions opening in the reversal direction — adds institutional conviction that the sweep was deliberate rather than random
[*]The touch count shown in the SFP label directly complements the Touch Counter module in SkuldX Level Patterns, providing consistent structural analysis across both manual and automated level detection
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © skuldxtrade

//@version=6
indicator("[SkuldX] SFP + Auto S&R", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)


// ══════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════

pivotLen     = input.int(10,    "Pivot Lookback (bars each side)", group = "S&R Detection", minval = 3,   maxval = 50)
clusterPct   = input.float(0.3, "Cluster Tolerance %",            group = "S&R Detection", minval = 0.05, maxval = 2.0, step = 0.05)
minTouches   = input.int(2,     "Min Touches for Valid Level",     group = "S&R Detection", minval = 1,   maxval = 10)
maxLevels    = input.int(8,     "Max Levels to Show",             group = "S&R Detection", minval = 1,   maxval = 20)
srLookback   = input.int(300,   "S&R History Lookback (bars)",    group = "S&R Detection", minval = 50,  maxval = 1000)

showSR         = input.bool(true,  "Show S&R Levels",             group = "S&R Display")
srLineWidth    = input.int(1,      "S&R Line Width",              group = "S&R Display", minval = 1, maxval = 4)
srStyleInput   = input.string("solid", "S&R Line Style",          group = "S&R Display", options = ["solid", "dashed", "dotted"])
colorSR        = input.color(color.new(color.gray, 30), "S&R Color", group = "S&R Display")
showTouchCount = input.bool(true,  "Show Touch Count in Label",   group = "S&R Display")

minWickPct   = input.float(0.3, "Min Wick Size % of candle",     group = "SFP Filters", minval = 0.0, maxval = 10.0, step = 0.1)
minBreachPct = input.float(0.03,"Min Breach Size % of level",    group = "SFP Filters", minval = 0.0, maxval = 1.0,  step = 0.01)
showBullish  = input.bool(true,  "Show Bullish SFP",             group = "SFP Filters")
showBearish  = input.bool(true,  "Show Bearish SFP",             group = "SFP Filters")

showLabel    = input.bool(true,  "Show Labels",                   group = "SFP Display")
showZone     = input.bool(true,  "Show Rejection Zone",           group = "SFP Display")
zoneExtend   = input.int(8,      "Zone Extend (bars right)",      group = "SFP Display", minval = 1, maxval = 50)
labelSize    = input.string("small", "Label Size",                group = "SFP Display", options = ["tiny", "small", "normal"])
zoneAlpha    = input.int(80,     "Zone Transparency",             group = "SFP Display", minval = 50, maxval = 99)
lineWidth    = input.int(1,      "SFP Line Width",                group = "SFP Display", minval = 1, maxval = 4)
colorBull    = input.color(color.new(color.green, 0), "Bullish Color", group = "SFP Display")
colorBear    = input.color(color.new(color.red,   0), "Bearish Color", group = "SFP Display")


// ══════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════

srStyleVal() =>
    switch srStyleInput
        "dashed" => line.style_dashed
        "dotted" => line.style_dotted
        =>          line.style_solid

szVal() =>
    switch labelSize
        "tiny"   => size.tiny
        "normal" => size.normal
        =>          size.small

inCluster(float a, float b) =>
    math.abs(a - b) / math.max(a, b) * 100 <= clusterPct

upperWickPct() =>
    r = high - low
    r > 0 ? (high - math.max(open, close)) / r * 100 : 0.0

lowerWickPct() =>
    r = high - low
    r > 0 ? (math.min(open, close) - low) / r * 100 : 0.0

breachPctHigh(float lvl) =>
    lvl > 0 ? (high - lvl) / lvl * 100 : 0.0

breachPctLow(float lvl) =>
    lvl > 0 ? (lvl - low) / lvl * 100 : 0.0


// ══════════════════════════════════════════════════════
// PIVOT COLLECTION
// Collects confirmed pivot highs and lows into rolling arrays
// Pivots are confirmed pivotLen bars after they form
// ══════════════════════════════════════════════════════

var float[] pivotPrices = array.new_float()
var int[]   pivotBars   = array.new_int()

float ph = ta.pivothigh(high, pivotLen, pivotLen)
float pl = ta.pivotlow(low,  pivotLen, pivotLen)

if not na(ph)
    array.push(pivotPrices, ph)
    array.push(pivotBars,   bar_index - pivotLen)

if not na(pl)
    array.push(pivotPrices, pl)
    array.push(pivotBars,   bar_index - pivotLen)

// Trim to srLookback window
while array.size(pivotBars) > 0 and bar_index - array.get(pivotBars, 0) > srLookback
    array.shift(pivotPrices)
    array.shift(pivotBars)


// ══════════════════════════════════════════════════════
// CLUSTER ENGINE + S&R DRAWING — last bar only
// Groups nearby pivots, counts touches, sorts by strength
// ══════════════════════════════════════════════════════

var float[] srLevels  = array.new_float()
var int[]   srTouches = array.new_int()
var line[]  srLines   = array.new_line()
var label[] srLabels  = array.new_label()

if barstate.islast and array.size(pivotPrices) > 0
    array.clear(srLevels)
    array.clear(srTouches)

    for ln in srLines
        line.delete(ln)
    for lb in srLabels
        label.delete(lb)
    array.clear(srLines)
    array.clear(srLabels)

    int n = array.size(pivotPrices)
    bool[] used = array.new_bool(n, false)

    // Build clusters
    for i = 0 to n - 1
        if i < array.size(used) and not array.get(used, i)
            float clusterSum   = array.get(pivotPrices, i)
            int   clusterCount = 1
            array.set(used, i, true)

            for j = i + 1 to n - 1
                if j < array.size(used) and not array.get(used, j)
                    if inCluster(array.get(pivotPrices, i), array.get(pivotPrices, j))
                        clusterSum   += array.get(pivotPrices, j)
                        clusterCount += 1
                        array.set(used, j, true)

            float clusterAvg = clusterSum / clusterCount

            // Count additional price bar touches
            int touchCount = clusterCount
            for k = pivotLen to math.min(srLookback, bar_index) - 1
                if inCluster(high[k], clusterAvg) or inCluster(low[k], clusterAvg)
                    touchCount += 1

            array.push(srLevels,  clusterAvg)
            array.push(srTouches, touchCount)

    // Bubble sort by touch count descending
    int lvlCount = array.size(srLevels)
    if lvlCount > 1
        for i = 0 to lvlCount - 2
            for j = 0 to lvlCount - i - 2
                if j + 1 < lvlCount
                    if array.get(srTouches, j) < array.get(srTouches, j + 1)
                        float tmpL = array.get(srLevels,  j)
                        int   tmpT = array.get(srTouches, j)
                        array.set(srLevels,  j,     array.get(srLevels,  j + 1))
                        array.set(srTouches, j,     array.get(srTouches, j + 1))
                        array.set(srLevels,  j + 1, tmpL)
                        array.set(srTouches, j + 1, tmpT)

    // Draw valid S&R levels
    if showSR
        int drawn = 0
        for i = 0 to lvlCount - 1
            if drawn >= maxLevels
                break
            if i < array.size(srTouches) and i < array.size(srLevels)
                int   touches = array.get(srTouches, i)
                float lvl     = array.get(srLevels,  i)
                if touches >= minTouches
                    ln = line.new(
                         x1    = bar_index - srLookback,
                         y1    = lvl,
                         x2    = bar_index + zoneExtend,
                         y2    = lvl,
                         color = colorSR,
                         width = srLineWidth,
                         style = srStyleVal())
                    array.push(srLines, ln)

                    string lblTxt = str.tostring(lvl, format.mintick)
                    if showTouchCount
                        lblTxt += "  [" + str.tostring(touches) + "T]"

                    lb = label.new(
                         x         = bar_index + zoneExtend,
                         y         = lvl,
                         text      = lblTxt,
                         style     = label.style_label_left,
                         color     = color.new(colorSR, 60),
                         textcolor = colorSR,
                         size      = szVal())
                    array.push(srLabels, lb)
                    drawn += 1


// ══════════════════════════════════════════════════════
// FIND NEAREST S&R LEVELS — every bar
// Identifies closest valid S&R above and below close
// Used as sweep targets for SFP detection
// ══════════════════════════════════════════════════════

float nearestSRAbove        = na
float nearestSRBelow        = na
float nearestSRAboveTouches = na
float nearestSRBelowTouches = na

if array.size(srLevels) > 0
    for i = 0 to array.size(srLevels) - 1
        if i < array.size(srTouches)
            float lvl     = array.get(srLevels,  i)
            int   touches = array.get(srTouches, i)
            if touches >= minTouches
                if lvl > close
                    if na(nearestSRAbove) or lvl < nearestSRAbove
                        nearestSRAbove        := lvl
                        nearestSRAboveTouches := touches
                else if lvl < close
                    if na(nearestSRBelow) or lvl > nearestSRBelow
                        nearestSRBelow        := lvl
                        nearestSRBelowTouches := touches


// ══════════════════════════════════════════════════════
// SFP DETECTION ON S&R LEVELS
// Only fires when price sweeps a validated S&R cluster
// Significantly higher quality than sweeping any swing point
// ══════════════════════════════════════════════════════

bool bearishSFP = showBearish and
     not na(nearestSRAbove) and
     high > nearestSRAbove and
     close < nearestSRAbove and
     upperWickPct() >= minWickPct and
     breachPctHigh(nearestSRAbove) >= minBreachPct

bool bullishSFP = showBullish and
     not na(nearestSRBelow) and
     low < nearestSRBelow and
     close > nearestSRBelow and
     lowerWickPct() >= minWickPct and
     breachPctLow(nearestSRBelow) >= minBreachPct


// ══════════════════════════════════════════════════════
// SFP VISUALIZATION
// ══════════════════════════════════════════════════════

if bearishSFP
    string touchStr = not na(nearestSRAboveTouches) ?
         " [" + str.tostring(int(nearestSRAboveTouches)) + "T]" : ""

    if showLabel
        label.new(
             x         = bar_index,
             y         = high,
             text      = "SFP ▼\n" + str.tostring(nearestSRAbove, format.mintick) + touchStr,
             style     = label.style_label_down,
             color     = color.new(colorBear, 20),
             textcolor = color.white,
             size      = szVal())

    if showZone
        box.new(
             left         = bar_index,
             top          = high,
             right        = bar_index + zoneExtend,
             bottom       = nearestSRAbove,
             bgcolor      = color.new(colorBear, zoneAlpha),
             border_color = color.new(colorBear, 40),
             border_width = 1,
             text         = "Sweep",
             text_color   = color.new(colorBear, 20),
             text_size    = size.tiny,
             text_halign  = text.align_right,
             text_valign  = text.align_top)

    line.new(
         x1    = bar_index - pivotLen,
         y1    = nearestSRAbove,
         x2    = bar_index + zoneExtend,
         y2    = nearestSRAbove,
         color = color.new(colorBear, 20),
         width = lineWidth,
         style = line.style_dashed)

if bullishSFP
    string touchStr = not na(nearestSRBelowTouches) ?
         " [" + str.tostring(int(nearestSRBelowTouches)) + "T]" : ""

    if showLabel
        label.new(
             x         = bar_index,
             y         = low,
             text      = "SFP ▲\n" + str.tostring(nearestSRBelow, format.mintick) + touchStr,
             style     = label.style_label_up,
             color     = color.new(colorBull, 20),
             textcolor = color.white,
             size      = szVal())

    if showZone
        box.new(
             left         = bar_index,
             top          = nearestSRBelow,
             right        = bar_index + zoneExtend,
             bottom       = low,
             bgcolor      = color.new(colorBull, zoneAlpha),
             border_color = color.new(colorBull, 40),
             border_width = 1,
             text         = "Sweep",
             text_color   = color.new(colorBull, 20),
             text_size    = size.tiny,
             text_halign  = text.align_right,
             text_valign  = text.align_bottom)

    line.new(
         x1    = bar_index - pivotLen,
         y1    = nearestSRBelow,
         x2    = bar_index + zoneExtend,
         y2    = nearestSRBelow,
         color = color.new(colorBull, 20),
         width = lineWidth,
         style = line.style_dashed)


// ══════════════════════════════════════════════════════
// DATA WINDOW
// ══════════════════════════════════════════════════════

plot(bearishSFP ? 1.0 : 0.0,         "Bearish SFP",       color = color.new(color.red,   100), display = display.data_window)
plot(bullishSFP ? 1.0 : 0.0,         "Bullish SFP",       color = color.new(color.green, 100), display = display.data_window)
plot(nearestSRAbove,                  "Nearest SR Above",  color = color.new(color.red,   100), display = display.data_window)
plot(nearestSRBelow,                  "Nearest SR Below",  color = color.new(color.green, 100), display = display.data_window)
plot(nearestSRAboveTouches,           "SR Above Touches",  color = color.new(color.gray,  100), display = display.data_window)
plot(nearestSRBelowTouches,           "SR Below Touches",  color = color.new(color.gray,  100), display = display.data_window)
plot(upperWickPct(),                  "Upper Wick %",      color = color.new(color.gray,  100), display = display.data_window)
plot(lowerWickPct(),                  "Lower Wick %",      color = color.new(color.gray,  100), display = display.data_window)
plot(float(array.size(srLevels)),     "S&R Levels Found",  color = color.new(color.gray,  100), display = display.data_window)
````
