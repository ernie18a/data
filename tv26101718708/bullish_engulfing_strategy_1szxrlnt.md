# Bullish Engulfing Strategy

- url: https://www.tradingview.com/script/1szXRlNt-Bullish-Engulfing-Strategy/
- type: indicator
- pine_id: PUB;OEgOJQPJcLuHWQ3vNC6v8UEIMArrTMV3
- version: 1.0

## Description

This is a bullish reversal pattern formed by two candlesticks. Following a downtrend, 
    the first candlestick is a down candlestick which is followed by an up candlestick 
    which has a long real body that engulfs or contains the real body of the prior bar. 
    The Engulfing pattern is the reverse of the Harami pattern. 

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=3
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 05/11/2018
//
//    This is a bullish reversal pattern formed by two candlesticks. Following a downtrend, 
//    the first candlestick is a down candlestick which is followed by an up candlestick 
//    which has a long real body that engulfs or contains the real body of the prior bar. 
//    The Engulfing pattern is the reverse of the Harami pattern. 
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////

study(title = "Bullish Engulfing Strategy", overlay = true)
input_takeprofit = input(40, title="Take Profit pip")
input_stoploss = input(20, title="Stop Loss pip")
input_minsizebody = input(2, title="Min. Size Body pip")
barcolor(open[1] > close[1] ? close > open ? close >= open[1] ? close[1] >= open ? close - open > open[1] - close[1] ? yellow :na :na : na : na : na)
posprice = 0.0
posprice := abs( close[1] - open[1]) >= input_minsizebody? open[1] > close[1] ? close > open ? close >= open[1] ? close[1] >= open ? close - open > open[1] - close[1] ? close :nz(posprice[1], 0) :nz(posprice[1], 0) : nz(posprice[1], 0) : nz(posprice[1], 0) : nz(posprice[1], 0): nz(posprice[1], 0)
pos = 0.0
pos := iff(posprice > 0, 1, 0)
barcolor(pos == -1 ? red: pos == 1 ? green : blue ) 
posprice := iff(low <= posprice - input_takeprofit and posprice > 0, 0 ,  nz(posprice, 0))
posprice := iff(high >= posprice + input_stoploss and posprice > 0, 0 ,  nz(posprice, 0))
````
