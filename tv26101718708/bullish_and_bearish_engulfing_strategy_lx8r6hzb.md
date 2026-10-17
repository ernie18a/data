# Bullish and Bearish Engulfing Strategy

- url: https://www.tradingview.com/script/lx8r6hZb-Bullish-and-Bearish-Engulfing-Strategy/
- type: strategy
- pine_id: PUB;3042
- version: -1.0

## Description

I've been trying to put a stop loss in the High or Low of the last second bar after I open a position but in this example the only way to close it, is with the opposite action. Does anyone know how to put a stop loss and order with just stop loss and close when there is a bullish or bearish engulfing bar?

## Source Code

````pine
//@version=2
strategy("Super Envolvente", overlay=true)

secLast = 1

checkingHighsAndLows(position) =>
    high >= high[position] and low <= low[position]

isBearishEngulfing(position) =>
    checkingHighsAndLows(position) and open >= close[position] and open >= open[position] and close <= open[position] and close <= close[position]

isBullishEngulfing(position) =>
    checkingHighsAndLows(position) and open <= close[position] and open <= open[position] and close >= open[position] and close >= close[position]


longCondition = isBullishEngulfing(1)

if (longCondition)
    strategy.entry("Long Entry", strategy.long)

shortCondition = isBearishEngulfing(1)

if (shortCondition)
    strategy.entry("Short Entry", strategy.short)
````
