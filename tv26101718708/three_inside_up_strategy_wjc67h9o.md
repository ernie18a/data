# Three Inside Up Strategy

- url: https://www.tradingview.com/script/WJC67h9o-Three-Inside-Up-Strategy/
- type: indicator
- pine_id: PUB;4FT1KQ6AvHwi6bQSGoHHaoYuuxEqYYrp
- version: 1.0

## Description

This is a three candlestick bullish reversal pattern consisting of a 
    bullish harami pattern formed by the first 2 candlesticks then followed 
    by up candlestick with a higher close than the prior candlestick.
 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=3
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 08/02/2019
//    This is a three candlestick bullish reversal pattern consisting of a 
//    bullish harami pattern formed by the first 2 candlesticks then followed 
//    by up candlestick with a higher close than the prior candlestick.
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title = "Three Inside Up Strategy", overlay = true)
input_takeprofit = input(20, title="Take Profit pip", step=0.01)
input_stoploss = input(20, title="Stop Loss pip", step=0.01)
barcolor(open[2] > close[2] ? close[1] > open[1] ? close[1] <= open[2] ? close[2] <= open[1] ? close[1] - open[1] < open[2] - close[2] ? close > open ? close > close[1] ? open > open[1] ? close > open[2] ? yellow :na :na : na : na : na:na : na : na : na)
posprice = 0.0
posprice := open[2] > close[2] ? close[1] > open[1] ? close[1] <= open[2] ? close[2] <= open[1] ? close[1] - open[1] < open[2] - close[2] ? close > open ? close > close[1] ? open > open[1] ? close > open[2]  ? close :nz(posprice[1], 0) :nz(posprice[1], 0) : nz(posprice[1], 0) : nz(posprice[1], 0) :nz(posprice[1], 0):nz(posprice[1], 0):nz(posprice[1], 0):nz(posprice[1], 0):nz(posprice[1], 0) 
pos = 0.0
pos := iff(posprice > 0, -1, 0)
barcolor(pos == -1 ? red: pos == 1 ? green : blue ) 
posprice := iff(low <= posprice - input_takeprofit and posprice > 0, 0 ,  nz(posprice, 0))
posprice := iff(high >= posprice + input_stoploss and posprice > 0, 0 ,  nz(posprice, 0))
````
