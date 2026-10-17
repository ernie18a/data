# How To Auto Set Date Range

- url: https://www.tradingview.com/script/zXEErEs9-How-To-Auto-Set-Date-Range/
- type: strategy
- pine_id: PUB;8LIZFAQMXYAWonTXWepmVGleeuECgwWs
- version: 4.0

## Description

Example how to automatically set the date range window to be backtested from X days or weeks ago to present. Additional options are also included to manually set the date range or to show entire range available.

Normally when you change chart period it changes the number of days being backtested, which means as you increase the chart period (for example from 5min to 15min), you also increase the number of days traded. So you can not compare apples to apples for which period would yield best performance for your strategy.

By incorporating this code with your own strategy's logic (replacing buy and sell), it will allow you to compare results of different period backtests over the same duration of time.

Date Range: ALL uses entire history.
Date Range: DAYS uses number you set in # Days or Weeks
Date Range: WEEKS uses number you set in # Days or Weeks
Date Range: MANUAL uses manual dates you set in From and To fields

Much gratitude to @pinechrix for suggesting this improvement to me, and to @Gesundheit for pointing me in the right direction on the original example I published previously. Thank you both!

NOTICE: This is an example script and not meant to be used as an actual strategy. By using this script or any portion thereof, you acknowledge that you have read and understood that this is for research purposes only and I am not responsible for any financial losses you may incur by using this script!

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © allanster

//@version=5
strategy(title = "How To Auto Set Date Range", shorttitle = "AutoDates", overlay = true, precision = 8, max_bars_back = 200, pyramiding = 0, initial_capital = 100000, 
     currency = currency.NONE, default_qty_type = strategy.cash, default_qty_value = 100000, commission_type = "percent", commission_value = 0.27)

// Revision: 3
// Author:   @allanster

// === INPUT MA LENGTHS ===
fastMA       = input.int   (defval = 12,                                   title = "FastMA Length",     minval = 1, step = 1)
slowMA       = input.int   (defval = 26,                                   title = "SlowMA Length",     minval = 1, step = 1)

// === INPUT BACKTEST RANGE ===
useRange     = input.string(defval = "WEEKS",                              title = "Date Range",        confirm = false, options = ["ALL", "DAYS", "WEEKS", "MANUAL"])
nDaysOrWeeks = input.int   (defval = 52,                                   title = "# Days or Weeks",   minval = 1)
fromTime     = input.time  (defval = timestamp("01 Jan 2021 00:00 +0000"), title = "From Date & Time")
thruTime     = input.time  (defval = timestamp("01 Jan 2112 00:00 +0000"), title = "Thru Date & Time")

// === INPUT SHOW PLOT ===
showDate     = input       (defval = true,                                 title = "Show Date Range")

// === FUNCTION EXAMPLE ===
window() =>                                                               // create function "within window of time"
    oneDay   = 24 * 60 * 60 * 1000
    oneWeek  = 7 * oneDay
    present  = timenow
    start    = useRange == "DAYS" ? present - nDaysOrWeeks * oneDay : 
      useRange == "WEEKS" ? present - nDaysOrWeeks * oneWeek : fromTime
    finish   = useRange == "DAYS" or useRange == "WEEKS" ? timestamp(2112, 1, 1, 23, 59) : thruTime
    useRange != "ALL" ? time >= start and time <= finish : true

// === LOGIC ===
crossOv      = ta.crossover (ta.ema(hlc3, fastMA), ta.ema(hlc3, slowMA))  // true when fastMA crosses over  slowMA
crossUn      = ta.crossunder(ta.ema(hlc3, fastMA), ta.ema(hlc3, slowMA))  // true when fastMA crosses under slowMA

// === EXECUTION ===
strategy.entry("L", strategy.long, when=window() and crossOv)             // enter long when "within window of time" AND crossover
strategy.close("L", when=window() and crossUn)                            // exit  long when "within window of time" AND crossunder         

// === PLOTTING ===
bgcolor(color = showDate and window() ? color.rgb(120,123,134, 90) : na)                                             // plot "within window of dates"
plot(ta.ema(hlc3, fastMA), title = 'FastMA', color = color.rgb(0,188,212),  linewidth = 2, style = plot.style_line)  // plot FastMA
plot(ta.ema(hlc3, slowMA), title = 'SlowMA', color = color.rgb(255,235,59), linewidth = 2, style = plot.style_line)  // plot SlowMA
````
