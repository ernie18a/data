<!-- tradingview-pine-id: PUB;5c5c6b1791784da98b36684f6501c87b -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Institutional Inducement Engine [algotim]

Source: https://www.tradingview.com/script/PmB3ihNU-Institutional-Inducement-Engine-algotim/

## Description

Overview
Institutional Inducement Engine is a market-structure analysis tool built around a specific sequence: identify a major swing level, locate a smaller swing positioned between current price and that major level, require structural confirmation, and then monitor the confirmed level for a subsequent liquidity interaction.

The purpose of this workflow is to distinguish a potentially meaningful internal liquidity level from an ordinary minor swing. Instead of treating every internal pivot as an inducement, the script maintains a candidate state and only promotes that candidate after the required structural condition has occurred.

The resulting chart shows the relationship between external liquidity, confirmed internal inducement levels, subsequent sweeps, and the opposing external liquidity level.

Problem Statement
A conventional swing-point indicator treats major and minor pivots largely as the same type of information. This can make it difficult to distinguish a meaningful internal level from ordinary market noise.

This script uses two different structural scales:

* External swings represent the larger liquidity reference.
* Internal swings represent smaller candidate levels.
* The distance between them is optionally evaluated relative to ATR.
* A candidate can remain pending until a subsequent structure break confirms it.

This creates a sequential workflow rather than simply plotting every detected pivot.

Methodology

1. External Structure

The script detects major swing highs and lows using a configurable external pivot length.

A confirmed external high becomes the current bearish-side liquidity reference, while a confirmed external low becomes the current bullish-side liquidity reference.

Only the most recently detected external levels are maintained as the active structural references.

2. Internal Candidate Detection

A separate, shorter pivot length is used to detect internal highs and lows.

For a bullish inducement candidate, the internal low must be above the most recent external low.

For a bearish inducement candidate, the internal high must be below the most recent external high.

The separation between the internal candidate and its corresponding external level can also be filtered using ATR. With the ATR filter enabled, the minimum separation is:

Distance >= ATR x Minimum Distance Multiplier

This prevents very small differences between internal and external pivots from automatically qualifying as separate structural levels.

3. Pending Candidate State

A qualifying internal pivot is not immediately treated as a confirmed inducement.

Instead, the script stores its price and bar position as a pending candidate.

This distinction is important because the indicator is evaluating a sequence rather than a single candle or pivot:

Internal swing -> candidate -> structural confirmation -> confirmed inducement.

4. Break of Structure Confirmation

When BOS confirmation is enabled, the script looks for an internal structure point formed after the candidate.

For a bullish candidate, a subsequent internal high is tracked and a close crossing above that level confirms the bullish inducement.

For a bearish candidate, a subsequent internal low is tracked and a close crossing below that level confirms the bearish inducement.

Once confirmed, the pending candidate is transferred into the confirmed inducement state.

This prevents the initial internal pivot from being presented as a completed signal before the required structural sequence has occurred.

5. Inducement Zone

After confirmation, the inducement price is converted into a chart zone.

The zone height is derived from ATR rather than using a fixed number of ticks, allowing its visual size to scale with the instrument's current volatility.

The zone is then extended for the user-defined number of bars.

6. Liquidity Sweep Tracking

The script separately monitors the active external levels and confirmed inducement levels for price sweeps.

An external low is considered swept when price trades below that level and subsequently closes back above it.

An external high is considered swept when price trades above that level and subsequently closes back below it.

Confirmed inducement levels are also monitored. Once price trades through a confirmed inducement level, its sweep state is recorded so the same level is not repeatedly reported as a new sweep.

7. Liquidity Path Projection
After an inducement is confirmed, the script can draw a visual path from that inducement toward the opposing external liquidity reference.

For a confirmed bullish inducement, the path is drawn toward the current external high.

For a confirmed bearish inducement, the path is drawn toward the current external low.

This line is a structural visualization of the relationship between the two detected liquidity references. It is not a forecast or guarantee that price will reach the projected level.

Signal Workflow

The complete workflow is:
1. Detect a major external swing high or low.
2. Store that swing as the current external liquidity reference.
3. Detect smaller internal swings.
4. Test whether the internal swing is positioned between price structure and the corresponding external level.
5. Apply the optional ATR separation filter.
6. Store a qualifying internal swing as a pending candidate.
7. Identify a subsequent internal structure point.
8. Wait for the required break of that structure.
9. Promote the pending candidate to a confirmed inducement.
10. Draw the inducement zone.
11. Monitor the confirmed inducement and external liquidity for sweeps.
12. Optionally project the structural path toward the opposing external liquidity level.

This sequence is the central analytical framework of the indicator.

Why This Indicator Is Different
A standard pivot indicator answers a relatively simple question: "Where are the recent swing highs and lows?"
This script attempts to answer a different question: "Which smaller swing has a defined structural relationship with a larger liquidity reference, and has that relationship subsequently received structural confirmation?"
The distinction comes from the interaction of the components rather than from simply placing several indicators on the same chart.

The external and internal pivot systems operate at different structural scales. The ATR filter controls the minimum separation between those scales. The pending-state mechanism then prevents a candidate from becoming a confirmed inducement until the required structural event occurs.

After confirmation, the same state is carried forward into the sweep-tracking and opposing-liquidity visualization stages.

Consequently, the output represents a sequence of structural conditions rather than an independent collection of pivot, ATR and sweep markers.

Inputs
Structure
**External Swing Length**
Controls the pivot length used for major external swing detection.

**Internal Swing Length**
Controls the shorter pivot length used for internal candidate detection.

Filters

**Enable ATR Noise Filter**
Enables or disables volatility-adjusted separation between internal and external swings.

**ATR Length**
Controls the ATR calculation used by the distance filter and inducement-zone sizing.

**Min Distance (x ATR)**
Sets the minimum separation between the internal candidate and corresponding external level when the ATR filter is enabled.

**Require BOS Confirmation**
When enabled, an internal candidate must receive the specified structural break before becoming a confirmed inducement.

Visuals
The visual settings control whether external liquidity, inducement zones, sweep markers, path projections and liquidity targets are displayed.

**Path Projection Length** controls how far the projected structural path is drawn.

Style
Colors can be customized independently for bullish-side liquidity, bearish-side liquidity, bullish inducement zones, bearish inducement zones and projected paths.

Alerts

The script can generate alerts for:
* New bullish inducement
* New bearish inducement
* Bullish liquidity sweep
* Bearish liquidity sweep
* BOS confirmation events

These alerts correspond to state transitions in the detection workflow rather than simply alerting whenever an ordinary pivot appears.

Practical Usage
Use the external liquidity levels as the larger structural references and the inducement zones as secondary internal levels.
A typical workflow is to first identify the active external liquidity on the chart, then observe whether an appropriately separated internal swing forms. With BOS confirmation enabled, wait for the subsequent structural break before treating the candidate as confirmed.

After confirmation, monitor the inducement and external liquidity levels for subsequent sweeps.

The projected liquidity path should be interpreted as a visual representation of the detected structural relationship, not as a prediction of future price movement.

The indicator can therefore be used as a framework for studying how internal and external swing structures interact across different instruments and timeframes.

Limitations
The script uses confirmed pivot calculations. A pivot is only known after the required bars to the right have formed, so newly detected structure is inherently delayed by the selected pivot lengths.

Increasing the external or internal swing lengths will generally reduce the number of detected swings while making the structural definitions more selective. Smaller values can produce more candidates and more noise.

ATR filtering adapts the minimum separation to recent volatility, but it does not determine whether a particular market-structure interpretation is correct.

Liquidity sweeps are identified from the price relationship with detected levels. A sweep does not guarantee a reversal or continuation.

Projected liquidity paths are visual aids based on the currently detected opposing external level. They should not be interpreted as future-price forecasts.

The indicator is an analytical tool and should not be treated as a standalone trading system or a guarantee of market behavior.

Notes
The terms "liquidity", "inducement", "sweep" and "break of structure" describe the structural definitions implemented by this script. Different traders and methodologies may define these concepts differently.
For reproducibility, the most important settings are the external swing length, internal swing length, ATR separation threshold and BOS confirmation setting.
Signals and structural markings should be evaluated together with the underlying price action and the characteristics of the instrument and timeframe being analyzed.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © algotim

//@version=6
indicator("Institutional Inducement Engine [algotim]", shorttitle="IIE [algotim]", overlay=true, max_bars_back=500, max_lines_count=200, max_labels_count=200, max_boxes_count=100)

// ---------------------------------------------------------------------------
// INPUTS
// ---------------------------------------------------------------------------
grpStruct = "Structure"
swingLenExt = input.int(15, "External Swing Length", minval=2, group=grpStruct, tooltip="Lookback used to detect major liquidity pools (external highs/lows).")
swingLenInt = input.int(5, "Internal Swing Length", minval=1, group=grpStruct, tooltip="Lookback used to detect minor swings (potential inducement points).")

grpFilter = "Filters"
useAtrFilter = input.bool(true, "Enable ATR Noise Filter", group=grpFilter)
atrLen = input.int(14, "ATR Length", minval=1, group=grpFilter)
minAtrMult = input.float(0.25, "Min Distance (x ATR)", minval=0.0, step=0.05, group=grpFilter, tooltip="Minimum distance between internal and external swing, expressed in ATR multiples, for the internal swing to qualify as inducement.")
requireBOS = input.bool(true, "Require BOS Confirmation", group=grpFilter, tooltip="Only mark a swing as inducement once price breaks structure in the expected direction.")

grpVisual = "Visuals"
showExternal = input.bool(true, "Show External Liquidity", group=grpVisual)
showInducement = input.bool(true, "Show Inducement Zones", group=grpVisual)
showSweeps = input.bool(true, "Show Sweep Markers", group=grpVisual)
showPaths = input.bool(true, "Show Liquidity Path Projection", group=grpVisual)
showTargets = input.bool(true, "Show Liquidity Targets", group=grpVisual)
extendBars = input.int(30, "Path Projection Length (bars)", minval=5, maxval=200, group=grpVisual)

grpColor = "Style"
colBullishSide = input.color(color.new(#2962FF, 0), "Bullish-Side Liquidity (External Low)", group=grpColor)
colBearishSide = input.color(color.new(#FF9800, 0), "Bearish-Side Liquidity (External High)", group=grpColor)
colBullInd = input.color(color.new(#26A69A, 70), "Bullish Inducement Zone", group=grpColor)
colBearInd = input.color(color.new(#9C27B0, 70), "Bearish Inducement Zone", group=grpColor)
colPath = input.color(color.new(#787B86, 30), "Liquidity Path", group=grpColor)

// ---------------------------------------------------------------------------
// CORE CALCULATIONS
// ---------------------------------------------------------------------------
atrVal = ta.atr(atrLen)

// External (major) swing points — define liquidity pools
extHigh = ta.pivothigh(high, swingLenExt, swingLenExt)
extLow  = ta.pivotlow(low, swingLenExt, swingLenExt)

// Internal (minor) swing points — candidate inducement
intHigh = ta.pivothigh(high, swingLenInt, swingLenInt)
intLow  = ta.pivotlow(low, swingLenInt, swingLenInt)

// Persistent state for most recent external liquidity levels
var float lastExtHighPrice = na
var int   lastExtHighBar   = na
var float lastExtLowPrice  = na
var int   lastExtLowBar    = na

if not na(extHigh)
    lastExtHighPrice := extHigh
    lastExtHighBar   := bar_index - swingLenExt
if not na(extLow)
    lastExtLowPrice := extLow
    lastExtLowBar   := bar_index - swingLenExt

// Track most recent external liquidity sweep state (so we don't re-trigger on same level)
var bool extHighSwept = false
var bool extLowSwept  = false

// Persistent state for candidate internal swings awaiting BOS confirmation
var float pendingBullIndPrice = na   // internal low candidate (bullish inducement)
var int   pendingBullIndBar   = na
var float pendingBearIndPrice = na   // internal high candidate (bearish inducement)
var int   pendingBearIndBar   = na

// Confirmed inducement state (for path projection / sweep tracking)
var float confBullIndPrice = na
var int   confBullIndBar   = na
var bool  confBullSwept    = false

var float confBearIndPrice = na
var int   confBearIndBar   = na
var bool  confBearSwept    = false

// ---------------------------------------------------------------------------
// EXTERNAL LIQUIDITY DRAWING (Bullish-side / Bearish-side pools)
// ---------------------------------------------------------------------------
var line extHighLine = na
var line extLowLine  = na
var label extHighLabel = na
var label extLowLabel  = na

if showExternal and not na(extHigh)
    if not na(extHighLine)
        line.delete(extHighLine)
    if not na(extHighLabel)
        label.delete(extHighLabel)
    extHighLine := line.new(lastExtHighBar, lastExtHighPrice, bar_index, lastExtHighPrice, color=colBearishSide, style=line.style_dashed, width=1, extend=extend.right)
    extHighLabel := label.new(bar_index, lastExtHighPrice, "Bearish-Side Liquidity", style=label.style_label_down, color=color.new(colBearishSide, 85), textcolor=colBearishSide, size=size.small)
    extHighSwept := false

if showExternal and not na(extLow)
    if not na(extLowLine)
        line.delete(extLowLine)
    if not na(extLowLabel)
        label.delete(extLowLabel)
    extLowLine := line.new(lastExtLowBar, lastExtLowPrice, bar_index, lastExtLowPrice, color=colBullishSide, style=line.style_dashed, width=1, extend=extend.right)
    extLowLabel := label.new(bar_index, lastExtLowPrice, "Bullish-Side Liquidity", style=label.style_label_up, color=color.new(colBullishSide, 85), textcolor=colBullishSide, size=size.small)
    extLowSwept := false

// ---------------------------------------------------------------------------
// INTERNAL SWING CANDIDATE REGISTRATION
// ---------------------------------------------------------------------------
// A bullish inducement candidate is an internal LOW that forms ABOVE the
// most recent external low (i.e., it sits between current price action and
// the deeper external liquidity pool). It represents a shallow low that can
// attract sell-stop liquidity before price reverses toward the external low
// — OR price uses it as a launch pad toward bearish-side liquidity (external high).
if not na(intLow) and not na(lastExtLowPrice)
    candPrice = intLow
    candBar   = bar_index - swingLenInt
    distOk = useAtrFilter ? (candPrice - lastExtLowPrice) >= minAtrMult * atrVal : candPrice > lastExtLowPrice
    if candPrice > lastExtLowPrice and distOk
        pendingBullIndPrice := candPrice
        pendingBullIndBar   := candBar

// A bearish inducement candidate is an internal HIGH that forms BELOW the
// most recent external high.
if not na(intHigh) and not na(lastExtHighPrice)
    candPrice = intHigh
    candBar   = bar_index - swingLenInt
    distOk = useAtrFilter ? (lastExtHighPrice - candPrice) >= minAtrMult * atrVal : candPrice < lastExtHighPrice
    if candPrice < lastExtHighPrice and distOk
        pendingBearIndPrice := candPrice
        pendingBearIndBar   := candBar

// ---------------------------------------------------------------------------
// BOS CONFIRMATION
// ---------------------------------------------------------------------------
// Bullish BOS: close breaks above the most recent internal swing high formed
// AFTER the pending bullish inducement low -> confirms inducement.
// We approximate "internal swing high after candidate" using intHigh updates
// that occur on bars after the candidate bar.
var float lastIntHighAfterBullCand = na
var float lastIntLowAfterBearCand  = na

if not na(intHigh)
    if not na(pendingBullIndBar) and (bar_index - swingLenInt) > pendingBullIndBar
        lastIntHighAfterBullCand := intHigh

if not na(intLow)
    if not na(pendingBearIndBar) and (bar_index - swingLenInt) > pendingBearIndBar
        lastIntLowAfterBearCand := intLow

bullBOS = requireBOS ? (not na(lastIntHighAfterBullCand) and ta.crossover(close, lastIntHighAfterBullCand)) : (not na(pendingBullIndPrice) and ta.crossunder(low, pendingBullIndPrice) == false and close > open)
bearBOS = requireBOS ? (not na(lastIntLowAfterBearCand) and ta.crossunder(close, lastIntLowAfterBearCand)) : (not na(pendingBearIndPrice) and ta.crossover(high, pendingBearIndPrice) == false and close < open)

// Simplified, robust BOS when requireBOS is false: any close beyond candidate's
// originating swing in the trend direction confirms it quickly.
if not requireBOS
    if not na(pendingBullIndPrice) and close > pendingBullIndPrice and bar_index > pendingBullIndBar
        bullBOS := true
    if not na(pendingBearIndPrice) and close < pendingBearIndPrice and bar_index > pendingBearIndBar
        bearBOS := true

newBullInducement = false
newBearInducement = false

if bullBOS and not na(pendingBullIndPrice)
    confBullIndPrice := pendingBullIndPrice
    confBullIndBar   := pendingBullIndBar
    confBullSwept    := false
    pendingBullIndPrice := na
    pendingBullIndBar   := na
    newBullInducement := true

if bearBOS and not na(pendingBearIndPrice)
    confBearIndPrice := pendingBearIndPrice
    confBearIndBar   := pendingBearIndBar
    confBearSwept    := false
    pendingBearIndPrice := na
    pendingBearIndBar   := na
    newBearInducement := true

// ---------------------------------------------------------------------------
// INDUCEMENT ZONE DRAWING
// ---------------------------------------------------------------------------
var box bullIndBox = na
var box bearIndBox = na

if showInducement and newBullInducement
    if not na(bullIndBox)
        box.delete(bullIndBox)
    zoneHeight = atrVal * 0.15
    bullIndBox := box.new(confBullIndBar, confBullIndPrice + zoneHeight, bar_index + extendBars, confBullIndPrice - zoneHeight, border_color=color.new(colBullInd, 30), bgcolor=colBullInd, extend=extend.none)
    label.new(confBullIndBar, confBullIndPrice - zoneHeight, "Bullish IDM", style=label.style_label_up, color=color.new(colBullInd, 60), textcolor=color.new(colBullInd, 0), size=size.small)

if showInducement and newBearInducement
    if not na(bearIndBox)
        box.delete(bearIndBox)
    zoneHeight = atrVal * 0.15
    bearIndBox := box.new(confBearIndBar, confBearIndPrice + zoneHeight, bar_index + extendBars, confBearIndPrice - zoneHeight, border_color=color.new(colBearInd, 30), bgcolor=colBearInd, extend=extend.none)
    label.new(confBearIndBar, confBearIndPrice + zoneHeight, "Bearish IDM", style=label.style_label_down, color=color.new(colBearInd, 60), textcolor=color.new(colBearInd, 0), size=size.small)

// ---------------------------------------------------------------------------
// UNIQUE FEATURE: LIQUIDITY PATH PROJECTION
// Draws a dotted line from the confirmed inducement to the expected
// liquidity target (the opposing external liquidity pool), visualizing the
// roadmap of where price may be engineered toward.
// ---------------------------------------------------------------------------
var line bullPathLine = na
var label bullTargetLabel = na
var line bearPathLine = na
var label bearTargetLabel = na

if showPaths and newBullInducement and not na(lastExtHighPrice)
    if not na(bullPathLine)
        line.delete(bullPathLine)
    if not na(bullTargetLabel)
        label.delete(bullTargetLabel)
    bullPathLine := line.new(confBullIndBar, confBullIndPrice, bar_index + extendBars, lastExtHighPrice, color=colPath, style=line.style_dotted, width=1)
    if showTargets
        bullTargetLabel := label.new(bar_index + extendBars, lastExtHighPrice, "Liquidity Target", style=label.style_label_left, color=color.new(colBearishSide, 85), textcolor=colBearishSide, size=size.small)

if showPaths and newBearInducement and not na(lastExtLowPrice)
    if not na(bearPathLine)
        line.delete(bearPathLine)
    if not na(bearTargetLabel)
        label.delete(bearTargetLabel)
    bearPathLine := line.new(confBearIndBar, confBearIndPrice, bar_index + extendBars, lastExtLowPrice, color=colPath, style=line.style_dotted, width=1)
    if showTargets
        bearTargetLabel := label.new(bar_index + extendBars, lastExtLowPrice, "Liquidity Target", style=label.style_label_left, color=color.new(colBullishSide, 85), textcolor=colBullishSide, size=size.small)

// ---------------------------------------------------------------------------
// SWEEP DETECTION (minimal markers)
// ---------------------------------------------------------------------------
bullishSweep = false
bearishSweep = false

// External liquidity sweeps
if showExternal and not na(lastExtLowPrice) and not extLowSwept
    if low < lastExtLowPrice and close > lastExtLowPrice
        extLowSwept := true
        bullishSweep := true

if showExternal and not na(lastExtHighPrice) and not extHighSwept
    if high > lastExtHighPrice and close < lastExtHighPrice
        extHighSwept := true
        bearishSweep := true

// Inducement sweeps (price returns to grab the inducement liquidity)
if not na(confBullIndPrice) and not confBullSwept
    if low < confBullIndPrice
        confBullSwept := true
        bearishSweep := true  // sweeping a bullish inducement is bearish liquidity grab

if not na(confBearIndPrice) and not confBearSwept
    if high > confBearIndPrice
        confBearSwept := true
        bullishSweep := true  // sweeping a bearish inducement is bullish liquidity grab

if showSweeps and bullishSweep
    label.new(bar_index, low - atrVal * 0.3, "✓", style=label.style_label_up, color=color.new(colBullishSide, 100), textcolor=colBullishSide, size=size.small)

if showSweeps and bearishSweep
    label.new(bar_index, high + atrVal * 0.3, "✓", style=label.style_label_down, color=color.new(colBearishSide, 100), textcolor=colBearishSide, size=size.small)

// ---------------------------------------------------------------------------
// ALERTS
// ---------------------------------------------------------------------------
alert(newBullInducement ? "Inducement Detector [algotim]: New Bullish Inducement formed at " + str.tostring(confBullIndPrice, format.mintick) : na, alert.freq_once_per_bar)
alert(newBearInducement ? "Inducement Detector [algotim]: New Bearish Inducement formed at " + str.tostring(confBearIndPrice, format.mintick) : na, alert.freq_once_per_bar)
alert(bullishSweep ? "Inducement Detector [algotim]: Bullish Liquidity Sweep detected" : na, alert.freq_once_per_bar)
alert(bearishSweep ? "Inducement Detector [algotim]: Bearish Liquidity Sweep detected" : na, alert.freq_once_per_bar)
alert((newBullInducement or newBearInducement) ? "Inducement Detector [algotim]: BOS Confirmation registered" : na, alert.freq_once_per_bar)
````
