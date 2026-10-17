# Adaptive MACD [LuxAlgo] - ADX Filtered Histogram

- url: https://www.tradingview.com/script/6QrJWjIu-Adaptive-MACD-LuxAlgo-ADX-Filtered-Histogram/
- type: indicator
- pine_id: PUB;b7878a1e124943aaae28a37c0dcaf952
- version: 1.0

## Description

This is a combination of the adaptive MACD and the ADX. I am able to adjust the ADX. If the adx is below my chosen key level the histogram will not fire. I find it handy to confirm trend of the MACD that can be very sensitive

## Source Code

````pine
//@version=5
indicator("Adaptive MACD [LuxAlgo] - ADX Filtered Histogram", shorttitle="Adaptive MACD ADX", overlay=false)

//------------------------------------------------------------------------------
// Adaptive MACD Inputs
//------------------------------------------------------------------------------
length = input.int(20, "R2 Period", minval=2)
fast = input.int(10, "Fast Length", minval=2)
slow = input.int(20, "Slow Length", minval=2)
signal = input.int(9, "Signal Length", minval=2)

//------------------------------------------------------------------------------
// ADX Filter Inputs
//------------------------------------------------------------------------------
diLen = input.int(9, "DI Length", minval=2)
adxSmooth = input.int(5, "ADX Smoothing", minval=2)
adxThreshold = input.float(25.0, "ADX Threshold", step=0.1)

//------------------------------------------------------------------------------
// Adaptive MACD (Original LuxAlgo)
//------------------------------------------------------------------------------
var float macd = 0.0

a1 = 2.0 / (fast + 1)
a2 = 2.0 / (slow + 1)

corr = ta.correlation(close, bar_index, length)
r2 = 0.5 * math.pow(corr, 2) + 0.5

K = r2 * ((1.0 - a1) * (1.0 - a2)) + (1.0 - r2) * ((1.0 - a1) / (1.0 - a2))

macd := (close - close[1]) * (a1 - a2) + (-a2 - a1 + 2.0) * nz(macd[1]) - K * nz(macd[2])

signalLine = ta.ema(macd, signal)
hist = macd - signalLine

//------------------------------------------------------------------------------
// ADX Calculation (DI 9 / ADX 5)
//------------------------------------------------------------------------------
upMove = high - high[1]
downMove = low[1] - low

plusDM = upMove > downMove and upMove > 0 ? upMove : 0.0
minusDM = downMove > upMove and downMove > 0 ? downMove : 0.0

tr1 = high - low
tr2 = math.abs(high - close[1])
tr3 = math.abs(low - close[1])

tr = math.max(tr1, math.max(tr2, tr3))

trRma = ta.rma(tr, diLen)
plusRma = ta.rma(plusDM, diLen)
minusRma = ta.rma(minusDM, diLen)

plusDI = trRma == 0 ? 0 : 100 * plusRma / trRma
minusDI = trRma == 0 ? 0 : 100 * minusRma / trRma

sumDI = plusDI + minusDI

dx = sumDI == 0 ? 0 : 100 * math.abs(plusDI - minusDI) / sumDI
adx = ta.rma(dx, adxSmooth)

//------------------------------------------------------------------------------
// Histogram Filter
//------------------------------------------------------------------------------
histVisible = adx >= adxThreshold ? hist : na

//------------------------------------------------------------------------------
// Original LuxAlgo Histogram Colors
//------------------------------------------------------------------------------
histColor =
     hist > 0 and hist > hist[1] ? #5b9cf6 :
     hist > 0 and hist < hist[1] ? color.new(#5b9cf6, 50) :
     hist < 0 and hist < hist[1] ? #f77c80 :
     color.new(#f77c80, 50)

//------------------------------------------------------------------------------
// Plots
//------------------------------------------------------------------------------
hline(0, "Zero Line", color=color.gray)

plot(
     histVisible,
     title="Histogram",
     style=plot.style_columns,
     color=histColor,
     linewidth=2)

plot(
     macd,
     title="MACD",
     color=color.white,
     linewidth=2)

plot(
     signalLine,
     title="Signal",
     color=color.fuchsia,
     linewidth=2)
````
