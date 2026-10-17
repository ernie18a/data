# Simple Momentum and Trend, Fixed PnL Strategy for SPY 1D [SR]

- url: https://www.tradingview.com/script/82er3iVb-Simple-Momentum-and-Trend-Fixed-PnL-Strategy-for-SPY-1D-SR/
- type: strategy
- pine_id: PUB;770f3e495b504b55a238528063e54501
- version: 2.0

## Description

This strategy uses an ATR rule to assess momentum and a TSI rule to assess bullish or bearishness
It has a fixed stop at 50 points, and fixed take profit at 300 pips

It provides a very satisfyingly smooth equity line with a max drawdown below 5% and realized profit over 200% 
This is the initial version as I work out optimizations and add plots to the chart based on the strategy's actions.

I would love to get the community's feedback and help as I'm new. Not sure how to limit the date range of the backtest to make it more realistic. I'm also not certain how to plot it best.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ShayanRastgou

//@version=5
strategy("Simple Momentum and Trend, Fixed PnL Strategy for SPY 1D", overlay=false, margin_long=20, margin_short=20, pyramiding = 25, default_qty_type = strategy.percent_of_equity, default_qty_value = 5, initial_capital = 10000)

// Set stop loss and take profit levels
stopLoss = 50
takeProfit = 300

// Set order size and pyramiding
orderSize = 2
maxPositions = 25

// Define long entry condition
longCondition = ta.atr(5) > ta.atr(20) and ta.tsi(close, 13, 25) > 0
if (longCondition and strategy.position_size < maxPositions)
    strategy.entry("My Long Entry Id" + str.tostring(bar_index), strategy.long, stop=stopLoss, limit=takeProfit)

// Define short entry condition
shortCondition = ta.atr(5) > ta.atr(20) and ta.tsi(close, 13, 25) < 0
if (shortCondition and strategy.position_size < maxPositions)
    strategy.entry("My Short Entry Id" + str.tostring(bar_index), strategy.short, stop=stopLoss, limit=takeProfit)

// Plot the 5-period ATR
plot(ta.atr(5), color=color.red, linewidth=2, title="5-Period ATR")

// Plot the 20-period ATR
plot(ta.atr(20), color=color.orange, linewidth=2, title="20-Period ATR")

// Plot the TSI
plot(ta.tsi(close, 13, 25), color=color.green, linewidth=2, title="TSI")
````
