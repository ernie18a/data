# Institutional CVD Divergence [Eduardo T.]

- url: https://www.tradingview.com/script/bUeDoJy5-Institutional-CVD-Divergence-Eduardo-T/
- type: indicator
- pine_id: PUB;df015975c0614405833fd36611745058
- version: 1.0

## Description

Most retail cvd indicators fail because they aggregate too much historical noise or bog down the rendering thread, I built this lightweight proxy for cumulative volume delta divergence to act as a baseline filter for structural shifts before deploying heavier raw tick parsing models. It simply decouples the bull/bear volume aggregation from the price action and flags real-time divergence anomalies directly on the chart, useful if you are trying to map institutional liquidity sweeps without freezing your platform during nfp or high volatility windows.

## Source Code

````pine
//@version=5
indicator("Institutional CVD Divergence [Eduardo T.]", shorttitle="Inst. CVD", overlay=false)
// This is a lightweight proxy for Cumulative Volume Delta divergence.
// Real institutional flow relies on raw tick data, but this serves as a baseline filter.

length = input.int(14, "Lookback Period")
bullVolume = close > open ? volume : close == open ? volume / 2 : 0
bearVolume = close < open ? volume : close == open ? volume / 2 : 0

cvd = ta.cum(bullVolume - bearVolume)

// Simple Divergence Logic
priceHigherHigh = high > ta.highest(high[1], length)
cvdLowerHigh = cvd < ta.highest(cvd[1], length)
bearDiv = priceHigherHigh and cvdLowerHigh

priceLowerLow = low < ta.lowest(low[1], length)
cvdHigherLow = cvd > ta.lowest(cvd[1], length)
bullDiv = priceLowerLow and cvdHigherLow

plot(cvd, color=color.new(color.blue, 0), title="CVD Line", linewidth=2)
plotshape(bearDiv, title="Bearish Flow Anomaly", location=location.top, color=color.red, style=shape.labeldown, text="CVD Div")
plotshape(bullDiv, title="Bullish Flow Anomaly", location=location.bottom, color=color.green, style=shape.labelup, text="CVD Div")
````
