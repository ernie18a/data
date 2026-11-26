# Volatility Finite Volume Elements Strategy

- url: https://www.tradingview.com/script/aAHWsMY5-Volatility-Finite-Volume-Elements-Strategy/
- type: indicator
- pine_id: PUB;tVTwfIjv86uRurT3ZbAnFO5Jr6mziTHK
- version: 1.0

## Description

This version has an important enhancement to the previous one that`s 
 especially useful with intraday minute charts.
 Due to the volatility had not been taken into account to avoid the extra 
 complication in the formula, the previous formula has some drawbacks:
 The main drawback is that the constant cutoff coefficient will overestimate 
 price changes in minute charts and underestimate corresponding changes in 
 weekly or monthly charts.
 And now the indicator uses adaptive cutoff coefficient which will adjust to 
 all time frames automatically.

 WARNING:
 This script to change bars colors.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 17/08/2017
// This is another version of FVE indicator that we have posted earlier 
// in this forum.
// This version has an important enhancement to the previous one that`s 
// especially useful with intraday minute charts.
// Due to the volatility had not been taken into account to avoid the extra 
// complication in the formula, the previous formula has some drawbacks:
// The main drawback is that the constant cutoff coefficient will overestimate 
// price changes in minute charts and underestimate corresponding changes in 
// weekly or monthly charts.
// And now the indicator uses adaptive cutoff coefficient which will adjust to 
// all time frames automatically.
//
// WARNING:
// This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Volatility Finite Volume Elements", shorttitle="FVI")
Samples = input(22, minval=1)
Perma = input(40, minval=1)
Cintra = input(0.1)
Cinter = input(0.1)
xhl2 = hl2
xhlc3 = hlc3
xClose = close
xIntra = log(high) - log(low)
xInter = log(xhlc3) - log(xhlc3[1])
xStDevIntra = stdev(sma(xIntra, Samples) , Samples)
xStDevInter = stdev(sma(xInter, Samples) , Samples)
xVolume = volume
TP = xhlc3
TP1 = xhlc3[1]
Intra = xIntra
Vintra = xStDevIntra
Inter = xInter
Vinter = xStDevInter
CutOff = Cintra * Vintra + Cinter * Vinter
MF = xClose - xhl2 + TP - TP1
FveFactor = iff(MF > CutOff * xClose, 1, 
             iff(MF < -1 * CutOff * xClose, -1,  0))
xVolumePlusMinus = xVolume * FveFactor
Fvesum = sum(xVolumePlusMinus, Samples)
VolSum = sum(xVolume, Samples)
xFVE = (Fvesum / VolSum) * 100
xEMAFVE = ema(xFVE, Perma)
pos =	iff(xFVE > xEMAFVE, 1,
	    iff(xFVE < xEMAFVE, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue)
plot(xFVE, color=green, title="FVI")
plot(xEMAFVE, color=blue, title="FVI EMA")
````
