# EMA Cloud Trend Probability

- url: https://www.tradingview.com/script/Ufj07Q1S-EMA-Cloud-Trend-Probability/
- type: indicator
- pine_id: PUB;0947a7dde0984294ae7e5bc762d36020
- version: 1.0

## Description

EMA Cloud Trend Probability

This indicator uses the EMA 200 Cloud to identify the primary market trend and the EMA 8 Cloud to track short-term momentum.

When the EMA 8 Cloud crosses above the EMA 200 Cloud, it signals a higher probability of a bullish trend. When the EMA 8 Cloud crosses below the EMA 200 Cloud, it signals a higher probability of a bearish trend.

🟢 Green Signal → Higher Probability of Long
🔴 Red Signal → Higher Probability of Short

The indicator is designed to help traders align with the prevailing trend and momentum. Signals represent probability, not certainty.

It can be used on any timeframe, from intraday trading to swing trading and investing, depending on your trading style and strategy. 📈📉

## Source Code

````pine
//@version=6
indicator("EMA Cloud Trend Probability", overlay=true)

// Inputs
len  = 200
len2 = 8

signalOffsetPct = input.float(1.00, "Signal Offset (% ATR)", minval=0.10, maxval=2.00, step=0.05)

// EMA 200 Cloud
emaHigh = ta.ema(high, len)
emaLow  = ta.ema(low, len)

pHigh = plot(emaHigh, "EMA 200 (High)", color=color.new(color.orange, 0), linewidth=1)
pLow  = plot(emaLow,  "EMA 200 (Low)",  color=color.new(color.orange, 0), linewidth=1)

fill(pHigh, pLow, color=color.new(color.orange, 60), title="EMA 200 Cloud Fill")

// EMA 8 Cloud
emaHigh2 = ta.ema(high, len2)
emaLow2  = ta.ema(low, len2)

pHigh2 = plot(emaHigh2, "EMA 8 (High)", color=color.new(color.blue, 0), linewidth=1)
pLow2  = plot(emaLow2,  "EMA 8 (Low)",  color=color.new(color.blue, 0), linewidth=1)

fill(pHigh2, pLow2, color=color.new(color.blue, 60), title="EMA 8 Cloud Fill")

// EMA 8 Close and EMA 200 Close
ema8_close   = ta.ema(close, len2)
ema200_close = ta.ema(close, len)

plot(ema8_close, "EMA 8 (Close)", color=color.new(color.blue, 0), linewidth=2)

// Signals
atr14  = ta.atr(14)
offset = atr14 * signalOffsetPct

crossUp   = ta.crossover(ema8_close, ema200_close)
crossDown = ta.crossunder(ema8_close, ema200_close)

var bool longSignalPlotted  = false
var bool shortSignalPlotted = false
var float crossLowPrice  = na
var float crossHighPrice = na

if crossUp
    longSignalPlotted := false
    crossLowPrice := low

if crossDown
    shortSignalPlotted := false
    crossHighPrice := high

longTrigger  = not longSignalPlotted and crossUp and close > emaHigh
shortTrigger = not shortSignalPlotted and crossDown and close < emaLow

if longTrigger
    longSignalPlotted := true

if shortTrigger
    shortSignalPlotted := true

buyPrice  = longTrigger  ? crossLowPrice - offset : na
sellPrice = shortTrigger ? crossHighPrice + offset : na

plotshape(buyPrice,  "Buy Signal",  style=shape.triangleup,   location=location.absolute, color=color.new(#22c55e, 0), size=size.small)
plotshape(sellPrice, "Sell Signal", style=shape.triangledown, location=location.absolute, color=color.new(#ef4444, 0), size=size.small)
````
