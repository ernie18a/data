# Price X MA Cross

- url: https://www.tradingview.com/script/UvI5z2DC-Price-X-MA-Cross/
- type: strategy
- pine_id: PUB;F0BSjb5JQidaY2JdyL1ZwiEjRBwMbuI4
- version: 2.0

## Description

Indicates long or short positions based on the crossing of price with a moving average. Different moving average types are available. There is a tolerance parameter to filter out false breakouts.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RafaelPiccolo

//@version=4
strategy("Price X MA Cross", overlay=true, initial_capital=1)

typ = input("HMA", "MA Type", options=["SMA", "EMA", "WMA", "HMA", "VWMA", "RMA", "TEMA"])
len = input(100, minval=1, title="Length")
src = input(close, "Source", type=input.source)
tol = input(0, minval=0, title="Tolerance (%)", type=input.float)

startYear = input(2000, 'Start Year')
startMonth = input(1, 'Start Month', minval=1, maxval=12)

tema(src, len)=>
    ema1 = ema(src, len)
    ema2 = ema(ema1, len)
    ema3 = ema(ema2, len)
    return = 3 * (ema1 - ema2) + ema3

getMAPoint(type, len, src)=>
    return = type == "SMA" ? sma(src, len) : type == "EMA" ? ema(src, len) : type == "WMA" ? wma(src, len) : type == "HMA" ? hma(src, len) : type == "VWMA" ? vwma(src, len) : type == "RMA" ? rma(src, len) : tema(src, len)

ma = getMAPoint(typ, len, src)
upperTol = ma * (1 + tol/100)
lowerTol = ma * (1 - tol/100)

timeFilter = (year >= startYear) and (year > startYear or (month >= startMonth))
longCondition = crossover(close, upperTol) and timeFilter
shortCondition = crossunder(close, lowerTol) and timeFilter

if (shortCondition)
    strategy.entry("Short", strategy.short)

if (longCondition)
    strategy.entry("Long", strategy.long)

plot(ma, "Moving Average", close > ma ? color.green : color.red, linewidth = 2)
t1 = plot(tol > 0 ? upperTol : na, transp = 70)
t2 = plot(tol > 0 ? lowerTol : na, transp = 70)
fill(t1, t2, color = tol > 0 ? color.blue : na)
````
