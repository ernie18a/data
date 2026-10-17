# Kota Test

- url: https://www.tradingview.com/script/n2NmenUm-Kota-Test/
- type: indicator
- pine_id: PUB;3c43b3c8a5664f41b520c6c3513dc27b
- version: 1.0

## Description

Really good. This strat is one of a kind you dont wanna miss.

## Source Code

````pine
//@version=6
indicator("Kota Test", overlay=true)

var float orbHigh = na
var float orbLow = na

if high > high[1]
    orbHigh := high

if low < low[1]
    orbLow := low

plot(orbHigh, color=color.green)
plot(orbLow, color=color.red)
````
