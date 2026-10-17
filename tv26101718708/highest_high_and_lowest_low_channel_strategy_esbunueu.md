# Highest High and Lowest Low channel Strategy

- url: https://www.tradingview.com/script/esbunUeu-Highest-High-and-Lowest-Low-channel-Strategy/
- type: indicator
- pine_id: PUB;EbD1L19MP3MhXPMDBFLo2ruPfqK9tWIl
- version: 1.0

## Description

Highest High and Lowest Low channel Strategy

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v2.0 22/02/2017
//  Highest High and Lowest Low channel Strategy
////////////////////////////////////////////////////////////
study(title="Trade channel", overlay = true)
PeriodLookBack = input(55)
xHighest55 = highest(PeriodLookBack)
xLowest55 = lowest(PeriodLookBack)
pos = iff(close > xHighest55[1], 1,
	     iff(close < xLowest55[1], -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(xHighest55[1], color=red, title="HH")
plot(xLowest55[1], color=green, title="LL")
````
