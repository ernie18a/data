# Stock_Strat_HL_V1

- url: https://www.tradingview.com/script/gE3gAqE4-Stock-Strat-HL-V1/
- type: strategy
- pine_id: PUB;6Yet5YFM0sQFs5jmRNjd9bB8GfB8slot
- version: 1.0

## Description

Stock_Strat_HL_V1 applied to BTC with some additional filters

## Source Code

````pine
//@version=4
strategy("Stock_Strat_HL_V1", overlay=true)

Week = security(syminfo.tickerid,'D',open)

H = highest(Week[1],16)
L = lowest(Week[1],16)

plot(H)
plot(L)

longCondition = close[2] > H and H[2] > H[1] and close > H
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long,stop=H)
    strategy.exit("My Long Entry Id",profit=1000,loss=100,trail_points=100)

shortCondition = close[2] < L and L[2] > L[1] and close < L
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short,stop=L)
    strategy.exit("My Short Entry Id",profit=1000,loss=100,trail_points=100)
````
