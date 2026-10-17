# Gann High Low Strategy

- url: https://www.tradingview.com/script/4B9Gvzkb/
- type: strategy
- pine_id: PUB;JjjqX3JKfrvNQzookUaxwXjenOaFuczE
- version: 1.0

## Description

Gann High Low is a moving average based trend indicator consisting of two different simple moving averages.
The Gann High Low Activator Indicator was described by Robert Krausz in a 1998 issue of Stocks & Commodities Magazine. It is a simple moving average SMA of the previous n period's highs or lows.
The indicator tracks both curves (of the highs and the lows). The close of the bar defines which of the two gets plotted.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dongyun

//@version=4
strategy("Gann High Low Strategy", overlay=true)

HPeriod = input(16,"HIGH Period")
LPeriod = input(48,"LOW Period")

hsma = 0.0
lsma = 0.0

hsma := sma(high,HPeriod)
lsma := sma(low,LPeriod)

HLd = iff(close>nz(hsma[1]),1,iff(close<nz(lsma[1]),-1,0))
HLv = valuewhen(HLd!=0,HLd,0)
HiLo = iff(HLv==-1,hsma,lsma)
HLcolor = HLv == -1 ? color.maroon : color.blue

plot(HiLo, linewidth=2, color=HLcolor)

if HLv == -1
    strategy.entry("short", strategy.short)
else
    if HLv == 1
        strategy.entry("long", strategy.long)
````
