# FRESH Volatility Regime & Range

- url: https://www.tradingview.com/script/0bjrJlUB-FRESH-Volatility-Regime-Range/
- type: indicator
- pine_id: PUB;fde29d7156784ef7a5d86de5f5c3f7b0
- version: 1.0

## Description

[b]FRESH Volatility Regime & Range[/b]

A single dashboard that answers two questions I ask before every session: is the market coiled or stretched right now, and where is price relative to the move the options market expects today?

[b]Why I built it[/b]
Most range tools are static — a fixed ATR band, yesterday's range, a round-number grid. But volatility isn't static. Some sessions open compressed and need to expand; others open already stretched and tend to revert. And a "big" move on a calm day is a normal move on a high-VIX day. I kept switching between three things to read this — opening-range expansion, an ATR sense of "normal," and the VIX-implied expected move — so I combined them into one overlay with a plain-language regime read.

It does two things together:
[list=1]
[*]Regime classification — it measures the realized Initial Balance (IB) range for three windows (Weekly, Daily, Pre‑NY) and compares each to ATR, bucketing the session as COMPRESSED → BALANCED → EXPANDED → STRETCHED. It also reads a VIX state (VOL CRUSH / STABLE / RISING / SHOCK) and rolls everything into a composite regime (e.g. MULTI‑TF COILED, BALANCED AUCTION, LATE EXPANSION, STRETCHED RISK).
[*]Volatility Range — a VIX‑implied expected‑move envelope anchored at the session open: a midline plus bands at ±0.25, ±0.9, and ±1.0× the day's expected move, with the prior session's ±1x shown faintly for reference.
[/list]
Plus Midnight Open and Settlement reference lines, and a summary dashboard.

[b]What it plots[/b]
[list]
[*]IB High/Low lines — Daily IB (09:30–10:30), Pre‑NY IB (04:00–09:30), Weekly IB (optional). The boundaries of each opening range; classic support/resistance and breakout levels. Each line is labeled.
[*]Volatility Range bands — MID (session open) and ±0.25 / ±0.9 / ±1.0× the VIX‑implied expected move, above and below, each labeled.
[*]Midnight Open & Settlement reference lines.
[*]Dashboard — Weekly / Daily / Pre‑NY regime, VIX state, Volatility Range state, and the composite regime at a glance.
[/list]
[b]How to read it[/b]
[list]
[*]Compressed / coiled → the market hasn't used its expected range; favor expansion / breakout scenarios. Stretched → it has run hot; favor mean‑reversion / exhaustion.
[*]Volatility Range zones: Inside ±0.25 (INNER) — price near fair value; rotational / mean‑reversion bias. Between 0.25 and 1.0× (INSIDE 1x) — a normal day's travel. At / beyond ±1.0× (BEYOND 1x) price has used a full expected move; these edges often act as inflection points (reversal on quiet days, or a continuation shelf on trend days — read the context).
[*]IB High/Low — break and hold beyond an IB edge often flips it to support/resistance in the breakout direction; rejection there is a fade.
[*]Composite regime (dashboard) is the one‑line summary to frame everything else.
[/list]
[b]How to use it (scenarios)[/b]
[list]
[*]Reversion: price pushes into a lower band / IB low and stalls — look for absorption or your own confirmation for a fade back toward the mid.
[*]Breakout: price clears an IB high or the +1x band with conviction; on the retest that level can flip to support for a continuation.
[*]Expected‑move context: in a high‑VIX session the ±1x bands sit far apart — give moves room; in a VOL‑CRUSH session they're tight — expect smaller, choppier travel.
[/list]
This is a context / framing tool, not a buy‑sell signal generator. It tells you what kind of day you're likely in so your own setups are taken in the right regime.

[b]The VIX setting[/b]
The bands are sized by the expected move: EM = sessionOpen × (VIX / 100) ÷ √252. That's the "rule of 16" — VIX is annualized implied volatility, and dividing by √252 converts it to a one‑day, one‑standard‑deviation move. At VIX 16 the ±1x band is roughly ±1% from the open; at VIX 32, ~±2%. So the envelope auto‑widens when implied vol is high and tightens when it's low — a volatility‑scaled "fair range for today," not a fixed ATR.

[b]VIX at anchor (default) vs Use live VIX:[/b]
[list]
[*]VIX at anchor (default) — the VIX value is sampled once, at the session‑open anchor, and frozen for the whole session. The expected move (and the bands) are computed once and stay put. This is intentional: the day's expected move is what's priced in at the open, like a settlement‑based expectation, and freezing it gives you stable, non‑repainting reference levels and a clean "how much of the expected move is used" ratio.
[*]Use live VIX (optional) — recomputes the expected move every bar from the current VIX, so the bands drift intraday as vol changes. More "current," but the levels move around (effectively repaint), which makes them less reliable as fixed targets.
[/list]

I recommend leaving it on anchor for clean levels; turn on live VIX only if you specifically want the envelope to track current volatility through the session. (Note: VIX only updates during cash hours, so if you anchor at the Globex/overnight open, the anchor value is effectively the prior cash‑session VIX; anchoring at the regular‑session open uses a fresh value.)
[b]Inputs worth knowing[/b]
[list=1]
[*]Anchor mode — Globex Open or Pit (RTH) Open for the Volatility Range midline.
[*]VIX source — auto (live VIX symbol) or a manual value, plus the anchor/live toggle above.
[*]IB sessions — the Daily / Pre‑NY / Weekly windows are configurable.
[*]Display — toggle each component (IB lines, Volatility Range, Midnight/Settlement, dashboard, labels) and set the Line Label Size (Tiny → Huge).
[/list]

[b]Notes[/b]
[list]
[*]Designed for the 30‑minute chart. I run it on 30m — the IB windows and snapshot timing are calibrated for it (the Daily‑IB read confirms on the 10:30–11:00 bar close, the RTH‑close read on the 16:00–16:30 bar close). It will draw on other timeframes, but 30m is the intended view.
[*]Built for ES / index futures (and instruments where a VIX‑style implied‑vol input makes sense). A VIX (or equivalent) series is required for the Volatility Range.
[*]Levels are anchored per session and reset at the session boundary.
[*]For education / market context only — not financial advice. Test it on your instrument and timeframe before relying on it.
[/list]

by oxkit (kitar.co/fresh)

## Source Code

````pine
//@version=6
// ============================================================================
//  FRESH VOLATILITY REGIME & RANGE
//  Version: 260606  (YYMMDD)
//  Author: oxkit  |  kitar.co/fresh
//
//  What it does:
//    Classifies the ES volatility regime by comparing realized Initial-Balance
//    ranges (Weekly / Daily / Pre-NY) against ATR (COMPRESSED -> STRETCHED),
//    overlays VIX state (crush/stable/rising/shock), and plots VIX-implied
//    "Volatility Range" expected-move levels (MID +/- 0.25 / 0.9 / 1.0x the
//    expected move) anchored at the session open. Also draws Midnight Open and
//    Settlement reference lines and a summary dashboard with a composite regime.
//
// ============================================================================
indicator("FRESH Volatility Regime & Range", overlay=true, max_lines_count=500, max_labels_count=500)

//==============================
// Inputs
//==============================
grpCore = "Core Settings"
atrLen = input.int(14, "ATR Length", group=grpCore)
compressedPct = input.float(0.30, "Compressed Threshold", step=0.05, group=grpCore)
expandedPct = input.float(0.50, "Expanded Threshold", step=0.05, group=grpCore)
stretchedPct = input.float(0.80, "Stretched Threshold", step=0.05, group=grpCore)

grpSessions = "Sessions - New York Time"
dailyIbSession = input.session("0930-1030", "Daily IB Session", group=grpSessions)
globexIbSession = input.session("0400-0930", "Pre-NY IB Session", group=grpSessions)
globexFullSession = input.session("1800-0930", "Full Globex Session", group=grpSessions)

grpDisplay = "Display"
showDaily = input.bool(true, "Show Daily IB", group=grpDisplay)
showGlobex = input.bool(true, "Show Pre-NY IB", group=grpDisplay)
showWeekly = input.bool(false, "Show Weekly IB", group=grpDisplay)
showMidnightOpen = input.bool(true, "Show Midnight Open", group=grpDisplay)
showSettlement = input.bool(true, "Show Settlement", group=grpDisplay)
showVrLabels = input.bool(true, "Show Vol Range Labels", group=grpDisplay)
showIbLabels = input.bool(true, "Show IB Labels", group=grpDisplay)
showDashboard = input.bool(true, "Show Dashboard", group=grpDisplay)

dashboardPositionInput = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpDisplay)

grpStyle = "Styles"
dailyWidth = input.int(2, "Daily IB Thickness", minval=1, maxval=5, group=grpStyle)
globexWidth = input.int(2, "Pre-NY IB Thickness", minval=1, maxval=5, group=grpStyle)
weeklyWidth = input.int(2, "Weekly IB Thickness", minval=1, maxval=5, group=grpStyle)

dailyStyleInput = input.string("Line Break", "Daily IB Style", options=["Line", "Line Break", "Circles"], group=grpStyle)
globexStyleInput = input.string("Circles", "Pre-NY IB Style", options=["Line", "Line Break", "Circles"], group=grpStyle)
weeklyStyleInput = input.string("Line Break", "Weekly IB Style", options=["Line", "Line Break", "Circles"], group=grpStyle)

midnightColor = input.color(color.purple, "Midnight Open Color", group=grpStyle)
midnightWidth = input.int(2, "Midnight Open Thickness", minval=1, maxval=5, group=grpStyle)
midnightLineStyleInput = input.string("Dashed", "Midnight Open Line Style", options=["Solid", "Dashed", "Dotted"], group=grpStyle)

settlementColor = input.color(color.blue, "Settlement Color", group=grpStyle)
settlementWidth = input.int(2, "Settlement Thickness", minval=1, maxval=5, group=grpStyle)
settlementLineStyleInput = input.string("Dotted", "Settlement Line Style", options=["Solid", "Dashed", "Dotted"], group=grpStyle)

labelTextSizeInput = input.string("Tiny", "Line Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=grpStyle)

compressedColor = input.color(color.teal, "Compressed Color", group=grpStyle)
balancedColor = input.color(color.gray, "Balanced Color", group=grpStyle)
expandedColor = input.color(color.orange, "Expanded Color", group=grpStyle)
stretchedColor = input.color(color.red, "Stretched Color", group=grpStyle)

// ---- Volatility Range (implied expected move from VIX) ----
grpVR = "Volatility Range"
showVolRange = input.bool(true,  "Show Volatility Range", group=grpVR)
vrMult1      = input.float(0.25, "Mult 1 (inner)", step=0.05, group=grpVR)
vrMult2      = input.float(0.90, "Mult 2",         step=0.05, group=grpVR)
vrMult3      = input.float(1.00, "Mult 3 (1x zone)", step=0.05, group=grpVR)
vrAnchorMode = input.string("Globex Open", "Anchor / Recalc", options=["Globex Open", "Pit Open", "Globex Open & Pit Open"], group=grpVR)
vrUseLiveVix = input.bool(false, "Use live VIX (else VIX at anchor)", group=grpVR)
vrColor      = input.color(color.green, "Volatility Range Color", group=grpVR)
vrWidth      = input.int(1, "Volatility Range Thickness", minval=1, maxval=5, group=grpVR)
vrShowPrior  = input.bool(true, "Show Prior Session 1x", group=grpVR)

//==============================
// Helpers
//==============================
getState(ratio) =>
    na(ratio) ? "N/A" :
     ratio < compressedPct ? "COMPRESSED" :
     ratio < expandedPct ? "BALANCED" :
     ratio < stretchedPct ? "EXPANDED" :
     "STRETCHED"

getColor(state) =>
    state == "COMPRESSED" ? compressedColor :
     state == "BALANCED" ? balancedColor :
     state == "EXPANDED" ? expandedColor :
     state == "STRETCHED" ? stretchedColor :
     color.black

getPlotStyle(styleInput) =>
    styleInput == "Line" ? plot.style_line :
     styleInput == "Circles" ? plot.style_circles :
     plot.style_linebr

getLineStyle(styleInput) =>
    styleInput == "Dashed" ? line.style_dashed :
     styleInput == "Dotted" ? line.style_dotted :
     line.style_solid

getLabelSize(sizeInput) =>
    sizeInput == "Huge" ? size.huge :
     sizeInput == "Large" ? size.large :
     sizeInput == "Normal" ? size.normal :
     sizeInput == "Small" ? size.small :
     size.tiny

dailyPlotStyle = getPlotStyle(dailyStyleInput)
globexPlotStyle = getPlotStyle(globexStyleInput)
weeklyPlotStyle = getPlotStyle(weeklyStyleInput)
midnightLineStyle = getLineStyle(midnightLineStyleInput)
settlementLineStyle = getLineStyle(settlementLineStyleInput)
lineLabelSize = getLabelSize(labelTextSizeInput)

//==============================
// ATR
//==============================
dailyAtr = request.security(syminfo.tickerid, "D", ta.atr(atrLen))
weeklyAtr = request.security(syminfo.tickerid, "W", ta.atr(atrLen))

//==============================
// Time
//==============================
dow = dayofweek
hourNY = hour(time, "America/New_York")
minuteNY = minute(time, "America/New_York")

//==============================
// VIX
//==============================
vix = request.security("TVC:VIX", timeframe.period, close)
vixOpen = request.security("TVC:VIX", "D", open)
vixChange = vixOpen > 0 ? ((vix - vixOpen) / vixOpen) * 100 : na

vixState =
     na(vixChange) ? "N/A" :
     vixChange > 5 ? "VOL SHOCK" :
     vixChange > 2 ? "VOL RISING" :
     vixChange < -3 ? "VOL CRUSH" :
     "VOL STABLE"

vixColor =
     vixState == "VOL SHOCK" ? stretchedColor :
     vixState == "VOL RISING" ? expandedColor :
     vixState == "VOL CRUSH" ? color.green :
     balancedColor

//==============================
// Volatility Range (implied expected move from open + VIX)
//   EM = anchorOpen * (VIX/100) / sqrt(252)   (1-day 1-SD expected move; "rule of 16")
//   Levels: MID = open; +/- {mult1, mult2, mult3} * EM  (mult3 = 1x expected-move zone)
//   RATIO = (close - MID) / EM ; STATE = which expected-move zone price is in
//==============================
vrIsGlobexAnchor = hourNY == 18 and minuteNY == 0
vrIsPitAnchor    = hourNY == 9  and minuteNY == 30
vrAnchorBar =
     vrAnchorMode == "Globex Open" ? vrIsGlobexAnchor :
     vrAnchorMode == "Pit Open"    ? vrIsPitAnchor :
     (vrIsGlobexAnchor or vrIsPitAnchor)

var float vrOpen = na
var float vrVixAnchor = na
var float vrPriorMid = na
var float vrPriorA3 = na
var float vrPriorB3 = na

if vrAnchorBar
    // carry the just-ended session's levels into "prior" before resetting
    if not na(vrOpen) and not na(vrVixAnchor) and vrVixAnchor > 0
        priorEM = vrOpen * (vrVixAnchor / 100.0) / math.sqrt(252)
        vrPriorMid := vrOpen
        vrPriorA3  := vrOpen + vrMult3 * priorEM
        vrPriorB3  := vrOpen - vrMult3 * priorEM
    vrOpen := open
    vrVixAnchor := vix

vrVixUsed = vrUseLiveVix ? vix : vrVixAnchor
vrEM = (not na(vrOpen) and not na(vrVixUsed) and vrVixUsed > 0) ? vrOpen * (vrVixUsed / 100.0) / math.sqrt(252) : na
vrMid = vrOpen
vrA1 = not na(vrEM) ? vrMid + vrMult1 * vrEM : na
vrB1 = not na(vrEM) ? vrMid - vrMult1 * vrEM : na
vrA2 = not na(vrEM) ? vrMid + vrMult2 * vrEM : na
vrB2 = not na(vrEM) ? vrMid - vrMult2 * vrEM : na
vrA3 = not na(vrEM) ? vrMid + vrMult3 * vrEM : na
vrB3 = not na(vrEM) ? vrMid - vrMult3 * vrEM : na
vrRatio = (not na(vrEM) and vrEM != 0) ? (close - vrMid) / vrEM : na
vrState =
     na(vrRatio) ? "N/A" :
     math.abs(vrRatio) < vrMult1 ? "INNER" :
     math.abs(vrRatio) < vrMult3 ? "INSIDE 1x" :
     "BEYOND 1x"
vrStateColor =
     vrState == "INNER" ? balancedColor :
     vrState == "INSIDE 1x" ? expandedColor :
     vrState == "BEYOND 1x" ? stretchedColor :
     color.black

//==============================
// Daily IB
//==============================
inDailyIb = not na(time(timeframe.period, dailyIbSession, "America/New_York"))
newDailyIb = inDailyIb and not inDailyIb[1]

var float dHigh = na
var float dLow = na

if newDailyIb
    dHigh := high
    dLow := low
else if inDailyIb
    dHigh := math.max(nz(dHigh, high), high)
    dLow := math.min(nz(dLow, low), low)

dSize = dHigh - dLow
dRatio = dailyAtr > 0 ? dSize / dailyAtr : na
dState = getState(dRatio)
dColor = getColor(dState)
dFuel = math.max(0, dailyAtr - nz(dSize, 0))

//==============================
// Full Globex ATR Baseline
//==============================
inFullGlobex = not na(time(timeframe.period, globexFullSession, "America/New_York"))
newFullGlobex = inFullGlobex and not inFullGlobex[1]

var float fullHigh = na
var float fullLow = na
var rangeArray = array.new_float()

if newFullGlobex
    if not na(fullHigh) and not na(fullLow)
        array.push(rangeArray, fullHigh - fullLow)
        if array.size(rangeArray) > atrLen
            array.shift(rangeArray)
    fullHigh := high
    fullLow := low
else if inFullGlobex
    fullHigh := math.max(nz(fullHigh, high), high)
    fullLow := math.min(nz(fullLow, low), low)

globexAtr = array.size(rangeArray) > 0 ? array.avg(rangeArray) : dailyAtr * 0.35

//==============================
// Pre-NY IB
//==============================
inGlobexIb = not na(time(timeframe.period, globexIbSession, "America/New_York"))
newGlobexIb = inGlobexIb and not inGlobexIb[1]

var float gHigh = na
var float gLow = na

if newGlobexIb
    gHigh := high
    gLow := low
else if inGlobexIb
    gHigh := math.max(nz(gHigh, high), high)
    gLow := math.min(nz(gLow, low), low)

gSize = gHigh - gLow
gRatio = globexAtr > 0 ? gSize / globexAtr : na
gState = getState(gRatio)
gColor = getColor(gState)
gFuel = math.max(0, globexAtr - nz(gSize, 0))

//==============================
// Weekly IB
//==============================
inWeeklyWindow =
     (dow == dayofweek.sunday and hourNY >= 18) or
     dow == dayofweek.monday or
     (dow == dayofweek.tuesday and hourNY < 16)

newWeeklyWindow = inWeeklyWindow and not inWeeklyWindow[1]

var float wHigh = na
var float wLow = na

if newWeeklyWindow
    wHigh := high
    wLow := low
else if inWeeklyWindow
    wHigh := math.max(nz(wHigh, high), high)
    wLow := math.min(nz(wLow, low), low)

wSize = wHigh - wLow
wRatio = weeklyAtr > 0 ? wSize / weeklyAtr : na
wState = getState(wRatio)
wColor = getColor(wState)
wFuel = math.max(0, weeklyAtr - nz(wSize, 0))

//==============================
// Midnight Open: 00:00 to 16:00 NY
//==============================
var line midnightLine = na
var label midnightLabel = na
var float midnightPrice = na

newMidnight = hourNY == 0 and minuteNY == 0

if newMidnight
    midnightPrice := open
    line.delete(midnightLine)
    label.delete(midnightLabel)

    midnightEndTime = time + (16 * 60 * 60 * 1000)

    if showMidnightOpen
        midnightLine := line.new(
             x1=time,
             y1=midnightPrice,
             x2=midnightEndTime,
             y2=midnightPrice,
             xloc=xloc.bar_time,
             extend=extend.none,
             color=midnightColor,
             width=midnightWidth,
             style=midnightLineStyle
         )

        midnightLabel := label.new(
             x=midnightEndTime,
             y=midnightPrice,
             text="midnight",
             xloc=xloc.bar_time,
             style=label.style_label_left,
             textcolor=midnightColor,
             color=color.new(color.black, 100),
             size=lineLabelSize
         )

if not showMidnightOpen
    line.delete(midnightLine)
    label.delete(midnightLabel)
    midnightLine := na
    midnightLabel := na

//==============================
// Settlement: captures 16:00 NY close, displays 18:00 to 00:00
//==============================
var line settlementLine = na
var label settlementLabel = na
var float settlementPrice = na

isSettlementBar = hourNY == 16 and minuteNY == 0
isGlobexOpen = hourNY == 18 and minuteNY == 0

if isSettlementBar
    settlementPrice := close

if isGlobexOpen and not na(settlementPrice)
    line.delete(settlementLine)
    label.delete(settlementLabel)

    settlementEndTime = time + (6 * 60 * 60 * 1000)

    if showSettlement
        settlementLine := line.new(
             x1=time,
             y1=settlementPrice,
             x2=settlementEndTime,
             y2=settlementPrice,
             xloc=xloc.bar_time,
             extend=extend.none,
             color=settlementColor,
             width=settlementWidth,
             style=settlementLineStyle
         )

        settlementLabel := label.new(
             x=settlementEndTime,
             y=settlementPrice,
             text="settlement",
             xloc=xloc.bar_time,
             style=label.style_label_left,
             textcolor=settlementColor,
             color=color.new(color.black, 100),
             size=lineLabelSize
         )

if not showSettlement
    line.delete(settlementLine)
    label.delete(settlementLabel)
    settlementLine := na
    settlementLabel := na

//==============================
// Contextual Regime Summary
//==============================
regimeText =
     wState == "COMPRESSED" and (dState == "EXPANDED" or dState == "STRETCHED") ? "MACRO COILED / LOCAL USED" :
     wState == "COMPRESSED" and dState == "COMPRESSED" ? "MULTI-TF COILED" :
     wState == "BALANCED" and dState == "BALANCED" ? "BALANCED AUCTION" :
     wState == "EXPANDED" and (dState == "EXPANDED" or dState == "STRETCHED") ? "LATE EXPANSION" :
     wState == "STRETCHED" or dState == "STRETCHED" ? "STRETCHED RISK" :
     "MIXED AUCTION"

regimeColor =
     regimeText == "MULTI-TF COILED" ? compressedColor :
     regimeText == "BALANCED AUCTION" ? balancedColor :
     regimeText == "MACRO COILED / LOCAL USED" ? expandedColor :
     regimeText == "LATE EXPANSION" ? stretchedColor :
     regimeText == "STRETCHED RISK" ? stretchedColor :
     expandedColor

//==============================
// Plotting
//==============================
showDailyLine =
     showDaily and
     not inDailyIb and
     hourNY >= 10 and
     hourNY <= 23

plot(showDailyLine ? dHigh : na, "Daily IB High", dColor, dailyWidth, dailyPlotStyle, editable=false)
plot(showDailyLine ? dLow : na, "Daily IB Low", dColor, dailyWidth, dailyPlotStyle, editable=false)

showGlobexLine =
     showGlobex and
     not inGlobexIb and
     (
         hourNY > 9 or
         (hourNY == 9 and minuteNY >= 30)
     ) and
     hourNY < 17

plot(showGlobexLine ? gHigh : na, "Pre-NY IB High", gColor, globexWidth, globexPlotStyle, editable=false)
plot(showGlobexLine ? gLow : na, "Pre-NY IB Low", gColor, globexWidth, globexPlotStyle, editable=false)

plot(showWeekly and not inWeeklyWindow ? wHigh : na, "Weekly IB High", wColor, weeklyWidth, weeklyPlotStyle, editable=false)
plot(showWeekly and not inWeeklyWindow ? wLow : na, "Weekly IB Low", wColor, weeklyWidth, weeklyPlotStyle, editable=false)

//------------------------------
// IB line labels (right edge — High/Low of each Initial Balance window)
//------------------------------
var label lblDH = na
var label lblDL = na
var label lblGH = na
var label lblGL = na
var label lblWH = na
var label lblWL = na

f_lvlLabel(lbl, yval, txt, col) =>
    label.delete(lbl)
    label out = na
    if not na(yval)
        out := label.new(bar_index + 3, yval, txt, xloc=xloc.bar_index, style=label.style_label_left, textcolor=col, color=color.new(color.black, 100), size=lineLabelSize)
    out

if barstate.islast and showIbLabels
    lblDH := f_lvlLabel(lblDH, showDailyLine  ? dHigh : na, "Daily IB High",  dColor)
    lblDL := f_lvlLabel(lblDL, showDailyLine  ? dLow  : na, "Daily IB Low",   dColor)
    lblGH := f_lvlLabel(lblGH, showGlobexLine ? gHigh : na, "Pre-NY IB High", gColor)
    lblGL := f_lvlLabel(lblGL, showGlobexLine ? gLow  : na, "Pre-NY IB Low",  gColor)
    lblWH := f_lvlLabel(lblWH, (showWeekly and not inWeeklyWindow) ? wHigh : na, "Weekly IB High", wColor)
    lblWL := f_lvlLabel(lblWL, (showWeekly and not inWeeklyWindow) ? wLow  : na, "Weekly IB Low",  wColor)

// ---- Volatility Range plots ----
plot(showVolRange ? vrMid : na, "Vol Range Mid", color.new(vrColor, 0),  vrWidth, plot.style_linebr, editable=false)
plot(showVolRange ? vrA3  : na, "Vol Range +1x", color.new(vrColor, 0),  vrWidth, plot.style_linebr, editable=false)
plot(showVolRange ? vrB3  : na, "Vol Range -1x", color.new(vrColor, 0),  vrWidth, plot.style_linebr, editable=false)
plot(showVolRange ? vrA2  : na, "Vol Range +0.9", color.new(vrColor, 45), vrWidth, plot.style_linebr, editable=false)
plot(showVolRange ? vrB2  : na, "Vol Range -0.9", color.new(vrColor, 45), vrWidth, plot.style_linebr, editable=false)
plot(showVolRange ? vrA1  : na, "Vol Range +0.25", color.new(vrColor, 70), vrWidth, plot.style_linebr, editable=false)
plot(showVolRange ? vrB1  : na, "Vol Range -0.25", color.new(vrColor, 70), vrWidth, plot.style_linebr, editable=false)
plot(showVolRange and vrShowPrior ? vrPriorA3 : na, "Prior Vol Range +1x", color.new(vrColor, 60), 1, plot.style_linebr, editable=false)
plot(showVolRange and vrShowPrior ? vrPriorB3 : na, "Prior Vol Range -1x", color.new(vrColor, 60), 1, plot.style_linebr, editable=false)

//------------------------------
// Vol Range line labels (right edge — like the Midnight Open tag)
//------------------------------
var label lblVrMid = na
var label lblVrA3  = na
var label lblVrB3  = na
var label lblVrA2  = na
var label lblVrB2  = na
var label lblVrA1  = na
var label lblVrB1  = na
var label lblVrPA3 = na
var label lblVrPB3 = na

f_vrLabel(lbl, yval, txt, transp) =>
    label.delete(lbl)
    label out = na
    if not na(yval)
        out := label.new(bar_index + 3, yval, txt, xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.new(vrColor, transp), color=color.new(color.black, 100), size=lineLabelSize)
    out

if barstate.islast and showVolRange and showVrLabels
    lblVrMid := f_vrLabel(lblVrMid, vrMid, "VR Mid", 0)
    lblVrA3  := f_vrLabel(lblVrA3,  vrA3,  "+1x",    0)
    lblVrB3  := f_vrLabel(lblVrB3,  vrB3,  "-1x",    0)
    lblVrA2  := f_vrLabel(lblVrA2,  vrA2,  "+0.9",   45)
    lblVrB2  := f_vrLabel(lblVrB2,  vrB2,  "-0.9",   45)
    lblVrA1  := f_vrLabel(lblVrA1,  vrA1,  "+0.25",  70)
    lblVrB1  := f_vrLabel(lblVrB1,  vrB1,  "-0.25",  70)
    lblVrPA3 := f_vrLabel(lblVrPA3, vrShowPrior ? vrPriorA3 : na, "+1x'", 60)
    lblVrPB3 := f_vrLabel(lblVrPB3, vrShowPrior ? vrPriorB3 : na, "-1x'", 60)

//==============================
// Dashboard
//==============================
dashboardPosition =
     dashboardPositionInput == "Top Left" ? position.top_left :
     dashboardPositionInput == "Bottom Right" ? position.bottom_right :
     dashboardPositionInput == "Bottom Left" ? position.bottom_left :
     position.top_right

var table dash = table.new(dashboardPosition, 4, 8, border_width=1)

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Layer", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 0, "Ratio", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 2, 0, "Fuel", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 3, 0, "State", text_color=color.white, bgcolor=color.black)

    table.cell(dash, 0, 1, "Weekly", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 1, str.tostring(wRatio, "#.##"), text_color=color.white, bgcolor=balancedColor)
    table.cell(dash, 2, 1, str.tostring(wFuel, "#.##"), text_color=color.white, bgcolor=balancedColor)
    table.cell(dash, 3, 1, wState, text_color=color.white, bgcolor=wColor)

    table.cell(dash, 0, 2, "Daily", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 2, str.tostring(dRatio, "#.##"), text_color=color.white, bgcolor=balancedColor)
    table.cell(dash, 2, 2, str.tostring(dFuel, "#.##"), text_color=color.white, bgcolor=balancedColor)
    table.cell(dash, 3, 2, dState, text_color=color.white, bgcolor=dColor)

    table.cell(dash, 0, 3, "Pre-NY", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 3, str.tostring(gRatio, "#.##"), text_color=color.white, bgcolor=balancedColor)
    table.cell(dash, 2, 3, str.tostring(gFuel, "#.##"), text_color=color.white, bgcolor=balancedColor)
    table.cell(dash, 3, 3, gState, text_color=color.white, bgcolor=gColor)

    table.cell(dash, 0, 4, "VIX", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 4, str.tostring(vix, "#.##"), text_color=color.white, bgcolor=balancedColor)
    table.cell(dash, 2, 4, str.tostring(vixChange, "#.##") + "%", text_color=color.white, bgcolor=balancedColor)
    table.cell(dash, 3, 4, vixState, text_color=color.white, bgcolor=vixColor)

    table.cell(dash, 0, 5, "Vol Range", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 5, str.tostring(vrRatio, "#.##"), text_color=color.white, bgcolor=balancedColor)
    table.cell(dash, 2, 5, str.tostring(vrEM, "#.#"), text_color=color.white, bgcolor=balancedColor)
    table.cell(dash, 3, 5, vrState, text_color=color.white, bgcolor=vrStateColor)

    table.cell(dash, 0, 6, "Regime", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 6, "", bgcolor=color.black)
    table.cell(dash, 2, 6, "", bgcolor=color.black)
    table.cell(dash, 3, 6, regimeText, text_color=color.white, bgcolor=regimeColor)

//==============================
// Snapshot Codes · Export Plots · Default Alert
//==============================

//------------------------------
// State Code Helpers
//------------------------------
stateCode(state) =>
    state == "COMPRESSED" ? 1 :
     state == "BALANCED" ? 2 :
     state == "EXPANDED" ? 3 :
     state == "STRETCHED" ? 4 :
     0

vixCode(state) =>
    state == "VOL CRUSH" ? 1 :
     state == "VOL STABLE" ? 2 :
     state == "VOL RISING" ? 3 :
     state == "VOL SHOCK" ? 4 :
     0

// Volatility Range state code: 1 = INNER, 2 = INSIDE 1x, 3 = BEYOND 1x
vrCode(state) =>
    state == "INNER" ? 1 :
     state == "INSIDE 1x" ? 2 :
     state == "BEYOND 1x" ? 3 :
     0

//------------------------------
// Composite Regime Code
//------------------------------
// 1 = MULTI-TF COILED
// 2 = BALANCED AUCTION
// 3 = MACRO COILED / LOCAL USED
// 4 = LATE EXPANSION
// 5 = STRETCHED RISK
// 6 = MIXED AUCTION

compositeCode =
     regimeText == "MULTI-TF COILED" ? 1 :
     regimeText == "BALANCED AUCTION" ? 2 :
     regimeText == "MACRO COILED / LOCAL USED" ? 3 :
     regimeText == "LATE EXPANSION" ? 4 :
     regimeText == "STRETCHED RISK" ? 5 :
     regimeText == "MIXED AUCTION" ? 6 :
     0

//------------------------------
// Snapshot Windows
//------------------------------
// Daily IB snapshot: on a 30m chart, confirms after the 10:30-11:00 bar closes.
// RTH close snapshot: on a 30m chart, confirms after the 16:00-16:30 bar closes.

dailyIbSnapshotWindow =
     hourNY == 10 and minuteNY >= 30 and minuteNY < 35

rthCloseSnapshotWindow =
     hourNY == 16 and minuteNY >= 0 and minuteNY < 5

dailyIbSnapshot =
     dailyIbSnapshotWindow and (bar_index == 0 or not dailyIbSnapshotWindow[1])

rthCloseSnapshot =
     rthCloseSnapshotWindow and (bar_index == 0 or not rthCloseSnapshotWindow[1])

snapshotTrigger =
     dailyIbSnapshot or rthCloseSnapshot

// 1 = Daily IB Snapshot, 2 = RTH Close Snapshot
snapshotTypeCode =
     dailyIbSnapshot ? 1 :
     rthCloseSnapshot ? 2 :
     0

//------------------------------
// Hidden Export Plots
//------------------------------
plot(wRatio, "Weekly Ratio Alert", display=display.none)
plot(dRatio, "Daily Ratio Alert", display=display.none)
plot(gRatio, "PreNY Ratio Alert", display=display.none)
plot(vixChange, "VIX Change Alert", display=display.none)

plot(stateCode(wState), "Weekly State Code", display=display.none)
plot(stateCode(dState), "Daily State Code", display=display.none)
plot(stateCode(gState), "PreNY State Code", display=display.none)
plot(vixCode(vixState), "VIX State Code", display=display.none)

plot(compositeCode, "Composite Regime Code", display=display.none)
plot(snapshotTypeCode, "Snapshot Type Code", display=display.none)

// ---- Volatility Range export plots ----
plot(vix,                "VIX Value Alert",          display=display.none)
plot(vrRatio,            "Vol Range Ratio Alert",    display=display.none)
plot(vrCode(vrState),    "Vol Range State Code",     display=display.none)
plot(vrEM,               "Vol Range EM Alert",       display=display.none)

//------------------------------
// Default Alert (generic alert() — public)
//------------------------------
// Fires once per bar close on each regime snapshot (Daily IB ~10:30 / RTH close ~16:00 NY).
if snapshotTrigger
    snapType = snapshotTypeCode == 1 ? "Daily IB" : snapshotTypeCode == 2 ? "RTH Close" : "Snapshot"
    msg = "FRESH Regime Snapshot (" + snapType + ") | Composite: " + regimeText + " | Weekly: " + wState + " | Daily: " + dState + " | PreNY: " + gState + " | VIX: " + vixState + " (" + str.tostring(vix, "#.##") + ") | VolRange: " + vrState + " (ratio " + str.tostring(vrRatio, "#.##") + ")"
    alert(msg, alert.freq_once_per_bar_close)
````
