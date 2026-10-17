# ATR Ticks with Multiplier

- url: https://www.tradingview.com/script/enpH7ddj-ATR-Ticks-with-Multiplier/
- type: indicator
- pine_id: PUB;29bbd206e75f48e5bc3b3d62bec5072c
- version: 1.0

## Description

This is a simple label "indicator" that allows you to easily view the current ATR(x) and get a multiplier of the ATR for stop loss and take profit target. This allows you to quickly adjust your brackets based on high or low volatility conditions. 

For example, if the ATR(5) is 10 points on the NQ, your multiplier stop loss is 1.25, your multiplier for take profit is 2.5 (2R), the ticks show will be 50 for the stop loss and 100 for the take profit.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © marketsurvivalist

//@version=6
indicator("ATR Ticks with Multiplier", overlay = true)
atr_length = input.int(5, "ATR Length")
multiplier_profit = input.float(1.25, "Multiplier Profit")
multiplier_loss = input.float(1.25, "Multiplier Loss")

atr_val = ta.atr(atr_length)
tick_range_profit = math.floor((atr_val / syminfo.mintick) * multiplier_profit) 
tick_range_loss = math.floor((atr_val / syminfo.mintick) * multiplier_loss) 

float upper = na
float lower = na

plotchar(atr_val, "Points", char="", location=location.bottom, color = color.black)
plotchar(tick_range_profit, "Ticks Profit", char="", location=location.bottom, color = color.green)
plotchar(tick_range_loss, "Ticks Loss", char="", location=location.bottom, color = color.red)
````
