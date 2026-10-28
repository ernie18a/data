# Micro Harmonic Swing Rhythm Meter + Structure Panel

- url: https://www.tradingview.com/script/TlRRbecA-Micro-Harmonic-Swing-Rhythm-Meter-Structure-Panel/
- type: indicator
- pine_id: PUB;5f170c8ff6a94808a543bf0a43eae32f
- version: 1.0

## Description

Micro Harmonic Swing Rhythm Meter

Overview

Inspired by the observation that markets often oscillate in recurring harmonic swings of both price and time.
The Micro Harmonic Swing Rhythm Meter is a market structure and rhythm analysis tool designed to identify recurring swing behavior in price action.

Rather than focusing on traditional indicators such as momentum, trend, or overbought/oversold conditions, this indicator measures the repeating "heartbeat" of the market by tracking swing size, swing duration, and the evolving rhythm between successive price pivots.

The objective is not to predict price, but to monitor whether the current auction process remains stable, is compressing, expanding, or becoming exhausted.



Core Concepts

Every market exhibits recurring oscillations.

These oscillations often develop with similar:

* Price amplitude
* Swing duration
* Expansion and contraction cycles

The indicator automatically detects swing pivots and measures:

* Swing Size
* Swing Duration
* Average Swing Size
* Average Swing Duration
* Swing Efficiency
* Market Rhythm State

By comparing the current swing against recent averages, the indicator evaluates whether price action remains in harmony with its established rhythm.



Rhythm States

NORMAL

Current swing size and duration remain close to recent averages.

Interpretation:

* Stable auction
* Balanced market conditions
* Established rhythm remains intact



COMPRESSED

Current swing size and duration are smaller than average.

Interpretation:

* Energy accumulation
* Contracting auction
* Potential precursor to expansion



STRETCHED

Current swing size and duration exceed recent averages.

Interpretation:

* Expansion phase
* Strong directional movement
* Possible acceleration or exhaustion



MIXED

Price amplitude and swing duration are no longer synchronized.

Interpretation:

* Transitional market behavior
* Changing auction structure
* Reduced rhythm consistency



Market Structure Assessment

The indicator automatically classifies recent swing behavior into higher-order structure states.

Possible structure classifications include:

Balanced Rotation

Stable oscillatory conditions.

Trade Mode:
Range Mode



Compression / Coiling

Multiple compressed swings indicate energy accumulation.

Trade Mode:
Breakout Watch



Expansion Attempt

Expansion emerges following a period of compression.

Trade Mode:
Confirm Breakout



Exhaustion Risk

Repeated stretched swings suggest mature directional movement.

Trade Mode:
Caution



Unstable Auction

Excessive mixed swings indicate poor rhythm consistency.

Trade Mode:
Wait



Efficiency Metric

Efficiency is calculated as:

Average Swing Size ÷ Average Swing Duration

This metric measures how much distance price is covering per unit of time.

Rising efficiency often indicates increasing participation and directional conviction.

Falling efficiency often indicates slowing market activity and declining momentum.



Intended Usage

This indicator is designed primarily as a market state monitor rather than a signal generator.

It may be used alongside:

* Price action analysis
* Volume analysis
* Order flow tools
* VWAP frameworks
* Market profile
* Liquidity analysis

The indicator is particularly useful for identifying:

* Compression before expansion
* Changes in auction rhythm
* Developing directional impulses
* Potential exhaustion conditions



Recommended Workflow

Higher timeframes may be used to determine dominant market structure while lower timeframes are used for execution.

Example:

30-minute chart:
Market structure and session rhythm

5-minute chart:
Tactical structure

1-minute chart:
Execution and timing

This multi-timeframe approach allows traders to align lower timeframe opportunities with higher timeframe rhythm conditions.



Disclaimer

This indicator is designed to assist with market observation and structure analysis. It does not provide trading advice and should not be interpreted as a standalone buy or sell signal.

## Source Code

````pine
//@version=6
indicator("Micro Harmonic Swing Rhythm Meter + Structure Panel", overlay=true, max_labels_count=500, max_lines_count=500)

// ─────────────────────────────────────
// Inputs
// ─────────────────────────────────────
pivotLen       = input.int(5, "Pivot sensitivity", minval=1)
avgSwings      = input.int(8, "Average swings used", minval=2, maxval=50)
showLabels     = input.bool(true, "Show swing labels")
showProjection = input.bool(true, "Show next swing projection")
showSwingLines = input.bool(true, "Show swing lines")
priceTolerance = input.float(20.0, "Normal rhythm tolerance %", minval=1.0)

swingLineColor = input.color(color.fuchsia, "Swing line color")
swingLineWidth = input.int(3, "Swing line width", minval=1, maxval=5)

// ─────────────────────────────────────
// Clutter Control
// ─────────────────────────────────────
maxSwingLabels = input.int(12, "Maximum Swing Labels Shown", minval=0, maxval=100)
maxSwingLines  = input.int(12, "Maximum Swing Lines Shown", minval=0, maxval=100)
maxBarsBack    = input.int(150, "Maximum Bars Back Shown", minval=0, tooltip="0 = disabled")
fadeOldSwings  = input.bool(true, "Fade Older Swings")
resetEachDay   = input.bool(false, "Reset Visuals Each New Day")
resetStatsDay  = input.bool(false, "Reset Rhythm Stats Each New Day")

// ─────────────────────────────────────
// Table Color Settings
// ─────────────────────────────────────
tableBgColor     = input.color(color.new(color.black, 25), "Table Background")
tableTextColor   = input.color(color.white, "Table Text")
tableBorderColor = input.color(color.gray, "Table Border")

// ─────────────────────────────────────
// Pivot Detection
// ─────────────────────────────────────
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

newPivot   = not na(ph) or not na(pl)
pivotPrice = not na(ph) ? ph : not na(pl) ? pl : na
pivotBar   = bar_index - pivotLen
pivotTime  = time[pivotLen]
pivotType  = not na(ph) ? 1 : not na(pl) ? -1 : 0

// ─────────────────────────────────────
// Persistent Variables
// ─────────────────────────────────────
var float lastPivotPrice = na
var int   lastPivotBar   = na
var int   lastPivotTime  = na
var int   lastPivotType  = 0

var float[] swingSizes = array.new_float()
var float[] swingDurations = array.new_float()
var string[] rhythmStates = array.new_string()

var line[] swingLines = array.new_line()
var int[] swingLineBars = array.new_int()

var label[] swingLabels = array.new_label()
var int[] swingLabelBars = array.new_int()
var color[] swingLabelColors = array.new_color()

var line projectionPriceLine = na
var line projectionTimeLine = na
var label projectionLabel = na

// ─────────────────────────────────────
// Functions
// ─────────────────────────────────────
f_avg(arr) =>
    float total = 0.0
    int count = array.size(arr)
    if count == 0
        na
    else
        for i = 0 to count - 1
            total += array.get(arr, i)
        total / count

f_countState(arr, stateName) =>
    int count = 0
    int size = array.size(arr)
    if size > 0
        for i = 0 to size - 1
            if array.get(arr, i) == stateName
                count += 1
    count

f_lastState(arr) =>
    int size = array.size(arr)
    size > 0 ? array.get(arr, size - 1) : "n/a"

// ─────────────────────────────────────
// Daily Reset
// ─────────────────────────────────────
newDay = ta.change(time("D")) != 0

if newDay and resetEachDay
    while array.size(swingLines) > 0
        line.delete(array.shift(swingLines))
        array.shift(swingLineBars)

    while array.size(swingLabels) > 0
        label.delete(array.shift(swingLabels))
        array.shift(swingLabelBars)
        array.shift(swingLabelColors)

    if not na(projectionPriceLine)
        line.delete(projectionPriceLine)
    if not na(projectionTimeLine)
        line.delete(projectionTimeLine)
    if not na(projectionLabel)
        label.delete(projectionLabel)

if newDay and resetStatsDay
    array.clear(swingSizes)
    array.clear(swingDurations)
    array.clear(rhythmStates)
    lastPivotPrice := na
    lastPivotBar := na
    lastPivotTime := na
    lastPivotType := 0

// ─────────────────────────────────────
// Main Swing Logic
// ─────────────────────────────────────
if newPivot
    bool validAlternatingPivot = na(lastPivotPrice) or pivotType != lastPivotType

    if validAlternatingPivot
        if not na(lastPivotPrice)
            swingSize = math.abs(pivotPrice - lastPivotPrice)
            swingMinutes = (pivotTime - lastPivotTime) / 60000.0

            array.push(swingSizes, swingSize)
            array.push(swingDurations, swingMinutes)

            if array.size(swingSizes) > avgSwings
                array.shift(swingSizes)

            if array.size(swingDurations) > avgSwings
                array.shift(swingDurations)

            avgSize = f_avg(swingSizes)
            avgDuration = f_avg(swingDurations)

            sizeDeviation = not na(avgSize) ? math.abs(swingSize - avgSize) / avgSize * 100.0 : na
            durationDeviation = not na(avgDuration) ? math.abs(swingMinutes - avgDuration) / avgDuration * 100.0 : na

            rhythmState = sizeDeviation <= priceTolerance and durationDeviation <= priceTolerance ? "NORMAL" :
                 swingSize > avgSize and swingMinutes > avgDuration ? "STRETCHED" :
                 swingSize < avgSize and swingMinutes < avgDuration ? "COMPRESSED" : "MIXED"

            array.push(rhythmStates, rhythmState)

            if array.size(rhythmStates) > avgSwings
                array.shift(rhythmStates)

            labelColor = rhythmState == "NORMAL" ? color.green :
                 rhythmState == "STRETCHED" ? color.orange :
                 rhythmState == "COMPRESSED" ? color.blue : color.gray

            if showSwingLines and maxSwingLines > 0
                newLine = line.new(
                     lastPivotBar,
                     lastPivotPrice,
                     pivotBar,
                     pivotPrice,
                     color = swingLineColor,
                     width = swingLineWidth
                )
                array.push(swingLines, newLine)
                array.push(swingLineBars, pivotBar)

            if showLabels and maxSwingLabels > 0
                newLabel = label.new(
                     pivotBar,
                     pivotPrice,
                     "Swing: " + str.tostring(swingSize, format.mintick) +
                     "\nTime: " + str.tostring(swingMinutes, "#.0") + " min" +
                     "\nAvg: " + str.tostring(avgSize, format.mintick) +
                     " / " + str.tostring(avgDuration, "#.0") + " min" +
                     "\n" + rhythmState,
                     style = pivotType == 1 ? label.style_label_down : label.style_label_up,
                     textcolor = color.white,
                     color = labelColor
                )
                array.push(swingLabels, newLabel)
                array.push(swingLabelBars, pivotBar)
                array.push(swingLabelColors, labelColor)

            if showProjection and not na(avgSize) and not na(avgDuration)
                if not na(projectionPriceLine)
                    line.delete(projectionPriceLine)
                if not na(projectionTimeLine)
                    line.delete(projectionTimeLine)
                if not na(projectionLabel)
                    label.delete(projectionLabel)

                projectedPrice = pivotType == -1 ? pivotPrice + avgSize : pivotPrice - avgSize
                projectedBars = math.round(avgDuration / timeframe.multiplier)
                projectedBar = pivotBar + projectedBars

                projectionPriceLine := line.new(
                     pivotBar,
                     projectedPrice,
                     projectedBar,
                     projectedPrice,
                     color=color.yellow,
                     style=line.style_dashed,
                     width=2
                )

                projectionTimeLine := line.new(
                     projectedBar,
                     pivotPrice,
                     projectedBar,
                     projectedPrice,
                     color=color.purple,
                     style=line.style_dotted,
                     width=2
                )

                projectionLabel := label.new(
                     projectedBar,
                     projectedPrice,
                     "Projected rhythm\nPrice: " + str.tostring(projectedPrice, format.mintick) +
                     "\nTime: +" + str.tostring(avgDuration, "#.0") + " min",
                     style=label.style_label_left,
                     textcolor=color.white,
                     color=color.purple
                )

        lastPivotPrice := pivotPrice
        lastPivotBar   := pivotBar
        lastPivotTime  := pivotTime
        lastPivotType  := pivotType

// ─────────────────────────────────────
// Delete Old Objects by Count
// ─────────────────────────────────────
while array.size(swingLines) > maxSwingLines
    line.delete(array.shift(swingLines))
    array.shift(swingLineBars)

while array.size(swingLabels) > maxSwingLabels
    label.delete(array.shift(swingLabels))
    array.shift(swingLabelBars)
    array.shift(swingLabelColors)

// ─────────────────────────────────────
// Delete Old Objects by Bars Back
// ─────────────────────────────────────
if maxBarsBack > 0
    while array.size(swingLines) > 0 and bar_index - array.get(swingLineBars, 0) > maxBarsBack
        line.delete(array.shift(swingLines))
        array.shift(swingLineBars)

    while array.size(swingLabels) > 0 and bar_index - array.get(swingLabelBars, 0) > maxBarsBack
        label.delete(array.shift(swingLabels))
        array.shift(swingLabelBars)
        array.shift(swingLabelColors)

// ─────────────────────────────────────
// Fade Older Swings
// ─────────────────────────────────────
if fadeOldSwings
    lineCount = array.size(swingLines)
    if lineCount > 0
        for i = 0 to lineCount - 1
            transparency = math.round(80 - 70 * (i + 1) / lineCount)
            line.set_color(array.get(swingLines, i), color.new(swingLineColor, transparency))

    labelCount = array.size(swingLabels)
    if labelCount > 0
        for i = 0 to labelCount - 1
            transparency = math.round(80 - 70 * (i + 1) / labelCount)
            label.set_color(array.get(swingLabels, i), color.new(array.get(swingLabelColors, i), transparency))
else
    lineCount = array.size(swingLines)
    if lineCount > 0
        for i = 0 to lineCount - 1
            line.set_color(array.get(swingLines, i), swingLineColor)

    labelCount = array.size(swingLabels)
    if labelCount > 0
        for i = 0 to labelCount - 1
            label.set_color(array.get(swingLabels, i), array.get(swingLabelColors, i))

// ─────────────────────────────────────
// Market Structure Assessment
// ─────────────────────────────────────
avgSizeNow = f_avg(swingSizes)
avgDurationNow = f_avg(swingDurations)
efficiencyNow = not na(avgSizeNow) and not na(avgDurationNow) and avgDurationNow != 0 ? avgSizeNow / avgDurationNow : na

normalCount     = f_countState(rhythmStates, "NORMAL")
compressedCount = f_countState(rhythmStates, "COMPRESSED")
stretchedCount  = f_countState(rhythmStates, "STRETCHED")
mixedCount      = f_countState(rhythmStates, "MIXED")
lastRhythmState = f_lastState(rhythmStates)

sampleCount = array.size(rhythmStates)

structureState = "Collecting data"
tradeMode = "WAIT"
structureMeaning = "Need more swings"

if sampleCount >= 4
    if compressedCount >= 3 and stretchedCount == 0
        structureState := "Compression / Coiling"
        tradeMode := "BREAKOUT WATCH"
        structureMeaning := "Energy building"
    else if compressedCount >= 2 and lastRhythmState == "STRETCHED"
        structureState := "Expansion Attempt"
        tradeMode := "CONFIRM BREAKOUT"
        structureMeaning := "Impulse may be starting"
    else if stretchedCount >= 3
        structureState := "Exhaustion Risk"
        tradeMode := "CAUTION"
        structureMeaning := "Do not chase late"
    else if normalCount >= 3
        structureState := "Balanced Rotation"
        tradeMode := "RANGE MODE"
        structureMeaning := "Rhythm stable"
    else if mixedCount >= 3
        structureState := "Unstable Auction"
        tradeMode := "WAIT"
        structureMeaning := "Rhythm unclear"
    else
        structureState := "Transitional"
        tradeMode := "WAIT / OBSERVE"
        structureMeaning := "Structure changing"

// ─────────────────────────────────────
// Table Display
// ─────────────────────────────────────
var table rhythmTable = table.new(
     position.top_right,
     2,
     8,
     border_width = 1,
     border_color = tableBorderColor
)

if barstate.islast
    table.cell(rhythmTable, 0, 0, "Avg Swing", text_color = tableTextColor, bgcolor = tableBgColor)
    table.cell(rhythmTable, 1, 0, na(avgSizeNow) ? "n/a" : str.tostring(avgSizeNow, format.mintick), text_color = tableTextColor, bgcolor = tableBgColor)

    table.cell(rhythmTable, 0, 1, "Avg Duration", text_color = tableTextColor, bgcolor = tableBgColor)
    table.cell(rhythmTable, 1, 1, na(avgDurationNow) ? "n/a" : str.tostring(avgDurationNow, "#.0") + " min", text_color = tableTextColor, bgcolor = tableBgColor)

    table.cell(rhythmTable, 0, 2, "Efficiency", text_color = tableTextColor, bgcolor = tableBgColor)
    table.cell(rhythmTable, 1, 2, na(efficiencyNow) ? "n/a" : str.tostring(efficiencyNow, "#.00") + " /min", text_color = tableTextColor, bgcolor = tableBgColor)

    table.cell(rhythmTable, 0, 3, "Last Swing", text_color = tableTextColor, bgcolor = tableBgColor)
    table.cell(rhythmTable, 1, 3, lastRhythmState, text_color = tableTextColor, bgcolor = tableBgColor)

    table.cell(rhythmTable, 0, 4, "Structure", text_color = tableTextColor, bgcolor = tableBgColor)
    table.cell(rhythmTable, 1, 4, structureState, text_color = tableTextColor, bgcolor = tableBgColor)

    table.cell(rhythmTable, 0, 5, "Trade Mode", text_color = tableTextColor, bgcolor = tableBgColor)
    table.cell(rhythmTable, 1, 5, tradeMode, text_color = tableTextColor, bgcolor = tableBgColor)

    table.cell(rhythmTable, 0, 6, "Meaning", text_color = tableTextColor, bgcolor = tableBgColor)
    table.cell(rhythmTable, 1, 6, structureMeaning, text_color = tableTextColor, bgcolor = tableBgColor)

    table.cell(rhythmTable, 0, 7, "Samples", text_color = tableTextColor, bgcolor = tableBgColor)
    table.cell(rhythmTable, 1, 7, str.tostring(sampleCount), text_color = tableTextColor, bgcolor = tableBgColor)
````
