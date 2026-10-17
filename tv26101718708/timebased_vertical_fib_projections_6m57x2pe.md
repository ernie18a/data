# Time-Based Vertical Fib Projections

- url: https://www.tradingview.com/script/6M57X2PE-Time-Based-Vertical-Fib-Projections/
- type: indicator
- pine_id: PUB;955c3cf0db9f4d24b57e59acb2a35553
- version: 1.0

## Description

[b]Time-Based Vertical Fib Projections[/b]

This indicator automatically measures the time it takes for price to form the high-to-low range during the time window from 20:00 to 00:00 EST.

Once the session ends, the script identifies the highest high and lowest low within that range, calculates the time distance between those two points, and projects that same time interval forward as vertical time levels.

Projection lines are plotted at 1σ, 2σ, 3σ, 4σ, 5σ, and beyond, based on the measured time interval. These projected vertical levels can help traders anticipate future timing windows where price may react, expand, reverse, or reach important intraday objectives.

Features include:

Automatic detection of the 20:00–00:00 EST range.
Measures time between the range high and range low
Projects forward time-based standard deviation levels
Optional labels for each projection
Optional marking of the original range high and low times
Adjustable number of projections
Custom line colors, style, width, and history length


This tool is intended for time-based analysis and does not generate buy or sell signals. It should be used alongside market structure, liquidity, session context, and risk management.


[b]Update Notes[/b]

The time-based range window is now fully customizable from the indicator settings.

The default range remains 20:00–00:00 EST, but users can now adjust the start and end time to define their own custom measurement window. The indicator will use the selected range to identify the high and low, calculate the time distance between those points, and project the vertical time levels forward from that custom range.

This makes the tool more flexible for traders who want to apply the same time-projection logic to different sessions, killzones, or custom trading windows.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © vladizvladi

//@version=6
indicator("Time-Based Vertical Fib Projections", overlay = true, max_lines_count = 500, max_labels_count = 500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
rangeSession = input.session("2000-0000", "Range Time Window")
tz           = input.string("America/New_York", "Timezone")
projCount   = input.int(8, "Number of Projections", minval = 1, maxval = 50)
keepHistory = input.int(5, "Keep Last N Ranges", minval = 1, maxval = 25)

showLabels  = input.bool(true, "Show Projection Labels")
showRangeHL = input.bool(true, "Mark Range High/Low Times")

projColor   = input.color(color.new(color.aqua, 0), "Projection Line Color")
rangeColor  = input.color(color.new(color.orange, 0), "Range Extreme Line Color")
lineStyleIn = input.string("Dashed", "Projection Line Style", options = ["Solid", "Dashed", "Dotted"])
lineWidth   = input.int(1, "Line Width", minval = 1, maxval = 4)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Helpers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
lineStyle = lineStyleIn == "Solid" ? line.style_solid :
     lineStyleIn == "Dashed" ? line.style_dashed :
     line.style_dotted

f_deleteOldObjects(line[] linesArr, label[] labelsArr, int maxRanges, int objectsPerRange) =>
    maxObjects = maxRanges * objectsPerRange

    while array.size(linesArr) > maxObjects
        oldLine = array.shift(linesArr)
        line.delete(oldLine)

    while array.size(labelsArr) > maxObjects
        oldLabel = array.shift(labelsArr)
        label.delete(oldLabel)

f_verticalLine(int xTime, color col, style, int width) =>
    line.new(
         x1 = xTime,
         y1 = low,
         x2 = xTime,
         y2 = high,
         xloc = xloc.bar_time,
         extend = extend.both,
         color = col,
         style = style,
         width = width
     )

f_label(int xTime, float y, string txt, color col) =>
    label.new(
         x = xTime,
         y = y,
         text = txt,
         xloc = xloc.bar_time,
         style = label.style_label_down,
         textcolor = color.white,
         color = col,
         size = size.small
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Session detection
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
inSession = not na(time(timeframe.period, rangeSession, tz))

sessionStart = inSession and not inSession[1]
sessionEnd   = not inSession and inSession[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Track high/low and their times during session
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float rangeHigh = na
var float rangeLow  = na
var int   highTime  = na
var int   lowTime   = na

var line[]  allLines  = array.new_line()
var label[] allLabels = array.new_label()

if sessionStart
    rangeHigh := high
    rangeLow  := low
    highTime  := time
    lowTime   := time

if inSession
    if na(rangeHigh) or high > rangeHigh
        rangeHigh := high
        highTime  := time

    if na(rangeLow) or low < rangeLow
        rangeLow := low
        lowTime  := time

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// On session end, project vertical fib/stdv lines
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if sessionEnd and not na(highTime) and not na(lowTime)
    duration = math.abs(highTime - lowTime)

    // Anchor from the later of the two extremes.
    anchorTime = math.max(highTime, lowTime)

    rangeSize = math.max(rangeHigh - rangeLow, syminfo.mintick)
    labelY = rangeHigh + rangeSize * 0.25

    // Optional: mark the actual high/low time lines.
    if showRangeHL
        hiLine = f_verticalLine(highTime, rangeColor, line.style_solid, lineWidth)
        loLine = f_verticalLine(lowTime, rangeColor, line.style_solid, lineWidth)

        array.push(allLines, hiLine)
        array.push(allLines, loLine)

        if showLabels
            hiLbl = f_label(highTime, labelY, "Range High", color.new(rangeColor, 0))
            loLbl = f_label(lowTime, labelY, "Range Low", color.new(rangeColor, 0))

            array.push(allLabels, hiLbl)
            array.push(allLabels, loLbl)

    // Only draw projections if high and low happened at different times.
    if duration > 0
        for i = 1 to projCount
            projectedTime = anchorTime + duration * i

            projLine = f_verticalLine(projectedTime, projColor, lineStyle, lineWidth)
            array.push(allLines, projLine)

            if showLabels
                txt = str.tostring(i) + "σ"
                projLbl = f_label(projectedTime, labelY, txt, color.new(projColor, 0))
                array.push(allLabels, projLbl)

    objectsPerRange = projCount + (showRangeHL ? 2 : 0)
    f_deleteOldObjects(allLines, allLabels, keepHistory, objectsPerRange)
````
