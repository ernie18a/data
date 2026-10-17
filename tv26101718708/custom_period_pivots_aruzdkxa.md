# Custom Period Pivots

- url: https://www.tradingview.com/script/AruzDkxA-Custom-Period-Pivots/
- type: indicator
- pine_id: PUB;9ace849bc41345bca08ac11e621a56e7
- version: 1.0

## Description

Fixed range pivots, all diff calculations of pivots available
Fixed range pivots, all diff calculations of pivots available
Fixed range pivots, all diff calculations of pivots available
Fixed range pivots, all diff calculations of pivots available
Fixed range pivots, all diff calculations of pivots available
Fixed range pivots, all diff calculations of pivots available

## Source Code

````pine
//@version=6
indicator("Codex Custom Period Pivots", overlay=true, max_lines_count=500, max_labels_count=500)
tz = input.string("America/New_York", "Timezone")
pivotTimeframe = input.timeframe("60", "Pivot timeframe")
pivotMode = input.string("OHLC", "Pivot formula", options=["OHLC", "OHL", "OHC", "OLC", "HLC", "HL", "OC", "OH", "OL", "HC", "LC", "O", "H", "L", "C"])
showCurrentPeriod = input.bool(true, "Show current forming period pivot")
showLabels = input.bool(true, "Show labels")
maxPeriodsKept = input.int(200, "Max pivots kept", minval=10, maxval=500)
pivotColor = input.color(color.new(color.orange, 0), "Completed period pivot")
extensionColor = input.color(color.new(color.yellow, 0), "Next-period extension")
currentPivotColor = input.color(color.new(color.aqua, 0), "Current forming period pivot")
pivotWidth = input.int(2, "Line width", minval=1, maxval=5)
calcPivot(mode, o, h, l, c) =>
    switch mode
        "OHLC" => (o + h + l + c) / 4.0
        "OHL" => (o + h + l) / 3.0
        "OHC" => (o + h + c) / 3.0
        "OLC" => (o + l + c) / 3.0
        "HLC" => (h + l + c) / 3.0
        "HL" => (h + l) / 2.0
        "OC" => (o + c) / 2.0
        "OH" => (o + h) / 2.0
        "OL" => (o + l) / 2.0
        "HC" => (h + c) / 2.0
        "LC" => (l + c) / 2.0
        "O" => o
        "H" => h
        "L" => l
        "C" => c
        => (o + h + l + c) / 4.0
periodTime = time(pivotTimeframe, "0000-2359:1234567", tz)
newPeriod = not barstate.isfirst and not na(periodTime) and periodTime != periodTime[1]
var float periodOpen = na
var float periodHigh = na
var float periodLow = na
var int periodStartBar = na
var line currentLine = na
var label currentLabel = na
var line extendingPrevLine = na
var label extendingPrevLabel = na
var array<line> pivotLines = array.new_line()
var array<line> extensionLines = array.new_line()
var array<label> pivotLabels = array.new_label()
if barstate.isfirst
    periodOpen := open
    periodHigh := high
    periodLow := low
    periodStartBar := bar_index
if newPeriod
    prevClose = close[1]
    prevPivot = calcPivot(pivotMode, periodOpen, periodHigh, periodLow, prevClose)
    completedLine = line.new(x1=periodStartBar, y1=prevPivot, x2=bar_index - 1, y2=prevPivot, xloc=xloc.bar_index, extend=extend.none, color=pivotColor, width=pivotWidth)
    nextPeriodLine = line.new(x1=bar_index, y1=prevPivot, x2=bar_index, y2=prevPivot, xloc=xloc.bar_index, extend=extend.none, color=extensionColor, width=pivotWidth, style=line.style_dashed)
    array.push(pivotLines, completedLine)
    array.push(extensionLines, nextPeriodLine)
    extendingPrevLine := nextPeriodLine
    if showLabels
        completedLabel = label.new(x=bar_index - 1, y=prevPivot, text=pivotTimeframe + " " + pivotMode, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(pivotColor, 0), textcolor=color.black, size=size.tiny)
        array.push(pivotLabels, completedLabel)
        extendingPrevLabel := label.new(x=bar_index, y=prevPivot, text="Next " + pivotTimeframe + " " + pivotMode, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(extensionColor, 0), textcolor=color.black, size=size.tiny)
        array.push(pivotLabels, extendingPrevLabel)
    if not na(currentLine)
        line.delete(currentLine)
        currentLine := na
    if not na(currentLabel)
        label.delete(currentLabel)
        currentLabel := na
    while array.size(pivotLines) > maxPeriodsKept
        oldLine = array.shift(pivotLines)
        line.delete(oldLine)
    while array.size(extensionLines) > maxPeriodsKept
        oldExtLine = array.shift(extensionLines)
        line.delete(oldExtLine)
    while array.size(pivotLabels) > maxPeriodsKept * 2
        oldLabel = array.shift(pivotLabels)
        label.delete(oldLabel)
    periodOpen := open
    periodHigh := high
    periodLow := low
    periodStartBar := bar_index
else
    periodHigh := na(periodHigh) ? high : math.max(periodHigh, high)
    periodLow := na(periodLow) ? low : math.min(periodLow, low)
if not na(extendingPrevLine)
    line.set_x2(extendingPrevLine, bar_index)
if not na(extendingPrevLabel)
    label.set_x(extendingPrevLabel, bar_index)
currentPivot = calcPivot(pivotMode, periodOpen, periodHigh, periodLow, close)
if showCurrentPeriod and not na(currentPivot)
    if na(currentLine)
        currentLine := line.new(x1=periodStartBar, y1=currentPivot, x2=bar_index, y2=currentPivot, xloc=xloc.bar_index, extend=extend.none, color=currentPivotColor, width=pivotWidth, style=line.style_dashed)
    else
        line.set_x1(currentLine, periodStartBar)
        line.set_y1(currentLine, currentPivot)
        line.set_x2(currentLine, bar_index)
        line.set_y2(currentLine, currentPivot)
    if showLabels
        if na(currentLabel)
            currentLabel := label.new(x=bar_index, y=currentPivot, text="Current " + pivotTimeframe + " " + pivotMode, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(currentPivotColor, 0), textcolor=color.black, size=size.tiny)
        else
            label.set_x(currentLabel, bar_index)
            label.set_y(currentLabel, currentPivot)
            label.set_text(currentLabel, "Current " + pivotTimeframe + " " + pivotMode)
else
    if not na(currentLine)
        line.delete(currentLine)
        currentLine := na
    if not na(currentLabel)
        label.delete(currentLabel)
        currentLabel := na
````
