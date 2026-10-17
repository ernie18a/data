# (IK) Grid Script

- url: https://www.tradingview.com/script/IIchZZ2m-IK-Grid-Script/
- type: strategy
- pine_id: PUB;F2qe2SGbqsTeay9JxkLa098TSVcnSpZt
- version: 4.0

## Description

This is my take on a grid trading strategy. From Investopedia:

 "Grid trading is most commonly associated with the foreign exchange market. Overall the technique seeks to capitalize on normal price volatility in an asset by placing buy and sell orders at certain regular intervals above and below a predefined base price."

This strategy is best used on sideways markets, without a definitive up or down major trend. Because it doesn't rely on huge vertical movement, this strategy is great for small timeframes. It only goes long. I've set initial_capital to 100 USD. default_qty_value should be your initial capital divided by your amount of grid lines. I'm also assuming a 0.1% commission per trade.

Here's the basic algorithm:
   - Create a grid based on an upper-bound (strong resistance) and a lower-bound (strong support)
   - Grid lines are spaced evenly between these two bounds. (I recommend anywhere between 5-10 grid lines, but this script lets you use up to 15. More gridlines = more/smaller trades)
   - Identify nearest gridline above and below current price (ignoring the very closest grid line) 
   - If price crosses under a near gridline, buy and recalculate near gridlines
   - If price crosses over a near gridline, sell and recalculate near gridlines
   - Trades are entered and exited based on a FIFO system. So if price falls 3 grid lines (buy-1, buy-2, buy-3), and subsequently crosses above one grid line, only the first trade will exit (sell-1). If it falls again, it will enter a new trade (buy-4), and if it crosses above again it will sell the original second trade (sell-2). The amount of trades you can be in at once are based on the amount of grid lines you have. 

[b]This strategy has no built-in stop loss! [/b] This is not a 'set-it-and-forget-it" script. Make sure that price remains within the bounds of your grid. If prices exits above the grid, you're in the money, but you won't be making any more trades. If price exits below the grid, you're 100% staked in whatever you happen to be trading. 

This script is more complicated than my last one, but should be more user friendly. Make sure to correctly set your lower-bound and upper-bound based on strong support and resistance (the default values for these are probably going to be meaningless). If you change your "Grid Quantity" (amount of grid lines) make sure to also change your 'Order Size' property under settings for proper test results (or default_qty_value in the strategy() declaration).

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tapRoot_coding - Ian Kuzmik

//@version=4
strategy("(IK) Grid Script", overlay=true, pyramiding=14, close_entries_rule="ANY", default_qty_type=strategy.cash, initial_capital=100.0, currency="USD", commission_type=strategy.commission.percent, commission_value=0.1)

// == INPUT == 
i_autoBounds    = input(group="Grid Bounds", title="Use Auto Bounds?", defval=false, type=input.bool)                             // calculate upper and lower bound of the grid automatically? This will theorhetically be less profitable, but will certainly require less attention
i_boundSrc      = input(group="Grid Bounds", title="(Auto) Bound Source", defval="Hi & Low", options=["Hi & Low", "Average"])     // should bounds of the auto grid be calculated from recent High & Low, or from a Simple Moving Average
i_boundLookback = input(group="Grid Bounds", title="(Auto) Bound Lookback", defval=250, type=input.integer, maxval=500, minval=0) // when calculating auto grid bounds, how far back should we look for a High & Low, or what should the length be of our sma 
i_boundDev      = input(group="Grid Bounds", title="(Auto) Bound Deviation", defval=0.10, type=input.float, maxval=1, minval=-1)  // if sourcing auto bounds from High & Low, this percentage will (positive) widen or (negative) narrow the bound limits. If sourcing from Average, this is the deviation (up and down) from the sma, and CANNOT be negative. 
i_upperBound    = input(group="Grid Bounds", title="(Manual) Upper Boundry", defval=0.285, type=input.float)                      // for manual grid bounds only. The upperbound price of your grid
i_lowerBound    = input(group="Grid Bounds", title="(Manual) Lower Boundry", defval=0.225, type=input.float)                      // for manual grid bounds only. The lowerbound price of your grid. 
i_gridQty       = input(group="Grid Lines",  title="Grid Line Quantity", defval=8, maxval=15, minval=3, type=input.integer)       // how many grid lines are in your grid

// == FUNCTIONS ==
// for auto grid only. return the upperbound if _up == true, or the lowerbound if _up == false
f_getGridBounds(_bs, _bl, _bd, _up) => 
    if _bs == "Hi & Low" 
        _up ? highest(close, _bl) * (1 + _bd) : lowest(close, _bl)  * (1 - _bd)
    else
        avg = sma(close, _bl)
        _up ? avg * (1 + _bd) : avg * (1 - _bd)

// using the lowerbound, grid width, and grid line quantity, build an array of prices (grid lines) from the bottom up
f_buildGrid(_lb, _gw, _gq) =>
    gridArr = array.new_float(0)
    for i=0 to _gq-1
        array.push(gridArr, _lb+(_gw*i))
    gridArr 

// return an array that contains the closest grid lines above and below current price (not counting the line price is currently on). This is solely for plotting purposes
f_getNearGridLines(_gridArr, _price) =>
    arr = array.new_int(3)
    for i = 0 to array.size(_gridArr)-1
        if array.get(_gridArr, i) > _price
            array.set(arr, 0, i == array.size(_gridArr)-1 ? i : i+1)
            array.set(arr, 1, i == 0 ? i : i-1)
            break
    arr
	
// == VARIABLES ==
var upperBound      = i_autoBounds ? f_getGridBounds(i_boundSrc, i_boundLookback, i_boundDev, true) : i_upperBound  // upperbound of our grid
var lowerBound      = i_autoBounds ? f_getGridBounds(i_boundSrc, i_boundLookback, i_boundDev, false) : i_lowerBound // lowerbound of our grid
var gridWidth       = (upperBound - lowerBound)/(i_gridQty-1)                                                       // space between lines in our grid
var gridLineArr     = f_buildGrid(lowerBound, gridWidth, i_gridQty)                                                 // an array of prices that correspond to our grid lines
var orderArr        = array.new_bool(i_gridQty, false)                                                              // a boolean array that indicates if there is an open order corresponding to each grid line

var closeLineArr    = f_getNearGridLines(gridLineArr, close)                                                        // for plotting purposes - an array of 2 indices that correspond to grid lines near price
var nearTopGridLine = array.get(closeLineArr, 0)                                                                    // for plotting purposes - the index (in our grid line array) of the closest grid line above current price                        
var nearBotGridLine = array.get(closeLineArr, 1)                                                                    // for plotting purposes - the index (in our grid line array) of the closest grid line below current price 

// == LOGIC ==
// ENTRY & EXIT
for i = 0 to (array.size(gridLineArr) - 1)
    if close < array.get(gridLineArr, i) and not array.get(orderArr, i) and i < (array.size(gridLineArr) - 1)
        buyId = i
        array.set(orderArr, buyId, true)
        strategy.entry(id=tostring(buyId), long=true, qty=(strategy.initial_capital/(i_gridQty-1))/close, comment="#"+tostring(buyId))
    if close > array.get(gridLineArr, i) and i != 0 
        if array.get(orderArr, i-1)
            sellId = i-1
            array.set(orderArr, sellId, false)
            strategy.close(id=tostring(sellId), comment="#"+tostring(sellId))
        
// MAINTAIN GRID 
// update auto grid (if active)
if i_autoBounds
    upperBound  := f_getGridBounds(i_boundSrc, i_boundLookback, i_boundDev, true)
    lowerBound  := f_getGridBounds(i_boundSrc, i_boundLookback, i_boundDev, false)
    gridWidth   := (upperBound - lowerBound)/(i_gridQty-1)
    gridLineArr := f_buildGrid(lowerBound, gridWidth, i_gridQty)

// update near grid lines (for plotting purposes)
closeLineArr    := f_getNearGridLines(gridLineArr, close)
nearTopGridLine := array.get(closeLineArr, 0)
nearBotGridLine := array.get(closeLineArr, 1)

// plot grid lines
plot(array.size(gridLineArr) > 0  ? array.get(gridLineArr,0)  : na, color=bar_index % 2 == 1 ? color.rgb(255,255,0,50) : #00000000)
plot(array.size(gridLineArr) > 1  ? array.get(gridLineArr,1)  : na, color=bar_index % 2 == 1 ? color.rgb(255,255,0,50) : #00000000)
plot(array.size(gridLineArr) > 2  ? array.get(gridLineArr,2)  : na, color=bar_index % 2 == 1 ? color.rgb(255,255,0,50) : #00000000)
plot(array.size(gridLineArr) > 3  ? array.get(gridLineArr,3)  : na, color=bar_index % 2 == 1 ? color.rgb(255,255,0,50) : #00000000)
plot(array.size(gridLineArr) > 4  ? array.get(gridLineArr,4)  : na, color=bar_index % 2 == 1 ? color.rgb(255,255,0,50) : #00000000)
plot(array.size(gridLineArr) > 5  ? array.get(gridLineArr,5)  : na, color=bar_index % 2 == 1 ? color.rgb(255,255,0,50) : #00000000)
plot(array.size(gridLineArr) > 6  ? array.get(gridLineArr,6)  : na, color=bar_index % 2 == 1 ? color.rgb(255,255,0,50) : #00000000)
plot(array.size(gridLineArr) > 7  ? array.get(gridLineArr,7)  : na, color=bar_index % 2 == 1 ? color.rgb(255,255,0,50) : #00000000)
plot(array.size(gridLineArr) > 8  ? array.get(gridLineArr,8)  : na, color=bar_index % 2 == 1 ? color.rgb(255,255,0,50) : #00000000)
plot(array.size(gridLineArr) > 9  ? array.get(gridLineArr,9)  : na, color=bar_index % 2 == 1 ? color.rgb(255,255,0,50) : #00000000)
plot(array.size(gridLineArr) > 10 ? array.get(gridLineArr,10) : na, color=bar_index % 2 == 1 ? color.rgb(255,255,0,50) : #00000000)
plot(array.size(gridLineArr) > 11 ? array.get(gridLineArr,11) : na, color=bar_index % 2 == 1 ? color.rgb(255,255,0,50) : #00000000)
plot(array.size(gridLineArr) > 12 ? array.get(gridLineArr,12) : na, color=bar_index % 2 == 1 ? color.rgb(255,255,0,50) : #00000000)
plot(array.size(gridLineArr) > 13 ? array.get(gridLineArr,13) : na, color=bar_index % 2 == 1 ? color.rgb(255,255,0,50) : #00000000)
plot(array.size(gridLineArr) > 14 ? array.get(gridLineArr,14) : na, color=bar_index % 2 == 1 ? color.rgb(255,255,0,50) : #00000000)

// plot near grid lines
plot(array.get(gridLineArr, nearTopGridLine), color=color.rgb(255,0,255,20), style=plot.style_stepline, linewidth=2)
plot(array.get(gridLineArr, nearBotGridLine), color=color.rgb(0,0,255,20),   style=plot.style_stepline, linewidth=2)
````
