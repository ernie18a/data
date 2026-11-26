# MNQ High-Probability Pullback Scalper

- url: https://www.tradingview.com/script/KRg5Pb9L-MNQ-High-Probability-Pullback-Scalper/
- type: indicator
- pine_id: PUB;db38658d369d41cb88c1d3af9fc352a7
- version: 1.0

## Description

How traders often use it on 1-minute Nasdaq
Long bias: price above VWAP + 9 EMA above 21 EMA
Short bias: price below VWAP + 9 EMA below 21 EMA
Arrows work best when they agree with the broader trend rather than during choppy open-range noise.

A cleaner MNQ scalping approach is to only mark pullbacks inside an already-established trend—not fresh momentum bursts.

This version waits for:

trend already established (5 EMA above 13 EMA and price on correct side of VWAP)
a real pullback into the fast EMA
the candle to reject the pullback and close back in trend direction
RSI confirmation
cooldown between signals so you don’t get clusters

## Source Code

````pine
//@version=5
indicator("MNQ High-Probability Pullback Scalper", overlay=true)

// Inputs
fastLen = input.int(5, title="Fast EMA")
slowLen = input.int(13, title="Slow EMA")
rsiLen = input.int(7, title="RSI Length")
rsiBull = input.int(52, title="Bull RSI Minimum")
rsiBear = input.int(48, title="Bear RSI Maximum")
cooldownBars = input.int(10, title="Bars Between Signals")

// Core calculations
fastEMA = ta.ema(close, fastLen)
slowEMA = ta.ema(close, slowLen)
vwapVal = ta.vwap(close)
rsiVal = ta.rsi(close, rsiLen)

// Established trend (not just fresh cross)
bullTrend = close > vwapVal and fastEMA > slowEMA and fastEMA > fastEMA[1]
bearTrend = close < vwapVal and fastEMA < slowEMA and fastEMA < fastEMA[1]

// Pullback definition
longPullback = bullTrend and low <= fastEMA and close > fastEMA and close > open and rsiVal > rsiBull
shortPullback = bearTrend and high >= fastEMA and close < fastEMA and close < open and rsiVal < rsiBear

// Cooldown logic
var int lastSignalBar = na
canSignal = na(lastSignalBar) or bar_index - lastSignalBar > cooldownBars

buySignal = longPullback and canSignal
sellSignal = shortPullback and canSignal

if buySignal or sellSignal
    lastSignalBar := bar_index

// Plots
plot(fastEMA, title="Fast EMA", linewidth=2, color=color.yellow)
plot(slowEMA, title="Slow EMA", linewidth=2, color=color.orange)
plot(vwapVal, title="VWAP", linewidth=2, color=color.aqua)

// Visual signals
plotshape(buySignal, title="BUY", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small)
plotshape(sellSignal, title="SELL", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

// Alerts
alertcondition(buySignal, title="MNQ Pullback Buy", message="MNQ high-probability long pullback")
alertcondition(sellSignal, title="MNQ Pullback Sell", message="MNQ high-probability short pullback")
````
