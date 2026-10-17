# My Strategy

- url: https://www.tradingview.com/script/HjlpiM3j-My-Strategy/
- type: strategy
- pine_id: PUB;817cd63489f44820b76cb83edfde45fd
- version: 1.0

## Description

This is for educational purpose. Strategy is a test strategy to take long and short position

## Source Code

````pine
//@version=5
//Script will identify inside candles (candles that don't go above/below previous range)

strategy("My Strategy", overlay=true)
shortSMA = ta.sma(close, 10)
longSMA = ta.sma(close, 30)
rsi = ta.rsi(close, 14)
longCondition = ta.crossover(shortSMA, longSMA)
shortCondition = ta.crossunder(shortSMA, longSMA)
atr = ta.atr(14)

if (longCondition)
    stopLoss = low - atr * 2
    takeProfit = high + atr * 2
    strategy.entry("long", strategy.long, 100, when = rsi > 50)
    strategy.exit("exit", "long", stop=stopLoss, limit=takeProfit)
if (shortCondition)
    stopLoss = high + atr * 2
    takeProfit = low - atr * 2
    strategy.entry("short", strategy.short, 100, when = rsi < 50)
    strategy.exit("exit", "short", stop=stopLoss, limit=takeProfit)
````
