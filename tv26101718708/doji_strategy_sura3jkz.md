# Doji Strategy

- url: https://www.tradingview.com/script/SurA3jkz-Doji-Strategy/
- type: indicator
- pine_id: PUB;NgzZXb0NqKM4fteQEPPTUtHTsTIIj39p
- version: 1.0

## Description

This is a candlestick where the open and close are the same. 
 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=3
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 28/01/2019
//   This is a candlestick where the open and close are the same. 
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title = "Doji Strategy", overlay = true)
input_takeprofit = input(10, title="Take Profit pip", step=0.01)
input_stoploss = input(10, title="Stop Loss pip", step=0.01)
input_minsizebody = input(0.5, title="Min. Size Body pip", step=0.01)
barcolor(abs(close - open) <= input_minsizebody ? open == close ? yellow : na : na)
possell = 0.0
posbuy = 0.0
pospricebuy = 0.0
pospricesell = 0.0
barcolornow = blue
pospricesell := close< close[2] ? abs(close - open) <= input_minsizebody ? open == close ? close : nz(pospricesell[1], 0) : nz(pospricesell[1], 0) : nz(pospricesell[1], 0) 
possell := iff(pospricesell > 0 , -1, 0)
barcolornow := possell == -1 ? red: posbuy == 1 ? green : blue 
pospricesell := iff(low <= pospricesell - input_takeprofit and pospricesell > 0, 0 ,  nz(pospricesell, 0))
pospricesell := iff(high >= pospricesell + input_stoploss and pospricesell > 0, 0 ,  nz(pospricesell, 0))
pospricebuy := close > close[2] ? abs(close - open) <= input_minsizebody ? open == close ? close : nz(pospricebuy[1], 0) : nz(pospricebuy[1], 0) : nz(pospricebuy[1], 0) 
posbuy := iff(pospricebuy > 0 , 1, 0)
barcolornow := posbuy == 1 ? green: barcolornow
pospricebuy := iff(high >= pospricebuy + input_takeprofit and pospricebuy > 0, 0 ,  nz(pospricebuy, 0))
pospricebuy := iff(low <= pospricebuy - input_stoploss and pospricebuy > 0, 0 ,  nz(pospricebuy, 0))
barcolor(barcolornow)
````
