# New Highs-Lows Strategy

- url: https://www.tradingview.com/script/zK0YQ9ou-New-Highs-Lows-Strategy/
- type: strategy
- pine_id: PUB;9cfccb6fda864de0a7d4997423e93a01
- version: 1.0

## Description

Strategy based on the net of new highs minus new lows on the NASDAQ.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © pieroliviermarquis

//@version=4
strategy(title = "New Highs-Lows", shorttitle="New Highs-Lows Strategy", overlay=false, default_qty_type=strategy.percent_of_equity, default_qty_value=100, calc_on_every_tick=true)

newhigh = security("HIGQ", timeframe.period, close)
newlow = security("LOWQ", timeframe.period, close)

net = newhigh - newlow
sum_ = sum(net, 20)

avg_fast = ema(net, 10)
avg_slow = ema(net, 20)

buy = avg_fast > avg_slow and net > 0
sell = avg_fast < avg_slow  and net < 0

plot(net, title="Net NASDAQ", color=net > 0? color.green: color.red, style=plot.style_columns, linewidth=2)

if buy
    strategy.entry("Long", strategy.long, comment="")

if sell
    strategy.close("Long", comment="", alert_message="")
````
