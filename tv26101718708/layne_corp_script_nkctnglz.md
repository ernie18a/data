# Layne Corp SCRIPT

- url: https://www.tradingview.com/script/NKCTNglZ-Layne-Corp-SCRIPT/
- type: strategy
- pine_id: PUB;6FM0tC0dYg4obFWCj59rdgI1e46mLhPt
- version: 1.0

## Description

Applicable to anything that can be bought or sold.

## Source Code

````pine
strategy("coin", overlay=true)

timeFilter = (year >= 2019) and (month >= 1) and (dayofmonth > 1)

ema = ema(high, 40)
hlc = hlc3

plot(ema)
plot(hlc)

long = cross(ema, hlc) and ema < hlc and timeFilter// and ema < bigema
short = cross(hlc, ema) and ema > hlc and timeFilter// and ema > bigema

strategy.entry("long", strategy.long, when=long)
strategy.entry("short", strategy.short, when=short)
````
