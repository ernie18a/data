# TFS: Volume Oscillator Backtest

- url: https://www.tradingview.com/script/TyW3PD4L-TFS-Volume-Oscillator-Backtest/
- type: strategy
- pine_id: PUB;pHNAmxhoeTq6PyaCS6v64s4pHz0Hq5Wl
- version: 1.0

## Description

This is the second part of TFS trading strategy. The concept of this 
 indicator is similar to that of On-Balance Volume indicator (OBV). It 
 is calculated according to these rules:
 If Close > Open, Volume is positive
 If Close < Open, Volume is negative
 If Close = Open, Volume is neutral
 Then you take the 7-day MA of the results. 

 You can change long to short in the Input Settings
 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 15/12/2017
// This is the second part of TFS trading strategy. The concept of this 
// indicator is similar to that of On-Balance Volume indicator (OBV). It 
// is calculated according to these rules:
// If Close > Open, Volume is positive
// If Close < Open, Volume is negative
// If Close = Open, Volume is neutral
// Then you take the 7-day MA of the results. 
//
// You can change long to short in the Input Settings
// WARNING:
// - For purpose educate only
// - This script to change bars colors.
////////////////////////////////////////////////////////////
strategy(title="TFS: Volume Oscillator", shorttitle="TFS: Volume Oscillator")
AvgLen = input(7, minval=1)
TopBand = input(40000, step=1)
LowBand = input(-35000, step=1)
reverse = input(false, title="Trade reverse")
hline(TopBand, color=red, linestyle=line)
hline(LowBand, color=green, linestyle=line)
hline(0, color=blue, linestyle=line)
xClose = close
xOpen = open
xVolume = volume
nVolAccum = sum(iff(xClose > xOpen, xVolume, iff(xClose < xOpen, -xVolume, 0))  ,AvgLen)
nRes = nVolAccum / AvgLen
pos = iff(nRes > TopBand, 1,
       iff(nRes < LowBand, -1, nz(pos[1], 0))) 
possig = iff(reverse and pos == 1, -1,
          iff(reverse and pos == -1, 1, pos))	   
if (possig == 1) 
    strategy.entry("Long", strategy.long)
if (possig == -1)
    strategy.entry("Short", strategy.short)	   	    
barcolor(possig == -1 ? red: possig == 1 ? green : blue ) 
plot(nRes, color=blue, title="TFS", style = histogram)
````
