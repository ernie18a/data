# EPS

- url: https://www.tradingview.com/script/KuUFk8VY-EPS/
- type: indicator
- pine_id: PUB;eee9b2ed0ff340c68af2f3db6bae5542
- version: 1.0

## Description

EPS has did it and made his own indicator that accurately marks out OTE and STDV
NOT RECOMMENDED TO USE PLEASE DO NOT USE

## Source Code

````pine
//@version=6
indicator("EPS-A — OTE + SD", "EPS-A", overlay=true, max_lines_count=500, max_labels_count=50, max_boxes_count=50)

// ════════════════════════════════════════════════════════
//  (1) SWING DETECTION
// ════════════════════════════════════════════════════════
gSw      = "(1) Swing Detection"
pivotLen = input.int(15, "Swing strength", minval=3, maxval=60, group=gSw, tooltip="Higher = larger, less frequent legs")

// ════════════════════════════════════════════════════════
//  (2) OTE — OPTIMAL TRADE ENTRY
// ════════════════════════════════════════════════════════
gOte     = "(2) OTE - Optimal Trade Entry"
showOte  = input.bool(true,   "Show OTE zone",          group=gOte)
oteStart = input.float(0.62,  "OTE start",  step=0.005, group=gOte)
oteEnd   = input.float(0.79,  "OTE end",    step=0.005, group=gOte)
oteSweet = input.float(0.705, "Sweet spot", step=0.005, group=gOte)
showEq   = input.bool(true,   "Show equilibrium (50%)", group=gOte)
oteFill  = input.color(color.new(#1D9E75, 84), "OTE fill", group=gOte)

// ════════════════════════════════════════════════════════
//  (3) STANDARD DEVIATION PROJECTIONS
// ════════════════════════════════════════════════════════
gSd     = "(3) Standard Deviation Projections"
showSd  = input.bool(true, "Show SD projections", group=gSd)
sd1     = input.float(1.0, "SD level 1", step=0.5, group=gSd)
sd2     = input.float(2.0, "SD level 2", step=0.5, group=gSd)
sd3     = input.float(2.5, "SD level 3", step=0.5, group=gSd)
sd4     = input.float(4.0, "SD level 4", step=0.5, group=gSd)
sdColor = input.color(#7F77DD, "SD color", group=gSd)

// ════════════════════════════════════════════════════════
//  (4) DASHBOARD
// ════════════════════════════════════════════════════════
gDa      = "(4) Dashboard"
showDash = input.bool(true, "Show info table", group=gDa)
dPos     = input.string("Top Right", "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=gDa)

// ════════════════════════════════════════════════════════
//  SWING LOGIC
// ════════════════════════════════════════════════════════
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low,  pivotLen, pivotLen)

var float swHigh = na
var float swLow  = na
var int   swHB   = na
var int   swLB   = na

if not na(ph)
    swHigh := ph
    swHB   := bar_index - pivotLen
if not na(pl)
    swLow := pl
    swLB  := bar_index - pivotLen

hasLeg   = not na(swHigh) and not na(swLow)
isBull   = hasLeg and swHB > swLB
rng      = hasLeg ? swHigh - swLow : na
legEnd   = isBull ? swHB : swLB
legStart = isBull ? swLB : swHB

// ════════════════════════════════════════════════════════
//  OTE + SD LEVELS
// ════════════════════════════════════════════════════════
oteA  = isBull ? swHigh - oteStart*rng : swLow + oteStart*rng
oteB  = isBull ? swHigh - oteEnd*rng   : swLow + oteEnd*rng
oteS  = isBull ? swHigh - oteSweet*rng : swLow + oteSweet*rng
eqP   = hasLeg ? (swHigh + swLow) / 2  : na
oteHi = math.max(oteA, oteB)
oteLo = math.min(oteA, oteB)
sdP1  = isBull ? swHigh + sd1*rng : swLow - sd1*rng
sdP2  = isBull ? swHigh + sd2*rng : swLow - sd2*rng
sdP3  = isBull ? swHigh + sd3*rng : swLow - sd3*rng
sdP4  = isBull ? swHigh + sd4*rng : swLow - sd4*rng
inOte = hasLeg and high >= oteLo and low <= oteHi

// ════════════════════════════════════════════════════════
//  DRAWING OBJECTS
// ════════════════════════════════════════════════════════
var box   bxOte   = na
var line  lnLeg   = na
var line  lnSweet = na
var line  lnEq    = na
var line  lnSd1   = na
var line  lnSd2   = na
var line  lnSd3   = na
var line  lnSd4   = na
var label lbOte   = na
var label lbSweet = na
var label lbEq    = na
var label lbSd1   = na
var label lbSd2   = na
var label lbSd3   = na
var label lbSd4   = na

dashP = dPos=="Top Left" ? position.top_left : dPos=="Bottom Right" ? position.bottom_right : dPos=="Bottom Left" ? position.bottom_left : position.top_right
var table dash = table.new(dashP, 2, 8, border_width=1, border_color=color.new(color.gray,50), frame_width=1, frame_color=color.new(color.gray,30))

if barstate.islast and hasLeg
    box.delete(bxOte)
    line.delete(lnLeg)
    line.delete(lnSweet)
    line.delete(lnEq)
    line.delete(lnSd1)
    line.delete(lnSd2)
    line.delete(lnSd3)
    line.delete(lnSd4)
    label.delete(lbOte)
    label.delete(lbSweet)
    label.delete(lbEq)
    label.delete(lbSd1)
    label.delete(lbSd2)
    label.delete(lbSd3)
    label.delete(lbSd4)

    rx     = bar_index + 12
    legCol = isBull ? color.new(#1D9E75, 0) : color.new(#E24B4A, 0)
    lnLeg := line.new(legStart, isBull ? swLow : swHigh, legEnd, isBull ? swHigh : swLow, color=legCol, width=2)

    if showOte
        bxOte   := box.new(legEnd, oteHi, rx, oteLo, border_color=color.new(#1D9E75, 35), bgcolor=oteFill)
        lnSweet := line.new(legEnd, oteS, rx, oteS, color=color.new(#1D9E75, 0), style=line.style_dashed)

    if showEq
        lnEq := line.new(legStart, eqP, rx, eqP, color=color.new(#888780, 0), style=line.style_dotted)

    if showSd
        lnSd1 := line.new(legEnd, sdP1, rx, sdP1, color=sdColor)
        lnSd2 := line.new(legEnd, sdP2, rx, sdP2, color=sdColor)
        lnSd3 := line.new(legEnd, sdP3, rx, sdP3, color=color.new(sdColor, 0), width=2)
        lnSd4 := line.new(legEnd, sdP4, rx, sdP4, color=sdColor)
      
// ════════════════════════════════════════════════════════
//  DASHBOARD
// ════════════════════════════════════════════════════════


// ════════════════════════════════════════════════════════
//  ALERTS
// ════════════════════════════════════════════════════════
sd1Hit = isBull ? high >= sdP1 : low <= sdP1
sd3Hit = isBull ? high >= sdP3 : low <= sdP3
alertcondition(inOte and not inOte[1],   "Price entered OTE", "Price tapped the OTE zone")
alertcondition(sd1Hit and not sd1Hit[1], "-1 SD reached",     "Price reached -1 SD projection")
alertcondition(sd3Hit and not sd3Hit[1], "-2.5 SD reached",   "Price reached -2.5 SD projection")
````
