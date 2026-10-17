# GENESIS

- url: https://www.tradingview.com/script/pgYRZCYi/
- type: strategy
- pine_id: PUB;82b28efe63614ee8b8ec2655ff05d88b
- version: 1.0

## Description

Hola, espero les sirva, por favor dejen sus comentarios de sus resultados, saludos

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © genesisjgonzalezh

//@version=5
strategy("GENESIS", overlay=true)

lenght1= (20)
lenght2= (50)

ema1= ta.ema(close, lenght1)
ema2 = ta.ema(close, lenght2)

long = ta.crossover(ema1,ema2)


short = ta.crossover(ema2,ema1)

LongSignal  = ta.crossover (ema1,ema2)
ShortSignal = ta.crossunder (ema1,ema2)
plotshape(LongSignal , title="Señal para Long", color= color.green, location=location.belowbar, size=size.tiny, text="Long", textcolor=color.white)
plotshape(ShortSignal , title="Señal para Short", color= color.red, location=location.abovebar, size=size.tiny, text="Short", textcolor=color.white)

strategy.entry("long", strategy.long, when = long)
strategy.exit("Exit", "Long", profit = 10, loss = 2)
strategy.entry("short", strategy.short, when = short)
strategy.exit("Exit", "short", profit = 10, loss = 2)
````
