# Just_Try_Different_Things

- url: https://www.tradingview.com/script/YDLfGHT8-Just-Try-Different-Things/
- type: strategy
- pine_id: PUB;Gu0JYgGHSZMrcZtElcaGtPC5CdzuXj98
- version: 1.0

## Description

Just_Try_Different_Things

## Source Code

````pine
//@version=4
strategy("Just_Try_Different_Things", overlay=true)


Sig = security(syminfo.tickerid,'15',open)

H = ema(highest(Sig,60),60)
L = ema(lowest(Sig,60),60)




longCondition = crossunder(sma(H, 30), sma(H, 60))
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)

shortCondition = crossover(sma(L, 30), sma(L, 60))
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
````
