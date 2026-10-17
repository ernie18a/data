# Breakout Range Long Strategy

- url: https://www.tradingview.com/script/KvxtErD5-Breakout-Range-Long-Strategy/
- type: indicator
- pine_id: PUB;522
- version: -1.0

## Description

Breakout Range Long Strategy

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 09/09/2014
// Breakout Range Long Strategy
////////////////////////////////////////////////////////////
study(title="Breakout Range Long Strategy", overlay = true)
look_bak = input(4, minval=1, title="Look Bak")
xHighest = highest(high, look_bak)
pos =	iff(high > xHighest[1], 1, 0) 
barcolor(pos == 1 ? green: blue )
plotshape(pos, style=shape.triangleup, location = location.belowbar, color = green)
````
