# Pair Trade

- url: https://www.tradingview.com/script/UqPGgdR7-Pair-Trade/
- type: strategy
- pine_id: PUB;PzW99x3ut9dlxq9Nwokxb1I6zjrDBa7C
- version: 2.0

## Description

Pair trade with inputs:
* length of correlation and moving average
* trade pair
* spread threshold to enter long / short
* spread threshold to exit long / short

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © danilogalisteu

//@version=4
strategy("Pair Trade", default_qty_type=strategy.percent_of_equity, default_qty_value=100)

length = input(37, "SMA length", input.integer)
//
x = log(security((input("BOVA11")), timeframe.period, close))
y = log(security((input("SMAL11")), timeframe.period, close))
x_ = sma(x, length)
y_ = sma(y, length)
mx = stdev(x, length)
my = stdev(y, length)
c = correlation(x, y, length)

spread_entry = input(0.035, "Entry spread", input.float, step=0.005)
spread_exit = input(-0.015, "Exit spread", input.float, step=0.005)

beta = c * (my / mx)
alpha = y_ - beta * x_
spread = y - (alpha + x * beta)

//plot(alpha, color=color.white, transp=0)
//plot(beta, color=color.blue, transp=0)
//plot(c, color=color.blue, transp=0)
plot(spread, color=color.red, transp=0)

strategy.entry("SE", strategy.short, when=spread>spread_entry)
strategy.close("SE", when=spread<spread_exit)
strategy.entry("LE", strategy.long, when=spread<-spread_entry)
strategy.close("LE", when=spread>-spread_exit)
````
