# Trend Trader AVR Backtest

- url: https://www.tradingview.com/script/DgXbsw50-Trend-Trader-AVR-Backtest/
- type: strategy
- pine_id: PUB;9iWb4K5yBnSr0Gt7MwEU56DqRaaPjfJD
- version: 1.0

## Description

This is plots the indicator developed by Andrew Abraham 
 in the Trading the Trend article of TASC September 1998  
 It was modified, result values wass averages.

## Source Code

````pine
//@version=3
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 10/10/2018
// This is plots the indicator developed by Andrew Abraham 
// in the Trading the Trend article of TASC September 1998  
// It was modified, result values wass averages.
////////////////////////////////////////////////////////////
strategy(title="Trend Trader AVR Backtest", overlay = true)
Length = input(21, minval=1),
LengthMA = input(21, minval=1),
Multiplier = input(3, minval=1)
reverse = input(false, title="Trade reverse")
avgTR      = wma(atr(1), Length)
highestC   = highest(Length)
lowestC    = lowest(Length)
hiLimit = highestC[1]-(avgTR[1] * Multiplier)
loLimit = lowestC[1]+(avgTR[1] * Multiplier)
ret = 0.0
ret :=  iff(close > hiLimit and close > loLimit, hiLimit,
         iff(close < loLimit and close < hiLimit, loLimit, nz(ret[1], 0)))
nResMA = ema(ret, LengthMA)        
pos = 0
pos := iff(close < nResMA, -1,
       iff(close > nResMA, 1, nz(pos[1], 0))) 
possig = iff(reverse and pos == 1, -1,
          iff(reverse and pos == -1, 1, pos))	   
if (possig == 1) 
    strategy.entry("Long", strategy.long)
if (possig == -1)
    strategy.entry("Short", strategy.short)	   	    
barcolor(possig == -1 ? red: possig == 1 ? green : blue ) 
plot(nResMA, color= blue , title="Trend Trader AVR")
````
