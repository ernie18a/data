# Ema Backtester

- url: https://www.tradingview.com/script/JO8IDVlT-Ema-Backtester/
- type: strategy
- pine_id: PUB;NOkxxBiGdeVqV17cZnmzQHZ6okDWMwyW
- version: 3.0

## Description

A simple, but useful script for backtesting purposes. Find the optimal Settings for your strategy.

tips are always welcome at: 38uGQJDDZDL6wX48x4gYTccPeQ3ZHVYmY4 (btc)

I hope you enjoy the script :)

## Source Code

````pine
//@version=3
//Double / makes code inactive in pinescript. Try removing them during testing to find optimal results.
//enjoy :)
//by somsbenikeenkat
strategy("Ema Backtester", overlay=true)
ema1=ema(close,input(24))
ema2=ema(close,input(53))
ema3=ema(close,input(80))
plot(ema1, "EMA1", yellow)
plot(ema2, "EMA2", white)
plot(ema3, "EMA3", blue)
barcolor(close>ema1 and ema1>ema2 ? lime : close<ema1 and ema1<ema2 ? red : gray)

if close>ema1 and ema1>ema2 //and ema2>ema3
    strategy.entry("Long", strategy.long)
if close<ema1 // and close[1]<ema1
    strategy.close("Long")

if close<ema1 and ema1<ema2 //and ema2<ema3
    strategy.entry("Short", strategy.short)
if close>ema1 // and close[1]>ema1
    strategy.close("Short")
````
