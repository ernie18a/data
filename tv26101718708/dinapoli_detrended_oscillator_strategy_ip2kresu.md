# DiNapoli Detrended Oscillator Strategy

- url: https://www.tradingview.com/script/iP2krEsU-DiNapoli-Detrended-Oscillator-Strategy/
- type: indicator
- pine_id: PUB;1181
- version: -1.0

## Description

DiNapoli Detrended Oscillator Strategy

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 02/04/2015
// DiNapoli Detrended Oscillator Strategy
////////////////////////////////////////////////////////////
study(title="DiNapoli Detrended Oscillator Strategy")
Length = input(14, minval=1)
Trigger = input(0)
hline(Trigger, color=gray, linestyle=line)
xSMA = sma(close, Length)
nRes = close - xSMA
pos =	iff(nRes > Trigger, 1,
	    iff(nRes <= Trigger, -1, nz(pos[1], 0))) 
plot(nRes, color=blue, title="DiNapoli")
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
````
