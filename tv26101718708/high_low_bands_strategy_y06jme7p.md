# High Low Bands Strategy

- url: https://www.tradingview.com/script/Y06JMe7p-High-Low-Bands-Strategy/
- type: indicator
- pine_id: PUB;5dg5O4L5owzu43lTz462wedgUOkP6iZh
- version: 2.0

## Description

As the name suggests, High low bands are two bands surrounding the underlying’s 
 price. These bands are generated from the triangular moving averages calculated 
 from the underlying’s price. The triangular moving average is, in turn, shifted 
 up and down by a fixed percentage. The bands, thus formed, are termed as High 
 low bands. The main theme and concept of High low bands is based upon the triangular 
 moving average. 

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.1 23/02/2018
// As the name suggests, High low bands are two bands surrounding the underlying’s 
// price. These bands are generated from the triangular moving averages calculated 
// from the underlying’s price. The triangular moving average is, in turn, shifted 
// up and down by a fixed percentage. The bands, thus formed, are termed as High 
// low bands. The main theme and concept of High low bands is based upon the triangular 
// moving average. 
//
// To fix do not correct to interpret a signal.
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="High Low Bands", overlay = true)
Length = input(14, minval=1)
PercentShift = input(1, minval = 0.01, step = 0.01)
xTMA = sma(sma(close, Length), Length)
xHighBand = xTMA + (xTMA * PercentShift / 100)
xLowBand = xTMA - (xTMA * PercentShift / 100)
pos = iff(close > xHighBand, 1,
       iff(close <xLowBand, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(xTMA, color=blue, title="TMA")
plot(xHighBand, color=red, title="High Band")
plot(xLowBand, color=red, title="Low Band")
````
