# R3 ETF Strategy

- url: https://www.tradingview.com/script/5CDSns2I-R3-ETF-Strategy/
- type: strategy
- pine_id: PUB;3c8fddb679e845369ac489c2fe4b2ad7
- version: 2.0

## Description

This strategy is a modification of the “R3 Strategy” from the book "High Probability ETF Trading" by Larry Connors and Cesar Alvarez. This RSI strategy is for a 1-day time-frame and has these 3 simple rules:

[b]Criteria:[/b]
[list]
[*]The price must be above the 200 day moving average.
[*]The 2-period (day) RSI drops 3 days in a row.
[*]The 2-period RSI must have been below 60 3 days ago and below 10 today. 

[b]Entry and Exit:[/b]
[*]If the 3 rules above are true, then buy on the close of the current day.
[*]Exit on the day's close when the RSI crosses above 70.
[/list]

[b]How it works[/b]:
The Strategy will buy when the buy conditions above are true. The strategy will sell when the RSI crosses above 70. The RSI period/length, and RSI entry/exit criteria thresholds have all been coded to be adjustable with inputs. 

[b]Plots[/b]:
Blue line = 200 Day EMA (Used as Entry Criteria) 

Disclaimer: Open-source scripts I publish in the community are largely meant to spark ideas that can be used as building blocks for part of a more robust trade management strategy. If you would like to implement a version of any script, I would recommend making significant additions/modifications to the strategy & risk management functions. If you don’t know how to program in Pine, then hire a Pine-coder. We can help!

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// @version = 5
// Author = TradeAutomation


strategy(title="R3 ETF Strategy", shorttitle="R3 ETF Strategy", process_orders_on_close=true, overlay=true, commission_type=strategy.commission.cash_per_contract, commission_value=0.0035, initial_capital = 1000000, default_qty_type=strategy.percent_of_equity, default_qty_value=100)


// Backtest Date Range Inputs // 
StartTime = input.time(defval=timestamp('01 Jan 2010 05:00 +0000'), title='Start Time')
EndTime = input.time(defval=timestamp('01 Jan 2099 00:00 +0000'), title='End Time')
InDateRange = time>=StartTime and time<=EndTime

// Calculations and Inputs //
RSILen = input.int(2, "RSI Length")
RSI = ta.rsi(close, RSILen)
TodaysMinRSI = input.int(10, "Today's Min RSI for Entry", tooltip = "The RSI must be below this number today to qualify for trade entry")
ExitRSI = input.int(70, "Exit RSI", tooltip = "The strategy will sell when the RSI crosses over this number")
Day3RSIMax = input.int(60, "Max RSI 3 Days Ago for Entry", tooltip = "The RSI must be below this number 3 days ago to qualify for trade entry")
EMAQualInput = input.bool(false, "Only enter trades when above qualifier EMA?", tooltip="When this is selected, a trade will only be entered when the price is above the EMA qualifier line.")
QEMA = ta.ema(close, input.int(200, "EMA Trade Qualifier Length"))

// Strategy Rules //
Rule1 = close>QEMA
Rule2 = RSI[3]<Day3RSIMax and RSI<TodaysMinRSI
Rule3 = RSI<RSI[1] and RSI[1]<RSI[2] and RSI[2]<RSI[3] 
Exit = ta.crossover(RSI, ExitRSI)

// Plot //
plot(QEMA, "200 Day EMA")

// Entry & Exit Functions //
if (InDateRange and Rule1 and Rule2 and Rule3 and EMAQualInput==true)
    strategy.entry("Long", strategy.long, alert_message="Long")
if (InDateRange and Rule2 and Rule3 and EMAQualInput==false)
    strategy.entry("Long", strategy.long, alert_message="Long")
if (InDateRange)
    strategy.close("Long", when = Exit, alert_message="Close Long")
if (not InDateRange)
    strategy.close_all(alert_message="Out of Date Range")
````
