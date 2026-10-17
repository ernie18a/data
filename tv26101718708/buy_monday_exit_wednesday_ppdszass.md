# Buy Monday, Exit Wednesday

- url: https://www.tradingview.com/script/PpDSzaSs-Buy-Monday-Exit-Wednesday/
- type: strategy
- pine_id: PUB;64190325a0eb4d87a3116b9206bb0e4c
- version: 1.0

## Description

Strategy to go long at end of Monday before market closes and exit before Wednesday close, or at stop loss or take profit percentages

[list]
[*] This runs strategy on entering by weekday name and also by session time.
[*] Implemented are also Take Profit and Stop Loss to exit position using custom inputs.
[*] Added stop loss and take profit plot lines
[/list]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © processingclouds

// @description Strategy to go long at end of Monday and exit by Tuesday close, or at stop loss or take profit percentages  

//@version=5
strategy("Buy Monday, Exit Wednesday", "Mon-Wed Swings",overlay=true)

//  ----- Inputs: stoploss %, takeProfit %
stopLossPercentage = input.float(defval=4.0, title='StopLoss %', minval=0.1, step=0.2) / 100
takeProfit = input.float(defval=3.0, title='Take Profit %', minval=0.3, step=0.2) / 100

//  ----- Exit and Entry Conditions - Check current day and session time
isLong = dayofweek == dayofweek.monday  and not na(time(timeframe.period, "1400-1601"))
isExit = dayofweek == dayofweek.wednesday and not na(time(timeframe.period, "1400-1601"))

//  ----- Calculate Stoploss and Take Profit values
SL = strategy.position_avg_price * (1 - stopLossPercentage)
TP = strategy.position_avg_price * (1 + takeProfit)

//  ----- Strategy Enter, and exit when conditions are met
strategy.entry("Enter Long", strategy.long, when=isLong)
if strategy.position_size > 0 
    strategy.close("Enter Long", isExit)
    strategy.exit(id="Exit", stop=SL, limit=TP)

//  ----- Plot Stoploss and TakeProfit lines
plot(strategy.position_size > 0 ? SL : na, style=plot.style_linebr, color=color.red, linewidth=2, title="StopLoss")
plot(strategy.position_size > 0 ? TP : na, style=plot.style_linebr, color=color.green, linewidth=2, title="TakeProfit")
````
