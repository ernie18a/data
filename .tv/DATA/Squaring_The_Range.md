<!-- tradingview-pine-id: PUB;84500002bed8449f959cdb21b3362dc8 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Squaring The Range

Source: https://www.tradingview.com/script/f6ULpoO8-Squaring-The-Range/

## Description

Squaring The Range (STR Pro)

Squaring The Range is a comprehensive geometric and time-cycle analysis tool engineered to calculate the mathematical relationship between price and time. Built on the foundational principles of W.D. Gann and esoteric market geometry, this indicator dynamically detects structural market legs and projects a master geometric square to forecast future support, resistance, and cyclical turning points.
Instead of relying on lagging moving averages or standard oscillators, this tool treats price and time as equal, unified vectors, allowing you to visualize the harmonic grid underlying market movements.

Why It Works

Financial markets do not move randomly; they expand and contract in proportional, geometric ratios. When a market establishes a significant high and a significant low, the space between them forms a "master square."

According to the law of vibration and Gann theory, the original energy that created the initial price range will dictate the future rhythm of the market. By subdividing this range into specific musical and mathematical octaves (eighths) and harmonic thirds, we expose the natural barriers where price action is mathematically forced to react. When the time it took to form the range is duplicated or fractionally divided, time and price "square out," resulting in high-probability trend reversals or accelerations.

How It Works

The STR Pro engine operates by identifying the most mathematically significant price swing within a defined window.
Swing Detection Engine: The script uses a lag-aware pivot detection system to identify structural highs and lows. It does not repaint. A swing is only confirmed after a set number of lower highs or higher lows form on both sides.
The Geometric Box: Once the high and low are confirmed, the indicator draws a foundational box connecting the two points, establishing the base price range and time vector (bar count).
Subdivisions: The price range is automatically sliced into 1/8 and 1/3 fractions. The time vector is divided into identical proportional fractions.
Vector Angles: Gann angles (1x1, 2x1, 1x2, 1x4, 4x1) are cast outward from the primary pivots. The 1x1 angle represents a perfectly balanced market moving one unit of price per one unit of time.

How To Use

1. Finding Confluence (Nodes)
The highest probability trade setups occur at "Major Nodes." These are coordinates on the chart where a horizontal price fraction (e.g., the 4/8 or 50% midline) perfectly intersects with a vertical time division (e.g., the 1/2 cycle mark). Watch for price action to consolidate or sharply reverse when it strikes a Major Node (marked in Gold) or Minor Node (marked in Silver).
2. Trading the Anniversary Cycles
The indicator projects 1x, 2x, and 3x "Anniversary" lines forward in time. If a market took 45 bars to form the initial range, the 1x Anniversary will plot exactly 45 bars later. Trend exhaustion and aggressive reversals frequently occur precisely on these vertical time boundaries.
3. Utilizing Gann Angles
Monitor price interaction with the ascending and descending angles.
If price is holding above an ascending 1x1 angle from the low, the trend is incredibly strong.
If price breaks below the 1x1, it mathematically targets the 1x2 angle next, signaling a deceleration in market velocity.

Settings Tutorial

► Pivot Selection & Auto-Detect
Use Auto-Detection: Toggle between the algorithm finding the pivots or you entering exact timestamps manually.
Auto-Detect Mode:
Macro Swing Extremes: Finds the highest structural high and lowest structural low in the window.
Latest Swing Leg: Squares only the most recent completed move.
Raw Extremes: Finds the absolute high/low regardless of swing structure.
Swing Strength: The number of bars required on each side of a candle to confirm a pivot. Higher numbers equal major structural swings; lower numbers catch micro swings.
Auto Lookback Window: The maximum number of bars the engine searches to find the swings.
Manual Pivot Times: If Auto-Detection is off, enter the exact date and time of the high and low you wish to square.
► Master Overlays & Fractions
Geometric Box / Nodes: Toggle the visibility of the primary bounding box and the intersection nodes.
Price Fractions: Choose whether to display the 1/8 octaves, the 1/3 thirds, or both.
Label Every Other Fraction: Cleans up the chart UI by hiding half the text labels while keeping the geometric lines visible.
► Gann Angles & Time Cycles
Gann Angles: Toggle individual angles (1x1, 1x2, 2x1, 1x4, 4x1).
Forward Projections: Controls how far into the future the angles cast (measured in multiples of the original time vector).
Division Cycles: How many times the original time vector is duplicated and sub-divided forward on the chart.
Anniversary Count: Controls how many vertical Anniversary cycle lines are projected.
► Alerts
STR Pro uses a unified alert system. You only need to create ONE alert in TradingView for this script (Condition: "Any alert() function call").
Use the toggles in this section to choose which specific events (price crossing a 1/8 level, hitting a time division, or striking an angle) will trigger that master alert.
► Visuals & Dashboard
Show Dashboard (HUD): Displays a live data panel showing the exact coordinates of the active pivots, the point value of the price range, the bar count of the time vector, and the active 1x1 scale ratio. Position and size can be adjusted to fit your layout.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PyraTime
//@version=6

// =============================================================================
// SQUARING THE RANGE (STR PRO)
// =============================================================================
// Description:
// Squaring The Range is a comprehensive geometric and time-cycle analysis tool 
// built on the principles of W.D. Gann and price-to-time squaring. The engine 
// dynamically detects macro swing extremes (or accepts manual pivot timestamps) 
// to construct a master geometric box around a given market leg.
//
// Core Mechanics:
// - Swing Detection: Uses a lag-aware pivot detection system to find structural highs and lows.
// - Geometric Fractions: Plots 1/8 and 1/3 price levels to identify natural support/resistance.
// - Time Divisions: Divides the time vector of the range into fractional increments.
// - Gann Angles: Casts standard 1x1, 1x2, 2x1, 1x4, and 4x1 angles to track velocity.
// 
// Note on Alerts & Repainting: 
// All alerts are strictly evaluated on closed/confirmed bars to prevent repainting. 
// Swing detection naturally requires N bars to confirm a pivot, which the script accounts for.
// =============================================================================

indicator("Squaring The Range", shorttitle = "STR Pro", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 100, max_bars_back = 5000)

// =============================================================================
// INPUTS
// =============================================================================
grpPivot = "► Pivot Selection & Auto-Detect"
useAuto = input.bool(true, "Use Auto-Detection", group = grpPivot, tooltip = "ON: the engine selects pivots automatically using the mode below. OFF: uses the two Manual Pivot Times.")
autoMode = input.string("Macro Swing Extremes", "Auto-Detect Mode", options = ["Macro Swing Extremes", "Latest Swing Leg", "Raw Extremes"], group = grpPivot, tooltip = "Macro Swing Extremes: highest confirmed swing high + lowest confirmed swing low in the window (structural macro square). Latest Swing Leg: the most recent confirmed swing high and swing low (squares the current leg). Raw Extremes: absolute highest high / lowest low of the window, swing-confirmed or not.")
swingStrength = input.int(10, "Swing Strength (bars each side)", minval = 2, maxval = 50, group = grpPivot, tooltip = "A swing requires this many lower highs (or higher lows) on BOTH sides. Higher = fewer, more significant swings. Note: a swing only confirms this many bars after it prints.")
lookbackWindow = input.int(250, "Auto Lookback Window (bars)", minval = 10, maxval = 5000, group = grpPivot)
highPivotTime = input.time(timestamp("2026-05-10T12:00:00"), "Manual High Pivot Time", group = grpPivot, confirm = true)
lowPivotTime  = input.time(timestamp("2026-05-10T18:00:00"), "Manual Low Pivot Time",  group = grpPivot, confirm = true)

grpOverlay = "► Master Overlays"
showGannBox        = input.bool(true, "Primary Geometric Box", group = grpOverlay)
showMajorNodes     = input.bool(true, "Major Nodes (Gold)", group = grpOverlay)
showMinorNodes     = input.bool(true, "Minor Nodes (Silver)", group = grpOverlay)
showPriceFractions = input.bool(true, "Price Fractions (1/8 + 1/3)", group = grpOverlay)
showTimeDivisions  = input.bool(true, "Time Cycle Divisions", group = grpOverlay)
showGannAngles     = input.bool(true, "Gann Angles", group = grpOverlay)
showAnniversaries  = input.bool(true, "Anniversary Projections (1x, 2x, 3x)", group = grpOverlay)

grpFractions = "► Price Fractions"
showEighths = input.bool(true, "Show Eighths", group = grpFractions)
showThirds  = input.bool(true, "Show Thirds", group = grpFractions)
labelEveryOther = input.bool(true, "Label Every Other Fraction (Clean UI)", group = grpFractions)
fractionColor = input.color(#D4AF37, "Fraction Line (Gold)", group = grpFractions)
midlineColor  = input.color(#E91E63, "Midline 1/2 (Crimson)", group = grpFractions)

grpAngles = "► Gann Angles"
show_1x1 = input.bool(true, "1x1", group = grpAngles, inline = "a1")
show_1x2 = input.bool(true, "1x2", group = grpAngles, inline = "a1")
show_2x1 = input.bool(true, "2x1", group = grpAngles, inline = "a1")
show_1x4 = input.bool(false, "1x4", group = grpAngles, inline = "a2")
show_4x1 = input.bool(true, "4x1", group = grpAngles, inline = "a2")
angleProjections = input.int(3, "Forward Projections (Widths)", minval = 1, maxval = 5, group = grpAngles)
angleColorUp = input.color(color.new(#00E676, 20), "Up Angle (Mint)", group = grpAngles)
angleColorDn = input.color(color.new(#FF5252, 20), "Down Angle (Coral)", group = grpAngles)

grpTime = "► Time Cycles"
timeDivColor = input.color(color.new(#00BCD4, 40), "Time Division (Cyan)", group = grpTime)
timeDivCycles = input.int(3, "Division Cycles (Multipliers)", minval = 1, maxval = 10, group = grpTime)
anniversaryColor = input.color(color.new(#9C27B0, 20), "Anniversary Line (Purple)", group = grpTime)
anniversaryCount = input.int(3, "Anniversary Count", minval = 1, maxval = 8, group = grpTime)

grpAlerts = "► Alerts (create ONE alert: condition = this script → 'Any alert() function call')"
alertsOn       = input.bool(true,  "Master Alert Switch", group = grpAlerts)
alertFractions = input.bool(true,  "Price crossing 1/8 levels", group = grpAlerts)
alertThirds    = input.bool(false, "Price crossing 1/3 levels", group = grpAlerts)
alertRangeBreak = input.bool(true, "Close beyond range High/Low", group = grpAlerts)
alertTimeDiv   = input.bool(true,  "Time division reached", group = grpAlerts)
alertAnniv     = input.bool(true,  "Anniversary bar reached", group = grpAlerts)
alert1x1       = input.bool(false, "Price crossing 1x1 angles", group = grpAlerts)

grpVis = "► Visuals & Dashboard"
showHUD = input.bool(true, "Show Dashboard (HUD)", group = grpVis)
hudPosition = input.string("Top Right", "HUD Position", options = ["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group = grpVis)
hudSize = input.string("Normal", "HUD Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpVis)
showLabels = input.bool(true, "Show Chart Labels", group = grpVis)
labelSize = input.string("small", "Label Size", options = ["tiny", "small", "normal", "large"], group = grpVis)

// =============================================================================
// SWING DETECTION ENGINE
// Confirmed pivots are stored as they print. A swing high/low needs
// `swingStrength` bars on each side, so it confirms with that much lag.
// =============================================================================
var array<float> shPrice = array.new<float>()
var array<int>   shIdx   = array.new<int>()
var array<int>   shTime  = array.new<int>()
var array<float> slPrice = array.new<float>()
var array<int>   slIdx   = array.new<int>()
var array<int>   slTime  = array.new<int>()

float ph = ta.pivothigh(high, swingStrength, swingStrength)
if not na(ph)
    array.push(shPrice, ph)
    array.push(shIdx, bar_index - swingStrength)
    array.push(shTime, time[swingStrength])
    if array.size(shPrice) > 500
        array.shift(shPrice)
        array.shift(shIdx)
        array.shift(shTime)

float pl = ta.pivotlow(low, swingStrength, swingStrength)
if not na(pl)
    array.push(slPrice, pl)
    array.push(slIdx, bar_index - swingStrength)
    array.push(slTime, time[swingStrength])
    if array.size(slPrice) > 500
        array.shift(slPrice)
        array.shift(slIdx)
        array.shift(slTime)

// Most extreme swing within the window (wantMax: highest high, else lowest low)
f_swingExtreme(prices, idxs, times, minIdx, wantMax) =>
    float bestP = na
    int   bestI = na
    int   bestT = na
    if array.size(prices) > 0
        for k = 0 to array.size(prices) - 1
            if array.get(idxs, k) >= minIdx
                float pK = array.get(prices, k)
                if na(bestP) or (wantMax ? pK > bestP : pK < bestP)
                    bestP := pK
                    bestI := array.get(idxs, k)
                    bestT := array.get(times, k)
    [bestP, bestI, bestT]

// Most recent confirmed swing within the window
f_swingLatest(prices, idxs, times, minIdx) =>
    float p = na
    int   i = na
    int   t = na
    int n = array.size(prices)
    if n > 0 and array.get(idxs, n - 1) >= minIdx
        p := array.get(prices, n - 1)
        i := array.get(idxs, n - 1)
        t := array.get(times, n - 1)
    [p, i, t]

// Raw absolute extremes (legacy mode, includes the live bar)
f_rawExtremes(windowBars) =>
    int searchBars = math.min(windowBars, bar_index)
    float maxH = high
    int   maxHOffset = 0
    float minL = low
    int   minLOffset = 0
    if searchBars >= 1
        for i = 1 to searchBars
            if high[i] > maxH
                maxH := high[i]
                maxHOffset := i
            if low[i] < minL
                minL := low[i]
                minLOffset := i
    [maxH, bar_index - maxHOffset, time[maxHOffset], minL, bar_index - minLOffset, time[minLOffset]]

// =============================================================================
// MANUAL PIVOT LOOKUP (nearest bar to each input timestamp)
// =============================================================================
var float liveHighPrice   = na
var int   liveHighIdx     = na
var int   liveHighTime    = na
var float liveLowPrice    = na
var int   liveLowIdx      = na
var int   liveLowTime     = na
var float nearestHighDiff = 1e15
var float nearestLowDiff  = 1e15

float diffH = math.abs(time - highPivotTime)
if diffH < nearestHighDiff
    nearestHighDiff := diffH
    liveHighIdx     := bar_index
    liveHighTime    := time
    liveHighPrice   := high

float diffL = math.abs(time - lowPivotTime)
if diffL < nearestLowDiff
    nearestLowDiff := diffL
    liveLowIdx     := bar_index
    liveLowTime    := time
    liveLowPrice   := low

// =============================================================================
// STATE & DRAWING HELPERS
// =============================================================================
var array<line>  allLines  = array.new<line>()
var array<label> allLabels = array.new<label>()
var array<box>   allBoxes  = array.new<box>()

// Drawings using xloc.bar_index cannot sit more than 500 bars past the last
// bar (Pine runtime error). Helpers below switch a drawing to xloc.bar_time
// when an endpoint crosses that limit, projecting bar indices to timestamps
// at the range's average ms-per-bar (exact on gapless 24/7 charts).
int MAX_FUTURE = 500
var int   g_refIdx   = na
var int   g_refTime  = na
var float g_msPerBar = na

f_idxToTime(idx) =>
    int(math.round(g_refTime + (idx - g_refIdx) * g_msPerBar))

f_labelSize() =>
    switch labelSize
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        => size.small

f_hudPos() =>
    switch hudPosition
        "Top Right"     => position.top_right
        "Top Center"    => position.top_center
        "Top Left"      => position.top_left
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Bottom Right"  => position.bottom_right
        "Bottom Center" => position.bottom_center
        "Bottom Left"   => position.bottom_left
        => position.top_right

f_hudSize() =>
    switch hudSize
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.normal

f_clearAll() =>
    if array.size(allLines) > 0
        for i = 0 to array.size(allLines) - 1
            line.delete(array.get(allLines, i))
        array.clear(allLines)
    if array.size(allLabels) > 0
        for i = 0 to array.size(allLabels) - 1
            label.delete(array.get(allLabels, i))
        array.clear(allLabels)
    if array.size(allBoxes) > 0
        for i = 0 to array.size(allBoxes) - 1
            box.delete(array.get(allBoxes, i))
        array.clear(allBoxes)

f_addLine(x1, y1, x2, y2, col, lstyle, lwidth) =>
    int ix1 = int(math.round(x1))
    int ix2 = int(math.round(x2))
    line ln = na
    if math.max(ix1, ix2) <= bar_index + MAX_FUTURE
        ln := line.new(ix1, y1, ix2, y2, xloc = xloc.bar_index, color = col, style = lstyle, width = lwidth, extend = extend.none)
    else
        ln := line.new(f_idxToTime(ix1), y1, f_idxToTime(ix2), y2, xloc = xloc.bar_time, color = col, style = lstyle, width = lwidth, extend = extend.none)
    array.push(allLines, ln)
    ln

f_addLabel(x, y, txt, col, txtCol, lstyle) =>
    int ix = int(math.round(x))
    label lb = na
    if ix <= bar_index + MAX_FUTURE
        lb := label.new(ix, y, txt, xloc = xloc.bar_index, color = col, textcolor = txtCol, style = lstyle, size = f_labelSize())
    else
        lb := label.new(f_idxToTime(ix), y, txt, xloc = xloc.bar_time, color = col, textcolor = txtCol, style = lstyle, size = f_labelSize())
    array.push(allLabels, lb)
    lb

f_addNode(x, y, col, sz) =>
    int ix = int(math.round(x))
    label lb = na
    if ix <= bar_index + MAX_FUTURE
        lb := label.new(ix, y, "", xloc = xloc.bar_index, color = col, style = label.style_circle, size = sz)
    else
        lb := label.new(f_idxToTime(ix), y, "", xloc = xloc.bar_time, color = col, style = label.style_circle, size = sz)
    array.push(allLabels, lb)
    lb

f_addBox(left, top, right, bottom, bcolor, bgc) =>
    bx = box.new(int(math.round(left)), top, int(math.round(right)), bottom, xloc = xloc.bar_index, border_color = bcolor, border_style = line.style_dashed, bgcolor = bgc)
    array.push(allBoxes, bx)
    bx

// =============================================================================
// MAIN LOGIC
// =============================================================================
if barstate.islast
    f_clearAll()
    float resolvedHigh = na
    int   resolvedHighBarIndex = na
    int   resolvedHighTime = na
    float resolvedLow = na
    int   resolvedLowBarIndex = na
    int   resolvedLowTime = na

    if useAuto
        int minIdx = bar_index - lookbackWindow
        if autoMode == "Raw Extremes"
            [rHP, rHI, rHT, rLP, rLI, rLT] = f_rawExtremes(lookbackWindow)
            resolvedHigh := rHP
            resolvedHighBarIndex := rHI
            resolvedHighTime := rHT
            resolvedLow := rLP
            resolvedLowBarIndex := rLI
            resolvedLowTime := rLT
        else if autoMode == "Latest Swing Leg"
            [sHP, sHI, sHT] = f_swingLatest(shPrice, shIdx, shTime, minIdx)
            [sLP, sLI, sLT] = f_swingLatest(slPrice, slIdx, slTime, minIdx)
            resolvedHigh := sHP
            resolvedHighBarIndex := sHI
            resolvedHighTime := sHT
            resolvedLow := sLP
            resolvedLowBarIndex := sLI
            resolvedLowTime := sLT
        else // Macro Swing Extremes
            [mHP, mHI, mHT] = f_swingExtreme(shPrice, shIdx, shTime, minIdx, true)
            [mLP, mLI, mLT] = f_swingExtreme(slPrice, slIdx, slTime, minIdx, false)
            resolvedHigh := mHP
            resolvedHighBarIndex := mHI
            resolvedHighTime := mHT
            resolvedLow := mLP
            resolvedLowBarIndex := mLI
            resolvedLowTime := mLT
    else
        resolvedHigh := liveHighPrice
        resolvedHighBarIndex := liveHighIdx
        resolvedHighTime := liveHighTime
        resolvedLow := liveLowPrice
        resolvedLowBarIndex := liveLowIdx
        resolvedLowTime := liveLowTime

    bool pivotsValid = not na(resolvedHigh) and not na(resolvedLow) and not na(resolvedHighBarIndex) and not na(resolvedLowBarIndex) and resolvedHigh > resolvedLow and resolvedLow > 0 and resolvedHighBarIndex != resolvedLowBarIndex

    if pivotsValid
        startIdx = math.min(resolvedHighBarIndex, resolvedLowBarIndex)
        endIdx   = math.max(resolvedHighBarIndex, resolvedLowBarIndex)
        int startTime = resolvedHighBarIndex < resolvedLowBarIndex ? resolvedHighTime : resolvedLowTime
        int endTime   = resolvedHighBarIndex < resolvedLowBarIndex ? resolvedLowTime : resolvedHighTime
        priceRange = resolvedHigh - resolvedLow
        barRange = endIdx - startIdx
        
        g_refIdx   := endIdx
        g_refTime  := endTime
        g_msPerBar := (endTime - startTime) * 1.0 / barRange
        totalCycleEndIdx = startIdx + math.round(barRange * timeDivCycles)

        if showGannBox
            f_addBox(startIdx, resolvedHigh, endIdx, resolvedLow, color.new(color.gray, 60), color.new(#1e222d, 80))

        if showMajorNodes or showMinorNodes
            for c = 0 to timeDivCycles - 1
                t25 = startIdx + math.round(barRange * (c + 0.25))
                t50 = startIdx + math.round(barRange * (c + 0.50))
                t75 = startIdx + math.round(barRange * (c + 0.75))
                t100 = startIdx + math.round(barRange * (c + 1.00))
                p25 = resolvedLow + priceRange * 0.25
                p50 = resolvedLow + priceRange * 0.50
                p75 = resolvedLow + priceRange * 0.75
                
                if showMajorNodes
                    f_addNode(t50, p50, color.new(#D4AF37, 15), size.small)
                    f_addNode(t100, p50, color.new(#D4AF37, 15), size.small)
                if showMinorNodes
                    f_addNode(t25, p25, color.new(color.silver, 30), size.tiny)
                    f_addNode(t25, p75, color.new(color.silver, 30), size.tiny)
                    f_addNode(t75, p25, color.new(color.silver, 30), size.tiny)
                    f_addNode(t75, p75, color.new(color.silver, 30), size.tiny)

        if showPriceFractions
            if showEighths
                for i = 1 to 7
                    level = resolvedLow + priceRange * i / 8.0
                    isMid = i == 4
                    col = isMid ? midlineColor : color.new(fractionColor, 30)
                    w = isMid ? 2 : 1
                    f_addLine(startIdx, level, totalCycleEndIdx, level, col, line.style_solid, w)
                    if showLabels and (isMid or not labelEveryOther or i % 2 == 0)
                        f_addLabel(totalCycleEndIdx, level, str.format("{0}/8", i), color.new(color.black, 100), col, label.style_label_left)
            if showThirds
                for i = 1 to 2
                    level = resolvedLow + priceRange * i / 3.0
                    f_addLine(startIdx, level, totalCycleEndIdx, level, color.new(#4DB6AC, 30), line.style_dashed, 1)
                    if showLabels and (not labelEveryOther or i % 2 == 0)
                        f_addLabel(startIdx, level, str.format("{0}/3", i), color.new(color.black, 100), color.new(#4DB6AC, 0), label.style_label_right)
            
            f_addLine(startIdx, resolvedHigh, totalCycleEndIdx, resolvedHigh, color.new(color.gray, 0), line.style_solid, 2)
            f_addLine(startIdx, resolvedLow,  totalCycleEndIdx, resolvedLow,  color.new(color.gray, 0), line.style_solid, 2)

        if showTimeDivisions
            divisions = array.from(0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875)
            labels    = array.from("1/8", "1/4", "3/8", "1/2", "5/8", "3/4", "7/8")
            for c = 0 to timeDivCycles - 1
                for i = 0 to array.size(divisions) - 1
                    frac = array.get(divisions, i)
                    idx = startIdx + math.round(barRange * (c + frac))
                    isMid = frac == 0.5
                    col = isMid ? color.new(#E91E63, 30) : timeDivColor
                    w = isMid ? 2 : 1
                    f_addLine(idx, resolvedLow, idx, resolvedHigh, col, line.style_dashed, w)
                    if showLabels and (isMid or not labelEveryOther or i % 2 == 1)
                        lblTxt = c == 0 ? array.get(labels, i) : str.format("{0} + {1}", c, array.get(labels, i))
                        f_addLabel(idx, resolvedHigh, lblTxt, color.new(color.black, 100), col, label.style_label_down)

        if showAnniversaries
            for i = 1 to anniversaryCount
                idx = endIdx + barRange * i
                f_addLine(idx, resolvedLow - priceRange * 0.1, idx, resolvedHigh + priceRange * 0.1, anniversaryColor, line.style_solid, 2)
                if showLabels
                    f_addLabel(idx, resolvedHigh + priceRange * 0.1, str.format("{0}x", i), color.new(color.black, 100), anniversaryColor, label.style_label_down)

        if showGannAngles
            for pass = 1 to 2
                isFromLow = pass == 1
                pivotIdx = isFromLow ? resolvedLowBarIndex : resolvedHighBarIndex
                pivotPrice = isFromLow ? resolvedLow : resolvedHigh
                projEndIdx = pivotIdx + barRange * angleProjections
                direction = isFromLow ? 1.0 : -1.0
                col = isFromLow ? angleColorUp : angleColorDn
                
                if show_1x1
                    f_addLine(pivotIdx, pivotPrice, projEndIdx, pivotPrice + direction * priceRange * angleProjections * 1.0, col, line.style_solid, 1)
                if show_1x2
                    f_addLine(pivotIdx, pivotPrice, projEndIdx, pivotPrice + direction * priceRange * angleProjections * 0.5, col, line.style_solid, 1)
                if show_2x1
                    f_addLine(pivotIdx, pivotPrice, projEndIdx, pivotPrice + direction * priceRange * angleProjections * 2.0, col, line.style_solid, 1)
                if show_1x4
                    f_addLine(pivotIdx, pivotPrice, projEndIdx, pivotPrice + direction * priceRange * angleProjections * 0.25, col, line.style_solid, 1)
                if show_4x1
                    f_addLine(pivotIdx, pivotPrice, projEndIdx, pivotPrice + direction * priceRange * angleProjections * 4.0, col, line.style_solid, 1)

        if showLabels
            f_addLabel(resolvedHighBarIndex, resolvedHigh, str.format("H {0,number,#.####}", resolvedHigh), color.new(#FF5252, 20), color.white, label.style_label_down)
            f_addLabel(resolvedLowBarIndex,  resolvedLow,  str.format("L {0,number,#.####}", resolvedLow),  color.new(#00E676, 20), color.white, label.style_label_up)

        // =====================================================================
        // ALERTS — evaluated on confirmed bars only, fire in realtime via a
        // single "Any alert() function call" alert created on this script.
        // =====================================================================
        if alertsOn and barstate.isconfirmed
            string ctx = syminfo.ticker + " " + timeframe.period
            
            if alertFractions
                for i = 1 to 7
                    level = resolvedLow + priceRange * i / 8.0
                    if (close[1] < level and close >= level) or (close[1] > level and close <= level)
                        alert(str.format("STR {0}: price crossed {1}/8 level at {2,number,#.####}", ctx, i, level), alert.freq_once_per_bar)
            if alertThirds
                for i = 1 to 2
                    level = resolvedLow + priceRange * i / 3.0
                    if (close[1] < level and close >= level) or (close[1] > level and close <= level)
                        alert(str.format("STR {0}: price crossed {1}/3 level at {2,number,#.####}", ctx, i, level), alert.freq_once_per_bar)
            if alertRangeBreak
                if close[1] <= resolvedHigh and close > resolvedHigh
                    alert(str.format("STR {0}: close above range high {1,number,#.####}", ctx, resolvedHigh), alert.freq_once_per_bar)
                if close[1] >= resolvedLow and close < resolvedLow
                    alert(str.format("STR {0}: close below range low {1,number,#.####}", ctx, resolvedLow), alert.freq_once_per_bar)
            if alertTimeDiv
                aDivs = array.from(0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875)
                aLbls = array.from("1/8", "1/4", "3/8", "1/2", "5/8", "3/4", "7/8")
                for c = 0 to timeDivCycles - 1
                    for k = 0 to array.size(aDivs) - 1
                        if bar_index == startIdx + math.round(barRange * (c + array.get(aDivs, k)))
                            alert(str.format("STR {0}: time division {1} of cycle {2} reached", ctx, array.get(aLbls, k), c + 1), alert.freq_once_per_bar)
            if alertAnniv
                for i = 1 to anniversaryCount
                    if bar_index == endIdx + barRange * i
                        alert(str.format("STR {0}: {1}x range anniversary reached", ctx, i), alert.freq_once_per_bar)
            if alert1x1
                float scaleA = priceRange / barRange
                float upNow  = resolvedLow + (bar_index - resolvedLowBarIndex) * scaleA
                float upPrev = upNow - scaleA
                if (close[1] < upPrev and close >= upNow) or (close[1] > upPrev and close <= upNow)
                    alert(str.format("STR {0}: price crossed ascending 1x1 at {1,number,#.####}", ctx, upNow), alert.freq_once_per_bar)
                float dnNow  = resolvedHigh - (bar_index - resolvedHighBarIndex) * scaleA
                float dnPrev = dnNow + scaleA
                if (close[1] < dnPrev and close >= dnNow) or (close[1] > dnPrev and close <= dnNow)
                    alert(str.format("STR {0}: price crossed descending 1x1 at {1,number,#.####}", ctx, dnNow), alert.freq_once_per_bar)

        if showHUD
            var table infoTable = table.new(f_hudPos(), 2, 7, bgcolor = color.new(#111827, 20), border_width = 1, border_color = color.new(#374151, 50))
            table.set_position(infoTable, f_hudPos())
            scale = priceRange / barRange
            sz = f_hudSize()
            
            table.cell(infoTable, 0, 0, "SQUARING THE RANGE",   text_color = color.white, bgcolor = color.new(#D4AF37, 20), text_size = sz)
            table.cell(infoTable, 1, 0, useAuto ? "AUTO" : "MANUAL", text_color = color.white, bgcolor = color.new(#D4AF37, 20), text_size = sz)
            table.cell(infoTable, 0, 1, "Pivot High",           text_color = color.new(color.white, 30), text_size = sz)
            table.cell(infoTable, 1, 1, str.format("{0,number,#.####}", resolvedHigh), text_color = color.new(#FF5252, 0), text_size = sz)
            table.cell(infoTable, 0, 2, "Pivot Low",            text_color = color.new(color.white, 30), text_size = sz)
            table.cell(infoTable, 1, 2, str.format("{0,number,#.####}", resolvedLow), text_color = color.new(#00E676, 0), text_size = sz)
            table.cell(infoTable, 0, 3, "Price Range",          text_color = color.new(color.white, 30), text_size = sz)
            table.cell(infoTable, 1, 3, str.format("{0,number,#.####}", priceRange), text_color = #D4AF37, text_size = sz)
            table.cell(infoTable, 0, 4, "Time Vector",          text_color = color.new(color.white, 30), text_size = sz)
            table.cell(infoTable, 1, 4, str.format("{0,number,#} Bars", barRange),    text_color = #D4AF37, text_size = sz)
            table.cell(infoTable, 0, 5, "1x1 Scale Ratio",      text_color = color.new(color.white, 30), text_size = sz)
            table.cell(infoTable, 1, 5, str.format("{0,number,#.####}", scale), text_color = #00BCD4, text_size = sz)
            table.cell(infoTable, 0, 6, "Detection",            text_color = color.new(color.white, 30), text_size = sz)
            table.cell(infoTable, 1, 6, useAuto ? autoMode : "Manual Times", text_color = color.new(color.white, 0), text_size = sz)

    else
        f_addLabel(bar_index, close, "Awaiting pivots.\nLower Swing Strength, widen the Lookback Window,\nor set Manual Pivot Times in Settings.", color.new(#D4AF37, 0), color.black, label.style_label_left)
````
