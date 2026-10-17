# VWAP Strategy v1.1

- url: https://www.tradingview.com/script/yo9gkoec-VWAP-Strategy-v1-1/
- type: indicator
- pine_id: PUB;a18f598c408543fca593918831b9379a
- version: 1.0

## Description

Simple vwap strategy showing lower highs and volume exhaustion.

## Source Code

````pine
//@version=6
indicator("VWAP Strategy", overlay=true)

// VWAP
vwapValue = ta.vwap(close)
plot(vwapValue, title="VWAP", color=color.rgb(211, 217, 48), linewidth=2)

// Volume Exhaustion Detection
volMa = ta.sma(volume, 20)
isVolExhaust = volume > volMa * 2
bgcolor(isVolExhaust ? color.new(color.orange, 85) : na, title="Volume Exhaustion")

// Optional: Mark Lower Highs (Bearish Confirmation)
lowerHigh = high < high[1] and high[1] < high[2]
plotshape(
     lowerHigh,
     location = location.abovebar,
     color = color.fuchsia,
     style = shape.triangledown,
     title = "Lower High"
)
````
