# How To Set Backtest Date Range

- url: https://www.tradingview.com/script/62hUcP6O-How-To-Set-Backtest-Date-Range/
- type: strategy
- pine_id: PUB;jXofp4jlj1UhXmtLOH5xbSOmxlnahQMH
- version: 8.0

## Description

Example how to select and set date range window to be backtested. Normally when you change chart period it changes the number of days being backtested which means as you increas the chart period (for example from 5min to 15min) you also increase the number of days traded, so you can not compare apples to apples for which period would yield best returns for your strategy. Now you can. Incorporate this code replacing buy and sell with your strategy, then simply input the From and To dates in Format -> Inputs, and then change the chart period to view updated results. 

NOTE: There is a limit in backtesting to 2000 orders, so please be aware of this when setting your date ranges. If you set your range too high, you may be exceeding this limit on some periods and not on others, so this would yield incorrect comparison of returns per period. If you see in your backtesting results that you are nearing this limit for one of your periods you are testing, then reduce the date range to a smaller number of days.

Enjoy!

(Thanks to @Gesundheit "Adeel" for pointing me in the right direction on this!)

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © allanster

// Revision: 7

//@version=5
strategy(title = "How To Set Backtest Range", shorttitle = "Dates", overlay = true, format = format.price, precision = 8,
     default_qty_type = strategy.cash, default_qty_value = 100, initial_capital = 10000, currency = currency.NONE,
     slippage = 2, commission_type = strategy.commission.percent, commission_value = 0.25)

// === INPUT MA SOURCES AND LENGTHS ===
i_srcF = input     (defval = hlc3, title = "Faster   ",                       inline = 'F')
i_lenF = input.int (defval = 12,   title = "Length",    minval = 1, step = 1, inline = 'F')
i_srcS = input     (defval = hlc3, title = "Slower ",                         inline = 'S')
i_lenS = input.int (defval = 26,   title = "Length",    minval = 1, step = 1, inline = 'S')

// === INPUT BACKTEST RANGE ===
i_from = input.time(defval = timestamp("01 Jan 2023 00:00 +0000"), title = "From")
i_thru = input.time(defval = timestamp("01 Mar 2023 00:00 +0000"), title = "Thru")

// === INPUT SHOW PLOT ===
i_show = input     (defval = true, title = "Show Date Range")

// === FUNCTION EXAMPLE ===
date() => time >= i_from and time <= i_thru  // create date function "within window of time"

// === LOGIC ===
fastMA = ta.ema(i_srcF, i_lenF)              // create Fast MA
slowMA = ta.ema(i_srcS, i_lenS)              // create Slow MA
crsOvr = ta.crossover (fastMA, slowMA)       // true when Fast MA crosses over  Slow MA
crsUnd = ta.crossunder(fastMA, slowMA)       // true when Fast MA crosses under Slow MA

// === EXECUTION ===
if date() and crsOvr                         // if "within window of time" AND crossover
    strategy.entry("Long", strategy.long)    //     enter long
if date() and crsUnd                         // if "within window of time" AND crossunder
    strategy.close("Long")                   //     close long         

// === PLOTTING ===
bgcolor(color = i_show and date() ? color.new(color.gray, 90) : na)  // plot if "Show Date Range" and "within window of time"
plot(series = fastMA, title = 'FastMA', color = color.yellow, linewidth = 2, style = plot.style_line)  // plot Fast MA
plot(series = slowMA, title = 'SlowMA', color = color.aqua,   linewidth = 2, style = plot.style_line)  // plot Slow MA
````
