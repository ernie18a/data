# Turtle Trend Trading System [racer8]

- url: https://www.tradingview.com/script/6TnqZSoe-Turtle-Trend-Trading-System-racer8/
- type: strategy
- pine_id: PUB;6qbl2X17wZuHK2GNdSLjsnQ2AWuNFMHo
- version: 1.0

## Description

This is the Turtle traders' actual system which uses a 55 period channel for entries & a 20 period channel for exits. Enjoy ;)

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © racer8
//@version=4
strategy("Turtle System", overlay=true)

n = input(55,"Entry Length")
e = input(20,"Exit Length")

HI = highest(n)
LO = lowest(n)
hi = highest(e)
lo = lowest(e)

if close>HI[1]
    strategy.entry("Buy", strategy.long)

if close<LO[1]
    strategy.entry("Sell", strategy.short)
    
if low<lo[1]
    strategy.close("Buy")

if high>hi[1]
    strategy.close("Sell")

plot(HI,color=color.lime)
plot(LO,color=color.red)
plot(hi,color=color.blue)
plot(lo,color=color.maroon)
````
