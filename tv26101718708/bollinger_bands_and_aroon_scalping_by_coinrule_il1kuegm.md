# Bollinger Bands And Aroon Scalping (by Coinrule)

- url: https://www.tradingview.com/script/iL1kUEgM-Bollinger-Bands-And-Aroon-Scalping-by-Coinrule/
- type: strategy
- pine_id: PUB;b8a8235f434f404ea7bf147a4e57f0fa
- version: 1.0

## Description

Many technical indicators can be profitable in certain market conditions while failing in others. [b]No indicator is perfect alone.[/b]

All the best trading strategies involve multiple indicators and leverage the benefit of each of them. The following is an optimised strategy based on Bollinger Bands and the Aroon indicator.

The Bollinger Bands are among the most famous and widely used indicators. They can suggest when an asset is oversold or overbought in the short term, thus provide the best time for buying and selling it.

A strategy buying dips can work well during times of uptrend. Downtrends will result in a drawdown for the P&L of the strategy. The suggested approach minimises the drawdowns, ensuring that the system trades only when it's more likely to close the trade in profit.

[b]The Setup[/b]

[i]ENTRY[/i]

[list]
[*]The price crosses below the basis line of the Bollinger Band indicator
[*]The Aroon Indicator is above 90
[/list]

[i]EXIT[/i]

[list]
[*]The price crosses below the upper Bollinger Band
[*]The Aroon Indicator drops below 70
[/list]

The Aroon Indicator plays a key role in this strategy. It acts as a confirmation that the asset is currently in an uptrend. On the other hand, it acts as a stop if market conditions deteriorate. The strategy uses an Aroon Indicator set to [b]288 periods[/b] to provide a longer-term view on market conditions, not being heavily dependent on short-term volatility.

The best time frame for this strategy based on our backtest is the [b]4-hr[/b]. The 1-hr can work well with three times more trades, on average. As trades increase, the profitability decreases. Yet again, this is the confirmation that trading more does not mean gaining more.

To make the results more realistic, the strategy assumes each order to trade 30% of the available capital. A trading fee of 0.1% is taken into account. The fee is aligned to the base fee applied on Binance, which is the largest cryptocurrency exchange.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © relevantLeader16058

//@version=4
strategy(shorttitle='Bollinger bands And Aroon Scalping',title='Bollinger bands And Aroon Scalping (by Coinrule)', overlay=true, initial_capital = 1000, process_orders_on_close=true, default_qty_type = strategy.percent_of_equity, default_qty_value = 30, commission_type=strategy.commission.percent, commission_value=0.1)

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


// BB inputs and calculations
lengthBB = input(20, minval=1)
src = input(close, title="Source")
mult = input(2.0, minval=0.001, maxval=50, title="StdDev")
basis = sma(src, lengthBB)
dev = mult * stdev(src, lengthBB)
upper = basis + dev
lower = basis - dev
offset = input(0, "Offset", type = input.integer, minval = -500, maxval = 500)


lengthAr = input(288, minval=1)
AroonUP = 100 * (highestbars(high, lengthAr+1) + lengthAr)/lengthAr
AroonDown = 100 * (lowestbars(low, lengthAr+1) + lengthAr)/lengthAr


Confirmation = input(90, "Aroon Confirmation")
Stop = input(70, "Aroon Stop")

Bullish = crossunder (close, basis)
Bearish = crossunder (close, upper)

//Entry 

strategy.entry(id="long", long = true, when = Bullish and AroonUP > Confirmation and window())

//Exit

strategy.close("long", when = Bearish or AroonUP < Stop and window())
````
