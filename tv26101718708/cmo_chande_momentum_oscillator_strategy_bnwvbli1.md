# CMO (Chande Momentum Oscillator) Strategy

- url: https://www.tradingview.com/script/bnWVbLI1-CMO-Chande-Momentum-Oscillator-Strategy/
- type: indicator
- pine_id: PUB;vGHOnF9LUwvfbykY71bjcBUuxOIRPDnm
- version: 1.0

## Description

This indicator plots Chande Momentum Oscillator. This indicator was 
    developed by Tushar Chande. A scientist, an inventor, and a respected 
    trading system developer, Mr. Chande developed the CMO to capture what 
    he calls "pure momentum". For more definitive information on the CMO and 
    other indicators we recommend the book The New Technical Trader by Tushar 
    Chande and Stanley Kroll.
    The CMO is closely related to, yet unique from, other momentum oriented 
    indicators such as Relative Strength Index, Stochastic, Rate-of-Change, 
    etc. It is most closely related to Welles Wilder`s RSI, yet it differs 
    in several ways:
        - It uses data for both up days and down days in the numerator, thereby 
          directly measuring momentum;
        - The calculations are applied on unsmoothed data. Therefore, short-term 
          extreme movements in price are not hidden. Once calculated, smoothing 
          can be applied to the CMO, if desired;
        - The scale is bounded between +100 and -100, thereby allowing you to 
          clearly see changes in net momentum using the 0 level. The bounded scale 
          also allows you to conveniently compare values across different securities.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 06/02/2017
//    This indicator plots Chande Momentum Oscillator. This indicator was 
//    developed by Tushar Chande. A scientist, an inventor, and a respected 
//    trading system developer, Mr. Chande developed the CMO to capture what 
//    he calls "pure momentum". For more definitive information on the CMO and 
//    other indicators we recommend the book The New Technical Trader by Tushar 
//    Chande and Stanley Kroll.
//    The CMO is closely related to, yet unique from, other momentum oriented 
//    indicators such as Relative Strength Index, Stochastic, Rate-of-Change, 
//    etc. It is most closely related to Welles Wilder`s RSI, yet it differs 
//    in several ways:
//        - It uses data for both up days and down days in the numerator, thereby 
//          directly measuring momentum;
//        - The calculations are applied on unsmoothed data. Therefore, short-term 
//          extreme movements in price are not hidden. Once calculated, smoothing 
//          can be applied to the CMO, if desired;
//        - The scale is bounded between +100 and -100, thereby allowing you to 
//          clearly see changes in net momentum using the 0 level. The bounded scale 
//          also allows you to conveniently compare values across different securities.
////////////////////////////////////////////////////////////
study(title="CMO (Chande Momentum Oscillator)", shorttitle="CMO")
Length = input(9, minval=1)
TopBand = input(70, minval=1)
LowBand = input(-70, maxval=-1)
hline(0, color=gray, linestyle=dashed)
hline(TopBand, color=red, linestyle=line)
hline(LowBand, color=green, linestyle=line)
xMom = abs(close - close[1])
xSMA_mom = sma(xMom, Length)
xMomLength = close - close[Length]
nRes = 100 * (xMomLength / (xSMA_mom * Length))
pos = iff(nRes > TopBand, 1,
	   iff(nRes <= LowBand, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nRes, color=blue, title="CMO")
````
