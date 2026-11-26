# High and Low Levels Strategy

- url: https://www.tradingview.com/script/f8vKNIrH-High-and-Low-Levels-Strategy/
- type: indicator
- pine_id: PUB;iT8PecVOitSEVVQy6NyP0XlTwjI4NVHP
- version: 1.0

## Description

This script shows a high and low period value.
    Width - width of lines
    SelectPeriod - Day or Week or Month and etc.
    LookBack - Shift levels 0 - current period, 1 - previous and etc.

 WARNING:
  - This script to change bars colors.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 29/06/2018
// This script shows a high and low period value.
//    Width - width of lines
//    SelectPeriod - Day or Week or Month and etc.
//    LookBack - Shift levels 0 - current period, 1 - previous and etc.
//
// WARNING:
//  - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="High and Low Levels Strategy", shorttitle="HL Levels", overlay = true)
SelectPeriod = input("D", defval="D", type=string)
LookBack = input(1,  minval=0)
xHigh  = security(tickerid, SelectPeriod, high[LookBack])
xLow   = security(tickerid, SelectPeriod, low[LookBack])
vS1 = xHigh
vR1 = xLow
pos = iff(close > vR1, 1,
       iff(close < vS1, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
````
