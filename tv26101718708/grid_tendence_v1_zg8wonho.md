# Grid Tendence V1

- url: https://www.tradingview.com/script/zG8wONho/
- type: strategy
- pine_id: PUB;af9d36c9603e4b99b894617400e0ca60
- version: 2.0

## Description

The “Grid Tendence V1” strategy is based on the classic Grid strategy, only in this case the entries and exits are made in favor of the trend, which allows to take advantage of large movements to maximize profits, since it is also possible to enter and exit with the balance with a controlled risk, because precisely the distance between each Grid works as a natural and adaptable stop loss and take profit. This fact helps to avoid overlapping entries and exits that would result from using stop loss and take profit as limit orders.

In this version of the script the entries and exits are always at market, and based on the percentage change of the price, not on the profit or loss of the current position.

The user will notice that the strategy setup is based on a controlled risk, risking 5% on each trade, a fairly standard commission and a modest initial capital, all this in order to protect the user of the strategy from unexpected or unrealistic results.

However, it is always recommended to optimize the parameters so that the strategy is effective for each asset and for each time frame.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © morzns
//@version=6
strategy('Grid Tendence V1', overlay = true, default_qty_type = strategy.percent_of_equity, default_qty_value = 5, initial_capital = 1000, commission_value = 0.01, calc_on_every_tick = true)

percent = input.float(1.00, title = '(%) Grid:', minval = 0.1, step = 0.1)
entry = strategy.closedtrades.exit_price(strategy.closedtrades - 1)

funA(close) =>
    strategy.close_all()
    strategy.entry('Long', strategy.long)
funB(close) =>
    strategy.close_all()
    strategy.entry('Short', strategy.short)

if strategy.position_size == 0
    strategy.entry('Long', strategy.long)
else if strategy.position_size > 0
    if strategy.opentrades.profit_percent(strategy.opentrades - 1) >= percent
        funA(close)
    else if strategy.opentrades.profit_percent(strategy.opentrades - 1) <= -percent
        funB(close)
else if strategy.position_size < 0
    if strategy.opentrades.profit_percent(strategy.opentrades - 1) >= percent
        funB(close)
    else if strategy.opentrades.profit_percent(strategy.opentrades - 1) <= -percent
        funA(close)

plot(entry, title = 'Close', color = color.gray, linewidth = 1, style = plot.style_circles)
````
