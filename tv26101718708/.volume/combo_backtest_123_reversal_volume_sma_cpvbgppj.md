# Combo Backtest 123 Reversal & Volume SMA

- url: https://www.tradingview.com/script/CpVBGPpJ-Combo-Backtest-123-Reversal-Volume-SMA/
- type: indicator
- pine_id: PUB;ZwGcUUxKfFshXDRls4REnimLL9lm2S5v
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
 Volume and SMA

 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=4
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 12/11/2020
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
// Volume and SMA
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

    
VSAVol(Length) =>
    pos = 0.0
    xSMA_vol = sma(volume, Length)
    pos := iff(volume > xSMA_vol, -1,
    	     iff(volume < xSMA_vol, 1, nz(pos[1], 0))) 
    pos

study(title="Combo Backtest 123 Reversal & Volume SMA", shorttitle="Combo", overlay = true)
Length = input(14, minval=1)
KSmoothing = input(1, minval=1)
DLength = input(3, minval=1)
Level = input(50, minval=1)
//-------------------------
Length_MAVol = input(40, minval=1)
posReversal123 = Reversal123(Length, KSmoothing, DLength, Level)
posVSAVol = VSAVol(Length_MAVol)
pos = iff(posReversal123 == 1 and posVSAVol == 1 , 1,
	   iff(posReversal123 == -1 and posVSAVol == -1, -1, 0)) 
barcolor(pos == -1 ? #b50404: pos == 1 ? #079605 : #0536b3 )
````
