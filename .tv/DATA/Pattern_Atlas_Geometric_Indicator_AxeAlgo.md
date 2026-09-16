<!-- tradingview-pine-id: PUB;6f86ed446d1d4bed97dd52311b68cd83 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Pattern Atlas :  Geometric Indicator [AxeAlgo]

Source: https://www.tradingview.com/script/rTfR2FWV-Pattern-Atlas-Geometric-Indicator-AxeAlgo/

## Description

Pattern Atlas : Geometric Indicator [AxeAlgo]

A chart-native scanner for 16 classical price-structure ("geometric") chart
patterns. It tracks confirmed swing pivots as they form and, when a run of
pivots satisfies the geometry of a known pattern and its breakout condition, it
marks the pattern on the chart with an outline box, an optional construction
skeleton, a measured-move target, and a labelled pin signal. It also keeps a
live status table of every pattern it knows.

All pattern-recognition logic lives in the companion Pine library
"Pattern Atlas : Geometric [AxeAlgo]". This script is the visualization and
alerting layer on top of it, so the detection rules stay in one place that can
be maintained and audited on their own.

Patterns detected

Reversal patterns: Head & Shoulders and its Inverse; Double Top and Double
Bottom; Triple Top and Triple Bottom; Rounding Top and Rounding Bottom; Diamond
Top and Diamond Bottom; Broadening Formation; and the V-Top / V-Bottom spike.

Continuation patterns: Ascending Triangle; Descending Triangle; Symmetrical
Triangle; Rising and Falling Wedge; Bull and Bear Flag; Bull and Bear Pennant;
Rectangle; and Cup & Handle with its Inverted form.

Structural patterns: Island Reversal and Bump-and-Run Reversal.

How it works

First, a rolling list of confirmed swing highs and lows is maintained. The
"Pivot left bars" and "Pivot right bars" inputs set how many bars on each side
of a candidate must be less extreme for it to count as a pivot. Higher values
give fewer, more significant pivots and a longer confirmation lag.

Next, each pattern function inspects the recent pivot sequence for its defining
shape together with the price move that confirms it. For example, Head &
Shoulders looks for three peaks with a lower-shoulder relationship and a close
back through the neckline; an Ascending Triangle looks for a flat resistance
base with a rising support line and a close through the base.

Each match reports its direction (bullish or bearish), the exact pivots it was
built from, a text description, a strength score, and a measured-move price
target.

Strength score

The strength score runs from 0 to 100 percent and measures how decisively price
broke through the pattern's confirmation level, relative to the pattern's own
price range. A higher score means a cleaner, more committed break.

Patterns defined by a single point, such as the Spike and the Island Reversal,
have no internal range to measure against and always score a neutral 50 percent.

The "Minimum pattern strength to show" input filters marginal matches off the
chart and out of the alerts.

Measured-move targets

The target is a classical projection: the pattern's own height added to or
subtracted from the breakout point, shown as a small price label. No ray is
drawn out to it.

Targets are not shown for the Spike, the Island Reversal, or the Bump-and-Run
Reversal, because those patterns have no reliable height to project from.

Repainting

Every box, line, target, and pin is drawn only on a closed bar. Each match is
gated so it appears, and alerts, only once, on the bar it is first confirmed.

Swing pivots are only known a number of bars after they occur, equal to
"Pivot right bars". That confirmation lag is structural to pivot-based analysis,
not repainting. Nothing already drawn is moved or removed on later bars.

What you see on the chart

A box outlines the full pivot span of each match, coloured by direction.

Construction lines draw a zig-zag through the exact pivots that built the
pattern. This is off by default.

Construction points place a small circle on each of those pivots. This is also
off by default.

A target label shows the measured-move price.

A pin signal is a thin stem with a glowing gem at its tip, placed below the bar
for a bullish match and above it for a bearish one. Hovering the gem shows the
full list of matches on that bar with their strength and targets.

The scanner table lists every pattern with a live status column. When a pattern
matches on the current bar the row shows its name and strength percent; when it
does not, the row shows a dash. Hovering any row shows that pattern's
description.

Inputs

Pivot Detection controls the left bars, right bars, and the maximum number of
pivots tracked.

The Reversal, Continuation, and Structural groups each have a master enable
switch plus one checkbox per pattern, so a whole category can be turned off in
one click.

Display controls the boxes, construction lines, construction points, targets,
and pin signals; the minimum strength filter; the table on/off, position, and
text size; and the bullish and bearish colours.

Watermark switches between a Dark and a Light theme.

Alerts

There is one alert condition per pattern, plus an "Any Bullish Chart Pattern"
and an "Any Bearish Chart Pattern" condition.

There is also a single dynamic alert() call that fires once per closed bar with
the full list of patterns found on that bar, along with their strength and
targets. Add it using the "Any alert() function call" option when creating the
alert.

Every alert condition is gated to confirmed bars in the code itself, so none of
them can fire from a still-forming bar regardless of the alert frequency chosen.

Notes

Chart-pattern recognition is inherently approximate. Treat matches as structured
context rather than mechanical trade signals, and confirm them with your own
analysis.

The indicator works best on liquid instruments and on timeframes where swings
are well defined. Very low timeframes produce noisy pivots.

This is not financial advice.

Dependency: Pattern Atlas : Geometric [AxeAlgo], a Pine library.

---

## Source Code

````pine
//@version=6
// Consumes Pattern_Atlas_Geometric — plots signals and fires alerts from its detect*() calls.
// One-time setup: open pattern_geometric.pine in the Pine Editor, Save, then
// Publish script -> Library -> Public. Once published, confirm the version number
// below matches what TradingView shows (bump it after every republish of the library).
indicator("Pattern Atlas :  Geometric Indicator [AxeAlgo]", overlay = true, max_labels_count = 500, max_boxes_count = 500, max_lines_count = 500)
import AxeAlgo/Pattern_Atlas_Geometric/1 as geo

// Bundles the per-bar scan results by direction, same convention as the
// Candlestick library's indicator_candlestick_scanner.pine.
type Collector
    array<string> descBull
    array<string> descBear

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------
// f_sortPivots isn't exported by the library (it's an internal helper there
// too), so it's kept here as well — used only as a defensive re-sort of
// pivotBars/pivotPrices immediately before drawing construction lines, in
// case a future library update ever returns them out of order.
f_sortPivots(_bars, _prices) =>
    _n = array.size(_bars)
    _sb = array.copy(_bars)
    _sp = array.copy(_prices)
    if _n >= 2
        for i = 0 to _n - 2
            for j = 0 to _n - 2 - i
                if array.get(_sb, j) > array.get(_sb, j + 1)
                    _tb = array.get(_sb, j)
                    _tp = array.get(_sp, j)
                    array.set(_sb, j, array.get(_sb, j + 1))
                    array.set(_sp, j, array.get(_sp, j + 1))
                    array.set(_sb, j + 1, _tb)
                    array.set(_sp, j + 1, _tp)
    [_sb, _sp]

// ---------------------------------------------------------------------------
// Inputs
// ---------------------------------------------------------------------------
grpPivots = "Pivot Detection"
pivotLeftBars = input.int(5, "Pivot left bars", minval = 1, group = grpPivots, tooltip = "Bars to the left of a candidate pivot that must be less extreme, for it to confirm. Higher = fewer, more significant pivots.")
pivotRightBars = input.int(5, "Pivot right bars", minval = 1, group = grpPivots, tooltip = "Bars to the right of a candidate pivot that must be less extreme. Also the confirmation lag before a pivot is known.")
maxPivots = input.int(20, "Max pivots tracked", minval = 5, group = grpPivots)

grpReversal = "Reversal Patterns"
grpContinuation = "Continuation Patterns"
grpStructural = "Structural Patterns"
grpDisplay = "Display"

// A master switch per category, above the per-pattern checkboxes, so a whole
// group can be turned off in one click without hunting down each toggle.
enableReversal = input.bool(true, "Enable Reversal Patterns", group = grpReversal)
showHeadAndShoulders_raw = input.bool(true, "Head & Shoulders (+ Inverse)", group = grpReversal)
showDoubleTopBottom_raw = input.bool(true, "Double Top / Bottom", group = grpReversal)
showTripleTopBottom_raw = input.bool(true, "Triple Top / Bottom", group = grpReversal)
showRoundingTopBottom_raw = input.bool(true, "Rounding Top / Bottom", group = grpReversal)
showDiamondTopBottom_raw = input.bool(true, "Diamond Top / Bottom", group = grpReversal)
showBroadeningTopBottom_raw = input.bool(true, "Broadening Formation", group = grpReversal)
showSpike_raw = input.bool(true, "V-Top / V-Bottom (Spike)", group = grpReversal)

enableContinuation = input.bool(true, "Enable Continuation Patterns", group = grpContinuation)
showTriangleAscending_raw = input.bool(true, "Ascending Triangle", group = grpContinuation)
showTriangleDescending_raw = input.bool(true, "Descending Triangle", group = grpContinuation)
showTriangleSymmetrical_raw = input.bool(true, "Symmetrical Triangle", group = grpContinuation)
showWedge_raw = input.bool(true, "Wedge (Rising / Falling)", group = grpContinuation)
showFlag_raw = input.bool(true, "Flag (Bull / Bear)", group = grpContinuation)
showPennant_raw = input.bool(true, "Pennant (Bull / Bear)", group = grpContinuation)
showRectangle_raw = input.bool(true, "Rectangle", group = grpContinuation)
showCupAndHandle_raw = input.bool(true, "Cup & Handle (+ Inverted)", group = grpContinuation)

enableStructural = input.bool(true, "Enable Structural Patterns", group = grpStructural)
showIslandReversal_raw = input.bool(true, "Island Reversal", group = grpStructural)
showBumpAndRun_raw = input.bool(true, "Bump-and-Run Reversal", group = grpStructural)

showBoxes = input.bool(true, "Highlight pattern span with a box", group = grpDisplay)
showLines = input.bool(false, "Show construction lines (pivot-by-pivot)", group = grpDisplay, tooltip = "Zig-zag segments joining the pivots that built the pattern.")
showPoints = input.bool(false, "Show construction points (pivots)", group = grpDisplay, tooltip = "A small circle on each pivot the pattern is built from.")
showTargets = input.bool(true, "Show measured-move price targets", group = grpDisplay, tooltip = "Projects a classical price target by measuring the pattern's own height from the breakout point. Not shown for Spike, Island Reversal or Bump-and-Run, which don't have a reliable height to project from.")
showSignals = input.bool(true, "Show pin signals", group = grpDisplay)
minStrength = input.int(0, "Minimum pattern strength to show (%)", minval = 0, maxval = 100, group = grpDisplay, tooltip = "Filters out marginal matches from the chart and alerts. Strength measures how decisively price broke through the pattern's confirmation level relative to the pattern's own price range. Patterns defined by a single point (Spike, Island Reversal) always score a neutral 50%, since they have no such range to measure against.")
showTable = input.bool(true, "Show pattern scanner table", group = grpDisplay)
tablePosStr = input.string("Top Right", "Table position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpDisplay)
tableSizeStr = input.string("Normal", "Table text size", options = ["Small", "Normal", "Large", "Huge"], group = grpDisplay)
// AxeAlgo Royal Gold & White — classic gold (bullish), pale gold-white (bearish)
bullColor = input.color(color.new(#D4AF37, 0), "Bullish marker color", group = grpDisplay)
bearColor = input.color(color.new(#FFF8E7, 0), "Bearish marker color", group = grpDisplay)

tablePos = tablePosStr == "Top Right" ? position.top_right : tablePosStr == "Top Left" ? position.top_left : tablePosStr == "Bottom Right" ? position.bottom_right : position.bottom_left
catTextSize = tableSizeStr == "Small" ? size.tiny : tableSizeStr == "Normal" ? size.small : tableSizeStr == "Large" ? size.normal : size.large
rowTextSize = tableSizeStr == "Small" ? size.small : tableSizeStr == "Normal" ? size.normal : tableSizeStr == "Large" ? size.large : size.huge
titleTextSize = tableSizeStr == "Small" ? size.normal : tableSizeStr == "Normal" ? size.large : size.huge

// ---------------------------------------------------------------------------
// Detect — trackPivots() once, then one call per library pattern function
// ---------------------------------------------------------------------------
pivots = geo.trackPivots(pivotLeftBars, pivotRightBars, maxPivots)

mHeadAndShoulders = geo.detectHeadAndShoulders(pivots)
mDoubleTopBottom = geo.detectDoubleTopBottom(pivots)
mTripleTopBottom = geo.detectTripleTopBottom(pivots)
mRoundingTopBottom = geo.detectRoundingTopBottom(pivots)
mDiamondTopBottom = geo.detectDiamondTopBottom(pivots)
mBroadeningTopBottom = geo.detectBroadeningTopBottom(pivots)
mSpike = geo.detectSpike()

mTriangleAscending = geo.detectTriangleAscending(pivots)
mTriangleDescending = geo.detectTriangleDescending(pivots)
mTriangleSymmetrical = geo.detectTriangleSymmetrical(pivots)
mWedge = geo.detectWedge(pivots)
mFlag = geo.detectFlag()
mPennant = geo.detectPennant()
mRectangle = geo.detectRectangle(pivots)
mCupAndHandle = geo.detectCupAndHandle(pivots)

mIslandReversal = geo.detectIslandReversal()
mBumpAndRun = geo.detectBumpAndRun(pivots)

// ---------------------------------------------------------------------------
// New-occurrence gate — a match's underlying breakout condition (e.g. "close
// below the neckline") typically stays true for many bars after it first
// fires, so .found alone would re-trigger boxes/lines/targets/pins/alerts on
// every one of those bars. isNewXxx is only true on the bar a pattern flips
// from not-found to found, so a still-valid match only ever shows/alerts
// once, on the bar it was actually confirmed.
// ---------------------------------------------------------------------------
isNewHeadAndShoulders = mHeadAndShoulders.found and (bar_index == 0 or not (mHeadAndShoulders[1]).found)
isNewDoubleTopBottom = mDoubleTopBottom.found and (bar_index == 0 or not (mDoubleTopBottom[1]).found)
isNewTripleTopBottom = mTripleTopBottom.found and (bar_index == 0 or not (mTripleTopBottom[1]).found)
isNewRoundingTopBottom = mRoundingTopBottom.found and (bar_index == 0 or not (mRoundingTopBottom[1]).found)
isNewDiamondTopBottom = mDiamondTopBottom.found and (bar_index == 0 or not (mDiamondTopBottom[1]).found)
isNewBroadeningTopBottom = mBroadeningTopBottom.found and (bar_index == 0 or not (mBroadeningTopBottom[1]).found)
isNewSpike = mSpike.found and (bar_index == 0 or not (mSpike[1]).found)

isNewTriangleAscending = mTriangleAscending.found and (bar_index == 0 or not (mTriangleAscending[1]).found)
isNewTriangleDescending = mTriangleDescending.found and (bar_index == 0 or not (mTriangleDescending[1]).found)
isNewTriangleSymmetrical = mTriangleSymmetrical.found and (bar_index == 0 or not (mTriangleSymmetrical[1]).found)
isNewWedge = mWedge.found and (bar_index == 0 or not (mWedge[1]).found)
isNewFlag = mFlag.found and (bar_index == 0 or not (mFlag[1]).found)
isNewPennant = mPennant.found and (bar_index == 0 or not (mPennant[1]).found)
isNewRectangle = mRectangle.found and (bar_index == 0 or not (mRectangle[1]).found)
isNewCupAndHandle = mCupAndHandle.found and (bar_index == 0 or not (mCupAndHandle[1]).found)

isNewIslandReversal = mIslandReversal.found and (bar_index == 0 or not (mIslandReversal[1]).found)
isNewBumpAndRun = mBumpAndRun.found and (bar_index == 0 or not (mBumpAndRun[1]).found)

// ---------------------------------------------------------------------------
// Strength & targets — delegated to the library's own patternStrength() and
// patternTarget() utility exports rather than reimplemented here, so this
// indicator can never drift out of sync with the library's scoring logic.
// ---------------------------------------------------------------------------
sHeadAndShoulders = geo.patternStrength(mHeadAndShoulders)
sDoubleTopBottom = geo.patternStrength(mDoubleTopBottom)
sTripleTopBottom = geo.patternStrength(mTripleTopBottom)
sRoundingTopBottom = geo.patternStrength(mRoundingTopBottom)
sDiamondTopBottom = geo.patternStrength(mDiamondTopBottom)
sBroadeningTopBottom = geo.patternStrength(mBroadeningTopBottom)
sSpike = geo.patternStrength(mSpike)

sTriangleAscending = geo.patternStrength(mTriangleAscending)
sTriangleDescending = geo.patternStrength(mTriangleDescending)
sTriangleSymmetrical = geo.patternStrength(mTriangleSymmetrical)
sWedge = geo.patternStrength(mWedge)
sFlag = geo.patternStrength(mFlag)
sPennant = geo.patternStrength(mPennant)
sRectangle = geo.patternStrength(mRectangle)
sCupAndHandle = geo.patternStrength(mCupAndHandle)

sIslandReversal = geo.patternStrength(mIslandReversal)
sBumpAndRun = geo.patternStrength(mBumpAndRun)

// Effective per-pattern gate = individual checkbox AND category master
// switch AND meets the minimum strength filter. This is what actually
// drives boxes, construction lines, pins and the pin tooltip text below —
// the scanner table ignores it by design, since the table is meant to be a
// full status board regardless of what's currently shown on the chart.
gHeadAndShoulders = showHeadAndShoulders_raw and enableReversal and sHeadAndShoulders >= minStrength and isNewHeadAndShoulders
gDoubleTopBottom = showDoubleTopBottom_raw and enableReversal and sDoubleTopBottom >= minStrength and isNewDoubleTopBottom
gTripleTopBottom = showTripleTopBottom_raw and enableReversal and sTripleTopBottom >= minStrength and isNewTripleTopBottom
gRoundingTopBottom = showRoundingTopBottom_raw and enableReversal and sRoundingTopBottom >= minStrength and isNewRoundingTopBottom
gDiamondTopBottom = showDiamondTopBottom_raw and enableReversal and sDiamondTopBottom >= minStrength and isNewDiamondTopBottom
gBroadeningTopBottom = showBroadeningTopBottom_raw and enableReversal and sBroadeningTopBottom >= minStrength and isNewBroadeningTopBottom
gSpike = showSpike_raw and enableReversal and sSpike >= minStrength and isNewSpike

gTriangleAscending = showTriangleAscending_raw and enableContinuation and sTriangleAscending >= minStrength and isNewTriangleAscending
gTriangleDescending = showTriangleDescending_raw and enableContinuation and sTriangleDescending >= minStrength and isNewTriangleDescending
gTriangleSymmetrical = showTriangleSymmetrical_raw and enableContinuation and sTriangleSymmetrical >= minStrength and isNewTriangleSymmetrical
gWedge = showWedge_raw and enableContinuation and sWedge >= minStrength and isNewWedge
gFlag = showFlag_raw and enableContinuation and sFlag >= minStrength and isNewFlag
gPennant = showPennant_raw and enableContinuation and sPennant >= minStrength and isNewPennant
gRectangle = showRectangle_raw and enableContinuation and sRectangle >= minStrength and isNewRectangle
gCupAndHandle = showCupAndHandle_raw and enableContinuation and sCupAndHandle >= minStrength and isNewCupAndHandle

gIslandReversal = showIslandReversal_raw and enableStructural and sIslandReversal >= minStrength and isNewIslandReversal
gBumpAndRun = showBumpAndRun_raw and enableStructural and sBumpAndRun >= minStrength and isNewBumpAndRun

// ---------------------------------------------------------------------------
// Measured-move price targets — see the "Strength & targets" note above.
// ---------------------------------------------------------------------------
tHeadAndShoulders = geo.patternTarget(mHeadAndShoulders)
tDoubleTopBottom = geo.patternTarget(mDoubleTopBottom)
tTripleTopBottom = geo.patternTarget(mTripleTopBottom)
tRoundingTopBottom = geo.patternTarget(mRoundingTopBottom)
tDiamondTopBottom = geo.patternTarget(mDiamondTopBottom)
tBroadeningTopBottom = geo.patternTarget(mBroadeningTopBottom)
tSpike = geo.patternTarget(mSpike)

tTriangleAscending = geo.patternTarget(mTriangleAscending)
tTriangleDescending = geo.patternTarget(mTriangleDescending)
tTriangleSymmetrical = geo.patternTarget(mTriangleSymmetrical)
tWedge = geo.patternTarget(mWedge)
tFlag = geo.patternTarget(mFlag)
tPennant = geo.patternTarget(mPennant)
tRectangle = geo.patternTarget(mRectangle)
tCupAndHandle = geo.patternTarget(mCupAndHandle)

tIslandReversal = geo.patternTarget(mIslandReversal)
tBumpAndRun = geo.patternTarget(mBumpAndRun)

// ---------------------------------------------------------------------------
// Collect enabled matches by direction — feeds the pin tooltips.
// ---------------------------------------------------------------------------
f_collect(_m, _enabled, _s, _t, _col) =>
    if _m.found and _enabled
        _targetPart = na(_t) ? "" : ", target " + str.tostring(_t, format.mintick)
        _text = _m.description + " [Strength: " + str.tostring(_s, "#") + "%" + _targetPart + "]"
        if _m.direction == "bullish"
            array.push(_col.descBull, _text)
        else
            array.push(_col.descBear, _text)

col = Collector.new(array.new<string>(), array.new<string>())

f_collect(mHeadAndShoulders, gHeadAndShoulders, sHeadAndShoulders, tHeadAndShoulders, col)
f_collect(mDoubleTopBottom, gDoubleTopBottom, sDoubleTopBottom, tDoubleTopBottom, col)
f_collect(mTripleTopBottom, gTripleTopBottom, sTripleTopBottom, tTripleTopBottom, col)
f_collect(mRoundingTopBottom, gRoundingTopBottom, sRoundingTopBottom, tRoundingTopBottom, col)
f_collect(mDiamondTopBottom, gDiamondTopBottom, sDiamondTopBottom, tDiamondTopBottom, col)
f_collect(mBroadeningTopBottom, gBroadeningTopBottom, sBroadeningTopBottom, tBroadeningTopBottom, col)
f_collect(mSpike, gSpike, sSpike, tSpike, col)

f_collect(mTriangleAscending, gTriangleAscending, sTriangleAscending, tTriangleAscending, col)
f_collect(mTriangleDescending, gTriangleDescending, sTriangleDescending, tTriangleDescending, col)
f_collect(mTriangleSymmetrical, gTriangleSymmetrical, sTriangleSymmetrical, tTriangleSymmetrical, col)
f_collect(mWedge, gWedge, sWedge, tWedge, col)
f_collect(mFlag, gFlag, sFlag, tFlag, col)
f_collect(mPennant, gPennant, sPennant, tPennant, col)
f_collect(mRectangle, gRectangle, sRectangle, tRectangle, col)
f_collect(mCupAndHandle, gCupAndHandle, sCupAndHandle, tCupAndHandle, col)

f_collect(mIslandReversal, gIslandReversal, sIslandReversal, tIslandReversal, col)
f_collect(mBumpAndRun, gBumpAndRun, sBumpAndRun, tBumpAndRun, col)

hasBull = array.size(col.descBull) > 0
hasBear = array.size(col.descBear) > 0
bullText = array.join(col.descBull, "\n\n")
bearText = array.join(col.descBear, "\n\n")

// ---------------------------------------------------------------------------
// Pattern boxes — outline the full pivot span of each matched pattern.
// Gated on barstate.isconfirmed so a box is only ever drawn once the bar it
// describes has actually closed — no repaint.
// ---------------------------------------------------------------------------
f_drawBox(_m, _enabled) =>
    if _m.found and _enabled and barstate.isconfirmed
        _startBar = array.min(_m.pivotBars)
        _top = array.max(_m.pivotPrices)
        _bot = array.min(_m.pivotPrices)
        _col = _m.direction == "bullish" ? bullColor : bearColor
        box.new(left = _startBar, top = _top, right = bar_index, bottom = _bot, border_color = color.new(_col, 0), border_width = 1, bgcolor = color.new(_col, 85))

if showBoxes
    f_drawBox(mHeadAndShoulders, gHeadAndShoulders)
    f_drawBox(mDoubleTopBottom, gDoubleTopBottom)
    f_drawBox(mTripleTopBottom, gTripleTopBottom)
    f_drawBox(mRoundingTopBottom, gRoundingTopBottom)
    f_drawBox(mDiamondTopBottom, gDiamondTopBottom)
    f_drawBox(mBroadeningTopBottom, gBroadeningTopBottom)
    f_drawBox(mSpike, gSpike)
    f_drawBox(mTriangleAscending, gTriangleAscending)
    f_drawBox(mTriangleDescending, gTriangleDescending)
    f_drawBox(mTriangleSymmetrical, gTriangleSymmetrical)
    f_drawBox(mWedge, gWedge)
    f_drawBox(mFlag, gFlag)
    f_drawBox(mPennant, gPennant)
    f_drawBox(mRectangle, gRectangle)
    f_drawBox(mCupAndHandle, gCupAndHandle)
    f_drawBox(mIslandReversal, gIslandReversal)
    f_drawBox(mBumpAndRun, gBumpAndRun)

// ---------------------------------------------------------------------------
// Construction lines & points — trace the exact pivots that built the match.
// Lines and points are independent toggles (showLines / showPoints).
// pivotBars/pivotPrices are already chronologically sorted by the library's
// own detect functions, but they're re-sorted here too via the local
// f_sortPivots() defined near the top of this script, as a cheap defensive
// safety net — otherwise a future library update that forgets to sort could
// make the zigzag jump backward in time and look wrong on chart.
// ---------------------------------------------------------------------------
f_drawStructure(_m, _enabled) =>
    if _m.found and _enabled and barstate.isconfirmed
        _col = _m.direction == "bullish" ? bullColor : bearColor
        [_sb, _sp] = f_sortPivots(_m.pivotBars, _m.pivotPrices)
        _n = array.size(_sb)
        if showLines and _n >= 2
            for i = 0 to _n - 2
                line.new(array.get(_sb, i), array.get(_sp, i), array.get(_sb, i + 1), array.get(_sp, i + 1), color = color.new(_col, 15), width = 2)
        if showPoints and _n >= 1
            for i = 0 to _n - 1
                label.new(array.get(_sb, i), array.get(_sp, i), "", style = label.style_circle, color = color.new(_col, 0), size = size.tiny, tooltip = _m.description)

if showLines or showPoints
    f_drawStructure(mHeadAndShoulders, gHeadAndShoulders)
    f_drawStructure(mDoubleTopBottom, gDoubleTopBottom)
    f_drawStructure(mTripleTopBottom, gTripleTopBottom)
    f_drawStructure(mRoundingTopBottom, gRoundingTopBottom)
    f_drawStructure(mDiamondTopBottom, gDiamondTopBottom)
    f_drawStructure(mBroadeningTopBottom, gBroadeningTopBottom)
    f_drawStructure(mSpike, gSpike)
    f_drawStructure(mTriangleAscending, gTriangleAscending)
    f_drawStructure(mTriangleDescending, gTriangleDescending)
    f_drawStructure(mTriangleSymmetrical, gTriangleSymmetrical)
    f_drawStructure(mWedge, gWedge)
    f_drawStructure(mFlag, gFlag)
    f_drawStructure(mPennant, gPennant)
    f_drawStructure(mRectangle, gRectangle)
    f_drawStructure(mCupAndHandle, gCupAndHandle)
    f_drawStructure(mIslandReversal, gIslandReversal)
    f_drawStructure(mBumpAndRun, gBumpAndRun)

// ---------------------------------------------------------------------------
// Measured-move price targets — a small price label at the projected target
// level. No line drawn out to it — the label alone is enough to read the
// number without adding another ray across the chart.
// ---------------------------------------------------------------------------
f_drawTarget(_m, _enabled, _t) =>
    if _m.found and _enabled and not na(_t) and barstate.isconfirmed
        _col = _m.direction == "bullish" ? bullColor : bearColor
        label.new(bar_index, _t, "Target " + str.tostring(_t, format.mintick), style = label.style_label_left, color = color.new(_col, 80), textcolor = color.new(_col, 0), size = size.tiny, tooltip = _m.description)

if showTargets
    f_drawTarget(mHeadAndShoulders, gHeadAndShoulders, tHeadAndShoulders)
    f_drawTarget(mDoubleTopBottom, gDoubleTopBottom, tDoubleTopBottom)
    f_drawTarget(mTripleTopBottom, gTripleTopBottom, tTripleTopBottom)
    f_drawTarget(mRoundingTopBottom, gRoundingTopBottom, tRoundingTopBottom)
    f_drawTarget(mDiamondTopBottom, gDiamondTopBottom, tDiamondTopBottom)
    f_drawTarget(mBroadeningTopBottom, gBroadeningTopBottom, tBroadeningTopBottom)
    f_drawTarget(mSpike, gSpike, tSpike)
    f_drawTarget(mTriangleAscending, gTriangleAscending, tTriangleAscending)
    f_drawTarget(mTriangleDescending, gTriangleDescending, tTriangleDescending)
    f_drawTarget(mTriangleSymmetrical, gTriangleSymmetrical, tTriangleSymmetrical)
    f_drawTarget(mWedge, gWedge, tWedge)
    f_drawTarget(mFlag, gFlag, tFlag)
    f_drawTarget(mPennant, gPennant, tPennant)
    f_drawTarget(mRectangle, gRectangle, tRectangle)
    f_drawTarget(mCupAndHandle, gCupAndHandle, tCupAndHandle)
    f_drawTarget(mIslandReversal, gIslandReversal, tIslandReversal)
    f_drawTarget(mBumpAndRun, gBumpAndRun, tBumpAndRun)

// ---------------------------------------------------------------------------
// Signals — same pin-with-glow treatment as the Candlestick scanner: a thin
// stem anchored to the breakout bar with a glowing gem at its tip, colored
// and offset below/above the bar by direction. Gated on barstate.isconfirmed
// so a signal is only ever drawn once the bar it describes has actually
// closed — no repaint.
// ---------------------------------------------------------------------------
f_glow(_c) =>
    _r = color.r(_c) + (255 - color.r(_c)) * 0.55
    _g = color.g(_c) + (255 - color.g(_c)) * 0.55
    _b = color.b(_c) + (255 - color.b(_c)) * 0.55
    color.rgb(_r, _g, _b, 45)

f_pin(_x, _yAnchor, _yTip, _col, _glow, _tip) =>
    line.new(_x, _yAnchor, _x, _yTip, color = color.new(_col, 35), width = 1)
    label.new(_x, _yTip, "", style = label.style_circle, color = _glow, size = size.small)
    label.new(_x, _yTip, "", style = label.style_circle, color = _col, size = size.tiny, tooltip = _tip)

pinLength = ta.atr(14) * 0.6
bullGlow = f_glow(bullColor)
bearGlow = f_glow(bearColor)

if showSignals and hasBull and barstate.isconfirmed
    f_pin(bar_index, low, low - pinLength, bullColor, bullGlow, bullText)

if showSignals and hasBear and barstate.isconfirmed
    f_pin(bar_index, high, high + pinLength, bearColor, bearGlow, bearText)

// ---------------------------------------------------------------------------
// Scanner table — every pattern the library knows, with a live status column
// for the current bar. Built only on the last bar; intentionally live (not
// isconfirmed-gated) since it's a "what's happening right now" readout.
// ---------------------------------------------------------------------------
f_setRow(_tbl, _row, _label, _m, _s, _t) =>
    _found = _m.found
    _rowColor = _found ? (_m.direction == "bullish" ? bullColor : bearColor) : color.new(#0E171D, 0)
    _nameText = _found ? _m.patternName : _label
    _nameColor = _found ? color.new(#14110B, 0) : color.new(#C9B37E, 0)
    _statusText = _found ? str.tostring(_s, "#") + "%" : "–"
    _statusColor = _found ? color.new(#14110B, 0) : color.new(#7A6423, 0)
    _targetPart = na(_t) ? "" : ", target " + str.tostring(_t, format.mintick)
    _tip = _found ? _m.description + " [Strength: " + str.tostring(_s, "#") + "%" + _targetPart + "]" : "No match on the current bar."
    table.cell(_tbl, 0, _row, _nameText, text_color = _nameColor, bgcolor = color.new(_rowColor, 0), text_size = rowTextSize, text_halign = text.align_left, tooltip = _tip)
    table.cell(_tbl, 1, _row, _statusText, text_color = _statusColor, bgcolor = color.new(_rowColor, 0), text_size = rowTextSize, text_halign = text.align_center, tooltip = _tip)

if showTable and barstate.islast
    tbl = table.new(position = tablePos, columns = 2, rows = 21, bgcolor = color.new(#081013, 0), border_width = 1, border_color = color.new(#B8860B, 75), frame_width = 2, frame_color = color.new(#D4AF37, 0))

    table.cell(tbl, 0, 0, "Pattern Atlas — Geometric", text_color = color.new(#14110B, 0), bgcolor = color.new(#D4AF37, 0), text_size = titleTextSize, text_halign = text.align_center)
    table.merge_cells(tbl, 0, 0, 1, 0)

    table.cell(tbl, 0, 1, "REVERSAL", text_color = color.new(#C9B37E, 0), bgcolor = color.new(#142028, 0), text_size = catTextSize, text_halign = text.align_left)
    table.merge_cells(tbl, 0, 1, 1, 1)
    f_setRow(tbl, 2, "Head & Shoulders (+ Inverse)", mHeadAndShoulders, sHeadAndShoulders, tHeadAndShoulders)
    f_setRow(tbl, 3, "Double Top / Bottom", mDoubleTopBottom, sDoubleTopBottom, tDoubleTopBottom)
    f_setRow(tbl, 4, "Triple Top / Bottom", mTripleTopBottom, sTripleTopBottom, tTripleTopBottom)
    f_setRow(tbl, 5, "Rounding Top / Bottom", mRoundingTopBottom, sRoundingTopBottom, tRoundingTopBottom)
    f_setRow(tbl, 6, "Diamond Top / Bottom", mDiamondTopBottom, sDiamondTopBottom, tDiamondTopBottom)
    f_setRow(tbl, 7, "Broadening Formation", mBroadeningTopBottom, sBroadeningTopBottom, tBroadeningTopBottom)
    f_setRow(tbl, 8, "V-Top / V-Bottom (Spike)", mSpike, sSpike, tSpike)

    table.cell(tbl, 0, 9, "CONTINUATION", text_color = color.new(#C9B37E, 0), bgcolor = color.new(#142028, 0), text_size = catTextSize, text_halign = text.align_left)
    table.merge_cells(tbl, 0, 9, 1, 9)
    f_setRow(tbl, 10, "Ascending Triangle", mTriangleAscending, sTriangleAscending, tTriangleAscending)
    f_setRow(tbl, 11, "Descending Triangle", mTriangleDescending, sTriangleDescending, tTriangleDescending)
    f_setRow(tbl, 12, "Symmetrical Triangle", mTriangleSymmetrical, sTriangleSymmetrical, tTriangleSymmetrical)
    f_setRow(tbl, 13, "Wedge (Rising / Falling)", mWedge, sWedge, tWedge)
    f_setRow(tbl, 14, "Flag (Bull / Bear)", mFlag, sFlag, tFlag)
    f_setRow(tbl, 15, "Pennant (Bull / Bear)", mPennant, sPennant, tPennant)
    f_setRow(tbl, 16, "Rectangle", mRectangle, sRectangle, tRectangle)
    f_setRow(tbl, 17, "Cup & Handle (+ Inverted)", mCupAndHandle, sCupAndHandle, tCupAndHandle)

    table.cell(tbl, 0, 18, "STRUCTURAL", text_color = color.new(#C9B37E, 0), bgcolor = color.new(#142028, 0), text_size = catTextSize, text_halign = text.align_left)
    table.merge_cells(tbl, 0, 18, 1, 18)
    f_setRow(tbl, 19, "Island Reversal", mIslandReversal, sIslandReversal, tIslandReversal)
    f_setRow(tbl, 20, "Bump-and-Run Reversal", mBumpAndRun, sBumpAndRun, tBumpAndRun)

// ───────────────────────── Watermark (Royal gold & cream — matches Fibonacci Confluence Suite [AxeAlgo Pro]) ─────────────────────────
grpWM = "Watermark"
wm_theme = input.string('Dark', 'Watermark Theme', group = grpWM, options = ['Dark', 'Light'])

if barstate.islast
    dark        = wm_theme == 'Dark'
    wm_bg       = dark ? color.new(#14110B, 0) : color.new(#F2EAD3, 0)
    wm_dot_col  = dark ? color.new(#D4AF37, 15) : color.new(#B8860B, 10)
    wm_txt_col  = dark ? color.new(#C9B37E, 0)  : color.new(#7A6423, 0)
    wm_frm_col  = dark ? color.new(#C9A227, 60) : color.new(#B8860B, 60)

    wm = table.new(position.bottom_center, 2, 1,
                   frame_color = wm_frm_col,
                   frame_width = 1,
                   border_width = 0)
    table.cell(wm, 0, 0, ' ◆ ',
               bgcolor = wm_bg,
               text_color = wm_dot_col,
               text_size = size.small,
               text_halign = text.align_center,
               text_valign = text.align_center)
    table.cell(wm, 1, 0, ' A X E A L G O ',
               bgcolor = wm_bg,
               text_color = wm_txt_col,
               text_size = size.small,
               text_halign = text.align_left,
               text_valign = text.align_center)

// ---------------------------------------------------------------------------
// Alerts — one alertcondition per pattern function, plus two combined ones,
// plus one alert() with a full dynamic message. Every condition is gated
// with barstate.isconfirmed in the code itself, not left to the user's
// alert-frequency choice, so none of them can fire off a still-forming bar.
// ---------------------------------------------------------------------------
alertcondition(isNewHeadAndShoulders and barstate.isconfirmed, title = "Head & Shoulders", message = "{{ticker}} {{interval}}: Head & Shoulders (or Inverse)")
alertcondition(isNewDoubleTopBottom and barstate.isconfirmed, title = "Double Top / Bottom", message = "{{ticker}} {{interval}}: Double Top or Bottom")
alertcondition(isNewTripleTopBottom and barstate.isconfirmed, title = "Triple Top / Bottom", message = "{{ticker}} {{interval}}: Triple Top or Bottom")
alertcondition(isNewRoundingTopBottom and barstate.isconfirmed, title = "Rounding Top / Bottom", message = "{{ticker}} {{interval}}: Rounding Top or Bottom")
alertcondition(isNewDiamondTopBottom and barstate.isconfirmed, title = "Diamond Top / Bottom", message = "{{ticker}} {{interval}}: Diamond Top or Bottom")
alertcondition(isNewBroadeningTopBottom and barstate.isconfirmed, title = "Broadening Formation", message = "{{ticker}} {{interval}}: Broadening Formation")
alertcondition(isNewSpike and barstate.isconfirmed, title = "V-Top / V-Bottom (Spike)", message = "{{ticker}} {{interval}}: Spike reversal")

alertcondition(isNewTriangleAscending and barstate.isconfirmed, title = "Ascending Triangle", message = "{{ticker}} {{interval}}: Ascending Triangle")
alertcondition(isNewTriangleDescending and barstate.isconfirmed, title = "Descending Triangle", message = "{{ticker}} {{interval}}: Descending Triangle")
alertcondition(isNewTriangleSymmetrical and barstate.isconfirmed, title = "Symmetrical Triangle", message = "{{ticker}} {{interval}}: Symmetrical Triangle")
alertcondition(isNewWedge and barstate.isconfirmed, title = "Wedge", message = "{{ticker}} {{interval}}: Rising or Falling Wedge")
alertcondition(isNewFlag and barstate.isconfirmed, title = "Flag", message = "{{ticker}} {{interval}}: Bull or Bear Flag")
alertcondition(isNewPennant and barstate.isconfirmed, title = "Pennant", message = "{{ticker}} {{interval}}: Bull or Bear Pennant")
alertcondition(isNewRectangle and barstate.isconfirmed, title = "Rectangle", message = "{{ticker}} {{interval}}: Rectangle")
alertcondition(isNewCupAndHandle and barstate.isconfirmed, title = "Cup & Handle", message = "{{ticker}} {{interval}}: Cup and Handle (or Inverted)")

alertcondition(isNewIslandReversal and barstate.isconfirmed, title = "Island Reversal", message = "{{ticker}} {{interval}}: Island Reversal")
alertcondition(isNewBumpAndRun and barstate.isconfirmed, title = "Bump-and-Run Reversal", message = "{{ticker}} {{interval}}: Bump-and-Run Reversal")

alertcondition(hasBull and barstate.isconfirmed, title = "Any Bullish Chart Pattern", message = "{{ticker}} {{interval}}: Bullish chart pattern")
alertcondition(hasBear and barstate.isconfirmed, title = "Any Bearish Chart Pattern", message = "{{ticker}} {{interval}}: Bearish chart pattern")

if barstate.isconfirmed and (hasBull or hasBear)
    header = "Chart pattern(s) on " + syminfo.ticker + " " + timeframe.period
    bullPart = hasBull ? "\n\nBullish:\n" + bullText : ""
    bearPart = hasBear ? "\n\nBearish:\n" + bearText : ""
    msg = header + bullPart + bearPart
    alert(msg, alert.freq_once_per_bar_close)
````
