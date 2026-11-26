# Combining Exponential And Volume Weighting

- url: https://www.tradingview.com/script/UFLil2te-Combining-Exponential-And-Volume-Weighting/
- type: indicator
- pine_id: PUB;jAYXzpzq9NZEBggGsLh0VwBqMvMH43bq
- version: 1.0

## Description

The related article is copyrighted material from Stocks & Commodities 2009 Oct

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 06/03/2017
// The related article is copyrighted material from Stocks & Commodities 2009 Oct 
////////////////////////////////////////////////////////////
study(title="Combining Exponential And Volume Weighting", overlay=true)
length = input(22, minval=1)
xMAVolPrice = ema(volume * close, length)
xMAVol = ema(volume, length)
nRes = xMAVolPrice / xMAVol
pos = iff(nRes < close[1], 1,
	     iff(nRes > close[1], -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nRes, color=blue)
````
