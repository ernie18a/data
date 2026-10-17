# ETF 3-Day Reversion Strategy

- url: https://www.tradingview.com/script/Cvi9Zf0q-ETF-3-Day-Reversion-Strategy/
- type: strategy
- pine_id: PUB;c8f90f8290bc4cabb3c9372a40f7f7bf
- version: 2.0

## Description

Introduction: This strategy is a modification of the “3-day Mean Reversion Strategy” from the book "High Probability ETF Trading" by Larry Connors and Cesar Alvarez. In the book, the authors discuss a high-probability ETF mean reversion strategy for a 1-day time-frame with these simple rules:

[list]
[*]The price must be above the 200 day SMA and below the 5 day SMA.
[*]The low of today must be lower than the low of yesterday (must be true for 3 consecutive days)
[*]The high of today must be lower than the high of yesterday (must be true for 3 consecutive days)
[*]If the 3 rules above are true, then buy on the close of the current day.
[*]Exit when the closing price crosses above the 5 day SMA. 
[/list]
In practice and in backtesting, I’ve found that the strategy consistently works better when using an EMA for the trend-line instead of an SMA. So, this script uses an EMA for the trend-line. I’ve also made the length of the exit EMA adjustable. 

How it works: 
The Strategy will buy when the buy conditions above are true. The strategy will sell when the closing price crosses over the Exit Moving Average

Plots:
Green line = Exit Moving Average (Default 5 Day EMA)
Blue line = 5 Day EMA (Used as Entry Criteria)

Disclaimer: Open-source scripts I publish in the community are largely meant to spark ideas that can be used as building blocks for part of a more robust trade management strategy. If you would like to implement a version of any script, I would recommend making significant additions/modifications to the strategy & risk management functions. If you don’t know how to program in Pine, then hire a Pine-coder. We can help!

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// @version = 5
// Author = TradeAutomation


strategy(title="ETF 3-Day Reversion Strategy", shorttitle="ETF 3-Day Reversion Strategy", process_orders_on_close=true, overlay=true, commission_type=strategy.commission.cash_per_order, commission_value=1, initial_capital = 10000000, default_qty_type=strategy.percent_of_equity, default_qty_value=100)


// Backtest Date Range Inputs // 
StartTime = input.time(defval=timestamp('01 Jan 2012 05:00 +0000'), title='Start Time')
EndTime = input.time(defval=timestamp('01 Jan 2099 00:00 +0000'), title='End Time')
InDateRange = time>=StartTime and time<=EndTime

// Strategy Rules //
DayEMA5 = ta.ema(close, 5)
EMAQualInput = input.bool(false, "Only enter trades when above qualifier EMA?", tooltip="When this is selected, a trade will only be entered when the price is above the EMA qualifier line.")
QEMA = ta.ema(close, input.int(200, "EMA Trade Qualifier Length"))
EMAQualifier = close>QEMA
Rule1 = EMAQualInput==true ? EMAQualifier : close>0
Rule2 = close<DayEMA5
Rule3 = high<high[1] and low<low[1] and high[1]<high[2] and low[1]<low[2] and high[2]<high[3] and low[2]<low[3]
ExitEMA = ta.ema(close, input.int(5, "EMA Length For Exit Strategy", tooltip = "The strategy will sell when the price crosses over this EMA"))
plot(DayEMA5, "Five Period EMA")
plot(QEMA, "Qualifier EMA")
plot(ExitEMA, "Exit EMA", color=color.green)

// Entry & Exit Functions //
if (InDateRange)
    strategy.entry("Long", strategy.long, when = Rule1 and Rule2 and Rule3)
    strategy.close("Long", when = ta.crossover(close, ExitEMA))
if (not InDateRange)
    strategy.close_all()
````
