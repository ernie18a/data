# Bitcoin Smart Cycle Scanner V9 

- url: https://www.tradingview.com/script/rghDhJzk-Bitcoin-Smart-Cycle-Scanner-V9/
- type: indicator
- pine_id: PUB;4515bcfaf2f541549bb202b9d5119c04
- version: 1.0

## Description

Bitcoin Smart Cycle Scanner V9 is a long-term Bitcoin cycle visualization tool designed to make major bull and bear market phases easier to read on the chart.

The indicator scans user-defined historical time windows to detect important cycle points such as bear market lows and bull market tops. It then marks those events with vertical lines, phase labels, background color zones, and day-count measurements showing how long each bull or bear phase lasted.

Main features:

* Detects major Bitcoin cycle lows and tops within adjustable date windows
* Highlights bull phases and bear phases with background colors
* Shows detected bear lows, bull tops, and phase duration in days
* Tracks the current bear low so far after the latest detected top
* Projects possible future bear lows and bull tops based on adjustable cycle-length assumptions
* Allows projected cycle timing to be customized from the settings

Cycle range note:

By default, this scanner focuses on Bitcoin cycle analysis from the 2018 bear market low onward. Historical windows can be adjusted manually in the settings.

This script is intended for cycle study, historical comparison, and visual analysis. It is not financial advice and should not be used as a standalone buy or sell signal.

Label positioning note:

Due to TradingView/Pine Script limitations, label boxes may not always stay perfectly aligned during aggressive zooming or price-scale adjustments. The labels are positioned to remain as readable as possible across normal chart usage. Feedback or improvement suggestions are welcome.

## Source Code

````pine
//@version=6
indicator("Bitcoin Smart Cycle Scanner V9 Top Bottom Labels", overlay=true, max_lines_count=200, max_labels_count=200)

// Search windows for detected highs/lows
low2018Start = input.time(defval = 1541030400000, title = "2018 Low Search Start")
low2018End   = input.time(defval = 1548979200000, title = "2018 Low Search End")

top2021Start = input.time(defval = 1544832000000, title = "2021 Top Search Start")
top2021End   = input.time(defval = 1640908800000, title = "2021 Top Search End")

low2022Start = input.time(defval = 1636502400000, title = "2022 Low Search Start")
low2022End   = input.time(defval = 1675209600000, title = "2022 Low Search End")

top2025Start = input.time(defval = 1668988800000, title = "2025 Top Search Start")
top2025End   = input.time(defval = 1767139200000, title = "2025 Top Search End")

// Background phase dates
bgBearLow2018 = input.time(defval = 1544832000000, title = "Background 2018 Bear Low")
bgBullTop2021 = input.time(defval = 1636502400000, title = "Background 2021 Bull Top")
bgBearLow2022 = input.time(defval = 1668988800000, title = "Background 2022 Bear Low")
bgBullTop2025 = input.time(defval = 1759708800000, title = "Background 2025 Bull Top")

// Projection settings
projectedBearDays = input.int(376, "Projected Bear Days After Bull Top", minval=1)
projectedBullDays = input.int(1050, "Projected Bull Days After Bear Low", minval=1)
futureProjectionCycles = input.int(2, "Future Projection Cycles", minval=0, maxval=5)

// Display settings
showBackground     = input.bool(true, "Show Background")
showDetectedLines  = input.bool(true, "Show Detected Lines")
showProjectedLines = input.bool(true, "Show Projected Lines")
showLabels         = input.bool(true, "Show Labels")
showLiveFutureLow  = input.bool(true, "Show Current Bear Low So Far")

labelRailPaddingPct = input.float(6.0, "Top/Bottom Label Padding (%)", minval=0.0, step=0.25)

// Constants
dayMs = 24 * 60 * 60 * 1000

daysBetween(_start, _end) =>
    math.round((_end - _start) / dayMs)

var float chartHighPrice = na
var float chartLowPrice = na

chartHighPrice := na(chartHighPrice) ? high : math.max(chartHighPrice, high)
chartLowPrice := na(chartLowPrice) ? low : math.min(chartLowPrice, low)

labelRailPrice(_isTop) =>
    padding = labelRailPaddingPct / 100.0
    _isTop ? chartHighPrice * (1.0 + padding) : math.max(chartLowPrice * (1.0 - padding), syminfo.mintick)

// Detected cycle points
var int   bearLow2018Time = na
var int   bearLow2018Index = na
var float bearLow2018Price = na

var int   bullTop2021Time = na
var int   bullTop2021Index = na
var float bullTop2021Price = na

var int   bearLow2022Time = na
var int   bearLow2022Index = na
var float bearLow2022Price = na

var int   bullTop2025Time = na
var int   bullTop2025Index = na
var float bullTop2025Price = na

var int   currentBearLowTime = na
var int   currentBearLowIndex = na
var float currentBearLowPrice = na

// Detect historical points
if time >= low2018Start and time <= low2018End
    if na(bearLow2018Price) or low < bearLow2018Price
        bearLow2018Price := low
        bearLow2018Time := time
        bearLow2018Index := bar_index

if time >= top2021Start and time <= top2021End
    if na(bullTop2021Price) or high > bullTop2021Price
        bullTop2021Price := high
        bullTop2021Time := time
        bullTop2021Index := bar_index

if time >= low2022Start and time <= low2022End
    if na(bearLow2022Price) or low < bearLow2022Price
        bearLow2022Price := low
        bearLow2022Time := time
        bearLow2022Index := bar_index

if time >= top2025Start and time <= top2025End
    if na(bullTop2025Price) or high > bullTop2025Price
        bullTop2025Price := high
        bullTop2025Time := time
        bullTop2025Index := bar_index

        currentBearLowPrice := na
        currentBearLowTime := na
        currentBearLowIndex := na

if not na(bullTop2025Time) and time > bullTop2025Time
    if na(currentBearLowPrice) or low < currentBearLowPrice
        currentBearLowPrice := low
        currentBearLowTime := time
        currentBearLowIndex := bar_index

// Duration calculations
bullDays1 = not na(bearLow2018Time) and not na(bullTop2021Time) ? daysBetween(bearLow2018Time, bullTop2021Time) : na
bearDays1 = not na(bullTop2021Time) and not na(bearLow2022Time) ? daysBetween(bullTop2021Time, bearLow2022Time) : na
bullDays2 = not na(bearLow2022Time) and not na(bullTop2025Time) ? daysBetween(bearLow2022Time, bullTop2025Time) : na

projectedBearLowTime = not na(bullTop2025Time) ? bullTop2025Time + projectedBearDays * dayMs : na

// Background using bgcolor
inBull1 = time >= bgBearLow2018 and time < bgBullTop2021
inBear1 = time >= bgBullTop2021 and time < bgBearLow2022
inBull2 = time >= bgBearLow2022 and time < bgBullTop2025
inBear2 = not na(projectedBearLowTime) and time >= bgBullTop2025 and time < projectedBearLowTime

bgcolor(showBackground and inBull1 ? color.new(color.green, 88) : na)
bgcolor(showBackground and inBear1 ? color.new(color.red, 88) : na)
bgcolor(showBackground and inBull2 ? color.new(color.green, 88) : na)
bgcolor(showBackground and inBear2 ? color.new(color.red, 88) : na)

// Drawing arrays
var line[]  lines  = array.new_line()
var label[] labels = array.new_label()

clearDrawings() =>
    if array.size(lines) > 0
        for i = 0 to array.size(lines) - 1
            line.delete(array.get(lines, i))
        array.clear(lines)

    if array.size(labels) > 0
        for i = 0 to array.size(labels) - 1
            label.delete(array.get(labels, i))
        array.clear(labels)

// Drawing helpers
drawDetectedLabel(_time, _index, _price, _text, _color, _labelStyle, _lineStyle, _isTop) =>
    if not na(_time) and not na(_index) and not na(_price)
        l = line.new(
             x1 = _time,
             y1 = low,
             x2 = _time,
             y2 = high,
             xloc = xloc.bar_time,
             extend = extend.both,
             color = _color,
             width = 2,
             style = _lineStyle
        )
        array.push(lines, l)

        if showLabels
            lb = label.new(
                 x = _index,
                 y = labelRailPrice(_isTop),
                 text = _text,
                 xloc = xloc.bar_index,
                 yloc = yloc.price,
                 style = _labelStyle,
                 color = _color,
                 textcolor = color.white
            )
            array.push(labels, lb)

drawProjectedLabel(_time, _text, _color, _labelStyle, _lineStyle, _isTop) =>
    if not na(_time)
        l = line.new(
             x1 = _time,
             y1 = low,
             x2 = _time,
             y2 = high,
             xloc = xloc.bar_time,
             extend = extend.both,
             color = _color,
             width = 2,
             style = _lineStyle
        )
        array.push(lines, l)

        if showLabels
            lb = label.new(
                 x = _time,
                 y = labelRailPrice(_isTop),
                 text = _text,
                 xloc = xloc.bar_time,
                 yloc = yloc.price,
                 style = _labelStyle,
                 color = _color,
                 textcolor = color.white
            )
            array.push(labels, lb)

// Draw everything
if barstate.islast
    clearDrawings()

    if showDetectedLines
        drawDetectedLabel(
             bearLow2018Time,
             bearLow2018Index,
             bearLow2018Price,
             "Detected Bear Low\n2018",
             color.gray,
             label.style_label_up,
             line.style_solid,
             false
        )

        drawDetectedLabel(
             bullTop2021Time,
             bullTop2021Index,
             bullTop2021Price,
             "Detected Bull Top\n2021\nBull Phase: " + str.tostring(bullDays1) + " days",
             color.orange,
             label.style_label_down,
             line.style_solid,
             true
        )

        drawDetectedLabel(
             bearLow2022Time,
             bearLow2022Index,
             bearLow2022Price,
             "Detected Bear Low\n2022\nBear Phase: " + str.tostring(bearDays1) + " days",
             color.blue,
             label.style_label_up,
             line.style_solid,
             false
        )

        drawDetectedLabel(
             bullTop2025Time,
             bullTop2025Index,
             bullTop2025Price,
             "Detected Bull Top / ATH\n2025\nBull Phase: " + str.tostring(bullDays2) + " days",
             color.orange,
             label.style_label_down,
             line.style_solid,
             true
        )

        if showLiveFutureLow and not na(currentBearLowTime)
            liveBearDays = daysBetween(bullTop2025Time, currentBearLowTime)

            drawDetectedLabel(
                 currentBearLowTime,
                 currentBearLowIndex,
                 currentBearLowPrice,
                 "Current Bear Low So Far\n" + str.tostring(liveBearDays) + " days after top",
                 color.purple,
                 label.style_label_up,
                 line.style_dotted,
                 false
            )

    if showProjectedLines and not na(projectedBearLowTime)
        drawProjectedLabel(
             projectedBearLowTime,
             "Projected Bear Low\nBear Projection: " + str.tostring(projectedBearDays) + " days",
             color.blue,
             label.style_label_up,
             line.style_dashed,
             false
        )

        futureStart = projectedBearLowTime

        for i = 0 to futureProjectionCycles - 1
            futureBullTop = futureStart + projectedBullDays * dayMs
            futureBearLow = futureBullTop + projectedBearDays * dayMs

            drawProjectedLabel(
                 futureBullTop,
                 "Projected Bull Top\nBull Projection: " + str.tostring(projectedBullDays) + " days",
                 color.orange,
                 label.style_label_down,
                 line.style_dashed,
                 true
            )

            drawProjectedLabel(
                 futureBearLow,
                 "Projected Bear Low\nBear Projection: " + str.tostring(projectedBearDays) + " days",
                 color.blue,
                 label.style_label_up,
                 line.style_dashed,
                 false
            )

            futureStart := futureBearLow
````
