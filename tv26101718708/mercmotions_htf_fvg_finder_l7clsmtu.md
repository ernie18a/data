# MercMotions HTF FVG Finder

- url: https://www.tradingview.com/script/l7cLsmTU-MercMotions-HTF-FVG-Finder/
- type: indicator
- pine_id: PUB;e0190f34f4044a33938f03b1a4b365a5
- version: 1.0

## Description

This indicator identifies and displays Fair Value Gaps (FVGs) from the 15-minute, 30-minute, 1-hour, and 4-hour timeframes directly on the chart. Each gap is automatically tracked as price interacts with it, allowing traders to clearly see important higher-timeframe imbalance zones without having to manually mark them. The indicator focuses on keeping the chart clean while preserving the key information needed to understand where higher-timeframe price inefficiencies exist.

The indicator also tracks how each FVG develops as price trades through the zone, including remaining unfilled portions and important levels such as the Consequent Encroachment (CE). Colors and visual settings can be customized to fit your chart and trading style. The goal is to provide a simple way to identify higher-timeframe FVGs and monitor whether price respects, fills, or breaks through these zones.

## Source Code

````pine
//@version=6
indicator("HTF FVG Levels - Remaining Unfilled", overlay=true, max_boxes_count=500)

// ─────────────────────────────────────────────
// SETTINGS
// ─────────────────────────────────────────────

fvgColor = input.color(color.blue, "FVG Color")
fillTransparency = input.int(88, "Fill Transparency", minval=0, maxval=100)
maxFVGs = input.int(200, "Maximum FVGs", minval=1, maxval=500)
lookbackMonths = input.int(4, "FVG Lookback (Months)", minval=1, maxval=24)

// ─────────────────────────────────────────────
// LOOKBACK
// ─────────────────────────────────────────────

lookbackTime = timenow - lookbackMonths * 30 * 24 * 60 * 60 * 1000
withinLookback = time >= lookbackTime

// ─────────────────────────────────────────────
// FVG DETECTION
// ─────────────────────────────────────────────

bullFVG = low > high[2]
bearFVG = high < low[2]

// ─────────────────────────────────────────────
// STORAGE
// ─────────────────────────────────────────────

var box[] boxes = array.new_box()
var float[] originalTop = array.new_float()
var float[] originalBottom = array.new_float()
var float[] remainingTop = array.new_float()
var float[] remainingBottom = array.new_float()
var int[] directions = array.new_int()

// ─────────────────────────────────────────────
// CREATE BULLISH FVG
// ─────────────────────────────────────────────

if barstate.isconfirmed and withinLookback and bullFVG
    float top = low
    float bottom = high[2]

    newBox = box.new(
         left = bar_index - 2,
         right = bar_index,
         top = top,
         bottom = bottom,
         bgcolor = color.new(fvgColor, fillTransparency),
         border_color = color.new(fvgColor, 100)
     )

    array.push(boxes, newBox)
    array.push(originalTop, top)
    array.push(originalBottom, bottom)
    array.push(remainingTop, top)
    array.push(remainingBottom, bottom)
    array.push(directions, 1)

// ─────────────────────────────────────────────
// CREATE BEARISH FVG
// ─────────────────────────────────────────────

if barstate.isconfirmed and withinLookback and bearFVG
    float top = low[2]
    float bottom = high

    newBox = box.new(
         left = bar_index - 2,
         right = bar_index,
         top = top,
         bottom = bottom,
         bgcolor = color.new(fvgColor, fillTransparency),
         border_color = color.new(fvgColor, 100)
     )

    array.push(boxes, newBox)
    array.push(originalTop, top)
    array.push(originalBottom, bottom)
    array.push(remainingTop, top)
    array.push(remainingBottom, bottom)
    array.push(directions, -1)

// ─────────────────────────────────────────────
// UPDATE REMAINING UNFILLED PORTION
// ─────────────────────────────────────────────

if array.size(boxes) > 0
    for i = array.size(boxes) - 1 to 0

        currentBox = array.get(boxes, i)
        origTop = array.get(originalTop, i)
        origBottom = array.get(originalBottom, i)
        remTop = array.get(remainingTop, i)
        remBottom = array.get(remainingBottom, i)
        direction = array.get(directions, i)

        // BULLISH
        if direction == 1
            if low <= remBottom
                box.delete(currentBox)
                array.remove(boxes, i)
                array.remove(originalTop, i)
                array.remove(originalBottom, i)
                array.remove(remainingTop, i)
                array.remove(remainingBottom, i)
                array.remove(directions, i)

            else if low < remTop
                remTop := low
                array.set(remainingTop, i, remTop)
                box.set_top(currentBox, remTop)
                box.set_bottom(currentBox, remBottom)
                box.set_right(currentBox, bar_index)

            else
                box.set_right(currentBox, bar_index)

        // BEARISH
        else
            if high >= remTop
                box.delete(currentBox)
                array.remove(boxes, i)
                array.remove(originalTop, i)
                array.remove(originalBottom, i)
                array.remove(remainingTop, i)
                array.remove(remainingBottom, i)
                array.remove(directions, i)

            else if high > remBottom
                remBottom := high
                array.set(remainingBottom, i, remBottom)
                box.set_top(currentBox, remTop)
                box.set_bottom(currentBox, remBottom)
                box.set_right(currentBox, bar_index)

            else
                box.set_right(currentBox, bar_index)

// ─────────────────────────────────────────────
// REMOVE FVGs OLDER THAN LOOKBACK
// ─────────────────────────────────────────────

if array.size(boxes) > 0
    for i = array.size(boxes) - 1 to 0
        currentBox = array.get(boxes, i)
        boxLeft = box.get_left(currentBox)

        if time[bar_index - boxLeft] < lookbackTime
            box.delete(currentBox)
            array.remove(boxes, i)
            array.remove(originalTop, i)
            array.remove(originalBottom, i)
            array.remove(remainingTop, i)
            array.remove(remainingBottom, i)
            array.remove(directions, i)

// ─────────────────────────────────────────────
// LIMIT NUMBER OF ACTIVE FVGs
// ─────────────────────────────────────────────

while array.size(boxes) > maxFVGs
    oldBox = array.shift(boxes)
    box.delete(oldBox)

    array.shift(originalTop)
    array.shift(originalBottom)
    array.shift(remainingTop)
    array.shift(remainingBottom)
    array.shift(directions)
````
