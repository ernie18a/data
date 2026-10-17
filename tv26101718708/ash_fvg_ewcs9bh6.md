# ASH FVG

- url: https://www.tradingview.com/script/EwCS9bH6-ASH-FVG/
- type: indicator
- pine_id: PUB;0a18a565b17f46e3a097784d709f4b48
- version: 1.0

## Description

GM - FVG indicator with 50% mid point.

FVG's disappear once price has re balanced.

Green = bullish.
Red = bearish.

Works on all timeframes.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ashley_poulson1995

//@version=5
indicator("FVG + 50% Midline", overlay=true, max_boxes_count=500, max_lines_count=500)

//━━━━━━━━ SETTINGS ━━━━━━━━//
bullColor = input.color(color.new(color.green, 85), "Bullish FVG")
bearColor = input.color(color.new(color.red, 85), "Bearish FVG")

bullLineColor = input.color(color.green, "Bullish Midline")
bearLineColor = input.color(color.red, "Bearish Midline")

extendBars = input.int(30, "Extend Bars", minval=1)

//━━━━━━━━ ARRAYS ━━━━━━━━//
var box[] boxes = array.new_box()
var line[] mids = array.new_line()

var float[] tops = array.new_float()
var float[] bottoms = array.new_float()

var bool[] bullishArr = array.new_bool()

//━━━━━━━━ BULLISH FVG ━━━━━━━━//
// low > high[2]

if low > high[2]

    top = low
    bottom = high[2]
    mid = (top + bottom) / 2

    b = box.new(
         left=bar_index-2,
         right=bar_index+extendBars,
         top=top,
         bottom=bottom,
         bgcolor=bullColor,
         border_color=color.green
     )

    l = line.new(
         x1=bar_index-2,
         y1=mid,
         x2=bar_index+extendBars,
         y2=mid,
         color=bullLineColor,
         width=2
     )

    array.push(boxes, b)
    array.push(mids, l)

    array.push(tops, top)
    array.push(bottoms, bottom)

    array.push(bullishArr, true)


//━━━━━━━━ BEARISH FVG ━━━━━━━━//
// high < low[2]

if high < low[2]

    top = low[2]
    bottom = high
    mid = (top + bottom) / 2

    b = box.new(
         left=bar_index-2,
         right=bar_index+extendBars,
         top=top,
         bottom=bottom,
         bgcolor=bearColor,
         border_color=color.red
     )

    l = line.new(
         x1=bar_index-2,
         y1=mid,
         x2=bar_index+extendBars,
         y2=mid,
         color=bearLineColor,
         width=2
     )

    array.push(boxes, b)
    array.push(mids, l)

    array.push(tops, top)
    array.push(bottoms, bottom)

    array.push(bullishArr, false)


//━━━━━━━━ DELETE FILLED FVGs ━━━━━━━━//

if array.size(boxes) > 0

    for i = array.size(boxes) - 1 to 0

        isBull = array.get(bullishArr, i)

        top = array.get(tops, i)
        bottom = array.get(bottoms, i)

        filled = false

        // Bullish FVG filled
        if isBull and low <= bottom
            filled := true

        // Bearish FVG filled
        if not isBull and high >= top
            filled := true

        if filled

            box.delete(array.get(boxes, i))
            line.delete(array.get(mids, i))

            array.remove(boxes, i)
            array.remove(mids, i)

            array.remove(tops, i)
            array.remove(bottoms, i)

            array.remove(bullishArr, i)
````
