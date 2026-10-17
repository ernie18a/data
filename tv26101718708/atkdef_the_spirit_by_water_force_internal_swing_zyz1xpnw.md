# ATK/DEF The Spirit by Water Force Internal Swing

- url: https://www.tradingview.com/script/zyZ1XPnW/
- type: indicator
- pine_id: PUB;d7770b13a76b487faf1e0e0947296008
- version: 1.0

## Description

# ATK/DEF The Spirit by Water Force Internal Swing

## Overview

ATK/DEF The Spirit by Water Force Internal Swing is a market structure observation framework combining Internal Swing tracking, BOS/CHoCH classification, Structure Distance monitoring, and FVG Dual Flow.

The framework connects internal swing formation, structural breaks, price-to-structure distance, and Fair Value Gap interactions within a unified observation model.

Water Force represents structural flow and adaptation, where internal price structure and imbalance zones are tracked through changing market conditions.

## Defining Conditions

### Internal Swing Structure

Identifies internal swing highs and lows through configurable left and right pivot lengths.

ATR-based filtering determines minimum swing separation, while same-direction zone filtering reduces nearby structural overlap. Dashed SH/SL reference lines mark detected swing points, with percentage distance incorporated into the original labels.

Unbroken reference lines can extend to the current bar. Confirmed structural breaks change the corresponding line's color, width, and style.

### Structure Distance

Tracks retained SH and SL reference levels and calculates their percentage distance from the current closing price.

The structure table displays reference prices, distance percentages, and corresponding states:

- NEAR — the reference is within the configured distance threshold.
- OK — the reference remains on its unbroken side and outside the NEAR threshold.
- BREAK — the reference lies beyond the current close according to the table's distance calculation.

The display retains up to three SH references and three SL references, subject to the script's queue and removal logic.

[image]https://www.tradingview.com/x/34gzkgth/[/image]

### BOS / CHoCH

Classifies closing-price breaks of recorded internal swing levels.

- BOS ↑ / BOS ↓ — structural break classification when the recorded internal trend direction is maintained.
- CHoCH ↑ / CHoCH ↓ — structural break classification when the break differs from the previously recorded internal trend direction.

Structural levels are updated when their defined closing-price break conditions are met. Label-spacing controls help reduce overlapping BOS/CHoCH annotations.

[image]https://www.tradingview.com/x/TG1LUV6n/[/image]

### FVG Dual Flow

Detects bullish and bearish Fair Value Gaps through three-candle price relationships, subject to the configured minimum gap size.

Each zone begins with a TEST state and progresses through a directional interaction sequence:

TEST → LIQUIDITY → ACCEPT / REJECT → CONFLICT → STOP → START → RESET → TEST

State transitions depend on price interaction with zone boundaries, closing-price relationships, confirmation counts, and ATR-based distance thresholds.

Bullish and bearish zones use separate state logic. FVG zones are removed when the defined closing-price invalidation condition is met, while older zones are removed when the configured retention limit is exceeded.

[image]https://www.tradingview.com/x/4j5rRMwy/[/image]

### Structure Management

Configurable settings control internal pivot sensitivity, ATR swing filtering, reference-line length, label offsets, overlap prevention, BOS/CHoCH display, FVG dimensions, confirmation counts, retained zones, distance thresholds, and alert conditions.

## Output Results

- Internal SH/SL reference lines and price-distance labels.
- BOS and CHoCH structural break classifications.
- A Structure Distance table showing retained SH/SL levels, percentage distances, and states.
- Bullish and bearish FVG zones with evolving Dual Flow labels.
- Configurable visual distinctions for swing structure, structural breaks, and FVG regions.
- Near-distance and structural-break alerts.

## Next Task / Action Framework

WATCH — Observe newly confirmed internal swing points and emerging FVG zones.

WAIT — Track price interaction with recorded structural levels and FVG boundaries.

TRACK — Monitor BOS/CHoCH classification, SH/SL distance, and FVG Dual Flow progression.

CONFIRM — Observe when closing-price relationships and configured conditions establish a new displayed state.

RECHECK — Reassess retained structural references, distance classifications, and FVG zone persistence as market conditions change.

## Scope

Designed for market observation and structural analysis through internal swing relationships, structural break classification, distance monitoring, and FVG interaction states.

The framework does not provide trading signals or prescribe directional actions. Displayed states and alerts reflect the indicator's programmed conditions and may vary with the selected instrument, timeframe, and input parameters.

## Source Code

````pine
//@version=6
indicator("ATK/DEF The Spirit by Water Force Internal Swing", shorttitle="ATK/DEF Water Element Internal Swing", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// ═══════════════════════════ INPUTS ═══════════════════════════
grpInt = "Internal Structure"
intLeftBars  = input.int(3,   "Internal Left Bars",  minval=1, group=grpInt)
intRightBars = input.int(3,   "Internal Right Bars", minval=1, group=grpInt)
showInternal = input.bool(true, "Show Internal Structure", group=grpInt)
intColorH    = input.color(color.red,  "Internal High Color", group=grpInt)
intColorL    = input.color(color.green,"Internal Low Color",  group=grpInt)

grpFilter = "Filter / Display"
atrLen    = input.int(14,  "ATR Length", minval=1, group=grpFilter)
atrMult   = input.float(1.0,"ATR Multiplier (Swing Filter)", minval=0.1, step=0.1, group=grpFilter)
offsetATR = input.float(0.3,"Text Offset (ATR Multiplier)", minval=0.1, step=0.1, group=grpFilter)
initLen   = input.int(3,   "Structure Line Initial Length (bars)", minval=1, group=grpFilter)
zoneATR   = input.float(0.5,"Same-Direction Zone (ATR Multiplier)", minval=0.1, step=0.1, group=grpFilter)
extendLine= input.bool(true,"Extend Unbroken Lines to Current Bar", group=grpFilter)
labelSize = input.string("tiny","Text Size", options=["tiny","small","normal","large"], group=grpFilter)

grpAnti = "Anti-Overlap"
antiSwingBars = input.int(3, "Min Bar Gap Between SH/SL Labels", minval=0, group=grpAnti)
antiBOSBar    = input.bool(true, "One BOS/CHoCH Label per Bar", group=grpAnti)
antiBOSBars   = input.int(2, "Min Bar Gap Between BOS/CHoCH Labels", minval=0, group=grpAnti)

grpBOS = "BOS / CHoCH"
showBOS      = input.bool(true, "Show BOS / CHoCH", group=grpBOS)
bosUpColor   = input.color(color.aqua, "Bullish Color", group=grpBOS)
bosDnColor   = input.color(color.red,  "Bearish Color", group=grpBOS)

grpFVG = "FVG Dual Flow"
showFVG        = input.bool(true, "Show FVG (Box + Label + Dual Flow)", group=grpFVG)
fvgBullColor   = input.color(color.new(color.green, 80), "Bullish FVG Color", group=grpFVG)
fvgBearColor   = input.color(color.new(color.red, 80),   "Bearish FVG Color", group=grpFVG)
fvgBorder      = input.bool(true, "FVG Border", group=grpFVG)
fvgBoxWidth    = input.int(10, "FVG Width (bars)", minval=1, maxval=50, group=grpFVG)
fvgMinSizeATR  = input.float(0.0, "FVG Min Size (ATR Multiplier)", minval=0.0, step=0.1, group=grpFVG)
fvgLabelSize   = input.string("tiny", "FVG Label Size", options=["tiny","small","normal","large"], group=grpFVG)
fvgAcceptBars  = input.int(3, "ACCEPT Confirm Bars", minval=1, group=grpFVG)
fvgConflictBars= input.int(2, "CONFLICT Confirm Bars", minval=1, group=grpFVG)
fvgFarATR      = input.float(1.0, "Far Distance (ATR Multiplier)", minval=0.1, step=0.1, group=grpFVG)
fvgMaxKeep     = input.int(50, "Max FVG Kept", minval=1, maxval=500, group=grpFVG)

grpDist = "Structure Distance / Alerts"
showDistTable   = input.bool(true, "Show Structure Distance Table", group=grpDist)
distNearPct     = input.float(0.5, "Near Alert Threshold (%)", minval=0.0, step=0.1, group=grpDist)
alertNear       = input.bool(true, "Near Alert (< Threshold %)", group=grpDist)
alertBreak      = input.bool(true, "Break Alert (Breakout)", group=grpDist)

f_size(string s) =>
    switch s
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        => size.large

// ═══════════════════════════ ATR ═══════════════════════════
atrVal    = ta.atr(atrLen)
threshold = atrVal * atrMult
yOffset   = atrVal * offsetATR
zone      = atrVal * zoneATR
fvgMinSize= atrVal * fvgMinSizeATR
fvgFarDist= atrVal * fvgFarATR

// ═══════════════════════════ PIVOTS ═══════════════════════════
intPH = ta.pivothigh(high, intLeftBars, intRightBars)
intPL = ta.pivotlow(low,  intLeftBars, intRightBars)

// ═══════════════════════════ INTERNAL STATE ═══════════════════════════
var int   intLastType = 0
var int   intTrend    = 0
var line  intLastHLine = na
var line  intLastLLine = na
var int   intPrevHX = na
var float intPrevHY = na
var int   intPrevLX = na
var float intPrevLY = na
var line  intPrevHLineRef = na
var line  intPrevLLineRef = na
var bool  intHBroken = false
var bool  intLBroken = false

var int   lastSwingBar = na
var int   lastBOSBar   = na
var int   lastBOSType  = 0

// ═══════════════════════════ STRUCTURE QUEUE (last 3 unbroken SH/SL) ═══════════════════════════
var array<float> shPrices = array.new<float>()
var array<int>   shBars   = array.new<int>()
var array<float> slPrices = array.new<float>()
var array<int>   slBars   = array.new<int>()

// ═══════════════════════════ INTERNAL SWING HIGH ═══════════════════════════
if showInternal and not na(intPH) and intLastType != 1
    px = bar_index - intRightBars
    py = intPH
    atrOK     = na(intPrevLY) or math.abs(py - intPrevLY) >= threshold
    noOverlap = na(intPrevHY) or math.abs(py - intPrevHY) >= zone
    barOK     = na(lastSwingBar) or (bar_index - lastSwingBar) >= antiSwingBars

    if atrOK and noOverlap and barOK
        if not na(intLastHLine) and not intHBroken
            line.set_x2(intLastHLine, px)
        if not na(intLastLLine) and not intLBroken
            line.set_x2(intLastLLine, px)

        intLastHLine := line.new(px, py, px + initLen, py, color=intColorH, width=1, style=line.style_dashed, xloc=xloc.bar_index)

        // ★ Distance merged into original SH label
        float dNow = (py - close) / close * 100
        string shTxt = "SH " + str.tostring(py, format.mintick) + "\n" + (dNow >= 0 ? "+" : "") + str.tostring(dNow, "#.##") + "%"
        label.new(px, py, shTxt, style=label.style_label_down, color=intColorH, textcolor=color.white, size=f_size(labelSize), xloc=xloc.bar_index)

        intPrevHX := px
        intPrevHY := py
        intPrevHLineRef := intLastHLine
        intLastType := 1
        intHBroken := false
        lastSwingBar := bar_index

        array.push(shPrices, py)
        array.push(shBars, px)
        while array.size(shPrices) > 3
            array.shift(shPrices)
            array.shift(shBars)

// ═══════════════════════════ INTERNAL SWING LOW ═══════════════════════════
if showInternal and not na(intPL) and intLastType != -1
    px = bar_index - intRightBars
    py = intPL
    atrOK     = na(intPrevHY) or math.abs(py - intPrevHY) >= threshold
    noOverlap = na(intPrevLY) or math.abs(py - intPrevLY) >= zone
    barOK     = na(lastSwingBar) or (bar_index - lastSwingBar) >= antiSwingBars

    if atrOK and noOverlap and barOK
        if not na(intLastLLine) and not intLBroken
            line.set_x2(intLastLLine, px)
        if not na(intLastHLine) and not intHBroken
            line.set_x2(intLastHLine, px)

        intLastLLine := line.new(px, py, px + initLen, py, color=intColorL, width=1, style=line.style_dashed, xloc=xloc.bar_index)

        // ★ Distance merged into original SL label
        float dNow = (close - py) / close * 100
        string slTxt = "SL " + str.tostring(py, format.mintick) + "\n" + (dNow >= 0 ? "+" : "") + str.tostring(dNow, "#.##") + "%"
        label.new(px, py, slTxt, style=label.style_label_up, color=intColorL, textcolor=color.white, size=f_size(labelSize), xloc=xloc.bar_index)

        intPrevLX := px
        intPrevLY := py
        intPrevLLineRef := intLastLLine
        intLastType := -1
        intLBroken := false
        lastSwingBar := bar_index

        array.push(slPrices, py)
        array.push(slBars, px)
        while array.size(slPrices) > 3
            array.shift(slPrices)
            array.shift(slBars)

// ═══════════════════════════ EXTEND UNBROKEN LINES ═══════════════════════════
if extendLine
    if not na(intLastHLine) and not intHBroken
        line.set_x2(intLastHLine, bar_index)
    if not na(intLastLLine) and not intLBroken
        line.set_x2(intLastLLine, bar_index)

// ═══════════════════════════ BOS / CHoCH ═══════════════════════════
bool shBreakEvent = false
bool slBreakEvent = false
float shBreakLevel = na
float slBreakLevel = na

if showBOS
    bosBarOK = not antiBOSBar or na(lastBOSBar) or (bar_index - lastBOSBar) >= antiBOSBars

    if not na(intPrevHY) and not intHBroken and close > intPrevHY
        intHBroken := true
        if not na(intPrevHLineRef)
            line.set_x2(intPrevHLineRef, bar_index)
            line.set_color(intPrevHLineRef, bosUpColor)
            line.set_width(intPrevHLineRef, 2)
            line.set_style(intPrevHLineRef, line.style_solid)

        if bosBarOK
            midX = math.round((intPrevHX + bar_index) / 2)
            txt  = intTrend == 1 ? "BOS ↑" : "CHoCH ↑"
            label.new(midX, intPrevHY + yOffset, txt, style=label.style_none, color=bosUpColor, textcolor=bosUpColor, size=f_size(labelSize), xloc=xloc.bar_index)
            lastBOSBar := bar_index
            lastBOSType := 1

        intTrend := 1
        shBreakEvent := true
        shBreakLevel := intPrevHY

        if array.size(shPrices) > 0
            array.shift(shPrices)
            array.shift(shBars)

    if not na(intPrevLY) and not intLBroken and close < intPrevLY
        intLBroken := true
        if not na(intPrevLLineRef)
            line.set_x2(intPrevLLineRef, bar_index)
            line.set_color(intPrevLLineRef, bosDnColor)
            line.set_width(intPrevLLineRef, 2)
            line.set_style(intPrevLLineRef, line.style_solid)

        if bosBarOK
            midX = math.round((intPrevLX + bar_index) / 2)
            txt  = intTrend == -1 ? "BOS ↓" : "CHoCH ↓"
            label.new(midX, intPrevLY - yOffset, txt, style=label.style_none, color=bosDnColor, textcolor=bosDnColor, size=f_size(labelSize), xloc=xloc.bar_index)
            lastBOSBar := bar_index
            lastBOSType := -1

        intTrend := -1
        slBreakEvent := true
        slBreakLevel := intPrevLY

        if array.size(slPrices) > 0
            array.shift(slPrices)
            array.shift(slBars)

// ═══════════════════════════ STRUCTURE DISTANCE ═══════════════════════════
float activeSH = array.size(shPrices) > 0 ? array.get(shPrices, array.size(shPrices) - 1) : na
float activeSL = array.size(slPrices) > 0 ? array.get(slPrices, array.size(slPrices) - 1) : na

float shDistPct = na(activeSH) ? na : (activeSH - close) / close * 100
float slDistPct = na(activeSL) ? na : (close - activeSL) / close * 100

// ═══════════════════════════ TABLE: STRUCTURE DISTANCE ═══════════════════════════
var table distTable = table.new(position.top_right, 4, 8, border_width=1)

if showDistTable and barstate.islast
    table.cell(distTable, 0, 0, "Structure", text_color=color.white, bgcolor=color.new(color.blue, 30))
    table.cell(distTable, 1, 0, "Price",     text_color=color.white, bgcolor=color.new(color.blue, 30))
    table.cell(distTable, 2, 0, "Dist %",    text_color=color.white, bgcolor=color.new(color.blue, 30))
    table.cell(distTable, 3, 0, "State",     text_color=color.white, bgcolor=color.new(color.blue, 30))

    // SH 3 rows (nearest → farthest)
    if array.size(shPrices) > 0
        int n = array.size(shPrices)
        for k = 0 to math.min(n, 3) - 1
            int idx = n - 1 - k
            float p = array.get(shPrices, idx)
            float d = (p - close) / close * 100
            string state = d >= 0 ? (d < distNearPct ? "NEAR" : "OK") : "BREAK"
            color bg = d >= 0 ? (d < distNearPct ? color.new(color.yellow, 60) : color.new(color.red, 70)) : color.new(color.gray, 70)
            string tag = k == 0 ? "SH Active" : "SH " + str.tostring(k + 1)
            table.cell(distTable, 0, 1 + k, tag, text_color=color.white, bgcolor=bg)
            table.cell(distTable, 1, 1 + k, str.tostring(p, format.mintick), text_color=color.white, bgcolor=bg)
            table.cell(distTable, 2, 1 + k, (d >= 0 ? "+" : "") + str.tostring(d, "#.##") + "%", text_color=color.white, bgcolor=bg)
            table.cell(distTable, 3, 1 + k, state, text_color=color.white, bgcolor=bg)

    // SL 3 rows
    if array.size(slPrices) > 0
        int n = array.size(slPrices)
        for k = 0 to math.min(n, 3) - 1
            int idx = n - 1 - k
            float p = array.get(slPrices, idx)
            float d = (close - p) / close * 100
            string state = d >= 0 ? (d < distNearPct ? "NEAR" : "OK") : "BREAK"
            color bg = d >= 0 ? (d < distNearPct ? color.new(color.yellow, 60) : color.new(color.green, 70)) : color.new(color.gray, 70)
            string tag = k == 0 ? "SL Active" : "SL " + str.tostring(k + 1)
            table.cell(distTable, 0, 4 + k, tag, text_color=color.white, bgcolor=bg)
            table.cell(distTable, 1, 4 + k, str.tostring(p, format.mintick), text_color=color.white, bgcolor=bg)
            table.cell(distTable, 2, 4 + k, (d >= 0 ? "+" : "") + str.tostring(d, "#.##") + "%", text_color=color.white, bgcolor=bg)
            table.cell(distTable, 3, 4 + k, state, text_color=color.white, bgcolor=bg)

// ═══════════════════════════ ALERTS (Break > Near priority) ═══════════════════════════
bool nearSH = not na(shDistPct) and shDistPct >= 0 and shDistPct < distNearPct
bool nearSL = not na(slDistPct) and slDistPct >= 0 and slDistPct < distNearPct

if shBreakEvent and alertBreak
    alert("SH Break | " + syminfo.ticker + " | " + timeframe.period + " | Level=" + str.tostring(shBreakLevel, format.mintick), alert.freq_once_per_bar_close)
else if nearSH and alertNear
    alert("SH Near | " + syminfo.ticker + " | " + timeframe.period + " | Dist=" + str.tostring(shDistPct, "#.##") + "%", alert.freq_once_per_bar_close)

if slBreakEvent and alertBreak
    alert("SL Break | " + syminfo.ticker + " | " + timeframe.period + " | Level=" + str.tostring(slBreakLevel, format.mintick), alert.freq_once_per_bar_close)
else if nearSL and alertNear
    alert("SL Near | " + syminfo.ticker + " | " + timeframe.period + " | Dist=" + str.tostring(slDistPct, "#.##") + "%", alert.freq_once_per_bar_close)

// ═══════════════════════════ FVG DUAL FLOW ═══════════════════════════
var array<box>   bullFvgBoxes  = array.new<box>()
var array<box>   bearFvgBoxes  = array.new<box>()
var array<label> bullFvgLabels = array.new<label>()
var array<label> bearFvgLabels = array.new<label>()

var array<int>   bullFvgStage  = array.new<int>()
var array<float> bullFvgTop    = array.new<float>()
var array<float> bullFvgBot    = array.new<float>()
var array<int>   bullFvgBar    = array.new<int>()
var array<int>   bullFvgCnt    = array.new<int>()

var array<int>   bearFvgStage  = array.new<int>()
var array<float> bearFvgTop    = array.new<float>()
var array<float> bearFvgBot    = array.new<float>()
var array<int>   bearFvgBar    = array.new<int>()
var array<int>   bearFvgCnt    = array.new<int>()

if showFVG and low > high[2]
    float gapTop = low
    float gapBot = high[2]
    float gapSize = gapTop - gapBot
    if gapSize >= fvgMinSize
        box b = box.new(bar_index, gapTop, bar_index + fvgBoxWidth, gapBot,
                        border_color = fvgBorder ? color.new(color.green, 50) : na,
                        border_width = fvgBorder ? 1 : 0,
                        bgcolor = fvgBullColor,
                        xloc = xloc.bar_index)
        array.push(bullFvgBoxes, b)

        int midX = bar_index + math.round(fvgBoxWidth / 2)
        float midY = (gapTop + gapBot) / 2
        lbl = label.new(midX, midY, "FVG ↑ TEST",
                        style = label.style_none,
                        textcolor = color.new(color.green, 0),
                        size = f_size(fvgLabelSize),
                        xloc = xloc.bar_index)
        array.push(bullFvgLabels, lbl)

        array.push(bullFvgStage, 1)
        array.push(bullFvgTop, gapTop)
        array.push(bullFvgBot, gapBot)
        array.push(bullFvgBar, bar_index)
        array.push(bullFvgCnt, 0)

if showFVG and high < low[2]
    float gapTop = low[2]
    float gapBot = high
    float gapSize = gapTop - gapBot
    if gapSize >= fvgMinSize
        box b = box.new(bar_index, gapTop, bar_index + fvgBoxWidth, gapBot,
                        border_color = fvgBorder ? color.new(color.red, 50) : na,
                        border_width = fvgBorder ? 1 : 0,
                        bgcolor = fvgBearColor,
                        xloc = xloc.bar_index)
        array.push(bearFvgBoxes, b)

        int midX = bar_index + math.round(fvgBoxWidth / 2)
        float midY = (gapTop + gapBot) / 2
        lbl = label.new(midX, midY, "FVG ↓ TEST",
                        style = label.style_none,
                        textcolor = color.new(color.red, 0),
                        size = f_size(fvgLabelSize),
                        xloc = xloc.bar_index)
        array.push(bearFvgLabels, lbl)

        array.push(bearFvgStage, 1)
        array.push(bearFvgTop, gapTop)
        array.push(bearFvgBot, gapBot)
        array.push(bearFvgBar, bar_index)
        array.push(bearFvgCnt, 0)

// FVG Bullish Flow
if showFVG and array.size(bullFvgStage) > 0
    int i = 0
    while i < array.size(bullFvgStage)
        int stage = array.get(bullFvgStage, i)
        float gTop = array.get(bullFvgTop, i)
        float gBot = array.get(bullFvgBot, i)
        int gBar = array.get(bullFvgBar, i)
        int cnt = array.get(bullFvgCnt, i)
        label lb = array.get(bullFvgLabels, i)

        if bar_index > gBar
            if stage == 1
                if low <= gTop
                    label.set_text(lb, "FVG ↑ LIQUIDITY")
                    array.set(bullFvgStage, i, 2)
                    array.set(bullFvgCnt, i, 0)
            else if stage == 2
                if low <= gBot
                    label.set_text(lb, "FVG ↑ CONFLICT")
                    array.set(bullFvgStage, i, 5)
                    array.set(bullFvgCnt, i, 0)
                else if close > gTop
                    label.set_text(lb, "FVG ↑ REJECT")
                    array.set(bullFvgStage, i, 4)
                    array.set(bullFvgCnt, i, 0)
                else if close >= gBot and close <= gTop
                    cnt += 1
                    array.set(bullFvgCnt, i, cnt)
                    if cnt >= fvgAcceptBars
                        label.set_text(lb, "FVG ↑ ACCEPT")
                        array.set(bullFvgStage, i, 3)
                        array.set(bullFvgCnt, i, 0)
            else if stage == 3
                if close > gTop
                    label.set_text(lb, "FVG ↑ REJECT")
                    array.set(bullFvgStage, i, 4)
                    array.set(bullFvgCnt, i, 0)
                else if low <= gBot
                    cnt += 1
                    array.set(bullFvgCnt, i, cnt)
                    if cnt >= fvgConflictBars
                        label.set_text(lb, "FVG ↑ CONFLICT")
                        array.set(bullFvgStage, i, 5)
                        array.set(bullFvgCnt, i, 0)
                else
                    array.set(bullFvgCnt, i, 0)
            else if stage == 4
                if low <= gTop
                    label.set_text(lb, "FVG ↑ CONFLICT")
                    array.set(bullFvgStage, i, 5)
                    array.set(bullFvgCnt, i, 0)
            else if stage == 5
                if close < gBot
                    label.set_text(lb, "FVG ↑ STOP")
                    array.set(bullFvgStage, i, 6)
                    array.set(bullFvgCnt, i, 0)
            else if stage == 6
                if close > gTop + fvgFarDist
                    label.set_text(lb, "FVG ↑ START")
                    array.set(bullFvgStage, i, 7)
                    array.set(bullFvgCnt, i, 0)
            else if stage == 7
                if close > gTop + fvgFarDist * 2
                    label.set_text(lb, "FVG ↑ RESET")
                    array.set(bullFvgStage, i, 8)
                    array.set(bullFvgCnt, i, 0)
            else if stage == 8
                if low <= gTop
                    label.set_text(lb, "FVG ↑ TEST")
                    array.set(bullFvgStage, i, 1)
                    array.set(bullFvgCnt, i, 0)
        i += 1

// FVG Bearish Flow
if showFVG and array.size(bearFvgStage) > 0
    int i = 0
    while i < array.size(bearFvgStage)
        int stage = array.get(bearFvgStage, i)
        float gTop = array.get(bearFvgTop, i)
        float gBot = array.get(bearFvgBot, i)
        int gBar = array.get(bearFvgBar, i)
        int cnt = array.get(bearFvgCnt, i)
        label lb = array.get(bearFvgLabels, i)

        if bar_index > gBar
            if stage == 1
                if high >= gBot
                    label.set_text(lb, "FVG ↓ LIQUIDITY")
                    array.set(bearFvgStage, i, 2)
                    array.set(bearFvgCnt, i, 0)
            else if stage == 2
                if high >= gTop
                    label.set_text(lb, "FVG ↓ CONFLICT")
                    array.set(bearFvgStage, i, 5)
                    array.set(bearFvgCnt, i, 0)
                else if close < gBot
                    label.set_text(lb, "FVG ↓ REJECT")
                    array.set(bearFvgStage, i, 4)
                    array.set(bearFvgCnt, i, 0)
                else if close >= gBot and close <= gTop
                    cnt += 1
                    array.set(bearFvgCnt, i, cnt)
                    if cnt >= fvgAcceptBars
                        label.set_text(lb, "FVG ↓ ACCEPT")
                        array.set(bearFvgStage, i, 3)
                        array.set(bearFvgCnt, i, 0)
            else if stage == 3
                if close < gBot
                    label.set_text(lb, "FVG ↓ REJECT")
                    array.set(bearFvgStage, i, 4)
                    array.set(bearFvgCnt, i, 0)
                else if high >= gTop
                    cnt += 1
                    array.set(bearFvgCnt, i, cnt)
                    if cnt >= fvgConflictBars
                        label.set_text(lb, "FVG ↓ CONFLICT")
                        array.set(bearFvgStage, i, 5)
                        array.set(bearFvgCnt, i, 0)
                else
                    array.set(bearFvgCnt, i, 0)
            else if stage == 4
                if high >= gBot
                    label.set_text(lb, "FVG ↓ CONFLICT")
                    array.set(bearFvgStage, i, 5)
                    array.set(bearFvgCnt, i, 0)
            else if stage == 5
                if close > gTop
                    label.set_text(lb, "FVG ↓ STOP")
                    array.set(bearFvgStage, i, 6)
                    array.set(bearFvgCnt, i, 0)
            else if stage == 6
                if close < gBot - fvgFarDist
                    label.set_text(lb, "FVG ↓ START")
                    array.set(bearFvgStage, i, 7)
                    array.set(bearFvgCnt, i, 0)
            else if stage == 7
                if close < gBot - fvgFarDist * 2
                    label.set_text(lb, "FVG ↓ RESET")
                    array.set(bearFvgStage, i, 8)
                    array.set(bearFvgCnt, i, 0)
            else if stage == 8
                if high >= gBot
                    label.set_text(lb, "FVG ↓ TEST")
                    array.set(bearFvgStage, i, 1)
                    array.set(bearFvgCnt, i, 0)
        i += 1

// FVG Fill Detection + FIFO
if showFVG
    if array.size(bullFvgBoxes) > 0
        int i = 0
        while i < array.size(bullFvgBoxes)
            box b = array.get(bullFvgBoxes, i)
            if not na(b)
                float bBot = box.get_bottom(b)
                if close < bBot
                    box.delete(b)
                    array.remove(bullFvgBoxes, i)
                    if i < array.size(bullFvgLabels)
                        label.delete(array.get(bullFvgLabels, i))
                        array.remove(bullFvgLabels, i)
                    if i < array.size(bullFvgStage)
                        array.remove(bullFvgStage, i)
                        array.remove(bullFvgTop, i)
                        array.remove(bullFvgBot, i)
                        array.remove(bullFvgBar, i)
                        array.remove(bullFvgCnt, i)
                else
                    i += 1
            else
                i += 1

    if array.size(bearFvgBoxes) > 0
        int i = 0
        while i < array.size(bearFvgBoxes)
            box b = array.get(bearFvgBoxes, i)
            if not na(b)
                float bTop = box.get_top(b)
                if close > bTop
                    box.delete(b)
                    array.remove(bearFvgBoxes, i)
                    if i < array.size(bearFvgLabels)
                        label.delete(array.get(bearFvgLabels, i))
                        array.remove(bearFvgLabels, i)
                    if i < array.size(bearFvgStage)
                        array.remove(bearFvgStage, i)
                        array.remove(bearFvgTop, i)
                        array.remove(bearFvgBot, i)
                        array.remove(bearFvgBar, i)
                        array.remove(bearFvgCnt, i)
                else
                    i += 1
            else
                i += 1

    while array.size(bullFvgBoxes) > fvgMaxKeep
        box.delete(array.shift(bullFvgBoxes))
        if array.size(bullFvgLabels) > 0
            label.delete(array.shift(bullFvgLabels))
            array.shift(bullFvgStage)
            array.shift(bullFvgTop)
            array.shift(bullFvgBot)
            array.shift(bullFvgBar)
            array.shift(bullFvgCnt)
    while array.size(bearFvgBoxes) > fvgMaxKeep
        box.delete(array.shift(bearFvgBoxes))
        if array.size(bearFvgLabels) > 0
            label.delete(array.shift(bearFvgLabels))
            array.shift(bearFvgStage)
            array.shift(bearFvgTop)
            array.shift(bearFvgBot)
            array.shift(bearFvgBar)
            array.shift(bearFvgCnt)
````
