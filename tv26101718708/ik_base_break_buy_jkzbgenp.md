# (IK) Base Break Buy

- url: https://www.tradingview.com/script/JkzbgenP-IK-Base-Break-Buy/
- type: strategy
- pine_id: PUB;YtHMC7x74CciYgGMe9Xyo0qZhcakXe4j
- version: 2.0

## Description

This strategy first calculates areas of support (bases), and then enters trades if that support is broken. The idea is to profit off of retracement. Dollar-cost-averaging safety orders are key here. This strategy takes into account a .1% commission, and tests are done with an initial capital of 100.00 USD. This only goes long.

The strategy is highly customizable. I've set the default values to suit ETH/USD 15m. If you're trading this on another ticker or timeframe, make sure to play around with the settings. There is an explanation of each input in the script comments. I found this to be profitable across most 'common sense' values for settings, but tweaking led to some pretty promising results. I leaned more towards high risk/high trade volume. 

Always remember though: [b]historical performance is no guarantee of future behavior[/b]. Keep settings within your personal risk tolerance, even if it promises better profit. Anyone can write a 100% profitable script if they assume price always eventually goes up. 

Check the script comments for more details, but, briefly, you can customize:
	-How many bases to keep track of at once
	-How those bases are calculated
	-What defines a 'base break'
	-Order amounts
	-Safety order count
	-Stop loss

Here's the basic algorithm:
	-Identify support.
		--Have previous candles found bottoms in the same area of the current candle bottom?
		--Is this support unique enough from other areas of support?
	-Determine if support is broken.
		--Has the price crossed under support quickly and with certainty? 
	-Enter trade with a percentage of initial capital.
	-Execute safety orders if price continues to drop.
	-Exit trade at profit target or stop loss. 

Take profit is dynamic and calculated on order entry. The bigger the 'break', the higher your take profit percentage. This target percentage is based on average position size, so as safety orders are filled, and average position size comes down, the target profit becomes easier to reach.

Stop loss can be calculated one of two ways, either a static level based on initial entry, or a  dynamic level based on average position size. [b]If you use the latter (default), be aware, your real losses will be greater than your stated stop loss percentage[/b]. For example:
	-stop loss = 15%, capital = 100.00, safety order threshold = 10%
	-you buy $50 worth of shares at $1         - price average is $1
	-you safety $25 worth of shares at $0.9  - price average is $0.966
	-you safety $25 worth of shares at $0.8. - price average is $0.925
	-you get stopped out at 0.925 * (1-.15) = $0.78625, and you're left with $78.62. 
This is a realized loss of ~21.4% with a stop loss set to 15%. The larger your safety order threshold, the larger your real loss in comparison to your stop loss percentage, and vice versa. 

Indicator plots show the calculated bases in white. The closest base below price is yellow. If that base is broken, it turns purple. Once a trade is entered, profit target is shown in silver and stop loss in red.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © userIan

//@version=4
strategy("(IK) Base Break Buy", overlay=true, pyramiding=6, precision=2, default_qty_type=strategy.cash, initial_capital=100.0, currency="USD", commission_type=strategy.commission.percent, commission_value=0.1)

// == INPUT ==
i_baseMax      = input(group="Base Calculations", title="Max Bases", type=input.integer, defval=3, minval=1, maxval=10)                                   // max amount of bases on the chart at any specific time
i_dev          = input(group="Base Calculations", title="Base Area Deviation", type=input.float, defval=0.005, minval=0.0, maxval=1.0)                    // if enough recent bars had bottoms within this deviation of the current bar's bottom, a base is created 
i_baseDev      = input(group="Base Calculations", title="Unique Base Deviation", type=input.float, defval=0.05, minval=0.0, maxval=1.0)                   // bases cannot be created if they fall within this deviation of an extant base
i_baseSource   = input(group="Base Calculations", title="Base Source", options=["Close or Open", "Low"], defval="Close or Open")                          // should base calcuations be based off of candlestick closes and opens (whichever is lower), or candlestick lows
i_lookback     = input(group="Base Calculations", title="Lookback", type=input.integer, defval=100)                                                       // how many bars back do we check to confirm current bases
i_confLevel    = input(group="Base Calculations", title="Confidence Level", type=input.float, defval=0.01, minval=0.0, maxval=1.0)                        // what percentage of historical bars bottoming within deviation are needed to confirm a base
i_breakThresh  = input(group="Base Break Detection", title="Break Threshold", type=input.float, defval=0.02, minval=0.0, maxval=1.0)                      // how far (by percentage) does price have to fall below a base to constitute a 'break'
i_breakWindow  = input(group="Base Break Detection", title="Break Window", type=input.integer, defval=5)                                                  // how many bars should we allow for price to fall below the break threshold before it's no longer a tradable break
i_initialOrder = input(group="Order Settings", title="Initial Order Capital", type=input.float, defval=0.2, minval=0.0, maxval=1.0)                       // what percentage of capital to use in initial trade entry
i_safetyCount  = input(group="Order Settings", title="Safety Order Max Count", type=input.integer, defval=3, minval=0, maxval=5)                          // maximum amount of safety orders per trade. remaining capital after initial entry will be divided evenly among these 
i_safetyThresh = input(group="Order Settings", title="Safter Order Threshold", type=input.float, defval=0.03, minval=0.0, maxval=1.0)                     // what percentage does price need to fall to activate a safety order
i_stopLoss     = input(group="Order Settings", title="Stop Loss", type=input.float, defval=0.2, minval=0.0, maxval=1.0)                                   // what percentage does price need to fall to activate a stop loss
i_stopLossType = input(group="Order Settings", title="Stop Loss Type", options=['From Initial Entry', 'From Price Average'], defval='From Price Average') // calculate static stop loss based on price at first entry, or dynamic stop loass based on position average price

// == FUNCTIONS ==
// is _val1 within the deviation (_dev) of _val2?
f_isCloseTo(_val1, _val2, _dev) => (_val1 <= _val2*(1+_dev)) and (_val1 >= _val2*(1-_dev)) 

// is this confirmed base (_val) distant enough (outside of deviation _dev) from another confirmed base (in _arr)?
f_newBase(_val, _arr, _dev) =>  
    result = true
    if array.size(_arr) > 0
        for i = 0 to array.size(_arr)-1
            if (_val <= array.get(_arr, i)*(1+_dev)) and (_val >= array.get(_arr, i)*(1-_dev))
                result := false
    result
    
// == VARIABLES ==
var bases          = array.new_float()                                                  // reference to every current base
var closestBase    = float(na)                                                          // the closest base to currenct price (only below price)
var brokenBase     = float(na)                                                          // the base that has been recently broken
var baseBreakIndex = int(na)                                                            // when the most recent base was broken
var takeProfit     = float(na)                                                          // dynamic take profit percentage base on severity of base break
var safetyOrderQty = ((strategy.initial_capital*(1-i_initialOrder))/i_safetyCount)/100  // percentage of capital to use for each safety order
var safetyCount    = 0                                                                  // keep track of how many safety orders we've made

// == LOGIC ==
// detect bases and add unique bases to base array
currentBot = i_baseSource == "Low" ? low : min(close,open)
count = 0
for i = 1 to i_lookback
	bot = i_baseSource == "Low" ? low[i] : min(close[i],open[i])
	if f_isCloseTo(currentBot, bot, i_dev)
		count := count +1	
if count >= (i_lookback * i_confLevel) and f_newBase(currentBot, bases, i_baseDev)
	array.unshift(bases, currentBot) 

// prune base array	
if array.size(bases) > i_baseMax
    array.pop(bases)
    
// detect base break
if crossunder(close, closestBase) and strategy.position_size == 0
	baseBreakIndex := bar_index
	brokenBase     := closestBase 
	
// reset baseBreak if window has expired; this is no longer a tradable break
if (bar_index - baseBreakIndex > i_breakWindow) and strategy.position_size == 0
	brokenBase := na

// update closest base
if array.size(bases) > 0
    array.sort(bases, order.descending)
    for i = 0 to array.size(bases)-1
        if array.get(bases, i) < close 
            closestBase := array.get(bases,i)
            break

// reset safety count if a trade has just been exited
if strategy.position_size == 0 
    safetyCount := 0

// == ENTRY AND EXIT ==
// enter trade if break is confirmed and set the takeProfit percentage
if close < (brokenBase * (1-i_breakThresh)) and strategy.position_size == 0 and barstate.isconfirmed
	strategy.entry(id="Long", long=strategy.long, qty=(strategy.initial_capital * i_initialOrder)/close, comment='buy')
	takeProfit := 1-(close/brokenBase) 
	
// safety order
if close < (strategy.position_avg_price * (1-i_safetyThresh)) and safetyCount < i_safetyCount
    safetyCount := safetyCount + 1
    strategy.entry(id="Long", long=strategy.long, qty=(strategy.initial_capital * safetyOrderQty)/close, comment='safety')

// exit trade
strategy.exit(id="Long", stop=i_stopLossType == "From Price Average" ? strategy.position_avg_price * (1-i_stopLoss) : brokenBase * (1-i_stopLoss), comment='sell-stop')
if (close > strategy.position_avg_price * (1+takeProfit)) and barstate.isconfirmed  
    strategy.close("Long", comment='sell-profit')
    brokenBase := na

// == PLOT ==	
plotTimer = bar_index % 2 == 0  // this creates a dashed line  	
plot(array.size(bases) > 0 and plotTimer ? array.get(bases,0)  : na, color=color.white, style=plot.style_linebr)
plot(array.size(bases) > 1 and plotTimer ? array.get(bases,1)  : na, color=color.white, style=plot.style_linebr)
plot(array.size(bases) > 2 and plotTimer ? array.get(bases,2)  : na, color=color.white, style=plot.style_linebr)
plot(array.size(bases) > 3 and plotTimer ? array.get(bases,3)  : na, color=color.white, style=plot.style_linebr)
plot(array.size(bases) > 4 and plotTimer ? array.get(bases,4)  : na, color=color.white, style=plot.style_linebr)
plot(array.size(bases) > 5 and plotTimer ? array.get(bases,5)  : na, color=color.white, style=plot.style_linebr)
plot(array.size(bases) > 6 and plotTimer ? array.get(bases,6)  : na, color=color.white, style=plot.style_linebr)
plot(array.size(bases) > 7 and plotTimer ? array.get(bases,7)  : na, color=color.white, style=plot.style_linebr)
plot(array.size(bases) > 8 and plotTimer ? array.get(bases,8)  : na, color=color.white, style=plot.style_linebr)
plot(array.size(bases) > 9 and plotTimer ? array.get(bases,9)  : na, color=color.white, style=plot.style_linebr)
plot(closestBase == closestBase[1] and strategy.position_size == 0 ? closestBase : na, color=color.yellow, style=plot.style_linebr)                                 // yellow line for closest base (if not in trade)
plot(brokenBase, color=color.purple, style=plot.style_linebr)                                                                                                       // purple line for the broken base that triggered the trade
plot(strategy.position_avg_price * (1+takeProfit), color=color.silver, style=plot.style_linebr)                                                                     // silver line for target profit
plot(i_stopLossType == "From Price Average" ? strategy.position_avg_price * (1-i_stopLoss) : brokenBase * (1-i_stopLoss), color=color.red, style=plot.style_linebr) // red line for stop loss
````
