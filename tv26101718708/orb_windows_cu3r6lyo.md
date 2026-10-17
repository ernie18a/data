# ORB Windows

- url: https://www.tradingview.com/script/cu3R6LyO-ORB-Windows/
- type: indicator
- pine_id: PUB;ed1e2b3ee970400d964d8d67a7893017
- version: 1.0

## Description

A clean, fully configurable Opening Range Breakout indicator with up to three simultaneous time windows. This script lets you define your own windows. Set them to whatever your session or strategy calls for.

[b]Three configurable windows[/b]
Each window tracks its own high and low independently. Window 1 defaults to 5 minutes, Window 2 to 15 minutes, Window 3 to 60 minutes (hidden by default). Set any window to whatever range you want. Lines are visually differentiated: W1 is solid, W2 is dashed, W3 is dotted.

[b]Break and confirm markers[/b]
Two signals per level, per window:

[list=1]
[*]Small triangle — price ticked through the level (break)
[*]Larger triangle — candle closed through the level (confirmation)
[/list]

Filtering on close confirmation reduces noise from wicks and fakeouts.

[b]Range label[/b]
When each window locks in, a label shows the high, low, and range size in both points and percentage. Useful for quickly assessing whether the ORB is tight or wide before deciding how to trade the break.

[b]Formation window highlight[/b]
A subtle background color marks the W1 formation period so you can see exactly which candles built the range. 

[b]12 alert conditions[/b]
Four per window: break above, break below, close above, close below. Wire them up however your workflow calls for.

[b]Settings[/b]
[list]
[*]ORB Windows: set the duration (in minutes) for each of the three windows
[*]Visibility: toggle each window, markers, range label, and formation highlight independently
[*]Colors: fully customizable per window
[/list]

Designed for intraday use. Works on any liquid instrument with a defined regular session.

## Source Code

````pine
//@version=6
indicator("ORB Windows", overlay=true, max_lines_count=30, max_labels_count=100)

// ═══════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════

w1Min = input.int(5,  "ORB Window 1 (min)", minval=1, maxval=390, group="ORB Windows")
w2Min = input.int(15, "ORB Window 2 (min)", minval=1, maxval=390, group="ORB Windows")
w3Min = input.int(60, "ORB Window 3 (min)", minval=1, maxval=390, group="ORB Windows")

showW1    = input.bool(true,  "Show Window 1",                   group="Visibility")
showW2    = input.bool(true,  "Show Window 2",                   group="Visibility")
showW3    = input.bool(false, "Show Window 3",                   group="Visibility")
showBreak = input.bool(true,  "Show Break Markers",              group="Visibility")
showClose = input.bool(true,  "Show Close Confirmation Markers", group="Visibility")
showBg    = input.bool(true,  "Highlight W1 Formation Window",   group="Visibility")
showRange = input.bool(true,  "Show ORB Range Label",            group="Visibility")

colW1H = input.color(color.new(#00E676, 0), "Window 1 High", group="Colors")
colW1L = input.color(color.new(#FF1744, 0), "Window 1 Low",  group="Colors")
colW2H = input.color(color.new(#00695C, 0), "Window 2 High", group="Colors")
colW2L = input.color(color.new(#B71C1C, 0), "Window 2 Low",  group="Colors")
colW3H = input.color(color.new(#00332A, 0), "Window 3 High", group="Colors")
colW3L = input.color(color.new(#801922, 0), "Window 3 Low",  group="Colors")

// ═══════════════════════════════════════════════════════════
// SESSION & TIME
// ═══════════════════════════════════════════════════════════

minuteOfDay      = hour * 60 + minute
marketOpen       = 9 * 60 + 30
marketClose      = 16 * 60
isRegularSession = minuteOfDay >= marketOpen and minuteOfDay < marketClose
isNewDay         = ta.change(time("D")) != 0
isSubDaily       = not timeframe.isdaily and not timeframe.isweekly and not timeframe.ismonthly

inW1 = isRegularSession and minuteOfDay >= marketOpen and minuteOfDay < marketOpen + w1Min
inW2 = isRegularSession and minuteOfDay >= marketOpen and minuteOfDay < marketOpen + w2Min
inW3 = isRegularSession and minuteOfDay >= marketOpen and minuteOfDay < marketOpen + w3Min

// ═══════════════════════════════════════════════════════════
// ORB HIGH / LOW — WINDOW 1
// ═══════════════════════════════════════════════════════════

var float orbW1H   = na
var float orbW1L   = na
var float runW1H   = na
var float runW1L   = na
var bool  lockedW1 = false

if isNewDay
    runW1H   := na
    runW1L   := na
    orbW1H   := na
    orbW1L   := na
    lockedW1 := false

if inW1
    runW1H := na(runW1H) ? high : math.max(runW1H, high)
    runW1L := na(runW1L) ? low  : math.min(runW1L, low)

if not inW1 and not lockedW1 and not na(runW1H)
    orbW1H   := runW1H
    orbW1L   := runW1L
    lockedW1 := true

// ═══════════════════════════════════════════════════════════
// ORB HIGH / LOW — WINDOW 2
// ═══════════════════════════════════════════════════════════

var float orbW2H   = na
var float orbW2L   = na
var float runW2H   = na
var float runW2L   = na
var bool  lockedW2 = false

if isNewDay
    runW2H   := na
    runW2L   := na
    orbW2H   := na
    orbW2L   := na
    lockedW2 := false

if inW2
    runW2H := na(runW2H) ? high : math.max(runW2H, high)
    runW2L := na(runW2L) ? low  : math.min(runW2L, low)

if not inW2 and not lockedW2 and not na(runW2H)
    orbW2H   := runW2H
    orbW2L   := runW2L
    lockedW2 := true

// ═══════════════════════════════════════════════════════════
// ORB HIGH / LOW — WINDOW 3
// ═══════════════════════════════════════════════════════════

var float orbW3H   = na
var float orbW3L   = na
var float runW3H   = na
var float runW3L   = na
var bool  lockedW3 = false

if isNewDay
    runW3H   := na
    runW3L   := na
    orbW3H   := na
    orbW3L   := na
    lockedW3 := false

if inW3
    runW3H := na(runW3H) ? high : math.max(runW3H, high)
    runW3L := na(runW3L) ? low  : math.min(runW3L, low)

if not inW3 and not lockedW3 and not na(runW3H)
    orbW3H   := runW3H
    orbW3L   := runW3L
    lockedW3 := true

// ═══════════════════════════════════════════════════════════
// DRAW ORB LINES
// W1 — solid    W2 — dashed    W3 — dotted
// ═══════════════════════════════════════════════════════════

var line lW1H = na
var line lW1L = na
var line lW2H = na
var line lW2L = na
var line lW3H = na
var line lW3L = na

if isNewDay
    line.delete(lW1H)
    line.delete(lW1L)
    line.delete(lW2H)
    line.delete(lW2L)
    line.delete(lW3H)
    line.delete(lW3L)

if lockedW1 and not lockedW1[1] and showW1
    lW1H := line.new(bar_index, orbW1H, bar_index + 1, orbW1H,
         extend=extend.right, color=colW1H, style=line.style_solid, width=2)
    lW1L := line.new(bar_index, orbW1L, bar_index + 1, orbW1L,
         extend=extend.right, color=colW1L, style=line.style_solid, width=2)

if lockedW2 and not lockedW2[1] and showW2
    lW2H := line.new(bar_index, orbW2H, bar_index + 1, orbW2H,
         extend=extend.right, color=colW2H, style=line.style_dashed, width=1)
    lW2L := line.new(bar_index, orbW2L, bar_index + 1, orbW2L,
         extend=extend.right, color=colW2L, style=line.style_dashed, width=1)

if lockedW3 and not lockedW3[1] and showW3
    lW3H := line.new(bar_index, orbW3H, bar_index + 1, orbW3H,
         extend=extend.right, color=colW3H, style=line.style_dotted, width=1)
    lW3L := line.new(bar_index, orbW3L, bar_index + 1, orbW3L,
         extend=extend.right, color=colW3L, style=line.style_dotted, width=1)

// ═══════════════════════════════════════════════════════════
// LABELS  (stored as vars for clean daily deletion)
// ═══════════════════════════════════════════════════════════

var label lblW1H   = na
var label lblW1L   = na
var label lblW1Rng = na
var label lblW2H   = na
var label lblW2L   = na
var label lblW2Rng = na
var label lblW3H   = na
var label lblW3L   = na
var label lblW3Rng = na

if isNewDay
    label.delete(lblW1H)
    label.delete(lblW1L)
    label.delete(lblW1Rng)
    label.delete(lblW2H)
    label.delete(lblW2L)
    label.delete(lblW2Rng)
    label.delete(lblW3H)
    label.delete(lblW3L)
    label.delete(lblW3Rng)

if lockedW1 and not lockedW1[1] and showW1
    rng  = orbW1H - orbW1L
    rngP = (rng / orbW1L) * 100
    lblW1H := label.new(bar_index, orbW1H,
         text=" W1 H: " + str.tostring(orbW1H, "#.##") + "  (" + str.tostring(w1Min) + "m)",
         style=label.style_label_right, color=colW1H,
         textcolor=color.white, size=size.small)
    lblW1L := label.new(bar_index, orbW1L,
         text=" W1 L: " + str.tostring(orbW1L, "#.##") + "  (" + str.tostring(w1Min) + "m)",
         style=label.style_label_right, color=colW1L,
         textcolor=color.white, size=size.small)
    if showRange
        lblW1Rng := label.new(bar_index, math.avg(orbW1H, orbW1L),
             text=" Rng: " + str.tostring(rng, "#.##") + "  (" + str.tostring(rngP, "#.0") + "%)",
             style=label.style_label_right, color=color.new(color.gray, 30),
             textcolor=color.white, size=size.small)

if lockedW2 and not lockedW2[1] and showW2
    rng  = orbW2H - orbW2L
    rngP = (rng / orbW2L) * 100
    lblW2H := label.new(bar_index, orbW2H,
         text=" W2 H: " + str.tostring(orbW2H, "#.##") + "  (" + str.tostring(w2Min) + "m)",
         style=label.style_label_right, color=colW2H,
         textcolor=color.white, size=size.small)
    lblW2L := label.new(bar_index, orbW2L,
         text=" W2 L: " + str.tostring(orbW2L, "#.##") + "  (" + str.tostring(w2Min) + "m)",
         style=label.style_label_right, color=colW2L,
         textcolor=color.white, size=size.small)
    if showRange
        lblW2Rng := label.new(bar_index, math.avg(orbW2H, orbW2L),
             text=" Rng: " + str.tostring(rng, "#.##") + "  (" + str.tostring(rngP, "#.0") + "%)",
             style=label.style_label_right, color=color.new(color.gray, 30),
             textcolor=color.white, size=size.small)

if lockedW3 and not lockedW3[1] and showW3
    rng  = orbW3H - orbW3L
    rngP = (rng / orbW3L) * 100
    lblW3H := label.new(bar_index, orbW3H,
         text=" W3 H: " + str.tostring(orbW3H, "#.##") + "  (" + str.tostring(w3Min) + "m)",
         style=label.style_label_right, color=colW3H,
         textcolor=color.white, size=size.small)
    lblW3L := label.new(bar_index, orbW3L,
         text=" W3 L: " + str.tostring(orbW3L, "#.##") + "  (" + str.tostring(w3Min) + "m)",
         style=label.style_label_right, color=colW3L,
         textcolor=color.white, size=size.small)
    if showRange
        lblW3Rng := label.new(bar_index, math.avg(orbW3H, orbW3L),
             text=" Rng: " + str.tostring(rng, "#.##") + "  (" + str.tostring(rngP, "#.0") + "%)",
             style=label.style_label_right, color=color.new(color.gray, 30),
             textcolor=color.white, size=size.small)

// ═══════════════════════════════════════════════════════════
// FORMATION WINDOW BACKGROUND
// Suppressed on 1D, 1W, 1M — visible on all intraday including 4H
// ═══════════════════════════════════════════════════════════

bgcolor(showBg and isSubDaily and inW1 ? color.new(color.yellow, 85) : na,
     title="W1 Formation Window")

// ═══════════════════════════════════════════════════════════
// BREAK & CONFIRM MARKERS — WINDOW 1
// tiny  = break (price ticked through)
// small = confirm (candle closed through)
// ═══════════════════════════════════════════════════════════

var bool firedBreakAboveW1 = false
var bool firedBreakBelowW1 = false
var bool firedConfAboveW1  = false
var bool firedConfBelowW1  = false

if isNewDay
    firedBreakAboveW1 := false
    firedBreakBelowW1 := false
    firedConfAboveW1  := false
    firedConfBelowW1  := false

activeW1 = isRegularSession and lockedW1

doBreakAboveW1 = activeW1 and high  > orbW1H and not firedBreakAboveW1
doBreakBelowW1 = activeW1 and low   < orbW1L and not firedBreakBelowW1
doConfAboveW1  = activeW1 and close > orbW1H and not firedConfAboveW1
doConfBelowW1  = activeW1 and close < orbW1L and not firedConfBelowW1

if doBreakAboveW1
    firedBreakAboveW1 := true
if doBreakBelowW1
    firedBreakBelowW1 := true
if doConfAboveW1
    firedConfAboveW1 := true
if doConfBelowW1
    firedConfBelowW1 := true

plotshape(showBreak and showW1 and doBreakAboveW1, title="W1 Break Above",
     style=shape.triangleup,   location=location.abovebar, color=colW1H, size=size.tiny)
plotshape(showBreak and showW1 and doBreakBelowW1, title="W1 Break Below",
     style=shape.triangledown, location=location.belowbar, color=colW1L, size=size.tiny)
plotshape(showClose and showW1 and doConfAboveW1,  title="W1 Confirm Above",
     style=shape.triangleup,   location=location.abovebar, color=colW1H, size=size.small)
plotshape(showClose and showW1 and doConfBelowW1,  title="W1 Confirm Below",
     style=shape.triangledown, location=location.belowbar, color=colW1L, size=size.small)

// ═══════════════════════════════════════════════════════════
// BREAK & CONFIRM MARKERS — WINDOW 2
// ═══════════════════════════════════════════════════════════

var bool firedBreakAboveW2 = false
var bool firedBreakBelowW2 = false
var bool firedConfAboveW2  = false
var bool firedConfBelowW2  = false

if isNewDay
    firedBreakAboveW2 := false
    firedBreakBelowW2 := false
    firedConfAboveW2  := false
    firedConfBelowW2  := false

activeW2 = isRegularSession and lockedW2

doBreakAboveW2 = activeW2 and high  > orbW2H and not firedBreakAboveW2
doBreakBelowW2 = activeW2 and low   < orbW2L and not firedBreakBelowW2
doConfAboveW2  = activeW2 and close > orbW2H and not firedConfAboveW2
doConfBelowW2  = activeW2 and close < orbW2L and not firedConfBelowW2

if doBreakAboveW2
    firedBreakAboveW2 := true
if doBreakBelowW2
    firedBreakBelowW2 := true
if doConfAboveW2
    firedConfAboveW2 := true
if doConfBelowW2
    firedConfBelowW2 := true

plotshape(showBreak and showW2 and doBreakAboveW2, title="W2 Break Above",
     style=shape.triangleup,   location=location.abovebar, color=colW2H, size=size.tiny)
plotshape(showBreak and showW2 and doBreakBelowW2, title="W2 Break Below",
     style=shape.triangledown, location=location.belowbar, color=colW2L, size=size.tiny)
plotshape(showClose and showW2 and doConfAboveW2,  title="W2 Confirm Above",
     style=shape.triangleup,   location=location.abovebar, color=colW2H, size=size.small)
plotshape(showClose and showW2 and doConfBelowW2,  title="W2 Confirm Below",
     style=shape.triangledown, location=location.belowbar, color=colW2L, size=size.small)

// ═══════════════════════════════════════════════════════════
// BREAK & CONFIRM MARKERS — WINDOW 3
// ═══════════════════════════════════════════════════════════

var bool firedBreakAboveW3 = false
var bool firedBreakBelowW3 = false
var bool firedConfAboveW3  = false
var bool firedConfBelowW3  = false

if isNewDay
    firedBreakAboveW3 := false
    firedBreakBelowW3 := false
    firedConfAboveW3  := false
    firedConfBelowW3  := false

activeW3 = isRegularSession and lockedW3

doBreakAboveW3 = activeW3 and high  > orbW3H and not firedBreakAboveW3
doBreakBelowW3 = activeW3 and low   < orbW3L and not firedBreakBelowW3
doConfAboveW3  = activeW3 and close > orbW3H and not firedConfAboveW3
doConfBelowW3  = activeW3 and close < orbW3L and not firedConfBelowW3

if doBreakAboveW3
    firedBreakAboveW3 := true
if doBreakBelowW3
    firedBreakBelowW3 := true
if doConfAboveW3
    firedConfAboveW3 := true
if doConfBelowW3
    firedConfBelowW3 := true

plotshape(showBreak and showW3 and doBreakAboveW3, title="W3 Break Above",
     style=shape.triangleup,   location=location.abovebar, color=colW3H, size=size.tiny)
plotshape(showBreak and showW3 and doBreakBelowW3, title="W3 Break Below",
     style=shape.triangledown, location=location.belowbar, color=colW3L, size=size.tiny)
plotshape(showClose and showW3 and doConfAboveW3,  title="W3 Confirm Above",
     style=shape.triangleup,   location=location.abovebar, color=colW3H, size=size.small)
plotshape(showClose and showW3 and doConfBelowW3,  title="W3 Confirm Below",
     style=shape.triangledown, location=location.belowbar, color=colW3L, size=size.small)

// ═══════════════════════════════════════════════════════════
// ALERTS  (12 conditions — 4 per window)
// ═══════════════════════════════════════════════════════════

alertcondition(doBreakAboveW1, "W1 Break Above ORB",   "Price broke above W1 ORB high")
alertcondition(doBreakBelowW1, "W1 Break Below ORB",   "Price broke below W1 ORB low")
alertcondition(doConfAboveW1,  "W1 Confirm Above ORB", "Candle CLOSED above W1 ORB high")
alertcondition(doConfBelowW1,  "W1 Confirm Below ORB", "Candle CLOSED below W1 ORB low")

alertcondition(doBreakAboveW2, "W2 Break Above ORB",   "Price broke above W2 ORB high")
alertcondition(doBreakBelowW2, "W2 Break Below ORB",   "Price broke below W2 ORB low")
alertcondition(doConfAboveW2,  "W2 Confirm Above ORB", "Candle CLOSED above W2 ORB high")
alertcondition(doConfBelowW2,  "W2 Confirm Below ORB", "Candle CLOSED below W2 ORB low")

alertcondition(doBreakAboveW3, "W3 Break Above ORB",   "Price broke above W3 ORB high")
alertcondition(doBreakBelowW3, "W3 Break Below ORB",   "Price broke below W3 ORB low")
alertcondition(doConfAboveW3,  "W3 Confirm Above ORB", "Candle CLOSED above W3 ORB high")
alertcondition(doConfBelowW3,  "W3 Confirm Below ORB", "Candle CLOSED below W3 ORB low")
````
