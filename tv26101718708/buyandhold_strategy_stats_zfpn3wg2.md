# Buy-and-hold strategy stats

- url: https://www.tradingview.com/script/ZfPn3wG2-Buy-and-hold-strategy-stats/
- type: strategy
- pine_id: PUB;rA1l4LXMQVRVkYsOEFN5QWAoL0IGPs6x
- version: 1.0

## Description

When you develop your own strategy you should compare its performance to the "buy-and-hold" strategy (you buy the financial instrument and you hold it long term). Ideally your strategy should perform better than the buy-and-hold strategy. While the net profit % of the buy-and-hold strategy is available under the "Performance Summary" tab of the "Strategy Tester" there are other factors that should be considered though. This is where this strategy comes in. It mimics the buy-and-hold strategy and gives you all the stats that are available for any strategy. For example, one such criteria that should be considered is the max. drawdown. Even if you strategy performs worse than the buy-and-hold strategy in terms of net profit, if the max. drawdown of your strategy is considerably lower than that of the buy-and-hold it may overall be a better strategy than the buy-and-hold as, in this scenario, it likely exposes the investor to significantly less risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradersForecast

//@version=4
strategy("Buy-and-hold strategy stats", overlay=true, pyramiding=1, initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=100, process_orders_on_close=true)
minDate = input(timestamp("01 Jan 2010 0:0 -0500"), title = "Start Date/Time", type = input.time)
maxDate = input(timestamp("01 Jan 2030 0:0 -0500"), title = "End Date/Time", type = input.time)
revTrd = input(false, title="Short position? (else it defaults to LONG)", type=input.bool)

strategy.close_all()
if time >= minDate and time <= maxDate
    strategy.entry("My Long Entry Id", revTrd ? strategy.short : strategy.long)
````
