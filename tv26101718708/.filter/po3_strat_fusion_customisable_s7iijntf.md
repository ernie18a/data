# PO3 STRAT Fusion Customisable

- url: https://www.tradingview.com/script/S7IIJNtF-PO3-STRAT-Fusion-Customisable/
- type: indicator
- pine_id: PUB;dda32f87726843729236dd29d01eec6f
- version: 1.0

## Description

# PO3 STRAT Fusion

**Multi-Timeframe Candles | The STRAT | Candle Classification | Custom Alerts**

## Overview

PO3 STRAT Fusion combines multi-timeframe candle visualisation with The STRAT price-action methodology in one customisable TradingView indicator.

Designed for traders who use candle structure, directional bias and multi-timeframe alignment, the indicator provides a clear view of price action without constantly switching chart timeframes.

It combines STRAT candle colouring and classification, higher-timeframe candle panels, a directional dashboard, custom alerts and optional technical tools.

## Key Features

### 1. STRAT Candle Classification

Automatically identifies and labels six candle classifications:

- **1 (Inside Bar):** The candle remains within the previous candle's high and low.
- **2U (Two Up):** Breaks the previous high without breaking the previous low.
- **2D (Two Down):** Breaks the previous low without breaking the previous high.
- **3 (Outside Bar):** Breaks both the previous high and low.
- **F2U (Failed Two Up):** Breaks the previous high but closes back within the previous candle's range.
- **F2D (Failed Two Down):** Breaks the previous low but closes back within the previous candle's range.

Chart candles are colour-coded according to their STRAT classification, with editable colours and optional labels positioned beneath the candles.

Default colours:

- 1: Yellow
- 2U / F2U: Green
- 2D / F2D: Fuchsia
- 3: Purple

Failed-2 highlighting can be enabled separately, while classification labels remain available independently.

### 2. Multi-Timeframe PO3 Candle Panels

Displays higher-timeframe candles to the right of the main chart, allowing traders to monitor developing price structure alongside their active trading timeframe.

- Two panels enabled by default: **1H and 4H**.
- Optional third timeframe panel.
- Adjustable timeframes, candle counts, widths and spacing.
- Current developing candle displayed at the right of each panel.
- STRAT classifications beneath higher-timeframe candles.
- Optional candle countdown timers.
- Customisable candle colours, wicks and outlines.

### 3. Multi-Timeframe Directional Dashboard

A compact dashboard displays directional information across five timeframes:

**15m | 30m | 1H | 4H | Daily**

Green and fuchsia directional arrows provide a quick visual reference for multi-timeframe alignment.

Dashboard position, visibility and colours are adjustable.

### 4. Custom STRAT Candle Alerts

Six separate TradingView alert conditions are available:

- Inside Bar (1)
- Two Up (2U)
- Two Down (2D)
- Outside Bar (3)
- Failed Two Up (F2U)
- Failed Two Down (F2D)

All alerts use one user-selectable timeframe and are evaluated on confirmed candle closes.

Alerts operate independently of the indicator's visual settings, so chart colouring, labels and higher-timeframe panels can be disabled without disabling alert functionality.

Individual alerts must be created through TradingView's alert interface.

For reliable candle-by-candle detection, use an alert timeframe equal to or higher than the chart timeframe.

### 5. Additional Chart Tools

Optional tools include:

- Up to three adjustable Exponential Moving Averages (EMAs).
- Volume Weighted Average Price (VWAP), displayed as a single line.
- Fair Value Gap (FVG) zones with customisable appearance and extension.

These features can be enabled or disabled independently to suit individual trading preferences.

## Customisation

The indicator includes organised settings for candle appearance, STRAT labels, multi-timeframe panels, countdown timers, dashboard positioning, alerts and optional technical tools.

Chart colouring and numbering can be controlled separately, allowing traders to maintain a clean chart while retaining the underlying STRAT analysis.

## How to Use

Use the main chart to identify STRAT candle structures and potential directional shifts.

Monitor the higher-timeframe PO3 panels to assess broader candle development and identify whether shorter-timeframe price action aligns with higher-timeframe structure.

Use the directional dashboard as a supplementary reference and configure alerts for the specific STRAT candle types relevant to your trading strategy.

Optional EMAs, VWAP and FVG zones can provide additional context for trend, price location and potential reaction areas.

## Important Information

PO3 STRAT Fusion is a price-action visualisation and alerting tool, not an automated trading strategy.

Developing candles may change classification before closing. Confirmed candle alerts are designed to avoid signals based on unfinished candles.

The indicator does not guarantee future price direction, trade profitability or successful outcomes. Traders should apply independent analysis, appropriate risk management and their own trading rules.

**PO3 STRAT Fusion Customisable**

## Source Code

````pine
//@version=6
// PO3 STRAT Fusion | Multi-Timeframe Price Action, STRAT Classification & FTC
// Three configurable candle panels with STRAT labels, confirmed Failed 2s,
// five-timeframe continuity dashboard, optional FVGs, three EMAs and VWAP.
// Failed 2 labels remain visible when optional candle highlighting is disabled.
// Six separate confirmed STRAT alerts on one selectable timeframe.
// Native chart candles are recoloured via barcolor(); PO3 wick and border defaults are grey.
// Analytical visualisation only; not a standalone trade signal system.
indicator("PO3 STRAT Fusion v11", shorttitle="PO3 STRAT v11", overlay=true, max_bars_back=500, max_boxes_count=400, max_lines_count=300, max_labels_count=400, dynamic_requests=true)

// PANEL SETTINGS
show1 = input.bool(true, "Show panel 1", group="1. Quick Setup")
tf1 = input.timeframe("60", "Panel 1 timeframe", group="1. Quick Setup")
show2 = input.bool(true, "Show panel 2", group="1. Quick Setup")
tf2 = input.timeframe("240", "Panel 2 timeframe", group="1. Quick Setup")
show3 = input.bool(false, "Show panel 3", group="1. Quick Setup")
tf3 = input.timeframe("D", "Panel 3 timeframe", group="1. Quick Setup")
count = input.int(4, "Candles per panel", minval=1, maxval=10, group="2. Candle Layout")
bodyWidth = input.int(4, "Body width (chart bars)", minval=2, maxval=10, group="2. Candle Layout")
spacing = input.int(2, "Space between candles", minval=0, maxval=10, group="2. Candle Layout", tooltip="Horizontal gap in chart bars between neighbouring candle bodies.")
panelGap = input.int(5, "Space between panels", minval=1, maxval=30, group="2. Candle Layout")
rightOffset = input.int(10, "Distance from last chart candle", minval=1, maxval=50, group="2. Candle Layout", tooltip="Moves the candle panels to the right of the latest chart candle.")
labelDistance = input.float(0.30, "STRAT number distance (ATR)", minval=0.05, maxval=5.0, step=0.05, group="2. Candle Layout", tooltip="Vertical distance of each STRAT label below its candle low, measured using chart ATR.")
panelNumbers = input.bool(true, "Show STRAT numbers on HTF panels", group="2. Candle Layout")
numberColor = input.color(color.white, "STRAT number colour", group="2. Candle Layout")
wickColor = input.color(#B8B8B8, "Wick colour", group="3. STRAT Candles")
upColor = input.color(#00E676, "2 Up / bullish body", group="3. STRAT Candles")
downColor = input.color(#FF00FF, "2 Down / bearish body", group="3. STRAT Candles")
insideColor = input.color(#FFEB3B, "1 Inside body", group="3. STRAT Candles")
outsideColor = input.color(#C545FC, "3 Outside body (purple)", group="3. STRAT Candles")
upBorder = input.color(#B8B8B8, "Bullish outline", group="3. STRAT Candles")
downBorder = input.color(#B8B8B8, "Bearish outline", group="3. STRAT Candles")
insideBorder = input.color(#B8B8B8, "Inside outline", group="3. STRAT Candles")
failedUpColor = input.color(#00E676, "F2U highlight body", group="3. STRAT Candles")
failedDownColor = input.color(#FF00FF, "F2D highlight body", group="3. STRAT Candles")
highlightFailed = input.bool(false, "Highlight Failed 2 candles", group="3. STRAT Candles", tooltip="OFF by default. F2U/F2D labels remain visible on confirmed failed 2 candles. Enable to recolour their bodies and outlines.")
failedUpBorder = input.color(#B8B8B8, "F2U highlight outline", group="3. STRAT Candles")
failedDownBorder = input.color(#B8B8B8, "F2D highlight outline", group="3. STRAT Candles")

// MAIN CHART STRAT CANDLES
chartColors = input.bool(true, "Colour normal chart candles", group="3A. Main Chart", tooltip="Apply STRAT colours to the chart candles as well as the HTF panels.")
chartNumbers = input.bool(true, "Show STRAT numbers on chart", group="3A. Main Chart", tooltip="Display STRAT classification below each chart candle. Labels are based on the current chart timeframe.")
chartNumberColor = input.color(color.white, "Chart STRAT number colour", group="3A. Main Chart")
chartLabelGap = input.float(0.08, "Chart label distance below wick (ATR)", minval=0.01, maxval=2.0, step=0.01, group="3A. Main Chart", tooltip="Labels are anchored below each candle low. Increase this value to move them further from the wick.")
chartLabelSize = input.string("Tiny", "Chart label size", options=["Tiny", "Small", "Normal"], group="3A. Main Chart")
chartLabelBackground = input.color(color.new(#202020, 20), "Chart label background", group="3A. Main Chart", tooltip="Dark backing helps keep STRAT labels readable against candles and chart lines.")

// Classification uses each candle's high and low relative to the preceding candle.
chartValid = not na(high[1]) and not na(low[1])
chartOne = chartValid and high <= high[1] and low >= low[1]
chartThree = chartValid and high > high[1] and low < low[1]
chartTwoUp = chartValid and high > high[1] and low >= low[1]
chartTwoDown = chartValid and low < low[1] and high <= high[1]
// Failed 2 labels are confirmed at close. On the live bar, show 2U/2D until confirmed.
chartF2U = chartTwoUp and barstate.isconfirmed and close <= high[1] and close >= low[1]
chartF2D = chartTwoDown and barstate.isconfirmed and close >= low[1] and close <= high[1]
chartBody = highlightFailed and chartF2U ? failedUpColor : highlightFailed and chartF2D ? failedDownColor : chartOne ? insideColor : chartThree ? outsideColor : chartTwoUp ? upColor : chartTwoDown ? downColor : close >= open ? upColor : downColor
chartBorder = highlightFailed and chartF2U ? failedUpBorder : highlightFailed and chartF2D ? failedDownBorder : chartOne ? insideBorder : chartThree ? upBorder : chartTwoUp ? upBorder : chartTwoDown ? downBorder : close >= open ? upBorder : downBorder
// Recolour native TradingView candles, preserving the original working STRAT behaviour.
// Pine barcolor() cannot independently set native candle wick/border colours.
barcolor(chartColors ? chartBody : na, title="Main chart STRAT candle colours")
// Draw one label per confirmed chart candle instead of 18 plotshape calls.
// Labels are capped to preserve space for PO3 panel and countdown labels.
chartLabelATR = nz(ta.atr(14), math.max(high - low, syminfo.mintick))
chartLabelY = low - math.max(chartLabelATR * chartLabelGap, syminfo.mintick * 3)
chartLabelText = chartOne ? "1" : chartThree ? "3" : chartF2U ? "F2U" : chartF2D ? "F2D" : chartTwoUp ? "2U" : chartTwoDown ? "2D" : ""
chartLabelActualSize = chartLabelSize == "Tiny" ? size.tiny : chartLabelSize == "Small" ? size.small : size.normal
var label[] chartHistoryLabels = array.new<label>()
if chartNumbers and barstate.isconfirmed and chartLabelText != ""
    label chartNewLabel = label.new(bar_index, chartLabelY, chartLabelText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=chartLabelBackground, textcolor=chartNumberColor, size=chartLabelActualSize)
    array.push(chartHistoryLabels, chartNewLabel)
    if array.size(chartHistoryLabels) > 280
        label.delete(array.shift(chartHistoryLabels))

// SEPARATE CONFIRMED STRAT ALERTS
// Choose a timeframe equal to or above the chart timeframe. For higher timeframes,
// signals are read from the PREVIOUS, fully closed HTF candle (no lookahead leak).
alertTF = input.timeframe("15", "Shared alert timeframe", group="9. STRAT Alerts", tooltip="All six alert conditions use this timeframe. Set it equal to or higher than the chart timeframe. For HTF alerts, the signal is available at the start of the next HTF candle.")

f_alertTypes() =>
    valid = not na(high[2]) and not na(low[2])
    one = valid and high[1] <= high[2] and low[1] >= low[2]
    three = valid and high[1] > high[2] and low[1] < low[2]
    twoUp = valid and high[1] > high[2] and low[1] >= low[2]
    twoDown = valid and low[1] < low[2] and high[1] <= high[2]
    f2u = twoUp and close[1] <= high[2] and close[1] >= low[2]
    f2d = twoDown and close[1] >= low[2] and close[1] <= high[2]
    [one, twoUp and not f2u, twoDown and not f2d, three, f2u, f2d]

[aOne, aTwoUp, aTwoDown, aThree, aF2U, aF2D] = request.security(syminfo.tickerid, alertTF, f_alertTypes(), lookahead=barmerge.lookahead_on)
// On a matching chart timeframe the just-closed bar is directly available,
// avoiding a one-bar delay. HTF signals pulse once on the new HTF candle.
alertSameTF = timeframe.in_seconds(alertTF) == timeframe.in_seconds(timeframe.period)
alertValidTF = timeframe.in_seconds(alertTF) >= timeframe.in_seconds(timeframe.period)
alertPulse = alertValidTF and barstate.isconfirmed and (alertSameTF or timeframe.change(alertTF))
alertOne = alertPulse and (alertSameTF ? chartOne : aOne)
alertTwoUp = alertPulse and (alertSameTF ? chartTwoUp and not chartF2U : aTwoUp)
alertTwoDown = alertPulse and (alertSameTF ? chartTwoDown and not chartF2D : aTwoDown)
alertThree = alertPulse and (alertSameTF ? chartThree : aThree)
alertF2U = alertPulse and (alertSameTF ? chartF2U : aF2U)
alertF2D = alertPulse and (alertSameTF ? chartF2D : aF2D)
alertcondition(alertOne, title="STRAT 1 (Inside)", message="PO3 STRAT Fusion: Confirmed 1 (Inside) on {{ticker}}. Check configured alert timeframe.")
alertcondition(alertTwoUp, title="STRAT 2U", message="PO3 STRAT Fusion: Confirmed 2U on {{ticker}}. Check configured alert timeframe.")
alertcondition(alertTwoDown, title="STRAT 2D", message="PO3 STRAT Fusion: Confirmed 2D on {{ticker}}. Check configured alert timeframe.")
alertcondition(alertThree, title="STRAT 3 (Outside)", message="PO3 STRAT Fusion: Confirmed 3 (Outside) on {{ticker}}. Check configured alert timeframe.")
alertcondition(alertF2U, title="STRAT F2U", message="PO3 STRAT Fusion: Confirmed Failed 2 Up (F2U) on {{ticker}}. Check configured alert timeframe.")
alertcondition(alertF2D, title="STRAT F2D", message="PO3 STRAT Fusion: Confirmed Failed 2 Down (F2D) on {{ticker}}. Check configured alert timeframe.")

// COUNTDOWN TIMERS
headingDistance = input.float(0.50, "Countdown distance (ATR)", minval=0.1, maxval=5.0, step=0.05, group="4. Countdown Timers", tooltip="Vertical distance from the highest wick to the heading, measured in chart ATR.")
showHeading = input.bool(true, "Show timeframe / countdown", group="4. Countdown Timers")
headingPosition = input.string("Top", "Heading position", options=["Top", "Bottom", "Both"], group="4. Countdown Timers")
headingColor = input.color(color.white, "Countdown and heading colour", group="4. Countdown Timers")

// FULL TIMEFRAME CONTINUITY
showFTC = input.bool(true, "Show FTC dashboard", group="5. FTC Dashboard")
ftcPosition = input.string("Bottom Left", "Dashboard position", tooltip="Select a fixed screen location for the five-timeframe continuity table.", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left", "Top Center", "Bottom Center"], group="5. FTC Dashboard")
ftcUp = input.color(#00E676, "Up arrow colour", group="5. FTC Dashboard")
ftcDown = input.color(#FF00FF, "Down arrow colour", group="5. FTC Dashboard")
ftcBackground = input.color(color.new(color.black, 25), "Box background", group="5. FTC Dashboard")
ftcText = input.color(color.white, "Timeframe text colour", group="5. FTC Dashboard")

// MOVING AVERAGES
ema1On = input.bool(false, "Show EMA 1", group="6. EMAs")
ema1Len = input.int(9, "EMA 1 length", minval=1, group="6. EMAs")
ema1Color = input.color(#39FF14, "EMA 1 colour", group="6. EMAs")
ema2On = input.bool(false, "Show EMA 2", group="6. EMAs")
ema2Len = input.int(21, "EMA 2 length", minval=1, group="6. EMAs")
ema2Color = input.color(#FF00FF, "EMA 2 colour", group="6. EMAs")
ema3On = input.bool(false, "Show EMA 3", group="6. EMAs")
ema3Len = input.int(50, "EMA 3 length", minval=1, group="6. EMAs")
ema3Color = input.color(color.white, "EMA 3 colour", group="6. EMAs")
plot(ema1On ? ta.ema(close, ema1Len) : na, "EMA 1", color=ema1Color, linewidth=2)
plot(ema2On ? ta.ema(close, ema2Len) : na, "EMA 2", color=ema2Color, linewidth=2)
plot(ema3On ? ta.ema(close, ema3Len) : na, "EMA 3", color=ema3Color, linewidth=2)

// SINGLE-LINE VWAP
vwapOn = input.bool(false, "Show VWAP", group="7. VWAP")
vwapAnchor = input.string("Session", "VWAP anchor", options=["Session", "Week", "Month", "Quarter", "Year"], group="7. VWAP")
vwapSource = input.source(hlc3, "VWAP source", group="7. VWAP")
vwapColor = input.color(color.white, "VWAP colour", group="7. VWAP")
vwapReset = switch vwapAnchor
    "Week" => timeframe.change("W")
    "Month" => timeframe.change("M")
    "Quarter" => timeframe.change("3M")
    "Year" => timeframe.change("12M")
    => timeframe.change("D")
vwapLine = ta.vwap(vwapSource, vwapReset)
plot(vwapOn ? vwapLine : na, "VWAP", color=vwapColor, linewidth=2)

// FAIR VALUE GAPS (same three-candle gap test as PO3)
fvgOn = input.bool(false, "Show FVG boxes", group="8. FVG")
fvgLeft = input.int(20, "Extend left (bars)", minval=0, maxval=500, group="8. FVG", tooltip="How far each panel FVG box extends left, measured in chart bars.")
fvgRight = input.int(5, "Extend right (bars)", minval=0, maxval=100, group="8. FVG", tooltip="How far each panel FVG box extends right, measured in chart bars.")
fvgBull = input.color(color.new(#39FF14, 85), "Bullish FVG fill", group="8. FVG")
fvgBear = input.color(color.new(#FF00FF, 85), "Bearish FVG fill", group="8. FVG")
fvgBorder = input.color(color.new(color.white, 65), "FVG border", group="8. FVG")

// Request 11 HTF candles: up to 10 visible, plus one preceding candle
// to classify the oldest visible STRAT candle correctly.
f_htf() =>
    [array.from(open, open[1], open[2], open[3], open[4], open[5], open[6], open[7], open[8], open[9], open[10]),
     array.from(high, high[1], high[2], high[3], high[4], high[5], high[6], high[7], high[8], high[9], high[10]),
     array.from(low, low[1], low[2], low[3], low[4], low[5], low[6], low[7], low[8], low[9], low[10]),
     array.from(close, close[1], close[2], close[3], close[4], close[5], close[6], close[7], close[8], close[9], close[10]),
     time, time_close]

[o1,h1,l1,c1,t1,tc1] = request.security(syminfo.tickerid, tf1, f_htf(), lookahead=barmerge.lookahead_off)
[o2,h2,l2,c2,t2,tc2] = request.security(syminfo.tickerid, tf2, f_htf(), lookahead=barmerge.lookahead_off)
[o3,h3,l3,c3,t3,tc3] = request.security(syminfo.tickerid, tf3, f_htf(), lookahead=barmerge.lookahead_off)

// FTC uses only 15m, 30m, 1H, 4H and Daily.
[ftcO15,ftcC15] = request.security(syminfo.tickerid, "15", [open,close])
[ftcO30,ftcC30] = request.security(syminfo.tickerid, "30", [open,close])
[ftcO60,ftcC60] = request.security(syminfo.tickerid, "60", [open,close])
[ftcO240,ftcC240] = request.security(syminfo.tickerid, "240", [open,close])
[ftcOD,ftcCD] = request.security(syminfo.tickerid, "D", [open,close])

f_position(p) =>
    switch p
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        "Top Center" => position.top_center
        "Bottom Center" => position.bottom_center
        => position.top_right

var table dashboard = table.new(f_position(ftcPosition), 5, 2, bgcolor=ftcBackground, frame_color=color.new(color.white, 60), frame_width=1)
f_ftcCell(col, tf, op, cl) =>
    table.cell(dashboard, col, 0, tf, text_color=ftcText, text_size=size.small, bgcolor=ftcBackground)
    table.cell(dashboard, col, 1, na(op) or na(cl) ? "·" : cl >= op ? "▲" : "▼", text_color=na(op) or na(cl) ? ftcText : cl >= op ? ftcUp : ftcDown, text_size=size.large, bgcolor=ftcBackground)
if barstate.islast
    if showFTC
        f_ftcCell(0, "15m", ftcO15, ftcC15)
        f_ftcCell(1, "30m", ftcO30, ftcC30)
        f_ftcCell(2, "1H", ftcO60, ftcC60)
        f_ftcCell(3, "4H", ftcO240, ftcC240)
        f_ftcCell(4, "D", ftcOD, ftcCD)
    else
        table.clear(dashboard, 0, 0, 4, 1)

// Drawings recreated on last chart bar only.
var array<box> bodies = array.new<box>()
var array<box> gaps = array.new<box>()
var array<line> wicks = array.new<line>()
var array<label> texts = array.new<label>()

f_clear() =>
    for b in bodies
        box.delete(b)
    for b in gaps
        box.delete(b)
    for ln in wicks
        line.delete(ln)
    for lb in texts
        label.delete(lb)
    array.clear(bodies)
    array.clear(gaps)
    array.clear(wicks)
    array.clear(texts)

f_tfName(tf) =>
    secs = timeframe.in_seconds(tf)
    na(secs) ? tf : secs < 3600 ? str.tostring(int(secs / 60)) + "m" : secs < 86400 ? str.tostring(int(secs / 3600)) + "H" : tf

f_countdown(endTime) =>
    remaining = math.max(0, int(math.floor((endTime - timenow) / 1000)))
    days = int(math.floor(remaining / 86400))
    hrs = int(math.floor((remaining % 86400) / 3600))
    mins = int(math.floor((remaining % 3600) / 60))
    secs = remaining % 60
    days > 0 ? str.tostring(days) + "d " + str.tostring(hrs, "00") + ":" + str.tostring(mins, "00") + ":" + str.tostring(secs, "00") : hrs > 0 ? str.tostring(hrs, "00") + ":" + str.tostring(mins, "00") + ":" + str.tostring(secs, "00") : str.tostring(mins, "00") + ":" + str.tostring(secs, "00")

// Each security array is newest-first: index 0 is the LIVE candle.
// Drawing goes oldest to newest so index 0 is ALWAYS the rightmost candle.
f_drawPanel(startX, tf, os, hs, ls, cs, endTime, atrValue) =>
    step = bodyWidth + spacing
    halfW = int(math.floor(bodyWidth / 2))
    topPrice = -1e20
    bottomPrice = 1e20
    for j = 0 to count - 1
        idx = count - 1 - j
        op = array.get(os, idx)
        hi = array.get(hs, idx)
        lo = array.get(ls, idx)
        cl = array.get(cs, idx)
        if not na(op) and not na(hi) and not na(lo) and not na(cl)
            topPrice := math.max(topPrice, hi)
            bottomPrice := math.min(bottomPrice, lo)
            priorHi = array.get(hs, idx + 1)
            priorLo = array.get(ls, idx + 1)
            validPrior = not na(priorHi) and not na(priorLo)
            one = validPrior and hi <= priorHi and lo >= priorLo
            three = validPrior and hi > priorHi and lo < priorLo
            twoUp = validPrior and hi > priorHi and lo >= priorLo
            twoDown = validPrior and lo < priorLo and hi <= priorHi
            // Only closed HTF candles can carry a confirmed failed-2 label.
            confirmed = idx > 0
            f2u = confirmed and twoUp and cl <= priorHi and cl >= priorLo
            f2d = confirmed and twoDown and cl >= priorLo and cl <= priorHi
            strat = f2u ? "F2U" : f2d ? "F2D" : one ? "1" : three ? "3" : twoUp ? "2U" : twoDown ? "2D" : "·"
            bodyFill = highlightFailed and f2u ? failedUpColor : highlightFailed and f2d ? failedDownColor : one ? insideColor : three ? outsideColor : twoUp ? upColor : twoDown ? downColor : cl >= op ? upColor : downColor
            // Grey outlines by default; all outline inputs remain editable.
            outline = highlightFailed and f2u ? failedUpBorder : highlightFailed and f2d ? failedDownBorder : one ? insideBorder : three ? outsideColor : twoUp ? upBorder : twoDown ? downBorder : cl >= op ? upBorder : downBorder
            mid = startX + j * step + halfW
            bodyTop = math.max(op, cl)
            bodyBottom = math.min(op, cl)
            // Draw bodies and wicks exactly from HTF OHLC values.
            array.push(bodies, box.new(mid - halfW, bodyTop, mid + halfW, bodyBottom, xloc=xloc.bar_index, border_color=outline, border_width=1, bgcolor=bodyFill))
            array.push(wicks, line.new(mid, hi, mid, bodyTop, xloc=xloc.bar_index, color=wickColor))
            array.push(wicks, line.new(mid, bodyBottom, mid, lo, xloc=xloc.bar_index, color=wickColor))
            if panelNumbers
                array.push(texts, label.new(mid, lo - math.max(atrValue * labelDistance, syminfo.mintick * 8), strat, xloc=xloc.bar_index, style=label.style_none, textcolor=numberColor, size=size.small, textalign=text.align_center))
    rightEdge = startX + (count - 1) * step + bodyWidth
    centerX = int(math.floor((startX + rightEdge) / 2))
    if topPrice > -1e19 and bottomPrice < 1e19
        if showHeading
            heading = f_tfName(tf) + "  (" + (barstate.isrealtime ? f_countdown(endTime) : "--:--") + ")"
            if headingPosition == "Top" or headingPosition == "Both"
                array.push(texts, label.new(centerX, topPrice + math.max(atrValue * headingDistance, syminfo.mintick * 12), heading, xloc=xloc.bar_index, style=label.style_none, textcolor=headingColor, size=size.normal))
            if headingPosition == "Bottom" or headingPosition == "Both"
                array.push(texts, label.new(centerX, bottomPrice - math.max(atrValue * (headingDistance + labelDistance + 0.15), syminfo.mintick * 20), heading, xloc=xloc.bar_index, style=label.style_none, textcolor=headingColor, size=size.normal))
        // Original PO3 three-candle FVG rule, using the first and third candles.
        if fvgOn and count >= 3
            for j = 2 to count - 1
                oldIdx = count - 1 - (j - 2)
                newIdx = count - 1 - j
                oldHi = array.get(hs, oldIdx)
                oldLo = array.get(ls, oldIdx)
                newHi = array.get(hs, newIdx)
                newLo = array.get(ls, newIdx)
                if not na(oldHi) and not na(oldLo) and not na(newHi) and not na(newLo)
                    leftEdge = startX - fvgLeft
                    farRight = rightEdge + fvgRight
                    if newLo > oldHi
                        array.push(gaps, box.new(leftEdge, newLo, farRight, oldHi, xloc=xloc.bar_index, border_color=fvgBorder, bgcolor=fvgBull))
                    else if newHi < oldLo
                        array.push(gaps, box.new(leftEdge, oldLo, farRight, newHi, xloc=xloc.bar_index, border_color=fvgBorder, bgcolor=fvgBear))

atr = nz(ta.atr(14), math.max(high - low, syminfo.mintick))
if barstate.islast
    f_clear()
    // PO3 panel order: panel 1, then 2, then optional 3. Within each panel,
    // older candles are on the left and the current candle is on the right.
    panelWidth = (count - 1) * (bodyWidth + spacing) + bodyWidth
    totalWidth = (show1 ? panelWidth : 0) + (show2 ? panelWidth : 0) + (show3 ? panelWidth : 0) + ((show1 ? 1 : 0) + (show2 ? 1 : 0) + (show3 ? 1 : 0) - 1) * panelGap
    // Keep all chart drawings inside TradingView's 500-future-bar limit.
    x = bar_index + math.min(rightOffset, math.max(1, 499 - totalWidth))
    if show1
        f_drawPanel(x, tf1, o1, h1, l1, c1, tc1, atr)
        x += panelWidth + panelGap
    if show2
        f_drawPanel(x, tf2, o2, h2, l2, c2, tc2, atr)
        x += panelWidth + panelGap
    if show3
        f_drawPanel(x, tf3, o3, h3, l3, c3, tc3, atr)
````
