# Vortex Signals [Gabremoku]

- url: https://www.tradingview.com/script/I3KOCVgc-Vortex-Signals-Gabremoku/
- type: indicator
- pine_id: PUB;689597b2c23f4ec79537c8f3825aa285
- version: 1.0

## Description

Vortex Signals [Gabremoku] is a reworked version of the classic Vortex Indicator designed to make directional shifts easier to read and less reactive than raw crossover-based interpretations.

Instead of treating every VI+ / VI- crossover as a direct trading signal, this script uses the Vortex lines as a regime detector first, then looks for signal quality through spread expansion and re-activation after a pullback. The goal is to reduce the noisy sequence of repeated entries and exits that often appears when the standard Vortex is used on its own.

What the script does:

Plots the classic Vortex components, VI+ and VI-.

Fills the space between the two lines with a dynamic gradient that reflects which side is dominant and how strong the current spread is.

Detects bullish and bearish dominance regimes.

Uses a signal engine based on regime change, spread expansion, and first valid continuation after weakening.

Prints compact chart markers for LONG, SHORT, and CLOSE events.

Includes a dashboard to show current state, sequence status, setup condition, spread, slope, and directional bias.

How it works:

Regime: the script first determines whether VI+ is above VI- or VI- is above VI+.

Spread: it measures the distance between the two Vortex lines to evaluate whether dominance is meaningful or weak.

Expansion: a regime becomes more relevant when the spread rises above its short baseline and continues widening.

Trigger logic: instead of firing on every crossover, the script waits for either an early valid impulse after regime change or the first useful re-expansion after a pullback inside the same regime.

Why this is different from the classic Vortex:

The built-in Vortex is often read through raw line crossovers.

This script reframes the indicator as a dominance and continuation tool rather than a pure crossover trigger.

The signal engine is designed to capture cleaner transitions and continuation phases while avoiding part of the back-and-forth noise that often occurs in choppy conditions.

How to use it:

In Long mode, focus on bullish dominance and the appearance of a LONG marker after spread expansion or re-expansion.

In Short mode, focus on bearish dominance and the appearance of a SHORT marker after the same logic on the opposite side.

CLOSE markers appear when the opposite Vortex condition breaks the active sequence.

Suggested use:

This script is generally better suited to trending or directional environments than to highly compressed sideways markets.

In my testing and chart observation, the signals can appear cleaner on the 1H timeframe, where short-term noise is often reduced compared with very low timeframes, but users should still adapt settings to the instrument and market structure they trade.

Notes:

This indicator is not predictive and does not guarantee profitable signals.

It should be used as a decision-support tool together with price structure, risk management, and broader market context.

As with any directional model, false signals can still occur during whipsaw or transition phases.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Gabremoku

//@version=6
indicator("Vortex Signals [Gabremoku]", shorttitle="Vortex Signals", format=format.price, precision=4, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════
//  Vortex Signals [Gabremoku]
//  Classic Vortex with regime-based signals:
//  - VI+ / VI- classic calculation
//  - Dominance gradient fill
//  - Regime + spread expansion + first pullback re-entry logic
//  - Overlay labels on price chart
//  - Dashboard
// ═══════════════════════════════════════════════════════════════


// ── INPUTS ─────────────────────────────────────────────────────
grp0 = "⚙️ Core"
period_ = input.int(14, "Length", minval=2, group=grp0)

grp1 = "🎨 Colors"
bullColor    = input.color(color.rgb(41, 98, 255), "Bullish Color", group=grp1)
bearColor    = input.color(color.rgb(233, 30, 99), "Bearish Color", group=grp1)
neutralColor = input.color(color.gray, "Neutral Color", group=grp1)

grp2 = "📐 Style"
lineWidth        = input.int(2, "Line Width", minval=1, maxval=5, group=grp2)
showFill         = input.bool(true, "Show Gradient Fill", group=grp2)
showMidline      = input.bool(false, "Show Midline 1.0", group=grp2)
showSignalPoints = input.bool(false, "Show Signal Points In Pane", group=grp2)
showSignals      = input.bool(true, "Show Overlay Signals", group=grp2)

grp3 = "🌈 Gradient Logic"
spreadRefLen     = input.int(100, "Spread Normalization Lookback", minval=10, group=grp3)
fillAggressive   = input.float(1.60, "Fill Aggressiveness", minval=0.5, maxval=4.0, step=0.1, group=grp3)
maxTranspWeak    = input.int(90, "Transparency on Weak Spread", minval=0, maxval=100, group=grp3)
minTranspStrong  = input.int(20, "Transparency on Strong Spread", minval=0, maxval=100, group=grp3)

grp4 = "🚦 Signal Engine"
strategySide      = input.string("Long", "Strategy Side", options=["Long", "Short"], group=grp4)
spreadMaLen       = input.int(5, "Spread Baseline Length", minval=1, group=grp4)
minSpreadDelta    = input.float(0.03, "Minimum Spread Advantage", minval=0.0, step=0.01, group=grp4)
pullbackBarsMax   = input.int(4, "Max Pullback Bars", minval=1, maxval=20, group=grp4)
signalAtrLen      = input.int(14, "Signal ATR Length", minval=1, group=grp4)
signalOffsetMult  = input.float(0.35, "Signal Offset ATR Multiplier", minval=0.05, step=0.05, group=grp4)
longText          = input.string("LONG", "Long Entry Text", group=grp4)
longCloseText     = input.string("CLOSE", "Long Exit Text", group=grp4)
shortText         = input.string("SHORT", "Short Entry Text", group=grp4)
shortCloseText    = input.string("CLOSE", "Short Exit Text", group=grp4)

grp5 = "🪧 Dashboard"
showDashboard      = input.bool(true, "Show Dashboard", group=grp5)
dashPosInput       = input.string("Bottom Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grp5)
dashTextSizeInput  = input.string("Small", "Dashboard Text Size", options=["Tiny", "Small", "Normal"], group=grp5)

dashTextSize = size.small
if dashTextSizeInput == "Tiny"
    dashTextSize := size.tiny
else if dashTextSizeInput == "Normal"
    dashTextSize := size.normal

dashPos = position.bottom_right
if dashPosInput == "Top Right"
    dashPos := position.top_right
else if dashPosInput == "Top Left"
    dashPos := position.top_left
else if dashPosInput == "Bottom Left"
    dashPos := position.bottom_left


// ── FUNCTIONS ──────────────────────────────────────────────────
clamp(_x, _min, _max) =>
    math.max(_min, math.min(_max, _x))


// ── CLASSIC VORTEX ─────────────────────────────────────────────
VMP = math.sum(math.abs(high - low[1]), period_)
VMM = math.sum(math.abs(low - high[1]), period_)
STR = math.sum(ta.atr(1), period_)

VIP = STR != 0 ? VMP / STR : na
VIM = STR != 0 ? VMM / STR : na


// ── SPREAD / DOMINANCE ─────────────────────────────────────────
spread = math.abs(VIP - VIM)
spreadMA = ta.ema(spread, spreadMaLen)
spreadAdv = spread - spreadMA

bullDominant = VIP > VIM
bearDominant = VIM > VIP

bullExpansion = bullDominant and spreadAdv > minSpreadDelta and spread > spread[1]
bearExpansion = bearDominant and spreadAdv > minSpreadDelta and spread > spread[1]

spreadMax = ta.highest(spread, spreadRefLen)
spreadNormBase = spreadMax != 0 ? spread / spreadMax : 0.0
spreadNorm = clamp(math.pow(spreadNormBase, fillAggressive), 0.0, 1.0)

dominantColor =
     bullDominant ? bullColor :
     bearDominant ? bearColor :
     neutralColor

fillWeak   = color.new(dominantColor, maxTranspWeak)
fillStrong = color.new(dominantColor, minTranspStrong)
fillColor  = color.from_gradient(spreadNorm, 0.0, 1.0, fillWeak, fillStrong)

state =
     bullExpansion ? "Bull Expansion" :
     bearExpansion ? "Bear Expansion" :
     bullDominant ? "Bull Dominance" :
     bearDominant ? "Bear Dominance" :
     "Neutral"

slopeState =
     spread > spread[1] ? "Expanding" :
     spread < spread[1] ? "Contracting" :
     "Flat"

bias =
     bullDominant ? "VI+" :
     bearDominant ? "VI-" :
     "Flat"


// ── REGIME CHANGE ──────────────────────────────────────────────
bullRegimeStart = bullDominant and not bullDominant[1]
bearRegimeStart = bearDominant and not bearDominant[1]

var bool bullArmed = false
var bool bearArmed = false
var int bullPullbackCount = 0
var int bearPullbackCount = 0
var bool bullPullbackSeen = false
var bool bearPullbackSeen = false

if bullRegimeStart
    bullArmed := true
    bullPullbackCount := 0
    bullPullbackSeen := false
    bearArmed := false
    bearPullbackCount := 0
    bearPullbackSeen := false

if bearRegimeStart
    bearArmed := true
    bearPullbackCount := 0
    bearPullbackSeen := false
    bullArmed := false
    bullPullbackCount := 0
    bullPullbackSeen := false


// ── PULLBACK / RE-EXPANSION ENGINE ─────────────────────────────
bullWeakening = bullDominant and spread <= spread[1]
bearWeakening = bearDominant and spread <= spread[1]

if bullArmed
    if bullWeakening
        bullPullbackSeen := true
        bullPullbackCount += 1
    else if bullPullbackSeen and spread > spread[1]
        bullPullbackCount := bullPullbackCount
    else
        bullPullbackCount := bullPullbackCount

if bearArmed
    if bearWeakening
        bearPullbackSeen := true
        bearPullbackCount += 1
    else if bearPullbackSeen and spread > spread[1]
        bearPullbackCount := bearPullbackCount
    else
        bearPullbackCount := bearPullbackCount

bullReEntryReady =
     bullArmed and
     bullPullbackSeen and
     bullPullbackCount <= pullbackBarsMax and
     bullExpansion and
     spread > spread[1]

bearReEntryReady =
     bearArmed and
     bearPullbackSeen and
     bearPullbackCount <= pullbackBarsMax and
     bearExpansion and
     spread > spread[1]

bullDirectImpulse =
     bullArmed and
     not bullPullbackSeen and
     bullExpansion and
     ta.barssince(bullRegimeStart) <= 1

bearDirectImpulse =
     bearArmed and
     not bearPullbackSeen and
     bearExpansion and
     ta.barssince(bearRegimeStart) <= 1

rawLongSignal  = bullReEntryReady or bullDirectImpulse
rawShortSignal = bearReEntryReady or bearDirectImpulse

if rawLongSignal
    bullArmed := false

if rawShortSignal
    bearArmed := false


// ── SEQUENCE STATE MACHINE ─────────────────────────────────────
rawLongExit  = ta.crossunder(VIP, VIM)
rawShortExit = ta.crossover(VIP, VIM)

var bool inLongSequence = false
var bool inShortSequence = false

longEntrySignal  = false
longExitSignal   = false
shortEntrySignal = false
shortExitSignal  = false

if strategySide == "Long"
    longEntrySignal := rawLongSignal and not inLongSequence
    longExitSignal  := rawLongExit and inLongSequence

    if longEntrySignal
        inLongSequence := true
    if longExitSignal
        inLongSequence := false

    inShortSequence := false

if strategySide == "Short"
    shortEntrySignal := rawShortSignal and not inShortSequence
    shortExitSignal  := rawShortExit and inShortSequence

    if shortEntrySignal
        inShortSequence := true
    if shortExitSignal
        inShortSequence := false

    inLongSequence := false


// ── OVERLAY SIGNAL MARKERS ─────────────────────────────────────
plotshape(showSignals and longEntrySignal,  title="Long Entry",  text="L", style=shape.labelup,   location=location.belowbar, color=bullColor, textcolor=color.white, size=size.tiny, force_overlay=true)
plotshape(showSignals and longExitSignal,   title="Long Exit",   text="X", style=shape.labeldown, location=location.abovebar, color=bearColor, textcolor=color.white, size=size.tiny, force_overlay=true)
plotshape(showSignals and shortEntrySignal, title="Short Entry", text="S", style=shape.labeldown, location=location.abovebar, color=bearColor, textcolor=color.white, size=size.tiny, force_overlay=true)
plotshape(showSignals and shortExitSignal,  title="Short Exit",  text="X", style=shape.labelup,   location=location.belowbar, color=bullColor, textcolor=color.white, size=size.tiny, force_overlay=true)

// ── PLOTS ──────────────────────────────────────────────────────
vipPlot = plot(VIP, title="VI +", color=bullColor, linewidth=lineWidth)
vimPlot = plot(VIM, title="VI -", color=bearColor, linewidth=lineWidth)
spreadBasePlot = plot(showFill ? spreadMA : na, title="Spread Baseline", color=color.new(chart.fg_color, 65), linewidth=1)

fill(vipPlot, vimPlot, showFill ? fillColor : na, title="Dominance Fill")
plot(showMidline ? 1.0 : na, title="Midline 1.0", color=color.new(chart.fg_color, 70), linewidth=1)

plot(showSignalPoints and longEntrySignal ? VIP : na, title="Long Entry Point", color=bullColor, linewidth=3, style=plot.style_circles)
plot(showSignalPoints and longExitSignal ? VIM : na, title="Long Exit Point", color=bearColor, linewidth=3, style=plot.style_circles)
plot(showSignalPoints and shortEntrySignal ? VIM : na, title="Short Entry Point", color=bearColor, linewidth=3, style=plot.style_circles)
plot(showSignalPoints and shortExitSignal ? VIP : na, title="Short Exit Point", color=bullColor, linewidth=3, style=plot.style_circles)


// ── DASHBOARD ─────────────────────────────────────────────────
seqState = strategySide == "Long"
     ? (inLongSequence ? "Long Active" : "Flat / Ready LONG")
     : (inShortSequence ? "Short Active" : "Flat / Ready SHORT")

setupState =
     strategySide == "Long"
     ? (bullArmed ? bullPullbackSeen ? "Bull Pullback" : "Bull Setup" : "Idle")
     : (bearArmed ? bearPullbackSeen ? "Bear Pullback" : "Bear Setup" : "Idle")

var table dash = table.new(dashPos, 2, 7, border_width=1)

if barstate.isfirst
    dash := table.new(dashPos, 2, 7, border_width=1)

if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "State", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 0, state, text_color=dominantColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 1, "Mode", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 1, strategySide, text_color=chart.fg_color, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 2, "Sequence", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 2, seqState, text_color=chart.fg_color, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 3, "Setup", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 3, setupState, text_color=chart.fg_color, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 4, "VI Spread", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 4, str.tostring(spread, "#.000"), text_color=dominantColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 5, "Slope", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 5, slopeState, text_color=spread > spread[1] ? color.lime : spread < spread[1] ? bearColor : neutralColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 6, "Bias", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 6, bias, text_color=dominantColor, text_halign=text.align_center, text_size=dashTextSize)

if barstate.islast and not showDashboard
    table.clear(dash, 0, 0, 1, 6)
````
