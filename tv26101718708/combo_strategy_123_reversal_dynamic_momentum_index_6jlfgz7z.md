# Combo Strategy 123 Reversal & Dynamic Momentum Index

- url: https://www.tradingview.com/script/6JLFGZ7Z-Combo-Strategy-123-Reversal-Dynamic-Momentum-Index/
- type: indicator
- pine_id: PUB;Gn79kyndEvRUopB03KFguB5YpfB81Xu2
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
 This indicator plots Dynamic Momentum Index indicator. The Dynamic Momentum 
 Index (DMI) was developed by Tushar Chande and Stanley Kroll. The indicator 
 is covered in detail in their book The New Technical Trader.
 The DMI is identical to Welles Wilder`s Relative Strength Index except the 
 number of periods is variable rather than fixed. The variability of the time 
 periods used in the DMI is controlled by the recent volatility of prices. 
 The more volatile the prices, the more sensitive the DMI is to price changes. 
 In other words, the DMI will use more time periods during quiet markets, and 
 less during active markets. The maximum time periods the DMI can reach is 30 
 and the minimum is 3. This calculation method is similar to the Variable 
 Moving Average, also developed by Tushar Chande.
The advantage of using a variable length time period when calculating the RSI 
 is that it overcomes the negative effects of smoothing, which often obscure short-term moves.
 The volatility index used in controlling the time periods in the DMI is based 
 on a calculation using a five period standard deviation and a ten period average 
 of the standard deviation.

 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=4
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 18/03/2020
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
// This indicator plots Dynamic Momentum Index indicator. The Dynamic Momentum 
// Index (DMI) was developed by Tushar Chande and Stanley Kroll. The indicator 
// is covered in detail in their book The New Technical Trader.
// The DMI is identical to Welles Wilder`s Relative Strength Index except the 
// number of periods is variable rather than fixed. The variability of the time 
// periods used in the DMI is controlled by the recent volatility of prices. 
// The more volatile the prices, the more sensitive the DMI is to price changes. 
// In other words, the DMI will use more time periods during quiet markets, and 
// less during active markets. The maximum time periods the DMI can reach is 30 
// and the minimum is 3. This calculation method is similar to the Variable 
// Moving Average, also developed by Tushar Chande.
// The advantage of using a variable length time period when calculating the RSI 
// is that it overcomes the negative effects of smoothing, which often obscure short-term moves.
// The volatility index used in controlling the time periods in the DMI is based 
// on a calculation using a five period standard deviation and a ten period average 
// of the standard deviation.
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

DMI(RSILen, BuyZone,SellZone,UpLimit,LoLimit) =>
    pos = 0
    xStdDev = stdev(close, 5) 
    xSMAStdDev = sma(xStdDev, 10)
    DTime = round(14 / xSMAStdDev - 0.5)
    xDMI = iff(DTime > UpLimit, UpLimit,
             iff(DTime < LoLimit, LoLimit, DTime))
    xRSI = rsi(xDMI, RSILen)
    pos := iff(xRSI > BuyZone, 1,
             iff(xRSI < SellZone, -1, nz(pos[1], 0))) 
    pos

study(title="Combo Strategy 123 Reversal & Dynamic Momentum Index", shorttitle="Combo", overlay = true)
Length = input(14, minval=1)
KSmoothing = input(1, minval=1)
DLength = input(3, minval=1)
Level = input(50, minval=1)
//-------------------------
RSILen = input(14, minval=1)
BuyZone = input(30, minval=1)
SellZone = input(70, minval=1)
UpLimit = input(30, minval=1)
LoLimit = input(5, minval=1)
posReversal123 = Reversal123(Length, KSmoothing, DLength, Level)
posDMI = DMI(RSILen, BuyZone,SellZone,UpLimit,LoLimit)
pos = iff(posReversal123 == 1 and posDMI == 1 , 1,
	   iff(posReversal123 == -1 and posDMI == -1, -1, 0)) 
barcolor(pos == -1 ? #b50404: pos == 1 ? #079605 : #0536b3 )
````
