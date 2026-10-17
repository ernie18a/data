# Combining DMI And Moving Average For A EUR/USD Trading System

- url: https://www.tradingview.com/script/DHGaDYDT-Combining-DMI-And-Moving-Average-For-A-EUR-USD-Trading-System/
- type: indicator
- pine_id: PUB;525
- version: -1.0

## Description

Combining DMI And Moving Average For A EUR/USD Trading System, by Rombout Kerstens
The related article is copyrighted material from Stocks & Commodities Aug 2009

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 10/09/2014
// The related article is copyrighted material from Stocks & Commodities Aug 2009 
////////////////////////////////////////////////////////////
study(title="Combining DMI And Moving Average For A EUR/USD Trading System")
Length_MA = input(30, minval=1)
Length_DMI = input(14, minval=1)
xMA = sma(close, Length_MA)
up = change(high)
down = -change(low)
trur = rma(tr, Length_DMI)
xPDI = fixnan(100 * rma(up > down and up > 0 ? up : 0, Length_DMI) / trur)
xNDI = fixnan(100 * rma(down > up and down > 0 ? down : 0, Length_DMI) / trur)
nPDI = xPDI
nNDI = xNDI
nMA = xMA
nPDI_1 = xPDI[1]
nNDI_1 = xNDI[1]
nMA_1 = xMA[1]
bMDILong = iff(nPDI > nNDI and nPDI_1 < nNDI_1, true, 
            iff(nPDI < nNDI and nPDI_1 > nNDI_1, false, false)) 
bMDIShort = iff(nPDI > nNDI and nPDI_1 < nNDI_1, false, 
                iff(nPDI < nNDI and nPDI_1 > nNDI_1, true, false)) 
bMALong = iff(close > nMA and close[1] < nMA_1, true, 
             iff(close < nMA and close[1] > nMA_1, false, false))
bMAShort = iff(close > nMA and close[1] < nMA_1, false, 
             iff(close < nMA and close[1] > nMA_1, true, false))
pos = iff(bMDILong and bMALong, 1, 
     iff(bMDIShort and bMAShort, -1, nz(pos[1], 0)))
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nPDI, color=green, title="DMI Plus")
plot(nNDI, color=red, title="DMI Minus")
````
