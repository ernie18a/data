# Kaufman Moving Average Adaptive (KAMA) Strategy

- url: https://www.tradingview.com/script/x8TRWFxU-Kaufman-Moving-Average-Adaptive-KAMA-Strategy/
- type: indicator
- pine_id: PUB;Cilk73upMcbbAaW769h9YRWtThCet8YL
- version: 1.0

## Description

Everyone wants a short-term, fast trading trend that works without large
 losses. That combination does not exist. But it is possible to have fast
 trading trends in which one must get in or out of the market quickly, but
 these have the distinct disadvantage of being whipsawed by market noise
 when the market is volatile in a sideways trending market. During these
 periods, the trader is jumping in and out of positions with no profit-making
 trend in sight. In an attempt to overcome the problem of noise and still be
 able to get closer to the actual change of the trend, Kaufman developed an
 indicator that adapts to market movement. This indicator, an adaptive moving
 average (AMA), moves very slowly when markets are moving sideways but moves
 swiftly when the markets also move swiftly, change directions or break out of
 a trading range.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 24/08/2017
// Everyone wants a short-term, fast trading trend that works without large
// losses. That combination does not exist. But it is possible to have fast
// trading trends in which one must get in or out of the market quickly, but
// these have the distinct disadvantage of being whipsawed by market noise
// when the market is volatile in a sideways trending market. During these
// periods, the trader is jumping in and out of positions with no profit-making
// trend in sight. In an attempt to overcome the problem of noise and still be
// able to get closer to the actual change of the trend, Kaufman developed an
// indicator that adapts to market movement. This indicator, an adaptive moving
// average (AMA), moves very slowly when markets are moving sideways but moves
// swiftly when the markets also move swiftly, change directions or break out of
// a trading range.
////////////////////////////////////////////////////////////
study(title="Kaufman Moving Average Adaptive (KAMA)", shorttitle="Kaufman Moving Average Adaptive (KAMA)", overlay = true)
Length = input(21, minval=1)
xPrice = close
xvnoise = abs(xPrice - xPrice[1])
nfastend = 0.666
nslowend = 0.0645
nsignal = abs(xPrice - xPrice[Length])
nnoise = sum(xvnoise, Length)
nefratio = iff(nnoise != 0, nsignal / nnoise, 0)
nsmooth = pow(nefratio * (nfastend - nslowend) + nslowend, 2) 
nAMA = nz(nAMA[1]) + nsmooth * (xPrice - nz(nAMA[1]))
pos =	iff(close[1] > nAMA, 1,
	    iff(close[1] < nAMA, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue)  
plot(nAMA, color=blue, title="KAMA")
````
