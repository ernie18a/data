# Accelerator Oscillator (AC) Strategy

- url: https://www.tradingview.com/script/pq1Xf2ly-Accelerator-Oscillator-AC-Strategy/
- type: indicator
- pine_id: PUB;qKti3FaLwwSEA8ynI0zx6WFi4P23LtxJ
- version: 1.0

## Description

The Accelerator Oscillator has been developed by Bill Williams 
 as the development of the Awesome Oscillator. It represents the 
 difference between the Awesome Oscillator and the 5-period moving 
 average, and as such it shows the speed of change of the Awesome 
 Oscillator, which can be useful to find trend reversals before the 
 Awesome Oscillator does.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 30/05/2017
// The Accelerator Oscillator has been developed by Bill Williams 
// as the development of the Awesome Oscillator. It represents the 
// difference between the Awesome Oscillator and the 5-period moving 
// average, and as such it shows the speed of change of the Awesome 
// Oscillator, which can be useful to find trend reversals before the 
// Awesome Oscillator does.
////////////////////////////////////////////////////////////
study("Accelerator Oscillator (AC) Strategy")
nLengthSlow = input(34, minval=1, title="Length Slow")
nLengthFast = input(5, minval=1, title="Length Fast")
xSMA1_hl2 = sma(hl2, nLengthFast)
xSMA2_hl2 = sma(hl2, nLengthSlow)
xSMA1_SMA2 = xSMA1_hl2 - xSMA2_hl2
xSMA_hl2 = sma(xSMA1_SMA2, nLengthFast)
nRes =  xSMA1_SMA2 - xSMA_hl2
cClr = nRes > nRes[1] ? blue : red
pos = iff(nRes > 0, 1,
       iff(nRes < 0, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nRes, style=histogram, linewidth=1, color=cClr)
````
