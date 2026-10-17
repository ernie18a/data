# TEMA1 Strategy

- url: https://www.tradingview.com/script/6Dk5iUCk-TEMA1-Strategy/
- type: indicator
- pine_id: PUB;3KWLpyBPJ2M7B3SwnxO828rHWiKNcHmI
- version: 1.0

## Description

This study plots the TEMA1 indicator. TEMA1 ia s triple MA (Moving Average),
 and is calculated as 3*MA - (3*MA(MA)) + (MA(MA(MA)))

 WARNING:
  - This script to change bars colors.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 13/08/2018
// This study plots the TEMA1 indicator. TEMA1 ia s triple MA (Moving Average),
// and is calculated as 3*MA - (3*MA(MA)) + (MA(MA(MA)))
//
// WARNING:
//  - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="TEMA1 Strategy", shorttitle="TEMA", overlay = true )
Length = input(26, minval=1)
xPrice = close
xEMA1 = ema(xPrice, Length)
xEMA2 = ema(xEMA1, Length)
xEMA3 = ema(xEMA2, Length)
nRes = 3 * xEMA1 - 3 * xEMA2 + xEMA3
pos = iff(close > nRes, 1,
       iff(close < nRes, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
````
