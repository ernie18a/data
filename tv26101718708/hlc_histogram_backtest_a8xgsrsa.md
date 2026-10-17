# (H-L)/C Histogram Backtest

- url: https://www.tradingview.com/script/A8XGSrsA-H-L-C-Histogram-Backtest/
- type: strategy
- pine_id: PUB;o1QXqt6vwCtZS4vXTDlTNuLv7u2jGnSj
- version: 1.0

## Description

This histogram displays (high-low)/close
  Can be applied to any time frame.

 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=3
////////////////////////////////////////////////////////////
//  Copyright by HPotter v2.0 25/10/2017
//
//  This histogram displays (high-low)/close
//  Can be applied to any time frame.
//
// WARNING:
// - For purpose educate only
// - This script to change bars colors.
////////////////////////////////////////////////////////////
strategy(title="(H-L)/C Histogram Backtest", precision = 2)
input_barwidth = input(4, title="Bar Width")
input_barsback = input(1, title="Look Back")
input_percentorprice = input(false, title="% change")
input_smalength = input(16, title="SMA Length")
reverse = input(false, title="Trade reverse")
hline(0, color=blue, linestyle=line)
xPrice = (high-low)/close
xPriceHL = (high-low)
xPrice1 = iff(input_percentorprice, xPrice * 100, xPriceHL)
xPrice1SMA = sma(abs(xPrice1), input_smalength)
pos = 0.0
pos := iff(xPrice1SMA[input_barsback] > abs(xPrice1), 1,
	   iff(xPrice1SMA[input_barsback] < abs(xPrice1), -1, nz(pos[1], 0))) 
possig = iff(reverse and pos == 1, -1,
          iff(reverse and pos == -1, 1, pos))	   
if (possig == 1) 
    strategy.entry("Long", strategy.long)
if (possig == -1)
    strategy.entry("Short", strategy.short)	   	    
barcolor(possig == -1 ? red: possig == 1 ? green : blue ) 
plot(abs(xPrice1), color=green, style = histogram, linewidth = input_barwidth, title="Change")
plot(xPrice1SMA[input_barsback], color=red, title="SMA")
````
