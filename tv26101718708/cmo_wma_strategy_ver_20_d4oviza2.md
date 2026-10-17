# CMO & WMA Strategy ver 2.0

- url: https://www.tradingview.com/script/D4OViZa2-CMO-WMA-Strategy-ver-2-0/
- type: indicator
- pine_id: PUB;AkgfduAuycEsHl0QVBP7Ue8QMwRuyvTi
- version: 1.0

## Description

This indicator plots Chandre Momentum Oscillator and its WMA on the 
    same chart. This indicator plots the absolute value of CMO.
    The CMO is closely related to, yet unique from, other momentum oriented 
    indicators such as Relative Strength Index, Stochastic, Rate-of-Change, 
    etc. It is most closely related to Welles Wilder?s RSI, yet it differs 
    in several ways:
    - It uses data for both up days and down days in the numerator, thereby 
        directly measuring momentum;
    - The calculations are applied on unsmoothed data. Therefore, short-term 
        extreme movements in price are not hidden. Once calculated, smoothing 
        can be applied to the CMO, if desired;
    - The scale is bounded between +100 and -100, thereby allowing you to clearly 
        see changes in net momentum using the 0 level. The bounded scale also allows 
        you to conveniently compare values across different securities.

## Source Code

````pine
//@version=3
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 17/10/2018
//    This indicator plots Chandre Momentum Oscillator and its WMA on the 
//    same chart. This indicator plots the absolute value of CMO.
//    The CMO is closely related to, yet unique from, other momentum oriented 
//    indicators such as Relative Strength Index, Stochastic, Rate-of-Change, 
//    etc. It is most closely related to Welles Wilder?s RSI, yet it differs 
//    in several ways:
//    - It uses data for both up days and down days in the numerator, thereby 
//        directly measuring momentum;
//    - The calculations are applied on unsmoothed data. Therefore, short-term 
//        extreme movements in price are not hidden. Once calculated, smoothing 
//        can be applied to the CMO, if desired;
//    - The scale is bounded between +100 and -100, thereby allowing you to clearly 
//        see changes in net momentum using the 0 level. The bounded scale also allows 
//        you to conveniently compare values across different securities.
////////////////////////////////////////////////////////////
study(title="CMO & WMA Strategy ver 2.0", shorttitle="CMO & WMA")
Length = input(9, minval=1)
LengthWMA = input(9, minval=1)
BuyZone = input(60, step = 0.01)
SellZone = input(-60, step = 0.01)
hline(BuyZone, color=green, linestyle=line)
hline(SellZone, color=red, linestyle=line)
hline(0, color=gray, linestyle=line)
xMom = abs(close - close[1])
xSMA_mom = sma(xMom, Length)
xMomLength = close - close[Length]
nRes = 100 * (xMomLength / (xSMA_mom * Length))
xWMACMO = wma(nRes, LengthWMA)
pos = 0.0
pos := iff(xWMACMO > BuyZone, 1,
	   iff(xWMACMO < SellZone, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nRes, color=blue, title="CMO")
plot(xWMACMO, color=red, title="WMA")
````
