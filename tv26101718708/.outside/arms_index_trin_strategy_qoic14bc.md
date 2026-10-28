# Arms Index (TRIN) Strategy

- url: https://www.tradingview.com/script/QOIc14Bc-Arms-Index-TRIN-Strategy/
- type: indicator
- pine_id: PUB;a39T6RllbxcCnXmuLYamBF7UFFHicS3B
- version: 1.0

## Description

The Arms index (TRIN) is a technical analysis indicator that compares advancing 
 and declining stock issues and trading volume as an indicator of overall market 
 sentiment. It measures the relationship between market supply and demand and is 
 used as a predictor of future price movements in the market, primarily on an 
 intraday basis. The Arms index seeks to provide a more dynamic explanation of 
 overall movements in the composite value of stock exchanges, such as the NYSE or 
 NASDAQ, by analyzing the strength and breadth of these movements.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 08/05/2017
// The Arms index (TRIN) is a technical analysis indicator that compares advancing 
// and declining stock issues and trading volume as an indicator of overall market 
// sentiment. It measures the relationship between market supply and demand and is 
// used as a predictor of future price movements in the market, primarily on an 
// intraday basis. The Arms index seeks to provide a more dynamic explanation of 
// overall movements in the composite value of stock exchanges, such as the NYSE or 
// NASDAQ, by analyzing the strength and breadth of these movements.
////////////////////////////////////////////////////////////
study(title="Arms Index (TRIN)", shorttitle="TRIN")
AdvSymbol = input(title="Advancing Symbol", type=symbol, defval="USI:ADV")
DecSymbol = input(title="Declining Symbol", type=symbol, defval="USI:DECL")
AdvSymbolVolume = input(title="Advancing Volume Symbol", type=symbol, defval="USI:UVOL")
DecSymbolVolume = input(title="Declining Volume Symbol", type=symbol, defval="USI:DVOL")
Resolutin = input(title="Resolution", type=resolution, defval="D")
TopBand = input(1.25, step = 0.01)
LowBand = input(0.7, step = 0.01)
hline(0, color=gray, linestyle=dashed)
hline(TopBand, color=red, linestyle=line)
hline(LowBand, color=green, linestyle=line)
xASValue = security(AdvSymbol, Resolutin, close)
xDSValue = security(DecSymbol, Resolutin, close)
xASVValue = security(AdvSymbolVolume, Resolutin, close)
xDSVValue = security(DecSymbolVolume, Resolutin, close)
nRes = (xASValue / xDSValue)/(xASVValue / xDSVValue)
pos = iff(nRes > TopBand, -1,
	     iff(nRes < LowBand, 1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nRes, color=blue, title="TRIN")
````
