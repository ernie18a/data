# Chimichangas

- url: https://www.tradingview.com/script/5EMOLrSy-Chimichangas/
- type: strategy
- pine_id: PUB;L5p26F1ZbWNN2mY2U1HrDwr9WFq4xwCu
- version: 1.0

## Description

TradingView has released fractional contracts for cryptocurrencies. Very cool, very swag. This script is to see how it works, and to test the efficiency of position sizing.

(I would like to see % based stops or take profits instead of ticks added too)

## Source Code

````pine
//@version=3
strategy("Chimichangas", overlay=true)

st_yr = input(2018, "Year Start")
st_mn = input(06,  "Month Start")
st_dd = input(15,    "Day Start")

start = time >= timestamp(st_yr, st_mn, st_dd, 00, 00)

chimi = sma(sma(sma(sma(sma(rma(ema(wma(vwma(swma(ohlc4), 1), 2), 3), 4), 5), 6), 7), 8), 9)
changas = sma(rma(ema(wma(vwma(avg(highest(ohlc4, 6), lowest(ohlc4, 9)), 10), 20), 30), 40), 50)

plot(chimi, "Profit", green, 2)
plot(changas, "Upside Down Profit", red, 2)

eq = (0.05 * strategy.equity) / close

longCondition = crossover(chimi,changas) and start
if (longCondition)
    strategy.entry("Long", 1, qty = eq)
    strategy.close("Long", when = close < valuewhen(crossover(chimi,changas) and start, close * .95, 0) or crossunder(chimi,changas))

shortCondition = crossunder(chimi,changas) and start
if (shortCondition)
    strategy.entry("Short", 0, qty = eq)
    strategy.close("Long", when = close > valuewhen(crossover(chimi,changas) and start, close * 1.05, 0) or crossover(chimi,changas))
````
