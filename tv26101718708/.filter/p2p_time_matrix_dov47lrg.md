# P2P Time Matrix

- url: https://www.tradingview.com/script/DOV47lrG-P2P-Time-Matrix/
- type: indicator
- pine_id: PUB;51a0260d6ef04cd5bc02063111687403
- version: 4.0

## Description

[b]P2P Time Matrix[/b] is a precision-based time indicator designed to automatically box and project key 1-minute anchor candles throughout the trading day. Instead of focusing on broad sessions, this tool highlights specific time-based candles — 18:00, 00:00, 08:30, 09:30, and 10:00 ET — and extends their high/low range forward so traders can study how price respects, rejects, or delivers through these key time anchors.

## Source Code

````pine
//@version=6
indicator("P2P Time Matrix", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
tz = input.string("America/New_York", "Timezone")

lookbackDays = input.int(3, "Lookback Days", minval=0, maxval=30)

showLabels  = input.bool(true, "Show Time Labels")
showMidline = input.bool(true, "Show Midlines")

liveBoxOffsetBars = input.int(10, "Current Day Box Offset From Current Candle", minval=1, maxval=120)

midlineStyleInput = input.string("Solid", "Midline Style", options=["Solid", "Dotted", "Dashed"])
midlineWidth      = input.int(1, "Midline Width", minval=1, maxval=5)

boxBorderWidth = input.int(1, "Box Border Width", minval=1, maxval=5)

labelSizeInput     = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large"])
labelOffsetMins    = input.int(3, "Label Offset From Box End - Minutes", minval=1, maxval=60)
midlineTextGapMins = input.int(2, "Midline Gap Before Text - Minutes", minval=1, maxval=30)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Source Candle Timeframes
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
timeframeGroup = "Anchor Candle Timeframes"

show1MinuteAnchors  = input.bool(true, "Show 1-Minute Candle Boxes", group=timeframeGroup)
show5MinuteAnchors  = input.bool(false, "Show 5-Minute Candle Boxes", group=timeframeGroup)
show10MinuteAnchors = input.bool(false, "Show 10-Minute Candle Boxes", group=timeframeGroup)
show15MinuteAnchors = input.bool(false, "Show 15-Minute Candle Boxes", group=timeframeGroup)
show30MinuteAnchors = input.bool(false, "Show 30-Minute Candle Boxes", group=timeframeGroup)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Anchor Visibility
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
show1800 = input.bool(true, "Show 18:00 Anchor")
show0000 = input.bool(true, "Show 00:00 Anchor")
show0830 = input.bool(true, "Show 08:30 Anchor")
show0930 = input.bool(true, "Show 09:30 Anchor")
show1000 = input.bool(true, "Show 10:00 Anchor")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Anchor Colors
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
group1800 = "18:00 Anchor Style"
fill1800   = input.color(color.new(color.green, 85), "Fill", group=group1800)
border1800 = input.color(color.new(color.green, 30), "Border", group=group1800)
line1800   = input.color(color.new(color.green, 0), "Midline", group=group1800)
text1800   = input.color(color.new(color.green, 0), "Text", group=group1800)

group0000 = "00:00 Anchor Style"
fill0000   = input.color(color.new(color.blue, 85), "Fill", group=group0000)
border0000 = input.color(color.new(color.blue, 30), "Border", group=group0000)
line0000   = input.color(color.new(color.blue, 0), "Midline", group=group0000)
text0000   = input.color(color.new(color.blue, 0), "Text", group=group0000)

group0830 = "08:30 Anchor Style"
fill0830   = input.color(color.new(color.orange, 85), "Fill", group=group0830)
border0830 = input.color(color.new(color.orange, 30), "Border", group=group0830)
line0830   = input.color(color.new(color.orange, 0), "Midline", group=group0830)
text0830   = input.color(color.new(color.orange, 0), "Text", group=group0830)

group0930 = "09:30 Anchor Style"
fill0930   = input.color(color.new(color.purple, 85), "Fill", group=group0930)
border0930 = input.color(color.new(color.purple, 30), "Border", group=group0930)
line0930   = input.color(color.new(color.purple, 0), "Midline", group=group0930)
text0930   = input.color(color.new(color.purple, 0), "Text", group=group0930)

group1000 = "10:00 Anchor Style"
fill1000   = input.color(color.new(color.red, 85), "Fill", group=group1000)
border1000 = input.color(color.new(color.red, 30), "Border", group=group1000)
line1000   = input.color(color.new(color.red, 0), "Midline", group=group1000)
text1000   = input.color(color.new(color.red, 0), "Text", group=group1000)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Time Helpers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
isAllowedTimeframe = timeframe.isintraday

msInMinute = 60 * 1000
msInDay    = 24 * 60 * 60 * 1000

int chartBarDurationMs = int(timeframe.in_seconds() * 1000)
int liveOffsetMs       = liveBoxOffsetBars * chartBarDurationMs

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Futures Session Day Helper
// Session begins at 18:00 ET.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
getSessionStart(_t) =>
    int y = year(_t, tz)
    int m = month(_t, tz)
    int d = dayofmonth(_t, tz)
    int h = hour(_t, tz)

    int sessionStartToday = timestamp(tz, y, m, d, 18, 0)

    h >= 18 ? sessionStartToday : sessionStartToday - msInDay

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Style Helpers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
getLineStyle(_style) =>
    _style == "Dotted" ? line.style_dotted :
     _style == "Dashed" ? line.style_dashed :
     line.style_solid

getTextSize(_size) =>
    _size == "Tiny" ? size.tiny :
     _size == "Normal" ? size.normal :
     _size == "Large" ? size.large :
     size.small

getTimeframeFill(_baseColor, _additionalTransparency) =>
    int baseTransparency = int(color.t(_baseColor))
    int adjustedTransparency = math.min(100, baseTransparency + _additionalTransparency)

    color.new(_baseColor, adjustedTransparency)

midStyle = getLineStyle(midlineStyleInput)
txtSize  = getTextSize(labelSizeInput)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Retrieve All Anchor Candles From a Source
// Timeframe
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
getAnchorSet() =>
    bool condition1800 = hour(time, tz) == 18 and minute(time, tz) == 0 and barstate.isconfirmed
    bool condition0000 = hour(time, tz) == 0 and minute(time, tz) == 0 and barstate.isconfirmed
    bool condition0830 = hour(time, tz) == 8 and minute(time, tz) == 30 and barstate.isconfirmed
    bool condition0930 = hour(time, tz) == 9 and minute(time, tz) == 30 and barstate.isconfirmed
    bool condition1000 = hour(time, tz) == 10 and minute(time, tz) == 0 and barstate.isconfirmed

    int anchor1800Time = ta.valuewhen(condition1800, time, 0)
    float anchor1800High = ta.valuewhen(condition1800, high, 0)
    float anchor1800Low = ta.valuewhen(condition1800, low, 0)

    int anchor0000Time = ta.valuewhen(condition0000, time, 0)
    float anchor0000High = ta.valuewhen(condition0000, high, 0)
    float anchor0000Low = ta.valuewhen(condition0000, low, 0)

    int anchor0830Time = ta.valuewhen(condition0830, time, 0)
    float anchor0830High = ta.valuewhen(condition0830, high, 0)
    float anchor0830Low = ta.valuewhen(condition0830, low, 0)

    int anchor0930Time = ta.valuewhen(condition0930, time, 0)
    float anchor0930High = ta.valuewhen(condition0930, high, 0)
    float anchor0930Low = ta.valuewhen(condition0930, low, 0)

    int anchor1000Time = ta.valuewhen(condition1000, time, 0)
    float anchor1000High = ta.valuewhen(condition1000, high, 0)
    float anchor1000Low = ta.valuewhen(condition1000, low, 0)

    [
         anchor1800Time,
         anchor1800High,
         anchor1800Low,
         anchor0000Time,
         anchor0000High,
         anchor0000Low,
         anchor0830Time,
         anchor0830High,
         anchor0830Low,
         anchor0930Time,
         anchor0930High,
         anchor0930Low,
         anchor1000Time,
         anchor1000High,
         anchor1000Low
     ]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1-Minute Anchor Data
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[
     a1_1800Time,
     a1_1800High,
     a1_1800Low,
     a1_0000Time,
     a1_0000High,
     a1_0000Low,
     a1_0830Time,
     a1_0830High,
     a1_0830Low,
     a1_0930Time,
     a1_0930High,
     a1_0930Low,
     a1_1000Time,
     a1_1000High,
     a1_1000Low
 ] = request.security(
     syminfo.tickerid,
     "1",
     getAnchorSet(),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
 )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 5-Minute Anchor Data
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[
     a5_1800Time,
     a5_1800High,
     a5_1800Low,
     a5_0000Time,
     a5_0000High,
     a5_0000Low,
     a5_0830Time,
     a5_0830High,
     a5_0830Low,
     a5_0930Time,
     a5_0930High,
     a5_0930Low,
     a5_1000Time,
     a5_1000High,
     a5_1000Low
 ] = request.security(
     syminfo.tickerid,
     "5",
     getAnchorSet(),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
 )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 10-Minute Anchor Data
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[
     a10_1800Time,
     a10_1800High,
     a10_1800Low,
     a10_0000Time,
     a10_0000High,
     a10_0000Low,
     a10_0830Time,
     a10_0830High,
     a10_0830Low,
     a10_0930Time,
     a10_0930High,
     a10_0930Low,
     a10_1000Time,
     a10_1000High,
     a10_1000Low
 ] = request.security(
     syminfo.tickerid,
     "10",
     getAnchorSet(),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
 )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 15-Minute Anchor Data
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[
     a15_1800Time,
     a15_1800High,
     a15_1800Low,
     a15_0000Time,
     a15_0000High,
     a15_0000Low,
     a15_0830Time,
     a15_0830High,
     a15_0830Low,
     a15_0930Time,
     a15_0930High,
     a15_0930Low,
     a15_1000Time,
     a15_1000High,
     a15_1000Low
 ] = request.security(
     syminfo.tickerid,
     "15",
     getAnchorSet(),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
 )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 30-Minute Anchor Data
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[
     a30_1800Time,
     a30_1800High,
     a30_1800Low,
     a30_0000Time,
     a30_0000High,
     a30_0000Low,
     a30_0830Time,
     a30_0830High,
     a30_0830Low,
     a30_0930Time,
     a30_0930High,
     a30_0930Low,
     a30_1000Time,
     a30_1000High,
     a30_1000Low
 ] = request.security(
     syminfo.tickerid,
     "30",
     getAnchorSet(),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
 )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Anchor Object Storage
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var box[]   anchorBoxes    = array.new_box()
var line[]  anchorLines    = array.new_line()
var label[] anchorLabels   = array.new_label()
var int[]   anchorSessions = array.new_int()

// Keep safely below TradingView's 500-object limit.
maxTrackedObjects = 475

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Delete Objects Outside the Lookback
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
deleteOldestObject() =>
    if array.size(anchorSessions) > 0
        box oldBox = array.shift(anchorBoxes)
        line oldLine = array.shift(anchorLines)
        label oldLabel = array.shift(anchorLabels)

        array.shift(anchorSessions)

        box.delete(oldBox)

        if not na(oldLine)
            line.delete(oldLine)

        if not na(oldLabel)
            label.delete(oldLabel)

cleanupOldObjects(_newestSession) =>
    int oldestSessionToKeep = _newestSession - lookbackDays * msInDay

    while array.size(anchorSessions) > 0 and array.get(anchorSessions, 0) < oldestSessionToKeep
        deleteOldestObject()

    while array.size(anchorSessions) >= maxTrackedObjects
        deleteOldestObject()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Drawing Function
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
drawAnchor(
     _leftTime,
     _high,
     _low,
     _anchorLabel,
     _sourceTimeframe,
     _fillColor,
     _borderColor,
     _midColor,
     _textColor
 ) =>
    int anchorSessionStart = getSessionStart(_leftTime)

    cleanupOldObjects(anchorSessionStart)

    if not na(_high) and not na(_low)
        float mid = (_high + _low) / 2.0

        // Completed sessions terminate at the next session.
        // Active-session boxes are repositioned on the last bar.
        int rightTime = anchorSessionStart + msInDay

        int labelX = rightTime - labelOffsetMins * msInMinute
        int midlineRightTime = labelX - midlineTextGapMins * msInMinute

        if midlineRightTime <= _leftTime
            midlineRightTime := rightTime

        string fullLabel = _anchorLabel + " • " + _sourceTimeframe

        box b = box.new(
             left=_leftTime,
             top=_high,
             right=rightTime,
             bottom=_low,
             xloc=xloc.bar_time,
             bgcolor=_fillColor,
             border_color=_borderColor,
             border_width=boxBorderWidth
         )

        line ln = na

        if showMidline
            ln := line.new(
                 x1=_leftTime,
                 y1=mid,
                 x2=midlineRightTime,
                 y2=mid,
                 xloc=xloc.bar_time,
                 color=_midColor,
                 width=midlineWidth,
                 style=midStyle
             )

        label lb = na

        if showLabels
            lb := label.new(
                 x=labelX,
                 y=mid,
                 text=fullLabel,
                 xloc=xloc.bar_time,
                 yloc=yloc.price,
                 style=label.style_none,
                 textcolor=_textColor,
                 color=color.new(color.black, 100),
                 size=txtSize,
                 textalign=text.align_right
             )

        array.push(anchorBoxes, b)
        array.push(anchorLines, ln)
        array.push(anchorLabels, lb)
        array.push(anchorSessions, anchorSessionStart)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// New Anchor Detection
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
isNewAnchor(_anchorTime) =>
    not na(_anchorTime) and (na(_anchorTime[1]) or _anchorTime != _anchorTime[1])

// 1-minute
new1_1800 = isNewAnchor(a1_1800Time)
new1_0000 = isNewAnchor(a1_0000Time)
new1_0830 = isNewAnchor(a1_0830Time)
new1_0930 = isNewAnchor(a1_0930Time)
new1_1000 = isNewAnchor(a1_1000Time)

// 5-minute
new5_1800 = isNewAnchor(a5_1800Time)
new5_0000 = isNewAnchor(a5_0000Time)
new5_0830 = isNewAnchor(a5_0830Time)
new5_0930 = isNewAnchor(a5_0930Time)
new5_1000 = isNewAnchor(a5_1000Time)

// 10-minute
new10_1800 = isNewAnchor(a10_1800Time)
new10_0000 = isNewAnchor(a10_0000Time)
new10_0830 = isNewAnchor(a10_0830Time)
new10_0930 = isNewAnchor(a10_0930Time)
new10_1000 = isNewAnchor(a10_1000Time)

// 15-minute
new15_1800 = isNewAnchor(a15_1800Time)
new15_0000 = isNewAnchor(a15_0000Time)
new15_0830 = isNewAnchor(a15_0830Time)
new15_0930 = isNewAnchor(a15_0930Time)
new15_1000 = isNewAnchor(a15_1000Time)

// 30-minute
new30_1800 = isNewAnchor(a30_1800Time)
new30_0000 = isNewAnchor(a30_0000Time)
new30_0830 = isNewAnchor(a30_0830Time)
new30_0930 = isNewAnchor(a30_0930Time)
new30_1000 = isNewAnchor(a30_1000Time)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Timeframe Fill Colors
// Larger source candles receive slightly more
// transparency so overlapping ranges remain visible.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
fill1800_1  = getTimeframeFill(fill1800, 0)
fill1800_5  = getTimeframeFill(fill1800, 2)
fill1800_10 = getTimeframeFill(fill1800, 4)
fill1800_15 = getTimeframeFill(fill1800, 6)
fill1800_30 = getTimeframeFill(fill1800, 8)

fill0000_1  = getTimeframeFill(fill0000, 0)
fill0000_5  = getTimeframeFill(fill0000, 2)
fill0000_10 = getTimeframeFill(fill0000, 4)
fill0000_15 = getTimeframeFill(fill0000, 6)
fill0000_30 = getTimeframeFill(fill0000, 8)

fill0830_1  = getTimeframeFill(fill0830, 0)
fill0830_5  = getTimeframeFill(fill0830, 2)
fill0830_10 = getTimeframeFill(fill0830, 4)
fill0830_15 = getTimeframeFill(fill0830, 6)
fill0830_30 = getTimeframeFill(fill0830, 8)

fill0930_1  = getTimeframeFill(fill0930, 0)
fill0930_5  = getTimeframeFill(fill0930, 2)
fill0930_10 = getTimeframeFill(fill0930, 4)
fill0930_15 = getTimeframeFill(fill0930, 6)
fill0930_30 = getTimeframeFill(fill0930, 8)

fill1000_1  = getTimeframeFill(fill1000, 0)
fill1000_5  = getTimeframeFill(fill1000, 2)
fill1000_10 = getTimeframeFill(fill1000, 4)
fill1000_15 = getTimeframeFill(fill1000, 6)
fill1000_30 = getTimeframeFill(fill1000, 8)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Execute 30-Minute Anchor Creation
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if isAllowedTimeframe and show30MinuteAnchors
    if show1800 and new30_1800
        drawAnchor(a30_1800Time, a30_1800High, a30_1800Low, "18:00", "30m", fill1800_30, border1800, line1800, text1800)

    if show0000 and new30_0000
        drawAnchor(a30_0000Time, a30_0000High, a30_0000Low, "00:00", "30m", fill0000_30, border0000, line0000, text0000)

    if show0830 and new30_0830
        drawAnchor(a30_0830Time, a30_0830High, a30_0830Low, "08:30", "30m", fill0830_30, border0830, line0830, text0830)

    if show0930 and new30_0930
        drawAnchor(a30_0930Time, a30_0930High, a30_0930Low, "09:30", "30m", fill0930_30, border0930, line0930, text0930)

    if show1000 and new30_1000
        drawAnchor(a30_1000Time, a30_1000High, a30_1000Low, "10:00", "30m", fill1000_30, border1000, line1000, text1000)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Execute 15-Minute Anchor Creation
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if isAllowedTimeframe and show15MinuteAnchors
    if show1800 and new15_1800
        drawAnchor(a15_1800Time, a15_1800High, a15_1800Low, "18:00", "15m", fill1800_15, border1800, line1800, text1800)

    if show0000 and new15_0000
        drawAnchor(a15_0000Time, a15_0000High, a15_0000Low, "00:00", "15m", fill0000_15, border0000, line0000, text0000)

    if show0830 and new15_0830
        drawAnchor(a15_0830Time, a15_0830High, a15_0830Low, "08:30", "15m", fill0830_15, border0830, line0830, text0830)

    if show0930 and new15_0930
        drawAnchor(a15_0930Time, a15_0930High, a15_0930Low, "09:30", "15m", fill0930_15, border0930, line0930, text0930)

    if show1000 and new15_1000
        drawAnchor(a15_1000Time, a15_1000High, a15_1000Low, "10:00", "15m", fill1000_15, border1000, line1000, text1000)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Execute 10-Minute Anchor Creation
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if isAllowedTimeframe and show10MinuteAnchors
    if show1800 and new10_1800
        drawAnchor(a10_1800Time, a10_1800High, a10_1800Low, "18:00", "10m", fill1800_10, border1800, line1800, text1800)

    if show0000 and new10_0000
        drawAnchor(a10_0000Time, a10_0000High, a10_0000Low, "00:00", "10m", fill0000_10, border0000, line0000, text0000)

    if show0830 and new10_0830
        drawAnchor(a10_0830Time, a10_0830High, a10_0830Low, "08:30", "10m", fill0830_10, border0830, line0830, text0830)

    if show0930 and new10_0930
        drawAnchor(a10_0930Time, a10_0930High, a10_0930Low, "09:30", "10m", fill0930_10, border0930, line0930, text0930)

    if show1000 and new10_1000
        drawAnchor(a10_1000Time, a10_1000High, a10_1000Low, "10:00", "10m", fill1000_10, border1000, line1000, text1000)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Execute 5-Minute Anchor Creation
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if isAllowedTimeframe and show5MinuteAnchors
    if show1800 and new5_1800
        drawAnchor(a5_1800Time, a5_1800High, a5_1800Low, "18:00", "5m", fill1800_5, border1800, line1800, text1800)

    if show0000 and new5_0000
        drawAnchor(a5_0000Time, a5_0000High, a5_0000Low, "00:00", "5m", fill0000_5, border0000, line0000, text0000)

    if show0830 and new5_0830
        drawAnchor(a5_0830Time, a5_0830High, a5_0830Low, "08:30", "5m", fill0830_5, border0830, line0830, text0830)

    if show0930 and new5_0930
        drawAnchor(a5_0930Time, a5_0930High, a5_0930Low, "09:30", "5m", fill0930_5, border0930, line0930, text0930)

    if show1000 and new5_1000
        drawAnchor(a5_1000Time, a5_1000High, a5_1000Low, "10:00", "5m", fill1000_5, border1000, line1000, text1000)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Execute 1-Minute Anchor Creation
// Drawn last so the original 1-minute range remains
// visible above larger overlapping source ranges.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if isAllowedTimeframe and show1MinuteAnchors
    if show1800 and new1_1800
        drawAnchor(a1_1800Time, a1_1800High, a1_1800Low, "18:00", "1m", fill1800_1, border1800, line1800, text1800)

    if show0000 and new1_0000
        drawAnchor(a1_0000Time, a1_0000High, a1_0000Low, "00:00", "1m", fill0000_1, border0000, line0000, text0000)

    if show0830 and new1_0830
        drawAnchor(a1_0830Time, a1_0830High, a1_0830Low, "08:30", "1m", fill0830_1, border0830, line0830, text0830)

    if show0930 and new1_0930
        drawAnchor(a1_0930Time, a1_0930High, a1_0930Low, "09:30", "1m", fill0930_1, border0930, line0930, text0930)

    if show1000 and new1_1000
        drawAnchor(a1_1000Time, a1_1000High, a1_1000Low, "10:00", "1m", fill1000_1, border1000, line1000, text1000)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Align Active-Session Boxes With Current Price
// Works with live charts and Bar Replay.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if isAllowedTimeframe and barstate.islast and array.size(anchorBoxes) > 0
    int activeSessionStart = getSessionStart(time)
    int dynamicRightTime = time + liveOffsetMs
    int dynamicLabelX = dynamicRightTime - labelOffsetMins * msInMinute
    int dynamicMidlineRightTime = dynamicLabelX - midlineTextGapMins * msInMinute

    for i = 0 to array.size(anchorBoxes) - 1
        int objectSession = array.get(anchorSessions, i)

        if objectSession == activeSessionStart
            box b = array.get(anchorBoxes, i)
            line ln = array.get(anchorLines, i)
            label lb = array.get(anchorLabels, i)

            box.set_right(b, dynamicRightTime)

            if not na(ln)
                line.set_x2(ln, dynamicMidlineRightTime)

            if not na(lb)
                label.set_x(lb, dynamicLabelX)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Timeframe Warning
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var label tfWarning = na

if not isAllowedTimeframe and barstate.islast
    label.delete(tfWarning)
    tfWarning := label.new(
         x=bar_index,
         y=high,
         text="P2P Time Matrix is available on seconds, minutes, and hourly charts only.",
         style=label.style_label_down,
         textcolor=color.white,
         color=color.red,
         size=size.small
     )

if isAllowedTimeframe and not na(tfWarning)
    label.delete(tfWarning)
    tfWarning := na
````
