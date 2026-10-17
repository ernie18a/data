# ATR Volatility Expansion

- url: https://www.tradingview.com/script/g7QOytu1-ATR-Volatility-Expansion/
- type: indicator
- pine_id: PUB;90468047bb464ea4b0bebfa262e0e661
- version: 1.0

## Description

ATR Volatility Expansion - allows longterm view - can be used to see volatility pattern

## Source Code

````pine
//@version=6
indicator("ATR Volatility Expansion", overlay=false)

// Inputs
atrLength      = input.int(14, "ATR Length", minval=1)
baselineLength = input.int(50, "Baseline Length", minval=2)
smoothLength   = input.int(10, "Smoothing Length", minval=1)

// ATR
atrValue = ta.atr(atrLength)

// Relative ATR Expansion
baselineATR = ta.sma(atrValue, baselineLength)
expansion = baselineATR > 0 ? atrValue / baselineATR : 1.0

// Smoothing
smoothedExpansion = ta.ema(expansion, smoothLength)

// Plots
plot(expansion, "Raw Expansion")
plot(smoothedExpansion, "Smoothed Expansion", linewidth=2)

hline(1.0, "Normal Volatility")
````
