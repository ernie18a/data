# KPL Swing Strategy

- url: https://www.tradingview.com/script/4mz6xvnK/
- type: strategy
- pine_id: PUB;2vsoKNPd3xFFCeaBq8PuktaWaZuCGcxI
- version: 4.0

## Description

The KPLSwing indicator is a simple trend following mechanical trading system which automates the entry and exit.

The trading system is extremely simple and easy to use and removes emotions from trading.

The trading or investing logic is simple.... buy on close above 20 days high and sell on close below 20 days low.

No targets are given as profits are unknown and is whatever the market gives. Losses are limited via position sizing.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ceyhun

//@version=4
strategy("KPL Swing Strategy", overlay=true)


no = input(20, title="Length")
res = highest(high, no)
sup = lowest(low, no)
avd = iff(close > res[1], 1, iff(close < sup[1], -1, 0))
avn = valuewhen(avd != 0, avd, 0)
tsl = iff(avn == 1, sup, res)
sl = iff(close > tsl, highest(lowest(low, no / 2), no / 2), lowest(highest(high, no / 2), no / 2))

Buy = crossover(close, tsl)
Sell = crossover(tsl, close)

Barcolor=input(true,title="Barcolor")
Bgcolor=input(true,title="Bgcolor")

colors=iff(close>tsl,color.green,iff(tsl<close,color.yellow,color.red))
barcolor(Barcolor ? colors:na)
bgcolor(Bgcolor ? colors:na)

plot(tsl,color=colors)
plot(sl,color=color.white,title="Stoploss")

if crossover(close, tsl)
    strategy.entry("Long", strategy.long, comment="Long")

if crossunder(close,tsl)
    strategy.entry("Short", strategy.short, comment="Short")
````
