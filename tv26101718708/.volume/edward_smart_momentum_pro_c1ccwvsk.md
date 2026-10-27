# Edward Smart Momentum Pro

- url: https://www.tradingview.com/script/c1cCwVSK-Edward-Smart-Momentum-Pro/
- type: indicator
- pine_id: PUB;dbd52e54a3c246f0bbd85768688632af
- version: 3.0

## Description

Edward Smart Momentum Pro is a trend-following indicator designed to help traders identify potential market momentum using a combination of exponential moving averages, volatility filtering, and momentum confirmation.

The indicator focuses on identifying the current market trend while filtering weaker price movements to produce cleaner trading signals.

Features

* Smart trend detection using multiple EMAs
* RSI momentum confirmation
* ATR-based volatility filter
* Buy and Sell signal labels
* Dynamic trend visualization
* Background trend highlighting
* Built-in alert conditions
* Non-repainting signals after candle close

How It Works

A BUY signal is generated when bullish trend conditions align with momentum and volatility confirmation.

A SELL signal is generated when bearish trend conditions align with momentum and volatility confirmation.

The background color changes to reflect the current market bias, making trend direction easier to identify at a glance.

Best Markets

* Forex
* Gold (XAUUSD)
* Indices
* Cryptocurrency
* Stocks

Suggested Timeframes

* M15
* M30
* H1
* H4

Notes

This indicator is designed as a confirmation tool and should be used together with price action, market structure, support and resistance, or your own trading strategy. It is not intended to be used as a standalone decision-making tool.

Alerts

* Buy Signal
* Sell Signal

Disclaimer

This script is provided for educational and analytical purposes only. It does not guarantee profitable results or predict future market movements. Always perform your own analysis and use proper risk management before making any trading decisions.

## Source Code

````pine

//@version=6
indicator("Edward Smart Momentum Pro", overlay=true)

// ===== INPUTS =====
fastEMA = input.int(20, "Fast EMA")
slowEMA = input.int(50, "Slow EMA")
rsiLen = input.int(14, "RSI Length")
atrLen = input.int(10, "ATR Length")
atrMult = input.float(2.0, "ATR Multiplier")

// ===== CALCULATIONS =====
emaFast = ta.ema(close, fastEMA)
emaSlow = ta.ema(close, slowEMA)

rsi = ta.rsi(close, rsiLen)
atr = ta.atr(atrLen)

// Dynamic Trend Line
upperBand = hl2 + atr * atrMult
lowerBand = hl2 - atr * atrMult

trend = 0
trend := close > upperBand[1] ? 1 :
         close < lowerBand[1] ? -1 :
         nz(trend[1], 1)

trendLine = trend == 1 ? lowerBand : upperBand

// Breakout
highestHigh = ta.highest(high, 15)
lowestLow = ta.lowest(low, 15)

bullBreak = close > highestHigh[1]
bearBreak = close < lowestLow[1]

// Volume Filter
volFilter = volume > ta.sma(volume, 20)

// Signals
buy = trend == 1 and emaFast > emaSlow and bullBreak and rsi > 55 and volFilter
sell = trend == -1 and emaFast < emaSlow and bearBreak and rsi < 45 and volFilter

// ===== PLOTS =====
plot(emaFast, color=color.aqua, linewidth=2, title="EMA Fast")
plot(emaSlow, color=color.orange, linewidth=2, title="EMA Slow")

plot(trendLine,
     color = trend == 1 ? color.lime : color.red,
     linewidth = 2,
     title = "Trend Line")

plotshape(buy,
     title="BUY",
     location=location.belowbar,
     style=shape.labelup,
     color=color.green,
     text="BUY")

plotshape(sell,
     title="SELL",
     location=location.abovebar,
     style=shape.labeldown,
     color=color.red,
     text="SELL")

bgcolor(trend == 1 ? color.new(color.green, 92) : color.new(color.red, 92))

alertcondition(buy, title="BUY ALERT", message="Edward Smart Momentum Pro BUY")
alertcondition(sell, title="SELL ALERT", message="Edward Smart Momentum Pro SELL")
````
