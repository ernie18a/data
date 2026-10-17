# RSI Classic Strategy (by Coinrule)

- url: https://www.tradingview.com/script/JMm04UG5-RSI-Classic-Strategy-by-Coinrule/
- type: strategy
- pine_id: PUB;3PYosSxzf3gK5SnFY1sBO1zGP3vh6TX5
- version: 1.0

## Description

One of the questions hobbyist traders more often ask is: [i]what is the perfect trading indicator?[/i]

Every indicator is just a tool, so its efficiency is proportional to your ability to read its signals and translate them into an actionable trading strategy. The RSI is likely the most flexible and easy to use among the technical indicators. 

This trading strategy tries to catch short-term swings on the coins of your choice with a simple yet profitable setup. 

[list]
[*][b]Buy when the RSI is lower than 30[/b] (you can adjust it to 35 in times of steep uptrend).
[b]Sell when the RSI is greater than 65[/b] (the target may range between 60 and 75 depending on the volatility of the coin).
[/list]


Note that the buy signal comes when the indicator crosses below 30 and not when it crosses above 30 as it happens on the built-in RSI strategy on Tradingview.

[b]The present script overperforms the built-in strategy, even adding trading fees and using a lower amount of capital for each trade (30%). That means that the system can deliver higher net-profits with lower risk levels.[/b]

A typical example of market conditions where this strategy works perfectly is as follows.

https://www.tradingview.com/x/nFjrPkMF/

The first initial breakout indicates that a new leg up in the trend may start. Bitcoin starts to trade within a range which you can identify when it reaches the point 3. That is the perfect time to start the rule because


- trading within a channel anticipates possible swings up and down
- the trend is on the upside, providing low downside risk in buying the dips.

This strategy works well with selected coins of your choice, and [b]it's a great fit on leverage exchanges like Binance Futures.[/b]

If you prefer to run it across all available coins on the market, instead, you may choose an optimized version. 

https://www.tradingview.com/script/Pm1WAtyI-Optimized-RSI-Strategy-Buy-The-Dips-by-Coinrule/

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © relevantLeader16058

//@version=4
strategy(shorttitle='RSI Classic Strategy',title='RSI Classic Strategy (by Coinrule)', overlay=true, initial_capital = 1000, process_orders_on_close=true, default_qty_type = strategy.percent_of_equity, default_qty_value = 30, commission_type=strategy.commission.percent, commission_value=0.1)

//Backtest dates
fromMonth = input(defval = 1,    title = "From Month",      type = input.integer, minval = 1, maxval = 12)
fromDay   = input(defval = 1,    title = "From Day",        type = input.integer, minval = 1, maxval = 31)
fromYear  = input(defval = 2020, title = "From Year",       type = input.integer, minval = 1970)
thruMonth = input(defval = 1,    title = "Thru Month",      type = input.integer, minval = 1, maxval = 12)
thruDay   = input(defval = 1,    title = "Thru Day",        type = input.integer, minval = 1, maxval = 31)
thruYear  = input(defval = 2112, title = "Thru Year",       type = input.integer, minval = 1970)

showDate  = input(defval = true, title = "Show Date Range", type = input.bool)

start     = timestamp(fromYear, fromMonth, fromDay, 00, 00)        // backtest start window
finish    = timestamp(thruYear, thruMonth, thruDay, 23, 59)        // backtest finish window
window()  => time >= start and time <= finish ? true : false       // create function "within window of time"


// RSI inputs and calculations
lengthRSI = 14
RSI = rsi(close, lengthRSI)
oversold= input(30)
overbought= input(60)

//Entry 
strategy.entry(id="long", long = true, when = RSI< oversold and window())

//Exit
//RSI
strategy.close("long", when = RSI > overbought and window())
````
