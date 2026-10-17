# Hourly Direction-Change Open Rays

- url: https://www.tradingview.com/script/kO4uSQZU-Hourly-Direction-Change-Open-Rays/
- type: indicator
- pine_id: PUB;aec994c552e64710a92848b5f0c73292
- version: 1.0

## Description

Plots price levels at direction changes of hourly candles

## Source Code

````pine
//@version=5
indicator("Hourly Direction-Change Open Rays", overlay=true, max_lines_count=500, max_labels_count=500)

// === Settings ===
useBodyCrossOnly = input.bool(true, "Cancel only if candle BODY crosses level")
showOnlyHourly   = input.bool(true, "Only draw on 1H chart")
showPrices       = input.bool(true, "Show price labels")
labelOffsetBars  = input.int(15, "Price label offset (bars)", minval=1)

// === Restrict to hourly if desired ===
isHourly = timeframe.period == "60"

if showOnlyHourly and not isHourly
    runtime.error("Switch chart to 1H to use this indicator.")

// === Storage for active rays, prices, and labels ===
var line[] activeLines = array.new_line()
var float[] activePrices = array.new_float()
var label[] activeLabels = array.new_label()

// === Candle direction helpers ===
isUp(idx) =>
    close[idx] > open[idx]

isDown(idx) =>
    close[idx] < open[idx]

// === Detect direction change on current bar ===
dirFlip =
     (isUp(0) and isDown(1)) or
     (isDown(0) and isUp(1))

// === Create new ray at the OPEN of the flip candle ===
if bar_index > 0 and dirFlip
    level = open
    newLine = line.new(
         x1 = bar_index,
         y1 = level,
         x2 = bar_index + 1,
         y2 = level,
         extend = extend.right,
         color = color.white,
         width = 2,
         style = line.style_solid
     )

    label newLabel = na
    if showPrices
        newLabel := label.new(
             x = bar_index + labelOffsetBars,
             y = level,
             text = str.tostring(level, format.mintick),
             style = label.style_label_left,
             color = color.white,
             textcolor = color.black,
             size = size.small
         )

    array.push(activeLines, newLine)
    array.push(activePrices, level)
    array.push(activeLabels, newLabel)

// === Function: has current candle body crossed a level? ===
bodyCross(level) =>
    bodyHigh = math.max(open, close)
    bodyLow  = math.min(open, close)
    bodyLow < level and bodyHigh > level

// Optional full-range cross if desired
rangeCross(level) =>
    low < level and high > level

// === Remove rays when crossed by a future candle body ===
// Loop backwards so deletions are safe
if array.size(activeLines) > 0
    for i = array.size(activeLines) - 1 to 0
        lvl = array.get(activePrices, i)
        crossed = useBodyCrossOnly ? bodyCross(lvl) : rangeCross(lvl)

        createdLine = array.get(activeLines, i)
        createdLabel = array.get(activeLabels, i)
        x1 = line.get_x1(createdLine)
        isFutureBar = bar_index > x1

        // keep the label on the right side of the chart
        if showPrices and not na(createdLabel)
            label.set_x(createdLabel, bar_index + labelOffsetBars)
            label.set_y(createdLabel, lvl)
            label.set_text(createdLabel, str.tostring(lvl, format.mintick))

        if isFutureBar and crossed
            line.delete(createdLine)
            if not na(createdLabel)
                label.delete(createdLabel)
            array.remove(activeLines, i)
            array.remove(activePrices, i)
            array.remove(activeLabels, i)
````
