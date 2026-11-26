# [VJ]First Candle Strategy

- url: https://www.tradingview.com/script/82Ylt2lz-VJ-First-Candle-Strategy/
- type: strategy
- pine_id: PUB;a24563321dab45d3a4e0d3334065c42a
- version: 1.0

## Description

Hello Traders, this is a simple intraday strategy involving the first candle of the day  with an  additional twist to the traditional style . You can modify the time of candle  on the stock and see what are your best picks. Comment below if you found something with good returns

Strategy: Observe the first candle of the day within any time frame. 15m works best. If the first candle is RED ,then go for buy side for the rest of the day. You could square off at close of session or have a fixed take profit and stop loss. This is a contrarian indicator where people just use this as their first entry for the day.  The same holds good when a Green candle is seen you go short side.

There is stop loss and take profit that can be used to optimise your trade

The template also includes daily square off based on your time.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © vikris
//@version=4
strategy("[VJ]First Candle Strategy", overlay = true,calc_on_every_tick = true,default_qty_type=strategy.percent_of_equity,default_qty_value=100,initial_capital=750,commission_type=strategy.commission.percent, 
     commission_value=0.02)


// ********** Strategy inputs - Start **********

// Used for intraday handling
// Session value should be from market start to the time you want to square-off 
// your intraday strategy
// Important: The end time should be at least 2 minutes before the intraday
// square-off time set by your broker
var i_marketSession = input(title="Market session", type=input.session, 
     defval="0915-1455", confirm=true)

// Make inputs that set the take profit % (optional)
longProfitPerc = input(title="Long Take Profit (%)",
     type=input.float, minval=0.0, step=0.1, defval=1) * 0.01

shortProfitPerc = input(title="Short Take Profit (%)",
     type=input.float, minval=0.0, step=0.1, defval=1) * 0.01
     
// Set stop loss level with input options (optional)
longLossPerc = input(title="Long Stop Loss (%)",
     type=input.float, minval=0.0, step=0.1, defval=0.5) * 0.01

shortLossPerc = input(title="Short Stop Loss (%)",
     type=input.float, minval=0.0, step=0.1, defval=0.5) * 0.01    


// ********** Strategy inputs - End **********


// ********** Supporting functions - Start **********

// A function to check whether the bar or period is in intraday session
barInSession(sess) => time(timeframe.period, sess) != 0



// Figure out take profit price
longExitPrice  = strategy.position_avg_price * (1 + longProfitPerc)
shortExitPrice = strategy.position_avg_price * (1 - shortProfitPerc)

// Determine stop loss price
longStopPrice  = strategy.position_avg_price * (1 - longLossPerc)
shortStopPrice = strategy.position_avg_price * (1 + shortLossPerc)


// ********** Supporting functions - End **********


// ********** Strategy - Start **********
// See if intraday session is active
bool intradaySession = barInSession(i_marketSession)

// Trade only if intraday session is active

//=================Strategy logic goes in here===========================
 
// If start of the daily session changed, then it's first bar of the new session
isNewDay = time("D") != time("D")[1]
var firstBarCloseValue = close
var firstBarOpenValue = open
if isNewDay
    firstBarCloseValue := close
    firstBarOpenValue := open


greenCandle = firstBarOpenValue < firstBarCloseValue
redCandle = firstBarOpenValue > firstBarCloseValue

buy = redCandle
sell = greenCandle


// plot(firstBarCloseValue)
// plot(firstBarOpenValue)



//Final Long/Short Condition
longCondition = buy
shortCondition =sell
 
//Long Strategy - buy condition and exits with Take profit and SL
if (longCondition and intradaySession)
    stop_level = longStopPrice
    profit_level = longExitPrice
    strategy.entry("My Long Entry Id", strategy.long)
    strategy.exit("TP/SL", "My Long Entry Id", stop=stop_level, limit=profit_level)


//Short Strategy - sell condition and exits with Take profit and SL
if (shortCondition and intradaySession)
    stop_level = shortStopPrice
    profit_level = shortExitPrice
    strategy.entry("My Short Entry Id", strategy.short)
    strategy.exit("TP/SL", "My Short Entry Id", stop=stop_level, limit=profit_level)
 
 
// Square-off position (when session is over and position is open)
squareOff = (not intradaySession) and (strategy.position_size != 0)
strategy.close_all(when = squareOff, comment = "Square-off")

// ********** Strategy - End **********
````
