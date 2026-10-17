# RWI Strategy

- url: https://www.tradingview.com/script/tYmjLdkw-RWI-Strategy/
- type: strategy
- pine_id: PUB;oDFUeduBP27YUEWAYGLaT6VMvhaUTP4Q
- version: 1.0

## Description

A test of the RWI used purely for long/short signals proves surprisingly profitable on 3H and 4H XBTUSD and ETHUSD.

## Source Code

````pine
//@version=4
// Copyright (c) 2020-present, JMOZ (1337.ltd)
strategy("RWI Strategy", overlay=false, default_qty_type=strategy.percent_of_equity, default_qty_value=100, initial_capital=10000, commission_value=0.075)


length = input(title="Length", type=input.integer, defval=14, minval=1)
threshold = input(title="Threshold", type=input.float, defval=1.0, step=0.1)


rwi(length, threshold) =>
    rwi_high = (high - nz(low[length])) / (atr(length) * sqrt(length))
    rwi_low = (nz(high[length]) - low) / (atr(length) * sqrt(length))
    is_rw = rwi_high < threshold and rwi_low < threshold
    [is_rw, rwi_high, rwi_low]


[is_rw, rwi_high, rwi_low] = rwi(length, threshold)


long = not is_rw and rwi_high > rwi_low
short = not is_rw and rwi_low > rwi_high


strategy.entry("Long", strategy.long, when=long)
strategy.entry("Short", strategy.short, when=short)


plot(rwi_high, title="RWI High", linewidth=1, color=is_rw?color.gray:color.blue, transp=0)
plot(rwi_low, title="RWI Low", linewidth=1, color=is_rw?color.gray:color.red, transp=0)
````
