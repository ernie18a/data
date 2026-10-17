# Volatility-Adjusted Position Sizer [Futures]

- url: https://www.tradingview.com/script/JckoMBeD-Volatility-Adjusted-Position-Sizer-Futures/
- type: indicator
- pine_id: PUB;b4397aa50657433eb7d33df080187804
- version: 1.0

## Description

This is an adjustable on chart mechanism to help determine position size based on volatility and current ATR.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © strades55

//@version=5
indicator("Volatility-Adjusted Position Sizer [Futures]", overlay=true, max_labels_count=500)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
grp_account = "Account Settings"
accountSize   = input.float(4000.0, "Account Size ($)", minval=100, group=grp_account)
riskPct       = input.float(10.0, "Risk Per Trade (%)", minval=0.1, maxval=100, step=0.1, group=grp_account)
contractValue = input.float(1.0, "Contract Point Value ($)", minval=0.01, group=grp_account)
tickSize      = input.float(0.25, "Tick Size", minval=0.0001, group=grp_account)

grp_atr = "ATR Stop Settings"
atrPeriod = input.int(14, "ATR Period", minval=1, group=grp_atr)
atrMult   = input.float(1.5, "ATR Multiplier", minval=0.1, step=0.1, group=grp_atr)
tradeDir  = input.string("Long", "Trade Direction", options=["Long", "Short"], group=grp_atr)

grp_rr = "Risk / Reward"
rrRatio = input.float(2.0, "Target R:R Ratio", minval=0.1, step=0.1, group=grp_rr)

grp_vol = "Volatility Adjustment"
volLookback = input.int(20, "Volatility Lookback", minval=5, group=grp_vol)
volScaleMin = input.float(0.5, "Min Vol Scale", minval=0.1, group=grp_vol)
volScaleMax = input.float(1.5, "Max Vol Scale", minval=0.5, group=grp_vol)

grp_disp = "Display"
showTable     = input.bool(true, "Show Info Table", group=grp_disp)
showStopLines = input.bool(true, "Show Stop / Target Lines", group=grp_disp)
showATRBand   = input.bool(true, "Show ATR Band", group=grp_disp)
tablePos      = input.string("Bottom Right", "Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Top Center","Bottom Center"], group=grp_disp)

// ─────────────────────────────────────────────
// FUNCTION (SAFE FORMAT)
// ─────────────────────────────────────────────
f_row(_table, idx, lbl, val, valColor) =>
    table.cell(_table, 0, idx, lbl, text_color=color.new(color.gray, 10), text_size=size.large, text_halign=text.align_left)
    table.cell(_table, 1, idx, val, text_color=valColor, text_size=size.large, text_halign=text.align_right)

// ─────────────────────────────────────────────
// CORE CALCULATIONS
// ─────────────────────────────────────────────
atr = ta.atr(atrPeriod)

stopDist = atr * atrMult
stopDistTicked = math.round(stopDist / tickSize) * tickSize

entryPrice = close

stopPrice   = tradeDir == "Long" ? entryPrice - stopDistTicked : entryPrice + stopDistTicked
targetPrice = tradeDir == "Long" ? entryPrice + stopDistTicked * rrRatio : entryPrice - stopDistTicked * rrRatio

atrAvg      = ta.sma(atr, volLookback)
rawVolScale = atrAvg / atr
volScale    = math.max(volScaleMin, math.min(volScaleMax, rawVolScale))

maxRiskDollars = accountSize * (riskPct / 100)
adjRiskDollars = maxRiskDollars * volScale

riskPerContract = stopDistTicked * contractValue
contracts = riskPerContract > 0 ? math.floor(adjRiskDollars / riskPerContract) : 0
contracts := math.max(1, contracts)

actualRisk      = contracts * riskPerContract
actualRiskPct   = (actualRisk / accountSize) * 100
potentialProfit = contracts * stopDistTicked * rrRatio * contractValue

// ─────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────
plot(showStopLines ? entryPrice  : na, title="Entry", color=color.yellow)
plot(showStopLines ? stopPrice   : na, title="Stop", color=color.red, linewidth=2)
plot(showStopLines ? targetPrice : na, title="Target", color=color.green, linewidth=2)

atrBandU = entryPrice + atr
atrBandL = entryPrice - atr

plot(showATRBand ? atrBandU : na, title="ATR High", color=color.new(color.blue, 75))
plot(showATRBand ? atrBandL : na, title="ATR Low", color=color.new(color.blue, 75))

// ─────────────────────────────────────────────
// LABELS (LAST BAR ONLY)
// ─────────────────────────────────────────────
if barstate.islast and showStopLines
    label.new(bar_index + 1, entryPrice,  "ENTRY\n" + str.tostring(entryPrice, "#.##"), color=color.yellow, textcolor=color.black)
    label.new(bar_index + 1, stopPrice,   "STOP\n" + str.tostring(stopPrice, "#.##"), color=color.red, textcolor=color.white)
    label.new(bar_index + 1, targetPrice, "TARGET\n" + str.tostring(targetPrice, "#.##"), color=color.green, textcolor=color.white)

// ─────────────────────────────────────────────
// TABLE
// ─────────────────────────────────────────────
var table infoTable = na

tblPos = switch tablePos
    "Top Right"     => position.top_right
    "Top Left"      => position.top_left
    "Bottom Right"  => position.bottom_right
    "Bottom Left"   => position.bottom_left
    "Top Center"    => position.top_center
    => position.bottom_center

if showTable
    if na(infoTable)
        infoTable := table.new(tblPos, 2, 12, bgcolor=color.new(color.black, 20))

    riskColor = actualRiskPct > riskPct ? color.red : color.green

    table.cell(infoTable, 0, 0, "⚡ POSITION SIZER", text_color=color.white)
    table.cell(infoTable, 1, 0, tradeDir + " | Futures", text_color=color.yellow)

    f_row(infoTable, 1,  "Account Size",   "$" + str.tostring(accountSize, "#,###"), color.white)
    f_row(infoTable, 2,  "Max Risk $",     "$" + str.tostring(maxRiskDollars, "#,###"), color.orange)
    f_row(infoTable, 3,  "Vol Scale",      str.tostring(volScale, "#.##") + "x", volScale < 1 ? color.red : color.green)
    f_row(infoTable, 4,  "Adj Risk $",     "$" + str.tostring(adjRiskDollars, "#,###"), color.orange)
    f_row(infoTable, 5,  "ATR",            str.tostring(atr, "#.##"), color.aqua)
    f_row(infoTable, 6,  "Stop Dist",      str.tostring(stopDistTicked, "#.##"), color.red)
    f_row(infoTable, 7,  "Risk/Contract",  "$" + str.tostring(riskPerContract, "#.##"), color.white)
    f_row(infoTable, 8,  "Contracts",      str.tostring(contracts), color.yellow)
    f_row(infoTable, 9,  "Actual Risk $",  "$" + str.tostring(actualRisk, "#.##"), riskColor)
    f_row(infoTable, 10, "Actual Risk %",  str.tostring(actualRiskPct, "#.##") + "%", riskColor)
    f_row(infoTable, 11, "Profit",         "$" + str.tostring(potentialProfit, "#.##"), color.green)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
alertcondition(ta.crossunder(close, stopPrice) and tradeDir == "Long",  title="Stop Hit Long")
alertcondition(ta.crossover(close, stopPrice)  and tradeDir == "Short", title="Stop Hit Short")
alertcondition(ta.crossover(close, targetPrice) and tradeDir == "Long", title="Target Hit Long")
alertcondition(ta.crossunder(close, targetPrice) and tradeDir == "Short", title="Target Hit Short")
````
