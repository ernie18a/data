# Buy and Hold, which day of month is best to buy?

- url: https://www.tradingview.com/script/zw7TUjjg-Buy-and-Hold-which-day-of-month-is-best-to-buy/
- type: strategy
- pine_id: PUB;8990226e6a1c45bbbe3f16094436857b
- version: 1.0

## Description

I wanted to invest a certain fiat amount each month and was wondering which day would be best to do this.

So, with this script, you can set your entry day. On the last day of the date range, it will close all positions. You can then see what amount of the asset you have accumulated to date. If you try all the days of the month and see when you can sell the most amount of the asset, you've found the best buy date of the month for that asset.

A second option is to set an exit day. This is good for a strategy where you would go long (buy) on the entry date and short (sell) on the exit day.
This was inspired by people running out of money by the end of the month and selling their asset, which could make the price fall. Then when they receive the wages by the 5th or so, they would rebuy, causing the price to go up.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dennis.decoene

//@version=4
strategy(title="Buy and Hold, which day of month is best to buy?", overlay=true, pyramiding=20000)

// Make input options that configure backtest date range
startDate = input(title="Start Date", type=input.integer,
     defval=1, minval=1, maxval=31, group="Starting From")
     
startMonth = input(title="Start Month", type=input.integer,
     defval=1, minval=1, maxval=12, group="Starting From")
     
startYear = input(title="Start Year", type=input.integer,
     defval=2021, minval=1800, maxval=2100, group="Starting From")

endDate = input(title="End Date", type=input.integer,
     defval=2, minval=1, maxval=31, group="Until")
endMonth = input(title="End Month", type=input.integer,
     defval=10, minval=1, maxval=12, group="Until")
endYear = input(title="End Year", type=input.integer,
     defval=2021, minval=1800, maxval=2100, group="Until")

entryday = input(title="Entry Day", type=input.integer,
     defval=26, minval=1, maxval=31, tooltip="When to enter (buy the asset) each month")
exitday = input(title="Exit Day", type=input.integer,
     defval=6, minval=1, maxval=31, tooltip="When to exit (sell the asset) each month")
     
useExitDay= input(title="Close position on exit day?", type=input.bool, defval=false, tooltip="Use the Exit Day to close each months position it true or close at the end of the period (if false)")
     
isEntryDay= (dayofmonth(time)==entryday)
isExitDay= (dayofmonth(time)==exitday-1)


inDateRange = (time >= timestamp(syminfo.timezone, startYear,
         startMonth, startDate, 0, 0)) and
     (time < timestamp(syminfo.timezone, endYear, endMonth, endDate, 0, 0))

if (isEntryDay and inDateRange)
    strategy.entry(id="Buy", long=true)
    
if (isExitDay and useExitDay)
    strategy.close_all()


// Exit open market position when date range ends
if (not inDateRange and not useExitDay)
    strategy.close_all()
````
