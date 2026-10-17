# DEMA 10-15-21-30

- url: https://www.tradingview.com/script/pbbY2XBu/
- type: strategy
- pine_id: PUB;vPRMEpvAawBTFHrcAdSzU66gileUUV1z
- version: 2.0

## Description

..

## Source Code

````pine
//@version=3
//Author: HighProfit

//Lead-In
strategy("dema10-15-21-30", shorttitle="4dema", overlay=true)

short = input(10, minval=1)
srcShort = input(close, title="Source Dema 1")

long = input(15, minval=1)
srcLong = input(close, title="Source Dema 2")

long2 = input(21, minval=1)
srcLong2 = input(close, title="Source Dema 3")

long3 = input(30, minval=1)
srcLong3 = input(ohlc4, title="Source Dema 4")

e1 = ema(srcShort, short)
e2 = ema(e1, short)
dema1 = 2 * e1 - e2
plot(dema1, color=green, linewidth = 2)

e3 = ema(srcLong, long)
e4 = ema(e3, long)
dema2 = 2 * e3 - e4
plot(dema2, color=blue, linewidth = 2)

e5 = ema(srcLong2, long2)
e6 = ema(e5, long2)
dema3 = 2 * e5 - e6
plot(dema3, color=black, linewidth = 2)

e7 = ema(srcLong3, long3)
e8 = ema(e7, long3)
dema4 = 2 * e7 - e8
plot(dema4, color=red, linewidth = 2)

//Conditions
longCondition = (dema1>dema2) and (dema1>dema3) and (dema1>dema4) and (dema2>dema3) and (dema2>dema4) and (dema3>dema4)

if (longCondition)

    strategy.entry("Long", strategy.long)

strategy.close("Long",  cross(dema1,dema2))

shortCondition = (dema4>dema3) and (dema4>dema2) and (dema4>dema1) and (dema3>dema2) and (dema3>dema1) and (dema2>dema1)
if (shortCondition)
    strategy.entry("Short", strategy.short)
    
strategy.close("Short", cross(dema1,dema2))

bgcolor(longCondition?green:white , transp=85, offset=1)
bgcolor(shortCondition?red:white , transp=85, offset=1)

alertcondition(longCondition, title="Buy", message="Buy!")

alertcondition(shortCondition, title="Sell", message="Sell!")
````
