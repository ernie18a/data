# GFG MACD Pivot Lines by Agaam

- url: https://www.tradingview.com/script/MwpDuqAP-GFG-MACD-Pivot-Lines-by-Agaam/
- type: indicator
- pine_id: PUB;fbf1b89685ca4f77bc02702b346f87ff
- version: 1.0

## Description

**GFG MACD Pivot Lines by Agaam**

**Description**
GFG MACD Pivot Lines by Agaam is a clean chart indicator that uses MACD turning points to create support and resistance style pivot lines directly on the price chart.

Instead of using only price highs and lows, this indicator watches the MACD for confirmed pivot highs and pivot lows. When a MACD pivot is confirmed, the indicator draws a horizontal price level from the candle where that MACD pivot happened.

**How It Works**
A bullish MACD pivot is created when the selected MACD source forms a confirmed pivot low. The indicator then draws a green support-style line from the price low or close of that candle.

A bearish MACD pivot is created when the selected MACD source forms a confirmed pivot high. The indicator then draws a red resistance-style line from the price high or close of that candle.

The MACD pivot source can be selected from:

* MACD Histogram
* MACD Line
* Signal Line

The price level can be based on either the candle wick or the candle close.

**How to Use**
Green MACD pivot lines may act as possible support or bullish reaction areas. Traders may watch these areas for long setups, bounces, or bullish confirmation.

Red MACD pivot lines may act as possible resistance or bearish reaction areas. Traders may watch these areas for short setups, rejections, or bearish confirmation.

This indicator can help identify where momentum turned in the past and where price may react again.

**Important Note About Pivots**
MACD pivots require confirmation. This means the signal appears after the selected number of right-side bars completes. The line is then drawn back from the actual pivot candle where the MACD turning point happened.

**Features**

* MACD-based pivot high and pivot low detection
* Bullish support-style pivot lines
* Bearish resistance-style pivot lines
* Adjustable MACD settings
* Choose Histogram, MACD Line, or Signal Line as the pivot source
* Choose wick or close for the price level
* Shows only the latest 3 bullish and 3 bearish pivot lines
* Pivot arrows/markers remain visible on the chart
* Adjustable line color, width, and style
* Optional labels with price values
* Alert conditions for bullish and bearish MACD pivots

**Best Used With**
This indicator works best when combined with price action, trend direction, supply and demand zones, VWAP, volume, market structure, and risk management.

**Disclaimer**
This indicator is for educational and informational purposes only. It is not financial advice, investment advice, or a buy/sell recommendation. Trading involves risk, and past performance does not guarantee future results. Always use your own analysis, confirmation, and proper risk management before making any trading decision.

## Source Code

````pine
//@version=5
indicator("GFG MACD Pivot Lines by Agaam", overlay=true, max_lines_count=500, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MACD SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
src = input.source(close, "Source", group="MACD Settings")
fastLen = input.int(12, "MACD Fast Length", minval=1, group="MACD Settings")
slowLen = input.int(26, "MACD Slow Length", minval=1, group="MACD Settings")
signalLen = input.int(9, "MACD Signal Length", minval=1, group="MACD Settings")

pivotSourceInput = input.string("Histogram", "MACD Pivot Source", options=["Histogram", "MACD Line", "Signal Line"], group="MACD Settings")
leftBars = input.int(3, "Pivot Left Bars", minval=1, maxval=50, group="MACD Settings")
rightBars = input.int(3, "Pivot Right Bars", minval=1, maxval=50, group="MACD Settings")

bullBelowZeroOnly = input.bool(false, "Bull Pivot Only Below Zero", group="MACD Filters")
bearAboveZeroOnly = input.bool(false, "Bear Pivot Only Above Zero", group="MACD Filters")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRICE LEVEL SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
priceMode = input.string("Wick", "Price Level From", options=["Wick", "Close"], group="Price Level")
showBullPivots = input.bool(true, "Show Bull MACD Pivot Lines", group="Price Level")
showBearPivots = input.bool(true, "Show Bear MACD Pivot Lines", group="Price Level")
currentOnly = input.bool(false, "Show Current Pivot Only Per Side", group="Price Level")
extendBarsRight = input.int(80, "Extend Lines Right", minval=1, maxval=500, group="Price Level")
keepLinesExtended = input.bool(true, "Keep Lines Extended With Chart", group="Price Level")

// Fixed to 3 lines per side
maxLinesPerSide = 3

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISUAL SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bullColor = input.color(color.lime, "Bull Pivot Line Color", group="Visuals")
bearColor = input.color(color.red, "Bear Pivot Line Color", group="Visuals")
bullLabelColor = input.color(color.new(color.lime, 10), "Bull Label Color", group="Visuals")
bearLabelColor = input.color(color.new(color.red, 10), "Bear Label Color", group="Visuals")
labelTextColor = input.color(color.white, "Label Text Color", group="Visuals")

lineWidth = input.int(2, "Line Width", minval=1, maxval=5, group="Visuals")
lineStyleInput = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group="Visuals")

showLabels = input.bool(true, "Show Labels", group="Visuals")
labelOffsetBars = input.int(0, "Label Extra Offset Bars", minval=0, maxval=100, group="Visuals")
labelSizeInput = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large"], group="Visuals")

showMarkers = input.bool(true, "Show Small Pivot Markers / Arrows", group="Markers")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_lineStyle(_style) =>
    _style == "Dashed" ? line.style_dashed : _style == "Dotted" ? line.style_dotted : line.style_solid

f_labelSize(_size) =>
    result = size.small
    if _size == "Tiny"
        result := size.tiny
    else if _size == "Normal"
        result := size.normal
    else if _size == "Large"
        result := size.large
    result

f_clearLines(_lines) =>
    while array.size(_lines) > 0
        oldLine = array.pop(_lines)
        line.delete(oldLine)

f_clearLabels(_labels) =>
    while array.size(_labels) > 0
        oldLabel = array.pop(_labels)
        label.delete(oldLabel)

f_trimOld(_lines, _labels, _max) =>
    while array.size(_lines) > _max
        oldLine = array.shift(_lines)
        line.delete(oldLine)

    while array.size(_labels) > _max
        oldLabel = array.shift(_labels)
        label.delete(oldLabel)

f_updateLines(_lines, _x2, _color, _width, _style) =>
    if array.size(_lines) > 0
        for i = 0 to array.size(_lines) - 1
            ln = array.get(_lines, i)
            line.set_x2(ln, _x2)
            line.set_color(ln, _color)
            line.set_width(ln, _width)
            line.set_style(ln, _style)

f_updateLabels(_labels, _x, _color, _textColor, _labelSize) =>
    if array.size(_labels) > 0
        for i = 0 to array.size(_labels) - 1
            lb = array.get(_labels, i)
            label.set_x(lb, _x)
            label.set_color(lb, _color)
            label.set_textcolor(lb, _textColor)
            label.set_size(lb, _labelSize)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MACD CALCULATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[macdLine, signalLine, macdHist] = ta.macd(src, fastLen, slowLen, signalLen)

macdPivotSource = pivotSourceInput == "MACD Line" ? macdLine : pivotSourceInput == "Signal Line" ? signalLine : macdHist

bullMacdPivot = ta.pivotlow(macdPivotSource, leftBars, rightBars)
bearMacdPivot = ta.pivothigh(macdPivotSource, leftBars, rightBars)

bullPivotConfirmed = not na(bullMacdPivot)
bearPivotConfirmed = not na(bearMacdPivot)

bullFilterOk = bullBelowZeroOnly ? bullMacdPivot < 0 : true
bearFilterOk = bearAboveZeroOnly ? bearMacdPivot > 0 : true

bullEvent = showBullPivots and bullPivotConfirmed and bullFilterOk
bearEvent = showBearPivots and bearPivotConfirmed and bearFilterOk

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRICE LEVEL FROM MACD PIVOT CANDLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bullPrice = priceMode == "Close" ? close[rightBars] : low[rightBars]
bearPrice = priceMode == "Close" ? close[rightBars] : high[rightBars]

pivotBarIndex = bar_index - rightBars
lineEndX = bar_index + extendBarsRight
labelX = lineEndX + labelOffsetBars

lineStyleFinal = f_lineStyle(lineStyleInput)
labelSizeFinal = f_labelSize(labelSizeInput)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ARRAYS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var bullLines = array.new_line()
var bearLines = array.new_line()
var bullLabels = array.new_label()
var bearLabels = array.new_label()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DELETE OLD OBJECTS IF SIDE IS TURNED OFF
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if barstate.islast
    if not showBullPivots
        f_clearLines(bullLines)
        f_clearLabels(bullLabels)

    if not showBearPivots
        f_clearLines(bearLines)
        f_clearLabels(bearLabels)

    if not showLabels
        f_clearLabels(bullLabels)
        f_clearLabels(bearLabels)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CREATE BULL MACD PIVOT LINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if bullEvent
    if currentOnly
        f_clearLines(bullLines)
        f_clearLabels(bullLabels)

    newBullLine = line.new(pivotBarIndex, bullPrice, lineEndX, bullPrice, xloc=xloc.bar_index, extend=extend.none, color=bullColor, width=lineWidth, style=lineStyleFinal)
    array.push(bullLines, newBullLine)

    if showLabels
        bullText = "MACD Bull Pivot  " + str.tostring(bullPrice, format.mintick)
        newBullLabel = label.new(labelX, bullPrice, bullText, xloc=xloc.bar_index, style=label.style_label_left, color=bullLabelColor, textcolor=labelTextColor, size=labelSizeFinal)
        array.push(bullLabels, newBullLabel)

    f_trimOld(bullLines, bullLabels, maxLinesPerSide)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CREATE BEAR MACD PIVOT LINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if bearEvent
    if currentOnly
        f_clearLines(bearLines)
        f_clearLabels(bearLabels)

    newBearLine = line.new(pivotBarIndex, bearPrice, lineEndX, bearPrice, xloc=xloc.bar_index, extend=extend.none, color=bearColor, width=lineWidth, style=lineStyleFinal)
    array.push(bearLines, newBearLine)

    if showLabels
        bearText = "MACD Bear Pivot  " + str.tostring(bearPrice, format.mintick)
        newBearLabel = label.new(labelX, bearPrice, bearText, xloc=xloc.bar_index, style=label.style_label_left, color=bearLabelColor, textcolor=labelTextColor, size=labelSizeFinal)
        array.push(bearLabels, newBearLabel)

    f_trimOld(bearLines, bearLabels, maxLinesPerSide)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// KEEP LINES AND LABELS UPDATED
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if barstate.islast
    if keepLinesExtended
        f_updateLines(bullLines, lineEndX, bullColor, lineWidth, lineStyleFinal)
        f_updateLines(bearLines, lineEndX, bearColor, lineWidth, lineStyleFinal)

    if showLabels
        f_updateLabels(bullLabels, labelX, bullLabelColor, labelTextColor, labelSizeFinal)
        f_updateLabels(bearLabels, labelX, bearLabelColor, labelTextColor, labelSizeFinal)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SMALL PIVOT MARKERS / ARROWS
// These stay as they are right now.
// The 3-line limit does not remove arrows.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(showMarkers and bullEvent, title="Bull MACD Pivot Marker", style=shape.triangleup, location=location.belowbar, offset=-rightBars, color=color.new(bullColor, 0), size=size.tiny)
plotshape(showMarkers and bearEvent, title="Bear MACD Pivot Marker", style=shape.triangledown, location=location.abovebar, offset=-rightBars, color=color.new(bearColor, 0), size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(bullEvent, title="Bull MACD Pivot", message="Bull MACD Pivot confirmed")
alertcondition(bearEvent, title="Bear MACD Pivot", message="Bear MACD Pivot confirmed")
````
