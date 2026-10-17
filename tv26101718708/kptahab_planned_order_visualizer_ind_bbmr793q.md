# [Kpt-Ahab] Planned Order Visualizer IND

- url: https://www.tradingview.com/script/BbmR793q/
- type: indicator
- pine_id: PUB;316e26c2ff4c46d2accea6e93ef61a84
- version: 1.0

## Description

This Script visualizes planned long or short positions, including an optional existing position size, average entry price, up to three planned entries, a stop-loss level, and an estimated liquidation price. The current position can be treated either as already open or as a new planned entry. In simulation mode, all active entries are included in the calculation immediately, while in live mode only triggered price levels are included. Additional safety settings help prevent historical alerts and can optionally block entry or SL levels that would trigger immediately. The script is designed for planning, visualization, and alerting of planned positions.



https://www.tradingview.com/x/4T6RRtHL/
**Tips**

* Use **Simulation** mode to preview how all active entries affect the average price before any live alerts are enabled.
* Use **Live** mode only when you want the script to track price-level triggers in real time.
* Keep **Trigger only in realtime** enabled when using alerts, to avoid historical alert triggers after loading the script.
* Use **Block marketable entry limits** and **Block marketable SL** to prevent levels that would trigger immediately.
* Increase the **Reset counter** only when you intentionally want to reset all triggered states and prepare a fresh setup.
* The liquidation price is an estimate for planning purposes and may differ from the exact exchange liquidation price.




This script currently uses a fixed entry structure with `E0` plus `E1`, `E2`, and `E3`. To increase the number of planned entries, duplicate the existing entry blocks and keep the same naming pattern.

For every additional entry, add:

* new input fields for active state, price, and quantity
* new submitted and triggered flags
* average price quantity/value calculations
* price-allowed and price-hit logic
* alert trigger logic
* line and label objects
* table rows if the entry should be shown in the info table

## Source Code

````pine
// © Kpt-Ahab
// [Kpt-Ahab] Planned Order Visualizer Indicator Version
//@version=6
indicator("[Kpt-Ahab] Planned Order Visualizer IND", overlay = true, max_lines_count = 50, max_labels_count = 50)

// ---------------------------------------------------
// General
// ---------------------------------------------------
groupGeneral = "General"

positionSide = input.string("Long", "Position side", options = ["Long", "Short"], group = groupGeneral, inline = "MODE")

mode = input.string(
     "Live",
     "Mode",
     options = ["Simulation", "Live"],
     group = groupGeneral,
     inline = "MODE",
     tooltip = "Simulation includes all active planned entries immediately in the average price calculation. Live only includes entries after their price level has been triggered."
)

// ---------------------------------------------------
// Current position
// ---------------------------------------------------
groupCurrent = "Current position"

currentMode = input.string(
     "Position already open",
     "Current position mode",
     options = ["Position already open", "New entry"],
     group = groupCurrent,
     tooltip = "Position already open: current quantity and average price are included immediately. New entry: current quantity and average price are treated as an open planned entry with order ID E0."
)

currentQty = input.float(1.0, "Current quantity", step = 0.001, minval = 0, group = groupCurrent, inline = "CUR")
currentAvgPrice = input.float(1650.0, "Average price", step = 0.01, minval = 0, group = groupCurrent, inline = "CUR")

// ---------------------------------------------------
// Trade capital
// ---------------------------------------------------
groupCapital = "Trade capital"

tradeCapital = input.float(2000.0, "Trade capital / Margin", step = 1.0, minval = 0, group = groupCapital)

// ---------------------------------------------------
// Liquidation
// ---------------------------------------------------
groupLiq = "Liquidation"

showLiquidation = input.bool(true, "Show liquidation price", group = groupLiq)

// ---------------------------------------------------
// Planned entries
// ---------------------------------------------------
groupEntries = "Planned entries"

entry1Active = input.bool(true, "Entry 1", group = groupEntries, inline = "E1")
entry1Price = input.float(1550.0, "Price", step = 0.01, minval = 0, group = groupEntries, inline = "E1")
entry1Qty = input.float(1.0, "Quantity", step = 0.001, minval = 0, group = groupEntries, inline = "E1")

entry2Active = input.bool(false, "Entry 2", group = groupEntries, inline = "E2")
entry2Price = input.float(1500.0, "Price", step = 0.01, minval = 0, group = groupEntries, inline = "E2")
entry2Qty = input.float(1.0, "Quantity", step = 0.001, minval = 0, group = groupEntries, inline = "E2")

entry3Active = input.bool(false, "Entry 3", group = groupEntries, inline = "E3")
entry3Price = input.float(1450.0, "Price", step = 0.01, minval = 0, group = groupEntries, inline = "E3")
entry3Qty = input.float(1.0, "Quantity", step = 0.001, minval = 0, group = groupEntries, inline = "E3")

// ---------------------------------------------------
// Manual SL / Reduce
// ---------------------------------------------------
groupSL = "Manual SL / Reduce"

slActive = input.bool(false, "Enable SL", group = groupSL, inline = "SL1")
slQtyMode = input.string("Entire position", "SL quantity", options = ["Entire position", "Fixed quantity", "Percent of position"], group = groupSL, inline = "SL1")

slPrice = input.float(1400.0, "SL price", step = 0.01, minval = 0, group = groupSL, inline = "SL2")
slFixedQty = input.float(0.10, "Fixed quantity", step = 0.001, minval = 0, group = groupSL, inline = "SL2")
slPercent = input.float(100.0, "Percent", step = 1.0, minval = 0, maxval = 100, group = groupSL, inline = "SL2")

// ---------------------------------------------------
// Live safety
// ---------------------------------------------------
groupLive = "Live safety"

enableLiveAlerts = input.bool(
     false,
     "ENABLE LIVE ALERTS",
     group = groupLive,
     tooltip = "Master safety switch. If disabled, the script only visualizes the setup and does not send alert() webhook messages."
)

placeOnlyRealtime = input.bool(
     true,
     "Trigger only in realtime",
     group = groupLive,
     tooltip = "Prevents the script from triggering alerts on historical candles when it is loaded. Recommended ON for broker webhooks."
)

blockMarketableLimit = input.bool(
     true,
     "Block marketable entry limits",
     group = groupLive,
     tooltip = "Long buy limits are armed only below the current price. Short sell limits are armed only above the current price. This prevents immediately executable entry levels."
)

blockMarketableSL = input.bool(
     true,
     "Block marketable SL",
     group = groupLive,
     tooltip = "Long SL sell stops are armed only below the current price. Short SL buy stops are armed only above the current price. This prevents immediately executable SL levels."
)

resetToken = input.int(
     0,
     "Reset counter",
     minval = 0,
     group = groupLive,
     tooltip = "Increase this number to reset internal armed/triggered flags. Use this only when you intentionally want to allow a fresh set of alerts."
)

// ---------------------------------------------------
// Display
// ---------------------------------------------------
groupDisplay = "Display"

barsBack = input.int(30, "Line start bars back", minval = 1, group = groupDisplay)
showLabels = input.bool(true, "Show labels", group = groupDisplay)
extendRight = input.bool(true, "Extend lines right", group = groupDisplay)
labelXStep = input.int(4, "Label X offset in bars", minval = 0, maxval = 50, group = groupDisplay)
showTable = input.bool(true, "Show info table", group = groupDisplay)

// ---------------------------------------------------
// Colors
// ---------------------------------------------------
avgColor = color.yellow
pendingColor = color.gray
filledColor = color.new(color.lime, 0)
blockedColor = color.new(color.orange, 0)
inactiveColor = color.new(color.gray, 80)
slColor = color.new(color.red, 0)
liqColor = color.new(color.red, 0)

labelTextDark = color.black
labelTextLight = color.white

tableHeaderBg = color.new(color.black, 0)
tableCellBg = color.new(color.black, 15)
tableText = color.white

// ---------------------------------------------------
// Direction
// ---------------------------------------------------
isLong = positionSide == "Long"

entrySideText = isLong ? "buy" : "sell"
slSideText = isLong ? "sell" : "buy"

entryActionLabel = isLong ? "Buy limit" : "Sell limit"
slActionLabel = isLong ? "Sell stop / reduce" : "Buy stop / reduce"

// ---------------------------------------------------
// Alert message
// ---------------------------------------------------
f_alertMessage(string orderId, string side, float qty, float price, bool reduceOnly) =>
    "[Kpt-Ahab] Planned Order Visualizer" +
     "\nOrder ID: " + orderId +
     "\nSymbol: " + syminfo.ticker +
     "\nSide: " + side +
     "\nQuantity: " + str.tostring(qty) +
     "\nPrice: " + str.tostring(price, format.mintick) +
     "\nReduce only: " + (reduceOnly ? "true" : "false") +
     "\nTime: " + str.tostring(timenow)

// ---------------------------------------------------
// One-time flags
// ---------------------------------------------------
varip bool currentSubmitted = false
varip bool entry1Submitted = false
varip bool entry2Submitted = false
varip bool entry3Submitted = false

varip bool currentTriggered = false
varip bool entry1Triggered = false
varip bool entry2Triggered = false
varip bool entry3Triggered = false

varip bool slSubmitted = false
varip bool slTriggered = false

varip int lastResetToken = na

isReset = na(lastResetToken) or resetToken != lastResetToken

if isReset
    currentSubmitted := false
    entry1Submitted := false
    entry2Submitted := false
    entry3Submitted := false

    currentTriggered := false
    entry1Triggered := false
    entry2Triggered := false
    entry3Triggered := false

    slSubmitted := false
    slTriggered := false

    lastResetToken := resetToken

// ---------------------------------------------------
// Current position / current entry state
// ---------------------------------------------------
currentAlreadyOpen = currentMode == "Position already open"
currentIsNewEntry = currentMode == "New entry"
currentValid = currentQty > 0 and currentAvgPrice > 0

// ---------------------------------------------------
// Average price
// ---------------------------------------------------
currentUsed =
     currentAlreadyOpen and currentValid ? true :
     currentIsNewEntry and currentValid ? mode == "Simulation" ? true : currentTriggered :
     false

entry1Used = mode == "Simulation" ? entry1Active : entry1Triggered
entry2Used = mode == "Simulation" ? entry2Active : entry2Triggered
entry3Used = mode == "Simulation" ? entry3Active : entry3Triggered

usedQty0 = currentUsed ? currentQty : 0.0
usedQty1 = entry1Used ? entry1Qty : 0.0
usedQty2 = entry2Used ? entry2Qty : 0.0
usedQty3 = entry3Used ? entry3Qty : 0.0

usedValue0 = currentUsed ? currentAvgPrice * currentQty : 0.0
usedValue1 = entry1Used ? entry1Price * entry1Qty : 0.0
usedValue2 = entry2Used ? entry2Price * entry2Qty : 0.0
usedValue3 = entry3Used ? entry3Price * entry3Qty : 0.0

totalQty = usedQty0 + usedQty1 + usedQty2 + usedQty3
totalValue = usedValue0 + usedValue1 + usedValue2 + usedValue3

avgPrice = totalQty > 0 ? totalValue / totalQty : na

// ---------------------------------------------------
// Capital and liquidation calculation
// ---------------------------------------------------
positionNotional = not na(avgPrice) ? totalQty * avgPrice : na

impliedLeverage =
     tradeCapital > 0 and not na(positionNotional) ?
     positionNotional / tradeCapital :
     na

liqDistance =
     totalQty > 0 and tradeCapital > 0 ?
     tradeCapital / totalQty :
     na

liqRaw =
     not na(avgPrice) and not na(liqDistance) ?
     isLong ? avgPrice - liqDistance : avgPrice + liqDistance :
     na

liqPrice = not na(liqRaw) and liqRaw > 0 ? liqRaw : na

liqDistancePct =
     not na(avgPrice) and not na(liqPrice) and avgPrice > 0 ?
     math.abs(avgPrice - liqPrice) / avgPrice * 100.0 :
     na

// ---------------------------------------------------
// Entry limit protection
// ---------------------------------------------------
f_entryLimitAllowed(float price) =>
    bool allowed = true

    if blockMarketableLimit
        allowed := isLong ? close > price : close < price

    allowed

currentAllowedByPrice = f_entryLimitAllowed(currentAvgPrice)
entry1AllowedByPrice = f_entryLimitAllowed(entry1Price)
entry2AllowedByPrice = f_entryLimitAllowed(entry2Price)
entry3AllowedByPrice = f_entryLimitAllowed(entry3Price)

currentAllowed = currentAllowedByPrice
entry1Allowed = entry1AllowedByPrice
entry2Allowed = entry2AllowedByPrice
entry3Allowed = entry3AllowedByPrice

// ---------------------------------------------------
// Entry hit logic
// Long:
//   Buy limit hit when low <= price.
// Short:
//   Sell limit hit when high >= price.
// ---------------------------------------------------
f_entryHit(float price) =>
    isLong ? low <= price : high >= price

currentHit = f_entryHit(currentAvgPrice)
entry1Hit = f_entryHit(entry1Price)
entry2Hit = f_entryHit(entry2Price)
entry3Hit = f_entryHit(entry3Price)

// ---------------------------------------------------
// SL protection
// ---------------------------------------------------
f_slAllowedByPrice(float price) =>
    bool allowed = true

    if blockMarketableSL
        allowed := isLong ? close > price : close < price

    allowed

slAllowedByPrice = f_slAllowedByPrice(slPrice)

requestedSlQty =
     slQtyMode == "Entire position" ? totalQty :
     slQtyMode == "Fixed quantity" ? slFixedQty :
     totalQty * slPercent / 100.0

slQty = math.min(requestedSlQty, totalQty)
slQtyOk = slQty > 0 and totalQty > 0

slHit = isLong ? low <= slPrice : high >= slPrice

// ---------------------------------------------------
// Live alerts allowed?
// ---------------------------------------------------
canProcessLive =
     mode == "Live" and
     enableLiveAlerts and
     (not placeOnlyRealtime or barstate.isrealtime)

// ---------------------------------------------------
// Arm / disarm entries
// ---------------------------------------------------
if mode != "Live" or not enableLiveAlerts or not currentIsNewEntry or not currentValid or slTriggered
    if currentSubmitted and not currentTriggered
        currentSubmitted := false

if mode != "Live" or not enableLiveAlerts or not entry1Active or slTriggered
    if entry1Submitted and not entry1Triggered
        entry1Submitted := false

if mode != "Live" or not enableLiveAlerts or not entry2Active or slTriggered
    if entry2Submitted and not entry2Triggered
        entry2Submitted := false

if mode != "Live" or not enableLiveAlerts or not entry3Active or slTriggered
    if entry3Submitted and not entry3Triggered
        entry3Submitted := false

if canProcessLive and currentIsNewEntry and currentValid and not currentSubmitted and not currentTriggered and currentAllowed and not slTriggered
    currentSubmitted := true

if canProcessLive and entry1Active and not entry1Submitted and not entry1Triggered and entry1Allowed and not slTriggered
    entry1Submitted := true

if canProcessLive and entry2Active and not entry2Submitted and not entry2Triggered and entry2Allowed and not slTriggered
    entry2Submitted := true

if canProcessLive and entry3Active and not entry3Submitted and not entry3Triggered and entry3Allowed and not slTriggered
    entry3Submitted := true

// ---------------------------------------------------
// Trigger entries exactly once
// ---------------------------------------------------
if canProcessLive and currentIsNewEntry and currentSubmitted and not currentTriggered and currentHit and not slTriggered
    currentTriggered := true
    alert(f_alertMessage("E0", entrySideText, currentQty, currentAvgPrice, false), alert.freq_all)

if canProcessLive and entry1Submitted and not entry1Triggered and entry1Hit and not slTriggered
    entry1Triggered := true
    alert(f_alertMessage("E1", entrySideText, entry1Qty, entry1Price, false), alert.freq_all)

if canProcessLive and entry2Submitted and not entry2Triggered and entry2Hit and not slTriggered
    entry2Triggered := true
    alert(f_alertMessage("E2", entrySideText, entry2Qty, entry2Price, false), alert.freq_all)

if canProcessLive and entry3Submitted and not entry3Triggered and entry3Hit and not slTriggered
    entry3Triggered := true
    alert(f_alertMessage("E3", entrySideText, entry3Qty, entry3Price, false), alert.freq_all)

// ---------------------------------------------------
// Arm / disarm SL
// ---------------------------------------------------
canArmSL =
     canProcessLive and
     slActive and
     slQtyOk and
     slAllowedByPrice and
     not slTriggered

if canArmSL
    slSubmitted := true
else
    if slSubmitted and not slTriggered
        slSubmitted := false

// ---------------------------------------------------
// Trigger SL exactly once
// ---------------------------------------------------
if canProcessLive and slSubmitted and not slTriggered and slHit
    slTriggered := true

    if not currentTriggered
        currentSubmitted := false

    if not entry1Triggered
        entry1Submitted := false

    if not entry2Triggered
        entry2Submitted := false

    if not entry3Triggered
        entry3Submitted := false

    alert(f_alertMessage("SL", slSideText, slQty, slPrice, true), alert.freq_all)

// ---------------------------------------------------
// Status
// ---------------------------------------------------
f_status(bool active, bool submitted, bool triggered, bool allowedByPrice) =>
    string result = "Inactive"

    if mode == "Simulation"
        result := active ? "Simulated" : "Inactive"
    else
        if triggered
            result := "Triggered"
        else if not active
            result := "Inactive"
        else if submitted
            result := "Armed"
        else if not enableLiveAlerts
            result := "Live alerts off"
        else if slTriggered
            result := "Stopped after SL"
        else if not allowedByPrice
            result := "Price blocked"
        else
            result := "Ready"

    result

currentStatus =
     currentAlreadyOpen and currentValid ? "Already open" :
     currentIsNewEntry ? f_status(currentValid, currentSubmitted, currentTriggered, currentAllowedByPrice) :
     "Inactive"

entry1Status = f_status(entry1Active, entry1Submitted, entry1Triggered, entry1AllowedByPrice)
entry2Status = f_status(entry2Active, entry2Submitted, entry2Triggered, entry2AllowedByPrice)
entry3Status = f_status(entry3Active, entry3Submitted, entry3Triggered, entry3AllowedByPrice)

slStatus =
     not slActive ? "Inactive" :
     slTriggered ? "Triggered" :
     mode != "Live" ? "Simulation" :
     not enableLiveAlerts ? "Live alerts off" :
     not slQtyOk ? "No position size" :
     not slAllowedByPrice ? "Price blocked" :
     slSubmitted ? "SL armed" :
     "Ready"

// ---------------------------------------------------
// Drawing helpers
// ---------------------------------------------------
f_updateLine(line id, float price, color lineColor, int width, string lineStyle, bool active) =>
    line result = id

    if active and not na(price)
        if na(result)
            result := line.new(
                 x1 = bar_index - barsBack,
                 y1 = price,
                 x2 = bar_index,
                 y2 = price,
                 xloc = xloc.bar_index,
                 extend = extendRight ? extend.right : extend.none,
                 color = lineColor,
                 width = width,
                 style = lineStyle
            )
        else
            line.set_xy1(result, bar_index - barsBack, price)
            line.set_xy2(result, bar_index, price)
            line.set_extend(result, extendRight ? extend.right : extend.none)
            line.set_color(result, lineColor)
            line.set_width(result, width)
            line.set_style(result, lineStyle)
    else
        if not na(result)
            line.delete(result)
            result := na

    result

f_updateLabel(label id, float price, string txt, color bgColor, color txtColor, bool active, int xOffsetBars) =>
    label result = id
    labelX = bar_index + xOffsetBars

    if showLabels and active and not na(price)
        if na(result)
            result := label.new(
                 x = labelX,
                 y = price,
                 text = txt,
                 xloc = xloc.bar_index,
                 style = label.style_label_left,
                 color = bgColor,
                 textcolor = txtColor,
                 size = size.small
            )
        else
            label.set_xy(result, labelX, price)
            label.set_text(result, txt)
            label.set_color(result, bgColor)
            label.set_textcolor(result, txtColor)
            label.set_size(result, size.small)
    else
        if not na(result)
            label.delete(result)
            result := na

    result

f_entryColor(bool active, bool submitted, bool triggered, bool allowed) =>
    color result = inactiveColor

    if triggered or (mode == "Simulation" and active)
        result := filledColor
    else if active
        if mode == "Live" and not allowed
            result := blockedColor
        else
            result := pendingColor

    result

f_entryStyle(bool active, bool submitted, bool triggered) =>
    string result = line.style_dotted

    if triggered or (mode == "Simulation" and active)
        result := line.style_solid
    else if active
        result := submitted ? line.style_dashed : line.style_dotted

    result

// ---------------------------------------------------
// Objects
// ---------------------------------------------------
var line avgLine = na
var line currentLine = na
var line entry1Line = na
var line entry2Line = na
var line entry3Line = na
var line slLine = na
var line liqLine = na

var label avgLabel = na
var label currentLabel = na
var label entry1Label = na
var label entry2Label = na
var label entry3Label = na
var label slLabel = na
var label liqLabel = na

// ---------------------------------------------------
// Draw
// ---------------------------------------------------
if barstate.islast
    avgText =
         "Position side: " + positionSide +
         "\nMode: " + mode +
         "\nAvg price: " + str.tostring(avgPrice, format.mintick) +
         "\nTotal qty: " + str.tostring(totalQty)

    avgLine := f_updateLine(avgLine, avgPrice, avgColor, 2, line.style_solid, not na(avgPrice))
    avgLabel := f_updateLabel(avgLabel, avgPrice, avgText, avgColor, labelTextDark, not na(avgPrice), 0)

    currentText = "Current / E0 - " + currentStatus +
         "\nMode: " + currentMode +
         "\nType: " + entryActionLabel +
         "\nPrice: " + str.tostring(currentAvgPrice, format.mintick) +
         "\nQty: " + str.tostring(currentQty) +
         "\nOrder ID: E0"

    currentVisualActive = currentIsNewEntry and currentValid

    currentLine := f_updateLine(currentLine, currentAvgPrice, f_entryColor(currentVisualActive, currentSubmitted, currentTriggered, currentAllowed), 1, f_entryStyle(currentVisualActive, currentSubmitted, currentTriggered), currentVisualActive)
    currentLabel := f_updateLabel(currentLabel, currentAvgPrice, currentText, f_entryColor(currentVisualActive, currentSubmitted, currentTriggered, currentAllowed), labelTextLight, currentVisualActive, labelXStep * 1)

    entry1Text = "Entry 1 - " + entry1Status +
         "\nType: " + entryActionLabel +
         "\nPrice: " + str.tostring(entry1Price, format.mintick) +
         "\nQty: " + str.tostring(entry1Qty) +
         "\nOrder ID: E1"

    entry2Text = "Entry 2 - " + entry2Status +
         "\nType: " + entryActionLabel +
         "\nPrice: " + str.tostring(entry2Price, format.mintick) +
         "\nQty: " + str.tostring(entry2Qty) +
         "\nOrder ID: E2"

    entry3Text = "Entry 3 - " + entry3Status +
         "\nType: " + entryActionLabel +
         "\nPrice: " + str.tostring(entry3Price, format.mintick) +
         "\nQty: " + str.tostring(entry3Qty) +
         "\nOrder ID: E3"

    entry1Line := f_updateLine(entry1Line, entry1Price, f_entryColor(entry1Active, entry1Submitted, entry1Triggered, entry1Allowed), 1, f_entryStyle(entry1Active, entry1Submitted, entry1Triggered), entry1Active or entry1Triggered)
    entry2Line := f_updateLine(entry2Line, entry2Price, f_entryColor(entry2Active, entry2Submitted, entry2Triggered, entry2Allowed), 1, f_entryStyle(entry2Active, entry2Submitted, entry2Triggered), entry2Active or entry2Triggered)
    entry3Line := f_updateLine(entry3Line, entry3Price, f_entryColor(entry3Active, entry3Submitted, entry3Triggered, entry3Allowed), 1, f_entryStyle(entry3Active, entry3Submitted, entry3Triggered), entry3Active or entry3Triggered)

    entry1Label := f_updateLabel(entry1Label, entry1Price, entry1Text, f_entryColor(entry1Active, entry1Submitted, entry1Triggered, entry1Allowed), labelTextLight, entry1Active or entry1Triggered, labelXStep * 2)
    entry2Label := f_updateLabel(entry2Label, entry2Price, entry2Text, f_entryColor(entry2Active, entry2Submitted, entry2Triggered, entry2Allowed), labelTextLight, entry2Active or entry2Triggered, labelXStep * 3)
    entry3Label := f_updateLabel(entry3Label, entry3Price, entry3Text, f_entryColor(entry3Active, entry3Submitted, entry3Triggered, entry3Allowed), labelTextLight, entry3Active or entry3Triggered, labelXStep * 4)

    slText = "SL - " + slStatus +
         "\nType: " + slActionLabel +
         "\nPrice: " + str.tostring(slPrice, format.mintick) +
         "\nQty: " + str.tostring(slQty) +
         "\nQty mode: " + slQtyMode +
         "\nReduce-only: true" +
         "\nOrder ID: SL"

    slLine := f_updateLine(slLine, slPrice, slColor, 2, line.style_dashed, slActive)
    slLabel := f_updateLabel(slLabel, slPrice, slText, slColor, labelTextLight, slActive, labelXStep * 5)

    liqText = "Liquidation approx." +
         "\nPrice: " + str.tostring(liqPrice, format.mintick) +
         "\nCapital: " + str.tostring(tradeCapital, format.mintick) +
         "\nDistance: " + str.tostring(liqDistancePct, "#.##") + "%" +
         "\nImpl. leverage: " + str.tostring(impliedLeverage, "#.##") + "x"

    liqLine := f_updateLine(liqLine, liqPrice, liqColor, 2, line.style_dotted, showLiquidation and not na(liqPrice))
    liqLabel := f_updateLabel(liqLabel, liqPrice, liqText, liqColor, labelTextLight, showLiquidation and not na(liqPrice), labelXStep * 6)

// ---------------------------------------------------
// Info table
// ---------------------------------------------------
var table infoTable = table.new(position.top_right, 2, 17, border_width = 1)

if barstate.islast
    if showTable
        table.cell(infoTable, 0, 0, "Position side", text_color = tableText, bgcolor = tableHeaderBg)
        table.cell(infoTable, 1, 0, positionSide, text_color = tableText, bgcolor = tableHeaderBg)

        table.cell(infoTable, 0, 1, "Mode", text_color = tableText, bgcolor = tableCellBg)
        table.cell(infoTable, 1, 1, mode, text_color = tableText, bgcolor = tableCellBg)

        table.cell(infoTable, 0, 2, "Current mode", text_color = tableText, bgcolor = tableCellBg)
        table.cell(infoTable, 1, 2, currentMode, text_color = tableText, bgcolor = tableCellBg)

        table.cell(infoTable, 0, 3, "Live alerts", text_color = tableText, bgcolor = tableCellBg)
        table.cell(infoTable, 1, 3, enableLiveAlerts ? "ON" : "OFF", text_color = tableText, bgcolor = tableCellBg)

        table.cell(infoTable, 0, 4, "Avg price", text_color = tableText, bgcolor = tableCellBg)
        table.cell(infoTable, 1, 4, str.tostring(avgPrice, format.mintick), text_color = tableText, bgcolor = tableCellBg)

        table.cell(infoTable, 0, 5, "Total qty", text_color = tableText, bgcolor = tableCellBg)
        table.cell(infoTable, 1, 5, str.tostring(totalQty), text_color = tableText, bgcolor = tableCellBg)

        table.cell(infoTable, 0, 6, "Notional", text_color = tableText, bgcolor = tableCellBg)
        table.cell(infoTable, 1, 6, str.tostring(positionNotional, format.mintick), text_color = tableText, bgcolor = tableCellBg)

        table.cell(infoTable, 0, 7, "Trade capital", text_color = tableText, bgcolor = tableCellBg)
        table.cell(infoTable, 1, 7, str.tostring(tradeCapital, format.mintick), text_color = tableText, bgcolor = tableCellBg)

        table.cell(infoTable, 0, 8, "Impl. leverage", text_color = tableText, bgcolor = tableCellBg)
        table.cell(infoTable, 1, 8, str.tostring(impliedLeverage, "#.##") + "x", text_color = tableText, bgcolor = tableCellBg)

        table.cell(infoTable, 0, 9, "Liq. distance", text_color = tableText, bgcolor = tableCellBg)
        table.cell(infoTable, 1, 9, str.tostring(liqDistancePct, "#.##") + "%", text_color = tableText, bgcolor = tableCellBg)

        table.cell(infoTable, 0, 10, "Liq. price", text_color = tableText, bgcolor = tableCellBg)
        table.cell(infoTable, 1, 10, showLiquidation and not na(liqPrice) ? str.tostring(liqPrice, format.mintick) : "Off", text_color = tableText, bgcolor = tableCellBg)

        table.cell(infoTable, 0, 11, "Current / E0", text_color = tableText, bgcolor = tableCellBg)
        table.cell(infoTable, 1, 11, currentStatus, text_color = tableText, bgcolor = tableCellBg)

        table.cell(infoTable, 0, 12, "Entry 1", text_color = tableText, bgcolor = tableCellBg)
        table.cell(infoTable, 1, 12, entry1Status, text_color = tableText, bgcolor = tableCellBg)

        table.cell(infoTable, 0, 13, "Entry 2", text_color = tableText, bgcolor = tableCellBg)
        table.cell(infoTable, 1, 13, entry2Status, text_color = tableText, bgcolor = tableCellBg)

        table.cell(infoTable, 0, 14, "Entry 3", text_color = tableText, bgcolor = tableCellBg)
        table.cell(infoTable, 1, 14, entry3Status, text_color = tableText, bgcolor = tableCellBg)

        table.cell(infoTable, 0, 15, "SL", text_color = tableText, bgcolor = tableCellBg)
        table.cell(infoTable, 1, 15, slStatus, text_color = tableText, bgcolor = tableCellBg)

        table.cell(infoTable, 0, 16, "SL qty", text_color = tableText, bgcolor = tableCellBg)
        table.cell(infoTable, 1, 16, str.tostring(slQty), text_color = tableText, bgcolor = tableCellBg)
    else
        table.clear(infoTable, 0, 0, 1, 16)
````
