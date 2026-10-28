# Structural Effort Targeting (MTF)

- url: https://www.tradingview.com/script/tcXSn2Ak-Structural-Effort-Targeting-MTF/
- type: indicator
- pine_id: PUB;1579a875c0454e9e81896275c25e9368
- version: 1.0

## Description

Structural Effort Targeting is a volume-driven target zone indicator designed to identify price levels that may continue to attract price due to prior high-effort market interaction.

Rather than plotting conventional support and resistance or generating entry signals, the script maps structurally significant target zones derived from historical price–volume behavior.

Core Concept

The framework is based on a simple idea:

Price often revisits zones where previous movement required unusually high relative effort.

Such zones may represent:
 • unfinished target areas
 • liquidity attraction zones
 • structural price objectives

Methodology

Relative Volume Effort Detection
The script identifies price interactions associated with elevated relative volume using configurable effort thresholds.

Target Zone Construction
Important levels are represented as zones rather than single lines, helping reflect real market interaction rather than overly precise levels.

Zone Clustering and Merge Logic
Nearby levels can be merged into higher-confluence target zones using configurable merge tolerances.

Nearest-Zone Selection Logic
Optional nearest-zone filtering can prioritize the most relevant structural targets around current price.

Multi-Timeframe Context
Target calculations may be sourced from higher timeframes while applied to lower execution charts.

Intended Use

This indicator is designed to support discretionary traders in:
 • mapping potential price objectives
 • identifying structural confluence
 • planning targets using volume and liquidity context
 • complementing market structure analysis

This indicator represents targets, not trade signals.

This script may also be used alongside companion regime-filter tools for broader market-structure context.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © danilita247

//@version=5
indicator("Structural Effort Targeting (MTF)", overlay=true, max_boxes_count=500, max_labels_count=50)

//========================
// Inputs
//========================

grpCalc = "Calculation (Timeframe Source)"
tfInput   = input.timeframe("", "Timeframe", group=grpCalc)   // "" = Chart
waitClose = input.bool(true, "Wait for timeframe close", group=grpCalc)

// Effective timeframe to use
tfCalc = (tfInput == "" ? timeframe.period : tfInput)

grpEffort = "Effort (Volume % over N)"
nVol   = input.int(300, "Lookback N", minval=20, group=grpEffort)
pVol   = input.float(90.0, "Target Volume Percentile (%)", minval=50, maxval=99.9, step=0.1, group=grpEffort)

grpZones = "Zones (Targets)"
atrLen = input.int(14, "ATR Length", minval=1, group=grpZones)
atrK   = input.float(0.005, "Zone Thickness = ATR * K", minval=0.001, step=0.0002, group=grpZones)
mergeK = input.float(0.10, "Merge Tolerance = ZoneThickness * K", minval=0.05, step=0.05, group=grpZones)
maxZones = input.int(200, "Max zones to keep", minval=50, maxval=450, group=grpZones)

grpView = "View: Current Moment (Nearest zones)"
nearestMode = input.string("Off", "Nearest mode", options=["Off","Top-K by strength","Recent touches"], group=grpView)
topK = input.int(25, "Top-K per side (above & below)", minval=1, maxval=25, group=grpView)
recentBars = input.int(5000, "Recent touches lookback (bars)", minval=10, maxval=5000, group=grpView)
capRecent = input.int(200, "Cap zones shown (Recent touches)", minval=5, maxval=200, group=grpView)
minStrengthToShow = input.int(1, "Min strength to show", minval = 1, maxval = 50,group = grpView)

grpColors = "Colors"
showHistory = input.bool(true, "Show History zones", group=grpColors)
histBaseCol = input.color(color.new(color.silver, 0), "History base color", group=grpColors)
histMinAlpha = input.int(94, "History min opacity (0-100)", minval=0, maxval=100, group=grpColors)

showFuture = input.bool(true, "Show zones above/below current price", group=grpColors)
aboveBaseCol = input.color(color.new(color.red, 0), "Above price base color", group=grpColors)
belowBaseCol = input.color(color.new(color.lime, 0), "Below price base color", group=grpColors)
futureMinAlpha = input.int(65, "Above/Below min opacity (0-100)", minval=0, maxval=100, group=grpColors)

grpStats = "Statistics"
showStats = input.bool(true, "Show stats table", group=grpStats)
touchLookback = input.int(1000, "Touches lookback (bars)", minval=10, maxval=5000, group=grpStats)
activeLookback = input.int(200, "Active zones lookback (bars)", minval=10, maxval=5000, group=grpStats)

// === HTF/LTF source series (based on tfCalc) ===
htfTime  = request.security(syminfo.tickerid, tfCalc, time,   barmerge.gaps_off, barmerge.lookahead_off)
htfHigh  = request.security(syminfo.tickerid, tfCalc, high,   barmerge.gaps_off, barmerge.lookahead_off)
htfLow   = request.security(syminfo.tickerid, tfCalc, low,    barmerge.gaps_off, barmerge.lookahead_off)
htfClose = request.security(syminfo.tickerid, tfCalc, close,  barmerge.gaps_off, barmerge.lookahead_off)
htfVol   = request.security(syminfo.tickerid, tfCalc, volume, barmerge.gaps_off, barmerge.lookahead_off)
htfATR   = request.security(syminfo.tickerid, tfCalc, ta.atr(atrLen), barmerge.gaps_off, barmerge.lookahead_off)

// Новый бар выбранного TF?
isNewTFbar = ta.change(htfTime)

// Если стоит waitClose, то работаем только когда HTF-бар уже “закрыт”.
// В LTF это обычно означает: действуем на первом баре нового HTF-бара, используя значения предыдущего.
doUpdate = waitClose ? isNewTFbar : true

//========================
// Helpers
//========================
f_clamp(x, a, b) =>
    math.max(a, math.min(b, x))

f_colorGradient(strNorm, baseCol, minAlpha) =>
    a = math.round(minAlpha - (minAlpha * f_clamp(strNorm, 0.0, 1.0)))  // strong => smaller alpha
    color.new(baseCol, int(f_clamp(a, 0, 100)))

// Percent rank (0..100)
f_percentRank(src, len) =>
    float cnt = 0.0
    for i = 0 to len - 1
        cnt += src[i] <= src ? 1.0 : 0.0
    100.0 * cnt / len

// Inserts idx into a "top list" by strength (descending), capped to cap.
// listIdx: array<int>, listS: array<float>
f_pushTop(listIdx, listS, idx, s, cap) =>
    int pos = array.size(listS)
    // find insert position
    for i = 0 to array.size(listS) - 1
        if s > array.get(listS, i)
            pos := i
            break
    array.insert(listIdx, pos, idx)
    array.insert(listS, pos, s)
    // trim
    while array.size(listS) > cap
        array.pop(listS)
        array.pop(listIdx)

//========================
// State (arrays of zones)
//========================
var centers   = array.new_float()
var strengths = array.new_float()
var halfW     = array.new_float()
var lastTouch = array.new_int()
var boxes     = array.new_box()

// counters
var int effortEvents = 0

atr = ta.atr(atrLen)
zoneHalf = atr * atrK * 0.5
mergeTol = (atr * atrK) * mergeK

//========================
// Effort event (MTF-aware)
//========================
volRank  = bar_index > nVol ? f_percentRank(htfVol, nVol) : na
isEffort = not na(volRank) and volRank >= pVol

newCenter = (htfHigh + htfLow + htfClose) / 3.0

// ВАЖНО: zoneHalf тоже должен быть из HTF ATR (если у тебя он считается где-то выше)
// Например: zoneHalf = (htfATR * atrK) * 0.5   (если у тебя так задумано)

//========================
// Insert / merge zone on effort
//========================
if doUpdate and isEffort
    effortEvents += 1

    float c  = na
    float st = na
    float c2 = na

    int hitIdx = -1

    if hitIdx != -1
        c  := array.get(centers, hitIdx)
        st := array.get(strengths, hitIdx)
        c2 := (c * st + newCenter) / (st + 1.0)
        array.set(centers, hitIdx, c2)
        array.set(strengths, hitIdx, st + 1.0)
        array.set(halfW, hitIdx, zoneHalf)
    else
        array.push(centers, newCenter)
        array.push(strengths, 1.0)
        array.push(halfW, zoneHalf)
        array.push(lastTouch, bar_index)
        b = box.new(bar_index, newCenter + zoneHalf, bar_index, newCenter - zoneHalf, border_width=0)
        array.push(boxes, b)

        // trim weakest if too many
        while array.size(centers) > maxZones
            int weakI = 0
            float weakS = array.get(strengths, 0)
            for z = 1 to array.size(strengths) - 1
                s = array.get(strengths, z)
                if s < weakS
                    weakS := s
                    weakI := z
            box.delete(array.get(boxes, weakI))
            array.remove(centers, weakI)
            array.remove(strengths, weakI)
            array.remove(halfW, weakI)
            array.remove(lastTouch, weakI)
            array.remove(boxes, weakI)
            
//========================
// Touch detection
//========================
int n = array.size(centers)
if n > 0
    for z = 0 to n - 1
        float c  = array.get(centers, z)
        float hw = array.get(halfW, z)
        bool touched = (high >= c - hw) and (low <= c + hw)
        if touched
            array.set(lastTouch, z, bar_index)

//========================
// Build "zones to show" list for Current Moment (SAFE)
//========================
var showIdx = array.new_int()
array.clear(showIdx)

// safe sizes (arrays may temporarily diverge)
int nC_show = array.size(centers)
int nS_show = array.size(strengths)
int nT_show = array.size(lastTouch)
int nShowR = math.min(nC_show, math.min(nS_show, nT_show))

if nShowR > 0
    if nearestMode == "Off"
        for z = 0 to nShowR - 1
            array.push(showIdx, z)

    else if nearestMode == "Top-K by strength"
        var topAboveIdx = array.new_int()
        var topAboveS   = array.new_float()
        var topBelowIdx = array.new_int()
        var topBelowS   = array.new_float()
        var int nShowR = 0
        array.clear(topAboveIdx), array.clear(topAboveS)
        array.clear(topBelowIdx), array.clear(topBelowS)

        for z = 0 to nShowR - 1
            float c0 = array.get(centers, z)
            float s0 = array.get(strengths, z)
            if c0 > close
                f_pushTop(topAboveIdx, topAboveS, z, s0, topK)
            else
                f_pushTop(topBelowIdx, topBelowS, z, s0, topK)

        int nAbove = array.size(topAboveIdx)
        if nAbove > 0
            for i = 0 to nAbove - 1
                array.push(showIdx, array.get(topAboveIdx, i))

        int nBelow2 = array.size(topBelowIdx)
        if nBelow2 > 0
            for i = 0 to nBelow2 - 1
                array.push(showIdx, array.get(topBelowIdx, i))

    else
        int added = 0
        for z = 0 to nShowR - 1
            int lt = array.get(lastTouch, z)
            if (bar_index - lt) <= recentBars
                array.push(showIdx, z)
                added += 1
                if added >= capRecent
                    break
//========================
// Render
//========================
// --- calculate max strength safely ---
float maxS = 1.0
int nStr = array.size(strengths)
if nStr > 0
    for i = 0 to nStr - 1
        maxS := math.max(maxS, array.get(strengths, i))

// --- hide all zones by default ---
int nBox = array.size(boxes)
if nBox > 0
    for i = 0 to nBox - 1
        box b0 = array.get(boxes, i)
        box.set_bgcolor(b0, color.new(color.gray, 100))
        box.set_border_color(b0, color.new(color.gray, 100))
        box.set_extend(b0, extend.none)

// --- draw selected zones ---
int nShow = array.size(showIdx)
int nC = array.size(centers)
int nS = array.size(strengths)
int nW = array.size(halfW)
int nT = array.size(lastTouch)
int nB2 = array.size(boxes)

// общий безопасный лимит
int nAll = math.min(nC, math.min(nS, math.min(nW, math.min(nT, nB2))))

if nShowR > 0 and nAll > 0
    for k = 0 to nShowR - 1
        int z = array.get(showIdx, k)

        // защита от рассинхрона индексов
        if z >= 0 and z < nAll
            float st = array.get(strengths, z)
            if st >= minStrengthToShow
                box b = array.get(boxes, z)

             // opacity
                bool isAbove = array.get(centers, z) > close
                color baseCol = isAbove ? aboveBaseCol : belowBaseCol
                int alpha = futureMinAlpha

                box.set_bgcolor(b, color.new(baseCol, alpha))
                box.set_border_color(b, color.new(baseCol, alpha))
                box.set_extend(b, extend.right)

//========================
// Statistics table (no signals)
//========================
var table t = na
if showStats and na(t)
    t := table.new(position.top_right, 2, 6, border_width=1)

if showStats and barstate.islast
    int zonesCount = array.size(centers)

    int touchesN = 0
    int activeN  = 0
    float activeStrengthSum = 0.0

    for z = 0 to zonesCount - 1
        lt = array.get(lastTouch, z)
        if (bar_index - lt) <= touchLookback
            touchesN += 1
        if (bar_index - lt) <= activeLookback
            activeN += 1
            activeStrengthSum += array.get(strengths, z)

    float activeAvgStrength = activeN > 0 ? (activeStrengthSum / activeN) : na

    table.cell(t, 0, 0, "Zones", text_color=color.white)
    table.cell(t, 1, 0, str.tostring(zonesCount), text_color=color.white)

    table.cell(t, 0, 1, "Effort events", text_color=color.white)
    table.cell(t, 1, 1, str.tostring(effortEvents), text_color=color.white)

    table.cell(t, 0, 2, "Touches (last N)", text_color=color.white)
    table.cell(t, 1, 2, str.tostring(touchesN) + "  (N=" + str.tostring(touchLookback) + ")", text_color=color.white)

    table.cell(t, 0, 3, "Active zones", text_color=color.white)
    table.cell(t, 1, 3, str.tostring(activeN) + "  (N=" + str.tostring(activeLookback) + ")", text_color=color.white)

    table.cell(t, 0, 4, "Active avg strength", text_color=color.white)
    table.cell(t, 1, 4, na(activeAvgStrength) ? "na" : str.tostring(activeAvgStrength, format.mintick), text_color=color.white)

    table.cell(t, 0, 5, "Nearest mode", text_color=color.white)
    table.cell(t, 1, 5, nearestMode, text_color=color.white)
````
