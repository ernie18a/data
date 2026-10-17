# MASS Index Strategy

- url: https://www.tradingview.com/script/EMK8ydy0-MASS-Index-Strategy/
- type: indicator
- pine_id: PUB;gFn5PGfV1ZtXjUG7wCJyXVv5fbizFlm7
- version: 1.0

## Description

The Mass Index was designed to identify trend reversals by measuring 
 the narrowing and widening of the range between the high and low prices. 
 As this range widens, the Mass Index increases; as the range narrows 
 the Mass Index decreases.
 The Mass Index was developed by Donald Dorsey. 

 WARNING:
  This script to change bars colors.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 11/09/2017
// The Mass Index was designed to identify trend reversals by measuring 
// the narrowing and widening of the range between the high and low prices. 
// As this range widens, the Mass Index increases; as the range narrows 
// the Mass Index decreases.
// The Mass Index was developed by Donald Dorsey. 
//
// WARNING:
//  This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="MASS Index", shorttitle="MASS Index")
Length1 = input(9, minval=1)
Length2 = input(25, minval=1)
Trigger = input(26.5, step = 0.01)
hline(27, color=blue, linestyle=line, title = "Setup")
hline(Trigger, color=red, linestyle=line, title = "Trigger")
xPrice = high - low
xEMA = ema(xPrice, Length1)
xSmoothXAvg = ema(xEMA, Length1)
nRes = sum(iff(xSmoothXAvg != 0, xEMA / xSmoothXAvg, 0), Length2)
pos = iff(nRes > Trigger, -1,
	   iff(nRes < Trigger, 1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue)
plot(nRes, color=red, title="MASS Index")
````
