# Combo Strategy 123 Reversal & Gann Swing Oscillator

- url: https://www.tradingview.com/script/GNClimEy-Combo-Strategy-123-Reversal-Gann-Swing-Oscillator/
- type: indicator
- pine_id: PUB;nlA8SsDwvyklKr8f2TH4foovEItsBKBQ
- version: 2.0

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
 The Gann Swing Oscillator has been adapted from Robert Krausz's book, 
 "A W.D. Gann Treasure Discovered". The Gann Swing Oscillator helps 
 define market swings. 

 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=4
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 03/11/2020
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
// The Gann Swing Oscillator has been adapted from Robert Krausz's book, 
// "A W.D. Gann Treasure Discovered". The Gann Swing Oscillator helps 
// define market swings. 
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

    
GannSO(Length) =>
    pos = 0.0
    xGSO = 0.0
    xHH = highest(Length)
    xLL = lowest(Length)
    xGSO:= iff(xHH[2] > xHH[1] and xHH[0] > xHH[1], 1,
             iff(xLL[2] < xLL[1] and xLL[0] < xLL[1], -1, nz(xGSO[1],0)))
    pos := iff(xGSO > 0, 1,
    	     iff(xGSO < 0, -1, nz(pos[1], 0))) 
    pos

study(title="Combo Strategy 123 Reversal & Gann Swing Oscillator", shorttitle="Combo", overlay = true)
Length = input(14, minval=1)
KSmoothing = input(1, minval=1)
DLength = input(3, minval=1)
Level = input(50, minval=1)
//-------------------------
LengthGSO = input(5, minval=1)
posReversal123 = Reversal123(Length, KSmoothing, DLength, Level)
posGannSO = GannSO(LengthGSO)
pos = iff(posReversal123 == 1 and posGannSO == 1 , 1,
	   iff(posReversal123 == -1 and posGannSO == -1, -1, 0)) 
barcolor(pos== -1 ? #b50404: pos == 1 ? #079605 : #0536b3 )
````
