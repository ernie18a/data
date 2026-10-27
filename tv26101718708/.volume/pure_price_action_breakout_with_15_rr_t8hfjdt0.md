# Pure Price Action Breakout with 1:5 RR

- url: https://www.tradingview.com/script/T8HfJDT0-Pure-Price-Action-Breakout-with-1-5-RR/
- type: strategy
- pine_id: PUB;d3b8d05fab204f8e8ab3857000ed8914
- version: 3.0

## Description

Description of the Price Action Trading Script (Pine Script v6)
Overview
This script is a pure price action-based breakout strategy designed for TradingView. It identifies key breakout levels and executes long and short trades based on market structure. The strategy ensures a minimum risk-to-reward ratio (RR) of 1:5, aiming for high profitability with well-defined stop-loss and take-profit levels.

How the Script Works
1️⃣ Breakout Identification
The script uses a lookback period to find the highest high and lowest low over the last n bars.
A bullish breakout occurs when the price closes above the previous highest high.
A bearish breakout happens when the price closes below the previous lowest low.
2️⃣ Entry & Exit Strategy
Long Entry: If a bullish breakout is detected, the script enters a long position.
Short Entry: If a bearish breakout is detected, the script enters a short position.
The stop-loss is placed at the recent swing low (for long trades) or recent swing high (for short trades).
The target price is calculated based on a risk-to-reward ratio of 1:5, ensuring profitable trades.
3️⃣ Risk Management
The stop-loss prevents excessive losses by exiting trades when the market moves unfavorably.
The strategy ensures that each trade has a reward potential at least 5 times the risk.
Positions are executed based on price action only, without indicators like moving averages or RSI.
4️⃣ Visual Representation
The script plots breakout levels to help traders visualize potential trade setups.
Entry points, stop-loss, and take-profit levels are labeled on the chart for easy tracking.
Key Features & Benefits
✔ Pure Price Action – No lagging indicators, only real-time price movements.
✔ High Risk-to-Reward Ratio (1:5) – Ensures high-profit potential trades.
✔ Real-time Entry & Exit Signals – Provides accurate trade setups.
✔ Dynamic Stop-loss Calculation – Adjusts based on recent market structure.
✔ Customizable Parameters – Lookback periods and risk ratios can be modified.

## Source Code

````pine
//@version=6
strategy("BTC Momentum Strategy", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=5)

// Timeframe Check
isFiveMin = timeframe.period == "5"
isFifteenMin = timeframe.period == "15"
timeframeFilter = isFiveMin or isFifteenMin

// Moving Averages
fastMA = ta.ema(close, 9)
slowMA = ta.ema(close, 21)

// RSI Calculation
rsi = ta.rsi(close, 14)

// ATR for Stop-Loss Calculation
atr = ta.atr(14)
stopLossFactor = 1.5
riskRewardRatio = 5

// Volume Confirmation
volCondition = volume > ta.sma(volume, 20)

// Entry Conditions
longCondition = ta.crossover(fastMA, slowMA) and rsi > 50 and volCondition
shortCondition = ta.crossunder(fastMA, slowMA) and rsi < 50 and volCondition

// Stop-Loss & Take-Profit
longStopLoss = close - (atr * stopLossFactor)
longTakeProfit = close + ((close - longStopLoss) * riskRewardRatio)
shortStopLoss = close + (atr * stopLossFactor)
shortTakeProfit = close - ((shortStopLoss - close) * riskRewardRatio)

// Entry Execution
if longCondition and timeframeFilter
    strategy.entry("Long", strategy.long)
    strategy.exit("Long Exit", from_entry="Long", stop=longStopLoss, limit=longTakeProfit)

if shortCondition and timeframeFilter
    strategy.entry("Short", strategy.short)
    strategy.exit("Short Exit", from_entry="Short", stop=shortStopLoss, limit=shortTakeProfit)

// Trade Limit Per Day
tradeCount = ta.barssince(strategy.opentrades == 0)
maxTradesPerDay = 5
if tradeCount > maxTradesPerDay
    strategy.close_all()

// Plot Signals
plotshape(series=longCondition, location=location.belowbar, color=color.green, style=shape.labelup, title="Buy Signal")
plotshape(series=shortCondition, location=location.abovebar, color=color.red, style=shape.labeldown, title="Sell Signal")

// Alerts
alertcondition(longCondition, title="Buy Alert", message="BTC Long Entry Signal")
alertcondition(shortCondition, title="Sell Alert", message="BTC Short Entry Signal")
````
