# Maximized Scalping On Trend (by Coinrule)

- url: https://www.tradingview.com/script/XAiEh7nb-Maximized-Scalping-On-Trend-by-Coinrule/
- type: strategy
- pine_id: PUB;8i7iMvSUrCANHwAfQzM34Ni7Fb9B9ydd
- version: 3.0

## Description

"[i]The trend is your friend.[/i]" This is one of the most famous and valuable teachings that experienced traders can give to newbies. There is a reason for that. 

No matter your views about where the price moves, [b]what matters is where the price heads to[/b].  [b]The market is always right, and ultimately it decides who gets the profit and who has to take a loss.[/b]

The purpose of this strategy is to spot when it's the most suitable time to buy an asset profiting from a potential short-term price increase. The strategy tends to open trades frequently, closing them on average in one and a half days.

[b]ENTRY[/b]

The buy order is placed on assets that present strong momentum when it's more likely that it is about to increase further in the short term.

To capture momentum on the asset, the rule strategy requires:

[list]
[*]the MA50 greater than the MA100
[*]the RSI greater than 50
[/list]

The rule, then, places the order when 

The price crosses above the MA9.

[b]EXIT[/b]

This strategy comes with a stop loss and a take profit which adapt dynamically to market conditions.

The trade is closed in profit when the [b]RSI is greater than 70[/b], as the trend could experience a pull-back.

Alternatively, the trade is closed when the [b]RSI is lower than 30[/b], being this a sign of weakening of the trend.

[b]Pro tip[/b]: The 1-hour time frame has proven to return the best results on average. The strategy can also work well in the 15-min time frame if you want to increase the trades' frequency.


The strategy assumes each order to trade 30% of the available capital and opens a trade at a time. A trading fee of 0.1% is taken into account.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Coinrule

//@version=4
strategy(shorttitle='Maximized Scalping On Trend',title='Maximized Scalping On Trend (by Coinrule)', overlay=true, initial_capital = 1000, process_orders_on_close=true, default_qty_type = strategy.percent_of_equity, default_qty_value = 30, commission_type=strategy.commission.percent, commission_value=0.1)

//Backtest dates
fromMonth = input(defval = 1,    title = "From Month",      type = input.integer, minval = 1, maxval = 12)
fromDay   = input(defval = 10,    title = "From Day",        type = input.integer, minval = 1, maxval = 31)
fromYear  = input(defval = 2019, title = "From Year",       type = input.integer, minval = 1970)
thruMonth = input(defval = 1,    title = "Thru Month",      type = input.integer, minval = 1, maxval = 12)
thruDay   = input(defval = 1,    title = "Thru Day",        type = input.integer, minval = 1, maxval = 31)
thruYear  = input(defval = 2112, title = "Thru Year",       type = input.integer, minval = 1970)

showDate  = input(defval = true, title = "Show Date Range", type = input.bool)

start     = timestamp(fromYear, fromMonth, fromDay, 00, 00)        // backtest start window
finish    = timestamp(thruYear, thruMonth, thruDay, 23, 59)        // backtest finish window
window()  => time >= start and time <= finish ? true : false       // create function "within window of time"

//MA inputs and calculations
movingaverage_fast = sma(close, input(9))
movingaverage_mid= sma(close, input(50))
movingaverage_slow = sma(close, input (100))


//Trend situation
Bullish= crossunder(close, movingaverage_fast)

Momentum = movingaverage_mid > movingaverage_slow

// RSI inputs and calculations
lengthRSI = 14
RSI = rsi(close, lengthRSI)

//Entry
strategy.entry(id="long", long = true, when = Bullish and Momentum and RSI > 50 and window())

//Exit

TP = input(70)
SL =input(30)
longTakeProfit  = RSI > TP
longStopPrice = RSI < SL

strategy.close("long", when = longStopPrice or longTakeProfit and window())

plot(movingaverage_fast, color=color.black, linewidth=2 )
plot(movingaverage_mid, color=color.orange, linewidth=2)
plot(movingaverage_slow, color=color.purple, linewidth=2)
````
