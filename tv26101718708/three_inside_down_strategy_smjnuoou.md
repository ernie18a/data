# Three Inside Down Strategy

- url: https://www.tradingview.com/script/SmjnUoou-Three-Inside-Down-Strategy/
- type: indicator
- pine_id: PUB;Z9T60hrOg28WUfulDlACvGd3HDq7Gr1Q
- version: 1.0

## Description

This is a three candlestick bearish reversal pattern consisting of a bearish 
    harami pattern formed by the first 2 candlesticks then followed by down 
    candlestick with a lower close than the prior candlestick.
 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=3
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 05/02/2019
//    This is a three candlestick bearish reversal pattern consisting of a bearish 
//    harami pattern formed by the first 2 candlesticks then followed by down 
//    candlestick with a lower close than the prior candlestick.
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title = "Three Inside Down Strategy", overlay = true)
input_takeprofit = input(40, title="Take Profit pip", step=0.01)
input_stoploss = input(20, title="Stop Loss pip", step=0.01)
barcolor(close[2] > open[2] ? open[1] > close[1] ? open[1] <= close[2] ? open[2] <= close[1] ? open[1] - close[1]< close[2] - open[2] ? close < open ? close < close[1] ? open < open[1] ? close < open[2] ? yellow :na :na : na : na : na:na : na : na : na)
posprice = 0.0
posprice :=  close[2] > open[2] ? open[1] > close[1] ? open[1] <= close[2] ? open[2] <= close[1] ? open[1] - close[1]< close[2] - open[2] ? close < open ? close < close[1] ? open < open[1] ? close < open[2] ? close :nz(posprice[1], 0) :nz(posprice[1], 0) : nz(posprice[1], 0) : nz(posprice[1], 0) :nz(posprice[1], 0):nz(posprice[1], 0):nz(posprice[1], 0):nz(posprice[1], 0):nz(posprice[1], 0) 
pos = 0.0
pos := iff(posprice > 0, 1, 0)
barcolor(pos == -1 ? red: pos == 1 ? green : blue ) 
posprice := iff(high >= posprice + input_takeprofit and posprice > 0, 0 ,  nz(posprice, 0))
posprice := iff(low <= posprice - input_stoploss and posprice > 0, 0 ,  nz(posprice, 0))
````
