# Trade checklist

- url: https://www.tradingview.com/script/3GqSyMPW/
- type: indicator
- pine_id: PUB;f85c74dc08024a489f2cf136cc30fdd2
- version: 1.0

## Description

Full Description
Trade Checklist – ICT / SMC Multi-Timeframe

This indicator was built to help traders objectively evaluate ICT / Smart Money Concepts setups using a structured multi-timeframe framework.

Instead of relying on discretion alone, the script converts key SMC concepts into a checklist-based scoring model.

The goal is simple:

Filter low-quality setups
Improve execution discipline
Avoid emotional entries
Trade only when multiple confirmations align
Multi-Timeframe Framework

The script analyzes 4 different timeframes:

Monthly (Macro Bias)

Used to determine overall directional bias.

Checks:

Trend alignment (EMA structure)
Market structure coherence
Available room to opposing zone
Weekly (Location)

Used to determine whether price is trading in a favorable area.

Checks:

Valid supply / demand zone
Premium / Discount positioning
Nearby liquidity pools
Daily (Confirmation)

Used to validate institutional intent.

Checks:

Liquidity sweep
Rejection
Market Structure Shift (MSS / BOS)
Displacement strength
4H (Execution)

Used for precise entry timing.

Checks:

Fair Value Gap presence
Trigger confirmation
Risk / Reward validation
Scoring System

Each condition contributes points.

Final score determines setup quality:

0–9 → NO TRADE
10–12 → WATCH
13+ → TRADE

This creates an objective framework for deciding whether a setup is worth trading.

LONG Setup Logic

Typical sequence:

Sweep Low
→ Displacement Up
→ Bullish MSS
→ FVG Retest
→ Entry

SHORT Setup Logic

Typical sequence:

Sweep High
→ Displacement Down
→ Bearish MSS
→ FVG Retest
→ Entry

Key Features
Multi-timeframe SMC framework
LONG / SHORT mode
Automated scoring system
Trade quality classification
Entry / Stop / TP inputs
Risk / Reward validation
Clean dashboard interface
Important

This indicator is NOT a signal generator.

It is a decision-support tool designed to help traders apply ICT / SMC concepts with more structure and consistency.

Best used alongside:

Market structure analysis
Liquidity mapping
Supply / Demand zones
FVG / Order Blocks
Proper risk management
Best Use Case

Ideal for traders using:

ICT concepts
Smart Money Concepts (SMC)
Liquidity-based trading
Multi-timeframe execution models
Disclaimer

For educational purposes only.
Not financial advice.

## Source Code

````pine
//@version=6
indicator("Trade checklist", overlay=true, max_labels_count=500)

// ======================================================
// CONFIGURACIÓN GENERAL
// ======================================================

bias = input.string("LONG", "Dirección del setup", options=["LONG", "SHORT"])

showTable  = input.bool(true, "Mostrar tabla")
showLevels = input.bool(true, "Mostrar líneas Entrada / Stop / TP")
showHelp   = input.bool(false, "Mostrar ayuda", group="Ayuda")

tablePositionInput = input.string(
     "Arriba derecha",
     "Ubicación tabla",
     options=["Arriba derecha", "Arriba izquierda", "Abajo derecha", "Abajo izquierda"]
)

tableSizeInput = input.string(
     "Pequeña",
     "Tamaño tabla",
     options=["Muy chica", "Pequeña", "Normal"]
)

tablePos = switch tablePositionInput
    "Arriba derecha" => position.top_right
    "Arriba izquierda" => position.top_left
    "Abajo derecha" => position.bottom_right
    "Abajo izquierda" => position.bottom_left

txtSize = switch tableSizeInput
    "Muy chica" => size.tiny
    "Pequeña" => size.small
    "Normal" => size.normal

// ======================================================
// PARÁMETROS AUTOMÁTICOS
// ======================================================

groupAuto = "Automatización"

monthlyFastEma = input.int(20, "EMA mensual rápida", minval=1, group=groupAuto)
monthlySlowEma = input.int(50, "EMA mensual lenta", minval=1, group=groupAuto)

weeklyLookback = input.int(26, "Rango semanal para Premium/Discount", minval=5, group=groupAuto)
weeklyZonePct = input.float(0.25, "Zona semanal extrema del rango", minval=0.05, maxval=0.50, step=0.05, group=groupAuto)
weeklyLiquidityLookback = input.int(8, "Lookback liquidez semanal", minval=2, group=groupAuto)

dailySweepLookback = input.int(5, "Lookback sweep diario", minval=2, group=groupAuto)
dailyMssLookback = input.int(5, "Lookback MSS/BOS diario", minval=2, group=groupAuto)
wickMinPct = input.float(0.35, "Mecha mínima rechazo", minval=0.10, maxval=0.80, step=0.05, group=groupAuto)
displacementAtrMult = input.float(1.10, "Displacement vs ATR diario", minval=0.50, step=0.10, group=groupAuto)

h4FvgLookback = input.int(10, "Lookback FVG 4H", minval=1, group=groupAuto)

minRoomPct = input.float(0.08, "Espacio mínimo a zona contraria", minval=0.01, step=0.01, group=groupAuto)
minRR = input.float(1.50, "R/R mínimo", minval=0.50, step=0.25, group=groupAuto)

// ======================================================
// TRADE PLAN
// ======================================================

groupTrade = "Trade Plan"

entryPrice = input.float(0.0, "Entrada", step=0.0001, group=groupTrade)
stopPrice  = input.float(0.0, "Stop", step=0.0001, group=groupTrade)
tp1Price   = input.float(0.0, "TP1", step=0.0001, group=groupTrade)
tp2Price   = input.float(0.0, "TP2", step=0.0001, group=groupTrade)

// ======================================================
// DATOS MENSUALES
// ======================================================

mClose = request.security(syminfo.tickerid, "M", close)

mEmaFast = request.security(syminfo.tickerid, "M", ta.ema(close, monthlyFastEma))
mEmaSlow = request.security(syminfo.tickerid, "M", ta.ema(close, monthlySlowEma))

mRangeHigh = request.security(syminfo.tickerid, "M", ta.highest(high, 12))
mRangeLow  = request.security(syminfo.tickerid, "M", ta.lowest(low, 12))

monthlyTrendOk = bias == "LONG" ? mEmaFast > mEmaSlow : mEmaFast < mEmaSlow
monthlyStructureOk = bias == "LONG" ? mClose > mEmaSlow : mClose < mEmaSlow

monthlyRoomLong = (mRangeHigh - mClose) / mClose
monthlyRoomShort = (mClose - mRangeLow) / mClose

monthlyNoBlockOk = bias == "LONG" ? monthlyRoomLong >= minRoomPct : monthlyRoomShort >= minRoomPct

// ======================================================
// DATOS SEMANALES
// ======================================================

wClose = request.security(syminfo.tickerid, "W", close)
wHigh  = request.security(syminfo.tickerid, "W", high)
wLow   = request.security(syminfo.tickerid, "W", low)

wRangeHigh = request.security(syminfo.tickerid, "W", ta.highest(high, weeklyLookback))
wRangeLow  = request.security(syminfo.tickerid, "W", ta.lowest(low, weeklyLookback))

wMid = (wRangeHigh + wRangeLow) / 2.0
wRange = wRangeHigh - wRangeLow

weeklyZoneLong = wClose <= wRangeLow + wRange * weeklyZonePct
weeklyZoneShort = wClose >= wRangeHigh - wRange * weeklyZonePct

weeklyZoneOk = bias == "LONG" ? weeklyZoneLong : weeklyZoneShort

weeklyPremiumDiscountOk = bias == "LONG" ? wClose < wMid : wClose > wMid

wPrevLowLiquidity = request.security(syminfo.tickerid, "W", ta.lowest(low[1], weeklyLiquidityLookback))
wPrevHighLiquidity = request.security(syminfo.tickerid, "W", ta.highest(high[1], weeklyLiquidityLookback))

weeklyLiquidityLong = wLow <= wPrevLowLiquidity or math.abs(wClose - wPrevLowLiquidity) / wClose <= 0.03
weeklyLiquidityShort = wHigh >= wPrevHighLiquidity or math.abs(wClose - wPrevHighLiquidity) / wClose <= 0.03

weeklyLiquidityOk = bias == "LONG" ? weeklyLiquidityLong : weeklyLiquidityShort

// ======================================================
// DATOS DIARIOS
// ======================================================

dOpen  = request.security(syminfo.tickerid, "D", open)
dHigh  = request.security(syminfo.tickerid, "D", high)
dLow   = request.security(syminfo.tickerid, "D", low)
dClose = request.security(syminfo.tickerid, "D", close)
dAtr   = request.security(syminfo.tickerid, "D", ta.atr(14))

dPrevLow = request.security(syminfo.tickerid, "D", ta.lowest(low[1], dailySweepLookback))
dPrevHigh = request.security(syminfo.tickerid, "D", ta.highest(high[1], dailySweepLookback))

dailySweepLong = dLow < dPrevLow and dClose > dPrevLow
dailySweepShort = dHigh > dPrevHigh and dClose < dPrevHigh

dailySweepOk = bias == "LONG" ? dailySweepLong : dailySweepShort

dRange = dHigh - dLow
dLowerWick = math.min(dOpen, dClose) - dLow
dUpperWick = dHigh - math.max(dOpen, dClose)

dailyRejectLong = dRange > 0 and dLowerWick / dRange >= wickMinPct and dClose > dLow + dRange * 0.50
dailyRejectShort = dRange > 0 and dUpperWick / dRange >= wickMinPct and dClose < dHigh - dRange * 0.50

dailyRejectionOk = bias == "LONG" ? dailyRejectLong : dailyRejectShort

dBosHigh = request.security(syminfo.tickerid, "D", ta.highest(high[1], dailyMssLookback))
dBosLow  = request.security(syminfo.tickerid, "D", ta.lowest(low[1], dailyMssLookback))

dailyMssLong = dClose > dBosHigh
dailyMssShort = dClose < dBosLow

dailyMssOk = bias == "LONG" ? dailyMssLong : dailyMssShort

dailyDispLong = dClose > dOpen and math.abs(dClose - dOpen) > dAtr * displacementAtrMult
dailyDispShort = dClose < dOpen and math.abs(dClose - dOpen) > dAtr * displacementAtrMult

dailyDisplacementOk = bias == "LONG" ? dailyDispLong : dailyDispShort

// ======================================================
// DATOS 4H
// ======================================================

h4BullFvgRecent = request.security(
     syminfo.tickerid,
     "240",
     not na(ta.barssince(low > high[2])) and ta.barssince(low > high[2]) <= h4FvgLookback
)

h4BearFvgRecent = request.security(
     syminfo.tickerid,
     "240",
     not na(ta.barssince(high < low[2])) and ta.barssince(high < low[2]) <= h4FvgLookback
)

h4FvgOk = bias == "LONG" ? h4BullFvgRecent : h4BearFvgRecent

h4LongTrigger = request.security(syminfo.tickerid, "240", close > high[1] and close > open)
h4ShortTrigger = request.security(syminfo.tickerid, "240", close < low[1] and close < open)

h4TriggerOk = bias == "LONG" ? h4LongTrigger : h4ShortTrigger

// ======================================================
// R/R AUTOMÁTICO
// ======================================================

hasTradePlan = entryPrice != 0.0 and stopPrice != 0.0 and tp1Price != 0.0

risk = math.abs(entryPrice - stopPrice)

reward1 = bias == "LONG" ? tp1Price - entryPrice : entryPrice - tp1Price
reward2 = bias == "LONG" ? tp2Price - entryPrice : entryPrice - tp2Price

rr1 = risk > 0 ? reward1 / risk : na
rr2 = risk > 0 ? reward2 / risk : na

validStop = bias == "LONG" ? stopPrice < entryPrice : stopPrice > entryPrice
validTp1 = bias == "LONG" ? tp1Price > entryPrice : tp1Price < entryPrice
validTp2 = tp2Price == 0.0 ? true : bias == "LONG" ? tp2Price > entryPrice : tp2Price < entryPrice

rrOk = hasTradePlan and validStop and validTp1 and validTp2 and risk > 0 and rr1 >= minRR

// ======================================================
// SCORING
// ======================================================

score = 0

score += monthlyTrendOk ? 1 : 0
score += monthlyStructureOk ? 1 : 0
score += monthlyNoBlockOk ? 1 : 0

score += weeklyZoneOk ? 2 : 0
score += weeklyPremiumDiscountOk ? 1 : 0
score += weeklyLiquidityOk ? 1 : 0

score += dailySweepOk ? 2 : 0
score += dailyRejectionOk ? 1 : 0
score += dailyMssOk ? 2 : 0
score += dailyDisplacementOk ? 1 : 0

score += h4FvgOk ? 1 : 0
score += h4TriggerOk ? 2 : 0
score += rrOk ? 1 : 0

maxScore = 17

statusText =
     score >= 13 ? "TRADE" :
     score >= 10 ? "WATCH" :
                   "NO TRADE"

// ======================================================
// FRONTEND TABLA - CLEAN PANEL
// ======================================================

bgPanel   = color.rgb(18, 20, 26)
bgHeader  = color.rgb(32, 36, 46)
bgRow     = color.rgb(24, 27, 35)
bgAlt     = color.rgb(28, 32, 41)
bgMuted   = color.rgb(42, 47, 58)

greenSoft = color.rgb(35, 150, 95)
redSoft   = color.rgb(205, 65, 80)
amberSoft = color.rgb(220, 155, 45)

whiteText = color.rgb(245, 245, 245)
mutedText = color.rgb(180, 185, 195)

stateColor =
     score >= 13 ? greenSoft :
     score >= 10 ? amberSoft :
                   redSoft

biasColor = bias == "LONG" ? greenSoft : redSoft

checkIcon(cond) =>
    cond ? "✓" : "×"

checkBg(cond) =>
    cond ? greenSoft : redSoft

rowBg(row) =>
    row % 2 == 0 ? bgRow : bgAlt

addCompactRow(tbl, row, tf, name, cond, points) =>
    table.cell(tbl, 0, row, tf, text_color=mutedText, bgcolor=rowBg(row), text_size=txtSize)
    table.cell(tbl, 1, row, name, text_color=whiteText, bgcolor=rowBg(row), text_size=txtSize)
    table.cell(tbl, 2, row, checkIcon(cond), text_color=whiteText, bgcolor=checkBg(cond), text_size=txtSize)
    table.cell(tbl, 3, row, str.tostring(points), text_color=mutedText, bgcolor=rowBg(row), text_size=txtSize)

addHelpRow(tbl, row, tf, checkName, logic, useText) =>
    table.cell(tbl, 0, row, tf, text_color=mutedText, bgcolor=rowBg(row), text_size=txtSize)
    table.cell(tbl, 1, row, checkName, text_color=whiteText, bgcolor=rowBg(row), text_size=txtSize)
    table.cell(tbl, 2, row, logic, text_color=whiteText, bgcolor=rowBg(row), text_size=txtSize)
    table.cell(tbl, 3, row, useText, text_color=mutedText, bgcolor=rowBg(row), text_size=txtSize)

// ======================================================
// TABLA
// ======================================================

var table t = table.new(tablePos, 4, 22, border_width=0)

// ======================================================
// TABLA NORMAL
// ======================================================

if barstate.islast and showTable and not showHelp
    table.cell(t, 0, 0, "Trade checklist", text_color=whiteText, bgcolor=bgHeader, text_size=txtSize)
    table.cell(t, 1, 0, bias, text_color=whiteText, bgcolor=biasColor, text_size=txtSize)
    table.cell(t, 2, 0, statusText, text_color=whiteText, bgcolor=stateColor, text_size=txtSize)
    table.cell(t, 3, 0, str.tostring(score) + "/" + str.tostring(maxScore), text_color=whiteText, bgcolor=stateColor, text_size=txtSize)

    table.cell(t, 0, 1, "Score", text_color=mutedText, bgcolor=bgPanel, text_size=txtSize)
    table.cell(t, 1, 1, str.tostring(score), text_color=whiteText, bgcolor=bgPanel, text_size=txtSize)
    table.cell(t, 2, 1, "Max", text_color=mutedText, bgcolor=bgPanel, text_size=txtSize)
    table.cell(t, 3, 1, str.tostring(maxScore), text_color=whiteText, bgcolor=bgPanel, text_size=txtSize)

    table.cell(t, 0, 2, "TF", text_color=mutedText, bgcolor=bgMuted, text_size=txtSize)
    table.cell(t, 1, 2, "Check", text_color=mutedText, bgcolor=bgMuted, text_size=txtSize)
    table.cell(t, 2, 2, "OK", text_color=mutedText, bgcolor=bgMuted, text_size=txtSize)
    table.cell(t, 3, 2, "Pts", text_color=mutedText, bgcolor=bgMuted, text_size=txtSize)

    addCompactRow(t, 3, "M", "Trend", monthlyTrendOk, monthlyTrendOk ? 1 : 0)
    addCompactRow(t, 4, "M", "Struct", monthlyStructureOk, monthlyStructureOk ? 1 : 0)
    addCompactRow(t, 5, "M", "Room", monthlyNoBlockOk, monthlyNoBlockOk ? 1 : 0)

    addCompactRow(t, 6, "W", "Zone", weeklyZoneOk, weeklyZoneOk ? 2 : 0)
    addCompactRow(t, 7, "W", "P/D", weeklyPremiumDiscountOk, weeklyPremiumDiscountOk ? 1 : 0)
    addCompactRow(t, 8, "W", "Liq", weeklyLiquidityOk, weeklyLiquidityOk ? 1 : 0)

    addCompactRow(t, 9, "D", "Sweep", dailySweepOk, dailySweepOk ? 2 : 0)
    addCompactRow(t, 10, "D", "Reject", dailyRejectionOk, dailyRejectionOk ? 1 : 0)
    addCompactRow(t, 11, "D", "MSS", dailyMssOk, dailyMssOk ? 2 : 0)
    addCompactRow(t, 12, "D", "Disp", dailyDisplacementOk, dailyDisplacementOk ? 1 : 0)

    addCompactRow(t, 13, "4H", "FVG", h4FvgOk, h4FvgOk ? 1 : 0)
    addCompactRow(t, 14, "4H", "Trig", h4TriggerOk, h4TriggerOk ? 2 : 0)
    addCompactRow(t, 15, "4H", "R/R", rrOk, rrOk ? 1 : 0)

    rrText = hasTradePlan and not na(rr1) ? str.tostring(rr1, "#.##") + "R" : "-"
    rr2Text = tp2Price != 0.0 and not na(rr2) ? str.tostring(rr2, "#.##") + "R" : "-"

    table.cell(t, 0, 16, "TP1 R", text_color=mutedText, bgcolor=bgPanel, text_size=txtSize)
    table.cell(t, 1, 16, rrText, text_color=whiteText, bgcolor=bgPanel, text_size=txtSize)
    table.cell(t, 2, 16, "TP2 R", text_color=mutedText, bgcolor=bgPanel, text_size=txtSize)
    table.cell(t, 3, 16, rr2Text, text_color=whiteText, bgcolor=bgPanel, text_size=txtSize)

    table.cell(t, 0, 17, "Rule", text_color=mutedText, bgcolor=bgHeader, text_size=txtSize)
    table.cell(t, 1, 17, "Sweep", text_color=dailySweepOk ? greenSoft : mutedText, bgcolor=bgHeader, text_size=txtSize)
    table.cell(t, 2, 17, "MSS", text_color=dailyMssOk ? greenSoft : mutedText, bgcolor=bgHeader, text_size=txtSize)
    table.cell(t, 3, 17, "R/R", text_color=rrOk ? greenSoft : mutedText, bgcolor=bgHeader, text_size=txtSize)

    table.cell(t, 0, 18, "Estado", text_color=whiteText, bgcolor=stateColor, text_size=txtSize)
    table.cell(t, 1, 18, statusText, text_color=whiteText, bgcolor=stateColor, text_size=txtSize)
    table.cell(t, 2, 18, "", bgcolor=stateColor, text_size=txtSize)
    table.cell(t, 3, 18, "", bgcolor=stateColor, text_size=txtSize)

    table.cell(t, 0, 19, "", bgcolor=na)
    table.cell(t, 1, 19, "", bgcolor=na)
    table.cell(t, 2, 19, "", bgcolor=na)
    table.cell(t, 3, 19, "", bgcolor=na)
    table.cell(t, 0, 20, "", bgcolor=na)
    table.cell(t, 1, 20, "", bgcolor=na)
    table.cell(t, 2, 20, "", bgcolor=na)
    table.cell(t, 3, 20, "", bgcolor=na)
    table.cell(t, 0, 21, "", bgcolor=na)
    table.cell(t, 1, 21, "", bgcolor=na)
    table.cell(t, 2, 21, "", bgcolor=na)
    table.cell(t, 3, 21, "", bgcolor=na)

// ======================================================
// TABLA AYUDA
// ======================================================

if barstate.islast and showTable and showHelp
    table.cell(t, 0, 0, "Trade checklist", text_color=whiteText, bgcolor=bgHeader, text_size=txtSize)
    table.cell(t, 1, 0, "HELP", text_color=whiteText, bgcolor=amberSoft, text_size=txtSize)
    table.cell(t, 2, 0, bias, text_color=whiteText, bgcolor=biasColor, text_size=txtSize)
    table.cell(t, 3, 0, str.tostring(score) + "/" + str.tostring(maxScore), text_color=whiteText, bgcolor=stateColor, text_size=txtSize)

    table.cell(t, 0, 1, "TF", text_color=mutedText, bgcolor=bgMuted, text_size=txtSize)
    table.cell(t, 1, 1, "Check", text_color=mutedText, bgcolor=bgMuted, text_size=txtSize)
    table.cell(t, 2, 1, "Qué mira", text_color=mutedText, bgcolor=bgMuted, text_size=txtSize)
    table.cell(t, 3, 1, "Uso", text_color=mutedText, bgcolor=bgMuted, text_size=txtSize)

    addHelpRow(t, 2, "M", "Trend", "EMAs", "Sesgo macro")
    addHelpRow(t, 3, "M", "Struct", "Close vs EMA", "Estructura")
    addHelpRow(t, 4, "M", "Room", "Espacio", "No chocar")

    addHelpRow(t, 5, "W", "Zone", "Extremo", "Zona trade")
    addHelpRow(t, 6, "W", "P/D", "50% rango", "Caro/barato")
    addHelpRow(t, 7, "W", "Liq", "High/Low", "Stops")

    addHelpRow(t, 8, "D", "Sweep", "Barrida", "Liquidez")
    addHelpRow(t, 9, "D", "Reject", "Mecha", "Rechazo")
    addHelpRow(t, 10, "D", "MSS", "BOS", "Cambio")
    addHelpRow(t, 11, "D", "Disp", "ATR", "Fuerza")

    addHelpRow(t, 12, "4H", "FVG", "Imbalance", "Zona entrada")
    addHelpRow(t, 13, "4H", "Trig", "Ruptura", "Entrada")
    addHelpRow(t, 14, "4H", "R/R", "TP/Stop", "Paga riesgo")

    table.cell(t, 0, 15, "Rule", text_color=whiteText, bgcolor=bgHeader, text_size=txtSize)
    table.cell(t, 1, 15, "Sweep", text_color=dailySweepOk ? greenSoft : mutedText, bgcolor=bgHeader, text_size=txtSize)
    table.cell(t, 2, 15, "MSS", text_color=dailyMssOk ? greenSoft : mutedText, bgcolor=bgHeader, text_size=txtSize)
    table.cell(t, 3, 15, "R/R", text_color=rrOk ? greenSoft : mutedText, bgcolor=bgHeader, text_size=txtSize)

    table.cell(t, 0, 16, "Score", text_color=mutedText, bgcolor=bgPanel, text_size=txtSize)
    table.cell(t, 1, 16, "0-9 NO", text_color=redSoft, bgcolor=bgPanel, text_size=txtSize)
    table.cell(t, 2, 16, "10-12 WATCH", text_color=amberSoft, bgcolor=bgPanel, text_size=txtSize)
    table.cell(t, 3, 16, "13+ TRADE", text_color=greenSoft, bgcolor=bgPanel, text_size=txtSize)

    table.cell(t, 0, 17, "LONG", text_color=greenSoft, bgcolor=bgHeader, text_size=txtSize)
    table.cell(t, 1, 17, "Demand", text_color=whiteText, bgcolor=bgHeader, text_size=txtSize)
    table.cell(t, 2, 17, "Sweep low", text_color=whiteText, bgcolor=bgHeader, text_size=txtSize)
    table.cell(t, 3, 17, "MSS up", text_color=whiteText, bgcolor=bgHeader, text_size=txtSize)

    table.cell(t, 0, 18, "SHORT", text_color=redSoft, bgcolor=bgHeader, text_size=txtSize)
    table.cell(t, 1, 18, "Supply", text_color=whiteText, bgcolor=bgHeader, text_size=txtSize)
    table.cell(t, 2, 18, "Sweep high", text_color=whiteText, bgcolor=bgHeader, text_size=txtSize)
    table.cell(t, 3, 18, "MSS down", text_color=whiteText, bgcolor=bgHeader, text_size=txtSize)

    table.cell(t, 0, 19, "Idea", text_color=mutedText, bgcolor=bgPanel, text_size=txtSize)
    table.cell(t, 1, 19, "Zona", text_color=whiteText, bgcolor=bgPanel, text_size=txtSize)
    table.cell(t, 2, 19, "Confirm", text_color=whiteText, bgcolor=bgPanel, text_size=txtSize)
    table.cell(t, 3, 19, "Ejecutar", text_color=whiteText, bgcolor=bgPanel, text_size=txtSize)

    table.cell(t, 0, 20, "", bgcolor=na)
    table.cell(t, 1, 20, "", bgcolor=na)
    table.cell(t, 2, 20, "", bgcolor=na)
    table.cell(t, 3, 20, "", bgcolor=na)
    table.cell(t, 0, 21, "", bgcolor=na)
    table.cell(t, 1, 21, "", bgcolor=na)
    table.cell(t, 2, 21, "", bgcolor=na)
    table.cell(t, 3, 21, "", bgcolor=na)

// ======================================================
// LÍNEAS DEL TRADE
// ======================================================

plot(showLevels and entryPrice != 0.0 ? entryPrice : na, "Entrada", color=color.new(color.blue, 0), linewidth=2, style=plot.style_linebr)
plot(showLevels and stopPrice != 0.0 ? stopPrice : na, "Stop", color=color.new(color.red, 0), linewidth=2, style=plot.style_linebr)
plot(showLevels and tp1Price != 0.0 ? tp1Price : na, "TP1", color=color.new(color.green, 0), linewidth=2, style=plot.style_linebr)
plot(showLevels and tp2Price != 0.0 ? tp2Price : na, "TP2", color=color.new(color.green, 45), linewidth=2, style=plot.style_linebr)

// ======================================================
// ALERTAS
// ======================================================

alertcondition(score >= 13, "Trade checklist: trade válido", "Trade checklist marcó TRADE válido.")
alertcondition(score >= 10 and score < 13, "Trade checklist: seguimiento", "Trade checklist marcó WATCH / seguimiento.")
````
