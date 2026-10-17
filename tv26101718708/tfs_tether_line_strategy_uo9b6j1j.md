# TFS: Tether Line Strategy

- url: https://www.tradingview.com/script/Uo9b6j1j-TFS-Tether-Line-Strategy/
- type: indicator
- pine_id: PUB;woljpILVrFEr3DbLHaSFlDHKit3NvARD
- version: 1.0

## Description

Tether line indicator is the first component of TFS trading strategy.
 It was named this way because stock prices have a tendency to cluster
 around it. It means that stock prices tend to move away from the midpoint
 between their 50-day highs and lows, then return to that midpoint at some
 time in the future. On a chart, it appears as though the stock price is
 tethered to this line, and hence the name.

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 06/12/2017
// Tether line indicator is the first component of TFS trading strategy.
// It was named this way because stock prices have a tendency to cluster
// around it. It means that stock prices tend to move away from the midpoint
// between their 50-day highs and lows, then return to that midpoint at some
// time in the future. On a chart, it appears as though the stock price is
// tethered to this line, and hence the name.
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="TFS: Tether Line", shorttitle="Tether Line", overlay = true )
Length = input(50, minval=1)
lower = lowest(Length)
upper = highest(Length)
xTether = avg(upper, lower)
pos = iff(xTether > close, -1,
       iff(xTether < close, 1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(xTether, color=green, title="Tether Line")
````
