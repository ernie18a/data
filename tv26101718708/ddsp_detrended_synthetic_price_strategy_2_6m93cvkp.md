# D_DSP (Detrended Synthetic Price) Strategy 2

- url: https://www.tradingview.com/script/6m93CvkP-D-DSP-Detrended-Synthetic-Price-Strategy-2/
- type: indicator
- pine_id: PUB;Gh1crY8TXjPLoIQPlw2WjhOvSHPzN6Rg
- version: 1.0

## Description

Detrended Synthetic Price is a function that is in phase with the 
 dominant cycle of real price data. This DSP is computed by subtracting 
 a half-cycle exponential moving average (EMA) from the quarter cycle 
 exponential moving average.
 See "MESA and Trading Market Cycles" by John Ehlers pages 64 - 70.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 17/03/2017
// Detrended Synthetic Price is a function that is in phase with the 
// dominant cycle of real price data. This DSP is computed by subtracting 
// a half-cycle exponential moving average (EMA) from the quarter cycle 
// exponential moving average.
// See "MESA and Trading Market Cycles" by John Ehlers pages 64 - 70. 
////////////////////////////////////////////////////////////
study(title="D_DSP (Detrended Synthetic Price)", shorttitle="D_DSP")
Length = input(14, minval=1)
SellBand = input(25)
BuyBand = input(-25)
hline(0, color=blue, linestyle=line)
hline(SellBand, color=red, linestyle=line)
hline(BuyBand, color=green, linestyle=line)
xHL2 = hl2
xEMA1 = ema(xHL2, Length)
xEMA2 = ema(xHL2, 2 * Length)
xEMA1_EMA2 = xEMA1 - xEMA2
pos = iff(xEMA1_EMA2 > SellBand, 1,
	     iff(xEMA1_EMA2 < BuyBand, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(xEMA1_EMA2, color=blue, title="D_DSP")
````
