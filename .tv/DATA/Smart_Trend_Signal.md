<!-- tradingview-pine-id: PUB;f94bdaa7912d4f48b6fa67e0bcc39f65 -->
<!-- tradingviewscripts-format: 1 -->
# Smart Trend Signal

Source: https://www.tradingview.com/script/zizzClbl-Smart-Trend-Signal/

## Description

Smart Trend Signal
Smart Trend Signal is a trend-following indicator designed to help traders identify high-probability buy and sell opportunities while filtering out market noise.
The indicator combines multiple technical factors, including:
Fast and Slow EMA trend analysis
RSI momentum confirmation
Volume confirmation for stronger signals
Visual Buy and Sell markers
Trend background highlighting
Features
Clear Buy and Sell signals
Trend confirmation using EMA crossover
RSI filter to reduce false entries
Volume filter for stronger trade setups
Works on all timeframes
Suitable for Forex, Crypto, Stocks, and Indices
Built-in alert conditions for TradingView notifications
How to Use
Buy Signal: Appears when the fast EMA crosses above the slow EMA, RSI confirms bullish momentum, and volume is above average.
Sell Signal: Appears when the fast EMA crosses below the slow EMA, RSI confirms bearish momentum, and volume is above average.
For better results, use this indicator alongside proper risk management, support and resistance analysis, and higher-timeframe trend confirmation.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ExpertTraderASK

//@version=6
indicator("Smart Trend Signal", overlay=true)

// Inputs
fastEMA = input.int(20, "Fast EMA")
slowEMA = input.int(50, "Slow EMA")
rsiLength = input.int(14, "RSI Length")
volLength = input.int(20, "Volume MA")

// Calculations
emaFast = ta.ema(close, fastEMA)
emaSlow = ta.ema(close, slowEMA)
rsi = ta.rsi(close, rsiLength)
volMA = ta.sma(volume, volLength)

// Trend
upTrend = emaFast > emaSlow
downTrend = emaFast < emaSlow

// Buy/Sell Conditions
buySignal = ta.crossover(emaFast, emaSlow) and rsi > 55 and volume > volMA
sellSignal = ta.crossunder(emaFast, emaSlow) and rsi < 45 and volume > volMA

// Plot EMAs
plot(emaFast, color=color.green, linewidth=2)
plot(emaSlow, color=color.red, linewidth=2)

// Signals
plotshape(buySignal, title="BUY", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small, text="BUY")
plotshape(sellSignal, title="SELL", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="SELL")

// Background
bgcolor(upTrend ? color.new(color.green, 92) : downTrend ? color.new(color.red, 92) : na)

// Alerts
alertcondition(buySignal, title="Buy Alert", message="Smart Trend BUY Signal")
alertcondition(sellSignal, title="Sell Alert", message="Smart Trend SELL Signal")
````
