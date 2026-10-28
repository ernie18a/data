# Cumulative Volume Delta (CVD) (Candle)

- url: https://www.tradingview.com/script/aoEF0WSz/
- type: indicator
- pine_id: PUB;6fef6278495e46abba52e41af1e3ba73
- version: 1.0

## Description

A lightweight Cumulative Volume Delta (CVD) indicator with ATAS-style candle visualization.

This script estimates buying and selling pressure from price action and volume, then accumulates the delta into a clear CVD structure. Supports both CVD Candles and Line modes, with flexible reset options (Session, Day, Week, Month, or Never).

Designed to help traders visualize market pressure, absorption, divergence, and momentum shifts in a clean and simple way.

## Source Code

````pine
//@version=6
indicator("Cumulative Volume Delta (CVD)", shorttitle="CVD", overlay=false, format=format.volume)

// Inputs
resetMode = input.string("Session", "Reset CVD", options=["Never", "Session", "Day", "Week", "Month"])
cvdMode = input.string("Candles", "CVD Display", options=["Candles", "Line"])

zeroThreshold = input.float(1.0, "Zero Threshold", minval=0.0, step=0.1)

// Function
fixZero(value) =>
    math.abs(value) < zeroThreshold ? 0.0 : value

// Delta approximation
priceRange = high - low

buyVol =
     priceRange != 0 ? volume * (close - low) / priceRange :
     close > open ? volume :
     volume * 0.5

sellVol =
     priceRange != 0 ? volume * (high - close) / priceRange :
     close < open ? volume :
     volume * 0.5

deltaRaw = buyVol - sellVol
delta = fixZero(deltaRaw)

// Reset logic
newSession = timeframe.change("D")
newDay = timeframe.change("D")
newWeek = timeframe.change("W")
newMonth = timeframe.change("M")

reset =
     resetMode == "Session" ? newSession :
     resetMode == "Day"     ? newDay :
     resetMode == "Week"    ? newWeek :
     resetMode == "Month"   ? newMonth :
     false

// CVD calculation
var float cvd = na

cvdOpen = fixZero(reset or na(cvd[1]) ? 0.0 : cvd[1])
cvdClose = fixZero(cvdOpen + delta)
cvdHigh = fixZero(math.max(cvdOpen, cvdClose))
cvdLow = fixZero(math.min(cvdOpen, cvdClose))

cvd := cvdClose

// Colors
cvdBull = cvdClose >= cvdOpen
cvdColor = cvdBull ? color.lime : color.red

// ATAS-style CVD candles
plotcandle(
     cvdMode == "Candles" ? cvdOpen : na,
     cvdMode == "Candles" ? cvdHigh : na,
     cvdMode == "Candles" ? cvdLow : na,
     cvdMode == "Candles" ? cvdClose : na,
     title="ATAS Style CVD Candles",
     color=cvdColor,
     wickcolor=cvdColor,
     bordercolor=cvdColor
)

// CVD line
plot(
     cvdMode == "Line" ? cvd : na,
     title="CVD Line",
     color=color.aqua,
     linewidth=2
)
````
