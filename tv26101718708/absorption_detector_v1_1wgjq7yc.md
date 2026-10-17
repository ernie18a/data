# Absorption Detector v1

- url: https://www.tradingview.com/script/1WGjQ7YC-Absorption-Detector-v1/
- type: indicator
- pine_id: PUB;396b40cfb4884904b3dea1702a9358b2
- version: 1.0

## Description

Absorption Detector v1Absorption Detector v1Absorption Detector v1Absorption Detector v1Absorption Detector v1Absorption Detector v1Absorption Detector v1Absorption Detector v1Absorption Detector v1

## Source Code

````pine
// This Pine Script™ source code is subject to the terms of the Mozilla Public License 2.0
// © Custom Absorption Indicator

//@version=5
indicator("Absorption Detector", overlay=false, format=format.volume)

// ─── INPUTS ───
lengthNorm   = input.int(50,   "Normalization Lookback",  minval=10, maxval=200)
absThreshold = input.float(2.0, "Absorption Threshold (σ)", minval=0.5, step=0.25, tooltip="How many standard deviations above mean = absorption event")
smoothLen    = input.int(3,    "Smoothing Length",         minval=1, maxval=10)
showDelta    = input.bool(true, "Show Delta Coloring")
showBg       = input.bool(true, "Highlight Absorption Zones")

// ─── CORE CALCULATION ───
// Absorption Ratio: volume relative to candle range
// High ratio = lots of volume absorbed with minimal price movement
candleRange = high - low
safeRange   = math.max(candleRange, syminfo.mintick) // avoid division by zero
rawAbsRatio = volume / safeRange

// Normalize using z-score so it works across any instrument/timeframe
absMean = ta.sma(rawAbsRatio, lengthNorm)
absStd  = ta.stdev(rawAbsRatio, lengthNorm)
safeStd = math.max(absStd, 0.0001)
absZScore = (rawAbsRatio - absMean) / safeStd

// Smooth for readability
absSmoothed = ta.sma(absZScore, smoothLen)

// ─── DELTA APPROXIMATION ───
// Where did price close within the candle?
// Close near high = buyers winning (buy absorption of sell pressure)
// Close near low  = sellers winning (sell absorption of buy pressure)
closePosition = (close - low) / safeRange  // 0 to 1
delta = (closePosition - 0.5) * 2           // -1 to +1

// Weighted delta: only meaningful when absorption is happening
weightedDelta = absSmoothed * delta

// ─── ABSORPTION EVENT DETECTION ───
isAbsorption    = absSmoothed > absThreshold
isBuyAbsorption  = isAbsorption and delta > 0.2
isSellAbsorption = isAbsorption and delta < -0.2

// ─── PLOTTING ───
// Main absorption ratio line
absColor = showDelta ? (delta > 0.2 ? color.new(#00C853, 0) : delta < -0.2 ? color.new(#FF1744, 0) : color.new(#9E9E9E, 30)) : color.new(#2196F3, 0)
plot(absSmoothed, "Absorption Ratio (z)", color=absColor, linewidth=2)

// Threshold line
hline(absThreshold, "Threshold", color=color.new(#FF9800, 50), linestyle=hline.style_dashed)
hline(0, "Zero", color=color.new(#616161, 70))

// Absorption event markers on the indicator
plotshape(isBuyAbsorption  ? absSmoothed : na, "Buy Absorption",  shape.triangleup,   location.absolute, color.new(#00C853, 0), size=size.tiny)
plotshape(isSellAbsorption ? absSmoothed : na, "Sell Absorption", shape.triangledown, location.absolute, color.new(#FF1744, 0), size=size.tiny)

// Background highlight during absorption
bgcolor(showBg and isBuyAbsorption  ? color.new(#00C853, 88) : na)
bgcolor(showBg and isSellAbsorption ? color.new(#FF1744, 88) : na)

// ─── DELTA HISTOGRAM (secondary visual) ───
plot(weightedDelta, "Weighted Delta", style=plot.style_columns, color=weightedDelta > 0 ? color.new(#00C853, 50) : color.new(#FF1744, 50))

// ─── ALERTS ───
alertcondition(isBuyAbsorption,  "Buy Absorption Detected",  "🟢 Buy absorption: heavy volume absorbed at support")
alertcondition(isSellAbsorption, "Sell Absorption Detected", "🔴 Sell absorption: heavy volume absorbed at resistance")
alertcondition(isAbsorption,     "Any Absorption Detected",  "⚡ Absorption event detected")
````
