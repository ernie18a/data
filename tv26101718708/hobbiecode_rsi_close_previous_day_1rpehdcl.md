# Hobbiecode - RSI + Close previous day

- url: https://www.tradingview.com/script/1rpeHDCL/
- type: strategy
- pine_id: PUB;c05d51c81c2944f18f9ac3399b2beed5
- version: 1.0

## Description

This is a simple strategy that is working well on SPY but also well performing on Mini Futures SP500. The strategy is composed by the followin rules:

1. If RSI(2) is less than 15, then enter at the close.
2. Exit on close if today’s close is higher than yesterday’s high.

If you backtest it on Mini Futures SP500 you will be able to track data from 1993. It is important to select D1 as timeframe.

Please share any comment or idea below.

Have a good trading,
Ramón.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © hobbiecode

// If RSI(2) is less than 15, then enter at the close.
// Exit on close if today’s close is higher than yesterday’s high.

//@version=5
strategy("Hobbiecode - RSI + Close previous day", overlay=true)

// RSI parameters
rsi_period = 2
rsi_lower = 15

// Calculate RSI
rsi_val = ta.rsi(close, rsi_period)

// Check if RSI is lower than the defined threshold
if (rsi_val < rsi_lower)
    strategy.entry("Buy", strategy.long)

// Check if today's close is higher than yesterday's high
if (strategy.position_size > 0 and close > ta.highest(high[1], 1))
    strategy.close("Buy")

// Plot RSI on chart
plot(rsi_val, title="RSI", color=color.red)
hline(rsi_lower, title="Oversold Level", color=color.blue)
````
