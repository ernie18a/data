# Numb Session & 90m Cycle Boxes [Time]

- url: https://www.tradingview.com/script/ZUYVEbSn-Numb-Session-90m-Cycle-Boxes-Time/
- type: indicator
- pine_id: PUB;41c9c9960a8a4228818eccf85c07ed12
- version: 1.0

## Description

session times with buy/sell liq

also it gives 90min cycle for each session

## Source Code

````pine
//@version=6
// =====================================================================
//  Numb Session & 90m Cycle Boxes  [Time]   v1.1
//  --------------------------------------------------------------------
//  Nested time skeleton (TheTimeCourse / Frank369 style):
//   - SESSION BOXES: Asia / London / New York, each spanning the
//     session's time width and running high-low range.
//   - 90-MIN CYCLE BOXES nested inside (alternating colour).
//   - BUYSIDE / SELLSIDE liquidity: each session's high (buyside) and
//     low (sellside) drawn as a line that extends right UNTIL SWEPT,
//     then freezes + fades.
//   - AMD PHASE LABELS: each session's 90-min cycles tagged by position
//     A (accumulation) -> M (manipulation) -> D (distribution).
//     NY splits into AM and PM at the configurable split (default 11:30),
//     each running its own A-M-D, so the morning reads "AM A/M/D".
//
//  Times use the chosen timezone (DST handled). Analysis tooling, not advice.
// =====================================================================
indicator("Numb Session & 90m Cycle Boxes [Time]", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 200)

// ---------------- Timezone ----------------
gT = "Timezone"
tz = input.string("America/New_York", "Timezone", options = ["America/New_York","America/Chicago","Europe/London","UTC","Asia/Tokyo","Asia/Shanghai","Asia/Karachi","Asia/Dubai","Australia/Sydney"], group = gT, tooltip = "All session/cycle times are in this timezone. DST handled automatically.")

// ---------------- Sessions ----------------
gSe = "Sessions"
showSessions = input.bool(true, "Show session boxes", group = gSe)
sessFill     = input.bool(true, "Fill session boxes", group = gSe)
sessTransp   = input.int(92, "Session fill transparency", minval = 0, maxval = 100, group = gSe)
showAsia = input.bool(true,  "Asia - show", group = gSe)
asiaSess = input.session("1800-0230", "Asia - session", group = gSe)
asiaCol  = input.color(#7e57c2, "Asia - colour", group = gSe)
showLon  = input.bool(true,  "London - show", group = gSe)
lonSess  = input.session("0230-0700", "London - session", group = gSe)
lonCol   = input.color(#ef5350, "London - colour", group = gSe)
showUS   = input.bool(true,  "New York - show", group = gSe)
usSess   = input.session("0700-1600", "New York - session", group = gSe)
usCol    = input.color(#26a69a, "New York - colour", group = gSe)

// ---------------- 90-min cycles ----------------
gCy = "90-min cycles"
showCycles = input.bool(true, "Show cycle boxes", group = gCy)
cycFillOn  = input.bool(true, "Fill cycle boxes", group = gCy)
cycTransp  = input.int(88, "Cycle fill transparency", minval = 0, maxval = 100, group = gCy)
cycleMin   = input.int(90, "Cycle length (minutes)", minval = 5, group = gCy)
anchorH    = input.int(7, "Cycle anchor hour", minval = 0, maxval = 23, group = gCy, tooltip = "Aligns the cycle grid. 07:00 lines up the London (02:30) and NY (07:00) starts.")
anchorM    = input.int(0, "Cycle anchor minute", minval = 0, maxval = 59, group = gCy)
cycColA    = input.color(#42a5f5, "Cycle colour A", group = gCy)
cycColB    = input.color(#ffa726, "Cycle colour B", group = gCy)
cycBorder  = input.color(color.new(color.gray, 30), "Cycle border", group = gCy)

// ---------------- Liquidity ----------------
gL = "Liquidity (Buyside / Sellside)"
showBSL   = input.bool(true, "Show buyside/sellside liquidity", group = gL)
bslLabels = input.bool(true, "Label liquidity lines", group = gL)
bslCol    = input.color(#26a69a, "Buyside colour", group = gL)
sslCol    = input.color(#ef5350, "Sellside colour", group = gL)
liqWidth  = input.int(1, "Line width", minval = 1, maxval = 4, group = gL)
maxLiq    = input.int(16, "Max liquidity levels kept", minval = 2, maxval = 60, group = gL, tooltip = "Older buyside/sellside lines are dropped past this count to avoid clutter.")

// ---------------- AMD phases ----------------
gA = "AMD phases"
showAMD = input.bool(true, "Show AMD phase labels", group = gA)
amPmH   = input.int(11, "NY AM/PM split hour", minval = 0, maxval = 23, group = gA, tooltip = "NY splits into AM and PM here, each running its own A-M-D. 11:30 matches the morning session ending.")
amPmM   = input.int(30, "NY AM/PM split minute", minval = 0, maxval = 59, group = gA)
amdCol  = input.color(#434651, "AMD label background", group = gA)
amdSize = input.string("Small", "AMD label size", options = ["Tiny","Small","Normal"], group = gA)

// ---------------- General ----------------
gG = "General"
lookbackDays = input.int(10, "Draw last N days only", minval = 1, group = gG, tooltip = "Limits how far back boxes/levels are drawn to keep it light. Increase for more history (watch the caps).")

// ---------------- Time ----------------
m = hour(time, tz) * 60 + minute(time, tz)
draw = (timenow - time) <= lookbackDays * 86400000

aT = not na(time(timeframe.period, asiaSess, tz))
lT = not na(time(timeframe.period, lonSess, tz))
uT = not na(time(timeframe.period, usSess, tz))

f_sessFill(c) => sessFill ? color.new(c, sessTransp) : color.new(c, 100)

// ---------------- Liquidity storage + adder ----------------
var array<line>  bslArr = array.new<line>()
var array<float> bslLvl = array.new<float>()
var array<bool>  bslAct = array.new<bool>()
var array<label> bslLbl = array.new<label>()
var array<line>  sslArr = array.new<line>()
var array<float> sslLvl = array.new<float>()
var array<bool>  sslAct = array.new<bool>()
var array<label> sslLbl = array.new<label>()

f_addLiq(hi, lo) =>
    if showBSL and draw
        bl = line.new(bar_index, hi, bar_index, hi, color = color.new(bslCol, 0), width = liqWidth, style = line.style_solid)
        array.push(bslArr, bl)
        array.push(bslLvl, hi)
        array.push(bslAct, true)
        array.push(bslLbl, bslLabels ? label.new(bar_index, hi, "Buyside", style = label.style_label_down, color = color.new(bslCol, 20), textcolor = color.white, size = size.tiny) : na)
        sl = line.new(bar_index, lo, bar_index, lo, color = color.new(sslCol, 0), width = liqWidth, style = line.style_solid)
        array.push(sslArr, sl)
        array.push(sslLvl, lo)
        array.push(sslAct, true)
        array.push(sslLbl, bslLabels ? label.new(bar_index, lo, "Sellside", style = label.style_label_up, color = color.new(sslCol, 20), textcolor = color.white, size = size.tiny) : na)

// ---------------- Session boxes ----------------
var box   asBox = na
var float asHi = na
var float asLo = na
if aT and not aT[1]
    asHi := high
    asLo := low
    asBox := (showSessions and showAsia and draw) ? box.new(bar_index, high, bar_index, low, border_color = color.new(asiaCol, 30), border_width = 1, bgcolor = f_sessFill(asiaCol), text = "Asia", text_color = color.new(asiaCol, 0), text_halign = text.align_left, text_valign = text.align_top, text_size = size.small) : na
else if aT
    asHi := math.max(asHi, high)
    asLo := math.min(asLo, low)
    if not na(asBox)
        box.set_top(asBox, asHi)
        box.set_bottom(asBox, asLo)
        box.set_right(asBox, bar_index)

var box   lnBox = na
var float lnHi = na
var float lnLo = na
if lT and not lT[1]
    lnHi := high
    lnLo := low
    lnBox := (showSessions and showLon and draw) ? box.new(bar_index, high, bar_index, low, border_color = color.new(lonCol, 30), border_width = 1, bgcolor = f_sessFill(lonCol), text = "London", text_color = color.new(lonCol, 0), text_halign = text.align_left, text_valign = text.align_top, text_size = size.small) : na
else if lT
    lnHi := math.max(lnHi, high)
    lnLo := math.min(lnLo, low)
    if not na(lnBox)
        box.set_top(lnBox, lnHi)
        box.set_bottom(lnBox, lnLo)
        box.set_right(lnBox, bar_index)

var box   usBox = na
var float usHi = na
var float usLo = na
if uT and not uT[1]
    usHi := high
    usLo := low
    usBox := (showSessions and showUS and draw) ? box.new(bar_index, high, bar_index, low, border_color = color.new(usCol, 30), border_width = 1, bgcolor = f_sessFill(usCol), text = "New York", text_color = color.new(usCol, 0), text_halign = text.align_left, text_valign = text.align_top, text_size = size.small) : na
else if uT
    usHi := math.max(usHi, high)
    usLo := math.min(usLo, low)
    if not na(usBox)
        box.set_top(usBox, usHi)
        box.set_bottom(usBox, usLo)
        box.set_right(usBox, bar_index)

// ---------------- 90-min cycle grid + phase ----------------
inSess = aT or lT or uT
anchorMin = anchorH * 60 + anchorM
cycId = int(((m - anchorMin + 1440) % 1440) / cycleMin)
newCyc = na(cycId[1]) or cycId != cycId[1]
f_cycFill(id) => cycFillOn ? ((id % 2 == 0) ? color.new(cycColA, cycTransp) : color.new(cycColB, cycTransp)) : color.new(color.gray, 100)

// phase block: 1 Asia, 2 London, 3 NY-AM, 4 NY-PM, 0 gap
amPmMin = amPmH * 60 + amPmM
pbId = aT ? 1 : lT ? 2 : uT ? (m < amPmMin ? 3 : 4) : 0
pbStart = (pbId != pbId[1]) and pbId != 0

var int sCycN = 0
if pbStart
    sCycN := 0
else if newCyc and pbId != 0
    sCycN := sCycN + 1

// ---------------- Cycle boxes ----------------
var box   cBox = na
var float cHi = na
var float cLo = na
startC = inSess and (newCyc or not inSess[1])
if startC
    cHi := high
    cLo := low
    cBox := (showCycles and draw) ? box.new(bar_index, high, bar_index, low, border_color = cycBorder, border_width = 1, border_style = line.style_dashed, bgcolor = f_cycFill(cycId)) : na
else if inSess
    cHi := math.max(cHi, high)
    cLo := math.min(cLo, low)
    if not na(cBox)
        box.set_top(cBox, cHi)
        box.set_bottom(cBox, cLo)
        box.set_right(cBox, bar_index)

// ---------------- AMD phase labels ----------------
amdLetter = sCycN == 0 ? "A" : sCycN == 1 ? "M" : sCycN == 2 ? "D" : ""
labelThis = sCycN <= 2
amdTag = pbId == 1 ? "AS" : pbId == 2 ? "LN" : pbId == 3 ? "AM" : pbId == 4 ? "PM" : ""
aSz = amdSize == "Tiny" ? size.tiny : amdSize == "Normal" ? size.normal : size.small
var label amdLbl = na
if showAMD and draw and pbId != 0
    if startC
        if labelThis
            amdLbl := label.new(bar_index, cHi, amdTag + " " + amdLetter, style = label.style_label_down, color = color.new(amdCol, 15), textcolor = color.white, size = aSz, yloc = yloc.price)
        else
            amdLbl := na
    else
        if not na(amdLbl)
            label.set_y(amdLbl, cHi)

// ---------------- Session-end -> add liquidity ----------------
if (not aT) and aT[1] and showAsia
    f_addLiq(asHi, asLo)
if (not lT) and lT[1] and showLon
    f_addLiq(lnHi, lnLo)
if (not uT) and uT[1] and showUS
    f_addLiq(usHi, usLo)

// ---------------- Extend liquidity until swept ----------------
if array.size(bslArr) > 0
    for i = 0 to array.size(bslArr) - 1
        if array.get(bslAct, i)
            ln = array.get(bslArr, i)
            lv = array.get(bslLvl, i)
            line.set_x2(ln, bar_index)
            if high > lv
                array.set(bslAct, i, false)
                line.set_style(ln, line.style_dashed)
                line.set_color(ln, color.new(bslCol, 72))
if array.size(sslArr) > 0
    for i = 0 to array.size(sslArr) - 1
        if array.get(sslAct, i)
            ln = array.get(sslArr, i)
            lv = array.get(sslLvl, i)
            line.set_x2(ln, bar_index)
            if low < lv
                array.set(sslAct, i, false)
                line.set_style(ln, line.style_dashed)
                line.set_color(ln, color.new(sslCol, 72))

// ---------------- Cap stored liquidity ----------------
if array.size(bslArr) > maxLiq
    l0 = array.shift(bslArr)
    line.delete(l0)
    array.shift(bslLvl)
    array.shift(bslAct)
    lb0 = array.shift(bslLbl)
    if not na(lb0)
        label.delete(lb0)
if array.size(sslArr) > maxLiq
    s0 = array.shift(sslArr)
    line.delete(s0)
    array.shift(sslLvl)
    array.shift(sslAct)
    sb0 = array.shift(sslLbl)
    if not na(sb0)
        label.delete(sb0)
````
