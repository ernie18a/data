# CC_Setup

- url: https://www.tradingview.com/script/CarG3LZW-CC-Setup/
- type: indicator
- pine_id: PUB;c4fe1e1d36044da2a2f5e9cc2d69d743
- version: 1.0

## Description

Pattern Rules

Hammer: Body ≤35% of range, lower shadow ≥2× body, minimal upper shadow
Bullish Engulfing: Must be bearish close → bullish open, opening at/below prior close and closing above prior open

## Source Code

````pine
//@version=5
indicator("CC_Setup", overlay=true)

hammerBody   = math.abs(close[1] - open[1])
hammerRange  = high[1] - low[1]
lowerShadow  = math.min(open[1], close[1]) - low[1]
upperShadow  = high[1] - math.max(open[1], close[1])

isHammer = hammerRange > 0 and
  (hammerBody / hammerRange <= 0.35) and
  (lowerShadow >= hammerBody * 2.0) and
  (upperShadow <= hammerBody * 1.2)

isBullEngulf = close[1] < open[1] and
  close > open and
  open <= close[1] and
  close >= open[1]

signal = isHammer and isBullEngulf

plotshape(signal, title="H+BE Signal",
  location=location.belowbar,
  style=shape.triangleup,
  color=color.new(color.orange, 0),
  size=size.normal,
  text="H+BE")

bgcolor(signal ? color.new(color.green, 88) : na)

alertcondition(signal, title="Hammer + Bullish Engulfing",
  message="{{ticker}} — Hammer + Bullish Engulfing on Daily")
````
