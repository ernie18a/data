# Auto Fib Retracement & Extensions exact copy of SNIPER Close

- url: https://www.tradingview.com/script/SbKZYQS6-Auto-Fib-Retracement-Extensions-exact-copy-of-SNIPER-Close/
- type: indicator
- pine_id: PUB;6f60f1ef5fac43b3a844003703c84ae8
- version: 5.0

## Description

It’s an auto-updating Fibonacci retracement and extension indicator that:

Detects swing highs/lows
Identifies trend direction (bullish or bearish)
Draws key Fibonacci levels
Highlights entry and target zones
Visually maps the trend with zigzag and background zones.

This isn’t just a basic Fib tool — it’s more like a mini trading system.
1. Smart Swing Detection
2. Trend Awareness
3. Full Fibonacci Framework
4. Visual Clarity (Big Advantage)
5. Built-in Trade Logic
6. Efficient Object Management
Baste on the SNIPER Close Indicator, and it will be updated regularly, and it's FREE.

## Source Code

````pine
// ─────────────────────────────────────────────────────────────
// Auto Fibonacci Pro
// this script is made by Vitaliy D copyright (R)2026
// Unauthorized copying or redistribution prohibited.
// ─────────────────────────────────────────────────────────────

//@version=6
indicator("VD Auto Fibonacci Pro", overlay=true,
     max_lines_count=500, max_labels_count=500, max_boxes_count=50)

// ── Inputs ────────────────────────────────────────────────────

grp1 = "Swing Detection"
useManualLen = input.bool(false, "Use Manual Pivot Length?", group=grp1, tooltip="If unchecked, length is automatic based on timeframe.")
manualLen    = input.int(21, "Manual Pivot Length", minval=3, group=grp1)

grpHeat = "Heatmap Settings"
showHeat = input.bool(true, "Enable Momentum Heatmap", group=grpHeat)
heatLen  = input.int(14, "Momentum Length (RSI)", group=grpHeat)
coldCol  = input.color(color.rgb(245, 29, 21), "Cold (Oversold)", group=grpHeat)
hotCol   = input.color(color.rgb(26, 245, 92), "Hot (Overbought)", group=grpHeat)

// ── Automatic Length Logic ────────────────────────────────────
int autoLen = 21 
if not useManualLen
    if timeframe.period == "30"
        autoLen := 6
    else if timeframe.period == "60"
        autoLen := 6
    else if timeframe.period == "120"
        autoLen := 21
    else if timeframe.period == "180"
        autoLen := 24
    else if timeframe.period == "240"
        autoLen := 8
    else if timeframe.isdaily and timeframe.multiplier == 1
        autoLen := 6
    else
        autoLen := 21

int swingLen = useManualLen ? manualLen : autoLen

// ── Heatmap Calculation ──────────────────────────────────────
rsiVal = ta.rsi(close, heatLen)
heatColor = color.from_gradient(rsiVal, 30, 70, coldCol, hotCol)

barcolor(showHeat ? heatColor : na)
bgcolor(showHeat ? color.new(heatColor, 50) : na)

// ── Other Inputs ──────────────────────────────────────────────
grp2 = "Display"
showRetrace = input.bool(true,  "Retracement Levels", group=grp2)
showExt     = input.bool(true,  "Extension Levels",   group=grp2)
showZigzag  = input.bool(true,  "Swing ZigZag Line",  group=grp2)
showBG      = input.bool(true,  "Colored Background", group=grp2)
showEntries = input.bool(true,  "Entry / Exit Zones", group=grp2)

grpDash = "Dashboard Settings"
showDash    = input.bool(true,    "Show Dashboard",        group=grpDash)
dashPos     = input.string("top_right", "Position", options=["top_right", "bottom_right", "top_left", "bottom_left", "top_center", "bottom_center"], group=grpDash)
dashSize    = input.string("small", "Size", options=["tiny", "small", "normal", "large"], group=grpDash)
dashBg      = input.color(color.new(#111213, 38), "Dash Background", group=grpDash)

grpSMA = "Moving Averages"
showSMA     = input.bool(false,  "Show SMAs",           group=grpSMA)
sma30Col    = input.color(#0a22f8, "SMA 30 Color",    group=grpSMA)
sma50Col    = input.color(#e21754, "SMA 50 Color",    group=grpSMA)
sma200Col   = input.color(#9c27b0, "SMA 200 Color",   group=grpSMA)

grp3 = "Colors"
bullCol  = input.color(color.rgb(14, 252, 34), "Bullish",    group=grp3)
bearCol  = input.color(#f44336, "Bearish",    group=grp3)
extCol   = input.color(#0a0a0a, "General Extensions", group=grp3)
entryCol = input.color(#4caf50, "Entry Zone", group=grp3)
exitCol  = input.color(#fa1c14, "Exit Zone",  group=grp3)
tp1Col   = input.color(#121312, "TP 1 (1.272)", group=grp3)
tp2Col   = input.color(#0a0a0a, "TP 2 (1.618)", group=grp3)
tp3Col   = input.color(#0a0a0a, "TP 3 (2.618)", group=grp3)

// ── SMA Calculations ──────────────────────────────────────────
sma30  = ta.sma(close, 30)
sma50  = ta.sma(close, 50)
sma200 = ta.sma(close, 200)

plot(showSMA ? sma30 : na,  "SMA 30",  color=sma30Col,  linewidth=1)
plot(showSMA ? sma50 : na,  "SMA 50",  color=sma50Col,  linewidth=2)
plot(showSMA ? sma200 : na, "SMA 200", color=sma200Col, linewidth=2)

// ── GLOBAL HELPER FUNCTIONS ──────────────────────────────────
fmt(v) => str.tostring(v, format.mintick)

// ── Pivot Detection ───────────────────────────────────────────
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow (low,  swingLen, swingLen)

var float lastHigh    = na
var int   lastHighBar = na
var float lastLow     = na
var int   lastLowBar  = na

if not na(ph)
    lastHigh    := ph
    lastHighBar := bar_index - swingLen
if not na(pl)
    lastLow     := pl
    lastLowBar  := bar_index - swingLen

// ── Trend & Dashboard Math ────────────────────────────────────
isBull = not na(lastLowBar)  and not na(lastHighBar) and lastLowBar  > lastHighBar
isBear = not na(lastHighBar) and not na(lastLowBar)  and lastHighBar > lastLowBar

trendCol = isBull ? bullCol : bearCol
rangeSize = lastHigh - lastLow
rawPercent = ((close - lastLow) / rangeSize) * 100

bullStrength = math.max(0, math.min(100, rawPercent))
bearStrength = 100 - bullStrength

// ── Dashboard Creation ────────────────────────────────────────
var table dashTable = table.new(dashPos, 2, 3, bgcolor=dashBg, border_width=1, border_color=color.new(color.gray, 70))

if showDash and barstate.islast
    table.cell(dashTable, 0, 0, "BULL STRENGTH", text_color=bullCol, text_size=dashSize)
    table.cell(dashTable, 1, 0, str.tostring(bullStrength, "0.0") + "%", text_color=bullCol, text_size=dashSize)
    table.cell(dashTable, 0, 1, "BEAR STRENGTH", text_color=bearCol, text_size=dashSize)
    table.cell(dashTable, 1, 1, str.tostring(bearStrength, "0.0") + "%", text_color=bearCol, text_size=dashSize)
    table.cell(dashTable, 0, 2, "PIVOT LEN", text_color=color.white, text_size=dashSize)
    table.cell(dashTable, 1, 2, str.tostring(swingLen), text_color=color.white, text_size=dashSize)

// ── Fib Math ──────────────────────────────────────────────────
pointA = isBull ? lastLow  : lastHigh
pointB = isBull ? lastHigh : lastLow
move = math.abs(pointB - pointA)

fibR(r) => isBull ? pointB - move * r : pointB + move * r
fibE(r) => isBull ? pointB + move * r : pointB - move * r

r0   = fibR(0.000)
r236 = fibR(0.236)
r382 = fibR(0.382)
r500 = fibR(0.500)
r618 = fibR(0.618)
r786 = fibR(0.786)
r100 = fibR(1.000)

e1272 = fibE(0.272)
e1414 = fibE(0.414)
e1618 = fibE(0.618)
e2000 = fibE(1.000)
e2618 = fibE(1.618)

// ── Drawing Arrays & Clear Logic ──────────────────────────────
var line[]  rLines   = array.new_line()
var line[]  eLines   = array.new_line()
var label[] rLabels  = array.new_label()
var label[] eLabels  = array.new_label()
var box[]   bgBoxes  = array.new_box()
var box[]   entBoxes = array.new_box()
var line zzLine = na

clearAll() =>
    if array.size(rLines) > 0
        for i = 0 to array.size(rLines) - 1
            line.delete(array.get(rLines, i))
    if array.size(eLines) > 0
        for i = 0 to array.size(eLines) - 1
            line.delete(array.get(eLines, i))
    if array.size(rLabels) > 0
        for i = 0 to array.size(rLabels) - 1
            label.delete(array.get(rLabels, i))
    if array.size(eLabels) > 0
        for i = 0 to array.size(eLabels) - 1
            label.delete(array.get(eLabels, i))
    if array.size(bgBoxes) > 0
        for i = 0 to array.size(bgBoxes) - 1
            box.delete(array.get(bgBoxes, i))
    if array.size(entBoxes) > 0
        for i = 0 to array.size(entBoxes) - 1
            box.delete(array.get(entBoxes, i))

    array.clear(rLines)
    array.clear(eLines)
    array.clear(rLabels)
    array.clear(eLabels)
    array.clear(bgBoxes)
    array.clear(entBoxes)
    line.delete(zzLine)

// ── Drawing Functions ────────────────────────────────────────
drawLevel(lvl, lbl, col, bold, isExt, startBar) =>
    w = bold ? 2 : 1
    s = bold ? line.style_solid : line.style_dashed
    ln = line.new(startBar, lvl, bar_index + 10, lvl, color=col, width=w, style=s)
    lb = label.new(bar_index + 11, lvl, lbl, style=label.style_label_left, color=color.new(color.black, 100), textcolor=col, size=size.small)
    if isExt
        array.push(eLines, ln)
        array.push(eLabels, lb)
    else
        array.push(rLines, ln)
        array.push(rLabels, lb)

drawBG(top, bot, col, transp) =>
    startBar = isBull ? lastLowBar : lastHighBar
    b = box.new(startBar, top, bar_index + 10, bot, border_color=color.new(col, 100), bgcolor=color.new(col, transp))
    array.push(bgBoxes, b)

drawZone(top, bot, col, lbl) =>
    startBar = isBull ? lastLowBar : lastHighBar
    b = box.new(startBar, top, bar_index + 10, bot, border_color=color.new(col, 60), bgcolor=color.new(col, 82), text=lbl, text_color=color.new(col, 0), text_size=size.small, text_halign=text.align_right, text_valign=text.align_center)
    array.push(entBoxes, b)

// ── Main Execution ────────────────────────────────────────────
if barstate.islast
    clearAll()
    startBar = isBull ? lastLowBar : lastHighBar
    if showZigzag
        aBar = isBull ? lastHighBar : lastLowBar
        aVal = isBull ? lastHigh    : lastLow
        bBar = isBull ? lastLowBar  : lastHighBar
        bVal = isBull ? lastLow     : lastHigh
        zzLine := line.new(aBar, aVal, bBar, bVal, color=color.new(color.white, 50), width=2)
    if showBG
        drawBG(r0,   r236, trendCol, 88)
        drawBG(r236, r382, trendCol, 84)
        drawBG(r382, r500, trendCol, 80)
        drawBG(r500, r618, trendCol, 76)
        drawBG(r618, r786, trendCol, 72)
        drawBG(r786, r100, trendCol, 68)
    if showRetrace
        drawLevel(r0,   "0.000 · " + fmt(r0),   trendCol, true,  false, startBar)
        drawLevel(r236, "0.236 · " + fmt(r236), trendCol, false, false, startBar)
        drawLevel(r382, "0.382 · " + fmt(r382), trendCol, false, false, startBar)
        drawLevel(r500, "0.500 · " + fmt(r500), trendCol, false, false, startBar)
        drawLevel(r618, "0.618 · " + fmt(r618), trendCol, false, false, startBar)
        drawLevel(r786, "0.786 · " + fmt(r786), trendCol, false, false, startBar)
        drawLevel(r100, "1.000 · " + fmt(r100), trendCol, true,  false, startBar)
    if showExt
        drawLevel(e1272, "TP 1 (1.272) · " + fmt(e1272), tp1Col, true,  true, startBar)
        drawLevel(e1414, "1.414 · " + fmt(e1414), extCol, false, true, startBar)
        drawLevel(e1618, "TP 2 (1.618) · " + fmt(e1618), tp2Col, true,  true, startBar)
        drawLevel(e2000, "2.000 · " + fmt(e2000), extCol, false, true, startBar)
        drawLevel(e2618, "TP 3 (2.618) · " + fmt(e2618), tp3Col, true,  true, startBar)
    if showEntries
        if isBull
            drawZone(r382, r618, entryCol, "▲ Entry Zone")
            drawZone(e1272, e1618, exitCol, "✦ Target Zone")
        if isBear
            drawZone(r618, r382, entryCol, "▼ Entry Zone")
            drawZone(e1618, e1272, exitCol, "✦ Target Zone")

// ── Plotting ──────────────────────────────────────────────────
plotshape(showZigzag and not na(ph), "Swing High", location=location.abovebar, style=shape.triangledown, color=bearCol, size=size.tiny, offset=-swingLen)
plotshape(showZigzag and not na(pl), "Swing Low",  location=location.belowbar, style=shape.triangleup,   color=bullCol, size=size.tiny, offset=-swingLen)
````
