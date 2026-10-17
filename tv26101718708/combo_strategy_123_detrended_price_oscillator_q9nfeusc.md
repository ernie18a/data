# Combo Strategy 123 Detrended Price Oscillator

- url: https://www.tradingview.com/script/Q9NfeUsC-Combo-Strategy-123-Detrended-Price-Oscillator/
- type: indicator
- pine_id: PUB;qmuhaGDjiNPE53XPxTODLqsnYiK56nJI
- version: 1.0

## Description

This is combo strategies for get a cumulative signal. 

 First strategy
 This System was created from the Book "How I Tripled My Money In The 
 Futures Market" by Ulf Jensen, Page 183. This is reverse type of strategies.
 The strategy buys at market, if close price is higher than the previous close 
 during 2 days and the meaning of 9-days Stochastic Slow Oscillator is lower than 50. 
 The strategy sells at market, if close price is lower than the previous close price 
 during 2 days and the meaning of 9-days Stochastic Fast Oscillator is higher than 50.

 Second strategy
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

 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=4
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 27/12/2019
// This is combo strategies for get a cumulative signal. 
//
// First strategy
// This System was created from the Book "How I Tripled My Money In The 
// Futures Market" by Ulf Jensen, Page 183. This is reverse type of strategies.
// The strategy buys at market, if close price is higher than the previous close 
// during 2 days and the meaning of 9-days Stochastic Slow Oscillator is lower than 50. 
// The strategy sells at market, if close price is lower than the previous close price 
// during 2 days and the meaning of 9-days Stochastic Fast Oscillator is higher than 50.
//
// Second strategy
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
//
// WARNING:
// - For purpose educate only
// - This script to change bars colors.
////////////////////////////////////////////////////////////
Reversal123(Length, KSmoothing, DLength, Level) =>
    vFast = sma(stoch(close, high, low, Length), KSmoothing) 
    vSlow = sma(vFast, DLength)
    pos = 0.0
    pos := iff(close[2] < close[1] and close > close[1] and vFast < vSlow and vFast > Level, 1,
	         iff(close[2] > close[1] and close < close[1] and vFast > vSlow and vFast < Level, -1, nz(pos[1], 0))) 
	pos

DPO(Length) =>
    pos = 0.0
    xPrice = close
    xsma = sma(xPrice, Length)
    nRes = xPrice - xsma
    pos := iff(nRes > 0, 1,
    	     iff(nRes < 0, -1, nz(pos[1], 0))) 
    pos

study(title="Combo Strategy 123 Detrended Price Oscillator", shorttitle="Combo", overlay = true)
Length = input(14, minval=1)
KSmoothing = input(1, minval=1)
DLength = input(3, minval=1)
Level = input(50, minval=1)
//-------------------------
LengthDPO = input(14, minval=1)
posReversal123 = Reversal123(Length, KSmoothing, DLength, Level)
posDPO = DPO(LengthDPO)
pos = iff(posReversal123 == 1 and posDPO == 1 , 1,
	   iff(posReversal123 == -1 and posDPO == -1, -1, 0)) 
barcolor(pos == -1 ? #b50404: pos == 1 ? #079605 : #0536b3 )
````
