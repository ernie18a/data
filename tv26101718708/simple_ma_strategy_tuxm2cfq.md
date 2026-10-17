# Simple MA strategy

- url: https://www.tradingview.com/script/TUxm2CFQ-Simple-MA-strategy/
- type: strategy
- pine_id: PUB;kTItkEbF7VDiUKMnD7OoY2RTu1aaDzbo
- version: 1.0

## Description

Simple above below MA strategy perfect for long term investors , numbers worked on a 1 for 1 contract basis with enough capital to cover the trades. Heikin ashi 1 hr

## Source Code

````pine
//@version=3
strategy("The simplest", overlay=true) 

ema3 = sma(hlc3, 400)
wma3 = ema(ema3, 2)
wma4 = ema(wma3, 2)
wma5 = ema(wma4, 200)

plot(wma5, color=red, linewidth =2)

longCondition = open[1] < wma5 and close > wma5 
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)
shortCondition = open[1] > wma5 and close < wma5 
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
````
