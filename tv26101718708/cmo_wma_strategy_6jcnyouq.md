# CMO & WMA Strategy

- url: https://www.tradingview.com/script/6JcnYoUq-CMO-WMA-Strategy/
- type: indicator
- pine_id: PUB;FV3J9V4JYBJFSp7LosBbzk29n0bO4Xmt
- version: 1.0

## Description

This indicator plots Chande Momentum Oscillator and its WMA on the 
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
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 08/02/2017
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
study(title="CMO & WMA", shorttitle="CMO & WMA")
Length = input(9, minval=1)
LengthWMA = input(9, minval=1)
hline(0, color=gray, linestyle=line)
xMom = abs(close - close[1])
xSMA_mom = sma(xMom, Length)
xMomLength = close - close[Length]
nRes = 100 * (xMomLength / (xSMA_mom * Length))
xWMACMO = wma(nRes, LengthWMA)
pos = iff(nRes > xWMACMO, 1,
	   iff(nRes <= xWMACMO, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nRes, color=blue, title="CMO")
plot(xWMACMO, color=red, title="WMA")
````
