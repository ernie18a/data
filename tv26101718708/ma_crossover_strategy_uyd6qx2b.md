# MA Crossover Strategy

- url: https://www.tradingview.com/script/uyd6qx2b-MA-Crossover-Strategy/
- type: strategy
- pine_id: PUB;QKMFJbE47QqdwpdN1MSeaKzTa923RhBx
- version: 1.0

## Description

Allows you to backtest different SMA & EMA crossover strategies.

## Source Code

````pine
//@version=3
//study(title="MA Crossover Strategy", overlay = true)
strategy("MA Crossover Strategy", overlay=true)
src = input(close, title="Source")

price = security(tickerid, period, src)
ma1 = input(25, title="1st MA Length")
type1 = input("SMA", "1st MA Type", options=["SMA", "EMA"])

ma2 = input(50, title="2nd MA Length")
type2 = input("SMA", "2nd MA Type", options=["SMA", "EMA"])

price1 = if (type1 == "SMA")
    sma(price, ma1)
else
    ema(price, ma1)
    
price2 = if (type2 == "SMA")
    sma(price, ma2)
else
    ema(price, ma2)


//plot(series=price, style=line,  title="Price", color=black, linewidth=1, transp=0)
plot(series=price1, style=line,  title="1st MA", color=blue, linewidth=2, transp=0)
plot(series=price2, style=line, title="2nd MA", color=green, linewidth=2, transp=0)


longCondition = crossover(price1, price2)
if (longCondition)
    strategy.entry("Long", strategy.long)

shortCondition = crossunder(price1, price2)
if (shortCondition)
    strategy.entry("Short", strategy.short)
````
