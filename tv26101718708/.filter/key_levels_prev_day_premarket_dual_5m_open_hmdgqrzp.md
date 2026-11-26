# Key Levels: Prev Day + Premarket + Dual 5m Open

- url: https://www.tradingview.com/script/hMdGqRZp-Key-Levels-Prev-Day-Premarket-Dual-5m-Open/
- type: indicator
- pine_id: PUB;9e6c2b413afa478c92c9b6bb949874f3
- version: 1.0

## Description

This script Locates the Previous Day High and Low, the Pre-Market High and Low, and the 5 minute opening range high and low of the am and pm sessions. This version fixs the pm session problem.

## Source Code

````pine
//@version=5
indicator("Key Levels: Prev Day + Premarket + Dual 5m Open", overlay=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showPD = input.bool(true, "Show Prev Day High/Low")
showPM = input.bool(true, "Show Pre Market High/Low")
showOR = input.bool(true, "Show 5m Open High/Low")

labelOffset = input.int(10, "Label Offset", minval=1)

// Session timezone
tz = "America/New_York"

// Previous Day colors
colPDHLine = input.color(color.orange, "Prev Day High Line Color")
colPDHText = input.color(color.white,  "Prev Day High Text Color")
colPDLLine = input.color(color.orange, "Prev Day Low Line Color")
colPDLText = input.color(color.white,  "Prev Day Low Text Color")

// Premarket colors
colPMHLine = input.color(color.aqua,   "Pre Market High Line Color")
colPMHText = input.color(color.white,  "Pre Market High Text Color")
colPMLLine = input.color(color.aqua,   "Pre Market Low Line Color")
colPMLText = input.color(color.white,  "Pre Market Low Text Color")

// 5-minute range colors
colORHLine = input.color(color.red,    "5 Min High Line Color")
colORHText = input.color(color.white,  "5 Min High Text Color")
colORLLine = input.color(color.red,    "5 Min Low Line Color")
colORLText = input.color(color.white,  "5 Min Low Text Color")

// Line widths
widthPD = input.int(2, "Prev Day Line Width", minval=1, maxval=5)
widthPM = input.int(2, "Pre Market Line Width", minval=1, maxval=5)
widthOR = input.int(2, "5 Min Range Line Width", minval=1, maxval=5)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TIME
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
hh = hour(time, tz)
mm = minute(time, tz)
minuteOfDay = hh * 60 + mm

// Trade day rolls at 18:00 NY time
tradeClock = time - 18 * 60 * 60 * 1000
tradeDayKey = year(tradeClock, tz) * 10000 + month(tradeClock, tz) * 100 + dayofmonth(tradeClock, tz)
newTradeDay = ta.change(tradeDayKey) != 0

// Sessions in New York time
pmStart = 3 * 60
pmEnd   = 9 * 60 + 29

eveORStart = 18 * 60
eveOREnd   = 18 * 60 + 4

nyORStart  = 9 * 60 + 30
nyOREnd    = 9 * 60 + 34

inPremarket = minuteOfDay >= pmStart and minuteOfDay <= pmEnd
inEveOR     = minuteOfDay >= eveORStart and minuteOfDay <= eveOREnd
inNyOR      = minuteOfDay >= nyORStart and minuteOfDay <= nyOREnd

pmJustEnded    = not inPremarket and inPremarket[1]
eveORJustEnded = not inEveOR and inEveOR[1]
nyORJustEnded  = not inNyOR and inNyOR[1]

// Use evening OR from 18:00 through 09:29
// Use NY OR from 09:30 through 17:59
useNyOR = minuteOfDay >= nyORStart and minuteOfDay < eveORStart

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PREV DAY (PRIOR FUTURES SESSION 18:00 → 17:00)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float curSessHigh = na
var float curSessLow  = na
var float prevSessHigh = na
var float prevSessLow  = na
var int   prevSessStartBar = na

if barstate.isfirst
    curSessHigh := high
    curSessLow  := low
    prevSessStartBar := bar_index

if newTradeDay
    prevSessHigh := curSessHigh
    prevSessLow  := curSessLow
    prevSessStartBar := bar_index

    curSessHigh := high
    curSessLow  := low
else
    curSessHigh := na(curSessHigh) ? high : math.max(curSessHigh, high)
    curSessLow  := na(curSessLow)  ? low  : math.min(curSessLow, low)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PREMARKET TRACKING (03:00 → 09:29 NY)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float pmHigh = na
var float pmLow  = na
var bool  pmLocked = false
var int   pmStartBar = na

if newTradeDay
    pmHigh := na
    pmLow := na
    pmLocked := false
    pmStartBar := na

if inPremarket and not pmLocked
    pmStartBar := na(pmStartBar) ? bar_index : pmStartBar
    pmHigh := na(pmHigh) ? high : math.max(pmHigh, high)
    pmLow  := na(pmLow)  ? low  : math.min(pmLow, low)

if pmJustEnded
    pmLocked := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EVENING 5-MIN OPEN (18:00 → 18:04 NY)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float eveHigh = na
var float eveLow  = na
var bool  eveLocked = false
var int   eveStartBar = na

if newTradeDay
    eveHigh := na
    eveLow := na
    eveLocked := false
    eveStartBar := na

if inEveOR and not eveLocked
    eveStartBar := na(eveStartBar) ? bar_index : eveStartBar
    eveHigh := na(eveHigh) ? high : math.max(eveHigh, high)
    eveLow  := na(eveLow)  ? low  : math.min(eveLow, low)

if eveORJustEnded
    eveLocked := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NY 5-MIN OPEN (09:30 → 09:34 NY)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float nyHigh = na
var float nyLow  = na
var bool  nyLocked = false
var int   nyStartBar = na

if newTradeDay
    nyHigh := na
    nyLow := na
    nyLocked := false
    nyStartBar := na

if inNyOR and not nyLocked
    nyStartBar := na(nyStartBar) ? bar_index : nyStartBar
    nyHigh := na(nyHigh) ? high : math.max(nyHigh, high)
    nyLow  := na(nyLow)  ? low  : math.min(nyLow, low)

if nyORJustEnded
    nyLocked := true

// Active 5-minute levels + start bar
activeORHigh = useNyOR ? nyHigh : eveHigh
activeORLow  = useNyOR ? nyLow  : eveLow
activeORStartBar = useNyOR ? nyStartBar : eveStartBar

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OBJECTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var line pdhLine = na
var line pdlLine = na
var line pmhLine = na
var line pmlLine = na
var line orhLine = na
var line orlLine = na

var label pdhLab = na
var label pdlLab = na
var label pmhLab = na
var label pmlLab = na
var label orhLab = na
var label orlLab = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RESET OBJECTS EACH TRADE DAY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if newTradeDay
    line.delete(pdhLine)
    line.delete(pdlLine)
    line.delete(pmhLine)
    line.delete(pmlLine)
    line.delete(orhLine)
    line.delete(orlLine)

    label.delete(pdhLab)
    label.delete(pdlLab)
    label.delete(pmhLab)
    label.delete(pmlLab)
    label.delete(orhLab)
    label.delete(orlLab)

    pdhLine := na
    pdlLine := na
    pmhLine := na
    pmlLine := na
    orhLine := na
    orlLine := na

    pdhLab := na
    pdlLab := na
    pmhLab := na
    pmlLab := na
    orhLab := na
    orlLab := na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAW PREV DAY LEVELS AS TRUE RAYS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if showPD and not na(prevSessHigh) and not na(prevSessStartBar)
    if na(pdhLine)
        pdhLine := line.new(prevSessStartBar, prevSessHigh, bar_index, prevSessHigh, extend=extend.right, color=colPDHLine, width=widthPD)
        pdhLab  := label.new(bar_index + labelOffset, prevSessHigh, "Prev Day High", style=label.style_label_left, color=colPDHLine, textcolor=colPDHText)
    else
        line.set_x1(pdhLine, prevSessStartBar)
        line.set_y1(pdhLine, prevSessHigh)
        line.set_x2(pdhLine, bar_index)
        line.set_y2(pdhLine, prevSessHigh)
        line.set_color(pdhLine, colPDHLine)
        line.set_width(pdhLine, widthPD)
        label.set_x(pdhLab, bar_index + labelOffset)
        label.set_y(pdhLab, prevSessHigh)
        label.set_color(pdhLab, colPDHLine)
        label.set_textcolor(pdhLab, colPDHText)
        label.set_text(pdhLab, "Prev Day High")

if showPD and not na(prevSessLow) and not na(prevSessStartBar)
    if na(pdlLine)
        pdlLine := line.new(prevSessStartBar, prevSessLow, bar_index, prevSessLow, extend=extend.right, color=colPDLLine, width=widthPD)
        pdlLab  := label.new(bar_index + labelOffset, prevSessLow, "Prev Day Low", style=label.style_label_left, color=colPDLLine, textcolor=colPDLText)
    else
        line.set_x1(pdlLine, prevSessStartBar)
        line.set_y1(pdlLine, prevSessLow)
        line.set_x2(pdlLine, bar_index)
        line.set_y2(pdlLine, prevSessLow)
        line.set_color(pdlLine, colPDLLine)
        line.set_width(pdlLine, widthPD)
        label.set_x(pdlLab, bar_index + labelOffset)
        label.set_y(pdlLab, prevSessLow)
        label.set_color(pdlLab, colPDLLine)
        label.set_textcolor(pdlLab, colPDLText)
        label.set_text(pdlLab, "Prev Day Low")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAW PREMARKET LEVELS AS TRUE RAYS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if showPM and not na(pmHigh) and not na(pmStartBar)
    if na(pmhLine)
        pmhLine := line.new(pmStartBar, pmHigh, bar_index, pmHigh, extend=extend.right, color=colPMHLine, width=widthPM)
        pmhLab  := label.new(bar_index + labelOffset, pmHigh, "Pre Market High", style=label.style_label_left, color=colPMHLine, textcolor=colPMHText)
    else
        line.set_x1(pmhLine, pmStartBar)
        line.set_y1(pmhLine, pmHigh)
        line.set_x2(pmhLine, bar_index)
        line.set_y2(pmhLine, pmHigh)
        line.set_color(pmhLine, colPMHLine)
        line.set_width(pmhLine, widthPM)
        label.set_x(pmhLab, bar_index + labelOffset)
        label.set_y(pmhLab, pmHigh)
        label.set_color(pmhLab, colPMHLine)
        label.set_textcolor(pmhLab, colPMHText)
        label.set_text(pmhLab, "Pre Market High")

if showPM and not na(pmLow) and not na(pmStartBar)
    if na(pmlLine)
        pmlLine := line.new(pmStartBar, pmLow, bar_index, pmLow, extend=extend.right, color=colPMLLine, width=widthPM)
        pmlLab  := label.new(bar_index + labelOffset, pmLow, "Pre Market Low", style=label.style_label_left, color=colPMLLine, textcolor=colPMLText)
    else
        line.set_x1(pmlLine, pmStartBar)
        line.set_y1(pmlLine, pmLow)
        line.set_x2(pmlLine, bar_index)
        line.set_y2(pmlLine, pmLow)
        line.set_color(pmlLine, colPMLLine)
        line.set_width(pmlLine, widthPM)
        label.set_x(pmlLab, bar_index + labelOffset)
        label.set_y(pmlLab, pmLow)
        label.set_color(pmlLab, colPMLLine)
        label.set_textcolor(pmlLab, colPMLText)
        label.set_text(pmlLab, "Pre Market Low")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAW ACTIVE 5-MIN LEVELS AS TRUE RAYS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if showOR and not na(activeORHigh) and not na(activeORStartBar)
    if na(orhLine)
        orhLine := line.new(activeORStartBar, activeORHigh, bar_index, activeORHigh, extend=extend.right, color=colORHLine, width=widthOR)
        orhLab  := label.new(bar_index + labelOffset, activeORHigh, "5 MIN H", style=label.style_label_left, color=colORHLine, textcolor=colORHText)
    else
        line.set_x1(orhLine, activeORStartBar)
        line.set_y1(orhLine, activeORHigh)
        line.set_x2(orhLine, bar_index)
        line.set_y2(orhLine, activeORHigh)
        line.set_color(orhLine, colORHLine)
        line.set_width(orhLine, widthOR)
        label.set_x(orhLab, bar_index + labelOffset)
        label.set_y(orhLab, activeORHigh)
        label.set_color(orhLab, colORHLine)
        label.set_textcolor(orhLab, colORHText)
        label.set_text(orhLab, "5 MIN H")

if showOR and not na(activeORLow) and not na(activeORStartBar)
    if na(orlLine)
        orlLine := line.new(activeORStartBar, activeORLow, bar_index, activeORLow, extend=extend.right, color=colORLLine, width=widthOR)
        orlLab  := label.new(bar_index + labelOffset, activeORLow, "5 MIN L", style=label.style_label_left, color=colORLLine, textcolor=colORLText)
    else
        line.set_x1(orlLine, activeORStartBar)
        line.set_y1(orlLine, activeORLow)
        line.set_x2(orlLine, bar_index)
        line.set_y2(orlLine, activeORLow)
        line.set_color(orlLine, colORLLine)
        line.set_width(orlLine, widthOR)
        label.set_x(orlLab, bar_index + labelOffset)
        label.set_y(orlLab, activeORLow)
        label.set_color(orlLab, colORLLine)
        label.set_textcolor(orlLab, colORLText)
        label.set_text(orlLab, "5 MIN L")
````
