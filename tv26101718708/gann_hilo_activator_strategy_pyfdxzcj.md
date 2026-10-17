# Gann HiLo Activator Strategy

- url: https://www.tradingview.com/script/PyFdxzcj-Gann-HiLo-Activator-Strategy/
- type: strategy
- pine_id: PUB;b79f18bea0da4de49ec7be5531a2b091
- version: 1.0

## Description

█ OVERVIEW

Strategy based on the [url=https://www.tradingview.com/script/Ggq66ykL-Gann-HiLo-Activator/]Gann Hilo Activator[/url]. This is a trend following strategy, which means it will go long (and close the previous short position) once the price closes above the high SMA, and go short (and close the previous long position) once the price closes below the low SMA.

█ PARAMETERS

- Length
- Displace (or offset): default is 1
- Begin from start: strategy will run since the beggining
- From year, month, day: Choose an specific date to start backtesting (must disable the parameter above to work)

█ HOW TO USE

After choosing the start date to run the strategy, you can change the length field and look at the backtest results to find the most optimal settings for the current symbol.

This strategy was tested on the stock and crypto market with good results. Hope you enjoy!

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © starbolt

//@version=5
strategy('Gann HiLo Activator Strategy', overlay=true, pyramiding=0, default_qty_type=strategy.percent_of_equity, default_qty_value=20, initial_capital=1000, process_orders_on_close=true)

len = input.int(3, 'Length', step=1, minval=1)
displace = input.int(1, 'Offset', step=1, minval=0)
from_start = input(false, 'Begin from start?')
backtest_year = input(2017, 'From Year')
backtest_month = input.int(01, 'From Month', minval=1, maxval=12, step=1)
backtest_day = input.int(01, 'From Day', minval=1, maxval=31, step=1)

start_time = from_start ? 0 : timestamp(backtest_year, backtest_month, backtest_day, 00, 00)

float hilo = na
hi = ta.sma(high, len)
lo = ta.sma(low, len)

hilo := close > hi[displace] ? 1 : close < lo[displace] ? -1 : hilo[1]
ghla = hilo == -1 ? hi[displace] : lo[displace]
color = hilo == -1 ? color.red : color.green

buyCondition = hilo == 1 and hilo[1] == -1
sellCondition = hilo == -1 and hilo[1] == 1

if buyCondition and time >= start_time
    strategy.entry('Long', strategy.long)

if sellCondition and time >= start_time
    strategy.entry('Short', strategy.short)

plot(ghla, color=color, style=plot.style_cross)
````
