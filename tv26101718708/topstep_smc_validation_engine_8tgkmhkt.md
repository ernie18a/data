# Topstep SMC Validation Engine

- url: https://www.tradingview.com/script/8tGKmHkt-Topstep-SMC-Validation-Engine/
- type: indicator
- pine_id: PUB;48ee8c3d170d48979587266d03690f5f
- version: 1.0

## Description

smc strat 5/11/26

testing and validating current strartegy

## Source Code

````pine
//@version=5
indicator("Topstep SMC Validation Engine", overlay=true, max_labels_count=500, max_boxes_count=500)

//====================================================
// SESSION FILTER (NY 9:30 -> 12:00)
//====================================================

sessionNY = input.session("0930-1200", "NY Session")
inSession = not na(time(timeframe.period, sessionNY))

//====================================================
// USER INPUTS
//====================================================

showFVG       = input.bool(true, "Show FVG")
showSignals   = input.bool(true, "Show Signals")
showLiquidity = input.bool(true, "Show Liquidity Sweeps")
showStats     = input.bool(true, "Show Stats")

rrTarget         = input.float(2.0, "RR Target", step=0.5)
stopBuffer       = input.float(5.0, "Stop Buffer")
swingLength      = input.int(5, "Swing Length")
displacementMult = input.float(1.5, "Displacement Threshold")

//====================================================
// ATR
//====================================================

atr = ta.atr(14)

//====================================================
// SWING HIGHS / LOWS
//====================================================

swingHigh = ta.pivothigh(high, swingLength, swingLength)
swingLow  = ta.pivotlow(low, swingLength, swingLength)

var float lastHigh = na
var float lastLow = na

if not na(swingHigh)
    lastHigh := swingHigh

if not na(swingLow)
    lastLow := swingLow

//====================================================
// LIQUIDITY SWEEPS
//====================================================

bullSweep = not na(lastLow) and low < lastLow and close > lastLow
bearSweep = not na(lastHigh) and high > lastHigh and close < lastHigh

plotshape(showLiquidity and bullSweep, title="Bull Sweep", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small)

plotshape(showLiquidity and bearSweep, title="Bear Sweep", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

//====================================================
// DISPLACEMENT + CISD
//====================================================

bullDisplacement = close > open and (close - open) > atr * 0.5 * displacementMult
bearDisplacement = close < open and (open - close) > atr * 0.5 * displacementMult

bullCISD = close > high[1]
bearCISD = close < low[1]

bullConfirm = bullSweep and bullDisplacement and bullCISD
bearConfirm = bearSweep and bearDisplacement and bearCISD

//====================================================
// FVG DETECTION
//====================================================

bullFVG = low > high[2]
bearFVG = high < low[2]

if showFVG and bullFVG
    box.new(
     left=bar_index-2,
     right=bar_index+5,
     top=low,
     bottom=high[2],
     bgcolor=color.new(color.green, 85),
     border_color=color.new(color.green, 50)
     )

if showFVG and bearFVG
    box.new(
     left=bar_index-2,
     right=bar_index+5,
     top=low[2],
     bottom=high,
     bgcolor=color.new(color.red, 85),
     border_color=color.new(color.red, 50)
     )

//====================================================
// ENTRY CONDITIONS
//====================================================

longEntry = inSession and bullConfirm and bullFVG
shortEntry = inSession and bearConfirm and bearFVG

//====================================================
// RISK MODEL
//====================================================

longStop = low - stopBuffer
shortStop = high + stopBuffer

longRisk = close - longStop
shortRisk = shortStop - close

longTarget = close + (longRisk * rrTarget)
shortTarget = close - (shortRisk * rrTarget)

//====================================================
// SIGNAL LABELS
//====================================================

if showSignals and longEntry
    label.new(
     bar_index,
     low,
     text="LONG\nSMC CONFIRM",
     style=label.style_label_up,
     color=color.lime,
     textcolor=color.black
     )

if showSignals and shortEntry
    label.new(
     bar_index,
     high,
     text="SHORT\nSMC CONFIRM",
     style=label.style_label_down,
     color=color.red,
     textcolor=color.white
     )

//====================================================
// PROBABILITY ENGINE
//====================================================

probability = 0

probability += (bullSweep or bearSweep) ? 25 : 0
probability += (bullDisplacement or bearDisplacement) ? 25 : 0
probability += (bullCISD or bearCISD) ? 25 : 0
probability += (bullFVG or bearFVG) ? 25 : 0

//====================================================
// TRADE STATS
//====================================================

var int totalTrades = 0
var int wins = 0

if longEntry or shortEntry
    totalTrades += 1

longWin = longEntry and high >= longTarget
shortWin = shortEntry and low <= shortTarget

if longWin or shortWin
    wins += 1

winRate = totalTrades > 0 ? (wins / totalTrades) * 100 : 0

//====================================================
// STATS TABLE
//====================================================

var table statsTable = table.new(position.top_right, 2, 5)

if showStats and barstate.islast

    table.cell(statsTable, 0, 0, "Trades")
    table.cell(statsTable, 1, 0, str.tostring(totalTrades))

    table.cell(statsTable, 0, 1, "Wins")
    table.cell(statsTable, 1, 1, str.tostring(wins))

    table.cell(statsTable, 0, 2, "Win Rate")
    table.cell(statsTable, 1, 2, str.tostring(math.round(winRate, 2)) + "%")

    table.cell(statsTable, 0, 3, "Probability")
    table.cell(statsTable, 1, 3, str.tostring(probability) + "%")

    table.cell(statsTable, 0, 4, "Session")
    table.cell(statsTable, 1, 4, inSession ? "ACTIVE" : "OFF")

//====================================================
// ALERTS
//====================================================

alertcondition(longEntry, title="Long Entry", message="Bullish SMC Setup")
alertcondition(shortEntry, title="Short Entry", message="Bearish SMC Setup")
````
