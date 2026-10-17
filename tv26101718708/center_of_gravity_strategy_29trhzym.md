# Center Of Gravity Strategy

- url: https://www.tradingview.com/script/29TRhzyM-Center-Of-Gravity-Strategy/
- type: indicator
- pine_id: PUB;r381RhbOSvQANlYWkuzjZu6HaGhuAXHh
- version: 1.0

## Description

The indicator is based on moving averages. On the basis of these, the 
 "center" of the price is calculated, and price channels are also constructed, 
 which act as corridors for the asset quotations.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 12/03/2018
// The indicator is based on moving averages. On the basis of these, the 
// "center" of the price is calculated, and price channels are also constructed, 
// which act as corridors for the asset quotations.
////////////////////////////////////////////////////////////
study(title="Center Of Gravity Strategy", shorttitle="CFO", overlay = true)
Length = input(20, minval=1)
m = input(5, minval=0)
Percent = input(1, minval=0)
SignalLine = input(1, minval=1, maxval = 2, title = "Trade from line (1 or 2)")
xLG = linreg(close, Length, m)
xLG1r = xLG + ((close * Percent) / 100)
xLG1s = xLG - ((close * Percent) / 100)
xLG2r = xLG + ((close * Percent) / 100) * 2
xLG2s = xLG - ((close * Percent) / 100) * 2
xSignalR = iff(SignalLine == 1, xLG1r, xLG2r)
xSignalS = iff(SignalLine == 1, xLG1s, xLG2s)
pos = iff(close > xSignalR, 1,
       iff(close < xSignalS, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(xLG, color=blue, title="CFO")
plot(xLG1r, color=green, title="LG1r")
plot(xLG2r, color=green, title="LG2r")
plot(xLG1s, color=red, title="LG1s")
plot(xLG2s, color=red, title="LG2s")
````
