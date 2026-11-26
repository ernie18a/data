# ICT Opening Range Gap by Laofengtrading

- url: https://www.tradingview.com/script/cCrbn8ui-ICT-Opening-Range-Gap-by-Laofengtrading/
- type: indicator
- pine_id: PUB;a32b1ac8a3f8497286ce8dcd0025db6f
- version: 1.0

## Description

This indicator marks the Opening Range Gap (ORG) based on New York time.

The ORG is calculated from the previous day 16:14 close to the current day 09:30 open. Once the New York 09:30 open occurs, the indicator draws the gap area and three key levels:

ORG High:
The higher price between the previous 16:14 close and the 09:30 open.

ORG Low:
The lower price between the previous 16:14 close and the 09:30 open.

ORG C.E:
The 50% level of the gap, also known as Consequent Encroachment.

Features:

- Uses fixed New York time
- Displays only after the 09:30 open
- Shows only the current day’s ORG
- Automatically hides all ORG levels before 09:30
- Draws the ORG area as a background box
- Marks ORG High, ORG Low, and ORG C.E
- Customizable colors, line widths, and labels
- Uses 1-minute data internally for accurate 16:14 close and 09:30 open detection

This tool is designed for traders who use ICT concepts and opening range gap levels as part of their intraday analysis.

## Source Code

````pine
//@version=6
indicator("ICT Opening Range Gap by Laofengtrading", overlay=true, max_boxes_count=50, max_lines_count=50, max_labels_count=50)

// === Inputs ===
showGapBox = input.bool(true, "Show Gap Area")
gapBoxColor = input.color(color.new(color.orange, 82), "Gap Area Color")

showHighLine = input.bool(true, "Show ORG High")
highLineColor = input.color(color.red, "ORG High Line Color")
highLineWidth = input.int(1, "ORG High Line Width", minval=1, maxval=5)

showLowLine = input.bool(true, "Show ORG Low")
lowLineColor = input.color(color.green, "ORG Low Line Color")
lowLineWidth = input.int(1, "ORG Low Line Width", minval=1, maxval=5)

showCELine = input.bool(true, "Show ORG C.E")
ceLineColor = input.color(color.gray, "ORG C.E Line Color")
ceLineWidth = input.int(1, "ORG C.E Line Width", minval=1, maxval=5)

showLabels = input.bool(true, "Show Labels")
labelTextColor = input.color(color.black, "Label Text Color")
labelBgColor = input.color(color.new(color.white, 100), "Label Background Color")
labelOffset = input.int(1, "Label Offset After Line", minval=0, maxval=50)

timezone = "America/New_York"

// === 1 Minute Engine ===
f_gapEngine() =>
    h = hour(time, timezone)
    m = minute(time, timezone)

    isClose1614 = h == 16 and m == 14
    isOpen0930 = h == 9 and m == 30

    var float lastClose1614 = na

    var int gapId = 0
    var float highLevel = na
    var float lowLevel = na
    var float ceLevel = na
    var int gapTime = na
    var int gapDate = na

    if isClose1614
        lastClose1614 := close

    if isOpen0930 and not na(lastClose1614)
        highLevel := math.max(lastClose1614, open)
        lowLevel := math.min(lastClose1614, open)
        ceLevel := (highLevel + lowLevel) / 2

        gapId += 1
        gapTime := time
        gapDate := year(time, timezone) * 10000 + month(time, timezone) * 100 + dayofmonth(time, timezone)

    [gapId, highLevel, lowLevel, ceLevel, gapTime, gapDate]

[gapId, highLevel, lowLevel, ceLevel, gapTime, gapDate] =
     request.security(syminfo.tickerid, "1", f_gapEngine(), barmerge.gaps_off, barmerge.lookahead_off)

// === Current NY Date / Time ===
currentDate = year(time, timezone) * 10000 + month(time, timezone) * 100 + dayofmonth(time, timezone)
currentHour = hour(time, timezone)
currentMinute = minute(time, timezone)
after0930 = currentHour > 9 or (currentHour == 9 and currentMinute >= 30)

// === Drawing Variables ===
var box gapBox = na

var line highLine = na
var line lowLine = na
var line ceLine = na

var label highLabel = na
var label lowLabel = na
var label ceLabel = na

var int lastDrawnGapId = na
var int activeGapDate = na

newTodayGap = gapId > 0 and (na(lastDrawnGapId) or gapId != lastDrawnGapId) and gapDate == currentDate and after0930 and not na(highLevel) and not na(lowLevel) and not na(ceLevel) and not na(gapTime)

// === Clear Everything Before 09:30 Or When Date Changes ===
if not after0930 or (not na(activeGapDate) and activeGapDate != currentDate)
    if not na(gapBox)
        box.delete(gapBox)
        gapBox := na

    if not na(highLine)
        line.delete(highLine)
        highLine := na
    if not na(lowLine)
        line.delete(lowLine)
        lowLine := na
    if not na(ceLine)
        line.delete(ceLine)
        ceLine := na

    if not na(highLabel)
        label.delete(highLabel)
        highLabel := na
    if not na(lowLabel)
        label.delete(lowLabel)
        lowLabel := na
    if not na(ceLabel)
        label.delete(ceLabel)
        ceLabel := na

    activeGapDate := na

// === Draw Today's Gap At 09:30 ===
if newTodayGap
    lastDrawnGapId := gapId
    activeGapDate := gapDate

    if not na(gapBox)
        box.delete(gapBox)
    if not na(highLine)
        line.delete(highLine)
    if not na(lowLine)
        line.delete(lowLine)
    if not na(ceLine)
        line.delete(ceLine)
    if not na(highLabel)
        label.delete(highLabel)
    if not na(lowLabel)
        label.delete(lowLabel)
    if not na(ceLabel)
        label.delete(ceLabel)

    dateText = str.tostring(gapDate)

    if showGapBox
        gapBox := box.new(
             left=gapTime,
             right=time,
             top=highLevel,
             bottom=lowLevel,
             xloc=xloc.bar_time,
             bgcolor=gapBoxColor,
             border_color=color.new(color.orange, 100),
             extend=extend.none
         )

    if showHighLine
        highLine := line.new(gapTime, highLevel, time, highLevel, xloc=xloc.bar_time, color=highLineColor, width=highLineWidth)

    if showLowLine
        lowLine := line.new(gapTime, lowLevel, time, lowLevel, xloc=xloc.bar_time, color=lowLineColor, width=lowLineWidth)

    if showCELine
        ceLine := line.new(gapTime, ceLevel, time, ceLevel, xloc=xloc.bar_time, color=ceLineColor, width=ceLineWidth)

    if showLabels
        if showHighLine
            highLabel := label.new(bar_index + labelOffset, highLevel, "ORG High " + dateText, xloc=xloc.bar_index, style=label.style_label_left, textcolor=labelTextColor, color=labelBgColor, size=size.small)

        if showLowLine
            lowLabel := label.new(bar_index + labelOffset, lowLevel, "ORG Low " + dateText, xloc=xloc.bar_index, style=label.style_label_left, textcolor=labelTextColor, color=labelBgColor, size=size.small)

        if showCELine
            ceLabel := label.new(bar_index + labelOffset, ceLevel, "ORG C.E " + dateText, xloc=xloc.bar_index, style=label.style_label_left, textcolor=labelTextColor, color=labelBgColor, size=size.small)

// === Extend Today's Objects To Latest Candle ===
if after0930 and activeGapDate == currentDate
    if not na(gapBox)
        box.set_right(gapBox, time)
        box.set_bgcolor(gapBox, gapBoxColor)

    if not na(highLine)
        line.set_x2(highLine, time)
        line.set_color(highLine, highLineColor)
        line.set_width(highLine, highLineWidth)

    if not na(lowLine)
        line.set_x2(lowLine, time)
        line.set_color(lowLine, lowLineColor)
        line.set_width(lowLine, lowLineWidth)

    if not na(ceLine)
        line.set_x2(ceLine, time)
        line.set_color(ceLine, ceLineColor)
        line.set_width(ceLine, ceLineWidth)

    if showLabels
        if not na(highLabel)
            label.set_x(highLabel, bar_index + labelOffset)
            label.set_y(highLabel, highLevel)

        if not na(lowLabel)
            label.set_x(lowLabel, bar_index + labelOffset)
            label.set_y(lowLabel, lowLevel)

        if not na(ceLabel)
            label.set_x(ceLabel, bar_index + labelOffset)
            label.set_y(ceLabel, ceLevel)
````
