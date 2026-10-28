# H4 High Low Lines

- url: https://www.tradingview.com/script/mGkw236k-H4-High-Low-Lines/
- type: indicator
- pine_id: PUB;f3aff23f7a044317b68aca52ec7ae5f2
- version: 1.0

## Description

[b]OVERVIEW[/b]

This indicator marks the high and low of the last N completed 4-hour candles on any chart timeframe (1m, 5m, 15m, 4H, etc.), syncing automatically to the symbol's real 4-hour session boundaries.

[b]HOW TO USE[/b]

Add the indicator to any chart. Two lines are drawn for each completed 4H candle: one at the wick high, one at the wick low. Each line starts exactly at the bar where that high or low occurred, extends a configurable distance ahead of price, and is labeled "H4" to the right.

Use the "Max H4 Candles to Show" input to choose how many recent 4H candles to display (1 to 10, default 2). Line color, width, style, label text, label color, label size, extend length, and label gap are all configurable in the inputs.

[b]LIMITATIONS[/b]

The script relies on a non-repainting multi-timeframe request to the native 240 ("240" minute / 4H) series. Because of this, on a realtime bar the script waits for the underlying 4H bar to be confirmed before drawing it, which introduces a small delay relative to the moment the 4H candle actually closes. This is expected behavior for non-repainting higher-timeframe requests and is not a bug.

[b]NOTES[/b]

This script uses the request.security() offset-and-lookahead technique documented by PineCoders in their "Higher-timeframe requests" publication to avoid repainting and ensure consistent timing across historical and live bars.

## Source Code

````pine
//@version=6
indicator("H4 High Low Lines", overlay=true, max_lines_count=500, max_labels_count=500)

// === INPUTS ===
maxLevels   = input.int(2, "Max H4 Candles to Show", minval=1, maxval=10)
lineColor   = input.color(color.black, "Line Color")
lineWidth   = input.int(1, "Line Width", minval=1, maxval=5)
lineStyle   = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"])
labelText   = input.string("H4", "Label Text")
labelColor  = input.color(color.black, "Label Text Color")
labelSize   = input.string("Small", "Label Font Size", options=["Tiny", "Small", "Normal", "Large", "Huge"])
extendBars  = input.int(20, "Extend Beyond Current Bar (bars)", minval=1)
labelGap    = input.int(3, "Label Gap (bars to the right of line end)", minval=0)

getLineStyle() =>
    lineStyle == "Dashed" ? line.style_dashed : lineStyle == "Dotted" ? line.style_dotted : line.style_solid

getLabelSize() =>
    labelSize == "Tiny" ? size.tiny : labelSize == "Small" ? size.small : labelSize == "Normal" ? size.normal : labelSize == "Large" ? size.large : size.huge

h4Time = request.security(syminfo.tickerid, "240", time[1], lookahead=barmerge.lookahead_on)
newH4Period = h4Time != h4Time[1] and not na(h4Time[1])

var float runHigh = na
var float runLow  = na
var int   runHighBar = na
var int   runLowBar  = na

var float doneHigh = na
var float doneLow  = na
var int   doneHighBar = na
var int   doneLowBar  = na
var bool  drawSignal = false

drawSignal := false

if newH4Period
    if not na(runHigh)
        doneHigh := runHigh
        doneLow := runLow
        doneHighBar := runHighBar
        doneLowBar := runLowBar
        drawSignal := true
    runHigh := high
    runLow := low
    runHighBar := bar_index
    runLowBar := bar_index
else
    if high > runHigh or na(runHigh)
        runHigh := high
        runHighBar := bar_index
    if low < runLow or na(runLow)
        runLow := low
        runLowBar := bar_index

var array<line>  h4LinesHigh  = array.new<line>()
var array<line>  h4LinesLow   = array.new<line>()
var array<label> h4LabelsHigh = array.new<label>()
var array<label> h4LabelsLow  = array.new<label>()

if drawSignal and not na(doneHigh) and not na(doneLow)
    endX = bar_index + extendBars

    lnH = line.new(x1=doneHighBar, y1=doneHigh, x2=endX, y2=doneHigh, xloc=xloc.bar_index, extend=extend.none, color=lineColor, width=lineWidth, style=getLineStyle())
    lbH = label.new(x=endX + labelGap, y=doneHigh, text=labelText, xloc=xloc.bar_index, color=color.new(color.white, 100), textcolor=labelColor, style=label.style_label_left, size=getLabelSize())

    lnL = line.new(x1=doneLowBar, y1=doneLow, x2=endX, y2=doneLow, xloc=xloc.bar_index, extend=extend.none, color=lineColor, width=lineWidth, style=getLineStyle())
    lbL = label.new(x=endX + labelGap, y=doneLow, text=labelText, xloc=xloc.bar_index, color=color.new(color.white, 100), textcolor=labelColor, style=label.style_label_left, size=getLabelSize())

    array.push(h4LinesHigh, lnH)
    array.push(h4LinesLow, lnL)
    array.push(h4LabelsHigh, lbH)
    array.push(h4LabelsLow, lbL)

    if array.size(h4LinesHigh) > maxLevels
        line.delete(array.shift(h4LinesHigh))
        line.delete(array.shift(h4LinesLow))
        label.delete(array.shift(h4LabelsHigh))
        label.delete(array.shift(h4LabelsLow))

if array.size(h4LinesHigh) > 0
    for i = 0 to array.size(h4LinesHigh) - 1
        lnH = array.get(h4LinesHigh, i)
        lnL = array.get(h4LinesLow, i)
        lbH = array.get(h4LabelsHigh, i)
        lbL = array.get(h4LabelsLow, i)

        newEndX = bar_index + extendBars
        line.set_x2(lnH, newEndX)
        line.set_x2(lnL, newEndX)
        label.set_x(lbH, newEndX + labelGap)
        label.set_x(lbL, newEndX + labelGap)
````
