# CMOaDisparity Index Strategy

- url: https://www.tradingview.com/script/21m5jq7U-CMOaDisparity-Index-Strategy/
- type: indicator
- pine_id: PUB;ictivf6kbrOAvgNHQfSfTVIz8v1Z1cpx
- version: 1.0

## Description

The related article is copyrighted material from Stocks & Commodities Dec 2009
 My strategy modification.

 WARNING:
  - This script to change bars colors.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 30/06/2018
// The related article is copyrighted materialfrom Stocks & Commodities Dec 2009
// My strategy modification.
//
// WARNING:
//  - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="CMOaDisparity Index Strategy")
LengthFirst = input(200, minval=1)
LengthSecond = input(50, minval=1)
LengthThird = input(20, minval=1)
ShowFirst = input(type=bool, defval=true)
ShowSecond = input(type=bool, defval=true)
ShowThird = input(type=bool, defval=true)
xEMAFirst = ema(close,LengthFirst)
xEMASecond  = ema(close,LengthSecond)
xEMAThird  = ema(close,LengthThird)
xResFirst = 100 * (close - xEMAFirst) / close
xResSecond = 100 * (close - xEMASecond) / close
xResThird = 100 * (close - xEMAThird) / close
pos = iff(xResThird > xResFirst, -1,
       iff(xResThird < xResSecond, 1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(ShowFirst ? xResFirst : na, color=red, title="DIX 1")
plot(ShowSecond ? xResSecond : na, color=blue, title="DIX 2")
plot(ShowThird ? xResThird : na, color=green, title="DIX 3")
````
