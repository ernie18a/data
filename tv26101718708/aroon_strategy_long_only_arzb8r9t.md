# Aroon Strategy long only

- url: https://www.tradingview.com/script/aRzb8R9t-Aroon-Strategy-long-only/
- type: strategy
- pine_id: PUB;d3b40a78ef7b46cea2567c2389dcd5bd
- version: 1.0

## Description

This is a simple long only strategy made of Aroon and Least Square moving average.

The rules are simple:

Long entry = crossover of upper part with the lower part from aroon and close of the candle is above the moving average

Long exit = crossunder of upper part with the lower part from aroon and close of the candle is below the moving average


IF you have any questions let me know !

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © exlux99

//@version=4

strategy(title = "Aroon Strategy long only", overlay = true,  pyramiding=1,initial_capital = 100, default_qty_type= strategy.percent_of_equity, default_qty_value = 100, calc_on_order_fills=false, slippage=0,commission_type=strategy.commission.percent,commission_value=0.1)

//Time
fromDay = input(defval = 1, title = "From Day", minval = 1, maxval = 31)
fromMonth = input(defval = 1, title = "From Month", minval = 1, maxval = 12)
fromYear = input(defval = 2010, title = "From Year", minval = 1970)
 //monday and session 
// To Date Inputs
toDay = input(defval = 31, title = "To Day", minval = 1, maxval = 31)
toMonth = input(defval = 12, title = "To Month", minval = 1, maxval = 12)
toYear = input(defval = 2021, title = "To Year", minval = 1970)

startDate = timestamp(fromYear, fromMonth, fromDay, 00, 00)
finishDate = timestamp(toYear, toMonth, toDay, 00, 00)
time_cond = time >= startDate and time <= finishDate

//INPUTS

length = input(15, minval=1, title="Aroon Legnth")
upper = 100 * (highestbars(high, length+1) + length)/length
lower = 100 * (lowestbars(low, length+1) + length)/length

lengthx = input(title="Length LSMA", type=input.integer, defval=20)
offset = 0//input(title="Offset", type=input.integer, defval=0)
src = input(close, title="Source")
lsma = linreg(src, lengthx, offset)


long = crossover(upper,lower) and close > lsma
longexit = crossunder(upper,lower) and close < lsma

if(time_cond)
    strategy.entry("long",1,when=long)
    strategy.close("long",when=longexit)
````
