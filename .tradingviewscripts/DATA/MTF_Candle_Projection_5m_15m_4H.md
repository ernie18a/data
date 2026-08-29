<!-- tradingview-pine-id: PUB;82e6a30f1e934ae392f22d052372259a -->
<!-- tradingviewscripts-format: 1 -->
# MTF Candle Projection — 5m / 15m / 4H

Source: https://www.tradingview.com/script/1kJSq8rO-MTF-Candle-Projection-5m-15m-4hr/

## Description

Multi-Timeframe Projection Suite

The Multi-Timeframe Projection Suite is designed for traders who execute on the 1-minute chart while maintaining awareness of higher-timeframe structure without constantly switching between charts.

This indicator projects multiple higher-timeframe candles directly onto the right side of the 1-minute chart, allowing users to view market context and short-term momentum in a single workspace.

Features

* Displays the last hour of 5-minute price action (12 candles).
* Displays the last hour of 15-minute price action (4 candles).
* Displays the currently active 4-hour candle.
* Individual on/off toggles for each timeframe.
* Customizable bullish and bearish colors for every timeframe.
* Adjustable candle-body and wick opacity settings.
* Adjustable spacing and positioning on the chart.
* Optional timeframe labels.

Intended Use

This indicator was built for traders who enter and manage positions on the 1-minute timeframe but rely on higher-timeframe market structure for confirmation. By projecting recent 5-minute and 15-minute candles alongside the active 4-hour candle, traders can quickly identify:

* Short-term momentum shifts.
* Higher-timeframe trend direction.
* Market compression and expansion.
* Potential support and resistance zones.
* Alignment between execution and broader market structure.

Recommended Workflow

* Use the 4-hour candle to determine overall market bias.
* Use the 15-minute projection to identify intermediate structure and momentum.
* Use the 5-minute projection to monitor recent price behavior.
* Execute entries and exits on the 1-minute chart.

Notes

This indicator is intended to provide visual context only and does not generate buy or sell signals. It is designed to supplement an existing trading strategy and should be used alongside proper risk management.

---

## Source Code

````pine
//@version=6
indicator("MTF Candle Projection — 5m / 15m / 4H", overlay=true, max_boxes_count=100, max_lines_count=100, max_labels_count=20)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DISPLAY SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

rightOffset = input.int(5, "Distance From Current Price", minval=1, maxval=100)
candleWidth = input.int(2, "Projected Candle Width", minval=1, maxval=5)
candleGap   = input.int(1, "Space Between Candles", minval=0, maxval=5)
groupGap    = input.int(5, "Space Between Timeframes", minval=1, maxval=20)

showLabels = input.bool(true, "Show Timeframe Labels")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 5-MINUTE SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

show5m       = input.bool(true, "Show 5-Minute Candles", group="5-Minute")
bull5m       = input.color(color.lime, "Bullish Color", group="5-Minute")
bear5m       = input.color(color.red, "Bearish Color", group="5-Minute")
opacity5m    = input.int(20, "Body Opacity", minval=0, maxval=100, group="5-Minute")
wickOpacity5 = input.int(0, "Wick Opacity", minval=0, maxval=100, group="5-Minute")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 15-MINUTE SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

show15m       = input.bool(true, "Show 15-Minute Candles", group="15-Minute")
bull15m       = input.color(color.aqua, "Bullish Color", group="15-Minute")
bear15m       = input.color(color.orange, "Bearish Color", group="15-Minute")
opacity15m    = input.int(20, "Body Opacity", minval=0, maxval=100, group="15-Minute")
wickOpacity15 = input.int(0, "Wick Opacity", minval=0, maxval=100, group="15-Minute")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 4-HOUR SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

show4h       = input.bool(true, "Show Active 4-Hour Candle", group="4-Hour")
bull4h       = input.color(color.blue, "Bullish Color", group="4-Hour")
bear4h       = input.color(color.purple, "Bearish Color", group="4-Hour")
opacity4h    = input.int(20, "Body Opacity", minval=0, maxval=100, group="4-Hour")
wickOpacity4 = input.int(0, "Wick Opacity", minval=0, maxval=100, group="4-Hour")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STORAGE ARRAYS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var array<float> opens5  = array.new_float()
var array<float> highs5  = array.new_float()
var array<float> lows5   = array.new_float()
var array<float> closes5 = array.new_float()

var array<float> opens15  = array.new_float()
var array<float> highs15  = array.new_float()
var array<float> lows15   = array.new_float()
var array<float> closes15 = array.new_float()

var array<box> projectedBodies = array.new_box()
var array<line> projectedWicks = array.new_line()
var array<label> projectedLabels = array.new_label()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BUILD 5-MINUTE CANDLES FROM THE CHART DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

new5m = ta.change(time("5")) != 0

if array.size(opens5) == 0
    array.unshift(opens5, open)
    array.unshift(highs5, high)
    array.unshift(lows5, low)
    array.unshift(closes5, close)
else
    if new5m
        array.unshift(opens5, open)
        array.unshift(highs5, high)
        array.unshift(lows5, low)
        array.unshift(closes5, close)

        if array.size(opens5) > 12
            array.pop(opens5)
            array.pop(highs5)
            array.pop(lows5)
            array.pop(closes5)
    else
        array.set(highs5, 0, math.max(array.get(highs5, 0), high))
        array.set(lows5, 0, math.min(array.get(lows5, 0), low))
        array.set(closes5, 0, close)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BUILD 15-MINUTE CANDLES FROM THE CHART DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

new15m = ta.change(time("15")) != 0

if array.size(opens15) == 0
    array.unshift(opens15, open)
    array.unshift(highs15, high)
    array.unshift(lows15, low)
    array.unshift(closes15, close)
else
    if new15m
        array.unshift(opens15, open)
        array.unshift(highs15, high)
        array.unshift(lows15, low)
        array.unshift(closes15, close)

        if array.size(opens15) > 4
            array.pop(opens15)
            array.pop(highs15)
            array.pop(lows15)
            array.pop(closes15)
    else
        array.set(highs15, 0, math.max(array.get(highs15, 0), high))
        array.set(lows15, 0, math.min(array.get(lows15, 0), low))
        array.set(closes15, 0, close)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ACTIVE 4-HOUR CANDLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[open4h, high4h, low4h, close4h] = request.security(
     syminfo.tickerid,
     "240",
     [open, high, low, close],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CANDLE DRAWING FUNCTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

drawCandle(
     int leftPosition,
     float candleOpen,
     float candleHigh,
     float candleLow,
     float candleClose,
     color bullishColor,
     color bearishColor,
     int bodyOpacity,
     int wickOpacity) =>

    candleColor = candleClose >= candleOpen ? bullishColor : bearishColor

    bodyTop = math.max(candleOpen, candleClose)
    bodyBottom = math.min(candleOpen, candleClose)

    // Give doji candles a visible body.
    if bodyTop == bodyBottom
        bodyTop += syminfo.mintick
        bodyBottom -= syminfo.mintick

    rightPosition = leftPosition + candleWidth
    centerPosition = leftPosition + int(math.floor(candleWidth / 2.0))

    candleWick = line.new(
         x1=centerPosition,
         y1=candleHigh,
         x2=centerPosition,
         y2=candleLow,
         xloc=xloc.bar_index,
         color=color.new(candleColor, wickOpacity),
         width=1)

    candleBody = box.new(
         left=leftPosition,
         top=bodyTop,
         right=rightPosition,
         bottom=bodyBottom,
         xloc=xloc.bar_index,
         border_color=color.new(candleColor, wickOpacity),
         bgcolor=color.new(candleColor, bodyOpacity))

    array.push(projectedWicks, candleWick)
    array.push(projectedBodies, candleBody)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DELETE AND REDRAW ON THE LAST BAR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if barstate.islast
    while array.size(projectedBodies) > 0
        box.delete(array.pop(projectedBodies))

    while array.size(projectedWicks) > 0
        line.delete(array.pop(projectedWicks))

    while array.size(projectedLabels) > 0
        label.delete(array.pop(projectedLabels))

    candleStep = candleWidth + candleGap

    base5m = bar_index + rightOffset
    base15m = base5m + 12 * candleStep + groupGap
    base4h = base15m + 4 * candleStep + groupGap

    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // DRAW 5-MINUTE CANDLES
    // Oldest candle is drawn on the left.
    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    if show5m
        count5m = array.size(opens5)

        if count5m > 0
            for position = 0 to count5m - 1
                arrayIndex = count5m - 1 - position
                candleX = base5m + position * candleStep

                drawCandle(
                     candleX,
                     array.get(opens5, arrayIndex),
                     array.get(highs5, arrayIndex),
                     array.get(lows5, arrayIndex),
                     array.get(closes5, arrayIndex),
                     bull5m,
                     bear5m,
                     opacity5m,
                     wickOpacity5)

            if showLabels
                label5m = label.new(
                     x=base5m + int((count5m * candleStep) / 2),
                     y=array.get(highs5, 0),
                     text="5 MIN — LAST HOUR",
                     xloc=xloc.bar_index,
                     style=label.style_label_down,
                     color=color.new(color.black, 100),
                     textcolor=color.new(bull5m, 0),
                     size=size.small)

                array.push(projectedLabels, label5m)

    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // DRAW 15-MINUTE CANDLES
    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    if show15m
        count15m = array.size(opens15)

        if count15m > 0
            for position = 0 to count15m - 1
                arrayIndex = count15m - 1 - position
                candleX = base15m + position * candleStep

                drawCandle(
                     candleX,
                     array.get(opens15, arrayIndex),
                     array.get(highs15, arrayIndex),
                     array.get(lows15, arrayIndex),
                     array.get(closes15, arrayIndex),
                     bull15m,
                     bear15m,
                     opacity15m,
                     wickOpacity15)

            if showLabels
                label15m = label.new(
                     x=base15m + int((count15m * candleStep) / 2),
                     y=array.get(highs15, 0),
                     text="15 MIN — LAST HOUR",
                     xloc=xloc.bar_index,
                     style=label.style_label_down,
                     color=color.new(color.black, 100),
                     textcolor=color.new(bull15m, 0),
                     size=size.small)

                array.push(projectedLabels, label15m)

    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // DRAW ACTIVE 4-HOUR CANDLE
    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    if show4h and not na(open4h)
        drawCandle(
             base4h,
             open4h,
             high4h,
             low4h,
             close4h,
             bull4h,
             bear4h,
             opacity4h,
             wickOpacity4)

        if showLabels
            label4h = label.new(
                 x=base4h + int(math.floor(candleWidth / 2.0)),
                 y=high4h,
                 text="ACTIVE 4H",
                 xloc=xloc.bar_index,
                 style=label.style_label_down,
                 color=color.new(color.black, 100),
                 textcolor=close4h >= open4h ? bull4h : bear4h,
                 size=size.small)

            array.push(projectedLabels, label4h)
````
