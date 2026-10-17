# HH/LL Trendlines [twr]

- url: https://www.tradingview.com/script/JO3bQn1C-HH-LL-Trendlines-twr/
- type: indicator
- pine_id: PUB;39992a7b901b4a5497898d9d292af30c
- version: 2.0

## Description

Automatically detects swing structure (HH/HL/LH/LL) using pivot highs/lows, labels each swing point, and — the key feature — draws trendlines connecting same-type consecutive pivots: LH→LH on the high side, HL→HL on the low side. This visualizes the two "structure lines" traders watch for trend continuation and potential breaks.
[b]How it works[/b]
[list]
[*]Pivot detection & classification
[*]Uses ta.pivothigh()/ta.pivotlow() with a user-defined Swing Length (fractal-style, symmetric lookback/lookforward)
[*]Each new swing high is compared to the prior swing high: higher → labeled HH (bullish, green), lower → labeled LH (bearish, red)
[*]Each new swing low is compared to the prior swing low: lower → labeled LL (bearish, red), higher → labeled HL (bullish, green)
[*]First pivot on each side gets a neutral "x" label since there's nothing to compare against yet
[*]
[/list]
[image]https://www.tradingview.com/x/kCNmuUdO/[/image]
[b]Trendline logic[/b]
[list]
[*]Only connects pivots of the same classification — so a LH connects to the previous LH (skipping over any HH in between), and a HL connects to the previous HL. This produces clean descending-resistance / ascending-support structure lines rather than zigzagging between every pivot.
[*]Lines are capped per side (Max Trend Lines Shown) using an array-based pool with oldest-first trimming, so the chart doesn't get cluttered over time
[/list]
[b]Live projection[/b]
[list]
[*]If Project Lines Forward is enabled, each line's slope is recalculated every bar and extended to the current bar (getProjectedY()), so the structure line behaves like a live trend channel boundary rather than a static segment frozen at the two pivot points
[*]Optional Remove Line Once Price Crosses It will auto-delete a line when price closes (or wicks, depending on Cross Source) through the projected level — useful for treating the line as an invalidated trendline break
[/list]
[b]Inputs summary[/b]
[list]
[*]Structure: swing length, label toggle
[*]Trend Lines: enable high/low connections independently, line width/style, max lines per side
[*]Projection: forward extension toggle, cross-removal toggle, cross source (Close vs High/Low)
[*]Colors: bullish/bearish color customization
[/list]

## Source Code

````pine
//@version=6
indicator('HH/LL Trendlines [twr]', overlay = true, max_lines_count = 500, max_labels_count = 500)

// ============================================================================
// INPUTS
// ============================================================================
gStruct = 'Structure'
lenMajor = input.int(14, 'Swing Length', minval = 1, group = gStruct, tooltip = 'Fractal pivot length used for HH/HL/LH/LL swing detection')
showLabels = input.bool(true, 'Show HH/HL/LH/LL Labels', group = gStruct)

gTrend = 'Trend Lines'
showTrendHigh = input.bool(true, 'Connect Highs (HH/LH)', inline = 'lt1', group = gTrend)
showTrendLow = input.bool(true, 'Connect Lows (HL/LL)', inline = 'lt2', group = gTrend)
trendWidth = input.int(1, 'Line Width', minval = 1, inline = 'lt3', group = gTrend)
trendStyle = input.string('Solid', 'Line Style', options = ['Solid', 'Dashed', 'Dotted'], inline = 'lt3', group = gTrend)
maxTrendLines = input.int(1, 'Max Trend Lines Shown (each side)', minval = 1, group = gTrend, tooltip = 'Independently caps how many high-connect & low-connect lines stay on the chart')

gProj = 'Trend Line Projection'
extendLines = input.bool(true, 'Project Lines Forward to Current Bar', group = gProj, tooltip = 'Recomputes the line\'s slope every bar and stretches it to the current bar, instead of leaving it fixed between the two pivots')
removeOnCross = input.bool(false, 'Remove Line Once Price Crosses It', group = gProj)
crossSource = input.string('Close', 'Cross Source', options = ['Close', 'High/Low'], group = gProj)

gZigzag = 'Live Zigzag'
showZigzag = input.bool(true, 'Show Zigzag', group = gZigzag)
zigzagColor = input.color(color.new(color.gray, 0), 'Confirmed Segment Color', group = gZigzag)
liveZigzagColor = input.color(color.new(color.gray, 0), 'Live Segment Color', group = gZigzag)
zigzagWidth = input.int(1, 'Zigzag Width', minval = 1, group = gZigzag)
liveStyle = input.string('Dotted', 'Live Segment Style', options = ['Solid', 'Dashed', 'Dotted'], group = gZigzag, tooltip = 'Style used for the developing (unconfirmed) leg that follows price in real time until the next pivot locks in')
maxZigzagLegs = input.int(50, 'Max Zigzag Legs Kept', minval = 2, group = gZigzag)

gColor = 'Colors'
bullColor = input.color(color.new(#089981, 0), 'Bullish', inline = 'c1', group = gColor)
bearColor = input.color(color.new(#F23645, 0), 'Bearish', inline = 'c1', group = gColor)

// ============================================================================
// STATE
// ============================================================================
var array<float> swHighVal = array.new_float()
var array<int> swHighIdx = array.new_int()
var array<float> swLowVal = array.new_float()
var array<int> swLowIdx = array.new_int()

var array<line> highLineArr = array.new_line() // down-sloping lines connecting LHs
var array<line> lowLineArr = array.new_line() // up-sloping lines connecting HLs

// live zigzag state
var array<int> zzIdx = array.new_int()
var array<float> zzVal = array.new_float()
var array<bool> zzIsHigh = array.new_bool()
var array<line> zzLines = array.new_line()
var line liveZZLine = na
var float runExtreme = na
var int runExtremeIdx = na

lineStyle() =>
    switch trendStyle
        'Solid' => line.style_solid
        'Dashed' => line.style_dashed
        'Dotted' => line.style_dotted
        => line.style_solid

liveLineStyle() =>
    switch liveStyle
        'Solid' => line.style_solid
        'Dashed' => line.style_dashed
        'Dotted' => line.style_dotted
        => line.style_dashed

trim(arrF, arrI, maxKeep) =>
    if array.size(arrF) > maxKeep
        array.shift(arrF)
        array.shift(arrI)

trimLines(arr, maxKeep) =>
    if array.size(arr) > maxKeep
        line.delete(array.shift(arr))

// Recompute the y-value of a line's slope projected out to the current bar_index
getProjectedY(ln) =>
    x1 = line.get_x1(ln)
    y1 = line.get_y1(ln)
    x2 = line.get_x2(ln)
    y2 = line.get_y2(ln)
    slope = (y2 - y1) / (x2 - x1)
    y2 + slope * (bar_index - x2)

// Push a confirmed pivot into the zigzag. Same-direction pivots replace the
// last point if more extreme (extends the current leg). Opposite-direction
// pivots finalize a new fixed segment and start a fresh developing leg.
// Returns true when a new alternating leg was started (caller resets the
// running-extreme tracker), since functions can't reassign global vars.
updateZigzag(idx, val, isHigh) =>
    bool startedNewLeg = false
    int n = array.size(zzIdx)
    if n == 0
        array.push(zzIdx, idx)
        array.push(zzVal, val)
        array.push(zzIsHigh, isHigh)
    else
        bool lastIsHigh = array.get(zzIsHigh, n - 1)
        float lastVal = array.get(zzVal, n - 1)
        if isHigh == lastIsHigh
            bool moreExtreme = isHigh ? val > lastVal : val < lastVal
            if moreExtreme
                array.set(zzIdx, n - 1, idx)
                array.set(zzVal, n - 1, val)
                if array.size(zzLines) > 0
                    line.set_xy2(array.get(zzLines, array.size(zzLines) - 1), idx, val)
        else
            int prevIdx = array.get(zzIdx, n - 1)
            float prevVal = array.get(zzVal, n - 1)
            line newLn = line.new(prevIdx, prevVal, idx, val, color = zigzagColor, width = zigzagWidth, style = line.style_solid)
            array.push(zzLines, newLn)
            array.push(zzIdx, idx)
            array.push(zzVal, val)
            array.push(zzIsHigh, isHigh)
            if array.size(zzLines) > maxZigzagLegs
                line.delete(array.shift(zzLines))
                array.shift(zzIdx)
                array.shift(zzVal)
                array.shift(zzIsHigh)
            startedNewLeg := true
    startedNewLeg

// ============================================================================
// PIVOT DETECTION
// ============================================================================
ph = ta.pivothigh(lenMajor, lenMajor)
pl = ta.pivotlow(lenMajor, lenMajor)

// ============================================================================
// NEW SWING HIGH -> classify HH/LH, connect to previous swing high
// ============================================================================
if not na(ph)
    int phIdx = bar_index - lenMajor
    bool hasPrev = array.size(swHighVal) >= 1
    float prevH = hasPrev ? array.get(swHighVal, array.size(swHighVal) - 1) : na
    int prevHIdx = hasPrev ? array.get(swHighIdx, array.size(swHighIdx) - 1) : na
    bool isHH = hasPrev and ph > prevH

    if showLabels
        string txt = not hasPrev ? 'x' : isHH ? 'HH' : 'LH'
        color col = not hasPrev ? color.gray : isHH ? bullColor : bearColor
        label.new(phIdx, ph, txt, style = label.style_label_down, color = color.new(color.white, 100), textcolor = col, size = size.small)

    if showTrendHigh and hasPrev and not isHH
        line hln = line.new(prevHIdx, prevH, phIdx, ph, color = bearColor, width = trendWidth, style = lineStyle())
        array.push(highLineArr, hln)
        trimLines(highLineArr, maxTrendLines)

    if showZigzag and updateZigzag(phIdx, ph, true)
        runExtreme := na
        runExtremeIdx := na

    array.push(swHighVal, ph)
    array.push(swHighIdx, phIdx)
    trim(swHighVal, swHighIdx, 20)

// ============================================================================
// NEW SWING LOW -> classify HL/LL, connect to previous swing low
// ============================================================================
if not na(pl)
    int plIdx = bar_index - lenMajor
    bool hasPrev = array.size(swLowVal) >= 1
    float prevL = hasPrev ? array.get(swLowVal, array.size(swLowVal) - 1) : na
    int prevLIdx = hasPrev ? array.get(swLowIdx, array.size(swLowIdx) - 1) : na
    bool isLL = hasPrev and pl < prevL

    if showLabels
        string txt = not hasPrev ? 'x' : isLL ? 'LL' : 'HL'
        color col = not hasPrev ? color.gray : isLL ? bearColor : bullColor
        label.new(plIdx, pl, txt, style = label.style_label_up, color = color.new(color.white, 100), textcolor = col, size = size.small)

    if showTrendLow and hasPrev and not isLL
        line lln = line.new(prevLIdx, prevL, plIdx, pl, color = bullColor, width = trendWidth, style = lineStyle())
        array.push(lowLineArr, lln)
        trimLines(lowLineArr, maxTrendLines)

    if showZigzag and updateZigzag(plIdx, pl, false)
        runExtreme := na
        runExtremeIdx := na

    array.push(swLowVal, pl)
    array.push(swLowIdx, plIdx)
    trim(swLowVal, swLowIdx, 20)

// ============================================================================
// PROJECT + AUTO-REMOVE LINES EACH BAR (QuantVue-style behavior)
// ============================================================================
// Down-sloping lines connecting swing highs (resistance)
if extendLines and array.size(highLineArr) > 0
    for i = array.size(highLineArr) - 1 to 0 by 1
        ln = array.get(highLineArr, i)
        projY = getProjectedY(ln)
        line.set_xy2(ln, bar_index, projY)
        src = crossSource == 'Close' ? close : high
        if removeOnCross and src > projY
            line.delete(ln)
            array.remove(highLineArr, i)

// Up-sloping lines connecting swing lows (support)
if extendLines and array.size(lowLineArr) > 0
    for i = array.size(lowLineArr) - 1 to 0 by 1
        ln = array.get(lowLineArr, i)
        projY = getProjectedY(ln)
        line.set_xy2(ln, bar_index, projY)
        src = crossSource == 'Close' ? close : low
        if removeOnCross and src < projY
            line.delete(ln)
            array.remove(lowLineArr, i)

// ============================================================================
// LIVE ZIGZAG LEG (follows price in real time until the next pivot confirms)
// ============================================================================
if showZigzag and array.size(zzIdx) > 0
    bool lastIsHigh = array.get(zzIsHigh, array.size(zzIsHigh) - 1)
    // track the running extreme (highest high / lowest low) since the last confirmed pivot
    if lastIsHigh
        if na(runExtreme) or low < runExtreme
            runExtreme := low
            runExtremeIdx := bar_index
    else
        if na(runExtreme) or high > runExtreme
            runExtreme := high
            runExtremeIdx := bar_index

    int lastIdx = array.get(zzIdx, array.size(zzIdx) - 1)
    float lastVal = array.get(zzVal, array.size(zzVal) - 1)
    int liveX2 = na(runExtreme) ? bar_index : runExtremeIdx
    float liveY2 = na(runExtreme) ? close : runExtreme

    if not na(liveZZLine)
        line.delete(liveZZLine)
    liveZZLine := line.new(lastIdx, lastVal, liveX2, liveY2, color = liveZigzagColor, width = zigzagWidth, style = liveLineStyle())
````
