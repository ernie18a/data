# Key Levels: PDH/PDL + ONH/ONL + PWH/PWL + PMH/PML

- url: https://www.tradingview.com/script/oemzRUf9-Key-Levels-PDH-PDL-ONH-ONL-PWH-PWL-PMH-PML/
- type: indicator
- pine_id: PUB;b6fa326f24fb4781b6c79415fe0dbb6f
- version: 2.0

## Description

A clean, no-repaint indicator that plots the most important reference levels traders watch every session — anchored exactly at the candle that made each high or low, with right-side labels showing the price.
Levels included:

PDH / PDL — Previous Day High & Low, calculated strictly from your chosen Regular Trading Hours session (default 0930-1600 ET), so overnight wicks don't contaminate the levels
PDC — Previous Day Close (optional), anchored at the actual 4:00 PM RTH close
ONH / ONL — Overnight High & Low, with a fully customizable session window (default 2000-0400 ET, ending before pre-market). The lines paint live during the overnight session, expanding as new highs/lows print, then freeze in place when the session ends
PWH / PWL — Previous Week High & Low
PMH / PML — Previous Month High & Low

Features:

Per-level toggles, colors, line widths (1–5), styles (solid / dashed / dotted), and transparency
Each line is anchored at the actual wick that created the high or low — no floating horizontals
Only one set of lines on the chart at any time — clean and uncluttered
Right-side labels with the level name and exact price
Configurable session timezone (defaults to America/New_York)
Adjustable right-extension distance
Uses time-based anchoring, so it works on every timeframe from 1-minute up to daily without bar-limit errors
No repainting — previous-period values freeze the moment a new period begins

## Source Code

````pine
//@version=5
indicator("Key Levels: PDH/PDL + ONH/ONL + PWH/PWL + PMH/PML", shorttitle="Key Levels", overlay=true, max_lines_count=500, max_labels_count=500)

// ============================================================================
// INPUTS
// ============================================================================
grpSessions = "Sessions"
rthSession  = input.session("0930-1600", "RTH Session for PDH/PDL", group=grpSessions)
onSession   = input.session("2000-0400", "Overnight Session (ONH/ONL)", group=grpSessions, tooltip="Default 2000-0400 ends BEFORE pre-market. Try '1600-0400' for full overnight.")
sessionTZ   = input.string("America/New_York", "Session Timezone", options=["America/New_York","America/Chicago","America/Los_Angeles","Europe/London","Asia/Tokyo","exchange"], group=grpSessions)

grpToggles = "Show / Hide"
showPDH = input.bool(true,  "Show PDH (Prev Day High)",  group=grpToggles)
showPDL = input.bool(true,  "Show PDL (Prev Day Low)",   group=grpToggles)
showPDC = input.bool(false, "Show PDC (Prev Day Close)", group=grpToggles)
showONH = input.bool(true,  "Show ONH (Overnight High)", group=grpToggles)
showONL = input.bool(true,  "Show ONL (Overnight Low)",  group=grpToggles)
showPWH = input.bool(true,  "Show PWH (Prev Week High)", group=grpToggles)
showPWL = input.bool(true,  "Show PWL (Prev Week Low)",  group=grpToggles)
showPMH = input.bool(true,  "Show PMH (Prev Month High)",group=grpToggles)
showPML = input.bool(true,  "Show PML (Prev Month Low)", group=grpToggles)
showLabels = input.bool(true, "Show Labels",  group=grpToggles)
showPriceOnLabel = input.bool(true, "Show Price on Label", group=grpToggles, tooltip="If on, labels show 'PDH 4523.50'. If off, labels show just 'PDH'.")

extendBars = input.int(60, "Extend Bars to the Right", minval=1, maxval=500, group="Line Extension")

g1="PDH Style"
pdhColor=input.color(color.green,"Color",group=g1)
pdhWidth=input.int(1,"Width",1,5,group=g1)
pdhStyleS=input.string("Solid","Style",options=["Solid","Dashed","Dotted"],group=g1)
pdhTransp=input.int(0,"Transparency",0,100,group=g1)

g2="PDL Style"
pdlColor=input.color(color.red,"Color",group=g2)
pdlWidth=input.int(1,"Width",1,5,group=g2)
pdlStyleS=input.string("Solid","Style",options=["Solid","Dashed","Dotted"],group=g2)
pdlTransp=input.int(0,"Transparency",0,100,group=g2)

g3="PDC Style"
pdcColor=input.color(color.gray,"Color",group=g3)
pdcWidth=input.int(1,"Width",1,5,group=g3)
pdcStyleS=input.string("Dashed","Style",options=["Solid","Dashed","Dotted"],group=g3)
pdcTransp=input.int(0,"Transparency",0,100,group=g3)

g4="ONH Style"
onhColor=input.color(color.blue,"Color",group=g4)
onhWidth=input.int(1,"Width",1,5,group=g4)
onhStyleS=input.string("Dashed","Style",options=["Solid","Dashed","Dotted"],group=g4)
onhTransp=input.int(0,"Transparency",0,100,group=g4)

g5="ONL Style"
onlColor=input.color(color.orange,"Color",group=g5)
onlWidth=input.int(1,"Width",1,5,group=g5)
onlStyleS=input.string("Dashed","Style",options=["Solid","Dashed","Dotted"],group=g5)
onlTransp=input.int(0,"Transparency",0,100,group=g5)

g6="PWH Style"
pwhColor=input.color(color.purple,"Color",group=g6)
pwhWidth=input.int(1,"Width",1,5,group=g6)
pwhStyleS=input.string("Solid","Style",options=["Solid","Dashed","Dotted"],group=g6)
pwhTransp=input.int(0,"Transparency",0,100,group=g6)

g7="PWL Style"
pwlColor=input.color(color.fuchsia,"Color",group=g7)
pwlWidth=input.int(1,"Width",1,5,group=g7)
pwlStyleS=input.string("Solid","Style",options=["Solid","Dashed","Dotted"],group=g7)
pwlTransp=input.int(0,"Transparency",0,100,group=g7)

g8="PMH Style"
pmhColor=input.color(color.teal,"Color",group=g8)
pmhWidth=input.int(1,"Width",1,5,group=g8)
pmhStyleS=input.string("Solid","Style",options=["Solid","Dashed","Dotted"],group=g8)
pmhTransp=input.int(0,"Transparency",0,100,group=g8)

g9="PML Style"
pmlColor=input.color(color.maroon,"Color",group=g9)
pmlWidth=input.int(1,"Width",1,5,group=g9)
pmlStyleS=input.string("Solid","Style",options=["Solid","Dashed","Dotted"],group=g9)
pmlTransp=input.int(0,"Transparency",0,100,group=g9)

// ============================================================================
// HELPERS
// ============================================================================
styleFromStr(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

applyTransp(c, t) => color.new(c, t)

inSession(sess) => not na(time(timeframe.period, sess, sessionTZ))

// Approximate ms per bar based on current timeframe — used to project line right
msPerBar = timeframe.in_seconds(timeframe.period) * 1000

// ============================================================================
// PDH / PDL / PDC — RTH-only, track TIMESTAMP of the high/low/close
// ============================================================================
isRTH  = inSession(rthSession)
newDay = ta.change(time("D")) != 0

var float todayHigh      = na
var float todayLow       = na
var float todayClose     = na
var int   todayHighTime  = na
var int   todayLowTime   = na
var int   todayCloseTime = na

var float pdh      = na
var float pdl      = na
var float pdc      = na
var int   pdhTime  = na
var int   pdlTime  = na
var int   pdcTime  = na

if newDay
    pdh     := todayHigh
    pdl     := todayLow
    pdc     := todayClose
    pdhTime := todayHighTime
    pdlTime := todayLowTime
    pdcTime := todayCloseTime
    todayHigh      := na
    todayLow       := na
    todayClose     := na
    todayHighTime  := na
    todayLowTime   := na
    todayCloseTime := na

if isRTH
    if na(todayHigh) or high > todayHigh
        todayHigh     := high
        todayHighTime := time
    if na(todayLow) or low < todayLow
        todayLow     := low
        todayLowTime := time
    todayClose     := close
    todayCloseTime := time

// ============================================================================
// PWH / PWL — previous week
// ============================================================================
newWeek = ta.change(time("W")) != 0

var float weekHigh     = na
var float weekLow      = na
var int   weekHighTime = na
var int   weekLowTime  = na

var float pwh     = na
var float pwl     = na
var int   pwhTime = na
var int   pwlTime = na

if newWeek
    pwh     := weekHigh
    pwl     := weekLow
    pwhTime := weekHighTime
    pwlTime := weekLowTime
    weekHigh     := na
    weekLow      := na
    weekHighTime := na
    weekLowTime  := na

if na(weekHigh) or high > weekHigh
    weekHigh     := high
    weekHighTime := time
if na(weekLow) or low < weekLow
    weekLow     := low
    weekLowTime := time

// ============================================================================
// PMH / PML — previous month
// ============================================================================
newMonth = ta.change(time("M")) != 0

var float monthHigh     = na
var float monthLow      = na
var int   monthHighTime = na
var int   monthLowTime  = na

var float pmh     = na
var float pml     = na
var int   pmhTime = na
var int   pmlTime = na

if newMonth
    pmh     := monthHigh
    pml     := monthLow
    pmhTime := monthHighTime
    pmlTime := monthLowTime
    monthHigh     := na
    monthLow      := na
    monthHighTime := na
    monthLowTime  := na

if na(monthHigh) or high > monthHigh
    monthHigh     := high
    monthHighTime := time
if na(monthLow) or low < monthLow
    monthLow     := low
    monthLowTime := time

// ============================================================================
// ONH / ONL — live during session, frozen after
// ============================================================================
isON      = inSession(onSession)
onStarted = isON and not isON[1]
onEnded   = not isON and isON[1]

var float onHighRun     = na
var float onLowRun      = na
var int   onHighRunTime = na
var int   onLowRunTime  = na

var float onhFrozen     = na
var float onlFrozen     = na
var int   onhFrozenTime = na
var int   onlFrozenTime = na

if onStarted
    onHighRun     := high
    onLowRun      := low
    onHighRunTime := time
    onLowRunTime  := time
    onhFrozen     := na
    onlFrozen     := na
    onhFrozenTime := na
    onlFrozenTime := na
else if isON
    if na(onHighRun) or high > onHighRun
        onHighRun     := high
        onHighRunTime := time
    if na(onLowRun) or low < onLowRun
        onLowRun     := low
        onLowRunTime := time

if onEnded
    onhFrozen     := onHighRun[1]
    onlFrozen     := onLowRun[1]
    onhFrozenTime := onHighRunTime[1]
    onlFrozenTime := onLowRunTime[1]
    onHighRun     := na
    onLowRun      := na
    onHighRunTime := na
    onLowRunTime  := na

onhDisplay     = isON ? onHighRun     : onhFrozen
onlDisplay     = isON ? onLowRun      : onlFrozen
onhDisplayTime = isON ? onHighRunTime : onhFrozenTime
onlDisplayTime = isON ? onLowRunTime  : onlFrozenTime

// ============================================================================
// DRAWING — uses xloc.bar_time so anchors work on any timeframe, any distance
// ============================================================================
var line  pdhLine = na
var label pdhLbl  = na
var line  pdlLine = na
var label pdlLbl  = na
var line  pdcLine = na
var label pdcLbl  = na
var line  onhLine = na
var label onhLbl  = na
var line  onlLine = na
var label onlLbl  = na
var line  pwhLine = na
var label pwhLbl  = na
var line  pwlLine = na
var label pwlLbl  = na
var line  pmhLine = na
var label pmhLbl  = na
var line  pmlLine = na
var label pmlLbl  = na

f_draw(_line, _lbl, _price, _anchorTime, _show, _showLbl, _showPrice, _txt, _col, _width, _styleStr, _transp) =>
    line  l = _line
    label b = _lbl
    if _show and not na(_price) and not na(_anchorTime)
        t1  = _anchorTime
        t2  = time + msPerBar * extendBars
        col = applyTransp(_col, _transp)
        sty = styleFromStr(_styleStr)
        if na(l)
            l := line.new(t1, _price, t2, _price, xloc=xloc.bar_time, extend=extend.none, color=col, style=sty, width=_width)
        else
            line.set_xy1(l, t1, _price)
            line.set_xy2(l, t2, _price)
            line.set_color(l, col)
            line.set_style(l, sty)
            line.set_width(l, _width)
        if _showLbl
            txt = _showPrice ? _txt + "  " + str.tostring(_price, format.mintick) : _txt
            if na(b)
                b := label.new(t2, _price, txt, xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 100), textcolor=col, size=size.small)
            else
                label.set_xy(b, t2, _price)
                label.set_text(b, txt)
                label.set_textcolor(b, col)
        else
            if not na(b)
                label.delete(b)
                b := na
    else
        if not na(l)
            line.delete(l)
            l := na
        if not na(b)
            label.delete(b)
            b := na
    [l, b]

if barstate.islast
    [a1, b1] = f_draw(pdhLine, pdhLbl, pdh, pdhTime, showPDH, showLabels, showPriceOnLabel, "PDH", pdhColor, pdhWidth, pdhStyleS, pdhTransp)
    pdhLine := a1
    pdhLbl  := b1

    [a2, b2] = f_draw(pdlLine, pdlLbl, pdl, pdlTime, showPDL, showLabels, showPriceOnLabel, "PDL", pdlColor, pdlWidth, pdlStyleS, pdlTransp)
    pdlLine := a2
    pdlLbl  := b2

    [a3, b3] = f_draw(pdcLine, pdcLbl, pdc, pdcTime, showPDC, showLabels, showPriceOnLabel, "PDC", pdcColor, pdcWidth, pdcStyleS, pdcTransp)
    pdcLine := a3
    pdcLbl  := b3

    [a4, b4] = f_draw(onhLine, onhLbl, onhDisplay, onhDisplayTime, showONH, showLabels, showPriceOnLabel, "ONH", onhColor, onhWidth, onhStyleS, onhTransp)
    onhLine := a4
    onhLbl  := b4

    [a5, b5] = f_draw(onlLine, onlLbl, onlDisplay, onlDisplayTime, showONL, showLabels, showPriceOnLabel, "ONL", onlColor, onlWidth, onlStyleS, onlTransp)
    onlLine := a5
    onlLbl  := b5

    [a6, b6] = f_draw(pwhLine, pwhLbl, pwh, pwhTime, showPWH, showLabels, showPriceOnLabel, "PWH", pwhColor, pwhWidth, pwhStyleS, pwhTransp)
    pwhLine := a6
    pwhLbl  := b6

    [a7, b7] = f_draw(pwlLine, pwlLbl, pwl, pwlTime, showPWL, showLabels, showPriceOnLabel, "PWL", pwlColor, pwlWidth, pwlStyleS, pwlTransp)
    pwlLine := a7
    pwlLbl  := b7

    [a8, b8] = f_draw(pmhLine, pmhLbl, pmh, pmhTime, showPMH, showLabels, showPriceOnLabel, "PMH", pmhColor, pmhWidth, pmhStyleS, pmhTransp)
    pmhLine := a8
    pmhLbl  := b8

    [a9, b9] = f_draw(pmlLine, pmlLbl, pml, pmlTime, showPML, showLabels, showPriceOnLabel, "PML", pmlColor, pmlWidth, pmlStyleS, pmlTransp)
    pmlLine := a9
    pmlLbl  := b9
````
