# Please help to make Larry Williams' volatility breakthrough.

- url: https://www.tradingview.com/script/Du8sJ2tf/
- type: strategy
- pine_id: PUB;j4qd5LVIcYtEkFyJhLk2qUZUsqIxK4zZ
- version: 1.0

## Description

Hello Traders!

I'm going to backtest Larry Williams' volatility breakthrough strategy.
However, contrary to my expectation, orders at certain bars are made the next day.
Is there anything I missed at my pine script code?
Please give me any tiny tips. 

Thank you!!

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ⓒ kgp1202

//@version=4
strategy("larry wiliams", overlay=true)

R = 0.5
range = high[1] - low[1]
buy_price = open + R * range

plot(buy_price)

if bar_index > 6000
    strategy.entry("BUY", strategy.long, stop=buy_price, when=strategy.position_size == 0)
    strategy.close("BUY")
````
