# ATK/DEF The Spirit By Metal Power Swing Flow 

- url: https://www.tradingview.com/script/R85TX24V/
- type: indicator
- pine_id: PUB;de7ca47a4a8a4968a4aac5250c5c3c2e
- version: 1.0

## Description

# ATK/DEF The Spirit By Metal Power Swing Flow

## Overview

ATK/DEF The Spirit By Metal Power Swing Flow is a multi-layer technical analysis indicator that combines swing structure, price-wave visualization, horizontal price levels, dual Fair Value Gap (FVG) tracking, directional candle-volume distribution, and session-based volatility readings.

It provides a unified visual framework for observing swing development, FVG interactions, candle-volume distribution, and relative volatility conditions.

## Core Features

### 1. Swing Structure & Wave Flow

- Identifies Swing Highs (SH) and Swing Lows (SL) using configurable pivot settings.
- Displays optional volume values at swing points.
- Supports multiple volume display formats.
- Uses ATR-based tolerance to filter nearby equal swing highs and lows.
- Connects alternating swing points with optional wave lines.
- Displays horizontal price levels with configurable extensions.
- Distinguishes touched and untouched levels according to the script's conditions.

### 2. Dual Fair Value Gap (FVG) Flow

Detects bullish and bearish Fair Value Gaps using three-candle price-gap conditions.

Each FVG includes a custom nine-stage sequence:

**Coalesce → Form → Boundary → Run → Filter → Converge → Transform → Conceal → Rebirth**

The indicator tracks these custom stages according to its internal rules and supports configurable gap appearance, minimum ATR-based gap size, maximum retention, age-based cleanup, and closing-price invalidation.

These stage names represent the indicator's custom logic and are not universal market classifications.

### 3. Directional Candle-Volume Distribution

Tracks bullish-candle and bearish-candle volume accumulated after an FVG forms.

The display can include volume percentages and one of three classifications:

- Bull Dominant
- Bear Dominant
- Balanced

Classification is based on a configurable volume-dominance threshold. This module uses candle direction and chart volume; it does not directly measure buyer-initiated or seller-initiated orders, institutional activity, or order-book liquidity.

### 4. Session Volatility Thermometer

Displays relative ATR-based volatility during configurable session windows.

Features include:

- Configurable timezone and session windows.
- Adjustable ATR length and historical averaging period.
- Color-coded relative volatility readings.
- Customizable display position and appearance.

The thermometer measures relative volatility according to the script's calculation rules. It is not a direct measure of market sentiment, liquidity depth, or future price direction.

## Analytical Framework

**Swing Structure** — Observes swing highs and lows, wave connections, and horizontal price levels.

**FVG Dynamics** — Tracks bullish and bearish gaps, custom stage progression, price interaction, and invalidation.

**Directional Volume Distribution** — Compares bullish-candle and bearish-candle volume associated with tracked FVGs.

**Session Volatility** — Observes relative ATR conditions during selected session windows.

Together, these components provide a visual framework for examining changes in market structure, gap behavior, candle-volume distribution, and relative volatility.

## Chart Examples

1. https://www.tradingview.com/x/nYFWhWr9/

2. https://www.tradingview.com/x/lWr29cJt/

3. https://www.tradingview.com/x/zw10Tr6b/

4. https://www.tradingview.com/x/IRbn6zQO/

5. https://www.tradingview.com/x/cv8Q83O8/

## Important Notice

This indicator is provided for technical analysis and reference purposes only.

All labels, classifications, and visual readings are generated according to the script's predefined calculation rules. They do not guarantee future market behavior or outcomes and should not be treated as standalone confirmation of price direction.

Users should consider broader market conditions and conduct their own independent analysis.

## License

Mozilla Public License 2.0 (MPL-2.0)

## Source Code

````pine
//// This Pine Script code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("ATK/DEF The Spirit By Metal Power Swing Flow", shorttitle="Metal Element Swing Flow", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// ═══════════════════════════ Inputs ═══════════════════════════
swingLen  = input.int(5, "Swing Lookback", minval=1)
highColor = input.color(color.new(color.red, 0), "SH Color")
lowColor  = input.color(color.new(color.teal, 0), "SL Color")
labelSize = input.string("small", "Label Size", options=["tiny", "small", "normal", "large"])
shText    = input.string("SH", "Swing High Text")
slText    = input.string("SL", "Swing Low Text")

grpVol = "Volume Display"
showSwingVol = input.bool(true, "Show Volume on SH/SL", group=grpVol)
volFormat    = input.string("k/M", "Volume Format", options=["k/M", "Raw", "万/亿"], group=grpVol)

grpDedup = "Swing Dedup"
swingTolATR = input.float(0.1, "Equal High/Low Tolerance (ATR)", minval=0.0, step=0.01, group=grpDedup)
atrLenDedup = input.int(14, "ATR Length (Dedup)", minval=1, group=grpDedup)

grpHoriz = "Horizontal Line"
showHorizontal = input.bool(true, "Show Horizontal Line", group=grpHoriz)
horizontalExtend = input.int(20, "Extend Bars", minval=5, maxval=100, group=grpHoriz)
horizontalColor = input.color(color.new(color.gray, 0), "Line Color", group=grpHoriz)
horizontalWidth = input.int(1, "Line Width", minval=1, maxval=4, group=grpHoriz)

grpWave = "Wave Line"
showWave = input.bool(true, "Show Wave Line", group=grpWave)
waveColor = input.color(color.new(color.blue, 0), "Wave Color", group=grpWave)
waveWidth = input.int(2, "Wave Width", minval=1, maxval=4, group=grpWave)
maxSwings = input.int(50, "Max Swings Kept", minval=10, maxval=200, group=grpWave)

grpTrend = "Trend Line (Reserved)"
showTrendline = input.bool(true, "Show Trend Line", group=grpTrend)
trendColor = input.color(color.new(color.green, 0), "Up Trend Color", group=grpTrend)
trendColorBear = input.color(color.new(color.red, 0), "Down Trend Color", group=grpTrend)
trendWidth = input.int(2, "Trend Width", minval=1, maxval=4, group=grpTrend)

grpFVG = "FVG Dual Flow"
showFVG        = input.bool(true, "Show FVG (Box + Label + Flow)", group=grpFVG)
fvgUpColor     = input.color(color.new(color.teal, 0), "FVG ↑ Color", group=grpFVG)
fvgDnColor     = input.color(color.new(color.red, 0),  "FVG ↓ Color", group=grpFVG)
fvgAlpha       = input.int(80, "FVG Fill Transparency", minval=0, maxval=100, group=grpFVG)
fvgBorder      = input.bool(true, "FVG Border", group=grpFVG)
fvgBoxWidth    = input.int(10, "FVG Width (Bars)", minval=1, maxval=50, group=grpFVG)
fvgMinSizeATR  = input.float(0.0, "FVG Min Size (ATR)", minval=0.0, step=0.1, group=grpFVG)
fvgLabelSize   = input.string("tiny", "FVG Label Size", options=["tiny","small","normal","large"], group=grpFVG)
fvgMaxKeep     = input.int(50, "FVG Max Kept", minval=1, maxval=500, group=grpFVG)
atrLenFVG      = input.int(14, "ATR Length (FVG)", minval=1, group=grpFVG)

grpLiq = "FVG Liquidity"
showFvgLiq   = input.bool(true, "Show Liquidity on FVG Label", group=grpLiq)
liqThreshold = input.float(1.2, "Dominance Threshold (x)", minval=1.0, step=0.1, group=grpLiq)
fvgMaxAge    = input.int(500, "FVG Max Age (Bars, 0=unlimited)", minval=0, maxval=5000, group=grpLiq)

grpTemp = "Thermometer"
showTemp       = input.bool(true, "Show Thermometer", group=grpTemp)
tempTZ         = input.string("Asia/Singapore", "Timezone", options=["Asia/Singapore","Asia/Kuala_Lumpur","Asia/Hong_Kong","Asia/Shanghai","UTC+8"], group=grpTemp)

tempSessionAsia = input.session("0900-0910", "Asia Session (09:00 bar)", group=grpTemp)
tempAsiaColor   = input.color(color.new(color.blue, 0), "Asia Label Color", group=grpTemp)

tempSessionEU   = input.session("1500-1510", "Europe Session (15:00 bar)", group=grpTemp)
tempEUColor     = input.color(color.new(color.orange, 0), "Europe Label Color", group=grpTemp)

tempSessionUS   = input.session("2100-2110", "US Session (21:00 bar)", group=grpTemp)
tempUSColor     = input.color(color.new(color.purple, 0), "US Label Color", group=grpTemp)

tempAtrLen     = input.int(14, "ATR Length", minval=1, group=grpTemp)
tempLookback   = input.int(20, "ATR Mean Lookback", minval=1, group=grpTemp)
tempHeightATR  = input.float(1.5, "Thermometer Height (ATR)", minval=0.1, step=0.1, group=grpTemp)
tempOffsetATR  = input.float(0.5, "Offset from Bar (ATR)", minval=0.0, step=0.1, group=grpTemp)
tempWidth      = input.int(4, "Thermometer Width (px)", minval=1, maxval=20, group=grpTemp)
tempLabelSize  = input.string("tiny", "Thermometer Label Size", options=["tiny","small","normal","large"], group=grpTemp)
tempColdColor  = input.color(color.new(color.blue, 0),   "Cold Color", group=grpTemp)
tempMidColor   = input.color(color.new(color.yellow, 0), "Mid Color", group=grpTemp)
tempHotColor   = input.color(color.new(color.red, 0),    "Hot Color", group=grpTemp)
tempMaxKeep    = input.int(50, "Thermometer Max Kept", minval=1, maxval=200, group=grpTemp)

f_size(string s) =>
    switch s
        "tiny" => size.tiny
        "small" => size.small
        "normal" => size.normal
        "large" => size.large

volText(float v) =>
    if na(v)
        "—"
    else
        switch volFormat
            "k/M" =>
                if v >= 1000000
                    str.tostring(v / 1000000, "#.##") + "M"
                else if v >= 1000
                    str.tostring(v / 1000, "#.#") + "k"
                else
                    str.tostring(v, "#")
            "万/亿" =>
                if v >= 100000000
                    str.tostring(v / 100000000, "#.##") + "亿"
                else if v >= 10000
                    str.tostring(v / 10000, "#.##") + "万"
                else
                    str.tostring(v, "#")
            =>
                str.tostring(v, "#")

bullFvgTxt(int st) =>
    switch st
        1 => "FVG ↑ Coalesce ➡"
        2 => "FVG ↑ Form ⬆"
        3 => "FVG ↑ Boundary ⬆"
        4 => "FVG ↑ Run ⬆"
        5 => "FVG ↑ Filter ⬇"
        6 => "FVG ↑ Converge ⬇"
        7 => "FVG ↑ Transform ⬆"
        8 => "FVG ↑ Conceal ⬆"
        9 => "FVG ↑ Rebirth ⬇"
        => "FVG ↑ Coalesce ➡"

bearFvgTxt(int st) =>
    switch st
        1 => "FVG ↓ Coalesce ➡"
        2 => "FVG ↓ Form ⬇"
        3 => "FVG ↓ Boundary ⬇"
        4 => "FVG ↓ Run ⬇"
        5 => "FVG ↓ Filter ⬆"
        6 => "FVG ↓ Converge ⬆"
        7 => "FVG ↓ Transform ⬇"
        8 => "FVG ↓ Conceal ⬇"
        9 => "FVG ↓ Rebirth ⬆"
        => "FVG ↓ Coalesce ➡"

liqText(float bullVol, float bearVol) =>
    float total = bullVol + bearVol
    if total <= 0
        "\n[L: —]"
    else
        float bullPct = bullVol / total * 100
        float bearPct = bearVol / total * 100
        string state = "Balanced"
        if bullVol > bearVol * liqThreshold
            state := "Bull Dominant"
        else if bearVol > bullVol * liqThreshold
            state := "Bear Dominant"
        "\n[L: " + state + " | Bull " + str.tostring(bullPct, "#") + "% | Bear " + str.tostring(bearPct, "#") + "%]"

tempColor(float ratio) =>
    if ratio <= 0.5
        color.from_gradient(ratio, 0.0, 0.5, tempColdColor, tempMidColor)
    else
        color.from_gradient(ratio, 0.5, 1.0, tempMidColor, tempHotColor)

swingHighPt = ta.pivothigh(high, swingLen, swingLen)
swingLowPt  = ta.pivotlow(low, swingLen, swingLen)

atrDedup = ta.atr(atrLenDedup)
atrFVG   = ta.atr(atrLenFVG)
atrTemp  = ta.atr(tempAtrLen)
swingTol = atrDedup * swingTolATR
fvgMinSize = atrFVG * fvgMinSizeATR

var float lastSwingHighPrice = na
var float lastSwingLowPrice  = na

var float[]  swingPrices        = array.new_float()
var int[]    swingIndices       = array.new_int()
var string[] swingTypes         = array.new_string()
var line[]   swingLines         = array.new_line()
var line[]   horizontalLines    = array.new_line()
var int[]    horizontalTouchIdx = array.new_int()

var float[] trendHighs = array.new_float()
var int[]   trendHighIndices = array.new_int()
var float[] trendLows = array.new_float()
var int[]   trendLowIndices = array.new_int()
var line[]  trendLines = array.new_line()
var line[]  trendLinesBear = array.new_line()

var array<box>   bullFvgBoxes  = array.new<box>()
var array<box>   bearFvgBoxes  = array.new<box>()
var array<label> bullFvgLabels = array.new<label>()
var array<label> bearFvgLabels = array.new<label>()

var array<int>   bullFvgStage  = array.new<int>()
var array<float> bullFvgTop    = array.new<float>()
var array<float> bullFvgBot    = array.new<float>()
var array<int>   bullFvgBar    = array.new<int>()

var array<int>   bearFvgStage  = array.new<int>()
var array<float> bearFvgTop    = array.new<float>()
var array<float> bearFvgBot    = array.new<float>()
var array<int>   bearFvgBar    = array.new<int>()

var array<float> bullFvgBullVol = array.new<float>()
var array<float> bullFvgBearVol = array.new<float>()
var array<float> bearFvgBullVol = array.new<float>()
var array<float> bearFvgBearVol = array.new<float>()

var array<box>   tempBoxes  = array.new<box>()
var array<label> tempLabels = array.new<label>()

deleteLineSafe(line ln) =>
    if not na(ln)
        line.delete(ln)

deleteBoxSafe(box b) =>
    if not na(b)
        box.delete(b)

deleteLabelSafe(label lb) =>
    if not na(lb)
        label.delete(lb)

fifoCleanup() =>
    while array.size(swingPrices) > maxSwings
        if array.size(swingLines) > 0
            deleteLineSafe(array.shift(swingLines))
        if array.size(horizontalLines) > 0
            deleteLineSafe(array.shift(horizontalLines))
        if array.size(swingPrices) > 0
            array.shift(swingPrices)
        if array.size(swingIndices) > 0
            array.shift(swingIndices)
        if array.size(swingTypes) > 0
            array.shift(swingTypes)
        if array.size(horizontalTouchIdx) > 0
            array.shift(horizontalTouchIdx)

fifoCleanupTrend() =>
    while array.size(trendHighs) > 20
        if array.size(trendLines) > 0
            deleteLineSafe(array.shift(trendLines))
        if array.size(trendHighs) > 0
            array.shift(trendHighs)
        if array.size(trendHighIndices) > 0
            array.shift(trendHighIndices)
    while array.size(trendLows) > 20
        if array.size(trendLinesBear) > 0
            deleteLineSafe(array.shift(trendLinesBear))
        if array.size(trendLows) > 0
            array.shift(trendLows)
        if array.size(trendLowIndices) > 0
            array.shift(trendLowIndices)

fifoCleanupTemp() =>
    while array.size(tempBoxes) > tempMaxKeep * 2
        deleteBoxSafe(array.shift(tempBoxes))
    while array.size(tempLabels) > tempMaxKeep
        deleteLabelSafe(array.shift(tempLabels))

isLevelTouched(float level, int startIdx) =>
    bool touched = false
    int checkBars = bar_index - startIdx
    if checkBars > 0
        for i = 1 to checkBars
            int barOffset = bar_index - startIdx - i
            if barOffset >= 0
                if low[barOffset] <= level and high[barOffset] >= level
                    touched := true
                    break
    touched

getTouchIndex(float level, int startIdx) =>
    int touchIdx = -1
    int checkBars = bar_index - startIdx
    if checkBars > 0
        for i = 1 to checkBars
            int barOffset = bar_index - startIdx - i
            if barOffset >= 0
                if low[barOffset] <= level and high[barOffset] >= level
                    touchIdx := bar_index - barOffset
                    break
    touchIdx

drawHorizontalLine(price, idx, isHigh) =>
    if showHorizontal
        bool touched = isLevelTouched(price, idx)
        int touchIdx = getTouchIndex(price, idx)
        int endX = idx + horizontalExtend
        color lineColor = color.new(horizontalColor, 70)
        if touched and touchIdx > 0
            endX := touchIdx
            lineColor := color.new(color.red, 60)
        else
            lineColor := color.new(horizontalColor, 70)
        line hLine = line.new(
            x1=idx - 1, y1=price, x2=endX, y2=price,
            color=lineColor, width=horizontalWidth, style=line.style_solid)
        array.push(horizontalLines, hLine)
        array.push(horizontalTouchIdx, touchIdx)

drawWaveLine(currentPrice, currentIdx, currentType) =>
    if showWave and array.size(swingPrices) >= 2
        float prevPrice = array.get(swingPrices, array.size(swingPrices) - 2)
        int prevIdx = array.get(swingIndices, array.size(swingIndices) - 2)
        string prevType = array.get(swingTypes, array.size(swingTypes) - 2)
        bool shouldDraw = false
        if currentType == "high" and prevType == "low"
            shouldDraw := true
        else if currentType == "low" and prevType == "high"
            shouldDraw := true
        if shouldDraw
            line waveLine = line.new(
                x1=prevIdx, y1=prevPrice, x2=currentIdx, y2=currentPrice,
                color=color.new(waveColor, 80), width=waveWidth, style=line.style_solid)
            array.push(swingLines, waveLine)

// Swing High
if not na(swingHighPt)
    int idx = bar_index - swingLen
    float price = swingHighPt
    bool isDup = not na(lastSwingHighPrice) and math.abs(price - lastSwingHighPrice) <= swingTol
    if not isDup
        string lblTxt = showSwingVol ? shText + " (" + volText(volume[swingLen]) + ")" : shText
        label.new(idx, price, lblTxt, style=label.style_label_down, size=f_size(labelSize),
             color=color.new(highColor, 15), textcolor=color.white)
        array.push(swingPrices, price)
        array.push(swingIndices, idx)
        array.push(swingTypes, "high")
        drawWaveLine(price, idx, "high")
        drawHorizontalLine(price, idx, true)
        array.push(trendHighs, price)
        array.push(trendHighIndices, idx)
        lastSwingHighPrice := price

// Swing Low
if not na(swingLowPt)
    int idx = bar_index - swingLen
    float price = swingLowPt
    bool isDup = not na(lastSwingLowPrice) and math.abs(price - lastSwingLowPrice) <= swingTol
    if not isDup
        string lblTxt = showSwingVol ? slText + " (" + volText(volume[swingLen]) + ")" : slText
        label.new(idx, price, lblTxt, style=label.style_label_up, size=f_size(labelSize),
             color=color.new(lowColor, 15), textcolor=color.white)
        array.push(swingPrices, price)
        array.push(swingIndices, idx)
        array.push(swingTypes, "low")
        drawWaveLine(price, idx, "low")
        drawHorizontalLine(price, idx, false)
        array.push(trendLows, price)
        array.push(trendLowIndices, idx)
        lastSwingLowPrice := price

fifoCleanup()
fifoCleanupTrend()

// ═══════════════════════════ FVG Dual Flow ═══════════════════════════
fvgBullColor = color.new(fvgUpColor, fvgAlpha)
fvgBearColor = color.new(fvgDnColor, fvgAlpha)

float curBullVol = close > open ? volume : 0.0
float curBearVol = close < open ? volume : 0.0

// Bull FVG detection
if showFVG and low > high[2]
    float gapTop = low
    float gapBot = high[2]
    if gapTop - gapBot >= fvgMinSize
        box b = box.new(bar_index, gapTop, bar_index + fvgBoxWidth, gapBot,
                        border_color = fvgBorder ? color.new(fvgUpColor, 50) : na,
                        border_width = fvgBorder ? 1 : 0,
                        bgcolor = fvgBullColor, xloc = xloc.bar_index)
        array.push(bullFvgBoxes, b)
        int midX = bar_index + math.round(fvgBoxWidth / 2)
        float midY = (gapTop + gapBot) / 2
        lbl = label.new(midX, midY, bullFvgTxt(1),
                        style=label.style_none, textcolor=fvgUpColor,
                        size=f_size(fvgLabelSize), xloc=xloc.bar_index)
        array.push(bullFvgLabels, lbl)
        array.push(bullFvgStage, 1)
        array.push(bullFvgTop, gapTop)
        array.push(bullFvgBot, gapBot)
        array.push(bullFvgBar, bar_index)
        array.push(bullFvgBullVol, curBullVol)
        array.push(bullFvgBearVol, curBearVol)

// Bear FVG detection
if showFVG and high < low[2]
    float gapTop = low[2]
    float gapBot = high
    if gapTop - gapBot >= fvgMinSize
        box b = box.new(bar_index, gapTop, bar_index + fvgBoxWidth, gapBot,
                        border_color = fvgBorder ? color.new(fvgDnColor, 50) : na,
                        border_width = fvgBorder ? 1 : 0,
                        bgcolor = fvgBearColor, xloc = xloc.bar_index)
        array.push(bearFvgBoxes, b)
        int midX = bar_index + math.round(fvgBoxWidth / 2)
        float midY = (gapTop + gapBot) / 2
        lbl = label.new(midX, midY, bearFvgTxt(1),
                        style=label.style_none, textcolor=fvgDnColor,
                        size=f_size(fvgLabelSize), xloc=xloc.bar_index)
        array.push(bearFvgLabels, lbl)
        array.push(bearFvgStage, 1)
        array.push(bearFvgTop, gapTop)
        array.push(bearFvgBot, gapBot)
        array.push(bearFvgBar, bar_index)
        array.push(bearFvgBullVol, curBullVol)
        array.push(bearFvgBearVol, curBearVol)

// Bull FVG incremental update + stage advance
if showFVG and array.size(bullFvgStage) > 0
    int i = 0
    while i < array.size(bullFvgStage)
        int stage = array.get(bullFvgStage, i)
        float gTop = array.get(bullFvgTop, i)
        float gBot = array.get(bullFvgBot, i)
        int gBar = array.get(bullFvgBar, i)
        label lb = array.get(bullFvgLabels, i)

        if bar_index > gBar
            array.set(bullFvgBullVol, i, array.get(bullFvgBullVol, i) + curBullVol)
            array.set(bullFvgBearVol, i, array.get(bullFvgBearVol, i) + curBearVol)

            if stage == 1
                if low <= gTop
                    array.set(bullFvgStage, i, 2)
            else if stage == 2
                if close > gTop
                    array.set(bullFvgStage, i, 3)
            else if stage == 3
                if close < gTop
                    array.set(bullFvgStage, i, 4)
            else if stage == 4
                if low <= gBot
                    array.set(bullFvgStage, i, 5)
            else if stage == 5
                if close > gBot
                    array.set(bullFvgStage, i, 6)
            else if stage == 6
                if close > gTop
                    array.set(bullFvgStage, i, 7)
            else if stage == 7
                if close < gTop
                    array.set(bullFvgStage, i, 8)
            else if stage == 8
                if close < gBot
                    array.set(bullFvgStage, i, 9)
            else if stage == 9
                array.set(bullFvgStage, i, 1)

            int newStage = array.get(bullFvgStage, i)
            string baseTxt = bullFvgTxt(newStage)
            if showFvgLiq
                float bv = array.get(bullFvgBullVol, i)
                float sv = array.get(bullFvgBearVol, i)
                baseTxt := baseTxt + liqText(bv, sv)
            label.set_text(lb, baseTxt)
        i += 1

// Bear FVG incremental update + stage advance
if showFVG and array.size(bearFvgStage) > 0
    int i = 0
    while i < array.size(bearFvgStage)
        int stage = array.get(bearFvgStage, i)
        float gTop = array.get(bearFvgTop, i)
        float gBot = array.get(bearFvgBot, i)
        int gBar = array.get(bearFvgBar, i)
        label lb = array.get(bearFvgLabels, i)

        if bar_index > gBar
            array.set(bearFvgBullVol, i, array.get(bearFvgBullVol, i) + curBullVol)
            array.set(bearFvgBearVol, i, array.get(bearFvgBearVol, i) + curBearVol)

            if stage == 1
                if high >= gBot
                    array.set(bearFvgStage, i, 2)
            else if stage == 2
                if close < gBot
                    array.set(bearFvgStage, i, 3)
            else if stage == 3
                if close > gBot
                    array.set(bearFvgStage, i, 4)
            else if stage == 4
                if high >= gTop
                    array.set(bearFvgStage, i, 5)
            else if stage == 5
                if close < gTop
                    array.set(bearFvgStage, i, 6)
            else if stage == 6
                if close < gBot
                    array.set(bearFvgStage, i, 7)
            else if stage == 7
                if close > gBot
                    array.set(bearFvgStage, i, 8)
            else if stage == 8
                if close > gTop
                    array.set(bearFvgStage, i, 9)
            else if stage == 9
                array.set(bearFvgStage, i, 1)

            int newStage = array.get(bearFvgStage, i)
            string baseTxt = bearFvgTxt(newStage)
            if showFvgLiq
                float bv = array.get(bearFvgBullVol, i)
                float sv = array.get(bearFvgBearVol, i)
                baseTxt := baseTxt + liqText(bv, sv)
            label.set_text(lb, baseTxt)
        i += 1

// FVG cleanup + FIFO
if showFVG
    if array.size(bullFvgBoxes) > 0
        int i = 0
        while i < array.size(bullFvgBoxes)
            box b = array.get(bullFvgBoxes, i)
            int gBar = array.get(bullFvgBar, i)
            bool expired = fvgMaxAge > 0 and (bar_index - gBar) > fvgMaxAge
            if not na(b)
                if close < box.get_bottom(b) or expired
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
                        array.remove(bullFvgBullVol, i)
                        array.remove(bullFvgBearVol, i)
                else
                    i += 1
            else
                i += 1

    if array.size(bearFvgBoxes) > 0
        int i = 0
        while i < array.size(bearFvgBoxes)
            box b = array.get(bearFvgBoxes, i)
            int gBar = array.get(bearFvgBar, i)
            bool expired = fvgMaxAge > 0 and (bar_index - gBar) > fvgMaxAge
            if not na(b)
                if close > box.get_top(b) or expired
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
                        array.remove(bearFvgBullVol, i)
                        array.remove(bearFvgBearVol, i)
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
            array.shift(bullFvgBullVol)
            array.shift(bullFvgBearVol)

    while array.size(bearFvgBoxes) > fvgMaxKeep
        box.delete(array.shift(bearFvgBoxes))
        if array.size(bearFvgLabels) > 0
            label.delete(array.shift(bearFvgLabels))
            array.shift(bearFvgStage)
            array.shift(bearFvgTop)
            array.shift(bearFvgBot)
            array.shift(bearFvgBar)
            array.shift(bearFvgBullVol)
            array.shift(bearFvgBearVol)

// ═══════════════════════════ Thermometer ═══════════════════════════
tempTimeAsia = time(timeframe.period, tempSessionAsia, tempTZ)
tempTimeEU   = time(timeframe.period, tempSessionEU,   tempTZ)
tempTimeUS   = time(timeframe.period, tempSessionUS,   tempTZ)

isTempBarAsia = not na(tempTimeAsia)
isTempBarEU   = not na(tempTimeEU)
isTempBarUS   = not na(tempTimeUS)

atrAvg = ta.sma(atrTemp, tempLookback)

drawThermometer(bool isTrigger, color labelColor, string prefix) =>
    if showTemp and isTrigger and not na(atrTemp) and not na(atrAvg) and atrAvg > 0
        float ratio = math.min(atrTemp / atrAvg, 2.0) / 2.0
        ratio := math.max(ratio, 0.0)
        float baseY  = low - atrTemp * tempOffsetATR
        float topY   = baseY - atrTemp * tempHeightATR
        float fillY  = baseY - (baseY - topY) * ratio
        box bgBox = box.new(bar_index - 1, baseY, bar_index + 1, topY,
                            border_color = color.new(color.gray, 50),
                            border_width = 1,
                            bgcolor = color.new(color.gray, 85),
                            xloc = xloc.bar_index)
        array.push(tempBoxes, bgBox)
        box fillBox = box.new(bar_index - 1, baseY, bar_index + 1, fillY,
                              border_color = na, border_width = 0,
                              bgcolor = tempColor(ratio), xloc = xloc.bar_index)
        array.push(tempBoxes, fillBox)
        string txt = prefix + " " + str.tostring(ratio * 100, "#.#") + "%"
        label lb = label.new(bar_index, topY - atrTemp * 0.1, txt,
                             style = label.style_none, textcolor = labelColor,
                             size = f_size(tempLabelSize), xloc = xloc.bar_index)
        array.push(tempLabels, lb)

drawThermometer(isTempBarAsia, tempAsiaColor, "ASIA T")
drawThermometer(isTempBarEU,   tempEUColor,   "EU T")
drawThermometer(isTempBarUS,   tempUSColor,   "US T")

fifoCleanupTemp()
````
