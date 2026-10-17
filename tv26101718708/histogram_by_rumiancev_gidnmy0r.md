#  Histogram by Rumiancev

- url: https://www.tradingview.com/script/giDnMY0R-Histogram-by-Rumiancev/
- type: indicator
- pine_id: PUB;e375463ea0f442ccb11bcd408549628b
- version: 1.0

## Description

[b]Rumiancev Histogram R/S/M[/b]

Rumiancev Histogram R/S/M is an open-source momentum indicator designed to combine three analytical layers in a single pane: a histogram-based Ergodic-style momentum model, two optional EMA overlays applied directly to the histogram, and an optional Adaptive RSI module with its own signal line and centered levels.
[image]https://www.tradingview.com/x/HILOlgoV/[/image]
The goal of this script is to provide a compact but flexible momentum workspace. Instead of forcing the user to stack several separate tools on the chart, this script brings the main momentum histogram, short smoothing overlays, and an additional adaptive strength filter together in one place. The result is a cleaner workflow for traders who want to read momentum shifts, short-term acceleration, slowing conditions, and auxiliary RSI-style confirmation from a single panel.

[b]General idea[/b]

The script is built around a normalized momentum histogram. It measures bar-to-bar price change, smooths that movement in multiple stages, and compares directional movement against total movement. This allows the oscillator to focus not only on whether price is rising or falling, but also on how efficiently price is moving in one direction relative to overall fluctuation.

A signal line is applied to the main oscillator value, and the histogram represents the distance between the oscillator and that signal. This makes the histogram useful for tracking momentum expansion and momentum contraction around the zero line.

In addition to the histogram, the script can display two optional EMA lines derived from the histogram itself. These lines help users visually filter short-term noise and better judge whether recent histogram movement is strengthening, fading, or transitioning.

The script also includes an optional Adaptive RSI module. This is not plotted in the classic RSI panel style. Instead, it is centered around zero and scaled so it can coexist with the histogram in the same pane. This gives the user an extra confirmation layer without requiring a separate indicator window.

[b]How the main histogram works[/b]
[image]https://www.tradingview.com/x/LoSmjUrO/[/image]
The core oscillator uses the change in closing price from one bar to the next. First, the script calculates the raw directional change. Then it calculates the absolute value of that same change. These two series represent direction and total movement.

Both series are then smoothed in two stages. The first stage uses the selected fast smoothing method and fast length. The second stage uses the selected slow smoothing method and slow length. After these smoothing steps, the script divides the smoothed directional movement by the smoothed absolute movement and multiplies the result by 100. This creates a normalized momentum reading.

That normalized reading becomes the main oscillator value. A separate signal line is then calculated using the selected signal smoothing method and signal length. The histogram is the difference between the main oscillator and the signal line.

This construction allows the histogram to react to changing momentum conditions while remaining more structured than a simple unsmoothed rate-of-change style plot.

[b]How to read the histogram[/b]

When the histogram is above zero, the main oscillator is above its signal line, which suggests positive momentum pressure. When the histogram is below zero, the main oscillator is below its signal line, which suggests negative momentum pressure.
[image]https://www.tradingview.com/x/kE5W6bxH/[/image]
If histogram bars are growing while already above zero, that often means bullish momentum is strengthening. If histogram bars are shrinking above zero, bullish pressure may still be present, but it is losing force. The same logic applies below zero: expanding negative bars can suggest increasing bearish pressure, while shrinking negative bars can suggest that bearish momentum is weakening.

The zero line is the main structural reference. Crosses above and below zero can be used to identify transitions in short-term momentum balance. However, like any momentum tool, the histogram should be interpreted in context, especially when price is ranging or when volatility suddenly expands.

[b]EMA overlays on the histogram[/b]

The script includes two optional EMA lines, named Yellow EMA and Blue EMA in the settings. These are calculated from the histogram values, not from price.
[image]https://www.tradingview.com/x/LqIRQAcU/[/image]
Their purpose is visual smoothing. Some traders prefer to read the raw histogram alone. Others prefer to see one or two smoothed references that make short swings easier to interpret. Because these EMAs are applied to the histogram, they can help reveal whether momentum is accelerating into a move, flattening, or starting to roll over before a more visible shift in the histogram bars occurs.

The Yellow EMA is typically used as the faster smoothing line, while the Blue EMA can be treated as the slower companion line. Users may keep both hidden, display one of them, or display both depending on their preferred chart-reading style.

[b]Adaptive RSI module[/b]

The Adaptive RSI included in this script is designed as an auxiliary momentum filter rather than a standard standalone RSI replacement. Instead of using the classic up-close versus down-close averaging approach only, this version evaluates directional pressure using the relationship between recent range expansion, recent range contraction, and ordinary bar-to-bar movement.
[image]https://www.tradingview.com/x/MZYp2f0a/[/image]
The script first examines the highest and lowest values over the selected RSI length. From there it measures whether the recent range is expanding upward, expanding downward, or whether current movement is better represented by the direct step from one bar to the next. That directional movement is then smoothed, compared to its absolute magnitude, and transformed into an RSI-style value centered around 50.

To make this RSI usable inside the same pane as the histogram, the script recenters it around zero by subtracting 50 and then multiplying the result by the RSI Scale input. The signal line for the Adaptive RSI is calculated separately using its own signal length and smoothing mode.

This gives the user a secondary confirmation line that can be visually aligned with the histogram without opening another indicator panel.

[b]How to read the Adaptive RSI in this script[/b]

Because the Adaptive RSI is centered and scaled, it should not be interpreted exactly like a classic RSI pane. Its purpose here is relative confirmation.
[image]https://www.tradingview.com/x/TpeCNJdW/[/image]
If the Adaptive RSI is rising and the histogram is also strengthening, the two layers are confirming each other. If the histogram is trying to recover while the Adaptive RSI remains weak or rolls over quickly, that may suggest the move has limited follow-through. If both the histogram and the Adaptive RSI signal line turn together, momentum alignment is clearer. If one improves while the other lags, the market may be in transition or lacking conviction.

The optional overbought, midline, and oversold levels provide extra visual structure for this centered RSI display. Since the RSI is scaled into the histogram pane, these levels are translated into centered equivalents instead of being shown as standard 70, 50, and 30 horizontal lines in a separate RSI panel.

[b]Input settings explained[/b]

Fast Length controls the first smoothing stage of the main momentum calculation. Smaller values make the oscillator more responsive. Larger values make it smoother and slower.

Slow Length controls the second smoothing stage of the main oscillator. Increasing it generally reduces noise further and creates a more stable but slower-moving histogram.

Signal Length controls how quickly the oscillator signal line responds. A shorter signal length makes the histogram react faster because the gap between oscillator and signal changes more quickly. A longer signal length tends to produce smoother histogram transitions.

Fast Smoothing determines the smoothing method used in the first stage of the oscillator calculation. Slow Smoothing determines the smoothing method used in the second stage. Signal Smoothing determines the smoothing method used for the oscillator signal line. Available choices are EMA, SMA, RMA, WMA, HMA, and TMA.

Yellow EMA enables or disables the first histogram EMA overlay. Blue EMA enables or disables the second histogram EMA overlay.

Yellow EMA Length sets the period for the faster EMA overlay on the histogram. Blue EMA Length sets the period for the second EMA overlay.

Show Adaptive RSI enables or disables the centered Adaptive RSI line.

Show RSI Signal enables or disables the signal line of the Adaptive RSI.

Show RSI Levels enables or disables the centered overbought, midline, and oversold reference levels for the Adaptive RSI display.

RSI Source defines which price source is used for the Adaptive RSI calculation. The default is HLC3, but the user can choose any source supported by Pine input.source.

RSI Length controls the lookback used by the Adaptive RSI model.

RSI Smoothing selects the smoothing method applied inside the Adaptive RSI calculation.

RSI Signal Length controls the smoothing length of the Adaptive RSI signal line.

Signal Smoothing in the RSI section selects the smoothing method used for the Adaptive RSI signal line.

RSI Scale controls how strongly the centered RSI is expanded or compressed inside the histogram pane. Lower values make the RSI layer more compact. Higher values make it visually more pronounced.

RSI Overbought sets the upper reference threshold used by the Adaptive RSI.

RSI Oversold sets the lower reference threshold used by the Adaptive RSI.

[b]Smoothing modes explained briefly[/b]

EMA responds relatively quickly and is often a good default for momentum work.

SMA is straightforward and balanced, but usually a bit slower in turning points.

RMA is smoother and often produces steadier transitions.

WMA places more emphasis on recent values than SMA.

HMA is generally more responsive and may suit users who want faster turning behavior with reduced lag.

TMA is heavily smoothed and may suit users who prefer a calmer visual structure over fast reaction.

Different smoothing combinations can materially change the character of the indicator. A user looking for responsiveness may prefer faster lengths and more reactive smoothing types. A user focused on broader trend pressure may prefer heavier smoothing and longer lengths.

[b]Practical ways to use the script[/b]

One common approach is to use the histogram as the primary trigger layer and the Adaptive RSI as a confirmation filter. In that workflow, the user watches for histogram recovery from negative values, histogram expansion above zero, or histogram contraction below zero, then checks whether the Adaptive RSI is moving in the same direction.

Another approach is to focus on momentum quality rather than signals. In that case, the user may ignore exact crosses and instead study whether histogram bars are expanding, flattening, or diverging in behavior from price structure. The EMA overlays can be helpful here because they smooth the histogram without hiding its basic structure.

Some users may also treat the script as a trend-phase tool. Sustained positive histogram behavior combined with a stable or rising Adaptive RSI can support a bullish phase reading. Sustained negative histogram behavior combined with weak Adaptive RSI behavior can support a bearish phase reading. Mixed readings can indicate consolidation, transition, or an early reversal attempt that still lacks confirmation.

[b]Important interpretation notes[/b]

This indicator is designed to measure momentum structure, not to predict the future. It should not be treated as a standalone trading system.

Momentum indicators can remain strong or weak for longer than expected during trending conditions. They can also produce frequent transitions during sideways markets. For that reason, this script is best used with price structure, higher timeframe context, risk management, and the user’s own trade process.

No divergence module is included in this version. The focus of the script is the histogram engine, histogram EMA overlays, and the Adaptive RSI confirmation layer.

[b]Who this script may be useful for[/b]

This script may be useful for traders who want a momentum-focused indicator that remains visually compact while still offering more than a single raw oscillator line. It can suit discretionary traders who read chart structure manually, as well as users who want a clean supporting tool for directional bias, momentum confirmation, or timing refinement.

It may be especially useful for users who like histogram-based momentum analysis but also want an additional internal filter without loading a second separate RSI pane.

[b]Open-source note[/b]

This script is published as open-source so traders and Pine users can study the logic, verify how it works, adapt it to their own process, and build on it if they find it useful.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// © Rumiancev

//@version=6
indicator("Rumiancev Histogram R/S/M", overlay = false)

//=====================================================================
// Inputs
//=====================================================================
groupMain = "Main Settings"
groupMa   = "Average Lines"
groupRsi  = "Adaptive RSI"

fastLength   = input.int(100, "Fast Length", minval = 1, group = groupMain)
slowLength   = input.int(25, "Slow Length", minval = 1, group = groupMain)
signalLength = input.int(9, "Signal Length", minval = 1, group = groupMain)

fastMaType   = input.string("EMA", "Fast Smoothing", options = ["EMA", "SMA", "RMA", "WMA", "HMA", "TMA"], group = groupMain)
slowMaType   = input.string("EMA", "Slow Smoothing", options = ["EMA", "SMA", "RMA", "WMA", "HMA", "TMA"], group = groupMain)
signalMaType = input.string("EMA", "Signal Smoothing", options = ["EMA", "SMA", "RMA", "WMA", "HMA", "TMA"], group = groupMain)

showYellowEma = input.bool(false, "Yellow EMA", group = groupMa, inline = "emaToggles")
showBlueEma   = input.bool(false, "Blue EMA", group = groupMa, inline = "emaToggles")

yellowLength = input.int(5, "Yellow EMA Length", minval = 1, group = groupMa)
blueLength   = input.int(9, "Blue EMA Length", minval = 1, group = groupMa)

// Adaptive RSI
showRsi         = input.bool(false, "Show Adaptive RSI", group = groupRsi)
showRsiSignal   = input.bool(false, "Show RSI Signal", group = groupRsi)
showRsiLevels   = input.bool(false, "Show RSI Levels", group = groupRsi)
rsiSource       = input.source(hlc3, "RSI Source", group = groupRsi)
rsiLength       = input.int(14, "RSI Length", minval = 2, group = groupRsi)
rsiSmoothing    = input.string("RMA", "RSI Smoothing", options = ["EMA", "SMA", "RMA", "WMA", "HMA", "TMA"], group = groupRsi)
rsiSignalLength = input.int(10, "RSI Signal Length", minval = 1, group = groupRsi)
rsiSignalMode   = input.string("EMA", "Signal Smoothing", options = ["EMA", "SMA", "RMA", "WMA", "HMA", "TMA"], group = groupRsi)
rsiScale        = input.float(0.12, "RSI Scale", minval = 0.05, step = 0.05, group = groupRsi)
rsiObLevel      = input.float(75.0, "RSI Overbought", minval = 50, maxval = 100, group = groupRsi)
rsiOsLevel      = input.float(25.0, "RSI Oversold", minval = 0, maxval = 50, group = groupRsi)

//=====================================================================
// Functions
//=====================================================================
applySmoothing(series float value, int len, string mode) =>
    safeLen = math.max(len, 1)
    hullLen = math.max(1, math.round(math.sqrt(safeLen)))
    switch mode
        "EMA" => ta.ema(value, safeLen)
        "SMA" => ta.sma(value, safeLen)
        "RMA" => ta.rma(value, safeLen)
        "WMA" => ta.wma(value, safeLen)
        "HMA" => ta.wma(2.0 * ta.wma(value, math.max(1, math.floor(safeLen / 2))) - ta.wma(value, safeLen), hullLen)
        "TMA" => ta.sma(ta.sma(value, safeLen), safeLen)

calcErgodicOscillator(src, fastLen, slowLen, sigLen, fastMode, slowMode, sigMode) =>
    delta = src - src[1]
    absDelta = math.abs(delta)

    stage1 = applySmoothing(delta, fastLen, fastMode)
    stage2 = applySmoothing(absDelta, fastLen, fastMode)

    stage3 = applySmoothing(stage1, slowLen, slowMode)
    stage4 = applySmoothing(stage2, slowLen, slowMode)

    smiValue = stage4 != 0 ? stage3 / stage4 * 100.0 : 0.0
    signalValue = applySmoothing(smiValue, sigLen, sigMode)
    oscValue = smiValue - signalValue

    [smiValue, signalValue, oscValue]

calcAdaptiveRsi(src, len, smoothMode, signalLen, signalMode) =>
    highestValue = ta.highest(src, len)
    lowestValue  = ta.lowest(src, len)
    rangeWidth   = highestValue - lowestValue
    stepMove     = src - src[1]

    directionalMove =
         highestValue > highestValue[1] ? rangeWidth :
         lowestValue < lowestValue[1] ? -rangeWidth :
         stepMove

    smoothedMove    = applySmoothing(directionalMove, len, smoothMode)
    smoothedAbsMove = applySmoothing(math.abs(directionalMove), len, smoothMode)

    baseRsi = smoothedAbsMove != 0 ? 50.0 + 50.0 * smoothedMove / smoothedAbsMove : 50.0
    signalRsi = applySmoothing(baseRsi, signalLen, signalMode)

    [baseRsi, signalRsi]

//=====================================================================
// Core Calculation
//=====================================================================
[smi, signal, histogram] = calcErgodicOscillator(close, fastLength, slowLength, signalLength, fastMaType, slowMaType, signalMaType)

yellowEma = ta.ema(histogram, yellowLength)
blueEma   = ta.ema(histogram, blueLength)

[adaptiveRsi, adaptiveRsiSignal] = calcAdaptiveRsi(rsiSource, rsiLength, rsiSmoothing, rsiSignalLength, rsiSignalMode)

adaptiveRsiCentered       = (adaptiveRsi - 50.0) * rsiScale
adaptiveRsiSignalCentered = (adaptiveRsiSignal - 50.0) * rsiScale

rsiOverboughtLine = (rsiObLevel - 50.0) * rsiScale
rsiOversoldLine   = (rsiOsLevel - 50.0) * rsiScale

histogramColor = histogram >= 0 ? #FF0000 : #007B00
adaptiveRsiColor = adaptiveRsi > rsiObLevel ? color.new(color.green, 20) : adaptiveRsi < rsiOsLevel ? color.new(color.red, 20) : color.new(color.silver, 20)

//=====================================================================
// Plots
//=====================================================================
plot(histogram, title = "SMI Ergodic Oscillator", style = plot.style_columns, color = histogramColor, linewidth = 2)
plot(showYellowEma ? yellowEma : na, title = "Yellow EMA", color = color.yellow, linewidth = 1)
plot(showBlueEma ? blueEma : na, title = "Blue EMA", color = color.blue, linewidth = 1)

plot(showRsi ? adaptiveRsiCentered : na, title = "Adaptive RSI", color = adaptiveRsiColor, linewidth = 1)
plot(showRsiSignal ? adaptiveRsiSignalCentered : na, title = "Adaptive RSI Signal", color = color.new(#ff5d00, 30), linewidth = 1)

plot(showRsiLevels ? rsiOverboughtLine : na, title = "RSI Overbought", color = #4caf4f4b, linewidth = 1)
plot(showRsiLevels ? 0 : na, title = "RSI Midline", color = #787b864d, linewidth = 1)
plot(showRsiLevels ? rsiOversoldLine : na, title = "RSI Oversold", color = #ff52524d, linewidth = 1)

hline(0, "Zero", color = #535300)
````
