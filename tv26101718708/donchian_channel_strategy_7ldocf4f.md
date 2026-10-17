# Donchian Channel Strategy

- url: https://www.tradingview.com/script/7lDOCF4F-Donchian-Channel-Strategy/
- type: strategy
- pine_id: PUB;bsDxr0XWIUNN8eA1uYT6a0lSGD3LgxfI
- version: 1.0

## Description

Ride the trend with full potential. Filter out false signals using long period ema. Lower bands take care of the stop loss. 
Use this strategy for banknifty futures for consistent quarterly returns.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © pratyush_trades

//@version=4
strategy("Donchian Channel Strategy", overlay=true)

length = input(20)
longRule = input("Higher High", "Long Entry", options=["Higher High", "Basis"])
shortRule = input("Lower Low", "Short Entry", options=["Lower Low", "Basis"])

hh = highest(high, length)
ll = lowest(low, length)

up = plot(hh, 'Upper Band', color = color.green)
dw = plot(ll, 'Lower Band', color = color.red)
mid = (hh + ll) / 2
midPlot = plot(mid, 'Basis', color = color.orange)
fill(up, midPlot, color=color.green, transp = 95)
fill(dw, midPlot, color=color.red, transp = 95)

if (close>ema(close,200))
    if (not na(close[length]))
        strategy.entry("Long", strategy.long, stop=longRule=='Basis' ? mid : hh)

if (close<ema(close,200))
    if (not na(close[length]))
        strategy.entry("Short", strategy.short, stop=shortRule=='Basis' ? mid : ll)

if (strategy.position_size>0)
    strategy.exit(id="Longs Exit",stop=ll)

if (strategy.position_size<0)
    strategy.exit(id="Shorts Exit",stop=hh)
````
