# Williams Accumulation/Distribution (Williams AD) Strategy

- url: https://www.tradingview.com/script/6j0XbdFa-Williams-Accumulation-Distribution-Williams-AD-Strategy/
- type: indicator
- pine_id: PUB;qthdGJ0nDUNHY7jvdmNsVb6qOkMTTZUM
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
//  Copyright by HPotter v1.0 17/01/2018
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
study(title="Williams Accumulation/Distribution (Williams AD)", shorttitle="Williams AD")
hline(0, color=blue, linestyle=line)
xPrice = close
xWAD = iff(close > nz(close[1], 0), nz(xWAD[1],0) + close - low[1], 
         iff(close < nz(close[1],0), nz(xWAD[1],0) + close - high[1],0))
pos = iff(xWAD > 0, 1,
       iff(xWAD < 0, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )         
plot(xWAD, color=green, title="Williams AD")
````
