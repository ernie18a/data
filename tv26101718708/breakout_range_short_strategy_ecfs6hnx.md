# Breakout Range Short Strategy

- url: https://www.tradingview.com/script/ecFS6HNX-Breakout-Range-Short-Strategy/
- type: indicator
- pine_id: PUB;523
- version: -1.0

## Description

Breakout Range Short Strategy

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 09/09/2014
// Breakout Range Short Strategy
////////////////////////////////////////////////////////////
study(title="Breakout Range Short Strategy", overlay = true)
look_bak = input(4, minval=1, title="Look Bak")
xLowest = lowest(low, look_bak)
pos =	iff(low < xLowest[1], 1, 0) 
barcolor(pos == 1 ? red: blue )
plotshape(pos, style=shape.triangledown, location = location.abovebar, color = red)
````
