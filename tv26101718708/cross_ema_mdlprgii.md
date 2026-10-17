# Cross EMA

- url: https://www.tradingview.com/script/mDLPrgiI/
- type: strategy
- pine_id: PUB;Hrwch4ePRlDdhZukZzbi7SmDuVT4MRwa
- version: 1.0

## Description

Strategia basata su cross EMA

## Source Code

````pine
//@version=2
strategy(title='Cross EMA', shorttitle='Cross EMA', overlay=true, pyramiding=0, initial_capital=1000, currency=currency.USD)

//============ signal Generator ==================================//
CortaPeriodo=input(10)
LungaPeriodo=input(21)
corta=ema(close, CortaPeriodo)
lunga=ema(close, 20)
longCondition = crossover(corta,lunga)
if (longCondition)
    strategy.entry("BUY", strategy.long)
shortCondition = crossunder(corta,lunga)
if (shortCondition)
    strategy.entry("SELL", strategy.short)
plot(corta, title="EMA corta", linewidth=4, color=orange)
plot(lunga, title="EMA lunga", linewidth=4, color=silver)
///////////////////////////////////////////////////////////////////////////////////////////
````
