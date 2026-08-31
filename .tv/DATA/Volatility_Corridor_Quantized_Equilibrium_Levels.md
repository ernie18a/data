<!-- tradingview-pine-id: PUB;ad5d15e587eb4801842a0b475187e48a -->
<!-- tradingviewscripts-format: 1 -->
# Volatility Corridor - Quantized Equilibrium Levels

Source: https://www.tradingview.com/script/LrnGg8A4-Volatility-Corridor-Quantized-Equilibrium-Levels/

## Description

Most range and channel tools slide. The midline is a moving average, so it moves on every bar, and the levels drawn from it move with it. That makes them fine as a trend read and close to useless as levels, because the level you looked at ten bars ago is no longer where you left it.

Volatility Corridor does the opposite. It holds still, and then it jumps.

HOW THE CORRIDOR IS BUILT

An equilibrium anchor sits at the centre of the corridor. Once placed, it is frozen. It does not drift, it does not smooth, it does not respond to anything at all until price closes more than one volatility step away from it.

When that happens, the anchor jumps by a whole number of steps in the direction of the breach, lands at the new location, re-measures its step size from ATR at that exact moment, and freezes again.

Three bands are drawn one step apart above the anchor and three below, giving seven horizontal levels: S3, S2, S1, EQ, R1, R2, R3. Because the anchor and the step are both frozen between jumps, every one of those levels is a genuine flat horizontal line for the entire life of the corridor. Across a chart the result is a staircase of stable shelves rather than a wave, and the jump bars are marked so the history of the structure is readable at a glance.

The quantization matters. The anchor moves by whole steps, never by fractions, so successive corridors line up on a common grid instead of drifting off it. When price returns to an area it traded weeks ago, the corridor tends to rebuild on the same shelves rather than near them.

WHAT IS ON THE CHART

Seven stepline levels, thickest at the equilibrium.

Six filled bands between them, darkening toward the outer edges, so the corridor reads instantly without inspecting a single number.

Candles tinted by their position inside the corridor, running from the lower colour at the bottom edge through neutral at equilibrium to the upper colour at the top.

Background tint whenever price is trading fully outside the corridor.

Price labels on every level at the right edge, in four selectable sizes.

Jump markers at the top and bottom of the pane showing every bar the corridor re-anchored, and in which direction.

SETUPS

Two setups are defined, and either can be switched off.

Reversion. Price has pushed into the outer band and closes back inside it while still on its own side of equilibrium. The stop is the far outer level, and the targets are the levels above: equilibrium first, then the next band, then the one after that. The reasoning is that a corridor that is holding will pull price back toward its centre, and the level structure already provides the map for that journey.

Breakout. Price closes fully beyond the outer level of the corridor. The stop is the first level back inside, and the targets are projected one, two and three steps beyond the corridor edge, on the same grid the corridor itself uses.

In both cases the stop and the targets are structural levels, not multiples of risk. Nothing is placed at an arbitrary distance. The stop is where the structure would be wrong, and the targets are the next shelves on the grid.

Only one setup is tracked at a time. A new signal cannot silently replace an unresolved one.

The panel keeps a record of whether the first target or the stop was reached first, and prints collecting rather than a percentage until the sample is large enough to mean anything. That number is a narrow measurement of one mechanical rule, not a backtest, and it says nothing about what a trader who moved a stop or scaled out would have achieved.

SETTINGS

Step Size is the one dial that matters. It sets the width of a single band in ATR terms, and therefore how far price must travel to force a jump. Larger values give wider, rarer, more significant corridors. Smaller values give a tighter grid that re-anchors often.

Volatility Length sets the ATR lookback used to measure a step at each anchor. Longer is more stable.

Everything else is cosmetic: fills, candle painting, label size, level thickness, background tint.

REPAINTING

The anchor, the step size, the jumps, the setups and the alerts all evaluate on confirmed bars only. A level that is drawn is final for the life of the corridor and is never moved retroactively. The script requests no higher timeframe data.

READING IT

Equilibrium is the fair value the corridor is currently defending. Price oscillating around it is a market with no directional decision.

The outer bands are where the current corridor stops being an adequate description of price. Price reaching them means one of two things is about to happen: it is rejected and the corridor holds, or it closes through and the whole structure jumps to a new shelf. Both are tradable and both have a setup defined for them.

A corridor that survives many bars is a market that has agreed on value. A rapid sequence of jumps in one direction is a trend, and the jump markers make that sequence obvious even when the candles do not.

This is an analysis tool, not financial advice, and not a trading system. The setups are two mechanically defined patterns, and no pattern has an edge on its own. Use it with your own risk management and position sizing.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=6
indicator("Volatility Corridor - Quantized Equilibrium Levels", "Corridor", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// ============================================================================
//  VOLATILITY CORRIDOR
//
//  A price corridor of seven levels that does not slide with every tick.
//  It holds still, and then jumps.
//
//  An equilibrium anchor sits at the centre. It is frozen until price closes
//  more than one volatility step away from it, at which point it jumps by a
//  whole number of steps toward price and freezes again at the new location.
//  The step size is re-measured from ATR at that moment and then held.
//
//  The result is a staircase, not a wave. Every level is flat and horizontal
//  for as long as the corridor holds, which is exactly what makes it usable
//  as a level: it does not move while you are watching it.
//
//  Three bands sit above the anchor and three below, each one step wide, and
//  the space between them is filled so the corridor reads at a glance from
//  across the room. Candles are tinted by their position inside it.
//
//  Setups are level based. The stop is the far edge of the corridor and the
//  targets are the levels above, not arbitrary multiples of risk.
//
//  Everything evaluates on confirmed bars. The corridor never redraws.
// ============================================================================

// -------------------------------- INPUTS -----------------------------------
G1 = "CORRIDOR"
G2 = "VISUALS"
G3 = "SETUPS"
G4 = "PANEL"

atrLen   = input.int(100, "Volatility Length", minval = 10, maxval = 500, group = G1, tooltip = "ATR lookback used to size one corridor step. Longer gives wider, slower, more stable corridors.")
stepMult = input.float(1.6, "Step Size (x ATR)", minval = 0.2, step = 0.1, group = G1, tooltip = "The width of one band. This is the single dial that decides how often the corridor re-anchors. Larger means fewer, bigger corridors.")

showBands  = input.bool(true, "Show Bands", group = G2)
showCloud  = input.bool(true, "Fill Corridor", group = G2)
paintBars  = input.bool(true, "Paint Candles by Position", group = G2)
showLabels = input.bool(true, "Show Level Labels", group = G2)
labelSize  = input.string("Normal", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = G2)
tintEdge   = input.bool(true, "Tint Background Outside The Corridor", group = G2)
lineW      = input.int(2, "Level Thickness", minval = 1, maxval = 4, group = G2)

sigMode  = input.string("Both", "Setup Mode", options = ["Reversion", "Breakout", "Both", "Off"], group = G3, tooltip = "Reversion takes price returning from the outer band toward the middle. Breakout takes a confirmed close beyond the corridor.")
showSetup = input.bool(true, "Draw Entry, Stop and Targets", group = G3)

showPanel = input.bool(true, "Show Panel", group = G4)
panelPos  = input.string("Top Right", "Panel Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = G4)

// -------------------------------- COLORS -----------------------------------
G5 = "COLORS"
cBull = input.color(#00e08a, "Bullish", group = G5)
cBear = input.color(#ff4560, "Bearish", group = G5)
cMid  = input.color(#c9a227, "Equilibrium", group = G5)
cTxt  = input.color(#0b0f18, "Label Text", group = G5)

// ============================================================================
//  1. QUANTIZED EQUILIBRIUM ANCHOR
// ============================================================================
float atrV = ta.atr(atrLen)

var float anchor  = na
var float aStep   = na
var int   aBar    = na
var int   jumpDir = 0

bool reAnchor = false

if barstate.isconfirmed and not na(atrV) and atrV > 0
    if na(anchor)
        aStep    := atrV * stepMult
        anchor   := close
        aBar     := bar_index
        reAnchor := true
    else
        float dev = close - anchor
        if math.abs(dev) > aStep
            int k = int(dev / aStep)
            k := k == 0 ? (dev > 0 ? 1 : -1) : k
            anchor   := anchor + k * aStep
            aStep    := atrV * stepMult
            aBar     := bar_index
            jumpDir  := k > 0 ? 1 : -1
            reAnchor := true

// -------------------------------- LEVELS -----------------------------------
float eq = anchor
float r1 = na(anchor) ? na : anchor + aStep
float r2 = na(anchor) ? na : anchor + aStep * 2
float r3 = na(anchor) ? na : anchor + aStep * 3
float s1 = na(anchor) ? na : anchor - aStep
float s2 = na(anchor) ? na : anchor - aStep * 2
float s3 = na(anchor) ? na : anchor - aStep * 3

// position inside the corridor, -1 at the bottom edge, +1 at the top edge
float pos = na(anchor) or aStep <= 0 ? 0.0 : math.max(math.min((close - anchor) / (aStep * 3), 1.5), -1.5)

// ============================================================================
//  2. THE CORRIDOR ITSELF
// ============================================================================
color cUpper = color.new(cBear, 0)
color cLower = color.new(cBull, 0)

pR3 = plot(showBands ? r3 : na, "R3", color = color.new(cBear, 15), linewidth = lineW, style = plot.style_stepline)
pR2 = plot(showBands ? r2 : na, "R2", color = color.new(cBear, 40), linewidth = lineW, style = plot.style_stepline)
pR1 = plot(showBands ? r1 : na, "R1", color = color.new(cBear, 62), linewidth = lineW, style = plot.style_stepline)
pEQ = plot(showBands ? eq : na, "Equilibrium", color = color.new(cMid, 0), linewidth = lineW + 1, style = plot.style_stepline)
pS1 = plot(showBands ? s1 : na, "S1", color = color.new(cBull, 62), linewidth = lineW, style = plot.style_stepline)
pS2 = plot(showBands ? s2 : na, "S2", color = color.new(cBull, 40), linewidth = lineW, style = plot.style_stepline)
pS3 = plot(showBands ? s3 : na, "S3", color = color.new(cBull, 15), linewidth = lineW, style = plot.style_stepline)

fill(pR2, pR3, color = showCloud ? color.new(cBear, 80) : na, title = "Upper Extreme")
fill(pR1, pR2, color = showCloud ? color.new(cBear, 88) : na, title = "Upper Band")
fill(pEQ, pR1, color = showCloud ? color.new(cBear, 94) : na, title = "Upper Inner")
fill(pEQ, pS1, color = showCloud ? color.new(cBull, 94) : na, title = "Lower Inner")
fill(pS1, pS2, color = showCloud ? color.new(cBull, 88) : na, title = "Lower Band")
fill(pS2, pS3, color = showCloud ? color.new(cBull, 80) : na, title = "Lower Extreme")

// candles tinted by where they sit inside the corridor
color barTint = color.from_gradient(pos, -1.0, 1.0, cBull, cBear)
plotcandle(paintBars ? open : na, paintBars ? high : na, paintBars ? low : na, paintBars ? close : na, title = "Corridor Candles", color = barTint, wickcolor = barTint, bordercolor = barTint)

bgcolor(tintEdge and not na(r3) and close > r3 ? color.new(cBear, 90) : tintEdge and not na(s3) and close < s3 ? color.new(cBull, 90) : na, title = "Outside Corridor")

// mark the bar where the corridor jumped
plotshape(reAnchor and jumpDir == 1, title = "Corridor Jump Up", style = shape.triangleup, location = location.bottom, color = color.new(cBull, 30), size = size.tiny)
plotshape(reAnchor and jumpDir == -1, title = "Corridor Jump Down", style = shape.triangledown, location = location.top, color = color.new(cBear, 30), size = size.tiny)

// ============================================================================
//  3. LEVEL LABELS
// ============================================================================
f_lsize(string s) => s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : size.normal

var label lR3 = na
var label lR2 = na
var label lR1 = na
var label lEQ = na
var label lS1 = na
var label lS2 = na
var label lS3 = na

f_tag(label old, float y, string txt, color bg) =>
    label.delete(old)
    label.new(bar_index + 12, y, txt + "  " + str.tostring(y, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = bg, textcolor = cTxt, size = f_lsize(labelSize))

if barstate.islast and showLabels and not na(anchor)
    lR3 := f_tag(lR3, r3, "R3", color.new(cBear, 10))
    lR2 := f_tag(lR2, r2, "R2", color.new(cBear, 30))
    lR1 := f_tag(lR1, r1, "R1", color.new(cBear, 50))
    lEQ := f_tag(lEQ, eq, "EQ", color.new(cMid, 0))
    lS1 := f_tag(lS1, s1, "S1", color.new(cBull, 50))
    lS2 := f_tag(lS2, s2, "S2", color.new(cBull, 30))
    lS3 := f_tag(lS3, s3, "S3", color.new(cBull, 10))

// ============================================================================
//  4. SETUPS
// ============================================================================
bool modeRev = sigMode == "Reversion" or sigMode == "Both"
bool modeBrk = sigMode == "Breakout" or sigMode == "Both"

var int   tDir   = 0
var float tEntry = na
var float tStop  = na
var float tT1    = na
var float tT2    = na
var float tT3    = na
var string tKind = ""
var int   wins   = 0
var int   losses = 0

bool sigLong  = false
bool sigShort = false

if barstate.isconfirmed and not na(anchor) and aStep > 0

    // ---- resolve an open setup first ---------------------------------------
    if tDir == 1
        if low <= tStop
            losses += 1
            tDir := 0
        else if high >= tT1
            wins += 1
            tDir := 0
    else if tDir == -1
        if high >= tStop
            losses += 1
            tDir := 0
        else if low <= tT1
            wins += 1
            tDir := 0

    // ---- reversion: price returns from the outer band -----------------------
    bool revLong  = modeRev and close > s2 and close[1] <= s2 and close < eq
    bool revShort = modeRev and close < r2 and close[1] >= r2 and close > eq

    // ---- breakout: confirmed close beyond the corridor ----------------------
    bool brkLong  = modeBrk and close > r3 and close[1] <= r3
    bool brkShort = modeBrk and close < s3 and close[1] >= s3

    if tDir == 0
        if revLong
            sigLong := true
            tDir    := 1
            tKind   := "Reversion"
            tEntry  := close
            tStop   := s3
            tT1     := eq
            tT2     := r1
            tT3     := r2
        else if brkLong
            sigLong := true
            tDir    := 1
            tKind   := "Breakout"
            tEntry  := close
            tStop   := r1
            tT1     := r3 + aStep
            tT2     := r3 + aStep * 2
            tT3     := r3 + aStep * 3
        else if revShort
            sigShort := true
            tDir     := -1
            tKind    := "Reversion"
            tEntry   := close
            tStop    := r3
            tT1      := eq
            tT2      := s1
            tT3      := s2
        else if brkShort
            sigShort := true
            tDir     := -1
            tKind    := "Breakout"
            tEntry   := close
            tStop    := s1
            tT1      := s3 - aStep
            tT2      := s3 - aStep * 2
            tT3      := s3 - aStep * 3

// -------------------------------- SETUP PLOTS ------------------------------
float plEntry = showSetup and tDir != 0 ? tEntry : na
float plStop  = showSetup and tDir != 0 ? tStop  : na
float plT1    = showSetup and tDir != 0 ? tT1    : na
float plT2    = showSetup and tDir != 0 ? tT2    : na
float plT3    = showSetup and tDir != 0 ? tT3    : na

pEn = plot(plEntry, "Entry", color = #ffffff, style = plot.style_linebr, linewidth = 2)
pSt = plot(plStop, "Stop", color = cBear, style = plot.style_linebr, linewidth = 2)
pTa = plot(plT3, "Final Target", color = cBull, style = plot.style_linebr, linewidth = 2)
plot(plT1, "Target 1", color = color.new(cBull, 35), style = plot.style_linebr, linewidth = 1)
plot(plT2, "Target 2", color = color.new(cBull, 35), style = plot.style_linebr, linewidth = 1)

fill(pEn, pSt, color = color.new(cBear, 88), title = "Risk")
fill(pEn, pTa, color = color.new(cBull, 92), title = "Reward")

if sigLong
    label.new(bar_index, low, "LONG  " + str.tostring(close, format.mintick), style = label.style_label_up, color = color.new(cBull, 0), textcolor = cTxt, size = size.normal)
if sigShort
    label.new(bar_index, high, "SHORT  " + str.tostring(close, format.mintick), style = label.style_label_down, color = color.new(cBear, 0), textcolor = cTxt, size = size.normal)

// ============================================================================
//  5. PANEL
// ============================================================================
f_pos(string s) => s == "Top Right" ? position.top_right : s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : position.middle_right

f_zone(float p) => p > 1.0 ? "Above corridor" : p > 0.66 ? "Upper extreme" : p > 0.33 ? "Upper band" : p > -0.33 ? "Equilibrium" : p > -0.66 ? "Lower band" : p > -1.0 ? "Lower extreme" : "Below corridor"

if barstate.islast and showPanel
    var table p = table.new(f_pos(panelPos), 2, 7, bgcolor = color.new(#0b0f18, 8), border_width = 1, border_color = color.new(#2a2e39, 0), frame_width = 1, frame_color = color.new(#2a2e39, 0))

    table.cell(p, 0, 0, "CORRIDOR", text_color = #0b0f18, text_halign = text.align_center, bgcolor = cMid, text_size = size.normal)
    table.cell(p, 1, 0, syminfo.ticker + "  " + timeframe.period, text_color = #0b0f18, text_halign = text.align_center, bgcolor = cMid, text_size = size.normal)

    table.cell(p, 0, 1, "Position", text_color = #9aa4b2, text_halign = text.align_center, text_size = size.normal)
    table.cell(p, 1, 1, f_zone(pos), text_color = barTint, text_halign = text.align_center, text_size = size.normal)

    table.cell(p, 0, 2, "Step size", text_color = #9aa4b2, text_halign = text.align_center, text_size = size.normal)
    table.cell(p, 1, 2, na(aStep) ? "-" : str.tostring(aStep, format.mintick), text_color = #e6eaf2, text_halign = text.align_center, text_size = size.normal)

    table.cell(p, 0, 3, "Corridor age", text_color = #9aa4b2, text_halign = text.align_center, text_size = size.normal)
    table.cell(p, 1, 3, na(aBar) ? "-" : str.tostring(bar_index - aBar) + " bars", text_color = #e6eaf2, text_halign = text.align_center, text_size = size.normal)

    table.cell(p, 0, 4, "Setup", text_color = #9aa4b2, text_halign = text.align_center, text_size = size.normal)
    table.cell(p, 1, 4, tDir == 0 ? "None" : (tDir == 1 ? "LONG " : "SHORT ") + tKind, text_color = tDir == 1 ? cBull : tDir == -1 ? cBear : #9aa4b2, text_halign = text.align_center, text_size = size.normal)

    table.cell(p, 0, 5, "Stop / Target 1", text_color = #9aa4b2, text_halign = text.align_center, text_size = size.normal)
    table.cell(p, 1, 5, tDir == 0 ? "-" : str.tostring(tStop, format.mintick) + "  /  " + str.tostring(tT1, format.mintick), text_color = #e6eaf2, text_halign = text.align_center, text_size = size.normal)

    int settled = wins + losses
    table.cell(p, 0, 6, "Record to T1", text_color = #9aa4b2, text_halign = text.align_center, text_size = size.normal)
    table.cell(p, 1, 6, settled < 10 ? "collecting " + str.tostring(settled) + "/10" : str.tostring(100.0 * wins / settled, "#.#") + " %  (" + str.tostring(settled) + ")", text_color = settled < 10 ? cMid : (wins >= losses ? cBull : cBear), text_halign = text.align_center, text_size = size.normal)

// ============================================================================
//  6. ALERTS
// ============================================================================
alertcondition(sigLong, title = "Long Setup", message = "Corridor: long setup on {{ticker}} {{interval}} at {{close}}")
alertcondition(sigShort, title = "Short Setup", message = "Corridor: short setup on {{ticker}} {{interval}} at {{close}}")
alertcondition(reAnchor and jumpDir == 1, title = "Corridor Jumped Up", message = "Corridor: the equilibrium re-anchored upward on {{ticker}} {{interval}}")
alertcondition(reAnchor and jumpDir == -1, title = "Corridor Jumped Down", message = "Corridor: the equilibrium re-anchored downward on {{ticker}} {{interval}}")
alertcondition(not na(r3) and close > r3 and close[1] <= r3, title = "Closed Above Corridor", message = "Corridor: price closed above the upper extreme on {{ticker}} {{interval}}")
alertcondition(not na(s3) and close < s3 and close[1] >= s3, title = "Closed Below Corridor", message = "Corridor: price closed below the lower extreme on {{ticker}} {{interval}}")

if sigLong
    alert("Corridor - LONG " + tKind + " on " + syminfo.ticker + " " + timeframe.period + " | entry " + str.tostring(tEntry, format.mintick) + " | stop " + str.tostring(tStop, format.mintick) + " | targets " + str.tostring(tT1, format.mintick) + " " + str.tostring(tT2, format.mintick) + " " + str.tostring(tT3, format.mintick), alert.freq_once_per_bar_close)
if sigShort
    alert("Corridor - SHORT " + tKind + " on " + syminfo.ticker + " " + timeframe.period + " | entry " + str.tostring(tEntry, format.mintick) + " | stop " + str.tostring(tStop, format.mintick) + " | targets " + str.tostring(tT1, format.mintick) + " " + str.tostring(tT2, format.mintick) + " " + str.tostring(tT3, format.mintick), alert.freq_once_per_bar_close)
````
