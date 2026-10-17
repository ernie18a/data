# Bill Williams. Awesome Oscillator (AC) Strategy

- url: https://www.tradingview.com/script/U77XAIYX-Bill-Williams-Awesome-Oscillator-AC-Strategy/
- type: indicator
- pine_id: PUB;542
- version: -1.0

## Description

This indicator plots the oscillator as a histogram where blue denotes 
    periods suited for buying and red . for selling. If the current value 
    of AO (Awesome Oscillator) is above previous, the period is considered 
    suited for buying and the period is marked blue. If the AO value is not 
    above previous, the period is considered suited for selling and the 
    indicator marks it as red.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 15/04/2014
//    This indicator plots the oscillator as a histogram where blue denotes 
//    periods suited for buying and red . for selling. If the current value 
//    of AO (Awesome Oscillator) is above previous, the period is considered 
//    suited for buying and the period is marked blue. If the AO value is not 
//    above previous, the period is considered suited for selling and the 
//    indicator marks it as red.
////////////////////////////////////////////////////////////
study("Bill Williams. Awesome Oscillator (AC)")
nLengthSlow = input(34, minval=1, title="Length Slow")
nLengthFast = input(5, minval=1, title="Length Fast")
xSMA1_hl2 = sma(hl2, nLengthFast)
xSMA2_hl2 = sma(hl2, nLengthSlow)
xSMA1_SMA2 = xSMA1_hl2 - xSMA2_hl2
xSMA_hl2 = sma(xSMA1_SMA2, nLengthFast)
nRes =  xSMA1_SMA2 - xSMA_hl2
cClr = nRes > nRes[1] ? blue : red
pos =	iff(nRes > nRes[1], 1,
	    iff(nRes < nRes[1], -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nRes, style=histogram, linewidth=1, color=cClr)
````
