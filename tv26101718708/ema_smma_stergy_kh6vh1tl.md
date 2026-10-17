# EMA SMMA STERGY

- url: https://www.tradingview.com/script/KH6Vh1tL-EMA-SMMA-STERGY/
- type: strategy
- pine_id: PUB;2mLnWo2LkMA3L3a6qDukQpLRERyXPsOX
- version: 1.0

## Description

EMA AND SMOOTH MA STERGY

## Source Code

````pine
//@version=3
// Modified from kivancfr3762's A2MK script

strategy("EMA STRATEGY", overlay=true)

smma=input(35, "SMMA Length")
ema=input(9, "EMA Length")

ema_sr = ema((max(close[1], high) + min(close[1], low)) / 2, ema)

highest_ema = ema(highest(ema_sr, 3), smma)
lowest_ema = ema(lowest(ema_sr, 3), smma)
k1 = ema_sr > highest_ema
k2 = ema_sr < lowest_ema

ema_ysl = iff(k1, lowest_ema, highest_ema)


longCondition = crossover(ema_ysl, ema_sr)
if (longCondition)
    strategy.entry("Short", strategy.short)

shortCondition = crossunder(ema_ysl, ema_sr)
if (shortCondition)
    strategy.entry("Long", strategy.long)
````
