# ChannelsBreakout

- url: https://www.tradingview.com/script/nNt11l6M-ChannelsBreakout/
- type: strategy
- pine_id: PUB;cBR5hb4VcV9GEMhacgh9Qdsb16s1Qflw
- version: 1.0

## Description

This script allows you to intercept price channel breakouts (Donchian channel) in a bullish perspective. Applicable both on Equities/ETFs and on Futures (Index Futures).

We open a position when closes crosses the upper channel. The trade ends with a trailing associated with a fast lower Donchian or a monetary stop loss.

It is an educational code and does not constitute a solicitation for public savings.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Giovanni_Trombetta

// Strategy to capture price channel breakouts

//@version=4
strategy("ChannelsBreakout", max_bars_back=50, overlay=true)

instrument = input(1, title = "Select 1: Stock/Forex, 2: Future")
money = input(10000, title = "Money for each trade")
backtest_start = input(2000, "Insert first year to backtest")
period = input(50, title = "Period in bars of Donchian Channel")
monetary_stoploss = input(1000, title = "Monetary Stop Loss")

quantity = if instrument != 1 
    1
else
    int(money / close)
    
upBarrier = highest(high,period)
downBarrier = lowest(low,period)
up = highest(high,period / 4)
down = lowest(low,period / 4)

plot(upBarrier, color=color.green, linewidth=2)
plot(downBarrier, color=color.red, linewidth=2)
plot(up, color=color.lime, linewidth=1)
plot(down, color=color.orange, linewidth=2)

longCondition = crossover(close, upBarrier[1]) and year >= backtest_start

if (longCondition)
    strategy.entry("Long", strategy.long, quantity, when = strategy.position_size == 0)

closeCondition = crossunder(close, down[1]) or down < down[1]

if (closeCondition)
    strategy.close("Long", comment = "Trailing")
    
stop_level = strategy.position_avg_price - monetary_stoploss / strategy.position_size
strategy.exit("StopLoss", from_entry = "Long", stop = stop_level)
plot(stop_level, color=color.yellow, linewidth=2)

l = label.new(bar_index, na,
  text="PineScript Code", color= color.lime, textcolor = color.white,
  style=label.style_labelup, yloc=yloc.belowbar, size=size.normal)
label.delete(l[1])
````
