# Linda Raschke MACD + Stochastic

- url: https://www.tradingview.com/script/cTxmiWt6/
- type: indicator
- pine_id: PUB;d310c0db8fad49d492e9ca5f5bbe3dac
- version: 1.0

## Description

# Linda Raschke MACD + Stochastic

This indicator combines a fast **MACD (3,10,16)** with a **Stochastic Oscillator (7,10,3)**, inspired by trading concepts commonly associated with professional trader Linda Raschke.

Instead of relying on a standard MACD (12,26,9), this version uses a faster configuration to detect short-term momentum shifts and potential trend changes more quickly.

## Features

* MACD (3,10,16)
* Stochastic (7,10,3)
* Automatic BUY and SELL signals
* Momentum confirmation using both indicators
* Built-in alert conditions
* Designed for day trading and swing trading

## Buy Signal

A BUY signal is generated when:

* The MACD line crosses above the Signal line.
* The Stochastic forms a bullish Hook, indicating momentum is turning upward.

## Sell Signal

A SELL signal is generated when:

* The MACD line crosses below the Signal line.
* The Stochastic forms a bearish Hook, indicating momentum is turning downward.

Signals are displayed only when both conditions occur together, helping reduce false entries.

## Recommended Usage

This indicator is intended to be used as a momentum confirmation tool rather than a standalone trading system.

For better trade selection, consider combining it with:

* 3 EMA & 10 EMA
* ATR Trailing Stop
* Previous Day High / Low
* Support & Resistance
* Price Action Analysis

## Disclaimer

This indicator is provided for educational and informational purposes only. It does not guarantee profitable trades and should always be used alongside proper risk management and independent market analysis.

## Source Code

````pine
//@version=6
indicator("Linda Raschke MACD + Stochastic", overlay=false)

// === MACD 3-10-16 ===
fastLen   = input.int(3,  "MACD Fast EMA")
slowLen   = input.int(10, "MACD Slow EMA")
signalLen = input.int(16, "MACD Signal EMA")

macdLine   = ta.ema(close, fastLen) - ta.ema(close, slowLen)
signalLine = ta.ema(macdLine, signalLen)
hist       = macdLine - signalLine

// === Stochastic 7-10-3 ===
kLen     = input.int(7,  "Stoch %K Length")
dLen     = input.int(10, "Stoch %D Length")
smoothK  = input.int(3,  "Stoch %K Smoothing")

rawK = ta.stoch(close, high, low, kLen)
k    = ta.sma(rawK, smoothK)
d    = ta.sma(k, dLen)

// === MACD Signals ===
macdBuy  = ta.crossover(macdLine, signalLine)
macdSell = ta.crossunder(macdLine, signalLine)

// === Stochastic Hook Signals ===
stochBuyHook  = k > k[1] and k[1] < k[2] and d > d[1]
stochSellHook = k < k[1] and k[1] > k[2] and d < d[1]

// === Combined Signals ===
buySignal  = macdBuy and stochBuyHook
sellSignal = macdSell and stochSellHook

// === Plot MACD ===
plot(macdLine,   title="MACD 3-10", color=color.blue, linewidth=2)
plot(signalLine, title="Signal 16", color=color.orange, linewidth=2)
plot(hist, title="MACD Histogram", style=plot.style_columns,
     color=hist >= 0 ? color.new(color.green, 30) : color.new(color.red, 30))

hline(0, "Zero Line", color=color.gray)

// === Plot Stochastic ===
plot(k, title="Stoch %K 7/3", color=color.lime, linewidth=2)
plot(d, title="Stoch %D 10", color=color.red, linewidth=2)

hline(80, "Stoch Overbought", color=color.new(color.gray, 60))
hline(20, "Stoch Oversold", color=color.new(color.gray, 60))

// === Signal Marks ===
plotshape(buySignal, title="Buy Signal", style=shape.triangleup,
     location=location.bottom, color=color.green, size=size.small, text="BUY")

plotshape(sellSignal, title="Sell Signal", style=shape.triangledown,
     location=location.top, color=color.red, size=size.small, text="SELL")

// === Alerts ===
alertcondition(buySignal, title="Linda Buy Signal",
     message="Linda Raschke MACD + Stochastic BUY Signal")

alertcondition(sellSignal, title="Linda Sell Signal",
     message="Linda Raschke MACD + Stochastic SELL Signal")
````
