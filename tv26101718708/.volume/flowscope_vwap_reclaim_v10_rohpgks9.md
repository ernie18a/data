# FlowScope VWAP Reclaim v1.0

- url: https://www.tradingview.com/script/ROhPgKS9-FlowScope-VWAP-Reclaim-v1-0/
- type: indicator
- pine_id: PUB;7e98c05be18849d9bd5bec58b93430a9
- version: 1.0

## Description

Price crosses VWAP, proves acceptance on the new side, retests or holds the VWAP zone, and then triggers only after confirmation.

This indicator is designed to help traders avoid blindly buying or selling every VWAP cross. Instead, it focuses on structured VWAP reclaim and rejection setups.

What This Indicator Shows

New York open vertical line
Session VWAP
Adaptive VWAP reclaim/rejection zone
Optional VWAP deviation bands
Bullish and bearish VWAP cross markers
VWAP retest/hold markers
Long and short trigger triangles
Extended-from-VWAP warning
VWAP chop-risk logic
Relative volume context
Compact dashboard showing current VWAP state
Main Concept

VWAP acts as a session fair-value reference.
When price is holding above VWAP, buyers may have control of session value.
When price is holding below VWAP, sellers may have control of session value.

This indicator does not treat a simple VWAP cross as a complete trade signal. It waits for:

Price to cross VWAP.
Price to hold on the new side.
Price to retest or defend the VWAP zone.
Price to break the confirmation candle.
Bullish VWAP Reclaim

A bullish VWAP reclaim happens when price moves from below VWAP to above VWAP and then proves it can hold there.

Basic long sequence:

Price crosses above VWAP.
Price holds above VWAP for the selected hold period.
Price retests or defends the VWAP zone.
A bullish retest marker appears.
A green trigger triangle appears if price breaks above the retest candle high.

This suggests sellers failed below fair value and buyers may be taking control.

Bearish VWAP Rejection

A bearish VWAP rejection happens when price moves from above VWAP to below VWAP and then proves it can hold underneath.

Basic short sequence:

Price crosses below VWAP.
Price holds below VWAP for the selected hold period.
Price retests or rejects the VWAP zone from below.
A bearish retest marker appears.
A red trigger triangle appears if price breaks below the retest candle low.

This suggests buyers failed above fair value and sellers may be taking control.

Marker Meanings

VW = VWAP cross
Price crossed VWAP and began a reclaim/rejection watch.

RT = VWAP retest or hold confirmation
Price retested or defended the VWAP zone after crossing.

Green triangle = Long trigger
Price broke above the bullish retest candle high.

Red triangle = Short trigger
Price broke below the bearish retest candle low.

EXT = Extended from VWAP
Price is stretched far from VWAP. This is a warning not to chase without a fresh setup.

CHOP = VWAP chop risk
Price has crossed VWAP repeatedly within the lookback window.

Dashboard States

The dashboard summarizes the current VWAP condition:

WAITING — No active VWAP setup.
LONG WATCH — Price reclaimed VWAP and is being monitored.
SHORT WATCH — Price lost VWAP and is being monitored.
LONG HOLD — Price is holding above VWAP and waiting for long confirmation.
SHORT HOLD — Price is holding below VWAP and waiting for short confirmation.
LONG TRIGGER — Long VWAP reclaim trigger fired.
SHORT TRIGGER — Short VWAP rejection trigger fired.
CHOP RISK — Price is crossing VWAP too often; caution.
EXTENDED — Price is stretched away from VWAP; avoid chasing.
OFF SESSION — Outside the active New York session.

Volume Context

Elevated or strong volume can support a VWAP reclaim or rejection. Weak volume may suggest the move lacks participation.

Best Used For

5-minute charts
New York session
VWAP reclaim setups
VWAP rejection setups
Intraday bias-shift decisions

Important Notes

VWAP can become very noisy when price repeatedly crosses it. During those conditions, the indicator may show chop risk, and signals should be treated with caution.

The strongest VWAP setups usually happen when:

Price clearly loses or reclaims VWAP.
Price holds on the new side.
The retest is controlled.
Volume supports the move.
There is enough room to target at least 1.5R–2R.
The setup is not directly into a major opposing level.

## Source Code

````pine
//@version=6
indicator("FlowScope VWAP Reclaim — MNQ v1.0", overlay=true, max_lines_count=500, max_labels_count=100, max_boxes_count=50)

//====================================================
// FlowScope VWAP Reclaim — MNQ v1.0
// Purpose: Session fair-value reclaim/rejection setup for MNQ/NQ.
// Designed for: MNQ1! / NQ1!, 5-minute chart, NY cash session.
// Core idea: VWAP cross -> hold/retest -> confirmation trigger.
//====================================================

//========================
// Inputs
//========================
groupSession = "Session"
tzInput       = input.string("America/New_York", "Session Timezone", group=groupSession)
activeSession = input.session("0930-1700", "Active NY Session", group=groupSession)
showOpenLine  = input.bool(true, "Show NY Open Vertical Line", group=groupSession)

// VWAP settings
groupVWAP = "VWAP Settings"
showVWAP          = input.bool(true, "Show VWAP", group=groupVWAP)
showVWAPZone      = input.bool(true, "Show VWAP Reclaim Zone", group=groupVWAP)
showVWAPBands     = input.bool(false, "Show VWAP Deviation Bands", group=groupVWAP)
bandStdevMult1    = input.float(1.0, "Band 1 StDev Multiplier", minval=0.25, step=0.25, group=groupVWAP)
bandStdevMult2    = input.float(2.0, "Band 2 StDev Multiplier", minval=0.25, step=0.25, group=groupVWAP)
zoneAtrMult       = input.float(0.12, "VWAP Zone = ATR ×", minval=0.01, step=0.01, group=groupVWAP)
minZonePts        = input.float(3.0, "Minimum VWAP Zone Points", minval=0.25, step=0.25, group=groupVWAP)
maxZonePts        = input.float(12.0, "Maximum VWAP Zone Points", minval=0.25, step=0.25, group=groupVWAP)
holdBars          = input.int(2, "VWAP Hold Bars", minval=1, maxval=5, group=groupVWAP)
retestTimeoutBars = input.int(8, "Retest Timeout Bars", minval=2, maxval=30, group=groupVWAP)

// MNQ settings
groupMNQ = "MNQ Settings"
atrLen             = input.int(14, "ATR Length", minval=1, group=groupMNQ)
stopBufferPts      = input.float(3.0, "Suggested Stop Buffer Points", minval=0.25, step=0.25, group=groupMNQ)
extendedAtrMult    = input.float(1.25, "Overextended From VWAP = ATR ×", minval=0.25, step=0.25, group=groupMNQ)
minDistanceForBias = input.float(4.0, "Minimum Distance From VWAP For Bias", minval=0.25, step=0.25, group=groupMNQ)

// Chop filter settings
groupChop = "Chop / No-Trade Filter"
useChopFilter       = input.bool(true, "Use VWAP Chop Warning", group=groupChop)
chopLookbackBars    = input.int(20, "VWAP Cross Lookback Bars", minval=5, maxval=100, group=groupChop)
chopCrossThreshold  = input.int(4, "Chop Warning Cross Count", minval=2, maxval=20, group=groupChop)
showChopWarnings    = input.bool(false, "Show Chop Warning Diamonds", group=groupChop)

// Volume settings
groupVol = "Volume Context"
showVolumeContext = input.bool(true, "Show Volume Context", group=groupVol)
volLen      = input.int(20, "Relative Volume Length", minval=1, group=groupVol)
weakVol     = input.float(0.80, "Weak Volume Threshold", minval=0.1, step=0.05, group=groupVol)
elevatedVol = input.float(1.20, "Elevated Volume Threshold", minval=0.1, step=0.05, group=groupVol)
strongVol   = input.float(1.80, "Strong Volume Threshold", minval=0.1, step=0.05, group=groupVol)
requireVolForTrigger = input.bool(false, "Require Elevated Volume For Trigger", group=groupVol)

// Visual settings
groupVisual = "Visuals"
showCrossMarks   = input.bool(true, "Show VWAP Cross Marks", group=groupVisual)
showRetestMarks  = input.bool(true, "Show Retest/Hold Marks", group=groupVisual)
showTriggerMarks = input.bool(true, "Show Trigger Triangles", group=groupVisual)

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
    state == "LONG WATCH" or state == "LONG HOLD" or state == "LONG TRIGGER" ? bullColor :
     state == "SHORT WATCH" or state == "SHORT HOLD" or state == "SHORT TRIGGER" ? bearColor :
     state == "CHOP RISK" or state == "EXTENDED" ? warnColor :
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
vwap = ta.vwap(hlc3)
zonePts = f_clamp(atr * zoneAtrMult, minZonePts, maxZonePts)
upperZone = vwap + zonePts
lowerZone = vwap - zonePts

// VWAP deviation bands.
stdevSource = hlc3
stdevLen = 50
vwapDev = ta.stdev(stdevSource - vwap, stdevLen)
upperBand1 = vwap + vwapDev * bandStdevMult1
lowerBand1 = vwap - vwapDev * bandStdevMult1
upperBand2 = vwap + vwapDev * bandStdevMult2
lowerBand2 = vwap - vwapDev * bandStdevMult2

// Volume context.
volAvg = ta.sma(volume, volLen)
rvol = volAvg > 0 ? volume / volAvg : na
volState = na(rvol) ? "N/A" : rvol < weakVol ? "Weak" : rvol < elevatedVol ? "Normal" : rvol < strongVol ? "Elevated" : "Strong"
volOK = not requireVolForTrigger or rvol >= elevatedVol

// VWAP bias and distance.
distanceFromVWAP = close - vwap
absDistanceFromVWAP = math.abs(distanceFromVWAP)
biasText = not inNY ? "Off" : absDistanceFromVWAP < minDistanceForBias ? "Neutral" : close > vwap ? "Bullish" : close < vwap ? "Bearish" : "Neutral"
extendedFromVWAP = inNY and absDistanceFromVWAP >= atr * extendedAtrMult

// Chop detection: repeated crosses of VWAP in lookback.
vwapCross = inNY and ta.cross(close, vwap)
vwapCrossCount = math.sum(vwapCross ? 1 : 0, chopLookbackBars)
chopRisk = useChopFilter and inNY and vwapCrossCount >= chopCrossThreshold
newChopRisk = chopRisk and not chopRisk[1]

//========================
// VWAP Reclaim / Rejection state
//========================
// Long setup: below VWAP -> reclaim above VWAP -> hold/retest -> trigger above confirmation candle.
// Short setup: above VWAP -> lose VWAP -> hold/retest from below -> trigger below confirmation candle.

bullCross = inNY and ta.crossover(close, vwap)
bearCross = inNY and ta.crossunder(close, vwap)

var bool bullReclaimActive = false
var bool bearRejectActive = false
var int bullCrossBar = na
var int bearCrossBar = na
var bool bullHoldReady = false
var bool bearHoldReady = false
var float bullRetestHigh = na
var float bullRetestLow = na
var float bearRetestLow = na
var float bearRetestHigh = na

if bullCross
    bullReclaimActive := true
    bearRejectActive := false
    bullHoldReady := false
    bearHoldReady := false
    bullCrossBar := bar_index
    bullRetestHigh := na
    bullRetestLow := na

if bearCross
    bearRejectActive := true
    bullReclaimActive := false
    bearHoldReady := false
    bullHoldReady := false
    bearCrossBar := bar_index
    bearRetestLow := na
    bearRetestHigh := na

// Hold means price accepts the new side of VWAP for selected bars.
bullHold = bullReclaimActive and ta.lowest(close, holdBars) > vwap
bearHold = bearRejectActive and ta.highest(close, holdBars) < vwap

if bullHold
    bullHoldReady := true
if bearHold
    bearHoldReady := true

// Retest/hold confirmation candle.
bullRetestConfirm = inNY and bullHoldReady and low <= upperZone and high >= lowerZone and close > vwap and close > open
bearRetestConfirm = inNY and bearHoldReady and high >= lowerZone and low <= upperZone and close < vwap and close < open

if bullRetestConfirm
    bullRetestHigh := high
    bullRetestLow := low

if bearRetestConfirm
    bearRetestLow := low
    bearRetestHigh := high

// Timeout if the cross does not develop into a retest.
if bullReclaimActive and bar_index - nz(bullCrossBar, bar_index) > retestTimeoutBars and na(bullRetestHigh)
    bullReclaimActive := false
    bullHoldReady := false

if bearRejectActive and bar_index - nz(bearCrossBar, bar_index) > retestTimeoutBars and na(bearRetestLow)
    bearRejectActive := false
    bearHoldReady := false

// Failure if price crosses back to the wrong side before confirmation.
bullFailed = bullReclaimActive and close < vwap
bearFailed = bearRejectActive and close > vwap

if bullFailed
    bullReclaimActive := false
    bullHoldReady := false
    bullRetestHigh := na
    bullRetestLow := na

if bearFailed
    bearRejectActive := false
    bearHoldReady := false
    bearRetestLow := na
    bearRetestHigh := na

// Triggers occur after retest confirmation candle.
longTrigger = inNY and not chopRisk and not na(bullRetestHigh[1]) and high > nz(bullRetestHigh[1]) and volOK
shortTrigger = inNY and not chopRisk and not na(bearRetestLow[1]) and low < nz(bearRetestLow[1]) and volOK

if longTrigger
    bullReclaimActive := false
    bullHoldReady := false
    bullRetestHigh := na
    bullRetestLow := na

if shortTrigger
    bearRejectActive := false
    bearHoldReady := false
    bearRetestLow := na
    bearRetestHigh := na

// Suggested risk context.
longStop = not na(bullRetestLow) ? bullRetestLow - stopBufferPts : na
shortStop = not na(bearRetestHigh) ? bearRetestHigh + stopBufferPts : na
longRiskPts = not na(bullRetestHigh) and not na(longStop) ? bullRetestHigh - longStop : na
shortRiskPts = not na(bearRetestLow) and not na(shortStop) ? shortStop - bearRetestLow : na
roomText = longTrigger or bullHoldReady ? "Check 2R" : shortTrigger or bearHoldReady ? "Check 2R" : extendedFromVWAP ? "Extended" : "N/A"

//========================
// Plots
//========================
plotVisible = inNY

pVWAP = plot(showVWAP and plotVisible ? vwap : na, "VWAP", color=color.new(neutralColor, 0), linewidth=2, style=plot.style_linebr)
pUpperZone = plot(showVWAPZone and plotVisible ? upperZone : na, "VWAP Zone Upper", color=color.new(neutralColor, 82), linewidth=1, style=plot.style_linebr)
pLowerZone = plot(showVWAPZone and plotVisible ? lowerZone : na, "VWAP Zone Lower", color=color.new(neutralColor, 82), linewidth=1, style=plot.style_linebr)
fill(pUpperZone, pLowerZone, color=showVWAPZone and plotVisible ? color.new(neutralColor, 92) : na, title="VWAP Reclaim Zone")

plot(showVWAPBands and plotVisible ? upperBand1 : na, "Upper VWAP Band 1", color=color.new(bullColor, 75), linewidth=1, style=plot.style_linebr)
plot(showVWAPBands and plotVisible ? lowerBand1 : na, "Lower VWAP Band 1", color=color.new(bearColor, 75), linewidth=1, style=plot.style_linebr)
plot(showVWAPBands and plotVisible ? upperBand2 : na, "Upper VWAP Band 2", color=color.new(bullColor, 85), linewidth=1, style=plot.style_linebr)
plot(showVWAPBands and plotVisible ? lowerBand2 : na, "Lower VWAP Band 2", color=color.new(bearColor, 85), linewidth=1, style=plot.style_linebr)

// Markers.
plotshape(showCrossMarks and bullCross, title="VWAP Bullish Reclaim Cross", style=shape.circle, location=location.abovebar, color=color.new(confirmColor, 0), size=size.tiny, text="VW")
plotshape(showCrossMarks and bearCross, title="VWAP Bearish Rejection Cross", style=shape.circle, location=location.belowbar, color=color.new(confirmColor, 0), size=size.tiny, text="VW")

plotshape(showRetestMarks and bullRetestConfirm, title="Bullish VWAP Retest/Hold", style=shape.circle, location=location.abovebar, color=color.new(bullColor, 0), size=size.tiny, text="RT")
plotshape(showRetestMarks and bearRetestConfirm, title="Bearish VWAP Retest/Hold", style=shape.circle, location=location.belowbar, color=color.new(bearColor, 0), size=size.tiny, text="RT")

plotshape(showTriggerMarks and longTrigger, title="Long VWAP Reclaim Trigger", style=shape.triangleup, location=location.belowbar, color=color.new(bullColor, 0), size=size.normal)
plotshape(showTriggerMarks and shortTrigger, title="Short VWAP Rejection Trigger", style=shape.triangledown, location=location.abovebar, color=color.new(bearColor, 0), size=size.normal)

plotshape(showChopWarnings and newChopRisk, title="VWAP Chop Risk", style=shape.diamond, location=location.abovebar, color=color.new(warnColor, 0), size=size.tiny, text="CHOP")
plotshape(showCrossMarks and extendedFromVWAP and not extendedFromVWAP[1], title="Extended From VWAP", style=shape.diamond, location=location.abovebar, color=color.new(warnColor, 0), size=size.tiny, text="EXT")

//========================
// Dashboard
//========================
stateText = longTrigger ? "LONG TRIGGER" :
     shortTrigger ? "SHORT TRIGGER" :
     chopRisk ? "CHOP RISK" :
     extendedFromVWAP and not bullHoldReady and not bearHoldReady ? "EXTENDED" :
     bullHoldReady ? "LONG HOLD" :
     bearHoldReady ? "SHORT HOLD" :
     bullReclaimActive ? "LONG WATCH" :
     bearRejectActive ? "SHORT WATCH" :
     inNY ? "WAITING" : "OFF SESSION"

vwapStateText = bullCross ? "Reclaimed" : bearCross ? "Lost" : close > vwap ? "Above" : close < vwap ? "Below" : "At VWAP"
setupText = bullHoldReady ? "Reclaim" : bearHoldReady ? "Rejection" : bullReclaimActive ? "Reclaim Watch" : bearRejectActive ? "Reject Watch" : chopRisk ? "No Trade" : "Wait"
chopText = chopRisk ? str.tostring(vwapCrossCount) + " crosses" : "Clean"
volDashText = showVolumeContext ? volState + (requireVolForTrigger and not volOK ? " ⚠" : "") : "Off"
actionText = longTrigger ? "Long Trigger" :
     shortTrigger ? "Short Trigger" :
     chopRisk ? "Avoid Chop" :
     bullHoldReady ? "Wait Long RT" :
     bearHoldReady ? "Wait Short RT" :
     bullReclaimActive ? "Hold Above VWAP" :
     bearRejectActive ? "Hold Below VWAP" :
     extendedFromVWAP ? "Do Not Chase" :
     inNY ? "Wait VWAP Shift" : "Wait NY"

distText = not inNY ? "Off" : str.tostring(distanceFromVWAP, "#.##") + " pts"

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
    table.cell(dash, 0, 0, "VWAP RECLAIM", bgcolor=headerBg, text_color=textColor, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 0, stateText, bgcolor=headerBg, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 1, "Bias", bgcolor=cellBg, text_color=mutedText, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 1, biasText, bgcolor=cellBg, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 2, "VWAP", bgcolor=cellBg2, text_color=mutedText, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 2, vwapStateText, bgcolor=cellBg2, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 3, "Distance", bgcolor=cellBg, text_color=mutedText, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 3, distText, bgcolor=cellBg, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 4, "Setup", bgcolor=cellBg2, text_color=mutedText, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 4, setupText, bgcolor=cellBg2, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 5, "Volume", bgcolor=cellBg, text_color=mutedText, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 5, volDashText, bgcolor=cellBg, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 6, "Chop", bgcolor=cellBg2, text_color=mutedText, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 6, chopText, bgcolor=cellBg2, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 7, "Action", bgcolor=headerBg, text_color=textColor, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 7, actionText, bgcolor=headerBg, text_color=textColor, text_size=ts, text_halign=text.align_right)

if not showDash and not na(dash)
    table.delete(dash)
    dash := na

//========================
// Alerts
//========================
alertcondition(bullCross, title="VWAP Bullish Reclaim", message="FlowScope VWAP Reclaim: Price reclaimed VWAP. Watch for hold/retest.")
alertcondition(bearCross, title="VWAP Bearish Rejection", message="FlowScope VWAP Reclaim: Price lost VWAP. Watch for hold/retest from below.")
alertcondition(bullRetestConfirm, title="Bullish VWAP Retest Confirmed", message="FlowScope VWAP Reclaim: Bullish VWAP retest/hold confirmed. Watch long trigger.")
alertcondition(bearRetestConfirm, title="Bearish VWAP Retest Confirmed", message="FlowScope VWAP Reclaim: Bearish VWAP retest/hold confirmed. Watch short trigger.")
alertcondition(longTrigger, title="Long VWAP Reclaim Trigger", message="FlowScope VWAP Reclaim: Long VWAP reclaim trigger fired.")
alertcondition(shortTrigger, title="Short VWAP Rejection Trigger", message="FlowScope VWAP Reclaim: Short VWAP rejection trigger fired.")
alertcondition(newChopRisk, title="VWAP Chop Risk", message="FlowScope VWAP Reclaim: Price is crossing VWAP repeatedly. Chop risk increased.")
alertcondition(extendedFromVWAP and not extendedFromVWAP[1], title="Extended From VWAP", message="FlowScope VWAP Reclaim: Price is extended from VWAP. Avoid chasing without a new setup.")
````
