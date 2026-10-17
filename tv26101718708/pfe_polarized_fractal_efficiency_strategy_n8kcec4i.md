# PFE (Polarized Fractal Efficiency) Strategy

- url: https://www.tradingview.com/script/N8KCEC4I-PFE-Polarized-Fractal-Efficiency-Strategy/
- type: indicator
- pine_id: PUB;KP5o4LkEKi1ehENtkMJ0fx6GGWB9aGgH
- version: 1.0

## Description

The Polarized Fractal Efficiency (PFE) indicator measures the efficiency 
 of price movements by drawing on concepts from fractal geometry and chaos 
 theory. The more linear and efficient the price movement, the shorter the 
 distance the prices must travel between two points and thus the more efficient 
 the price movement.
 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 28/09/2017
// The Polarized Fractal Efficiency (PFE) indicator measures the efficiency 
// of price movements by drawing on concepts from fractal geometry and chaos 
// theory. The more linear and efficient the price movement, the shorter the 
// distance the prices must travel between two points and thus the more efficient 
// the price movement.
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="PFE (Polarized Fractal Efficiency)", shorttitle="PFE (Polarized Fractal Efficiency)")
Length = input(9, minval=1)
LengthEMA = input(5, minval=1)
BuyBand = input(50, step = 0.1)
SellBand = input(-50, step = 0.1)
hline(BuyBand, color=green, linestyle=line, title = "TopBand")
hline(SellBand, color=red, linestyle=line, title = "LowBand")
PFE = sqrt(pow(close - close[Length], 2) + 100)
C2C = sum(sqrt(pow((close - close[1]), 2) + 1), Length)
xFracEff = iff(close - close[Length] > 0,  round((PFE / C2C) * 100) , round(-(PFE / C2C) * 100))
xEMA = ema(xFracEff, LengthEMA)
pos = iff(xEMA < SellBand, -1,
	   iff(xEMA > BuyBand, 1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue)
plot(xEMA, color=blue, title="PFE")
````
