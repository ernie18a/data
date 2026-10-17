# Bearish Harami

- url: https://www.tradingview.com/script/WSrY4D9c-Bearish-Harami/
- type: indicator
- pine_id: PUB;CAwQLNfNJScY5h9pzgMVtYQZPvdYyYME
- version: 1.0

## Description

Copyright by HPotter  15/01/2019
    This is a bearish reversal pattern formed by two candlesticks in which a short 
    real body is contained within the prior session's long real body. Usually the 
    second real body is the opposite color of the first real body. The Harami pattern 
    is the reverse of the Engulfing pattern. 

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=3
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 15/01/2019
//    This is a bearish reversal pattern formed by two candlesticks in which a short 
//    real body is contained within the prior session's long real body. Usually the 
//    second real body is the opposite color of the first real body. The Harami pattern 
//    is the reverse of the Engulfing pattern. 
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title = "Bearish Harami", overlay = true)
input_takeprofit = input(20, title="Take Profit pip")
input_stoploss = input(10, title="Stop Loss pip")
input_minsizebody = input(3, title="Min. Size Body pip")
barcolor(abs(close- open) >= input_minsizebody ? close[1] > open[1] ? open > close ? open <= close[1] ? open[1] <= close ? open - close < close[1] - open[1] ? yellow :na :na : na : na : na : na)
posprice = 0.0
posprice := abs( close - open) >= input_minsizebody? close[1] > open[1] ? open > close ? open <= close[1] ? open[1] <= close ? open - close < close[1] - open[1] ? close :nz(posprice[1], 0) :nz(posprice[1], 0) : nz(posprice[1], 0) : nz(posprice[1], 0) : nz(posprice[1], 0): nz(posprice[1], 0)
pos = 0.0
pos := iff(posprice > 0, -1, 0)
barcolor(pos == -1 ? red: pos == 1 ? green : blue ) 
posprice := iff(low <= posprice - input_takeprofit and posprice > 0, 0 ,  nz(posprice, 0))
posprice := iff(high >= posprice + input_stoploss and posprice > 0, 0 ,  nz(posprice, 0))
````
