# The Pivot Detector Oscillator Strategy

- url: https://www.tradingview.com/script/CHBCVYqE-The-Pivot-Detector-Oscillator-Strategy/
- type: indicator
- pine_id: PUB;0hkHXARrSWHy9wCDu5Oreb6uftO9kSs1
- version: 1.0

## Description

The Pivot Detector Oscillator, by Giorgos E. Siligardos
 The related article is copyrighted material from Stocks & Commodities 2009 Sep

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 02/10/2017
// The Pivot Detector Oscillator, by Giorgos E. Siligardos
// The related article is copyrighted material from Stocks & Commodities 2009 Sep
////////////////////////////////////////////////////////////
study(title="The Pivot Detector Oscillator, by Giorgos E. Siligardos")
Length_MA = input(200, minval=1)
Length_RSI = input(14, minval=1)
UpBand = input(100, minval=1)
DownBand = input(0)
MidlleBand = input(50)
hline(MidlleBand, color=black, linestyle=dashed)
hline(UpBand, color=red, linestyle=line)
hline(DownBand, color=green, linestyle=line)
xMA = sma(close, Length_MA)
xRSI = rsi(close, Length_RSI)
nRes = iff(close > xMA, (xRSI - 35) / (85-35), 
         iff(close <= xMA, (xRSI - 20) / (70 - 20), 0))
pos = iff(nRes * 100 > 50, 1,
	   iff(nRes * 100 < 50, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue)        
plot(nRes * 100, color=blue, title="Pivot Detector Oscillator")
````
