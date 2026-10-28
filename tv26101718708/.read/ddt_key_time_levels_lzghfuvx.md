# DDT Key Time Levels

- url: https://www.tradingview.com/script/LZghfUvx-DDT-Key-Time-Levels/
- type: indicator
- pine_id: PUB;e280a3daa54449979559cfeda43928f1
- version: 1.0

## Description

DDT Key Time Levels

A clean and minimalistic level indicator built around the levels I personally use every day for liquidity, market structure, and trade planning.

The goal of this indicator is simple: provide the most important time-based highs, lows, and opens without cluttering the chart.

Included Levels:

▪️ Current Daily High (DH)
▪️ Current Daily Low (DL)

▪️ Previous Daily High (PDH)
▪️ Previous Daily Low (PDL)

▪️ Current Weekly High (WH)
▪️ Current Weekly Low (WL)

▪️ Monday High (MON-H)
▪️ Monday Low (MON-L)

▪️ Monthly Open (MO)
▪️ Monthly High (MH)
▪️ Monthly Low (ML)

Features:

▪️ Clean dotted levels starting from the moment they are established.
▪️ Minimalistic design focused on chart readability.
▪️ Optional visibility controls for each level group.
▪️ Adjustable line width and extension length.
▪️ Labels can be positioned on the left or right side of the chart.
▪️ Automatic level merging when multiple levels exist at the same price.

Why I Built This

Many level indicators cover the entire chart with unnecessary information, labels, boxes, and visual noise.

This indicator was designed around the philosophy of The Structured Process:

Less noise. More information.

The focus is on identifying important liquidity levels, understanding where market participants are likely positioned, and improving overall trade planning without distracting from price action itself.

How I Use It

▪️ PDH and PDL for daily liquidity targets.
▪️ WH and WL for higher timeframe context.
▪️ MON-H and MON-L for weekly liquidity references.
▪️ MO as a key monthly bias level.
▪️ MH and ML for major higher timeframe objectives.

Combined with market structure, supply & demand, liquidity concepts, and statistical context, these levels become powerful reference points for building objective trade scenarios.

Part of the DDTRADING toolkit and The Structured Process framework.

Process over outcome.

## Source Code

````pine
//@version=6
indicator("DDT Key Time Levels", shorttitle="DDT Levels", overlay=true, max_lines_count=100, max_labels_count=100)

// Settings
showCurrentDaily  = input.bool(true, "Current Daily High / Low", group="Levels")
showPreviousDaily = input.bool(true, "Previous Daily High / Low", group="Levels")
showWeekly        = input.bool(true, "Current Weekly High / Low", group="Levels")
showMonday        = input.bool(true, "Monday High / Low", group="Levels")
showMonthly       = input.bool(true, "Monthly Open / High / Low", group="Levels")

lineExtendBars    = input.int(150, "Extend Lines Right", minval=10, maxval=500, group="Style")
lineWidth         = input.int(1, "Line Width", minval=1, maxval=3, group="Style")
levelColor        = input.color(color.black, "Level Color", group="Style")
labelPosition     = input.string("Right", "Label Position", options=["Left", "Right"], group="Style")
labelOffset       = input.int(2, "Label Offset", minval=0, maxval=50, group="Style")

// Helpers
f_updateLine(line ln, bool show, int x1, float y) =>
    line result = ln

    if not show or na(x1) or na(y)
        if not na(result)
            line.delete(result)
        result := na
    else
        if na(result)
            result := line.new(
                 x1=x1,
                 y1=y,
                 x2=bar_index + lineExtendBars,
                 y2=y,
                 xloc=xloc.bar_index,
                 extend=extend.none,
                 color=levelColor,
                 style=line.style_dotted,
                 width=lineWidth
             )
        else
            line.set_x1(result, x1)
            line.set_y1(result, y)
            line.set_x2(result, bar_index + lineExtendBars)
            line.set_y2(result, y)
            line.set_color(result, levelColor)
            line.set_style(result, line.style_dotted)
            line.set_width(result, lineWidth)

    result

f_addLabelData(float[] ys, string[] texts, int[] xs, float y, string txt, int x1) =>
    if not na(y) and not na(x1)
        bool merged = false
        float tolerance = syminfo.mintick * 2.0
        int arrSize = array.size(ys)

        if arrSize > 0
            for i = 0 to arrSize - 1
                if math.abs(array.get(ys, i) - y) <= tolerance
                    array.set(texts, i, array.get(texts, i) + " / " + txt)
                    array.set(xs, i, math.min(array.get(xs, i), x1))
                    merged := true

        if not merged
            array.push(ys, y)
            array.push(texts, txt)
            array.push(xs, x1)

// Time changes
newDay   = ta.change(time("D")) != 0
newWeek  = ta.change(time("W")) != 0
newMonth = ta.change(time("M")) != 0

// Daily tracking
var float dailyHigh = na
var float dailyLow  = na
var int dailyHighBar = na
var int dailyLowBar  = na

var float prevDailyHigh = na
var float prevDailyLow  = na
var int prevDailyStartBar = na

if na(dailyHigh)
    dailyHigh := high
    dailyLow := low
    dailyHighBar := bar_index
    dailyLowBar := bar_index

if newDay
    prevDailyHigh := dailyHigh
    prevDailyLow := dailyLow
    prevDailyStartBar := bar_index

    dailyHigh := high
    dailyLow := low
    dailyHighBar := bar_index
    dailyLowBar := bar_index

if high > dailyHigh
    dailyHigh := high
    dailyHighBar := bar_index

if low < dailyLow
    dailyLow := low
    dailyLowBar := bar_index

// Weekly tracking
var float weeklyHigh = na
var float weeklyLow  = na
var int weeklyHighBar = na
var int weeklyLowBar  = na

if na(weeklyHigh) or newWeek
    weeklyHigh := high
    weeklyLow := low
    weeklyHighBar := bar_index
    weeklyLowBar := bar_index

if high > weeklyHigh
    weeklyHigh := high
    weeklyHighBar := bar_index

if low < weeklyLow
    weeklyLow := low
    weeklyLowBar := bar_index

// Monday tracking
isMonday = dayofweek(time) == dayofweek.monday

var float mondayHigh = na
var float mondayLow  = na
var int mondayHighBar = na
var int mondayLowBar  = na

if newWeek
    mondayHigh := na
    mondayLow := na
    mondayHighBar := na
    mondayLowBar := na

if isMonday
    if na(mondayHigh) or high > mondayHigh
        mondayHigh := high
        mondayHighBar := bar_index

    if na(mondayLow) or low < mondayLow
        mondayLow := low
        mondayLowBar := bar_index

// Monthly tracking
var float monthlyOpen = na
var float monthlyHigh = na
var float monthlyLow  = na
var int monthlyOpenBar = na
var int monthlyHighBar = na
var int monthlyLowBar  = na

if na(monthlyOpen) or newMonth
    monthlyOpen := open
    monthlyHigh := high
    monthlyLow := low
    monthlyOpenBar := bar_index
    monthlyHighBar := bar_index
    monthlyLowBar := bar_index

if high > monthlyHigh
    monthlyHigh := high
    monthlyHighBar := bar_index

if low < monthlyLow
    monthlyLow := low
    monthlyLowBar := bar_index

// Lines
var line dhLine = na
var line dlLine = na
var line pdhLine = na
var line pdlLine = na
var line whLine = na
var line wlLine = na
var line monhLine = na
var line monlLine = na
var line moLine = na
var line mhLine = na
var line mlLine = na

dhLine := f_updateLine(dhLine, showCurrentDaily, dailyHighBar, dailyHigh)
dlLine := f_updateLine(dlLine, showCurrentDaily, dailyLowBar, dailyLow)

pdhLine := f_updateLine(pdhLine, showPreviousDaily, prevDailyStartBar, prevDailyHigh)
pdlLine := f_updateLine(pdlLine, showPreviousDaily, prevDailyStartBar, prevDailyLow)

whLine := f_updateLine(whLine, showWeekly, weeklyHighBar, weeklyHigh)
wlLine := f_updateLine(wlLine, showWeekly, weeklyLowBar, weeklyLow)

monhLine := f_updateLine(monhLine, showMonday, mondayHighBar, mondayHigh)
monlLine := f_updateLine(monlLine, showMonday, mondayLowBar, mondayLow)

moLine := f_updateLine(moLine, showMonthly, monthlyOpenBar, monthlyOpen)
mhLine := f_updateLine(mhLine, showMonthly, monthlyHighBar, monthlyHigh)
mlLine := f_updateLine(mlLine, showMonthly, monthlyLowBar, monthlyLow)

// Labels
var label[] activeLabels = array.new<label>()
var float[] labelYs = array.new<float>()
var string[] labelTexts = array.new<string>()
var int[] labelXs = array.new<int>()

if barstate.islast
    int activeSize = array.size(activeLabels)

    if activeSize > 0
        for i = 0 to activeSize - 1
            label.delete(array.get(activeLabels, i))

    array.clear(activeLabels)
    array.clear(labelYs)
    array.clear(labelTexts)
    array.clear(labelXs)

    if showCurrentDaily
        f_addLabelData(labelYs, labelTexts, labelXs, dailyHigh, "DH", dailyHighBar)
        f_addLabelData(labelYs, labelTexts, labelXs, dailyLow, "DL", dailyLowBar)

    if showPreviousDaily
        f_addLabelData(labelYs, labelTexts, labelXs, prevDailyHigh, "PDH", prevDailyStartBar)
        f_addLabelData(labelYs, labelTexts, labelXs, prevDailyLow, "PDL", prevDailyStartBar)

    if showWeekly
        f_addLabelData(labelYs, labelTexts, labelXs, weeklyHigh, "WH", weeklyHighBar)
        f_addLabelData(labelYs, labelTexts, labelXs, weeklyLow, "WL", weeklyLowBar)

    if showMonday
        f_addLabelData(labelYs, labelTexts, labelXs, mondayHigh, "MON-H", mondayHighBar)
        f_addLabelData(labelYs, labelTexts, labelXs, mondayLow, "MON-L", mondayLowBar)

    if showMonthly
        f_addLabelData(labelYs, labelTexts, labelXs, monthlyOpen, "MO", monthlyOpenBar)
        f_addLabelData(labelYs, labelTexts, labelXs, monthlyHigh, "MH", monthlyHighBar)
        f_addLabelData(labelYs, labelTexts, labelXs, monthlyLow, "ML", monthlyLowBar)

    int labelCount = array.size(labelYs)

    if labelCount > 0
        for i = 0 to labelCount - 1
            float y = array.get(labelYs, i)
            string txt = array.get(labelTexts, i)
            int startX = array.get(labelXs, i)

            int labelX = labelPosition == "Right" ? bar_index + lineExtendBars + labelOffset : startX - labelOffset

            label lb = label.new(
                 x=labelX,
                 y=y,
                 text=txt,
                 xloc=xloc.bar_index,
                 style=label.style_none,
                 textcolor=levelColor,
                 color=color.new(color.white, 100),
                 size=size.tiny
             )

            array.push(activeLabels, lb)
````
