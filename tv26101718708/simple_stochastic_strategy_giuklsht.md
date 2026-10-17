# Simple  Stochastic Strategy

- url: https://www.tradingview.com/script/gIuKlSHt-Simple-Stochastic-Strategy/
- type: indicator
- pine_id: PUB;yoBuKoFkG7DCQ3ZPohSAst5dQFTjjTTf
- version: 1.0

## Description

This back testing strategy generates a long trade at the Open of the following 
 bar when the %K line crosses up UpBand line.
 It generates a short trade at the Open of the following bar when the %K line 
 crosses down DownBand line.

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 04/10/2017
// This back testing strategy generates a long trade at the Open of the following 
// bar when the %K line crosses up UpBand line.
// It generates a short trade at the Open of the following bar when the %K line 
// crosses down DownBand line.
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Strategy Stochastic", shorttitle="Strategy Stochastic")
Length = input(7, minval=1)
DLength = input(3, minval=1)
UpBand = input(20, minval=1)
DownBand = input(80, minval=1)
hline(50, color=black, linestyle=dashed)
hline(UpBand, color=red, linestyle=line)
hline(DownBand, color=green, linestyle=line)
vFast = stoch(close, high, low, Length)
vSlow = sma(vFast, DLength)
pos = iff(vFast > UpBand, 1,
	    iff(vFast < DownBand, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(vSlow, color=blue, title="D")
plot(vFast, color=red, title="K")
````
