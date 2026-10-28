# Absorption Overlay

- url: https://www.tradingview.com/script/oStJQWHN-Absorption-Overlay/
- type: indicator
- pine_id: PUB;bf25056c71444a8286134788bc205b26
- version: 1.0

## Description

Orderflow absorption detector on  chart. Orderflow absorption detector on  chart. Orderflow absorption detector on  chart

## Source Code

````pine
// Absorption Overlay Markers — add to price chart
// Use together with "Absorption Detector v2" indicator panel
//@version=5
indicator("Absorption Overlay", overlay=true)

// ─── INPUTS (match these to the main indicator) ───
lengthNorm    = input.int(50,    "Normalization Lookback",   minval=10, maxval=200)
trendLen      = input.int(5,     "Trend Context Length",     minval=2,  maxval=20)
absThreshold  = input.float(2.0, "Absorption Threshold (σ)", minval=0.5, step=0.25)
smoothLen     = input.int(3,     "Smoothing Length",         minval=1, maxval=10)

// ─── SAME CORE LOGIC ───
candleRange  = high - low
safeRange    = math.max(candleRange, syminfo.mintick)
rawAbsRatio  = volume / safeRange
absMean      = ta.sma(rawAbsRatio, lengthNorm)
absStd       = ta.stdev(rawAbsRatio, lengthNorm)
safeStd      = math.max(absStd, 0.0001)
absZScore    = (rawAbsRatio - absMean) / safeStd
absSmoothed  = ta.sma(absZScore, smoothLen)

priceChange  = close - close[trendLen]
trendSma     = ta.sma(close, trendLen)
incomingSell = close < trendSma and priceChange < 0
incomingBuy  = close > trendSma and priceChange > 0

isAbsorption     = absSmoothed > absThreshold
isBuyAbsorption  = isAbsorption and incomingSell
isSellAbsorption = isAbsorption and incomingBuy

// ─── OVERLAY MARKERS ───
plotshape(isBuyAbsorption,  "Buy Absorption",  shape.labelup,   location.belowbar, color.new(#00C853, 0), text="ABS", textcolor=color.white, size=size.small)
plotshape(isSellAbsorption, "Sell Absorption", shape.labeldown, location.abovebar, color.new(#FF1744, 0), text="ABS", textcolor=color.white, size=size.small)

// ─── ABSORPTION LEVEL LINES ───
// Draw a short horizontal line at the absorption price level to mark the zone
var line buyLine  = na
var line sellLine = na

if isBuyAbsorption
    buyLine := line.new(bar_index - 2, low, bar_index + 8, low, color=color.new(#00C853, 30), width=2, style=line.style_solid)

if isSellAbsorption
    sellLine := line.new(bar_index - 2, high, bar_index + 8, high, color=color.new(#FF1744, 30), width=2, style=line.style_solid)
````
