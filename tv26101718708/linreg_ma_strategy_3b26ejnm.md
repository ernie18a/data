# linreg Ma Strategy

- url: https://www.tradingview.com/script/3b26EJnM/
- type: strategy
- pine_id: PUB;TFsmReSGyTpEXMrUYSkcDxQoZHAwd81r
- version: 1.0

## Description

Use linreg change strategy

## Source Code

````pine
//@version=3
strategy("linreg ATR Strategy",overlay=false)
lengthKC=input(30,"Length")
SignalPeriod=input(10, title="Signal Length")
sc=close-avg(avg(highest(high, lengthKC), lowest(low, lengthKC)),sma(close,lengthKC))
lineregs=linreg(sc,lengthKC,0)
emasc=sma(lineregs,SignalPeriod)
plot(lineregs)
plot(emasc, color=red, linewidth=2)
longCondition = crossover(lineregs,emasc)
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)
shortCondition = crossunder(lineregs,emasc)
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
````
