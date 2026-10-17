# JSC_5/13 EMAs

- url: https://www.tradingview.com/script/t4es983A-JSC-5-13-EMAs/
- type: strategy
- pine_id: PUB;sbyvsdZyzGKWu59IC4U51pC4vEVxD6gG
- version: 1.0

## Description

Simple EMA trading strategy

## Source Code

````pine
//@version=2
strategy(title="JSC_5/13 EMAs", shorttitle="5/13 EMAs", overlay = true)
lns = input(true, title="long positions only if checked, long and short positions if unchecked")
lo = lns ? 0:1
lenshort = input(5, minval=1, title="Length")
lenlong = input(13, minval=1, title="Length")
src = input(close, title="Source")
outshort = ema(src, lenshort)
outlong = ema(src,lenlong)
plot(outshort, title="EMA", color=blue)
plot(outlong, title="EMA", color=blue)

longCondition = cross(outshort,outlong) and outshort > outlong ? 1:0
shortCondition = cross(outshort,outlong) and outshort < outlong ? 1:0
//plot(longCondition)
//plot(shortCondition)

if (longCondition)
    strategy.entry("5/13 EMAs", strategy.long)
strategy.close("5/13 EMAs", when = shortCondition and lo ==1)    
    
if (shortCondition and lns)
    strategy.entry("5/13 EMAs", strategy.short)
````
