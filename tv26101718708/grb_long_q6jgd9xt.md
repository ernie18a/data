# GRB Long

- url: https://www.tradingview.com/script/Q6jGd9xT-GRB-Long/
- type: strategy
- pine_id: PUB;b5ede6ee439d45ecb87c1ebea023d3ca
- version: 2.0

## Description

This strategy generates swing trading signals based on the Golden Ratio Breakout. This is a long-only strategy, entry is breakout and retest of 38.2 fib level and SL is 23.6 fib level from last 21 days. These are only suggestions and NOT recommendations. Please do your own due diligence before taking ANY action. No responsibility for any profits/LOSSES.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © omkarkondhekar

//@version=4
strategy("GRBLong", overlay=true)

highInput = input(title = "High Days", type = input.integer, defval = 21, minval = 11)
lowInput = input(title = "Low Days", type = input.integer, defval = 21, minval = 5)

// Configure backtest start date with inputs
startDate = input(title="Start Date", type=input.integer,
     defval=1, minval=1, maxval=31)
startMonth = input(title="Start Month", type=input.integer,
     defval=1, minval=1, maxval=12)
startYear = input(title="Start Year", type=input.integer,
     defval=2019, minval=1800, maxval=2100)

// See if this bar's time happened on/after start date
afterStartDate = (time >= timestamp(syminfo.timezone,
     startYear, startMonth, startDate, 0, 0))

high21 = highest(high, highInput)
low21 = lowest(low, lowInput)

diff = high21 - low21

longEntrySignal = low > low21 + (diff * 0.382) and close[1] > open[1] 

strategy.entry("Long", strategy.long, when = longEntrySignal and afterStartDate)
strategy.exit("Long Exit", "Long", stop = low21 + (diff * 0.236))

plot(low21 + (diff * 0.382), color= color.green)
plot(low21 + (diff * 0.236), color = color.red)
````
