# DSS Bressert (Double Smoothed Stochastic) Strategy

- url: https://www.tradingview.com/script/xIZkFpcC-DSS-Bressert-Double-Smoothed-Stochastic-Strategy/
- type: indicator
- pine_id: PUB;8OICHY0CWtXRlvk3juL46SHvtV2IGElc
- version: 1.0

## Description

Double Smoothed Stochastics (DSS) is designed by William Blaw. 
 It attempts to combine moving average methods with oscillator principles.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 24/04/2014
// Double Smoothed Stochastics (DSS) is designed by William Blaw. 
// It attempts to combine moving average methods with oscillator principles. 
////////////////////////////////////////////////////////////
study(title="DSS Bressert (Double Smoothed Stochastic)", shorttitle="DSS Bressert")
PDS = input(10, minval=1)
EMAlen = input(9, minval=1)
TriggerLen = input(5, minval=1)
Overbought = input(80, minval=1)
Oversold = input(20, minval=1)
hline(Overbought, color=green, linestyle=line)
hline(Oversold, color=red, linestyle=line)
xPreCalc = ema(stoch(close, high, low, PDS), EMAlen)
xDSS = ema(stoch(xPreCalc, xPreCalc, xPreCalc, PDS), EMAlen)
//xDSS = stoch(xPreCalc, xPreCalc, xPreCalc, PDS)
xTrigger = ema(xDSS, TriggerLen)
pos = iff(xTrigger < xDSS and xTrigger < Oversold, -1,
	     iff(xTrigger > xDSS and xTrigger > Overbought, 1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(xDSS, color=blue, title="DSS")
plot(xTrigger, color=red, title="Trigger")
````
