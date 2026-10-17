# Buy/Sell on the levels

- url: https://www.tradingview.com/script/DPx9VRI9-Buy-Sell-on-the-levels/
- type: strategy
- pine_id: PUB;bb35facc7a4a446080426ed062ee0a0b
- version: 1.0

## Description

This script is generally 

My describe is:

There are a lot of levels we would like to buy some crypto.
When the price has crossed the level-line - we buy, but only if we have the permission in array(2)
When we have bought the crypto - we lose the permission for buy for now(till we will sell it on the next higher level)
When we sell some crypto(on the buying level + 1) we have the permission again.

There also are 2 protect indicators. We can buy if these indicators both green only(super trend and PIVOT )
Jun 12
Release Notes: Hello there,

Uncomment this section before use for real trade:
if array.get(price_to_sellBue, i) >= open and array.get(price_to_sellBue, i) <= close// and
//direction < 0 and permission_for_buy != 0

Here is my script.

In general - this is incredible simple script to use and understand.
First of all You can see this script working with only long orders, it means we going to get money if crypto grows only. Short orders we need to close the position on time.
In this script we buy crypto and sell with step 1% upper.

You can simply change the step by changing the price arrays.
Please note, if You want to see where the levels of this script is You Have to copy the next my indicator called LEVEL 1%

In general - if the price has across the price-level we buy some crypto and loose permission for buying for this level till we sell some crypto. There is ''count_of_orders" array field with value 2. When we bought some crypto the value turns to 0. 0 means not allowed to by on this level!!! The script buy if the bar is green only(last tick).

The script check every level(those we can see in "price_to_sellBue" array).
If the price across one of them - full script runs. After buying(if it possible) we check is there any crypto for sell on the level.
We check all levels below actual level( of actual level - ''i'' than we check all levels from 0 to i-1).
If there is any order that has value 0 in count of orders and index <= i-1 - we count it to var SELL amount and in the end of loop sell all of it.
Pay attention - it sells only if price across the level with red bar AND HAS ORDERS TO SELL WHICH WAS BOUGHT BELOW!!!

In Strategy tester it shows not-profitables orders sometimes, because if You have old Long position - it sells it first. First in - first out.
If the price goes down for a long time and You sell after 5 buys You sell the first of it with the highest value.

There is 2 protection from horrible buying in this strategy. The first one - Supertrend. If the supertrend is red - there is no permission for buy.
The second one - something between PIVOT and supertrend but with switcher.
If the price across last minimum - switcher is red - no permission for buy and the actual price becomes last minimum . The last maximum calculated for last 100 bars.
When the price across last maximum - switcher is green, we can buy. The last minimum calculation for last 100 bars, last maximum is actual price.

This two protections will save You from buying if price get crash down.

Enjoy my script.

Should You need the code or explanation, You have any ideas how to improve this crypt, contact me.

Vladyslav.
Jun 12
Release Notes: Here has been uncommented the protection for buy in case of price get down.
5 hours ago
Release Notes: Changed rages up to actual price to make it work

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © svatvlad1993

//@version=5

strategy("test for more freq","BUY/SELL test for more freq",pyramiding=100 , overlay=true, currency=currency.USDT, commission_type=strategy.commission.percent,
     commission_value=0.05,initial_capital=5000, margin_long=10, margin_short=10, max_lines_count = 500, max_labels_count = 500, max_bars_back = 5000)//, default_qty_type=strategy.percent_of_equity, default_qty_value=4)


// tail-resistance for buy

var last_min = low[0]
var last_max = high[0]

var permission_for_buy = 0

lowest0 = ta.lowest(low,100)
highest0 = ta.highest(high,100)

if close > last_max
    if lowest0 != 0
        last_min := lowest0
    else
        last_min := close - (close * 0.02)
    last_max := high
    permission_for_buy := 1
    
if close < last_min
    last_min := low
    if highest0 != 0
        last_max := highest0
    else
        last_max := close + (close * 0.02)
    permission_for_buy := 0



plot_diaps1 = plot(permission_for_buy != 0? na : last_max, title='Max',color=color.new(#ff0000, 95),style=plot.style_cross,trackprice=true )
plot_diaps2 = plot(permission_for_buy != 0? na : last_min, title='Min',color=color.new(#ff0000, 95),style=plot.style_cross,trackprice=true )

plot_diaps3 = plot(permission_for_buy != 1? na : last_max, title='max',color=color.new(color.green, 95),style=plot.style_cross,trackprice=true )
plot_diaps4 = plot(permission_for_buy != 1? na : last_min, title='min',color=color.new(color.green, 95),style=plot.style_cross,trackprice=true )

fill(plot_diaps1, plot_diaps2,color=color.new(#ff0000, 95))
fill(plot_diaps3, plot_diaps4,color=color.new(color.green, 95))


//Supertrend

atrPeriod = input(10, "ATR Length")
factor = input.float(2.5, "Factor", step = 0.01)

[supertrend, direction] = ta.supertrend(factor, atrPeriod)

bodyMiddle = plot((open + close) / 2, display=display.none)
upTrend = plot(direction < 0 ? supertrend : na, "Up Trend", color = color.teal, style=plot.style_linebr)
downTrend = plot(direction < 0? na : supertrend, "Down Trend", color = color.maroon, style=plot.style_linebr)

fill(bodyMiddle, upTrend, color.new(color.teal, 75), fillgaps=false)
fill(bodyMiddle, downTrend, color.new(color.maroon, 75), fillgaps=false)


// levels sell/buy

var float[] price_to_sellBue = array.from(1.01, 1.02, 1.03, 1.04, 1.05, 1.06, 1.071, 1.082, 1.093, 1.104, 1.115, 1.126, 1.137, 1.148, 1.159, 1.171, 1.183, 1.195, 1.207, 1.219, 1.231, 1.243, 1.255, 1.268, 1.281, 1.294, 1.307, 1.32, 1.333, 1.346, 1.359, 1.373, 1.387, 1.401, 1.415, 1.429, 1.443, 1.457, 1.472, 1.487, 1.502, 1.517, 1.532, 1.547, 1.562, 1.578, 1.594, 1.61, 1.626, 1.642, 1.658, 1.675, 1.692, 1.709, 1.726, 1.743, 1.76, 1.778, 1.796, 1.814, 1.832, 1.85, 1.869, 1.888, 1.907, 1.926, 1.945, 1.964, 1.984, 2.004, 2.024, 2.044, 2.064, 2.085, 2.106, 2.127, 2.148, 2.169, 2.191, 2.213, 2.235, 2.257, 2.28, 2.303, 2.326, 2.349, 2.372, 2.396, 2.42, 2.444, 2.468, 2.493, 2.518, 2.543, 2.568, 2.594, 2.62, 2.646, 2.672, 2.699, 2.726, 2.753, 2.781, 2.809, 2.837, 2.865, 2.894, 2.923, 2.952, 2.982, 3.012, 3.042, 3.072, 3.103, 3.134, 3.165, 3.197, 3.229, 3.261, 3.294, 3.327, 3.36, 3.394, 3.428, 3.462, 3.497, 3.532, 3.567, 3.603, 3.639, 3.675, 3.712, 3.749, 3.786, 3.824, 3.862, 3.901, 3.94, 3.979, 4.019)
var float[] count_of_orders = array.from(2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0 ,2.0)


//loops for sale/buy


for i = 0 to 139
    if array.get(price_to_sellBue, i) >= open[0] and array.get(price_to_sellBue, i) <= close[0] and
     direction[0] < 0 and permission_for_buy != 0
        if array.get(count_of_orders, i) > 0
            strategy.order(str.tostring(i), strategy.long, 15)
            g = array.get(count_of_orders, i)
            array.set(count_of_orders, i, g - 2)
            break





var SELL_amount = 0
var strategy_short = 0
for i = 0 to 139
    if array.get(price_to_sellBue, i) <= open[0] and array.get(price_to_sellBue, i) >= close[0]
        for j = 0 to i-1 
            if array.get(count_of_orders, j) != 2
                strategy_short := strategy_short + 1
                array.set(count_of_orders, j, 2)
                SELL_amount := SELL_amount + 15
        strategy.order(str.tostring(strategy_short),strategy.short, SELL_amount)
        SELL_amount := 0
        break


// добавить SMA и продавать при низходящем тренде


plot(strategy.equity)
````
