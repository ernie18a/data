# Easy to Use 50/100/200 Day Moving Average Strategy

- url: https://www.tradingview.com/script/xQySH7CQ-Easy-to-Use-50-100-200-Day-Moving-Average-Strategy/
- type: strategy
- pine_id: PUB;ndmYsOuiNVgwMz9JYGDlIPT439ZmsP5a
- version: 1.0

## Description

Whenever you see someone publish a chart or idea, what's the one thing you almost always see? Moving Averages!

Many investors focus on these indictors solely as entry and exit points, so here's an easy to manipulate strategy to backtest and see if this is feasible on your security.

[b]CODE VARIABLES[/b]
[b]LINE 2[/b] - Here you can change your currency and amount you want to invest on each entry.
[b]LINE 8/9/10[/b] - Here we establish the 50 (Fast), 100 (Medium) and 200 (Slow) day variables. These can be adjusted to your choosing.
[b]LINE 13/14/15[/b] - Here we establish what date we want to start backtesting from. Simple change the [i]defval [/i] on each line to change the date (In the code below we start on Jan 1st, 2010).
[b]LINE 20/23[/b] - Here, within the [i]crossover[/i] and [i]crossunder[/i] functions, we set which MA's must cross to enter and exit a trade. Below we have the 50 day moving above and under the 200 day. Simple change the variables to FastMA, MediumMA and SlowMA to your choosing.

[b]NOTE:[/b] As a beginner you may not want to short stock, therefore LINE 5 was added to only allow long positions.

Hope this helps, from one beginner to another.

Cheers!

## Source Code

````pine
//@version=3
strategy(title="50/100/200 Moving Average Strategy", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=100, initial_capital=10000, currency=currency.CAD)

// Only Enter Long Positions //
strategy.risk.allow_entry_in(strategy.direction.long)

// Create Inputs //
FastMA      =sma(close,50)
MediumMA    =sma(close,100)
SlowMA      =sma(close,200)

// Backtest Start Date Inputs //
startDate   = input(title="Start Date",  type=integer,   defval=1,    minval=1,    maxval=31)
startMonth  = input(title="Start Month", type=integer,   defval=1,    minval=1,    maxval=12)
startYear   = input(title="Start Year",  type=integer,   defval=2010, minval=1800, maxval=2100)

afterStartDate = (time >= timestamp(syminfo.timezone, startYear, startMonth, startDate, 0, 0))

// Submit Orders //
if (afterStartDate and crossover(FastMA, SlowMA))
    strategy.entry(id="BUY", long=true)

if (afterStartDate and crossunder(FastMA, SlowMA))
    strategy.entry(id="SELL", long=false)
````
