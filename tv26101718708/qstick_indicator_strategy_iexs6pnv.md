# Qstick Indicator Strategy

- url: https://www.tradingview.com/script/ieXS6pnV-Qstick-Indicator-Strategy/
- type: indicator
- pine_id: PUB;1VJtP3QgrHbsaijDiSZwCcxqD08n0JZu
- version: 1.0

## Description

A technical indicator developed by Tushar Chande to numerically identify 
 trends in candlestick charting. It is calculated by taking an 'n' period 
 moving average of the difference between the open and closing prices. A 
 Qstick value greater than zero means that the majority of the last 'n' days 
 have been up, indicating that buying pressure has been increasing. 

 Transaction signals come from when the Qstick indicator crosses through the 
 zero line. Crossing above zero is used as the entry signal because it is indicating 
 that buying pressure is increasing, while sell signals come from the indicator 
 crossing down through zero. In addition, an 'n' period moving average of the Qstick 
 values can be drawn to act as a signal line. Transaction signals are then generated 
 when the Qstick value crosses through the trigger line.

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 13/04/2018
// A technical indicator developed by Tushar Chande to numerically identify 
// trends in candlestick charting. It is calculated by taking an 'n' period 
// moving average of the difference between the open and closing prices. A 
// Qstick value greater than zero means that the majority of the last 'n' days 
// have been up, indicating that buying pressure has been increasing. 
//
// Transaction signals come from when the Qstick indicator crosses through the 
// zero line. Crossing above zero is used as the entry signal because it is indicating 
// that buying pressure is increasing, while sell signals come from the indicator 
// crossing down through zero. In addition, an 'n' period moving average of the Qstick 
// values can be drawn to act as a signal line. Transaction signals are then generated 
// when the Qstick value crosses through the trigger line.
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Qstick Indicator Strategy")
Length = input(14, minval=1)
xR = close - open
xQstick = sma(xR, Length)
clr = iff(xQstick >= 0, green, red)
pos = iff(xQstick > 0, 1,
       iff(xQstick < 0, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
p1 = plot(0, color=black, title="0")
p2 = plot(xQstick, color=blue, title="Qstick")
fill(p1, p2, color=clr)
````
