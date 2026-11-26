# Hmmmmmmmm_Yea_Ok

- url: https://www.tradingview.com/script/Egt7KpuW-Hmmmmmmmm-Yea-Ok/
- type: strategy
- pine_id: PUB;OBJ2FrQwCYmW6z2xuHHUbjh3flbtXurJ
- version: 1.0

## Description

Hmmmmmmmm_Yea_Ok


Just testing different things out

## Source Code

````pine
//@version=4
strategy("Hmmmmmmmm_Yea_Ok", overlay=true)


DAY = security(syminfo.tickerid,'D',open)
fhour = security(syminfo.tickerid,'240',open)
Ohour = security(syminfo.tickerid,'60',open)

longCondition = DAY[1] < ema(DAY,14) and mom(fhour[1],14) < 0 and crossunder(ema(open,14),ema(open,28)) and ema(Ohour,14) > ema(Ohour,28)
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)

shortCondition = DAY[1] > ema(DAY,14) and mom(fhour[1],14) > 0 and crossover(ema(open,14),ema(open,28)) and ema(Ohour,14) > ema(Ohour,28) 
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
````
