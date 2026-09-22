<!-- tradingview-pine-id: PUB;29918b10884e4e26ad1e291b979067fe -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Breakout Retest Signals [algotim]

Source: https://www.tradingview.com/script/rFaVrkiK-Breakout-Retest-Signals-algotim/

## Description

Overview
Breakout Retest Quality Signals is a price-structure indicator designed to distinguish ordinary level breaks from breakouts that produce a meaningful retest.
The script does not treat every cross of a swing level as a valid breakout. A confirmed swing high or low first establishes the structural reference. Price must then close beyond that level by a minimum ATR-adjusted distance. Once the breakout qualifies, the script creates a volatility-scaled zone around the broken level and monitors the following price action for a retest.
The central purpose of the indicator is to evaluate the quality of that retest rather than simply marking every touch of the broken level.

Problem Statement
A basic breakout indicator can produce signals whenever price moves marginally above or below a previous high or low. Likewise, a basic retest indicator may treat any return to the broken level as confirmation.
Those approaches do not distinguish between a decisive breakout followed by a controlled rejection and a weak breakout followed by deep penetration of the level.
This script addresses that problem by separating the setup into three stages:
**structural breakout -> volatility-scaled retest zone -> retest quality evaluation**
This makes the retest itself part of the signal validation process.

Methodology
1. Confirmed structural levels
The script uses confirmed pivot highs and pivot lows to establish the most recent structural reference points.
A pivot is confirmed using the configured swing length, so the structural levels are not based on unconfirmed turning points.

2. ATR-qualified breakout

A bullish breakout occurs when price crosses above the most recent confirmed pivot high.

A bearish breakout occurs when price crosses below the most recent confirmed pivot low.

The breakout must also exceed the configured minimum breakout strength, measured as a multiple of ATR:
**Bullish displacement = close - broken high**
**Bearish displacement = broken low - close**
The displacement must be at least the user-defined ATR multiple.
This prevents small crosses around a structural level from automatically becoming breakout events.

3. Dynamic breakout zone
After a qualified breakout, the script creates a zone around the broken structural level.
The zone width is calculated from ATR rather than from a fixed number of ticks or points:
**Zone width = ATR x Zone Width Multiplier**
This allows the same methodology to account for different volatility conditions.
For a bullish breakout, the broken level becomes a potential support area.
For a bearish breakout, the broken level becomes a potential resistance area.

4. Retest monitoring
After the breakout, the zone remains active while the script waits for price to return to it.
The retest is only considered during the configured retest window. The zone also has a maximum lifetime so that an old breakout does not remain active indefinitely.
This creates an explicit state sequence rather than evaluating every bar independently:
**Breakout detected -> zone active -> retest pending -> retest evaluated -> confirmed or invalidated**

5. Retest Quality Engine
The primary differentiating component is the Retest Quality Engine.
When price enters the breakout zone, the script measures how deeply price penetrates the zone before moving back in the breakout direction.
Penetration is normalized against the width of the zone, allowing the measurement to remain related to the current volatility regime.
The resulting quality score favors relatively shallow and decisive rejection while assigning lower quality to deeper penetration.

The score is then compared with the user-defined minimum quality threshold.

This means that touching the zone alone is not necessarily enough to generate a signal.

6. Rejection confirmation
When the rejection-candle option is enabled, the retest must also close back outside the zone in the original breakout direction.
For a bullish setup, price must reject the zone and close back above it.
For a bearish setup, price must reject the zone and close back below it.
This additional condition separates a retest rejection from a simple penetration of the breakout area.

Signal Workflow
Bullish workflow
1. A confirmed pivot high establishes a structural resistance level.
2. Price crosses above that pivot.
3. The close must exceed the pivot by at least the configured ATR displacement.
4. A bullish breakout zone is created around the broken level.
5. The script waits for price to return to that zone.
6. Penetration depth is measured relative to the zone width.
7. The Retest Quality Engine converts the penetration into a quality score.
8. If the score meets the minimum threshold, the retest can qualify.
9. When rejection-candle confirmation is enabled, price must close back above the zone.
10. A bullish confirmation is then displayed.

Bearish workflow
1. A confirmed pivot low establishes a structural support level.
2. Price crosses below that pivot.
3. The close must exceed the pivot by at least the configured ATR displacement.
4. A bearish breakout zone is created around the broken level.
5. The script waits for price to return to that zone.
6. Penetration depth is measured relative to the zone width.
7. The Retest Quality Engine calculates the retest quality.
8. If the score meets the minimum threshold, the retest can qualify.
9. When rejection-candle confirmation is enabled, price must close back below the zone.
10. A bearish confirmation is then displayed.

Why This Indicator Is Different
A conventional breakout script generally answers one question:

**Did price break the level?**

A conventional retest script generally adds:

**Did price come back to the level?**

This indicator adds another layer:
**How cleanly did price reject the breakout zone after returning to it?**
The distinction is important because not all retests have the same structure.
The implementation combines the breakout and retest stages into one state-based process. ATR is used in two separate but related ways: first to filter weak structural breaks, and then to scale the breakout zone to current volatility.
The Retest Quality Engine then evaluates the interaction with that zone rather than treating every retest as equivalent.
The result is a more selective breakout-retest workflow instead of a collection of unrelated indicators.

Inputs
Structure Detection
**Swing Lookback (Pivot Length)**
Controls the number of bars used to confirm swing highs and lows.

**Minimum Breakout Strength (x ATR)**
Sets the minimum closing displacement beyond the structural level required for a breakout.

Breakout Zone
**Zone Width (x ATR)**
Controls the width of the dynamic breakout zone.

**Zone Max Lifetime (bars)**
Limits how long a breakout zone remains active.

Retest and Quality Engine
**Max Bars to Wait for Retest**
Defines the maximum number of bars allowed between breakout and retest.

**Minimum Retest Quality Score**
Sets the minimum quality score required for confirmation.

**Require Rejection Candle on Retest**
Requires the retest candle to close back in the breakout direction.

Volatility
**ATR Length**
Controls the ATR calculation used for breakout displacement and zone sizing.

Visual Style
The visual settings control bullish and bearish colors, zone opacity, confirmation labels, and the number of active zones displayed.

Alerts
The script can be used with TradingView alerts for the available confirmation conditions.
Alerts should be configured from the script's available alert conditions after adding the indicator to the chart.

Practical Usage
The indicator is intended to be used as a structural price-action filter.
A practical workflow is to first identify the direction and broader market context, then use the script to monitor qualified structural breaks and their subsequent retests.
Higher minimum breakout-strength and retest-quality settings will generally make the conditions more selective.
Lower thresholds will allow more setups but may also admit weaker breakouts and less decisive retests.
The breakout zone can also be used as a visual reference for evaluating whether price is accepting or rejecting the broken structure.
Signals should be evaluated together with the instrument, timeframe, market conditions, and the trader's own risk-management process.

Limitations
Pivot levels require confirmation and therefore are identified only after the required swing bars have formed.
A breakout that satisfies the ATR threshold does not guarantee continuation.
The quality score measures the geometry of the retest relative to the calculated zone; it does not predict the future direction or magnitude of price movement.
ATR-based measurements adapt to volatility but do not eliminate market noise.
A retest can fail after confirmation, particularly during rapidly changing or range-bound conditions.
The indicator is an analytical tool and should not be interpreted as a guarantee of profitable trading results.

Notes
This script is based on a single price-structure workflow: confirm the structural level, qualify the breakout using ATR displacement, define a volatility-scaled zone, monitor the retest, and evaluate the quality of the rejection.
The intention is to provide a consistent framework for studying breakout-retest behavior rather than to claim that every qualified setup will produce continuation.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © algotim

//@version=6
indicator("Breakout Retest Signals [algotim]", shorttitle="BRS [algotim]", overlay=true, max_boxes_count=200, max_lines_count=200, max_labels_count=200)

// ============================================================================
// BREAKOUT RETEST SIGNALS [algotim]
// Author: algotim
//
// Detects valid structural breakouts, builds a dynamic breakout zone, waits
// for a retest of that zone, and scores the retest quality using the
// proprietary "Retest Quality Engine" before confirming an entry signal.
// ============================================================================

// ----------------------------------------------------------------------------
// INPUTS
// ----------------------------------------------------------------------------

grpStruct = "Structure Detection"
swingLen     = input.int(10, "Swing Lookback (Pivot Length)", minval=3, maxval=50, group=grpStruct, tooltip="Number of bars on each side used to confirm a swing high/low pivot.")
minBreakoutATR = input.float(0.25, "Minimum Breakout Strength (x ATR)", minval=0.0, step=0.05, group=grpStruct, tooltip="Minimum close distance beyond the pivot level, expressed as a multiple of ATR, for a breakout to be considered valid (filters noise breakouts).")

grpZone = "Breakout Zone"
zoneATRMult  = input.float(0.25, "Zone Width (x ATR)", minval=0.05, step=0.05, group=grpZone, tooltip="Width of the breakout zone around the broken level, as a multiple of ATR.")
zoneMaxBars  = input.int(50, "Zone Max Lifetime (bars)", minval=5, maxval=300, group=grpZone, tooltip="Maximum number of bars a breakout zone remains active waiting for a retest.")

grpRetest = "Retest & Quality Engine"
retestMaxBars  = input.int(30, "Max Bars to Wait for Retest", minval=3, maxval=200, group=grpRetest, tooltip="Maximum bars after breakout during which a retest is valid.")
minQualityScore = input.int(60, "Minimum Retest Quality Score", minval=0, maxval=100, group=grpRetest, tooltip="Confirmed entry signals only trigger when the Retest Quality Score is at or above this threshold. The score measures how deep price penetrates the zone before rejecting back through it — shallow, decisive rejections score higher than deep, sluggish penetrations.")
requireRejectionCandle = input.bool(true, "Require Rejection Candle on Retest", group=grpRetest, tooltip="Require the retest bar to close back outside the zone in the breakout direction (a rejection/reversal candle), not just touch the zone.")

grpATR = "Volatility"
atrLen = input.int(14, "ATR Length", minval=1, group=grpATR)

grpStyle = "Visual Style"
bullColor   = input.color(color.new(#00bcd4, 0), "Bullish Color", group=grpStyle)
bearColor   = input.color(color.new(#ff5252, 0), "Bearish Color", group=grpStyle)
zoneOpacityActive  = input.int(85, "Zone Opacity (Active)", minval=0, maxval=100, group=grpStyle)
zoneOpacityRetest  = input.int(60, "Zone Opacity (Retest Pending)", minval=0, maxval=100, group=grpStyle)
showZoneLabel = input.bool(true, "Show Zone Quality Label on Confirmation", group=grpStyle)
maxZonesShown = input.int(5, "Max Active Zones Displayed", minval=1, maxval=20, group=grpStyle, tooltip="Limits clutter by only keeping the most recent N breakout zones visible.")

// ----------------------------------------------------------------------------
// CALCULATIONS
// ----------------------------------------------------------------------------

atrVal = ta.atr(atrLen)

// Pivot detection (non-repainting once confirmed after swingLen bars)
pivotHigh = ta.pivothigh(high, swingLen, swingLen)
pivotLow  = ta.pivotlow(low, swingLen, swingLen)

// Track most recent confirmed pivot levels
var float lastPivotHigh = na
var float lastPivotLow  = na

if not na(pivotHigh)
    lastPivotHigh := pivotHigh

if not na(pivotLow)
    lastPivotLow := pivotLow

// ----------------------------------------------------------------------------
// BREAKOUT ZONE STRUCTURE (using a User-Defined Type for clean state mgmt)
// ----------------------------------------------------------------------------

type Zone
    float level        // broken structural level
    float top           // zone upper bound
    float bottom        // zone lower bound
    bool  isBullish     // breakout direction (true = bullish breakout, zone acts as support)
    int   startBar      // bar index breakout occurred
    bool  retested      // retest occurred
    bool  confirmed     // confirmed entry triggered
    bool  invalidated   // zone invalidated (expired or failed)
    int   qualityScore  // retest quality score (0-100)
    box   zoneBox
    line  levelLine

var Zone[] zones = array.new<Zone>()

// ----------------------------------------------------------------------------
// BREAKOUT DETECTION
// ----------------------------------------------------------------------------

bullBreakout = not na(lastPivotHigh) and ta.crossover(close, lastPivotHigh) and (close - lastPivotHigh) >= minBreakoutATR * atrVal
bearBreakout = not na(lastPivotLow)  and ta.crossunder(close, lastPivotLow)  and (lastPivotLow - close)  >= minBreakoutATR * atrVal

// Create new zone on valid breakout
if bullBreakout
    float lvl = lastPivotHigh
    float w = zoneATRMult * atrVal
    Zone z = Zone.new(level=lvl, top=lvl + w, bottom=lvl - w, isBullish=true, startBar=bar_index, retested=false, confirmed=false, invalidated=false, qualityScore=0, zoneBox=na, levelLine=na)
    array.push(zones, z)

if bearBreakout
    float lvl = lastPivotLow
    float w = zoneATRMult * atrVal
    Zone z = Zone.new(level=lvl, top=lvl + w, bottom=lvl - w, isBullish=false, startBar=bar_index, retested=false, confirmed=false, invalidated=false, qualityScore=0, zoneBox=na, levelLine=na)
    array.push(zones, z)

// ----------------------------------------------------------------------------
// RETEST QUALITY ENGINE
// ----------------------------------------------------------------------------
// Measures how deeply price penetrates the breakout zone before rejecting
// back in the breakout direction. Penetration depth is normalized against
// the zone width, then inverted so shallow, decisive rejections score high
// and deep, sluggish penetrations (or zone failures) score low.

f_qualityScore(Zone z) =>
    float zoneWidth = z.top - z.bottom
    float penetration = 0.0
    if z.isBullish
        // how far price dipped below the top of the zone (toward/through bottom)
        penetration := math.max(0.0, z.top - low)
    else
        // how far price pushed above the bottom of the zone (toward/through top)
        penetration := math.max(0.0, high - z.bottom)

    float penetrationRatio = zoneWidth > 0 ? math.min(penetration / zoneWidth, 1.5) : 1.0
    // Score: 100 = touched edge only (penetration ~0), 0 = penetration >= 1.5x zone width
    float rawScore = (1.0 - (penetrationRatio / 1.5)) * 100.0

    // Rejection candle bonus: candle closes back outside zone in breakout direction
    bool rejectionCandle = z.isBullish ? close > z.top : close < z.bottom
    float bonus = rejectionCandle ? 10.0 : 0.0

    int finalScore = int(math.max(0.0, math.min(100.0, rawScore + bonus)))
    finalScore

// ----------------------------------------------------------------------------
// PROCESS ZONES: retest detection, scoring, confirmation, invalidation
// ----------------------------------------------------------------------------

var bool breakoutAlertBull = false
var bool breakoutAlertBear = false
var bool retestAlertBull   = false
var bool retestAlertBear   = false
var bool confirmAlertBull  = false
var bool confirmAlertBear  = false

breakoutAlertBull := false
breakoutAlertBear := false
retestAlertBull   := false
retestAlertBear   := false
confirmAlertBull  := false
confirmAlertBear  := false

if bullBreakout
    breakoutAlertBull := true
if bearBreakout
    breakoutAlertBear := true

if array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        Zone z = array.get(zones, i)

        if not z.invalidated
            int age = bar_index - z.startBar

            // Skip the breakout bar itself for retest checks
            if bar_index > z.startBar
                bool priceInZone = low <= z.top and high >= z.bottom

                if not z.retested
                    if priceInZone
                        // Retest touch detected
                        z.retested := true
                        z.qualityScore := f_qualityScore(z)

                        if z.isBullish
                            retestAlertBull := true
                        else
                            retestAlertBear := true

                        // Check for immediate confirmation on same bar
                        bool rejectionOk = requireRejectionCandle ? (z.isBullish ? close > z.top : close < z.bottom) : (z.isBullish ? close > z.bottom : close < z.top)
                        if rejectionOk and z.qualityScore >= minQualityScore
                            z.confirmed := true
                            z.invalidated := true
                            if z.isBullish
                                confirmAlertBull := true
                            else
                                confirmAlertBear := true
                    else if age >= zoneMaxBars
                        z.invalidated := true
                else if not z.confirmed
                    // Already retested at least once, watch for confirmation/rejection over subsequent bars
                    bool rejectionOk = z.isBullish ? close > z.top : close < z.bottom
                    int currentScore = f_qualityScore(z)
                    z.qualityScore := math.max(z.qualityScore, currentScore)

                    if rejectionOk and z.qualityScore >= minQualityScore
                        z.confirmed := true
                        z.invalidated := true
                        if z.isBullish
                            confirmAlertBull := true
                        else
                            confirmAlertBear := true
                    else if age >= zoneMaxBars + retestMaxBars
                        z.invalidated := true

                // Invalidate if price closes decisively back through the level against breakout direction
                bool failure = z.isBullish ? close < (z.level - zoneATRMult * atrVal) : close > (z.level + zoneATRMult * atrVal)
                if failure and not z.confirmed
                    z.invalidated := true

            array.set(zones, i, z)

// Remove invalidated zones (clean up boxes/lines and shrink array)
if array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        Zone z = array.get(zones, i)
        if z.invalidated
            if not na(z.zoneBox)
                box.delete(z.zoneBox)
            if not na(z.levelLine)
                line.delete(z.levelLine)
            array.remove(zones, i)

// ----------------------------------------------------------------------------
// VISUALIZATION
// ----------------------------------------------------------------------------

int activeCount = array.size(zones)
int startIdx = math.max(0, activeCount - maxZonesShown)

if barstate.islast and activeCount > 0
    for i = 0 to activeCount - 1
        Zone z = array.get(zones, i)
        if not na(z.zoneBox)
            box.delete(z.zoneBox)
        if not na(z.levelLine)
            line.delete(z.levelLine)
        array.set(zones, i, z)

    for i = startIdx to activeCount - 1
        Zone z = array.get(zones, i)
        color baseColor = z.isBullish ? bullColor : bearColor
        int opacity = z.retested ? zoneOpacityRetest : zoneOpacityActive
        color fillColor = color.new(baseColor, opacity)
        color borderColor = color.new(baseColor, 40)

        box bx = box.new(left=z.startBar, top=z.top, right=bar_index + 10, bottom=z.bottom,
             border_color=borderColor, border_width=1, border_style=line.style_dashed,
             bgcolor=fillColor, extend=extend.none)

        line ln = line.new(x1=z.startBar, y1=z.level, x2=bar_index + 10, y2=z.level,
             color=color.new(baseColor, 20), width=1, style=line.style_dotted)

        z.zoneBox := bx
        z.levelLine := ln
        array.set(zones, i, z)

        if z.retested and showZoneLabel
            string lblTxt = (z.confirmed ? "✓ " : "") + "Quality: " + str.tostring(z.qualityScore) + (z.confirmed ? "  CONFIRMED" : "")
            label.new(x=bar_index, y=z.isBullish ? z.top : z.bottom,
                 text=lblTxt, style=z.isBullish ? label.style_label_down : label.style_label_up,
                 color=color.new(baseColor, 10), textcolor=color.white, size=size.small)
                 
// Breakout markers (subtle, small)
plotshape(breakoutAlertBull, title="Bullish Breakout", style=shape.circle, location=location.belowbar, color=color.new(bullColor, 60), size=size.tiny)
plotshape(breakoutAlertBear, title="Bearish Breakout", style=shape.circle, location=location.abovebar, color=color.new(bearColor, 60), size=size.tiny)

// Confirmed entry signals — speech-bubble style labels
if confirmAlertBull
    label.new(x=bar_index, y=low, text="BULLISH", style=label.style_label_up,
         color=bullColor, textcolor=color.white, size=size.normal, yloc=yloc.belowbar)

if confirmAlertBear
    label.new(x=bar_index, y=high, text="BEARISH", style=label.style_label_down,
         color=bearColor, textcolor=color.white, size=size.normal, yloc=yloc.abovebar)

// ----------------------------------------------------------------------------
// ALERTS
// ----------------------------------------------------------------------------

if breakoutAlertBull
    alert("Breakout Retest Signals [algotim]: Bullish structure breakout detected on " + syminfo.ticker + " (" + timeframe.period + "). Zone created — awaiting retest.", alert.freq_once_per_bar_close)

if breakoutAlertBear
    alert("Breakout Retest Signals [algotim]: Bearish structure breakout detected on " + syminfo.ticker + " (" + timeframe.period + "). Zone created — awaiting retest.", alert.freq_once_per_bar_close)

if retestAlertBull
    alert("Breakout Retest Signals [algotim]: Bullish breakout zone retest in progress on " + syminfo.ticker + " (" + timeframe.period + "). Monitoring rejection quality.", alert.freq_once_per_bar_close)

if retestAlertBear
    alert("Breakout Retest Signals [algotim]: Bearish breakout zone retest in progress on " + syminfo.ticker + " (" + timeframe.period + "). Monitoring rejection quality.", alert.freq_once_per_bar_close)

if confirmAlertBull
    alert("Breakout Retest Signals [algotim]: CONFIRMED LONG entry on " + syminfo.ticker + " (" + timeframe.period + "). Retest Quality Score >= " + str.tostring(minQualityScore) + ".", alert.freq_once_per_bar_close)

if confirmAlertBear
    alert("Breakout Retest Signals [algotim]: CONFIRMED SHORT entry on " + syminfo.ticker + " (" + timeframe.period + "). Retest Quality Score >= " + str.tostring(minQualityScore) + ".", alert.freq_once_per_bar_close)
````
