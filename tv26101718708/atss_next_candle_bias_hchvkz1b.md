# ATSS Next Candle Bias

- url: https://www.tradingview.com/script/hCHVKz1B-ATSS-Next-Candle-Bias/
- type: indicator
- pine_id: PUB;64ec8dccce444c3abbbbba55ae67c1c6
- version: 1.0

## Description

Simple minimalist script to display next candle biad, showing assessment and number of supporting tests, e.g. Bull 4/5 or Bear 5/5

## Source Code

````pine
//@version=6
indicator("ATSS Next Candle Bias", overlay=true, max_labels_count=500)

// Inputs
showLabel = input.bool(true, "Show label")
emaLen = input.int(50, minval=1, title="Trend EMA")
bodyMin = input.float(0.50, minval=0.0, maxval=1.0, title="Minimum body / range")
closeZone = input.float(0.25, minval=0.0, maxval=0.5, title="Close zone")
labelOffsetAtr = input.float(1.5, minval=0.0, title="Label offset ATR")

// Confirmed candle only
o = open[1]
h = high[1]
l = low[1]
c = close[1]

prevHigh = high[2]
prevLow = low[2]

ema = ta.ema(close, emaLen)
emaC = ema[1]
atr = ta.atr(14)

// Candle structure
rng = h - l
body = math.abs(c - o)
bodyRatio = rng > 0 ? body / rng : 0

bullCandle = c > o
bearCandle = c < o

closeNearHigh = rng > 0 ? c >= h - rng * closeZone : false
closeNearLow = rng > 0 ? c <= l + rng * closeZone : false

strongBody = bodyRatio >= bodyMin

// Breakout / location
brokePrevHigh = c > prevHigh
brokePrevLow = c < prevLow

aboveEma = c > emaC
belowEma = c < emaC

// Bias model
bullBias = bullCandle and closeNearHigh and strongBody and brokePrevHigh and aboveEma
bearBias = bearCandle and closeNearLow and strongBody and brokePrevLow and belowEma

// Softer bias when most, but not all, conditions agree
bullScore =
     (bullCandle ? 1 : 0) +
     (closeNearHigh ? 1 : 0) +
     (strongBody ? 1 : 0) +
     (brokePrevHigh ? 1 : 0) +
     (aboveEma ? 1 : 0)

bearScore =
     (bearCandle ? 1 : 0) +
     (closeNearLow ? 1 : 0) +
     (strongBody ? 1 : 0) +
     (brokePrevLow ? 1 : 0) +
     (belowEma ? 1 : 0)

softBull = not bullBias and bullScore >= 4 and bullScore > bearScore
softBear = not bearBias and bearScore >= 4 and bearScore > bullScore

labelText =
     bullBias ? "BULL " + str.tostring(bullScore) + "/5" :
     bearBias ? "BEAR " + str.tostring(bearScore) + "/5" :
     softBull ? "bull " + str.tostring(bullScore) + "/5" :
     softBear ? "bear " + str.tostring(bearScore) + "/5" :
     "NEUTRAL"

labelColor =
     bullBias ? color.lime :
     bearBias ? color.red :
     softBull ? color.green :
     softBear ? color.maroon :
     color.gray

var label biasLabel = na

if barstate.islast and showLabel and bar_index > 2
    label.delete(biasLabel)
    biasLabel := label.new(
         bar_index[1],
         h + atr[1] * labelOffsetAtr,
         labelText,
         style=label.style_none,
         textcolor=labelColor,
         size=size.normal
     )

plot(ema, "Trend EMA", color=color.new(color.blue, 0), linewidth=2)
````
