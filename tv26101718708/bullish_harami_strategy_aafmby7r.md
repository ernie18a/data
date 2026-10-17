# Bullish Harami Strategy

- url: https://www.tradingview.com/script/AAfmby7R-Bullish-Harami-Strategy/
- type: indicator
- pine_id: PUB;uLyZlcW1rtzyERscMFYyX5VQmvPnS814
- version: 1.0

## Description

This is a bullish reversal pattern formed by two candlesticks in which a small 
    real body is contained within the prior session's unusually large real body.
    Usually the second real body is the opposite color of the first real body. 
    The Harami pattern is the reverse of the Engulfing pattern. 

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=3
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 17/01/2019
//    This is a bullish reversal pattern formed by two candlesticks in which a small 
//    real body is contained within the prior session's unusually large real body.
//    Usually the second real body is the opposite color of the first real body. 
//    The Harami pattern is the reverse of the Engulfing pattern. 
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title = "Bullish Harami Strategy", overlay = true)
input_takeprofit = input(40, title="Take Profit pip")
input_stoploss = input(20, title="Stop Loss pip")
input_minsizebody = input(1, title="Min. Size Body pip")
barcolor(abs(close - open) >= input_minsizebody ? open[1] > close[1] ? close > open ? close <= open[1] ? close[1] <= open ? close - open < open[1] - close[1] ? yellow :na :na : na : na : na : na)
posprice = 0.0
posprice := abs(close - open) >= input_minsizebody? open[1] > close[1] ? close > open ? close <= open[1] ? close[1] <= open ? close - open < open[1] - close[1] ? close :nz(posprice[1], 0) :nz(posprice[1], 0) : nz(posprice[1], 0) : nz(posprice[1], 0) : nz(posprice[1], 0): nz(posprice[1], 0)
pos = 0.0
pos := iff(posprice > 0, 1, 0)
barcolor(pos == -1 ? red: pos == 1 ? green : blue ) 
posprice := iff(low <= posprice - input_takeprofit and posprice > 0, 0 ,  nz(posprice, 0))
posprice := iff(high >= posprice + input_stoploss and posprice > 0, 0 ,  nz(posprice, 0))
````
