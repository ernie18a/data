# DaveStrat

- url: https://www.tradingview.com/script/zMD0MU0U-DaveStrat/
- type: strategy
- pine_id: PUB;20a255b907904ce9a575b068ac12a0ae
- version: 1.0

## Description

This script attempts to guess inflection points in cryptocurrency asset prices using change in two simple moving averages on the daily timescale.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © David Frausto Pena
//@version=5
strategy("DaveStrat")
if bar_index < 10000
    goindicator  = ta.change(ta.sma(ta.sma(close,25),3))
    dropindicator = ta.change(ta.sma(ta.sma(close,100),3))
    strategy.entry("buy", strategy.long, 10, when=((goindicator)-dropindicator) > 0.0)
    if ta.sma(close,3)-ta.sma(close,25)<0
        strategy.entry("sell", strategy.short, 10, when=dropindicator-goindicator > 0)
plot(ta.change(ta.sma(ta.sma(close,25),3)),"50madeltasmooth", color.green)
plot(ta.change(ta.sma(ta.sma(close,100),3)),"100madeltasmooth", color.red)
````
