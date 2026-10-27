# Stochastic RSI Strategy (with SMA and VWAP Filters)

- url: https://www.tradingview.com/script/06wt9GNj-Stochastic-RSI-Strategy-with-SMA-and-VWAP-Filters/
- type: strategy
- pine_id: PUB;d7deb7758bed4f8586baac69f9f003a6
- version: 1.0

## Description

The strategy is designed to trade on the Stochastic RSI indicator crossover signals.

Below are all of the trading conditions: 
-When the Stochastic RSI crosses above 30, a long position is entered.
-When the Stochastic RSI crosses below 70, a short position is entered.
-The strategy also includes two additional conditions for entry:
-Long entries must have a positive spread value between the 9 period simple moving average and the 21 period simple moving average.
-Short entries must have a negative spread value between the 9 period simple moving average and the 21 period simple moving average.
-Long entries must also be below the volume-weighted average price.
-Short entries must also be above the volume-weighted average price.
-The strategy includes stop loss and take profit orders for risk management:
-A stop loss of 20 ticks is placed for both long and short trades.
-A take profit of 25 ticks is placed for both long and short trades.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © thedoggwalker

//@version=4
strategy("Stochastic RSI Strategy", overlay=true)

// Stochastic RSI
length = input(14, title="Length")
src = input(close, title="Source")
smoothK = input(3, title="K")
smoothD = input(3, title="D")

rsiValue = rsi(src, length)
highestRSI = highest(rsiValue, length)
lowestRSI = lowest(rsiValue, length)
k = (rsiValue - lowestRSI) / (highestRSI - lowestRSI) * 100
d = sma(k, smoothD)

// Moving averages
maShort = sma(close, 9)
maLong = sma(close, 21)

// Spread between moving averages
spread = maShort - maLong

// VWAP
vwapValue = vwap(hlc3)

// Entry conditions
longCondition = crossover(k, 30) and spread > 0 and close < vwapValue
shortCondition = crossunder(k, 70) and spread < 0 and close > vwapValue

// Entry orders
if (longCondition)
    strategy.entry("Long", strategy.long)

if (shortCondition)
    strategy.entry("Short", strategy.short)

// Exit orders
longStopLoss = close - 20 * syminfo.mintick
longTakeProfit = close + 25 * syminfo.mintick
strategy.exit("Exit Long", "Long", stop=longStopLoss, limit=longTakeProfit)

shortStopLoss = close + 20 * syminfo.mintick
shortTakeProfit = close - 25 * syminfo.mintick
strategy.exit("Exit Short", "Short", stop=shortStopLoss, limit=shortTakeProfit)
````
