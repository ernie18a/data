# 10am Open + Rejection Blocks

- url: https://www.tradingview.com/script/KpTNAcXa-10am-Open-Rejection-Blocks/
- type: indicator
- pine_id: PUB;64a0a346abb34c529b2cce59718d4c3f
- version: 3.0

## Description

[b]❤︎ 10am Open + Rejection Blocks[/b]

This indicator is based on the 10am opening line concept inspired by Powell’s strategy.

The idea is that the new 4-hour opening candle at 10:00 AM often creates a manipulation wick. The opposite side of that manipulation can then be treated as potential continuation.

[b]Core Logic[/b]
[list]
[*]Plots the 10:00 AM opening line
[*]Measures the opposite-side wick from the 10am open
[*]Allows a custom wick-size threshold in points
[*]Highlights when the wick meets the manipulation threshold
[*]Detects 5-minute rejection blocks around the 10am line
[/list]
[b]Manipulation Threshold[/b]
The wick threshold lets you define how large a wick must be to qualify as manipulation.

I have found that 12.5 points or greater can be a useful qualifier.

If the wick is smaller than the threshold, the opposing side may be considered the manipulation instead. In that case, traders can wait for price to reclaim the 10am line using a rejection block.

[b]Bullish Rejection Block[/b]
[list]
[*]5-minute candle closes bullish
[*]Opens at or above the 10am line
[*]Wicks below the line
[*]Closes back above the line
[*]The lower wick forms the rejection block
[/list]
[b]Bearish Rejection Block[/b]
[list]
[*]5-minute candle closes bearish
[*]Opens at or below the 10am line
[*]Wicks above the line
[*]Closes back below the line
[*]The upper wick forms the rejection block
[/list]
[b]Display Options[/b]
[list]
[*]Show or hide the 10am opening line
[*]Show all rejection blocks
[*]Show only the first bullish and first bearish rejection block
[*]Customize colors, labels, line style, and extension length
[/list]
This tool is intended for visual study and backtesting support. It does not provide financial advice or guaranteed trade signals.

## Source Code

````pine
//@version=6
indicator("❤︎ 10am Open + Rejection Blocks", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

//━━━━━━━━━━━━━━━━━━━
// General
//━━━━━━━━━━━━━━━━━━━
timezoneInput = input.string("America/New_York", "Timezone", options=[
     "America/New_York",
     "America/Chicago",
     "America/Denver",
     "America/Los_Angeles",
     "UTC",
     "Europe/London",
     "Asia/Tokyo"
], group="General")

//━━━━━━━━━━━━━━━━━━━
// 10 AM Line
//━━━━━━━━━━━━━━━━━━━
lineMode = input.string("Current Session", "10am Line Display", options=["None", "Current Session", "Every Session"], group="10 AM Line")
showLine = lineMode != "None"
maxLineTimeframe = input.timeframe("15", "... Up To Timeframe", group="10 AM Line")

endHour = input.int(12, "Line End (hh:mm)", minval=0, maxval=23, inline = "Line_End", group="10 AM Line")
endMinute = input.int(00, "", minval=00, maxval=59, inline = "Line_End", group="10 AM Line")

lineStyleInput = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], inline = "10_Line", group="10 AM Line")
lineColor = input.color(#99ca9d, "", inline = "10_Line", group="10 AM Line")
lineThicknessInput = input.string("2px", "", options=["1px", "2px", "3px", "4px", "5px"], inline = "10_Line", group="10 AM Line")

lineLabelText = input.string("10:00", "Line Label", inline = "10_Label", group="10 AM Line")
lineLabelColor = input.color(#99ca9d, "", inline = "10_Label", group="10 AM Line")
lineLabelSizeInput = input.string("12px", "", options=["8px", "10px", "12px", "14px", "16px", "18px"], inline = "10_Label", group="10 AM Line")
lineLabelOffsetBars = 0

//━━━━━━━━━━━━━━━━━━━
// 4-Hour Wick Label
//━━━━━━━━━━━━━━━━━━━
var wick = "4-Hour Wick Label"

showWickLabel = input.bool(true, "Show Opposite Wick Label", group= wick)
wickThreshold = input.float(12.5, "Minimum Wick Size", step=0.5, tooltip="Minimum wick size, in points, required for the opposite wick to be considered the 4-hour manipulation wick.", group= wick)
wickLabelColor = input.color(#99ca9d, "Wick Label Style", inline = "Wick_Label", group= wick)
wickLabelSizeInput = input.string("12px", "", options=["8px", "10px", "12px", "14px", "16px", "18px"], inline = "Wick_Label", group= wick)
wickLabelOffsetPoints = 2.0

//━━━━━━━━━━━━━━━━━━━
// Rejection Blocks
//━━━━━━━━━━━━━━━━━━━
rbTf = input.timeframe("5", "RB Timeframe", options=["1", "5", "15"], group="Rejection Blocks")

rbDisplayMode = input.string("All", "RB Display", options=["None", "First Bull + First Bear", "All"], group="Rejection Blocks")
showBlocks = rbDisplayMode != "None"

rbCutoffHour = input.int(12, "RB Cutoff (hh:mm)", minval=0, maxval=23, inline = "RB_end", group="Rejection Blocks")
rbCutoffMinute = input.int(0, "", minval=0, maxval=59, inline = "RB_end",group="Rejection Blocks")

bullBlockColor = input.color(color.new(#90bff9, 70), "Bullish RB", inline = "RB_Color", group="Rejection Blocks")
bearBlockColor = input.color(color.new(#f4b8dc, 70), "Bearish RB", inline = "RB_Color", group="Rejection Blocks")

extendBars = input.int(4, "Extend Bars", minval=1, group="Rejection Blocks")

showRbLabels = input.bool(false, "Show RB Labels", inline = "RB_Label", group="Rejection Blocks")
centerRbLabels = true
rbLabelTextColor = input.color(#99ca9d, "", inline = "RB_Label", group="Rejection Blocks")
rbLabelSizeInput = input.string("10px", "", options=["8px", "10px", "12px", "14px", "16px", "18px"], inline="RB_Label", group="Rejection Blocks")

//━━━━━━━━━━━━━━━━━━━
// RB Qualifiers
//━━━━━━━━━━━━━━━━━━━
var RB_Q = "Rejection Block Qualifiers"

requireCandleColor = input.bool(true, "Require Candle Color", tooltip="When enabled, bullish RBs must close green and bearish RBs must close red. When disabled, RB direction is based on wick-through and close location relative to the 10 AM line.", group = RB_Q)

dojiHandling = input.string("Exclude", "Doji Handling", options=["Exclude", "Use Larger Wick"], tooltip = "'Exclude' ignores dojis. 'Use Larger Wick' assigns RB direction based on the larger wick, while still requiring a close above or below the 10 AM line.", group= RB_Q)

rbQualificationMode = input.string(
     "Wick Greater Than Body",
     "Wick Filter",
     options=["Wick Greater Than Body", "All"],
     tooltip="Controls whether the rejection wick must be larger than the candle body. 'All' allows any valid RB regardless of wick-to-body size.",
     group= RB_Q)

//━━━━━━━━━━━━━━━━━━━
// Style Conversion
//━━━━━━━━━━━━━━━━━━━
getLabelSize(sizeInput) =>
    switch sizeInput
        "8px" => size.tiny
        "10px" => size.small
        "12px" => size.normal
        "14px" => size.large
        "16px" => size.large
        => size.huge

getLineStyle(styleInput) =>
    switch styleInput
        "Solid" => line.style_solid
        "Dashed" => line.style_dashed
        => line.style_dotted

getLineWidth(widthInput) =>
    switch widthInput
        "1px" => 1
        "2px" => 2
        "3px" => 3
        "4px" => 4
        => 5

lineLabelSize = getLabelSize(lineLabelSizeInput)
wickLabelSize = getLabelSize(wickLabelSizeInput)
rbLabelSize = getLabelSize(rbLabelSizeInput)

lineStyle = getLineStyle(lineStyleInput)
lineWidth = getLineWidth(lineThicknessInput)

showLinesOnThisTF = timeframe.in_seconds(timeframe.period) <= timeframe.in_seconds(maxLineTimeframe)
showBlocksOnThisTF = timeframe.in_seconds(timeframe.period) <= timeframe.in_seconds(rbTf)

//━━━━━━━━━━━━━━━━━━━
// Time Detection
//━━━━━━━━━━━━━━━━━━━
isTenAM = hour(time, timezoneInput) == 10 and minute(time, timezoneInput) == 0
newDay = ta.change(dayofmonth(time, timezoneInput))

//━━━━━━━━━━━━━━━━━━━
// Storage
//━━━━━━━━━━━━━━━━━━━
var float currentTenOpen = na
var int currentTenStartTime = na
var int currentTenEndTime = na
var int currentFourHourEndTime = na
var int currentRbCutoffTime = na

var float tenHigh = na
var float tenLow = na
var label wickLabel = na

var bool bullRbShown = false
var bool bearRbShown = false
var int lastRbTime = na

var line[] tenLines = array.new_line()
var label[] tenLabels = array.new_label()
var int[] tenEndTimes = array.new_int()
var box[] rbBoxes = array.new_box()
var label[] rbLabels = array.new_label()


//━━━━━━━━━━━━━━━━━━━
// Reset Per Session
//━━━━━━━━━━━━━━━━━━━
if newDay != 0
    currentTenOpen := na
    currentTenStartTime := na
    currentTenEndTime := na
    currentFourHourEndTime := na
    currentRbCutoffTime := na
    tenHigh := na
    tenLow := na
    bullRbShown := false
    bearRbShown := false
    lastRbTime := na

    if not na(wickLabel)
        label.delete(wickLabel)
        wickLabel := na

    if lineMode == "Current Session"
        if array.size(tenLines) > 0
            for i = 0 to array.size(tenLines) - 1
                line.delete(array.get(tenLines, i))

        if array.size(tenLabels) > 0
            for i = 0 to array.size(tenLabels) - 1
                label.delete(array.get(tenLabels, i))

        if array.size(rbBoxes) > 0
            for i = 0 to array.size(rbBoxes) - 1
                box.delete(array.get(rbBoxes, i))

        if array.size(rbLabels) > 0
            for i = 0 to array.size(rbLabels) - 1
                label.delete(array.get(rbLabels, i))

        array.clear(tenLines)
        array.clear(tenLabels)
        array.clear(tenEndTimes)
        array.clear(rbBoxes)
        array.clear(rbLabels)

//━━━━━━━━━━━━━━━━━━━
// Capture 10 AM Open
//━━━━━━━━━━━━━━━━━━━
if isTenAM and na(currentTenOpen)
    currentTenOpen := open
    tenHigh := high
    tenLow := low

    currentTenStartTime := timestamp(timezoneInput, year(time, timezoneInput), month(time, timezoneInput), dayofmonth(time, timezoneInput), 10, 0)
    currentTenEndTime := timestamp(timezoneInput, year(time, timezoneInput), month(time, timezoneInput), dayofmonth(time, timezoneInput), endHour, endMinute)
    currentFourHourEndTime := timestamp(timezoneInput, year(time, timezoneInput), month(time, timezoneInput), dayofmonth(time, timezoneInput), 14, 0)
    currentRbCutoffTime := timestamp(timezoneInput, year(time, timezoneInput), month(time, timezoneInput), dayofmonth(time, timezoneInput), rbCutoffHour, rbCutoffMinute)

    if showLine and showLinesOnThisTF
        newLine = line.new(currentTenStartTime, currentTenOpen, currentTenEndTime, currentTenOpen, xloc=xloc.bar_time, extend=extend.none, color=lineColor, style=lineStyle, width=lineWidth)

        newLabel = label.new(currentTenEndTime, currentTenOpen, lineLabelText, xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.white, 100), textcolor=lineLabelColor, size=lineLabelSize)

        wickLabel := label.new(currentTenStartTime, currentTenOpen, "", xloc=xloc.bar_time, style=label.style_label_center, color=color.new(color.white, 100), textcolor=wickLabelColor, size=wickLabelSize)

        array.push(tenLines, newLine)
        array.push(tenLabels, newLabel)
        array.push(tenEndTimes, currentTenEndTime)

//━━━━━━━━━━━━━━━━━━━
// Track Wick Extremes
//━━━━━━━━━━━━━━━━━━━
inTenWindow =
     not na(currentTenStartTime) and
     not na(currentTenEndTime) and
     time >= currentTenStartTime and
     time <= currentTenEndTime

if inTenWindow and not na(currentTenOpen)
    tenHigh := math.max(tenHigh, high)
    tenLow := math.min(tenLow, low)

//━━━━━━━━━━━━━━━━━━━
// Wick Label Logic
//━━━━━━━━━━━━━━━━━━━
isBullBody = not na(currentTenOpen) and close >= currentTenOpen

bottomWick = not na(currentTenOpen) and not na(tenLow) ? math.max(currentTenOpen - tenLow, 0) : na
topWick = not na(currentTenOpen) and not na(tenHigh) ? math.max(tenHigh - currentTenOpen, 0) : na

oppositeWick = isBullBody ? bottomWick : topWick
wickIsBottom = isBullBody

wickText =
     not na(oppositeWick)
     ? (wickIsBottom ? "↓ " : "↑ ") + str.tostring(oppositeWick, "#.##") + " pts" + (oppositeWick >= wickThreshold ? " ✓" : "")
     : ""

midTime =
     not na(currentTenStartTime) and not na(currentTenEndTime)
     ? currentTenStartTime + int((currentTenEndTime - currentTenStartTime) / 2)
     : na

wickY = wickIsBottom ? currentTenOpen - wickLabelOffsetPoints : currentTenOpen + wickLabelOffsetPoints
wickStyle = wickIsBottom ? label.style_label_down : label.style_label_up

//━━━━━━━━━━━━━━━━━━━
// Doji Detection
//━━━━━━━━━━━━━━━━━━━
detectDoji(_bodyPoints, _high, _low) =>
    candleRange = _high - _low
    bodyPercent = candleRange > 0 ? _bodyPoints / candleRange : 1.0
    bodyPercent <= 0.25

//━━━━━━━━━━━━━━━━━━━
// Rejection Block Detection
//━━━━━━━━━━━━━━━━━━━
detectRB(_tenOpen) =>
    bullCandle = close > open
    bearCandle = close < open

    bodyPoints = math.abs(close - open)
    isDoji = detectDoji(bodyPoints, high, low)

    upperWick = high - math.max(open, close)
    lowerWick = math.min(open, close) - low

    useNormalColorLogic = not isDoji

    normalBullValid =
         useNormalColorLogic and
         (not requireCandleColor or bullCandle) and
         open >= _tenOpen and
         low < _tenOpen and
         close > _tenOpen

    normalBearValid =
         useNormalColorLogic and
         (not requireCandleColor or bearCandle) and
         open <= _tenOpen and
         high > _tenOpen and
         close < _tenOpen

    dojiTouchesTenLine =
         not na(_tenOpen) and
         low <= _tenOpen and
         high >= _tenOpen

    dojiBullValid =
         isDoji and
         dojiHandling == "Use Larger Wick" and
         dojiTouchesTenLine and
         lowerWick > upperWick and
         close > _tenOpen

    dojiBearValid =
         isDoji and
         dojiHandling == "Use Larger Wick" and
         dojiTouchesTenLine and
         upperWick > lowerWick and
         close < _tenOpen

    bullValid = normalBullValid or dojiBullValid
    bearValid = normalBearValid or dojiBearValid

    bullFullWick = bullValid ? math.max(math.min(open, close) - low, 0) : na
    bearFullWick = bearValid ? math.max(high - math.max(open, close), 0) : na

    bullRB =
         bullValid and
         not (isDoji and dojiHandling == "Exclude") and
         (
             rbQualificationMode == "All" or
             bullFullWick > bodyPoints
         )

    bearRB =
         bearValid and
         not (isDoji and dojiHandling == "Exclude") and
         (
             rbQualificationMode == "All" or
             bearFullWick > bodyPoints
         )

    rbTop = bullRB ? math.min(open, close) : bearRB ? high : na
    rbBottom = bullRB ? low : bearRB ? math.max(open, close) : na
    rbTime = bullRB or bearRB ? time : na
    rbPoints = bullRB ? bullFullWick : bearRB ? bearFullWick : na

    [bullRB, bearRB, rbTop, rbBottom, rbTime, rbPoints, barstate.isconfirmed]

[bullRB, bearRB, rbTop, rbBottom, rbTime, rbPoints, rbConfirmed] = request.security(syminfo.tickerid, rbTf, detectRB(currentTenOpen), barmerge.gaps_off, barmerge.lookahead_off)

//━━━━━━━━━━━━━━━━━━━
// Draw Rejection Blocks
//━━━━━━━━━━━━━━━━━━━
hasRB =
     rbConfirmed and
     (bullRB or bearRB) and
     not na(rbTop) and
     not na(rbBottom) and
     not na(rbTime)

rbInWindow =
     hasRB and
     not na(currentTenStartTime) and
     not na(currentRbCutoffTime) and
     rbTime >= currentTenStartTime and
     rbTime <= currentRbCutoffTime

isNewRB = hasRB and (na(lastRbTime) or rbTime != lastRbTime)

allowByMode = switch rbDisplayMode
    "All" => true
    "First Bull + First Bear" => (bullRB and not bullRbShown) or (bearRB and not bearRbShown)
    => false

if showBlocks and showBlocksOnThisTF and rbInWindow and isNewRB and allowByMode
    lastRbTime := rbTime

    if bullRB
        bullRbShown := true

    if bearRB
        bearRbShown := true

    blockColor = bullRB ? bullBlockColor : bearBlockColor
    rbEndTime = rbTime + extendBars * timeframe.in_seconds(rbTf) * 1000

    newBox = box.new(
         rbTime,
         rbTop,
         rbEndTime,
         rbBottom,
         xloc=xloc.bar_time,
         border_color=na,
         bgcolor=blockColor)

    array.push(rbBoxes, newBox)

    if showRbLabels
        rbLabelX = rbTime
        if centerRbLabels
            rbLabelX := rbTime + int((rbEndTime - rbTime) / 2)

        rbLabelOffsetPoints = 6.0
        rbLabelY = bullRB ? rbBottom - rbLabelOffsetPoints : rbTop + rbLabelOffsetPoints

        newRbLabel = label.new(
            rbLabelX,
            rbLabelY,
            str.tostring(rbPoints, "#.##") + " pts",
            xloc = xloc.bar_time,
            style = label.style_label_center,
            color = color.new(color.white, 100),
            textcolor = rbLabelTextColor,
            size = rbLabelSize)

        array.push(rbLabels, newRbLabel)

//━━━━━━━━━━━━━━━━━━━
// Update 10 AM Line + Labels
//━━━━━━━━━━━━━━━━━━━
if showLine and showLinesOnThisTF
    if array.size(tenLines) > 0
        for i = 0 to array.size(tenLines) - 1
            l = array.get(tenLines, i)
            line.set_color(l, lineColor)
            line.set_style(l, lineStyle)
            line.set_width(l, lineWidth)

    if array.size(tenLabels) > 0
        for i = 0 to array.size(tenLabels) - 1
            lb = array.get(tenLabels, i)
            endTime = array.get(tenEndTimes, i)
            label.set_x(lb, endTime + lineLabelOffsetBars * timeframe.in_seconds(timeframe.period) * 1000)
            label.set_text(lb, lineLabelText)
            label.set_textcolor(lb, lineLabelColor)
            label.set_size(lb, lineLabelSize)

    if not na(wickLabel) and not na(midTime)
        showWickLabelNow = showWickLabel and not na(currentFourHourEndTime) and time <= currentFourHourEndTime

        label.set_x(wickLabel, midTime)
        label.set_y(wickLabel, wickY)
        label.set_style(wickLabel, wickStyle)
        label.set_textcolor(wickLabel, wickLabelColor)
        label.set_size(wickLabel, wickLabelSize)
        label.set_text(wickLabel, showWickLabelNow ? wickText : "")

//━━━━━━━━━━━━━━━━━━━
// Hide Line When Off / TF Too High
//━━━━━━━━━━━━━━━━━━━
if not showLine or not showLinesOnThisTF
    if array.size(tenLines) > 0
        for i = 0 to array.size(tenLines) - 1
            line.delete(array.get(tenLines, i))

    if array.size(tenLabels) > 0
        for i = 0 to array.size(tenLabels) - 1
            label.delete(array.get(tenLabels, i))

    if not na(wickLabel)
        label.delete(wickLabel)
        wickLabel := na

    array.clear(tenLines)
    array.clear(tenLabels)
    array.clear(tenEndTimes)
````
