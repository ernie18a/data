# DCA Accumulator

- url: https://www.tradingview.com/script/3j0tWPL1-DCA-Accumulator/
- type: indicator
- pine_id: PUB;a64128331cc4478599d2528e465ed1f9
- version: 1.0

## Description

DCA Accumulator is a portfolio tracking indicator designed to help visualize a dollar-cost averaging plan on the currently selected chart symbol.

The script calculates scheduled purchases based on user-defined settings such as total capital, target number of buys, start date, buy frequency, and buy timing. The DCA amount is automatically calculated from the capital deployed divided by the target number of buys.

The indicator tracks:

* Number of completed buys
* Purchase date
* Purchase price
* Amount invested per buy
* Shares accumulated
* Total invested capital
* Average cost
* Current estimated position value
* Unrealized profit or loss

This tool is intended for planning, tracking, and educational analysis only. It does not generate buy or sell signals, does not predict future price movement, and does not guarantee any outcome. Values are based on chart data and the selected settings, so results may vary depending on symbol, timeframe, available history, and market conditions.

Past performance and historical chart behavior do not guarantee future results. This indicator should be used as one part of a broader research and risk management process, not as financial advice or a recommendation to buy, sell, or hold any asset.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MysticMads

//@version=6
indicator("DCA Accumulator", shorttitle="DCA Accum", overlay=false, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
capitalDeployed = input.float(10000.00, "Capital Deployed", minval=0.01, step=100.0)
targetBuys      = input.int(52, "Target Buys", minval=1, maxval=366)

// Auto-calculated from Capital Deployed / Target Buys
dcaAmount       = capitalDeployed / targetBuys

useCapitalLimit = input.bool(true, "Stop At Total Capital?")
totalCapital    = capitalDeployed

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Symbol Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// This script calculates the symbol currently open on the chart.
// No request.security() call is used because close/time already belong to the active chart symbol.
chartSymbol = syminfo.ticker

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Custom Start Date
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
useStartDate = input.bool(true, "Use Custom Start Date?")
startDate    = input.time(timestamp("2026-01-01T00:00:00"), "DCA Start Date")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DCA Schedule
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
buyFrequency = input.string(
     "Weekly",
     "Buy Frequency",
     options = ["Every Day", "Specific Day Of Week", "Weekly", "Monthly"]
)

customBuyDay = input.string(
     "Monday",
     "Custom Buy Day",
     options = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
)

buyTiming = input.string(
     "First Bar Of Period",
     "Buy Timing",
     options = ["First Bar Of Period", "Last Bar Of Prior Period"]
)

showTable = input.bool(true, "Show DCA Table")
showPlots = input.bool(true, "Show Invested / Value Plots")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// State Variables
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dcaTable = na

var int   buyCount         = 0
var float cumulativeCash   = 0.0
var float cumulativeShares = 0.0
var float avgCost          = na
var float currentValue     = na
var float unrealizedPnL    = na
var float unrealizedPnLPct = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Day Mapping
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
selectedDay =
     customBuyDay == "Monday"    ? dayofweek.monday :
     customBuyDay == "Tuesday"   ? dayofweek.tuesday :
     customBuyDay == "Wednesday" ? dayofweek.wednesday :
     customBuyDay == "Thursday"  ? dayofweek.thursday :
     customBuyDay == "Friday"    ? dayofweek.friday :
     customBuyDay == "Saturday"  ? dayofweek.saturday :
     dayofweek.sunday

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Period Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
newDay   = ta.change(time("D")) != 0
newWeek  = ta.change(time("W")) != 0
newMonth = ta.change(time("M")) != 0

isSelectedDayNow  = dayofweek(time) == selectedDay
isSelectedDayPrev = dayofweek(time[1]) == selectedDay

newPeriod =
     buyFrequency == "Every Day" ? newDay :
     buyFrequency == "Specific Day Of Week" ? (
         buyTiming == "First Bar Of Period"
             ? newDay and isSelectedDayNow
             : newDay and isSelectedDayPrev
       ) :
     buyFrequency == "Weekly" ? newWeek :
     buyFrequency == "Monthly" ? newMonth :
     false

// Current chart symbol price
buyPrice = buyTiming == "First Bar Of Period" ? close : close[1]
buyDate  = buyTiming == "First Bar Of Period" ? time  : time[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Start Date Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
afterStart        = useStartDate ? time >= startDate : true
buyDateAfterStart = useStartDate ? buyDate >= startDate : true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Capital / Buy Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
canBuyByTarget  = buyCount < targetBuys
canBuyByCapital = useCapitalLimit ? cumulativeCash < totalCapital : true

remainingCapital = totalCapital - cumulativeCash
actualBuyAmount  = useCapitalLimit ? math.min(dcaAmount, remainingCapital) : dcaAmount

validBuy =
     newPeriod and
     afterStart and
     buyDateAfterStart and
     canBuyByTarget and
     canBuyByCapital and
     not na(buyPrice) and
     actualBuyAmount > 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Table Setup
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if barstate.isfirst and showTable
    dcaTable := table.new(
         position = position.top_right,
         columns = 8,
         rows = 372,
         bgcolor = color.new(color.black, 15),
         border_color = color.new(color.gray, 40),
         border_width = 1
    )

    titleBg  = color.new(color.purple, 20)
    headerBg = color.new(color.blue, 20)

    table.cell(dcaTable, 0, 0, chartSymbol, text_color=color.white, text_size=size.small, bgcolor=titleBg)
    table.cell(dcaTable, 1, 0, "DCA Accumulator", text_color=color.white, text_size=size.small, bgcolor=titleBg)
    table.cell(dcaTable, 2, 0, buyFrequency, text_color=color.white, text_size=size.small, bgcolor=titleBg)
    table.cell(dcaTable, 3, 0, "$" + str.format("{0,number,#.##}", dcaAmount), text_color=color.white, text_size=size.small, bgcolor=titleBg)
    table.cell(dcaTable, 4, 0, "Target", text_color=color.white, text_size=size.small, bgcolor=titleBg)
    table.cell(dcaTable, 5, 0, str.tostring(targetBuys), text_color=color.white, text_size=size.small, bgcolor=titleBg)
    table.cell(dcaTable, 6, 0, "Capital", text_color=color.white, text_size=size.small, bgcolor=titleBg)
    table.cell(dcaTable, 7, 0, "$" + str.format("{0,number,#.##}", totalCapital), text_color=color.white, text_size=size.small, bgcolor=titleBg)

    table.cell(dcaTable, 0, 1, "Buy #",      text_color=color.white, text_size=size.small, bgcolor=headerBg)
    table.cell(dcaTable, 1, 1, "Date",       text_color=color.white, text_size=size.small, bgcolor=headerBg)
    table.cell(dcaTable, 2, 1, "Price",      text_color=color.white, text_size=size.small, bgcolor=headerBg)
    table.cell(dcaTable, 3, 1, "Amount",     text_color=color.white, text_size=size.small, bgcolor=headerBg)
    table.cell(dcaTable, 4, 1, "Shares",     text_color=color.white, text_size=size.small, bgcolor=headerBg)
    table.cell(dcaTable, 5, 1, "Cum Shares", text_color=color.white, text_size=size.small, bgcolor=headerBg)
    table.cell(dcaTable, 6, 1, "Invested",   text_color=color.white, text_size=size.small, bgcolor=headerBg)
    table.cell(dcaTable, 7, 1, "Avg Cost",   text_color=color.white, text_size=size.small, bgcolor=headerBg)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DCA Execution
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if barstate.isconfirmed and validBuy
    buyCount += 1

    sharesBought = actualBuyAmount / buyPrice

    cumulativeCash   += actualBuyAmount
    cumulativeShares += sharesBought
    avgCost          := cumulativeCash / cumulativeShares

    row = buyCount + 1

    if showTable and not na(dcaTable) and buyCount <= 366
        isBelowAvg = buyPrice < avgCost
        priceColor = isBelowAvg ? color.lime : color.white

        table.cell(dcaTable, 0, row, str.tostring(buyCount), text_color=color.white, text_size=size.tiny)
        table.cell(dcaTable, 1, row, str.format("{0,date,MM/dd/yy}", buyDate), text_color=color.white, text_size=size.tiny)
        table.cell(dcaTable, 2, row, "$" + str.format("{0,number,#.##}", buyPrice), text_color=priceColor, text_size=size.tiny)
        table.cell(dcaTable, 3, row, "$" + str.format("{0,number,#.##}", actualBuyAmount), text_color=color.white, text_size=size.tiny)
        table.cell(dcaTable, 4, row, str.format("{0,number,#.####}", sharesBought), text_color=color.white, text_size=size.tiny)
        table.cell(dcaTable, 5, row, str.format("{0,number,#.####}", cumulativeShares), text_color=color.white, text_size=size.tiny)
        table.cell(dcaTable, 6, row, "$" + str.format("{0,number,#.##}", cumulativeCash), text_color=color.white, text_size=size.tiny)
        table.cell(dcaTable, 7, row, "$" + str.format("{0,number,#.##}", avgCost), text_color=color.yellow, text_size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Live Portfolio Value
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
currentValue     := cumulativeShares * close
unrealizedPnL    := currentValue - cumulativeCash
unrealizedPnLPct := cumulativeCash > 0 ? unrealizedPnL / cumulativeCash * 100 : na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Summary Row
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if barstate.islast and showTable and not na(dcaTable)
    summaryRow = 369

    pnlColor  = unrealizedPnL >= 0 ? color.lime : color.red
    summaryBg = color.new(color.gray, 70)

    table.cell(dcaTable, 0, summaryRow, "Summary", text_color=color.white, text_size=size.small, bgcolor=summaryBg)
    table.cell(dcaTable, 1, summaryRow, "Buys: " + str.tostring(buyCount), text_color=color.white, text_size=size.small, bgcolor=summaryBg)
    table.cell(dcaTable, 2, summaryRow, "Now: $" + str.format("{0,number,#.##}", close), text_color=color.white, text_size=size.small, bgcolor=summaryBg)
    table.cell(dcaTable, 3, summaryRow, "Value", text_color=color.white, text_size=size.small, bgcolor=summaryBg)
    table.cell(dcaTable, 4, summaryRow, "$" + str.format("{0,number,#.##}", currentValue), text_color=color.white, text_size=size.small, bgcolor=summaryBg)
    table.cell(dcaTable, 5, summaryRow, "P/L", text_color=color.white, text_size=size.small, bgcolor=summaryBg)
    table.cell(dcaTable, 6, summaryRow, "$" + str.format("{0,number,#.##}", unrealizedPnL), text_color=pnlColor, text_size=size.small, bgcolor=summaryBg)
    table.cell(dcaTable, 7, summaryRow, str.format("{0,number,#.##}", unrealizedPnLPct) + "%", text_color=pnlColor, text_size=size.small, bgcolor=summaryBg)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Plots
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(showPlots ? cumulativeCash : na, title="Total Invested", linewidth=2)
plot(showPlots ? currentValue : na, title="Current Value", linewidth=2)
plot(showPlots ? avgCost : na, title="Average Cost", linewidth=2)
````
