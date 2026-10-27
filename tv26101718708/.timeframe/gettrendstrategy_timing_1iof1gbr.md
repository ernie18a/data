# GetTrendStrategy timing

- url: https://www.tradingview.com/script/1iof1GBr-gettrendstrategy-timing/
- type: strategy
- pine_id: PUB;DoLvbv0DqSNerZCOyEh5a9tfl9Y5a5vQ
- version: 1.0

## Description

In this version you can select a period of time. Use only for analysis not for trading.

## Source Code

````pine
//@version=2
strategy("GetTrendStrategy timing", overlay=true)
tim=input('370')
 
//////////////////////////////////////////////////////////////////////
// Component Code Start
testStartYear = input(2017, "Backtest Start Year")
testStartMonth = input(10, "Backtest Start Month")
testStartDay = input(25, "Backtest Start Day")
testStartHour = input(7, "Backtest Start Hour")
testPeriodStart = timestamp(testStartYear,testStartMonth,testStartDay,testStartHour,0)
testStopYear = input(2017, "Backtest Stop Year")
testStopMonth = input(10, "Backtest Stop Month")
testStopDay = input(30, "Backtest Stop Day")
testStopHour = input(13, "Backtest stop Hour")
testPeriodStop = timestamp(testStopYear,testStopMonth,testStopDay,testStartHour,0)
 
testPeriod() => time >= testPeriodStart and time <= testPeriodStop ? true : false
// Component Code Stop
//////////////////////////////////////////////////////////////////////
 
 
out1 = security(tickerid, tim, open)
out2 = security(tickerid, tim, close)
plot(out1,color=red)
plot(out2,color=green)
longCondition = crossover(security(tickerid, tim, close),security(tickerid, tim, open))
 
if testPeriod()
    if (longCondition)
        strategy.entry("long", strategy.long)
shortCondition = crossunder(security(tickerid, tim, close),security(tickerid, tim, open))
 
if testPeriod()
    if (shortCondition)
        strategy.entry("short", strategy.short)
````
