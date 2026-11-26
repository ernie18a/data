# OBV Trend

- url: https://www.tradingview.com/script/dG2enMXm/
- type: strategy
- pine_id: PUB;lbPpSfFQA0cr5k03E196LCUFZuN7AzVl
- version: 1.0

## Description

OBV Trend

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dongyun

//@version=4
strategy("均衡交易量指标系统", overlay=true)
//strategy.risk.allow_entry_in(strategy.direction.long)
period = input(60,'')
OBVlocal = 0.0

if close > close[1]
    OBVlocal := nz(OBVlocal[1]) + volume
else
    if close < close[1]
        OBVlocal := nz(OBVlocal[1]) - volume
    else
        OBVlocal := nz(OBVlocal[1])

MAOBV = sma(OBVlocal,period)

if MAOBV > MAOBV[1]
    strategy.entry("Long", strategy.long, when=strategy.position_size <= 0)
else
    if MAOBV < MAOBV[1]
        strategy.entry("Short", strategy.short, when=strategy.position_size > 0)
````
