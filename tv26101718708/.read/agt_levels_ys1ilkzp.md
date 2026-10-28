# AGT Levels

- url: https://www.tradingview.com/script/ys1iLkzP-AGT-Levels/
- type: indicator
- pine_id: PUB;f3dbe5d8fe3741ce8297d2bb17267c21
- version: 1.0

## Description

AGT Levels is a custom volume-profile-based support and resistance tool designed to highlight key High Volume Nodes and Low Volume Nodes directly on your chart.

Instead of using standard horizontal levels, this indicator builds a full right-side volume profile from the same data used to calculate the levels. The profile is plotted to the right of price and faces back toward the chart, making it easier to see where volume has built up and where price may react.

The main idea is simple:

High Volume Nodes can act as areas where price accepts value, consolidates, or reacts strongly.

Low Volume Nodes can act as rejection zones, thin liquidity areas, or fast-move regions where price may move quickly through or reject from.

The indicator includes:

• Full right-side volume profile
• Up/down volume split inside the profile
• HVN and LVN level detection
• Major and minor level zones
• Adjustable sensitivity settings
• Adjustable profile offset
• Level zones extending from the volume profile
• Optional boxes, midlines, or both
• Alerts for level touches and rejections

The Sensitivity setting controls both the volume profile resolution and the level detection logic:

Conservative gives cleaner, broader levels.

Balanced gives a good all-round view.

Aggressive gives more granular levels and a more detailed profile.

This tool is designed to help traders identify important volume-based reaction zones, rather than relying only on traditional highs/lows or manually drawn support and resistance.

Best used together with your own market structure, session bias, VWAP, orderflow, or liquidity-based strategy.

This script does not predict future price movement. It is intended for technical analysis, backtesting, and educational use only.

Not financial advice. Always do your own research and risk management.

## Source Code

````pine
//@version=6
indicator("AGT Levels - Right Side VP", overlay=true, max_boxes_count=500, max_lines_count=500)

//====================================================
// USER INPUTS
//====================================================
groupMain = "Levels"
precisionSetting = input.string("Balanced", "Sensitivity", options=["Conservative", "Balanced", "Aggressive"], tooltip="Controls both the LVN/HVN detection and the right-side volume profile resolution. Conservative uses fewer rows and a narrower profile. Balanced is the default all-round setting. Aggressive uses more rows and a wider profile for more granular mapping.", group=groupMain)
levelDensity     = input.int(20, "Max Levels", minval=1, maxval=20, tooltip="Sets the maximum number of HVN/LVN zones shown on the chart. Lower values keep the chart cleaner, while higher values show more levels.", group=groupMain)
zoneWidth        = input.int(0, "Zone Width", minval=0, maxval=5, tooltip="Adjusts how thick each plotted HVN/LVN zone appears. Higher values create broader zones around each selected profile row, while lower values keep levels tighter and more precise.", group=groupMain)
levelExtensionBars = input.int(120, "Level Extension Left From VP", minval=1, maxval=500, tooltip="Controls how far the HVN/LVN zones extend left from the right-side volume profile into the chart. Higher values make the levels project further across price action.", group=groupMain)

groupVP = "Volume Profile"
showVolumeProfile = input.bool(true, "Show Right-Side Volume Profile", tooltip="Shows the full volume profile on the right side of the chart. The profile uses the exact same scan range, row count, smoothing and sensitivity logic as the LVN/HVN levels.", group=groupVP)
profileOffsetBars = input.int(20, "Profile Offset Right", minval=0, maxval=400, tooltip="Moves the volume profile to the right of the current bar. Default is 20 bars to keep the profile separate from live candles.", group=groupVP)
profileUpColor    = input.color(color.new(color.rgb(0, 170, 120), 55), "Up Volume Color", tooltip="Color used for volume from bullish candles inside each profile row.", group=groupVP)
profileDownColor  = input.color(color.new(color.rgb(220, 60, 60), 55), "Down Volume Color", tooltip="Color used for volume from bearish candles inside each profile row.", group=groupVP)
profileBorderColor = input.color(color.new(color.gray, 88), "Profile Row Border", tooltip="Border color for individual volume profile rows. Higher transparency keeps the profile cleaner.", group=groupVP)

groupStyle = "Style"
displayMode      = input.string("Boxes", "Level Display", options=["Boxes", "Midlines", "Both"], tooltip="Choose how HVN/LVN levels are drawn from the volume profile. Boxes show full zones, Midlines show the center line of each zone, and Both displays both styles together.", group=groupStyle)
showMajorLevels  = input.bool(true, "Show Major HVNs", tooltip="Shows or hides the stronger high-volume node zones on the chart and highlights them inside the volume profile.", group=groupStyle)
showMinorLevels  = input.bool(true, "Show Minor LVNs", tooltip="Shows or hides the lower-volume node zones on the chart and highlights them inside the volume profile.", group=groupStyle)
majorColor       = input.color(color.new(color.rgb(0, 70, 180), 72), "HVN / Major Level Color", tooltip="Sets the display color for high-volume node levels and their profile highlight.", group=groupStyle)
minorColor       = input.color(color.new(color.rgb(180, 0, 0), 72), "LVN / Minor Level Color", tooltip="Sets the display color for low-volume node levels and their profile highlight.", group=groupStyle)

//====================================================
// INTERNAL SETTINGS
//====================================================
int rows                 = precisionSetting == "Conservative" ? 50 : precisionSetting == "Balanced" ? 100 : 150
int profileWidthBars     = precisionSetting == "Conservative" ? 24 : precisionSetting == "Balanced" ? 40 : 58
int valueShare           = 70
float majorCutoff        = 65.0
float minorCutoff        = 25.0
bool mergeZones          = true
bool useTurningPts       = true
int smoothPasses         = 1
bool ignoreEdges         = true
int minBarsRequired      = 20
int maxBarsToScan        = 4999

//====================================================
// HELPERS
//====================================================
f_get_bounds() =>
    int startBar = math.max(0, bar_index - maxBarsToScan)
    int endBar = bar_index
    [startBar, endBar]

f_clamp(_x, _min, _max) =>
    math.max(_min, math.min(_max, _x))

f_clear_boxes(box[] arr) =>
    int sz = array.size(arr)
    if sz > 0
        for i = 0 to sz - 1
            box.delete(array.get(arr, i))
    array.clear(arr)

f_clear_lines(line[] arr) =>
    int sz = array.size(arr)
    if sz > 0
        for i = 0 to sz - 1
            line.delete(array.get(arr, i))
    array.clear(arr)

f_array_max(float[] arr) =>
    float m = 0.0
    int sz = array.size(arr)
    if sz > 0
        for i = 0 to sz - 1
            m := math.max(m, array.get(arr, i))
    m

f_is_peak(float[] arr, int i) =>
    float c = array.get(arr, i)
    float l = i > 0 ? array.get(arr, i - 1) : c
    float r = i < array.size(arr) - 1 ? array.get(arr, i + 1) : c
    c >= l and c >= r and (c > l or c > r)

f_is_trough(float[] arr, int i) =>
    float c = array.get(arr, i)
    float l = i > 0 ? array.get(arr, i - 1) : c
    float r = i < array.size(arr) - 1 ? array.get(arr, i + 1) : c
    c <= l and c <= r and (c < l or c < r)

f_smooth(float[] src, int passes) =>
    float[] out = array.copy(src)
    for p = 0 to passes - 1
        float[] tmp = array.new_float(array.size(out), 0.0)
        for i = 0 to array.size(out) - 1
            float a = i > 0 ? array.get(out, i - 1) : array.get(out, i)
            float b = array.get(out, i)
            float c = i < array.size(out) - 1 ? array.get(out, i + 1) : array.get(out, i)
            array.set(tmp, i, (a + b + c) / 3.0)
        out := tmp
    out

f_sort_indices_desc(float[] vals) =>
    int n = array.size(vals)
    int[] idx = array.new_int()
    if n > 0
        for i = 0 to n - 1
            array.push(idx, i)
        if n > 1
            for i = 0 to n - 2
                for j = 0 to n - i - 2
                    int a = array.get(idx, j)
                    int b = array.get(idx, j + 1)
                    if array.get(vals, a) < array.get(vals, b)
                        array.set(idx, j, b)
                        array.set(idx, j + 1, a)
    idx

f_array_contains_int(int[] arr, int val) =>
    bool found = false
    int sz = array.size(arr)
    if sz > 0
        for i = 0 to sz - 1
            if array.get(arr, i) == val
                found := true
    found

//====================================================
// DRAWING STORAGE
//====================================================
var box[] levelBoxes = array.new_box()
var line[] levelLines = array.new_line()
var box[] profileBoxes = array.new_box()
var float[] majorZoneLows = array.new_float()
var float[] majorZoneHighs = array.new_float()
var float[] minorZoneLows = array.new_float()
var float[] minorZoneHighs = array.new_float()
var float[] profileHighlightLows = array.new_float()
var float[] profileHighlightHighs = array.new_float()
var bool[] profileHighlightMajor = array.new_bool()

var bool majorLevelTouch = false
var bool minorLevelTouch = false
var bool anyLevelTouch = false
var bool majorLevelRejection = false
var bool minorLevelRejection = false
var bool anyLevelRejection = false

//====================================================
// ALERT HELPERS
//====================================================
f_zone_touched(float zoneLow, float zoneHigh) =>
    high >= zoneLow and low <= zoneHigh

f_zone_touched_prev(float zoneLow, float zoneHigh) =>
    bar_index > 0 ? (high[1] >= zoneLow and low[1] <= zoneHigh) : false

alertcondition(majorLevelTouch, title="Major Level Touch", message="AGT Levels: Price touched a major level on {{ticker}} {{interval}} | Current price: {{close}}")
alertcondition(minorLevelTouch, title="Minor Level Touch", message="AGT Levels: Price touched a minor level on {{ticker}} {{interval}} | Current price: {{close}}")
alertcondition(anyLevelTouch, title="Any Level Touch", message="AGT Levels: Price touched a level on {{ticker}} {{interval}} | Current price: {{close}}")
alertcondition(majorLevelRejection, title="Major Level Rejection", message="AGT Levels: Price rejected from a major level on {{ticker}} {{interval}} | Current price: {{close}}")
alertcondition(minorLevelRejection, title="Minor Level Rejection", message="AGT Levels: Price rejected from a minor level on {{ticker}} {{interval}} | Current price: {{close}}")
alertcondition(anyLevelRejection, title="Any Level Rejection", message="AGT Levels: Price rejected from a level on {{ticker}} {{interval}} | Current price: {{close}}")

//====================================================
// CORE CALC
//====================================================
majorLevelTouch := false
minorLevelTouch := false
anyLevelTouch := false
majorLevelRejection := false
minorLevelRejection := false
anyLevelRejection := false

if barstate.islast
    f_clear_boxes(levelBoxes)
    f_clear_lines(levelLines)
    f_clear_boxes(profileBoxes)
    array.clear(majorZoneLows)
    array.clear(majorZoneHighs)
    array.clear(minorZoneLows)
    array.clear(minorZoneHighs)
    array.clear(profileHighlightLows)
    array.clear(profileHighlightHighs)
    array.clear(profileHighlightMajor)

    [leftBar, rightBar] = f_get_bounds()
    int firstOffset = math.max(0, bar_index - rightBar)
    int lastOffset = math.min(maxBarsToScan, math.max(0, bar_index - leftBar))

    float rangeHigh = na
    float rangeLow  = na
    int barsCount   = 0

    for i = firstOffset to lastOffset
        rangeHigh := na(rangeHigh) ? high[i] : math.max(rangeHigh, high[i])
        rangeLow  := na(rangeLow)  ? low[i]  : math.min(rangeLow, low[i])
        barsCount += 1

    if barsCount >= minBarsRequired and not na(rangeHigh) and not na(rangeLow) and rangeHigh > rangeLow
        float rowSize = (rangeHigh - rangeLow) / rows

        float[] upVol = array.new_float(rows, 0.0)
        float[] dnVol = array.new_float(rows, 0.0)
        float[] totalRaw = array.new_float(rows, 0.0)

        for i = firstOffset to lastOffset
            float bh = high[i]
            float bl = low[i]
            float bv = volume[i]
            bool upBar = close[i] >= open[i]

            float barRange = math.max(bh - bl, syminfo.mintick)
            int firstRow = int(math.floor((bl - rangeLow) / rowSize))
            int lastRow  = int(math.floor((bh - rangeLow) / rowSize))
            firstRow := f_clamp(firstRow, 0, rows - 1)
            lastRow  := f_clamp(lastRow, 0, rows - 1)

            for r = firstRow to lastRow
                float rowBottom = rangeLow + r * rowSize
                float rowTop    = rowBottom + rowSize
                float overlap   = math.max(0.0, math.min(bh, rowTop) - math.max(bl, rowBottom))
                float alloc     = overlap > 0 ? bv * (overlap / barRange) : 0.0
                if upBar
                    array.set(upVol, r, array.get(upVol, r) + alloc)
                else
                    array.set(dnVol, r, array.get(dnVol, r) + alloc)

        for r = 0 to rows - 1
            array.set(totalRaw, r, array.get(upVol, r) + array.get(dnVol, r))

        float[] totalSmoothed = smoothPasses > 0 ? f_smooth(totalRaw, smoothPasses) : array.copy(totalRaw)
        float maxNodeVol = f_array_max(totalSmoothed)

        int centerRow = 0
        float centerVol = 0.0
        float totalProfileVol = 0.0
        for r = 0 to rows - 1
            float tv = array.get(totalSmoothed, r)
            totalProfileVol += tv
            if tv > centerVol
                centerVol := tv
                centerRow := r

        int upperRow = centerRow
        int lowerRow = centerRow
        float targetValue = totalProfileVol * valueShare / 100.0
        float runningValue = array.get(totalSmoothed, centerRow)

        while runningValue < targetValue and (lowerRow > 0 or upperRow < rows - 1)
            float belowVol = lowerRow > 0 ? array.get(totalSmoothed, lowerRow - 1) : -1.0
            float aboveVol = upperRow < rows - 1 ? array.get(totalSmoothed, upperRow + 1) : -1.0
            if aboveVol >= belowVol
                if upperRow < rows - 1
                    upperRow += 1
                    runningValue += array.get(totalSmoothed, upperRow)
                else if lowerRow > 0
                    lowerRow -= 1
                    runningValue += array.get(totalSmoothed, lowerRow)
            else
                if lowerRow > 0
                    lowerRow -= 1
                    runningValue += array.get(totalSmoothed, lowerRow)
                else if upperRow < rows - 1
                    upperRow += 1
                    runningValue += array.get(totalSmoothed, upperRow)

        float majorNodeCutoff = maxNodeVol * majorCutoff / 100.0
        float minorNodeCutoff = maxNodeVol * minorCutoff / 100.0

        int[] majorRows = array.new_int()
        int[] minorRows = array.new_int()

        for r = 0 to rows - 1
            bool edgeBlocked = ignoreEdges and (r == 0 or r == rows - 1)
            if not edgeBlocked
                float v = array.get(totalSmoothed, r)
                bool peakOk = not useTurningPts or f_is_peak(totalSmoothed, r)
                bool troughOk = not useTurningPts or f_is_trough(totalSmoothed, r)

                if showMajorLevels and v >= majorNodeCutoff and peakOk
                    array.push(majorRows, r)

                if showMinorLevels and v <= minorNodeCutoff and troughOk
                    array.push(minorRows, r)

        float[] majorStrength = array.new_float()
        int majorRowsSize = array.size(majorRows)
        if majorRowsSize > 0
            for i = 0 to majorRowsSize - 1
                int r = array.get(majorRows, i)
                array.push(majorStrength, array.get(totalSmoothed, r))

        float[] minorStrength = array.new_float()
        int minorRowsSize = array.size(minorRows)
        if minorRowsSize > 0
            for i = 0 to minorRowsSize - 1
                int r = array.get(minorRows, i)
                array.push(minorStrength, maxNodeVol - array.get(totalSmoothed, r))

        int[] majorOrder = f_sort_indices_desc(majorStrength)
        int[] minorOrder = f_sort_indices_desc(minorStrength)

        bool[] majorUsed = array.new_bool(rows, false)
        bool[] minorUsed = array.new_bool(rows, false)

        int profileStart = bar_index + profileOffsetBars
        int profileEnd = profileStart + profileWidthBars
        int levelLeftEdge = math.max(0, profileStart - levelExtensionBars)

        int majorLimit = math.max(1, math.ceil(levelDensity / 2.0))
        int minorLimit = math.max(1, levelDensity - majorLimit)

        int majorDrawn = 0
        int majorOrderSize = array.size(majorOrder)
        if majorOrderSize > 0
            for k = 0 to majorOrderSize - 1
                if majorDrawn >= majorLimit
                    break

                int ord = array.get(majorOrder, k)
                int center = array.get(majorRows, ord)

                if not array.get(majorUsed, center)
                    int lowRow = math.max(0, center - zoneWidth)
                    int highRow = math.min(rows - 1, center + zoneWidth)

                    if mergeZones
                        while lowRow > 0 and f_array_contains_int(majorRows, lowRow - 1)
                            lowRow -= 1
                        while highRow < rows - 1 and f_array_contains_int(majorRows, highRow + 1)
                            highRow += 1

                    for r = lowRow to highRow
                        array.set(majorUsed, r, true)

                    float y1 = rangeLow + lowRow * rowSize
                    float y2 = rangeLow + (highRow + 1) * rowSize
                    float yMid = (y1 + y2) / 2.0
                    if displayMode == "Boxes" or displayMode == "Both"
                        box b = box.new(levelLeftEdge, y2, profileStart, y1, bgcolor=majorColor, border_color=color.new(majorColor, 0))
                        array.push(levelBoxes, b)
                    if displayMode == "Midlines" or displayMode == "Both"
                        line l = line.new(levelLeftEdge, yMid, profileStart, yMid, color=color.new(majorColor, 0), width=2)
                        array.push(levelLines, l)
                    array.push(majorZoneLows, y1)
                    array.push(majorZoneHighs, y2)
                    array.push(profileHighlightLows, y1)
                    array.push(profileHighlightHighs, y2)
                    array.push(profileHighlightMajor, true)

                    majorDrawn += 1

        int minorDrawn = 0
        int minorOrderSize = array.size(minorOrder)
        if minorOrderSize > 0
            for k = 0 to minorOrderSize - 1
                if minorDrawn >= minorLimit
                    break

                int ord = array.get(minorOrder, k)
                int center = array.get(minorRows, ord)

                if not array.get(minorUsed, center)
                    int lowRow = math.max(0, center - zoneWidth)
                    int highRow = math.min(rows - 1, center + zoneWidth)

                    if mergeZones
                        while lowRow > 0 and f_array_contains_int(minorRows, lowRow - 1)
                            lowRow -= 1
                        while highRow < rows - 1 and f_array_contains_int(minorRows, highRow + 1)
                            highRow += 1

                    for r = lowRow to highRow
                        array.set(minorUsed, r, true)

                    float y1 = rangeLow + lowRow * rowSize
                    float y2 = rangeLow + (highRow + 1) * rowSize
                    float yMid = (y1 + y2) / 2.0
                    if displayMode == "Boxes" or displayMode == "Both"
                        box b = box.new(levelLeftEdge, y2, profileStart, y1, bgcolor=minorColor, border_color=color.new(minorColor, 0))
                        array.push(levelBoxes, b)
                    if displayMode == "Midlines" or displayMode == "Both"
                        line l = line.new(levelLeftEdge, yMid, profileStart, yMid, color=color.new(minorColor, 0), width=2)
                        array.push(levelLines, l)
                    array.push(minorZoneLows, y1)
                    array.push(minorZoneHighs, y2)
                    array.push(profileHighlightLows, y1)
                    array.push(profileHighlightHighs, y2)
                    array.push(profileHighlightMajor, false)

                    minorDrawn += 1

        if showVolumeProfile and maxNodeVol > 0
            for r = 0 to rows - 1
                float rowBottom = rangeLow + r * rowSize
                float rowTop = rowBottom + rowSize
                float rowVol = array.get(totalSmoothed, r)
                if rowVol > 0
                    int totalLen = int(math.round(profileWidthBars * rowVol / maxNodeVol))
                    totalLen := math.max(1, math.min(profileWidthBars, totalLen))

                    float rawUp = array.get(upVol, r)
                    float rawDn = array.get(dnVol, r)
                    float rawTotal = rawUp + rawDn
                    int upLen = rawTotal > 0 ? int(math.round(totalLen * rawUp / rawTotal)) : int(math.round(totalLen * 0.5))
                    int dnLen = totalLen - upLen

                    if rawUp > 0 and rawDn > 0 and totalLen >= 2
                        upLen := math.max(1, math.min(totalLen - 1, upLen))
                        dnLen := totalLen - upLen
                    else if rawUp > 0 and rawDn <= 0
                        upLen := totalLen
                        dnLen := 0
                    else if rawDn > 0 and rawUp <= 0
                        upLen := 0
                        dnLen := totalLen

                    // Face the full volume profile left by anchoring each row to the right edge
                    if dnLen > 0
                        box dnBox = box.new(profileEnd - totalLen, rowTop, profileEnd - upLen, rowBottom, bgcolor=profileDownColor, border_color=profileBorderColor)
                        array.push(profileBoxes, dnBox)
                    if upLen > 0
                        box upBox = box.new(profileEnd - upLen, rowTop, profileEnd, rowBottom, bgcolor=profileUpColor, border_color=profileBorderColor)
                        array.push(profileBoxes, upBox)

            int highlightCount = array.size(profileHighlightLows)
            if highlightCount > 0
                for i = 0 to highlightCount - 1
                    float y1 = array.get(profileHighlightLows, i)
                    float y2 = array.get(profileHighlightHighs, i)
                    bool isMajor = array.get(profileHighlightMajor, i)
                    color hColor = isMajor ? majorColor : minorColor
                    box hb = box.new(profileStart, y2, profileEnd, y1, bgcolor=color.new(hColor, 88), border_color=color.new(hColor, 0))
                    array.push(profileBoxes, hb)

        float nearestMajorAbove = na
        float nearestMajorBelow = na
        int majorZonesSize = array.size(majorZoneLows)
        if majorZonesSize > 0
            for i = 0 to majorZonesSize - 1
                float zoneLow = array.get(majorZoneLows, i)
                float zoneHigh = array.get(majorZoneHighs, i)
                float zoneMid = (zoneLow + zoneHigh) / 2.0
                bool touchedNow = f_zone_touched(zoneLow, zoneHigh)
                bool touchedPrev = f_zone_touched_prev(zoneLow, zoneHigh)
                bool rejectedNow = touchedNow and (close > zoneHigh or close < zoneLow)
                if touchedNow and not touchedPrev
                    majorLevelTouch := true
                if rejectedNow and not touchedPrev
                    majorLevelRejection := true
                if zoneMid >= close
                    nearestMajorAbove := na(nearestMajorAbove) ? zoneMid : math.min(nearestMajorAbove, zoneMid)
                if zoneMid <= close
                    nearestMajorBelow := na(nearestMajorBelow) ? zoneMid : math.max(nearestMajorBelow, zoneMid)

        float nearestMinorAbove = na
        float nearestMinorBelow = na
        int minorZonesSize = array.size(minorZoneLows)
        if minorZonesSize > 0
            for i = 0 to minorZonesSize - 1
                float zoneLow = array.get(minorZoneLows, i)
                float zoneHigh = array.get(minorZoneHighs, i)
                float zoneMid = (zoneLow + zoneHigh) / 2.0
                bool touchedNow = f_zone_touched(zoneLow, zoneHigh)
                bool touchedPrev = f_zone_touched_prev(zoneLow, zoneHigh)
                bool rejectedNow = touchedNow and (close > zoneHigh or close < zoneLow)
                if touchedNow and not touchedPrev
                    minorLevelTouch := true
                if rejectedNow and not touchedPrev
                    minorLevelRejection := true
                if zoneMid >= close
                    nearestMinorAbove := na(nearestMinorAbove) ? zoneMid : math.min(nearestMinorAbove, zoneMid)
                if zoneMid <= close
                    nearestMinorBelow := na(nearestMinorBelow) ? zoneMid : math.max(nearestMinorBelow, zoneMid)

        anyLevelTouch := majorLevelTouch or minorLevelTouch
        anyLevelRejection := majorLevelRejection or minorLevelRejection
````
