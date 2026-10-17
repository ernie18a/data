# ChannelBreakOutStrategy

- url: https://www.tradingview.com/script/hfrFcHcL/
- type: strategy
- pine_id: PUB;Qw7NEqYdIwaLlY8OLqrtMdeRwOkLCvMT
- version: 1.0

## Description

test

## Source Code

````pine
//@version=3
strategy("ChannelBreakOutStrategy", overlay=true)

length = input(title="Length", type=integer, minval=1, maxval=1000, defval=18)

upBound = highest(high, length)
downBound = lowest(low, length)

if (not na(close[length]))
    strategy.entry("Long", strategy.long, stop=upBound + syminfo.mintick, comment="Long")
    strategy.entry("Short", strategy.short, stop=downBound - syminfo.mintick, comment="Short")

//plot(strategy.equity, title="equity", color=red, linewidth=2, style=areabr)
````
