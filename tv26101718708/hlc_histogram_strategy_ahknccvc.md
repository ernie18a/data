# (H-L)/C Histogram Strategy

- url: https://www.tradingview.com/script/AhKnccVC-H-L-C-Histogram-Strategy/
- type: indicator
- pine_id: PUB;W30bi83sSVjDYBZ7zsELvsouK0wwSHKq
- version: 1.0

## Description

This histogram displays (high-low)/close
  Can be applied to any time frame.

WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=3
////////////////////////////////////////////////////////////
//  Copyright by HPotter v2.0 24/10/2017
//
//  This histogram displays (high-low)/close
//  Can be applied to any time frame.
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="(H-L)/C Histogram Strategy", precision = 2)
input_barwidth = input(4, title="Bar Width")
input_barsback = input(4, title="Look Back")
input_percentorprice = input(false, title="% change")
input_smalength = input(13, title="SMA Length")
hline(0, color=blue, linestyle=line)
xPrice = (high-low)/close
xPriceHL = (high-low)
xPrice1 = iff(input_percentorprice, xPrice * 100, xPriceHL)
xPrice1SMA = sma(abs(xPrice1), input_smalength)
pos = 0.0
pos := iff(xPrice1SMA[input_barsback] > abs(xPrice1), 1,
	   iff(xPrice1SMA[input_barsback] < abs(xPrice1), -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue ) 
plot(abs(xPrice1), color=green, style = histogram, linewidth = input_barwidth, title="Change")
plot(xPrice1SMA[input_barsback], color=red, title="SMA")
````
