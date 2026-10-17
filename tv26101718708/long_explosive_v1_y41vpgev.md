# Long Explosive V1

- url: https://www.tradingview.com/script/Y41VPgEV/
- type: strategy
- pine_id: PUB;2816f6039feb4f85aca981c32b7508db
- version: 2.0

## Description

The “Long Explosive V1” strategy calculates the percentage change in price from the last closing price of the candlestick, so that if it increases by a certain percentage it goes long, but if it decreases by another percentage it sends an exit order, so that the percentage limits above and below the current price function as inherent stop loss and take profit, with the benefit of taking advantage of the volatility of the bull market.

Entries and exits are always at the market and based on percentage changes in the price. Of course, the default configuration of the strategy considers a position with a 5% risk control, modest initial capital and standard commissions, which helps to obtain realistic results and protect the user from unexpectedly controlled potential losses.

It is again emphasized that it is always advisable to adjust the parameters of the strategy well, so that the risk-reward is well controlled.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © morzns
//@version=6
strategy("Long Explosive V1", overlay = true, default_qty_type = strategy.percent_of_equity, default_qty_value = 5, initial_capital = 1000, commission_value = 0.01, calc_on_every_tick = true)

longLimit = input.float(1.00, title = "Price increase (%):", minval = 0.1, step = 0.1) * close * 0.01
shortLimit = input.float(1.00, title = "Price decrease (%):", minval = 0.1, step = 0.1) * close * 0.01

buyCondition = ta.change(close, 1) > longLimit
sellCondition = ta.change(close, 1) < -shortLimit

if sellCondition
    strategy.close_all()
if buyCondition
    strategy.close_all()
    strategy.entry("Long", strategy.long)
````
