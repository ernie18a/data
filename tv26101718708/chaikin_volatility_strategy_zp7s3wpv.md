# Chaikin Volatility Strategy

- url: https://www.tradingview.com/script/Zp7s3wPv-Chaikin-Volatility-Strategy/
- type: indicator
- pine_id: PUB;403
- version: -1.0

## Description

Chaikin's Volatility indicator compares the spread between a security's
high and low prices. It quantifies volatility as a widening of the range
between the high and the low price.
You can use in the xPrice1 and xPrice2 any series: Open, High, Low, Close, HL2,
HLC3, OHLC4 and ect...

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 13/08/2014
// Chaikin's Volatility indicator compares the spread between a security's
// high and low prices. It quantifies volatility as a widening of the range
// between the high and the low price.
// You can use in the xPrice1 and xPrice2 any series: Open, High, Low, Close, HL2,
// HLC3, OHLC4 and ect...
///////////////////////////////////////////////////////////
study(title="Chaikin Volatility Strategy")
Length = input(10, minval=1)
ROCLength = input(12, minval=1)
Trigger = input(0, minval=1)
hline(0, color=purple, linestyle=line)
hline(Trigger, color=red, linestyle=line)
xPrice1 = high
xPrice2 = low
xPrice = xPrice1 - xPrice2
xROC_EMA = roc(ema(xPrice, Length), ROCLength)
pos =	iff(xROC_EMA < Trigger, 1,
	    iff(xROC_EMA > Trigger, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(xROC_EMA, color=blue, title="Chaikin Volatility Strategy")
````
