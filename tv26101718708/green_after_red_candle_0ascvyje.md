# Green After Red Candle

- url: https://www.tradingview.com/script/0aSCVYJe-Green-After-Red-Candle/
- type: indicator
- pine_id: PUB;69f465dd8b6347edb915b477a9493660
- version: 1.0

## Description

Prompts appearance of a green candle after a red candle.

## Source Code

````pine
//@version=6
indicator('Green After Red Candle', overlay = true)

// ─── Conditions ───────────────────────────────────────────────
prevCandleRed = close[1] < open[1] // Previous closed candle was red
currCandleGreen = close[0] > open[0] // Latest closed candle is green

// ─── Signal ───────────────────────────────────────────────────
signal = prevCandleRed and currCandleGreen

// ─── Plot ─────────────────────────────────────────────────────
plotshape(series = signal, title = 'Green After Red', style = shape.triangleup, location = location.belowbar, color = color.new(color.lime, 0), size = size.small, text = 'G▲R')

// ─── Alert Condition ──────────────────────────────────────────
alertcondition(condition = signal, title = 'Green After Red Candle', message = '🟢 Green candle closed after Red — {{ticker}} | {{interval}} | Price: {{close}}')
````
