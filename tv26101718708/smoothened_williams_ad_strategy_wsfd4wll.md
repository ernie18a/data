# Smoothened Williams A/D Strategy

- url: https://www.tradingview.com/script/wsfd4wll-Smoothened-Williams-A-D-Strategy/
- type: indicator
- pine_id: PUB;fJtGv1NYROgalEnsi92sZi4cFdPhS8Iy
- version: 1.0

## Description

Accumulation is a term used to describe a market controlled by buyers;
 whereas distribution is defined by a market controlled by sellers.
 Williams recommends trading this indicator based on divergences:

  Distribution of the security is indicated when the security is making 
  a new high and the A/D indicator is failing to make a new high. Sell.

  Accumulation of the security is indicated when the security is making 
  a new low and the A/D indicator is failing to make a new low. Buy.

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 19/01/2018
// Accumulation is a term used to describe a market controlled by buyers;
// whereas distribution is defined by a market controlled by sellers.
// Williams recommends trading this indicator based on divergences:
//
//  Distribution of the security is indicated when the security is making 
//  a new high and the A/D indicator is failing to make a new high. Sell.
//
//  Accumulation of the security is indicated when the security is making 
//  a new low and the A/D indicator is failing to make a new low. Buy.
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Smoothened Williams Accumulation/Distribution (Williams AD)", shorttitle="Williams AD")
Length = input(14, step = 1)
hline(0, color=blue, linestyle=line)
xPrice = close
xWAD = iff(close > nz(close[1], 0), nz(xWAD[1],0) + close - low[1], 
         iff(close < nz(close[1],0), nz(xWAD[1],0) + close - high[1],0))
xWADMA = sma(xWAD, Length)
pos = iff(xWAD > xWADMA, 1,
       iff(xWAD < xWADMA, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )         
plot(xWAD, color=green, title="Williams AD")
plot(xWADMA, color=red, title="MA(AD)")
````
