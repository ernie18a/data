# Smart Trend Filter V6

- url: https://www.tradingview.com/script/KHXXY4vt-Smart-Trend-Filter-V6/
- type: indicator
- pine_id: PUB;305174e9be9a42b29745a82f4aa72a32
- version: 1.0

## Description

Smart Trend Filter V6

Overview

Smart Trend Filter V6 is a trend-following indicator that combines multiple technical analysis tools into a single system to help traders identify high-quality trading opportunities. Instead of relying on one indicator alone, it uses trend, momentum, and volume confirmation to filter out weaker signals and highlight stronger market setups.

The goal of this indicator is to provide a cleaner view of the market by reducing noise and helping traders focus on trades that align with the prevailing trend.

---

How the Indicator Works

Smart Trend Filter V6 evaluates four important aspects of the market before generating a signal.

1. Trend Detection (EMA 20 & EMA 50)

The indicator uses two Exponential Moving Averages (EMAs) to determine the overall market direction.

- When EMA 20 is above EMA 50, the market is considered bullish.
- When EMA 20 is below EMA 50, the market is considered bearish.

This trend filter helps traders avoid trading against the dominant market direction.

2. Momentum Confirmation (RSI)

The Relative Strength Index (RSI) measures the strength of price movement.

- Higher RSI values indicate stronger bullish momentum.
- Lower RSI values indicate stronger bearish momentum.

RSI confirmation helps filter out weak crossovers that lack momentum.

3. Volume Confirmation

Volume plays an important role in validating price movements.

The indicator compares the current volume with its moving average.

Signals are generated only when trading volume is above average, increasing the likelihood that the move is supported by market participation.

4. Price Confirmation

Before a signal is confirmed, price must also agree with the trend.

For a Buy signal, price must close above the fast EMA.

For a Sell signal, price must close below the fast EMA.

This additional confirmation helps reduce false entries.

---

Buy Signal

A Buy signal appears when all of the following conditions are met:

- EMA 20 crosses above EMA 50.
- RSI is above the selected Buy threshold.
- Volume is above its moving average.
- Price closes above EMA 20.

---

Sell Signal

A Sell signal appears when all of the following conditions are met:

- EMA 20 crosses below EMA 50.
- RSI is below the selected Sell threshold.
- Volume is above its moving average.
- Price closes below EMA 20.

---

Features

- Non-repainting signal logic
- Trend confirmation using dual EMAs
- RSI momentum filter
- Volume-based confirmation
- Buy and Sell arrows
- Background trend highlighting
- Customizable settings
- TradingView alert support
- Works across multiple asset classes

---

Suitable Markets

Smart Trend Filter V6 can be used on:

- Forex
- Cryptocurrencies
- Stocks
- Commodities
- Indices

---

Recommended Timeframes

- 5 Minutes
- 15 Minutes
- 30 Minutes
- 1 Hour
- 4 Hours
- Daily

Higher timeframes generally produce fewer but stronger signals, while lower timeframes generate more opportunities with increased market noise.

---

Best Practices

For improved results:

- Trade in the direction of the higher-timeframe trend.
- Use stop-loss and proper risk management.
- Wait for candle close before acting on a signal.
- Combine the indicator with key support and resistance levels for additional confirmation.

---

Disclaimer

Smart Trend Filter V6 is designed as a technical analysis tool to assist with market analysis. No indicator can predict the market with complete accuracy, and all trading involves risk. Always perform your own analysis and apply sound risk management before making trading decisions.

If you find this indicator useful, consider adding it to your favorites and sharing your feedback. Your suggestions are always appreciated and help improve future updates.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ExpertTraderASK

//@version=6
indicator("Smart Trend Filter V6", overlay=true, max_labels_count=500)

// ===== Inputs =====
fastEMA = input.int(20, "Fast EMA", minval=1)
slowEMA = input.int(50, "Slow EMA", minval=1)
rsiLength = input.int(14, "RSI Length", minval=2)
buyRSI = input.int(55, "Buy RSI Level")
sellRSI = input.int(45, "Sell RSI Level")
volLength = input.int(20, "Volume MA Length")

// ===== Calculations =====
emaFast = ta.ema(close, fastEMA)
emaSlow = ta.ema(close, slowEMA)

rsi = ta.rsi(close, rsiLength)

volMA = ta.sma(volume, volLength)

// ===== Trend =====
bullTrend = emaFast > emaSlow
bearTrend = emaFast < emaSlow

// ===== Entry Conditions =====
buySignal =
     ta.crossover(emaFast, emaSlow) and
     rsi > buyRSI and
     volume > volMA and
     close > emaFast

sellSignal =
     ta.crossunder(emaFast, emaSlow) and
     rsi < sellRSI and
     volume > volMA and
     close < emaFast

// ===== Plot EMAs =====
plot(emaFast, title="EMA 20", color=color.green, linewidth=2)
plot(emaSlow, title="EMA 50", color=color.red, linewidth=2)

// ===== Buy/Sell Signals =====
plotshape(buySignal,
     title="BUY",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     size=size.small,
     text="BUY")

plotshape(sellSignal,
     title="SELL",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.small,
     text="SELL")

// ===== Background =====
bgcolor(bullTrend ? color.new(color.green, 92) :
       bearTrend ? color.new(color.red, 92) : na)

// ===== Alerts =====
alertcondition(buySignal, title="Buy Alert", message="Smart Trend Filter BUY")
alertcondition(sellSignal, title="Sell Alert", message="Smart Trend Filter SELL")
````
