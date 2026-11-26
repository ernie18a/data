# Tranquila SMC Free v1.01

- url: https://www.tradingview.com/script/ciPt9DiG-Tranquila-SMC-Free-v1-01/
- type: indicator
- pine_id: PUB;2d423387da4744d6bbb8f81294369321
- version: 1.0

## Description

Tranquila SMC Free v1.01

A clean Smart Money Concepts (SMC) tool designed to help traders identify key market structure and liquidity zones without manually drawing everything on the chart.

Features

✔ Bullish & Bearish BOS (Break of Structure)

✔ Bullish & Bearish CHoCH (Change of Character)

✔ Bullish Order Blocks

✔ Bearish Order Blocks

✔ Bullish Fair Value Gaps (FVG)

✔ Bearish Fair Value Gaps (FVG)

✔ FVG 50% Midline

✔ Previous Day High (PDH)

✔ Previous Day Low (PDL)

✔ Previous Week High (PWH)

✔ Previous Week Low (PWL)

Purpose

This indicator focuses on the core concepts used by many ICT and SMC traders:

Market Structure
Liquidity Levels
Order Blocks
Fair Value Gaps
Previous Day and Week Highs/Lows

The goal is to provide a clean chart with the most important information already marked, allowing traders to focus on execution instead of manual chart work.

Notes
This indicator does not generate buy or sell signals.
It is designed as a visual analysis tool.
All elements can be enabled or disabled through the settings menu.
Works on Forex, Indices, Commodities and Crypto markets.
Best Used For
Market Structure Analysis
Liquidity-Based Trading
ICT Concepts
Smart Money Concepts (SMC)
Intraday and Swing Trading

Keep your chart clean, focus on price action, and let the indicator handle the drawing.

## Source Code

````pine
//@version=5
indicator("Tranquila SMC Free v1.0", overlay=true, max_boxes_count=300, max_labels_count=300, max_lines_count=300)

//====================================================================
// TRANQUILA SMC FREE v1.0
// Free clean visual tool:
// - BOS / CHoCH
// - Bullish / Bearish Order Blocks
// - Bullish / Bearish FVG
// - PDH / PDL / optional PWH / PWL
// No dashboard. No score. No bias engine. No signals.
//====================================================================

//==============================
// INPUTS
//==============================
grpStructure = "Market Structure"
showStructure = input.bool(true, "Show BOS / CHoCH", group=grpStructure)
structureMode = input.string("Swing", "Structure Mode", options=["Swing", "Internal"], group=grpStructure)
swingLen = input.int(20, "Swing Length", minval=5, maxval=100, group=grpStructure)
internalLen = input.int(5, "Internal Length", minval=2, maxval=30, group=grpStructure)
structureLineWidth = input.int(1, "Structure Line Width", minval=1, maxval=4, group=grpStructure)

// Order Blocks
grpOB = "Order Blocks"
showOB = input.bool(true, "Show Order Blocks", group=grpOB)
obLookback = input.int(20, "OB Search Lookback", minval=3, maxval=100, group=grpOB)
obExtendBars = input.int(80, "OB Extend Bars", minval=10, maxval=500, group=grpOB)
maxBullOB = input.int(5, "Max Bullish OB", minval=1, maxval=20, group=grpOB)
maxBearOB = input.int(5, "Max Bearish OB", minval=1, maxval=20, group=grpOB)
obInvalidation = input.string("Close Through", "OB Invalidation", options=["Wick Through", "Close Through"], group=grpOB)
showOBLabels = input.bool(true, "Show OB Labels", group=grpOB)

// FVG
grpFVG = "Fair Value Gaps"
showFVG = input.bool(true, "Show FVG", group=grpFVG)
fvgTf = input.timeframe("", "FVG Timeframe Empty = Chart TF", group=grpFVG)
fvgMinAtr = input.float(0.20, "FVG Min Size ATR", minval=0.0, step=0.05, group=grpFVG)
fvgExtendBars = input.int(60, "FVG Extend Bars", minval=5, maxval=500, group=grpFVG)
maxBullFVG = input.int(4, "Max Bull FVG", minval=1, maxval=20, group=grpFVG)
maxBearFVG = input.int(4, "Max Bear FVG", minval=1, maxval=20, group=grpFVG)
fvgInvalidation = input.string("Full Fill", "FVG Invalidation", options=["Full Fill", "Close Through", "50% Fill"], group=grpFVG)
showFVGLabels = input.bool(true, "Show FVG Labels", group=grpFVG)
showFvgMidline = input.bool(true, "Show FVG 50% Midline", group=grpFVG)

// Levels
grpLevels = "Liquidity Levels"
showLevels = input.bool(true, "Show Levels", group=grpLevels)
showPDH = input.bool(true, "Show PDH", group=grpLevels)
showPDL = input.bool(true, "Show PDL", group=grpLevels)
showPWH = input.bool(false, "Show PWH", group=grpLevels)
showPWL = input.bool(false, "Show PWL", group=grpLevels)
levelBarsForward = input.int(60, "Levels Bars Forward", minval=5, maxval=500, group=grpLevels)
levelWidth = input.int(1, "Daily Level Width", minval=1, maxval=5, group=grpLevels)
weeklyLevelWidth = input.int(2, "Weekly Level Width", minval=1, maxval=5, group=grpLevels)
levelStyleInput = input.string("Solid", "Daily Level Style", options=["Solid", "Dashed", "Dotted"], group=grpLevels)
weeklyStyleInput = input.string("Dashed", "Weekly Level Style", options=["Solid", "Dashed", "Dotted"], group=grpLevels)

// Visual
grpVisual = "Visual"
bullCol = input.color(color.rgb(8, 153, 129), "Structure Bull Color", group=grpVisual)
bearCol = input.color(color.rgb(242, 54, 69), "Structure Bear Color", group=grpVisual)
obBullCol = input.color(color.rgb(8, 153, 129), "Bullish OB Color", group=grpVisual)
obBearCol = input.color(color.rgb(242, 54, 69), "Bearish OB Color", group=grpVisual)
fvgBullCol = input.color(color.rgb(41, 98, 255), "Bullish FVG Color", group=grpVisual)
fvgBearCol = input.color(color.rgb(255, 152, 0), "Bearish FVG Color", group=grpVisual)
grayCol = input.color(color.rgb(135, 139, 148), "Neutral Color", group=grpVisual)
obTransp = input.int(84, "OB Transparency", minval=0, maxval=100, group=grpVisual)
fvgTransp = input.int(86, "FVG Transparency", minval=0, maxval=100, group=grpVisual)
labelSizeInput = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal"], group=grpVisual)

//==============================
// TYPES
//==============================
type Pivot
    float level
    bool crossed
    int bar

type Zone
    float top
    float bottom
    int dir
    box bx
    label lb
    line midLine
    int createdBar

//==============================
// HELPERS
//==============================
white0 = color.new(color.white, 100)

f_labelSize(_s) =>
    _s == "Tiny" ? size.tiny : _s == "Normal" ? size.normal : size.small

labSize = f_labelSize(labelSizeInput)

f_lineStyle(_style) =>
    _style == "Dashed" ? line.style_dashed : _style == "Dotted" ? line.style_dotted : line.style_solid

f_zoneMid(_top, _bottom) =>
    math.avg(_top, _bottom)

f_findBullOB(_lookback) =>
    float _top = na
    float _bottom = na
    int _bar = na
    for i = 1 to _lookback
        if na(_bar) and close[i] < open[i]
            _top := open[i]
            _bottom := low[i]
            _bar := bar_index - i
    [_top, _bottom, _bar]

f_findBearOB(_lookback) =>
    float _top = na
    float _bottom = na
    int _bar = na
    for i = 1 to _lookback
        if na(_bar) and close[i] > open[i]
            _top := high[i]
            _bottom := open[i]
            _bar := bar_index - i
    [_top, _bottom, _bar]

f_createZone(_top, _bottom, _dir, _startBar, _extendBars, _transp, _txt, _showLabel, _kind) =>
    _isFvg = _kind == "FVG"
    _c = _isFvg ? (_dir == 1 ? fvgBullCol : fvgBearCol) : (_dir == 1 ? obBullCol : obBearCol)
    _mid = f_zoneMid(_top, _bottom)
    _bx = box.new(_startBar, _top, bar_index + _extendBars, _bottom, bgcolor=color.new(_c, _transp), border_color=color.new(_c, 20))
    _lb = _showLabel ? label.new(bar_index + _extendBars, _mid, _txt, style=label.style_label_left, textcolor=_c, color=white0, size=labSize) : na
    _ml = _isFvg and showFvgMidline ? line.new(_startBar, _mid, bar_index + _extendBars, _mid, color=color.new(_c, 0), width=1, style=line.style_dashed) : na
    Zone.new(_top, _bottom, _dir, _bx, _lb, _ml, bar_index)

f_cleanZones(array<Zone> _arr, string _kind, string _invalidation, int _extendBars) =>
    int i = array.size(_arr) - 1
    while i >= 0
        z = array.get(_arr, i)
        mid = f_zoneMid(z.top, z.bottom)

        bool invalid = false
        if _kind == "OB"
            invalid := z.dir == 1 ? (_invalidation == "Close Through" ? close < z.bottom : low < z.bottom) : (_invalidation == "Close Through" ? close > z.top : high > z.top)
        else
            invalid := z.dir == 1 ? (_invalidation == "50% Fill" ? low <= mid : _invalidation == "Close Through" ? close < z.bottom : low <= z.bottom) : (_invalidation == "50% Fill" ? high >= mid : _invalidation == "Close Through" ? close > z.top : high >= z.top)

        if invalid
            box.delete(z.bx)
            label.delete(z.lb)
            line.delete(z.midLine)
            array.remove(_arr, i)
        else
            box.set_right(z.bx, bar_index + _extendBars)
            if not na(z.lb)
                label.set_x(z.lb, bar_index + _extendBars)
                label.set_y(z.lb, mid)
            if not na(z.midLine)
                line.set_x2(z.midLine, bar_index + _extendBars)
                line.set_y1(z.midLine, mid)
                line.set_y2(z.midLine, mid)
        i -= 1
    0

f_limitZones(array<Zone> _arr, int _max) =>
    while array.size(_arr) > _max
        old = array.pop(_arr)
        box.delete(old.bx)
        label.delete(old.lb)
        line.delete(old.midLine)
    0

//==============================
// MARKET STRUCTURE
//==============================
len = structureMode == "Swing" ? swingLen : internalLen

var Pivot pHigh = Pivot.new(na, false, na)
var Pivot pLow = Pivot.new(na, false, na)
var int trend = 0

ph = ta.pivothigh(high, len, len)
pl = ta.pivotlow(low, len, len)

if not na(ph)
    pHigh.level := ph
    pHigh.crossed := false
    pHigh.bar := bar_index - len

if not na(pl)
    pLow.level := pl
    pLow.crossed := false
    pLow.bar := bar_index - len

bullBreak = not na(pHigh.level) and ta.crossover(close, pHigh.level) and not pHigh.crossed
bearBreak = not na(pLow.level) and ta.crossunder(close, pLow.level) and not pLow.crossed

// Arrays for zones
var Zone[] bullOBs = array.new<Zone>()
var Zone[] bearOBs = array.new<Zone>()
var Zone[] bullFVGs = array.new<Zone>()
var Zone[] bearFVGs = array.new<Zone>()

if bullBreak
    tag = trend == -1 ? "CHoCH" : "BOS"
    pHigh.crossed := true
    trend := 1

    if showStructure
        line.new(pHigh.bar, pHigh.level, bar_index, pHigh.level, color=bullCol, width=structureLineWidth)
        label.new(math.round((pHigh.bar + bar_index) / 2), pHigh.level, tag, style=label.style_label_down, textcolor=bullCol, color=white0, size=labSize)

    if showOB
        [obTop, obBottom, obBar] = f_findBullOB(obLookback)
        if not na(obTop) and not na(obBottom) and not na(obBar)
            array.unshift(bullOBs, f_createZone(obTop, obBottom, 1, obBar, obExtendBars, obTransp, "Bull OB", showOBLabels, "OB"))

if bearBreak
    tag = trend == 1 ? "CHoCH" : "BOS"
    pLow.crossed := true
    trend := -1

    if showStructure
        line.new(pLow.bar, pLow.level, bar_index, pLow.level, color=bearCol, width=structureLineWidth)
        label.new(math.round((pLow.bar + bar_index) / 2), pLow.level, tag, style=label.style_label_up, textcolor=bearCol, color=white0, size=labSize)

    if showOB
        [obTop, obBottom, obBar] = f_findBearOB(obLookback)
        if not na(obTop) and not na(obBottom) and not na(obBar)
            array.unshift(bearOBs, f_createZone(obTop, obBottom, -1, obBar, obExtendBars, obTransp, "Bear OB", showOBLabels, "OB"))

// Clean OBs
f_cleanZones(bullOBs, "OB", obInvalidation, obExtendBars)
f_cleanZones(bearOBs, "OB", obInvalidation, obExtendBars)
f_limitZones(bullOBs, maxBullOB)
f_limitZones(bearOBs, maxBearOB)

//==============================
// FVG ENGINE
//==============================
string fvgTimeframe = fvgTf == "" ? timeframe.period : fvgTf
[fHigh, fLow, fHigh2, fLow2] = request.security(syminfo.tickerid, fvgTimeframe, [high, low, high[2], low[2]], barmerge.gaps_off, barmerge.lookahead_off)

newFvgBar = timeframe.change(fvgTimeframe)
atr = ta.atr(14)
minFvgSize = atr * fvgMinAtr

bullFVG = newFvgBar and fLow > fHigh2 and (fLow - fHigh2) >= minFvgSize
bearFVG = newFvgBar and fHigh < fLow2 and (fLow2 - fHigh) >= minFvgSize

if showFVG and bullFVG
    array.unshift(bullFVGs, f_createZone(fLow, fHigh2, 1, bar_index - 2, fvgExtendBars, fvgTransp, "Bull FVG 50%", showFVGLabels, "FVG"))

if showFVG and bearFVG
    array.unshift(bearFVGs, f_createZone(fLow2, fHigh, -1, bar_index - 2, fvgExtendBars, fvgTransp, "Bear FVG 50%", showFVGLabels, "FVG"))

f_cleanZones(bullFVGs, "FVG", fvgInvalidation, fvgExtendBars)
f_cleanZones(bearFVGs, "FVG", fvgInvalidation, fvgExtendBars)
f_limitZones(bullFVGs, maxBullFVG)
f_limitZones(bearFVGs, maxBearFVG)

//==============================
// PDH / PDL / PWH / PWL
//==============================
newDay = timeframe.change("D")

var float curDHigh = na
var float curDLow = na
var int curDHighTime = na
var int curDLowTime = na

var float pdh = na
var float pdl = na
var int pdhTime = na
var int pdlTime = na

if barstate.isfirst
    curDHigh := high
    curDLow := low
    curDHighTime := time
    curDLowTime := time

if newDay
    pdh := curDHigh
    pdl := curDLow
    pdhTime := curDHighTime
    pdlTime := curDLowTime
    curDHigh := high
    curDLow := low
    curDHighTime := time
    curDLowTime := time
else
    if na(curDHigh) or high > curDHigh
        curDHigh := high
        curDHighTime := time
    if na(curDLow) or low < curDLow
        curDLow := low
        curDLowTime := time

newWeek = timeframe.change("W")

var float curWHigh = na
var float curWLow = na
var int curWHighTime = na
var int curWLowTime = na

var float pwh = na
var float pwl = na
var int pwhTime = na
var int pwlTime = na

if barstate.isfirst
    curWHigh := high
    curWLow := low
    curWHighTime := time
    curWLowTime := time

if newWeek
    pwh := curWHigh
    pwl := curWLow
    pwhTime := curWHighTime
    pwlTime := curWLowTime
    curWHigh := high
    curWLow := low
    curWHighTime := time
    curWLowTime := time
else
    if na(curWHigh) or high > curWHigh
        curWHigh := high
        curWHighTime := time
    if na(curWLow) or low < curWLow
        curWLow := low
        curWLowTime := time

var line lPDH = na
var line lPDL = na
var line lPWH = na
var line lPWL = na
var label lbPDH = na
var label lbPDL = na
var label lbPWH = na
var label lbPWL = na

tfSeconds = timeframe.in_seconds(timeframe.period)
levelTimeX2 = time + tfSeconds * 1000 * levelBarsForward
labelTimeX = levelTimeX2

dailyStyle = f_lineStyle(levelStyleInput)
weeklyStyle = f_lineStyle(weeklyStyleInput)

if barstate.islast
    line.delete(lPDH)
    line.delete(lPDL)
    line.delete(lPWH)
    line.delete(lPWL)
    label.delete(lbPDH)
    label.delete(lbPDL)
    label.delete(lbPWH)
    label.delete(lbPWL)

    if showLevels
        if showPDH and not na(pdh) and not na(pdhTime)
            lPDH := line.new(pdhTime, pdh, levelTimeX2, pdh, xloc=xloc.bar_time, color=bearCol, width=levelWidth, style=dailyStyle)
            lbPDH := label.new(labelTimeX, pdh, "PDH", xloc=xloc.bar_time, style=label.style_label_left, textcolor=bearCol, color=white0, size=labSize)

        if showPDL and not na(pdl) and not na(pdlTime)
            lPDL := line.new(pdlTime, pdl, levelTimeX2, pdl, xloc=xloc.bar_time, color=bullCol, width=levelWidth, style=dailyStyle)
            lbPDL := label.new(labelTimeX, pdl, "PDL", xloc=xloc.bar_time, style=label.style_label_left, textcolor=bullCol, color=white0, size=labSize)

        if showPWH and not na(pwh) and not na(pwhTime)
            lPWH := line.new(pwhTime, pwh, levelTimeX2, pwh, xloc=xloc.bar_time, color=color.new(bearCol, 25), width=weeklyLevelWidth, style=weeklyStyle)
            lbPWH := label.new(labelTimeX, pwh, "PWH", xloc=xloc.bar_time, style=label.style_label_left, textcolor=bearCol, color=white0, size=labSize)

        if showPWL and not na(pwl) and not na(pwlTime)
            lPWL := line.new(pwlTime, pwl, levelTimeX2, pwl, xloc=xloc.bar_time, color=color.new(bullCol, 25), width=weeklyLevelWidth, style=weeklyStyle)
            lbPWL := label.new(labelTimeX, pwl, "PWL", xloc=xloc.bar_time, style=label.style_label_left, textcolor=bullCol, color=white0, size=labSize)

//==============================
// ALERT CONDITIONS
//==============================
alertcondition(bullBreak, "Bullish BOS/CHoCH", "Bullish structure break on {{ticker}}")
alertcondition(bearBreak, "Bearish BOS/CHoCH", "Bearish structure break on {{ticker}}")
alertcondition(bullFVG, "Bullish FVG", "Bullish FVG on {{ticker}}")
alertcondition(bearFVG, "Bearish FVG", "Bearish FVG on {{ticker}}")
````
