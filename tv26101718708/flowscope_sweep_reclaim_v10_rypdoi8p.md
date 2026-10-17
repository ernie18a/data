# FlowScope Sweep & Reclaim v1.0

- url: https://www.tradingview.com/script/rYPDOI8P-FlowScope-Sweep-Reclaim-v1-0/
- type: indicator
- pine_id: PUB;f4792006684f449b931db6c43cff4665
- version: 2.0

## Description

This setup is designed for traders who want to avoid chasing breakouts and instead wait for proof that a move beyond a key level has failed.

What This Indicator Tracks

The indicator automatically plots and monitors important levels, including:

New York open vertical line
Opening range high and low
Premarket high and low
Previous day high and low
Optional opening range midpoint
Sweep markers
Reclaim markers
Long and short trigger triangles
Relative volume / “Trap Fuel” context
A compact dashboard showing the current setup state
How the Setup Works

A bullish Sweep & Reclaim happens when price moves below an obvious support level, triggers stops or breakout shorts, then closes back above that level.

A bearish Sweep & Reclaim happens when price moves above an obvious resistance level, triggers breakout buyers or short stops, then closes back below that level.

The trade idea is not to enter during the sweep. The trade idea is to wait for the reclaim and then use the reclaim candle as the trigger structure.


For a long setup:

Price sweeps below support.
The sweep must exceed the minimum MNQ sweep threshold.
Price closes back above the swept level.
A reclaim marker appears.
A long trigger appears if price breaks above the reclaim candle high.
Stop placement is generally below the sweep low, with a small MNQ buffer.


For a short setup:

Price sweeps above resistance.
The sweep must exceed the minimum MNQ sweep threshold.
Price closes back below the swept level.
A reclaim marker appears.
A short trigger appears if price breaks below the reclaim candle low.
Stop placement is generally above the sweep high, with a small MNQ buffer.
Marker Meanings

S = Sweep
Price has moved beyond an obvious level by the required sweep distance.

R = Reclaim
Price has closed back through the swept level, suggesting the breakout or breakdown may have failed.

Green triangle = Long trigger
Price broke above the bullish reclaim candle high.

Red triangle = Short trigger
Price broke below the bearish reclaim candle low.

Dashboard States

The dashboard summarizes the current condition:

WAITING — No active sweep setup.
SWEEP BELOW — Price has swept below a support level.
SWEEP ABOVE — Price has swept above a resistance level.
LONG TRAP — Bullish reclaim is active.
SHORT TRAP — Bearish reclaim is active.
LONG TRIGGER — Long trigger has appeared.
SHORT TRIGGER — Short trigger has appeared.
OFF SESSION — Outside the active New York session.
Volume Context

The indicator includes relative volume context to help judge whether the sweep may have meaningful participation behind it.

For this setup, strong volume can be interpreted differently than in a normal breakout strategy.

If price sweeps a level on high volume and then reclaims, that volume may become trap fuel, because traders who entered the failed breakout may be forced to exit.

Volume states include:

Weak
Normal
Elevated
Trap Fuel
Best Used For

This indicator is best used on:

5-minute charts
New York cash session
Failed breakout / failed breakdown reversal setups

It is especially useful around:

Opening range high
Opening range low
Premarket high
Premarket low
Previous day high
Previous day low

Important Notes

This indicator is not intended to predict every reversal. A sweep does not automatically mean price must reverse.

The strongest setups usually happen when:

The level is obvious.
The sweep is meaningful.
Price reclaims quickly.
The reclaim candle is strong.
There is enough room to target at least 1.5R–2R.
The trade is not directly into a major opposing level.

Always use proper risk management and confirm the broader market context before entering a trade.

## Source Code

````pine
//@version=6
indicator("FlowScope Sweep & Reclaim — MNQ v1.0", overlay=true, max_lines_count=500, max_labels_count=100, max_boxes_count=50)

//====================================================
// FlowScope Sweep & Reclaim — MNQ v1.0
// Purpose: Detect failed breakouts/breakdowns around obvious MNQ levels.
// Designed for: MNQ1! / NQ1!, 5-minute chart, NY cash session.
// Core idea: Sweep an obvious level -> reclaim it -> trigger on reclaim candle break.
//====================================================

//========================
// Inputs
//========================
groupSession = "Session"
tzInput       = input.string("America/New_York", "Session Timezone", group=groupSession)
activeSession = input.session("0930-1700", "Active NY Session", group=groupSession)
orSession     = input.session("0930-0945", "Opening Range Window", group=groupSession)
pmSession     = input.session("0400-0929", "Premarket Window", group=groupSession)
showOpenLine  = input.bool(true, "Show NY Open Vertical Line", group=groupSession)

// Level controls
groupLevels = "Levels"
showORLevels = input.bool(true, "Show Opening Range High/Low", group=groupLevels)
showPMLevels = input.bool(true, "Show Premarket High/Low", group=groupLevels)
showPDLevels = input.bool(true, "Show Previous Day High/Low", group=groupLevels)
showMid      = input.bool(false, "Show Opening Range Midpoint", group=groupLevels)
showLevelLabels = input.bool(false, "Show Level Text Labels", group=groupLevels)

// MNQ sweep settings
groupMNQ = "MNQ Sweep Settings"
atrLen        = input.int(14, "ATR Length", minval=1, group=groupMNQ)
sweepAtrMult  = input.float(0.10, "Minimum Sweep = ATR ×", minval=0.01, step=0.01, group=groupMNQ)
minSweepPts   = input.float(4.0, "Minimum Sweep Points", minval=0.25, step=0.25, group=groupMNQ)
maxSweepPts   = input.float(12.0, "Maximum Sweep Points", minval=0.25, step=0.25, group=groupMNQ)
stopBufferPts = input.float(3.0, "Suggested Stop Buffer Points", minval=0.25, step=0.25, group=groupMNQ)
reclaimTimeoutBars = input.int(5, "Sweep Timeout Bars", minval=1, maxval=20, group=groupMNQ)

// Volume settings
groupVol = "Volume Context"
showVolumeContext = input.bool(true, "Show Volume Context", group=groupVol)
volLen      = input.int(20, "Relative Volume Length", minval=1, group=groupVol)
weakVol     = input.float(0.80, "Weak Volume Threshold", minval=0.1, step=0.05, group=groupVol)
elevatedVol = input.float(1.20, "Elevated Volume Threshold", minval=0.1, step=0.05, group=groupVol)
trapFuelVol = input.float(1.80, "Trap Fuel Volume Threshold", minval=0.1, step=0.05, group=groupVol)
requireVolForTrigger = input.bool(false, "Require Elevated Volume For Trigger", group=groupVol)

// Visual settings
groupVisual = "Visuals"
showSweepMarks   = input.bool(true, "Show Sweep Markers", group=groupVisual)
showReclaimMarks = input.bool(true, "Show Reclaim Markers", group=groupVisual)
showTriggers     = input.bool(true, "Show Trigger Triangles", group=groupVisual)

bullColor     = input.color(color.rgb(0, 190, 120), "Bull Color", group=groupVisual)
bearColor     = input.color(color.rgb(220, 70, 70), "Bear Color", group=groupVisual)
neutralColor  = input.color(color.rgb(150, 150, 150), "Neutral Color", group=groupVisual)
warnColor     = input.color(color.rgb(235, 175, 55), "Warning Color", group=groupVisual)
reclaimColor  = input.color(color.rgb(80, 160, 255), "Reclaim Marker Color", group=groupVisual)
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
    state == "LONG TRAP" or state == "LONG TRIGGER" ? bullColor :
     state == "SHORT TRAP" or state == "SHORT TRIGGER" ? bearColor :
     state == "SWEEP ABOVE" or state == "SWEEP BELOW" or state == "RECLAIM WATCH" ? warnColor :
     neutralColor

//========================
// Sessions
//========================
inNY     = not na(time(timeframe.period, activeSession, tzInput))
inOR     = not na(time(timeframe.period, orSession, tzInput))
inPM     = not na(time(timeframe.period, pmSession, tzInput))
startNY  = inNY and not inNY[1]
startOR  = inOR and not inOR[1]
endOR    = not inOR and inOR[1]

//========================
// Core calculations
//========================
atr = ta.atr(atrLen)
sweepPts = f_clamp(atr * sweepAtrMult, minSweepPts, maxSweepPts)

volAvg = ta.sma(volume, volLen)
rvol = volAvg > 0 ? volume / volAvg : na
volState = na(rvol) ? "N/A" : rvol < weakVol ? "Weak" : rvol < elevatedVol ? "Normal" : rvol < trapFuelVol ? "Elevated" : "Trap Fuel"
volOK = not requireVolForTrigger or rvol >= elevatedVol

// Previous day levels from daily data.
pdHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdLow  = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)

//========================
// Persistent levels
//========================
var float pmHigh = na
var float pmLow = na
var float orHigh = na
var float orLow = na
var float orMid = na
var bool orSet = false

var array<line> openLines = array.new<line>()

// Build/reset daily levels.
if inPM and not inPM[1]
    pmHigh := high
    pmLow := low

if inPM
    pmHigh := math.max(nz(pmHigh, high), high)
    pmLow := math.min(nz(pmLow, low), low)

if startOR
    if showOpenLine
        nyLine = line.new(x1=bar_index, y1=low, x2=bar_index, y2=high, extend=extend.both, color=color.new(openLineColor, 0), style=line.style_dashed, width=1)
        array.push(openLines, nyLine)
        if array.size(openLines) > 100
            line.delete(array.shift(openLines))
    orHigh := high
    orLow := low
    orMid := na
    orSet := false

if inOR
    orHigh := math.max(nz(orHigh, high), high)
    orLow := math.min(nz(orLow, low), low)
    orMid := (orHigh + orLow) / 2.0

if endOR
    orSet := true
    orMid := (orHigh + orLow) / 2.0

//========================
// Level selection logic
//========================
// A support level can produce a long trap when swept below and reclaimed.
// A resistance level can produce a short trap when swept above and reclaimed.

float supportLevel = na
string supportName = "N/A"
float resistanceLevel = na
string resistanceName = "N/A"

// Nearest visible level by distance from current price.
// Pine does not allow tuple reassignment with :=, so this is written inline.
if showORLevels and orSet
    if not na(orLow) and (na(supportLevel) or math.abs(close - orLow) < math.abs(close - supportLevel))
        supportLevel := orLow
        supportName := "ORL"
    if not na(orHigh) and (na(resistanceLevel) or math.abs(close - orHigh) < math.abs(close - resistanceLevel))
        resistanceLevel := orHigh
        resistanceName := "ORH"

if showPMLevels
    if not na(pmLow) and (na(supportLevel) or math.abs(close - pmLow) < math.abs(close - supportLevel))
        supportLevel := pmLow
        supportName := "PML"
    if not na(pmHigh) and (na(resistanceLevel) or math.abs(close - pmHigh) < math.abs(close - resistanceLevel))
        resistanceLevel := pmHigh
        resistanceName := "PMH"

if showPDLevels
    if not na(pdLow) and (na(supportLevel) or math.abs(close - pdLow) < math.abs(close - supportLevel))
        supportLevel := pdLow
        supportName := "PDL"
    if not na(pdHigh) and (na(resistanceLevel) or math.abs(close - pdHigh) < math.abs(close - resistanceLevel))
        resistanceLevel := pdHigh
        resistanceName := "PDH"

//========================
// Sweep & reclaim state
//========================
var bool longSweepActive = false
var bool shortSweepActive = false
var float sweptSupport = na
var float sweptResistance = na
var string sweptSupportName = "N/A"
var string sweptResistanceName = "N/A"
var float sweepLow = na
var float sweepHigh = na
var int longSweepBar = na
var int shortSweepBar = na
var float longReclaimHigh = na
var float shortReclaimLow = na
var bool longReclaimReady = false
var bool shortReclaimReady = false

canEvaluate = inNY

rawLongSweep = canEvaluate and not na(supportLevel) and low <= supportLevel - sweepPts and close < supportLevel
rawShortSweep = canEvaluate and not na(resistanceLevel) and high >= resistanceLevel + sweepPts and close > resistanceLevel

// Only mark the first sweep in a sequence.
// This prevents repeated sweep dots while price stays beyond the swept level.
newLongSweep = rawLongSweep and not longSweepActive and not longReclaimReady
newShortSweep = rawShortSweep and not shortSweepActive and not shortReclaimReady

if newLongSweep
    longSweepActive := true
    longReclaimReady := false
    sweptSupport := supportLevel
    sweptSupportName := supportName
    sweepLow := low
    longSweepBar := bar_index
    longReclaimHigh := na

if newShortSweep
    shortSweepActive := true
    shortReclaimReady := false
    sweptResistance := resistanceLevel
    sweptResistanceName := resistanceName
    sweepHigh := high
    shortSweepBar := bar_index
    shortReclaimLow := na

// Update extremes while active.
if longSweepActive
    sweepLow := math.min(nz(sweepLow, low), low)

if shortSweepActive
    sweepHigh := math.max(nz(sweepHigh, high), high)

// Timeouts.
if longSweepActive and bar_index - nz(longSweepBar, bar_index) > reclaimTimeoutBars
    longSweepActive := false
    longReclaimReady := false

if shortSweepActive and bar_index - nz(shortSweepBar, bar_index) > reclaimTimeoutBars
    shortSweepActive := false
    shortReclaimReady := false

// Reclaim confirmations.
longReclaim = canEvaluate and longSweepActive and close > sweptSupport and close > open
shortReclaim = canEvaluate and shortSweepActive and close < sweptResistance and close < open

if longReclaim
    longReclaimReady := true
    longReclaimHigh := high

if shortReclaim
    shortReclaimReady := true
    shortReclaimLow := low

// Triggers occur after reclaim candle.
longTrigger = canEvaluate and longReclaimReady[1] and high > nz(longReclaimHigh[1]) and volOK
shortTrigger = canEvaluate and shortReclaimReady[1] and low < nz(shortReclaimLow[1]) and volOK

if longTrigger
    longSweepActive := false
    longReclaimReady := false

if shortTrigger
    shortSweepActive := false
    shortReclaimReady := false

// Risk context.
longStop = not na(sweepLow) ? sweepLow - stopBufferPts : na
shortStop = not na(sweepHigh) ? sweepHigh + stopBufferPts : na
longRiskPts = not na(longReclaimHigh) and not na(longStop) ? longReclaimHigh - longStop : na
shortRiskPts = not na(shortReclaimLow) and not na(shortStop) ? shortStop - shortReclaimLow : na
roomText = longReclaimReady or longTrigger ? "Check 2R" : shortReclaimReady or shortTrigger ? "Check 2R" : "N/A"

//========================
// Plots: Levels only during NY session
//========================
plotVisible = inNY

plot(showORLevels and plotVisible and orSet ? orHigh : na, "ORH", color=color.new(bullColor, 10), linewidth=2, style=plot.style_linebr)
plot(showORLevels and plotVisible and orSet ? orLow : na, "ORL", color=color.new(bearColor, 10), linewidth=2, style=plot.style_linebr)
plot(showMid and plotVisible and orSet ? orMid : na, "OR Mid", color=color.new(neutralColor, 35), linewidth=1, style=plot.style_linebr)

plot(showPMLevels and plotVisible ? pmHigh : na, "PMH", color=color.new(bullColor, 45), linewidth=1, style=plot.style_linebr)
plot(showPMLevels and plotVisible ? pmLow : na, "PML", color=color.new(bearColor, 45), linewidth=1, style=plot.style_linebr)

plot(showPDLevels and plotVisible ? pdHigh : na, "PDH", color=color.new(bullColor, 65), linewidth=1, style=plot.style_linebr)
plot(showPDLevels and plotVisible ? pdLow : na, "PDL", color=color.new(bearColor, 65), linewidth=1, style=plot.style_linebr)

// Optional labels on last bar only.
var label pmhLabel = na
var label pmlLabel = na
var label pdhLabel = na
var label pdlLabel = na
var label orhLabel = na
var label orlLabel = na

if barstate.islast and showLevelLabels
    label.delete(pmhLabel), label.delete(pmlLabel), label.delete(pdhLabel), label.delete(pdlLabel), label.delete(orhLabel), label.delete(orlLabel)
    if showPMLevels and not na(pmHigh)
        pmhLabel := label.new(bar_index, pmHigh, "PMH", style=label.style_label_left, textcolor=color.white, color=color.new(bullColor, 35), size=size.tiny)
    if showPMLevels and not na(pmLow)
        pmlLabel := label.new(bar_index, pmLow, "PML", style=label.style_label_left, textcolor=color.white, color=color.new(bearColor, 35), size=size.tiny)
    if showPDLevels and not na(pdHigh)
        pdhLabel := label.new(bar_index, pdHigh, "PDH", style=label.style_label_left, textcolor=color.white, color=color.new(bullColor, 65), size=size.tiny)
    if showPDLevels and not na(pdLow)
        pdlLabel := label.new(bar_index, pdLow, "PDL", style=label.style_label_left, textcolor=color.white, color=color.new(bearColor, 65), size=size.tiny)
    if showORLevels and orSet
        orhLabel := label.new(bar_index, orHigh, "ORH", style=label.style_label_left, textcolor=color.white, color=color.new(bullColor, 20), size=size.tiny)
        orlLabel := label.new(bar_index, orLow, "ORL", style=label.style_label_left, textcolor=color.white, color=color.new(bearColor, 20), size=size.tiny)

//========================
// Markers
//========================
plotshape(showSweepMarks and newLongSweep, title="Support Swept", style=shape.circle, location=location.belowbar, color=color.new(warnColor, 0), size=size.tiny)
plotshape(showSweepMarks and newShortSweep, title="Resistance Swept", style=shape.circle, location=location.abovebar, color=color.new(warnColor, 0), size=size.tiny)

plotshape(showReclaimMarks and longReclaim, title="Bullish Reclaim", style=shape.circle, location=location.abovebar, color=color.new(reclaimColor, 0), size=size.tiny, text="R")
plotshape(showReclaimMarks and shortReclaim, title="Bearish Reclaim", style=shape.circle, location=location.belowbar, color=color.new(reclaimColor, 0), size=size.tiny, text="R")

plotshape(showTriggers and longTrigger, title="Long Sweep & Reclaim Trigger", style=shape.triangleup, location=location.belowbar, color=color.new(bullColor, 0), size=size.normal)
plotshape(showTriggers and shortTrigger, title="Short Sweep & Reclaim Trigger", style=shape.triangledown, location=location.abovebar, color=color.new(bearColor, 0), size=size.normal)

//========================
// Dashboard
//========================
levelText = longReclaimReady or longSweepActive ? sweptSupportName : shortReclaimReady or shortSweepActive ? sweptResistanceName : not na(supportLevel) or not na(resistanceLevel) ? "Watching" : "N/A"
sweepText = newLongSweep ? "Below " + supportName : newShortSweep ? "Above " + resistanceName : longSweepActive ? "Below " + sweptSupportName : shortSweepActive ? "Above " + sweptResistanceName : "None"
reclaimText = longTrigger or shortTrigger ? "Triggered" : longReclaimReady ? "Bull Ready" : shortReclaimReady ? "Bear Ready" : longSweepActive or shortSweepActive ? "Waiting" : "N/A"

stateText = longTrigger ? "LONG TRIGGER" : shortTrigger ? "SHORT TRIGGER" : longReclaimReady ? "LONG TRAP" : shortReclaimReady ? "SHORT TRAP" : longSweepActive ? "SWEEP BELOW" : shortSweepActive ? "SWEEP ABOVE" : inNY ? "WAITING" : "OFF SESSION"
actionText = longTrigger ? "Long Trigger" : shortTrigger ? "Short Trigger" : longReclaimReady ? "Buy Stop > R High" : shortReclaimReady ? "Sell Stop < R Low" : longSweepActive or shortSweepActive ? "Wait Reclaim" : inNY ? "Wait Sweep" : "Wait NY"
volDashText = showVolumeContext ? volState + (requireVolForTrigger and not volOK ? " ⚠" : "") : "Off"

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
    table.cell(dash, 0, 0, "SWEEP & RECLAIM", bgcolor=headerBg, text_color=textColor, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 0, stateText, bgcolor=headerBg, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 1, "Level", bgcolor=cellBg, text_color=mutedText, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 1, levelText, bgcolor=cellBg, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 2, "Sweep", bgcolor=cellBg2, text_color=mutedText, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 2, sweepText, bgcolor=cellBg2, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 3, "Reclaim", bgcolor=cellBg, text_color=mutedText, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 3, reclaimText, bgcolor=cellBg, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 4, "Volume", bgcolor=cellBg2, text_color=mutedText, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 4, volDashText, bgcolor=cellBg2, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 5, "Sweep Min", bgcolor=cellBg, text_color=mutedText, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(sweepPts, "#.##") + " pts", bgcolor=cellBg, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 6, "Room", bgcolor=cellBg2, text_color=mutedText, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 6, roomText, bgcolor=cellBg2, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 7, "Action", bgcolor=headerBg, text_color=textColor, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 7, actionText, bgcolor=headerBg, text_color=textColor, text_size=ts, text_halign=text.align_right)

if not showDash and not na(dash)
    table.delete(dash)
    dash := na

//========================
// Alerts
//========================
alertcondition(newLongSweep, title="Support Level Swept", message="FlowScope Sweep & Reclaim: MNQ swept below an obvious support level.")
alertcondition(newShortSweep, title="Resistance Level Swept", message="FlowScope Sweep & Reclaim: MNQ swept above an obvious resistance level.")
alertcondition(longReclaim, title="Bullish Reclaim Confirmed", message="FlowScope Sweep & Reclaim: Price reclaimed support after sweep. Watch long trigger.")
alertcondition(shortReclaim, title="Bearish Reclaim Confirmed", message="FlowScope Sweep & Reclaim: Price lost resistance after sweep. Watch short trigger.")
alertcondition(longTrigger, title="Long Sweep & Reclaim Trigger", message="FlowScope Sweep & Reclaim: Long trigger fired after reclaim.")
alertcondition(shortTrigger, title="Short Sweep & Reclaim Trigger", message="FlowScope Sweep & Reclaim: Short trigger fired after reclaim.")
````
