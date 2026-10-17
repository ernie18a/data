# Buy & Hold aka. HODL Strategy

- url: https://www.tradingview.com/script/GohWkf47-Buy-Hold-aka-HODL-Strategy/
- type: strategy
- pine_id: PUB;55322f92a47d42c9acc360d11a200a01
- version: 3.0

## Description

This is a simply HODL or Buy & Hold strategy, which is super useful to see the risk and reward of such a strategy.
The benefit of using this strategy is that you also get to see the Max Drawdown (Risk).
This way you can compare it to the Net Profit (Reward) and decide if it's worth it for you.

This strategy buys on the [b]Start Date[/b] and sells either on the [b]End Date[/b] or on the last candle if the [b]End Date[/b] is in the future.
[i]Remember that the strategy must close the trade (sell) otherwise you don't see any results in the Strategy Tester (this is how it works).[/i]

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © michaelionita

//@version=6
strategy("Buy & Hold aka. HODL Strategy", overlay=true, calc_on_every_tick=false, initial_capital=10000, default_qty_type=strategy.percent_of_equity, pyramiding=1, default_qty_value=100, commission_type=strategy.commission.percent, commission_value=0.1, slippage=0, fill_orders_on_standard_ohlc=true)

// Date condition inputs
startDate = input.time(title="Start Date", defval=timestamp("1 Jan 2018 00:00 +0000"), group="Dates")
endDate = input.time(title="End Date", defval=timestamp("31 Dec 2069 00:00 +0000"), group="Dates")
timeCondition = time >= startDate and time <= endDate

// Debugging
// log.info("time: {0}, startDate: {1} bar_index: {2}, ct: {3}", time, startDate, bar_index, strategy.closedtrades)
// label.new(bar_index, high, text = str.tostring(time), color = color.black, textcolor = color.white, yloc = yloc.abovebar)

if (time >= startDate and strategy.closedtrades == 0) or (time >= startDate and bar_index == 1)
    strategy.entry("long", strategy.long)

if (time >= endDate) or (bar_index >= last_bar_index - 1)
    strategy.close_all()

// Display equity line
plot(title="Equity Line", series=strategy.equity, trackprice=true, display=display.data_window, color=color.red)
````
