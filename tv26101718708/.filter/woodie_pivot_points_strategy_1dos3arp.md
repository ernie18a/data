# Woodie Pivot Points Strategy

- url: https://www.tradingview.com/script/1Dos3Arp-Woodie-Pivot-Points-Strategy/
- type: indicator
- pine_id: PUB;HPHuANHMcc8qk9LWQMOO1WLanJHHWq3R
- version: 1.0

## Description

Simply input the vales of the high, low and closing price of the previous 
 period to calculate the Woodie pivot point and the associated resistance 
 and support levels for the present period.

 WARNING:
  - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 21/08/2018
// Simply input the vales of the high, low and closing price of the previous 
// period to calculate the Woodie pivot point and the associated resistance 
// and support levels for the present period.
//
// WARNING:
//  - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Woodie Pivot Points Strategy", overlay = true)
width = input(2, minval=1)
xHigh  = security(tickerid,"D", high[1])
xLow   = security(tickerid,"D", low[1])
xClose = security(tickerid,"D", close[1])
xPP = (xHigh+xLow+(xClose*2)) / 4
pos = iff(close[1] < xPP[1] and close > xPP, 1,
       iff(close < xPP, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(xPP, color=blue, title="WPP", style = circles, linewidth = width)
````
