# Heikin Ashi Camarilla Pivot Points [QuantPad]

- url: https://www.tradingview.com/script/BSG5frsf-Heikin-Ashi-Camarilla-Pivot-Points-QuantPad/
- type: indicator
- pine_id: PUB;2d6b04986d5042f7b42eb87b17a4e752
- version: 1.0

## Description

Weekly/Monthly HA Camarilla Pivot Points
Heiken Ashi's Pivot Point Averages

## Source Code

````pine
// © QuantPad LLC
//@version=6
indicator("Heikin Ashi Camarilla Pivot Points [QuantPad]", overlay=true, max_lines_count=500, max_labels_count=500)

showWeekly = input.bool(true, "Show Weekly HA Pivots", group="Display")
showMonthly = input.bool(true, "Show Monthly HA Pivots", group="Display")
showLevelNames = input.bool(true, "Show Level Labels", group="Display")
showLevelPrices = input.bool(true, "Show Level Prices", group="Display")
weeklyHistoryPeriods = input.int(1, "Weekly Periods To Keep", minval=1, maxval=20, group="History")
monthlyHistoryPeriods = input.int(1, "Monthly Periods To Keep", minval=1, maxval=20, group="History")
weeklyColor = input.color(color.black, "Weekly Pivot Color", group="Display")
monthlyColor = input.color(color.red, "Monthly Pivot Color", group="Display")

f_camarilla(float h, float l, float c) =>
    float rng = h - l
    float p = (h + l + c) / 3.0
    float r1 = c + rng * 1.1 / 12.0
    float s1 = c - rng * 1.1 / 12.0
    float r2 = c + rng * 1.1 / 6.0
    float s2 = c - rng * 1.1 / 6.0
    float r3 = c + rng * 1.1 / 4.0
    float s3 = c - rng * 1.1 / 4.0
    float r4 = c + rng * 1.1 / 2.0
    float s4 = c - rng * 1.1 / 2.0
    float r5 = l != 0.0 ? (h / l) * c : na
    float s5 = not na(r5) ? c - (r5 - c) : na
    [p, r1, s1, r2, s2, r3, s3, r4, s4, r5, s5]

f_level_name(int slot) =>
    string levelName = slot == 0 ? "P" : slot == 1 ? "R1" : slot == 2 ? "R2" : slot == 3 ? "R3" : slot == 4 ? "R4" : slot == 5 ? "R5" : slot == 6 ? "S1" : slot == 7 ? "S2" : slot == 8 ? "S3" : slot == 9 ? "S4" : "S5"
    levelName

f_level_width(int slot) =>
    int lineWidth = slot == 0 or slot == 4 or slot == 5 or slot == 9 or slot == 10 ? 2 : 1
    lineWidth

f_label_text(string prefix, string levelName, float level, bool showName, bool showPrice) =>
    string textValue = ""
    if showName
        textValue := prefix + " " + levelName
    if showPrice
        string priceText = str.tostring(level, format.mintick)
        textValue := textValue == "" ? priceText : textValue + " " + priceText
    textValue

f_add_level(array<line> lineArr, array<label> labelArr, array<int> labelTimeArr, int startTime, int leftLabelTime, float level, color baseColor, string prefix, string levelName, int lineWidth) =>
    line newLine = na
    label newLabel = na
    if not na(level)
        newLine := line.new(x1=startTime, y1=level, x2=time, y2=level, xloc=xloc.bar_time, extend=extend.none, color=baseColor, style=line.style_solid, width=lineWidth)
        newLabel := label.new(x=leftLabelTime, y=level, xloc=xloc.bar_time, yloc=yloc.price, text=prefix + " " + levelName, style=label.style_label_right, textcolor=baseColor, color=color.new(color.white, 100), size=size.tiny, text_font_family=font.family_monospace)
    array.push(lineArr, newLine)
    array.push(labelArr, newLabel)
    array.push(labelTimeArr, leftLabelTime)

f_trim_history(array<line> lineArr, array<label> labelArr, array<int> labelTimeArr, int periodsToKeep) =>
    int maxObjects = periodsToKeep * 11
    while array.size(lineArr) > maxObjects
        line oldLine = array.shift(lineArr)
        if not na(oldLine)
            line.delete(oldLine)
    while array.size(labelArr) > maxObjects
        label oldLabel = array.shift(labelArr)
        if not na(oldLabel)
            label.delete(oldLabel)
    while array.size(labelTimeArr) > maxObjects
        array.shift(labelTimeArr)

f_finalize_last_block(array<line> lineArr, int endTime) =>
    int objCount = array.size(lineArr)
    if objCount >= 11
        int startIdx = objCount - 11
        for i = startIdx to objCount - 1
            line ln = array.get(lineArr, i)
            if not na(ln)
                line.set_x2(ln, endTime)

f_update_objects(array<line> lineArr, array<label> labelArr, array<int> labelTimeArr, bool showSet, color setColor, string prefix, bool showName, bool showPrice) =>
    int objCount = array.size(lineArr)
    if objCount > 0
        int activeStart = math.max(objCount - 11, 0)
        for i = 0 to objCount - 1
            int slot = i % 11
            line ln = array.get(lineArr, i)
            label lb = array.get(labelArr, i)
            int labelTime = array.get(labelTimeArr, i)
            if not na(ln)
                float level = line.get_y1(ln)
                line.set_color(ln, showSet ? setColor : color.new(setColor, 100))
                line.set_width(ln, f_level_width(slot))
                if i >= activeStart
                    line.set_x2(ln, time)
                    line.set_y1(ln, level)
                    line.set_y2(ln, level)
                if not na(lb)
                    label.set_x(lb, labelTime)
                    label.set_y(lb, level)
                    label.set_text(lb, showSet ? f_label_text(prefix, f_level_name(slot), level, showName, showPrice) : "")
                    label.set_style(lb, label.style_label_right)
                    label.set_textcolor(lb, setColor)
                    label.set_color(lb, color.new(color.white, 100))

f_add_pivot_block(array<line> lineArr, array<label> labelArr, array<int> labelTimeArr, int startTime, int leftLabelTime, color setColor, string prefix, float p, float r1, float r2, float r3, float r4, float r5, float s1, float s2, float s3, float s4, float s5) =>
    f_add_level(lineArr, labelArr, labelTimeArr, startTime, leftLabelTime, p, setColor, prefix, "P", 2)
    f_add_level(lineArr, labelArr, labelTimeArr, startTime, leftLabelTime, r1, setColor, prefix, "R1", 1)
    f_add_level(lineArr, labelArr, labelTimeArr, startTime, leftLabelTime, r2, setColor, prefix, "R2", 1)
    f_add_level(lineArr, labelArr, labelTimeArr, startTime, leftLabelTime, r3, setColor, prefix, "R3", 1)
    f_add_level(lineArr, labelArr, labelTimeArr, startTime, leftLabelTime, r4, setColor, prefix, "R4", 2)
    f_add_level(lineArr, labelArr, labelTimeArr, startTime, leftLabelTime, r5, setColor, prefix, "R5", 2)
    f_add_level(lineArr, labelArr, labelTimeArr, startTime, leftLabelTime, s1, setColor, prefix, "S1", 1)
    f_add_level(lineArr, labelArr, labelTimeArr, startTime, leftLabelTime, s2, setColor, prefix, "S2", 1)
    f_add_level(lineArr, labelArr, labelTimeArr, startTime, leftLabelTime, s3, setColor, prefix, "S3", 1)
    f_add_level(lineArr, labelArr, labelTimeArr, startTime, leftLabelTime, s4, setColor, prefix, "S4", 2)
    f_add_level(lineArr, labelArr, labelTimeArr, startTime, leftLabelTime, s5, setColor, prefix, "S5", 2)

haTicker = ticker.heikinashi(syminfo.tickerid)
[weekStartTime, pW, r1W, s1W, r2W, s2W, r3W, s3W, r4W, s4W, r5W, s5W] = request.security(haTicker, "1W", [time, (high[1] + low[1] + close[1]) / 3.0, close[1] + (high[1] - low[1]) * 1.1 / 12.0, close[1] - (high[1] - low[1]) * 1.1 / 12.0, close[1] + (high[1] - low[1]) * 1.1 / 6.0, close[1] - (high[1] - low[1]) * 1.1 / 6.0, close[1] + (high[1] - low[1]) * 1.1 / 4.0, close[1] - (high[1] - low[1]) * 1.1 / 4.0, close[1] + (high[1] - low[1]) * 1.1 / 2.0, close[1] - (high[1] - low[1]) * 1.1 / 2.0, low[1] != 0.0 ? (high[1] / low[1]) * close[1] : na, low[1] != 0.0 ? close[1] - ((high[1] / low[1]) * close[1] - close[1]) : na], barmerge.gaps_off, barmerge.lookahead_off)
[currentMonthStartSeed, monthlySeedHigh, monthlySeedLow, monthlySeedClose] = request.security(syminfo.tickerid, "1M", [time, high[1], low[1], close[1]], barmerge.gaps_off, barmerge.lookahead_off)
[haDayPrevTime, haDayPrevMonthStart] = request.security(haTicker, "1D", [time[1], time("1M")[1]], barmerge.gaps_off, barmerge.lookahead_off)
[rawDayPrevHigh, rawDayPrevLow, rawDayPrevClose] = request.security(syminfo.tickerid, "1D", [high[1], low[1], close[1]], barmerge.gaps_off, barmerge.lookahead_off)

isNewWeeklyPivot = ta.change(weekStartTime) != 0
isNewCompletedHADay = ta.change(haDayPrevTime) != 0
currentMonthStart = time("1M")
isNewMonthlyPeriod = ta.change(currentMonthStart) != 0
chartBarMs = int(math.max(nz(time - time[1], 0), 1))
weeklyLabelTime = weekStartTime - chartBarMs

var weeklyLines = array.new_line()
var weeklyLabels = array.new_label()
var weeklyLabelTimes = array.new_int()
var monthlyLines = array.new_line()
var monthlyLabels = array.new_label()
var monthlyLabelTimes = array.new_int()
var int monthAggStart = na
var float monthAggRawHigh = na
var float monthAggRawLow = na
var float monthAggRawClose = na

if isNewWeeklyPivot
    f_finalize_last_block(weeklyLines, weekStartTime - chartBarMs)
    f_add_pivot_block(weeklyLines, weeklyLabels, weeklyLabelTimes, weekStartTime, weeklyLabelTime, weeklyColor, "W", pW, r1W, r2W, r3W, r4W, r5W, s1W, s2W, s3W, s4W, s5W)

if array.size(monthlyLines) == 0 and not na(monthlySeedHigh) and not na(monthlySeedLow) and not na(monthlySeedClose)
    [pMonthSeed, r1MonthSeed, s1MonthSeed, r2MonthSeed, s2MonthSeed, r3MonthSeed, s3MonthSeed, r4MonthSeed, s4MonthSeed, r5MonthSeed, s5MonthSeed] = f_camarilla(monthlySeedHigh, monthlySeedLow, monthlySeedClose)
    int currentMonthLabelTime = currentMonthStartSeed - chartBarMs
    f_add_pivot_block(monthlyLines, monthlyLabels, monthlyLabelTimes, currentMonthStartSeed, currentMonthLabelTime, monthlyColor, "M", pMonthSeed, r1MonthSeed, r2MonthSeed, r3MonthSeed, r4MonthSeed, r5MonthSeed, s1MonthSeed, s2MonthSeed, s3MonthSeed, s4MonthSeed, s5MonthSeed)

if isNewCompletedHADay and not na(haDayPrevMonthStart)
    if na(monthAggStart)
        monthAggStart := haDayPrevMonthStart
        monthAggRawHigh := rawDayPrevHigh
        monthAggRawLow := rawDayPrevLow
        monthAggRawClose := rawDayPrevClose
    else if haDayPrevMonthStart == monthAggStart
        if na(monthAggRawHigh)
            monthAggRawHigh := rawDayPrevHigh
            monthAggRawLow := rawDayPrevLow
            monthAggRawClose := rawDayPrevClose
        else
            monthAggRawHigh := math.max(monthAggRawHigh, rawDayPrevHigh)
            monthAggRawLow := math.min(monthAggRawLow, rawDayPrevLow)
            monthAggRawClose := rawDayPrevClose
    else
        monthAggStart := haDayPrevMonthStart
        monthAggRawHigh := rawDayPrevHigh
        monthAggRawLow := rawDayPrevLow
        monthAggRawClose := rawDayPrevClose

if isNewMonthlyPeriod and not na(monthAggRawHigh)
    [pMonth, r1Month, s1Month, r2Month, s2Month, r3Month, s3Month, r4Month, s4Month, r5Month, s5Month] = f_camarilla(monthAggRawHigh, monthAggRawLow, monthAggRawClose)
    int nextMonthLabelTime = currentMonthStart - chartBarMs
    f_finalize_last_block(monthlyLines, currentMonthStart - chartBarMs)
    f_add_pivot_block(monthlyLines, monthlyLabels, monthlyLabelTimes, currentMonthStart, nextMonthLabelTime, monthlyColor, "M", pMonth, r1Month, r2Month, r3Month, r4Month, r5Month, s1Month, s2Month, s3Month, s4Month, s5Month)
    monthAggStart := currentMonthStart
    monthAggRawHigh := na
    monthAggRawLow := na
    monthAggRawClose := na

f_trim_history(weeklyLines, weeklyLabels, weeklyLabelTimes, weeklyHistoryPeriods)
f_trim_history(monthlyLines, monthlyLabels, monthlyLabelTimes, monthlyHistoryPeriods)
f_update_objects(weeklyLines, weeklyLabels, weeklyLabelTimes, showWeekly, weeklyColor, "W", showLevelNames, showLevelPrices)
f_update_objects(monthlyLines, monthlyLabels, monthlyLabelTimes, showMonthly, monthlyColor, "M", showLevelNames, showLevelPrices)
````
