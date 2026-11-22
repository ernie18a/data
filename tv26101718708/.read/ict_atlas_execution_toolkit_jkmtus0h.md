# ICT Atlas - Execution Toolkit

- url: https://www.tradingview.com/script/jkMtUS0h-ICT-Atlas-Execution-Toolkit/
- type: indicator
- pine_id: PUB;33bb6529e4d1465391e77aeb0a136991
- version: 1.0

## Description

ICT Atlas — Liquidity Execution Toolkit

Use best with #ICTPulse

ICT Atlas is an execution-focused visual toolkit for discretionary ICT-style futures traders. It is designed to organize session liquidity, timed intraday windows, SMT divergence, liquidity sweeps, and post-sweep market structure confirmation in one workflow.

This script is not an automated trading system and does not issue buy or sell signals. Its purpose is to help traders visually follow a sequence of conditions often used in manual execution:

1. Identify session liquidity.
2. Observe whether liquidity is swept.
3. Check for SMT divergence.
4. Wait for market structure confirmation after the sweep.
5. Use the trader’s own entry and risk model.

How it works

The script tracks Asia, London, and New York sessions using the selected timezone. At the end of each session, it records the session high and low, then extends those levels to the right side of the chart. These levels are labeled as AH/AL, LH/LL, and NYH/NYL.

Liquidity sweep detection is based on price interacting with those stored session levels. The user can choose between a simple wick-touch condition or a stricter wick-and-close-back condition. This allows the trader to decide whether a sweep should mean only that price traded through a level, or that price traded through the level and then rejected back inside it.

The SMT module compares the active chart symbol with a user-selected comparison symbol. It uses pivot highs and pivot lows to detect divergence between the two markets. A bearish SMT condition appears when one market makes a higher high while the comparison market does not confirm. A bullish SMT condition appears when one market makes a lower low while the comparison market does not confirm.

The MSS/BOS confirmation module only becomes relevant after a liquidity sweep. After a valid high-side or low-side sweep, the script waits for price to break a recent swing level within the configured expiry window. This is intended to separate simple liquidity touches from situations where structure later confirms a possible shift.

The micro-box module highlights recurring intraday timing windows from :50 to :10 using the selected timezone. During each micro window, the script tracks the high, low, and midpoint of that window, allowing traders to study reactions around specific time-based execution windows.

Main features

* Asia, London, and New York session tracking
* Previous session high and low levels
* AH/AL, LH/LL, and NYH/NYL labels
* Liquidity sweep labels
* Wick-touch or wick-and-close-back sweep modes
* SMT divergence using a comparison symbol
* Post-sweep MSS/BOS confirmation
* ICT-style micro timing boxes from :50 to :10
* Optional alerts for sweeps and structure confirmation
* Adjustable colors, line widths, lookbacks, and object limits

How to use it

ICT Atlas is best used on lower timeframes such as 1-minute, 3-minute, and 5-minute charts.

Suggested workflow:

1. Mark the latest session highs and lows.
2. Watch for a sweep of Asia, London, or New York liquidity.
3. Check whether SMT divergence is present between the chart symbol and the comparison symbol.
4. Wait for MSS/BOS confirmation after the sweep.
5. Apply your own entry model, invalidation, and risk management.

This script is intended for educational and analytical use only. It does not provide financial advice, trade recommendations, or guaranteed outcomes. Futures and financial market trading involves risk.

## Source Code

````pine
//Sakamoah - My 1st Indicator #ICTAtlas
//@version=6
indicator("ICT Atlas - Execution Toolkit", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ─────────────────────────────────────
// Groups
// ─────────────────────────────────────
gSess  = "Sessions"
gDock  = "Session Dock"
gMicro = "ICT Micros"
gMSty  = "Micro Style"
gHL    = "Session Highs / Lows"
gSMT   = "SMT Divergence"
gSweep = "Liquidity Sweeps"

// ─────────────────────────────────────
// Session Inputs
// ─────────────────────────────────────
tz = input.string("America/New_York", "Timezone", group=gSess)

showAsia   = input.bool(true, "Show Asia", group=gSess)
showLondon = input.bool(true, "Show London", group=gSess)
showNY     = input.bool(true, "Show New York", group=gSess)

asiaSession   = input.session("1800-0000", "Asia Session", group=gSess)
londonSession = input.session("0200-0500", "London Session", group=gSess)
nySession     = input.session("0930-1200", "New York Session", group=gSess)

showBackground = input.bool(false, "Show Session Background", group=gSess)

// ─────────────────────────────────────
// Dock Style
// ─────────────────────────────────────
asiaColor   = input.color(color.black, "Asia Color", group=gDock)
londonColor = input.color(color.red, "London Color", group=gDock)
nyColor     = input.color(color.blue, "NY Color", group=gDock)

dockSymbol = input.string("─", "Dock Thickness", options=["·", "─", "━"], group=gDock)
dockTransp = input.int(20, "Dock Transparency", minval=0, maxval=90, group=gDock)

// ─────────────────────────────────────
// Micro Inputs
// ─────────────────────────────────────
showMicros     = input.bool(true, "Show ICT Micro Boxes", group=gMicro)
microLookback  = input.string("Last 4h", "Show Micro Boxes", options=["Last 4h", "Last 24h", "Last Week"], group=gMicro)
showMidline    = input.bool(false, "Show 50% Line", group=gMicro)
showMicroHL    = input.bool(false, "Show Micro High / Low Lines", group=gMicro)
maxMicroBoxes  = input.int(20, "Max Micro Boxes", minval=20, maxval=160, group=gMicro)

// ─────────────────────────────────────
// Micro Style
// ─────────────────────────────────────
boxColor    = input.color(color.new(color.red, 85), "Box Background", group=gMSty)
borderColor = input.color(color.new(color.red, 35), "Box Border", group=gMSty)
lineColor   = input.color(color.new(color.red, 20), "High / Low / Mid Lines", group=gMSty)
hideColor   = color.new(color.red, 100)

// ─────────────────────────────────────
// Session High / Low Inputs
// ─────────────────────────────────────
showSessionHL = input.bool(true, "Show Session Highs / Lows", group=gHL)
hlLastSets    = input.int(1, "Show Last Session Sets", minval=1, maxval=10, group=gHL)
showHLLabels  = input.bool(true, "Show Labels AH/AL/LH/LL/NYH/NYL", group=gHL)
hlWidth       = input.int(1, "Line Width", minval=1, maxval=4, group=gHL)
hlTransp      = input.int(0, "Line Transparency", minval=0, maxval=90, group=gHL)
hlLabelOffset = input.int(8, "Label Offset Right", minval=1, maxval=50, group=gHL)

// ─────────────────────────────────────
// SMT Inputs
// ─────────────────────────────────────
showSMT       = input.bool(true, "Show SMT Divergence", group=gSMT)
smtSymbol     = input.symbol("CME_MINI:ES1!", "Compare Symbol", group=gSMT)
smtPivotLen   = input.int(3, "Pivot Strength", minval=1, maxval=10, group=gSMT)
showBullSMT   = input.bool(true, "Show Bullish SMT", group=gSMT)
showBearSMT   = input.bool(true, "Show Bearish SMT", group=gSMT)
maxSMTObjects = input.int(5, "Max SMT Signals", minval=5, maxval=100, group=gSMT)

bullSMTColor  = input.color(color.new(color.lime, 0), "Bullish SMT Color", group=gSMT)
bearSMTColor  = input.color(color.new(color.red, 0), "Bearish SMT Color", group=gSMT)
smtLineWidth  = input.int(1, "SMT Line Width", minval=1, maxval=4, group=gSMT)

// ─────────────────────────────────────
// Sweep Inputs
// ─────────────────────────────────────
showSweeps       = input.bool(true, "Show Liquidity Sweeps", group=gSweep)
showAsiaSweeps   = input.bool(true, "Show Asia Sweeps", group=gSweep)
showLondonSweeps = input.bool(true, "Show London Sweeps", group=gSweep)
showNYSweeps     = input.bool(true, "Show NY Sweeps", group=gSweep)

sweepMode = input.string("Wick + Close Back", "Sweep Mode", options=["Wick Touch", "Wick + Close Back"], group=gSweep)

maxSweepLabels = input.int(10, "Max Sweep Labels", minval=10, maxval=200, group=gSweep)

sweepHighColor = input.color(color.new(color.red, 0), "High Sweep Color", group=gSweep)
sweepLowColor  = input.color(color.new(color.lime, 0), "Low Sweep Color", group=gSweep)

// ─────────────────────────────────────
// Helpers
// ─────────────────────────────────────
inSession(sess) =>
    not na(time(timeframe.period, sess, tz))

levelChanged(_new, _old) =>
    na(_new) != na(_old) or (not na(_new) and not na(_old) and _new != _old)

msHour = 60 * 60 * 1000
msDay  = 24 * msHour

// ─────────────────────────────────────
// Session Detection + Dock
// ─────────────────────────────────────
asiaRaw   = inSession(asiaSession)
londonRaw = inSession(londonSession)
nyRaw     = inSession(nySession)

asiaOn   = showAsia and asiaRaw
londonOn = showLondon and londonRaw
nyOn     = showNY and nyRaw

bgcolor(showBackground and asiaOn ? color.new(asiaColor, 92) : na)
bgcolor(showBackground and londonOn ? color.new(londonColor, 92) : na)
bgcolor(showBackground and nyOn ? color.new(nyColor, 92) : na)

plotchar(asiaOn, "Asia Dock", dockSymbol, location.bottom, color.new(asiaColor, dockTransp), size=size.tiny)
plotchar(londonOn, "London Dock", dockSymbol, location.bottom, color.new(londonColor, dockTransp), size=size.tiny)
plotchar(nyOn, "NY Dock", dockSymbol, location.bottom, color.new(nyColor, dockTransp), size=size.tiny)

// ─────────────────────────────────────
// ICT Micro Boxes
// HH:50 to next HH:10 New York time
// ─────────────────────────────────────
lookbackMs = microLookback == "Last 4h" ? 4 * msHour : microLookback == "Last 24h" ? msDay : 7 * msDay
microCutoff = time - lookbackMs

m = minute(time, tz)
inMicro = m >= 50 or m < 10
prevInMicro = bar_index > 0 ? inMicro[1] : false

newMicro = showMicros and inMicro and not prevInMicro
endMicro = showMicros and not inMicro and prevInMicro

var box curBox = na
var line curHiLine = na
var line curLoLine = na
var line curMidLine = na

var float microHi = na
var float microLo = na
var int microStart = na

var box[] microBoxes = array.new_box()
var line[] microHiLines = array.new_line()
var line[] microLoLines = array.new_line()
var line[] microMidLines = array.new_line()
var int[] microTimes = array.new_int()

if newMicro
    microHi := high
    microLo := low
    microStart := time

    curBox := box.new(microStart, microHi, time_close, microLo, xloc=xloc.bar_time, bgcolor=boxColor, border_color=borderColor)
    curHiLine := line.new(microStart, microHi, time_close, microHi, xloc=xloc.bar_time, color=showMicroHL ? lineColor : hideColor)
    curLoLine := line.new(microStart, microLo, time_close, microLo, xloc=xloc.bar_time, color=showMicroHL ? lineColor : hideColor)
    curMidLine := line.new(microStart, (microHi + microLo) / 2, time_close, (microHi + microLo) / 2, xloc=xloc.bar_time, color=showMidline ? lineColor : hideColor, style=line.style_dotted)

    array.push(microBoxes, curBox)
    array.push(microHiLines, curHiLine)
    array.push(microLoLines, curLoLine)
    array.push(microMidLines, curMidLine)
    array.push(microTimes, microStart)

if showMicros and inMicro and not na(curBox)
    microHi := math.max(microHi, high)
    microLo := math.min(microLo, low)
    mid = (microHi + microLo) / 2

    box.set_top(curBox, microHi)
    box.set_bottom(curBox, microLo)
    box.set_right(curBox, time_close)

    line.set_xy2(curHiLine, time_close, microHi)
    line.set_y1(curHiLine, microHi)

    line.set_xy2(curLoLine, time_close, microLo)
    line.set_y1(curLoLine, microLo)

    line.set_xy2(curMidLine, time_close, mid)
    line.set_y1(curMidLine, mid)

if endMicro
    curBox := na
    curHiLine := na
    curLoLine := na
    curMidLine := na
    microHi := na
    microLo := na
    microStart := na

while array.size(microBoxes) > 0 and (array.get(microTimes, 0) < microCutoff or array.size(microBoxes) > maxMicroBoxes)
    box.delete(array.shift(microBoxes))
    line.delete(array.shift(microHiLines))
    line.delete(array.shift(microLoLines))
    line.delete(array.shift(microMidLines))
    array.shift(microTimes)

// ─────────────────────────────────────
// Session High / Low Lines
// ─────────────────────────────────────
var line[] hlLines = array.new_line()
var label[] hlLabels = array.new_label()

var float lastAH = na
var float lastAL = na
var float lastLH = na
var float lastLL = na
var float lastNYH = na
var float lastNYL = na

addHL(_hi, _lo, _hiBar, _loBar, _hiTxt, _loTxt, _clr) =>
    if showSessionHL and not na(_hi) and not na(_lo) and not na(_hiBar) and not na(_loBar)
        c = color.new(_clr, hlTransp)

        hiLine = line.new(_hiBar, _hi, _hiBar + 1, _hi, xloc=xloc.bar_index, extend=extend.right, color=c, width=hlWidth)
        loLine = line.new(_loBar, _lo, _loBar + 1, _lo, xloc=xloc.bar_index, extend=extend.right, color=c, width=hlWidth)

        label hiLabel = na
        label loLabel = na

        if showHLLabels
            hiLabel := label.new(bar_index + hlLabelOffset, _hi, _hiTxt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=c, size=size.small)
            loLabel := label.new(bar_index + hlLabelOffset, _lo, _loTxt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=c, size=size.small)

        array.push(hlLines, hiLine)
        array.push(hlLines, loLine)
        array.push(hlLabels, hiLabel)
        array.push(hlLabels, loLabel)

cleanHL() =>
    maxObjects = hlLastSets * 3 * 2

    while array.size(hlLines) > maxObjects
        line.delete(array.shift(hlLines))

        oldLabel = array.shift(hlLabels)
        if not na(oldLabel)
            label.delete(oldLabel)

// Asia tracking
var float asiaHi = na
var float asiaLo = na
var int asiaHiBar = na
var int asiaLoBar = na

asiaPrev = bar_index > 0 ? asiaRaw[1] : false
asiaStart = showAsia and asiaRaw and not asiaPrev
asiaEnd   = showAsia and not asiaRaw and asiaPrev

if asiaStart
    asiaHi := high
    asiaLo := low
    asiaHiBar := bar_index
    asiaLoBar := bar_index

if showAsia and asiaRaw
    if na(asiaHi) or high >= asiaHi
        asiaHi := high
        asiaHiBar := bar_index
    if na(asiaLo) or low <= asiaLo
        asiaLo := low
        asiaLoBar := bar_index

if asiaEnd
    lastAH := asiaHi
    lastAL := asiaLo
    addHL(asiaHi, asiaLo, asiaHiBar, asiaLoBar, "AH", "AL", asiaColor)
    cleanHL()
    asiaHi := na
    asiaLo := na
    asiaHiBar := na
    asiaLoBar := na

// London tracking
var float londonHi = na
var float londonLo = na
var int londonHiBar = na
var int londonLoBar = na

londonPrev = bar_index > 0 ? londonRaw[1] : false
londonStart = showLondon and londonRaw and not londonPrev
londonEnd   = showLondon and not londonRaw and londonPrev

if londonStart
    londonHi := high
    londonLo := low
    londonHiBar := bar_index
    londonLoBar := bar_index

if showLondon and londonRaw
    if na(londonHi) or high >= londonHi
        londonHi := high
        londonHiBar := bar_index
    if na(londonLo) or low <= londonLo
        londonLo := low
        londonLoBar := bar_index

if londonEnd
    lastLH := londonHi
    lastLL := londonLo
    addHL(londonHi, londonLo, londonHiBar, londonLoBar, "LH", "LL", londonColor)
    cleanHL()
    londonHi := na
    londonLo := na
    londonHiBar := na
    londonLoBar := na

// NY tracking
var float nyHi = na
var float nyLo = na
var int nyHiBar = na
var int nyLoBar = na

nyPrev = bar_index > 0 ? nyRaw[1] : false
nyStart = showNY and nyRaw and not nyPrev
nyEnd   = showNY and not nyRaw and nyPrev

if nyStart
    nyHi := high
    nyLo := low
    nyHiBar := bar_index
    nyLoBar := bar_index

if showNY and nyRaw
    if na(nyHi) or high >= nyHi
        nyHi := high
        nyHiBar := bar_index
    if na(nyLo) or low <= nyLo
        nyLo := low
        nyLoBar := bar_index

if nyEnd
    lastNYH := nyHi
    lastNYL := nyLo
    addHL(nyHi, nyLo, nyHiBar, nyLoBar, "NYH", "NYL", nyColor)
    cleanHL()
    nyHi := na
    nyLo := na
    nyHiBar := na
    nyLoBar := na

if barstate.islast and array.size(hlLabels) > 0
    for i = 0 to array.size(hlLabels) - 1
        lab = array.get(hlLabels, i)
        if not na(lab)
            label.set_x(lab, bar_index + hlLabelOffset)

// ─────────────────────────────────────
// SMT Divergence
// ─────────────────────────────────────
smtHigh = request.security(smtSymbol, timeframe.period, high, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
smtLow  = request.security(smtSymbol, timeframe.period, low, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

chartPH = ta.pivothigh(high, smtPivotLen, smtPivotLen)
chartPL = ta.pivotlow(low, smtPivotLen, smtPivotLen)

compHighAtPivot = smtHigh[smtPivotLen]
compLowAtPivot  = smtLow[smtPivotLen]

var float prevChartHigh = na
var float prevCompHigh  = na
var int prevHighBar = na

var float prevChartLow = na
var float prevCompLow  = na
var int prevLowBar = na

var line[] smtLines = array.new_line()
var label[] smtLabels = array.new_label()

addSMT(_x1, _y1, _x2, _y2, _txt, _clr, _isBull) =>
    if showSMT
        smtLine = line.new(_x1, _y1, _x2, _y2, xloc=xloc.bar_index, extend=extend.none, color=_clr, width=smtLineWidth)

        smtLabel = label.new(
             x=_x2,
             y=_y2,
             text=_txt,
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=_isBull ? label.style_label_up : label.style_label_down,
             color=color.new(_clr, 80),
             textcolor=_clr,
             size=size.tiny
        )

        array.push(smtLines, smtLine)
        array.push(smtLabels, smtLabel)

cleanSMT() =>
    while array.size(smtLines) > maxSMTObjects
        line.delete(array.shift(smtLines))
        label.delete(array.shift(smtLabels))

if showSMT and showBearSMT and not na(chartPH)
    pivotBar = bar_index - smtPivotLen
    currentChartHigh = chartPH
    currentCompHigh = compHighAtPivot

    bearSMT =
         not na(prevChartHigh) and not na(prevCompHigh) and
         (
             (currentChartHigh > prevChartHigh and currentCompHigh <= prevCompHigh) or
             (currentChartHigh <= prevChartHigh and currentCompHigh > prevCompHigh)
         )

    if bearSMT
        addSMT(prevHighBar, prevChartHigh, pivotBar, currentChartHigh, "SMT", bearSMTColor, false)
        cleanSMT()

    prevChartHigh := currentChartHigh
    prevCompHigh := currentCompHigh
    prevHighBar := pivotBar

if showSMT and showBullSMT and not na(chartPL)
    pivotBar = bar_index - smtPivotLen
    currentChartLow = chartPL
    currentCompLow = compLowAtPivot

    bullSMT =
         not na(prevChartLow) and not na(prevCompLow) and
         (
             (currentChartLow < prevChartLow and currentCompLow >= prevCompLow) or
             (currentChartLow >= prevChartLow and currentCompLow < prevCompLow)
         )

    if bullSMT
        addSMT(prevLowBar, prevChartLow, pivotBar, currentChartLow, "SMT", bullSMTColor, true)
        cleanSMT()

    prevChartLow := currentChartLow
    prevCompLow := currentCompLow
    prevLowBar := pivotBar

// ─────────────────────────────────────
// Liquidity Sweeps
// ─────────────────────────────────────
var label[] sweepLabels = array.new_label()

addSweep(_txt, _price, _isLowSweep, _clr) =>
    if showSweeps
        lab = label.new(
             x=bar_index,
             y=_price,
             text=_txt,
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=_isLowSweep ? label.style_label_up : label.style_label_down,
             color=color.new(_clr, 80),
             textcolor=_clr,
             size=size.tiny
        )

        array.push(sweepLabels, lab)

        while array.size(sweepLabels) > maxSweepLabels
            label.delete(array.shift(sweepLabels))

sweepHigh(_level) =>
    sweepMode == "Wick Touch" ? high > _level : high > _level and close < _level

sweepLow(_level) =>
    sweepMode == "Wick Touch" ? low < _level : low < _level and close > _level

var float prevAH = na
var float prevAL = na
var float prevLH = na
var float prevLL = na
var float prevNYH = na
var float prevNYL = na

var bool sweptAH = false
var bool sweptAL = false
var bool sweptLH = false
var bool sweptLL = false
var bool sweptNYH = false
var bool sweptNYL = false

if levelChanged(lastAH, prevAH)
    sweptAH := false
    prevAH := lastAH

if levelChanged(lastAL, prevAL)
    sweptAL := false
    prevAL := lastAL

if levelChanged(lastLH, prevLH)
    sweptLH := false
    prevLH := lastLH

if levelChanged(lastLL, prevLL)
    sweptLL := false
    prevLL := lastLL

if levelChanged(lastNYH, prevNYH)
    sweptNYH := false
    prevNYH := lastNYH

if levelChanged(lastNYL, prevNYL)
    sweptNYL := false
    prevNYL := lastNYL

ahSweep  = showSweeps and showAsiaSweeps and not sweptAH and not na(lastAH) and sweepHigh(lastAH)
alSweep  = showSweeps and showAsiaSweeps and not sweptAL and not na(lastAL) and sweepLow(lastAL)

lhSweep  = showSweeps and showLondonSweeps and not sweptLH and not na(lastLH) and sweepHigh(lastLH)
llSweep  = showSweeps and showLondonSweeps and not sweptLL and not na(lastLL) and sweepLow(lastLL)

nyhSweep = showSweeps and showNYSweeps and not sweptNYH and not na(lastNYH) and sweepHigh(lastNYH)
nylSweep = showSweeps and showNYSweeps and not sweptNYL and not na(lastNYL) and sweepLow(lastNYL)

if ahSweep
    addSweep("AH Sweep", high, false, sweepHighColor)
    sweptAH := true

if alSweep
    addSweep("AL Sweep", low, true, sweepLowColor)
    sweptAL := true

if lhSweep
    addSweep("LH Sweep", high, false, sweepHighColor)
    sweptLH := true

if llSweep
    addSweep("LL Sweep", low, true, sweepLowColor)
    sweptLL := true

if nyhSweep
    addSweep("NYH Sweep", high, false, sweepHighColor)
    sweptNYH := true

if nylSweep
    addSweep("NYL Sweep", low, true, sweepLowColor)
    sweptNYL := true

alertcondition(ahSweep, "AH Sweep", "Asia High swept")
alertcondition(alSweep, "AL Sweep", "Asia Low swept")

alertcondition(lhSweep, "LH Sweep", "London High swept")
alertcondition(llSweep, "LL Sweep", "London Low swept")

alertcondition(nyhSweep, "NYH Sweep", "NY High swept")
alertcondition(nylSweep, "NYL Sweep", "NY Low swept")

// ─────────────────────────────────────
// MSS / BOS Confirmation v6
// Detects market structure shift after liquidity sweep
// ─────────────────────────────────────
gMSS = "MSS / BOS Confirmation"

showMSS        = input.bool(true, "Show MSS After Sweep", group=gMSS)
mssPivotLen    = input.int(3, "Swing Strength", minval=1, maxval=10, group=gMSS)
mssExpiryBars  = input.int(50, "Max Bars After Sweep", minval=5, maxval=300, group=gMSS)
maxMSSSignals  = input.int(5, "Max MSS Signals", minval=5, maxval=100, group=gMSS)

bullMSSColor   = input.color(color.new(color.lime, 0), "Bullish MSS Color", group=gMSS)
bearMSSColor   = input.color(color.new(color.red, 0), "Bearish MSS Color", group=gMSS)
mssLineWidth   = input.int(1, "MSS Line Width", minval=1, maxval=4, group=gMSS)

// Track swings
mssPH = ta.pivothigh(high, mssPivotLen, mssPivotLen)
mssPL = ta.pivotlow(low, mssPivotLen, mssPivotLen)

var float lastSwingHigh = na
var float lastSwingLow  = na
var int lastSwingHighBar = na
var int lastSwingLowBar  = na

if not na(mssPH)
    lastSwingHigh := mssPH
    lastSwingHighBar := bar_index - mssPivotLen

if not na(mssPL)
    lastSwingLow := mssPL
    lastSwingLowBar := bar_index - mssPivotLen

// Track latest sweep
anyLowSweep  = alSweep or llSweep or nylSweep
anyHighSweep = ahSweep or lhSweep or nyhSweep

var int lastLowSweepBar = na
var int lastHighSweepBar = na

if anyLowSweep
    lastLowSweepBar := bar_index

if anyHighSweep
    lastHighSweepBar := bar_index

lowSweepValid  = not na(lastLowSweepBar) and bar_index - lastLowSweepBar <= mssExpiryBars
highSweepValid = not na(lastHighSweepBar) and bar_index - lastHighSweepBar <= mssExpiryBars

bullMSS = showMSS and lowSweepValid and not na(lastSwingHigh) and close > lastSwingHigh
bearMSS = showMSS and highSweepValid and not na(lastSwingLow) and close < lastSwingLow

var line[] mssLines = array.new_line()
var label[] mssLabels = array.new_label()

addMSS(_x1, _y1, _x2, _y2, _txt, _clr, _isBull) =>
    if showMSS
        l = line.new(
             x1=_x1,
             y1=_y1,
             x2=_x2,
             y2=_y2,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=_clr,
             width=mssLineWidth
        )

        lab = label.new(
             x=_x2,
             y=_y2,
             text=_txt,
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=_isBull ? label.style_label_up : label.style_label_down,
             color=color.new(_clr, 80),
             textcolor=_clr,
             size=size.tiny
        )

        array.push(mssLines, l)
        array.push(mssLabels, lab)

        while array.size(mssLines) > maxMSSSignals
            line.delete(array.shift(mssLines))
            label.delete(array.shift(mssLabels))

if bullMSS
    addMSS(lastSwingHighBar, lastSwingHigh, bar_index, close, "Bull MSS", bullMSSColor, true)
    lastLowSweepBar := na

if bearMSS
    addMSS(lastSwingLowBar, lastSwingLow, bar_index, close, "Bear MSS", bearMSSColor, false)
    lastHighSweepBar := na

alertcondition(bullMSS, "Bullish MSS After Sweep", "Bullish MSS confirmed after liquidity sweep")
alertcondition(bearMSS, "Bearish MSS After Sweep", "Bearish MSS confirmed after liquidity sweep")
````
