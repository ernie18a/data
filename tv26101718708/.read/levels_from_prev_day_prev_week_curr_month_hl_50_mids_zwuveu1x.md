# Levels from Prev Day + Prev Week + Curr Month H/L + 50% Mids

- url: https://www.tradingview.com/script/ZwUvEu1X-Levels-from-Prev-Day-Prev-Week-Curr-Month-H-L-50-Mids/
- type: indicator
- pine_id: PUB;7c79710383484bad801c3bab955e0a1c
- version: 1.0

## Description

A clean multi-timeframe market structure indicator that plots

Monthly High/Low,
Previous Day High/Low,
Day-2 High/Low, and
Previous Week High/Low levels directly from the exact candle where each level was formed.

Optional 50% midpoint levels are also displayed to highlight equilibrium and reaction zones.

The script extends all levels forward as precise right-side rays, making it easy to track important support, resistance, liquidity, and price interaction areas throughout the session. Fully customisable colours, labels, and line styles provide a professional and clutter-free trading experience across both intraday and higher timeframes.

50% area are premium and discount zone. Thats why we need them

## Source Code

````pine
//@version=6
indicator("Prev Day + Prev Week + Curr Month H/L + 50% Mids • Rays from exact candle", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ── Inputs ────────────────────────────────────────────────────────────────
showLabels      = input.bool(true,  "Show Labels")
showMidLines    = input.bool(true,  "Show 50% Midpoint Lines")
lineWidth       = input.int(1,      "Line Width", minval=1, maxval=5)

// ── Color Inputs ──────────────────────────────────────────────────────────
col_yestH   = input.color(color.black,     "Yesterday High Color")
col_yestL   = input.color(color.black,     "Yesterday Low Color")
col_yestMid = input.color(color.purple,    "Yesterday 50% Mid Color")

col_prevD2H = input.color(color.gray,      "D-2 High Color")
col_prevD2L = input.color(color.gray,      "D-2 Low Color")
col_prevD2Mid = input.color(color.teal,    "D-2 50% Mid Color")

col_lastWkH = input.color(color.orange,    "Last Week High Color")
col_lastWkL = input.color(color.orange,    "Last Week Low Color")
col_lastWkMid = input.color(color.fuchsia, "Last Week 50% Mid Color")

col_currMthH   = input.color(color.blue,   "Current Month High Color")
col_currMthL   = input.color(color.blue,   "Current Month Low Color")
col_currMthMid = input.color(color.lime,   "Current Month 50% Mid Color")

// ── Detection ─────────────────────────────────────────────────────────────
isNewDay   = ta.change(time("D")) != 0
isNewWeek  = ta.change(time("W")) != 0
isNewMonth = ta.change(time("M")) != 0

// ── Security calls ────────────────────────────────────────────────────────
float yestHigh   = request.security(syminfo.tickerid, "D", high[1],  lookahead=barmerge.lookahead_on)
float yestLow    = request.security(syminfo.tickerid, "D", low[1],   lookahead=barmerge.lookahead_on)

float prevD2High = request.security(syminfo.tickerid, "D", high[2],  lookahead=barmerge.lookahead_on)
float prevD2Low  = request.security(syminfo.tickerid, "D", low[2],   lookahead=barmerge.lookahead_on)

float lastWkHigh = request.security(syminfo.tickerid, "W", high[1],  lookahead=barmerge.lookahead_on)
float lastWkLow  = request.security(syminfo.tickerid, "W", low[1],   lookahead=barmerge.lookahead_on)

// Current month high/low (developing)
float currMthHigh = request.security(syminfo.tickerid, "M", high,    lookahead=barmerge.lookahead_on)
float currMthLow  = request.security(syminfo.tickerid, "M", low,     lookahead=barmerge.lookahead_on)

// ── Variables ─────────────────────────────────────────────────────────────
var float  yHigh = na, var int yHighBar = na
var float  yLow  = na, var int yLowBar  = na
var float  yMid  = na, var int yMidBar  = na

var float  d2High = na, var int d2HighBar = na
var float  d2Low  = na, var int d2LowBar  = na
var float  d2Mid  = na, var int d2MidBar  = na

var float  wkHigh = na, var int wkHighBar = na
var float  wkLow  = na, var int wkLowBar  = na
var float  wkMid  = na, var int wkMidBar  = na

var float  mthHigh = na, var int mthHighBar = na
var float  mthLow  = na, var int mthLowBar  = na
var float  mthMid  = na

var line   lYh = na, var line lYl = na, var line lYm = na
var line   lD2h = na, var line lD2l = na, var line lD2m = na
var line   lWkH = na, var line lWkL = na, var line lWkM = na
var line   lMthH = na, var line lMthL = na, var line lMthM = na

var label  lblYh = na, var label lblYl = na, var label lblYm = na
var label  lblD2h = na, var label lblD2l = na, var label lblD2m = na
var label  lblWkH = na, var label lblWkL = na, var label lblWkM = na
var label  lblMthH = na, var label lblMthL = na, var label lblMthM = na

// ── Track Current Month High/Low Bar ──────────────────────────────────────
if isNewMonth
    mthHigh    := high
    mthLow     := low
    mthHighBar := bar_index
    mthLowBar  := bar_index
else
    if high >= mthHigh
        mthHigh    := high
        mthHighBar := bar_index
    if low <= mthLow
        mthLow     := low
        mthLowBar  := bar_index

mthMid := (mthHigh + mthLow) / 2

// ── Logic on New Day ──────────────────────────────────────────────────────
if isNewDay
    // Shift previous day to D-2
    d2High := yHigh
    d2Low  := yLow
    d2Mid  := yMid
    d2HighBar := yHighBar
    d2LowBar  := yLowBar
    d2MidBar  := yMidBar

    // Find exact candle for Yesterday (intraday only)
    int foundYh = na
    int foundYl = na
    if timeframe.isintraday
        for i = 1 to 1500
            if na(time[i]) or time("D")[i] != time("D")[1]
                break
            if high[i] == yestHigh and na(foundYh)
                foundYh := bar_index - i
            if low[i] == yestLow and na(foundYl)
                foundYl := bar_index - i

    yHigh := yestHigh
    yLow  := yestLow
    yMid  := (yestHigh + yestLow) / 2
    yHighBar := foundYh
    yLowBar  := foundYl
    yMidBar  := foundYh

    // Weekly update
    if isNewWeek
        int foundWkH = na
        int foundWkL = na
        if timeframe.isintraday
            for i = 1 to 3000
                if na(time[i]) or time("W")[i] != time("W")[1]
                    break
                if high[i] == lastWkHigh and na(foundWkH)
                    foundWkH := bar_index - i
                if low[i] == lastWkLow and na(foundWkL)
                    foundWkL := bar_index - i

        wkHigh := lastWkHigh
        wkLow  := lastWkLow
        wkMid  := (lastWkHigh + lastWkLow) / 2
        wkHighBar := foundWkH
        wkLowBar  := foundWkL
        wkMidBar  := foundWkH

    // Delete old objects
    line.delete(lYh)
    line.delete(lYl)
    line.delete(lYm)
    line.delete(lD2h)
    line.delete(lD2l)
    line.delete(lD2m)
    line.delete(lWkH)
    line.delete(lWkL)
    line.delete(lWkM)
    line.delete(lMthH)
    line.delete(lMthL)
    line.delete(lMthM)

    label.delete(lblYh)
    label.delete(lblYl)
    label.delete(lblYm)
    label.delete(lblD2h)
    label.delete(lblD2l)
    label.delete(lblD2m)
    label.delete(lblWkH)
    label.delete(lblWkL)
    label.delete(lblWkM)
    label.delete(lblMthH)
    label.delete(lblMthL)
    label.delete(lblMthM)

    bool higherTF = timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly

    int startBar = higherTF ? bar_index - 1 : (na(yHighBar) ? bar_index : yHighBar)

    // Yesterday
    lYh := line.new(startBar, yHigh, startBar + 1, yHigh, extend=extend.right, color=col_yestH, width=lineWidth)
    lYl := line.new(startBar, yLow,  startBar + 1, yLow,  extend=extend.right, color=col_yestL, width=lineWidth)
    if showMidLines and not na(yMid)
        lYm := line.new(startBar, yMid, startBar + 1, yMid, extend=extend.right, color=col_yestMid, width=lineWidth)

    // D-2
    int startD2 = higherTF ? bar_index - 1 : (na(d2HighBar) ? bar_index : d2HighBar)
    lD2h := line.new(startD2, d2High, startD2 + 1, d2High, extend=extend.right, color=col_prevD2H, width=lineWidth)
    lD2l := line.new(startD2, d2Low,  startD2 + 1, d2Low,  extend=extend.right, color=col_prevD2L, width=lineWidth)
    if showMidLines and not na(d2Mid)
        lD2m := line.new(startD2, d2Mid, startD2 + 1, d2Mid, extend=extend.right, color=col_prevD2Mid, width=lineWidth)

    // Last Week
    int startWk = higherTF ? bar_index - 1 : (na(wkHighBar) ? bar_index : wkHighBar)
    lWkH := line.new(startWk, wkHigh, startWk + 1, wkHigh, extend=extend.right, color=col_lastWkH, width=lineWidth)
    lWkL := line.new(startWk, wkLow,  startWk + 1, wkLow,  extend=extend.right, color=col_lastWkL, width=lineWidth)
    if showMidLines and not na(wkMid)
        lWkM := line.new(startWk, wkMid, startWk + 1, wkMid, extend=extend.right, color=col_lastWkMid, width=lineWidth)

    // Current Month
    int startMth = higherTF ? bar_index - 1 : (na(mthHighBar) ? bar_index : mthHighBar)
    lMthH := line.new(startMth, mthHigh, startMth + 1, mthHigh, extend=extend.right, color=col_currMthH, width=lineWidth)
    int startMthL = higherTF ? bar_index - 1 : (na(mthLowBar) ? bar_index : mthLowBar)
    lMthL := line.new(startMthL, mthLow, startMthL + 1, mthLow, extend=extend.right, color=col_currMthL, width=lineWidth)
    if showMidLines and not na(mthMid)
        lMthM := line.new(startMth, mthMid, startMth + 1, mthMid, extend=extend.right, color=col_currMthMid, width=lineWidth)

    // Labels
    if showLabels
        lblYh := label.new(bar_index + 5, yHigh, "Y H", style=label.style_label_left, color=color.new(col_yestH, 80), textcolor=color.white, size=size.small)
        lblYl := label.new(bar_index + 5, yLow,  "Y L", style=label.style_label_left, color=color.new(col_yestL, 80), textcolor=color.white, size=size.small)
        if showMidLines
            lblYm := label.new(bar_index + 5, yMid, "Y 50%", style=label.style_label_left, color=color.new(col_yestMid, 80), textcolor=color.white, size=size.small)

        lblD2h := label.new(bar_index + 5, d2High, "D2 H", style=label.style_label_left, color=color.new(col_prevD2H, 80), textcolor=color.white, size=size.small)
        lblD2l := label.new(bar_index + 5, d2Low,  "D2 L", style=label.style_label_left, color=color.new(col_prevD2L, 80), textcolor=color.white, size=size.small)
        if showMidLines
            lblD2m := label.new(bar_index + 5, d2Mid, "D2 50%", style=label.style_label_left, color=color.new(col_prevD2Mid, 80), textcolor=color.white, size=size.small)

        lblWkH := label.new(bar_index + 5, wkHigh, "Wk H", style=label.style_label_left, color=color.new(col_lastWkH, 80), textcolor=color.white, size=size.small)
        lblWkL := label.new(bar_index + 5, wkLow,  "Wk L", style=label.style_label_left, color=color.new(col_lastWkL, 80), textcolor=color.white, size=size.small)
        if showMidLines
            lblWkM := label.new(bar_index + 5, wkMid, "Wk 50%", style=label.style_label_left, color=color.new(col_lastWkMid, 80), textcolor=color.white, size=size.small)

        lblMthH := label.new(bar_index + 5, mthHigh, "Mth H", style=label.style_label_left, color=color.new(col_currMthH, 80), textcolor=color.white, size=size.small)
        lblMthL := label.new(bar_index + 5, mthLow,  "Mth L", style=label.style_label_left, color=color.new(col_currMthL, 80), textcolor=color.white, size=size.small)
        if showMidLines
            lblMthM := label.new(bar_index + 5, mthMid, "Mth 50%", style=label.style_label_left, color=color.new(col_currMthMid, 80), textcolor=color.white, size=size.small)

// ── Update Current Month Lines on Every Bar ───────────────────────────────
if not na(lMthH)
    line.set_y1(lMthH, mthHigh)
    line.set_y2(lMthH, mthHigh)
    line.set_x1(lMthH, mthHighBar)
if not na(lMthL)
    line.set_y1(lMthL, mthLow)
    line.set_y2(lMthL, mthLow)
    line.set_x1(lMthL, mthLowBar)
if not na(lMthM) and showMidLines
    line.set_y1(lMthM, mthMid)
    line.set_y2(lMthM, mthMid)

// Update month labels
if showLabels and not na(lblMthH)
    label.set_y(lblMthH, mthHigh)
    label.set_x(lblMthH, bar_index + 5)
if showLabels and not na(lblMthL)
    label.set_y(lblMthL, mthLow)
    label.set_x(lblMthL, bar_index + 5)
if showLabels and showMidLines and not na(lblMthM)
    label.set_y(lblMthM, mthMid)
    label.set_x(lblMthM, bar_index + 5)
````
