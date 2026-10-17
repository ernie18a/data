# SMA + MACD + RSI Signals

- url: https://www.tradingview.com/script/9aK2KxwB-SMA-MACD-RSI-Signals/
- type: indicator
- pine_id: PUB;693b18ecd0d84ac3b905c56650507e30
- version: 1.0

## Description

Intraday 5 mins, Best indicator for intraday

BUY
10 SMA crosses above 20 SMA
MACD line > Signal line (bullish momentum)
RSI > 50 (strength confirmation)
SELL
10 SMA crosses below 20 SMA
MACD line < Signal line
RSI < 50

## Source Code

````pine
//@version=5
indicator("SMA + MACD + RSI Signals", overlay=true)

// === INPUTS ===
fastLength = input.int(10, title="Fast SMA Length")
slowLength = input.int(20, title="Slow SMA Length")

rsiLength = input.int(14, title="RSI Length")
rsiBuyLevel = input.int(50, title="RSI Buy Level")
rsiSellLevel = input.int(50, title="RSI Sell Level")

macdFast = input.int(12, title="MACD Fast Length")
macdSlow = input.int(26, title="MACD Slow Length")
macdSignal = input.int(9, title="MACD Signal Length")

// === INDICATORS ===
// SMA
smaFast = ta.sma(close, fastLength)
smaSlow = ta.sma(close, slowLength)

// RSI
rsi = ta.rsi(close, rsiLength)

// MACD
[macdLine, signalLine, _] = ta.macd(close, macdFast, macdSlow, macdSignal)

// === CONDITIONS ===
// Buy Condition
buyCondition = ta.crossover(smaFast, smaSlow) and macdLine > signalLine and rsi > rsiBuyLevel

// Sell Condition
sellCondition = ta.crossunder(smaFast, smaSlow) and macdLine < signalLine and rsi < rsiSellLevel

// === PLOTS ===
plot(smaFast, color=color.blue, title="10 SMA")
plot(smaSlow, color=color.red, title="20 SMA")

// Buy Signal
plotshape(buyCondition, title="BUY", location=location.belowbar, color=color.green, style=shape.labelup, text="BUY")

// Sell Signal
plotshape(sellCondition, title="SELL", location=location.abovebar, color=color.red, style=shape.labeldown, text="SELL")

// === ALERTS ===
alertcondition(buyCondition, title="Buy Alert", message="Buy Signal")
alertcondition(sellCondition, title="Sell Alert", message="Sell Signal")
````
