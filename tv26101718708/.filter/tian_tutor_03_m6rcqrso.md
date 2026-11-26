# Tian Tutor 0.3

- url: https://www.tradingview.com/script/m6rcQRSo/
- type: indicator
- pine_id: PUB;1e50d20e4b7f4b1f80e7115b294caca7
- version: 1.0

## Description

压力线支撑线

## Source Code

````pine
//@version=6
indicator("田导师 0.2", overlay=true, max_lines_count=500, max_labels_count=200, max_bars_back=5000)

// Clean Cheetah 3.0 local reconstruction.
// Scope:
// - 3.0 confirmed QQ core: 3-minute EMA(8) / EMA(30) and cross pulses.
// - 3.0 horizontal objects: recompute pressure/support from an adaptive
//   timeframe window. Only confirmed structure pivots are used; broken levels,
//   repeated highs/lows in the same water zone, and weak reactions are excluded.
// - No screenshot-lock anchors and no 6.3 logic.

supportLineTf = input.timeframe("15", "支撑趋势线", options=["1", "2", "3", "5", "8", "10", "15", "30", "45", "60", "120", "180", "240"])
pressureLineTf = input.timeframe("5", "压力趋势线", options=["1", "2", "3", "5", "8", "10", "15", "30", "45", "60", "120", "180", "240"])
signalLineTf = input.timeframe("5", "趋势信号线", options=["1", "2", "3", "5", "8", "10", "15", "30", "45", "60", "120", "180", "240"])

srTf = signalLineTf
fastLen = 8
slowLen = 30
showCore = true
showZone = false
showSignals = false

showObjects = true
showObjectLabels = true
levelExtendBars = 480
autoWindow = true
manualStatsHours = 12.0
maxScanBars = 4500
autoLineCount = true
manualSupportCount = 3
manualPressureCount = 3
autoLineCap = 12
atrLen = 14
structureLeft = 12
structureRight = 5
confirmBars = 18
minRejectAtr = 0.45
mergeAtr = 0.45
minGapAtr = 0.70

supportTrendSr = request.security(syminfo.tickerid, supportLineTf, ta.ema(close, fastLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
pressureTrendSr = request.security(syminfo.tickerid, pressureLineTf, ta.ema(close, slowLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[signalFastSr, signalSlowSr] = request.security(syminfo.tickerid, srTf, [ta.ema(close, fastLen), ta.ema(close, slowLen)], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

bullCross = ta.crossover(signalFastSr, signalSlowSr)
bearCross = ta.crossunder(signalFastSr, signalSlowSr)
bullState = signalFastSr >= signalSlowSr

coreFastColor = bullState ? color.rgb(245, 245, 245) : color.rgb(235, 55, 170)
coreSlowColor = bullState ? color.rgb(245, 245, 245) : color.rgb(200, 45, 155)
zoneColor = bullState ? color.new(color.rgb(40, 170, 160), 88) : color.new(color.rgb(235, 55, 170), 88)

pFast = plot(showCore ? supportTrendSr : na, "支撑趋势线", color=coreFastColor, linewidth=2, style=plot.style_line)
pSlow = plot(showCore ? pressureTrendSr : na, "压力趋势线", color=coreSlowColor, linewidth=2, style=plot.style_line)
fill(pFast, pSlow, title="EMA压力支撑带", color=showZone ? zoneColor : na)

plotshape(showSignals and bullCross, "多头交叉信号", shape.labelup, location.belowbar, color=color.rgb(25, 185, 90), text="多", textcolor=color.white, size=size.tiny)
plotshape(showSignals and bearCross, "空头交叉信号", shape.labeldown, location.abovebar, color=color.rgb(225, 60, 75), text="空", textcolor=color.white, size=size.tiny)

plot(bullCross ? 1.0 : 0.0, "多头信号", color=color.lime, display=display.data_window)
plot(bearCross ? 1.0 : 0.0, "空头信号", color=color.red, display=display.data_window)

supportColor = color.rgb(0, 172, 172)
pressureColor = color.rgb(178, 86, 28)
supportLabelColor = color.new(color.rgb(0, 120, 125), 15)
pressureLabelColor = color.new(color.rgb(130, 64, 26), 15)
supportLabelText = "支撑位:13705378125"
pressureLabelText = "压力位:13705378125"

atr = ta.atr(atrLen)
safeExtendBars = math.min(levelExtendBars, 480)
safeBackBars = 9999

var line[] supportLines = array.new_line()
var label[] supportLabels = array.new_label()
var line[] pressureLines = array.new_line()
var label[] pressureLabels = array.new_label()

f_delete_object(line lineId, label labelId) =>
    if not na(lineId)
        line.delete(lineId)
    if not na(labelId)
        label.delete(labelId)

f_safe_x(int x) =>
    math.max(x, bar_index - safeBackBars)

f_find_near(float[] levels, float price, float tolerance) =>
    int found = -1
    int n = array.size(levels)
    if n > 0
        for i = 0 to n - 1
            if found == -1 and math.abs(array.get(levels, i) - price) <= tolerance
                found := i
    found

f_add_candidate(float[] levels, int[] starts, float[] scores, int[] touches, float price, int startX, float tolerance, float score, bool isSupport) =>
    int existing = f_find_near(levels, price, tolerance)
    if existing == -1
        array.push(levels, price)
        array.push(starts, startX)
        array.push(scores, score)
        array.push(touches, 1)
    else
        float oldLevel = array.get(levels, existing)
        bool useNewExtreme = isSupport ? price < oldLevel : price > oldLevel
        if useNewExtreme
            array.set(levels, existing, price)
            array.set(starts, existing, startX)
        array.set(scores, existing, math.max(array.get(scores, existing), score))
        array.set(touches, existing, array.get(touches, existing) + 1)
    0

f_is_structure_high(int offset, int leftBars, int rightBars) =>
    bool ok = offset >= rightBars and not na(high[offset + leftBars]) and not na(high[offset - rightBars])
    if ok
        float level = high[offset]
        for j = 1 to leftBars
            if high[offset + j] > level
                ok := false
        for j = 1 to rightBars
            if high[offset - j] >= level
                ok := false
    ok

f_is_structure_low(int offset, int leftBars, int rightBars) =>
    bool ok = offset >= rightBars and not na(low[offset + leftBars]) and not na(low[offset - rightBars])
    if ok
        float level = low[offset]
        for j = 1 to leftBars
            if low[offset + j] < level
                ok := false
        for j = 1 to rightBars
            if low[offset - j] <= level
                ok := false
    ok

f_reaction_score(float level, int offset, bool isSupport, int bars, float atrValue, int recentOffset) =>
    float reactionExtreme = isSupport ? high[offset] : low[offset]
    int usableBars = math.min(bars, math.max(0, offset - recentOffset))
    if usableBars > 0
        for step = 1 to usableBars
            int k = offset - step
            reactionExtreme := isSupport ? math.max(reactionExtreme, high[k]) : math.min(reactionExtreme, low[k])
    float move = isSupport ? reactionExtreme - level : level - reactionExtreme
    move / math.max(atrValue, syminfo.mintick)

f_broken_after(float level, int offset, bool isSupport, float buffer, int recentOffset) =>
    bool broken = false
    if offset > recentOffset
        for k = recentOffset to offset - 1
            bool bodyBreak = isSupport ? close[k] < level - buffer : close[k] > level + buffer
            if bodyBreak
                broken := true
    broken

f_level_touch_score(float level, int offset, bool isSupport, int bars, float tolerance, int recentOffset) =>
    int touches = 0
    int usableBars = math.min(bars, math.max(0, offset - recentOffset))
    if usableBars > 0
        for step = 0 to usableBars
            int k = offset - step
            bool touched = isSupport ? low[k] <= level + tolerance and close[k] >= level - tolerance : high[k] >= level - tolerance and close[k] <= level + tolerance
            if touched
                touches += 1
    math.min(touches, 6) * 0.35

f_level_on_active_side(float level, bool isSupport, float reference, float buffer) =>
    isSupport ? level < reference - buffer : level > reference + buffer

f_confirmed_extreme_offset(bool isSupport, int scanEnd, int rightBars, int confirmBars, float atrValue, float minMoveAtr, int recentOffset, int windowStartTime) =>
    int out = na
    float bestLevel = na
    int scanStart = math.max(rightBars + recentOffset, recentOffset + 1)
    if scanEnd >= scanStart
        for offset = scanStart to scanEnd
            int usableBars = math.min(confirmBars, math.max(0, offset - recentOffset))
            if usableBars > 0 and not na(time[offset]) and time[offset] >= windowStartTime
                float level = isSupport ? low[offset] : high[offset]
                float reactionExtreme = isSupport ? high[offset] : low[offset]
                for step = 1 to usableBars
                    int k = offset - step
                    reactionExtreme := isSupport ? math.max(reactionExtreme, high[k]) : math.min(reactionExtreme, low[k])
                float move = isSupport ? reactionExtreme - level : level - reactionExtreme
                bool confirmed = move >= math.max(atrValue, syminfo.mintick) * minMoveAtr
                bool better = isSupport ? na(bestLevel) or level < bestLevel : na(bestLevel) or level > bestLevel
                if confirmed and better
                    bestLevel := level
                    out := offset
    out

f_chart_seconds() =>
    float seconds = timeframe.in_seconds(timeframe.period)
    nz(seconds, 60.0)

f_bars_for_seconds(float targetSeconds, float chartSeconds, int maxBars) =>
    int convertedBars = int(math.ceil(targetSeconds / math.max(chartSeconds, 1.0)))
    math.min(maxBars, math.max(0, convertedBars))

f_auto_window_hours(float chartSeconds) =>
    float minutes = chartSeconds / 60.0
    float hours = 12.0
    if chartSeconds <= 1
        hours := 1.0
    else if chartSeconds <= 5
        hours := 2.0
    else if chartSeconds <= 10
        hours := 4.0
    else if chartSeconds <= 15
        hours := 6.0
    else if chartSeconds <= 30
        hours := 6.0
    else if chartSeconds <= 45
        hours := 10.0
    else if minutes <= 1
        hours := 64.0
    else if minutes <= 2
        hours := 48.0
    else if minutes <= 3
        hours := 60.0
    else if minutes <= 5
        hours := 120.0
    else if minutes <= 10
        hours := 240.0
    else if minutes <= 15
        hours := 360.0
    else if minutes <= 30
        hours := 720.0
    else if minutes <= 60
        hours := 1440.0
    else if minutes <= 120
        hours := 2850.0
    else if minutes <= 240
        hours := 4800.0
    else if minutes <= 1440
        hours := 2160.0
    else
        hours := 4320.0
    math.min(hours, 4320.0)

f_auto_line_count(float chartSeconds, float windowBars, int cap) =>
    float minutes = chartSeconds / 60.0
    int base = 6
    if chartSeconds < 60
        base := 6
    else if minutes <= 3
        base := 8
    else if minutes <= 15
        base := 9
    else if minutes <= 60
        base := 10
    else if minutes <= 240
        base := 11
    else
        base := 12
    int extra = windowBars > 900 ? 1 : 0
    math.min(cap, math.max(1, base + extra))

f_rank_by_price(float[] levels, int[] starts, int levelIndex, bool isSupport) =>
    int rank = 0
    float level = array.get(levels, levelIndex)
    int startX = array.get(starts, levelIndex)
    int n = array.size(levels)
    if n > 0
        for j = 0 to n - 1
            if j != levelIndex
                float other = array.get(levels, j)
                int otherStartX = array.get(starts, j)
                bool better = isSupport ? other > level or other == level and otherStartX < startX : other < level or other == level and otherStartX < startX
                if better
                    rank += 1
    rank

f_level_far_from_picked(float level, int startX, float[] pickedLevels, int[] pickedStarts, float minGap, int minBars) =>
    bool ok = true
    int n = array.size(pickedLevels)
    if n > 0
        for i = 0 to n - 1
            bool sameWater = math.abs(level - array.get(pickedLevels, i)) < minGap
            bool sameImpulse = math.abs(startX - array.get(pickedStarts, i)) < minBars and math.abs(level - array.get(pickedLevels, i)) < minGap * 1.50
            if sameWater or sameImpulse
                ok := false
    ok

f_rank_score(float[] scores, int[] touches, int levelIndex) =>
    array.get(scores, levelIndex) + array.get(touches, levelIndex) * 0.35

f_line_width(float[] scores, int[] touches, int levelIndex) =>
    int touchCount = array.get(touches, levelIndex)
    float strength = f_rank_score(scores, touches, levelIndex)
    int width = 1
    if touchCount >= 4 and strength >= 4.0
        width := 2
    width

f_pick_levels(float[] levels, int[] starts, float[] scores, int[] touches, float[] outLevels, int[] outStarts, int[] outWidths, int maxCount, bool isSupport, float minGap, int minBars) =>
    array.clear(outLevels)
    array.clear(outStarts)
    array.clear(outWidths)
    int n = array.size(levels)
    if n > 0
        for wantedRank = 0 to n - 1
            if array.size(outLevels) < maxCount
                for i = 0 to n - 1
                    if f_rank_by_price(levels, starts, i, isSupport) == wantedRank
                        float level = array.get(levels, i)
                        int startX = array.get(starts, i)
                        if f_level_far_from_picked(level, startX, outLevels, outStarts, minGap, minBars)
                            array.push(outLevels, level)
                            array.push(outStarts, startX)
                            array.push(outWidths, f_line_width(scores, touches, i))

f_filter_active_levels(float[] levels, int[] starts, int[] widths, bool isSupport, float reference, float sideBuffer, float breakBuffer, int recentOffset) =>
    int i = array.size(levels) - 1
    while i >= 0
        float level = array.get(levels, i)
        int offset = math.max(recentOffset, bar_index - array.get(starts, i))
        bool wrongSide = not f_level_on_active_side(level, isSupport, reference, sideBuffer)
        bool broken = f_broken_after(level, offset, isSupport, breakBuffer, recentOffset)
        if wrongSide or broken
            array.remove(levels, i)
            array.remove(starts, i)
            array.remove(widths, i)
        i -= 1

f_sync_line(line id, int startX, float level, color lineColor, int width) =>
    line out = id
    if na(level) or na(startX)
        if not na(out)
            line.delete(out)
        out := na
    else
        int drawStartX = f_safe_x(startX)
        int endX = bar_index + safeExtendBars
        if na(out)
            out := line.new(drawStartX, level, endX, level, xloc=xloc.bar_index, extend=extend.right, color=lineColor, width=width)
        else
            line.set_xy1(out, drawStartX, level)
            line.set_xy2(out, endX, level)
            line.set_extend(out, extend.right)
            line.set_color(out, lineColor)
            line.set_width(out, width)
    out

f_sync_label(label id, int startX, float level, bool isSupport, bool visible) =>
    label out = id
    if not visible or na(level) or na(startX)
        if not na(out)
            label.delete(out)
        out := na
    else
        int drawStartX = f_safe_x(startX)
        string txt = isSupport ? supportLabelText : pressureLabelText
        color bg = isSupport ? supportLabelColor : pressureLabelColor
        string labelSize = size.normal
        if na(out)
            out := label.new(drawStartX, level, txt, xloc=xloc.bar_index, style=isSupport ? label.style_label_up : label.style_label_down, color=bg, textcolor=color.white, size=labelSize)
        else
            label.set_xy(out, drawStartX, level)
            label.set_text(out, txt)
            label.set_style(out, isSupport ? label.style_label_up : label.style_label_down)
            label.set_color(out, bg)
            label.set_textcolor(out, color.white)
            label.set_size(out, labelSize)
    out

f_sync_objects(line[] lines, label[] labels, float[] levels, int[] starts, int[] widths, bool isSupport, int maxCount) =>
    while array.size(lines) > array.size(levels)
        line oldLine = array.pop(lines)
        if not na(oldLine)
            line.delete(oldLine)
    while array.size(labels) > array.size(levels)
        label oldLabel = array.pop(labels)
        if not na(oldLabel)
            label.delete(oldLabel)
    int n = math.min(array.size(levels), maxCount)
    if n > 0
        for i = 0 to n - 1
            float level = array.get(levels, i)
            int startX = array.get(starts, i)
            int width = array.size(widths) > i ? array.get(widths, i) : 1
            line existingLine = array.size(lines) > i ? array.get(lines, i) : na
            label existingLabel = array.size(labels) > i ? array.get(labels, i) : na
            line syncedLine = f_sync_line(existingLine, startX, level, isSupport ? supportColor : pressureColor, width)
            label syncedLabel = f_sync_label(existingLabel, startX, level, isSupport, showObjects and showObjectLabels)
            if array.size(lines) > i
                array.set(lines, i, syncedLine)
            else
                array.push(lines, syncedLine)
            if array.size(labels) > i
                array.set(labels, i, syncedLabel)
            else
                array.push(labels, syncedLabel)
    while array.size(lines) > n
        line oldLine = array.pop(lines)
        if not na(oldLine)
            line.delete(oldLine)
    while array.size(labels) > n
        label oldLabel = array.pop(labels)
        if not na(oldLabel)
            label.delete(oldLabel)

f_clear_objects(line[] lines, label[] labels) =>
    while array.size(lines) > 0
        line oldLine = array.pop(lines)
        if not na(oldLine)
            line.delete(oldLine)
    while array.size(labels) > 0
        label oldLabel = array.pop(labels)
        if not na(oldLabel)
            label.delete(oldLabel)

if barstate.islast
    float[] supportLevels = array.new_float()
    int[] supportStarts = array.new_int()
    float[] supportScores = array.new_float()
    int[] supportTouches = array.new_int()
    float[] pressureLevels = array.new_float()
    int[] pressureStarts = array.new_int()
    float[] pressureScores = array.new_float()
    int[] pressureTouches = array.new_int()
    float atrLive = math.max(nz(atr, syminfo.mintick), syminfo.mintick)
    float mergeTolLive = math.max(syminfo.mintick * 5.0, atrLive * mergeAtr)
    float minGapLive = math.max(syminfo.mintick * 8.0, atrLive * minGapAtr)
    float breakBufferLive = math.max(syminfo.mintick * 2.0, atrLive * 0.02)
    float chartSeconds = f_chart_seconds()
    float statsHoursLive = autoWindow ? f_auto_window_hours(chartSeconds) : manualStatsHours
    int windowStartTime = time - int(statsHoursLive * 60.0 * 60.0 * 1000.0)
    int historyLimit = 4999
    int estimatedWindowBars = int(math.ceil(statsHoursLive * 3600.0 / math.max(chartSeconds, 1.0))) + 20
    int scanLimit = math.min(math.min(maxScanBars, historyLimit), math.max(100, estimatedWindowBars))
    int recentOffset = barstate.isconfirmed ? 0 : 1
    int windowBars = 0
    if showObjects
        for offset = recentOffset to scanLimit
            if not na(time[offset]) and time[offset] >= windowStartTime
                windowBars += 1
    int leftLive = math.min(80, math.max(structureLeft, int(math.round(windowBars * 0.012))))
    int rightLive = math.min(50, math.max(structureRight, int(math.round(windowBars * 0.005))))
    int confirmLive = math.min(120, math.max(confirmBars, int(math.round(windowBars * 0.015))))
    int minStructureGapBars = math.max(leftLive + rightLive, int(math.round(windowBars * 0.02)))
    int scanEnd = math.min(scanLimit, historyLimit - leftLive)
    int scanStart = math.max(rightLive + recentOffset, recentOffset + 1)
    int quickLeft = math.max(3, math.min(leftLive, int(math.round(leftLive * 0.45))))
    int quickRight = math.max(2, math.min(rightLive, int(math.round(rightLive * 0.55))))
    int quickScanStart = math.max(quickRight + recentOffset, recentOffset + 1)
    int microPressureLeft = 2
    int microPressureRight = 1
    int microPressureScanStart = math.max(microPressureRight + recentOffset, recentOffset + 1)
    int microPressureMaxBars = math.max(0, scanEnd - recentOffset)
    int microPressureLookbackBars = f_bars_for_seconds(7200.0, chartSeconds, microPressureMaxBars)
    int microPressureScanEnd = recentOffset + microPressureLookbackBars
    float activeReference = close
    float activeSideBuffer = math.max(syminfo.mintick * 2.0, atrLive * 0.02)
    int supportCountLive = autoLineCount ? f_auto_line_count(chartSeconds, windowBars, autoLineCap) : manualSupportCount
    int pressureCountLive = autoLineCount ? f_auto_line_count(chartSeconds, windowBars, autoLineCap) : manualPressureCount
    if showObjects
        if scanEnd >= scanStart
            int confirmedSupportOffset = f_confirmed_extreme_offset(true, scanEnd, rightLive, confirmLive, atrLive, minRejectAtr, recentOffset, windowStartTime)
            if not na(confirmedSupportOffset)
                float level = low[confirmedSupportOffset]
                float score = 2.0 + f_level_touch_score(level, confirmedSupportOffset, true, confirmLive, mergeTolLive, recentOffset)
                if f_level_on_active_side(level, true, activeReference, activeSideBuffer) and not f_broken_after(level, confirmedSupportOffset, true, breakBufferLive, recentOffset)
                    f_add_candidate(supportLevels, supportStarts, supportScores, supportTouches, level, bar_index - confirmedSupportOffset, mergeTolLive, score, true)
            int confirmedPressureOffset = f_confirmed_extreme_offset(false, scanEnd, rightLive, confirmLive, atrLive, minRejectAtr, recentOffset, windowStartTime)
            if not na(confirmedPressureOffset)
                float level = high[confirmedPressureOffset]
                float score = 2.0 + f_level_touch_score(level, confirmedPressureOffset, false, confirmLive, mergeTolLive, recentOffset)
                if f_level_on_active_side(level, false, activeReference, activeSideBuffer) and not f_broken_after(level, confirmedPressureOffset, false, breakBufferLive, recentOffset)
                    f_add_candidate(pressureLevels, pressureStarts, pressureScores, pressureTouches, level, bar_index - confirmedPressureOffset, mergeTolLive, score, false)
            if scanEnd >= scanStart
                for offset = scanStart to scanEnd
                    if not na(time[offset]) and time[offset] >= windowStartTime
                        float pivotAtr = math.max(nz(atr[offset], atrLive), syminfo.mintick)
                        if f_is_structure_high(offset, leftLive, rightLive)
                            float level = high[offset]
                            float reaction = f_reaction_score(level, offset, false, confirmLive, pivotAtr, recentOffset)
                            float score = reaction + f_level_touch_score(level, offset, false, confirmLive, mergeTolLive, recentOffset)
                            if reaction >= minRejectAtr and f_level_on_active_side(level, false, activeReference, activeSideBuffer) and not f_broken_after(level, offset, false, breakBufferLive, recentOffset)
                                f_add_candidate(pressureLevels, pressureStarts, pressureScores, pressureTouches, level, bar_index - offset, mergeTolLive, score, false)
                        if f_is_structure_low(offset, leftLive, rightLive)
                            float level = low[offset]
                            float reaction = f_reaction_score(level, offset, true, confirmLive, pivotAtr, recentOffset)
                            float score = reaction + f_level_touch_score(level, offset, true, confirmLive, mergeTolLive, recentOffset)
                            if reaction >= minRejectAtr and f_level_on_active_side(level, true, activeReference, activeSideBuffer) and not f_broken_after(level, offset, true, breakBufferLive, recentOffset)
                                f_add_candidate(supportLevels, supportStarts, supportScores, supportTouches, level, bar_index - offset, mergeTolLive, score, true)
            if scanEnd >= quickScanStart
                for offset = quickScanStart to scanEnd
                    if not na(time[offset]) and time[offset] >= windowStartTime
                        float pivotAtr = math.max(nz(atr[offset], atrLive), syminfo.mintick)
                        if f_is_structure_high(offset, quickLeft, quickRight)
                            float level = high[offset]
                            float reaction = f_reaction_score(level, offset, false, confirmLive, pivotAtr, recentOffset)
                            float score = reaction + f_level_touch_score(level, offset, false, confirmLive, mergeTolLive, recentOffset) * 0.60
                            if reaction >= minRejectAtr and f_level_on_active_side(level, false, activeReference, activeSideBuffer) and not f_broken_after(level, offset, false, breakBufferLive, recentOffset)
                                f_add_candidate(pressureLevels, pressureStarts, pressureScores, pressureTouches, level, bar_index - offset, mergeTolLive * 0.80, score, false)
                        if f_is_structure_low(offset, quickLeft, quickRight)
                            float level = low[offset]
                            float reaction = f_reaction_score(level, offset, true, confirmLive, pivotAtr, recentOffset)
                            float score = reaction + f_level_touch_score(level, offset, true, confirmLive, mergeTolLive, recentOffset) * 0.60
                            if reaction >= minRejectAtr and f_level_on_active_side(level, true, activeReference, activeSideBuffer) and not f_broken_after(level, offset, true, breakBufferLive, recentOffset)
                                f_add_candidate(supportLevels, supportStarts, supportScores, supportTouches, level, bar_index - offset, mergeTolLive * 0.80, score, true)
            if microPressureScanEnd >= microPressureScanStart
                for offset = microPressureScanStart to microPressureScanEnd
                    if not na(time[offset]) and time[offset] >= windowStartTime
                        float pivotAtr = math.max(nz(atr[offset], atrLive), syminfo.mintick)
                        if f_is_structure_high(offset, microPressureLeft, microPressureRight)
                            float level = high[offset]
                            float reaction = f_reaction_score(level, offset, false, confirmLive, pivotAtr, recentOffset)
                            float score = 1.25 + reaction + f_level_touch_score(level, offset, false, confirmLive, mergeTolLive, recentOffset) * 0.50
                            if reaction >= math.max(0.15, minRejectAtr * 0.50) and f_level_on_active_side(level, false, activeReference, activeSideBuffer) and not f_broken_after(level, offset, false, breakBufferLive, recentOffset)
                                f_add_candidate(pressureLevels, pressureStarts, pressureScores, pressureTouches, level, bar_index - offset, mergeTolLive * 0.50, score, false)

    float[] pickedSupportLevels = array.new_float()
    int[] pickedSupportStarts = array.new_int()
    int[] pickedSupportWidths = array.new_int()
    float[] pickedPressureLevels = array.new_float()
    int[] pickedPressureStarts = array.new_int()
    int[] pickedPressureWidths = array.new_int()
    f_pick_levels(supportLevels, supportStarts, supportScores, supportTouches, pickedSupportLevels, pickedSupportStarts, pickedSupportWidths, supportCountLive, true, minGapLive, minStructureGapBars)
    f_pick_levels(pressureLevels, pressureStarts, pressureScores, pressureTouches, pickedPressureLevels, pickedPressureStarts, pickedPressureWidths, pressureCountLive, false, minGapLive, minStructureGapBars)
    f_filter_active_levels(pickedSupportLevels, pickedSupportStarts, pickedSupportWidths, true, activeReference, activeSideBuffer, breakBufferLive, recentOffset)
    f_filter_active_levels(pickedPressureLevels, pickedPressureStarts, pickedPressureWidths, false, activeReference, activeSideBuffer, breakBufferLive, recentOffset)

    if showObjects
        f_sync_objects(supportLines, supportLabels, pickedSupportLevels, pickedSupportStarts, pickedSupportWidths, true, supportCountLive)
        f_sync_objects(pressureLines, pressureLabels, pickedPressureLevels, pickedPressureStarts, pickedPressureWidths, false, pressureCountLive)
    else
        f_clear_objects(supportLines, supportLabels)
        f_clear_objects(pressureLines, pressureLabels)

alertcondition(bullCross, "Cheetah 3.0 v:jkc88588 probe", "Cheetah 3.0 v:jkc88588 probe")
alertcondition(bearCross, "Cheetah 3.0 v:ar8w17 probe", "Cheetah 3.0 v:ar8w17 probe")
````
