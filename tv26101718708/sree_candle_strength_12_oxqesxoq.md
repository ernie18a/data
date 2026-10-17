#  SREE Candle STrength ($1.2+)

- url: https://www.tradingview.com/script/OxqEsXoq-SREE-Candle-STrength-1-2/
- type: indicator
- pine_id: PUB;47923673d2404d7ea55ed8b78f2b20c3
- version: 3.0

## Description

identify candles with 1.2$ range

identify candles with 1.2$ range

identify candles with 1.2$ range

## Source Code

````pine
//@version=5
indicator(" Script", overlay=true)
//
plotshape(close > open, location=location.belowbar, style=shape.triangleup, color=color.green, size=size.tiny)
plotshape(close < open, location=location.abovebar, style=shape.triangledown, color=color.red, size=size.tiny)
````
