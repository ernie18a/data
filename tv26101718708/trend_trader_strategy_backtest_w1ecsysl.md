# Trend Trader Strategy Backtest

- url: https://www.tradingview.com/script/w1ecsySl-Trend-Trader-Strategy-Backtest/
- type: strategy
- pine_id: PUB;IbsJZpQWIpGVROUBpyLt4Q5eB3vNgOKw
- version: 2.0

## Description

This is plots the indicator developed by Andrew Abraham 
 in the Trading the Trend article of TASC September 1998  

 You can change long to short in the Input Settings
 Please, use it only for learning or paper trading. Do not for real trading.

## Source Code

````pine
//@version=4
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 12/01/2017
// This is plots the indicator developed by Andrew Abraham 
// in the Trading the Trend article of TASC September 1998  
//
// You can change long to short in the Input Settings
// Please, use it only for learning or paper trading. Do not for real trading.
////////////////////////////////////////////////////////////
strategy(title="Trend Trader Strategy", overlay = true)
Length = input(21, minval=1),
Multiplier = input(3, minval=1)
reverse = input(false, title="Trade reverse")
ret = 0.0
pos = 0.0
avgTR      = wma(atr(1), Length)
highestC   = highest(Length)
lowestC    = lowest(Length)
hiLimit = highestC[1]-(avgTR[1] * Multiplier)
loLimit = lowestC[1]+(avgTR[1] * Multiplier)
ret :=iff(close > hiLimit and close > loLimit, hiLimit,
       iff(close < loLimit and close < hiLimit, loLimit, nz(ret[1], 0)))
pos :=iff(close > ret, 1,
	   iff(close < ret, -1, nz(pos[1], 0))) 
possig = iff(reverse and pos == 1, -1,
          iff(reverse and pos == -1, 1, pos))	   
if (possig == 1) 
    strategy.entry("Long", strategy.long)
if (possig == -1)
    strategy.entry("Short", strategy.short)	   	    
barcolor(possig == -1 ? color.red: possig == 1 ? color.green : color.blue )
plot(ret, color= color.blue , title="Trend Trader Strategy")
````
