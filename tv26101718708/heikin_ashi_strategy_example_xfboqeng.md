# Heikin Ashi Strategy Example

- url: https://www.tradingview.com/script/xFBoQENG-Heikin-Ashi-Strategy-Example/
- type: strategy
- pine_id: PUB;pGlUhUhvNKNXwzDG9ApWwb9LOAEeEdS5
- version: 1.0

## Description

A strategy which calculates it's entry/exit conditions using HeikinAshi prices and executes orders using real prices (usual candles). NOTE that strategy should be added on a usual candles chart. Heikin Ashi prices are requested in the Pine code using 'security' function.

This is a possible solution to a question https://getsatisfaction.com/tradingview/topics/strategy-tester-places-incorrect-orders-in-backtesting-when-using-heikin-ashi-candles?reply[id]=19502808#reply_19502808

## Source Code

````pine
// NOTE: Add this strategy on a usual candles chart, NOT on a HeikinAshi chart.
//@version=3 
strategy("Heikin Ashi Strategy Example", overlay=true)

haTicker = heikinashi(tickerid)
haOpen = security(haTicker, period, open)
haClose = security(haTicker, period, close)

longCondition = haClose > haOpen and haOpen > haClose[1]
exitCondition = haClose < haOpen

if (time > timestamp(2018,5,11,0,0)) and time < timestamp(2018,5,15,0,0)
    strategy.entry("Long", strategy.long, 100, when = longCondition)
    
strategy.close_all(when = exitCondition)
````
