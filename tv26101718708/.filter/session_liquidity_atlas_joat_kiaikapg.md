# Session Liquidity Atlas [JOAT]

- url: https://www.tradingview.com/script/KiaiKapg-Session-Liquidity-Atlas-JOAT/
- type: indicator
- pine_id: PUB;f3277f7286f44e429a1d18cadc7249cd
- version: 1.0

## Description

[b]Session Liquidity Atlas [JOAT][/b]

[b]Introduction[/b]

SLA Session Liquidity Atlas is an open-source session context indicator built to map the active trading session, opening range, prior-session liquidity, confirmed sweeps, and confirmed opening-range breaks in one clean overlay.

The problem it solves is session context. A breakout above the opening range means something different when the prior-session high was just swept, when the session range is compressed, or when price is still trapped inside the opening band. SLA organizes those reference points into a readable liquidity atlas with a top-right dashboard and restrained dark-mode chart shading.

[b]Core Concepts[/b]

[b]1. Active Session Range[/b]
The indicator tracks the selected session's open, high, low, close, bar count, and live range. The session band updates during the active window and freezes naturally when the session ends.

[b]2. Opening Range[/b]
The opening range is built from the first configurable number of session minutes. Confirmed closes above or below the opening range define bullish or bearish break events.

[b]3. Prior-Session Liquidity[/b]
Prior-session high and low are projected forward as liquidity reference levels. A sweep is confirmed only when price trades through a prior level but closes back inside it on a confirmed bar.

[b]4. Confirmed Bias State[/b]
Bias updates from opening-range breaks and mature sweep states. All official events use confirmed bars, avoiding realtime-only signals being mistaken for final signals.

[b]5. Visual System[/b]
The overlay uses transparent session bands, opening-range shading, prior-session reference lines, and a compact dashboard. No arrows or retail-style marker clutter are used.

[image]https://www.tradingview.com/x/e623LDmU/[/image]

[b]Features[/b]

[list]
[*][b]Session range band:[/b] Tracks live high and low of the selected session
[*][b]Opening range band:[/b] Displays the early-session decision range
[*][b]Prior-session liquidity levels:[/b] Projects prior high and low as reference lines
[*][b]Confirmed sweep detection:[/b] Detects high/low sweeps only after bar close
[*][b]Confirmed opening-range breaks:[/b] Break events require closed-bar confirmation
[*][b]Bias tinting:[/b] Background gently reflects current bullish, bearish, or neutral state
[*][b]Top-right dashboard:[/b] Shows session status, bias, sweep state, breakout state, range, OR/session ratio, and body balance
[*][b]Alert conditions:[/b] Includes confirmed alerts for sweeps and opening-range breaks
[/list]

[b]Input Parameters[/b]

[b]Session:[/b]
[list]
[*]Primary Session: Session window used by the atlas
[*]Opening Range Minutes: Number of minutes used to build the opening range
[*]Sweep Hold Bars: Bars required before a sweep state matures into bias context
[/list]

[b]Visual:[/b]
[list]
[*]Show Session Band
[*]Show Opening Range Band
[*]Show Prior Session Liquidity
[*]Tint Background On Bias
[*]Line Width and transparency controls
[/list]

[b]How to Use[/b]

[b]Step 1:[/b] Read the dashboard bias and session status.

[b]Step 2:[/b] Watch whether price is inside or outside the opening range.

[b]Step 3:[/b] Treat prior-session high and low as liquidity reference levels, not guaranteed reversal points.

[b]Step 4:[/b] Use confirmed sweeps and confirmed opening-range breaks as context for another entry model or discretionary plan.

[b]Limitations[/b]

[list]
[*]Opening-range logic depends on the selected session and chart timeframe
[*]A sweep can fail and continue beyond the prior level
[*]The indicator is a context layer, not a complete trading system
[*]Signals confirm only after the bar closes, so they intentionally appear after the event candle is complete
[/list]

[b]Originality Statement[/b]

SLA is an original JOAT implementation combining session range logic, prior-session liquidity sweeps, opening-range breaks, and a compact state dashboard into one transformed Pine Script v6 overlay. It is not a copy of any source script.

[b]Disclaimer[/b]

This script is for educational and informational purposes only. It is not financial advice and does not guarantee future results. Trading involves risk, and users should apply their own risk management.

Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Session Liquidity Atlas [JOAT]", "SLA [JOAT]", overlay=true, max_lines_count=200, max_labels_count=50, max_boxes_count=20, max_bars_back=5000)

//------------------------------------------------------------------------------//
// Session Liquidity Atlas
// Tracks session range, opening range, prior-session liquidity, and confirmed
// sweep/breakout states using only confirmed bars for persistent signals.
//------------------------------------------------------------------------------//

// ---------- Inputs
slaGroupSession = "Session"
slaGroupLevels  = "Liquidity Levels"
slaGroupVisual  = "Visual"
slaGroupDash    = "Dashboard"

sessInput     = input.session("0930-1600", "Primary Session", group=slaGroupSession, tooltip="Session used for the active liquidity atlas.")
orMinutes     = input.int(30, "Opening Range Minutes", minval=5, maxval=180, group=slaGroupSession)
holdBars      = input.int(3, "Sweep Hold Bars", minval=1, maxval=10, group=slaGroupSession, tooltip="Bars to wait after a sweep before the state is considered mature.")

showSession   = input.bool(true, "Show Session Band", group=slaGroupVisual)
showOpening   = input.bool(true, "Show Opening Range Band", group=slaGroupVisual)
showPrev      = input.bool(true, "Show Prior Session Liquidity", group=slaGroupVisual)
showEquilibrium = input.bool(true, "Show Equilibrium + VWAP", group=slaGroupVisual)
showTargets   = input.bool(true, "Show OR Expansion Targets", group=slaGroupLevels)
showSignalText = input.bool(true, "Show Clean Signal Labels", group=slaGroupVisual)
showBackground = input.bool(true, "Tint Background On Bias", group=slaGroupVisual)
showDash      = input.bool(true, "Show Dashboard", group=slaGroupDash)

lineWidth     = input.int(2, "Line Width", minval=1, maxval=4, group=slaGroupVisual)
transBand     = input.int(84, "Band Transparency", minval=60, maxval=95, group=slaGroupVisual)
transLine     = input.int(0, "Line Transparency", minval=0, maxval=80, group=slaGroupVisual)
orWindowBars  = math.max(1, int(math.ceil(orMinutes / timeframe.multiplier)))

// ---------- Palette
colBull  = color.rgb(8, 153, 129)
colBear  = color.rgb(242, 54, 69)
colNeut  = color.rgb(138, 151, 171)
colBlue  = color.rgb(91, 156, 246)
colViolet = color.rgb(166, 120, 255)
colAmber = color.rgb(245, 173, 66)
colDeep  = color.rgb(13, 17, 24)
colMid   = color.rgb(21, 28, 38)
colText  = color.rgb(225, 232, 240)
colGrid  = color.rgb(54, 64, 82)

// ---------- Helpers
f_sessionActive(_sess) =>
    not na(time(timeframe.period, _sess))

f_safeRange(_h, _l) =>
    math.max(_h - _l, syminfo.mintick)

f_biasColor(_bias) =>
    _bias > 0 ? colBull : _bias < 0 ? colBear : colNeut

// ---------- Persistent state
var float sessOpen  = na
var float sessHigh  = na
var float sessLow   = na
var float sessClose = na
var int   sessBars  = 0
var int   sessStart = na

var float orHigh = na
var float orLow  = na
var int orBars   = 0

var float prevSessHigh = na
var float prevSessLow  = na
var float prevSessOpen = na
var float prevSessClose = na
var float prevSessRange = na

var float confirmedSweepHigh = na
var float confirmedSweepLow  = na
var int sweepHighAge = 0
var int sweepLowAge  = 0

var int biasState = 0
var int breakoutState = 0
var int sweepState = 0
var bool sweepAbove = false
var bool sweepBelow = false

var box sessionBox = na
var box openingBox = na
var label signalTag = na

var float sessionPv = 0.0
var float sessionVol = 0.0

// ---------- Session detection
inSession = f_sessionActive(sessInput)
prevInSession = bar_index > 0 ? inSession[1] : false
sessionStart = inSession and not prevInSession
sessionEnd = not inSession and prevInSession
confirmedBar = barstate.isconfirmed

// ---------- Reset and roll forward confirmed state
if confirmedBar and sessionStart
    prevSessOpen := sessOpen
    prevSessHigh := sessHigh
    prevSessLow := sessLow
    prevSessClose := sessClose
    prevSessRange := not na(sessHigh) and not na(sessLow) ? f_safeRange(sessHigh, sessLow) : na

    sessOpen := open
    sessHigh := high
    sessLow := low
    sessClose := close
    sessBars := 1
    sessStart := bar_index

    orHigh := high
    orLow := low
    orBars := 1
    sessionPv := hlc3 * volume
    sessionVol := volume

    biasState := 0
    breakoutState := 0
    sweepState := 0
    confirmedSweepHigh := na
    confirmedSweepLow := na
    sweepHighAge := 0
    sweepLowAge := 0
else if confirmedBar and inSession
    sessHigh := na(sessHigh) ? high : math.max(sessHigh, high)
    sessLow := na(sessLow) ? low : math.min(sessLow, low)
    sessClose := close
    sessBars += 1
    sessionPv += hlc3 * volume
    sessionVol += volume

    if sessBars <= orWindowBars
        orHigh := na(orHigh) ? high : math.max(orHigh, high)
        orLow := na(orLow) ? low : math.min(orLow, low)
        orBars += 1

    // Confirmed sweep logic against prior session liquidity.
    sweepAbove := not na(prevSessHigh) and high > prevSessHigh and close < prevSessHigh
    sweepBelow := not na(prevSessLow) and low < prevSessLow and close > prevSessLow

    if sweepAbove
        confirmedSweepHigh := prevSessHigh
        sweepHighAge := 0
        sweepState := -1
    else
        sweepHighAge += 1

    if sweepBelow
        confirmedSweepLow := prevSessLow
        sweepLowAge := 0
        sweepState := 1
    else
        sweepLowAge += 1

    // Breakout bias is only updated on confirmed closes.
    orBreakUp = showOpening and not na(orHigh) and close > orHigh and close[1] <= orHigh
    orBreakDn = showOpening and not na(orLow) and close < orLow and close[1] >= orLow

    if orBreakUp
        breakoutState := 1
        biasState := 1
    else if orBreakDn
        breakoutState := -1
        biasState := -1
    else if sweepState == -1 and sweepHighAge >= holdBars and close < open
        biasState := -1
    else if sweepState == 1 and sweepLowAge >= holdBars and close > open
        biasState := 1
    else
        biasState := biasState == 0 ? (close >= open ? 1 : -1) : biasState

// Roll over trailing state on confirmed session end.
if confirmedBar and sessionEnd
    prevSessOpen := sessOpen
    prevSessHigh := sessHigh
    prevSessLow := sessLow
    prevSessClose := sessClose
    prevSessRange := not na(sessHigh) and not na(sessLow) ? f_safeRange(sessHigh, sessLow) : na

// ---------- Derived context
sessRange = not na(sessHigh) and not na(sessLow) ? f_safeRange(sessHigh, sessLow) : na
orRange   = not na(orHigh) and not na(orLow) ? f_safeRange(orHigh, orLow) : na
sessionMid = not na(sessHigh) and not na(sessLow) ? (sessHigh + sessLow) * 0.5 : na
sessionVWAP = sessionVol > 0 ? sessionPv / sessionVol : na
orExtUp = not na(orHigh) and not na(orRange) ? orHigh + orRange * 0.5 : na
orExtDn = not na(orLow) and not na(orRange) ? orLow - orRange * 0.5 : na
rangeCompression = not na(sessRange) and not na(orRange) ? orRange / sessRange : na
bodyBalance = sessBars > 0 and not na(sessOpen) and not na(sessClose) ? (sessClose - sessOpen) / f_safeRange(sessHigh, sessLow) : 0.0
vwapDelta = not na(sessionVWAP) and not na(sessRange) ? (close - sessionVWAP) / sessRange : 0.0
liquidityScore = math.max(0.0, math.min(100.0, 50.0 + 35.0 * bodyBalance + 20.0 * vwapDelta + 10.0 * (breakoutState + sweepState)))
liquidityColor = f_biasColor(biasState)

// ---------- Visual bands
pSessHigh = plot(showSession and inSession ? sessHigh : na, "Session High", color=color.new(liquidityColor, transLine), linewidth=lineWidth, style=plot.style_linebr)
pSessLow  = plot(showSession and inSession ? sessLow : na, "Session Low", color=color.new(liquidityColor, transLine), linewidth=lineWidth, style=plot.style_linebr)
fill(pSessHigh, pSessLow, color=color.new(liquidityColor, transBand), title="Session Band")

pOrHigh = plot(showOpening and inSession ? orHigh : na, "Opening Range High", color=color.new(colText, 20), linewidth=1, style=plot.style_linebr)
pOrLow  = plot(showOpening and inSession ? orLow : na, "Opening Range Low", color=color.new(colText, 20), linewidth=1, style=plot.style_linebr)
fill(pOrHigh, pOrLow, color=color.new(colText, 88), title="Opening Range Band")

pMid = plot(showEquilibrium and inSession ? sessionMid : na, "Session Equilibrium", color=color.new(colBlue, 25), linewidth=1, style=plot.style_linebr)
pVwap = plot(showEquilibrium and inSession ? sessionVWAP : na, "Session VWAP", color=color.new(colViolet, 0), linewidth=2, style=plot.style_linebr)
fill(pMid, pVwap, color=showEquilibrium ? color.new(close >= sessionVWAP ? colBull : colBear, 90) : na, title="VWAP Equilibrium Gradient")

plot(showTargets and inSession ? orExtUp : na, "OR Upside Expansion", color=color.new(colAmber, 25), linewidth=1, style=plot.style_linebr)
plot(showTargets and inSession ? orExtDn : na, "OR Downside Expansion", color=color.new(colAmber, 25), linewidth=1, style=plot.style_linebr)

pPrevHigh = plot(showPrev and not na(prevSessHigh) ? prevSessHigh : na, "Prior Session High", color=color.new(colBull, 35), linewidth=1, style=plot.style_linebr)
pPrevLow  = plot(showPrev and not na(prevSessLow) ? prevSessLow : na, "Prior Session Low", color=color.new(colBear, 35), linewidth=1, style=plot.style_linebr)

// ---------- Background regime tint
bgcolor(showBackground ? color.new(liquidityColor, biasState == 0 ? 95 : 92) : na)

// ---------- Session box management
if confirmedBar and inSession
    if na(sessionBox)
        sessionBox := box.new(left=sessStart, top=sessHigh, right=bar_index, bottom=sessLow, bgcolor=color.new(liquidityColor, 92), border_color=color.new(liquidityColor, 80))
    else
        box.set_left(sessionBox, sessStart)
        box.set_right(sessionBox, bar_index)
        box.set_top(sessionBox, sessHigh)
        box.set_bottom(sessionBox, sessLow)
        box.set_bgcolor(sessionBox, color.new(liquidityColor, 92))
        box.set_border_color(sessionBox, color.new(liquidityColor, 80))

    if showOpening
        if na(openingBox)
            openingBox := box.new(left=sessStart, top=orHigh, right=bar_index, bottom=orLow, bgcolor=color.new(colText, 92), border_color=color.new(colText, 88))
        else
            box.set_left(openingBox, sessStart)
            box.set_right(openingBox, math.max(bar_index, sessStart))
            box.set_top(openingBox, orHigh)
            box.set_bottom(openingBox, orLow)
            box.set_bgcolor(openingBox, color.new(colText, 92))
            box.set_border_color(openingBox, color.new(colText, 88))

// Hide boxes when session ends so old ranges do not keep growing.
if confirmedBar and sessionEnd
    if not na(sessionBox)
        box.set_right(sessionBox, bar_index)
    if not na(openingBox)
        box.set_right(openingBox, bar_index)

// ---------- Confirmed signals as text-only markers in the data window
confirmedSweepHighEvent = confirmedBar and sweepAbove
confirmedSweepLowEvent  = confirmedBar and sweepBelow
confirmedBreakUpEvent   = confirmedBar and not na(orHigh) and close > orHigh and close[1] <= orHigh
confirmedBreakDnEvent   = confirmedBar and not na(orLow) and close < orLow and close[1] >= orLow

if showSignalText and (confirmedSweepHighEvent or confirmedSweepLowEvent or confirmedBreakUpEvent or confirmedBreakDnEvent)
    label.delete(signalTag)
    sigText = confirmedBreakUpEvent ? "OR Break Up" : confirmedBreakDnEvent ? "OR Break Down" : confirmedSweepLowEvent ? "Low Sweep" : "High Sweep"
    sigColor = confirmedBreakUpEvent or confirmedSweepLowEvent ? colBull : colBear
    sigY = confirmedBreakUpEvent or confirmedSweepLowEvent ? low : high
    sigStyle = confirmedBreakUpEvent or confirmedSweepLowEvent ? label.style_label_up : label.style_label_down
    signalTag := label.new(bar_index, sigY, sigText, color=color.new(sigColor, 12), textcolor=colText, style=sigStyle, size=size.normal)

plotchar(confirmedSweepHighEvent, title="Sweep High", char=" ", location=location.top, display=display.none)
plotchar(confirmedSweepLowEvent, title="Sweep Low", char=" ", location=location.bottom, display=display.none)
plotchar(confirmedBreakUpEvent, title="Break Up", char=" ", location=location.top, display=display.none)
plotchar(confirmedBreakDnEvent, title="Break Down", char=" ", location=location.bottom, display=display.none)

alertcondition(confirmedSweepHighEvent, "SLA Prior High Sweep", "SLA confirmed a prior-session high sweep on a closed bar.")
alertcondition(confirmedSweepLowEvent, "SLA Prior Low Sweep", "SLA confirmed a prior-session low sweep on a closed bar.")
alertcondition(confirmedBreakUpEvent, "SLA Opening Range Break Up", "SLA confirmed an opening-range bullish break on a closed bar.")
alertcondition(confirmedBreakDnEvent, "SLA Opening Range Break Down", "SLA confirmed an opening-range bearish break on a closed bar.")

// ---------- Dashboard
var table dash = table.new(position.top_right, 2, 10, bgcolor=color.new(colDeep, 12), frame_color=color.new(colGrid, 35), border_color=color.new(colGrid, 35), frame_width=1)

f_row(_row, _title, _value, _bg) =>
    table.cell(dash, 0, _row, _title, text_color=color.new(colText, 0), bgcolor=_bg, text_size=size.normal)
    table.cell(dash, 1, _row, _value, text_color=color.new(colText, 0), bgcolor=_bg, text_size=size.normal)

if barstate.islast and showDash
    table.clear(dash, 0, 0, 1, 9)
    f_row(0, "Session", inSession ? "Active" : "Closed", color.new(colMid, 0))
    f_row(1, "Bias", biasState > 0 ? "Bullish" : biasState < 0 ? "Bearish" : "Neutral", color.new(f_biasColor(biasState), 78))
    f_row(2, "Sweep", sweepState > 0 ? "Below" : sweepState < 0 ? "Above" : "None", color.new(colMid, 0))
    f_row(3, "Breakout", breakoutState > 0 ? "Up" : breakoutState < 0 ? "Down" : "Waiting", color.new(colMid, 0))
    f_row(4, "Range", na(sessRange) ? "n/a" : str.tostring(sessRange, format.mintick), color.new(colMid, 0))
    f_row(5, "OR/Session", na(rangeCompression) ? "n/a" : str.tostring(rangeCompression * 100.0, "#.0") + "%", color.new(colMid, 0))
    f_row(6, "Body Balance", str.tostring(bodyBalance * 100.0, "#.0") + "%", color.new(colMid, 0))
    f_row(7, "VWAP Delta", str.tostring(vwapDelta * 100.0, "#.0") + "%", color.new(close >= sessionVWAP ? colBull : colBear, 82))
    f_row(8, "Liquidity Score", str.tostring(liquidityScore, "#"), color.new(liquidityScore >= 60 ? colBull : liquidityScore <= 40 ? colBear : colAmber, 78))
    f_row(9, "Equilibrium", close >= sessionMid ? "Premium" : "Discount", color.new(close >= sessionMid ? colBlue : colViolet, 82))
else if barstate.islast and not showDash
    table.clear(dash, 0, 0, 1, 9)
````
