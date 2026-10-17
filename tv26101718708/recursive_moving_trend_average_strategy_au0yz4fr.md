# Recursive Moving Trend Average Strategy

- url: https://www.tradingview.com/script/au0yz4Fr-Recursive-Moving-Trend-Average-Strategy/
- type: indicator
- pine_id: PUB;OimzjuKnTU47dlrggpQVGHiTWD2965sw
- version: 1.0

## Description

Taken from an article "The Yen Recused" in the December 1998 issue of TASC, 
 written by Dennis Meyers. He describes the Recursive MA in mathematical terms 
 as "recursive polynomial fit, a technique that uses a small number of past values 
 of the estimated price and today's price to predict tomorrows price."
 Red bars color - short position. Green is long.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 25/05/2017
// Taken from an article "The Yen Recused" in the December 1998 issue of TASC, 
// written by Dennis Meyers. He describes the Recursive MA in mathematical terms 
// as "recursive polynomial fit, a technique that uses a small number of past values 
// of the estimated price and today's price to predict tomorrows price."
// Red bars color - short position. Green is long.
////////////////////////////////////////////////////////////
study(title="Recursive Moving Trend Average", shorttitle="RMTA", overlay = true)
Length = input(21, minval=3)
Alpha = 2 / (Length+1)
Bot = (1-Alpha) * nz(Bot[1],close) + close
nRes = (1-Alpha) * nz(nRes[1],close) + (Alpha*(close + Bot - nz(Bot[1], 0)))
pos = iff(nRes > close[1], -1,
	     iff(nRes < close[1], 1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nRes, color=blue, title="RMTA")
````
