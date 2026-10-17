# Price Gap Identifier

- url: https://www.tradingview.com/script/tpMPnRFR-Price-Gap-Identifier/
- type: indicator
- pine_id: PUB;f572fa482aab42089b0baeb46222c50c
- version: 1.0

## Description

Identify price gaps.
Green = potential support gap
Red = potential resistance gaps\

## Source Code

````pine
//@version=5
indicator("Price Gap Detector", overlay=true, max_boxes_count=500)

showBullishGaps = input.bool(true, "Show Bullish Gaps")
showBearishGaps = input.bool(true, "Show Bearish Gaps")
bullColor = input.color(color.new(color.green, 80), "Bullish Gap Color")
bearColor = input.color(color.new(color.red, 80), "Bearish Gap Color")
minGapSize = input.float(0.0, "Min Gap Size (0 = any)", minval=0.0)

gapUp = low > high[1]
gapDown = high < low[1]

gapUpSize = gapUp ? low - high[1] : 0.0
gapDownSize = gapDown ? low[1] - high : 0.0

if showBullishGaps and gapUp and gapUpSize >= minGapSize
    box.new(bar_index - 1, low, bar_index + 20, high[1], border_color=color.rgb(29, 32, 29), border_width=1, bgcolor=bullColor)

if showBearishGaps and gapDown and gapDownSize >= minGapSize
    box.new(bar_index - 1, low[1], bar_index + 20, high, border_color=color.rgb(39, 32, 32), border_width=1, bgcolor=bearColor)
````
