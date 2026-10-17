# Hour breakout model

- url: https://www.tradingview.com/script/rluzVelm-Hour-breakout-model/
- type: strategy
- pine_id: PUB;wDccwWlSxSLsif0s6vAjIp1PMP7sOsdz
- version: 2.0

## Description

Hi guys, this is my first script and i need help to upgrade it

I'm sure this work better if:
1) the breakout line green and red are the max and min of the "time window" between 03 00 and 07 00 (and not only 03 00 like now)
2) put stoploss on the redline for long, and on greenline for short

Thx for any help

## Source Code

````pine
//@version=3
strategy("My Strategy", overlay=true)

highTimeFrame = input("D", type=resolution)
sessSpec = input("0300-0700")

is_newbar(res, sess) =>
    t = time(res, sess)
    na(t[1]) and not na(t) or t[1] < t

newbar = is_newbar("2300", sessSpec)
s1 = na
s1 := newbar ? low : nz(s1[1])
s2 = na
s2 := newbar ? high : nz(s2[1])

plot(s1, style=circles, linewidth=3, color=red)
plot(s2, style=circles, linewidth=3, color=lime)

longCondition = crossover (s2, close)
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)

shortCondition = crossunder(s1, close)
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
````
