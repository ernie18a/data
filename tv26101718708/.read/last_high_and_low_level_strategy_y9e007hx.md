# Last High and Low Level Strategy

- url: https://www.tradingview.com/script/y9E007hX-Last-High-and-Low-Level-Strategy/
- type: indicator
- pine_id: PUB;G9UGIZNIbjS5NBJZAqbWljDHA7Gm4oSe
- version: 1.0

## Description

This script shows a high and low period value.
    SelectPeriod - Day or Week or Month and etc.
    LookBackPeriods - Shift levels 0 - current period, 1 - previous and etc.

 WARNING:
  - This script to change bars colors

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 06/07/2018
// This script shows a high and low period value.
//    SelectPeriod - Day or Week or Month and etc.
//    LookBackPeriods - Shift levels 0 - current period, 1 - previous and etc.
//
// WARNING:
//  - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Last High and Low Level Strategy", shorttitle="LHL Level", overlay = true)
SelectPeriod = input("D", defval="D", type=string)
LookBackPeriods = input(1,  minval=0)
xHigh  = security(tickerid, SelectPeriod, high[LookBackPeriods])
xLow   = security(tickerid, SelectPeriod, low[LookBackPeriods])
pos = iff(close > xHigh, 1,
       iff(close < xLow, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
````
