# Combo Strategies 123 Reversal and Accelerator Oscillator (AC)

- url: https://www.tradingview.com/script/fOYVlrxr-Combo-Strategies-123-Reversal-and-Accelerator-Oscillator-AC/
- type: indicator
- pine_id: PUB;PVkgmHn9QhwAxWJobb3xeJTRV2CQBdEq
- version: 1.0

## Description

This is combo strategies for get 
 a cumulative signal. Result signal will return 1 if two strategies 
 is long, -1 if all strategies is short and 0 if signals of strategies is not equal.

 First strategy
 This System was created from the Book "How I Tripled My Money In The 
 Futures Market" by Ulf Jensen, Page 183. This is reverse type of strategies.
 The strategy buys at market, if close price is higher than the previous close 
 during 2 days and the meaning of 9-days Stochastic Slow Oscillator is lower than 50. 
 The strategy sells at market, if close price is lower than the previous close price 
 during 2 days and the meaning of 9-days Stochastic Fast Oscillator is higher than 50.

 Second strategy
 The Accelerator Oscillator has been developed by Bill Williams 
 as the development of the Awesome Oscillator. It represents the 
 difference between the Awesome Oscillator and the 5-period moving 
 average, and as such it shows the speed of change of the Awesome 
 Oscillator, which can be useful to find trend reversals before the 
 Awesome Oscillator does.

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=3
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 24/04/2019
// This is combo strategies for get 
// a cumulative signal. Result signal will return 1 if two strategies 
// is long, -1 if all strategies is short and 0 if signals of strategies is not equal.
//
// First strategy
// This System was created from the Book "How I Tripled My Money In The 
// Futures Market" by Ulf Jensen, Page 183. This is reverse type of strategies.
// The strategy buys at market, if close price is higher than the previous close 
// during 2 days and the meaning of 9-days Stochastic Slow Oscillator is lower than 50. 
// The strategy sells at market, if close price is lower than the previous close price 
// during 2 days and the meaning of 9-days Stochastic Fast Oscillator is higher than 50.
//
// Secon strategy
// The Accelerator Oscillator has been developed by Bill Williams 
// as the development of the Awesome Oscillator. It represents the 
// difference between the Awesome Oscillator and the 5-period moving 
// average, and as such it shows the speed of change of the Awesome 
// Oscillator, which can be useful to find trend reversals before the 
// Awesome Oscillator does.
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
Reversal123(Length, KSmoothing, DLength, Level) =>
    vFast = sma(stoch(close, high, low, Length), KSmoothing) 
    vSlow = sma(vFast, DLength)
    pos = 0.0
    pos := iff(close[2] < close[1] and close > close[1] and vFast < vSlow and vFast > Level, 1,
	         iff(close[2] > close[1] and close < close[1] and vFast > vSlow and vFast < Level, -1, nz(pos[1], 0))) 
	pos

AcceleratorOscillator(nLengthSlow, nLengthFast) =>
    xSMA1_hl2 = sma(hl2, nLengthFast)
    xSMA2_hl2 = sma(hl2, nLengthSlow)
    xSMA1_SMA2 = xSMA1_hl2 - xSMA2_hl2
    xSMA_hl2 = sma(xSMA1_SMA2, nLengthFast)
    nRes =  xSMA1_SMA2 - xSMA_hl2
    cClr = nRes > nRes[1] ? blue : red
    pos = 0.0
    pos := iff(nRes > 0, 1,
             iff(nRes < 0, -1, nz(pos[1], 0))) 
    pos

study(title="Combo Strategies 123 Reversal and Accelerator Oscillator (AC)", shorttitle="Combo", overlay = true)
Length = input(14, minval=1)
KSmoothing = input(1, minval=1)
DLength = input(3, minval=1)
Level = input(50, minval=1)
nLengthSlow = input(34, minval=1, title="Length Slow")
nLengthFast = input(5, minval=1, title="Length Fast")
posReversal123 = Reversal123(Length, KSmoothing, DLength, Level)
posAcceleratorOscillator = AcceleratorOscillator(nLengthSlow, nLengthFast)
pos = iff(posReversal123 == 1 and posAcceleratorOscillator == 1 , 1,
	   iff(posReversal123 == -1 and posAcceleratorOscillator == -1, -1, 0)) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
````
