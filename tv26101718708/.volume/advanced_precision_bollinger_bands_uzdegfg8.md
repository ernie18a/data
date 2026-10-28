# Advanced Precision Bollinger Bands

- url: https://www.tradingview.com/script/UzDegFG8-Advanced-Precision-Bollinger-Bands/
- type: indicator
- pine_id: PUB;67afc0e41bd14e708f0eda51d6502883
- version: 1.0

## Description

Dynamic Basis Alert: The center line turns orange when the bands are in a historical "squeeze" (low volatility). This acts as a visual warning to stop blind mean-reversion trading, as an explosive move is building.


Volume Integration: Standard Bollinger Bands fail when price grinds against an outer line on weak volume, convincing traders a trend is starting when it isn't. The green/red triangle signals on this script only fire if the breakout candle is backed by heavy trading volume.


Intra-candle Stability: By anchoring calculations primarily to the close, it reduces dynamic repainting issues that throw off visual backtesting.

## Source Code

````pine
//@version=5
indicator(title="Advanced Precision Bollinger Bands", shorttitle="Precision BB", overlay=true)

// --- Inputs ---
length = input.int(20, minval=1, title="BB Length")
src = input.source(close, title="Source")
mult = input.float(2.0, minval=0.001, maxval=50, title="StdDev Multiplier")
volLength = input.int(20, title="Volume MA Length")
volThreshold = input.float(1.2, title="Volume Breakthrough Multiplier (e.g. 1.2 = 120%)")

// --- Calculations ---
// Using EMA for basis to reduce lag and optimize tracking accuracy
basis = ta.ema(src, length)
dev = mult * ta.stdev(src, length)
upper = basis + dev
lower = basis - dev

// Volatility/Bandwidth Squeeze Calculation
bbWidth = (upper - lower) / basis
isSqueezing = bbWidth < ta.sma(bbWidth, length)

// Volume Filter to validate accuracy of breakout
avgVolume = ta.sma(volume, volLength)
highVolume = volume > (avgVolume * volThreshold)

// --- Signals ---
bool bullishBreakout = ta.crossover(src, upper) and highVolume
bool bearishBreakout = ta.crossunder(src, lower) and highVolume

// --- Plotting ---
colorBasis = isSqueezing ? color.orange : color.blue
plot(basis, title="Basis (EMA)", color=colorBasis, linewidth=2)

pUpper = plot(upper, title="Upper Band", color=bullishBreakout ? color.green : color.gray, linewidth=1)
pLower = plot(lower, title="Lower Band", color=bearishBreakout ? color.red : color.gray, linewidth=1)

// Shading the channel for clean visuals
fill(pUpper, pLower, color=color.new(color.blue, 96), title="Background")

// Visual Triggers on Chart
plotshape(bullishBreakout, title="Bullish Vol Breakout", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
plotshape(bearishBreakout, title="Bearish Vol Breakout", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)
````
