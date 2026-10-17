# Trend Trader Bands Strategy

- url: https://www.tradingview.com/script/sBoTQO7v-Trend-Trader-Bands-Strategy/
- type: indicator
- pine_id: PUB;x1q6ZjPXwcZw4pAK6gEtRfgkzuwRkErY
- version: 1.0

## Description

This is plots the indicator developed by Andrew Abraham 
 in the Trading the Trend article of TASC September 1998  
 It was modified, result values wass averages.
 And draw two bands above and below TT line.

## Source Code

````pine
//@version=3
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 15/10/2018
// This is plots the indicator developed by Andrew Abraham 
// in the Trading the Trend article of TASC September 1998  
// It was modified, result values wass averages.
// And draw two bands above and below TT line.
////////////////////////////////////////////////////////////
study(title="Trend Trader Bands Strategy", overlay = true)
Length = input(21, minval=1),
LengthMA = input(21, minval=1),
BandStep = input(20),
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
pos := iff(close < nResMA - BandStep , -1,
       iff(close > nResMA + BandStep, 1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nResMA, color= blue , title="Trend Trader AVR")
plot(nResMA+BandStep, color= red , title="Trend Trader UpBand")
plot(nResMA-BandStep, color= green, title="Trend Trader DnBand")
````
