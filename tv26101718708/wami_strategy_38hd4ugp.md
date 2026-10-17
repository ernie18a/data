# WAMI Strategy

- url: https://www.tradingview.com/script/38hd4UGp-WAMI-Strategy/
- type: indicator
- pine_id: PUB;184
- version: -1.0

## Description

The WAMI-based trading lies in the application and iteration of the 
 optimization process until the indicated trades on past market data 
 give consistent, profitable results. It is rather difficult process 
 based on Fourier analysis. 
 You can to change Trigger parameter for to get best values of strategy.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 08/07/2014
// The WAMI-based trading lies in the application and iteration of the 
// optimization process until the indicated trades on past market data 
// give consistent, profitable results. It is rather difficult process 
// based on Fourier analysis. 
// You can to change Trigger parameter for to get best values of strategy.
////////////////////////////////////////////////////////////
study(title="WAMI Strategy", shorttitle="WAMI Strategy")
Length_EMA = input(13, minval=1)
Length_WMA = input(4, minval=1)
Trigger = input(0)
hline(Trigger, color=purple, linestyle=line)
xWAMI = ema(ema(wma(mom(close, 1),Length_WMA),Length_EMA),Length_EMA)
pos =	iff(xWAMI > Trigger, 1,
	    iff(xWAMI < Trigger, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(xWAMI, color=blue, title="WAMI")
````
