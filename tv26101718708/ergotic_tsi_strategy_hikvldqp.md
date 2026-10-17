# Ergotic TSI Strategy

- url: https://www.tradingview.com/script/hikvLDQp-Ergotic-TSI-Strategy/
- type: indicator
- pine_id: PUB;205
- version: -1.0

## Description

r - Length of first EMA smoothing of 1 day momentum       
    s - Length of second EMA smoothing of 1 day smoothing          
    u- Length of third EMA smoothing of 1 day momentum           
    Length of EMA signal line                                  


    This is one of the techniques described by William Blau in his book "Momentum,
    Direction and Divergence" (1995). If you like to learn more, we advise you to 
    read this book. His book focuses on three key aspects of trading: momentum, 
    direction and divergence. Blau, who was an electrical engineer before becoming 
    a trader, thoroughly examines the relationship between price and momentum in 
    step-by-step examples. From this grounding, he then looks at the deficiencies 
    in other oscillators and introduces some innovative techniques, including a 
    fresh twist on Stochastics. On directional issues, he analyzes the intricacies 
    of ADX and offers a unique approach to help define trending and non-trending periods. 
   You can use in the xPrice any series: Open, High, Low, Close, HL2, HLC3, OHLC4 and ect...

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 17/07/2014
// r - Length of first EMA smoothing of 1 day momentum        4
// s - Length of second EMA smoothing of 1 day smoothing      8    
// u- Length of third EMA smoothing of 1 day momentum         6  
// Length of EMA signal line                                  3
// Source of Ergotic TSI                                      Close
//
// This is one of the techniques described by William Blau in his book "Momentum,
// Direction and Divergence" (1995). If you like to learn more, we advise you to 
// read this book. His book focuses on three key aspects of trading: momentum, 
// direction and divergence. Blau, who was an electrical engineer before becoming 
// a trader, thoroughly examines the relationship between price and momentum in 
// step-by-step examples. From this grounding, he then looks at the deficiencies 
// in other oscillators and introduces some innovative techniques, including a 
// fresh twist on Stochastics. On directional issues, he analyzes the intricacies 
// of ADX and offers a unique approach to help define trending and non-trending periods. 
// You can use in the xPrice any series: Open, High, Low, Close, HL2, HLC3, OHLC4 and ect...
////////////////////////////////////////////////////////////
study(title="Ergotic TSI Strategy")
r = input(4, minval=1)
s = input(8, minval=1)
u = input(6, minval=1)
SmthLen = input(3, minval=1)
hline(0, color=blue, linestyle=line)
xPrice = close
xPrice1 = xPrice - xPrice[1]
xPrice2 = abs(xPrice - xPrice[1])
xSMA_R = ema(ema(ema(xPrice1,r), s),u)
xSMA_aR = ema(ema(ema(xPrice2, r), s),u)
Val1 = 100 * xSMA_R
Val2 = xSMA_aR
xTSI = iff (Val2 != 0, Val1 / Val2, 0)
xEMA_TSI = ema(xTSI, SmthLen)
pos =	iff(xTSI > xEMA_TSI, 1,
	    iff(xTSI < xEMA_TSI, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(xTSI, color=green, title="Ergotic TSI")
plot(xEMA_TSI, color=red, title="SigLin")
````
