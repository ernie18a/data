# Pivot Engine Pro

- url: https://www.tradingview.com/script/udhXordx-Pivot-Engine-Pro/
- type: indicator
- pine_id: PUB;efd60192203f4d05b9c4859127ba9ab1
- version: 1.0

## Description

Combined Pivot points from weekly, daily
EMA
session
Killzone
Asian Range

## Source Code

````pine
//@version=6
indicator("Pivot Engine Pro", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

//====================================================
// Pivot Engine Pro
// Weekly Pivot Engine
// Daily Pivot Engine
// Moving Averages
// Asian Range Session
// Psychological Levels
// Session Backgrounds / Killzones
//====================================================

//----------------------------------------------------
// Constants / styling
//----------------------------------------------------
var color WEEKLY_ACTIVE_COLOR      = color.purple
var color WEEKLY_BROKEN_COLOR      = color.new(color.purple, 75)
var color WEEKLY_ACTIVE_TEXT_COLOR = color.purple

var color DAILY_ACTIVE_COLOR       = color.green
var color DAILY_BROKEN_COLOR       = color.new(color.green, 75)
var color DAILY_ACTIVE_TEXT_COLOR  = color.green

var color ASIAN_LINE_COLOR         = color.gray
var color ASIAN_FILL_COLOR         = color.new(color.gray, 90)
var color ASIAN_BORDER_INVISIBLE   = color.new(color.gray, 100)

var color PSYCH_LEVEL_COLOR        = color.new(color.gray, 65)

var color SESSION_BG_COLOR         = color.new(color.green, 90)
var color KILLZONE_1_BG_COLOR      = color.new(color.orange, 90)
var color KILLZONE_2_BG_COLOR      = color.new(color.aqua, 90)

var color KILLZONE_LINE_COLOR      = color.new(color.gray, 25)

var int ACTIVE_LINE_WIDTH   = 2
var int BROKEN_LINE_WIDTH   = 2
var int ASIAN_LINE_WIDTH    = 1
var int PSYCH_LINE_WIDTH    = 1
var int KILLZONE_LINE_WIDTH = 1
var int MAX_VISIBLE_LEVELS  = 5
var int FADED_BROKEN_COUNT  = 2
var int INVALID_INDEX       = -1

//----------------------------------------------------
// Inputs
//----------------------------------------------------
asianSessionTime = input.session("0000-0600", "Asian Range Session")
asianTimezone    = input.string("Europe/London", "Asian Range Timezone", options = ["Europe/London", "UTC"])
showAsianShading = input.bool(true, "Show Asian Session Shading")
showAsianRange   = input.bool(true, "Show Asian Range Lines")
showPsychLevels  = input.bool(true, "Show Psychological Levels")

sessionBgTime     = input.session("0800-1700", "8AM-5PM Background Session")
sessionBgTimezone = input.string("Europe/London", "8AM-5PM Background Timezone", options = ["Europe/London", "UTC"])
showSessionBg     = input.bool(true, "Show 8AM-5PM Green Background")

killzone1Time     = input.session("0700-0900", "Killzone 1 Session")
killzone2Time     = input.session("1200-1500", "Killzone 2 Session")
killzoneTimezone  = input.string("Europe/London", "Killzone Timezone", options = ["Europe/London", "UTC"])
showKillzones     = input.bool(true, "Show Killzones")
showKillzoneMarks = input.bool(true, "Show 8AM / 1PM Vertical Lines")

//----------------------------------------------------
// Timeframe filter
//----------------------------------------------------
showLowerTfOnly = timeframe.isseconds or (timeframe.isintraday and timeframe.multiplier <= 15)
showOnly30m     = timeframe.isminutes and timeframe.multiplier == 30
showOnly15m     = timeframe.isseconds or (timeframe.isminutes and timeframe.multiplier <= 15)

//----------------------------------------------------
// Moving averages
//----------------------------------------------------
ema14  = ta.ema(close, 14)
sma50  = ta.sma(close, 50)
ema200 = ta.ema(close, 200)

plot(ema200, title="200 EMA", color=color.purple, linewidth=2)
plot(ema14,  title="14 EMA",  color=color.green,  linewidth=1)
plot(sma50,  title="50 SMA",  color=color.red,    linewidth=1)

//----------------------------------------------------
// Utility
//----------------------------------------------------
f_isSameLevel(float a, float b) =>
    math.abs(a - b) <= syminfo.mintick

f_clearLine(line ln) =>
    if not na(ln)
        line.delete(ln)

f_clearLabel(label lb) =>
    if not na(lb)
        label.delete(lb)

//----------------------------------------------------
// Weekly pivot detection
//----------------------------------------------------
f_getWeeklyPivotHighPrice() =>
    float ph = na
    if bar_index >= 2
        ph := high[1] > high[2] and high[1] > high ? high[1] : na
    ph

f_getWeeklyPivotLowPrice() =>
    float pl = na
    if bar_index >= 2
        pl := low[1] < low[2] and low[1] < low ? low[1] : na
    pl

f_getWeeklyPivotHighTime() =>
    int pt = na
    if bar_index >= 2
        pt := high[1] > high[2] and high[1] > high ? time[1] : na
    pt

f_getWeeklyPivotLowTime() =>
    int pt = na
    if bar_index >= 2
        pt := low[1] < low[2] and low[1] < low ? time[1] : na
    pt

weeklyPivotHighPrice = request.security(syminfo.tickerid, "W", f_getWeeklyPivotHighPrice(), barmerge.gaps_off, barmerge.lookahead_off)
weeklyPivotLowPrice  = request.security(syminfo.tickerid, "W", f_getWeeklyPivotLowPrice(),  barmerge.gaps_off, barmerge.lookahead_off)
weeklyPivotHighTime  = request.security(syminfo.tickerid, "W", f_getWeeklyPivotHighTime(),  barmerge.gaps_off, barmerge.lookahead_off)
weeklyPivotLowTime   = request.security(syminfo.tickerid, "W", f_getWeeklyPivotLowTime(),   barmerge.gaps_off, barmerge.lookahead_off)

//----------------------------------------------------
// Daily pivot detection
//----------------------------------------------------
f_getDailyPivotHighPrice() =>
    float ph = na
    if bar_index >= 2
        ph := high[1] > high[2] and high[1] > high ? high[1] : na
    ph

f_getDailyPivotLowPrice() =>
    float pl = na
    if bar_index >= 2
        pl := low[1] < low[2] and low[1] < low ? low[1] : na
    pl

f_getDailyPivotHighTime() =>
    int pt = na
    if bar_index >= 2
        pt := high[1] > high[2] and high[1] > high ? time[1] : na
    pt

f_getDailyPivotLowTime() =>
    int pt = na
    if bar_index >= 2
        pt := low[1] < low[2] and low[1] < low ? time[1] : na
    pt

dailyPivotHighPrice = request.security(syminfo.tickerid, "D", f_getDailyPivotHighPrice(), barmerge.gaps_off, barmerge.lookahead_off)
dailyPivotLowPrice  = request.security(syminfo.tickerid, "D", f_getDailyPivotLowPrice(),  barmerge.gaps_off, barmerge.lookahead_off)
dailyPivotHighTime  = request.security(syminfo.tickerid, "D", f_getDailyPivotHighTime(),  barmerge.gaps_off, barmerge.lookahead_off)
dailyPivotLowTime   = request.security(syminfo.tickerid, "D", f_getDailyPivotLowTime(),   barmerge.gaps_off, barmerge.lookahead_off)

//----------------------------------------------------
// Persistent storage - Weekly
//----------------------------------------------------
var weeklyHighPrices = array.new_float()
var weeklyHighTimes  = array.new_int()
var weeklyHighBroken = array.new_bool()

var weeklyLowPrices  = array.new_float()
var weeklyLowTimes   = array.new_int()
var weeklyLowBroken  = array.new_bool()

var int lastStoredWeeklyHighTime = na
var int lastStoredWeeklyLowTime  = na

//----------------------------------------------------
// Persistent storage - Daily
//----------------------------------------------------
var dailyHighPrices = array.new_float()
var dailyHighTimes  = array.new_int()
var dailyHighBroken = array.new_bool()

var dailyLowPrices  = array.new_float()
var dailyLowTimes   = array.new_int()
var dailyLowBroken  = array.new_bool()

var int lastStoredDailyHighTime = na
var int lastStoredDailyLowTime  = na

//----------------------------------------------------
// Asian range storage
//----------------------------------------------------
var asianHighLines = array.new_line()
var asianLowLines  = array.new_line()
var asianFillBoxes = array.new_box()

var float asianHigh = na
var float asianLow  = na
var int asianStartTime = na
var int asianEndTime   = na
var line currentAsianHighLine = na
var line currentAsianLowLine  = na
var box  currentAsianFillBox  = na

//----------------------------------------------------
// Psychological levels storage
//----------------------------------------------------
var psychLines = array.new_line()

//----------------------------------------------------
// Killzone vertical line storage
//----------------------------------------------------
var killzoneMarkLines = array.new_line()

//----------------------------------------------------
// Store pivots
//----------------------------------------------------
if not na(weeklyPivotHighPrice) and not na(weeklyPivotHighTime)
    if na(lastStoredWeeklyHighTime) or weeklyPivotHighTime != lastStoredWeeklyHighTime
        array.push(weeklyHighPrices, weeklyPivotHighPrice)
        array.push(weeklyHighTimes, weeklyPivotHighTime)
        array.push(weeklyHighBroken, false)
        lastStoredWeeklyHighTime := weeklyPivotHighTime

if not na(weeklyPivotLowPrice) and not na(weeklyPivotLowTime)
    if na(lastStoredWeeklyLowTime) or weeklyPivotLowTime != lastStoredWeeklyLowTime
        array.push(weeklyLowPrices, weeklyPivotLowPrice)
        array.push(weeklyLowTimes, weeklyPivotLowTime)
        array.push(weeklyLowBroken, false)
        lastStoredWeeklyLowTime := weeklyPivotLowTime

if not na(dailyPivotHighPrice) and not na(dailyPivotHighTime)
    if na(lastStoredDailyHighTime) or dailyPivotHighTime != lastStoredDailyHighTime
        array.push(dailyHighPrices, dailyPivotHighPrice)
        array.push(dailyHighTimes, dailyPivotHighTime)
        array.push(dailyHighBroken, false)
        lastStoredDailyHighTime := dailyPivotHighTime

if not na(dailyPivotLowPrice) and not na(dailyPivotLowTime)
    if na(lastStoredDailyLowTime) or dailyPivotLowTime != lastStoredDailyLowTime
        array.push(dailyLowPrices, dailyPivotLowPrice)
        array.push(dailyLowTimes, dailyPivotLowTime)
        array.push(dailyLowBroken, false)
        lastStoredDailyLowTime := dailyPivotLowTime

//----------------------------------------------------
// Break logic
//----------------------------------------------------
f_breakWeeklyHighs() =>
    int sz = array.size(weeklyHighPrices)
    if sz > 0
        for i = 0 to sz - 1
            bool isBroken = array.get(weeklyHighBroken, i)
            float level   = array.get(weeklyHighPrices, i)
            if not isBroken and high >= level
                array.set(weeklyHighBroken, i, true)

f_breakWeeklyLows() =>
    int sz = array.size(weeklyLowPrices)
    if sz > 0
        for i = 0 to sz - 1
            bool isBroken = array.get(weeklyLowBroken, i)
            float level   = array.get(weeklyLowPrices, i)
            if not isBroken and low <= level
                array.set(weeklyLowBroken, i, true)

f_breakDailyHighs() =>
    int sz = array.size(dailyHighPrices)
    if sz > 0
        for i = 0 to sz - 1
            bool isBroken = array.get(dailyHighBroken, i)
            float level   = array.get(dailyHighPrices, i)
            if not isBroken and high >= level
                array.set(dailyHighBroken, i, true)

f_breakDailyLows() =>
    int sz = array.size(dailyLowPrices)
    if sz > 0
        for i = 0 to sz - 1
            bool isBroken = array.get(dailyLowBroken, i)
            float level   = array.get(dailyLowPrices, i)
            if not isBroken and low <= level
                array.set(dailyLowBroken, i, true)

f_breakWeeklyHighs()
f_breakWeeklyLows()
f_breakDailyHighs()
f_breakDailyLows()

//----------------------------------------------------
// Pivot selectors
//----------------------------------------------------
f_findNearestActiveWeeklyHighIndices(float refPrice, int maxCount) =>
    result = array.new_int()
    int sz = array.size(weeklyHighPrices)
    if sz > 0
        for pick = 0 to maxCount - 1
            float bestPrice = na
            int bestIndex = INVALID_INDEX
            for i = 0 to sz - 1
                bool isBroken = array.get(weeklyHighBroken, i)
                float level   = array.get(weeklyHighPrices, i)
                bool alreadyPicked = false
                int existingCount = array.size(result)
                if existingCount > 0
                    for j = 0 to existingCount - 1
                        if array.get(result, j) == i
                            alreadyPicked := true
                            break
                if not isBroken and not alreadyPicked and level > refPrice
                    if na(bestPrice) or level < bestPrice
                        bestPrice := level
                        bestIndex := i
            if bestIndex != INVALID_INDEX
                array.push(result, bestIndex)
    result

f_findNearestActiveWeeklyLowIndices(float refPrice, int maxCount) =>
    result = array.new_int()
    int sz = array.size(weeklyLowPrices)
    if sz > 0
        for pick = 0 to maxCount - 1
            float bestPrice = na
            int bestIndex = INVALID_INDEX
            for i = 0 to sz - 1
                bool isBroken = array.get(weeklyLowBroken, i)
                float level   = array.get(weeklyLowPrices, i)
                bool alreadyPicked = false
                int existingCount = array.size(result)
                if existingCount > 0
                    for j = 0 to existingCount - 1
                        if array.get(result, j) == i
                            alreadyPicked := true
                            break
                if not isBroken and not alreadyPicked and level < refPrice
                    if na(bestPrice) or level > bestPrice
                        bestPrice := level
                        bestIndex := i
            if bestIndex != INVALID_INDEX
                array.push(result, bestIndex)
    result

f_findNearestActiveDailyHighIndices(float refPrice, int maxCount, array<int> activeWeeklyHighs) =>
    result = array.new_int()
    int sz = array.size(dailyHighPrices)
    if sz > 0
        for pick = 0 to maxCount - 1
            float bestPrice = na
            int bestIndex = INVALID_INDEX
            for i = 0 to sz - 1
                bool isBroken = array.get(dailyHighBroken, i)
                float level   = array.get(dailyHighPrices, i)
                bool alreadyPicked = false
                int existingCount = array.size(result)
                if existingCount > 0
                    for j = 0 to existingCount - 1
                        if array.get(result, j) == i
                            alreadyPicked := true
                            break

                bool overlapsWeekly = false
                int weeklyCount = array.size(activeWeeklyHighs)
                if weeklyCount > 0
                    for j = 0 to weeklyCount - 1
                        int weeklyIndex = array.get(activeWeeklyHighs, j)
                        float weeklyLevel = array.get(weeklyHighPrices, weeklyIndex)
                        if f_isSameLevel(level, weeklyLevel)
                            overlapsWeekly := true
                            break

                if not isBroken and not alreadyPicked and not overlapsWeekly and level > refPrice
                    if na(bestPrice) or level < bestPrice
                        bestPrice := level
                        bestIndex := i
            if bestIndex != INVALID_INDEX
                array.push(result, bestIndex)
    result

f_findNearestActiveDailyLowIndices(float refPrice, int maxCount, array<int> activeWeeklyLows) =>
    result = array.new_int()
    int sz = array.size(dailyLowPrices)
    if sz > 0
        for pick = 0 to maxCount - 1
            float bestPrice = na
            int bestIndex = INVALID_INDEX
            for i = 0 to sz - 1
                bool isBroken = array.get(dailyLowBroken, i)
                float level   = array.get(dailyLowPrices, i)
                bool alreadyPicked = false
                int existingCount = array.size(result)
                if existingCount > 0
                    for j = 0 to existingCount - 1
                        if array.get(result, j) == i
                            alreadyPicked := true
                            break

                bool overlapsWeekly = false
                int weeklyCount = array.size(activeWeeklyLows)
                if weeklyCount > 0
                    for j = 0 to weeklyCount - 1
                        int weeklyIndex = array.get(activeWeeklyLows, j)
                        float weeklyLevel = array.get(weeklyLowPrices, weeklyIndex)
                        if f_isSameLevel(level, weeklyLevel)
                            overlapsWeekly := true
                            break

                if not isBroken and not alreadyPicked and not overlapsWeekly and level < refPrice
                    if na(bestPrice) or level > bestPrice
                        bestPrice := level
                        bestIndex := i
            if bestIndex != INVALID_INDEX
                array.push(result, bestIndex)
    result

f_getLastBrokenWeeklyHighIndices(int countWanted) =>
    result = array.new_int()
    int sz = array.size(weeklyHighPrices)
    if sz > 0
        for i = sz - 1 to 0
            if array.get(weeklyHighBroken, i)
                array.push(result, i)
                if array.size(result) >= countWanted
                    break
    result

f_getLastBrokenWeeklyLowIndices(int countWanted) =>
    result = array.new_int()
    int sz = array.size(weeklyLowPrices)
    if sz > 0
        for i = sz - 1 to 0
            if array.get(weeklyLowBroken, i)
                array.push(result, i)
                if array.size(result) >= countWanted
                    break
    result

f_getLastBrokenDailyHighIndices(int countWanted) =>
    result = array.new_int()
    int sz = array.size(dailyHighPrices)
    if sz > 0
        for i = sz - 1 to 0
            if array.get(dailyHighBroken, i)
                array.push(result, i)
                if array.size(result) >= countWanted
                    break
    result

f_getLastBrokenDailyLowIndices(int countWanted) =>
    result = array.new_int()
    int sz = array.size(dailyLowPrices)
    if sz > 0
        for i = sz - 1 to 0
            if array.get(dailyLowBroken, i)
                array.push(result, i)
                if array.size(result) >= countWanted
                    break
    result

//----------------------------------------------------
// Visual storage
//----------------------------------------------------
var weeklyHighLines   = array.new_line(MAX_VISIBLE_LEVELS)
var weeklyHighLabels  = array.new_label(MAX_VISIBLE_LEVELS)
var weeklyLowLines    = array.new_line(MAX_VISIBLE_LEVELS)
var weeklyLowLabels   = array.new_label(MAX_VISIBLE_LEVELS)

var weeklyBrokenHighLines  = array.new_line(FADED_BROKEN_COUNT)
var weeklyBrokenHighLabels = array.new_label(FADED_BROKEN_COUNT)
var weeklyBrokenLowLines   = array.new_line(FADED_BROKEN_COUNT)
var weeklyBrokenLowLabels  = array.new_label(FADED_BROKEN_COUNT)

var dailyHighLines   = array.new_line(MAX_VISIBLE_LEVELS)
var dailyHighLabels  = array.new_label(MAX_VISIBLE_LEVELS)
var dailyLowLines    = array.new_line(MAX_VISIBLE_LEVELS)
var dailyLowLabels   = array.new_label(MAX_VISIBLE_LEVELS)

var dailyBrokenHighLines  = array.new_line(FADED_BROKEN_COUNT)
var dailyBrokenHighLabels = array.new_label(FADED_BROKEN_COUNT)
var dailyBrokenLowLines   = array.new_line(FADED_BROKEN_COUNT)
var dailyBrokenLowLabels  = array.new_label(FADED_BROKEN_COUNT)

//----------------------------------------------------
// Initialize
//----------------------------------------------------
if barstate.isfirst
    for i = 0 to MAX_VISIBLE_LEVELS - 1
        array.set(weeklyHighLines, i, na)
        array.set(weeklyHighLabels, i, na)
        array.set(weeklyLowLines, i, na)
        array.set(weeklyLowLabels, i, na)
        array.set(dailyHighLines, i, na)
        array.set(dailyHighLabels, i, na)
        array.set(dailyLowLines, i, na)
        array.set(dailyLowLabels, i, na)

    for i = 0 to FADED_BROKEN_COUNT - 1
        array.set(weeklyBrokenHighLines, i, na)
        array.set(weeklyBrokenHighLabels, i, na)
        array.set(weeklyBrokenLowLines, i, na)
        array.set(weeklyBrokenLowLabels, i, na)
        array.set(dailyBrokenHighLines, i, na)
        array.set(dailyBrokenHighLabels, i, na)
        array.set(dailyBrokenLowLines, i, na)
        array.set(dailyBrokenLowLabels, i, na)

//----------------------------------------------------
// Draw helper
//----------------------------------------------------
f_drawPivotLevel(
    line existingLine,
    label existingLabel,
    int pivotTime,
    float price,
    string labelText,
    color lineColor,
    color textColor,
    int lineWidth
) =>
    f_clearLine(existingLine)
    f_clearLabel(existingLabel)

    line newLine = line.new(x1=pivotTime, y1=price, x2=time, y2=price, xloc=xloc.bar_time, extend=extend.right, color=lineColor, width=lineWidth)
    label newLabel = label.new(x=time, y=price, text=labelText, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_none, color=na, textcolor=textColor, size=size.small)

    [newLine, newLabel]

//----------------------------------------------------
// Asian session logic
//----------------------------------------------------
asianSessionActive = showLowerTfOnly and not na(time(timeframe.period, asianSessionTime, asianTimezone))
asianSessionStart  = asianSessionActive and not asianSessionActive[1]
asianSessionEnd    = not asianSessionActive and asianSessionActive[1]

if not showLowerTfOnly
    if not na(currentAsianHighLine)
        line.delete(currentAsianHighLine)
        currentAsianHighLine := na
    if not na(currentAsianLowLine)
        line.delete(currentAsianLowLine)
        currentAsianLowLine := na
    if not na(currentAsianFillBox)
        box.delete(currentAsianFillBox)
        currentAsianFillBox := na

if asianSessionStart
    asianHigh := high
    asianLow := low
    asianStartTime := time
    asianEndTime := time
    currentAsianHighLine := na
    currentAsianLowLine := na
    currentAsianFillBox := na

    if showAsianRange
        currentAsianHighLine := line.new(asianStartTime, asianHigh, asianEndTime, asianHigh, xloc=xloc.bar_time, extend=extend.none, color=ASIAN_LINE_COLOR, width=ASIAN_LINE_WIDTH)
        currentAsianLowLine  := line.new(asianStartTime, asianLow, asianEndTime, asianLow, xloc=xloc.bar_time, extend=extend.none, color=ASIAN_LINE_COLOR, width=ASIAN_LINE_WIDTH)
        array.push(asianHighLines, currentAsianHighLine)
        array.push(asianLowLines, currentAsianLowLine)

    if showAsianShading
        currentAsianFillBox := box.new(asianStartTime, asianHigh, asianEndTime, asianLow, xloc=xloc.bar_time, border_color=ASIAN_BORDER_INVISIBLE, bgcolor=ASIAN_FILL_COLOR, border_width=0)
        array.push(asianFillBoxes, currentAsianFillBox)

if asianSessionActive
    asianHigh := na(asianHigh) ? high : math.max(asianHigh, high)
    asianLow := na(asianLow) ? low : math.min(asianLow, low)
    asianEndTime := time

    if showAsianRange
        if not na(currentAsianHighLine)
            line.set_x1(currentAsianHighLine, asianStartTime)
            line.set_x2(currentAsianHighLine, asianEndTime)
            line.set_y1(currentAsianHighLine, asianHigh)
            line.set_y2(currentAsianHighLine, asianHigh)
        if not na(currentAsianLowLine)
            line.set_x1(currentAsianLowLine, asianStartTime)
            line.set_x2(currentAsianLowLine, asianEndTime)
            line.set_y1(currentAsianLowLine, asianLow)
            line.set_y2(currentAsianLowLine, asianLow)

    if showAsianShading and not na(currentAsianFillBox)
        box.set_left(currentAsianFillBox, asianStartTime)
        box.set_right(currentAsianFillBox, asianEndTime)
        box.set_top(currentAsianFillBox, asianHigh)
        box.set_bottom(currentAsianFillBox, asianLow)

if asianSessionEnd
    asianEndTime := time[1]
    if showAsianRange
        if not na(currentAsianHighLine)
            line.set_x2(currentAsianHighLine, asianEndTime)
        if not na(currentAsianLowLine)
            line.set_x2(currentAsianLowLine, asianEndTime)

    if showAsianShading and not na(currentAsianFillBox)
        box.set_right(currentAsianFillBox, asianEndTime)

//----------------------------------------------------
// Psychological levels
//----------------------------------------------------
if barstate.islast
    int psychCount = array.size(psychLines)
    if psychCount > 0
        for i = 0 to psychCount - 1
            line ln = array.get(psychLines, i)
            if not na(ln)
                line.delete(ln)
    array.clear(psychLines)

    if showPsychLevels and showLowerTfOnly
        float pipSize = syminfo.mintick * 10.0
        float blockSize = pipSize * 100.0
        float[] offsets = array.from(0.0, 20.0, 50.0, 80.0, 100.0)

        float anchor = close
        float baseBlock = math.floor(anchor / blockSize) * blockSize

        for block = -6 to 6
            float blockBase = baseBlock + (block * blockSize)

            for j = 0 to array.size(offsets) - 1
                float level = blockBase + (array.get(offsets, j) * pipSize)

                line newPsychLine = line.new(
                     x1 = bar_index - 500,
                     y1 = level,
                     x2 = bar_index + 500,
                     y2 = level,
                     xloc = xloc.bar_index,
                     extend = extend.none,
                     color = PSYCH_LEVEL_COLOR,
                     width = PSYCH_LINE_WIDTH
                 )
                array.push(psychLines, newPsychLine)

//----------------------------------------------------
// Session backgrounds / killzones on 30m only
//----------------------------------------------------
sessionBgActive = showOnly30m and showSessionBg and not na(time(timeframe.period, sessionBgTime, sessionBgTimezone))
killzone1Active = showOnly15m and showKillzones and not na(time(timeframe.period, killzone1Time, killzoneTimezone))
killzone2Active = showOnly15m and showKillzones and not na(time(timeframe.period, killzone2Time, killzoneTimezone))

bgcolor(sessionBgActive ? SESSION_BG_COLOR : na)
bgcolor(killzone1Active ? KILLZONE_1_BG_COLOR : na)
bgcolor(killzone2Active ? KILLZONE_2_BG_COLOR : na)

//----------------------------------------------------
// Killzone marker lines at 8AM and 1PM on 30m only
//----------------------------------------------------
mark8Session  = showOnly15m and showKillzoneMarks and not na(time(timeframe.period, "0800-0815", killzoneTimezone))
mark13Session = showOnly15m and showKillzoneMarks and not na(time(timeframe.period, "1300-1315", killzoneTimezone))

mark8Start  = mark8Session and not mark8Session[1]
mark13Start = mark13Session and not mark13Session[1]

if mark8Start
    line newMark8 = line.new(
         x1 = time,
         y1 = low - (ta.atr(14) * 20),
         x2 = time,
         y2 = high + (ta.atr(14) * 20),
         xloc = xloc.bar_time,
         extend = extend.none,
         color = KILLZONE_LINE_COLOR,
         width = KILLZONE_LINE_WIDTH
     )
    array.push(killzoneMarkLines, newMark8)

if mark13Start
    line newMark13 = line.new(
         x1 = time,
         y1 = low - (ta.atr(14) * 20),
         x2 = time,
         y2 = high + (ta.atr(14) * 20),
         xloc = xloc.bar_time,
         extend = extend.none,
         color = KILLZONE_LINE_COLOR,
         width = KILLZONE_LINE_WIDTH
     )
    array.push(killzoneMarkLines, newMark13)

//----------------------------------------------------
// Render active weekly highs
//----------------------------------------------------
activeWeeklyHighIndices = f_findNearestActiveWeeklyHighIndices(close, MAX_VISIBLE_LEVELS)

for slot = 0 to MAX_VISIBLE_LEVELS - 1
    line existingLine = array.get(weeklyHighLines, slot)
    label existingLabel = array.get(weeklyHighLabels, slot)

    if slot < array.size(activeWeeklyHighIndices)
        int pivotIndex   = array.get(activeWeeklyHighIndices, slot)
        float pivotPrice = array.get(weeklyHighPrices, pivotIndex)
        int pivotTime    = array.get(weeklyHighTimes, pivotIndex)
        string labelText = "WH" + str.tostring(slot + 1)

        [newLine, newLabel] = f_drawPivotLevel(existingLine, existingLabel, pivotTime, pivotPrice, labelText, WEEKLY_ACTIVE_COLOR, WEEKLY_ACTIVE_TEXT_COLOR, ACTIVE_LINE_WIDTH)
        array.set(weeklyHighLines, slot, newLine)
        array.set(weeklyHighLabels, slot, newLabel)
    else
        f_clearLine(existingLine)
        f_clearLabel(existingLabel)
        array.set(weeklyHighLines, slot, na)
        array.set(weeklyHighLabels, slot, na)

//----------------------------------------------------
// Render active weekly lows
//----------------------------------------------------
activeWeeklyLowIndices = f_findNearestActiveWeeklyLowIndices(close, MAX_VISIBLE_LEVELS)

for slot = 0 to MAX_VISIBLE_LEVELS - 1
    line existingLine = array.get(weeklyLowLines, slot)
    label existingLabel = array.get(weeklyLowLabels, slot)

    if slot < array.size(activeWeeklyLowIndices)
        int pivotIndex   = array.get(activeWeeklyLowIndices, slot)
        float pivotPrice = array.get(weeklyLowPrices, pivotIndex)
        int pivotTime    = array.get(weeklyLowTimes, pivotIndex)
        string labelText = "WL" + str.tostring(slot + 1)

        [newLine, newLabel] = f_drawPivotLevel(existingLine, existingLabel, pivotTime, pivotPrice, labelText, WEEKLY_ACTIVE_COLOR, WEEKLY_ACTIVE_TEXT_COLOR, ACTIVE_LINE_WIDTH)
        array.set(weeklyLowLines, slot, newLine)
        array.set(weeklyLowLabels, slot, newLabel)
    else
        f_clearLine(existingLine)
        f_clearLabel(existingLabel)
        array.set(weeklyLowLines, slot, na)
        array.set(weeklyLowLabels, slot, na)

//----------------------------------------------------
// Render broken weekly highs
//----------------------------------------------------
brokenWeeklyHighIndices = f_getLastBrokenWeeklyHighIndices(FADED_BROKEN_COUNT)

for slot = 0 to FADED_BROKEN_COUNT - 1
    line existingLine = array.get(weeklyBrokenHighLines, slot)
    label existingLabel = array.get(weeklyBrokenHighLabels, slot)

    f_clearLabel(existingLabel)
    array.set(weeklyBrokenHighLabels, slot, na)

    if slot < array.size(brokenWeeklyHighIndices)
        int pivotIndex   = array.get(brokenWeeklyHighIndices, slot)
        float pivotPrice = array.get(weeklyHighPrices, pivotIndex)
        int pivotTime    = array.get(weeklyHighTimes, pivotIndex)

        f_clearLine(existingLine)
        line newLine = line.new(x1=pivotTime, y1=pivotPrice, x2=time, y2=pivotPrice, xloc=xloc.bar_time, extend=extend.right, color=WEEKLY_BROKEN_COLOR, width=BROKEN_LINE_WIDTH)
        array.set(weeklyBrokenHighLines, slot, newLine)
    else
        f_clearLine(existingLine)
        array.set(weeklyBrokenHighLines, slot, na)

//----------------------------------------------------
// Render broken weekly lows
//----------------------------------------------------
brokenWeeklyLowIndices = f_getLastBrokenWeeklyLowIndices(FADED_BROKEN_COUNT)

for slot = 0 to FADED_BROKEN_COUNT - 1
    line existingLine = array.get(weeklyBrokenLowLines, slot)
    label existingLabel = array.get(weeklyBrokenLowLabels, slot)

    f_clearLabel(existingLabel)
    array.set(weeklyBrokenLowLabels, slot, na)

    if slot < array.size(brokenWeeklyLowIndices)
        int pivotIndex   = array.get(brokenWeeklyLowIndices, slot)
        float pivotPrice = array.get(weeklyLowPrices, pivotIndex)
        int pivotTime    = array.get(weeklyLowTimes, pivotIndex)

        f_clearLine(existingLine)
        line newLine = line.new(x1=pivotTime, y1=pivotPrice, x2=time, y2=pivotPrice, xloc=xloc.bar_time, extend=extend.right, color=WEEKLY_BROKEN_COLOR, width=BROKEN_LINE_WIDTH)
        array.set(weeklyBrokenLowLines, slot, newLine)
    else
        f_clearLine(existingLine)
        array.set(weeklyBrokenLowLines, slot, na)

//----------------------------------------------------
// Render active daily highs
//----------------------------------------------------
activeDailyHighIndices = f_findNearestActiveDailyHighIndices(close, MAX_VISIBLE_LEVELS, activeWeeklyHighIndices)

for slot = 0 to MAX_VISIBLE_LEVELS - 1
    line existingLine = array.get(dailyHighLines, slot)
    label existingLabel = array.get(dailyHighLabels, slot)

    if slot < array.size(activeDailyHighIndices)
        int pivotIndex   = array.get(activeDailyHighIndices, slot)
        float pivotPrice = array.get(dailyHighPrices, pivotIndex)
        int pivotTime    = array.get(dailyHighTimes, pivotIndex)
        string labelText = "DH" + str.tostring(slot + 1)

        [newLine, newLabel] = f_drawPivotLevel(existingLine, existingLabel, pivotTime, pivotPrice, labelText, DAILY_ACTIVE_COLOR, DAILY_ACTIVE_TEXT_COLOR, ACTIVE_LINE_WIDTH)
        array.set(dailyHighLines, slot, newLine)
        array.set(dailyHighLabels, slot, newLabel)
    else
        f_clearLine(existingLine)
        f_clearLabel(existingLabel)
        array.set(dailyHighLines, slot, na)
        array.set(dailyHighLabels, slot, na)

//----------------------------------------------------
// Render active daily lows
//----------------------------------------------------
activeDailyLowIndices = f_findNearestActiveDailyLowIndices(close, MAX_VISIBLE_LEVELS, activeWeeklyLowIndices)

for slot = 0 to MAX_VISIBLE_LEVELS - 1
    line existingLine = array.get(dailyLowLines, slot)
    label existingLabel = array.get(dailyLowLabels, slot)

    if slot < array.size(activeDailyLowIndices)
        int pivotIndex   = array.get(activeDailyLowIndices, slot)
        float pivotPrice = array.get(dailyLowPrices, pivotIndex)
        int pivotTime    = array.get(dailyLowTimes, pivotIndex)
        string labelText = "DL" + str.tostring(slot + 1)

        [newLine, newLabel] = f_drawPivotLevel(existingLine, existingLabel, pivotTime, pivotPrice, labelText, DAILY_ACTIVE_COLOR, DAILY_ACTIVE_TEXT_COLOR, ACTIVE_LINE_WIDTH)
        array.set(dailyLowLines, slot, newLine)
        array.set(dailyLowLabels, slot, newLabel)
    else
        f_clearLine(existingLine)
        f_clearLabel(existingLabel)
        array.set(dailyLowLines, slot, na)
        array.set(dailyLowLabels, slot, na)

//----------------------------------------------------
// Render broken daily highs
//----------------------------------------------------
brokenDailyHighIndices = f_getLastBrokenDailyHighIndices(FADED_BROKEN_COUNT)

for slot = 0 to FADED_BROKEN_COUNT - 1
    line existingLine = array.get(dailyBrokenHighLines, slot)
    label existingLabel = array.get(dailyBrokenHighLabels, slot)

    f_clearLabel(existingLabel)
    array.set(dailyBrokenHighLabels, slot, na)

    if slot < array.size(brokenDailyHighIndices)
        int pivotIndex   = array.get(brokenDailyHighIndices, slot)
        float pivotPrice = array.get(dailyHighPrices, pivotIndex)
        int pivotTime    = array.get(dailyHighTimes, pivotIndex)

        f_clearLine(existingLine)
        line newLine = line.new(x1=pivotTime, y1=pivotPrice, x2=time, y2=pivotPrice, xloc=xloc.bar_time, extend=extend.right, color=DAILY_BROKEN_COLOR, width=BROKEN_LINE_WIDTH)
        array.set(dailyBrokenHighLines, slot, newLine)
    else
        f_clearLine(existingLine)
        array.set(dailyBrokenHighLines, slot, na)

//----------------------------------------------------
// Render broken daily lows
//----------------------------------------------------
brokenDailyLowIndices = f_getLastBrokenDailyLowIndices(FADED_BROKEN_COUNT)

for slot = 0 to FADED_BROKEN_COUNT - 1
    line existingLine = array.get(dailyBrokenLowLines, slot)
    label existingLabel = array.get(dailyBrokenLowLabels, slot)

    f_clearLabel(existingLabel)
    array.set(dailyBrokenLowLabels, slot, na)

    if slot < array.size(brokenDailyLowIndices)
        int pivotIndex   = array.get(brokenDailyLowIndices, slot)
        float pivotPrice = array.get(dailyLowPrices, pivotIndex)
        int pivotTime    = array.get(dailyLowTimes, pivotIndex)

        f_clearLine(existingLine)
        line newLine = line.new(x1=pivotTime, y1=pivotPrice, x2=time, y2=pivotPrice, xloc=xloc.bar_time, extend=extend.right, color=DAILY_BROKEN_COLOR, width=BROKEN_LINE_WIDTH)
        array.set(dailyBrokenLowLines, slot, newLine)
    else
        f_clearLine(existingLine)
        array.set(dailyBrokenLowLines, slot, na)
````
