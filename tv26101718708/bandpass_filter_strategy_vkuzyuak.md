# Bandpass Filter Strategy

- url: https://www.tradingview.com/script/vkuZyUaK-Bandpass-Filter-Strategy/
- type: indicator
- pine_id: PUB;575
- version: -1.0

## Description

The related article is copyrighted material from
 Stocks & Commodities Mar 2010
 You can use in the xPrice any series: Open, High, Low, Close, HL2, HLC3, OHLC4 and ect...

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 02/10/2014
// The related article is copyrighted material from
// Stocks & Commodities Mar 2010
// You can use in the xPrice any series: Open, High, Low, Close, HL2, HLC3, OHLC4 and ect...
////////////////////////////////////////////////////////////
study(title="Bandpass Filter Strategy")
Length = input(20, minval=1)
Delta = input(0.5)
TriggerLevel = input(0)
xPrice = hl2
hline(TriggerLevel, color=blue, linestyle=line)
beta = cos(3.14 * (360 / Length) / 180)
gamma = 1 / cos(3.14 * (720 * Delta / Length) / 180)
alpha = gamma - sqrt(gamma * gamma - 1)
BP = 0.5 * (1 - alpha) * (xPrice - xPrice[2]) + beta * (1 + alpha) * nz(BP[1]) - alpha * nz(BP[2])
pos =	iff(BP > TriggerLevel, 1,
	    iff(BP <= TriggerLevel, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(BP, color=red, title="Bandpass Filter Strategy")
````
