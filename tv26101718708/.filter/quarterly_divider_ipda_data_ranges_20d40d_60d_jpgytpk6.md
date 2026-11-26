# Quarterly Divider + IPDA Data Ranges  20D/40D /60D

- url: https://www.tradingview.com/script/JPGytpK6-Quarterly-Divider-IPDA-Data-Ranges-20D-40D-60D/
- type: indicator
- pine_id: PUB;185c71584ea9431cadaa30b5ef52e38a
- version: 1.0

## Description

This indicator combines quarterly dividers with IPDA 20, 40 and 60 day data ranges. At the start of each new quarter, it identifies the highest confirmed swing high and lowest confirmed swing low from the previous 20, 40 and 60 trading days and projects those levels forward into the new quarter.

Each range is drawn from the actual swing candle where the high or low occurred, giving you clear reference levels for your quarterly analysis. The levels remain active until price reaches them, while the quarterly dividers help clearly separate each new market quarter.

The indicator also includes custom colour, thickness and line-style settings, allowing you to use solid, dashed or dotted lines for your IPDA levels and quarterly dividers.

## Source Code

````pine
//@version=6
indicator("Quarterly Divider + IPDA Data Ranges | 20D • 40D • 60D", overlay=true, max_lines_count=500, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// QUARTERLY DIVIDERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupDivider = "Quarterly Dividers"

showQuarterDividers = input.bool(true, "Show Quarterly Dividers", group=groupDivider)

showQ1 = input.bool(true, "Q1", group=groupDivider, inline="quarters")
showQ2 = input.bool(true, "Q2", group=groupDivider, inline="quarters")
showQ3 = input.bool(true, "Q3", group=groupDivider, inline="quarters")
showQ4 = input.bool(true, "Q4", group=groupDivider, inline="quarters")

dividerColor = input.color(color.gray, "Divider Colour", group=groupDivider)

dividerWidth = input.int(
     1,
     "Divider Thickness",
     minval=1,
     maxval=5,
     group=groupDivider)

dividerStyleInput = input.string(
     "Dashed",
     "Divider Style",
     options=["Solid", "Dashed", "Dotted"],
     group=groupDivider)

dividerStyle = dividerStyleInput == "Dashed" ? line.style_dashed :
     dividerStyleInput == "Dotted" ? line.style_dotted :
     line.style_solid

historicalQuarters = input.int(
     20,
     "Historical Quarters",
     minval=1,
     maxval=100,
     group=groupDivider)

showQuarterLabels = input.bool(true, "Show Quarter Labels", group=groupDivider)
showYearLabels = input.bool(true, "Show Year Labels", group=groupDivider)

labelPosition = input.string(
     "Top",
     "Label Position",
     options=["Top", "Middle", "Bottom"],
     group=groupDivider)

var line[] quarterLines = array.new_line()
var label[] quarterLabels = array.new_label()

// First available chart bar of a new quarter
newQuarter = timeframe.change("3M")

if newQuarter and showQuarterDividers
    quarter = month(time) == 1 ? 1 :
         month(time) == 4 ? 2 :
         month(time) == 7 ? 3 : 4

    showThisQuarter = quarter == 1 ? showQ1 :
         quarter == 2 ? showQ2 :
         quarter == 3 ? showQ3 :
         showQ4

    if showThisQuarter
        newDivider = line.new(
             x1=bar_index,
             y1=low,
             x2=bar_index,
             y2=high,
             xloc=xloc.bar_index,
             extend=extend.both,
             color=dividerColor,
             width=dividerWidth,
             style=dividerStyle)

        array.push(quarterLines, newDivider)

        if showQuarterLabels or showYearLabels
            quarterText = "Q" + str.tostring(quarter)
            yearText = str.tostring(year(time))

            labelText = showQuarterLabels and showYearLabels ? quarterText + " " + yearText :
                 showQuarterLabels ? quarterText :
                 yearText

            labelY = labelPosition == "Top" ? high :
                 labelPosition == "Bottom" ? low :
                 (high + low) / 2

            newLabel = label.new(
                 x=bar_index,
                 y=labelY,
                 text=labelText,
                 xloc=xloc.bar_index,
                 style=label.style_none,
                 textcolor=dividerColor,
                 size=size.small)

            array.push(quarterLabels, newLabel)

        while array.size(quarterLines) > historicalQuarters
            oldLine = array.shift(quarterLines)
            line.delete(oldLine)

        while array.size(quarterLabels) > historicalQuarters
            oldLabel = array.shift(quarterLabels)
            label.delete(oldLabel)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 20 DAY RANGE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

group20 = "20 Day Range"

high20Color = input.color(color.red, "High Line Colour", group=group20)
low20Color = input.color(color.red, "Low Line Colour", group=group20)

high20LabelColor = input.color(color.red, "High Label Colour", group=group20)
low20LabelColor = input.color(color.red, "Low Label Colour", group=group20)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 40 DAY RANGE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

group40 = "40 Day Range"

high40Color = input.color(color.orange, "High Line Colour", group=group40)
low40Color = input.color(color.orange, "Low Line Colour", group=group40)

high40LabelColor = input.color(color.orange, "High Label Colour", group=group40)
low40LabelColor = input.color(color.orange, "Low Label Colour", group=group40)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 60 DAY RANGE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

group60 = "60 Day Range"

high60Color = input.color(color.yellow, "High Line Colour", group=group60)
low60Color = input.color(color.yellow, "Low Line Colour", group=group60)

high60LabelColor = input.color(color.yellow, "High Label Colour", group=group60)
low60LabelColor = input.color(color.yellow, "Low Label Colour", group=group60)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// IPDA LINE SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupStyle = "IPDA Line Settings"

lineWidth = input.int(
     2,
     "Line Thickness",
     minval=1,
     maxval=5,
     group=groupStyle)

lineStyleInput = input.string(
     "Solid",
     "Line Style",
     options=["Solid", "Dashed", "Dotted"],
     group=groupStyle)

lineStyle = lineStyleInput == "Dashed" ? line.style_dashed :
     lineStyleInput == "Dotted" ? line.style_dotted :
     line.style_solid


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FIND HIGHEST SWING HIGH / LOWEST SWING LOW
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

getSwingRange(periods) =>
    pivotHigh = ta.pivothigh(high, 1, 1)
    pivotLow = ta.pivotlow(low, 1, 1)

    float bestHigh = na
    float bestLow = na

    int bestHighTime = na
    int bestLowTime = na

    for i = 1 to periods - 1
        if not na(pivotHigh[i])
            pivotTime = time[i + 1]

            if na(bestHigh) or pivotHigh[i] > bestHigh
                bestHigh := pivotHigh[i]
                bestHighTime := pivotTime

        if not na(pivotLow[i])
            pivotTime = time[i + 1]

            if na(bestLow) or pivotLow[i] < bestLow
                bestLow := pivotLow[i]
                bestLowTime := pivotTime

    [bestHigh, bestLow, bestHighTime, bestLowTime]


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DAILY SWING DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[h20, l20, ht20, lt20] = request.security(
     syminfo.tickerid,
     "D",
     getSwingRange(20),
     lookahead=barmerge.lookahead_off)

[h40, l40, ht40, lt40] = request.security(
     syminfo.tickerid,
     "D",
     getSwingRange(40),
     lookahead=barmerge.lookahead_off)

[h60, l60, ht60, lt60] = request.security(
     syminfo.tickerid,
     "D",
     getSwingRange(60),
     lookahead=barmerge.lookahead_off)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STORED LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var float high20 = na
var float low20 = na
var int high20Time = na
var int low20Time = na

var float high40 = na
var float low40 = na
var int high40Time = na
var int low40Time = na

var float high60 = na
var float low60 = na
var int high60Time = na
var int low60Time = na


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LINE OBJECTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var line high20Line = na
var line low20Line = na

var line high40Line = na
var line low40Line = na

var line high60Line = na
var line low60Line = na


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LABEL OBJECTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var label high20Label = na
var label low20Label = na

var label high40Label = na
var label low40Label = na

var label high60Label = na
var label low60Label = na


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HIT STATUS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var bool high20Hit = false
var bool low20Hit = false

var bool high40Hit = false
var bool low40Hit = false

var bool high60Hit = false
var bool low60Hit = false


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NEW QUARTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if newQuarter

    // Delete previous quarter's objects

    if not na(high20Line)
        line.delete(high20Line)

    if not na(low20Line)
        line.delete(low20Line)

    if not na(high40Line)
        line.delete(high40Line)

    if not na(low40Line)
        line.delete(low40Line)

    if not na(high60Line)
        line.delete(high60Line)

    if not na(low60Line)
        line.delete(low60Line)


    if not na(high20Label)
        label.delete(high20Label)

    if not na(low20Label)
        label.delete(low20Label)

    if not na(high40Label)
        label.delete(high40Label)

    if not na(low40Label)
        label.delete(low40Label)

    if not na(high60Label)
        label.delete(high60Label)

    if not na(low60Label)
        label.delete(low60Label)


    // Reset objects

    high20Line := na
    low20Line := na

    high40Line := na
    low40Line := na

    high60Line := na
    low60Line := na


    high20Label := na
    low20Label := na

    high40Label := na
    low40Label := na

    high60Label := na
    low60Label := na


    // Reset hit status

    high20Hit := false
    low20Hit := false

    high40Hit := false
    low40Hit := false

    high60Hit := false
    low60Hit := false


    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // FREEZE NEW QUARTER'S LEVELS
    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    high20 := h20
    low20 := l20

    high20Time := ht20
    low20Time := lt20


    high40 := h40
    low40 := l40

    high40Time := ht40
    low40Time := lt40


    high60 := h60
    low60 := l60

    high60Time := ht60
    low60Time := lt60


    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // OVERLAP PRIORITY
    // 60D > 40D > 20D
    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    showHigh60 = not na(high60)

    showHigh40 =
         not na(high40) and
         (na(high60) or high40 != high60)

    showHigh20 =
         not na(high20) and
         (na(high60) or high20 != high60) and
         (na(high40) or high20 != high40)


    showLow60 = not na(low60)

    showLow40 =
         not na(low40) and
         (na(low60) or low40 != low60)

    showLow20 =
         not na(low20) and
         (na(low60) or low20 != low60) and
         (na(low40) or low20 != low40)


    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // CREATE 20D LINES
    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    if showHigh20 and not na(high20Time)
        high20Line := line.new(
             x1=high20Time,
             y1=high20,
             x2=time,
             y2=high20,
             xloc=xloc.bar_time,
             extend=extend.none,
             color=high20Color,
             width=lineWidth,
             style=lineStyle)

    if showLow20 and not na(low20Time)
        low20Line := line.new(
             x1=low20Time,
             y1=low20,
             x2=time,
             y2=low20,
             xloc=xloc.bar_time,
             extend=extend.none,
             color=low20Color,
             width=lineWidth,
             style=lineStyle)


    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // CREATE 40D LINES
    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    if showHigh40 and not na(high40Time)
        high40Line := line.new(
             x1=high40Time,
             y1=high40,
             x2=time,
             y2=high40,
             xloc=xloc.bar_time,
             extend=extend.none,
             color=high40Color,
             width=lineWidth,
             style=lineStyle)

    if showLow40 and not na(low40Time)
        low40Line := line.new(
             x1=low40Time,
             y1=low40,
             x2=time,
             y2=low40,
             xloc=xloc.bar_time,
             extend=extend.none,
             color=low40Color,
             width=lineWidth,
             style=lineStyle)


    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // CREATE 60D LINES
    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    if showHigh60 and not na(high60Time)
        high60Line := line.new(
             x1=high60Time,
             y1=high60,
             x2=time,
             y2=high60,
             xloc=xloc.bar_time,
             extend=extend.none,
             color=high60Color,
             width=lineWidth,
             style=lineStyle)

    if showLow60 and not na(low60Time)
        low60Line := line.new(
             x1=low60Time,
             y1=low60,
             x2=time,
             y2=low60,
             xloc=xloc.bar_time,
             extend=extend.none,
             color=low60Color,
             width=lineWidth,
             style=lineStyle)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EXTEND ACTIVE LINES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if not na(high20Line) and not high20Hit
    line.set_x2(high20Line, time)

if not na(low20Line) and not low20Hit
    line.set_x2(low20Line, time)

if not na(high40Line) and not high40Hit
    line.set_x2(high40Line, time)

if not na(low40Line) and not low40Hit
    line.set_x2(low40Line, time)

if not na(high60Line) and not high60Hit
    line.set_x2(high60Line, time)

if not na(low60Line) and not low60Hit
    line.set_x2(low60Line, time)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STOP LINE WHEN PRICE HITS LEVEL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if not na(high20Line) and not high20Hit and high >= high20
    line.set_x2(high20Line, time)
    high20Hit := true

if not na(low20Line) and not low20Hit and low <= low20
    line.set_x2(low20Line, time)
    low20Hit := true


if not na(high40Line) and not high40Hit and high >= high40
    line.set_x2(high40Line, time)
    high40Hit := true

if not na(low40Line) and not low40Hit and low <= low40
    line.set_x2(low40Line, time)
    low40Hit := true


if not na(high60Line) and not high60Hit and high >= high60
    line.set_x2(high60Line, time)
    high60Hit := true

if not na(low60Line) and not low60Hit and low <= low60
    line.set_x2(low60Line, time)
    low60Hit := true


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LABELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if not na(high20Line)
    if na(high20Label)
        high20Label := label.new(
             x=time,
             y=high20,
             text="20 Day High",
             xloc=xloc.bar_time,
             style=label.style_label_left,
             textcolor=high20LabelColor,
             color=color.new(color.white, 100))
    else
        label.set_x(high20Label, time)
        label.set_y(high20Label, high20)


if not na(low20Line)
    if na(low20Label)
        low20Label := label.new(
             x=time,
             y=low20,
             text="20 Day Low",
             xloc=xloc.bar_time,
             style=label.style_label_left,
             textcolor=low20LabelColor,
             color=color.new(color.white, 100))
    else
        label.set_x(low20Label, time)
        label.set_y(low20Label, low20)


if not na(high40Line)
    if na(high40Label)
        high40Label := label.new(
             x=time,
             y=high40,
             text="40 Day High",
             xloc=xloc.bar_time,
             style=label.style_label_left,
             textcolor=high40LabelColor,
             color=color.new(color.white, 100))
    else
        label.set_x(high40Label, time)
        label.set_y(high40Label, high40)


if not na(low40Line)
    if na(low40Label)
        low40Label := label.new(
             x=time,
             y=low40,
             text="40 Day Low",
             xloc=xloc.bar_time,
             style=label.style_label_left,
             textcolor=low40LabelColor,
             color=color.new(color.white, 100))
    else
        label.set_x(low40Label, time)
        label.set_y(low40Label, low40)


if not na(high60Line)
    if na(high60Label)
        high60Label := label.new(
             x=time,
             y=high60,
             text="60 Day High",
             xloc=xloc.bar_time,
             style=label.style_label_left,
             textcolor=high60LabelColor,
             color=color.new(color.white, 100))
    else
        label.set_x(high60Label, time)
        label.set_y(high60Label, high60)


if not na(low60Line)
    if na(low60Label)
        low60Label := label.new(
             x=time,
             y=low60,
             text="60 Day Low",
             xloc=xloc.bar_time,
             style=label.style_label_left,
             textcolor=low60LabelColor,
             color=color.new(color.white, 100))
    else
        label.set_x(low60Label, time)
        label.set_y(low60Label, low60)
````
