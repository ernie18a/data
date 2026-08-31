<!-- tradingview-pine-id: PUB;cb6f79cb39ea47c8850e8a312d666e2e -->
<!-- tradingviewscripts-format: 1 -->
# Supertrend with Buy/Sell Signals

Source: https://www.tradingview.com/script/JJFjNCeL-Supertrend-with-Buy-Sell-Signals/

## Description

Supertrend with Buy & Sell Signals

Overview
Supertrend with Buy & Sell Signals is a clean and easy-to-use trend-following indicator designed to help traders identify potential market trends and reversal points. It combines the reliability of the Supertrend algorithm with clear visual BUY and SELL labels, making it suitable for beginners as well as experienced traders.
The indicator automatically detects trend direction, highlights bullish and bearish conditions, and generates signals whenever a new trend is confirmed.

Features
✔️ Automatic Supertrend calculation
✔️ Clear BUY and SELL signal labels
✔️ Green and red trend visualization
✔️ Background color for quick trend identification
✔️ Built-in TradingView alerts
✔️ Lightweight and easy to read
✔️ Works on all markets and timeframes

How to Use

BUY Signal
A BUY label appears when the Supertrend changes from a bearish trend to a bullish trend.
Consider:

Looking for long (buy) opportunities.
Waiting for candle confirmation before entering a trade.
Using proper risk management.

SELL Signal
A SELL label appears when the Supertrend changes from a bullish trend to a bearish trend.
Consider:

Looking for short (sell) opportunities where applicable.
Closing long positions if it matches your trading plan.

Confirming the signal with price action.
Understanding the Indicator

Green Trend
A green Supertrend indicates that buyers are in control and the market is currently in an uptrend.

Red Trend
A red Supertrend indicates that sellers are in control and the market is currently in a downtrend.

The indicator is designed to help traders stay with the prevailing trend instead of reacting to every small price movement.

Best Practices
For higher-quality trading decisions, consider using this indicator together with:

Market structure
Support & Resistance
Volume analysis
Candlestick confirmation
Higher timeframe trend analysis

Avoid relying on any single indicator for every trading decision.
Learning from This Indicator
This indicator can help you develop important trading skills by teaching you how to:
Identify market trends
Recognize trend reversals
Avoid trading against the prevailing trend
Improve trade timing
Practice patience and discipline by waiting for confirmed signals
As you gain experience, combine these signals with your own analysis to build confidence and consistency.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ExpertTraderASK

//@version=6
indicator("Supertrend with Buy/Sell Signals", overlay=true)

// Inputs
atrLength = input.int(10, title="ATR Length")
factor = input.float(3.0, title="Multiplier", step=0.1)

// Supertrend
[supertrend, direction] = ta.supertrend(factor, atrLength)

// Plot Supertrend
upTrend = plot(direction < 0 ? supertrend : na, "Up Trend", color=color.green, linewidth=2)
downTrend = plot(direction > 0 ? supertrend : na, "Down Trend", color=color.red, linewidth=2)

// Background Color
bgcolor(direction < 0 ? color.new(color.green, 90) : color.new(color.red, 90))

// Buy & Sell Signals
buySignal = direction < 0 and direction[1] > 0
sellSignal = direction > 0 and direction[1] < 0

// Plot Labels
plotshape(buySignal,
     title="Buy",
     location=location.belowbar,
     style=shape.labelup,
     text="BUY",
     color=color.green,
     textcolor=color.white,
     size=size.small)

plotshape(sellSignal,
     title="Sell",
     location=location.abovebar,
     style=shape.labeldown,
     text="SELL",
     color=color.red,
     textcolor=color.white,
     size=size.small)

// Alerts
alertcondition(buySignal, title="Buy Alert", message="Supertrend BUY Signal")
alertcondition(sellSignal, title="Sell Alert", message="Supertrend SELL Signal")
````
