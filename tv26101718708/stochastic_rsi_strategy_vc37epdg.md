# Stochastic RSI Strategy

- url: https://www.tradingview.com/script/Vc37EPdG-Stochastic-RSI-Strategy/
- type: indicator
- pine_id: PUB;SG8bVkyn6m1gz46K0wOr4to5cZmV5ROO
- version: 1.0

## Description

This strategy used to calculate the Stochastic RSI

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 24/11/2014
// This strategy used to calculate the Stochastic RSI
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Stochastic RSI", shorttitle="Stoch RSI Strategy")
TopBand = input(80, step=0.01)
LowBand = input(20, step=0.01)
hline(TopBand, color=red, linestyle=line)
hline(LowBand, color=green, linestyle=line)
Source = close
lengthRSI = input(14, minval=1), lengthStoch = input(14, minval=1)
smoothK = input(3, minval=1), smoothD = input(3, minval=1)
rsi1 = rsi(Source, lengthRSI)
k = sma(stoch(rsi1, rsi1, rsi1, lengthStoch), smoothK)
d = sma(k, smoothD)
d_cross_80 = cross(d,TopBand) 
dc80 = d_cross_80 ? red : green 
pos = iff(k > TopBand, 1,
       iff(k < LowBand, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(k, color= orange)
plot(d, color=dc80)
````
