# Volume with Average + Weak Move + BOS

- url: https://www.tradingview.com/script/GTOJJ094-Volume-with-Average-Weak-Move-BOS/
- type: indicator
- pine_id: PUB;15f70581a0b0465188515c5eee2eb1f0
- version: 1.0

## Description

**Volume + trend strength + fake move detector with structure (BOS).**

## Source Code

````pine
//@version=5
indicator("Volume with Average + Weak Move + BOS", overlay=false)

// Inputs
avgLength = input.int(20, title="Volume Average Length")
atrLength = input.int(14, title="ATR Length")
atrMult   = input.float(1.5, title="Sharp Move Threshold (ATR Multiplier)")
lookback  = input.int(10, title="BOS Lookback Length")
avgColor  = input.color(color.yellow, title="Average Line Color")

// Calculations
volumeAvg = ta.sma(volume, avgLength)
atrValue  = ta.atr(atrLength)

// Price movement detection
candleRange = high - low
isSharpMove = candleRange > atrValue * atrMult

// Volume condition
isLowVolume = volume < volumeAvg

// Direction
isBull = close > open
isBear = close < open

// ✅ Weak move (sharp move + low volume)
weakMove = isSharpMove and isLowVolume

// --------------------
// 🔥 BOS LOGIC
// --------------------
// Swing highs/lows
prevHigh = ta.highest(high, lookback)[1]
prevLow  = ta.lowest(low, lookback)[1]

// Break of Structure
bosBull = close > prevHigh
bosBear = close < prevLow

// --------------------
// 🎨 COLOR LOGIC
// --------------------
barColor =
     weakMove        ? color.red :     // <-- changed to RED
     isBull          ? color.black :
                       color.gray

// --------------------
// 📊 PLOTS
// --------------------
plot(volume, title="Volume", style=plot.style_columns, color=barColor)
plot(volumeAvg, title="Volume Average", color=avgColor, linewidth=2)

// BOS markers
plotshape(bosBull, title="Bullish BOS", location=location.bottom, 
     color=color.green, style=shape.triangleup, size=size.small)

plotshape(bosBear, title="Bearish BOS", location=location.top, 
     color=color.red, style=shape.triangledown, size=size.small)
````
