# Highest High and Lowest Low channel Backtest

- url: https://www.tradingview.com/script/s0h29KkT-Highest-High-and-Lowest-Low-channel-Backtest/
- type: strategy
- pine_id: PUB;TXyEBZYJZ21UBS3gI5iQZdeVD0qHffzU
- version: 1.0

## Description

Highest High and Lowest Low channel Strategy

 You can change long to short in the Input Settings
 Please, use it only for learning or paper trading. Do not for real trading.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v2.0 23/02/2017
//  Highest High and Lowest Low channel Strategy
//
// You can change long to short in the Input Settings
// Please, use it only for learning or paper trading. Do not for real trading.
////////////////////////////////////////////////////////////
strategy(title="Trade channel", overlay = true)
PeriodLookBack = input(55)
reverse = input(false, title="Trade reverse")
xHighest55 = highest(PeriodLookBack)
xLowest55 = lowest(PeriodLookBack)
pos = iff(close > xHighest55[1], 1,
	     iff(close < xLowest55[1], -1, nz(pos[1], 0))) 
possig = iff(reverse and pos == 1, -1,
          iff(reverse and pos == -1, 1, pos))	   
if (possig == 1) 
    strategy.entry("Long", strategy.long)
if (possig == -1)
    strategy.entry("Short", strategy.short)	   	    
barcolor(possig == -1 ? red: possig == 1 ? green : blue )
plot(xHighest55[1], color=red, title="HH")
plot(xLowest55[1], color=green, title="LL")
````
