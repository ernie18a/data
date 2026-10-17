# Volatility Regime Filter(ATR based)

- url: https://www.tradingview.com/script/6he9Wwoe-Volatility-Regime-Filter-ATR-based/
- type: indicator
- pine_id: PUB;2600ffd6eae1428db217493aea89bf61
- version: 1.0

## Description

The Volatility Regime Filter -
Not all trends are created equal. Entering trades during "dead" markets or extreme panic can ruin a system's win rate.

How it works: The system calculates the Average True Range (ATR) over 14 periods, then ranks current volatility against the last 100 periods using a percentile scale (0 to 100).

The Rule: The ATR Percentile must be between 20 and 90.

Why it matters: It forces the system to skip trades when the market is asleep (under 20th percentile) or during erratic, unpredictable volatility spikes like news events or market crashes (above 90th percentile).

Happy Trading.

## Source Code

````pine
//@version=6
indicator("Volatility Regime Filter", shorttitle="VRF", overlay=false)

// =========================================================================
// INPUTS
// =========================================================================
int atrLength  = input.int(14, title="ATR Length", minval=1)
int lookback   = input.int(100, title="Percentile Lookback Period", minval=2)
float lowerBnd = input.float(20.0, title="Lower Bound (Sleepy Market)", minval=0, maxval=100)
float upperBnd = input.float(90.0, title="Upper Bound (Panic Market)", minval=0, maxval=100)

// =========================================================================
// CALCULATIONS
// =========================================================================
// 1. Calculate the standard Average True Range (ATR)
float currentAtr = ta.atr(atrLength)

// 2. Rank current volatility against the last 100 periods (0 to 100 scale)
float atrPercentile = ta.percentrank(currentAtr, lookback)

// 3. The Rule: Check if the market is in the "Goldilocks" zone (between 20 and 90)
bool validRegime = (atrPercentile >= lowerBnd) and (atrPercentile <= upperBnd)

// =========================================================================
// VISUALIZATION
// =========================================================================
// Plot the ATR Percentile line
plot(atrPercentile, title="ATR Percentile", color=color.blue, linewidth=2)

// Plot the 20 and 90 threshold lines for reference
hline(upperBnd, title="Upper Bound (90)", color=color.red, linestyle=hline.style_dashed)
hline(lowerBnd, title="Lower Bound (20)", color=color.gray, linestyle=hline.style_dashed)

// Change background color based on the regime (Combined into a single line to prevent syntax errors)
color bgColor = validRegime ? color.new(color.green, 90) : atrPercentile < lowerBnd ? color.new(color.gray, 90) : color.new(color.red, 90)

bgcolor(bgColor, title="Regime Background")

// Optional: Provide the boolean condition as an exportable variable 
plotshape(validRegime ? atrPercentile : na, title="Valid Condition Marker", style=shape.circle, location=location.absolute, color=color.new(color.green, 80), size=size.tiny)
````
