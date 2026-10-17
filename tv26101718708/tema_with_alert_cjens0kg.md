# TEMA With Alert

- url: https://www.tradingview.com/script/cjenS0kG-TEMA-With-Alert/
- type: strategy
- pine_id: PUB;3lj8P21vSBVD8KvrF1yt2JhVm9s8YUnu
- version: 1.0

## Description

TEMA Strat

## Source Code

````pine
//@version=2
strategy(title="TEMA With Alert", shorttitle="ALRTEMA", overlay = true )
//Blue
Length = input(233, minval=1)
xPrice = close
xEMA1 = ema(xPrice, Length)
xEMA2 = ema(xEMA1, Length)
xEMA3 = ema(xEMA2, Length)
nRes = 3 * xEMA1 - 3 * xEMA2 + xEMA3

//RED
Length2 = input(21, minval=1)
xPrice2 = close
xEMA21 = ema(xPrice2, Length2)
xEMA22 = ema(xEMA21, Length2)
xEMA32 = ema(xEMA22, Length2)
nRes2 = 3 * xEMA21 - 3 * xEMA22 + xEMA32

short = cross(nRes, xEMA21) and nRes > xEMA21
long = cross(nRes, xEMA21) and nRes < xEMA21

strategy.entry("long", strategy.long, when=long)
strategy.entry("short", strategy.short, when=short)
````
