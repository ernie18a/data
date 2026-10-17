# Overnight Gap Analysis

- url: https://www.tradingview.com/script/rEZ9Pggd-Overnight-Gap-Analysis/
- type: strategy
- pine_id: PUB;d5b2a462f8d5435d9a428a34a46fe9ca
- version: 1.0

## Description

There is a wide range of opinion on holding positions overnight due to gap risk. So, out of curiosity, I coded this analysis as a strategy to see what the result of only holding a position overnight on an asset would be. The results really surprised me. The script backtests 10+ years, and here are the findings:

[list]
[*]Holding a position for 1 hour bar overnight on QQQ since January 2010 results in a 545% return. QQQ's entire return holding through the same period is 643%
[*]The max equity drawdown on holding that position overnight is lower then the buy/hold drawdown on the underlying asset.
[*]It doesn't matter if the last bar of the day is green or red, the results are similar.
[*]It doesn't matter if it is a bull or bear market. Filtering the script to only trade when the price is above the 200-day moving average actually reduces its return from 545% to 301%, though it does also reduce drawdown.
[*]I see similar patterns when applying the script to other index ETFs. Applying it to leveraged index ETFs can end up beating buy/hold of the underlying index.
[*]Since this script holds through the 1st bar of the day, this could also speak to a day-opening price pattern
[/list]

The default inputs are for the script to be applied to [b]1 hour charts only[/b] that have 7 bars on the chart per day. You can apply it to other chart types, but must follow the instructions below for it to work properly. 

[b]What the script is doing[/b]: 
This script is buying the close of the last bar of the day and closing the trade at the close of the next bar. So, all trades are being held for 1 bar. By default, the script is setup for use on a 1hr chart that has 7 bars per day. If you try to apply it to a different timeframe, you will need to adjust the count of the last bar of the day with the script input. I.e. There are 7 bars per day on an hour chart on US Stocks/ETFs, so the input is set to 7 by default. 

[b]Other ways this script can be used[/b]: 
This script can also test the result of holding a position over any 1 bar in the day using that same input. For instance, on an hour chart you can input 6 on the script input, and it will model buying the close of the 6th bar of the day while selling on the close of the next bar. I used this out of curiosity to model what only holding the last bar of the day would result in. On average, you lose money on the last bar every day.  

[b]The irony here is that the root cause of this last bar of the day losing may be people selling their positions at the end of day so that they aren't exposed to overnight gap risk.[/b]


Disclaimer: This is not financial advice. Open-source scripts I publish in the community are largely meant to spark ideas that can be used as building blocks for part of a more robust trade management strategy. If you would like to implement a version of any script, I would recommend making significant additions/modifications to the strategy & risk management functions. If you don’t know how to program in Pine, then hire a Pine-coder. We can help!

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// @version = 5
// Author = TradeAutomation


strategy(title="Overnight Gap Analysis", shorttitle="Overnight Gap Analysis", process_orders_on_close=true, calc_on_every_tick=false, overlay=true, commission_type=strategy.commission.cash_per_order, commission_value=1, slippage=0, initial_capital = 100000, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

// Default settings are for a 1 hour chart in a market that has 7 bars per day. The number of bars on the chart per day must be adjusted with an input for the script to work on other types of charts/markets. 
 
// Script Date Range Inputs  
StartTime = input.time(defval=timestamp('01 Jan 2010 05:00 +0000'), group="Script Date Range Settings", title='Start Time')
EndTime = input.time(defval=timestamp('01 Jan 2099 00:00 +0000'), group="Script Date Range Settings", title='End Time')
InDateRange = time>=StartTime and time<=EndTime

// Identifies the Last Bar of the Day
var todaybarcount = 0
todaybarcount := close and not ta.change(time_tradingday) ? todaybarcount + 1 : ta.change(time_tradingday) ? 1 : todaybarcount[1]

// Calculates Trigger and Filter Criteria
LongTrigger = todaybarcount==input.int(7, "Number of Bars on Your Chart Per Day", tooltip="This is used to identify the last bar of the day. A Long order is placed on the close of this bar")
EMAFilterInput = input.bool(false, "Only Enter Trade if Above EMA?")
EMAFilter = close>ta.ema(close, input.int(1400, "EMA Qual Length")) 
EnteredLastBar = ta.crossover(strategy.position_size, 0.5) ? 1 : 0

// Entry and Exit Functions
if (InDateRange and EMAFilterInput==true)
    strategy.entry("Long", strategy.long, when = LongTrigger and EMAFilter, alert_message="Buy")
if (InDateRange and EMAFilterInput==false)
    strategy.entry("Long", strategy.long, when = LongTrigger, alert_message="Buy")
if (InDateRange)
    strategy.close("Long", when = EnteredLastBar==1)
````
