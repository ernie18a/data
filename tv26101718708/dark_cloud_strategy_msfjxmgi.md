# Dark Cloud Strategy

- url: https://www.tradingview.com/script/MSfJXMgI-Dark-Cloud-Strategy/
- type: indicator
- pine_id: PUB;BBMaalyf0mgIBJzcr9LpNqiXXeAvfKfX
- version: 1.0

## Description

This is a bearish reversal pattern formed by two candlesticks  within a uptrend. 
    Consists of an up candlestick followed by a down candlestick which opens lower 
    than the prior candlestick and closes below the midrange of the prior candlestick. 
    It is the reverse of the Piercing Line.
 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=3
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 22/01/2019
//    This is a bearish reversal pattern formed by two candlesticks  within a uptrend. 
//    Consists of an up candlestick followed by a down candlestick which opens lower 
//    than the prior candlestick and closes below the midrange of the prior candlestick. 
//    It is the reverse of the Piercing Line.
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title = "Dark Cloud Strategy", overlay = true)
input_takeprofit = input(2.5, title="Take Profit pip", step=0.01)
input_stoploss = input(2.50, title="Stop Loss pip", step=0.01)
barcolor( open[1] < close[1] ? open > high[1] ? close < close[1] - ((close[1] - open[1]) / 2) ? close > open[1] ? yellow :na :na :na :na )
posprice = 0.0
posprice :=  open[1] < close[1] ? open > high[1] ? close < close[1] - ((close[1] - open[1]) / 2) ? close > open[1] ? close :nz(posprice[1], 0) :nz(posprice[1], 0) : nz(posprice[1], 0) : nz(posprice[1], 0) 
pos = 0.0
pos := iff(posprice > 0, -1, 0)
barcolor(pos == -1 ? red: pos == 1 ? green : blue ) 
posprice := iff(low <= posprice - input_takeprofit and posprice > 0, 0 ,  nz(posprice, 0))
posprice := iff(high >= posprice + input_stoploss and posprice > 0, 0 ,  nz(posprice, 0))
````
