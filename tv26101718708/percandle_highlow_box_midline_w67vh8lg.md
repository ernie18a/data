# Per-Candle High-Low Box + Midline

- url: https://www.tradingview.com/script/w67VH8lG-Per-Candle-High-Low-Box-Midline/
- type: indicator
- pine_id: PUB;e435a06d385042a0a065c4d7141dca13
- version: 1.0

## Description

Draws a translucent box from each candle’s high to low over a configurable lookback, plus a dotted horizontal line at the midpoint (high + low) / 2.

Each box extends indefinitely to the right so prior candle ranges stay visible as price develops. Midlines use a long finite extension so the dotted style renders correctly.

Inputs

Lookback bars — how many recent candles get a box and midline
Midline extend (bars) — how far the dotted midlines reach into future space
Colors and line width for boxes and midlines
Useful for seeing each bar’s range and equilibrium level at a glance, and how later price interacts with those levels.

## Source Code

````pine
//@version=6
indicator("Per-Candle High-Low Box + Midline", overlay = true, max_boxes_count = 500, max_lines_count = 500)

lookback   = input.int(20, "Lookback bars", minval = 1, maxval = 500)
lineExtend = input.int(500, "Midline extend (bars)", minval = 1)
boxColor   = input.color(color.new(color.teal, 80), "Box fill")
borderColor = input.color(color.teal, "Box border")
midColor   = input.color(color.orange, "Midline color")
midWidth   = input.int(1, "Midline width", minval = 1, maxval = 4)

var box[]  boxes = array.new<box>()
var line[] lines = array.new<line>()

f_clear() =>
    if array.size(boxes) > 0
        for i = 0 to array.size(boxes) - 1
            box.delete(array.get(boxes, i))
        array.clear(boxes)
    if array.size(lines) > 0
        for i = 0 to array.size(lines) - 1
            line.delete(array.get(lines, i))
        array.clear(lines)

if barstate.islast
    f_clear()

    for i = 0 to lookback - 1
        float hi  = high[i]
        float lo  = low[i]
        float mid = (hi + lo) / 2.0
        int left  = bar_index - i

        array.push(boxes, box.new(left, hi, left, lo,
             border_color = borderColor,
             bgcolor      = boxColor,
             border_width = 1,
             extend       = extend.right))

        array.push(lines, line.new(left, mid, bar_index + lineExtend, mid,
             color  = midColor,
             width  = midWidth,
             style  = line.style_dotted,
             extend = extend.none))
````
