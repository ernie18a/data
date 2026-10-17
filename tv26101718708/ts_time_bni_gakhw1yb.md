# TS Time - BNI

- url: https://www.tradingview.com/script/gakHW1Yb-TS-Time-BNI/
- type: indicator
- pine_id: PUB;ad567a1d9e8d4021954baa63d840d429
- version: 1.0

## Description

Custom TradingView indicator that plots up to 12 customizable vertical time markers on the chart. Each marker can be enabled or disabled individually and includes adjustable time, timezone, line color, line style, line width, label visibility, label position, label color, and label size.

The script currently supports both Los Angeles and New York timezones only, draws future time markers, and automatically labels each marker using its assigned time. Labels can be positioned at the top, middle, or bottom of the visible chart area for cleaner readability while reviewing market sessions and key trading windows.

Note: If requested, I can add more timezones.

## Source Code

````pine
//@version=6
indicator("TS Time - BNI", overlay=true, max_lines_count=500, max_labels_count=500)

// =========================
// Inputs
// =========================
timezoneChoice = input.string("America/Los_Angeles", "Timezone", options=["America/Los_Angeles", "America/New_York"])
futureDays     = input.int(3, "Show Future Days", minval=0, maxval=10)
maxStoredLines = input.int(180, "Max Stored Historical Lines", minval=50, maxval=300)

// =========================
// Helpers
// =========================
f_convertTo24(_hour12, _ampm) =>
    _ampm == "AM" ? (_hour12 == 12 ? 0 : _hour12) : (_hour12 == 12 ? 12 : _hour12 + 12)

f_getStyle(_styleStr) =>
    _styleStr == "Solid" ? line.style_solid : _styleStr == "Dashed" ? line.style_dashed : line.style_dotted

f_getTextSize(_sizeStr) =>
    _sizeStr == "Tiny"  ? size.tiny  :
     _sizeStr == "Small" ? size.small :
     _sizeStr == "Large" ? size.large :
     _sizeStr == "Huge"  ? size.huge  :
     size.normal

f_trimLines(_arr, _maxCount) =>
    while array.size(_arr) > _maxCount
        oldLine = array.shift(_arr)
        line.delete(oldLine)

f_trimLabels(_arr, _maxCount) =>
    while array.size(_arr) > _maxCount
        oldLabel = array.shift(_arr)
        label.delete(oldLabel)

f_formatTimeLabel(_hour12, _minute, _ampm) =>
    str.tostring(_hour12) + ":" + str.tostring(_minute, "00") + _ampm

// =========================
// Visible chart range — track top of visible price area
// =========================
isVisible = time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time

var float visibleHigh = na
var float visibleLow  = na

if time == chart.left_visible_bar_time
    visibleHigh := high
    visibleLow  := low
else if isVisible
    visibleHigh := math.max(nz(visibleHigh, high), high)
    visibleLow  := math.min(nz(visibleLow,  low),  low)

chartTopY = nz(visibleHigh, high)
chartBotY = nz(visibleLow,  low)
chartRange = chartTopY - chartBotY

// Label Y = just below the very top of visible range (5% down from top)
labelY = chartTopY - chartRange * 0.05

// =========================
// Draw one vertical line at the matching bar
// =========================
f_drawHistoricalLine(_lineArr, _labelArr, _enabled, _hour12, _minute, _ampm, _lineColor, _style, _width, _showText, _textColor, _textSize, _tz, _maxCount, _labelY) =>
    h24      = f_convertTo24(_hour12, _ampm)
    isTarget = _enabled and hour(time, _tz) == h24 and minute(time, _tz) == _minute
    if isTarget
        newLine = line.new(
             x1 = time, y1 = close - 1,
             x2 = time, y2 = close + 1,
             xloc = xloc.bar_time, extend = extend.both,
             color = _lineColor, style = f_getStyle(_style), width = _width)
        array.push(_lineArr, newLine)
        f_trimLines(_lineArr, _maxCount)

        if _showText
            lbl = f_formatTimeLabel(_hour12, _minute, _ampm)
            newLabel = label.new(
                 x         = time,
                 y         = _labelY,
                 xloc      = xloc.bar_time,
                 yloc      = yloc.price,
                 text      = lbl,
                 style     = label.style_none,
                 textcolor = _textColor,
                 size      = f_getTextSize(_textSize))
            array.push(_labelArr, newLabel)
            f_trimLabels(_labelArr, _maxCount)

f_addFutureLines(_lineArr, _labelArr, _enabled, _hour12, _minute, _ampm, _lineColor, _style, _width, _showText, _textColor, _textSize, _tz, _futureDays, _baseYear, _baseMonth, _baseDay, _currentTime, _labelY) =>
    if _enabled
        h24 = f_convertTo24(_hour12, _ampm)
        for d = 0 to _futureDays
            ts = timestamp(_tz, _baseYear, _baseMonth, _baseDay + d, h24, _minute)
            if ts > _currentTime
                newLine = line.new(
                     x1 = ts, y1 = close - 1,
                     x2 = ts, y2 = close + 1,
                     xloc = xloc.bar_time, extend = extend.both,
                     color = _lineColor, style = f_getStyle(_style), width = _width)
                array.push(_lineArr, newLine)

                if _showText
                    lbl = f_formatTimeLabel(_hour12, _minute, _ampm)
                    newLabel = label.new(
                         x         = ts,
                         y         = _labelY,
                         xloc      = xloc.bar_time,
                         yloc      = yloc.price,
                         text      = lbl,
                         style     = label.style_none,
                         textcolor = _textColor,
                         size      = f_getTextSize(_textSize))
                    array.push(_labelArr, newLabel)

// Update ALL label Ys to current visible top
f_refreshLabelYs(_arr, _labelY) =>
    sz = array.size(_arr)
    if sz > 0
        for i = 0 to sz - 1
            label.set_y(array.get(_arr, i), _labelY)

// =========================
// TS Time 1
// =========================
group1     = "TS Time 1"
enable1    = input.bool(true,   "Enable",     group=group1)
hour1      = input.int(12,      "Hour",       minval=1, maxval=12, group=group1)
minute1    = input.int(0,       "Minute",     minval=0, maxval=59, group=group1)
ampm1      = input.string("AM", "AM/PM",      options=["AM","PM"], group=group1)
color1     = input.color(color.new(color.gray, 75), "Line Color",  group=group1)
style1     = input.string("Dotted", "Line Style", options=["Solid","Dashed","Dotted"], group=group1)
width1     = input.int(1, "Line Width", minval=1, maxval=5, group=group1)
showText1  = input.bool(true,   "Show Label", group=group1)
textColor1 = input.color(color.gray, "Label Color", group=group1)
textSize1  = input.string("Small", "Label Size", options=["Tiny","Small","Normal","Large","Huge"], group=group1)

// =========================
// TS Time 2
// =========================
group2     = "TS Time 2"
enable2    = input.bool(true,   "Enable",     group=group2)
hour2      = input.int(3,       "Hour",       minval=1, maxval=12, group=group2)
minute2    = input.int(0,       "Minute",     minval=0, maxval=59, group=group2)
ampm2      = input.string("AM", "AM/PM",      options=["AM","PM"], group=group2)
color2     = input.color(color.new(color.gray, 75), "Line Color",  group=group2)
style2     = input.string("Dotted", "Line Style", options=["Solid","Dashed","Dotted"], group=group2)
width2     = input.int(1, "Line Width", minval=1, maxval=5, group=group2)
showText2  = input.bool(true,   "Show Label", group=group2)
textColor2 = input.color(color.gray, "Label Color", group=group2)
textSize2  = input.string("Small", "Label Size", options=["Tiny","Small","Normal","Large","Huge"], group=group2)

// =========================
// TS Time 3
// =========================
group3     = "TS Time 3"
enable3    = input.bool(true,   "Enable",     group=group3)
hour3      = input.int(3,       "Hour",       minval=1, maxval=12, group=group3)
minute3    = input.int(45,      "Minute",     minval=0, maxval=59, group=group3)
ampm3      = input.string("AM", "AM/PM",      options=["AM","PM"], group=group3)
color3     = input.color(color.new(color.gray, 75), "Line Color",  group=group3)
style3     = input.string("Dotted", "Line Style", options=["Solid","Dashed","Dotted"], group=group3)
width3     = input.int(1, "Line Width", minval=1, maxval=5, group=group3)
showText3  = input.bool(true,   "Show Label", group=group3)
textColor3 = input.color(color.gray, "Label Color", group=group3)
textSize3  = input.string("Small", "Label Size", options=["Tiny","Small","Normal","Large","Huge"], group=group3)

// =========================
// TS Time 4
// =========================
group4     = "TS Time 4"
enable4    = input.bool(true,   "Enable",     group=group4)
hour4      = input.int(4,       "Hour",       minval=1, maxval=12, group=group4)
minute4    = input.int(15,      "Minute",     minval=0, maxval=59, group=group4)
ampm4      = input.string("AM", "AM/PM",      options=["AM","PM"], group=group4)
color4     = input.color(color.new(color.gray, 75), "Line Color",  group=group4)
style4     = input.string("Dotted", "Line Style", options=["Solid","Dashed","Dotted"], group=group4)
width4     = input.int(1, "Line Width", minval=1, maxval=5, group=group4)
showText4  = input.bool(true,   "Show Label", group=group4)
textColor4 = input.color(color.gray, "Label Color", group=group4)
textSize4  = input.string("Small", "Label Size", options=["Tiny","Small","Normal","Large","Huge"], group=group4)

// =========================
// TS Time 5
// =========================
group5     = "TS Time 5"
enable5    = input.bool(true,   "Enable",     group=group5)
hour5      = input.int(6,       "Hour",       minval=1, maxval=12, group=group5)
minute5    = input.int(0,       "Minute",     minval=0, maxval=59, group=group5)
ampm5      = input.string("AM", "AM/PM",      options=["AM","PM"], group=group5)
color5     = input.color(color.new(color.gray, 75), "Line Color",  group=group5)
style5     = input.string("Dotted", "Line Style", options=["Solid","Dashed","Dotted"], group=group5)
width5     = input.int(1, "Line Width", minval=1, maxval=5, group=group5)
showText5  = input.bool(true,   "Show Label", group=group5)
textColor5 = input.color(color.gray, "Label Color", group=group5)
textSize5  = input.string("Small", "Label Size", options=["Tiny","Small","Normal","Large","Huge"], group=group5)

// =========================
// TS Time 6
// =========================
group6     = "TS Time 6"
enable6    = input.bool(true,   "Enable",     group=group6)
hour6      = input.int(8,       "Hour",       minval=1, maxval=12, group=group6)
minute6    = input.int(15,      "Minute",     minval=0, maxval=59, group=group6)
ampm6      = input.string("AM", "AM/PM",      options=["AM","PM"], group=group6)
color6     = input.color(color.new(color.gray, 75), "Line Color",  group=group6)
style6     = input.string("Dotted", "Line Style", options=["Solid","Dashed","Dotted"], group=group6)
width6     = input.int(1, "Line Width", minval=1, maxval=5, group=group6)
showText6  = input.bool(true,   "Show Label", group=group6)
textColor6 = input.color(color.gray, "Label Color", group=group6)
textSize6  = input.string("Small", "Label Size", options=["Tiny","Small","Normal","Large","Huge"], group=group6)

// =========================
// TS Time 7
// =========================
group7     = "TS Time 7"
enable7    = input.bool(true,   "Enable",     group=group7)
hour7      = input.int(9,       "Hour",       minval=1, maxval=12, group=group7)
minute7    = input.int(0,       "Minute",     minval=0, maxval=59, group=group7)
ampm7      = input.string("AM", "AM/PM",      options=["AM","PM"], group=group7)
color7     = input.color(color.new(color.gray, 75), "Line Color",  group=group7)
style7     = input.string("Dotted", "Line Style", options=["Solid","Dashed","Dotted"], group=group7)
width7     = input.int(1, "Line Width", minval=1, maxval=5, group=group7)
showText7  = input.bool(true,   "Show Label", group=group7)
textColor7 = input.color(color.gray, "Label Color", group=group7)
textSize7  = input.string("Small", "Label Size", options=["Tiny","Small","Normal","Large","Huge"], group=group7)

// =========================
// TS Time 8
// =========================
group8     = "TS Time 8"
enable8    = input.bool(true,   "Enable",     group=group8)
hour8      = input.int(9,       "Hour",       minval=1, maxval=12, group=group8)
minute8    = input.int(30,      "Minute",     minval=0, maxval=59, group=group8)
ampm8      = input.string("AM", "AM/PM",      options=["AM","PM"], group=group8)
color8     = input.color(color.new(color.gray, 75), "Line Color",  group=group8)
style8     = input.string("Dotted", "Line Style", options=["Solid","Dashed","Dotted"], group=group8)
width8     = input.int(1, "Line Width", minval=1, maxval=5, group=group8)
showText8  = input.bool(true,   "Show Label", group=group8)
textColor8 = input.color(color.gray, "Label Color", group=group8)
textSize8  = input.string("Small", "Label Size", options=["Tiny","Small","Normal","Large","Huge"], group=group8)

// =========================
// TS Time 9
// =========================
group9     = "TS Time 9"
enable9    = input.bool(true,   "Enable",     group=group9)
hour9      = input.int(10,      "Hour",       minval=1, maxval=12, group=group9)
minute9    = input.int(45,      "Minute",     minval=0, maxval=59, group=group9)
ampm9      = input.string("AM", "AM/PM",      options=["AM","PM"], group=group9)
color9     = input.color(color.new(color.gray, 75), "Line Color",  group=group9)
style9     = input.string("Dotted", "Line Style", options=["Solid","Dashed","Dotted"], group=group9)
width9     = input.int(1, "Line Width", minval=1, maxval=5, group=group9)
showText9  = input.bool(true,   "Show Label", group=group9)
textColor9 = input.color(color.gray, "Label Color", group=group9)
textSize9  = input.string("Small", "Label Size", options=["Tiny","Small","Normal","Large","Huge"], group=group9)

// =========================
// TS Time 10
// =========================
group10     = "TS Time 10"
enable10    = input.bool(true,   "Enable",     group=group10)
hour10      = input.int(11,      "Hour",       minval=1, maxval=12, group=group10)
minute10    = input.int(15,      "Minute",     minval=0, maxval=59, group=group10)
ampm10      = input.string("AM", "AM/PM",      options=["AM","PM"], group=group10)
color10     = input.color(color.new(color.gray, 75), "Line Color",  group=group10)
style10     = input.string("Dotted", "Line Style", options=["Solid","Dashed","Dotted"], group=group10)
width10     = input.int(1, "Line Width", minval=1, maxval=5, group=group10)
showText10  = input.bool(true,   "Show Label", group=group10)
textColor10 = input.color(color.gray, "Label Color", group=group10)
textSize10  = input.string("Small", "Label Size", options=["Tiny","Small","Normal","Large","Huge"], group=group10)

// =========================
// TS Time 11
// =========================
group11     = "TS Time 11"
enable11    = input.bool(true,   "Enable",     group=group11)
hour11      = input.int(1,       "Hour",       minval=1, maxval=12, group=group11)
minute11    = input.int(0,       "Minute",     minval=0, maxval=59, group=group11)
ampm11      = input.string("PM", "AM/PM",      options=["AM","PM"], group=group11)
color11     = input.color(color.new(color.gray, 75), "Line Color",  group=group11)
style11     = input.string("Dotted", "Line Style", options=["Solid","Dashed","Dotted"], group=group11)
width11     = input.int(1, "Line Width", minval=1, maxval=5, group=group11)
showText11  = input.bool(true,   "Show Label", group=group11)
textColor11 = input.color(color.gray, "Label Color", group=group11)
textSize11  = input.string("Small", "Label Size", options=["Tiny","Small","Normal","Large","Huge"], group=group11)

// =========================
// TS Time 12
// =========================
group12     = "TS Time 12"
enable12    = input.bool(true,   "Enable",     group=group12)
hour12i     = input.int(1,       "Hour",       minval=1, maxval=12, group=group12)
minute12i   = input.int(30,      "Minute",     minval=0, maxval=59, group=group12)
ampm12      = input.string("PM", "AM/PM",      options=["AM","PM"], group=group12)
color12     = input.color(color.new(color.gray, 75), "Line Color",  group=group12)
style12     = input.string("Dotted", "Line Style", options=["Solid","Dashed","Dotted"], group=group12)
width12     = input.int(1, "Line Width", minval=1, maxval=5, group=group12)
showText12  = input.bool(true,   "Show Label", group=group12)
textColor12 = input.color(color.gray, "Label Color", group=group12)
textSize12  = input.string("Small", "Label Size", options=["Tiny","Small","Normal","Large","Huge"], group=group12)

// =========================
// Storage
// =========================
var historicalLines  = array.new_line()
var historicalLabels = array.new_label()
var futureLines      = array.new_line()
var futureLabels     = array.new_label()

// =========================
// Draw historical lines + labels every bar
// =========================
f_drawHistoricalLine(historicalLines, historicalLabels, enable1,  hour1,   minute1,   ampm1,  color1,  style1,  width1,  showText1,  textColor1,  textSize1,  timezoneChoice, maxStoredLines, labelY)
f_drawHistoricalLine(historicalLines, historicalLabels, enable2,  hour2,   minute2,   ampm2,  color2,  style2,  width2,  showText2,  textColor2,  textSize2,  timezoneChoice, maxStoredLines, labelY)
f_drawHistoricalLine(historicalLines, historicalLabels, enable3,  hour3,   minute3,   ampm3,  color3,  style3,  width3,  showText3,  textColor3,  textSize3,  timezoneChoice, maxStoredLines, labelY)
f_drawHistoricalLine(historicalLines, historicalLabels, enable4,  hour4,   minute4,   ampm4,  color4,  style4,  width4,  showText4,  textColor4,  textSize4,  timezoneChoice, maxStoredLines, labelY)
f_drawHistoricalLine(historicalLines, historicalLabels, enable5,  hour5,   minute5,   ampm5,  color5,  style5,  width5,  showText5,  textColor5,  textSize5,  timezoneChoice, maxStoredLines, labelY)
f_drawHistoricalLine(historicalLines, historicalLabels, enable6,  hour6,   minute6,   ampm6,  color6,  style6,  width6,  showText6,  textColor6,  textSize6,  timezoneChoice, maxStoredLines, labelY)
f_drawHistoricalLine(historicalLines, historicalLabels, enable7,  hour7,   minute7,   ampm7,  color7,  style7,  width7,  showText7,  textColor7,  textSize7,  timezoneChoice, maxStoredLines, labelY)
f_drawHistoricalLine(historicalLines, historicalLabels, enable8,  hour8,   minute8,   ampm8,  color8,  style8,  width8,  showText8,  textColor8,  textSize8,  timezoneChoice, maxStoredLines, labelY)
f_drawHistoricalLine(historicalLines, historicalLabels, enable9,  hour9,   minute9,   ampm9,  color9,  style9,  width9,  showText9,  textColor9,  textSize9,  timezoneChoice, maxStoredLines, labelY)
f_drawHistoricalLine(historicalLines, historicalLabels, enable10, hour10,  minute10,  ampm10, color10, style10, width10, showText10, textColor10, textSize10, timezoneChoice, maxStoredLines, labelY)
f_drawHistoricalLine(historicalLines, historicalLabels, enable11, hour11,  minute11,  ampm11, color11, style11, width11, showText11, textColor11, textSize11, timezoneChoice, maxStoredLines, labelY)
f_drawHistoricalLine(historicalLines, historicalLabels, enable12, hour12i, minute12i, ampm12, color12, style12, width12, showText12, textColor12, textSize12, timezoneChoice, maxStoredLines, labelY)

// =========================
// On last bar: refresh all label Ys + rebuild future lines/labels
// =========================
if barstate.islast
    // Refresh Y on all historical labels to current visible top
    f_refreshLabelYs(historicalLabels, labelY)

    // Rebuild future lines & labels
    if array.size(futureLines) > 0
        for i = 0 to array.size(futureLines) - 1
            line.delete(array.get(futureLines, i))
    array.clear(futureLines)

    if array.size(futureLabels) > 0
        for i = 0 to array.size(futureLabels) - 1
            label.delete(array.get(futureLabels, i))
    array.clear(futureLabels)

    baseYear  = year(time,       timezoneChoice)
    baseMonth = month(time,      timezoneChoice)
    baseDay   = dayofmonth(time, timezoneChoice)

    f_addFutureLines(futureLines, futureLabels, enable1,  hour1,   minute1,   ampm1,  color1,  style1,  width1,  showText1,  textColor1,  textSize1,  timezoneChoice, futureDays, baseYear, baseMonth, baseDay, time, labelY)
    f_addFutureLines(futureLines, futureLabels, enable2,  hour2,   minute2,   ampm2,  color2,  style2,  width2,  showText2,  textColor2,  textSize2,  timezoneChoice, futureDays, baseYear, baseMonth, baseDay, time, labelY)
    f_addFutureLines(futureLines, futureLabels, enable3,  hour3,   minute3,   ampm3,  color3,  style3,  width3,  showText3,  textColor3,  textSize3,  timezoneChoice, futureDays, baseYear, baseMonth, baseDay, time, labelY)
    f_addFutureLines(futureLines, futureLabels, enable4,  hour4,   minute4,   ampm4,  color4,  style4,  width4,  showText4,  textColor4,  textSize4,  timezoneChoice, futureDays, baseYear, baseMonth, baseDay, time, labelY)
    f_addFutureLines(futureLines, futureLabels, enable5,  hour5,   minute5,   ampm5,  color5,  style5,  width5,  showText5,  textColor5,  textSize5,  timezoneChoice, futureDays, baseYear, baseMonth, baseDay, time, labelY)
    f_addFutureLines(futureLines, futureLabels, enable6,  hour6,   minute6,   ampm6,  color6,  style6,  width6,  showText6,  textColor6,  textSize6,  timezoneChoice, futureDays, baseYear, baseMonth, baseDay, time, labelY)
    f_addFutureLines(futureLines, futureLabels, enable7,  hour7,   minute7,   ampm7,  color7,  style7,  width7,  showText7,  textColor7,  textSize7,  timezoneChoice, futureDays, baseYear, baseMonth, baseDay, time, labelY)
    f_addFutureLines(futureLines, futureLabels, enable8,  hour8,   minute8,   ampm8,  color8,  style8,  width8,  showText8,  textColor8,  textSize8,  timezoneChoice, futureDays, baseYear, baseMonth, baseDay, time, labelY)
    f_addFutureLines(futureLines, futureLabels, enable9,  hour9,   minute9,   ampm9,  color9,  style9,  width9,  showText9,  textColor9,  textSize9,  timezoneChoice, futureDays, baseYear, baseMonth, baseDay, time, labelY)
    f_addFutureLines(futureLines, futureLabels, enable10, hour10,  minute10,  ampm10, color10, style10, width10, showText10, textColor10, textSize10, timezoneChoice, futureDays, baseYear, baseMonth, baseDay, time, labelY)
    f_addFutureLines(futureLines, futureLabels, enable11, hour11,  minute11,  ampm11, color11, style11, width11, showText11, textColor11, textSize11, timezoneChoice, futureDays, baseYear, baseMonth, baseDay, time, labelY)
    f_addFutureLines(futureLines, futureLabels, enable12, hour12i, minute12i, ampm12, color12, style12, width12, showText12, textColor12, textSize12, timezoneChoice, futureDays, baseYear, baseMonth, baseDay, time, labelY)

    // Also refresh future label Ys
    f_refreshLabelYs(futureLabels, labelY)
````
