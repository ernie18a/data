# Percent change bar chart Strategy

- url: https://www.tradingview.com/script/GiHAgcoT-Percent-change-bar-chart-Strategy/
- type: indicator
- pine_id: PUB;YqeXlL5JRG15oG2Z9WVikza9ch4OLQXR
- version: 1.0

## Description

This histogram displays price or % change from previous bar. 

 WARNING:
  - This script to change bars colors.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v3.0 25/07/2018
//
//  This histogram displays price or % change from previous bar. 
//
// WARNING:
//  - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Percent change bar chart Strategy", precision = 2)
input_barwidth = input(4, title="Bar Width")
input_percentorprice = input(false, title="Price Change")
input_barsback = input(1, title="Look Back")
SellZone = input(-0.33, minval=0.01, step = 0.01)
BuyZone = input(0.33, minval=0.01, step = 0.01)
hline(0, color=blue, linestyle=line)
hline(BuyZone, color=green, linestyle=line)
hline(SellZone, color=red, linestyle=line)
xPrice = close
xPrice1 = iff(input_percentorprice, xPrice - xPrice[input_barsback], ((xPrice - xPrice[input_barsback]) * 100)/ xPrice[input_barsback])
colorg = iff(xPrice1 < 0, red, green)
pos = iff(xPrice1 > BuyZone, 1,
       iff(xPrice1 < SellZone, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(xPrice1, color=colorg, style = histogram, linewidth = input_barwidth, title="Change")
````
