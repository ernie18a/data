# Hobbiecode - Five Day Low RSI Strategy

- url: https://www.tradingview.com/script/PmJa1OXL/
- type: strategy
- pine_id: PUB;fd2dee6c53ab497197598e7b58c03e37
- version: 2.0

## Description

This is a simple strategy that is working well on SPY but also well performing on Mini Futures SP500. The strategy is composed by the followin rules:

1. If today’s close is below yesterday’s five-day low, go long at the close.
2. Sell at the close when the two-day RSI closes above 50.
3. There is a time stop of five days if the sell criterium is not triggered.

If you backtest it on Mini Futures SP500 you will be able to track data from 1993. It is important to select D1 as timeframe.

Please share any comment or idea below.

Have a good trading,
Ramón.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © hobbiecode

// If today’s close is below yesterday’s five-day low, go long at the close.
// Sell at the close when the two-day RSI closes above 50.
// There is a time stop of five days if the sell criterium is not triggered.

//@version=5
strategy("Hobbiecode - Five Day Low RSI Strategy", overlay=true)

// RSI parameters
rsi_period = 2
rsi_upper = 50

// Calculate RSI
rsi_val = ta.rsi(close, rsi_period)

// Check if today's close is below yesterday's 5 day low
conditionEntry = close < ta.lowest(low[1], 5) and strategy.position_size < 1
if (conditionEntry)
    strategy.entry("Buy", strategy.long)

// Check if RSI closes above 50
if (strategy.position_size > 0 and rsi_val > rsi_upper)
    strategy.close("Buy")

// If position held for more than 5 days without sell criteria, then close position
if (strategy.position_size > 0 and ta.barssince(conditionEntry) >= 5)
    strategy.close("Buy")


// Plot RSI on chart
plot(rsi_val, title="RSI", color=color.red)
hline(rsi_upper, title="Overbought Level", color=color.blue)
````
