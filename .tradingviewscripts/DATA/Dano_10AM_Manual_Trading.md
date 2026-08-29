<!-- tradingview-pine-id: PUB;772a70e2bd574de9a3d52e0a5c67adac -->
<!-- tradingviewscripts-format: 1 -->
# Dano 10AM Manual Trading

Source: https://www.tradingview.com/script/YyBAoC5C-10AM-Strategy-Manual-Indicator/

## Description

For use on M1 MNQ chart only.

Marks out the 10AM level and projects a recommended stop based on desired risk you can adjust in the settings.

Strategy originated from Powell ( I think ) and I learned it from Dano in the PlayBit Discord server.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © WaffleTime

//@version=6
indicator("Dano 10AM Manual Trading", "Dano 10AM Manual", overlay = true, max_labels_count = 500)

// This is a manual-trading companion for the Dano10AM NinjaTrader strategy.
// It does not place orders. For behavior closest to the original strategy, use a 1-minute chart.

const string TZ = "America/New_York"

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────
string groupTime = "1. Time"
int keyHour = input.int(10, "Key-open hour (ET)", minval = 0, maxval = 23, group = groupTime)
int keyMinute = input.int(0, "Key-open minute (ET)", minval = 0, maxval = 59, group = groupTime)
int cutoffHour = input.int(12, "Entry-cutoff hour (ET)", minval = 0, maxval = 23, group = groupTime)
int cutoffMinute = input.int(0, "Entry-cutoff minute (ET)", minval = 0, maxval = 59, group = groupTime)

string groupDisplacement = "2. Displacement"
float displacementPoints = input.float(25.0, "Minimum displacement (points)", minval = 0.25, step = 0.25, group = groupDisplacement)
int minBodyTicks = input.int(8, "Minimum candle body (ticks)", minval = 0, group = groupDisplacement)
bool requireClose = input.bool(true, "Require close beyond displacement", group = groupDisplacement, tooltip = "On: the candle must close beyond the threshold. Off: its high/low may reach the threshold.")
string tradeDirection = input.string("Both", "Direction", options = ["Both", "Long only", "Short only"], group = groupDisplacement)
bool showDisplacement = input.bool(true, "Show displacement levels", group = groupDisplacement)
bool shadeDisplacement = input.bool(true, "Shade displacement zones", group = groupDisplacement)

string groupRisk = "3. Trade Plan"
bool useStaticStop = input.bool(false, "Use static stop", group = groupRisk, tooltip = "Off uses the post-10:00 swing extreme plus the stop buffer, matching the NinjaTrader strategy.")
float staticStopPoints = input.float(20.0, "Static stop (points)", minval = 0.25, step = 0.25, group = groupRisk)
int stopBufferTicks = input.int(2, "Structural-stop buffer (ticks)", minval = 0, group = groupRisk)
float minimumStopPoints = input.float(5.0, "Minimum stop (points)", minval = 0.25, step = 0.25, group = groupRisk)
float maximumStopPoints = input.float(25.0, "Maximum stop (points)", minval = 0.25, step = 0.25, group = groupRisk)
float rewardMultiple = input.float(10.0, "Target (R)", minval = 0.25, maxval = 20.0, step = 0.25, group = groupRisk)
float trimMultiple = input.float(4.0, "Trim / breakeven trigger (R)", minval = 0.25, maxval = 20.0, step = 0.25, group = groupRisk)
bool showTradePlan = input.bool(true, "Show entry, stop, target, and trim levels", group = groupRisk)
bool showTradeLabels = input.bool(true, "Show entry, SL, and TP price labels", group = groupRisk)
bool showSignals = input.bool(true, "Show setup and retest markers", group = groupRisk)

string groupSizing = "4. MNQ Position Sizing"
float desiredRisk = input.float(200.0, "Desired risk ($)", minval = 1.0, step = 1.0, group = groupSizing)
float pointValue = input.float(2.0, "Dollar value per point, per contract", minval = 0.01, step = 0.01, group = groupSizing, tooltip = "MNQ is $2 per point per contract. Change this only if you use another instrument.")
int maxContracts = input.int(20, "Maximum contracts", minval = 1, maxval = 500, group = groupSizing)
float sizingStart = input.float(5.0, "Sizing-list first stop (points)", minval = 0.25, step = 0.25, group = groupSizing)
float sizingStep = input.float(5.0, "Sizing-list increment (points)", minval = 0.25, step = 0.25, group = groupSizing)
bool showRiskTable = input.bool(true, "Show sizing table", group = groupSizing)

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
f_roundToTick(float price) =>
    math.round(price / syminfo.mintick) * syminfo.mintick

f_contracts(float stopPoints) =>
    float riskPerContract = stopPoints * pointValue
    int uncapped = riskPerContract > 0 ? int(math.floor(desiredRisk / riskPerContract)) : 0
    math.max(1, math.min(maxContracts, uncapped))

f_price(float value) =>
    na(value) ? "—" : str.tostring(value, format.mintick)

f_dollars(float value) =>
    na(value) ? "—" : "$" + str.tostring(value, "#.00")

// ─────────────────────────────────────────────────────────────────────────────
// Daily state and the exact 10:00 ET open
// ─────────────────────────────────────────────────────────────────────────────
int etDate = year(time, TZ) * 10000 + month(time, TZ) * 100 + dayofmonth(time, TZ)
int etMinutes = hour(time, TZ) * 60 + minute(time, TZ)
int keyMinutes = keyHour * 60 + keyMinute
int cutoffMinutes = cutoffHour * 60 + cutoffMinute
bool newEtDay = na(etDate[1]) or etDate != etDate[1]
bool isKeyBar = timeframe.isintraday and etMinutes == keyMinutes
bool inEntryWindow = etMinutes >= keyMinutes and etMinutes < cutoffMinutes

var float keyOpen = na
var bool keyCaptured = false
var float postOpenHigh = na
var float postOpenLow = na
var bool setupLocked = false
var int setupBar = na
var int planDirection = 0
var float plannedEntry = na
var float plannedStop = na
var float plannedTarget = na
var float plannedTrim = na
var float plannedRiskPoints = na
var bool entryTouched = false

if newEtDay
    keyOpen := na
    keyCaptured := false
    postOpenHigh := na
    postOpenLow := na
    setupLocked := false
    setupBar := na
    planDirection := 0
    plannedEntry := na
    plannedStop := na
    plannedTarget := na
    plannedTrim := na
    plannedRiskPoints := na
    entryTouched := false

if not keyCaptured and isKeyBar
    keyOpen := f_roundToTick(open)
    keyCaptured := true
    postOpenHigh := high
    postOpenLow := low

if keyCaptured
    postOpenHigh := math.max(postOpenHigh, high)
    postOpenLow := math.min(postOpenLow, low)

// ─────────────────────────────────────────────────────────────────────────────
// Displacement confirmation and manual trade plan
// ─────────────────────────────────────────────────────────────────────────────
float bodyTicks = math.abs(close - open) / syminfo.mintick
bool bodyOkay = bodyTicks >= minBodyTicks
bool longAllowed = tradeDirection != "Short only"
bool shortAllowed = tradeDirection != "Long only"
bool bullishThresholdHit = keyCaptured and (requireClose ? close >= keyOpen + displacementPoints : high >= keyOpen + displacementPoints)
bool bearishThresholdHit = keyCaptured and (requireClose ? close <= keyOpen - displacementPoints : low <= keyOpen - displacementPoints)
bool bullishDisplacement = bullishThresholdHit and close > open and bodyOkay and longAllowed
bool bearishDisplacement = bearishThresholdHit and close < open and bodyOkay and shortAllowed

bool bullSetupSignal = false
bool bearSetupSignal = false
bool longRetestSignal = false
bool shortRetestSignal = false

// For manual trading, the active plan follows the latest confirmed displacement.
// A full opposite-side displacement replaces the earlier plan instead of leaving
// the first direction locked for the rest of the day.
if barstate.isconfirmed and keyCaptured and inEntryWindow
    if bullishDisplacement and (not setupLocked or planDirection != 1)
        float candidateStop = useStaticStop ? keyOpen - staticStopPoints : postOpenLow - stopBufferTicks * syminfo.mintick
        float candidateRisk = keyOpen - f_roundToTick(candidateStop)
        if candidateRisk > maximumStopPoints
            candidateRisk := maximumStopPoints
            candidateStop := keyOpen - maximumStopPoints
        candidateStop := f_roundToTick(candidateStop)
        candidateRisk := keyOpen - candidateStop
        if candidateRisk >= minimumStopPoints and keyOpen < close
            setupLocked := true
            setupBar := bar_index
            planDirection := 1
            plannedEntry := keyOpen
            plannedStop := candidateStop
            plannedRiskPoints := candidateRisk
            plannedTarget := f_roundToTick(keyOpen + rewardMultiple * candidateRisk)
            plannedTrim := f_roundToTick(keyOpen + trimMultiple * candidateRisk)
            entryTouched := false
            bullSetupSignal := true
    else if bearishDisplacement and (not setupLocked or planDirection != -1)
        float candidateStop = useStaticStop ? keyOpen + staticStopPoints : postOpenHigh + stopBufferTicks * syminfo.mintick
        float candidateRisk = f_roundToTick(candidateStop) - keyOpen
        if candidateRisk > maximumStopPoints
            candidateRisk := maximumStopPoints
            candidateStop := keyOpen + maximumStopPoints
        candidateStop := f_roundToTick(candidateStop)
        candidateRisk := candidateStop - keyOpen
        if candidateRisk >= minimumStopPoints and keyOpen > close
            setupLocked := true
            setupBar := bar_index
            planDirection := -1
            plannedEntry := keyOpen
            plannedStop := candidateStop
            plannedRiskPoints := candidateRisk
            plannedTarget := f_roundToTick(keyOpen - rewardMultiple * candidateRisk)
            plannedTrim := f_roundToTick(keyOpen - trimMultiple * candidateRisk)
            entryTouched := false
            bearSetupSignal := true

// A revisit can occur only after the displacement bar, because the limit order
// in the original strategy is submitted after that candle confirms.
if setupLocked and not entryTouched and bar_index > setupBar and inEntryWindow
    if planDirection == 1 and low <= plannedEntry
        entryTouched := true
        longRetestSignal := true
    else if planDirection == -1 and high >= plannedEntry
        entryTouched := true
        shortRetestSignal := true

// Position sizing and dollar outcomes for the active setup. Sizing does not
// move the stop or target; it determines the quantity and total dollars at risk.
int activeQty = not na(plannedRiskPoints) ? f_contracts(plannedRiskPoints) : 0
float activeRiskPerContract = not na(plannedRiskPoints) ? plannedRiskPoints * pointValue : na
float activeTotalRisk = not na(activeRiskPerContract) ? activeRiskPerContract * activeQty : na
float activeTargetProfit = not na(activeTotalRisk) ? activeTotalRisk * rewardMultiple : na

// ─────────────────────────────────────────────────────────────────────────────
// Chart levels and markers
// ─────────────────────────────────────────────────────────────────────────────
float upperDisplacement = keyCaptured ? keyOpen + displacementPoints : na
float lowerDisplacement = keyCaptured ? keyOpen - displacementPoints : na

keyPlot = plot(keyCaptured ? keyOpen : na, "10:00 ET Open", color = color.rgb(30, 144, 255), linewidth = 2, style = plot.style_linebr)
upperPlot = plot(showDisplacement ? upperDisplacement : na, "Bullish Displacement", color = color.new(color.lime, 10), linewidth = 1, style = plot.style_linebr)
lowerPlot = plot(showDisplacement ? lowerDisplacement : na, "Bearish Displacement", color = color.new(color.red, 10), linewidth = 1, style = plot.style_linebr)
fill(keyPlot, upperPlot, color = showDisplacement and shadeDisplacement ? color.new(color.lime, 92) : na, title = "Bullish displacement zone")
fill(keyPlot, lowerPlot, color = showDisplacement and shadeDisplacement ? color.new(color.red, 92) : na, title = "Bearish displacement zone")

plot(showTradePlan and setupLocked ? plannedStop : na, "Planned Stop", color = color.rgb(220, 70, 70), linewidth = 2, style = plot.style_linebr)
plot(showTradePlan and setupLocked ? plannedTarget : na, "Planned Target", color = color.rgb(25, 170, 95), linewidth = 2, style = plot.style_linebr)
plot(showTradePlan and setupLocked ? plannedTrim : na, "Trim / Breakeven Trigger", color = color.rgb(164, 102, 255), linewidth = 1, style = plot.style_linebr)

plotshape(showSignals and bullSetupSignal, title = "Bullish displacement confirmed", style = shape.labelup, location = location.belowbar, color = color.rgb(20, 150, 80), text = "LONG\nSETUP", textcolor = color.white, size = size.tiny)
plotshape(showSignals and bearSetupSignal, title = "Bearish displacement confirmed", style = shape.labeldown, location = location.abovebar, color = color.rgb(205, 55, 55), text = "SHORT\nSETUP", textcolor = color.white, size = size.tiny)
plotshape(showSignals and longRetestSignal, title = "Long 10:00-open retest", style = shape.triangleup, location = location.belowbar, color = color.yellow, text = "ENTRY", textcolor = color.black, size = size.small)
plotshape(showSignals and shortRetestSignal, title = "Short 10:00-open retest", style = shape.triangledown, location = location.abovebar, color = color.yellow, text = "ENTRY", textcolor = color.black, size = size.small)

// Keep exact prices visible at the right edge of the chart for order entry.
var label entryPriceLabel = na
var label stopPriceLabel = na
var label targetPriceLabel = na

if barstate.islast
    label.delete(entryPriceLabel)
    label.delete(stopPriceLabel)
    label.delete(targetPriceLabel)
    if showTradePlan and showTradeLabels and setupLocked
        string directionText = planDirection == 1 ? "LONG" : "SHORT"
        entryPriceLabel := label.new(bar_index + 2, plannedEntry, directionText + " ENTRY  " + f_price(plannedEntry) + "\n" + str.tostring(activeQty) + " contracts", xloc = xloc.bar_index, style = label.style_label_left, color = color.rgb(210, 165, 40), textcolor = color.black, size = size.small)
        stopPriceLabel := label.new(bar_index + 2, plannedStop, "SL  " + f_price(plannedStop) + "\n" + str.tostring(plannedRiskPoints, "#.##") + " pts • " + f_dollars(activeTotalRisk), xloc = xloc.bar_index, style = label.style_label_left, color = color.rgb(205, 65, 65), textcolor = color.white, size = size.small)
        targetPriceLabel := label.new(bar_index + 2, plannedTarget, "TP  " + f_price(plannedTarget) + "\n" + str.tostring(rewardMultiple, "#.##") + "R • " + f_dollars(activeTargetProfit), xloc = xloc.bar_index, style = label.style_label_left, color = color.rgb(30, 155, 90), textcolor = color.white, size = size.small)

// ─────────────────────────────────────────────────────────────────────────────
// Risk-sizing table: floor(desired risk / per-contract risk), capped at max.
// If one contract already exceeds desired risk, the table still shows one in red.
// ─────────────────────────────────────────────────────────────────────────────
var table riskTable = table.new(position.top_right, 5, 12, border_width = 1, border_color = color.new(color.gray, 55))

if barstate.isfirst
    table.merge_cells(riskTable, 0, 0, 4, 0)

if barstate.islast
    if showRiskTable
        color titleBg = color.rgb(26, 35, 50)
        color headerBg = color.rgb(43, 54, 72)
        color normalBg = color.new(color.rgb(24, 29, 38), 5)
        color muted = color.rgb(185, 194, 208)
        string status = not keyCaptured ? "Waiting for 10:00 ET" : not setupLocked ? "Waiting for displacement" : entryTouched ? (planDirection == 1 ? "Long entry retested" : "Short entry retested") : (planDirection == 1 ? "Long plan armed" : "Short plan armed")
        float upRemaining = keyCaptured ? math.max(0.0, upperDisplacement - (requireClose ? close : high)) : na
        float downRemaining = keyCaptured ? math.max(0.0, (requireClose ? close : low) - lowerDisplacement) : na
        bool oneMinuteChart = timeframe.isminutes and timeframe.multiplier == 1

        table.cell(riskTable, 0, 0, "DANO 10AM • MNQ RISK SIZING", text_color = color.white, bgcolor = titleBg, text_size = size.small)
        table.cell(riskTable, 0, 1, status, text_color = color.white, bgcolor = normalBg, text_size = size.tiny)
        table.cell(riskTable, 1, 1, "10:00 open\n" + f_price(keyOpen), text_color = muted, bgcolor = normalBg, text_size = size.tiny)
        table.cell(riskTable, 2, 1, "Desired risk\n" + f_dollars(desiredRisk), text_color = muted, bgcolor = normalBg, text_size = size.tiny)
        table.cell(riskTable, 3, 1, "$ / point\n" + f_dollars(pointValue), text_color = muted, bgcolor = normalBg, text_size = size.tiny)
        table.cell(riskTable, 4, 1, keyCaptured ? "Up left " + str.tostring(upRemaining, "#.00") + "\nDown left " + str.tostring(downRemaining, "#.00") : (oneMinuteChart ? "1-minute chart" : "Use 1-minute chart"), text_color = oneMinuteChart ? muted : color.orange, bgcolor = normalBg, text_size = size.tiny)

        table.cell(riskTable, 0, 2, "Stop pts", text_color = color.white, bgcolor = headerBg, text_size = size.tiny)
        table.cell(riskTable, 1, 2, "Contracts", text_color = color.white, bgcolor = headerBg, text_size = size.tiny)
        table.cell(riskTable, 2, 2, "$/contract", text_color = color.white, bgcolor = headerBg, text_size = size.tiny)
        table.cell(riskTable, 3, 2, "Actual risk", text_color = color.white, bgcolor = headerBg, text_size = size.tiny)
        table.cell(riskTable, 4, 2, "Vs desired", text_color = color.white, bgcolor = headerBg, text_size = size.tiny)

        for i = 0 to 4
            float rowStop = sizingStart + i * sizingStep
            int rowQty = f_contracts(rowStop)
            float rowPerContract = rowStop * pointValue
            float rowActual = rowPerContract * rowQty
            bool overRisk = rowActual > desiredRisk + 0.001
            color rowText = overRisk ? color.rgb(255, 140, 105) : color.white
            string comparison = overRisk ? "+" + f_dollars(rowActual - desiredRisk) : "-" + f_dollars(desiredRisk - rowActual)
            int row = i + 3
            table.cell(riskTable, 0, row, str.tostring(rowStop, "#.##"), text_color = rowText, bgcolor = normalBg, text_size = size.tiny)
            table.cell(riskTable, 1, row, str.tostring(rowQty), text_color = rowText, bgcolor = normalBg, text_size = size.tiny)
            table.cell(riskTable, 2, row, f_dollars(rowPerContract), text_color = rowText, bgcolor = normalBg, text_size = size.tiny)
            table.cell(riskTable, 3, row, f_dollars(rowActual), text_color = rowText, bgcolor = normalBg, text_size = size.tiny)
            table.cell(riskTable, 4, row, comparison, text_color = rowText, bgcolor = normalBg, text_size = size.tiny)

        table.cell(riskTable, 0, 8, "CURRENT PLAN", text_color = color.white, bgcolor = headerBg, text_size = size.tiny)
        table.cell(riskTable, 1, 8, "Stop pts", text_color = color.white, bgcolor = headerBg, text_size = size.tiny)
        table.cell(riskTable, 2, 8, "Contracts", text_color = color.white, bgcolor = headerBg, text_size = size.tiny)
        table.cell(riskTable, 3, 8, "$/contract", text_color = color.white, bgcolor = headerBg, text_size = size.tiny)
        table.cell(riskTable, 4, 8, "Actual risk", text_color = color.white, bgcolor = headerBg, text_size = size.tiny)

        color planText = not na(activeTotalRisk) and activeTotalRisk > desiredRisk + 0.001 ? color.rgb(255, 140, 105) : color.rgb(255, 215, 80)
        table.cell(riskTable, 0, 9, planDirection == 1 ? "LONG" : planDirection == -1 ? "SHORT" : "—", text_color = planText, bgcolor = normalBg, text_size = size.tiny)
        table.cell(riskTable, 1, 9, na(plannedRiskPoints) ? "—" : str.tostring(plannedRiskPoints, "#.##"), text_color = planText, bgcolor = normalBg, text_size = size.tiny)
        table.cell(riskTable, 2, 9, activeQty == 0 ? "—" : str.tostring(activeQty), text_color = planText, bgcolor = normalBg, text_size = size.tiny)
        table.cell(riskTable, 3, 9, f_dollars(activeRiskPerContract), text_color = planText, bgcolor = normalBg, text_size = size.tiny)
        table.cell(riskTable, 4, 9, f_dollars(activeTotalRisk), text_color = planText, bgcolor = normalBg, text_size = size.tiny)

        table.cell(riskTable, 0, 10, "ENTRY", text_color = color.white, bgcolor = headerBg, text_size = size.tiny)
        table.cell(riskTable, 1, 10, "STOP LOSS", text_color = color.white, bgcolor = headerBg, text_size = size.tiny)
        table.cell(riskTable, 2, 10, "TAKE PROFIT", text_color = color.white, bgcolor = headerBg, text_size = size.tiny)
        table.cell(riskTable, 3, 10, "TP R", text_color = color.white, bgcolor = headerBg, text_size = size.tiny)
        table.cell(riskTable, 4, 10, "PROFIT @ TP", text_color = color.white, bgcolor = headerBg, text_size = size.tiny)
        table.cell(riskTable, 0, 11, f_price(plannedEntry), text_color = color.rgb(255, 215, 80), bgcolor = normalBg, text_size = size.tiny)
        table.cell(riskTable, 1, 11, f_price(plannedStop), text_color = color.rgb(255, 125, 110), bgcolor = normalBg, text_size = size.tiny)
        table.cell(riskTable, 2, 11, f_price(plannedTarget), text_color = color.rgb(95, 220, 145), bgcolor = normalBg, text_size = size.tiny)
        table.cell(riskTable, 3, 11, setupLocked ? str.tostring(rewardMultiple, "#.##") + "R" : "—", text_color = muted, bgcolor = normalBg, text_size = size.tiny)
        table.cell(riskTable, 4, 11, f_dollars(activeTargetProfit), text_color = color.rgb(95, 220, 145), bgcolor = normalBg, text_size = size.tiny)
    else
        table.clear(riskTable, 0, 0, 4, 11)

// Alerts can be created from TradingView's Create Alert dialog.
alertcondition(bullSetupSignal, "Dano bullish displacement", "Bullish Dano displacement confirmed. Watch for a retest of the 10:00 ET open.")
alertcondition(bearSetupSignal, "Dano bearish displacement", "Bearish Dano displacement confirmed. Watch for a retest of the 10:00 ET open.")
alertcondition(longRetestSignal, "Dano long entry retest", "Price retested the 10:00 ET open after bullish displacement.")
alertcondition(shortRetestSignal, "Dano short entry retest", "Price retested the 10:00 ET open after bearish displacement.")
````
