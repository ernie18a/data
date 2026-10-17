# Detrended Price Oscillator Strategy

- url: https://www.tradingview.com/script/X2rInS57-Detrended-Price-Oscillator-Strategy/
- type: indicator
- pine_id: PUB;kp1CLhuHlar0Y4qSA1lRe0NKY97V4Lhe
- version: 1.0

## Description

The Detrend Price Osc indicator is similar to a moving average, 
 in that it filters out trends in prices to more easily identify 
 cycles. The indicator is an attempt to define cycles in a trend 
 by drawing a moving average as a horizontal straight line and 
 placing prices along the line according to their relation to a 
 moving average. It provides a means of identifying underlying 
 cycles not apparent when the moving average is viewed within a 
 price chart. Cycles of a longer duration than the Length (number 
 of bars used to calculate the Detrend Price Osc) are effectively 
 filtered or removed by the oscillator.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 30/03/2017
// The Detrend Price Osc indicator is similar to a moving average, 
// in that it filters out trends in prices to more easily identify 
// cycles. The indicator is an attempt to define cycles in a trend 
// by drawing a moving average as a horizontal straight line and 
// placing prices along the line according to their relation to a 
// moving average. It provides a means of identifying underlying 
// cycles not apparent when the moving average is viewed within a 
// price chart. Cycles of a longer duration than the Length (number 
// of bars used to calculate the Detrend Price Osc) are effectively 
// filtered or removed by the oscillator.
////////////////////////////////////////////////////////////
study(title="Detrended Price Oscillator", shorttitle="DPO")
Length = input(14, minval=1)
Series = input(title="Price", type=string, defval="close")
hline(0, color=green, linestyle=line)
xPrice = close
xsma = sma(xPrice, Length)
nRes = xPrice - xsma
pos = iff(nRes > 0, 1,
	     iff(nRes < 0, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nRes, color=red, title="Detrended Price Oscillator")
````
