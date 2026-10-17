# Trend Balance Point System by Welles Wilder

- url: https://www.tradingview.com/script/w12N5Pq3-Trend-Balance-Point-System-by-Welles-Wilder/
- type: strategy
- pine_id: PUB;KI69Elh3pv6CPG73wJDg0Xi8jXPJLhnc
- version: 3.0

## Description

This is the original Trend Balance Point System created by Welles Wilders in 1978, rules can be found in his book New Concepts in Technical Trading Systems.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © 2020 X-Trader.net

//@version=3
strategy("Trend Balance Point System by Welles Wilder", overlay=true, default_qty_type = strategy.percent_of_equity, default_qty_value = 100, initial_capital = 10000)

MomPer = input(2, "Momentum Period")

isLong = strategy.position_size > 0
isShort = strategy.position_size < 0

longTrigger = mom(close, MomPer)[1] > mom(close, MomPer)[2] and mom(close, MomPer)[1] > mom(close, MomPer)[3]
shortTrigger = mom(close, MomPer)[1] < mom(close, MomPer)[2] and mom(close, MomPer)[1] < mom(close, MomPer)[3]

longEntry = (not isLong) and longTrigger 
shortEntry = (not isShort) and shortTrigger

longStop = valuewhen(longEntry, ((high[1]+low[1]+close[1])/3 - (high[1]-low[1])), 0)
longTP = valuewhen(longEntry, (2*(high[1]+low[1]+close[1])/3 - low[1]), 0)
shortStop = valuewhen(shortEntry, ((high[1]+low[1]+close[1])/3 + (high[1]-low[1])), 0)
shortTP = valuewhen(shortEntry, (2*(high[1]+low[1]+close[1])/3 - high[1]), 0)

strategy.entry(id = "Long", long = true, when = (longEntry and not isShort))
strategy.exit("Exit Long", "Long", profit = longTP, loss = longStop,  when = isLong) 

strategy.entry(id = "Short", long = false, when = (shortEntry and not isLong))
strategy.exit("Exit Short", "Short", profit = shortTP, loss = shortStop,  when = isShort)
````
