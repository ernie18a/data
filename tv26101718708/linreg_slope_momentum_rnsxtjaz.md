# LinReg Slope Momentum

- url: https://www.tradingview.com/script/RnSXTJaz-LinReg-Slope-Momentum/
- type: strategy
- pine_id: PUB;fecf5a242afd41478b9b2a23c74870d2
- version: 1.0

## Description

basic lin reg momentum strategy, use 100 length. Longs on positive slope and shorts on a negative.

## Source Code

````pine
//@version=5
strategy("LinReg Slope Momentum", overlay=false)

// === INPUTS ===
regLen = input.int(50, "Regression Length")
slopeThreshold = input.float(0, "Slope Threshold")

// === CALCULATE SLOPE ===
// Method 1: Simple slope approximation
linRegValue = ta.linreg(close, regLen, 0)
linRegPrev = ta.linreg(close, regLen, 1)
slope = linRegValue - linRegPrev

// Method 2: Normalized slope (% change per bar)
normalizedSlope = (slope / close) * 100

// === SIGNALS ===
longSignal = slope > slopeThreshold
shortSignal = slope < -slopeThreshold

// === EXECUTION ===
if longSignal and strategy.position_size <= 0
    strategy.entry("Long", strategy.long)
if shortSignal and strategy.position_size >= 0
    strategy.entry("Short", strategy.short)

// === PLOTS ===
plot(slope, "Slope", color=slope > 0 ? color.green : color.red, linewidth=2)
hline(0, "Zero", color=color.gray)
hline(slopeThreshold, "Upper", color=color.green, linestyle=hline.style_dotted)
hline(-slopeThreshold, "Lower", color=color.red, linestyle=hline.style_dotted)
````
