# ST_greed_spot_example

- url: https://www.tradingview.com/script/i0HNfq2Z-st-greed-spot-example/
- type: strategy
- pine_id: PUB;d38c058c844b4634b85ddf13c1487e8e
- version: 2.0

## Description

A simple grid long strategy. The first entry into the transaction is carried out according to the "double bottom" pattern, then when the average entry price decreases by a certain percentage, the position is completed. Dobor is always carried out for the same amount of funds. Take profit with an increase in the average entry price for a given volume

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alferow

//@version=5
strategy("ST_gree_spot_example", overlay=true, initial_capital = 1000, pyramiding = 20, commission_value = 0.06, default_qty_type = strategy.percent_of_equity, default_qty_value = 100)


start = input.time(timestamp("01 Jan 2001 00:00"), title = 'Start date')
finish = input.time(timestamp("01 Jan 2101 00:00"), title = 'Finish date')


trig = time > start and time < finish ? true : false



l = ta.lowest(low, input(50, title = 'Period for low'))
hl = l[6]
// plot(hl, color = color.red)

n = input(10, title = 'Depth grid')

var money = 0.0
var price1 = 0.0

cond = low < hl and close > hl

if strategy.position_size == 0 and cond and strategy.equity > 0
    price1 := close[1]
    money := strategy.equity/n

vol1 = money/price1



var i = 0
if strategy.position_size > strategy.position_size[1]
    i := i + 1
if strategy.position_size == 0
    i := 0



    
k = input(3.0, title = 'Drawdown %')

pricen = strategy.position_avg_price * (1 - (k/100))

voln = money/pricen

t = input(3.0, title = 'Take %')

tp = strategy.position_avg_price * (1 + (t/100))

plot(strategy.position_avg_price, color = color.white)
plot(tp, color = color.green)
plot(pricen, color = color.red, offset = 3)

if cond and strategy.position_size == 0 and strategy.equity > 0 and trig
    strategy.entry('buy', strategy.long, qty = vol1, limit = price1)

if strategy.position_size != 0 and strategy.equity > 0 and trig and i <= n - 1
    strategy.order('buy', strategy.long, qty = voln, limit = pricen)

if trig
    strategy.exit('buy', limit = tp)
````
