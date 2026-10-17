# Elder Ray (Bull Power) Strategy

- url: https://www.tradingview.com/script/STEeYhTV-Elder-Ray-Bull-Power-Strategy/
- type: indicator
- pine_id: PUB;236
- version: -1.0

## Description

Developed by Dr Alexander Elder, the Elder-ray indicator measures buying 
 and selling pressure in the market. The Elder-ray is often used as part 
 of the Triple Screen trading system but may also be used on its own.
 Dr Elder uses a 13-day exponential moving average (EMA) to indicate the 
 market consensus of value. Bull Power measures the ability of buyers to 
 drive prices above the consensus of value. Bear Power reflects the ability 
 of sellers to drive prices below the average consensus of value.
 Bull Power is calculated by subtracting the 13-day EMA from the day's High. 
 Bear power subtracts the 13-day EMA from the day's Low.
 You can use in the xPrice any series: Open, High, Low, Close, HL2, HLC3, OHLC4 and ect...

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 23/07/2014
// Developed by Dr Alexander Elder, the Elder-ray indicator measures buying 
// and selling pressure in the market. The Elder-ray is often used as part 
// of the Triple Screen trading system but may also be used on its own.
// Dr Elder uses a 13-day exponential moving average (EMA) to indicate the 
// market consensus of value. Bull Power measures the ability of buyers to 
// drive prices above the consensus of value. Bear Power reflects the ability 
// of sellers to drive prices below the average consensus of value.
// Bull Power is calculated by subtracting the 13-day EMA from the day's High. 
// Bear power subtracts the 13-day EMA from the day's Low.
// You can use in the xPrice any series: Open, High, Low, Close, HL2, HLC3, OHLC4 and ect...
////////////////////////////////////////////////////////////
study(title="Elder Ray (Bull Power) Strategy")
Length = input(13, minval=1)
Trigger = input(0)
hline(0, color=purple, linestyle=line)
xPrice = close
xMA = ema(xPrice,Length)
DayHigh = iff(dayofmonth != dayofmonth[1], high, max(high, nz(DayHigh[1])))
nRes = DayHigh - xMA
pos =	iff(nRes > Trigger, 1,
	    iff(nRes < Trigger, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nRes, color=blue, title="Bull Power", style = histogram)
````
