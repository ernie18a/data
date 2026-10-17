# Swing Points

- url: https://www.tradingview.com/script/S0ZeE5AO-Swing-Points/
- type: strategy
- pine_id: PUB;FxC9pS0uxDU9ILUl4ZK2gTUpViq4iuTk
- version: 2.0

## Description

work in progress

## Source Code

````pine
//@version=3
strategy("Swing Points", overlay=true)


leftBars = input(1)
rightBars=input(1)
sl = pivotlow(low, leftBars, rightBars)
sh = pivothigh(high, leftBars, rightBars)

last_sh=na
last_sh:= sh!=0 ? sh : nz(last_sh[1])

last_sl=na
last_sl:= sl!=0 ? sl : nz(last_sl[1])


EMA = ema(close,55)

longCondition = sh and high > EMA
shortCondition = sl and close < EMA
exitLongCondition = sl < sh[1]
exitShortCondition = sh > sl[1]

if longCondition 
    strategy.entry("swinghigh", strategy.long, stop=last_sh)
    
if shortCondition 
    strategy.entry("swinglow", strategy.short, stop=last_sl)
   
if exitLongCondition
    strategy.exit("stoplong", "swinghigh", stop = last_sl )

if exitShortCondition
    strategy.exit("stopshort", "swinglow", stop = last_sh )
    
plot(EMA,linewidth = 4)
plotshape(sh, style=shape.triangleup, location=location.abovebar, color=green, size=size.tiny)
plotshape(sl, style=shape.triangledown, location=location.belowbar, color=red, size=size.tiny)
````
