# Ergotic MDI Strategy

- url: https://www.tradingview.com/script/aCdUj4L1-Ergotic-MDI-Strategy/
- type: indicator
- pine_id: PUB;211
- version: -1.0

## Description

This is one of the techniques described by William Blau in his book "Momentum,
    Direction and Divergence" (1995). If you like to learn more, we advise you to
    read this book. His book focuses on three key aspects of trading: momentum, 
    direction and divergence. Blau, who was an electrical engineer before becoming 
    a trader, thoroughly examines the relationship between price and momentum in 
    step-by-step examples. From this grounding, he then looks at the deficiencies 
    in other oscillators and introduces some innovative techniques, including a 
    fresh twist on Stochastics. On directional issues, he analyzes the intricacies 
    of ADX and offers a unique approach to help define trending and non-trending periods.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 17/07/2014
// This is one of the techniques described by William Blau in his book "Momentum,
// Direction and Divergence" (1995). If you like to learn more, we advise you to
// read this book. His book focuses on three key aspects of trading: momentum, 
// direction and divergence. Blau, who was an electrical engineer before becoming 
// a trader, thoroughly examines the relationship between price and momentum in 
// step-by-step examples. From this grounding, he then looks at the deficiencies 
// in other oscillators and introduces some innovative techniques, including a 
// fresh twist on Stochastics. On directional issues, he analyzes the intricacies 
// of ADX and offers a unique approach to help define trending and non-trending periods.
////////////////////////////////////////////////////////////
study(title="Ergotic MDI (Mean Deviation Indicator) Strategy")
r = input(32, minval=1)
s = input(5, minval=1)
u = input(5, minval=1)
SmthLen = input(3, minval=1)
hline(0, color=blue, linestyle=line)
xEMA = ema(close, r)
xEMA_S = close - xEMA
xEMA_U = ema(ema(xEMA_S, s), u)
xSignal = ema(xEMA_U, u)
pos =	iff(xEMA_U > xSignal, 1,
	    iff(xEMA_U < xSignal, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(xEMA_U, color=green, title="Ergotic MDI")
plot(xSignal, color=red, title="SigLin")
````
