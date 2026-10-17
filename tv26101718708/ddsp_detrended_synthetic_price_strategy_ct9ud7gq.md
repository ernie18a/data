# D_DSP (Detrended Synthetic Price) Strategy

- url: https://www.tradingview.com/script/cT9Ud7GQ-D-DSP-Detrended-Synthetic-Price-Strategy/
- type: indicator
- pine_id: PUB;ln9NdF53SzbU1Fdi8vnudePbuVpzEUiE
- version: 1.0

## Description

Detrended Synthetic Price is a function that is in phase with the 
 dominant cycle of real price data. This DSP is computed by subtracting 
 a half-cycle exponential moving average (EMA) from the quarter cycle 
 exponential moving average.
 See "MESA and Trading Market Cycles" by John Ehlers pages 64 - 70.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 15/03/2017
// Detrended Synthetic Price is a function that is in phase with the 
// dominant cycle of real price data. This DSP is computed by subtracting 
// a half-cycle exponential moving average (EMA) from the quarter cycle 
// exponential moving average.
// See "MESA and Trading Market Cycles" by John Ehlers pages 64 - 70. 
////////////////////////////////////////////////////////////
study(title="D_DSP (Detrended Synthetic Price)", shorttitle="D_DSP")
Length = input(14, minval=1)
hline(0, color=red, linestyle=line)
xHL2 = hl2
xEMA1 = ema(xHL2, Length)
xEMA2 = ema(xHL2, 2 * Length)
xEMA1_EMA2 = xEMA1 - xEMA2
pos = iff(xEMA1_EMA2 > 0, 1,
	     iff(xEMA1_EMA2 < 0, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(xEMA1_EMA2, color=blue, title="D_DSP")
````
