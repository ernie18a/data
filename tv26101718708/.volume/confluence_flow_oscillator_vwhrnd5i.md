# Confluence Flow Oscillator

- url: https://www.tradingview.com/script/VWhRnd5I-Confluence-Flow-Oscillator/
- type: indicator
- pine_id: PUB;e3a4506d38f849bf851fb300433d3e21
- version: 1.0

## Description

[b]Confluence Flow Oscillator[/b]

Confluence Flow Oscillator is an educational momentum, pressure, and volume-flow indicator designed to help traders evaluate whether current market movement is supported by directional pressure, bar-close behavior, and volume-weighted participation.

This script is an indicator, not a trading strategy. It does not place trades, does not simulate orders, and does not provide backtested performance results. Any signal markers are optional and disabled by default. The indicator should be used as a research and decision-support tool, not as financial advice or an automatic trading system.

[b]What the script measures[/b]

The indicator creates a composite oscillator called Flow Score. The Flow Score is calculated from three separate components:

1. Close Location Value / CLV

CLV measures where the candle closes within its own high-low range.

When the close is near the high of the candle, CLV is positive.
When the close is near the low of the candle, CLV is negative.
When the close is near the middle of the candle, CLV is closer to neutral.

This helps measure intrabar buying or selling pressure.

2. RSI Distance From 50

The script uses RSI as a momentum component, but instead of displaying the standard RSI scale, it re-centers RSI around a zero line.

RSI values above 50 contribute positively to the Flow Score.
RSI values below 50 contribute negatively to the Flow Score.

This allows RSI momentum to be blended into a zero-centered oscillator.

3. Chaikin Money Flow / CMF

CMF measures volume-weighted accumulation or distribution over the selected lookback period.

Positive CMF values suggest that volume is more associated with buying pressure.
Negative CMF values suggest that volume is more associated with selling pressure.

The script scales CMF so it can be blended with the other oscillator components.

[b]How the Flow Score is calculated[/b]

[b]The Flow Score is a weighted blend of:[/b]

- Smoothed CLV × 100.
- RSI distance from 50.
- CMF × 100.

Users can adjust the weight of each component. For example, increasing the CMF weight gives more influence to volume-based flow. Setting a component weight to zero removes that component from the composite calculation.

[b]The final result is plotted as a zero-centered oscillator:[/b]

- Positive values suggest bullish pressure.
- Negative values suggest bearish pressure.
- Readings above the bullish threshold suggest stronger upside flow.
- Readings below the bearish threshold suggest stronger downside flow.

[b]Originality and usefulness[/b]

This indicator is designed as a confluence-based flow oscillator rather than a simple single-input momentum tool.

The purpose of combining CLV, RSI distance, and CMF is to evaluate three different aspects of market behavior in one normalized view:

- CLV shows where candles close within their own range.
- RSI distance from 50 shows directional momentum relative to a neutral momentum level.
- CMF shows whether volume is supporting accumulation or distribution.

The script also includes optional confirmation filters so that signals are not based only on a threshold cross. These filters can require volume conviction, recent pivot structure, and exhaustion protection before a signal marker is allowed.

This makes the indicator useful for traders who want to study whether directional movement is supported by price location, momentum, and volume flow together.

[b]Signal logic[/b]

The script can optionally display signal markers, but they are disabled by default.

A bullish signal can occur when the Flow Score crosses above the bullish threshold and the selected confirmation filters are satisfied.

A bearish signal can occur when the Flow Score crosses below the bearish threshold and the selected confirmation filters are satisfied.

A long-exit marker can occur when the Flow Score crosses below the bearish threshold while the script’s internal long-state is active.

These markers are informational only. They are not guaranteed entries or exits, and they should not be used without additional analysis, risk management, and testing.

[b]Confirmation filters[/b]

The script includes several optional filters:

1. Volume Conviction Filter

When enabled, the signal requires current volume to be at or above a selected percentile of recent volume. This is intended to reduce signals that occur during low-participation conditions.

2. Pivot Structure Filter

When enabled, bullish signals require a recent confirmed pivot low, and bearish signals require a recent confirmed pivot high. This helps connect oscillator signals to recent market structure.

Because pivot confirmation requires bars to close after the pivot point, pivot-based logic can appear with delay. This is a normal characteristic of confirmed pivot calculations.

3. Exhaustion Guards

When enabled, the script attempts to avoid buying into overbought conditions and avoid selling into oversold conditions.

The exhaustion guard can block bullish signals when RSI is already above the selected overbought block level, and it can block bearish signals when RSI is already below the selected oversold block level.

It also checks whether an opposite-side flow regime existed recently before allowing a new signal. This helps reduce signals that occur after an extended one-sided move without prior regime context.

[b]How to use it[/b]

[b]A practical workflow is:[/b]

1. Use the zero line to identify whether flow is generally bullish or bearish.
2. Use the bullish and bearish threshold lines to identify stronger flow conditions.
3. Review whether the Flow Score is rising, falling, or flattening.
4. Enable optional signal markers only if you want visual threshold-cross markers.
5. Use the volume, pivot, and exhaustion filters to make signals more selective.
6. Confirm any setup with your own market structure, trend context, support/resistance, higher timeframe analysis, and risk rules.

[b]Main settings[/b]

Core Periods

- RSI Length: controls the RSI momentum lookback.
- CMF Length: controls the Chaikin Money Flow lookback.
- CLV Smoothing: smooths the Close Location Value component.

Component Weights

- CLV Weight: controls the influence of candle close-location pressure.
- RSI Distance Weight: controls the influence of RSI momentum.
- CMF Weight: controls the influence of volume-weighted money flow.

Signal Logic

- Long Entry Threshold: bullish Flow Score threshold.
- Short/Exit Threshold: bearish Flow Score threshold.
- Show Short Signals: enables bearish short markers. Disabled by default.

Volume Conviction

- Require Volume Conviction: requires above-percentile volume before signals are shown.
- Volume Percentile: sets the required volume percentile.
- Volume Window: sets the lookback used for volume percentile calculation.

Pivot Structure

- Require Recent Pivot: requires recent pivot confirmation before signals.
- Pivot Left Bars: controls the left-side pivot confirmation.
- Pivot Right Bars: controls the right-side pivot confirmation.
- Max Pivot Age: controls how recent a pivot must be to qualify.

Exhaustion Guards

- Use Exhaustion Guards: enables overbought/oversold and regime-context filters.
- RSI Oversold Block: blocks bearish signals when RSI is too low.
- RSI Overbought Block: blocks bullish signals when RSI is too high.
- Regime Confirmation Window: checks whether a prior opposite-side flow regime existed.

Visuals

- Shade Bullish/Bearish Zones: shades the oscillator area above or below zero.
- Show Threshold Lines: displays bullish and bearish threshold lines.
- Show Buy/Sell Signal Markers: enables optional signal markers in the oscillator pane.
- Plot Signal Arrows on Price: displays optional markers on the main price chart when signal markers are enabled.

[b]Alerts[/b]

The script includes alert conditions for:

- Bullish Signal.
- Bearish Signal.
- Long Exit.

Alerts only trigger when signal markers are enabled. They are intended as informational alerts, not automated trading instructions.

[b]Important limitations[/b]

This indicator does not predict future price movement.

A positive Flow Score does not guarantee price will continue upward.
A negative Flow Score does not guarantee price will continue downward.
A bullish or bearish marker does not guarantee a profitable trade.

The Flow Score can behave differently across symbols, timeframes, sessions, and market conditions. Volume-based components may be less reliable on instruments where volume data is limited, synthetic, or inconsistent.

Users should test the indicator across multiple symbols and timeframes before relying on it in any decision-making process.

Recommended use

Confluence Flow Oscillator is used as a supporting oscillator for studying momentum, candle pressure, and volume participation together. It is designed to complement, not replace, a complete trading plan.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ADXAE

//@version=6
// Confluence Flow Oscillator — composite momentum/pressure/flow oscillator with optional structural confirmation.
//
// What it measures:
//   1. CLV (Close Location Value): where the close sits inside the bar's range.
//      Formula: (2*close - high - low) / (high - low)
//
//   2. RSI distance from 50: RSI re-centered around zero.
//      Formula: (RSI - 50) * 2
//
//   3. CMF (Chaikin Money Flow): volume-weighted accumulation/distribution.
//
// The final oscillator, "Flow Score", is a weighted blend of CLV, RSI distance, and CMF,
// normalized around the zero line. Positive readings suggest bullish pressure.
// Negative readings suggest bearish pressure.
//
// Notes:
// - This is an indicator, not a strategy.
// - Buy/Sell markers are disabled by default.
// - Alerts are available only when signal markers are enabled.

indicator("Confluence Flow Oscillator", shorttitle="ConfFlow", overlay=false, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════════════════
// INPUT GROUPS
// ═══════════════════════════════════════════════════════════════════════════

grpCore    = "════ Core Periods ════"
grpWeight  = "════ Component Weights ════"
grpSig     = "════ Signal Logic ════"
grpVol     = "════ Volume Conviction ════"
grpPivot   = "════ Pivot Structure ════"
grpExhaust = "════ Exhaustion Guards ════"
grpVis     = "════ Visuals ════"

// ═══════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════

// — Core periods
rsiLen = input.int(
     14, "RSI Length", minval=2, maxval=100, group=grpCore,
     tooltip="RSI lookback period. Lower values react faster but can be noisier. Higher values are smoother but slower."
)

cmfLen = input.int(
     20, "CMF Length", minval=2, maxval=200, group=grpCore,
     tooltip="Chaikin Money Flow lookback period used to measure volume-weighted buying or selling pressure."
)

clvSmooth = input.int(
     3, "CLV Smoothing", minval=1, maxval=20, group=grpCore,
     tooltip="SMA smoothing applied to Close Location Value. A value of 1 uses raw CLV. Higher values reduce noise."
)

// — Component weights
wCLV = input.float(
     0.8, "CLV Weight", minval=0.0, maxval=3.0, step=0.1, group=grpWeight,
     tooltip="Weight of Close Location Value in the composite Flow Score. Set to 0 to remove this component."
)

wRSI = input.float(
     1.0, "RSI Distance Weight", minval=0.0, maxval=3.0, step=0.1, group=grpWeight,
     tooltip="Weight of RSI distance from 50 in the composite Flow Score. Set to 0 to remove this component."
)

wCMF = input.float(
     2.0, "CMF Weight", minval=0.0, maxval=3.0, step=0.1, group=grpWeight,
     tooltip="Weight of Chaikin Money Flow in the composite Flow Score. Higher values give more influence to volume-based flow."
)

// — Signal logic
longThresh = input.float(
     28.0, "Long Entry Threshold", minval=5.0, maxval=90.0, step=1.0, group=grpSig,
     tooltip="Bullish threshold. A crossover above this level can qualify as a bullish signal when filters are satisfied."
)

shortThresh = input.float(
     -15.0, "Short/Exit Threshold", minval=-90.0, maxval=-5.0, step=1.0, group=grpSig,
     tooltip="Bearish threshold. A crossunder below this level can qualify as a bearish/exit signal when filters are satisfied."
)

useShorts = input.bool(
     false, "Show Short Signals", group=grpSig,
     tooltip="When enabled, bearish crosses can generate short signal markers. Disabled by default."
)

// — Volume conviction
useVolFilter = input.bool(
     true, "Require Volume Conviction", group=grpVol,
     tooltip="When enabled, signals require current volume to be above the selected percentile of recent volume."
)

volPctile = input.float(
     65, "Volume Percentile (%)", minval=10, maxval=99, step=1, group=grpVol, active=useVolFilter,
     tooltip="Volume must be at or above this percentile of the selected volume window to pass the conviction filter."
)

volWin = input.int(
     50, "Volume Window", minval=10, maxval=500, group=grpVol, active=useVolFilter,
     tooltip="Lookback period used for the volume percentile calculation."
)

// — Pivot structure
usePivotFilter = input.bool(
     true, "Require Recent Pivot", group=grpPivot,
     tooltip="When enabled, bullish signals require a recent pivot low and bearish signals require a recent pivot high."
)

pivLeft = input.int(
     2, "Pivot Left Bars", minval=1, maxval=30, group=grpPivot, active=usePivotFilter,
     tooltip="Number of bars to the left used for pivot confirmation."
)

pivRight = input.int(
     2, "Pivot Right Bars", minval=1, maxval=30, group=grpPivot, active=usePivotFilter,
     tooltip="Number of bars to the right used for pivot confirmation. Pivots are confirmed only after these bars close."
)

pivMaxAge = input.int(
     15, "Max Pivot Age (bars)", minval=1, maxval=100, group=grpPivot, active=usePivotFilter,
     tooltip="Maximum number of bars allowed since the most recent confirmed pivot."
)

// — Exhaustion guards
useExhaustFilter = input.bool(
     true, "Use Exhaustion Guards", group=grpExhaust,
     tooltip="When enabled, signals are filtered to avoid buying into overbought conditions or selling into oversold conditions."
)

rsiExhaustOS = input.float(
     40, "RSI Oversold Block (SELL)", minval=10, maxval=49, step=1, group=grpExhaust, active=useExhaustFilter,
     tooltip="Blocks bearish signals when RSI is at or below this value."
)

rsiExhaustOB = input.float(
     75, "RSI Overbought Block (BUY)", minval=51, maxval=90, step=1, group=grpExhaust, active=useExhaustFilter,
     tooltip="Blocks bullish signals when RSI is at or above this value."
)

regimeWindow = input.int(
     12, "Regime Confirmation Window", minval=2, maxval=60, group=grpExhaust, active=useExhaustFilter,
     tooltip="Lookback period used to confirm that a prior opposite-side regime existed before a signal."
)

// — Visuals
showFill = input.bool(
     true, "Shade Bullish/Bearish Zones", group=grpVis,
     tooltip="Shades the oscillator area above or below the zero line."
)

showThresh = input.bool(
     true, "Show Threshold Lines", group=grpVis,
     tooltip="Shows the bullish and bearish threshold lines."
)

showSignalMarkers = input.bool(
     false, "Show Buy/Sell Signal Markers", group=grpVis,
     tooltip="Shows signal markers inside the oscillator pane. Disabled by default."
)

plotOnPrice = input.bool(
     false, "Plot Signal Arrows on Price", group=grpVis,
     tooltip="Shows BUY/SELL markers on the main price chart when signal markers are enabled. Disabled by default."
)

// ═══════════════════════════════════════════════════════════════════════════
// COMPONENT 1 — CLOSE LOCATION VALUE
// ═══════════════════════════════════════════════════════════════════════════

hlRange = high - low
clvRaw = hlRange > 0 ? (2.0 * close - high - low) / hlRange : 0.0
clv = ta.sma(clvRaw, clvSmooth)
clvScaled = clv * 100.0

// ═══════════════════════════════════════════════════════════════════════════
// COMPONENT 2 — RSI DISTANCE FROM 50
// ═══════════════════════════════════════════════════════════════════════════

rsiVal = ta.rsi(close, rsiLen)
rsiDistance = (rsiVal - 50.0) * 2.0

// ═══════════════════════════════════════════════════════════════════════════
// COMPONENT 3 — CHAIKIN MONEY FLOW
// ═══════════════════════════════════════════════════════════════════════════

mfVolume = hlRange > 0 ? ((close - low) - (high - close)) / hlRange * volume : 0.0
cmfSumMF = math.sum(mfVolume, cmfLen)
cmfSumV = math.sum(volume, cmfLen)
cmf = cmfSumV > 0 ? cmfSumMF / cmfSumV : 0.0
cmfScaled = cmf * 100.0

// ═══════════════════════════════════════════════════════════════════════════
// COMPOSITE FLOW SCORE
// ═══════════════════════════════════════════════════════════════════════════

wSum = wCLV + wRSI + wCMF
flowScore = wSum > 0 ? (clvScaled * wCLV + rsiDistance * wRSI + cmfScaled * wCMF) / wSum : 0.0

// ═══════════════════════════════════════════════════════════════════════════
// VOLUME CONVICTION
// ═══════════════════════════════════════════════════════════════════════════

volThreshold = ta.percentile_linear_interpolation(volume, volWin, volPctile)
volConviction = not useVolFilter or volume >= volThreshold

// ═══════════════════════════════════════════════════════════════════════════
// PIVOT STRUCTURE
// ═══════════════════════════════════════════════════════════════════════════

pivHi = ta.pivothigh(high, pivLeft, pivRight)
pivLo = ta.pivotlow(low, pivLeft, pivRight)

barsSincePivLo = nz(ta.barssince(not na(pivLo)), 9999)
barsSincePivHi = nz(ta.barssince(not na(pivHi)), 9999)

pivotLongOK = not usePivotFilter or barsSincePivLo <= pivMaxAge
pivotShortOK = not usePivotFilter or barsSincePivHi <= pivMaxAge

// ═══════════════════════════════════════════════════════════════════════════
// EXHAUSTION GUARDS
// ═══════════════════════════════════════════════════════════════════════════

rsiOKforShort = not useExhaustFilter or rsiVal > rsiExhaustOS
rsiOKforLong = not useExhaustFilter or rsiVal < rsiExhaustOB

wasBullishRegime = math.sum(flowScore > 0 ? 1 : 0, regimeWindow) > 0
wasBearishRegime = math.sum(flowScore < 0 ? 1 : 0, regimeWindow) > 0

regimeOKforShort = not useExhaustFilter or wasBullishRegime
regimeOKforLong = not useExhaustFilter or wasBearishRegime

exhaustOKforShort = rsiOKforShort and regimeOKforShort
exhaustOKforLong = rsiOKforLong and regimeOKforLong

// ═══════════════════════════════════════════════════════════════════════════
// SIGNAL LOGIC
// ═══════════════════════════════════════════════════════════════════════════

crossUp = ta.crossover(flowScore, longThresh)
crossDown = ta.crossunder(flowScore, shortThresh)

longEntry = crossUp and volConviction and pivotLongOK and exhaustOKforLong
longExit = crossDown and exhaustOKforShort
shortEntry = useShorts and crossDown and volConviction and pivotShortOK and exhaustOKforShort

var int simPos = 0
if longEntry and simPos != 1
    simPos := 1
else if shortEntry and simPos != -1
    simPos := -1
else if longExit and simPos == 1
    simPos := 0

longEntryVis = longEntry and simPos == 1 and simPos[1] != 1
shortEntryVis = shortEntry and simPos == -1 and simPos[1] != -1
longExitVis = longExit and simPos == 0 and simPos[1] == 1

showPaneSignals = showSignalMarkers
showPriceSignals = showSignalMarkers and plotOnPrice

// ═══════════════════════════════════════════════════════════════════════════
// PLOTS — OSCILLATOR PANE
// ═══════════════════════════════════════════════════════════════════════════

plot(0, "Zero", color=color.new(color.gray, 50), display=display.pane)

plot(showThresh ? longThresh : na, "Bullish Threshold", color=color.new(color.green, 30), linewidth=1, style=plot.style_linebr)
plot(showThresh ? shortThresh : na, "Bearish Threshold", color=color.new(color.red, 30), linewidth=1, style=plot.style_linebr)

flowColor = flowScore >= longThresh ? color.new(color.green, 0) :
     flowScore <= shortThresh ? color.new(color.red, 0) :
     color.new(color.gray, 0)

flowLine = plot(flowScore, "Flow Score", color=flowColor, linewidth=2)
zeroLine = plot(0, "Zero Fill Anchor", color=color.new(color.gray, 100), display=display.none)

fill(
     flowLine, zeroLine,
     color=showFill ? (flowScore >= 0 ? color.new(color.green, 80) : color.new(color.red, 80)) : na,
     title="Flow Zone Fill"
)

// Optional components are hidden by default and can be enabled from the Style tab.
plot(clvScaled, "CLV Smoothed × 100", color=color.new(color.aqua, 60), display=display.none)
plot(rsiDistance, "RSI Distance From 50", color=color.new(color.orange, 60), display=display.none)
plot(cmfScaled, "CMF × 100", color=color.new(color.fuchsia, 60), display=display.none)

// Signal markers are disabled by default.
plotshape(showPaneSignals and longEntryVis, "Bullish Signal (pane)", shape.triangleup, location.bottom, color=color.new(color.green, 0), size=size.tiny)
plotshape(showPaneSignals and shortEntryVis, "Bearish Signal (pane)", shape.triangledown, location.top, color=color.new(color.red, 0), size=size.tiny)
plotshape(showPaneSignals and longExitVis, "Long Exit (pane)", shape.xcross, location.top, color=color.new(color.yellow, 0), size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════
// OPTIONAL PRICE-CHART MARKERS
// ═══════════════════════════════════════════════════════════════════════════

plotshape(showPriceSignals and longEntryVis, "Bullish Signal", shape.labelup, location.belowbar, color=color.new(color.green, 0), textcolor=color.white, text="BUY", size=size.small, force_overlay=true)
plotshape(showPriceSignals and shortEntryVis, "Bearish Signal", shape.labeldown, location.abovebar, color=color.new(color.red, 0), textcolor=color.white, text="SELL", size=size.small, force_overlay=true)
plotshape(showPriceSignals and longExitVis, "Long Exit", shape.xcross, location.abovebar, color=color.new(color.yellow, 0), size=size.small, force_overlay=true)

// ═══════════════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════════════

alertcondition(showSignalMarkers and longEntryVis, "Confluence Flow Oscillator — Bullish Signal", "Flow Score crossed above the bullish threshold with selected filters satisfied.")
alertcondition(showSignalMarkers and shortEntryVis, "Confluence Flow Oscillator — Bearish Signal", "Flow Score crossed below the bearish threshold with selected filters satisfied.")
alertcondition(showSignalMarkers and longExitVis, "Confluence Flow Oscillator — Long Exit", "Flow Score crossed below the bearish threshold while the internal long-state was active.")
````
