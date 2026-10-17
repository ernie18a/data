# Bollinger Bands Long Strategy

- url: https://www.tradingview.com/script/oQS3uUS5-Bollinger-Bands-Long-Strategy/
- type: strategy
- pine_id: PUB;27d84586d9a0402ca305609f13aa683d
- version: 1.0

## Description

This strategy is designed for identifying and executing long trades based on Bollinger Bands and RSI. It aims to capitalize on potential oversold conditions and subsequent price recovery.

Key Features:
- Bollinger Bands (10,2): The strategy uses Bollinger Bands with a 10-period moving average and a multiplier of 2 to define price volatility.
- RSI Filter: A trade is only triggered when the RSI (14-period) is below 30, ensuring entry during oversold conditions.
- Entry Condition: A long trade is entered immediately when the price crosses below the lower Bollinger Band and the RSI is under 30.
- Exit Condition: The position is exited when the price reaches or crosses above the Bollinger Band basis (20-period moving average).

Best Used For:
- Identifying oversold conditions with a strong potential for a rebound.
- Markets or assets with clear oscillations and volatility e.g., BTC.

**Disclaimer:** This strategy is for educational purposes and should be used with caution. Backtesting and risk management are essential before live trading.

## Source Code

````pine
//@version=5
strategy("Bollinger Bands Long Strategy", overlay=true, process_orders_on_close=false)

// Bollinger Bands Settings
length = 10
src = close
mult = 2
basis = ta.sma(src, length)
deviation = mult * ta.stdev(src, length)
upper = basis + deviation
lower = basis - deviation

// RSI Settings
rsiLength = 14
rsi = ta.rsi(src, rsiLength)

// Conditions for Long Entry and Exit
longEntryCondition = (close < lower) and (rsi < 30)
longExitCondition = close >= basis

// Execute Long Trades
if longEntryCondition
    strategy.entry("Long", strategy.long)

if longExitCondition
    strategy.close("Long")

// Plot Bollinger Bands
plot(upper, color=color.blue)
plot(lower, color=color.blue)
plot(basis, color=color.orange)
````
