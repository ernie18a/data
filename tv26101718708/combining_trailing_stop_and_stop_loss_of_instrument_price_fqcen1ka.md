#  Combining Trailing Stop and Stop loss (% of instrument price)

- url: https://www.tradingview.com/script/FQCEN1Ka-Combining-Trailing-Stop-and-Stop-loss-of-instrument-price/
- type: strategy
- pine_id: PUB;db61051ec4854ab7936479612b198f2e
- version: 3.0

## Description

Both a trailing stop and a stop loss are necessary tools for every trader, for locking in as much profit in any given trade, while on the other hand minimizing the risks involved in trading.
I started to write this scipt to give an answer to many traders who wanted these two tools combined, but didn't find any way to program this.
TV has some shortcomings in the built-in functions regarding this topic. You can use 'stop' and 'limit', or 'loss' and 'profit' and even functions with trailing stops. But all of these lack the flexibility of the use of percentages.
I used many ideas of the community, and with this scrip I want to give back to the community.

The strategy is just a simple crossing of two Exponential Moving Averages, so do not start trading based solely on this script.
Also keep in mind that no two assets are the same, and adjustments should be made in the configuration for every asset.
This script should be viewed as a template, just take out the chunks of code you need. A savvy programmer can undoubtedly implement a 'take profit' of 50% halfway down the trade.

The features are:
-Everything is easily adjustable through the configuration section
-2 EMA's which form the strategy to go Long or Short
-Trailing stop, which adjust itself every bar according to the configuration
-Stop loss, which uses the entry price of the trade and stays at the same level according to the configuration
-The chart provides a visual reference for the levels of both stops

Happy trading!

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © wouterpruym1828

//DISCLAIMER: This is not a trading strategy. Rather, it is a template from which you can take chunks of code and implement them in your own script.
//I do not take any responsibility in case of resulting losses while using parts of this script or the script as a whole. It is up to the user to decide how to use this script, 
//thereby assuming full responsibility in the risks taken while trading.

//@version=5
strategy(title=" Combining Trailing Stop, Take Profit and Stop loss (% of instrument price)",
     overlay=true, pyramiding=1, shorttitle="TSL&TP&SL%")

//INDICATOR SECTION

// Indicator Input options+
i_FastEMA = input.int(title = "Fast EMA period", minval = 0, defval = 20)
i_SlowEMA = input.int(title = "Slow EMA period", minval = 0, defval = 50)
     
// Calculate moving averages
fastEMA = ta.ema(close, i_FastEMA)
slowEMA = ta.ema(close, i_SlowEMA)

// Plot moving averages
plot(fastEMA, title="Fast SMA", color=color.blue)
plot(slowEMA, title="Slow SMA", color=color.orange)




//STRATEGY SECTION  

// Calculate trading conditions
buy  = ta.crossover(fastEMA, slowEMA)
sell = ta.crossunder(fastEMA, slowEMA)

// STEP 1:
// Configure trail stop loss level with input options (optional)

longTrailPerc = input.float(title="Long Trailing Stop (%)", minval=0.0, step=0.1, defval=7) * 0.01

shortTrailPerc = input.float(title="Short Trailing Stop (%)", minval=0.0, step=0.1, defval=7) * 0.01

//Configure stop loss level with input options (optional)

longStopPerc = input.float(title="Long Stop Loss (%)", minval=0.0, step=0.1, defval=2)*0.01

shortStopPerc = input.float(title="Short Stop Loss (%)", minval=0.0, step=0.1, defval=2)*0.01

//Configure take profit price level and take profit ratio with input options (optional)

longTpPerc = input.float(title="Long Take Profit (%)", minval=0.0, step=0.1, defval=2) 

shortTpPerc = input.float(title="Short Take Profit (%)", minval=0.0, step=0.1, defval=2) 

TP_Ratio = input.float(title="Unwind Postion Size % @ TP", defval=50, step=1, tooltip="Example: 50 closing 50% of the position once TP is reached")/100

//Configure stop loss after take profit with input options (optional)

longStopTpPerc = input.float(title="Long Stop Loss after TP", minval=0.0, step=0.1, defval=1)

shortStopTpPerc = input.float(title="Short Stop Loss after TP", minval=0.0, step=0.1, defval=1)

// STEP 2:
// Determine trail stop loss prices
longTrailPrice = 0.0, shortTrailPrice = 0.0

longTrailPrice := if (strategy.position_size > 0)
    stopValue = high * (1 - longTrailPerc)
    math.max(stopValue, longTrailPrice[1])
else
    0

shortTrailPrice := if (strategy.position_size < 0)
    stopValue = low * (1 + shortTrailPerc)
    math.min(stopValue, shortTrailPrice[1])
else
    999999

//Determine entry price

entryPrice = 0.0

entryPrice := strategy.opentrades.entry_price(strategy.opentrades - 1)

//Determine stop loss after reaching TP

longStopTP = 0.0, shortStopTP = 0.0

longStopTP := entryPrice + (entryPrice * (longStopTpPerc / 100))

shortStopTP := entryPrice - (entryPrice * (shortStopTpPerc / 100))


// Determine take profit prices

percentAsPoints(pcnt) =>
    strategy.position_size != 0 ? math.round(pcnt / 100.0 * strategy.position_avg_price / syminfo.mintick) : float(na)

percentAsPrice(pcnt) =>
    strategy.position_size != 0 ? ((pcnt / 100.0) + 1.0) * strategy.position_avg_price : float(na)
 
current_position_size = math.abs(strategy.position_size)
initial_position_size = math.abs(ta.valuewhen(strategy.position_size[1] == 0.0, strategy.position_size, 0))   


longTP  = strategy.position_avg_price + percentAsPoints(longTpPerc) * syminfo.mintick * strategy.position_size / math.abs(strategy.position_size)
bool stageLongTP = false
if high > longTP
    stageLongTP := true



shortTP  = strategy.position_avg_price + percentAsPoints(shortTpPerc) * syminfo.mintick * strategy.position_size / math.abs(strategy.position_size)
bool stageShortTP = false
if low < shortTP
    stageShortTP := true

// Determine stop loss prices

longLossPrice =  entryPrice * (1 - longStopPerc)

shortLossPrice =  entryPrice * (1 + shortStopPerc)


// Plot trail stop, stop loss and take profit values for confirmation

plot(entryPrice, color=color.black, style=plot.style_cross, linewidth=2, title="Entry Price")

plot(series=(strategy.position_size > 0) ? longTrailPrice : na,
     color=color.fuchsia, style=plot.style_cross,
     linewidth=2, title="Long Trail Stop")
plot(series=(strategy.position_size < 0) ? shortTrailPrice : na,
     color=color.fuchsia, style=plot.style_cross,
     linewidth=2, title="Short Trail Stop")

plot(series=(strategy.position_size > 0) ? longLossPrice : na,
     color=color.olive, style=plot.style_cross,
     linewidth=2, title="Long Stop Loss")
plot(series=(strategy.position_size < 0) ? shortLossPrice : na,
     color=color.olive, style=plot.style_cross,
     linewidth=2, title="Short Stop Loss")
     
plot(series=(strategy.position_size > 0) ? longTP : na,
     color=color.green, style=plot.style_cross,
     linewidth=2, title="Long TP")
plot(series=(strategy.position_size < 0) ? shortTP : na,
     color=color.green, style=plot.style_cross,
     linewidth=2, title="Short TP")
     
plot(series=(strategy.position_size > 0) ? longStopTP : na,
     color=color.aqua, style=plot.style_cross,
     linewidth=2, title="Long TP Stop Loss")
plot(series=(strategy.position_size < 0) ? shortStopTP : na,
     color=color.aqua, style=plot.style_cross,
     linewidth=2, title="Short TP Stop Loss")
     


// Submit entry orders
if (buy)
    strategy.entry("Buy", strategy.long)

if (sell)
    strategy.entry("Sell", strategy.short)
    
//Evaluating trailing stop, stop after take profit or stop loss to use, 


var longStopPrice = 0.0
if strategy.position_avg_price < longTP 
    if longTrailPrice < longLossPrice
        longStopPrice := longLossPrice
    else if longTrailPrice > longLossPrice
        longStopPrice := longTrailPrice
        
if stageLongTP == true
    if longTrailPrice < longStopTP
        longStopPrice := longStopTP
    else if longTrailPrice > longStopTP
        longStopPrice := longTrailPrice


var shortStopPrice = 0.0
if strategy.position_avg_price > shortTP
    if shortTrailPrice > shortLossPrice
        shortStopPrice := shortLossPrice
    else if shortTrailPrice < shortLossPrice
        shortStopPrice := shortTrailPrice
        
if stageShortTP == true
    if shortTrailPrice > shortStopTP
        shortStopPrice := shortStopTP
    else if shortTrailPrice < shortStopTP
        shortStopPrice := shortTrailPrice


// STEP 3:
// Submit exit orders for take profit (stop loss moves to entry price) and stop price

if (strategy.position_size > 0)
    strategy.exit(id="Buy TP", qty = initial_position_size * TP_Ratio, limit = longTP)
    strategy.exit(id="Buy Stop", stop=longStopPrice)

if (strategy.position_size < 0)
    strategy.exit(id="Sell TP", qty = initial_position_size * TP_Ratio, limit = shortTP)
    // shortLossPrice := shortStopTP
    strategy.exit(id="Sell Stop", stop=shortStopPrice)
````
