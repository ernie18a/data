# Combo Strategy 123 Reversal & Center Of Gravity

- url: https://www.tradingview.com/script/WcU6Riad-Combo-Strategy-123-Reversal-Center-Of-Gravity/
- type: indicator
- pine_id: PUB;s8VvfIbu5rYIsPz963EsM4J8QPiPH9ZC
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
 The indicator is based on moving averages. On the basis of these, the 
 "center" of the price is calculated, and price channels are also constructed, 
 which act as corridors for the asset quotations.

 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=4
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 16/07/2019
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
// The indicator is based on moving averages. On the basis of these, the 
// "center" of the price is calculated, and price channels are also constructed, 
// which act as corridors for the asset quotations.
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

CenterOfGravity(Length, m,Percent, SignalLine) =>
    pos = 0
    xLG = linreg(close, Length, m)
    xLG1r = xLG + ((close * Percent) / 100)
    xLG1s = xLG - ((close * Percent) / 100)
    xLG2r = xLG + ((close * Percent) / 100) * 2
    xLG2s = xLG - ((close * Percent) / 100) * 2
    xSignalR = iff(SignalLine == 1, xLG1r, xLG2r)
    xSignalS = iff(SignalLine == 1, xLG1s, xLG2s)
    pos :=  iff(close > xSignalR, 1,
             iff(close < xSignalS, -1, nz(pos[1], 0))) 
    pos

study(title="Combo Strategy 123 Reversal & Center Of Gravity", shorttitle="Combo", overlay = true)
Length = input(14, minval=1)
KSmoothing = input(1, minval=1)
DLength = input(3, minval=1)
Level = input(50, minval=1)
//-------------------------
LengthCoF = input(20, minval=1)
m = input(5, minval=0)
Percent = input(1, minval=0)
SignalLine = input(1, minval=1, maxval = 2, title = "Trade from line (1 or 2)")
posReversal123 = Reversal123(LengthCoF, KSmoothing, DLength, Level)
posCenterOfGravity = CenterOfGravity(Length, m,Percent, SignalLine)
pos = iff(posReversal123 == 1 and posCenterOfGravity == 1 , 1,
	   iff(posReversal123 == -1 and posCenterOfGravity == -1, -1, 0)) 
barcolor(pos == -1 ? #b50404: pos == 1 ? #079605 : #0536b3 )
````
