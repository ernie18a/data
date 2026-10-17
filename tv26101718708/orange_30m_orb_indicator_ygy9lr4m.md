# Orange 30M ORB Indicator

- url: https://www.tradingview.com/script/ygy9lR4M-Orange-30M-ORB-Indicator/
- type: indicator
- pine_id: PUB;25054ce4ba7e43cc864cb05f5e68bb5b
- version: 1.0

## Description

This script is an advanced Opening Range Breakout (ORB) + Retest indicator designed to track institutional-style liquidity behavior across multiple sessions (New York, London, Asia).

At its core, it:

Builds opening ranges (high, low, and 50% midline) for each selected session based on a user-defined time window (e.g., first 30 minutes).
Monitors breakouts above or below those ranges using either candle closes or wicks.
Identifies valid retests of the breakout level using precise criteria:
Wick or proximity-based touch of the level
Controlled penetration into the range
Valid closing behavior relative to the level
Highlights the retest candle (purple by default) and the next confirmation candle (orange) for clear trade visualization.

A key feature of this version:

Once a session’s range is formed, it remains active for retests even after the session ends, allowing setups to develop naturally.
All prior session ranges are automatically reset at the next 9:30 AM New York open, ensuring only the most relevant liquidity zones are used going forward.

Additional capabilities include:

Multi-session tracking (NY, London, Asia)
Customizable retest logic (strict touch or distance-based)
Timeframe filtering for precision entries
Adjustable tolerance levels for wicks and closes
Optional historical plotting and labeling
Built-in alerts for retests and confirmation candles

Overall, this tool is built to help you systematically identify breakout–retest continuation setups with clarity and consistency, aligned with how price interacts with key session liquidity zones.

## Source Code

````pine
//@version=5
indicator("Orange 30M ORB Indicator", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

//──────────────────────────────────────────────────────────────────────────────
// General Inputs
//──────────────────────────────────────────────────────────────────────────────
grpGeneral = "General"
showBoxes         = input.bool(true, "Show opening range boxes", group=grpGeneral)
showMidline       = input.bool(true, "Show midline", group=grpGeneral)
showLabels        = input.bool(true, "Show session labels", group=grpGeneral)
showRetestLabels  = input.bool(true, "Show retest labels", group=grpGeneral)
historicalSession = input.bool(true, "Keep historical session drawings", group=grpGeneral)
breakoutByClose   = input.bool(true, "Breakout uses candle close", group=grpGeneral)

nyTZ = "America/New_York"

//──────────────────────────────────────────────────────────────────────────────
// Retest Inputs
//──────────────────────────────────────────────────────────────────────────────
grpRetest = "Retest Settings"
retestChartTF      = input.string("15", "Retest chart timeframe", options=["1", "5", "15"], group=grpRetest)
restrictRetestTF   = input.bool(true, "Restrict retest to selected chart timeframe", group=grpRetest)
maxRetestBars      = input.int(500, "Maximum bars from breakout to retest", minval=1, group=grpRetest)
wickIntoRangeMax   = input.float(10.0, "Max wick penetration into range points", minval=0.0, step=0.25, group=grpRetest)
closeIntoRangeMax  = input.float(5.0, "Max close penetration into range points", minval=0.0, step=0.25, group=grpRetest)

retestMode         = input.string("Touch or Within Distance", "Retest Qualification Mode", options=["Touch Only", "Touch or Within Distance"], group=grpRetest)
retestDistance     = input.float(5.0, "Retest distance from breakout level points", minval=0.0, step=0.25, group=grpRetest)

retestCandleColor  = input.color(color.purple, "Retest Candle Color", group=grpRetest)
nextCandleColor    = input.color(color.orange, "Next Candle After Retest Color", group=grpRetest)

//──────────────────────────────────────────────────────────────────────────────
// Session Inputs
//──────────────────────────────────────────────────────────────────────────────
grp1 = "Session 1"
s1Enabled = input.bool(true, "Enable Session 1", group=grp1)
s1Name    = input.string("New York", "Session Label", group=grp1)
s1Session = input.session("0930-1600", "Session Time NY Local", group=grp1)
s1ORMin   = input.int(30, "Opening Range Minutes", minval=1, group=grp1)
s1Color   = input.color(color.blue, "Session Color", group=grp1)

grp2 = "Session 2"
s2Enabled = input.bool(false, "Enable Session 2", group=grp2)
s2Name    = input.string("London", "Session Label", group=grp2)
s2Session = input.session("0300-1100", "Session Time NY Local", group=grp2)
s2ORMin   = input.int(30, "Opening Range Minutes", minval=1, group=grp2)
s2Color   = input.color(color.orange, "Session Color", group=grp2)

grp3 = "Session 3"
s3Enabled = input.bool(false, "Enable Session 3", group=grp3)
s3Name    = input.string("Asia", "Session Label", group=grp3)
s3Session = input.session("2000-0300", "Session Time NY Local", group=grp3)
s3ORMin   = input.int(30, "Opening Range Minutes", minval=1, group=grp3)
s3Color   = input.color(color.purple, "Session Color", group=grp3)

bg1 = color.new(s1Color, 88)
bg2 = color.new(s2Color, 88)
bg3 = color.new(s3Color, 88)

//──────────────────────────────────────────────────────────────────────────────
// Helpers
//──────────────────────────────────────────────────────────────────────────────
selectedTFMinutes = str.tonumber(retestChartTF)
isAllowedRetestTF = timeframe.isintraday and timeframe.multiplier == selectedTFMinutes
allowRetestNow    = restrictRetestTF ? isAllowedRetestTF : true
useDistanceMode   = retestMode == "Touch or Within Distance"

extendBoxToCurrentBar(_box) =>
    if not na(_box)
        box.set_right(_box, time_close)

bullCloseOk(level) =>
    close >= level - closeIntoRangeMax

bearCloseOk(level) =>
    close <= level + closeIntoRangeMax

bullRetestZoneOk(level) =>
    useDistanceMode ? low >= level - wickIntoRangeMax and low <= level + retestDistance : low >= level - wickIntoRangeMax and low <= level

bearRetestZoneOk(level) =>
    useDistanceMode ? high <= level + wickIntoRangeMax and high >= level - retestDistance : high <= level + wickIntoRangeMax and high >= level

clearObjects(_box, _midLine, _label) =>
    if not historicalSession
        if not na(_box)
            box.delete(_box)
        if not na(_midLine)
            line.delete(_midLine)
        if not na(_label)
            label.delete(_label)

//──────────────────────────────────────────────────────────────────────────────
// Session Detection
//──────────────────────────────────────────────────────────────────────────────
inS1 = s1Enabled and not na(time(timeframe.period, s1Session, nyTZ))
inS2 = s2Enabled and not na(time(timeframe.period, s2Session, nyTZ))
inS3 = s3Enabled and not na(time(timeframe.period, s3Session, nyTZ))

newS1 = inS1 and not inS1[1]
newS2 = inS2 and not inS2[1]
newS3 = inS3 and not inS3[1]

// This is the master reset point.
// When the new 9:30 AM New York ORB session begins, old ranges stop being valid.
ny930Start = not na(time(timeframe.period, "0930-0931", nyTZ))
newNY930   = ny930Start and not ny930Start[1]

//──────────────────────────────────────────────────────────────────────────────
// Session 1 State
//──────────────────────────────────────────────────────────────────────────────
var float s1High = na
var float s1Low = na
var float s1Mid = na
var int   s1StartTime = na
var bool  s1Finalized = false
var bool  s1BullBroken = false
var bool  s1BearBroken = false
var int   s1BullBreakBar = na
var int   s1BearBreakBar = na
var bool  s1ActiveRetestRange = false
var box   s1Box = na
var line  s1MidLine = na
var label s1Label = na

//──────────────────────────────────────────────────────────────────────────────
// Session 2 State
//──────────────────────────────────────────────────────────────────────────────
var float s2High = na
var float s2Low = na
var float s2Mid = na
var int   s2StartTime = na
var bool  s2Finalized = false
var bool  s2BullBroken = false
var bool  s2BearBroken = false
var int   s2BullBreakBar = na
var int   s2BearBreakBar = na
var bool  s2ActiveRetestRange = false
var box   s2Box = na
var line  s2MidLine = na
var label s2Label = na

//──────────────────────────────────────────────────────────────────────────────
// Session 3 State
//──────────────────────────────────────────────────────────────────────────────
var float s3High = na
var float s3Low = na
var float s3Mid = na
var int   s3StartTime = na
var bool  s3Finalized = false
var bool  s3BullBroken = false
var bool  s3BearBroken = false
var int   s3BullBreakBar = na
var int   s3BearBreakBar = na
var bool  s3ActiveRetestRange = false
var box   s3Box = na
var line  s3MidLine = na
var label s3Label = na

//──────────────────────────────────────────────────────────────────────────────
// Reset old active retest ranges at the new 9:30 AM ORB session
//──────────────────────────────────────────────────────────────────────────────
if newNY930
    s1ActiveRetestRange := false
    s2ActiveRetestRange := false
    s3ActiveRetestRange := false
    s1BullBroken := false
    s1BearBroken := false
    s2BullBroken := false
    s2BearBroken := false
    s3BullBroken := false
    s3BearBroken := false
    s1BullBreakBar := na
    s1BearBreakBar := na
    s2BullBreakBar := na
    s2BearBreakBar := na
    s3BullBreakBar := na
    s3BearBreakBar := na

//──────────────────────────────────────────────────────────────────────────────
// SESSION 1
//──────────────────────────────────────────────────────────────────────────────
if newS1
    clearObjects(s1Box, s1MidLine, s1Label)
    s1High := high
    s1Low := low
    s1Mid := (s1High + s1Low) / 2.0
    s1StartTime := time
    s1Finalized := false
    s1BullBroken := false
    s1BearBroken := false
    s1BullBreakBar := na
    s1BearBreakBar := na
    s1ActiveRetestRange := false

    if showBoxes
        s1Box := box.new(left=time, top=high, right=time_close, bottom=low, xloc=xloc.bar_time, bgcolor=bg1, border_color=s1Color)
    if showMidline
        s1MidLine := line.new(x1=time, y1=s1Mid, x2=time_close, y2=s1Mid, xloc=xloc.bar_time, extend=extend.none, color=s1Color, style=line.style_dashed)
    if showLabels
        s1Label := label.new(x=time, y=high, text=s1Name, xloc=xloc.bar_time, style=label.style_label_down, textcolor=color.white, color=s1Color)

s1OREnd = na(s1StartTime) ? na : s1StartTime + s1ORMin * 60 * 1000

if inS1 and not na(s1StartTime)
    if not s1Finalized
        if time < s1OREnd
            s1High := math.max(s1High, high)
            s1Low := math.min(s1Low, low)
            s1Mid := (s1High + s1Low) / 2.0

            if showBoxes and not na(s1Box)
                box.set_top(s1Box, s1High)
                box.set_bottom(s1Box, s1Low)
                box.set_right(s1Box, time_close)

            if showMidline and not na(s1MidLine)
                line.set_y1(s1MidLine, s1Mid)
                line.set_y2(s1MidLine, s1Mid)
                line.set_x2(s1MidLine, time_close)

            if showLabels and not na(s1Label)
                label.set_x(s1Label, time)
                label.set_y(s1Label, s1High)
        else
            s1Finalized := true
            s1ActiveRetestRange := true

if s1Finalized and s1ActiveRetestRange
    if showBoxes
        extendBoxToCurrentBar(s1Box)
    if showMidline and not na(s1MidLine)
        line.set_x2(s1MidLine, time_close)

s1BreakUpSrc = breakoutByClose ? close > s1High : high > s1High
s1BreakDnSrc = breakoutByClose ? close < s1Low : low < s1Low

s1BullBreak = s1ActiveRetestRange and s1Finalized and not s1BullBroken and s1BreakUpSrc
s1BearBreak = s1ActiveRetestRange and s1Finalized and not s1BearBroken and s1BreakDnSrc

if s1BullBreak
    s1BullBroken := true
    s1BullBreakBar := bar_index

if s1BearBreak
    s1BearBroken := true
    s1BearBreakBar := bar_index

s1BullRetestZone = bullRetestZoneOk(s1High)
s1BullCloseValid = bullCloseOk(s1High)
s1BearRetestZone = bearRetestZoneOk(s1Low)
s1BearCloseValid = bearCloseOk(s1Low)

s1BullRetest = s1ActiveRetestRange and allowRetestNow and s1BullBroken and not na(s1BullBreakBar) and bar_index > s1BullBreakBar and bar_index - s1BullBreakBar <= maxRetestBars and s1BullRetestZone and s1BullCloseValid
s1BearRetest = s1ActiveRetestRange and allowRetestNow and s1BearBroken and not na(s1BearBreakBar) and bar_index > s1BearBreakBar and bar_index - s1BearBreakBar <= maxRetestBars and s1BearRetestZone and s1BearCloseValid

//──────────────────────────────────────────────────────────────────────────────
// SESSION 2
//──────────────────────────────────────────────────────────────────────────────
if newS2
    clearObjects(s2Box, s2MidLine, s2Label)
    s2High := high
    s2Low := low
    s2Mid := (s2High + s2Low) / 2.0
    s2StartTime := time
    s2Finalized := false
    s2BullBroken := false
    s2BearBroken := false
    s2BullBreakBar := na
    s2BearBreakBar := na
    s2ActiveRetestRange := false

    if showBoxes
        s2Box := box.new(left=time, top=high, right=time_close, bottom=low, xloc=xloc.bar_time, bgcolor=bg2, border_color=s2Color)
    if showMidline
        s2MidLine := line.new(x1=time, y1=s2Mid, x2=time_close, y2=s2Mid, xloc=xloc.bar_time, extend=extend.none, color=s2Color, style=line.style_dashed)
    if showLabels
        s2Label := label.new(x=time, y=high, text=s2Name, xloc=xloc.bar_time, style=label.style_label_down, textcolor=color.white, color=s2Color)

s2OREnd = na(s2StartTime) ? na : s2StartTime + s2ORMin * 60 * 1000

if inS2 and not na(s2StartTime)
    if not s2Finalized
        if time < s2OREnd
            s2High := math.max(s2High, high)
            s2Low := math.min(s2Low, low)
            s2Mid := (s2High + s2Low) / 2.0

            if showBoxes and not na(s2Box)
                box.set_top(s2Box, s2High)
                box.set_bottom(s2Box, s2Low)
                box.set_right(s2Box, time_close)

            if showMidline and not na(s2MidLine)
                line.set_y1(s2MidLine, s2Mid)
                line.set_y2(s2MidLine, s2Mid)
                line.set_x2(s2MidLine, time_close)

            if showLabels and not na(s2Label)
                label.set_x(s2Label, time)
                label.set_y(s2Label, s2High)
        else
            s2Finalized := true
            s2ActiveRetestRange := true

if s2Finalized and s2ActiveRetestRange
    if showBoxes
        extendBoxToCurrentBar(s2Box)
    if showMidline and not na(s2MidLine)
        line.set_x2(s2MidLine, time_close)

s2BreakUpSrc = breakoutByClose ? close > s2High : high > s2High
s2BreakDnSrc = breakoutByClose ? close < s2Low : low < s2Low

s2BullBreak = s2ActiveRetestRange and s2Finalized and not s2BullBroken and s2BreakUpSrc
s2BearBreak = s2ActiveRetestRange and s2Finalized and not s2BearBroken and s2BreakDnSrc

if s2BullBreak
    s2BullBroken := true
    s2BullBreakBar := bar_index

if s2BearBreak
    s2BearBroken := true
    s2BearBreakBar := bar_index

s2BullRetestZone = bullRetestZoneOk(s2High)
s2BullCloseValid = bullCloseOk(s2High)
s2BearRetestZone = bearRetestZoneOk(s2Low)
s2BearCloseValid = bearCloseOk(s2Low)

s2BullRetest = s2ActiveRetestRange and allowRetestNow and s2BullBroken and not na(s2BullBreakBar) and bar_index > s2BullBreakBar and bar_index - s2BullBreakBar <= maxRetestBars and s2BullRetestZone and s2BullCloseValid
s2BearRetest = s2ActiveRetestRange and allowRetestNow and s2BearBroken and not na(s2BearBreakBar) and bar_index > s2BearBreakBar and bar_index - s2BearBreakBar <= maxRetestBars and s2BearRetestZone and s2BearCloseValid

//──────────────────────────────────────────────────────────────────────────────
// SESSION 3
//──────────────────────────────────────────────────────────────────────────────
if newS3
    clearObjects(s3Box, s3MidLine, s3Label)
    s3High := high
    s3Low := low
    s3Mid := (s3High + s3Low) / 2.0
    s3StartTime := time
    s3Finalized := false
    s3BullBroken := false
    s3BearBroken := false
    s3BullBreakBar := na
    s3BearBreakBar := na
    s3ActiveRetestRange := false

    if showBoxes
        s3Box := box.new(left=time, top=high, right=time_close, bottom=low, xloc=xloc.bar_time, bgcolor=bg3, border_color=s3Color)
    if showMidline
        s3MidLine := line.new(x1=time, y1=s3Mid, x2=time_close, y2=s3Mid, xloc=xloc.bar_time, extend=extend.none, color=s3Color, style=line.style_dashed)
    if showLabels
        s3Label := label.new(x=time, y=high, text=s3Name, xloc=xloc.bar_time, style=label.style_label_down, textcolor=color.white, color=s3Color)

s3OREnd = na(s3StartTime) ? na : s3StartTime + s3ORMin * 60 * 1000

if inS3 and not na(s3StartTime)
    if not s3Finalized
        if time < s3OREnd
            s3High := math.max(s3High, high)
            s3Low := math.min(s3Low, low)
            s3Mid := (s3High + s3Low) / 2.0

            if showBoxes and not na(s3Box)
                box.set_top(s3Box, s3High)
                box.set_bottom(s3Box, s3Low)
                box.set_right(s3Box, time_close)

            if showMidline and not na(s3MidLine)
                line.set_y1(s3MidLine, s3Mid)
                line.set_y2(s3MidLine, s3Mid)
                line.set_x2(s3MidLine, time_close)

            if showLabels and not na(s3Label)
                label.set_x(s3Label, time)
                label.set_y(s3Label, s3High)
        else
            s3Finalized := true
            s3ActiveRetestRange := true

if s3Finalized and s3ActiveRetestRange
    if showBoxes
        extendBoxToCurrentBar(s3Box)
    if showMidline and not na(s3MidLine)
        line.set_x2(s3MidLine, time_close)

s3BreakUpSrc = breakoutByClose ? close > s3High : high > s3High
s3BreakDnSrc = breakoutByClose ? close < s3Low : low < s3Low

s3BullBreak = s3ActiveRetestRange and s3Finalized and not s3BullBroken and s3BreakUpSrc
s3BearBreak = s3ActiveRetestRange and s3Finalized and not s3BearBroken and s3BreakDnSrc

if s3BullBreak
    s3BullBroken := true
    s3BullBreakBar := bar_index

if s3BearBreak
    s3BearBroken := true
    s3BearBreakBar := bar_index

s3BullRetestZone = bullRetestZoneOk(s3High)
s3BullCloseValid = bullCloseOk(s3High)
s3BearRetestZone = bearRetestZoneOk(s3Low)
s3BearCloseValid = bearCloseOk(s3Low)

s3BullRetest = s3ActiveRetestRange and allowRetestNow and s3BullBroken and not na(s3BullBreakBar) and bar_index > s3BullBreakBar and bar_index - s3BullBreakBar <= maxRetestBars and s3BullRetestZone and s3BullCloseValid
s3BearRetest = s3ActiveRetestRange and allowRetestNow and s3BearBroken and not na(s3BearBreakBar) and bar_index > s3BearBreakBar and bar_index - s3BearBreakBar <= maxRetestBars and s3BearRetestZone and s3BearCloseValid

//──────────────────────────────────────────────────────────────────────────────
// Combined Retest States
//──────────────────────────────────────────────────────────────────────────────
anyBullRetest = s1BullRetest or s2BullRetest or s3BullRetest
anyBearRetest = s1BearRetest or s2BearRetest or s3BearRetest
anyRetest     = anyBullRetest or anyBearRetest

paintNextBull = anyBullRetest[1]
paintNextBear = anyBearRetest[1]
paintNext     = paintNextBull or paintNextBear

//──────────────────────────────────────────────────────────────────────────────
// Visual Markers
//──────────────────────────────────────────────────────────────────────────────
plotshape(showRetestLabels and s1BullRetest, title="S1 Bull Retest", location=location.abovebar, style=shape.circle, size=size.tiny, color=s1Color, text="S1 RT")
plotshape(showRetestLabels and s1BearRetest, title="S1 Bear Retest", location=location.belowbar, style=shape.circle, size=size.tiny, color=s1Color, text="S1 RT")

plotshape(showRetestLabels and s2BullRetest, title="S2 Bull Retest", location=location.abovebar, style=shape.circle, size=size.tiny, color=s2Color, text="S2 RT")
plotshape(showRetestLabels and s2BearRetest, title="S2 Bear Retest", location=location.belowbar, style=shape.circle, size=size.tiny, color=s2Color, text="S2 RT")

plotshape(showRetestLabels and s3BullRetest, title="S3 Bull Retest", location=location.abovebar, style=shape.circle, size=size.tiny, color=s3Color, text="S3 RT")
plotshape(showRetestLabels and s3BearRetest, title="S3 Bear Retest", location=location.belowbar, style=shape.circle, size=size.tiny, color=s3Color, text="S3 RT")

//──────────────────────────────────────────────────────────────────────────────
// Candle Coloring
//──────────────────────────────────────────────────────────────────────────────
candlePaint = anyRetest ? retestCandleColor : paintNext ? nextCandleColor : na

barcolor(candlePaint)
plotcandle(open, high, low, close, title="Retest Candle Overlay", color=candlePaint, wickcolor=candlePaint, bordercolor=candlePaint)

//──────────────────────────────────────────────────────────────────────────────
// Alerts
//──────────────────────────────────────────────────────────────────────────────
alertcondition(s1BullRetest, title="Session 1 Bull Retest", message="Session 1 bullish retest")
alertcondition(s1BearRetest, title="Session 1 Bear Retest", message="Session 1 bearish retest")
alertcondition(s2BullRetest, title="Session 2 Bull Retest", message="Session 2 bullish retest")
alertcondition(s2BearRetest, title="Session 2 Bear Retest", message="Session 2 bearish retest")
alertcondition(s3BullRetest, title="Session 3 Bull Retest", message="Session 3 bullish retest")
alertcondition(s3BearRetest, title="Session 3 Bear Retest", message="Session 3 bearish retest")

alertcondition(paintNextBull, title="Bullish Next Candle After Retest", message="Immediate next candle after bullish retest")
alertcondition(paintNextBear, title="Bearish Next Candle After Retest", message="Immediate next candle after bearish retest")
````
