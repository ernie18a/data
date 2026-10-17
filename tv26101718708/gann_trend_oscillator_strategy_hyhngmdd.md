# Gann Trend Oscillator Strategy

- url: https://www.tradingview.com/script/hYhNgmDD-Gann-Trend-Oscillator-Strategy/
- type: indicator
- pine_id: PUB;IBSTd45vFyV4I1AWC9SpxUpJkIR19GgJ
- version: 1.0

## Description

The Gann Swing Oscillator has been adapted from Robert Krausz's book, 
 "A W.D. Gann Treasure Discovered". The Gann Swing Oscillator helps 
 define market swings.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 18/05/2017
// The Gann Swing Oscillator has been adapted from Robert Krausz's book, 
// "A W.D. Gann Treasure Discovered". The Gann Swing Oscillator helps 
// define market swings. 
////////////////////////////////////////////////////////////
study(title="Gann Trend Oscillator")
Length = input(3, minval=1)
hline(0, color=gray, linestyle=dashed)
xHH = highest(close, Length)
xLL = lowest(close, Length)
xGSO = iff(xHH[2] > xHH[1] and xHH[0] > xHH[1], -1,
         iff(xLL[2] < xLL[1] and xLL[0] < xLL[1], 1, nz(xGSO[1],0)))
pos = iff(xGSO > 0, 1,
	     iff(xGSO < 0, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )          
plot(xGSO, color=blue, title="GTO")
````
