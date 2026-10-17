# High Low Bands Backtest

- url: https://www.tradingview.com/script/INPab7Qm-High-Low-Bands-Backtest/
- type: strategy
- pine_id: PUB;T3MEEgI7Lf1sY736Lspw8ESyNwxwyOoA
- version: 2.0

## Description

As the name suggests, High low bands are two bands surrounding the underlying’s 
 price. These bands are generated from the triangular moving averages calculated 
 from the underlying’s price. The triangular moving average is, in turn, shifted 
 up and down by a fixed percentage. The bands, thus formed, are termed as High 
 low bands. The main theme and concept of High low bands is based upon the triangular 
 moving average. 

 You can change long to short in the Input Settings
 WARNING:
  - For purpose educate only
  - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 28/02/2018
// As the name suggests, High low bands are two bands surrounding the underlying’s 
// price. These bands are generated from the triangular moving averages calculated 
// from the underlying’s price. The triangular moving average is, in turn, shifted 
// up and down by a fixed percentage. The bands, thus formed, are termed as High 
// low bands. The main theme and concept of High low bands is based upon the triangular 
// moving average. 
//
// To fix do not correct to interpret a signal.
//
// You can change long to short in the Input Settings
// WARNING:
//  - For purpose educate only
//  - This script to change bars colors.
////////////////////////////////////////////////////////////
strategy(title="High Low Bands", overlay = true)
Length = input(14, minval=1)
PercentShift = input(1, minval = 0.01, step = 0.01)
reverse = input(false, title="Trade reverse")
xTMA = sma(sma(close, Length), Length)
xHighBand = xTMA + (xTMA * PercentShift / 100)
xLowBand = xTMA - (xTMA * PercentShift / 100)
pos = iff(close > xHighBand, 1,
       iff(close <xLowBand, -1, nz(pos[1], 0))) 
possig = iff(reverse and pos == 1, -1,
          iff(reverse and pos == -1, 1, pos))	   
if (possig == 1) 
    strategy.entry("Long", strategy.long)
if (possig == -1)
    strategy.entry("Short", strategy.short)	   	    
barcolor(possig == -1 ? red: possig == 1 ? green : blue ) 
plot(xTMA, color=blue, title="TMA")
plot(xHighBand, color=red, title="High Band")
plot(xLowBand, color=red, title="Low Band")
````
