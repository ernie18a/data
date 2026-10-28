# VWAPStrategy

- url: https://www.tradingview.com/script/t1lk7Uvk-VWAPStrategy/
- type: strategy
- pine_id: PUB;hRRQNjFicLj6CKsjxCQ7FCon7Owse7Zt
- version: 1.0

## Description

Cross ema3 with VWAP. Just to give imression of how a day migth be divided in a long- and short bias zone. Not suited as trading signal.

## Source Code

````pine
//@version=2
//Not suited for trading, signals show late
//Use in 1 minutes chart
strategy(title="VWAPStrategy", overlay=true)

//Values for Simple Moving Average fast
valfast=3
//Value for VWAP
valslow= vwap(hlc3)

long = sma(close, valfast)
short = valslow

plot(short, color = red)
plot(long, color = green)

longCond=crossover(long,short)
shortCond=crossover(short,long)
strategy.entry("LONG", strategy.long, when=longCond)
strategy.entry("SHORT", strategy.short, when=shortCond)
strategy.exit("EXLONG", from_entry="LONG", when=shortCond)
strategy.exit("EXSHORT", from_entry="SHORT", when=longCond)
````
