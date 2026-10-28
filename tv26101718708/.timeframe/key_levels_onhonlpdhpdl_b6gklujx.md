# Key Levels - ONH/ONL/PDH/PDL

- url: https://www.tradingview.com/script/B6GKlUjx-Key-Levels-ONH-ONL-PDH-PDL/
- type: indicator
- pine_id: PUB;758a8e51a1fa466f86a21f5b7248213b
- version: 1.0

## Description

An indicator that displays the following levels:
[list]
[*]Overnight high
[*]overnight low 
[*]previous day high 
[*]previous day low
[/list]

## Source Code

````pine
//@version=6
indicator("Key Levels - ONH/ONL/PDH/PDL", shorttitle="Key Levels", overlay=true)

// ═══════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════

grpSess  = "Session"
onSess   = input.session("1800-0930", "Overnight Session", group=grpSess, tooltip="CME overnight: 18:00 → 09:30 ET (RTH open). Adjust for your instrument.")
tz       = input.string("America/New_York", "Timezone", options=["America/New_York","America/Chicago","Europe/London","Europe/Budapest","Asia/Tokyo","exchange"], group=grpSess)

grpLvl   = "Levels"
showPDH  = input.bool(true, "Prev Day High", group=grpLvl, inline="pdh")
colPDH   = input.color(#f23645, "", group=grpLvl, inline="pdh")
showPDL  = input.bool(true, "Prev Day Low",  group=grpLvl, inline="pdl")
colPDL   = input.color(#089981, "", group=grpLvl, inline="pdl")
showONH  = input.bool(true, "Overnight High", group=grpLvl, inline="onh")
colONH   = input.color(#ff9800, "", group=grpLvl, inline="onh")
showONL  = input.bool(true, "Overnight Low",  group=grpLvl, inline="onl")
colONL   = input.color(#2962ff, "", group=grpLvl, inline="onl")

grpStyle = "Style"
lnStyle  = input.string("Solid", "Line Style", options=["Solid","Dashed","Dotted"], group=grpStyle)
lnWidth  = input.int(1, "Line Width", minval=1, maxval=4, group=grpStyle)
showLbl  = input.bool(true, "Show Labels", group=grpStyle)
lblSize  = input.string("small", "Label Size", options=["tiny","small","normal","large"], group=grpStyle)

// ═══════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════

f_style(s)   => s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid
f_lblSize(s) => s == "tiny" ? size.tiny : s == "small" ? size.small : s == "normal" ? size.normal : size.large

inON   = not na(time(timeframe.period, onSess, tz))
newDay = tz == "exchange" ? ta.change(time("D")) != 0 : ta.change(dayofmonth(time, tz)) != 0

// ═══════════════════════════════════════════════════════════════
// STATE — running extremes for the current day / current overnight
// ═══════════════════════════════════════════════════════════════

var float dayH = na, var int dayHT = na
var float dayL = na, var int dayLT = na
var float onH  = na, var int onHT  = na
var float onL  = na, var int onLT  = na
var bool  onActive = false

// Persistent drawing objects — ONE of each, reused
var line  lnPDH = na, var label lbPDH = na
var line  lnPDL = na, var label lbPDL = na
var line  lnONH = na, var label lbONH = na
var line  lnONL = na, var label lbONL = na

// ═══════════════════════════════════════════════════════════════
// DAY ROLLOVER → draw PDH/PDL from the bar that made the extreme,
// extending infinitely right. Delete previous drawings first.
// ═══════════════════════════════════════════════════════════════

if newDay
    if not na(dayH)
        if showPDH
            line.delete(lnPDH)
            label.delete(lbPDH)
            lnPDH := line.new(dayHT, dayH, dayHT + 1, dayH, xloc=xloc.bar_time, extend=extend.right, color=colPDH, style=f_style(lnStyle), width=lnWidth)
            if showLbl
                lbPDH := label.new(dayHT, dayH, "PDH " + str.tostring(dayH, format.mintick), xloc=xloc.bar_time, style=label.style_none, textcolor=colPDH, size=f_lblSize(lblSize))
        if showPDL
            line.delete(lnPDL)
            label.delete(lbPDL)
            lnPDL := line.new(dayLT, dayL, dayLT + 1, dayL, xloc=xloc.bar_time, extend=extend.right, color=colPDL, style=f_style(lnStyle), width=lnWidth)
            if showLbl
                lbPDL := label.new(dayLT, dayL, "PDL " + str.tostring(dayL, format.mintick), xloc=xloc.bar_time, style=label.style_none, textcolor=colPDL, size=f_lblSize(lblSize))

    dayH := high
    dayL := low
    dayHT := time
    dayLT := time
else
    if na(dayH) or high > dayH
        dayH := high
        dayHT := time
    if na(dayL) or low < dayL
        dayL := low
        dayLT := time

// ═══════════════════════════════════════════════════════════════
// OVERNIGHT SESSION → draw ONH/ONL at session close, extend right
// ═══════════════════════════════════════════════════════════════

onEntering = inON and not onActive

// New overnight session begins → clear prior ON drawings
if onEntering
    onH := high
    onL := low
    onHT := time
    onLT := time
    onActive := true
    line.delete(lnONH), label.delete(lbONH), lnONH := na, lbONH := na
    line.delete(lnONL), label.delete(lbONL), lnONL := na, lbONL := na

// While overnight is live, update extremes
if inON
    if high > onH
        onH := high
        onHT := time
    if low < onL
        onL := low
        onLT := time

// Mark session as inactive once we leave it, but keep the levels drawn
if not inON and onActive
    onActive := false

// (Re)draw ONH/ONL to reflect the current ON high/low — works live during
// the session AND persists after RTH open. Line anchors at the bar that
// made the extreme and extends infinitely right.
if not na(onH)
    if showONH
        if na(lnONH)
            lnONH := line.new(onHT, onH, onHT + 1, onH, xloc=xloc.bar_time, extend=extend.right, color=colONH, style=f_style(lnStyle), width=lnWidth)
            if showLbl
                lbONH := label.new(onHT, onH, "ONH " + str.tostring(onH, format.mintick), xloc=xloc.bar_time, style=label.style_none, textcolor=colONH, size=f_lblSize(lblSize))
        else if line.get_y1(lnONH) != onH
            line.set_xy1(lnONH, onHT, onH)
            line.set_xy2(lnONH, onHT + 1, onH)
            if not na(lbONH)
                label.set_xy(lbONH, onHT, onH)
                label.set_text(lbONH, "ONH " + str.tostring(onH, format.mintick))
if not na(onL)
    if showONL
        if na(lnONL)
            lnONL := line.new(onLT, onL, onLT + 1, onL, xloc=xloc.bar_time, extend=extend.right, color=colONL, style=f_style(lnStyle), width=lnWidth)
            if showLbl
                lbONL := label.new(onLT, onL, "ONL " + str.tostring(onL, format.mintick), xloc=xloc.bar_time, style=label.style_none, textcolor=colONL, size=f_lblSize(lblSize))
        else if line.get_y1(lnONL) != onL
            line.set_xy1(lnONL, onLT, onL)
            line.set_xy2(lnONL, onLT + 1, onL)
            if not na(lbONL)
                label.set_xy(lbONL, onLT, onL)
                label.set_text(lbONL, "ONL " + str.tostring(onL, format.mintick))

// ═══════════════════════════════════════════════════════════════
// KEEP LABELS PINNED TO THE RIGHT EDGE (last bar)
// ═══════════════════════════════════════════════════════════════

if barstate.islast
    if not na(lbPDH)
        label.set_x(lbPDH, time)
    if not na(lbPDL)
        label.set_x(lbPDL, time)
    if not na(lbONH)
        label.set_x(lbONH, time)
    if not na(lbONL)
        label.set_x(lbONL, time)

// ═══════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════

alertcondition(not na(lnPDH) and ta.crossover(close,  line.get_y1(lnPDH)), "Close above PDH", "Close above Previous Day High")
alertcondition(not na(lnPDL) and ta.crossunder(close, line.get_y1(lnPDL)), "Close below PDL", "Close below Previous Day Low")
alertcondition(not na(lnONH) and ta.crossover(close,  line.get_y1(lnONH)), "Close above ONH", "Close above Overnight High")
alertcondition(not na(lnONL) and ta.crossunder(close, line.get_y1(lnONL)), "Close below ONL", "Close below Overnight Low")
````
