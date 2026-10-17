# NDOG + NWOG Lines [ICT Concepts}]

- url: https://www.tradingview.com/script/COp1HR2M-NDOG-NWOG-Lines-ICT-Concepts/
- type: indicator
- pine_id: PUB;63c419ba48854f8abaefc9c59bc766da
- version: 1.0

## Description

Work In Progress

This script colorizes New Day and New Week Opening gaps
Attempted to keep as simple and non-invasive as possible

## Source Code

````pine
//@version=6
indicator("ICT NDOG + NWOG Lines", overlay=true, max_lines_count=500, max_labels_count=500)

tz = "America/New_York"

// Visibility
showNDOG = input.bool(true, "Show NDOG")
showNWOG = input.bool(true, "Show NWOG")
showMid  = input.bool(true, "Show Gap Midpoint")

// Lookback controls
ndogLookbackDays = input.int(6, "NDOG Lookback Days", minval=1, maxval=365)
nwogLookbackWeeks = input.int(12, "NWOG Lookback Weeks", minval=1, maxval=520)

// Color controls
ndogFreshColor = input.color(color.new(color.aqua, 0), "NDOG Fresh Color")
ndogOldColor   = input.color(color.new(color.aqua, 55), "NDOG Older Color")
ndogAncColor   = input.color(color.new(color.aqua, 80), "NDOG Ancient Color")

nwogFreshColor = input.color(color.new(color.orange, 0), "NWOG Fresh Color")
nwogOldColor   = input.color(color.new(color.orange, 45), "NWOG Older Color")
nwogAncColor   = input.color(color.new(color.orange, 75), "NWOG Ancient Color")

midColor = input.color(color.new(color.gray, 65), "Midpoint Color")
lineWidth = input.int(1, "Line Width", minval=1, maxval=4)

var float dailyClose = na
var float weeklyClose = na

var line[] ndogLines = array.new_line()
var int[]  ndogTimes = array.new_int()

var line[] nwogLines = array.new_line()
var int[]  nwogTimes = array.new_int()

f_addLine(float price, color col, style, line[] lineArr, int[] timeArr) =>
    l = line.new(
         x1=time,
         y1=price,
         x2=time + 1,
         y2=price,
         xloc=xloc.bar_time,
         extend=extend.right,
         color=col,
         width=lineWidth,
         style=style)
    array.push(lineArr, l)
    array.push(timeArr, time)

f_cleanLines(line[] lineArr, int[] timeArr, int lookbackMs) =>
    if array.size(lineArr) > 0
        for i = array.size(lineArr) - 1 to 0
            gapTime = array.get(timeArr, i)
            if time - gapTime > lookbackMs
                line.delete(array.get(lineArr, i))
                array.remove(lineArr, i)
                array.remove(timeArr, i)

f_recolorLines(line[] lineArr, int[] timeArr, int lookbackMs, color freshCol, color oldCol, color ancCol) =>
    if array.size(lineArr) > 0
        for i = 0 to array.size(lineArr) - 1
            l = array.get(lineArr, i)
            gapTime = array.get(timeArr, i)
            ageRatio = (time - gapTime) / lookbackMs

            col = ageRatio < 0.33 ? freshCol : ageRatio < 0.66 ? oldCol : ancCol
            line.set_color(l, col)

// Time checks
barCloseHour = hour(time_close, tz)
barCloseMin  = minute(time_close, tz)
barOpenHour  = hour(time, tz)
barOpenMin   = minute(time, tz)

barCloseDay = dayofweek(time_close, tz)
barOpenDay  = dayofweek(time, tz)

isDailyClose = barCloseHour == 17 and barCloseMin == 0
isDailyOpen  = barOpenHour == 18 and barOpenMin == 0

isWeeklyClose = isDailyClose and barCloseDay == dayofweek.friday
isWeeklyOpen  = isDailyOpen and barOpenDay == dayofweek.sunday

if isDailyClose
    dailyClose := close

if isWeeklyClose
    weeklyClose := close

ndogLookbackMs = ndogLookbackDays * 24 * 60 * 60 * 1000
nwogLookbackMs = nwogLookbackWeeks * 7 * 24 * 60 * 60 * 1000

// Draw NDOG
if showNDOG and isDailyOpen and not na(dailyClose)
    dailyOpen = open
    mid = (dailyOpen + dailyClose) / 2

    f_addLine(dailyClose, ndogFreshColor, line.style_solid, ndogLines, ndogTimes)
    f_addLine(dailyOpen, ndogFreshColor, line.style_solid, ndogLines, ndogTimes)

    if showMid
        f_addLine(mid, midColor, line.style_dotted, ndogLines, ndogTimes)

// Draw NWOG
if showNWOG and isWeeklyOpen and not na(weeklyClose)
    weeklyOpen = open
    mid = (weeklyOpen + weeklyClose) / 2

    f_addLine(weeklyClose, nwogFreshColor, line.style_solid, nwogLines, nwogTimes)
    f_addLine(weeklyOpen, nwogFreshColor, line.style_solid, nwogLines, nwogTimes)

    if showMid
        f_addLine(mid, midColor, line.style_dotted, nwogLines, nwogTimes)

// Maintain range
f_cleanLines(ndogLines, ndogTimes, ndogLookbackMs)
f_cleanLines(nwogLines, nwogTimes, nwogLookbackMs)

// Recolor by age
f_recolorLines(ndogLines, ndogTimes, ndogLookbackMs, ndogFreshColor, ndogOldColor, ndogAncColor)
f_recolorLines(nwogLines, nwogTimes, nwogLookbackMs, nwogFreshColor, nwogOldColor, nwogAncColor)
````
