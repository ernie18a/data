# Volume Profile -  Accurate

- url: https://www.tradingview.com/script/bP1PJ6LT-Volume-Profile-Accurate/
- type: indicator
- pine_id: PUB;86a27ead50b444f2b0427443cf2bfaf5
- version: 1.0

## Description

Core Architecture
1. Lower-Timeframe Precision Engine Traditional volume profiles on TradingView can be inaccurate because they guess the volume distribution within a daily candle. This script actually pulls raw data from a lower Source TF (default 5-minute) using request.security_lower_tf and mathematically reconstructs the exact volume traded at every single price tick for the entire day.

2. The Histogram (The Profile itself) It divides the entire price range of the period into a set number of horizontal rows (default 24). It then sorts the lower timeframe volume into these rows, painting a histogram (horizontal bars) on the side of the chart.

Key Trading Features
1. Point of Control (POC) The script mathematically isolates the single row with the absolute highest traded volume for the period.

Action: It projects a solid red line across the chart at this exact price level. The POC acts as the ultimate "fair value" price where buyers and sellers agreed the most, making it a massive magnet for future price action and a strong support/resistance level.
2. Value Area (VA) It calculates the core range where the majority of the trading took place (default is 68% of all volume, representing one standard deviation).

Action: It plots the Value Area High (VAH) and Value Area Low (VAL) as blue lines, and dynamically fills the background between them. Trading outside the Value Area represents an imbalance, while trading inside it represents balance.
3. Advanced Node Detection (HVN & LVN) This is where the script shines. It doesn't just plot the profile; it uses an algorithm to scan the shape of the profile and identify specific structural anomalies:

HVN (High Volume Nodes): Peaks in the profile (other than the POC). The script automatically draws red dashed lines and boxes at these levels. They act as localized support/resistance ledges.
LVN (Low Volume Nodes): Valleys or "gaps" in the profile where price moved so fast that almost zero volume was traded.
LVN Areas: The script goes a step further and intelligently groups adjacent LVNs together to create an "LVN Area" box (default Lime Green). Because there is no historical volume here to stop the price, if price enters an LVN Area, it will usually slice right through it like a hot knife 
through butter.

Visual Control
It uses Pine Script's array-based object management (array<box>, array<line>) to dynamically clean up and redraw the profile flawlessly on every tick. You have full control in the settings over where the profile draws (Left/Right), its width, the color of the Value area vs outside the Value area, and toggles for every single specific node.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Copyright Greymyst

//@version=6
indicator("Volume Profile", "VP", true, max_bars_back = 5000, max_boxes_count = 500, max_lines_count = 400, max_labels_count = 250, dynamic_requests = true)

f_clearBoxes(array<box> boxes) =>
    boxCount = array.size(boxes)
    if boxCount > 0
        for i = 0 to boxCount - 1
            box.delete(array.get(boxes, i))
    array.clear(boxes)

f_clearLines(array<line> lines) =>
    lineCount = array.size(lines)
    if lineCount > 0
        for i = 0 to lineCount - 1
            line.delete(array.get(lines, i))
    array.clear(lines)

f_clearLabels(array<label> labels) =>
    labelCount = array.size(labels)
    if labelCount > 0
        for i = 0 to labelCount - 1
            label.delete(array.get(labels, i))
    array.clear(labels)

f_setLine(line id, bool showLine, int x1, float y1, int x2, float y2, color lineColor, int lineWidth) =>
    line result = id

    if showLine
        if na(result)
            result := line.new(x1 = x1, y1 = y1, x2 = x2, y2 = y2, xloc = xloc.bar_time, extend = extend.none, color = lineColor, style = line.style_solid, width = lineWidth)
        else
            line.set_xy1(result, x1, y1)
            line.set_xy2(result, x2, y2)
            line.set_color(result, lineColor)
            line.set_width(result, lineWidth)
    else if not na(result)
        line.delete(result)
        result := na

    result

groupVolumeProfile = "Single Volume Profile"

profilePeriodTf   = input.timeframe("1D", "Profile Period TF", group = groupVolumeProfile, tooltip = "Completed period used for the profile. For previous day profile, keep this on 1D.")
sourceTf          = input.timeframe("5", "Source TF For Calculation", group = groupVolumeProfile, tooltip = "All profile, LVN, and HVN calculations use this timeframe and are shown unchanged on every chart timeframe.")
regularSess       = input.bool(false, "Use Regular Session Periods", group = groupVolumeProfile, tooltip = "Uses regular session boundaries when the symbol supports them.")
volumeProfile     = input.bool(true, "Volume Profile", inline = "vp", group = groupVolumeProfile)
totalVolumeColor  = input.color(color.new(color.orange, 50), "", inline = "vp", group = groupVolumeProfile)
vaVolumeColor     = input.color(color.new(color.gray, 50), "", inline = "vp", group = groupVolumeProfile)
isValueArea       = input.float(68, "Value Area Volume %", minval = 0, maxval = 100, group = groupVolumeProfile) / 100
profileLevels     = input.int(24, "Number Of Rows", minval = 10, maxval = 100, step = 1, group = groupVolumeProfile)
profilePlacement  = input.string("Left", "Placement", options = ["Right", "Left", "Next Period"], group = groupVolumeProfile)
profileWidth      = input.int(50, "Profile Width %", minval = 0, maxval = 100, group = groupVolumeProfile) / 100
pointOfControl    = input.bool(true, "Point Of Control (POC)", inline = "poc", group = groupVolumeProfile)
pocColor          = input.color(color.new(color.red, 0), "", inline = "poc", group = groupVolumeProfile)
pocWidth          = input.int(2, "Width", inline = "poc", group = groupVolumeProfile)
valueAreaHigh     = input.bool(true, "Value Area High (VAH)", inline = "vah", group = groupVolumeProfile)
vahColor          = input.color(color.new(color.blue, 0), "", inline = "vah", group = groupVolumeProfile)
valueAreaLow      = input.bool(true, "Value Area Low (VAL)", inline = "val", group = groupVolumeProfile)
valColor          = input.color(color.new(color.blue, 0), "", inline = "val", group = groupVolumeProfile)
vaBackground      = input.bool(true, "Background Fill Of Value Area", inline = "vbg", group = groupVolumeProfile)
vaBackgroundColor = input.color(color.new(color.blue, 90), "", inline = "vbg", group = groupVolumeProfile)
backgroundFill    = input.bool(true, "Background Fill Of Profile Range", inline = "bg", group = groupVolumeProfile)
backgroundColor   = input.color(color.new(color.blue, 95), "", inline = "bg", group = groupVolumeProfile)
showLvn           = input.bool(true, "Show LVN", group = groupVolumeProfile)
showHvn           = input.bool(true, "Show HVN", group = groupVolumeProfile)
showLvnAreas      = input.bool(true, "Show LVN Areas", group = groupVolumeProfile)
filterMinorNodes  = input.bool(true, "Filter Minor LVN/HVN", group = groupVolumeProfile)

sourceTfSeconds = timeframe.in_seconds(sourceTf)
chartTfSeconds = timeframe.in_seconds()

if na(sourceTfSeconds) or sourceTfSeconds <= 0 or na(chartTfSeconds) or chartTfSeconds <= 0
    runtime.error("Use time-based chart and source timeframes.")

sourceBarMs = int(math.round(sourceTfSeconds * 1000.0))
chartUsesLowerTfArrays = chartTfSeconds > sourceTfSeconds

var int activePeriodKey = na
var array<int> activeTimes = array.new_int()
var array<float> activeHighs = array.new_float()
var array<float> activeLows = array.new_float()
var array<float> activeVolumes = array.new_float()

var int previousPeriodStart = na
var int previousPeriodEnd = na
var array<int> previousTimes = array.new_int()
var array<float> previousHighs = array.new_float()
var array<float> previousLows = array.new_float()
var array<float> previousVolumes = array.new_float()

array<int> sourceTimes = array.new_int()
array<float> sourceHighs = array.new_float()
array<float> sourceLows = array.new_float()
array<float> sourceVolumes = array.new_float()
array<int> sourcePeriodKeys = array.new_int()

if chartUsesLowerTfArrays
    sourceTimes := request.security_lower_tf(syminfo.tickerid, sourceTf, time)
    sourceHighs := request.security_lower_tf(syminfo.tickerid, sourceTf, high)
    sourceLows := request.security_lower_tf(syminfo.tickerid, sourceTf, low)
    sourceVolumes := request.security_lower_tf(syminfo.tickerid, sourceTf, volume)
    sourcePeriodKeys := regularSess ? request.security_lower_tf(syminfo.tickerid, sourceTf, time(profilePeriodTf, session.regular)) : request.security_lower_tf(syminfo.tickerid, sourceTf, time(profilePeriodTf))
else
    srcTime = request.security(syminfo.tickerid, sourceTf, time, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
    srcTimePrev = request.security(syminfo.tickerid, sourceTf, time[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
    srcHighPrev = request.security(syminfo.tickerid, sourceTf, high[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
    srcLowPrev = request.security(syminfo.tickerid, sourceTf, low[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
    srcVolumePrev = request.security(syminfo.tickerid, sourceTf, volume[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
    srcPeriodKeyPrev = regularSess ? request.security(syminfo.tickerid, sourceTf, time(profilePeriodTf, session.regular)[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off) : request.security(syminfo.tickerid, sourceTf, time(profilePeriodTf)[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
    newSourceBar = ta.change(srcTime) != 0

    if newSourceBar and not na(srcTimePrev) and not na(srcPeriodKeyPrev)
        array.push(sourceTimes, srcTimePrev)
        array.push(sourceHighs, srcHighPrev)
        array.push(sourceLows, srcLowPrev)
        array.push(sourceVolumes, srcVolumePrev)
        array.push(sourcePeriodKeys, srcPeriodKeyPrev)

sourceBarsToProcess = array.size(sourceTimes)

if sourceBarsToProcess > 0
    for sourceIndex = 0 to sourceBarsToProcess - 1
        srcBarTime = array.get(sourceTimes, sourceIndex)
        srcBarHigh = array.get(sourceHighs, sourceIndex)
        srcBarLow = array.get(sourceLows, sourceIndex)
        srcBarVolume = array.get(sourceVolumes, sourceIndex)
        srcPeriodKey = array.get(sourcePeriodKeys, sourceIndex)

        if not na(srcBarTime) and not na(srcPeriodKey)
            if na(activePeriodKey)
                activePeriodKey := srcPeriodKey

            if srcPeriodKey != activePeriodKey and array.size(activeTimes) > 0
                previousTimes := array.copy(activeTimes)
                previousHighs := array.copy(activeHighs)
                previousLows := array.copy(activeLows)
                previousVolumes := array.copy(activeVolumes)
                previousPeriodStart := array.get(previousTimes, 0)
                previousPeriodEnd := array.get(previousTimes, array.size(previousTimes) - 1) + sourceBarMs

                array.clear(activeTimes)
                array.clear(activeHighs)
                array.clear(activeLows)
                array.clear(activeVolumes)
                activePeriodKey := srcPeriodKey

            if srcPeriodKey != activePeriodKey and array.size(activeTimes) == 0
                activePeriodKey := srcPeriodKey

            array.push(activeTimes, srcBarTime)
            array.push(activeHighs, srcBarHigh)
            array.push(activeLows, srcBarLow)
            array.push(activeVolumes, srcBarVolume)

var array<box> profileBoxes = array.new_box()
var line pocLine = na
var line vahLine = na
var line valLine = na
var linefill vaFill = na
var array<line> lvnLines = array.new_line()
var array<box> lvnBoxes = array.new_box()
var array<label> lvnLabels = array.new_label()
var array<box> lvnAreaBoxes = array.new_box()
var array<label> lvnAreaLabels = array.new_label()
var array<line> hvnLines = array.new_line()
var array<box> hvnBoxes = array.new_box()
var array<label> hvnLabels = array.new_label()

if barstate.islast
    f_clearBoxes(profileBoxes)
    f_clearLines(lvnLines)
    f_clearBoxes(lvnBoxes)
    f_clearLabels(lvnLabels)
    f_clearBoxes(lvnAreaBoxes)
    f_clearLabels(lvnAreaLabels)
    f_clearLines(hvnLines)
    f_clearBoxes(hvnBoxes)
    f_clearLabels(hvnLabels)

    hasPreviousProfile = array.size(previousTimes) > 0 and not na(previousPeriodStart) and not na(previousPeriodEnd)

    if hasPreviousProfile
        priceHighest = array.max(previousHighs)
        priceLowest = array.min(previousLows)
        priceRange = priceHighest - priceLowest
        safeRange = priceRange > 0 ? priceRange : syminfo.mintick * profileLevels
        priceStep = safeRange / profileLevels
        volumeStorage = array.new_float(profileLevels, 0.0)
        previousBarCount = array.size(previousTimes)

        for barIndex = 0 to previousBarCount - 1
            candleHigh = array.get(previousHighs, barIndex)
            candleLow = array.get(previousLows, barIndex)
            candleVolume = nz(array.get(previousVolumes, barIndex))
            candleSize = math.max(candleHigh - candleLow, syminfo.mintick)

            for level = 0 to profileLevels - 1
                levelLow = priceLowest + level * priceStep
                levelHigh = levelLow + priceStep
                allocatedVolume = 0.0

                if candleHigh >= levelLow and candleLow < levelHigh
                    if candleHigh <= levelHigh and candleLow >= levelLow
                        allocatedVolume := candleVolume
                    else if candleHigh >= levelHigh and candleLow <= levelLow
                        allocatedVolume := candleVolume * (priceStep / candleSize)
                    else if candleHigh >= levelHigh
                        allocatedVolume := candleVolume * ((levelHigh - candleLow) / candleSize)
                    else if candleLow <= levelLow
                        allocatedVolume := candleVolume * ((candleHigh - levelLow) / candleSize)

                if allocatedVolume > 0
                    array.set(volumeStorage, level, array.get(volumeStorage, level) + allocatedVolume)

        maxVolume = array.max(volumeStorage)
        rowWidths = array.new_int(profileLevels, 0)
        lowestNonZeroWidth = int(1e9)
        highestDrawnWidth = 0

        if maxVolume > 0
            for level = 0 to profileLevels - 1
                levelVolume = array.get(volumeStorage, level)
                widthBars = levelVolume > 0 ? math.max(1, int(math.round(levelVolume / maxVolume * previousBarCount * profileWidth))) : 0
                array.set(rowWidths, level, widthBars)

                if widthBars > 0
                    lowestNonZeroWidth := math.min(lowestNonZeroWidth, widthBars)
                    highestDrawnWidth := math.max(highestDrawnWidth, widthBars)

        pocLevel = array.indexof(volumeStorage, maxVolume)
        targetVolume = array.sum(volumeStorage) * isValueArea
        valueAreaVolume = array.get(volumeStorage, pocLevel)
        levelAbovePoc = pocLevel
        levelBelowPoc = pocLevel
        lvnLevels = array.new_int()
        hvnLevels = array.new_int()

        while valueAreaVolume < targetVolume and targetVolume > 0
            if levelBelowPoc == 0 and levelAbovePoc == profileLevels - 1
                break

            volumeAbovePoc = levelAbovePoc < profileLevels - 1 ? array.get(volumeStorage, levelAbovePoc + 1) : 0.0
            volumeBelowPoc = levelBelowPoc > 0 ? array.get(volumeStorage, levelBelowPoc - 1) : 0.0

            if volumeBelowPoc == 0 and volumeAbovePoc == 0
                break

            if volumeAbovePoc >= volumeBelowPoc
                valueAreaVolume += volumeAbovePoc
                levelAbovePoc += 1
            else
                valueAreaVolume += volumeBelowPoc
                levelBelowPoc -= 1

        if profileLevels >= 3
            for level = 1 to profileLevels - 2
                currentWidth = array.get(rowWidths, level)
                previousWidth = array.get(rowWidths, level - 1)
                nextWidth = array.get(rowWidths, level + 1)
                lvnGapLeft = previousWidth - currentWidth
                lvnGapRight = nextWidth - currentWidth
                hvnGapLeft = currentWidth - previousWidth
                hvnGapRight = currentWidth - nextWidth
                isExtremeLvn = currentWidth > 0 and currentWidth == lowestNonZeroWidth
                isExtremeHvn = currentWidth > 0 and currentWidth == highestDrawnWidth
                passesLvnFilter = not filterMinorNodes or isExtremeLvn or (lvnGapLeft >= 2 and lvnGapRight >= 2)
                passesHvnFilter = not filterMinorNodes or isExtremeHvn or (hvnGapLeft >= 2 and hvnGapRight >= 2)
                isLvnCandidate = currentWidth < previousWidth and currentWidth < nextWidth and passesLvnFilter
                isHvnCandidate = currentWidth > previousWidth and currentWidth > nextWidth and passesHvnFilter

                if isLvnCandidate and (currentWidth > 0 or previousWidth > 0 or nextWidth > 0)
                    array.push(lvnLevels, level)

                if isHvnCandidate and currentWidth > 0
                    array.push(hvnLevels, level)

        currentDrawEnd = time_close
        profileRightTime = previousPeriodEnd
        profileLeftTime = previousPeriodStart

        if backgroundFill
            array.push(profileBoxes, box.new(left = profileLeftTime, top = priceHighest, right = profileRightTime, bottom = priceLowest, xloc = xloc.bar_time, border_color = backgroundColor, border_style = line.style_dotted, bgcolor = backgroundColor))

        if volumeProfile and maxVolume > 0
            for level = 0 to profileLevels - 1
                widthBars = array.get(rowWidths, level)

                if widthBars > 0
                    widthTime = widthBars * sourceBarMs
                    startTime = profilePlacement == "Right" ? profileRightTime - widthTime : profilePlacement == "Left" ? profileLeftTime : profileRightTime
                    endTime = profilePlacement == "Right" ? profileRightTime : startTime + widthTime
                    topPrice = priceLowest + (level + 0.98) * priceStep
                    bottomPrice = priceLowest + (level + 0.02) * priceStep
                    boxColor = level >= levelBelowPoc and level <= levelAbovePoc ? totalVolumeColor : vaVolumeColor

                    array.push(profileBoxes, box.new(left = startTime, top = topPrice, right = endTime, bottom = bottomPrice, xloc = xloc.bar_time, border_color = boxColor, bgcolor = boxColor))

        pocPrice = priceLowest + (pocLevel + 0.50) * priceStep
        vahPrice = priceLowest + (levelAbovePoc + 1.00) * priceStep
        valPrice = priceLowest + levelBelowPoc * priceStep

        pocLine := f_setLine(pocLine, pointOfControl and maxVolume > 0, profileLeftTime, pocPrice, profileRightTime, pocPrice, pocColor, pocWidth)
        vahLine := f_setLine(vahLine, valueAreaHigh and maxVolume > 0, profileLeftTime, vahPrice, profileRightTime, vahPrice, vahColor, 2)
        valLine := f_setLine(valLine, valueAreaLow and maxVolume > 0, profileLeftTime, valPrice, profileRightTime, valPrice, valColor, 2)

        lvnAreaStarts = array.new_int()
        lvnAreaEnds = array.new_int()

        if profileLevels >= 5
            for centerLevel = 2 to profileLevels - 3
                leftOuterWidth = array.get(rowWidths, centerLevel - 2)
                rightOuterWidth = array.get(rowWidths, centerLevel + 2)
                middleLowWidth = array.get(rowWidths, centerLevel - 1)
                middleMidWidth = array.get(rowWidths, centerLevel)
                middleHighWidth = array.get(rowWidths, centerLevel + 1)
                outerMinWidth = math.min(leftOuterWidth, rightOuterWidth)
                middleMaxWidth = math.max(middleLowWidth, math.max(middleMidWidth, middleHighWidth))
                isLvnAreaCandidate = outerMinWidth > 0 and middleMaxWidth > 0 and middleMaxWidth < outerMinWidth

                if isLvnAreaCandidate
                    candidateStart = centerLevel - 1
                    candidateEnd = centerLevel + 1
                    existingAreas = array.size(lvnAreaStarts)

                    if existingAreas > 0
                        previousAreaEnd = array.get(lvnAreaEnds, existingAreas - 1)

                        if candidateStart <= previousAreaEnd + 1
                            mergedEnd = math.max(previousAreaEnd, candidateEnd)
                            array.set(lvnAreaEnds, existingAreas - 1, mergedEnd)
                        else
                            array.push(lvnAreaStarts, candidateStart)
                            array.push(lvnAreaEnds, candidateEnd)
                    else
                        array.push(lvnAreaStarts, candidateStart)
                        array.push(lvnAreaEnds, candidateEnd)

        if showLvn and array.size(lvnLevels) > 0
            for lvnIndex = 0 to array.size(lvnLevels) - 1
                lvnLevel = array.get(lvnLevels, lvnIndex)
                insideLvnArea = false

                if showLvnAreas and array.size(lvnAreaStarts) > 0
                    for areaIndex = 0 to array.size(lvnAreaStarts) - 1
                        areaLowLevel = array.get(lvnAreaStarts, areaIndex)
                        areaHighLevel = array.get(lvnAreaEnds, areaIndex)

                        if lvnLevel >= areaLowLevel and lvnLevel <= areaHighLevel
                            insideLvnArea := true
                            break

                if not insideLvnArea
                    lvnPrice = priceLowest + (lvnLevel + 0.50) * priceStep
                    lvnTop = priceLowest + (lvnLevel + 1.00) * priceStep
                    lvnBottom = priceLowest + lvnLevel * priceStep

                    array.push(lvnLines, line.new(x1 = profileLeftTime, y1 = lvnPrice, x2 = currentDrawEnd, y2 = lvnPrice, xloc = xloc.bar_time, extend = extend.none, color = color.new(color.lime, 0), style = line.style_dashed, width = 1))
                    array.push(lvnBoxes, box.new(left = profileLeftTime, top = lvnTop, right = currentDrawEnd, bottom = lvnBottom, xloc = xloc.bar_time, border_color = color.new(color.lime, 70), bgcolor = color.new(color.lime, 85)))
                    array.push(lvnLabels, label.new(x = currentDrawEnd, y = lvnPrice, text = "LVN", xloc = xloc.bar_time, yloc = yloc.price, style = label.style_none, textcolor = color.lime, color = #00000000, size = size.small))

        if showLvnAreas and array.size(lvnAreaStarts) > 0
            for areaIndex = 0 to array.size(lvnAreaStarts) - 1
                areaLowLevel = array.get(lvnAreaStarts, areaIndex)
                areaHighLevel = array.get(lvnAreaEnds, areaIndex)
                areaTop = priceLowest + (areaHighLevel + 1.00) * priceStep
                areaBottom = priceLowest + areaLowLevel * priceStep
                areaMidPrice = math.avg(areaTop, areaBottom)

                array.push(lvnAreaBoxes, box.new(left = profileLeftTime, top = areaTop, right = currentDrawEnd, bottom = areaBottom, xloc = xloc.bar_time, border_color = color.new(color.lime, 40), bgcolor = color.new(color.lime, 90)))
                array.push(lvnAreaLabels, label.new(x = currentDrawEnd, y = areaMidPrice, text = "LVN Area", xloc = xloc.bar_time, yloc = yloc.price, style = label.style_none, textcolor = color.lime, color = #00000000, size = size.small))

        if showHvn and array.size(hvnLevels) > 0
            for hvnIndex = 0 to array.size(hvnLevels) - 1
                hvnLevel = array.get(hvnLevels, hvnIndex)
                hvnPrice = priceLowest + (hvnLevel + 0.50) * priceStep
                hvnTop = priceLowest + (hvnLevel + 1.00) * priceStep
                hvnBottom = priceLowest + hvnLevel * priceStep

                array.push(hvnLines, line.new(x1 = profileLeftTime, y1 = hvnPrice, x2 = currentDrawEnd, y2 = hvnPrice, xloc = xloc.bar_time, extend = extend.none, color = color.new(color.red, 0), style = line.style_dashed, width = 1))
                array.push(hvnBoxes, box.new(left = profileLeftTime, top = hvnTop, right = currentDrawEnd, bottom = hvnBottom, xloc = xloc.bar_time, border_color = color.new(color.red, 70), bgcolor = color.new(color.red, 85)))
                array.push(hvnLabels, label.new(x = currentDrawEnd, y = hvnPrice, text = "HVN", xloc = xloc.bar_time, yloc = yloc.price, style = label.style_none, textcolor = color.red, color = #00000000, size = size.small))

        if vaBackground and not na(vahLine) and not na(valLine)
            if na(vaFill)
                vaFill := linefill.new(vahLine, valLine, vaBackgroundColor)
            else
                linefill.set_color(vaFill, vaBackgroundColor)
        else if not na(vaFill)
            linefill.delete(vaFill)
            vaFill := na
    else
        pocLine := f_setLine(pocLine, false, 0, 0.0, 0, 0.0, pocColor, pocWidth)
        vahLine := f_setLine(vahLine, false, 0, 0.0, 0, 0.0, vahColor, 2)
        valLine := f_setLine(valLine, false, 0, 0.0, 0, 0.0, valColor, 2)

        if not na(vaFill)
            linefill.delete(vaFill)
            vaFill := na
````
