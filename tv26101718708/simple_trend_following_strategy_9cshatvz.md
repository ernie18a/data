# Simple Trend Following Strategy

- url: https://www.tradingview.com/script/9CsHATvz-Simple-Trend-Following-Strategy/
- type: strategy
- pine_id: PUB;OMgNC0Xs2DHy78S9gBwrMVY7Yb1x2df3
- version: 1.0

## Description

Super simple short/long entry signal strategy based off the one used by the "Turtles" with 4 simple moving averages rolled into one indicator.

## Source Code

````pine
//@version=3
strategy("Trend Following", overlay=true, default_qty_type = strategy.percent_of_equity, default_qty_value = 10)

maxIdLossPcnt = input(1, "Max Intraday Loss(%)", type=float)
entryLong = false
entryShort = false

strategy.risk.max_intraday_loss(maxIdLossPcnt, strategy.percent_of_equity)

if (close > highest(high[1], 20))
    strategy.entry("Long fast", strategy.long)
    entryLong = true
    

if (close < lowest(low[1], 20))
    strategy.entry("Short fast", strategy.short)
    entryShort = true
    
if (close > highest(high[1], 55))
    strategy.entry("Long slow", strategy.long)
    entryLong = true

if (close < lowest(low[1], 55))
    strategy.entry("Short slow", strategy.short)
    entryShort = true

len1 = input(21, minval=1, title="21 SMA")
src1 = input(close, title="21 SMA")
out1 = sma(src1, len1)
plot(out1, title="21 SMA", color= white)

len2 = input(50, minval=1, title="50 SMA")
src2 = input(close, title="50 SMA")
out2 = sma(src2, len2)
plot(out2, title="50 SMA", color= blue)

len3 = input(100, minval=1, title="100 SMA")
src3 = input(close, title="100 SMA")
out3 = sma(src3, len3)
plot(out3, title="100 SMA", color= orange)

len4 = input(200, minval=1, title="200 SMA")
src4 = input(close, title="200 SMA")
out4 = sma(src4, len4)
plot(out4, title="200 SMA", color= green)
````
