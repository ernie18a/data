<!-- tradingview-pine-id: PUB;718c53e3607243c193905949e57ca43c -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Trend Following SuperSmoother - Accumulation Zones [JW]:

Source: https://www.tradingview.com/script/TqSghoTD-Trend-Following-SuperSmoother-Accumulation-Zones-JW/

## Description

Trend Following SuperSmoother - Accumulation Zones

A Pine Script trend following indicator designed to identify systematic accumulation opportunities, profit-taking periods and broader position cycles using a smoothed oscillator framework.

The indicator is intended primarily for long-horizon analysis, with particular emphasis on distinguishing early trend reversals from pullbacks within established positive trends.

---------------------------------------------------------------------------------------------------------------------

Overview

The indicator combines a SuperSmoother-based oscillator and signal line with Bollinger-style oscillator bands and a state-based signal framework.

Rather than treating every oscillator crossover as an independent trading signal, it classifies market conditions into distinct phases:

- Early Reversal Accumulation
- Pullback Accumulation
- Profit-Taking
- Long / Out-of-Market Position Regimes

Signals are evaluated on confirmed candle closes to reduce intrabar noise.

---------------------------------------------------------------------------------------------------------------------

Indicator Components

SuperSmoother Oscillator

The core oscillator is smoothed to reduce short-term market noise while preserving changes in longer-term momentum.

Its colour identifies its current direction:

- Green: oscillator rising
- Red: oscillator falling

A separate signal line provides a slower reference against which changes in oscillator behaviour can be assessed.

Bollinger Bands

Upper and lower bands are calculated around the oscillator framework and are used to identify unusually extended oscillator conditions.

Unlike price Bollinger Bands, these bands operate within the oscillator pane and form part of the logic for identifying potential reversal and pullback setups.

---------------------------------------------------------------------------------------------------------------------

Accumulation Logic

1. Early Reversal

Early-reversal accumulation is designed to identify improving momentum following a sufficiently weak oscillator regime.

The setup begins when the oscillator has moved through the lower Bollinger boundary and subsequently satisfies the required rising/green conditions while remaining in the negative regime.

The exit condition depends on the state of the signal line when the setup occurs:

- If the signal line is below zero, accumulation continues until the signal reaches zero.
- If the signal line is already above zero, accumulation continues until the oscillator crosses the signal line from below.

This distinction prevents an early-reversal zone from remaining active indefinitely when the signal line was already positive at entry.

A large green triangle marks a confirmed early-reversal entry.

2. Pullback Accumulation

Pullback accumulation is intended for corrections occurring within an established positive oscillator regime.

The setup tracks an oscillator that has moved above the upper Bollinger boundary and subsequently falls back through it. Once the required falling/red condition is satisfied, a pullback accumulation period can begin.

This allows the oscillator to turn red either before or after crossing the upper band rather than requiring both events to occur on the same candle.

A smaller dark-green triangle marks the pullback entry.

---------------------------------------------------------------------------------------------------------------------

Profit-Taking

A profit-taking regime can begin when:

- the oscillator is above zero;
- the oscillator turns from rising to falling; and
- no higher-priority accumulation regime is active.

Profit-taking periods are displayed as light-red zones.

A small dark-red circle marks the beginning of a profit-taking phase.

Signal priority is:

Early Reversal > Pullback > Profit-Taking

This state hierarchy prevents accumulation and profit-taking zones from overlapping.

---------------------------------------------------------------------------------------------------------------------

Position-Cycle Signals

The indicator also provides a higher-level representation of the intended long-term position cycle.

Entry

A confirmed early-reversal signal marks the beginning of the primary long regime.

The oscillator pane displays:

- a green vertical entry line; and
- a green zero-axis regime line while the position remains active.

Exit

When the oscillator crosses below zero on a confirmed candle close:

- a large red circle marks the exit;
- a red vertical line identifies the transition; and
- the zero-axis regime changes from green to red.

The red regime continues until the next confirmed early-reversal entry.

This creates a continuous visual distinction between the indicator's long/holding regime and its out-of-market regime.

---------------------------------------------------------------------------------------------------------------------

Visual Signal Guide

[*] Large green triangle -> Early-reversal entry / primary position entry
[*] Small dark-green triangle -> Pullback accumulation
[*] Small dark-red circle -> Profit-taking signal
[*] Large red circle -> Oscillator below zero / primary position exit
[*] Green background -> Accumulation zone
[*] Light-red background -> Profit-taking zone
[*] Green zero-axis regime -> Long / holding period
[*] Red zero-axis regime -> Out-of-market period
[*] Black hollow circles -> Regime change

---------------------------------------------------------------------------------------------------------------------

Design Philosophy

The indicator is designed around a simple idea: trend following does not necessarily require buying only after a trend has already become obvious.

Instead, the framework attempts to separate three useful stages of a longer market cycle:

1. accumulation during an emerging reversal;
2. additional accumulation during pullbacks within a positive trend; and
3. profit-taking as positive momentum begins to deteriorate.

The primary exit remains deliberately slower: a confirmed oscillator move below zero.

This makes the framework more suited to medium- and long-horizon trend participation than short-term trading.

---------------------------------------------------------------------------------------------------------------------

Alerts

Early-reversal and pullback entries are combined into a single TradingView entry alert condition, allowing both accumulation signal types to be monitored using one alert.

Signals are confirmed at candle close.

---------------------------------------------------------------------------------------------------------------------

The indicator can be applied across different securities and timeframes, although its parameters and behaviour should be evaluated for the characteristics of the underlying instrument.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © JeremyW201

//@version=6
indicator("Trend Following SuperSmoother - Accumulation Zones [JW]:", overlay=false, max_lines_count=300)

//=============================================================================
// INPUTS
//=============================================================================

// SuperSmoother
smoothingLength = input.int(5, "Price Smoothing Length", minval=1, group="SuperSmoother")

// Moving Averages
fastLength = input.int(20, "Fast MA", minval=1, group="Moving Averages")
slowLength = input.int(50, "Slow MA", minval=1, group="Moving Averages")
signalLength = input.int(25, "Signal Line Length", minval=1, group="Moving Averages")
src = input.source(close, "Source", group="Moving Averages")

// Direction Logic
directionLength = input.int(
    2,
    "Direction Lookback",
    minval=1,
    group="Direction Logic",
    tooltip="Number of bars used to determine whether oscillator and signal are rising or falling."
)

// Manual Bollinger Bands
bbLength = input.int(20, "BB Volatility Lookback", minval=2, group="Manual Bollinger Bands")
bbSmoothing = input.int(5, "BB Width Smoothing", minval=1, group="Manual Bollinger Bands")
upperBBMultiplier = input.float(1.0, "Upper BB Standard Deviations", minval=0.0, step=0.05, group="Manual Bollinger Bands")
lowerBBMultiplier = input.float(1.0, "Lower BB Standard Deviations", minval=0.0, step=0.05, group="Manual Bollinger Bands")

// Visualisation
showUpperBB = input.bool(true, "Show Upper BB", group="Visualisation")
showLowerBB = input.bool(true, "Show Lower BB", group="Visualisation")
showBackground = input.bool(true, "Highlight Zones", group="Visualisation")

// OFF by default
colourCandles = input.bool(false, "Colour Zone Candles", group="Visualisation")

showHistogram = input.bool(true, "Show Oscillator-Signal Histogram", group="Visualisation")
showEntryMarkers = input.bool(true, "Show Price Entry Markers", group="Visualisation")
showZeroBreakMarker = input.bool(true, "Show Oscillator Below-Zero Marker", group="Visualisation")
showIntersectionMarkers = input.bool(true, "Show Intersection Circles", group="Visualisation")
showProfitTakingMarker = input.bool(true, "Show Profit-Taking Marker", group="Visualisation")
showPositionAxis = input.bool(true, "Show Position Holding Axis", group="Visualisation")
showPositionBoundaries = input.bool(true, "Show Position Entry / Exit Boundaries", group="Visualisation")

//=============================================================================
// HARD-BAKED VISUAL STYLE
//=============================================================================

// Oscillator
oscRisingColour = color.rgb(0, 215, 105)
oscFallingColour = color.rgb(255, 55, 70)
oscFlatColour = color.rgb(225, 190, 30)

// Signal
signalRisingColour = color.rgb(35, 95, 245)
signalFallingColour = color.rgb(245, 145, 20)
signalFlatColour = color.rgb(130, 130, 130)

// Bollinger Bands
bbColour = color.rgb(55, 55, 55)

// Accumulation zones
earlyReversalZoneColour = color.rgb(68, 195, 180)
pullbackZoneColour = color.rgb(110, 185, 100)

// Profit-taking zone
profitTakingZoneColour = color.rgb(245, 120, 120)

// Optional zone candle colours
earlyReversalCandleColour = color.rgb(68, 195, 180)
pullbackCandleColour = color.rgb(75, 170, 85)
profitTakingCandleColour = color.rgb(230, 105, 105)

// Large markers — exact oscillator shades
largeGreenMarkerColour = oscRisingColour
largeRedMarkerColour = oscFallingColour

// Smaller markers — darker shades
smallGreenMarkerColour = color.rgb(0, 150, 72)
smallRedMarkerColour = color.rgb(195, 40, 50)

// Intersection circles
intersectionColour = color.black

// Strategic position colours — exact oscillator shades
positionHeldColour = oscRisingColour
positionOutColour = oscFallingColour

//=============================================================================
// SUPERSMOOTHER
//=============================================================================

supersmoother(source, length) =>
    a1 = math.exp(-1.414 * math.pi / length)
    b1 = 2.0 * a1 * math.cos(1.414 * math.pi / length)
    c2 = b1
    c3 = -a1 * a1
    c1 = 1.0 - c2 - c3
    ss = 0.0
    ss := c1 * (source + nz(source[1])) / 2.0 + c2 * nz(ss[1]) + c3 * nz(ss[2])
    ss

//=============================================================================
// CORE CALCULATIONS
//=============================================================================

smoothedPrice = supersmoother(src, smoothingLength)

fastMA = ta.ema(smoothedPrice, fastLength)
slowMA = ta.ema(smoothedPrice, slowLength)

oscillator = fastMA - slowMA
signalLine = ta.ema(oscillator, signalLength)

spread = oscillator - signalLine

//=============================================================================
// DIRECTION
//=============================================================================

oscillatorSlope = oscillator - oscillator[directionLength]
signalSlope = signalLine - signalLine[directionLength]

oscRising = oscillatorSlope > 0
oscFalling = oscillatorSlope < 0

signalRising = signalSlope > 0
signalFalling = signalSlope < 0

oscFlat = not oscRising and not oscFalling
signalFlat = not signalRising and not signalFalling

// First confirmed falling-state bar
oscTurnsRed = oscFalling and not oscFalling[1]

//=============================================================================
// MANUAL BOLLINGER BANDS
//=============================================================================

rawSpreadStd = ta.stdev(spread, bbLength)
spreadStd = ta.ema(rawSpreadStd, bbSmoothing)

upperBB = signalLine + upperBBMultiplier * spreadStd
lowerBB = signalLine - lowerBBMultiplier * spreadStd

//=============================================================================
// PRECOMPUTED CROSS EVENTS
//=============================================================================

crossBelowZero = ta.crossunder(oscillator, 0)
signalCrossAboveZero = ta.crossover(signalLine, 0)
oscCrossAboveSignal = ta.crossover(oscillator, signalLine)
oscCrossAboveLowerBB = ta.crossover(oscillator, lowerBB)
oscCrossBelowUpperBB = ta.crossunder(oscillator, upperBB)

//=============================================================================
// ZONE STATE
//=============================================================================
//
// zoneMode:
//
// 0 = neutral
// 1 = early-reversal accumulation
// 2 = pullback accumulation
// 3 = profit-taking
//
// Priority:
// Early reversal > Pullback > Profit-taking
//=============================================================================

var int zoneMode = 0

// Early-reversal exit mode:
//
// 0 = none
// 1 = Signal < 0 at entry -> exit when Signal crosses above zero
// 2 = Signal >= 0 at entry -> exit when Oscillator crosses above Signal

var int earlyReversalExitMode = 0

// One-shot setup memory
var bool earlyReversalSawBelowBB = false
var bool pullbackSawAboveBB = false

// Zone events
bool startEarlyReversal = false
bool startPullback = false
bool endEarlyReversal = false
bool endPullback = false
bool startProfitTaking = false
bool endProfitTaking = false

startEarlyReversal := false
startPullback := false
endEarlyReversal := false
endPullback := false
startProfitTaking := false
endProfitTaking := false

//=============================================================================
// STRATEGIC POSITION STATE
//=============================================================================
//
// ENTRY = large early-reversal triangle
// EXIT  = large oscillator-below-zero red circle
//=============================================================================

var bool positionHeld = false

bool positionEntryEvent = false
bool positionExitEvent = false

positionEntryEvent := false
positionExitEvent := false

//=============================================================================
// PRE-TRANSITION HELPERS
//=============================================================================

earlyReversalActiveBefore = zoneMode == 1
pullbackActiveBefore = zoneMode == 2
accumulationActiveBefore = earlyReversalActiveBefore or pullbackActiveBefore

canSearchForEntry = not accumulationActiveBefore

//=============================================================================
// ENTRY-SIDE INTERSECTION EVENTS
//=============================================================================

earlyReversalEntryIntersection = barstate.isconfirmed and earlyReversalSawBelowBB and oscillator < 0 and oscCrossAboveLowerBB

pullbackEntryIntersection = barstate.isconfirmed and pullbackSawAboveBB and oscillator > 0 and oscCrossBelowUpperBB

//=============================================================================
// ONE-SHOT SETUP MEMORY
//=============================================================================

if barstate.isconfirmed

    if canSearchForEntry

        //=====================================================================
        // EARLY REVERSAL
        //=====================================================================

        // Fresh excursion below Lower BB creates one reversal opportunity.

        if oscillator < 0 and oscillator < lowerBB
            earlyReversalSawBelowBB := true

        // Reaching zero before entry invalidates it.

        if oscillator >= 0
            earlyReversalSawBelowBB := false

        //=====================================================================
        // PULLBACK
        //=====================================================================

        // Fresh excursion above Upper BB creates one pullback opportunity.

        if oscillator > 0 and oscillator > upperBB
            pullbackSawAboveBB := true

        // Falling to/below zero before entry invalidates it.

        if oscillator <= 0
            pullbackSawAboveBB := false

    else

        earlyReversalSawBelowBB := false
        pullbackSawAboveBB := false

//=============================================================================
// ENTRY CONDITIONS
//=============================================================================

//-----------------------------------------------------------------------------
// PRIORITY 1 — EARLY REVERSAL
//
// 1. Prior excursion below Lower BB
// 2. Oscillator remains < 0
// 3. Oscillator is now above Lower BB
// 4. Oscillator is green / rising
//-----------------------------------------------------------------------------

earlyReversalEntry = canSearchForEntry and earlyReversalSawBelowBB and oscillator < 0 and oscillator > lowerBB and oscRising

//-----------------------------------------------------------------------------
// PRIORITY 2 — PULLBACK
//
// 1. Prior excursion above Upper BB
// 2. Oscillator remains > 0
// 3. Oscillator is now below Upper BB
// 4. Oscillator is red / falling
//-----------------------------------------------------------------------------

pullbackEntry = canSearchForEntry and pullbackSawAboveBB and oscillator > 0 and oscillator < upperBB and oscFalling

//-----------------------------------------------------------------------------
// PRIORITY 3 — PROFIT-TAKING
//
// Begins only if:
//
// 1. No accumulation zone is active
// 2. No higher-priority accumulation entry occurs this bar
// 3. Oscillator > 0
// 4. Oscillator turns red
//-----------------------------------------------------------------------------

profitTakingEntry = canSearchForEntry and not earlyReversalEntry and not pullbackEntry and oscillator > 0 and oscTurnsRed

//=============================================================================
// ZONE STATE MACHINE
//=============================================================================

if barstate.isconfirmed

    //=========================================================================
    // EARLY REVERSAL ACTIVE
    //=========================================================================

    if zoneMode == 1

        //---------------------------------------------------------------------
        // Type 1:
        // Signal was negative at entry.
        //---------------------------------------------------------------------

        if earlyReversalExitMode == 1 and signalCrossAboveZero

            zoneMode := 0
            earlyReversalExitMode := 0
            endEarlyReversal := true

        //---------------------------------------------------------------------
        // Type 2:
        // Signal was already >= 0 at entry.
        //---------------------------------------------------------------------

        else if earlyReversalExitMode == 2 and oscCrossAboveSignal

            zoneMode := 0
            earlyReversalExitMode := 0
            endEarlyReversal := true

    //=========================================================================
    // PULLBACK ACTIVE
    //=========================================================================

    else if zoneMode == 2

        // Ends when oscillator turns green.
        if oscRising

            zoneMode := 0
            endPullback := true

        // Or oscillator falls below zero first.
        else if oscillator < 0

            zoneMode := 0
            endPullback := true

    //=========================================================================
    // NEUTRAL OR PROFIT-TAKING
    //=========================================================================

    else

        //---------------------------------------------------------------------
        // PRIORITY 1 — EARLY REVERSAL
        //---------------------------------------------------------------------

        if earlyReversalEntry

            if zoneMode == 3
                endProfitTaking := true

            zoneMode := 1
            startEarlyReversal := true

            // Choose exit rule based on Signal regime at entry.

            if signalLine < 0
                earlyReversalExitMode := 1
            else
                earlyReversalExitMode := 2

            earlyReversalSawBelowBB := false
            pullbackSawAboveBB := false

        //---------------------------------------------------------------------
        // PRIORITY 2 — PULLBACK
        //---------------------------------------------------------------------

        else if pullbackEntry

            if zoneMode == 3
                endProfitTaking := true

            zoneMode := 2
            startPullback := true

            earlyReversalExitMode := 0

            pullbackSawAboveBB := false
            earlyReversalSawBelowBB := false

        //---------------------------------------------------------------------
        // EXISTING PROFIT-TAKING
        //---------------------------------------------------------------------

        else if zoneMode == 3

            // Profit-taking ends on strategic zero-cross exit.
            if crossBelowZero

                zoneMode := 0
                endProfitTaking := true

        //---------------------------------------------------------------------
        // PRIORITY 3 — START PROFIT-TAKING
        //---------------------------------------------------------------------

        else if profitTakingEntry

            zoneMode := 3
            startProfitTaking := true

//=============================================================================
// STRATEGIC POSITION STATE MACHINE
//=============================================================================
//
// Large early-reversal triangle -> position ON.
//
// Large red zero-cross circle -> position OFF.
//
// Pullback signals do not change the strategic holding state.
//=============================================================================

if barstate.isconfirmed

    // Strategic exit
    if positionHeld and crossBelowZero

        positionHeld := false
        positionExitEvent := true

    // Strategic entry
    else if not positionHeld and startEarlyReversal

        positionHeld := true
        positionEntryEvent := true

//=============================================================================
// FINAL STATE HELPERS
//=============================================================================

earlyReversalActive = zoneMode == 1
pullbackActive = zoneMode == 2
profitTakingActive = zoneMode == 3

accumulationActive = earlyReversalActive or pullbackActive

startAccumulating = startEarlyReversal or startPullback
endAccumulating = endEarlyReversal or endPullback

confirmedEarlyReversalEntry = startEarlyReversal
confirmedPullbackEntry = startPullback
confirmedProfitTakingEntry = startProfitTaking

confirmedOscBelowZero = crossBelowZero and barstate.isconfirmed

//=============================================================================
// EXIT INTERSECTION EVENTS
//=============================================================================

earlyReversalZeroExit = endEarlyReversal and signalCrossAboveZero

earlyReversalSignalExit = endEarlyReversal and oscCrossAboveSignal

pullbackRecoveryExit = endPullback and oscRising and oscillator >= 0

pullbackZeroExit = endPullback and oscillator < 0

//=============================================================================
// OSCILLATOR COLOUR
//=============================================================================

color oscillatorColour = oscFlatColour

if oscRising
    oscillatorColour := oscRisingColour
else if oscFalling
    oscillatorColour := oscFallingColour
else
    oscillatorColour := oscFlatColour

//=============================================================================
// SIGNAL COLOUR
//=============================================================================

color signalColour = signalFlatColour

if signalRising
    signalColour := signalRisingColour
else if signalFalling
    signalColour := signalFallingColour
else
    signalColour := signalFlatColour

//=============================================================================
// OSCILLATOR
//=============================================================================

plot(
    oscillator,
    title="Oscillator",
    color=oscillatorColour,
    linewidth=2
)

//=============================================================================
// SIGNAL LINE
//=============================================================================

plot(
    signalLine,
    title="Signal Line",
    color=signalColour,
    linewidth=2
)

//=============================================================================
// BOLLINGER BANDS
//=============================================================================
//
// Thin dotted BBs.
//=============================================================================

plot(
    showUpperBB ? upperBB : na,
    title="Upper BB",
    color=bbColour,
    linewidth=1,
    style=plot.style_line,
    linestyle=plot.linestyle_dotted
)

plot(
    showLowerBB ? lowerBB : na,
    title="Lower BB",
    color=bbColour,
    linewidth=1,
    style=plot.style_line,
    linestyle=plot.linestyle_dotted
)

//=============================================================================
// POSITION / ZERO AXIS
//=============================================================================
//
// One dynamic series prevents green/red overlap.
//
// GREEN dashed = strategic position held.
// RED dashed   = strategic position exited.
//
// Width = 1.
//=============================================================================

positionAxisColour = positionHeld ? positionHeldColour : positionOutColour

plot(
    showPositionAxis ? 0 : na,
    title="Strategic Position Axis",
    color=positionAxisColour,
    linewidth=1,
    style=plot.style_line,
    linestyle=plot.linestyle_dashed
)

//=============================================================================
// POSITION ENTRY / EXIT VERTICAL BOUNDARIES
//=============================================================================
//
// Green = large strategic entry triangle.
//
// Red = large strategic exit circle.
//
// extend.both makes the line span the full indicator pane.
//
// Width = 1.
//=============================================================================

var array<line> positionBoundaryLines = array.new<line>()

maxPositionBoundaries = 200

if barstate.isconfirmed and showPositionBoundaries

    //---------------------------------------------------------------------
    // GREEN ENTRY BOUNDARY
    //---------------------------------------------------------------------

    if positionEntryEvent

        entryBoundary = line.new(
            x1=bar_index,
            y1=0,
            x2=bar_index,
            y2=1,
            xloc=xloc.bar_index,
            extend=extend.both,
            color=positionHeldColour,
            style=line.style_solid,
            width=1
        )

        array.push(positionBoundaryLines, entryBoundary)

    //---------------------------------------------------------------------
    // RED EXIT BOUNDARY
    //---------------------------------------------------------------------

    if positionExitEvent

        exitBoundary = line.new(
            x1=bar_index,
            y1=0,
            x2=bar_index,
            y2=1,
            xloc=xloc.bar_index,
            extend=extend.both,
            color=positionOutColour,
            style=line.style_solid,
            width=1
        )

        array.push(positionBoundaryLines, exitBoundary)

    //---------------------------------------------------------------------
    // Object housekeeping
    //---------------------------------------------------------------------

    if array.size(positionBoundaryLines) > maxPositionBoundaries

        oldBoundary = array.shift(positionBoundaryLines)

        line.delete(oldBoundary)

//=============================================================================
// HISTOGRAM
//=============================================================================

color histogramColour = color.gray

if spread >= 0
    histogramColour := oscRisingColour
else
    histogramColour := oscFallingColour

plot(
    showHistogram ? spread : na,
    title="Oscillator-Signal Spread",
    color=color.new(histogramColour, 82),
    style=plot.style_histogram
)

//=============================================================================
// ZONE BACKGROUND
//=============================================================================
//
// Strict priority:
//
// 1. Early reversal
// 2. Pullback
// 3. Profit-taking
//
// Only one zone can therefore appear on any candle.
//=============================================================================

color zoneBackground = na

if showBackground

    if earlyReversalActive
        zoneBackground := color.new(earlyReversalZoneColour, 82)

    else if pullbackActive
        zoneBackground := color.new(pullbackZoneColour, 85)

    else if profitTakingActive
        zoneBackground := color.new(profitTakingZoneColour, 86)

bgcolor(
    zoneBackground,
    title="Trend Following Zone"
)

//=============================================================================
// PRICE CANDLE COLOUR
//=============================================================================
//
// Available as an option, but OFF by default.
//=============================================================================

color zoneCandleColour = na

if colourCandles

    if earlyReversalActive
        zoneCandleColour := earlyReversalCandleColour

    else if pullbackActive
        zoneCandleColour := pullbackCandleColour

    else if profitTakingActive
        zoneCandleColour := profitTakingCandleColour

barcolor(
    zoneCandleColour,
    title="Trend Following Zone Candle Colour"
)

//=============================================================================
// BLACK INTERSECTION CIRCLES
//=============================================================================
//
// Small hollow circles in the oscillator pane.
//=============================================================================

// Early reversal entry intersection
plotchar(
    showIntersectionMarkers and earlyReversalEntryIntersection ? lowerBB : na,
    title="Early Reversal Lower BB Intersection",
    char="○",
    location=location.absolute,
    color=intersectionColour,
    size=size.small
)

// Pullback entry intersection
plotchar(
    showIntersectionMarkers and pullbackEntryIntersection ? upperBB : na,
    title="Pullback Upper BB Intersection",
    char="○",
    location=location.absolute,
    color=intersectionColour,
    size=size.small
)

// Profit-taking start
plotchar(
    showIntersectionMarkers and confirmedProfitTakingEntry ? oscillator : na,
    title="Profit-Taking Start",
    char="○",
    location=location.absolute,
    color=intersectionColour,
    size=size.small
)

// Early reversal Type 1 exit
plotchar(
    showIntersectionMarkers and earlyReversalZeroExit ? 0 : na,
    title="Early Reversal Signal Zero Exit",
    char="○",
    location=location.absolute,
    color=intersectionColour,
    size=size.small
)

// Early reversal Type 2 exit
plotchar(
    showIntersectionMarkers and earlyReversalSignalExit ? signalLine : na,
    title="Early Reversal Oscillator-Signal Exit",
    char="○",
    location=location.absolute,
    color=intersectionColour,
    size=size.small
)

// Pullback recovery exit
plotchar(
    showIntersectionMarkers and pullbackRecoveryExit ? oscillator : na,
    title="Pullback Recovery Exit",
    char="○",
    location=location.absolute,
    color=intersectionColour,
    size=size.small
)

// Pullback zero exit
plotchar(
    showIntersectionMarkers and pullbackZeroExit ? 0 : na,
    title="Pullback Zero Exit",
    char="○",
    location=location.absolute,
    color=intersectionColour,
    size=size.small
)

// Strategic exit / oscillator zero-cross
plotchar(
    showIntersectionMarkers and confirmedOscBelowZero ? 0 : na,
    title="Strategic Exit Zero Cross",
    char="○",
    location=location.absolute,
    color=intersectionColour,
    size=size.small
)

//=============================================================================
// PRICE-CHART SIGNAL MARKERS
//=============================================================================
//
// DRAW ORDER:
//
// 1. Small dark-red Profit-Taking circle
// 2. Small dark-green Pullback triangle
// 3. Large bright-red Strategic Exit circle
// 4. Large bright-green Early-Reversal triangle
//
// Large markers therefore sit above smaller ones.
//
// If large circle and large triangle ever coincide,
// the triangle is rendered last.
//=============================================================================

//-----------------------------------------------------------------------------
// 1. SMALL DARK-RED PROFIT-TAKING CIRCLE
//-----------------------------------------------------------------------------

plotshape(
    showProfitTakingMarker and confirmedProfitTakingEntry,
    title="Start Profit Taking",
    style=shape.circle,
    location=location.abovebar,
    color=smallRedMarkerColour,
    size=size.small,
    force_overlay=true
)

//-----------------------------------------------------------------------------
// 2. SMALL DARK-GREEN PULLBACK TRIANGLE
//-----------------------------------------------------------------------------

plotshape(
    showEntryMarkers and confirmedPullbackEntry,
    title="Pullback Entry",
    style=shape.triangleup,
    location=location.belowbar,
    color=smallGreenMarkerColour,
    size=size.small,
    force_overlay=true
)

//-----------------------------------------------------------------------------
// 3. LARGE BRIGHT-RED STRATEGIC EXIT
//-----------------------------------------------------------------------------

plotshape(
    showZeroBreakMarker and confirmedOscBelowZero,
    title="Oscillator Crossed Below Zero",
    style=shape.circle,
    location=location.abovebar,
    color=largeRedMarkerColour,
    size=size.large,
    force_overlay=true
)

//-----------------------------------------------------------------------------
// 4. LARGE BRIGHT-GREEN EARLY-REVERSAL ENTRY
//-----------------------------------------------------------------------------

plotshape(
    showEntryMarkers and confirmedEarlyReversalEntry,
    title="Early Reversal Entry",
    style=shape.triangleup,
    location=location.belowbar,
    color=largeGreenMarkerColour,
    size=size.large,
    force_overlay=true
)

//=============================================================================
// ALERTS
//=============================================================================

//-----------------------------------------------------------------------------
// SINGLE COMBINED ACCUMULATION ENTRY ALERT
//
// Covers:
// - Early reversal
// - Pullback
//
// Recommended TradingView setting:
// Once Per Bar Close
//-----------------------------------------------------------------------------

alertcondition(
    startAccumulating,
    title="Accumulation Entry",
    message="Trend Following SuperSmoother accumulation entry confirmed on {{ticker}} — {{interval}}"
)

//-----------------------------------------------------------------------------
// PROFIT-TAKING START ALERT
//-----------------------------------------------------------------------------

alertcondition(
    startProfitTaking,
    title="Start Profit Taking",
    message="Trend Following SuperSmoother profit-taking zone started on {{ticker}} — {{interval}}"
)

//-----------------------------------------------------------------------------
// STRATEGIC EXIT / ZERO-CROSS ALERT
//-----------------------------------------------------------------------------

alertcondition(
    confirmedOscBelowZero,
    title="Oscillator Below Zero",
    message="Trend Following SuperSmoother oscillator crossed below zero on {{ticker}} — {{interval}}"
)

//-----------------------------------------------------------------------------
// ACCUMULATION-END ALERT
//-----------------------------------------------------------------------------

alertcondition(
    endAccumulating,
    title="End Accumulating",
    message="Trend Following SuperSmoother accumulation zone ended on {{ticker}} — {{interval}}"
)
````
