# LSX: Mystery BTC strategy with 100% hit rate

- url: https://www.tradingview.com/script/Lbe2FYN6-LSX-Mystery-BTC-strategy-with-100-hit-rate/
- type: strategy
- pine_id: PUB;dRapHBeMa9tehYufqPJXdzignhg5VBCD
- version: 2.0

## Description

I said in the main crypto chat, that it was easy to create a BS strategy with a 100% profit rate, so here's the proof.

Looks awesome right? I can promise you, if you trade with this, it will sooner or later [b]blow your account.[/b]

Keeping the inner workings of it a secret, just like the scammers do.

Why am I publishing this? To show why investing in these 'mystery strategies' is a terrible idea. That's also why I've hidden the code, so it looks more attractive than it really is.


[b]Say safe, don't get scammed. Don't get rekt.[/b]

## Source Code

````pine
//@version=3
strategy("LSX", overlay=true, default_qty_value=100)

shortSym = "BTCUSDSHORTS"
longSym = "BTCUSDLONGS"
src = input(close)

shorts = security(shortSym, period, src)
longs = security(longSym, period, src)

longCondition = crossover(shorts, longs)
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)

shortCondition = crossunder(shorts, longs)
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
    
    //rekt*2
````
