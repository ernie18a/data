# Strong Candle + Volume Spike (Arrows)

- url: https://www.tradingview.com/script/Pv0otuxn-Strong-Candle-Volume-Spike-Arrows/
- type: indicator
- pine_id: PUB;c0447ed961fa4fdc844c6d7fa42566c4
- version: 1.0

## Description

Identifying strong candle for breakout trading based on candle range, close of candle, ATR and volume

## Source Code

````pine
//@version=6
indicator("Strong Candle + Volume Spike (Arrows)", overlay=true)

// Inputs
bodyRatioThreshold = input.float(0.6)
closePositionThreshold = input.float(0.7)
atrLength = input.int(14)
atrMultiplier = input.float(1.0)
volLength = input.int(20)
volMultiplier = input.float(1.5)

// Calculations
bodySize = math.abs(close - open)
rangeSize = high - low

bodyRatio = rangeSize > 0 ? bodySize / rangeSize : 0

closeNearHigh = rangeSize > 0 ? (close - low) / rangeSize : 0
closeNearLow  = rangeSize > 0 ? (high - close) / rangeSize : 0

atr = ta.atr(atrLength)
strongRange = rangeSize > (atr * atrMultiplier)

volMA = ta.sma(volume, volLength)
volumeSpike = volume > (volMA * volMultiplier)

isBullish = close > open
isBearish = close < open

strongBull = (isBullish and bodyRatio >= bodyRatioThreshold and strongRange and closeNearHigh >= closePositionThreshold and volumeSpike)
strongBear = (isBearish and bodyRatio >= bodyRatioThreshold and strongRange and closeNearLow >= closePositionThreshold and volumeSpike)

// Arrows
plotshape(strongBull, location=location.belowbar, color=color.green, style=shape.arrowup, size=size.small)
plotshape(strongBear, location=location.abovebar, color=color.red, style=shape.arrowdown, size=size.small)

// Candle color
barcolor(strongBull ? color.lime : strongBear ? color.red : na)
````
