# FlowScope Range Edge v1.0

- url: https://www.tradingview.com/script/d49aEih5-FlowScope-Range-Edge-v1-0/
- type: indicator
- pine_id: PUB;3e8c0feb972a42bb951d6ac883eb0acb
- version: 2.0

## Description

What This Indicator Shows

The indicator automatically builds a rolling intraday range and displays:

New York open vertical line
Active NY session range high
Active NY session range low
Range midpoint
Adaptive upper and lower edge zones
Range box shading
Reversal confirmation markers
Breakout and retest markers
Long and short trigger triangles
Relative volume context
Chop-risk logic
Compact dashboard showing the current range state
Main Concept

At the upper range edge, price can either:

Reject and rotate lower, creating a possible short reversal setup.
Break above, hold outside the range, retest, and continue higher.

At the lower range edge, price can either:

Reject and rotate higher, creating a possible long reversal setup.
Break below, hold outside the range, retest, and continue lower.

Range Edge Reversal

A range edge reversal happens when price tests or briefly pushes through a range edge, then closes back inside the range.

For a bullish reversal:

Price tests the lower range edge.
Sellers fail to continue lower.
Price closes back inside the range with bullish confirmation.
A long trigger appears if price breaks above the confirmation candle.

For a bearish reversal:

Price tests the upper range edge.
Buyers fail to continue higher.
Price closes back inside the range with bearish confirmation.
A short trigger appears if price breaks below the confirmation candle.

These trades typically look for rotation back toward the range midpoint, VWAP area, or the opposite side of the range.

Range Breakout Continuation

A range breakout continuation happens when price closes outside the range, holds beyond the edge, retests the broken range boundary, and then continues.

For a bullish continuation:

Price closes above the range high.
Price holds outside the range.
Price retests the upper edge from above.
A long trigger appears after the retest confirms.

For a bearish continuation:

Price closes below the range low.
Price holds outside the range.
Price retests the lower edge from below.
A short trigger appears after the retest confirms.

Marker Meanings

REV = Range edge rejection/reversal confirmation
Price tested a range edge and closed back inside.

BR = Range breakout
Price closed outside the range.

RT = Breakout retest
Price retested the broken range edge and held outside.

Green triangle = Long trigger
A bullish reversal or continuation trigger has appeared.

Red triangle = Short trigger
A bearish reversal or continuation trigger has appeared.

Dashboard States

The dashboard summarizes current range behavior:

WAITING — No active range-edge condition.
EDGE WATCH — Price is near the upper or lower edge.
REV LONG — Lower-edge reversal setup is active.
REV SHORT — Upper-edge reversal setup is active.
BREAK LONG — Bullish breakout continuation is developing.
BREAK SHORT — Bearish breakout continuation is developing.
LONG TRIGGER — Long trigger has fired.
SHORT TRIGGER — Short trigger has fired.
CHOP RISK — Two-sided range breaks suggest messy conditions.
OFF SESSION — Outside the New York active session.

For continuation trades, elevated volume can help confirm that the breakout has participation behind it. For reversal trades, volume can help show whether the edge test had enough activity to matter.

Best Used For

5-minute charts
New York cash session
Rotational or range-bound market conditions
Failed breakout or range expansion decisions

Important Notes

The strongest setups usually occur when:

The range is clearly defined.
Price reaches a true range edge, not the middle.
There is enough room to target at least 1.5R–2R.
The trigger does not appear directly into a major opposing level.
The market is not in a strong one-directional trend.

## Source Code

````pine
//@version=6
indicator("FlowScope Range Edge Manual — MNQ v1.2", overlay=true, max_lines_count=500, max_labels_count=100, max_boxes_count=50)

//====================================================
// FlowScope Range Edge Manual — MNQ v1.2
// Purpose: Semi-discretionary range box + mechanical edge logic.
// Designed for: MNQ1! / NQ1!, 5-minute chart, NY cash session.
// Core idea: Trader defines the range high/low. Indicator handles edge rejection and breakout continuation logic.
//====================================================

//========================
// Inputs
//========================
groupSession = "Session"
tzInput       = input.string("America/New_York", "Session Timezone", group=groupSession)
activeSession = input.session("0930-1700", "Active NY Session", group=groupSession)
showOpenLine  = input.bool(true, "Show NY Open Vertical Line", group=groupSession)

// Manual range settings
groupRange = "Manual Range"
useManualRange    = input.bool(true, "Use Manual Range", group=groupRange)
manualRangeHigh   = input.float(30000.0, "Manual Range High", step=0.25, group=groupRange)
manualRangeLow    = input.float(29920.0, "Manual Range Low", step=0.25, group=groupRange)
showRangeBox      = input.bool(true, "Show Range Box", group=groupRange)
showRangeMid      = input.bool(true, "Show Range Midpoint", group=groupRange)
showEdgeZones     = input.bool(true, "Show Edge Zones", group=groupRange)
extendRangeRight  = input.bool(true, "Extend Manual Range Right", group=groupRange)

// Auto fallback, optional
useAutoFallback   = input.bool(false, "Use Auto Fallback If Manual Off", group=groupRange)
autoLookbackBars  = input.int(24, "Auto Lookback Bars", minval=10, maxval=150, group=groupRange)
minRangePts       = input.float(35.0, "Minimum Range Size Points", minval=1.0, step=1.0, group=groupRange)
maxRangePts       = input.float(140.0, "Maximum Range Size Points", minval=5.0, step=5.0, group=groupRange)

// MNQ edge logic settings
groupLogic = "Range Edge Logic"
atrLen             = input.int(14, "ATR Length", minval=1, group=groupLogic)
edgeZoneAtrMult    = input.float(0.20, "Edge Zone = ATR ×", minval=0.01, step=0.01, group=groupLogic)
minEdgeZonePts     = input.float(5.0, "Minimum Edge Zone Points", minval=0.25, step=0.25, group=groupLogic)
maxEdgeZonePts     = input.float(18.0, "Maximum Edge Zone Points", minval=0.25, step=0.25, group=groupLogic)
breakoutBufferPts  = input.float(8.0, "Breakout Acceptance Buffer Points", minval=0.25, step=0.25, group=groupLogic)
holdBars           = input.int(2, "Breakout Hold Bars", minval=1, maxval=5, group=groupLogic)
retestTimeoutBars  = input.int(8, "Breakout Retest Timeout Bars", minval=2, maxval=30, group=groupLogic)
stopBufferPts      = input.float(3.0, "Suggested Stop Buffer Points", minval=0.25, step=0.25, group=groupLogic)

// Volume settings
groupVol = "Volume Context"
showVolumeContext = input.bool(true, "Show Volume Context", group=groupVol)
volLen      = input.int(20, "Relative Volume Length", minval=1, group=groupVol)
weakVol     = input.float(0.80, "Weak Volume Threshold", minval=0.1, step=0.05, group=groupVol)
elevatedVol = input.float(1.20, "Elevated Volume Threshold", minval=0.1, step=0.05, group=groupVol)
strongVol   = input.float(1.80, "Strong Volume Threshold", minval=0.1, step=0.05, group=groupVol)
requireVolForContinuation = input.bool(false, "Require Elevated Volume For Continuation", group=groupVol)

// Chop settings
groupChop = "Chop / No-Trade"
midChopLookbackBars   = input.int(20, "Midpoint Cross Lookback", minval=5, maxval=100, group=groupChop)
midChopCrossThreshold = input.int(4, "Chop Warning Mid Cross Count", minval=2, maxval=20, group=groupChop)
showChopWarnings      = input.bool(false, "Show Chop Warning Diamonds", group=groupChop)

// Visual settings
groupVisual = "Visuals"
showReversalMarks = input.bool(true, "Show Reversal Confirmation Dots", group=groupVisual)
showBreakMarks    = input.bool(true, "Show Breakout / Retest Dots", group=groupVisual)
showTriggerMarks  = input.bool(true, "Show Trigger Triangles", group=groupVisual)
showLevelLabels   = input.bool(false, "Show Range Level Labels", group=groupVisual)

bullColor     = input.color(color.rgb(0, 190, 120), "Bull Color", group=groupVisual)
bearColor     = input.color(color.rgb(220, 70, 70), "Bear Color", group=groupVisual)
neutralColor  = input.color(color.rgb(150, 150, 150), "Neutral Color", group=groupVisual)
warnColor     = input.color(color.rgb(235, 175, 55), "Warning Color", group=groupVisual)
confirmColor  = input.color(color.rgb(80, 160, 255), "Confirmation Marker Color", group=groupVisual)
openLineColor = input.color(color.rgb(0, 190, 120), "NY Open Line Color", group=groupVisual)

// Dashboard settings
groupDash = "Dashboard"
showDash = input.bool(true, "Show Dashboard", group=groupDash)
dashPos  = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupDash)
dashSize = input.string("Small", "Dashboard Text Size", options=["Tiny", "Small", "Normal"], group=groupDash)

//========================
// Helpers
//========================
f_clamp(x, lo, hi) => math.min(math.max(x, lo), hi)

f_table_pos(pos) =>
    switch pos
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_text_size(sz) =>
    switch sz
        "Tiny" => size.tiny
        "Normal" => size.normal
        => size.small

f_state_color(state) =>
    state == "REV LONG" or state == "BREAK LONG" or state == "LONG TRIGGER" ? bullColor :
     state == "REV SHORT" or state == "BREAK SHORT" or state == "SHORT TRIGGER" ? bearColor :
     state == "EDGE WATCH" or state == "BREAK WATCH" or state == "CHOP RISK" ? warnColor :
     neutralColor

//========================
// Sessions
//========================
inNY    = not na(time(timeframe.period, activeSession, tzInput))
startNY = inNY and not inNY[1]

var array<line> openLines = array.new<line>()
if startNY and showOpenLine
    nyLine = line.new(x1=bar_index, y1=low, x2=bar_index, y2=high, extend=extend.both, color=color.new(openLineColor, 0), style=line.style_dashed, width=1)
    array.push(openLines, nyLine)
    if array.size(openLines) > 100
        line.delete(array.shift(openLines))

//========================
// Core calculations
//========================
atr = ta.atr(atrLen)
edgeZonePts = f_clamp(atr * edgeZoneAtrMult, minEdgeZonePts, maxEdgeZonePts)

volAvg = ta.sma(volume, volLen)
rvol = volAvg > 0 ? volume / volAvg : na
volState = na(rvol) ? "N/A" : rvol < weakVol ? "Weak" : rvol < elevatedVol ? "Normal" : rvol < strongVol ? "Elevated" : "Strong"
volOKContinuation = not requireVolForContinuation or rvol >= elevatedVol

manualHigh = math.max(manualRangeHigh, manualRangeLow)
manualLow  = math.min(manualRangeHigh, manualRangeLow)

autoHigh = ta.highest(high[1], autoLookbackBars)
autoLow  = ta.lowest(low[1], autoLookbackBars)
autoSize = autoHigh - autoLow
autoValid = useAutoFallback and autoSize >= minRangePts and autoSize <= maxRangePts

rangeHigh = useManualRange ? manualHigh : autoValid ? autoHigh : na
rangeLow  = useManualRange ? manualLow : autoValid ? autoLow : na
rangeMid  = (rangeHigh + rangeLow) / 2.0
rangeSize = rangeHigh - rangeLow
rangeValid = inNY and not na(rangeHigh) and not na(rangeLow) and rangeHigh > rangeLow and rangeSize >= minRangePts and rangeSize <= maxRangePts

upperZoneTop = rangeHigh + edgeZonePts
upperZoneBot = rangeHigh - edgeZonePts
lowerZoneTop = rangeLow + edgeZonePts
lowerZoneBot = rangeLow - edgeZonePts

nearUpper = rangeValid and high >= upperZoneBot and low <= upperZoneTop
nearLower = rangeValid and high >= lowerZoneBot and low <= lowerZoneTop
insideRange = rangeValid and close <= rangeHigh and close >= rangeLow
aboveRange = rangeValid and close > rangeHigh
belowRange = rangeValid and close < rangeLow
middleOfRange = rangeValid and not nearUpper and not nearLower and insideRange

locationText = nearUpper ? "Upper Edge" : nearLower ? "Lower Edge" : middleOfRange ? "Middle" : aboveRange ? "Above Range" : belowRange ? "Below Range" : "N/A"
rangeModeText = useManualRange ? "Manual" : autoValid ? "Auto" : "None"

// Chop detection through midpoint rotation.
midCross = inNY and rangeValid and ta.cross(close, rangeMid)
midCrossCount = math.sum(midCross ? 1 : 0, midChopLookbackBars)
chopRisk = inNY and rangeValid and midCrossCount >= midChopCrossThreshold
newChopRisk = chopRisk and not chopRisk[1]

//========================
// Range Edge Reversal Logic
//========================
// Long reversal: lower edge test/rejection back inside range.
longReversalConfirm = rangeValid and nearLower and low <= rangeLow and close > rangeLow and close > open
// Short reversal: upper edge test/rejection back inside range.
shortReversalConfirm = rangeValid and nearUpper and high >= rangeHigh and close < rangeHigh and close < open

var bool longRevReady = false
var bool shortRevReady = false
var float longRevHigh = na
var float longRevLow = na
var float shortRevHigh = na
var float shortRevLow = na

if longReversalConfirm
    longRevReady := true
    shortRevReady := false
    longRevHigh := high
    longRevLow := low

if shortReversalConfirm
    shortRevReady := true
    longRevReady := false
    shortRevHigh := high
    shortRevLow := low

longReversalTrigger = inNY and longRevReady[1] and high > nz(longRevHigh[1])
shortReversalTrigger = inNY and shortRevReady[1] and low < nz(shortRevLow[1])

if longReversalTrigger
    longRevReady := false
if shortReversalTrigger
    shortRevReady := false

//========================
// Range Breakout Continuation Logic
//========================
var bool upBreakActive = false
var bool downBreakActive = false
var bool upHoldReady = false
var bool downHoldReady = false
var int upBreakBar = na
var int downBreakBar = na
var float upRetestHigh = na
var float upRetestLow = na
var float downRetestHigh = na
var float downRetestLow = na
var bool upRetestReady = false
var bool downRetestReady = false

newUpBreak = rangeValid and close > rangeHigh + breakoutBufferPts and close[1] <= rangeHigh + breakoutBufferPts
newDownBreak = rangeValid and close < rangeLow - breakoutBufferPts and close[1] >= rangeLow - breakoutBufferPts

if newUpBreak
    upBreakActive := true
    downBreakActive := false
    upHoldReady := false
    downHoldReady := false
    upRetestReady := false
    downRetestReady := false
    upBreakBar := bar_index
    upRetestHigh := na
    upRetestLow := na

if newDownBreak
    downBreakActive := true
    upBreakActive := false
    downHoldReady := false
    upHoldReady := false
    downRetestReady := false
    upRetestReady := false
    downBreakBar := bar_index
    downRetestHigh := na
    downRetestLow := na

upHold = upBreakActive and ta.lowest(close, holdBars) > rangeHigh
downHold = downBreakActive and ta.highest(close, holdBars) < rangeLow

if upHold
    upHoldReady := true
if downHold
    downHoldReady := true

upRetestConfirm = rangeValid and upHoldReady and low <= upperZoneTop and high >= upperZoneBot and close > rangeHigh and close > open
downRetestConfirm = rangeValid and downHoldReady and high >= lowerZoneBot and low <= lowerZoneTop and close < rangeLow and close < open

if upRetestConfirm
    upRetestHigh := high
    upRetestLow := low
    upRetestReady := true

if downRetestConfirm
    downRetestHigh := high
    downRetestLow := low
    downRetestReady := true

if upBreakActive and bar_index - nz(upBreakBar, bar_index) > retestTimeoutBars and not upRetestReady
    upBreakActive := false
    upHoldReady := false

if downBreakActive and bar_index - nz(downBreakBar, bar_index) > retestTimeoutBars and not downRetestReady
    downBreakActive := false
    downHoldReady := false

longContinuationTrigger = inNY and upRetestReady[1] and high > nz(upRetestHigh[1]) and volOKContinuation
shortContinuationTrigger = inNY and downRetestReady[1] and low < nz(downRetestLow[1]) and volOKContinuation

if longContinuationTrigger
    upBreakActive := false
    upHoldReady := false
    upRetestReady := false
    upRetestHigh := na
    upRetestLow := na

if shortContinuationTrigger
    downBreakActive := false
    downHoldReady := false
    downRetestReady := false
    downRetestHigh := na
    downRetestLow := na

//========================
// Room / risk context
//========================
longRevStop = not na(longRevLow) ? longRevLow - stopBufferPts : na
shortRevStop = not na(shortRevHigh) ? shortRevHigh + stopBufferPts : na
longRevRisk = not na(longRevHigh) and not na(longRevStop) ? longRevHigh - longRevStop : na
shortRevRisk = not na(shortRevLow) and not na(shortRevStop) ? shortRevStop - shortRevLow : na
longRoomToMid = not na(longRevRisk) and longRevRisk > 0 ? (rangeMid - longRevHigh) / longRevRisk : na
shortRoomToMid = not na(shortRevRisk) and shortRevRisk > 0 ? (shortRevLow - rangeMid) / shortRevRisk : na
roomText = longRevReady ? (longRoomToMid >= 1.0 ? "Mid Clear" : "Mid Tight") :
     shortRevReady ? (shortRoomToMid >= 1.0 ? "Mid Clear" : "Mid Tight") :
     upHoldReady or downHoldReady ? "Check 2R" :
     middleOfRange ? "Middle" : "N/A"

//========================
// Plots
//========================
plotVisible = inNY and rangeValid

pHigh = plot(showRangeBox and plotVisible ? rangeHigh : na, "Range High", color=color.new(bullColor, 0), linewidth=2, style=plot.style_linebr)
pLow  = plot(showRangeBox and plotVisible ? rangeLow : na, "Range Low", color=color.new(bearColor, 0), linewidth=2, style=plot.style_linebr)
pMid  = plot(showRangeMid and plotVisible ? rangeMid : na, "Range Mid", color=color.new(neutralColor, 35), linewidth=1, style=plot.style_linebr)

pUpperTop = plot(showEdgeZones and plotVisible ? upperZoneTop : na, "Upper Edge Zone Top", color=color.new(bullColor, 85), style=plot.style_linebr)
pUpperBot = plot(showEdgeZones and plotVisible ? upperZoneBot : na, "Upper Edge Zone Bottom", color=color.new(bullColor, 85), style=plot.style_linebr)
pLowerTop = plot(showEdgeZones and plotVisible ? lowerZoneTop : na, "Lower Edge Zone Top", color=color.new(bearColor, 85), style=plot.style_linebr)
pLowerBot = plot(showEdgeZones and plotVisible ? lowerZoneBot : na, "Lower Edge Zone Bottom", color=color.new(bearColor, 85), style=plot.style_linebr)

fill(pHigh, pLow, color=showRangeBox and plotVisible ? color.new(neutralColor, 94) : na, title="Manual Range Box")
fill(pUpperTop, pUpperBot, color=showEdgeZones and plotVisible ? color.new(bullColor, 92) : na, title="Upper Edge Zone")
fill(pLowerTop, pLowerBot, color=showEdgeZones and plotVisible ? color.new(bearColor, 92) : na, title="Lower Edge Zone")

// Optional right-side labels.
var label highLabel = na
var label lowLabel = na
var label midLabel = na
if barstate.islast and showLevelLabels
    label.delete(highLabel)
    label.delete(lowLabel)
    label.delete(midLabel)
    highLabel := label.new(bar_index, rangeHigh, "RH", style=label.style_label_left, textcolor=color.white, color=color.new(bullColor, 25), size=size.tiny)
    lowLabel := label.new(bar_index, rangeLow, "RL", style=label.style_label_left, textcolor=color.white, color=color.new(bearColor, 25), size=size.tiny)
    if showRangeMid
        midLabel := label.new(bar_index, rangeMid, "MID", style=label.style_label_left, textcolor=color.white, color=color.new(neutralColor, 35), size=size.tiny)

// Markers.
plotshape(showReversalMarks and longReversalConfirm, title="Lower Edge Reversal Confirm", style=shape.circle, location=location.abovebar, color=color.new(confirmColor, 0), size=size.tiny)
plotshape(showReversalMarks and shortReversalConfirm, title="Upper Edge Reversal Confirm", style=shape.circle, location=location.belowbar, color=color.new(confirmColor, 0), size=size.tiny)

plotshape(showBreakMarks and newUpBreak, title="Range Break Up", style=shape.circle, location=location.abovebar, color=color.new(warnColor, 0), size=size.tiny, text="BR")
plotshape(showBreakMarks and newDownBreak, title="Range Break Down", style=shape.circle, location=location.belowbar, color=color.new(warnColor, 0), size=size.tiny, text="BR")
plotshape(showBreakMarks and upRetestConfirm, title="Bullish Break Retest", style=shape.circle, location=location.abovebar, color=color.new(bullColor, 0), size=size.tiny)
plotshape(showBreakMarks and downRetestConfirm, title="Bearish Break Retest", style=shape.circle, location=location.belowbar, color=color.new(bearColor, 0), size=size.tiny)

plotshape(showTriggerMarks and longReversalTrigger, title="Long Range Reversal Trigger", style=shape.triangleup, location=location.belowbar, color=color.new(bullColor, 0), size=size.normal)
plotshape(showTriggerMarks and shortReversalTrigger, title="Short Range Reversal Trigger", style=shape.triangledown, location=location.abovebar, color=color.new(bearColor, 0), size=size.normal)
plotshape(showTriggerMarks and longContinuationTrigger, title="Long Range Break Continuation Trigger", style=shape.triangleup, location=location.belowbar, color=color.new(bullColor, 0), size=size.normal)
plotshape(showTriggerMarks and shortContinuationTrigger, title="Short Range Break Continuation Trigger", style=shape.triangledown, location=location.abovebar, color=color.new(bearColor, 0), size=size.normal)
plotshape(showChopWarnings and newChopRisk, title="Range Chop Risk", style=shape.diamond, location=location.abovebar, color=color.new(warnColor, 0), size=size.tiny, text="CHOP")

//========================
// Dashboard
//========================
modeText = longRevReady or shortRevReady ? "Reversal" : upHoldReady or downHoldReady ? "Continuation" : middleOfRange ? "No Trade" : nearUpper or nearLower ? "Edge Watch" : "Wait"
edgeText = longReversalConfirm ? "Lower Reject" : shortReversalConfirm ? "Upper Reject" : newUpBreak ? "Break Up" : newDownBreak ? "Break Down" : upRetestConfirm or downRetestConfirm ? "Retest Hold" : nearUpper ? "Test Upper" : nearLower ? "Test Lower" : middleOfRange ? "Middle" : "None"

stateText = longReversalTrigger or longContinuationTrigger ? "LONG TRIGGER" :
     shortReversalTrigger or shortContinuationTrigger ? "SHORT TRIGGER" :
     longRevReady ? "REV LONG" :
     shortRevReady ? "REV SHORT" :
     upHoldReady ? "BREAK LONG" :
     downHoldReady ? "BREAK SHORT" :
     chopRisk ? "CHOP RISK" :
     nearUpper or nearLower ? "EDGE WATCH" :
     newUpBreak or newDownBreak ? "BREAK WATCH" :
     middleOfRange ? "MIDDLE" :
     inNY ? "WAITING" : "OFF SESSION"

actionText = longReversalTrigger ? "Long Trigger" :
     shortReversalTrigger ? "Short Trigger" :
     longContinuationTrigger ? "Long Breakout" :
     shortContinuationTrigger ? "Short Breakout" :
     longRevReady ? "Buy Stop > REV" :
     shortRevReady ? "Sell Stop < REV" :
     upHoldReady ? "Wait Bull Retest" :
     downHoldReady ? "Wait Bear Retest" :
     nearUpper ? "Watch Upper Edge" :
     nearLower ? "Watch Lower Edge" :
     middleOfRange ? "No Trade - Middle" :
     inNY ? "Wait Range Edge" : "Wait NY"

rangeText = not inNY ? "Off" : rangeValid ? str.tostring(rangeSize, "#.##") + " pts" : "Invalid"
volDashText = showVolumeContext ? volState + (requireVolForContinuation and not volOKContinuation ? " ⚠" : "") : "Off"
chopText = chopRisk ? str.tostring(midCrossCount) + " mid crosses" : "Clean"

headerBg = color.new(f_state_color(stateText), 0)
cellBg = color.new(color.rgb(20, 22, 26), 10)
cellBg2 = color.new(color.rgb(32, 34, 40), 5)
textColor = color.white
mutedText = color.rgb(210, 215, 220)

var table dash = na
if showDash and na(dash)
    dash := table.new(f_table_pos(dashPos), 2, 8, bgcolor=color.new(color.black, 10), frame_color=color.new(neutralColor, 50), frame_width=1, border_color=color.new(neutralColor, 75), border_width=1)

if showDash and not na(dash) and barstate.islast
    ts = f_text_size(dashSize)
    table.clear(dash, 0, 0, 1, 7)
    table.cell(dash, 0, 0, "RANGE EDGE", bgcolor=headerBg, text_color=textColor, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 0, stateText, bgcolor=headerBg, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 1, "Mode", bgcolor=cellBg, text_color=mutedText, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 1, rangeModeText, bgcolor=cellBg, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 2, "Range", bgcolor=cellBg2, text_color=mutedText, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 2, rangeText, bgcolor=cellBg2, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 3, "Location", bgcolor=cellBg, text_color=mutedText, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 3, locationText, bgcolor=cellBg, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 4, "Edge", bgcolor=cellBg2, text_color=mutedText, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 4, edgeText, bgcolor=cellBg2, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 5, "Setup", bgcolor=cellBg, text_color=mutedText, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 5, modeText, bgcolor=cellBg, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 6, "Volume", bgcolor=cellBg2, text_color=mutedText, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 6, volDashText, bgcolor=cellBg2, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 7, "Action", bgcolor=headerBg, text_color=textColor, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 7, actionText, bgcolor=headerBg, text_color=textColor, text_size=ts, text_halign=text.align_right)

if not showDash and not na(dash)
    table.delete(dash)
    dash := na

//========================
// Alerts
//========================
alertcondition(longReversalConfirm, title="Lower Range Edge Rejection", message="FlowScope Range Edge Manual: Lower edge rejection detected. Watch long reversal trigger.")
alertcondition(shortReversalConfirm, title="Upper Range Edge Rejection", message="FlowScope Range Edge Manual: Upper edge rejection detected. Watch short reversal trigger.")
alertcondition(newUpBreak, title="Range Break Up", message="FlowScope Range Edge Manual: Price closed above manual range high plus buffer. Watch hold/retest continuation.")
alertcondition(newDownBreak, title="Range Break Down", message="FlowScope Range Edge Manual: Price closed below manual range low minus buffer. Watch hold/retest continuation.")
alertcondition(upRetestConfirm, title="Bullish Range Break Retest", message="FlowScope Range Edge Manual: Bullish breakout retest confirmed. Watch long trigger.")
alertcondition(downRetestConfirm, title="Bearish Range Break Retest", message="FlowScope Range Edge Manual: Bearish breakdown retest confirmed. Watch short trigger.")
alertcondition(longReversalTrigger, title="Long Range Reversal Trigger", message="FlowScope Range Edge Manual: Long range reversal trigger fired.")
alertcondition(shortReversalTrigger, title="Short Range Reversal Trigger", message="FlowScope Range Edge Manual: Short range reversal trigger fired.")
alertcondition(longContinuationTrigger, title="Long Range Break Continuation Trigger", message="FlowScope Range Edge Manual: Long breakout continuation trigger fired.")
alertcondition(shortContinuationTrigger, title="Short Range Break Continuation Trigger", message="FlowScope Range Edge Manual: Short breakout continuation trigger fired.")
alertcondition(newChopRisk, title="Range Chop Risk", message="FlowScope Range Edge Manual: Repeated midpoint rotation detected. Chop risk increased.")
````
