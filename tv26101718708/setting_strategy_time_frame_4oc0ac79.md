# Setting Strategy Time Frame

- url: https://www.tradingview.com/script/4Oc0Ac79-Setting-Strategy-Time-Frame/
- type: strategy
- pine_id: PUB;dZaISUg7MICCbwEZqsmm8GXIwm3MB48o
- version: 1.0

## Description

Advancing my previous post on my first pine script strategy in which i built a working Moving Average Crossover strategy, we now added a custom time frame.

## Source Code

````pine
//@version=2
strategy("Setting Strategy Time Frame")

ema20 = ema(close, 20)
ema50 = ema(close, 50)

long = ema20 > ema50 
short = ema20 < ema50 

testPeriodStart = timestamp(2010,7,2,0,0)

testPeriodStop = timestamp(2018,8,30,0,0)

if time >= testPeriodStart and time <= testPeriodStop
    strategy.entry("Long", strategy.long, 10000.0, when=long)
    strategy.entry("Short", strategy.short, 10000.0, when=short)
    

strategy.close("Long", when = short)
strategy.close("Short", when = long)
````
