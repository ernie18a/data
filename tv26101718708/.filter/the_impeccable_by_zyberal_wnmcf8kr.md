# The Impeccable by zyberal

- url: https://www.tradingview.com/script/WNmcF8Kr-The-Impeccable-by-zyberal/
- type: strategy
- pine_id: PUB;59ebf8b52f7f443abfb2a50a08a13d31
- version: 1.0

## Description

This strategy works differently than others, it uses the IchimokuTenkan, Kijun, and Senkou periods to compute a general sense of market trend. Then I used the MACD fast, slow, and smooth with custom inputs to compute a optimum cross for finding macro bottoms and tops for any asset. This strategy doesn't trade on weekends and does not have a set TP (take profit) for each long or short.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Revazi

//@version=5
strategy("The Impeccable by zyberal", overlay = true)

// Inputs {
// Strategy variables
IchimokuTenkanPeriod = input(9)
IchimokuKijunPeriod = input(190)
IchimokuSenkouPeriod = input(52)
MACDMainFast = input(3)
MACDMainSlow = input(10)
MACDMainSmooth = input(9)
ExitAfterBars = input(2)
ProfitTarget = input(135)
StopLoss = input(70)

// Trading Options
DontTradeOnWeekends = input(true)
ExitAtEndOfDay = input(true)
DayExitTimeHour   = input(23)
DayExitTimeMinute = input(04)

ExitOnFriday = input(true)
FridayExitTimeHour   = input(20)
FridayExitTimeMinute = input(40)

// }



// TRADING OPTIONS LOGIC {
OpenOrdersAllowed = true

// Dont trade on weekends {
if DontTradeOnWeekends
    if dayofweek == dayofweek.saturday or
       dayofweek == dayofweek.sunday
        OpenOrdersAllowed := false
// }

// Exit on close (end of day) {
if ExitAtEndOfDay
    if timeframe.isintraday and
       time >= timestamp(year(timenow), month(timenow), dayofmonth(timenow), DayExitTimeHour, DayExitTimeMinute)
        OpenOrdersAllowed := false
// }

// Exit on Friday {
if ExitOnFriday
    if timeframe.isintraday and
       time >= timestamp(year(timenow), month(timenow), dayofmonth(timenow), FridayExitTimeHour, FridayExitTimeMinute)
        OpenOrdersAllowed := false
// }


// Rule: Trading signals {
openW3 = request.security(syminfo.tickerid, "W", open)[3]

middleDonchian(Length) => math.avg(ta.highest(Length), ta.lowest(Length))
Tenkan = middleDonchian(IchimokuTenkanPeriod)[2]

[macdLine, signalLine, _] = ta.macd(close, MACDMainFast, MACDMainSlow, MACDMainSmooth)

LongEntrySignal = openW3 > Tenkan and ta.crossunder(macdLine, signalLine)[3] //macdLine[3] < signalLine[3]
ShortEntrySignal = openW3 < Tenkan and ta.crossover(macdLine, signalLine)[3] //macdLine[3] > signalLine[3]
// }



// Calculate conditions {
IsFlat() => strategy.position_size == 0
IsLong() => strategy.position_size > 0
IsShort() => strategy.position_size < 0

longCondition  = OpenOrdersAllowed and not IsLong() and LongEntrySignal
shortCondition = OpenOrdersAllowed and not IsShort() and ShortEntrySignal

// }

// Open positions based on conditions {
strategy.order(id = "buy", direction = strategy.long, qty = 1, when = longCondition)
strategy.order(id = "sell", direction = strategy.short, qty = 1, when = shortCondition)
// }
````
