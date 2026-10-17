# Average Highest High and Lowest Low Swinger Strategy

- url: https://www.tradingview.com/script/jZyFMNoL-Average-Highest-High-and-Lowest-Low-Swinger-Strategy/
- type: strategy
- pine_id: PUB;9f28d89388d24e1287e29b2ad6cdd776
- version: 1.0

## Description

This is a full price action strategy designed for trending markets such as crypto and stocks.

Its purely made on calculations for the highest high and lowest low using 2 different length , a faster and a slower one.
With those we make multiple averages.

Rules for entry:
For long: our close of the candle is above both the average using fast and slow line
For short: our close of the candle is below both the average using fast and slow line


Rules for exit
We always exit when we have an opposite order


Caution
This strategy use no risk management system, so be careful with it 


If you have any questions, let me know

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © exlux99

//@version=4
strategy(title = "Avg HH/LL Crypto Swinger", overlay = true, initial_capital = 100, default_qty_type= strategy.percent_of_equity, default_qty_value = 100, commission_type=strategy.commission.percent,commission_value=0.1)

varLo = input(title="Fast Line", type=input.integer, defval=9, minval=1)
varHi = input(title="Slow  Line", type=input.integer, defval=26, minval=1)

a = lowest(varLo)
b = highest(varLo)
c = (a + b ) / 2

d = lowest(varHi)
e = highest(varHi)
f = (d + e) / 2

g = ((c + f) / 2)[varHi]
h = ((highest(varHi * 2) + lowest(varHi * 2)) / 2)[varHi]



long=close > c and close > f and close >g and close > h
short=close < c and close < f and close<g and close < h

strategy.entry("long",1,when=long)
strategy.entry('short',0,when=short)
````
