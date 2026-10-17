# TEMA With Alert and backtest

- url: https://www.tradingview.com/script/6SYhwt5i-TEMA-With-Alert-and-backtest/
- type: strategy
- pine_id: PUB;hvNkdMpZrJOV7dgMks6ieHbE8RieSzh3
- version: 2.0

## Description

added backtest function

## Source Code

````pine
//@version=2
strategy(title="TEMA With Alert", shorttitle="ALRTEMA", overlay = true )
//Blue
Length = input(34, minval=1)
xPrice = close
xEMA1 = ema(xPrice, Length)
xEMA2 = ema(xEMA1, Length)
xEMA3 = ema(xEMA2, Length)
nRes = 3 * xEMA1 - 3 * xEMA2 + xEMA3

//RED
Length2 = input(13, minval=1)
xPrice2 = close
xEMA12 = ema(xPrice2, Length2)
xEMA22 = ema(xEMA12, Length2)
xEMA32 = ema(xEMA22, Length2)
nRes2 = 3 * xEMA12 - 3 * xEMA22 + xEMA32

short = cross(nRes, nRes2) and nRes > nRes2
long = cross(nRes, nRes2) and nRes < nRes2

strategy.entry("long", strategy.long, when=long)
strategy.entry("short", strategy.short, when=short)
````
