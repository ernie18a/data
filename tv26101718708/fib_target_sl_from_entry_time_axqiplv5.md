# Fib Target & SL From Entry Time

- url: https://www.tradingview.com/script/axqiplv5-Fib-Target-SL-From-Entry-Time/
- type: indicator
- pine_id: PUB;574218bb400f4753bc2637027e1ba477
- version: 1.0

## Description

Fib Target & SL From Entry Time
Time-Based Entry, Automatic Stop Loss & Fibonacci Target Projection

OVERVIEW

Fib Target & SL From Entry Time is a professional trade planning and risk management indicator designed to automatically generate Stop Loss and Fibonacci-based Take Profit levels from a user-selected Entry Time.

Instead of manually calculating risk, reward, and target levels, simply select the direction of your trade and choose the Entry Date & Time. The indicator automatically captures the trade setup and projects multiple Fibonacci extension targets together with a dynamic Stop Loss based on recent market structure.

This tool is ideal for traders who want to plan trades objectively, manage risk consistently, and visualize reward-to-risk opportunities directly on the chart.

━━━━━━━━━━━━━━━━━━━━━━
KEY FEATURES
━━━━━━━━━━━━━━━━━━━━━━

✓ Manual Trade Direction Selection
Choose between Long and Short trade setups.

✓ Time-Based Entry Detection
Select any historical or future Entry Date & Time.
The indicator automatically captures the first candle that reaches or crosses the selected time.

✓ Automatic Entry Price Lock
Entry price is locked using the closing price of the selected entry candle.

✓ Automatic Swing-Based Stop Loss
For Long trades:
Stop Loss is placed below the lowest swing low.

For Short trades:
Stop Loss is placed above the highest swing high.

✓ Fibonacci Extension Targets
Automatically calculates:

• TP1
• TP2
• TP3

using customizable Fibonacci multipliers.

✓ Risk-Reward Calculation
Instantly displays expected Reward-to-Risk ratios for all targets.

✓ Dashboard Panel
View all important trade information in one place:

• Trade Direction
• Entry Price
• Stop Loss
• TP1
• TP2
• TP3
• Risk-Reward Ratios
• Trade Status

✓ Visual Trade Levels
Draws clean horizontal levels for:

• Entry
• Stop Loss
• TP1
• TP2
• TP3

✓ Alert Support
Built-in alerts for:

• New Trade Captured
• TP1 Hit
• TP2 Hit
• TP3 Hit
• Stop Loss Hit

━━━━━━━━━━━━━━━━━━━━━━
HOW IT WORKS
━━━━━━━━━━━━━━━━━━━━━━

LONG TRADE

1. Select Long Direction.
2. Choose Entry Date & Time.
3. Indicator captures the closing price of the entry candle.
4. Lowest low from the selected Swing Length becomes Stop Loss.
5. Fibonacci targets are projected above Entry Price.

SHORT TRADE

1. Select Short Direction.
2. Choose Entry Date & Time.
3. Indicator captures the closing price of the entry candle.
4. Highest high from the selected Swing Length becomes Stop Loss.
5. Fibonacci targets are projected below Entry Price.

━━━━━━━━━━━━━━━━━━━━━━
HOW TO USE
━━━━━━━━━━━━━━━━━━━━━━

Step 1

Add the indicator to your chart.

Step 2

Choose:

• Long
or
• Short

under Trade Direction.

Step 3

Select your desired Entry Date & Time.

Step 4

Adjust Swing Length if required.

Higher values:
Wider Stop Loss

Lower values:
Tighter Stop Loss

Step 5

Customize Fibonacci multipliers if desired.

Default values:

TP1 = 1.272
TP2 = 1.618
TP3 = 2.618

Step 6

Monitor projected levels and trade status using the dashboard.

━━━━━━━━━━━━━━━━━━━━━━
ALERT SETUP
━━━━━━━━━━━━━━━━━━━━━━

To create alerts:

1. Click Add Alert.
2. Select Fib Trade Planner Pro.
3. Choose one of the following conditions:

• New Trade Captured
• TP1 Hit
• TP2 Hit
• TP3 Hit
• Stop Loss Hit

4. Create the alert.

The indicator will notify you whenever the selected event occurs.

━━━━━━━━━━━━━━━━━━━━━━
WHO CAN USE THIS INDICATOR?
━━━━━━━━━━━━━━━━━━━━━━

• Swing Traders
• Position Traders
• Intraday Traders
• Crypto Traders
• Forex Traders
• Stock Market Traders
• Risk Management Focused Traders

━━━━━━━━━━━━━━━━━━━━━━
IMPORTANT NOTES
━━━━━━━━━━━━━━━━━━━━━━

• This indicator is designed for trade planning and visualization.
• Entry price is based on the closing price of the selected entry candle.
• Fibonacci targets are calculated from the Entry-to-Stop Loss risk distance.
• Risk management remains the responsibility of the trader.
• Past performance does not guarantee future results.

━━━━━━━━━━━━━━━━━━━━━━
Fib Target & SL From Entry Time helps traders quickly build structured trade setups with predefined risk, reward, and Fibonacci target levels while maintaining a disciplined trading approach.

## Source Code

````pine
//@version=6
indicator("Fib Target & SL From Entry Time", shorttitle = "Fib TP/SL", overlay = true, max_lines_count = 50, max_labels_count = 50)

// ============================================================================
// INPUTS
// ============================================================================
grpTrade = "Trade Setup"
direction  = input.string(title = "Trade Direction", defval = "Long", options = ["Long", "Short"], group = grpTrade)
entryTime  = input.time(title = "Entry Date & Time", defval = timestamp("2026-06-19 00:00 +0000"), group = grpTrade, tooltip = "Pick the exact date & time of the candle you want as your Entry. The script finds the candle whose open-time matches/crosses this moment and locks Entry = that candle's CLOSE. Works for past dates too (scans chart history) and for future times (waits and captures live).")

grpCalc = "Calculation Settings"
swingLength = input.int(title = "Swing Length (bars)", defval = 20, minval = 1, group = grpCalc)

grpFib = "Fibonacci Multipliers"
fibTP1 = input.float(title = "TP1 Multiplier", defval = 1.272, step = 0.001, group = grpFib)
fibTP2 = input.float(title = "TP2 Multiplier", defval = 1.618, step = 0.001, group = grpFib)
fibTP3 = input.float(title = "TP3 Multiplier", defval = 2.618, step = 0.001, group = grpFib)

grpVisual = "Visual Settings"
showLabels  = input.bool(title = "Show Labels", defval = true, group = grpVisual)
extendRight = input.bool(title = "Extend Lines Right", defval = true, group = grpVisual)
lineWidth   = input.int(title = "Line Width", defval = 2, minval = 1, maxval = 4, group = grpVisual)

grpDash = "Dashboard"
showDashboard = input.bool(title = "Show Dashboard", defval = true, group = grpDash)
dashLocation  = input.string(title = "Dashboard Position", defval = "Top Right", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpDash)
dashSize      = input.string(title = "Dashboard Text Size", defval = "Normal", options = ["Tiny", "Small", "Normal", "Large"], group = grpDash)

// ============================================================================
// FIXED COLORS (per spec)
// ============================================================================
colEntry = color.blue
colSL    = color.red
colTP    = color.green

// ============================================================================
// PERSISTENT STATE (var = initialized once, survives across all bars)
// ============================================================================
var float  entryPrice = na
var float  slPrice    = na
var float  tp1Price   = na
var float  tp2Price   = na
var float  tp3Price   = na
var string tradeDir   = ""
var bool   tradeActive = false
var string tradeStatus = "No Trade"

var bool tp1Hit = false
var bool tp2Hit = false
var bool tp3Hit = false
var bool slHit  = false

// One-bar "just happened" pulse flags, used only for alerts (avoids history-referencing pitfalls)
var bool justCaptured = false
var bool justTp1      = false
var bool justTp2      = false
var bool justTp3      = false
var bool justSl       = false

var line  entryLine = na
var line  slLine    = na
var line  tp1Line   = na
var line  tp2Line   = na
var line  tp3Line   = na

var label entryLbl = na
var label slLbl    = na
var label tp1Lbl   = na
var label tp2Lbl   = na
var label tp3Lbl   = na

var float lastEntryTimeUsed = na   // remembers which entryTime value we last captured for
var bool  capturedForCurrentTime = false  // true once we've captured for lastEntryTimeUsed

// Reset one-bar pulse flags at the start of every bar's evaluation
justCaptured := false
justTp1      := false
justTp2      := false
justTp3      := false
justSl       := false

// ============================================================================
// CAPTURE LOGIC
// Fires on the FIRST bar whose time is >= the user-selected entryTime.
// - Past entryTime: on first script load, history is scanned bar-by-bar from
//   the left; the first historical bar satisfying time >= entryTime captures
//   immediately using that bar's already-printed, fixed close (not lookahead,
//   since that bar has already closed on the chart).
// - Future entryTime: nothing captures until real time reaches that bar; then
//   it captures live using that bar's close once it closes / updates.
// - If the user picks a NEW entryTime (any direction, past or future), the
//   "captured" flag resets so the script re-arms and looks for the new match.
// ============================================================================
if entryTime != lastEntryTimeUsed
    lastEntryTimeUsed := entryTime
    capturedForCurrentTime := false

captureTriggered = not capturedForCurrentTime and time >= entryTime

if captureTriggered
    capturedForCurrentTime := true
    entryPrice  := close
    tradeDir    := direction
    tradeActive := true
    tradeStatus := "Active"
    justCaptured := true

    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    slHit  := false

    if tradeDir == "Long"
        swingLow = ta.lowest(low, swingLength)
        slPrice := swingLow
        riskLong = entryPrice - slPrice
        tp1Price := entryPrice + riskLong * fibTP1
        tp2Price := entryPrice + riskLong * fibTP2
        tp3Price := entryPrice + riskLong * fibTP3
    else
        swingHigh = ta.highest(high, swingLength)
        slPrice := swingHigh
        riskShort = slPrice - entryPrice
        tp1Price := entryPrice - riskShort * fibTP1
        tp2Price := entryPrice - riskShort * fibTP2
        tp3Price := entryPrice - riskShort * fibTP3

// ============================================================================
// TRADE STATUS MONITORING (runs every bar while a trade is active)
// ============================================================================
if tradeActive
    isLong = tradeDir == "Long"
    slCondition  = isLong ? low <= slPrice  : high >= slPrice
    tp1Condition = isLong ? high >= tp1Price : low <= tp1Price
    tp2Condition = isLong ? high >= tp2Price : low <= tp2Price
    tp3Condition = isLong ? high >= tp3Price : low <= tp3Price

    if not slHit and slCondition
        slHit := true
        justSl := true
        tradeActive := false
        tradeStatus := "Stop Loss Hit"

    if tradeActive
        if not tp1Hit and tp1Condition
            tp1Hit  := true
            justTp1 := true
        if not tp2Hit and tp2Condition
            tp2Hit  := true
            justTp2 := true
        if not tp3Hit and tp3Condition
            tp3Hit  := true
            justTp3 := true
            tradeActive := false
            tradeStatus := "TP3 Hit - Trade Complete"

    if tradeActive
        tradeStatus := tp2Hit ? "TP2 Hit - Running" : tp1Hit ? "TP1 Hit - Running" : "Active"

// ============================================================================
// DRAWING — lines are created once per trade and updated in place every bar
// (cheaper than delete+recreate, and avoids any flicker / repaint artifacts).
// ============================================================================
if not na(entryPrice)
    x1 = bar_index - 1
    x2 = bar_index
    extendStyle = extendRight ? extend.right : extend.none

    if captureTriggered
        // Brand-new trade: (re)create the drawing objects
        line.delete(entryLine)
        line.delete(slLine)
        line.delete(tp1Line)
        line.delete(tp2Line)
        line.delete(tp3Line)
        label.delete(entryLbl)
        label.delete(slLbl)
        label.delete(tp1Lbl)
        label.delete(tp2Lbl)
        label.delete(tp3Lbl)

        entryLine := line.new(x1, entryPrice, x2, entryPrice, extend = extendStyle, color = colEntry, width = lineWidth, style = line.style_solid)
        slLine    := line.new(x1, slPrice,    x2, slPrice,    extend = extendStyle, color = colSL,    width = lineWidth, style = line.style_solid)
        tp1Line   := line.new(x1, tp1Price,   x2, tp1Price,   extend = extendStyle, color = colTP,    width = lineWidth, style = line.style_dashed)
        tp2Line   := line.new(x1, tp2Price,   x2, tp2Price,   extend = extendStyle, color = colTP,    width = lineWidth, style = line.style_dashed)
        tp3Line   := line.new(x1, tp3Price,   x2, tp3Price,   extend = extendStyle, color = colTP,    width = lineWidth, style = line.style_dashed)

        if showLabels
            entryLbl := label.new(x2, entryPrice, "ENTRY\n" + str.tostring(entryPrice, format.mintick), style = label.style_label_left, color = colEntry, textcolor = color.white, size = size.small)
            slLbl    := label.new(x2, slPrice,    "SL\n"    + str.tostring(slPrice,    format.mintick), style = label.style_label_left, color = colSL,    textcolor = color.white, size = size.small)
            tp1Lbl   := label.new(x2, tp1Price,   "TP1\n"   + str.tostring(tp1Price,   format.mintick), style = label.style_label_left, color = colTP,    textcolor = color.white, size = size.small)
            tp2Lbl   := label.new(x2, tp2Price,   "TP2\n"   + str.tostring(tp2Price,   format.mintick), style = label.style_label_left, color = colTP,    textcolor = color.white, size = size.small)
            tp3Lbl   := label.new(x2, tp3Price,   "TP3\n"   + str.tostring(tp3Price,   format.mintick), style = label.style_label_left, color = colTP,    textcolor = color.white, size = size.small)
    else
        // Same trade still active/closed: just stretch the right edge & slide labels forward
        if not extendRight
            line.set_x2(entryLine, bar_index)
            line.set_x2(slLine, bar_index)
            line.set_x2(tp1Line, bar_index)
            line.set_x2(tp2Line, bar_index)
            line.set_x2(tp3Line, bar_index)

        if showLabels
            label.set_x(entryLbl, bar_index + 1)
            label.set_x(slLbl, bar_index + 1)
            label.set_x(tp1Lbl, bar_index + 1)
            label.set_x(tp2Lbl, bar_index + 1)
            label.set_x(tp3Lbl, bar_index + 1)

// ============================================================================
// DASHBOARD
// ============================================================================
getPos(p) =>
    result = switch p
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right
    result

getSize(s) =>
    result = switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.normal
    result

rrTxt(rr) =>
    na(rr) ? "—" : str.tostring(rr, "#.##") + "R"

var table dash = table.new(position = getPos(dashLocation), columns = 2, rows = 9, border_width = 1)
var string lastDashPos = dashLocation

if dashLocation != lastDashPos
    table.delete(dash)
    dash := table.new(position = getPos(dashLocation), columns = 2, rows = 9, border_width = 1)
    lastDashPos := dashLocation

if showDashboard and barstate.islast
    table.clear(dash, 0, 0, 1, 8)

    headerBg = color.new(color.gray, 20)
    rowBg    = color.new(color.gray, 85)
    tsize    = getSize(dashSize)

    table.cell(dash, 0, 0, "FIB TRADE DASHBOARD", text_color = color.white, bgcolor = headerBg, text_size = tsize)
    table.cell(dash, 1, 0, "", bgcolor = headerBg)

    hasTrade = not na(entryPrice) and not na(slPrice) and entryPrice != slPrice
    rr1 = hasTrade ? math.abs(tp1Price - entryPrice) / math.abs(entryPrice - slPrice) : na
    rr2 = hasTrade ? math.abs(tp2Price - entryPrice) / math.abs(entryPrice - slPrice) : na
    rr3 = hasTrade ? math.abs(tp3Price - entryPrice) / math.abs(entryPrice - slPrice) : na

    table.cell(dash, 0, 1, "Direction", text_color = color.white, bgcolor = rowBg, text_size = tsize)
    table.cell(dash, 1, 1, tradeDir == "" ? "—" : tradeDir, text_color = tradeDir == "Long" ? color.lime : color.orange, bgcolor = rowBg, text_size = tsize)

    table.cell(dash, 0, 2, "Entry", text_color = color.white, bgcolor = rowBg, text_size = tsize)
    table.cell(dash, 1, 2, na(entryPrice) ? "—" : str.tostring(entryPrice, format.mintick), text_color = colEntry, bgcolor = rowBg, text_size = tsize)

    table.cell(dash, 0, 3, "Stop Loss", text_color = color.white, bgcolor = rowBg, text_size = tsize)
    table.cell(dash, 1, 3, na(slPrice) ? "—" : str.tostring(slPrice, format.mintick), text_color = colSL, bgcolor = rowBg, text_size = tsize)

    table.cell(dash, 0, 4, "TP1", text_color = color.white, bgcolor = rowBg, text_size = tsize)
    table.cell(dash, 1, 4, na(tp1Price) ? "—" : str.tostring(tp1Price, format.mintick), text_color = colTP, bgcolor = rowBg, text_size = tsize)

    table.cell(dash, 0, 5, "TP2", text_color = color.white, bgcolor = rowBg, text_size = tsize)
    table.cell(dash, 1, 5, na(tp2Price) ? "—" : str.tostring(tp2Price, format.mintick), text_color = colTP, bgcolor = rowBg, text_size = tsize)

    table.cell(dash, 0, 6, "TP3", text_color = color.white, bgcolor = rowBg, text_size = tsize)
    table.cell(dash, 1, 6, na(tp3Price) ? "—" : str.tostring(tp3Price, format.mintick), text_color = colTP, bgcolor = rowBg, text_size = tsize)

    table.cell(dash, 0, 7, "RR (TP1/TP2/TP3)", text_color = color.white, bgcolor = rowBg, text_size = tsize)
    table.cell(dash, 1, 7, rrTxt(rr1) + " / " + rrTxt(rr2) + " / " + rrTxt(rr3), text_color = color.white, bgcolor = rowBg, text_size = tsize)

    statusColor = tradeStatus == "Stop Loss Hit" ? color.red : tradeStatus == "No Trade" ? color.gray : str.contains(tradeStatus, "TP3") ? color.lime : color.yellow
    table.cell(dash, 0, 8, "Trade Status", text_color = color.white, bgcolor = rowBg, text_size = tsize)
    table.cell(dash, 1, 8, tradeStatus, text_color = statusColor, bgcolor = rowBg, text_size = tsize)

// ============================================================================
// ALERTS
// ============================================================================
alertcondition(justCaptured, title = "New Trade Captured", message = "New Trade Captured: Entry locked at close.")
alertcondition(justTp1, title = "TP1 Hit", message = "TP1 Hit!")
alertcondition(justTp2, title = "TP2 Hit", message = "TP2 Hit!")
alertcondition(justTp3, title = "TP3 Hit", message = "TP3 Hit! Trade complete.")
alertcondition(justSl, title = "Stop Loss Hit", message = "Stop Loss Hit!")

if justCaptured
    alert("New Trade Captured: " + tradeDir + " @ " + str.tostring(entryPrice, format.mintick), alert.freq_once_per_bar)
if justTp1
    alert("TP1 Hit @ " + str.tostring(tp1Price, format.mintick), alert.freq_once_per_bar)
if justTp2
    alert("TP2 Hit @ " + str.tostring(tp2Price, format.mintick), alert.freq_once_per_bar)
if justTp3
    alert("TP3 Hit @ " + str.tostring(tp3Price, format.mintick) + " - Trade Complete", alert.freq_once_per_bar)
if justSl
    alert("Stop Loss Hit @ " + str.tostring(slPrice, format.mintick), alert.freq_once_per_bar)
````
