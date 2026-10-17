# SMA 10/100 Crossover Strategy intended for BTCUSD on 4 hourly

- url: https://www.tradingview.com/script/WyYSSuth-SMA-10-100-Crossover-Strategy-intended-for-BTCUSD-on-4-hourly/
- type: strategy
- pine_id: PUB;naO7KB5CN7qs3EQTob6HFId4acubOFBg
- version: 1.0

## Description

A really simple trend/momentum following crossover strategy intended for higher timeframes to trade BTCUSD and other crypto pairs.

## Source Code

````pine
//@version=3
//study(title="MA Crossover Strategy", overlay = true)
// Simple MA crossover strategy with a 10/100 MA crossover)

strategy("MA Crossover Strategy", overlay=true)
src = input(close, title="Source")

price = security(tickerid, period, src)
ma1 = input(10, title="1st MA Length")
type1 = input("SMA", "1st MA Type", options=["SMA", "EMA"])

ma2 = input(100, title="2nd MA Length")
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
