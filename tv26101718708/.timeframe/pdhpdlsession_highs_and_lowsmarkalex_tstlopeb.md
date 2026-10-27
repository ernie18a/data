# PDH+PDL+Session Highs and Lows_MarkAlex

- url: https://www.tradingview.com/script/TStlOpeB-PDH-PDL-Session-Highs-and-Lows-MarkAlex/
- type: indicator
- pine_id: PUB;bbd3a4326efa457681fd7ad459918282
- version: 2.0

## Description

"PDH/PDL & Session Levels"
A clean multi-timeframe levels indicator that plots two types of horizontal reference lines anchored to their source candles and extending to the current bar:
Daily/Weekly/Monthly Levels — Draws the previous day high and low, previous week high and low, and the current daily, weekly, and monthly open prices as color-coded horizontal lines. Each line originates from the first bar of the current period and stretches to the current candle so you always see exactly how far price has traveled from those key levels. All seven levels are individually toggleable with custom colors.
Session Highs & Lows — Tracks the highest and lowest wick printed during each of the three major trading sessions — Asia (1pm–5pm MT), London (1am–6am MT), and New York (6:30am–3pm MT) — and draws a horizontal line anchored to the exact candle that made that high or low, extending to the current bar. Shows the last two occurrences of each session so you can compare back-to-back sessions. The most recent session is full color, the previous one is faded. All three sessions are individually toggleable with custom colors.

## Source Code

````pine
//@version=6
indicator("PDH PDL & Session Levels", overlay=true, max_bars_back=500, max_lines_count=200, max_labels_count=200)

// ─────────────────────────────────────────────
// DAILY/WEEKLY/MONTHLY COLORS & TOGGLES
// ─────────────────────────────────────────────
grpD = "Daily / Weekly / Monthly"
colorHigh      = input.color(color.red,    "High Line Color",         group=grpD)
colorLow       = input.color(color.green,  "Low Line Color",          group=grpD)
colorDayOpen   = input.color(color.blue,   "Daily Open Color",        group=grpD)
colorWeekOpen  = input.color(color.orange, "Weekly Open Color",       group=grpD)
colorMonthOpen = input.color(color.purple, "Monthly Open Color",      group=grpD)
showPDH = input.bool(true, "Show PDH", group=grpD)
showPDL = input.bool(true, "Show PDL", group=grpD)
showPWH = input.bool(true, "Show PWH", group=grpD)
showPWL = input.bool(true, "Show PWL", group=grpD)
showDO  = input.bool(true, "Show Daily Open",   group=grpD)
showWO  = input.bool(true, "Show Weekly Open",  group=grpD)
showMO  = input.bool(true, "Show Monthly Open", group=grpD)

// ─────────────────────────────────────────────
// SESSION COLORS & TOGGLES
// ─────────────────────────────────────────────
grp1 = "London Session"
showLondon = input.bool(true, "Show London", group=grp1)
londonCol  = input.color(color.new(#00BFFF, 0), "London Color", group=grp1)
londonSess = input.session("0100-0600", "London Time (UTC-7)", group=grp1)

grp2 = "Asia Session"
showAsia = input.bool(true, "Show Asia", group=grp2)
asiaCol  = input.color(color.new(#FF9800, 0), "Asia Color", group=grp2)
asiaSess = input.session("1300-1700", "Asia Time (UTC-7)", group=grp2)

grp3 = "New York Session"
showNY  = input.bool(true, "Show New York", group=grp3)
nyCol   = input.color(color.new(#00FF88, 0), "New York Color", group=grp3)
nySess  = input.session("0630-1500", "NY Time (UTC-7)", group=grp3)

// ─────────────────────────────────────────────
// DAILY/WEEKLY/MONTHLY DATA
// ─────────────────────────────────────────────
yesterdayHigh    = request.security(syminfo.tickerid, "D", high[1])
yesterdayLow     = request.security(syminfo.tickerid, "D", low[1])
previousWeekHigh = request.security(syminfo.tickerid, "W", high[1])
previousWeekLow  = request.security(syminfo.tickerid, "W", low[1])
dayOpen          = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_on)
weekOpen         = request.security(syminfo.tickerid, "W", open, lookahead=barmerge.lookahead_on)
monthOpen        = request.security(syminfo.tickerid, "M", open, lookahead=barmerge.lookahead_on)

var int dayStartBar   = na
var int weekStartBar  = na
var int monthStartBar = na

isNewDay   = ta.change(time("D")) != 0
isNewWeek  = ta.change(time("W")) != 0
isNewMonth = ta.change(time("M")) != 0

if isNewDay
    dayStartBar := bar_index
if isNewWeek
    weekStartBar := bar_index
if isNewMonth
    monthStartBar := bar_index

// ─────────────────────────────────────────────
// SESSION DETECTION
// ─────────────────────────────────────────────
inLondon = not na(time(timeframe.period, londonSess, "America/Phoenix"))
inAsia   = not na(time(timeframe.period, asiaSess,   "America/Phoenix"))
inNY     = not na(time(timeframe.period, nySess,     "America/Phoenix"))

// ─────────────────────────────────────────────
// SESSION TRACKERS
// ─────────────────────────────────────────────

// ── LONDON ──
var float lCurH = na, var float lCurL = na
var int lCurHB = na,  var int lCurLB = na
var float lH1 = na,   var float lL1 = na, var int lHB1 = na, var int lLB1 = na, var int lE1 = na
var float lH2 = na,   var float lL2 = na, var int lHB2 = na, var int lLB2 = na, var int lE2 = na
var bool lWas = false

if inLondon
    if not lWas
        lCurH := high, lCurL := low, lCurHB := bar_index, lCurLB := bar_index
    else
        if high >= lCurH
            lCurH := high, lCurHB := bar_index
        if low <= lCurL
            lCurL := low, lCurLB := bar_index
    lWas := true
else
    if lWas
        lH2 := lH1, lL2 := lL1, lHB2 := lHB1, lLB2 := lLB1, lE2 := lE1
        lH1 := lCurH, lL1 := lCurL, lHB1 := lCurHB, lLB1 := lCurLB, lE1 := bar_index - 1
    lWas := false

// ── ASIA ──
var float aCurH = na, var float aCurL = na
var int aCurHB = na,  var int aCurLB = na
var float aH1 = na,   var float aL1 = na, var int aHB1 = na, var int aLB1 = na, var int aE1 = na
var float aH2 = na,   var float aL2 = na, var int aHB2 = na, var int aLB2 = na, var int aE2 = na
var bool aWas = false

if inAsia
    if not aWas
        aCurH := high, aCurL := low, aCurHB := bar_index, aCurLB := bar_index
    else
        if high >= aCurH
            aCurH := high, aCurHB := bar_index
        if low <= aCurL
            aCurL := low, aCurLB := bar_index
    aWas := true
else
    if aWas
        aH2 := aH1, aL2 := aL1, aHB2 := aHB1, aLB2 := aLB1, aE2 := aE1
        aH1 := aCurH, aL1 := aCurL, aHB1 := aCurHB, aLB1 := aCurLB, aE1 := bar_index - 1
    aWas := false

// ── NY ──
var float nCurH = na, var float nCurL = na
var int nCurHB = na,  var int nCurLB = na
var float nH1 = na,   var float nL1 = na, var int nHB1 = na, var int nLB1 = na, var int nE1 = na
var float nH2 = na,   var float nL2 = na, var int nHB2 = na, var int nLB2 = na, var int nE2 = na
var bool nWas = false

if inNY
    if not nWas
        nCurH := high, nCurL := low, nCurHB := bar_index, nCurLB := bar_index
    else
        if high >= nCurH
            nCurH := high, nCurHB := bar_index
        if low <= nCurL
            nCurL := low, nCurLB := bar_index
    nWas := true
else
    if nWas
        nH2 := nH1, nL2 := nL1, nHB2 := nHB1, nLB2 := nLB1, nE2 := nE1
        nH1 := nCurH, nL1 := nCurL, nHB1 := nCurHB, nLB1 := nCurLB, nE1 := bar_index - 1
    nWas := false

// ─────────────────────────────────────────────
// LINE/LABEL VARS
// ─────────────────────────────────────────────
var line highLine = na,       var line lowLine = na
var line weekHighLine = na,   var line weekLowLine = na
var line openLine = na,       var line weekOpenLine = na,   var line monthOpenLine = na
var label highLabel = na,     var label lowLabel = na
var label weekHighLabel = na, var label weekLowLabel = na
var label openLabel = na,     var label weekOpenLabel = na, var label monthOpenLabel = na

var line llH1=na, var line llL1=na, var line llH2=na, var line llL2=na
var line laH1=na, var line laL1=na, var line laH2=na, var line laL2=na
var line lnH1=na, var line lnL1=na, var line lnH2=na, var line lnL2=na
var label lbH1=na, var label lbL1=na, var label lbH2=na, var label lbL2=na
var label abH1=na, var label abL1=na, var label abH2=na, var label abL2=na
var label nbH1=na, var label nbL1=na, var label nbH2=na, var label nbL2=na

// ─────────────────────────────────────────────
// DRAW DAILY/WEEKLY/MONTHLY — every bar
// ─────────────────────────────────────────────
secondsPerBar = timeframe.in_seconds(timeframe.period)
barsPerDay    = math.ceil(86400 / secondsPerBar)
cap           = math.min(barsPerDay * 7, 4999)

line.delete(highLine),      line.delete(lowLine)
line.delete(weekHighLine),  line.delete(weekLowLine)
line.delete(openLine),      line.delete(weekOpenLine),  line.delete(monthOpenLine)
label.delete(highLabel),    label.delete(lowLabel)
label.delete(weekHighLabel),label.delete(weekLowLabel)
label.delete(openLabel),    label.delete(weekOpenLabel),label.delete(monthOpenLabel)

if showPDH and not na(yesterdayHigh) and not na(dayStartBar)
    cappedDay = math.max(dayStartBar, bar_index - cap)
    highLine  := line.new(cappedDay, yesterdayHigh, bar_index, yesterdayHigh, color=colorHigh, width=1)
    highLabel := label.new(bar_index, yesterdayHigh, text="PDH", textcolor=colorHigh, style=label.style_none, size=size.small)

if showPDL and not na(yesterdayLow) and not na(dayStartBar)
    cappedDay = math.max(dayStartBar, bar_index - cap)
    lowLine  := line.new(cappedDay, yesterdayLow, bar_index, yesterdayLow, color=colorLow, width=1)
    lowLabel := label.new(bar_index, yesterdayLow, text="PDL", textcolor=colorLow, style=label.style_none, size=size.small)

if showPWH and not na(previousWeekHigh) and not na(weekStartBar)
    cappedWeek = math.max(weekStartBar, bar_index - cap)
    weekHighLine  := line.new(cappedWeek, previousWeekHigh, bar_index, previousWeekHigh, color=colorHigh, width=1)
    weekHighLabel := label.new(bar_index, previousWeekHigh, text="PWH", textcolor=colorHigh, style=label.style_none, size=size.small)

if showPWL and not na(previousWeekLow) and not na(weekStartBar)
    cappedWeek = math.max(weekStartBar, bar_index - cap)
    weekLowLine  := line.new(cappedWeek, previousWeekLow, bar_index, previousWeekLow, color=colorLow, width=1)
    weekLowLabel := label.new(bar_index, previousWeekLow, text="PWL", textcolor=colorLow, style=label.style_none, size=size.small)

if showDO and not na(dayOpen) and not na(dayStartBar)
    cappedDay = math.max(dayStartBar, bar_index - cap)
    openLine  := line.new(cappedDay, dayOpen, bar_index, dayOpen, color=colorDayOpen, width=1)
    openLabel := label.new(bar_index, dayOpen, text="D", textcolor=colorDayOpen, style=label.style_none, size=size.small)

if showWO and not na(weekOpen) and not na(weekStartBar)
    cappedWeek = math.max(weekStartBar, bar_index - cap)
    weekOpenLine  := line.new(cappedWeek, weekOpen, bar_index, weekOpen, color=colorWeekOpen, width=1)
    weekOpenLabel := label.new(bar_index, weekOpen, text="W", textcolor=colorWeekOpen, style=label.style_none, size=size.small)

if showMO and not na(monthOpen) and not na(monthStartBar)
    cappedMonth = math.max(monthStartBar, bar_index - cap)
    monthOpenLine  := line.new(cappedMonth, monthOpen, bar_index, monthOpen, color=colorMonthOpen, width=1)
    monthOpenLabel := label.new(bar_index, monthOpen, text="M", textcolor=colorMonthOpen, style=label.style_none, size=size.small)

// ─────────────────────────────────────────────
// DRAW SESSION LINES — last bar only
// ─────────────────────────────────────────────
if barstate.islast
    line.delete(llH1),  line.delete(llL1),  line.delete(llH2),  line.delete(llL2)
    line.delete(laH1),  line.delete(laL1),  line.delete(laH2),  line.delete(laL2)
    line.delete(lnH1),  line.delete(lnL1),  line.delete(lnH2),  line.delete(lnL2)
    label.delete(lbH1), label.delete(lbL1), label.delete(lbH2), label.delete(lbL2)
    label.delete(abH1), label.delete(abL1), label.delete(abH2), label.delete(abL2)
    label.delete(nbH1), label.delete(nbL1), label.delete(nbH2), label.delete(nbL2)

    lH  = inLondon ? lCurH  : lH1,  lL  = inLondon ? lCurL  : lL1
    lHB = inLondon ? lCurHB : lHB1, lLB = inLondon ? lCurLB : lLB1
    lH_2 = inLondon ? lH1 : lH2,    lL_2 = inLondon ? lL1 : lL2
    lHB_2 = inLondon ? lHB1 : lHB2, lLB_2 = inLondon ? lLB1 : lLB2
    lEnd_2 = inLondon ? lE1 : lE2

    aH  = inAsia ? aCurH  : aH1,    aL  = inAsia ? aCurL  : aL1
    aHB = inAsia ? aCurHB : aHB1,   aLB = inAsia ? aCurLB : aLB1
    aH_2 = inAsia ? aH1 : aH2,      aL_2 = inAsia ? aL1 : aL2
    aHB_2 = inAsia ? aHB1 : aHB2,   aLB_2 = inAsia ? aLB1 : aLB2
    aEnd_2 = inAsia ? aE1 : aE2

    nH  = inNY ? nCurH  : nH1,      nL  = inNY ? nCurL  : nL1
    nHB = inNY ? nCurHB : nHB1,     nLB = inNY ? nCurLB : nLB1
    nH_2 = inNY ? nH1 : nH2,        nL_2 = inNY ? nL1 : nL2
    nHB_2 = inNY ? nHB1 : nHB2,     nLB_2 = inNY ? nLB1 : nLB2
    nEnd_2 = inNY ? nE1 : nE2

    if showLondon
        c1 = londonCol
        c2 = color.new(londonCol, 65)
        if not na(lH) and not na(lHB)
            llH1 := line.new(lHB, lH, bar_index, lH, color=c1, width=1)
            lbH1 := label.new(bar_index, lH, text="LH", textcolor=c1, style=label.style_none, size=size.small)
        if not na(lL) and not na(lLB)
            llL1 := line.new(lLB, lL, bar_index, lL, color=c1, width=1)
            lbL1 := label.new(bar_index, lL, text="LL", textcolor=c1, style=label.style_none, size=size.small)
        if not na(lH_2) and not na(lHB_2) and not na(lEnd_2)
            llH2 := line.new(lHB_2, lH_2, lEnd_2, lH_2, color=c2, width=1)
            lbH2 := label.new(lEnd_2, lH_2, text="LH", textcolor=c2, style=label.style_none, size=size.small)
        if not na(lL_2) and not na(lLB_2) and not na(lEnd_2)
            llL2 := line.new(lLB_2, lL_2, lEnd_2, lL_2, color=c2, width=1)
            lbL2 := label.new(lEnd_2, lL_2, text="LL", textcolor=c2, style=label.style_none, size=size.small)

    if showAsia
        c1 = asiaCol
        c2 = color.new(asiaCol, 65)
        if not na(aH) and not na(aHB)
            laH1 := line.new(aHB, aH, bar_index, aH, color=c1, width=1)
            abH1 := label.new(bar_index, aH, text="AH", textcolor=c1, style=label.style_none, size=size.small)
        if not na(aL) and not na(aLB)
            laL1 := line.new(aLB, aL, bar_index, aL, color=c1, width=1)
            abL1 := label.new(bar_index, aL, text="AL", textcolor=c1, style=label.style_none, size=size.small)
        if not na(aH_2) and not na(aHB_2) and not na(aEnd_2)
            laH2 := line.new(aHB_2, aH_2, aEnd_2, aH_2, color=c2, width=1)
            abH2 := label.new(aEnd_2, aH_2, text="AH", textcolor=c2, style=label.style_none, size=size.small)
        if not na(aL_2) and not na(aLB_2) and not na(aEnd_2)
            laL2 := line.new(aLB_2, aL_2, aEnd_2, aL_2, color=c2, width=1)
            abL2 := label.new(aEnd_2, aL_2, text="AL", textcolor=c2, style=label.style_none, size=size.small)

    if showNY
        c1 = nyCol
        c2 = color.new(nyCol, 65)
        if not na(nH) and not na(nHB)
            lnH1 := line.new(nHB, nH, bar_index, nH, color=c1, width=1)
            nbH1 := label.new(bar_index, nH, text="NYH", textcolor=c1, style=label.style_none, size=size.small)
        if not na(nL) and not na(nLB)
            lnL1 := line.new(nLB, nL, bar_index, nL, color=c1, width=1)
            nbL1 := label.new(bar_index, nL, text="NYL", textcolor=c1, style=label.style_none, size=size.small)
        if not na(nH_2) and not na(nHB_2) and not na(nEnd_2)
            lnH2 := line.new(nHB_2, nH_2, nEnd_2, nH_2, color=c2, width=1)
            nbH2 := label.new(nEnd_2, nH_2, text="NYH", textcolor=c2, style=label.style_none, size=size.small)
        if not na(nL_2) and not na(nLB_2) and not na(nEnd_2)
            lnL2 := line.new(nLB_2, nL_2, nEnd_2, nL_2, color=c2, width=1)
            nbL2 := label.new(nEnd_2, nL_2, text="NYL", textcolor=c2, style=label.style_none, size=size.small)
````
