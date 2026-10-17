# Momentum Strategy, rev.2

- url: https://www.tradingview.com/script/ogG62XFJ-Momentum-Strategy-rev-2/
- type: strategy
- pine_id: PUB;vyoKmKEp1TusvoTGpGLxcyf33bylQHxR
- version: 1.0

## Description

This is a revised version of the Momentum strategy listed in the built-ins.
For more information check out this resource: 
https://www.forexstrategiesresources.com/binary-options-trading-strategies/22-binary-options-strategy-60-min-bollineger-bands-and-momentum/

## Source Code

````pine
//@version=3
strategy("Momentum Strategy, rev.2", overlay=true)

//
// Data
//
src = input(close)
lookback = input(20)
cscheme=input(1, title="Bar color scheme", options=[1,2])

//
// Functions
//
momentum(ts, p) => (ts - ts[p]) / ts[p]

normalize(src, len) =>
    hi  = highest(src, len)
    lo  = lowest(src, len)
    res = (src - lo)/(hi - lo)

//
// Main
//
price = close
mid = sma(src, lookback)
mom = normalize(momentum(price, lookback),100)

//
// Bar Colors
//
clr1 = cscheme==1?black: red
clr2 = cscheme==1?white: green
barcolor(close < open ? clr1 : clr2)

//
// Strategy
//
if (mom > .5 and price > mid )
    strategy.entry("MomLE", strategy.long, stop=high+syminfo.mintick, comment="MomLE")
else
    strategy.cancel("MomLE")

if (mom < .5 and price < mid )
    strategy.entry("MomSE", strategy.short, stop=low-syminfo.mintick, comment="MomSE")
else
    strategy.cancel("MomSE")

//plot(strategy.equity, title="equity", color=red, linewidth=2, style=areabr)
````
