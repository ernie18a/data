# Stochastic Momentum Index [MiesOnCharts]

- url: https://www.tradingview.com/script/nV8zuFFc-Stochastic-Momentum-Index-MiesOnCharts/
- type: indicator
- pine_id: PUB;8a65649821ab4632baa0723c1ea014c6
- version: 1.0

## Description

A smoother William Blau's Stochastic Momentum Index.

[b]What it measures[/b]

Where the close sits against the middle of the recent high to low range, scaled from -100 to +100. Zero is a close at the middle of the range, +100 a close pinned to its top, -100 to its bottom.

A plain stochastic divides by the range on every bar, so in a tight range it swings from one end to the other. The SMI smooths the distance and the range separately before dividing them.

[b]What is different here[/b]

- Blau smoothed both parts with two EMAs each. This version uses one Ehlers SuperSmoother on each.
- A cross buffer. The line only changes side once the SMI is clearly past its signal line, so it does not flip every time the two lines touch. 
- Signals fire on the close. The line moves with price while a bar is forming, but markers and alerts only fire once the bar has closed.

[b]How to read it[/b]

- Green line: the SMI is above its signal line and momentum is rising. Red: below it and momentum is falling.
- Shaded background: the SMI is beyond the overbought or oversold level.
- Triangles: a turn made while the signal line is beyond one of those levels. A turn down from overbought or up from oversold is the classic SMI signal.
- Optional candle colouring follows the same green and red.

[b]Settings[/b]

- Range Length: how many bars the high to low range covers. Longer gives a steadier, slower line.
- Smoothing: the SuperSmoother period. Longer is quieter and slower.
- Signal Length: the EMA of the SMI drawn as the signal line.
- Cross Buffer: how far past the signal line the SMI has to get before the line changes side. Zero changes side on every cross.
- Overbought and Oversold: the levels used for the shading and the triangles.

[b]Alerts[/b]

Turned up, turned down, turned up in oversold and turned down in overbought. All fire on the bar close.

[b]Notes[/b]

Like any oscillator, it describes momentum that has already happened. Overbought and oversold are not reversal calls on their own; in a strong trend the SMI can stay at an extreme for a long time.

[b]Credits[/b]

The Stochastic Momentum Index is William Blau's. The SuperSmoother is John Ehlers'.

For educational purposes only. Not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MiesOnCharts

//   __  __ _
//  |  \/  (_) ___  ___
//  | |\/| | |/ _ \/ __|
//  | |  | | |  __/\__ \
//  |_|  |_|_|\___||___/

//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  STOCHASTIC MOMENTUM INDEX
// 
//    D   = close - (highest high + lowest low) / 2
//    R   = highest high - lowest low
//    SMI = 100 x SS(D) / (0.5 x SS(R))
//
//  Blau smoothed D and R with two EMAs each. Here each gets one Ehlers
//  SuperSmoother instead, a two pole filter that removes more of the short
//  wiggle than a pair of EMAs at the same delay. The signal line is an EMA of
//  the SMI, and the line only changes side once it is clear of the signal line
//  by the cross buffer, so it stops flipping on every touch.
// ═══════════════════════════════════════════════════════════════════════════
indicator("Stochastic Momentum Index [MiesOnCharts]", shorttitle = "SMI - Mies", overlay = false, precision = 2)

grpM = "SMI"
grpL = "Levels"
grpD = "Display"

rangeLen  = input.int(16, "Range Length", minval = 1, group = grpM, display = display.none,
     tooltip = "Bars the highest high and lowest low are taken over.")
smoothLen = input.int(12, "Smoothing", minval = 2, group = grpM, display = display.none,
     tooltip = "Period of the SuperSmoother applied to both the distance from the midpoint and the range. Longer is quieter and slower.")
sigLen    = input.int(10, "Signal Length", minval = 1, group = grpM, display = display.none,
     tooltip = "EMA of the SMI drawn as the signal line.")
buffer    = input.float(3.0, "Cross Buffer", minval = 0, step = 0.5, group = grpM, display = display.none,
     tooltip = "How far past the signal line the SMI has to get")

obLvl = input.float(40.0, "Overbought", minval = 0, maxval = 100, step = 5, group = grpL, display = display.none,
     tooltip = "Level above which the SMI counts as overbought. A turn down made while the signal line is above it is marked.")
osLvl = input.float(-40.0, "Oversold", minval = -100, maxval = 0, step = 5, group = grpL, display = display.none,
     tooltip = "Level below which the SMI counts as oversold. A turn up made while the signal line is below it is marked.")

showSig   = input.bool(true,  "Signal Line",         group = grpD, display = display.none)
showFill  = input.bool(true,  "Fill Between Lines",  group = grpD, display = display.none)
showBg    = input.bool(true,  "Shade Extremes",      group = grpD, display = display.none)
showMarks = input.bool(true,  "Mark Extreme Turns",  group = grpD, display = display.none)
paintBars = input.bool(false, "Paint Candles",       group = grpD, display = display.none,
     tooltip = "Colours the candles with the side the SMI is on: green above its signal line, red below.")
colUp  = input.color(#00ff15, "Rising",  inline = "c", group = grpD)
colDn  = input.color(#ff0000, "Falling", inline = "c", group = grpD)
colSig = input.color(#787b86, "Signal",  inline = "c", group = grpD)

// ── The smoother ──────────────────────────────────────────────────────────
// Ehlers' two pole SuperSmoother. Seeded with its own input for the first two
// bars, then recursive. Each call site keeps its own history, so the distance
// and the range below are smoothed independently.
f_ss(float x, simple int P) =>
    float a1 = math.exp(-math.sqrt(2.0) * math.pi / P)
    float c2 = 2.0 * a1 * math.cos(math.sqrt(2.0) * math.pi / P)
    float c3 = -a1 * a1
    float c1 = 1.0 - c2 - c3
    float y  = na
    y := na(x) ? na : na(y[1]) or na(y[2]) ? x : c1 * (x + x[1]) / 2.0 + c2 * y[1] + c3 * y[2]
    y

// ── The index ─────────────────────────────────────────────────────────────
// Unlike a pair of EMAs, the SuperSmoother can overshoot a little, so the
// ratio is held inside +-100 where the SMI is defined.
float hh  = ta.highest(high, rangeLen)
float ll  = ta.lowest(low, rangeLen)
float dS  = f_ss(close - (hh + ll) / 2.0, smoothLen)
float rS  = f_ss(hh - ll, smoothLen)
float smi = na(rS) ? na : rS > 0 ? math.max(-100.0, math.min(100.0, 100.0 * dS / (0.5 * rS))) : 0.0
float sig = ta.ema(smi, sigLen)

// ── Side ──────────────────────────────────────────────────────────────────
// Above the signal line by more than the buffer is rising, below it by more
// than the buffer is falling, and in between the line keeps the side it had.
// Moves live with price on the unconfirmed bar and confirms on the close.
var int side = 0
if not na(smi) and not na(sig)
    side := smi > sig + buffer ? 1 : smi < sig - buffer ? -1 : side

color lineCol = side == 1 ? colUp : side == -1 ? colDn : colSig

// ── Render ────────────────────────────────────────────────────────────────
pSmi = plot(smi, "SMI", color = lineCol, linewidth = 2)
pSig = plot(sig, "Signal", color = showSig ? colSig : na, linewidth = 1)
fill(pSmi, pSig, color = showFill and showSig ? color.new(lineCol, 80) : na, title = "SMI Fill")

hline(obLvl, "Overbought", color.new(colDn, 55), hline.style_dashed)
hline(0,     "Zero",       color.new(#ffffff, 62), hline.style_dotted)
hline(osLvl, "Oversold",   color.new(colUp, 55), hline.style_dashed)

bgcolor(showBg and smi >= obLvl ? color.new(colDn, 92) : na, title = "Overbought")
bgcolor(showBg and smi <= osLvl ? color.new(colUp, 92) : na, title = "Oversold")

barcolor(paintBars and side != 0 ? lineCol : na, title = "Candles")

// ── Signals ───────────────────────────────────────────────────────────────
// A turn is the bar the side changes, taken on closed bars only, so a turn
// that undoes itself before the close never marks or alerts. It counts as an
// extreme one when the signal line sits beyond the level.
bool turnUp   = barstate.isconfirmed and side ==  1 and side[1] !=  1
bool turnDn   = barstate.isconfirmed and side == -1 and side[1] != -1
bool turnUpOS = turnUp and sig <= osLvl
bool turnDnOB = turnDn and sig >= obLvl

plotshape(showMarks and turnUpOS ? smi : na, "Oversold Turn",   shape.triangleup,   location.absolute, colUp, size = size.tiny)
plotshape(showMarks and turnDnOB ? smi : na, "Overbought Turn", shape.triangledown, location.absolute, colDn, size = size.tiny)

alertcondition(turnUp,   "Turned Up",               "SMI turned up through its signal line")
alertcondition(turnDn,   "Turned Down",             "SMI turned down through its signal line")
alertcondition(turnUpOS, "Turned Up in Oversold",   "SMI turned up through its signal line in oversold")
alertcondition(turnDnOB, "Turned Down in Overbought", "SMI turned down through its signal line in overbought")
````
