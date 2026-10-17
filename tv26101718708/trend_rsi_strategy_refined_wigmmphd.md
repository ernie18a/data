# Trend + RSI Strategy (Refined)

- url: https://www.tradingview.com/script/wigMmPHd-Trend-RSI-Strategy-Refined/
- type: strategy
- pine_id: PUB;22652e4aef524dd88871595237cf4d06
- version: 1.0

## Description

Trend + RSI Strategy (Refined)

This script implements a structured trend-following strategy using EMA direction and RSI confirmation.

Core logic:
• Trend direction defined by fast and slow EMA alignment
• RSI used as confirmation filter
• Entries only when both conditions align

Enhancements:
• Cleaner entry and exit structure
• ATR-based stop loss and target levels
• Improved consistency and reduced signal noise
• Defined risk per trade

This is a refined version of a simple concept:
trend + confirmation + structured execution.

## Source Code

````pine
//@version=5
strategy("Trend + RSI Strategy (Enhanced)", overlay=true, initial_capital=10000, commission_type=strategy.commission.percent, commission_value=0.10, slippage=2, pyramiding=0, process_orders_on_close=true)

// === Inputs ===
fastLength = input.int(9, title="Fast EMA")
slowLength = input.int(21, title="Slow EMA")
rsiLength = input.int(14, title="RSI Length")
rsiThreshold = input.int(50, title="RSI Threshold")
atrLength = input.int(14, title="ATR Length")
atrMultiplier = input.float(1.5, title="ATR Stop Multiplier")
riskPerTrade = input.float(1.0, title="Risk Per Trade (%)", minval=0.1, maxval=5.0)

// === Indicators ===
fastEMA = ta.ema(close, fastLength)
slowEMA = ta.ema(close, slowLength)
rsi = ta.rsi(close, rsiLength)
atr = ta.atr(atrLength)

// === Conditions ===
trendUp = fastEMA > slowEMA
trendDown = fastEMA < slowEMA

longCondition = trendUp and rsi > rsiThreshold
shortCondition = trendDown and rsi < rsiThreshold

// === Entries and Exits ===
if (longCondition and strategy.position_size == 0)
    strategy.entry("Long", strategy.long, qty=riskPerTrade)

if (shortCondition and strategy.position_size == 0)
    strategy.entry("Short", strategy.short, qty=riskPerTrade)

// === Stops and Targets ===
longStop = close - (atr * atrMultiplier)
shortStop = close + (atr * atrMultiplier)
longTarget = close + (atr * atrMultiplier * 2)
shortTarget = close - (atr * atrMultiplier * 2)

strategy.exit("Exit Long", from_entry="Long", stop=longStop, limit=longTarget)
strategy.exit("Exit Short", from_entry="Short", stop=shortStop, limit=shortTarget)

// === Plots ===
plot(fastEMA, color=color.blue, title="Fast EMA")
plot(slowEMA, color=color.red, title="Slow EMA")
````
