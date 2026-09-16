<!-- tradingview-pine-id: PUB;e99cfaa76039491cbf64f15f760eacab -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MACD Pullback Validation with Divergence Filters [algotim]

Source: https://www.tradingview.com/script/3W5Ew47n-MACD-Pullback-Validation-with-Divergence-Filters-algotim/

## Description

MACD Pullback Validation with Divergence Filters is a momentum confirmation indicator designed to identify continuation opportunities after temporary pullbacks rather than generating signals from every MACD crossover.

Instead of relying on a single event, the script evaluates multiple stages of market behavior. It begins by detecting pullbacks within an existing momentum cycle, waits for momentum recovery, confirms that price and the MACD histogram are no longer weakening, and optionally verifies that the setup occurs near significant price locations using pivot-derived support/resistance levels or Bollinger Band extremes.

The objective is to reduce low-quality MACD signals by requiring several independent conditions to align before a bullish or bearish signal is displayed.

Problem Statement

Traditional MACD crossover signals frequently occur during ranging markets or immediately after short-lived momentum fluctuations. Likewise, divergence signals alone often appear too early and do not necessarily indicate that momentum has already shifted back in the anticipated direction.

This indicator addresses that limitation by requiring multiple confirmation stages rather than treating each condition as an independent trading signal.

Instead of responding to isolated events, it evaluates whether a pullback has occurred, whether momentum is rebuilding, whether a recent divergence supports the move, and whether price is located in an area where reversals may be more meaningful.

Methodology
The analytical framework consists of several sequential validation layers.

First, MACD crossover events occurring above or below the zero line are monitored to identify temporary pullbacks within an existing momentum cycle. These crossover events establish the recent pullback state.

Next, the script monitors the MACD histogram. Bullish momentum requires the histogram to remain above zero while increasing relative to the previous bar. Bearish momentum requires the histogram to remain below zero while decreasing.

The indicator then waits for the MACD line itself to cross the zero line, treating this as evidence that momentum has shifted back in the direction of the prevailing move.

Histogram divergence is calculated using confirmed pivot highs and pivot lows. Regular bullish divergence requires price to form a lower low while the histogram forms a higher low. Regular bearish divergence requires price to form a higher high while the histogram forms a lower high. Hidden divergence calculations are also available for users who wish to visualize continuation-type divergence.

Finally, optional contextual filters may be enabled.

The Support/Resistance filter checks whether the current price is interacting with recently confirmed pivot-based levels.

The Bollinger Band filter requires bullish setups to occur after closing below the lower band and bearish setups after closing above the upper band, helping identify momentum reversals from statistically extended price conditions.

Signals are generated only after every enabled validation layer has been satisfied.

Signal Workflow

Bullish workflow
1. Detect a recent bearish MACD crossover occurring above the zero line to identify a pullback.
2. Confirm a regular bullish MACD histogram divergence using pivot comparisons.
3. Require the MACD histogram to begin strengthening.
4. Wait for the MACD line to cross back above the zero line.
5. Optionally require interaction with recent pivot-based support.
6. Optionally require price to close below the lower Bollinger Band.
7. Display a bullish signal.

Bearish workflow
1. Detect a recent bullish MACD crossover occurring below the zero line.
2. Confirm a regular bearish MACD histogram divergence.
3. Require bearish histogram acceleration.
4. Wait for the MACD line to cross below the zero line.
5. Optionally require interaction with recent pivot-based resistance.
6. Optionally require price to close above the upper Bollinger Band.
7. Display a bearish signal.

Why This Indicator Is Different
Many MACD indicators generate signals immediately after crossovers, while divergence indicators typically evaluate price and momentum independently.

This script integrates these concepts into a sequential validation framework where each condition serves a different analytical purpose.

The pullback logic identifies temporary counter-trend momentum.

The histogram evaluates whether momentum is rebuilding.

The zero-line crossover confirms broader momentum alignment.

Divergence provides evidence that momentum and price are no longer moving in agreement.

Optional pivot interaction and Bollinger Band filters add market-location confirmation before a signal is produced.

Rather than displaying every crossover or every divergence, the indicator waits until multiple independent conditions align before producing a trading signal.

Inputs

The script includes configurable parameters for:
* MACD fast, slow, and signal periods
* Pullback lookback window
* Divergence pivot lengths
* Divergence range settings
* Optional hidden divergence display
* Optional Support/Resistance validation
* Pivot sensitivity
* Optional Bollinger Band confirmation
* Bollinger Band length and standard deviation

Alerts
Built-in alert conditions are available for:
* Bullish Signal
* Bearish Signal
* Regular Bullish Divergence
* Hidden Bullish Divergence
* Regular Bearish Divergence
* Hidden Bearish Divergence

Practical Usage
The indicator is intended for traders who prefer waiting for momentum confirmation after temporary pullbacks instead of reacting to every MACD crossover.

Optional Support/Resistance and Bollinger Band filters can be enabled to make signal selection more restrictive when additional price-location confirmation is desired.

Limitations
MACD histogram divergence relies on confirmed pivot highs and lows, so divergence signals are only confirmed after the required pivot bars have formed.

Support and resistance levels are derived from pivot calculations and represent algorithmically identified swing points rather than manually drawn market structure.

Like any momentum-based indicator, performance may vary across different market conditions and should be evaluated alongside a broader trading plan and appropriate risk management.

Notes
This indicator is intended as an analytical decision-support tool. It combines momentum analysis, pullback recognition, divergence detection, and optional contextual filters into a structured confirmation process rather than relying on any individual condition as a standalone trading signal.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © algotim

//@version=6
indicator("MACD Pullback Validation with Divergence Filters [algotim]", overlay=true)

// MACD Inputs
fastLength   = input.int(12, "Fast Length")
slowLength   = input.int(26, "Slow Length")
signalLength = input.int(9, "Signal Length")
lookback     = input.int(10, "Pullback Lookback", minval=1)

// MACD Calculation
[macdLine, signalLine, hist] = ta.macd(close, fastLength, slowLength, signalLength)

// =====================================================
// HISTOGRAM MOMENTUM CONDITIONS
// =====================================================

// Positive histogram increasing
histBullish = hist > 0 and hist > hist[1]

// Negative histogram decreasing
histBearish = hist < 0 and hist < hist[1]

// =====================================================
// PULLBACK CONDITIONS
// =====================================================

// Bearish crossover above zero
bearishCrossAboveZero =
     ta.crossunder(macdLine, signalLine) and
     macdLine > 0 and
     signalLine > 0

// Bullish crossover below zero
bullishCrossBelowZero =
     ta.crossover(macdLine, signalLine) and
     macdLine < 0 and
     signalLine < 0

barsSinceBearishCross = ta.barssince(bearishCrossAboveZero)
barsSinceBullishCross = ta.barssince(bullishCrossBelowZero)

recentBearishCross =
     not na(barsSinceBearishCross) and
     barsSinceBearishCross <= lookback

recentBullishCross =
     not na(barsSinceBullishCross) and
     barsSinceBullishCross <= lookback

// =====================================================
// ZERO LINE CONDITIONS
// =====================================================

macdCrossAboveZero = ta.crossover(macdLine, 0)
macdCrossBelowZero = ta.crossunder(macdLine, 0)

// =====================================================
// DIVERGENCE SETTINGS
// =====================================================

lbR = input.int(title="Pivot Lookback Right", defval=5)
lbL = input.int(title="Pivot Lookback Left", defval=5)
rangeUpper = input.int(title="Max of Lookback Range", defval=60)
rangeLower = input.int(title="Min of Lookback Range", defval=5)

plotBullish = input.bool(title="Plot Bullish", defval=true)
plotHiddenBullish = input.bool(title="Plot Hidden Bullish", defval=false)
plotBearish = input.bool(title="Plot Bearish", defval=true)
plotHiddenBearish = input.bool(title="Plot Hidden Bearish", defval=false)

// Colors
bearishColor = color.red
bullishColor = color.green
hiddenBullishColor = color.new(color.green, 80)
hiddenBearishColor = color.new(color.red, 80)
textColor = color.white
noneColor = color.new(color.white, 100)

// MACD Histogram
osc = hist

// Pivot Detection
plFound = not na(ta.pivotlow(osc, lbL, lbR))
phFound = not na(ta.pivothigh(osc, lbL, lbR))

_inRange(cond) =>
    bars = ta.barssince(cond)
    rangeLower <= bars and bars <= rangeUpper

// =====================================================
// REGULAR BULLISH DIVERGENCE
// =====================================================

inRangePl = _inRange(plFound[1])

oscHL = osc[lbR] > ta.valuewhen(plFound, osc[lbR], 1) and inRangePl
priceLL = low[lbR] < ta.valuewhen(plFound, low[lbR], 1)

bullishCondAlert = priceLL and oscHL and plFound
bullishCond = plotBullish and bullishCondAlert

// =====================================================
// HIDDEN BULLISH DIVERGENCE
// =====================================================

oscLL = osc[lbR] < ta.valuewhen(plFound, osc[lbR], 1) and inRangePl
priceHL = low[lbR] > ta.valuewhen(plFound, low[lbR], 1)

hiddenBullishCondAlert = priceHL and oscLL and plFound
hiddenBullishCond = plotHiddenBullish and hiddenBullishCondAlert

// =====================================================
// REGULAR BEARISH DIVERGENCE
// =====================================================

inRangePh = _inRange(phFound[1])

oscLH = osc[lbR] < ta.valuewhen(phFound, osc[lbR], 1) and inRangePh
priceHH = high[lbR] > ta.valuewhen(phFound, high[lbR], 1)

bearishCondAlert = priceHH and oscLH and phFound
bearishCond = plotBearish and bearishCondAlert

// =====================================================
// HIDDEN BEARISH DIVERGENCE
// =====================================================

oscHH = osc[lbR] > ta.valuewhen(phFound, osc[lbR], 1) and inRangePh
priceLH = high[lbR] < ta.valuewhen(phFound, high[lbR], 1)

hiddenBearishCondAlert = priceLH and oscHH and phFound
hiddenBearishCond = plotHiddenBearish and hiddenBearishCondAlert

// Divergence Alerts
alertcondition(bullishCondAlert, title="Regular Bullish Divergence", message="MACD Histogram Regular Bullish Divergence")
alertcondition(hiddenBullishCondAlert, title="Hidden Bullish Divergence", message="MACD Histogram Hidden Bullish Divergence")
alertcondition(bearishCondAlert, title="Regular Bearish Divergence", message="MACD Histogram Regular Bearish Divergence")
alertcondition(hiddenBearishCondAlert, title="Hidden Bearish Divergence", message="MACD Histogram Hidden Bearish Divergence")

// =====================================================
// FINAL SIGNALS
// =====================================================

recentBullishDiv = ta.barssince(bullishCondAlert) <= 30
recentBearishDiv = ta.barssince(bearishCondAlert) <= 30

// =====================================================
// SUPPORT / RESISTANCE FILTER
// =====================================================

enableSRFilter = input.bool(false, "Enable Support/Resistance Filter")

leftBars  = input.int(10, "Left Bars", minval=1)
rightBars = input.int(10, "Right Bars", minval=1)

bodyHigh = math.max(open, close)
bodyLow  = math.min(open, close)

pivotHigh = ta.pivothigh(bodyHigh, leftBars, rightBars)
pivotLow  = ta.pivotlow(bodyLow, leftBars, rightBars)

var float latestPivotHighCandleHigh = na
var float latestPivotHighCandleLow  = na

if not na(pivotHigh)
    latestPivotHighCandleHigh := high[rightBars]
    latestPivotHighCandleLow  := low[rightBars]

    label.new(
         bar_index - rightBars,
         high[rightBars],
         "PH",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white)

var float latestPivotLowCandleHigh = na
var float latestPivotLowCandleLow  = na

if not na(pivotLow)
    latestPivotLowCandleHigh := high[rightBars]
    latestPivotLowCandleLow  := low[rightBars]

    label.new(
         bar_index - rightBars,
         low[rightBars],
         "PL",
         style=label.style_label_up,
         color=color.lime,
         textcolor=color.black)

// Latest support & resistance from pivot bodies
supportLevel    = latestPivotHighCandleHigh
resistanceLevel = latestPivotHighCandleLow

supportZoneTop    = supportLevel
supportZoneBottom = supportLevel

resistanceZoneTop    = resistanceLevel
resistanceZoneBottom = resistanceLevel

touchSupport =
     not na(supportLevel) and
     low <= supportZoneTop

touchResistance =
     not na(resistanceLevel) and
     high >= resistanceZoneBottom

// =====================================================
// BOLLINGER BAND FILTER
// =====================================================

enableBBFilter = input.bool(false, "Enable Bollinger Band Filter")

bbLength = input.int(20, "BB Length")
bbMult   = input.float(2.0, "BB StdDev", step=0.1)

bbBasis = ta.sma(close, bbLength)
bbDev   = bbMult * ta.stdev(close, bbLength)

bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev

// Close outside bands
bbBullishCondition  = close < bbLower
bbBearishCondition = close > bbUpper

plot(enableBBFilter ? bbUpper : na, "BB Upper", color=color.new(color.red, 50))
plot(enableBBFilter ? bbBasis : na, "BB Basis", color=color.new(color.gray, 50))
plot(enableBBFilter ? bbLower : na, "BB Lower", color=color.new(color.green, 50))

baseBullishSignal =
     histBullish and
     macdCrossAboveZero and
     recentBearishCross and
     recentBullishDiv

baseBearishSignal =
     histBearish and
     macdCrossBelowZero and
     recentBullishCross and
     recentBearishDiv

bullishSignal =
     baseBullishSignal and
     (
         not enableSRFilter or
         touchSupport
     ) and
     (
         not enableBBFilter or
         bbBullishCondition
     )

bearishSignal =
     baseBearishSignal and
     (
         not enableSRFilter or
         touchResistance
     ) and
     (
         not enableBBFilter or
         bbBearishCondition
     )

// =====================================================
// PLOTS
// =====================================================

plotshape(
     bullishSignal,
     title="BULLISH",
     location=location.belowbar,
     style=shape.labelup,
     color=color.lime,
     text="BULLISH",
     textcolor=color.white,
     size=size.normal)

plotshape(
     bearishSignal,
     title="BEARISH",
     location=location.abovebar,
     style=shape.labeldown,
     color=color.red,
     text="BEARISH",
     textcolor=color.white,
     size=size.normal)

// =====================================================
// ALERTS
// =====================================================

alertcondition(
     bullishSignal,
     title="Bullish Signal",
     message="MACD Bullish Signal")

alertcondition(
     bearishSignal,
     title="Bearish Signal",
     message="MACD Bearish Signal")
````
