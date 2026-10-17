# Trend Trader AVR Strategy

- url: https://www.tradingview.com/script/Qa64CyD7-Trend-Trader-AVR-Strategy/
- type: indicator
- pine_id: PUB;NcN4vXBRBXxks9kZ9LEf6cvJi8ufsogi
- version: 1.0

## Description

This is plots the indicator developed by Andrew Abraham 
 in the Trading the Trend article of TASC September 1998  
 It was modified, result values wass averages.

## Source Code

````pine
//@version=3
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 08/10/2018
// This is plots the indicator developed by Andrew Abraham 
// in the Trading the Trend article of TASC September 1998  
// It was modified, result values wass averages.
////////////////////////////////////////////////////////////
study(title="Trend Trader AVR Strategy", overlay = true)
Length = input(21, minval=1),
LengthMA = input(21, minval=1),
Multiplier = input(3, minval=1)
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
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nResMA, color= blue , title="Trend Trader AVR")
````
