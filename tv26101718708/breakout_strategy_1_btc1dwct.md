# Breakout Strategy #1

- url: https://www.tradingview.com/script/BTC1dwCT-Breakout-Strategy-1/
- type: strategy
- pine_id: PUB;G5JxH5NZbsANqAJnXBtarRmjZ6Sd8qJC
- version: 2.0

## Description

Breakout above previous pivot points trigger a long. Close below pivot lows trigger the exit.
Most effective during trends.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Yo_adriiiiaan

//@version=4
strategy("Breakout Strategy", overlay = true, commission_type=strategy.commission.percent,commission_value=0, initial_capital = 1000,  default_qty_type=strategy.percent_of_equity, default_qty_value=100)
left =  input(10)
right = input(10)
pivot_high = 0.000
pivot_low = 0.000
pivot_high := nz(pivothigh(high,left,right), pivot_high[1])
pivot_low := nz(pivotlow(low,left,right), pivot_low[1])
plot(pivot_high)
plot(pivot_low)
breakout_bull = close > pivot_high[1]
breakdown_bear = close < pivot_low[1]

 
testStartYear = input(2017, "Backtest Start Year")
testStartMonth = input(8, "Backtest Start Month")
testStartDay = input(20, "Backtest Start Day")
testStartHour = input(0, "Backtest Start Hour")
testStartMin = input(0, "Backtest Start Minute")
testPeriodStart = timestamp(testStartYear,testStartMonth,testStartDay,testStartHour,testStartMin)
testStopYear = input(2099, "Backtest Stop Year")
testStopMonth = input(1, "Backtest Stop Month")
testStopDay = input(30, "Backtest Stop Day")
testPeriodStop = timestamp(testStopYear,testStopMonth,testStopDay,0,0)
testPeriod() =>
    time >= testPeriodStart and time <= testPeriodStop ? true : false
    
barcolor(close > pivot_high[1]? color.green:close < pivot_low[1]? color.red:close < pivot_high[1]? color.orange:na)
strategy.entry("Long", strategy.long, when = breakout_bull and testPeriod())
strategy.close_all(when = breakdown_bear and testPeriod()) 
//strategy.entry("Short", strategy.short, when = breakdown_bear)
alertcondition( breakout_bull, title = "Bullish Breakout")
alertcondition(breakdown_bear, title = "Bearish Breakdown")
````
