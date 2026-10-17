# Numb Session & 90m Cycle Boxes [Time]

- url: https://www.tradingview.com/script/J6sGctUI-Numb-Session-90m-Cycle-Boxes-Time/
- type: indicator
- pine_id: PUB;1da0752eb1bb4290a7e0f55a2262a731
- version: 1.0

## Description

This indictor Draws the nested time skeleton 
   - SESSION BOXES: Asia / London / New York, each box spanning the
 session's time width and its running high-low range
 - 90-MIN CYCLE BOXES: nested inside the sessions

## Source Code

````pine
//@version=6
// =====================================================================
//  Numb Session & 90m Cycle Boxes  [Time]   v1.0
//  --------------------------------------------------------------------
//  Draws the nested time skeleton:
//   - SESSION BOXES: Asia / London / New York, each box spanning the
//     session's time width and its running high-low range
//     (top edge = buyside liquidity, bottom edge = sellside). Labelled.
//   - 90-MIN CYCLE BOXES: nested inside the sessions, one box per
//     90-min cycle (aligned to a configurable anchor; 07:00 lines up the
//     London 02:30 and NY 07:00 starts), each spanning that cycle's
//     high-low range, alternating colour.
//
//  Pure visual structure for the session / Quarterly-Theory model — no
//  signals. Colours + transparency fully adjustable. Times use the
//  chosen timezone (DST handled). Analysis tooling, not advice.
// =====================================================================
indicator("Numb Session & 90m Cycle Boxes [Time]", overlay = true, max_boxes_count = 500, max_labels_count = 50, max_lines_count = 50)

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

// ---------------- General ----------------
gG = "General"
lookbackDays = input.int(10, "Draw last N days only", minval = 1, group = gG, tooltip = "Limits how far back boxes are drawn to keep it light. Increase for more history (watch the 500-box cap).")

// ---------------- Time ----------------
m = hour(time, tz) * 60 + minute(time, tz)
draw = (timenow - time) <= lookbackDays * 86400000

aT = not na(time(timeframe.period, asiaSess, tz))
lT = not na(time(timeframe.period, lonSess, tz))
uT = not na(time(timeframe.period, usSess, tz))

f_sessFill(c) => sessFill ? color.new(c, sessTransp) : color.new(c, 100)

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

// ---------------- 90-min cycle boxes ----------------
inSess = aT or lT or uT
anchorMin = anchorH * 60 + anchorM
cycId = int(((m - anchorMin + 1440) % 1440) / cycleMin)
newCyc = na(cycId[1]) or cycId != cycId[1]
f_cycFill(id) => cycFillOn ? ((id % 2 == 0) ? color.new(cycColA, cycTransp) : color.new(cycColB, cycTransp)) : color.new(color.gray, 100)

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
````
