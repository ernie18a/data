# FlowScope ORB Retest v1.0

- url: https://www.tradingview.com/script/t6gSwybo-FlowScope-ORB-Retest-v1-0/
- type: indicator
- pine_id: PUB;dc1986b8f3f34ed9a7d17a1aff8685b9
- version: 1.0

## Description

What This Indicator Shows

The indicator automatically marks the New York opening range and tracks whether price is breaking, retesting, failing, or chopping around that range.

It includes:

New York session opening range from 9:30–9:45 AM ET
Opening range high and low
Opening range midpoint
Adaptive MNQ retest zones based on ATR
Bullish and bearish retest confirmation markers
Long and short trigger markers
Failed breakout warnings
Two-sided breakout/chop warnings
Relative volume context
Compact dashboard showing the current setup state
Core Setup Logic

The main setup is an Opening Range Breakout Retest.

For a bullish setup, price must break above the opening range high, hold outside the range, and then retest the breakout zone. A long trigger appears only after retest confirmation.

For a bearish setup, price must break below the opening range low, hold outside the range, and then retest the breakdown zone. A short trigger appears only after retest confirmation.

This is designed to avoid chasing the first breakout candle and instead focus on cleaner continuation opportunities after the market shows acceptance outside the opening range.

MNQ-Specific Design

MNQ/NQ often pierces key levels before deciding direction, so this indicator treats the opening range levels as zones, not perfect tick-by-tick lines.

The retest zones are calculated using ATR, with configurable minimum and maximum point values. This helps the indicator adjust to different volatility conditions while staying practical for MNQ.

Dashboard States

The dashboard helps simplify the current market condition:

BUILDING — Opening range is still forming.
WATCH — Range is set, waiting for breakout.
LONG WATCH — Price has broken above the opening range.
SHORT WATCH — Price has broken below the opening range.
LONG RETEST — Bullish retest area is active.
SHORT RETEST — Bearish retest area is active.
LONG TRIGGER — Bullish retest trigger has appeared.
SHORT TRIGGER — Bearish retest trigger has appeared.
FAILED — Breakout failed back inside the range.
TWO-SIDED — Price has broken both sides of the range, increasing chop risk.
Volume Context

The indicator includes a relative volume readout to help judge whether the breakout has meaningful participation behind it.

Volume is not treated as the only signal. It is used as context:

Weak volume may suggest a lower-quality breakout.
Elevated or strong volume may support continuation.
Strong volume followed by failure may signal trap behavior.
Best Used For

This indicator is best used on:

MNQ1!
NQ1!
5-minute charts
New York cash session trading
Opening range breakout/retest playbook execution

It is intended to complement a broader trading process, especially for traders who want to avoid chasing and prefer waiting for confirmation.

Important Notes

This indicator is for education, chart context, and discretionary trading support. It does not guarantee profitable trades and should not be used as a standalone trading system.

Opening range breakouts can fail, especially on choppy or news-driven days. Always use proper risk management, confirm market context, and avoid taking signals blindly.

## Source Code

````pine
//@version=6
indicator("FlowScope ORB Retest — MNQ v1.0", overlay=true, max_boxes_count=50, max_lines_count=50, max_labels_count=100)

//====================================================
// FlowScope ORB Retest — MNQ v1.0
// Purpose: MNQ-focused Opening Range Breakout Retest
// Notes:
// - Designed for 5-minute MNQ1! charts.
// - Uses the 8:30–8:45 AM America/Chicago opening range by default.
// - Marks ORH/ORL/MID, adaptive retest zones, setup states, volume context, and alerts.
//====================================================

//========================
// Inputs
//========================
groupSession = "Session"
tzInput      = input.string("America/New_York", "Session Timezone", group=groupSession)
orSession    = input.session("0930-0945", "Opening Range Window", group=groupSession)
tradeSession = input.session("0930-1700", "Active Session Window", group=groupSession)

showORBox    = input.bool(true, "Show Opening Range Box", group=groupSession)
showMid      = input.bool(true, "Show OR Midpoint", group=groupSession)
showZones    = input.bool(true, "Show MNQ Retest Zones", group=groupSession)

// MNQ / volatility settings
groupMNQ = "MNQ Volatility Settings"
atrLen             = input.int(14, "ATR Length", minval=1, group=groupMNQ)
zoneAtrMult         = input.float(0.20, "Retest Zone = ATR ×", minval=0.01, step=0.01, group=groupMNQ)
minZonePts          = input.float(4.0, "Minimum Zone Points", minval=0.25, step=0.25, group=groupMNQ)
maxZonePts          = input.float(15.0, "Maximum Zone Points", minval=0.25, step=0.25, group=groupMNQ)
extendedAtrMult     = input.float(0.75, "Extended Breakout Threshold = ATR ×", minval=0.10, step=0.05, group=groupMNQ)
stopBufferPts       = input.float(3.0, "Suggested Stop Buffer Points", minval=0.25, step=0.25, group=groupMNQ)

// Volume settings
groupVol = "Volume Context"
showVolumeContext = input.bool(true, "Show Volume Context", group=groupVol)
volLen            = input.int(20, "Relative Volume Length", minval=1, group=groupVol)
elevatedVol       = input.float(1.20, "Elevated Volume Threshold", minval=0.1, step=0.05, group=groupVol)
strongVol         = input.float(1.80, "Strong Volume Threshold", minval=0.1, step=0.05, group=groupVol)
weakVol           = input.float(0.80, "Weak Volume Threshold", minval=0.1, step=0.05, group=groupVol)
requireVolume     = input.bool(false, "Require Elevated Volume For Trigger", group=groupVol)

// Visual settings
groupVisual = "Visuals"
showBreakMarkers = input.bool(false, "Show Breakout Markers", group=groupVisual)
showRetestMarks  = input.bool(true, "Show Retest Active Markers", group=groupVisual)
showTriggers     = input.bool(true, "Show Trigger Arrows", group=groupVisual)
showLabels       = input.bool(false, "Show OR Text Labels", group=groupVisual)

bullColor    = input.color(color.rgb(0, 190, 120), "Bull Color", group=groupVisual)
bearColor    = input.color(color.rgb(220, 70, 70), "Bear Color", group=groupVisual)
neutralColor = input.color(color.rgb(150, 150, 150), "Neutral Color", group=groupVisual)
warnColor    = input.color(color.rgb(235, 175, 55), "Warning Color", group=groupVisual)

// Dashboard settings
groupDash = "Dashboard"
showDash = input.bool(true, "Show Dashboard", group=groupDash)
dashPos  = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupDash)
dashSize = input.string("Small", "Dashboard Text Size", options=["Tiny", "Small", "Normal"], group=groupDash)

//========================
// Helpers
//========================
f_clamp(x, lo, hi) =>
    math.min(math.max(x, lo), hi)

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
    state == "LONG WATCH" or state == "LONG RETEST" or state == "LONG TRIGGER" ? bullColor :
     state == "SHORT WATCH" or state == "SHORT RETEST" or state == "SHORT TRIGGER" ? bearColor :
     state == "FAILED" or state == "TWO-SIDED" ? warnColor :
     neutralColor

//========================
// Session Detection
//========================
inOR      = not na(time(timeframe.period, orSession, tzInput))
inSession = not na(time(timeframe.period, tradeSession, tzInput))
startOR   = inOR and not inOR[1]
endOR     = not inOR and inOR[1]

//========================
// Core Calculations
//========================
atr = ta.atr(atrLen)
zonePts = f_clamp(atr * zoneAtrMult, minZonePts, maxZonePts)
extendedPts = atr * extendedAtrMult

volAvg = ta.sma(volume, volLen)
rvol = volAvg > 0 ? volume / volAvg : na
volState = na(rvol) ? "N/A" : rvol < weakVol ? "Weak" : rvol < elevatedVol ? "Normal" : rvol < strongVol ? "Elevated" : "Strong"
volSupports = not requireVolume or rvol >= elevatedVol

//========================
// Persistent OR State
//========================
var float orHigh = na
var float orLow = na
var float orMid = na
var bool rangeSet = false

var bool brokeUp = false
var bool brokeDn = false
var bool failedUp = false
var bool failedDn = false
var bool twoSided = false

var int upBreakBar = na
var int dnBreakBar = na

var bool longRetestActive = false
var bool shortRetestActive = false
var float longRetestLow = na
var float shortRetestHigh = na
var float longConfirmHigh = na
var float shortConfirmLow = na

var box orBox = na
var label orhLabel = na
var label orlLabel = na
var label midLabel = na

// Reset and build opening range
if startOR
    orHigh := high
    orLow := low
    orMid := na
    rangeSet := false
    brokeUp := false
    brokeDn := false
    failedUp := false
    failedDn := false
    twoSided := false
    upBreakBar := na
    dnBreakBar := na
    longRetestActive := false
    shortRetestActive := false
    longRetestLow := na
    shortRetestHigh := na
    longConfirmHigh := na
    shortConfirmLow := na
    if not na(orBox)
        box.delete(orBox)
    if showORBox
        orBox := box.new(left=bar_index, top=high, right=bar_index, bottom=low, bgcolor=color.new(neutralColor, 88), border_color=color.new(neutralColor, 45))
    if not na(orhLabel)
        label.delete(orhLabel)
    if not na(orlLabel)
        label.delete(orlLabel)
    if not na(midLabel)
        label.delete(midLabel)

if inOR
    orHigh := math.max(nz(orHigh, high), high)
    orLow := math.min(nz(orLow, low), low)
    orMid := (orHigh + orLow) / 2.0
    if showORBox and not na(orBox)
        box.set_top(orBox, orHigh)
        box.set_bottom(orBox, orLow)
        box.set_right(orBox, bar_index)

if endOR
    rangeSet := true
    orMid := (orHigh + orLow) / 2.0
    if showLabels
        orhLabel := label.new(bar_index, orHigh, "ORH", style=label.style_label_left, textcolor=color.white, color=color.new(bullColor, 20), size=size.tiny)
        orlLabel := label.new(bar_index, orLow, "ORL", style=label.style_label_left, textcolor=color.white, color=color.new(bearColor, 20), size=size.tiny)
        if showMid
            midLabel := label.new(bar_index, orMid, "MID", style=label.style_label_left, textcolor=color.white, color=color.new(neutralColor, 30), size=size.tiny)

// Keep labels near current bar, but only during the active NY session.
if rangeSet and showLabels and inSession
    if not na(orhLabel)
        label.set_x(orhLabel, bar_index)
        label.set_y(orhLabel, orHigh)
    if not na(orlLabel)
        label.set_x(orlLabel, bar_index)
        label.set_y(orlLabel, orLow)
    if showMid and not na(midLabel)
        label.set_x(midLabel, bar_index)
        label.set_y(midLabel, orMid)

//========================
// Breakout / Retest Logic
//========================
canEvaluate = rangeSet and inSession and not inOR

bullBreak = canEvaluate and not brokeUp and close > orHigh
bearBreak = canEvaluate and not brokeDn and close < orLow

if bullBreak
    brokeUp := true
    upBreakBar := bar_index
    if brokeDn
        twoSided := true

if bearBreak
    brokeDn := true
    dnBreakBar := bar_index
    if brokeUp
        twoSided := true

// Failure: breakout closes back inside its boundary after the breakout has happened.
if canEvaluate and brokeUp and bar_index > nz(upBreakBar, bar_index) and close < orHigh
    failedUp := true

if canEvaluate and brokeDn and bar_index > nz(dnBreakBar, bar_index) and close > orLow
    failedDn := true

// Retest zones around ORH/ORL.
orhZoneTop = orHigh + zonePts
orhZoneBot = orHigh - zonePts
orlZoneTop = orLow + zonePts
orlZoneBot = orLow - zonePts

longInRetestZone = canEvaluate and brokeUp and not failedUp and low <= orhZoneTop and high >= orhZoneBot
shortInRetestZone = canEvaluate and brokeDn and not failedDn and high >= orlZoneBot and low <= orlZoneTop

// Confirmation candle: tests zone, rejects, and closes back on the correct side.
longConfirm = longInRetestZone and close > orHigh and close > open
shortConfirm = shortInRetestZone and close < orLow and close < open

if longConfirm
    longRetestActive := true
    longRetestLow := low
    longConfirmHigh := high

if shortConfirm
    shortRetestActive := true
    shortRetestHigh := high
    shortConfirmLow := low

// Trigger occurs on the bar after confirmation if price breaks confirmation candle high/low.
longTrigger = canEvaluate and longRetestActive[1] and not failedUp and high > nz(longConfirmHigh[1]) and volSupports
shortTrigger = canEvaluate and shortRetestActive[1] and not failedDn and low < nz(shortConfirmLow[1]) and volSupports

if longTrigger
    longRetestActive := false

if shortTrigger
    shortRetestActive := false

// Extension context
bullExtended = brokeUp and close > orHigh + extendedPts
bearExtended = brokeDn and close < orLow - extendedPts

// Suggested risk context from confirmation structure
longStop = not na(longRetestLow) ? longRetestLow - stopBufferPts : na
shortStop = not na(shortRetestHigh) ? shortRetestHigh + stopBufferPts : na
longRiskPts = not na(longConfirmHigh) and not na(longStop) ? longConfirmHigh - longStop : na
shortRiskPts = not na(shortConfirmLow) and not na(shortStop) ? shortStop - shortConfirmLow : na

// Simple room check: can price move 2R before hitting the opposite side of the OR/mid? This is intentionally conservative.
longRoomClear = not na(longRiskPts) ? (close + 2.0 * longRiskPts > close) : false
shortRoomClear = not na(shortRiskPts) ? (close - 2.0 * shortRiskPts < close) : false
roomText = longTrigger or (brokeUp and not failedUp) ? (longRoomClear ? "Clear" : "Check") : shortTrigger or (brokeDn and not failedDn) ? (shortRoomClear ? "Clear" : "Check") : "N/A"

//========================
// Plots
//========================
// Keep all OR levels/zones contained inside the NY cash-session window.
plotVisible = inSession and (rangeSet or inOR)

plotORH = plot(plotVisible ? orHigh : na, "ORH", color=color.new(bullColor, 0), linewidth=2, style=plot.style_linebr)
plotORL = plot(plotVisible ? orLow : na, "ORL", color=color.new(bearColor, 0), linewidth=2, style=plot.style_linebr)
plotMID = plot(showMid and plotVisible ? orMid : na, "OR Mid", color=color.new(neutralColor, 30), linewidth=1, style=plot.style_linebr)

plotORHZoneTop = plot(showZones and plotVisible ? orhZoneTop : na, "ORH Zone Top", color=color.new(bullColor, 85), style=plot.style_linebr)
plotORHZoneBot = plot(showZones and plotVisible ? orhZoneBot : na, "ORH Zone Bottom", color=color.new(bullColor, 85), style=plot.style_linebr)
plotORLZoneTop = plot(showZones and plotVisible ? orlZoneTop : na, "ORL Zone Top", color=color.new(bearColor, 85), style=plot.style_linebr)
plotORLZoneBot = plot(showZones and plotVisible ? orlZoneBot : na, "ORL Zone Bottom", color=color.new(bearColor, 85), style=plot.style_linebr)

fill(plotORHZoneTop, plotORHZoneBot, color=showZones ? color.new(bullColor, 92) : na, title="ORH Retest Zone")
fill(plotORLZoneTop, plotORLZoneBot, color=showZones ? color.new(bearColor, 92) : na, title="ORL Retest Zone")

// Markers
plotshape(showBreakMarkers and bullBreak, title="Bullish OR Breakout", style=shape.triangleup, location=location.belowbar, color=color.new(bullColor, 0), size=size.tiny)
plotshape(showBreakMarkers and bearBreak, title="Bearish OR Breakout", style=shape.triangledown, location=location.abovebar, color=color.new(bearColor, 0), size=size.tiny)

// RT marks are deliberately placed opposite the trigger arrows:
// - Bullish retest confirmation marks above the candle.
// - Bearish retest confirmation marks below the candle.
plotshape(showRetestMarks and longConfirm, title="Long Retest Confirming", style=shape.circle, location=location.abovebar, color=color.new(bullColor, 0), size=size.tiny, text="RT")
plotshape(showRetestMarks and shortConfirm, title="Short Retest Confirming", style=shape.circle, location=location.belowbar, color=color.new(bearColor, 0), size=size.tiny, text="RT")

// Trigger markers use fixed-size triangles instead of arrow shapes.
// Arrow shapes can visually distort or feel tiny when zoomed far out.
plotshape(showTriggers and longTrigger, title="Long ORB Retest Trigger", style=shape.triangleup, location=location.belowbar, color=color.new(bullColor, 0), size=size.normal)
plotshape(showTriggers and shortTrigger, title="Short ORB Retest Trigger", style=shape.triangledown, location=location.abovebar, color=color.new(bearColor, 0), size=size.normal)

plotshape(twoSided and not twoSided[1], title="Two-Sided OR Break Warning", style=shape.diamond, location=location.abovebar, color=color.new(warnColor, 0), size=size.tiny, text="2S")
plotshape((failedUp and not failedUp[1]) or (failedDn and not failedDn[1]), title="Failed OR Break Warning", style=shape.xcross, location=location.abovebar, color=color.new(warnColor, 0), size=size.tiny, text="FAIL")

//========================
// Dashboard State
//========================
rangeText = inOR ? "Building" : rangeSet ? "Set" : "Waiting"

biasText = twoSided ? "Neutral" : brokeUp and not failedUp ? "Long" : brokeDn and not failedDn ? "Short" : "Neutral"
breakText = bullBreak ? "Above ORH" : bearBreak ? "Below ORL" : brokeUp and not failedUp ? "Above ORH" : brokeDn and not failedDn ? "Below ORL" : failedUp or failedDn ? "Failed" : "None"
retestText = longTrigger or shortTrigger ? "Triggered" : longRetestActive ? "Long Ready" : shortRetestActive ? "Short Ready" : longInRetestZone ? "Long Active" : shortInRetestZone ? "Short Active" : brokeUp or brokeDn ? "Waiting" : "N/A"

stateText = inOR ? "BUILDING" : twoSided ? "TWO-SIDED" : failedUp or failedDn ? "FAILED" : longTrigger ? "LONG TRIGGER" : shortTrigger ? "SHORT TRIGGER" : longRetestActive or longInRetestZone ? "LONG RETEST" : shortRetestActive or shortInRetestZone ? "SHORT RETEST" : brokeUp and not failedUp ? "LONG WATCH" : brokeDn and not failedDn ? "SHORT WATCH" : rangeSet ? "WATCH" : "WAIT"

actionText = inOR ? "Wait" : twoSided ? "Caution" : failedUp or failedDn ? "No Trade" : longTrigger ? "Long Trigger" : shortTrigger ? "Short Trigger" : longRetestActive ? "Buy Stop > RT High" : shortRetestActive ? "Sell Stop < RT Low" : longInRetestZone or shortInRetestZone ? "Wait Confirm" : brokeUp or brokeDn ? (bullExtended or bearExtended ? "Wait Retest" : "Prepare") : "Wait Break"

volDashText = showVolumeContext ? volState + (requireVolume and not volSupports ? " ⚠" : "") : "Off"

// Dashboard colors
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
    table.cell(dash, 0, 0, "ORB RETEST", bgcolor=headerBg, text_color=textColor, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 0, stateText, bgcolor=headerBg, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 1, "Range", bgcolor=cellBg, text_color=mutedText, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 1, rangeText, bgcolor=cellBg, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 2, "Bias", bgcolor=cellBg2, text_color=mutedText, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 2, biasText, bgcolor=cellBg2, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 3, "Break", bgcolor=cellBg, text_color=mutedText, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 3, breakText, bgcolor=cellBg, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 4, "Retest", bgcolor=cellBg2, text_color=mutedText, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 4, retestText, bgcolor=cellBg2, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 5, "Volume", bgcolor=cellBg, text_color=mutedText, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 5, volDashText, bgcolor=cellBg, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 6, "Zone", bgcolor=cellBg2, text_color=mutedText, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(zonePts, "#.##") + " pts", bgcolor=cellBg2, text_color=textColor, text_size=ts, text_halign=text.align_right)

    table.cell(dash, 0, 7, "Action", bgcolor=headerBg, text_color=textColor, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, 7, actionText, bgcolor=headerBg, text_color=textColor, text_size=ts, text_halign=text.align_right)

if not showDash and not na(dash)
    table.delete(dash)
    dash := na

//========================
// Alerts
//========================
alertcondition(endOR, title="ORB Range Complete", message="FlowScope ORB Retest: Opening range is complete.")
alertcondition(bullBreak, title="Bullish OR Breakout", message="FlowScope ORB Retest: MNQ closed above opening range high.")
alertcondition(bearBreak, title="Bearish OR Breakout", message="FlowScope ORB Retest: MNQ closed below opening range low.")
alertcondition(longConfirm, title="Long Retest Active", message="FlowScope ORB Retest: Long retest confirmation candle detected near ORH zone.")
alertcondition(shortConfirm, title="Short Retest Active", message="FlowScope ORB Retest: Short retest confirmation candle detected near ORL zone.")
alertcondition(longTrigger, title="Long ORB Retest Trigger", message="FlowScope ORB Retest: Long trigger fired. Check entry above retest confirmation high.")
alertcondition(shortTrigger, title="Short ORB Retest Trigger", message="FlowScope ORB Retest: Short trigger fired. Check entry below retest confirmation low.")
alertcondition((failedUp and not failedUp[1]) or (failedDn and not failedDn[1]), title="Failed OR Breakout", message="FlowScope ORB Retest: OR breakout failed back inside range.")
alertcondition(twoSided and not twoSided[1], title="Two-Sided OR Break Warning", message="FlowScope ORB Retest: Price has broken both sides of the opening range. Chop risk increased.")
````
