# Buy/Sell Signals: SMA + Volume + Trade Profit

- url: https://www.tradingview.com/script/nBN4MxUX-Buy-Sell-Signals-SMA-Volume-Trade-Profit/
- type: indicator
- pine_id: PUB;70dd5a30d24a44d9823555deb824456b
- version: 1.0

## Description

This indicator generates buy and sell signals using SMA 150, SMA 50, candle color, and volume conditions.
A buy signal appears when a green candle closes above the SMA 150, remains within the selected maximum percentage above it, closes above the SMA 50, and has above-average volume.
A sell signal appears on the first candle that closes below the SMA 50 after a buy signal.
The indicator tracks each completed trade and displays the profit/loss percentage on the sell candle. It also includes a summary table showing trade count, average profit, total compounded profit, average yearly profit, time spent in trades, and yearly capital-efficiency adjusted for exposure time.
The checked time period is configurable in years.

## Source Code

````pine
//@version=6
indicator("Buy/Sell Signals: SMA + Volume + Trade Profit", overlay=true)
// Inputs
sma150Len   = input.int(150, "SMA 150 Length", minval=1)
sma50Len    = input.int(50, "SMA 50 Length", minval=1)
volLen      = input.int(20, "Average Volume Length", minval=1)
maxAbovePct = input.float(5.0, "Max % Above SMA 150", minval=0.0, step=0.1)
yearsBack   = input.int(5, "Years Checked", minval=1, maxval=50)
onlyClosed  = input.bool(true, "Only Signal After Candle Close")
// Calculations
sma150 = ta.sma(close, sma150Len)
sma50  = ta.sma(close, sma50Len)
avgVol = ta.sma(volume, volLen)
// Buy conditions
isGreen = close > open
closedAboveSMA150 = close > sma150
notTooFarAbove150 = close <= sma150 * (1 + maxAbovePct / 100)
closedAboveSMA50 = close > sma50
volumeAboveAvg = volume > avgVol
confirmedOk = onlyClosed ? barstate.isconfirmed : true
rawBuySignal =
     confirmedOk and
     isGreen and
     closedAboveSMA150 and
     notTooFarAbove150 and
     closedAboveSMA50 and
     volumeAboveAvg
// Sell condition: first candle that closes under SMA 50
rawSellSignal =
     confirmedOk and
     ta.crossunder(close, sma50)
// Trade state
var bool inTrade = false
var float entryPrice = na
var int entryTime = na
// Checked-period stats
periodStartTime = timestamp(year(timenow) - yearsBack, month(timenow), dayofmonth(timenow), 0, 0)
var float sumProfit = 0.0
var int tradeCount = 0
var float equityMultiplier = 1.0
// Time inside trade, in milliseconds
var int timeInTradeMs = 0
// Final signals
buySignal = rawBuySignal and not inTrade
sellSignal = rawSellSignal and inTrade
// Buy logic
if buySignal
    entryPrice := close
    entryTime := time_close
    inTrade := true
// Sell logic
if sellSignal
    profitPct = ((close - entryPrice) / entryPrice) * 100
    // Count only trades opened inside the checked period
    if entryTime >= periodStartTime
        sumProfit += profitPct
        tradeCount += 1
        equityMultiplier *= (1 + profitPct / 100)
    // Count time inside trade, clipped to checked period
    tradeStartTime = math.max(entryTime, periodStartTime)
    tradeEndTime = time_close
    if tradeEndTime > periodStartTime
        timeInTradeMs += math.max(0, tradeEndTime - tradeStartTime)
    label.new(
         bar_index,
         high,
         "SELL\n" + str.tostring(profitPct, "#.##") + "%",
         style=label.style_label_down,
         color=profitPct >= 0 ? color.green : color.red,
         textcolor=color.white,
         size=size.small
    )
    inTrade := false
    entryPrice := na
    entryTime := na
// Stats
avgProfit = tradeCount > 0 ? sumProfit / tradeCount : na
totalProfit = (equityMultiplier - 1) * 100
avgProfitPerYear =
     tradeCount > 0
     ? (math.pow(equityMultiplier, 1.0 / yearsBack) - 1) * 100
     : na
// Add current open trade time if we are still inside a trade
entryTimeSafe = na(entryTime) ? periodStartTime : entryTime
currentOpenTradeMs =
     inTrade
     ? math.max(0, time_close - math.max(entryTimeSafe, periodStartTime))
     : 0
totalTimeInTradeMs = timeInTradeMs + currentOpenTradeMs
totalPeriodMs = timenow - periodStartTime
pctTimeInTrade =
     totalPeriodMs > 0
     ? (totalTimeInTradeMs / totalPeriodMs) * 100
     : na
// Simple yearly capital-efficiency score
// Example over 5 years:
// 20% total profit, 20% time in trade
// yearly profit = 20 / 5 = 4%
// capital efficiency/year = 4 / 0.20 = 20%
simpleProfitPerYear = totalProfit / yearsBack
capitalEfficiencyPerYear =
     tradeCount > 0 and pctTimeInTrade > 0
     ? simpleProfitPerYear / (pctTimeInTrade / 100)
     : na
// Plots
plot(sma150, "SMA 150", color=color.orange, linewidth=2)
plot(sma50, "SMA 50", color=color.blue, linewidth=2)
// Buy marker
plotshape(
     buySignal,
     title="Buy Signal",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     size=size.small,
     text="BUY"
)
// Sell marker
plotshape(
     sellSignal,
     title="Sell Signal",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.tiny
)
// Stats table
var table statsTable = table.new(position.top_right, 1, 6)
if barstate.islast
    table.cell(
         statsTable,
         0,
         0,
         "Last " + str.tostring(yearsBack) + "Y closed trades: " + str.tostring(tradeCount),
         text_color=color.white,
         bgcolor=color.black
    )
    table.cell(
         statsTable,
         0,
         1,
         "Avg profit/trade: " + (tradeCount > 0 ? str.tostring(avgProfit, "#.##") + "%" : "N/A"),
         text_color=color.white,
         bgcolor=color.black
    )
    table.cell(
         statsTable,
         0,
         2,
         "Total profit: " + (tradeCount > 0 ? str.tostring(totalProfit, "#.##") + "%" : "N/A"),
         text_color=color.white,
         bgcolor=color.black
    )
    table.cell(
         statsTable,
         0,
         3,
         "Avg profit/year: " + (tradeCount > 0 ? str.tostring(avgProfitPerYear, "#.##") + "%" : "N/A"),
         text_color=color.white,
         bgcolor=color.black
    )
    table.cell(
         statsTable,
         0,
         4,
         "% time in trade: " + str.tostring(pctTimeInTrade, "#.##") + "%",
         text_color=color.white,
         bgcolor=color.black
    )
    table.cell(
         statsTable,
         0,
         5,
         "Capital efficiency/year: " + (tradeCount > 0 and pctTimeInTrade > 0 ? str.tostring(capitalEfficiencyPerYear, "#.##") + "%" : "N/A"),
         text_color=color.white,
         bgcolor=color.black
    )
// Alerts
alertcondition(
     buySignal,
     title="Buy Signal",
     message="Buy signal: green candle, above SMA150 within max %, above SMA50, and volume above average."
)
alertcondition(
     sellSignal,
     title="Sell Signal",
     message="Sell signal: first candle closed under SMA50."
)
````
