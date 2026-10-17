# CMOav Strategy

- url: https://www.tradingview.com/script/Kh45MftQ-CMOav-Strategy/
- type: indicator
- pine_id: PUB;bBN1mArW3VOAKAsbCMn4wmaHWYkxHNtI
- version: 1.0

## Description

This indicator plots average of three different length CMO's. This indicator 
    was developed by Tushar Chande. A scientist, an inventor, and a respected 
    trading system developer, Mr. Chande developed the CMO to capture what he 
    calls "pure momentum". For more definitive information on the CMO and other 
    indicators we recommend the book The New Technical Trader by Tushar Chande 
    and Stanley Kroll.
    The CMO is closely related to, yet unique from, other momentum oriented 
    indicators such as Relative Strength Index, Stochastic, Rate-of-Change, etc. 
    It is most closely related to Welles Wilder?s RSI, yet it differs in several ways:
    - It uses data for both up days and down days in the numerator, thereby directly 
    measuring momentum;
    - The calculations are applied on unsmoothed data. Therefore, short-term extreme 
    movements in price are not hidden. Once calculated, smoothing can be applied to 
    the CMO, if desired;
    - The scale is bounded between +100 and -100, thereby allowing you to clearly see 
    changes in net momentum using the 0 level. The bounded scale also allows you to 
    conveniently compare values across different securities.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 27/02/2017
//    This indicator plots average of three different length CMO's. This indicator 
//    was developed by Tushar Chande. A scientist, an inventor, and a respected 
//    trading system developer, Mr. Chande developed the CMO to capture what he 
//    calls "pure momentum". For more definitive information on the CMO and other 
//    indicators we recommend the book The New Technical Trader by Tushar Chande 
//    and Stanley Kroll.
//    The CMO is closely related to, yet unique from, other momentum oriented 
//    indicators such as Relative Strength Index, Stochastic, Rate-of-Change, etc. 
//    It is most closely related to Welles Wilder?s RSI, yet it differs in several ways:
//    - It uses data for both up days and down days in the numerator, thereby directly 
//    measuring momentum;
//    - The calculations are applied on unsmoothed data. Therefore, short-term extreme 
//    movements in price are not hidden. Once calculated, smoothing can be applied to 
//    the CMO, if desired;
//    - The scale is bounded between +100 and -100, thereby allowing you to clearly see 
//    changes in net momentum using the 0 level. The bounded scale also allows you to 
//    conveniently compare values across different securities.
////////////////////////////////////////////////////////////
study(title="CMOav", shorttitle="CMOav")
Length1 = input(5, minval=1)
Length2 = input(10, minval=1)
Length3 = input(20, minval=1)
TopBand = input(70, minval=1)
LowBand = input(-70, maxval=-1)
hline(0, color=purple, linestyle=dashed)
hline(TopBand, color=red, linestyle=line)
hline(LowBand, color=green, linestyle=line)
xMom = close - close[1]
xMomabs = abs(close - close[1])
nSum1 = sum(xMom, Length1)
nSumAbs1 = sum(xMomabs, Length1)
nSum2 = sum(xMom, Length2)
nSumAbs2 = sum(xMomabs, Length2)
nSum3 = sum(xMom, Length3)
nSumAbs3 = sum(xMomabs, Length3)
nRes = 100 * (nSum1 / nSumAbs1 + nSum2 / nSumAbs2 + nSum3 / nSumAbs3 ) / 3
pos = iff(nRes > TopBand, 1,
	     iff(nRes < LowBand, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nRes, color=blue, title="CMOav")
````
