<!-- tradingview-pine-id: PUB;c72ab512bcf045f5acf35bc1c4f6eeff -->
<!-- tradingviewscripts-format: 1 -->
# Future Swing • Adaptive Target-Hit Timing TEST

Source: https://www.tradingview.com/script/pQf7pSTF-Future-Swing-Target-FST-ZeroEmotionTrading/

## Description

This indicator is based on the original *Future Swing* concept by **BigBeluga**, with enhancements focused on swing-distance tracking, adaptive timing, and forward projection analysis.

The original script provides swing-based forecasting using confirmed pivot structure and historical swing behavior.  
The modified version extends that foundation by adding:

- **Average bar-distance analysis** between pivots, so projected swing timing is not only price-based but also informed by how long swings typically take.
- **Adaptive future projection timing**, using historical target-hit behavior and/or average pivot duration to estimate how many bars a projected move may take.
- **Tracking of previously completed swing targets**, including whether targets were successfully reached and how many bars each prior target took to complete.
- **Forward multi-pivot forecasting**, allowing the script to project multiple future swings in sequence using current historical averages — for example: current direction → opposite direction → current direction again.

This makes the indicator useful not only for estimating the next likely swing distance, but also for visualizing the probable push/pullback structure ahead based on historical swing behavior.

**Attribution**
Original concept and script by **BigBeluga**.  
Enhanced and modified with adaptive timing, prior target-hit tracking, and chained future swing projections.

---

## Source Code

````pine
//@version=6
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// Original concept © BigBeluga
// Adaptive target-hit timing test version
// Original script by: BigBeluga
// Enhanced & Modified by: ZeroEmotion.IndiLab

indicator("Future Swing • Adaptive Target-Hit Timing TEST", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500, max_bars_back=5000)

// INPUTS ---------------------------------------------------------------------
len = input.int(50, "Pivot Length", minval=10)
dataqty = input.int(5, "Historical Swing Samples", minval=3, maxval=20)
calcType = input.string("Average", "Swing Projection Method", options=["Average", "Median", "Mode"])
fallbackBars = input.int(10, "Fallback Bars", minval=1)
timingSamples = input.int(5, "Target-Hit Timing Samples", minval=1, maxval=20)
timingMethod = input.string("EMA", "Target Timing Method", options=["Average", "Median", "EMA"])
recentWeight = input.float(0.50, "EMA Recent-Hit Weight", minval=0.05, maxval=1.00, step=0.05)

showGhost = input.bool(true, "Show Current Forecasts")
ghostShowMode = input.string("Both", "Current Forecast Mode", options=["Both", "Current Leg Only", "Short Only (Ghost High)", "Long Only (Ghost Low)"])
showPivotForecast = input.bool(false, "Show Last Confirmed Pivot Forecast")
showFutureForecast = input.bool(true, "Show Multi-Pivot Future Forecast")
futurePivotCount = input.int(3, "Future Pivots To Show", minval=1, maxval=10)
showPrevForecasts = input.bool(true, "Show Completed Hit Forecasts")
prevForecastCount = input.int(5, "Completed Forecasts To Show", minval=1, maxval=50)

postion_d = input.string("Bottom Right", "Dashboard Position", options=["Middle Right", "Top Center", "Top Right", "Top Left", "Middle Left", "Middle Center", "Bottom Left", "Bottom Center", "Bottom Right"])
sizeData = input.string("Normal", "Dashboard Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"])
extendR = input.bool(false, "Extend Swing Zones Forward")
colorBull = input.color(color.rgb(21, 221, 124), "Bull Color", inline="c")
colorBear = input.color(color.rgb(235, 117, 20), "Bear Color", inline="c")

DataSize = switch sizeData
    "Tiny" => size.tiny
    "Small" => size.small
    "Normal" => size.normal
    "Large" => size.large
    => size.huge

dashPosition = switch postion_d
    "Middle Right" => position.middle_right
    "Middle Left" => position.middle_left
    "Middle Center" => position.middle_center
    "Top Right" => position.top_right
    "Top Center" => position.top_center
    "Top Left" => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Center" => position.bottom_center
    => position.bottom_left

// TYPES ----------------------------------------------------------------------
type swingD
    float val
    int indx

// PIVOT AND SWING STATE -------------------------------------------------------
var swingD lastPivot = swingD.new(na, na)
var swingD hSwing = swingD.new(na, na)
var swingD lSwing = swingD.new(na, na)

var int lastType = 0

var float[] swingPC = array.new_float()
var float[] upPivotDur = array.new_float()
var float[] downPivotDur = array.new_float()

// ACTUAL TIME-TO-TARGET SAMPLES ----------------------------------------------
var float[] upHitDur = array.new_float()
var float[] downHitDur = array.new_float()

var int lastUpHitBars = na
var int lastDownHitBars = na

// VISUAL STATE ---------------------------------------------------------------
var line[] legLines = array.new_line()
var box swingUpper = na
var box swingLower = na

var float ghostHighVal = na
var int ghostHighIndx = na
var float ghostLowVal = na
var int ghostLowIndx = na

var line ghostHighLine = na
var label ghostHighLbl = na
var line ghostLowLine = na
var label ghostLowLbl = na

var line pivotLine = na
var label pivotLbl = na

var line[] futureShortLines = array.new_line()
var label[] futureShortLabels = array.new_label()
var line[] futureLongLines = array.new_line()
var label[] futureLongLabels = array.new_label()

var line[] prevFCLines = array.new_line()
var label[] prevFCLabels = array.new_label()

// ACTIVE SHORT TARGET STATE --------------------------------------------------
var float shortAnchorVal = na
var int shortAnchorIdx = na
var float shortTargetPct = na
var float shortTargetVal = na
var int shortExpectedBars = na
var bool shortTargetHit = false
var int shortHitIdx = na
var int shortHitBars = na

// ACTIVE LONG TARGET STATE ---------------------------------------------------
var float longAnchorVal = na
var int longAnchorIdx = na
var float longTargetPct = na
var float longTargetVal = na
var int longExpectedBars = na
var bool longTargetHit = false
var int longHitIdx = na
var int longHitBars = na

// CORE SERIES ----------------------------------------------------------------
atr = ta.atr(200) * 0.5
ph = ta.pivothigh(len, len)
pl = ta.pivotlow(len, len)

// HELPERS --------------------------------------------------------------------
f_calc(float[] a) =>
    int sz = array.size(a)
    sz > 0 ? (calcType == "Average" ? array.avg(a) : calcType == "Median" ? array.median(a) : array.mode(a)) : na

f_clampBars(float x) =>
    int result = int(math.round(x))
    result < 1 ? 1 : result

f_timing(float[] a) =>
    float result = na
    int asz = array.size(a)
    if asz > 0
        if timingMethod == "Average"
            result := array.avg(a)
        else if timingMethod == "Median"
            result := array.median(a)
        else
            if asz > 0
                for i = 0 to asz - 1
                    value = array.get(a, i)
                    result := na(result) ? value : result + recentWeight * (value - result)
    result

// CONFIRMED PIVOT HIGH --------------------------------------------------------
if not na(ph)
    pIndx = bar_index - len
    pVal = ph

    if lastType == 0
        lastType := 1
        lastPivot.indx := pIndx
        lastPivot.val := pVal
        ghostHighVal := pVal
        ghostHighIndx := pIndx
        ghostLowVal := low[len]
        ghostLowIndx := pIndx
        hSwing.indx := pIndx
        hSwing.val := pVal

    else if lastType == 1
        if pVal >= lastPivot.val
            lastPivot.indx := pIndx
            lastPivot.val := pVal
            ghostHighVal := pVal
            ghostHighIndx := pIndx
            ghostLowVal := low[len]
            ghostLowIndx := pIndx
            hSwing.indx := pIndx
            hSwing.val := pVal

    else
        lSwing.indx := lastPivot.indx
        lSwing.val := lastPivot.val
        hSwing.indx := pIndx
        hSwing.val := pVal

        pcUp = (hSwing.val - lSwing.val) / lSwing.val * 100.0
        durUp = float(hSwing.indx - lSwing.indx)

        array.push(swingPC, pcUp)
        array.push(upPivotDur, durUp)

        while array.size(swingPC) > dataqty
            array.shift(swingPC)

        while array.size(upPivotDur) > dataqty
            array.shift(upPivotDur)

        newLeg = line.new(lSwing.indx, lSwing.val, hSwing.indx, hSwing.val, color=colorBull, width=2)
        array.push(legLines, newLeg)

        if array.size(legLines) > 200
            line.delete(array.shift(legLines))

        if not na(swingUpper)
            box.delete(swingUpper)

        if not na(swingLower)
            box.delete(swingLower)

        swingUpper := box.new(hSwing.indx, hSwing.val, hSwing.indx + fallbackBars, hSwing.val + atr, border_color=colorBear, border_width=1, bgcolor=color.new(colorBear, 80), text_halign=text.align_right, text_color=color.new(chart.fg_color, 10), text_size=DataSize)
        swingLower := box.new(lSwing.indx, lSwing.val, lSwing.indx + fallbackBars, lSwing.val - atr, border_color=colorBull, border_width=1, bgcolor=color.new(colorBull, 80), text_halign=text.align_right, text_color=color.new(chart.fg_color, 10), text_size=DataSize)

        lastType := 1
        lastPivot.indx := pIndx
        lastPivot.val := pVal
        ghostHighVal := pVal
        ghostHighIndx := pIndx
        ghostLowVal := low[len]
        ghostLowIndx := pIndx

// CONFIRMED PIVOT LOW ---------------------------------------------------------
if not na(pl)
    pIndx = bar_index - len
    pVal = pl

    if lastType == 0
        lastType := -1
        lastPivot.indx := pIndx
        lastPivot.val := pVal
        ghostLowVal := pVal
        ghostLowIndx := pIndx
        ghostHighVal := high[len]
        ghostHighIndx := pIndx
        lSwing.indx := pIndx
        lSwing.val := pVal

    else if lastType == -1
        if pVal <= lastPivot.val
            lastPivot.indx := pIndx
            lastPivot.val := pVal
            ghostLowVal := pVal
            ghostLowIndx := pIndx
            ghostHighVal := high[len]
            ghostHighIndx := pIndx
            lSwing.indx := pIndx
            lSwing.val := pVal

    else
        hSwing.indx := lastPivot.indx
        hSwing.val := lastPivot.val
        lSwing.indx := pIndx
        lSwing.val := pVal

        pcDn = (lSwing.val - hSwing.val) / hSwing.val * 100.0
        durDn = float(lSwing.indx - hSwing.indx)

        array.push(swingPC, pcDn)
        array.push(downPivotDur, durDn)

        while array.size(swingPC) > dataqty
            array.shift(swingPC)

        while array.size(downPivotDur) > dataqty
            array.shift(downPivotDur)

        newLeg = line.new(hSwing.indx, hSwing.val, lSwing.indx, lSwing.val, color=colorBear, width=2)
        array.push(legLines, newLeg)

        if array.size(legLines) > 200
            line.delete(array.shift(legLines))

        if not na(swingUpper)
            box.delete(swingUpper)

        if not na(swingLower)
            box.delete(swingLower)

        swingUpper := box.new(hSwing.indx, hSwing.val, hSwing.indx + fallbackBars, hSwing.val + atr, border_color=colorBear, border_width=1, bgcolor=color.new(colorBear, 80), text_halign=text.align_right, text_color=color.new(chart.fg_color, 10), text_size=DataSize)
        swingLower := box.new(lSwing.indx, lSwing.val, lSwing.indx + fallbackBars, lSwing.val - atr, border_color=colorBull, border_width=1, bgcolor=color.new(colorBull, 80), text_halign=text.align_right, text_color=color.new(chart.fg_color, 10), text_size=DataSize)

        lastType := -1
        lastPivot.indx := pIndx
        lastPivot.val := pVal
        ghostLowVal := pVal
        ghostLowIndx := pIndx
        ghostHighVal := high[len]
        ghostHighIndx := pIndx

// LIVE GHOST EXTREMES ---------------------------------------------------------
if lastType == -1
    if na(ghostHighVal)
        ghostHighVal := high
        ghostHighIndx := bar_index

    if high >= ghostHighVal
        ghostHighVal := high
        ghostHighIndx := bar_index

if lastType == 1
    if na(ghostLowVal)
        ghostLowVal := low
        ghostLowIndx := bar_index

    if low <= ghostLowVal
        ghostLowVal := low
        ghostLowIndx := bar_index

// CURRENT SWING STATISTICS ----------------------------------------------------
absSwingNow = array.new_float()
upSwingNow = array.new_float()
downSwingNow = array.new_float()

int swingPCSize = array.size(swingPC)
if swingPCSize > 0
    for i = 0 to swingPCSize - 1
        value = array.get(swingPC, i)
        array.push(absSwingNow, math.abs(value))

        if value >= 0
            array.push(upSwingNow, value)
        else
            array.push(downSwingNow, math.abs(value))

allValNow = f_calc(absSwingNow)
upValNow = f_calc(upSwingNow)
downValNow = f_calc(downSwingNow)

upPivotAvgNow = f_calc(upPivotDur)
downPivotAvgNow = f_calc(downPivotDur)

upPivotBarsNow = na(upPivotAvgNow) ? fallbackBars : f_clampBars(upPivotAvgNow)
downPivotBarsNow = na(downPivotAvgNow) ? fallbackBars : f_clampBars(downPivotAvgNow)

upHitTimingBefore = f_timing(upHitDur)
downHitTimingBefore = f_timing(downHitDur)

upProjectionBarsBefore = na(upHitTimingBefore) ? upPivotBarsNow : f_clampBars(upHitTimingBefore)
downProjectionBarsBefore = na(downHitTimingBefore) ? downPivotBarsNow : f_clampBars(downHitTimingBefore)

useUpSwingNow = na(upValNow) ? allValNow : upValNow
useDownSwingNow = na(downValNow) ? allValNow : downValNow

// DETECT NEW SHORT ANCHOR -----------------------------------------------------
shortAnchorChanged = false

if not na(ghostHighIndx)
    shortAnchorChanged := na(shortAnchorIdx) ? true : ghostHighIndx != shortAnchorIdx or ghostHighVal != shortAnchorVal

shortNeedsReset = shortAnchorChanged or (not na(ghostHighIndx) and na(shortTargetVal) and not na(useDownSwingNow))

if shortNeedsReset
    if shortTargetHit and showPrevForecasts and not na(shortAnchorIdx) and not na(shortAnchorVal) and not na(shortTargetVal) and not na(shortHitIdx)
        completedShortLine = line.new(shortAnchorIdx, shortAnchorVal, shortHitIdx, shortTargetVal, color=color.new(colorBear, 15), style=line.style_dashed)
        completedShortLabel = label.new(shortHitIdx, shortTargetVal, "-" + str.tostring(shortTargetPct, format.percent) + " • HIT " + str.tostring(shortHitBars) + "b", style=label.style_label_left, color=color.new(colorBear, 88), textcolor=chart.fg_color, size=DataSize)
        array.push(prevFCLines, completedShortLine)
        array.push(prevFCLabels, completedShortLabel)

        while array.size(prevFCLines) > prevForecastCount
            line.delete(array.shift(prevFCLines))

        while array.size(prevFCLabels) > prevForecastCount
            label.delete(array.shift(prevFCLabels))

    shortAnchorVal := ghostHighVal
    shortAnchorIdx := ghostHighIndx
    shortTargetPct := useDownSwingNow
    shortTargetVal := not na(shortTargetPct) ? shortAnchorVal - shortAnchorVal * shortTargetPct / 100.0 : na
    shortExpectedBars := downProjectionBarsBefore
    shortTargetHit := false
    shortHitIdx := na
    shortHitBars := na

    if not na(shortTargetVal)
        shortLookback = int(math.min(bar_index - shortAnchorIdx, 4999))

        if shortLookback > 0
            shortFound = false

            for k = 1 to shortLookback
                historyOffset = shortLookback - k

                if not shortFound and low[historyOffset] <= shortTargetVal
                    shortHitIdx := bar_index - historyOffset
                    shortHitBars := shortHitIdx - shortAnchorIdx
                    shortTargetHit := true
                    shortFound := true

            if shortTargetHit and shortHitBars > 0
                array.push(downHitDur, float(shortHitBars))
                lastDownHitBars := shortHitBars

                while array.size(downHitDur) > timingSamples
                    array.shift(downHitDur)

// DETECT NEW LONG ANCHOR ------------------------------------------------------
longAnchorChanged = false

if not na(ghostLowIndx)
    longAnchorChanged := na(longAnchorIdx) ? true : ghostLowIndx != longAnchorIdx or ghostLowVal != longAnchorVal

longNeedsReset = longAnchorChanged or (not na(ghostLowIndx) and na(longTargetVal) and not na(useUpSwingNow))

if longNeedsReset
    if longTargetHit and showPrevForecasts and not na(longAnchorIdx) and not na(longAnchorVal) and not na(longTargetVal) and not na(longHitIdx)
        completedLongLine = line.new(longAnchorIdx, longAnchorVal, longHitIdx, longTargetVal, color=color.new(colorBull, 15), style=line.style_dashed)
        completedLongLabel = label.new(longHitIdx, longTargetVal, "+" + str.tostring(longTargetPct, format.percent) + " • HIT " + str.tostring(longHitBars) + "b", style=label.style_label_left, color=color.new(colorBull, 88), textcolor=chart.fg_color, size=DataSize)
        array.push(prevFCLines, completedLongLine)
        array.push(prevFCLabels, completedLongLabel)

        while array.size(prevFCLines) > prevForecastCount
            line.delete(array.shift(prevFCLines))

        while array.size(prevFCLabels) > prevForecastCount
            label.delete(array.shift(prevFCLabels))

    longAnchorVal := ghostLowVal
    longAnchorIdx := ghostLowIndx
    longTargetPct := useUpSwingNow
    longTargetVal := not na(longTargetPct) ? longAnchorVal + longAnchorVal * longTargetPct / 100.0 : na
    longExpectedBars := upProjectionBarsBefore
    longTargetHit := false
    longHitIdx := na
    longHitBars := na

    if not na(longTargetVal)
        longLookback = int(math.min(bar_index - longAnchorIdx, 4999))

        if longLookback > 0
            longFound = false

            for k = 1 to longLookback
                historyOffset = longLookback - k

                if not longFound and high[historyOffset] >= longTargetVal
                    longHitIdx := bar_index - historyOffset
                    longHitBars := longHitIdx - longAnchorIdx
                    longTargetHit := true
                    longFound := true

            if longTargetHit and longHitBars > 0
                array.push(upHitDur, float(longHitBars))
                lastUpHitBars := longHitBars

                while array.size(upHitDur) > timingSamples
                    array.shift(upHitDur)

// LIVE SHORT TARGET HIT -------------------------------------------------------
if not shortTargetHit and not na(shortTargetVal) and not na(shortAnchorIdx) and bar_index > shortAnchorIdx and low <= shortTargetVal
    shortTargetHit := true
    shortHitIdx := bar_index
    shortHitBars := bar_index - shortAnchorIdx
    array.push(downHitDur, float(shortHitBars))
    lastDownHitBars := shortHitBars

    while array.size(downHitDur) > timingSamples
        array.shift(downHitDur)

// LIVE LONG TARGET HIT --------------------------------------------------------
if not longTargetHit and not na(longTargetVal) and not na(longAnchorIdx) and bar_index > longAnchorIdx and high >= longTargetVal
    longTargetHit := true
    longHitIdx := bar_index
    longHitBars := bar_index - longAnchorIdx
    array.push(upHitDur, float(longHitBars))
    lastUpHitBars := longHitBars

    while array.size(upHitDur) > timingSamples
        array.shift(upHitDur)

// UPDATED ADAPTIVE TIMING -----------------------------------------------------
upHitTimingNow = f_timing(upHitDur)
downHitTimingNow = f_timing(downHitDur)

upProjectionBarsNow = na(upHitTimingNow) ? upPivotBarsNow : f_clampBars(upHitTimingNow)
downProjectionBarsNow = na(downHitTimingNow) ? downPivotBarsNow : f_clampBars(downHitTimingNow)

upTimingSource = array.size(upHitDur) > 0 ? "Target hits" : "Pivot fallback"
downTimingSource = array.size(downHitDur) > 0 ? "Target hits" : "Pivot fallback"

// VOLUME BOX INFORMATION -----------------------------------------------------
buyVol = array.new_float()
sellVol = array.new_float()

hasSwings = not na(hSwing.indx) and not na(lSwing.indx) and not na(hSwing.val) and not na(lSwing.val)

if barstate.islast and hasSwings
    lowerIndex = math.min(hSwing.indx, lSwing.indx)
    volumeLookback = int(math.min(bar_index - lowerIndex, 4999))

    if volumeLookback >= 0
        for i = 0 to volumeLookback
            if close[i] > open[i]
                array.push(buyVol, volume[i])
            else
                array.push(sellVol, volume[i])

buySum = array.size(buyVol) > 0 ? array.sum(buyVol) : 0.0
sellSum = array.size(sellVol) > 0 ? array.sum(sellVol) : 0.0

if not na(swingUpper)
    box.set_text(swingUpper, str.tostring(hSwing.val) + "🔺\n-" + str.tostring(sellSum, format.volume) + "🔻")

if not na(swingLower)
    box.set_text(swingLower, str.tostring(lSwing.val) + "🔻\n+" + str.tostring(buySum, format.volume) + "🔺")

if extendR and not na(swingLower)
    box.set_extend(swingLower, extend.right)

if extendR and not na(swingUpper)
    box.set_extend(swingUpper, extend.right)

// DASHBOARD ------------------------------------------------------------------
var table dash = table.new(dashPosition, 2, 50, bgcolor=chart.bg_color)

if barstate.islast
    if not showPrevForecasts
        while array.size(prevFCLines) > 0
            line.delete(array.pop(prevFCLines))

        while array.size(prevFCLabels) > 0
            label.delete(array.pop(prevFCLabels))

    if showPrevForecasts
        while array.size(prevFCLines) > prevForecastCount
            line.delete(array.shift(prevFCLines))

        while array.size(prevFCLabels) > prevForecastCount
            label.delete(array.shift(prevFCLabels))

    table.clear(dash, 0, 0, 1, 49)

    int swingPCSizeD = array.size(swingPC)
    if swingPCSizeD > 0
        for i = 0 to swingPCSizeD - 1
            value = array.get(swingPC, i)
            swingColor = swingPCSizeD == 1 ? colorBull : color.from_gradient(i, 0, swingPCSizeD - 1, colorBear, colorBull)
            table.cell(dash, 0, i, "Swing " + str.tostring(i + 1), text_color=swingColor, text_size=DataSize)
            table.cell(dash, 1, i, str.tostring(value, format.percent), text_color=swingColor, text_size=DataSize)

    upN = array.size(upSwingNow)
    downN = array.size(downSwingNow)
    ratio = not na(upValNow) and not na(downValNow) and downValNow != 0 ? upValNow / downValNow : na
    biasDelta = not na(upValNow) and not na(downValNow) ? upValNow - downValNow : na

    regime = "Insufficient"

    if not na(upValNow) and not na(downValNow) and upValNow != 0 and downValNow != 0
        regime := ratio >= 1.15 ? "Bullish" : ratio <= 1.0 / 1.15 ? "Bearish" : "Choppy"

    regimeColor = regime == "Bullish" ? colorBull : regime == "Bearish" ? colorBear : chart.fg_color
    row = swingPCSizeD

    table.cell(dash, 0, row, "Up AVG (" + str.tostring(upN) + ")", text_color=chart.fg_color, text_size=DataSize)
    table.cell(dash, 1, row, na(upValNow) ? "—" : "+" + str.tostring(upValNow, format.percent), text_color=chart.fg_color, text_size=DataSize)

    table.cell(dash, 0, row + 1, "Down AVG (" + str.tostring(downN) + ")", text_color=chart.fg_color, text_size=DataSize)
    table.cell(dash, 1, row + 1, na(downValNow) ? "—" : "-" + str.tostring(downValNow, format.percent), text_color=chart.fg_color, text_size=DataSize)

    table.cell(dash, 0, row + 2, "Up Pivot AVG", text_color=chart.fg_color, text_size=DataSize)
    table.cell(dash, 1, row + 2, str.tostring(upPivotBarsNow) + " bars", text_color=chart.fg_color, text_size=DataSize)

    table.cell(dash, 0, row + 3, "Down Pivot AVG", text_color=chart.fg_color, text_size=DataSize)
    table.cell(dash, 1, row + 3, str.tostring(downPivotBarsNow) + " bars", text_color=chart.fg_color, text_size=DataSize)

    table.cell(dash, 0, row + 4, "Up Time-to-Target", text_color=colorBull, text_size=DataSize)
    table.cell(dash, 1, row + 4, str.tostring(upProjectionBarsNow) + " bars • " + upTimingSource + " (" + str.tostring(array.size(upHitDur)) + ")", text_color=colorBull, text_size=DataSize)

    table.cell(dash, 0, row + 5, "Down Time-to-Target", text_color=colorBear, text_size=DataSize)
    table.cell(dash, 1, row + 5, str.tostring(downProjectionBarsNow) + " bars • " + downTimingSource + " (" + str.tostring(array.size(downHitDur)) + ")", text_color=colorBear, text_size=DataSize)

    table.cell(dash, 0, row + 6, "Last Up Target Hit", text_color=chart.fg_color, text_size=DataSize)
    table.cell(dash, 1, row + 6, na(lastUpHitBars) ? "—" : str.tostring(lastUpHitBars) + " bars", text_color=chart.fg_color, text_size=DataSize)

    table.cell(dash, 0, row + 7, "Last Down Target Hit", text_color=chart.fg_color, text_size=DataSize)
    table.cell(dash, 1, row + 7, na(lastDownHitBars) ? "—" : str.tostring(lastDownHitBars) + " bars", text_color=chart.fg_color, text_size=DataSize)

    table.cell(dash, 0, row + 8, "Bias Δ", text_color=chart.fg_color, text_size=DataSize)
    table.cell(dash, 1, row + 8, na(biasDelta) ? "—" : (biasDelta >= 0 ? "+" : "") + str.tostring(biasDelta, format.percent), text_color=chart.fg_color, text_size=DataSize)

    table.cell(dash, 0, row + 9, "Bias Ratio", text_color=chart.fg_color, text_size=DataSize)
    table.cell(dash, 1, row + 9, na(ratio) ? "—" : str.tostring(ratio, "#.##") + "x", text_color=chart.fg_color, text_size=DataSize)

    table.cell(dash, 0, row + 10, "Regime", text_color=chart.fg_color, text_size=DataSize)
    table.cell(dash, 1, row + 10, regime, text_color=regimeColor, text_size=DataSize)

    table.cell(dash, 0, row + 11, "Delta Volume", text_color=chart.fg_color, text_size=DataSize)
    table.cell(dash, 1, row + 11, str.tostring(buySum - sellSum, format.volume), text_color=chart.fg_color, text_size=DataSize)

    table.cell(dash, 0, row + 12, "Total Volume", text_color=chart.fg_color, text_size=DataSize)
    table.cell(dash, 1, row + 12, str.tostring(buySum + sellSum, format.volume), text_color=chart.fg_color, text_size=DataSize)

    // CURRENT SHORT FORECAST --------------------------------------------------
    showShort = showGhost and (ghostShowMode == "Both" or ghostShowMode == "Short Only (Ghost High)" or (ghostShowMode == "Current Leg Only" and lastType == -1))

    if showShort and not na(shortAnchorIdx) and not na(shortAnchorVal) and not na(shortTargetVal) and not na(shortExpectedBars)
        shortElapsed = bar_index - shortAnchorIdx
        shortProjectedEnd = shortAnchorIdx + int(math.min(shortExpectedBars, 500))
        shortDisplayEnd = shortTargetHit ? shortHitIdx : math.max(shortProjectedEnd, bar_index + 1)
        shortStatus = shortTargetHit ? "HIT " + str.tostring(shortHitBars) + "b" : shortElapsed > shortExpectedBars ? "OVERDUE +" + str.tostring(shortElapsed - shortExpectedBars) + "b" : "EST " + str.tostring(shortExpectedBars) + "b"
        shortText = "-" + str.tostring(shortTargetPct, format.percent) + " • " + shortStatus

        if na(ghostHighLine)
            ghostHighLine := line.new(shortAnchorIdx, shortAnchorVal, shortDisplayEnd, shortTargetVal, color=color.new(colorBear, 0), style=line.style_dashed)
        else
            line.set_xy1(ghostHighLine, shortAnchorIdx, shortAnchorVal)
            line.set_xy2(ghostHighLine, shortDisplayEnd, shortTargetVal)
            line.set_color(ghostHighLine, color.new(colorBear, 0))

        if na(ghostHighLbl)
            ghostHighLbl := label.new(shortDisplayEnd, shortTargetVal, shortText, style=label.style_label_left, color=color.new(colorBear, 85), textcolor=chart.fg_color, size=DataSize)
        else
            label.set_xy(ghostHighLbl, shortDisplayEnd, shortTargetVal)
            label.set_text(ghostHighLbl, shortText)
            label.set_color(ghostHighLbl, color.new(colorBear, 85))
    else
        if not na(ghostHighLine)
            line.delete(ghostHighLine)
            ghostHighLine := na

        if not na(ghostHighLbl)
            label.delete(ghostHighLbl)
            ghostHighLbl := na

    // CURRENT LONG FORECAST ---------------------------------------------------
    showLong = showGhost and (ghostShowMode == "Both" or ghostShowMode == "Long Only (Ghost Low)" or (ghostShowMode == "Current Leg Only" and lastType == 1))

    if showLong and not na(longAnchorIdx) and not na(longAnchorVal) and not na(longTargetVal) and not na(longExpectedBars)
        longElapsed = bar_index - longAnchorIdx
        longProjectedEnd = longAnchorIdx + int(math.min(longExpectedBars, 500))
        longDisplayEnd = longTargetHit ? longHitIdx : math.max(longProjectedEnd, bar_index + 1)
        longStatus = longTargetHit ? "HIT " + str.tostring(longHitBars) + "b" : longElapsed > longExpectedBars ? "OVERDUE +" + str.tostring(longElapsed - longExpectedBars) + "b" : "EST " + str.tostring(longExpectedBars) + "b"
        longText = "+" + str.tostring(longTargetPct, format.percent) + " • " + longStatus

        if na(ghostLowLine)
            ghostLowLine := line.new(longAnchorIdx, longAnchorVal, longDisplayEnd, longTargetVal, color=color.new(colorBull, 0), style=line.style_dashed)
        else
            line.set_xy1(ghostLowLine, longAnchorIdx, longAnchorVal)
            line.set_xy2(ghostLowLine, longDisplayEnd, longTargetVal)
            line.set_color(ghostLowLine, color.new(colorBull, 0))

        if na(ghostLowLbl)
            ghostLowLbl := label.new(longDisplayEnd, longTargetVal, longText, style=label.style_label_left, color=color.new(colorBull, 85), textcolor=chart.fg_color, size=DataSize)
        else
            label.set_xy(ghostLowLbl, longDisplayEnd, longTargetVal)
            label.set_text(ghostLowLbl, longText)
            label.set_color(ghostLowLbl, color.new(colorBull, 85))
    else
        if not na(ghostLowLine)
            line.delete(ghostLowLine)
            ghostLowLine := na

        if not na(ghostLowLbl)
            label.delete(ghostLowLbl)
            ghostLowLbl := na

    // MULTI-PIVOT FUTURE FORECAST --------------------------------------------
    while array.size(futureShortLines) > 0
        line.delete(array.pop(futureShortLines))

    while array.size(futureShortLabels) > 0
        label.delete(array.pop(futureShortLabels))

    while array.size(futureLongLines) > 0
        line.delete(array.pop(futureLongLines))

    while array.size(futureLongLabels) > 0
        label.delete(array.pop(futureLongLabels))

    futureShowShort = showFutureForecast and (ghostShowMode == "Both" or ghostShowMode == "Short Only (Ghost High)" or (ghostShowMode == "Current Leg Only" and lastType == -1))
    futureShowLong = showFutureForecast and (ghostShowMode == "Both" or ghostShowMode == "Long Only (Ghost Low)" or (ghostShowMode == "Current Leg Only" and lastType == 1))

    if futureShowShort and not na(shortAnchorIdx) and not na(shortAnchorVal) and not na(shortExpectedBars) and not na(useDownSwingNow) and not na(useUpSwingNow)
        projX1 = shortAnchorIdx
        projY1 = shortAnchorVal
        projDir = -1
        futureMaxIdx = bar_index + 500

        for i = 0 to futurePivotCount - 1
            if projX1 < futureMaxIdx
                float segPct = na
                int segBarsRaw = na
                segStatus = "EST "

                if projDir == -1
                    segPct := useDownSwingNow

                    if i == 0 and shortTargetHit and not na(shortHitBars)
                        segBarsRaw := shortHitBars
                        segStatus := "HIT "
                    else if i == 0
                        segBarsRaw := shortExpectedBars
                    else
                        segBarsRaw := downProjectionBarsNow
                else
                    segPct := useUpSwingNow
                    segBarsRaw := upProjectionBarsNow

                remainingBars = futureMaxIdx - projX1

                if not na(segPct) and not na(segBarsRaw) and remainingBars > 0
                    segBars = math.max(1, math.min(segBarsRaw, remainingBars))
                    projX2 = projX1 + segBars
                    projY2 = projDir == -1 ? projY1 - projY1 * segPct / 100.0 : projY1 + projY1 * segPct / 100.0
                    segColor = projDir == -1 ? color.new(colorBear, 35) : color.new(colorBull, 35)
                    segBackground = projDir == -1 ? color.new(colorBear, 92) : color.new(colorBull, 92)
                    segText = (projDir == -1 ? "-" : "+") + str.tostring(segPct, format.percent) + " • " + segStatus + str.tostring(segBarsRaw) + "b"

                    futureShortLine = line.new(projX1, projY1, projX2, projY2, color=segColor, style=line.style_dotted)
                    futureShortLabel = label.new(projX2, projY2, segText, style=label.style_label_left, color=segBackground, textcolor=chart.fg_color, size=DataSize)
                    array.push(futureShortLines, futureShortLine)
                    array.push(futureShortLabels, futureShortLabel)

                    projX1 := projX2
                    projY1 := projY2
                    projDir := projDir * -1

    if futureShowLong and not na(longAnchorIdx) and not na(longAnchorVal) and not na(longExpectedBars) and not na(useUpSwingNow) and not na(useDownSwingNow)
        projX1 = longAnchorIdx
        projY1 = longAnchorVal
        projDir = 1
        futureMaxIdx = bar_index + 500

        for i = 0 to futurePivotCount - 1
            if projX1 < futureMaxIdx
                float segPct = na
                int segBarsRaw = na
                segStatus = "EST "

                if projDir == 1
                    segPct := useUpSwingNow

                    if i == 0 and longTargetHit and not na(longHitBars)
                        segBarsRaw := longHitBars
                        segStatus := "HIT "
                    else if i == 0
                        segBarsRaw := longExpectedBars
                    else
                        segBarsRaw := upProjectionBarsNow
                else
                    segPct := useDownSwingNow
                    segBarsRaw := downProjectionBarsNow

                remainingBars = futureMaxIdx - projX1

                if not na(segPct) and not na(segBarsRaw) and remainingBars > 0
                    segBars = math.max(1, math.min(segBarsRaw, remainingBars))
                    projX2 = projX1 + segBars
                    projY2 = projDir == 1 ? projY1 + projY1 * segPct / 100.0 : projY1 - projY1 * segPct / 100.0
                    segColor = projDir == 1 ? color.new(colorBull, 35) : color.new(colorBear, 35)
                    segBackground = projDir == 1 ? color.new(colorBull, 92) : color.new(colorBear, 92)
                    segText = (projDir == 1 ? "+" : "-") + str.tostring(segPct, format.percent) + " • " + segStatus + str.tostring(segBarsRaw) + "b"

                    futureLongLine = line.new(projX1, projY1, projX2, projY2, color=segColor, style=line.style_dotted)
                    futureLongLabel = label.new(projX2, projY2, segText, style=label.style_label_left, color=segBackground, textcolor=chart.fg_color, size=DataSize)
                    array.push(futureLongLines, futureLongLine)
                    array.push(futureLongLabels, futureLongLabel)

                    projX1 := projX2
                    projY1 := projY2
                    projDir := projDir * -1

    // OPTIONAL CONFIRMED-PIVOT FORECAST --------------------------------------
    pivotDirection = lastType == -1 ? 1 : -1
    pivotSwingPct = pivotDirection == 1 ? useUpSwingNow : useDownSwingNow
    pivotDurationBars = pivotDirection == 1 ? upProjectionBarsNow : downProjectionBarsNow

    if showPivotForecast and lastType != 0 and not na(lastPivot.indx) and not na(lastPivot.val) and not na(pivotSwingPct)
        pivotDrawBars = int(math.min(pivotDurationBars, 500))
        pivotEnd = lastPivot.indx + pivotDrawBars
        pivotTarget = pivotDirection == 1 ? lastPivot.val + lastPivot.val * pivotSwingPct / 100.0 : lastPivot.val - lastPivot.val * pivotSwingPct / 100.0
        pivotText = (pivotDirection == 1 ? "+" : "-") + str.tostring(pivotSwingPct, format.percent) + " • EST " + str.tostring(pivotDurationBars) + "b"
        pivotColor = pivotDirection == 1 ? color.new(colorBull, 35) : color.new(colorBear, 35)
        pivotBackground = pivotDirection == 1 ? color.new(colorBull, 92) : color.new(colorBear, 92)

        if na(pivotLine)
            pivotLine := line.new(lastPivot.indx, lastPivot.val, pivotEnd, pivotTarget, color=pivotColor, style=line.style_dashed)
        else
            line.set_xy1(pivotLine, lastPivot.indx, lastPivot.val)
            line.set_xy2(pivotLine, pivotEnd, pivotTarget)
            line.set_color(pivotLine, pivotColor)

        if na(pivotLbl)
            pivotLbl := label.new(pivotEnd, pivotTarget, pivotText, style=label.style_label_left, color=pivotBackground, textcolor=chart.fg_color, size=DataSize)
        else
            label.set_xy(pivotLbl, pivotEnd, pivotTarget)
            label.set_text(pivotLbl, pivotText)
            label.set_color(pivotLbl, pivotBackground)
    else
        if not na(pivotLine)
            line.delete(pivotLine)
            pivotLine := na

        if not na(pivotLbl)
            label.delete(pivotLbl)
            pivotLbl := na

    // SWING-ZONE EXTENSION ----------------------------------------------------
    zoneBars = math.max(fallbackBars, math.max(upProjectionBarsNow, downProjectionBarsNow))
    zoneDrawBars = int(math.min(zoneBars, 500))

    if not na(swingUpper)
        box.set_right(swingUpper, bar_index + zoneDrawBars)

    if not na(swingLower)
        box.set_right(swingLower, bar_index + zoneDrawBars)

var _wmTable = table.new(position.bottom_center, 1, 1)
table.cell(_wmTable, 0, 0, "</> ZeroEmotion.IndiLab  |  Modified", text_color=color.new(color.white, 50), text_size=size.large)
````
