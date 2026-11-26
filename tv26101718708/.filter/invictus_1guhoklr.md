# invictus

- url: https://www.tradingview.com/script/1guHokLR-invictus/
- type: indicator
- pine_id: PUB;1c6a37ab60a04431b73fe5bf7c216146
- version: 2.0

## Description

EMA 20 + SMMA 70 + EMA 200 + VWAP is a multi-trend overlay indicator that combines fast, medium, and long-term moving averages with VWAP to help traders identify trend direction, momentum shifts, and key support or resistance zones. It is useful for confirming bullish or bearish structure, tracking pullbacks, and comparing current price action against the session’s volume-weighted average.

## Source Code

````pine

//@version=6
indicator("EMA 20 + SMMA 70 + EMA 200 + VWAP", overlay=true)

// Inputs
ema20Length  = input.int(20, title="EMA 20", minval=1)
smma70Length = input.int(70, title="SMMA 70", minval=1)
ema200Length = input.int(200, title="EMA 200", minval=1)
src          = input.source(close, title="VWAP Source")

// EMA Calculations
ema20  = ta.ema(close, ema20Length)
ema200 = ta.ema(close, ema200Length)

// SMMA Function
smma(src, length) =>
    var float smmaValue = na
    smmaValue := na(smmaValue[1]) ? ta.sma(src, length) : (smmaValue[1] * (length - 1) + src) / length
    smmaValue

smma70 = smma(close, smma70Length)

// VWAP
vwapValue = ta.vwap(src)

// Plots
plot(ema20, title="EMA 20", color=color.green, linewidth=2)
plot(smma70, title="SMMA 70", color=color.red, linewidth=2)
plot(ema200, title="EMA 200", color=color.blue, linewidth=2)
plot(vwapValue, title="VWAP", color=color.purple, linewidth=2)
````
