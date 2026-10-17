# 1H Range Blocks

- url: https://www.tradingview.com/script/R2Dbg9a2-1H-Range-Blocks/
- type: indicator
- pine_id: PUB;0b6ee0b3accc46ac96edceeb213624a4
- version: 1.0

## Description

1 hour candle range that marke each hourly candle including wicks not excluding

## Source Code

````pine
//@version=6
indicator("1H Range Blocks", overlay=true, max_boxes_count=500)

border = input.color(color.blue)
fill   = input.color(color.new(color.blue, 85))
maxBox = input.int(100)

// stable 1H detection
newHour = time("60") != time("60")[1]

var float h = na
var float l = na
var int startBar = na
var box[] boxes = array.new_box()

if newHour
    // finalize previous hour ONLY
    if not na(h)
        array.push(
            boxes,
            box.new(
                left=startBar,
                right=bar_index - 1,
                top=h,
                bottom=l,
                xloc=xloc.bar_index,
                border_color=border,
                bgcolor=fill
            )
        )

        if array.size(boxes) > maxBox
            box.delete(array.shift(boxes))

    // reset tracking
    startBar := bar_index
    h := high
    l := low

else
    // ONLY data collection, no drawing updates
    h := na(h) ? high : math.max(h, high)
    l := na(l) ? low  : math.min(l, low)
````
