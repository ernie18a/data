# Dynamo Strategy

- url: https://www.tradingview.com/script/6NjlH0jF-Dynamo-Strategy/
- type: indicator
- pine_id: PUB;YheGcs3xCBgY54ZHJlkwrc6JIXSFeqAU
- version: 1.0

## Description

In July 1996 Futures magazine, E. Marshall Wall introduces the 
 Dynamic Momentum Oscillator (Dynamo). Please refer to this article 
 for interpretation.
 The Dynamo oscillator is a normalizing function which adjusts the 
 values of a standard oscillator for trendiness by taking the difference 
 between the value of the oscillator and a moving average of the oscillator 
 and then subtracting that value from the oscillator midpoint.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 07/04/2017
// In July 1996 Futures magazine, E. Marshall Wall introduces the 
// Dynamic Momentum Oscillator (Dynamo). Please refer to this article 
// for interpretation.
// The Dynamo oscillator is a normalizing function which adjusts the 
// values of a standard oscillator for trendiness by taking the difference 
// between the value of the oscillator and a moving average of the oscillator 
// and then subtracting that value from the oscillator midpoint.
////////////////////////////////////////////////////////////
study(title="Dynamo", shorttitle="Dynamo")
OscLen = input(10, minval=1)
MALen = input(20, minval=1)
HiBand = input(77, minval=1)
LowBand = input(23)
hline(HiBand, color=red, linestyle=line)
hline(LowBand, color=green, linestyle=line)
xOscK = stoch(close, high, low, OscLen)
xOscAvg = sma(xOscK, OscLen)
xMAVal = sma(xOscAvg, MALen)
maxNum = 9999999
LowestSoFar = iff(xOscAvg < nz(LowestSoFar[1], maxNum), xOscAvg, nz(LowestSoFar[1], maxNum))
HighestSoFar = iff(xOscAvg > nz(HighestSoFar[1]), xOscAvg, nz(HighestSoFar[1]))
MidPnt = (LowestSoFar + HighestSoFar) / 2
nRes = MidPnt - (xMAVal - xOscAvg)
pos = iff(nRes > HiBand, 1,
	     iff(nRes < LowBand, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nRes, color=blue, title="Dynamo")
````
