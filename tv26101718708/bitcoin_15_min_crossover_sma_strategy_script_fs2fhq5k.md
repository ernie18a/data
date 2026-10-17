# Bitcoin 15 min crossover SMA Strategy Script

- url: https://www.tradingview.com/script/fS2fhQ5k-Bitcoin-15-min-crossover-SMA-Strategy-Script/
- type: strategy
- pine_id: PUB;3sd9THzfz8TIwn9cI5antaXSPRefg2p9
- version: 1.0

## Description

Is a very simple script that must be used on the 15 min chart of BTCUSD, and works.
Tested same EA in production since 2016.
Use the 200 and 50 SMA to buy and sell.
Works well!
Enjoi!

## Source Code

````pine
//@version=3
strategy("My Strategy", overlay=true)

longCondition = crossover(sma(close, 50), sma(close, 200))
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)

shortCondition = crossunder(sma(close, 50), sma(close, 200))
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
````
