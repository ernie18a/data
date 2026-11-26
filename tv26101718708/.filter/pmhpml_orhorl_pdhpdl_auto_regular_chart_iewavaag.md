# PMH/PML + ORH/ORL + PDH/PDL Auto Regular Chart

- url: https://www.tradingview.com/script/IEWAVaaG-PMH-PML-ORH-ORL-PDH-PDL-Auto-Regular-Chart/
- type: indicator
- pine_id: PUB;dfc2e04e91fd47d3b8a0f3e3a3d1b5f4
- version: 2.0

## Description

Marks all levels for PMH, PML, ORH, ORL (15 mins) and PDH, and PDL. All levels appear after 15 mins

## Source Code

````pine
//@version=6
indicator("PMH/PML + ORH/ORL + PDH/PDL Auto Regular Chart", overlay=true, max_lines_count=500, max_labels_count=500)

// Sessions
premarketSession    = input.session("0400-0929", "Premarket Session")
openingRangeSession = input.session("0930-0945", "Opening Range")
regularSession      = input.session("0930-1600", "Regular Session")

// Visibility
showPMLevels       = input.bool(true, "Premarket Levels PMH/PML", group="Level Visibility")
showORLevels       = input.bool(true, "Opening Range Levels ORH/ORL", group="Level Visibility")
showPDLevels       = input.bool(true, "Previous Day Levels PDH/PDL", group="Level Visibility")
showPreviousLevels = input.bool(false, "Previous days levels", group="Level Visibility")
daysBack           = input.int(10, "Previous Days to Show", minval=1, maxval=365, group="Level Visibility")

// Style
lineTransparency = input.int(65, "Line Transparency", minval=0, maxval=100, group="Style")
lineWidth        = input.int(2, "Line Width", minval=1, maxval=5, group="Style")
labelOffsetTicks = input.int(10, "Label Offset Below Line", minval=0, group="Style")

// NEW: Color customization
bullColorInput = input.color(color.rgb(99, 216, 103), "High Level Color", group="Style")
bearColorInput = input.color(color.rgb(250, 145, 145), "Low Level Color", group="Style")

greenLine = color.new(bullColorInput, lineTransparency)
redLine   = color.new(bearColorInput, lineTransparency)

// Force extended-hours data
extendedTicker = ticker.modify(syminfo.tickerid, session=session.extended)

// Premarket levels
f_pm_levels() =>
    var float pmh = na
    var float pml = na

    newDayPM = ta.change(time("D")) != 0
    inPM = not na(time("1", premarketSession))

    if newDayPM
        pmh := na
        pml := na

    if inPM
        pmh := na(pmh) ? high : math.max(pmh, high)
        pml := na(pml) ? low : math.min(pml, low)

    [pmh, pml]

[pmh, pml] = request.security(extendedTicker, "1", f_pm_levels(), barmerge.gaps_off, barmerge.lookahead_off)

// Previous REGULAR session high/low only
f_rth_prev_levels() =>
    var float rthHigh = na
    var float rthLow  = na
    var float prevHigh = na
    var float prevLow  = na

    newDayRTH = ta.change(time("D")) != 0
    inRTH_1m = not na(time("1", regularSession))

    if newDayRTH
        prevHigh := rthHigh
        prevLow  := rthLow
        rthHigh := na
        rthLow  := na

    if inRTH_1m
        rthHigh := na(rthHigh) ? high : math.max(rthHigh, high)
        rthLow  := na(rthLow) ? low : math.min(rthLow, low)

    [prevHigh, prevLow]

[pdh, pdl] = request.security(extendedTicker, "1", f_rth_prev_levels(), barmerge.gaps_off, barmerge.lookahead_off)

// Session logic
inOR  = not na(time(timeframe.period, openingRangeSession))
inRTH = not na(time(timeframe.period, regularSession))
newDay = ta.change(time("D")) != 0
rthOpen = inRTH and not inRTH[1]

// Opening range values
var float orh = na
var float orl = na
var bool morningLevelsDrawn = false
var bool orLevelsDrawn = false

if newDay
    orh := na
    orl := na
    morningLevelsDrawn := false
    orLevelsDrawn := false

if inOR
    orh := na(orh) ? high : math.max(orh, high)
    orl := na(orl) ? low : math.min(orl, low)

// Time anchors
startTime = timestamp(syminfo.timezone, year, month, dayofmonth, 9, 30)
endTime   = timestamp(syminfo.timezone, year, month, dayofmonth, 16, 0)
midTime   = timestamp(syminfo.timezone, year, month, dayofmonth, 12, 45)

f_labelY(level) =>
    level - syminfo.mintick * labelOffsetTicks

// Store drawn objects
var line[]  allLines  = array.new_line()
var label[] allLabels = array.new_label()

f_clearLevels() =>
    if array.size(allLines) > 0
        for i = 0 to array.size(allLines) - 1
            line.delete(array.get(allLines, i))
        array.clear(allLines)

    if array.size(allLabels) > 0
        for i = 0 to array.size(allLabels) - 1
            label.delete(array.get(allLabels, i))
        array.clear(allLabels)

// Clear old levels at 9:30 open when previous days are hidden
if rthOpen and not showPreviousLevels
    f_clearLevels()

// Most recent visible trading day logic
lastDayTime = timestamp(syminfo.timezone, year(last_bar_time), month(last_bar_time), dayofmonth(last_bar_time), 0, 0)
thisDayTime = timestamp(syminfo.timezone, year, month, dayofmonth, 0, 0)

isMostRecentTradingDay = thisDayTime == lastDayTime
daysAgo = math.floor((lastDayTime - thisDayTime) / 86400000)

shouldDrawDay = isMostRecentTradingDay or (showPreviousLevels and daysAgo >= 1 and daysAgo <= daysBack)

// Draw function
f_drawLevel(_level, _name, _color) =>
    ln = line.new(startTime, _level, endTime, _level, xloc=xloc.bar_time, color=_color, width=lineWidth)
    lb = label.new(midTime, f_labelY(_level), _name, xloc=xloc.bar_time, style=label.style_none, textcolor=color.white, size=size.small)

    array.push(allLines, ln)
    array.push(allLabels, lb)

// Draw PMH/PML + PDH/PDL after RTH starts
morningLevelsReady = inRTH and not morningLevelsDrawn and (not na(pmh) or not na(pml) or not na(pdh) or not na(pdl))

if morningLevelsReady
    if shouldDrawDay
        if showPMLevels and not na(pmh)
            f_drawLevel(pmh, "PMH", greenLine)

        if showPMLevels and not na(pml)
            f_drawLevel(pml, "PML", redLine)

        if showPDLevels and not na(pdh)
            f_drawLevel(pdh, "PDH", greenLine)

        if showPDLevels and not na(pdl)
            f_drawLevel(pdl, "PDL", redLine)

    morningLevelsDrawn := true

// Draw ORH/ORL after opening range ends
openingRangeDone = not inOR and inRTH and not orLevelsDrawn and not na(orh) and not na(orl)

if openingRangeDone
    if shouldDrawDay and showORLevels
        f_drawLevel(orh, "ORH", greenLine)
        f_drawLevel(orl, "ORL", redLine)

    orLevelsDrawn := true
````
