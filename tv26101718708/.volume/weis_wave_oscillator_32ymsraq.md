# Weis Wave Oscillator

- url: https://www.tradingview.com/script/32ymSRAQ-Weis-Wave-Oscillator/
- type: indicator
- pine_id: PUB;b6e6e799cf2e416c89dea3afa7929163
- version: 1.0

## Description

Weis Wave Oscillator

1. Overview

Weis Wave Oscillator is a volume-based wave analysis indicator.

Instead of reading volume bar by bar, the indicator groups volume into directional price waves. It accumulates volume during confirmed upward and downward waves, then displays the accumulated wave volume as columns in a separate pane.

The purpose of the indicator is to help users compare effort versus result by studying how much volume was involved in each directional wave.

This is an indicator, not a strategy. It does not place trades, does not execute orders, and does not produce TradingView Strategy Tester results.

2. Core Idea

Traditional volume bars show volume for each individual candle.

Weis Wave Oscillator groups volume across an entire price wave.

This allows users to ask a different question:

How much volume was required to create this wave?

This can help users study whether a move had strong participation, weak participation, or inefficient effort.

3. Wave Direction

Wave direction is based on confirmed pivot highs and pivot lows.

When a pivot low is confirmed, the indicator starts or continues an upward wave.

When a pivot high is confirmed, the indicator starts or continues a downward wave.

Because pivots require future bars to confirm, wave changes can appear with a delay. This is expected behavior for pivot-based wave analysis.

4. Wave Volume

During each wave, the indicator accumulates the volume of each bar.

For an upward wave, the accumulated volume is displayed using the up wave color.

For a downward wave, the accumulated volume is displayed using the down wave color.

The displayed columns represent the total volume accumulated inside the current directional wave, not only the volume of a single candle.

5. Average Wave Volume

The indicator includes an optional average completed wave volume line.

This line is calculated from recently completed waves.

It helps users compare the current wave volume against the recent average wave effort.

If the current wave grows above the average, it may suggest stronger participation compared with recent waves.

6. High Effort Waves

The indicator can highlight high effort waves.

A wave is considered high effort when its accumulated volume becomes greater than the average completed wave volume multiplied by the selected high-effort factor.

The default high-effort factor is 1.50.

This means the wave must reach at least 150% of the average completed wave volume to be highlighted.

High effort does not automatically mean bullish or bearish continuation. It simply means that the wave used a larger amount of volume compared with recent completed waves.

7. Effort Versus Result

The main purpose of the indicator is to support effort-versus-result analysis.

Examples:

* A strong upward wave with high volume and clear price progress may suggest committed buying participation.
* A strong downward wave with high volume and clear downside progress may suggest committed selling pressure.
* A very large wave volume with limited price progress may suggest inefficient effort, absorption, resistance, or support.
* Comparing the volume of opposing waves can help users study whether buyers or sellers are showing stronger participation.

These observations should always be reviewed with price structure and market context.

8. Optional Effort / Result Line

The indicator includes an optional effort/result line.

This line compares completed wave volume with the absolute price result of the wave.

It is OFF by default to keep the chart clean.

When enabled, it can help users study cases where a wave uses large volume but produces limited price movement.

9. Display

The default display is designed to be clean:

* Wave volume columns are ON.
* Average completed wave volume line is ON.
* Wave volume line is OFF.
* Effort/result line is OFF.

The colors are designed to make wave states easier to separate visually:

* Normal up wave: green
* Normal down wave: red
* High effort up wave: yellow
* High effort down wave: blue

Users can change all colors from the settings.

10. How to Use

A practical workflow:

1. Add the indicator to the chart.

2. Watch how volume accumulates during each upward and downward wave.

3. Compare the current wave volume with the average completed wave volume line.

4. Look for high effort waves when the columns change to the high-effort colors.

5. Compare wave volume with price progress.

6. Review whether large effort produced strong movement or weak movement.

7. Combine the reading with support, resistance, trend direction, market structure, and volume context.

8. Avoid using wave color alone as a trade signal.

9. Suggested Use Cases

Weis Wave Oscillator can be useful for:

* Volume wave analysis
* Effort-versus-result review
* Wyckoff-style volume interpretation
* Comparing buying and selling pressure
* Studying absorption or inefficient effort
* Reviewing support and resistance reactions
* Confirming or questioning directional moves
* Identifying waves with unusually high participation

12. Important Usage Note

This indicator does not tell users when to buy or sell.

It does not predict future price movement.

It does not guarantee continuation.

It does not guarantee reversal.

It does not identify support or resistance by itself.

It only groups volume into directional waves and highlights wave effort.

Users should treat the output as an analytical layer, not as a standalone trading system.

13. Limitations

Wave direction is based on confirmed pivots, so wave changes may appear after the actual turning point.

The indicator can behave differently across timeframes.

Volume data quality can vary by market and symbol.

On markets with unreliable or synthetic volume, the interpretation may be less useful.

A high effort wave can appear before continuation, reversal, or consolidation.

Users should always review the broader chart context before making any trading decision.

14. Alerts

The script includes alert conditions for:

* New up wave
* New down wave
* High effort wave

Alerts are notifications only. They do not place orders and do not confirm broker execution.

15. Educational Disclaimer

This script is for educational and chart-analysis purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. Users are responsible for their own analysis, risk management, and trading decisions.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) ADXAE

//@version=6
// ============================================================================
// Weis Wave Oscillator
// ============================================================================
// Weis Wave Oscillator accumulates volume across confirmed directional price waves.
//
// Instead of reading volume bar by bar, this indicator groups volume into
// directional waves and accumulates the volume inside each wave.
//
// The goal is to help users compare effort versus result:
//
// - A rising wave-volume column means volume is accumulating inside the current wave.
// - The column direction/color represents the confirmed wave direction.
// - High effort waves are highlighted when accumulated wave volume exceeds
//   the selected average-wave threshold.
//
// Important:
// Wave direction is based on confirmed pivots. Because pivots require future
// bars to confirm, wave changes may appear with delay. This is expected
// behavior for pivot-based wave analysis.
//
// This is an indicator, not a strategy.
// It does not provide buy or sell recommendations.
// ============================================================================

indicator("Weis Wave Oscillator", "Weis Wave Oscillator", format = format.volume, precision = 0, timeframe = "")

// ============================================================================
// Inputs
// ============================================================================

grpWave = "1) Wave Logic"

pivotLen = input.int(
     3,
     "Wave reversal bars",
     minval = 1,
     maxval = 20,
     group = grpWave,
     tooltip = "Controls how many bars are needed to confirm a wave reversal. Lower values create more frequent waves. Higher values create fewer and larger waves, but confirmation becomes slower.")

src = input.source(
     close,
     "Source",
     group = grpWave,
     tooltip = "Price source used to detect pivot highs and lows for wave direction. Close is the default.")

grpEffort = "2) Effort Analysis"

avgWaveLen = input.int(
     20,
     "Average wave volume length",
     minval = 2,
     group = grpEffort,
     tooltip = "Number of completed waves used to calculate the average wave volume reference line.")

showAvgLine = input.bool(
     true,
     "Show average wave volume line",
     group = grpEffort,
     tooltip = "Shows the average completed wave volume line. This helps compare the current wave volume against recent completed wave activity.")

highlightHighEffort = input.bool(
     true,
     "Highlight high effort waves",
     group = grpEffort,
     tooltip = "When enabled, the active wave changes to a special color if its accumulated volume is greater than the average completed wave volume multiplied by the selected high-effort factor.")

highEffortMult = input.float(
     1.50,
     "High effort wave x average",
     minval = 1.0,
     step = 0.10,
     group = grpEffort,
     tooltip = "Multiplier used to define a high-effort wave. Example: 1.50 means the wave volume must be at least 150% of the average completed wave volume.")

grpResult = "3) Optional Result Measurement"

showResultLine = input.bool(
     false,
     "Show effort / result line",
     group = grpResult,
     tooltip = "Optional. Shows a ratio between completed wave volume and absolute price progress. OFF by default to keep the pane clean.")

resultScale = input.float(
     1000000.0,
     "Effort / result scale",
     minval = 1.0,
     step = 1000.0,
     group = grpResult,
     tooltip = "Scaling value used to make the effort/result line easier to view in the same pane. It does not change the core wave-volume calculation.")

grpDisplay = "4) Display"

showColumns = input.bool(
     true,
     "Show wave volume columns",
     group = grpDisplay,
     tooltip = "Shows the main wave-volume columns. This is the core visual output of the indicator.")

showWaveLine = input.bool(
     false,
     "Show wave volume line",
     group = grpDisplay,
     tooltip = "Shows the wave volume as a line. OFF by default because columns are usually clearer.")

columnWidth = input.int(
     4,
     "Column width",
     minval = 1,
     maxval = 5,
     group = grpDisplay,
     tooltip = "Controls the visual thickness of the wave-volume columns. Higher values make columns easier to see.")

lineWidth = input.int(
     2,
     "Line width",
     minval = 1,
     maxval = 4,
     group = grpDisplay,
     tooltip = "Controls the thickness of the optional wave-volume line and optional effort/result line.")

avgLineWidth = input.int(
     2,
     "Average line width",
     minval = 1,
     maxval = 4,
     group = grpDisplay,
     tooltip = "Controls the thickness of the average completed wave volume reference line.")

grpColors = "5) Colors"

upWaveColor = input.color(
     color.new(#00C853, 0),
     "Up wave color",
     group = grpColors,
     tooltip = "Color used for normal upward volume waves. Default is strong green.")

downWaveColor = input.color(
     color.new(#FF1744, 0),
     "Down wave color",
     group = grpColors,
     tooltip = "Color used for normal downward volume waves. Default is strong red.")

highEffortUpColor = input.color(
     color.new(#FFD600, 0),
     "High effort up wave color",
     group = grpColors,
     tooltip = "Color used when an upward wave reaches the high-effort threshold. Default is yellow for clear separation from normal green.")

highEffortDownColor = input.color(
     color.new(#2979FF, 0),
     "High effort down wave color",
     group = grpColors,
     tooltip = "Color used when a downward wave reaches the high-effort threshold. Default is blue for clear separation from normal red.")

neutralColor = input.color(
     color.new(#9E9E9E, 30),
     "Neutral color",
     group = grpColors,
     tooltip = "Fallback color used when the wave direction is not yet clearly initialized.")

avgColor = input.color(
     color.new(#616161, 0),
     "Average line color",
     group = grpColors,
     tooltip = "Color used for the average completed wave volume reference line.")

resultColor = input.color(
     color.new(#7B1FA2, 0),
     "Effort / result line color",
     group = grpColors,
     tooltip = "Color used for the optional effort/result line.")

// ============================================================================
// Pivot-based wave direction
// ============================================================================

pivotHigh = ta.pivothigh(src, pivotLen, pivotLen)
pivotLow = ta.pivotlow(src, pivotLen, pivotLen)

upFlip = not na(pivotLow)
downFlip = not na(pivotHigh)

var int waveDir = 0

newDir = waveDir

if upFlip
    newDir := 1

if downFlip
    newDir := -1

if waveDir == 0
    newDir := 1

flip = newDir != waveDir

// ============================================================================
// Wave volume and result tracking
// ============================================================================

var float waveVolume = 0.0
var float waveStartPrice = na
var float completedWaveVolume = na
var float completedWaveResultPct = na
var int completedWaveDir = 0

if na(waveStartPrice)
    waveStartPrice := src

if flip
    completedWaveVolume := waveVolume
    completedWaveResultPct := waveStartPrice != 0.0 ? (src - waveStartPrice) / waveStartPrice * 100.0 : 0.0
    completedWaveDir := waveDir

    waveDir := newDir
    waveVolume := volume
    waveStartPrice := src
else
    waveVolume += volume
    waveDir := newDir

// ============================================================================
// Average completed wave volume
// ============================================================================

completedForAvg = flip and not na(completedWaveVolume) ? completedWaveVolume : na

avgWaveVolumeRaw = ta.sma(completedForAvg, avgWaveLen)

avgWaveVolume = ta.valuewhen(not na(avgWaveVolumeRaw), avgWaveVolumeRaw, 0)

validAvg = not na(avgWaveVolume) and avgWaveVolume > 0

activeHighEffort = highlightHighEffort and validAvg and waveVolume > avgWaveVolume * highEffortMult

completedHighEffort = flip and validAvg and completedWaveVolume > avgWaveVolume * highEffortMult

// ============================================================================
// Effort / Result measurement
// ============================================================================

absResult = math.abs(completedWaveResultPct)

effortResultRaw = flip and absResult > 0 ? completedWaveVolume / absResult : na

effortResultScaled = effortResultRaw / resultScale

// ============================================================================
// Plot colors
// ============================================================================

baseWaveColor = waveDir == 1 ? upWaveColor : waveDir == -1 ? downWaveColor : neutralColor

waveColor = activeHighEffort ?
     waveDir == 1 ? highEffortUpColor : highEffortDownColor :
     baseWaveColor

// ============================================================================
// Plots
// ============================================================================

plot(
     showColumns ? waveVolume : na,
     title = "Wave Volume",
     color = waveColor,
     style = plot.style_columns,
     linewidth = columnWidth)

plot(
     showWaveLine ? waveVolume : na,
     title = "Wave Volume Line",
     color = waveColor,
     style = plot.style_line,
     linewidth = lineWidth)

plot(
     showAvgLine ? avgWaveVolume : na,
     title = "Average Completed Wave Volume",
     color = avgColor,
     linewidth = avgLineWidth)

plot(
     showResultLine ? effortResultScaled : na,
     title = "Effort / Result",
     color = resultColor,
     linewidth = lineWidth,
     style = plot.style_line)

hline(
     0,
     "Zero",
     color = color.new(color.gray, 70),
     linestyle = hline.style_solid)

// ============================================================================
// Alerts
// ============================================================================

alertcondition(
     flip and waveDir == 1,
     title = "New Up Wave",
     message = "Weis Wave Oscillator: new up wave started on {{ticker}} {{interval}}")

alertcondition(
     flip and waveDir == -1,
     title = "New Down Wave",
     message = "Weis Wave Oscillator: new down wave started on {{ticker}} {{interval}}")

alertcondition(
     completedHighEffort,
     title = "High Effort Wave",
     message = "Weis Wave Oscillator: completed wave volume exceeded the selected high-effort threshold on {{ticker}} {{interval}}")

// ============================================================================
// End of file
// ============================================================================
````
