# Absorption Detector v2

- url: https://www.tradingview.com/script/qnNt0PeF-Absorption-Detector-v2/
- type: indicator
- pine_id: PUB;4c63b8b7f70d441d8ac6d092e1e78e8f
- version: 1.0

## Description

Absorption Detector v2Absorption Detector v2Absorption Detector v2Absorption Detector v2Absorption Detector v2Absorption Detector v2Absorption Detector v2

## Source Code

````pine
// Absorption Detector v2 — context-aware delta + overlay markers
//@version=5
indicator("Absorption Detector v2", overlay=false, format=format.volume)

// ─── INPUTS ───
lengthNorm    = input.int(50,    "Normalization Lookback",   minval=10, maxval=200)
trendLen      = input.int(5,     "Trend Context Length",     minval=2,  maxval=20, tooltip="How many bars back to determine incoming pressure direction")
absThreshold  = input.float(2.0, "Absorption Threshold (σ)", minval=0.5, step=0.25)
smoothLen     = input.int(3,     "Smoothing Length",         minval=1, maxval=10)
showBg        = input.bool(true, "Highlight Absorption Zones")

// ─── CORE: ABSORPTION RATIO ───
candleRange = high - low
safeRange   = math.max(candleRange, syminfo.mintick)
rawAbsRatio = volume / safeRange

absMean  = ta.sma(rawAbsRatio, lengthNorm)
absStd   = ta.stdev(rawAbsRatio, lengthNorm)
safeStd  = math.max(absStd, 0.0001)
absZScore = (rawAbsRatio - absMean) / safeStd

absSmoothed = ta.sma(absZScore, smoothLen)

// ─── CONTEXT-AWARE DELTA ───
// Instead of looking at close position within candle (unreliable),
// look at WHERE price came FROM to determine pressure direction.
//
// Price dropping into this bar = selling pressure incoming
//   → if absorbed (high ratio) = BUY absorption (someone catching the knife)
// Price rising into this bar = buying pressure incoming
//   → if absorbed (high ratio) = SELL absorption (someone capping the move)

priceChange    = close - close[trendLen]  // net move over lookback
trendSma       = ta.sma(close, trendLen)
incomingSell   = close < trendSma and priceChange < 0   // price was falling into this zone
incomingBuy    = close > trendSma and priceChange > 0   // price was rising into this zone

// Delta: positive = buy absorption, negative = sell absorption
// Magnitude comes from how strong the incoming pressure was relative to how little price moved
pressureStrength = math.abs(priceChange) / safeRange  // how much pressure vs how little movement
delta = incomingSell ? 1.0 : incomingBuy ? -1.0 : 0.0

// ─── ABSORPTION EVENT DETECTION ───
isAbsorption     = absSmoothed > absThreshold
isBuyAbsorption  = isAbsorption and incomingSell   // price falling + absorbed = buyers catching
isSellAbsorption = isAbsorption and incomingBuy    // price rising + absorbed = sellers capping

// ─── PLOTTING: INDICATOR PANEL ───
absColor = isBuyAbsorption ? color.new(#00C853, 0) : isSellAbsorption ? color.new(#FF1744, 0) : color.new(#9E9E9E, 40)
plot(absSmoothed, "Absorption Ratio (z)", color=absColor, linewidth=2)

hline(absThreshold, "Threshold", color=color.new(#FF9800, 50), linestyle=hline.style_dashed)
hline(0, "Zero", color=color.new(#616161, 70))

// Event markers on indicator
plotshape(isBuyAbsorption  ? absSmoothed : na, "Buy Absorption",  shape.triangleup,   location.absolute, color.new(#00C853, 0), size=size.small)
plotshape(isSellAbsorption ? absSmoothed : na, "Sell Absorption", shape.triangledown, location.absolute, color.new(#FF1744, 0), size=size.small)

// Background
bgcolor(showBg and isBuyAbsorption  ? color.new(#00C853, 88) : na)
bgcolor(showBg and isSellAbsorption ? color.new(#FF1744, 88) : na)

// Weighted delta histogram
weightedDelta = absSmoothed * delta
plot(weightedDelta, "Weighted Delta", style=plot.style_columns, color=weightedDelta > 0 ? color.new(#00C853, 50) : color.new(#FF1744, 50))

// ─── OVERLAY MARKERS (on price chart) ───
// These use plotshape with location.abovebar / belowbar to appear on the main chart
// Note: overlay=false means these won't show on price chart directly.
// To get overlay markers, use the companion overlay script below.

// ─── ALERTS ───
alertcondition(isBuyAbsorption,  "Buy Absorption",  "🟢 Buy absorption: selling pressure absorbed — potential support")
alertcondition(isSellAbsorption, "Sell Absorption", "🔴 Sell absorption: buying pressure absorbed — potential resistance")
alertcondition(isAbsorption,     "Any Absorption",  "⚡ Absorption event detected")
````
