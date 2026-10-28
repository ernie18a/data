# Last High and Low Level Backtest

- url: https://www.tradingview.com/script/yVMNfEZw-Last-High-and-Low-Level-Backtest/
- type: strategy
- pine_id: PUB;FeHu8t1fdebN5QNTBEsvZDmpJHF3J82B
- version: 1.0

## Description

This script shows a high and low period value.
    SelectPeriod - Day or Week or Month and etc.
    LookBackPeriods - Shift levels 0 - current period, 1 - previous and etc.

 You can change long to short in the Input Settings
 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 13/07/2018
// This script shows a high and low period value.
//    SelectPeriod - Day or Week or Month and etc.
//    LookBackPeriods - Shift levels 0 - current period, 1 - previous and etc.
//
// You can change long to short in the Input Settings
// WARNING:
// - For purpose educate only
// - This script to change bars colors.
////////////////////////////////////////////////////////////
strategy(title="Last High and Low Level Backtest", shorttitle="LHL Level", overlay = true)
SelectPeriod = input("D", defval="D", type=string)
LookBackPeriods = input(1,  minval=0)
reverse = input(false, title="Trade reverse")
xHigh  = security(tickerid, SelectPeriod, high[LookBackPeriods])
xLow   = security(tickerid, SelectPeriod, low[LookBackPeriods])
pos = iff(close > xHigh, 1,
       iff(close < xLow, -1, nz(pos[1], 0))) 
possig = iff(reverse and pos == 1, -1,
          iff(reverse and pos == -1, 1, pos))	   
if (possig == 1) 
    strategy.entry("Long", strategy.long)
if (possig == -1)
    strategy.entry("Short", strategy.short)	   	    
barcolor(possig == -1 ? red: possig == 1 ? green : blue )
````
