<!-- tradingview-pine-id: PUB;7d50abffdaaf4a8aa26d6a441e59aabc -->
<!-- tradingviewscripts-format: 1 -->
# Universal Signal Backtester PRO [JFT]

Source: https://www.tradingview.com/script/OGzJZ1Nx-Universal-Signal-Backtester-PRO-JFT/

## Description

A professional trading performance analysis system designed for traders who want to test, evaluate, and improve their strategies with accurate data.
This powerful tool helps traders understand the real performance of their BUY and SELL systems before making live trading decisions.

Complete Features:
Universal Signal Testing System
Analyze any trading strategy and measure its historical performance with detailed statistics.
Automatic Trade Analysis
Tracks trades automatically and evaluates results without manual calculations.

Entry Detection System
Identifies trading entries and records performance from the moment a signal appears.
Smart Stop Loss Tracking
Monitors risk levels and shows whether trades reach Stop Loss or continue toward targets.
Multi Target Management
Complete TP1, TP2, and TP3 tracking to understand profit-taking performance.

Advanced Performance Dashboard
Displays essential trading statistics:
• Total Trades
• Winning Trades
• Losing Trades
• Win Rate Percentage
• Profit Factor
• Active Trade Status

Risk Reward Analysis
Evaluate the balance between risk and potential reward to improve strategy quality.
Strategy Performance Evaluation
Discover which setups perform better and optimize your trading approach.
Multi Market Support

Compatible with:
• Forex
• Gold (XAUUSD)
• Silver (XAGUSD)
• Crypto
• Indices
• Commodities

Clean Professional Interface
Designed with a simple chart layout to provide important information without unnecessary clutter.
Universal Signal Backtester PRO [JFT] is built for traders who believe in testing, statistics, and continuous improvement.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © JohnsonForexTrader

//@version=6
indicator("Universal Signal Backtester PRO [JFT]", shorttitle="USB PRO", overlay=true)

//━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━

group1 = "Settings"

stopPercent = input.float(1.0, "Stop Loss %", step=0.1, group=group1)
targetPercent = input.float(2.0, "Target %", step=0.1, group=group1)

showSignals = input.bool(true, "Show Entry", group=group1)


//━━━━━━━━━━━━━━━━━━
// SAMPLE SIGNAL ENGINE
// Replace later with any indicator signal
//━━━━━━━━━━━━━━━━━━

ema = ta.ema(close, 50)

buySignal =
     ta.crossover(close, ema)

sellSignal =
     ta.crossunder(close, ema)


//━━━━━━━━━━━━━━━━━━
// TRADE VARIABLES
//━━━━━━━━━━━━━━━━━━

var float entry = na
var float sl = na
var float tp = na

var bool inTrade = false
var bool longTrade = false


var int totalTrades = 0
var int winTrades = 0
var int lossTrades = 0



//━━━━━━━━━━━━━━━━━━
// OPEN TRADE
//━━━━━━━━━━━━━━━━━━

if buySignal and not inTrade

    entry := close
    sl := entry * (1 - stopPercent / 100)
    tp := entry * (1 + targetPercent / 100)

    inTrade := true
    longTrade := true

    totalTrades += 1



if sellSignal and not inTrade

    entry := close
    sl := entry * (1 + stopPercent / 100)
    tp := entry * (1 - targetPercent / 100)

    inTrade := true
    longTrade := false

    totalTrades += 1



//━━━━━━━━━━━━━━━━━━
// CLOSE TRADE
//━━━━━━━━━━━━━━━━━━

if inTrade

    if longTrade

        if low <= sl
            lossTrades += 1
            inTrade := false

        if high >= tp
            winTrades += 1
            inTrade := false


    else

        if high >= sl
            lossTrades += 1
            inTrade := false

        if low <= tp
            winTrades += 1
            inTrade := false



//━━━━━━━━━━━━━━━━━━
// SIGNAL DISPLAY
//━━━━━━━━━━━━━━━━━━

plotshape(
 showSignals and buySignal,
 title="BUY",
 text="BUY",
 style=shape.labelup,
 location=location.belowbar,
 color=color.lime,
 textcolor=color.black)


plotshape(
 showSignals and sellSignal,
 title="SELL",
 text="SELL",
 style=shape.labeldown,
 location=location.abovebar,
 color=color.red,
 textcolor=color.white)



//━━━━━━━━━━━━━━━━━━
// DASHBOARD
//━━━━━━━━━━━━━━━━━━

var table dash = table.new(position.top_right, 2, 4)

winRate = totalTrades > 0 ? (winTrades / totalTrades) * 100 : 0


if barstate.islast

    table.cell(dash,0,0,"Trades")
    table.cell(dash,1,0,str.tostring(totalTrades))

    table.cell(dash,0,1,"Wins")
    table.cell(dash,1,1,str.tostring(winTrades))

    table.cell(dash,0,2,"Loss")
    table.cell(dash,1,2,str.tostring(lossTrades))

    table.cell(dash,0,3,"Win Rate")
    table.cell(dash,1,3,str.tostring(winRate,"#.##")+"%")
    //━━━━━━━━━━━━━━━━━━
// PART 2
// MULTI TARGET BACKTEST
//━━━━━━━━━━━━━━━━━━

showTargets = input.bool(true, "Show TP Levels")

tp1RR = input.float(1.0, "TP1 RR")
tp2RR = input.float(2.0, "TP2 RR")
tp3RR = input.float(3.0, "TP3 RR")


//━━━━━━━━━━━━━━━━━━
// TARGET VARIABLES
//━━━━━━━━━━━━━━━━━━

var float tp1 = na
var float tp2 = na
var float tp3 = na

var bool tp1Hit = false
var bool tp2Hit = false
var bool tp3Hit = false


//━━━━━━━━━━━━━━━━━━
// CREATE TARGETS
//━━━━━━━━━━━━━━━━━━

if (buySignal or sellSignal) and not inTrade

    risk = math.abs(entry - sl)

    if longTrade
        tp1 := entry + risk * tp1RR
        tp2 := entry + risk * tp2RR
        tp3 := entry + risk * tp3RR

    else
        tp1 := entry - risk * tp1RR
        tp2 := entry - risk * tp2RR
        tp3 := entry - risk * tp3RR

    tp1Hit := false
    tp2Hit := false
    tp3Hit := false



//━━━━━━━━━━━━━━━━━━
// CHECK TARGETS
//━━━━━━━━━━━━━━━━━━

if inTrade

    if longTrade

        if high >= tp1
            tp1Hit := true

        if high >= tp2
            tp2Hit := true

        if high >= tp3
            tp3Hit := true


    else

        if low <= tp1
            tp1Hit := true

        if low <= tp2
            tp2Hit := true

        if low <= tp3
            tp3Hit := true



//━━━━━━━━━━━━━━━━━━
// DRAW ONLY ACTIVE TRADE
//━━━━━━━━━━━━━━━━━━

if showTargets and inTrade

    line.new(
     bar_index,
     entry,
     bar_index + 10,
     entry,
     color=color.blue)

    line.new(
     bar_index,
     sl,
     bar_index + 10,
     sl,
     color=color.red)

    line.new(
     bar_index,
     tp1,
     bar_index + 10,
     tp1,
     color=color.green)

    line.new(
     bar_index,
     tp2,
     bar_index + 10,
     tp2,
     color=color.lime)

    line.new(
     bar_index,
     tp3,
     bar_index + 10,
     tp3,
     color=color.aqua)
     //━━━━━━━━━━━━━━━━━━━━━━━━━━
// PART 3
// ADVANCED PERFORMANCE DASHBOARD FIX
//━━━━━━━━━━━━━━━━━━━━━━━━━━


//━━━━━━━━━━━━━━━━━━━━━━━━━━
// PROFIT TRACKING
//━━━━━━━━━━━━━━━━━━━━━━━━━━

var float jftProfit = 0.0
var float jftLoss = 0.0


//━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRADE PERFORMANCE
//━━━━━━━━━━━━━━━━━━━━━━━━━━

if not inTrade and not na(entry)

    if longTrade
        jftResult = close - entry

        if jftResult > 0
            jftProfit += jftResult
        else
            jftLoss += math.abs(jftResult)


    else
        jftResult = entry - close

        if jftResult > 0
            jftProfit += jftResult
        else
            jftLoss += math.abs(jftResult)



//━━━━━━━━━━━━━━━━━━━━━━━━━━
// STATISTICS
//━━━━━━━━━━━━━━━━━━━━━━━━━━

jftProfitFactor =
     jftLoss > 0 ? jftProfit / jftLoss : 0


jftWinRate =
     totalTrades > 0 ?
     (winTrades / totalTrades) * 100 :
     0



//━━━━━━━━━━━━━━━━━━━━━━━━━━
// FINAL DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━

var table jftPanel = table.new(
     position.bottom_right,
     2,
     7,
     border_width=1)


if barstate.islast

    table.cell(
     jftPanel,
     0,
     0,
     "JFT BACKTEST PRO")


    table.cell(
     jftPanel,
     0,
     1,
     "Trades")


    table.cell(
     jftPanel,
     1,
     1,
     str.tostring(totalTrades))


    table.cell(
     jftPanel,
     0,
     2,
     "Win Rate")


    table.cell(
     jftPanel,
     1,
     2,
     str.tostring(jftWinRate,"#.##")+"%")


    table.cell(
     jftPanel,
     0,
     3,
     "Wins")


    table.cell(
     jftPanel,
     1,
     3,
     str.tostring(winTrades))


    table.cell(
     jftPanel,
     0,
     4,
     "Loss")


    table.cell(
     jftPanel,
     1,
     4,
     str.tostring(lossTrades))


    table.cell(
     jftPanel,
     0,
     5,
     "Profit Factor")


    table.cell(
     jftPanel,
     1,
     5,
     str.tostring(jftProfitFactor,"#.##"))


    table.cell(
     jftPanel,
     0,
     6,
     "Status")


    table.cell(
     jftPanel,
     1,
     6,
     inTrade ? "ACTIVE" : "WAIT")
     //━━━━━━━━━━━━━━━━━━━━━━━━━━
// PART 4
// FINAL PROFESSIONAL PANEL
//━━━━━━━━━━━━━━━━━━━━━━━━━━

showFinalPanel = input.bool(true, "Show Final Panel")


//━━━━━━━━━━━━━━━━━━━━━━━━━━
// TP STATUS
//━━━━━━━━━━━━━━━━━━━━━━━━━━

jftTPStatus =
     tp3Hit ? "TP3 HIT" :
     tp2Hit ? "TP2 HIT" :
     tp1Hit ? "TP1 HIT" :
     inTrade ? "RUNNING" :
     "WAIT"


//━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRADE DIRECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━

jftDirection =
     inTrade ?
     (longTrade ? "LONG" : "SHORT") :
     "NONE"


//━━━━━━━━━━━━━━━━━━━━━━━━━━
// FINAL DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━

var table finalPanel = table.new(
     position.top_right,
     2,
     6,
     border_width=1)


if barstate.islast and showFinalPanel

    table.cell(
     finalPanel,
     0,
     0,
     "JFT SIGNAL TESTER")


    table.cell(
     finalPanel,
     0,
     1,
     "Direction")


    table.cell(
     finalPanel,
     1,
     1,
     jftDirection)


    table.cell(
     finalPanel,
     0,
     2,
     "Trade Status")


    table.cell(
     finalPanel,
     1,
     2,
     jftTPStatus)


    table.cell(
     finalPanel,
     0,
     3,
     "TP1")


    table.cell(
     finalPanel,
     1,
     3,
     tp1Hit ? "DONE" : "WAIT")


    table.cell(
     finalPanel,
     0,
     4,
     "TP2")


    table.cell(
     finalPanel,
     1,
     4,
     tp2Hit ? "DONE" : "WAIT")


    table.cell(
     finalPanel,
     0,
     5,
     "TP3")


    table.cell(
     finalPanel,
     1,
     5,
     tp3Hit ? "DONE" : "WAIT")



//━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
 buySignal,
 "JFT Backtester BUY",
 "New BUY Trade Detected")


alertcondition(
 sellSignal,
 "JFT Backtester SELL",
 "New SELL Trade Detected")
````
