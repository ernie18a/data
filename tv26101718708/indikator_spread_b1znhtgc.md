# Indikator Spread

- url: https://www.tradingview.com/script/B1ZNhtGC/
- type: indicator
- pine_id: PUB;30bc699ee8824410801e77c7b298b1ba
- version: 1.0

## Description

This indicator calculates the spread between two indicators

## Source Code

````pine
//@version=5
indicator("Spread", overlay=false, max_bars_back=500)

// Inputs
s1 = input.source(close, title="Quelle 1")
s2 = input.source(close, title="Quelle 2")
offset = input.int(0, title="Offset (Bars)", minval=-500, maxval=500)

// Spread
spread = s1 - s2

// Plot
plot(spread, title="Spread", color=color.new(color.blue, 0), offset=offset)
hline(0, color=color.gray, linestyle=hline.style_dashed)
````
