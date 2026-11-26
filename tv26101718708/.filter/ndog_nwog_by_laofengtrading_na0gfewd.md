# NDOG NWOG by Laofengtrading

- url: https://www.tradingview.com/script/Na0GFEwd-NDOG-NWOG-by-Laofengtrading/
- type: indicator
- pine_id: PUB;bc4ea4496eb041589031e37293f91449
- version: 1.0

## Description

This indicator automatically marks New Daily Opening Gaps (NDOG) and New Weekly Opening Gaps (NWOG) using New York time.

NDOG is calculated from the previous New York 16:59 close to the 18:00 open. The gap is labeled with the next trading day date, because the 18:00 open belongs to the next trading session.

NWOG is detected when the gap is formed from Friday 16:59 close to Sunday 18:00 open.

Features:

- Automatically detects NDOG and NWOG
- Uses fixed New York time
- Calculates gaps from 1-minute data
- Draws each gap as a rectangle from the gap creation point to the latest candle
- Displays the gap name and trading date next to the rectangle
- Optional middle line
- Customizable NDOG and NWOG background colors
- Separate colors for the latest NDOG and latest NWOG
- Customizable text color and size
- Adjustable retention count for NDOG and NWOG

Default retention:

NDOG: 5
NWOG: 3

## Source Code

````pine
//@version=6
indicator("NDOG NWOG by Laofengtrading", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

showNDOG = input.bool(true, "Show NDOG")
ndogKeep = input.int(5, "NDOG Keep Count", minval=1, maxval=100)
ndogBgColor = input.color(color.new(color.aqua, 78), "NDOG Background Color")
latestNdogBgColor = input.color(color.new(color.aqua, 60), "Latest NDOG Color")

showNWOG = input.bool(true, "Show NWOG")
nwogKeep = input.int(3, "NWOG Keep Count", minval=1, maxval=100)
nwogBgColor = input.color(color.new(color.orange, 78), "NWOG Background Color")
latestNwogBgColor = input.color(color.new(color.orange, 60), "Latest NWOG Color")

showText = input.bool(true, "Show Text")
textColor = input.color(color.black, "Text Color")
textSizeInput = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal", "Large"])
textOffset = input.int(0, "Text Offset After Box", minval=0, maxval=50)

middleLineColor = input.color(color.gray, "Middle Line Color")
middleLineWidth = input.int(1, "Middle Line Width", minval=1, maxval=5)

timezone = "America/New_York"
oneDayMs = 24 * 60 * 60 * 1000
labelSize = textSizeInput == "Tiny" ? size.tiny : textSizeInput == "Small" ? size.small : textSizeInput == "Normal" ? size.normal : size.large

f_gapEngine() =>
    h = hour(time, timezone)
    m = minute(time, timezone)
    dow = dayofweek(time, timezone)

    isClose459 = h == 16 and m == 59
    isOpen1800 = h == 18 and m == 0

    var float lastClose459 = na
    var int lastCloseDow = na

    var int gapId = 0
    var float gapTop = na
    var float gapBottom = na
    var int gapTime = na
    var int gapType = 0
    var int gapDate = na

    if isClose459
        lastClose459 := close
        lastCloseDow := dow

    if isOpen1800 and not na(lastClose459)
        nextSessionTime = time + oneDayMs

        gapId += 1
        gapTop := math.max(lastClose459, open)
        gapBottom := math.min(lastClose459, open)
        gapTime := time
        gapType := lastCloseDow == dayofweek.friday and dow == dayofweek.sunday ? 2 : 1
        gapDate := year(nextSessionTime, timezone) * 10000 + month(nextSessionTime, timezone) * 100 + dayofmonth(nextSessionTime, timezone)

    [gapId, gapTop, gapBottom, gapTime, gapType, gapDate]

[gapId, gapTop, gapBottom, gapTime, gapType, gapDate] =
     request.security(syminfo.tickerid, "1", f_gapEngine(), barmerge.gaps_off, barmerge.lookahead_off)

var box[] ndogBoxes = array.new_box()
var line[] ndogLines = array.new_line()
var label[] ndogLabels = array.new_label()

var box[] nwogBoxes = array.new_box()
var line[] nwogLines = array.new_line()
var label[] nwogLabels = array.new_label()

var int lastDrawnGapId = na

newGap = gapId > 0 and (na(lastDrawnGapId) or gapId != lastDrawnGapId) and not na(gapTop) and not na(gapBottom) and not na(gapTime)

if newGap
    lastDrawnGapId := gapId

    isNWOG = gapType == 2
    gapName = isNWOG ? "NWOG" : "NDOG"
    gapText = gapName + " " + str.tostring(gapDate)
    gapMid = (gapTop + gapBottom) / 2

    if isNWOG and showNWOG
        b = box.new(left=gapTime, right=time, top=gapTop, bottom=gapBottom, xloc=xloc.bar_time, bgcolor=latestNwogBgColor, border_color=color.new(color.orange, 100), extend=extend.none)
        ln = line.new(x1=gapTime, y1=gapMid, x2=time, y2=gapMid, xloc=xloc.bar_time, color=middleLineColor, width=middleLineWidth, extend=extend.none)

        array.push(nwogBoxes, b)
        array.push(nwogLines, ln)

        if showText
            lb = label.new(x=bar_index + textOffset, y=gapMid, xloc=xloc.bar_index, text=gapText, style=label.style_label_left, textcolor=textColor, color=color.new(color.white, 100), size=labelSize)
            array.push(nwogLabels, lb)

        while array.size(nwogBoxes) > nwogKeep
            box.delete(array.shift(nwogBoxes))
        while array.size(nwogLines) > nwogKeep
            line.delete(array.shift(nwogLines))
        while array.size(nwogLabels) > nwogKeep
            label.delete(array.shift(nwogLabels))

    if not isNWOG and showNDOG
        b = box.new(left=gapTime, right=time, top=gapTop, bottom=gapBottom, xloc=xloc.bar_time, bgcolor=latestNdogBgColor, border_color=color.new(color.aqua, 100), extend=extend.none)
        ln = line.new(x1=gapTime, y1=gapMid, x2=time, y2=gapMid, xloc=xloc.bar_time, color=middleLineColor, width=middleLineWidth, extend=extend.none)

        array.push(ndogBoxes, b)
        array.push(ndogLines, ln)

        if showText
            lb = label.new(x=bar_index + textOffset, y=gapMid, xloc=xloc.bar_index, text=gapText, style=label.style_label_left, textcolor=textColor, color=color.new(color.white, 100), size=labelSize)
            array.push(ndogLabels, lb)

        while array.size(ndogBoxes) > ndogKeep
            box.delete(array.shift(ndogBoxes))
        while array.size(ndogLines) > ndogKeep
            line.delete(array.shift(ndogLines))
        while array.size(ndogLabels) > ndogKeep
            label.delete(array.shift(ndogLabels))

// Update NDOG only with NDOG colors
if array.size(ndogBoxes) > 0
    for i = 0 to array.size(ndogBoxes) - 1
        b = array.get(ndogBoxes, i)
        box.set_right(b, time)
        box.set_bgcolor(b, i == array.size(ndogBoxes) - 1 ? latestNdogBgColor : ndogBgColor)

// Update NWOG only with NWOG colors
if array.size(nwogBoxes) > 0
    for i = 0 to array.size(nwogBoxes) - 1
        b = array.get(nwogBoxes, i)
        box.set_right(b, time)
        box.set_bgcolor(b, i == array.size(nwogBoxes) - 1 ? latestNwogBgColor : nwogBgColor)

if array.size(ndogLines) > 0
    for i = 0 to array.size(ndogLines) - 1
        line.set_x2(array.get(ndogLines, i), time)

if array.size(nwogLines) > 0
    for i = 0 to array.size(nwogLines) - 1
        line.set_x2(array.get(nwogLines, i), time)

if showText
    if array.size(ndogLabels) > 0
        for i = 0 to array.size(ndogLabels) - 1
            label.set_x(array.get(ndogLabels, i), bar_index + textOffset)

    if array.size(nwogLabels) > 0
        for i = 0 to array.size(nwogLabels) - 1
            label.set_x(array.get(nwogLabels, i), bar_index + textOffset)
````
