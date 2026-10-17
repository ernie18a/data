# RSI HistoAlert Strategy

- url: https://www.tradingview.com/script/bXMVCkJK-RSI-HistoAlert-Strategy/
- type: indicator
- pine_id: PUB;370
- version: -1.0

## Description

This is simple indicator modified RSI Strategy
You can use in the xPrice any series: Open, High, Low, Close, HL2, HLC3, OHLC4 and ect...

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 07/08/2014
// This simple indicator modified RSI
// You can use in the xPrice any series: Open, High, Low, Close, HL2, HLC3, OHLC4 and ect...
////////////////////////////////////////////////////////////
study(title="RSI HistoAlert Strategy")
RSIPeriod = input(13, minval=1)
BuyAlertLevel = input(-10)
SellAlertLevel = input(10)
RSIHistoModify = input(1.5)
hline(0, color=purple, linestyle=line)
hline(BuyAlertLevel, color=green, linestyle=dashed)
hline(SellAlertLevel, color=red, linestyle=dashed)
xPrice = close
RSIMain = (rsi(xPrice, RSIPeriod) - 50) * RSIHistoModify
rsiHcolor = iff(RSIMain >= 0 , green,
        iff(RSIMain < 0, red, black))
pos =iff(RSIMain > BuyAlertLevel, 1,
	    iff(RSIMain < SellAlertLevel, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )        
plot(RSIMain, color=blue, title="RSI HistoAlert")
plot(RSIMain, color=rsiHcolor, title="Histogram", style = histogram, linewidth  = 1)
````
