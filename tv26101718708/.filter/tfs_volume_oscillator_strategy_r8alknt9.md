# TFS: Volume Oscillator Strategy

- url: https://www.tradingview.com/script/R8alknT9-TFS-Volume-Oscillator-Strategy/
- type: indicator
- pine_id: PUB;so4mxJES24q06AUuMLoLMalTq4upPwJr
- version: 1.0

## Description

This is the second part of TFS trading strategy. The concept of this 
 indicator is similar to that of On-Balance Volume indicator (OBV). It 
 is calculated according to these rules:
 If Close > Open, Volume is positive
 If Close < Open, Volume is negative
 If Close = Open, Volume is neutral
 Then you take the 7-day MA of the results. 

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 13/12/2017
// This is the second part of TFS trading strategy. The concept of this 
// indicator is similar to that of On-Balance Volume indicator (OBV). It 
// is calculated according to these rules:
// If Close > Open, Volume is positive
// If Close < Open, Volume is negative
// If Close = Open, Volume is neutral
// Then you take the 7-day MA of the results. 
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="TFS: Volume Oscillator", shorttitle="TFS: Volume Oscillator")
AvgLen = input(7, minval=1)
TopBand = input(40000, step=1)
LowBand = input(-35000, step=1)
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
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nRes, color=blue, title="TFS", style = histogram)
````
