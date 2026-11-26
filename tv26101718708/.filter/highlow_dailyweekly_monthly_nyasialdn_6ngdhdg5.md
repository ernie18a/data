# High/Low Daily,Weekly, monthly. NY-Asia-Ldn

- url: https://www.tradingview.com/script/6nGDHdg5/
- type: indicator
- pine_id: PUB;7fe4f8aa0efe463d854eb810ef70bb47
- version: 1.0

## Description

HTF Candle High/Low Projection (D/W/M/Y)

This indicator automatically projects the highs and lows of higher timeframe candles directly onto the current chart.
It supports Daily, Weekly, Monthly, and Yearly levels.

Each time a higher timeframe period closes:

the script records that candle’s high and low,

then draws them as horizontal levels on the chart,

with a clear label showing their origin: D, W, M, or Y.

These levels remain visible until price touches them for the first time.
Once a level is hit by a wick, the projection stops exactly at that point, allowing the trader to clearly identify where the market reacted.

The indicator is fully customizable:

enable or disable each timeframe individually,

choose custom colors for Daily, Weekly, Monthly, and Yearly levels,

adjust line style, line width, label size, and label offset,

control the maximum number of active objects on the chart.

This makes it useful for identifying:

higher timeframe liquidity,

important reaction zones,

untouched highs and lows,

and key areas where price may seek or react.

In short, this tool helps traders keep important HTF reference levels visible at all times in a clean and structured way.

## Source Code

````pine
//@version=6
indicator("HTF + Sessions Levels from Real High/Low Candle", overlay=true, max_lines_count=500, max_labels_count=500)

//====================================================
// INPUTS
//====================================================
groupGeneral = "General"
showDaily    = input.bool(false, "Show Daily", group=groupGeneral)
showWeekly   = input.bool(true,  "Show Weekly", group=groupGeneral)
showMonthly  = input.bool(true,  "Show Monthly", group=groupGeneral)
showYearly   = input.bool(true,  "Show Yearly", group=groupGeneral)
showAsia     = input.bool(false, "Show Asia", group=groupGeneral)
showLondon   = input.bool(false, "Show London", group=groupGeneral)
showNewYork  = input.bool(false, "Show New York", group=groupGeneral)
maxLevels    = input.int(200, "Max active levels", minval=50, maxval=500, group=groupGeneral)
keepSweptDays = input.int(30, "Keep swept levels for X days", minval=1, maxval=365, group=groupGeneral)

groupStyle = "Style"
dailyColor          = input.color(color.lime,    "Daily color", group=groupStyle)
weeklyColor         = input.color(color.aqua,    "Weekly color", group=groupStyle)
monthlyColor        = input.color(color.orange,  "Monthly color", group=groupStyle)
yearlyColor         = input.color(color.fuchsia, "Yearly color", group=groupStyle)
asiaColor           = input.color(color.yellow,  "Asia color", group=groupStyle)
londonColor         = input.color(color.blue,    "London color", group=groupStyle)
newYorkColor        = input.color(color.red,     "New York color", group=groupStyle)
lineWidth           = input.int(1, "Line width", minval=1, maxval=4, group=groupStyle)
labelSizeIn         = input.string("Tiny", "Label size", options=["Tiny", "Small", "Normal"], group=groupStyle)
mergeToleranceTicks = input.int(3, "Merge tolerance (ticks)", minval=1, maxval=50, group=groupStyle)

groupSessions = "Sessions"
sessionTz      = input.string("Etc/UTC", "Session timezone", group=groupSessions)
asiaSession    = input.session("0000-0800", "Asia session", group=groupSessions)
londonSession  = input.session("0800-1300", "London session", group=groupSessions)
newYorkSession = input.session("1300-1700", "New York session", group=groupSessions)

//====================================================
// STYLE HELPERS
//====================================================
f_labelSize(_s) =>
    _s == "Tiny" ? size.tiny : _s == "Small" ? size.small : size.normal

labelSize = f_labelSize(labelSizeIn)

//====================================================
// STORAGE
//====================================================
var line[]   lvlLines      = array.new_line()
var float[]  lvlPrices     = array.new_float()
var string[] lvlTexts      = array.new_string()
var color[]  lvlColors     = array.new_color()
var int[]    lvlStartT     = array.new_int()
var bool[]   lvlActive     = array.new_bool()
var int[]    lvlSweepTime  = array.new_int()

var label[] mergedLabels = array.new_label()

//====================================================
// HELPERS
//====================================================
f_joinText(_base, _add) =>
    _base == "" ? _add : _base + " / " + _add

f_clearMergedLabels() =>
    int sz = array.size(mergedLabels)
    if sz > 0
        for i = 0 to sz - 1
            label.delete(array.get(mergedLabels, i))
    array.clear(mergedLabels)

f_barMs() =>
    int ms = na(time[1]) ? 1 : int(time - time[1])
    ms <= 0 ? 1 : ms

f_addLevel(_startTime, _price, _txt, _col) =>
    line l = line.new(
         _startTime, _price,
         time,       _price,
         xloc=xloc.bar_time,
         extend=extend.none,
         color=_col,
         width=lineWidth,
         style=line.style_dotted
     )

    array.push(lvlLines, l)
    array.push(lvlPrices, _price)
    array.push(lvlTexts, _txt)
    array.push(lvlColors, _col)
    array.push(lvlStartT, _startTime)
    array.push(lvlActive, true)
    array.push(lvlSweepTime, na)

    if array.size(lvlLines) > maxLevels
        line.delete(array.shift(lvlLines))
        array.shift(lvlPrices)
        array.shift(lvlTexts)
        array.shift(lvlColors)
        array.shift(lvlStartT)
        array.shift(lvlActive)
        array.shift(lvlSweepTime)

//====================================================
// DELETE ONLY OLD SWEPT LEVELS
//====================================================
f_pruneOldSweptLevels() =>
    int keepMs = keepSweptDays * 24 * 60 * 60 * 1000
    int i = array.size(lvlLines) - 1

    while i >= 0
        bool active = array.get(lvlActive, i)
        int swpT = array.get(lvlSweepTime, i)

        bool deleteIt = not active and not na(swpT) and (time - swpT > keepMs)

        if deleteIt
            line.delete(array.get(lvlLines, i))
            array.remove(lvlLines, i)
            array.remove(lvlPrices, i)
            array.remove(lvlTexts, i)
            array.remove(lvlColors, i)
            array.remove(lvlStartT, i)
            array.remove(lvlActive, i)
            array.remove(lvlSweepTime, i)

        i -= 1

//====================================================
// UPDATE LEVELS
//====================================================
f_updateLevels() =>
    int sz = array.size(lvlLines)

    if sz > 0
        for i = 0 to sz - 1
            bool active = array.get(lvlActive, i)

            if active
                line l = array.get(lvlLines, i)
                float pr = array.get(lvlPrices, i)
                int st = array.get(lvlStartT, i)

                line.set_x2(l, time)

                bool canSweep = time > st
                bool touched = canSweep and high >= pr and low <= pr

                if touched
                    array.set(lvlActive, i, false)
                    array.set(lvlSweepTime, i, time)
                    line.set_x2(l, time)

//====================================================
// MERGED LABELS
//====================================================
f_updateMergedLabels() =>
    f_clearMergedLabels()

    int sz = array.size(lvlLines)

    if sz > 0
        float tol = mergeToleranceTicks * syminfo.mintick
        int barMs = f_barMs()

        float[] actPrices = array.new_float()
        string[] actTexts = array.new_string()
        color[] actColors = array.new_color()

        float[] swpPrices = array.new_float()
        string[] swpTexts = array.new_string()
        color[] swpColors = array.new_color()
        int[] swpTimes = array.new_int()

        for i = 0 to sz - 1
            bool active = array.get(lvlActive, i)
            float pr = array.get(lvlPrices, i)
            string txt = array.get(lvlTexts, i)
            color col = array.get(lvlColors, i)

            if active
                int foundA = -1
                int actSz = array.size(actPrices)

                if actSz > 0
                    for g = 0 to actSz - 1
                        float grpPr = array.get(actPrices, g)
                        if math.abs(pr - grpPr) <= tol
                            foundA := g
                            break

                if foundA == -1
                    array.push(actPrices, pr)
                    array.push(actTexts, txt)
                    array.push(actColors, col)
                else
                    string cur = array.get(actTexts, foundA)
                    array.set(actTexts, foundA, f_joinText(cur, txt))

            else
                int swpT = array.get(lvlSweepTime, i)

                if not na(swpT)
                    int foundS = -1
                    int swpSz = array.size(swpPrices)

                    if swpSz > 0
                        for g = 0 to swpSz - 1
                            float grpPr = array.get(swpPrices, g)
                            int grpT = array.get(swpTimes, g)

                            bool samePrice = math.abs(pr - grpPr) <= tol
                            bool sameTime  = math.abs(swpT - grpT) <= barMs

                            if samePrice and sameTime
                                foundS := g
                                break

                    if foundS == -1
                        array.push(swpPrices, pr)
                        array.push(swpTexts, txt)
                        array.push(swpColors, col)
                        array.push(swpTimes, swpT)
                    else
                        string cur = array.get(swpTexts, foundS)
                        array.set(swpTexts, foundS, f_joinText(cur, txt))

        int actFinalSz = array.size(actPrices)
        if actFinalSz > 0
            for g = 0 to actFinalSz - 1
                label lb = label.new(
                     time,
                     array.get(actPrices, g),
                     array.get(actTexts, g),
                     xloc=xloc.bar_time,
                     style=label.style_none,
                     textcolor=array.get(actColors, g),
                     size=labelSize
                 )
                array.push(mergedLabels, lb)

        int swpFinalSz = array.size(swpPrices)
        if swpFinalSz > 0
            for g = 0 to swpFinalSz - 1
                label lb = label.new(
                     array.get(swpTimes, g) - barMs * 2,
                     array.get(swpPrices, g),
                     array.get(swpTexts, g),
                     xloc=xloc.bar_time,
                     style=label.style_none,
                     textcolor=array.get(swpColors, g),
                     size=labelSize
                 )
                array.push(mergedLabels, lb)

//====================================================
// DAILY BUILD
//====================================================
newDay = ta.change(time("D")) != 0

var float dayHigh = na
var float dayLow  = na
var int   dayHighTime = na
var int   dayLowTime  = na

if barstate.isfirst
    dayHigh := high
    dayLow := low
    dayHighTime := time
    dayLowTime := time
else
    if newDay
        if showDaily and not na(dayHigh) and not na(dayLow)
            f_addLevel(dayHighTime, dayHigh, "D", dailyColor)
            f_addLevel(dayLowTime,  dayLow,  "D", dailyColor)

        dayHigh := high
        dayLow := low
        dayHighTime := time
        dayLowTime := time
    else
        if high > dayHigh
            dayHigh := high
            dayHighTime := time
        if low < dayLow
            dayLow := low
            dayLowTime := time

//====================================================
// WEEKLY BUILD
//====================================================
newWeek = ta.change(time("W")) != 0

var float weekHigh = na
var float weekLow  = na
var int   weekHighTime = na
var int   weekLowTime  = na

if barstate.isfirst
    weekHigh := high
    weekLow := low
    weekHighTime := time
    weekLowTime := time
else
    if newWeek
        if showWeekly and not na(weekHigh) and not na(weekLow)
            f_addLevel(weekHighTime, weekHigh, "W", weeklyColor)
            f_addLevel(weekLowTime,  weekLow,  "W", weeklyColor)

        weekHigh := high
        weekLow := low
        weekHighTime := time
        weekLowTime := time
    else
        if high > weekHigh
            weekHigh := high
            weekHighTime := time
        if low < weekLow
            weekLow := low
            weekLowTime := time

//====================================================
// MONTHLY BUILD
//====================================================
newMonth = ta.change(time("M")) != 0

var float monthHigh = na
var float monthLow  = na
var int   monthHighTime = na
var int   monthLowTime  = na

if barstate.isfirst
    monthHigh := high
    monthLow := low
    monthHighTime := time
    monthLowTime := time
else
    if newMonth
        if showMonthly and not na(monthHigh) and not na(monthLow)
            f_addLevel(monthHighTime, monthHigh, "M", monthlyColor)
            f_addLevel(monthLowTime,  monthLow,  "M", monthlyColor)

        monthHigh := high
        monthLow := low
        monthHighTime := time
        monthLowTime := time
    else
        if high > monthHigh
            monthHigh := high
            monthHighTime := time
        if low < monthLow
            monthLow := low
            monthLowTime := time

//====================================================
// YEARLY BUILD
//====================================================
newYear = ta.change(time("12M")) != 0

var float yearHigh = na
var float yearLow  = na
var int   yearHighTime = na
var int   yearLowTime  = na

if barstate.isfirst
    yearHigh := high
    yearLow := low
    yearHighTime := time
    yearLowTime := time
else
    if newYear
        if showYearly and not na(yearHigh) and not na(yearLow)
            f_addLevel(yearHighTime, yearHigh, "Y", yearlyColor)
            f_addLevel(yearLowTime,  yearLow,  "Y", yearlyColor)

        yearHigh := high
        yearLow := low
        yearHighTime := time
        yearLowTime := time
    else
        if high > yearHigh
            yearHigh := high
            yearHighTime := time
        if low < yearLow
            yearLow := low
            yearLowTime := time

//====================================================
// ASIA SESSION BUILD
//====================================================
inAsia = not na(time(timeframe.period, asiaSession, sessionTz))
asiaStart = inAsia and not inAsia[1]
asiaEnd   = not inAsia and inAsia[1]

var float asiaHigh = na
var float asiaLow  = na
var int   asiaHighTime = na
var int   asiaLowTime  = na

if asiaStart
    asiaHigh := high
    asiaLow := low
    asiaHighTime := time
    asiaLowTime := time
else if inAsia
    if high > nz(asiaHigh, high)
        asiaHigh := high
        asiaHighTime := time
    if low < nz(asiaLow, low)
        asiaLow := low
        asiaLowTime := time

if asiaEnd and showAsia and not na(asiaHigh) and not na(asiaLow)
    f_addLevel(asiaHighTime, asiaHigh, "ASIA-H", asiaColor)
    f_addLevel(asiaLowTime,  asiaLow,  "ASIA-L", asiaColor)

//====================================================
// LONDON SESSION BUILD
//====================================================
inLondon = not na(time(timeframe.period, londonSession, sessionTz))
londonStart = inLondon and not inLondon[1]
londonEnd   = not inLondon and inLondon[1]

var float londonHigh = na
var float londonLow  = na
var int   londonHighTime = na
var int   londonLowTime  = na

if londonStart
    londonHigh := high
    londonLow := low
    londonHighTime := time
    londonLowTime := time
else if inLondon
    if high > nz(londonHigh, high)
        londonHigh := high
        londonHighTime := time
    if low < nz(londonLow, low)
        londonLow := low
        londonLowTime := time

if londonEnd and showLondon and not na(londonHigh) and not na(londonLow)
    f_addLevel(londonHighTime, londonHigh, "LDN-H", londonColor)
    f_addLevel(londonLowTime,  londonLow,  "LDN-L", londonColor)

//====================================================
// NEW YORK SESSION BUILD
//====================================================
inNewYork = not na(time(timeframe.period, newYorkSession, sessionTz))
newYorkStart = inNewYork and not inNewYork[1]
newYorkEnd   = not inNewYork and inNewYork[1]

var float newYorkHigh = na
var float newYorkLow  = na
var int   newYorkHighTime = na
var int   newYorkLowTime  = na

if newYorkStart
    newYorkHigh := high
    newYorkLow := low
    newYorkHighTime := time
    newYorkLowTime := time
else if inNewYork
    if high > nz(newYorkHigh, high)
        newYorkHigh := high
        newYorkHighTime := time
    if low < nz(newYorkLow, low)
        newYorkLow := low
        newYorkLowTime := time

if newYorkEnd and showNewYork and not na(newYorkHigh) and not na(newYorkLow)
    f_addLevel(newYorkHighTime, newYorkHigh, "NY-H", newYorkColor)
    f_addLevel(newYorkLowTime,  newYorkLow,  "NY-L", newYorkColor)

//====================================================
// FINAL UPDATE
//====================================================
f_updateLevels()
f_pruneOldSweptLevels()
f_updateMergedLabels()
````
