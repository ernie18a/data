# Warm_Up

- url: https://www.tradingview.com/script/5q0z53EQ-Warm-Up/
- type: strategy
- pine_id: PUB;3t4XrTjvXc3vjakOnJckTWAtnxBk8iMt
- version: 1.0

## Description

Warm_Up

I havent coded any scripts in some time, need to get back into the swing of things

## Source Code

````pine
//@version=4
strategy("Warm_Up", overlay=false)

range = security(syminfo.tickerid,'240',open)

o = sma(range,7)+sma(range,14)/2
ol = sma(range,14)+sma(range,28)/2
oll = sma(range,28)+sma(range,56)/2

plot(o)
plot(ol)
plot(oll)

cob = crossover(o, oll) and o > ol
cos = crossunder(o, oll) and o < ol

longCondition = cob
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)
    strategy.exit("My Long Entry Id", profit=1000,trail_points=50)

shortCondition = cos
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
    strategy.exit("My Short Entry Id", profit=1000,trail_points=50)
````
