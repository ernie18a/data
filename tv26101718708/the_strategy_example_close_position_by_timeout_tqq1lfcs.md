# The strategy example. Close position by timeout

- url: https://www.tradingview.com/script/Tqq1lFCS-The-strategy-example-Close-position-by-timeout/
- type: strategy
- pine_id: PUB;dd80f119679a4ce1849b60aa90c27f2b
- version: 1.0

## Description

This is an example how to close open entries by timeout for educational purpose.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © adolgov

//@version=5
strategy("The strategy example. Close position by timeout", overlay=true, margin_long=100, margin_short=100, process_orders_on_close=true)

longCondition = ta.crossover(ta.sma(close, 14), ta.sma(close, 28))
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)

shortCondition = ta.crossunder(ta.sma(close, 14), ta.sma(close, 28))
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)

closePositionAfter(timeoutS)=>
    if strategy.opentrades > 0
        for i = 0 to strategy.opentrades-1
            if time - strategy.opentrades.entry_time(i) >= timeoutS*1000
                entry = strategy.opentrades.entry_id(i)
                strategy.close(entry, comment = str.format("Close \"{0}\" by timeout {1}s", entry, timeoutS))
                
closePositionAfter(120) // close position after 120 sec
````
