# 21 EMA Structure Cloud

- url: https://www.tradingview.com/script/qeFMCUAf-21-EMA-Structure-Cloud/
- type: indicator
- pine_id: PUB;1ce0afce7e674a7cb080cd1edf39ed67
- version: 1.0

## Description

EMA of high / EMA of close / EMA of low setup — three 21-period EMAs

## Source Code

````pine
//@version=5
indicator("21 EMA Structure Cloud", overlay=true)

length = input.int(21, "Length", minval=1)

emaHigh  = ta.ema(high,  length)
emaClose = ta.ema(close, length)
emaLow   = ta.ema(low,   length)

midPlot  = plot(emaClose, "21 EMA (close)", color=color.new(color.gray, 20), linewidth=1)
highPlot = plot(emaHigh,  "21 EMA (high)",  color=color.new(color.gray, 60))
lowPlot  = plot(emaLow,   "21 EMA (low)",   color=color.new(color.gray, 60))

fill(highPlot, lowPlot, color=color.new(color.gray, 88), title="Cloud")
````
