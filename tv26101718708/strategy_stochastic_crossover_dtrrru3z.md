# Strategy Stochastic Crossover

- url: https://www.tradingview.com/script/dtrRRU3z-Strategy-Stochastic-Crossover/
- type: indicator
- pine_id: PUB;71
- version: -1.0

## Description

This back testing strategy generates a long trade at the Open of the following 
    bar when the %K line crosses below the %D line and both are above the Overbought level.
    It generates a short trade at the Open of the following bar when the %K line 
    crosses above the %D line and both values are below the Oversold level.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 19/05/2014
// This back testing strategy generates a long trade at the Open of the following 
// bar when the %K line crosses below the %D line and both are above the Overbought level.
// It generates a short trade at the Open of the following bar when the %K line 
// crosses above the %D line and both values are below the Oversold level.
////////////////////////////////////////////////////////////
study(title="Strategy Stochastic Crossover", shorttitle="Strategy Stochastic Crossover1", overlay = true )
Length = input(7, minval=1)
DLength = input(3, minval=1)
Oversold = input(20, minval=1)
Overbought = input(70, minval=1)
vFast = stoch(close, high, low, Length)
vSlow = sma(vFast, DLength)
pos =	iff(vFast < vSlow and vFast > Overbought and vSlow > Overbought, 1,
	    iff(vFast >= vSlow and vFast < Oversold and vSlow < Oversold, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
````
