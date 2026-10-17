# STA 3-Candle ORB

- url: https://www.tradingview.com/script/Q5PO2i1D-STA-3-Candle-ORB/
- type: indicator
- pine_id: PUB;27b4a934f2624ab198523d22fdfeb8ef
- version: 1.0

## Description

Watches the first three five-minute candles of the New York open. When all three close the same direction, it draws the opening range with a dotted midline. When they disagree it draws nothing, so an empty chart is the answer.

The gate decides whether to trade, not which way. Once price breaks an edge, the indicator marks the entry, the stop at the opposite edge, and three targets at half, one, and one and a half times the range.

Built for the 5-minute chart. For education and study by the members of Sisterhood Trading Academy.

## Source Code

````pine
//@version=6
// ============================================================================
// STA 3-Candle ORB
//
// Developed and designed for members of the Sisterhood Trading Academy.
//
// Marks the opening range for Amanda's STA 3-Candle ORB, and only when the gate
// passes. It REPORTS levels. It does not name trades, place orders, or grade
// anything -- same posture as STA FVG Locator.
//
// THE GATE
//   The 9:30, 9:35 and 9:40 five-minute candles must ALL close the same
//   direction (all up or all down). If they disagree, NOTHING IS DRAWN -- the
//   absence of a box is the no-trade signal.
//   The gate is GO / NO-GO ONLY. It does not pick direction. Three up candles
//   do not mean "go long". Price picks the side by breaking an edge.
//
// WHAT GETS DRAWN
//   At 9:45, if the gate passed : the opening-range box + a dotted midline.
//   On the first edge break     : Entry, Stop, P1, P2, P3 on the broken side.
//
//   Entry  the edge price crossed first
//   Stop   the OPPOSITE edge (so initial risk = the full range, 1R)
//   P1     entry +/- 0.50R    (0.5 : 1)
//   P2     entry +/- 1.00R    (1 : 1)   <- the target, per Oct 3 2026
//   P3     entry +/- 1.50R    (1.5 : 1)
//
// WHY THE LEVELS APPEAR LATE
//   Stop and targets sit on the far side of the entry, and which side that is
//   is unknowable until price breaks. Nothing is predicted here; the levels
//   resolve the moment an edge gives way.
//
// NOTES
//   - P3 appears on Amanda's card but not in the module transcript. Kept behind
//     an input, on by default because it was asked for. Treat as unconfirmed.
//   - The 1/4x trail line is deliberately NOT drawn. The trail rungs are still
//     unresolved between the card and the transcript.
//   - 5-MINUTE CHART ONLY. On any other timeframe the script draws a notice and
//     does nothing else.
//   - Palette is shared with STA FVG Locator: Deep Ocean #18454E, Morning Haze
//     #E08D2D, Evening Light #E56F33, Ember #F3492B, Paper #F6EDE7. Midline uses
//     Morning Haze in both scripts, so a midline reads the same on either.
//
// For education and study. This script reports levels on a chart. It does not
// place orders, it is not financial advice, and nothing here is a claim about
// future results. Futures trading carries risk of loss.
// ============================================================================

indicator("STA 3-Candle ORB", "STA 3C ORB", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ---------------------------------------------------------------- inputs ----
gGate = "Gate"
tz       = input.string("America/New_York", "Timezone",             group = gGate)
orSess   = input.session("0930-0945",       "Opening range window", group = gGate)
extSess  = input.session("0930-1600",       "Extend levels until",  group = gGate)
reqAgree = input.bool(true,  "Require all 3 candles same direction", group = gGate,
     tooltip = "Off = draw the range every day regardless of the gate. For study only.")

gLvl = "Levels"
showP3   = input.bool(true,  "Show P3 (1.5x)", group = gLvl,
     tooltip = "On Amanda's card, absent from the module transcript. Unconfirmed.")
showLbl  = input.bool(true,  "Show level labels", group = gLvl)

// Palette shared with STA FVG Locator -- same names, same hexes.
gPal = "Visual palette"
deepOcean    = input.color(#18454E, "Deep Ocean - box and targets", group = gPal)
morningHaze  = input.color(#E08D2D, "Morning Haze - midline",       group = gPal)
eveningLight = input.color(#E56F33, "Evening Light - entry",        group = gPal)
ember        = input.color(#F3492B, "Ember - stop",                 group = gPal)
paper        = input.color(#F6EDE7, "Paper - label text",           group = gPal)

gSty = "Style"
showTint = input.bool(true,  "Tint the three opening candles", group = gSty)
showNT   = input.bool(false, "Mark no-trade mornings",         group = gSty,
     tooltip = "Default off: the absence of a box is the signal.")
tBoxF = input.int(92, "Box fill transparency",   minval = 0, maxval = 100, group = gSty)
tBoxB = input.int(35, "Box border transparency", minval = 0, maxval = 100, group = gSty)
tTint = input.int(94, "Candle tint transparency",minval = 0, maxval = 100, group = gSty)
szLbl = input.string(size.small, "Label size",
     options = [size.tiny, size.small, size.normal], group = gSty)

cBoxF = color.new(deepOcean, tBoxF)
cBoxB = color.new(deepOcean, tBoxB)
cTint = color.new(deepOcean, tTint)
cMid  = morningHaze
cEnt  = eveningLight
cStp  = ember
cTgt  = deepOcean

// ------------------------------------------------------- timeframe guard ----
isFive = timeframe.isminutes and timeframe.multiplier == 5

var label warn = na
if barstate.islast
    label.delete(warn)
    warn := isFive ? na : label.new(bar_index, close,
         "STA 3-Candle ORB\nneeds the 5-minute chart",
         style = label.style_label_left, color = color.new(eveningLight, 10),
         textcolor = paper, size = size.normal)

// --------------------------------------------------------------- windows ----
inOR  = isFive and not na(time(timeframe.period, orSess,  tz))
inEXT = isFive and not na(time(timeframe.period, extSess, tz))

orStart = inOR and not inOR[1]
orEnd   = not inOR and inOR[1]

// ----------------------------------------------------------------- state ----
var float orH   = na
var float orL   = na
var int   nBar  = 0
var int   nUp   = 0
var int   nDn   = 0
var int   tOR   = na
var bool  armed = false
var int   dir   = 0

var box   bxOR  = na
var line  lnMid = na
var line  lnE   = na
var line  lnS   = na
var line  lnT1  = na
var line  lnT2  = na
var line  lnT3  = na
var label laE   = na
var label laS   = na
var label laT1  = na
var label laT2  = na
var label laT3  = na

// ------------------------------------------------- build the opening range --
if orStart
    orH   := high
    orL   := low
    nBar  := 1
    nUp   := close > open ? 1 : 0
    nDn   := close < open ? 1 : 0
    tOR   := time
    armed := false
    dir   := 0
    // drop handles so yesterday's drawings stay put instead of stretching
    bxOR  := na
    lnMid := na
    lnE   := na
    lnS   := na
    lnT1  := na
    lnT2  := na
    lnT3  := na
    laE   := na
    laS   := na
    laT1  := na
    laT2  := na
    laT3  := na
else if inOR
    orH  := math.max(orH, high)
    orL  := math.min(orL, low)
    nBar += 1
    nUp  += close > open ? 1 : 0
    nDn  += close < open ? 1 : 0

// -------------------------------------------------- 9:45 -- run the gate ----
if orEnd
    agree = nBar == 3 and (nUp == 3 or nDn == 3)
    pass  = reqAgree ? agree : nBar == 3
    if pass
        armed := true
        bxOR  := box.new(tOR, orH, time, orL, xloc = xloc.bar_time,
             border_color = cBoxB, border_width = 1, bgcolor = cBoxF)
        mid = (orH + orL) / 2
        lnMid := line.new(tOR, mid, time, mid, xloc = xloc.bar_time,
             color = cMid, style = line.style_dotted, width = 1)
    else if showNT and nBar == 3
        label.new(time, orH, "no trade", xloc = xloc.bar_time,
             style = label.style_label_down, color = color.new(deepOcean, 75),
             textcolor = deepOcean, size = size.tiny)

// ------------------------------------- first edge break -- resolve levels ----
if armed and dir == 0 and not inOR
    up = high > orH
    dn = low  < orL
    d  = 0
    if up and dn
        d := close > orH ? 1 : close < orL ? -1 : 0   // both edges in one bar
    else if up
        d := 1
    else if dn
        d := -1

    if d != 0
        dir := d
        R     = orH - orL
        lvlE  = d == 1 ? orH : orL
        lvlS  = d == 1 ? orL : orH
        lvlP1 = lvlE + d * R * 0.5
        lvlP2 = lvlE + d * R * 1.0
        lvlP3 = lvlE + d * R * 1.5

        lnE  := line.new(tOR, lvlE,  time, lvlE,  xloc = xloc.bar_time, color = cEnt, width = 1)
        lnS  := line.new(tOR, lvlS,  time, lvlS,  xloc = xloc.bar_time, color = cStp, width = 2)
        lnT1 := line.new(tOR, lvlP1, time, lvlP1, xloc = xloc.bar_time, color = cTgt,
             style = line.style_dashed)
        lnT2 := line.new(tOR, lvlP2, time, lvlP2, xloc = xloc.bar_time, color = cTgt, width = 2)
        if showP3
            lnT3 := line.new(tOR, lvlP3, time, lvlP3, xloc = xloc.bar_time, color = cTgt,
                 style = line.style_dashed)

        if showLbl
            laE  := label.new(time, lvlE,  "Entry", xloc = xloc.bar_time,
                 style = label.style_label_left, color = color.new(cEnt, 5),
                 textcolor = paper, size = szLbl)
            laS  := label.new(time, lvlS,  "Stop",  xloc = xloc.bar_time,
                 style = label.style_label_left, color = color.new(cStp, 5),
                 textcolor = paper, size = szLbl)
            laT1 := label.new(time, lvlP1, "P1  0.5x", xloc = xloc.bar_time,
                 style = label.style_label_left, color = color.new(cTgt, 5),
                 textcolor = paper, size = szLbl)
            laT2 := label.new(time, lvlP2, "P2  1x",   xloc = xloc.bar_time,
                 style = label.style_label_left, color = color.new(cTgt, 5),
                 textcolor = paper, size = szLbl)
            if showP3
                laT3 := label.new(time, lvlP3, "P3  1.5x", xloc = xloc.bar_time,
                     style = label.style_label_left, color = color.new(cTgt, 5),
                     textcolor = paper, size = szLbl)

// -------------------------------------------- carry drawings to the right ---
if inEXT
    if not na(bxOR)
        box.set_right(bxOR, time)
    if not na(lnMid)
        line.set_x2(lnMid, time)
    if not na(lnE)
        line.set_x2(lnE, time)
        line.set_x2(lnS, time)
        line.set_x2(lnT1, time)
        line.set_x2(lnT2, time)
        if not na(lnT3)
            line.set_x2(lnT3, time)
    if not na(laE)
        label.set_x(laE,  time)
        label.set_x(laS,  time)
        label.set_x(laT1, time)
        label.set_x(laT2, time)
        if not na(laT3)
            label.set_x(laT3, time)

// ----------------------------------------------------------------- tint -----
bgcolor(showTint and inOR ? cTint : na, title = "Opening range window")
````
