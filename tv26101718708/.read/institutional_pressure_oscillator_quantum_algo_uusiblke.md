# Institutional Pressure Oscillator [Quantum Algo]

- url: https://www.tradingview.com/script/uusIBLke-Institutional-Pressure-Oscillator-Quantum-Algo/
- type: indicator
- pine_id: PUB;d960c156d65c4488922b539a8a2fead4
- version: 2.0

## Description

[b]OVERVIEW[/b]

This oscillator measures directional volume pressure using a volatility-adaptive filter to separate institutional conviction from market noise. Unlike standard volume indicators that treat all bars equally or use simple up-close/down-close attribution, this tool applies logarithmic normalization and an adaptive noise gate to classify each bar as accumulation pressure, distribution pressure, or neutral - then accumulates that classified pressure over a rolling window.

The result is a zero-centered oscillator that shows whether net buying or selling pressure is dominant, how strong the conviction is behind the current move, and where momentum shifts are occurring.


[b]HOW IT WORKS
[/b]
The oscillator is built in five stages:

1. Logarithmic Price Differential - Computes log-returns between consecutive bars instead of raw price change. This normalization ensures the noise gate behaves consistently across instruments of any price scale, from sub-penny assets to five-figure contracts.

2. Adaptive Noise Gate - A rolling 30-bar standard deviation of log-returns establishes the current volatility regime. The Noise Gate Sensitivity parameter scales this dispersion into a dynamic threshold. Price moves below the threshold are classified as noise and receive zero pressure attribution. This prevents low-conviction, choppy bars from polluting the reading.

3. Participation Normalization - A rolling average of volume over the accumulation window establishes a baseline of normal participation. Any single bar's contribution is capped at a configurable multiple of this baseline (the Participation Cap). This prevents flash crashes, wash trades, or anomalous volume spikes from dominating the oscillator.

4. Directional Classification - Each bar that passes the noise gate is assigned its capped volume as either positive (price moved up through the gate) or negative (price moved down through the gate). Bars that fail the gate in both directions contribute nothing.

5. Cumulative Pressure and Signal Generation - Classified pressure is summed over the accumulation window, divided by the participation baseline, and optionally smoothed. An EMA-based trigger line tracks the oscillator, and the difference between the two forms the conviction histogram.


[b]WHAT MAKES THIS DIFFERENT FROM STANDARD VOLUME INDICATORS
[/b]
Standard volume bars show participation but not direction. OBV and similar cumulative indicators assign direction based on whether the close is higher or lower than the previous close - a simplistic classification that is noisy and unreliable, especially on wicks and dojis.

This oscillator addresses both problems:

The logarithmic noise gate dynamically filters out bars where price movement is too small relative to current volatility to represent genuine directional conviction. This means the oscillator only counts volume on bars where price actually moved meaningfully.

The participation cap prevents anomalous single-bar volume from distorting the cumulative reading. In crypto markets especially, exchange-generated volume spikes, liquidation cascades, and wash trading can create misleading signals on traditional volume indicators. The cap normalizes these outliers automatically.

The conviction histogram adds a momentum dimension that most flow indicators lack. It shows not just whether pressure is positive or negative, but whether it is accelerating or decelerating - providing an additional layer of timing information.

The logarithmic normalization means the same parameter settings produce consistent signal quality across any instrument and any price level without manual adjustment.


[b]HOW TO READ
[/b]
Oscillator above zero: Net buying pressure is dominant. The further above zero, the stronger the conviction.

Oscillator below zero: Net selling pressure is dominant. Depth below zero reflects selling conviction.

Trigger line crossover (bullish): The oscillator crosses above its trigger line. Buying pressure momentum is accelerating.

Trigger line crossover (bearish): The oscillator crosses below its trigger line. Selling pressure momentum is accelerating.

Conviction histogram expanding: The spread between the oscillator and trigger line is growing. The current directional pressure is gaining strength.

Conviction histogram contracting: The spread is narrowing. The current move is losing momentum. Often precedes a crossover or a pressure zone flip.

Divergence vs. price: When price makes a higher high but the oscillator makes a lower high (or vice versa), volume participation is not confirming the price move. This is one of the most reliable early warnings the oscillator provides.


[b]HOW TO USE
[/b]
1. Use the pressure zone (above or below zero) to define directional bias. Above zero favors long setups. Below zero favors short setups.

2. Use trigger line crossovers for entry timing. A bullish crossover in a positive pressure zone confirms buying acceleration. A bearish crossover in a negative pressure zone confirms selling acceleration.

3. Watch for divergences between price and the oscillator. A new price high with a lower oscillator high suggests the move is losing institutional backing.

4. Use the conviction histogram to gauge the strength behind the current pressure. Expanding bars confirm momentum. Contracting bars warn that the current bias may be weakening.

5. Works on any market and any timeframe. Particularly effective on crypto perpetuals on 4H and Daily timeframes where institutional volume patterns are most visible, and on swing trading setups where you want to confirm that volume supports a breakout or breakdown.


[b]SETTINGS
[/b]
Accumulation Window (default 130): The lookback period for cumulative pressure calculation. Higher values produce smoother, trend-oriented readings. Lower values increase sensitivity to recent participation shifts.

Noise Gate Sensitivity (default 0.2): Controls the volatility-scaled threshold below which price moves are ignored. Increasing this value makes the oscillator more selective. Decreasing it allows weaker moves to influence the reading.

Participation Cap (default 2.5): Limits any single bar's volume contribution to this multiple of the rolling average. Essential for markets where volume anomalies are common.

Trigger Line Smoothing (default 5): EMA period for the trigger line. Lower values give faster crossover signals with more noise. Higher values produce more reliable but later signals.

Extra Smoothing (default off): Applies an additional SMA pass to the oscillator for a cleaner line at the cost of added lag.

Show Conviction Histogram: Toggles the histogram bars displaying momentum spread between the oscillator and its trigger line.

Show Pressure Zones: Enables shading between the oscillator and zero line with distinct colors for accumulation and distribution phases.

Show Crossover Signals: Plots circular markers at bars where the oscillator crosses its trigger line.

## Source Code

````pine
// This Pine Script(TM) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) QuantumAlgo

//@version=6
indicator(title="Institutional Pressure Oscillator [Quantum Algo]", shorttitle="Pressure Oscillator [Quantum Algo]", overlay=false, precision=2)

// -----------------------------------------------------------------------------
//  Institutional Pressure Oscillator
//
//  Detects hidden accumulation and distribution by measuring directional 
//  pressure behind each bar's volume. Applies a logarithmic volatility. 
//  filter to separate institutional conviction from market noise, then 
//  normalizes the result against a rolling participation baseline.
//
//  How To Read:
//  - Oscillator above zero   = net buying pressure (accumulation phase)
//  - Oscillator below zero   = net selling pressure (distribution phase)
//  - Trigger line cross up   = pressure momentum shifting bullish
//  - Trigger line cross down = pressure momentum shifting bearish
//  - Histogram expanding     = conviction increasing behind the move
//  - Histogram contracting   = conviction fading, watch for reversal
//  - Divergence vs price     = early warning of trend exhaustion
// -----------------------------------------------------------------------------

// -- Pressure Engine ---------------------------------------------------------
grp_engine = "Pressure Engine"
pressureWindow   = input.int(130, title="Accumulation Window", minval=10, maxval=500, tooltip="Number of bars over which directional pressure is accumulated. Longer windows produce smoother readings. Shorter windows react faster.", group=grp_engine)
noiseGate        = input.float(0.2, title="Noise Gate Sensitivity", minval=0.01, maxval=1.0, step=0.01, tooltip="Controls how aggressively small price moves are filtered out. Higher values require stronger directional conviction before volume is counted.", group=grp_engine)
participationCap = input.float(2.5, title="Participation Cap", minval=1.0, maxval=10.0, step=0.1, tooltip="Limits any single bar's influence to this multiple of the average participation level. Prevents flash spikes from distorting the oscillator.", group=grp_engine)
triggerSmoothing = input.int(5, title="Trigger Line Smoothing", minval=1, maxval=50, tooltip="EMA period for the trigger line. Lower values produce earlier but noisier crossover signals.", group=grp_engine)
useExtraSmooth   = input.bool(false, title="Extra Smoothing", tooltip="Applies an additional moving average pass for a cleaner but more lagging reading.", group=grp_engine)

// -- Display Options ---------------------------------------------------------
grp_display = "Display Options"
showConviction     = input.bool(true, title="Show Conviction Histogram", tooltip="Displays the momentum difference between the oscillator and its trigger line as a histogram.", group=grp_display)
showPressureZones  = input.bool(true, title="Show Pressure Zones", tooltip="Shades the area between the oscillator and zero to distinguish accumulation from distribution phases.", group=grp_display)
showCrossSignals   = input.bool(true, title="Show Crossover Signals", tooltip="Marks bars where the oscillator crosses its trigger line.", group=grp_display)

// -- Colors ------------------------------------------------------------------
grp_palette = "Colors"
col_accumulation = input.color(#00e5ff, title="Accumulation Pressure", group=grp_palette)
col_distribution = input.color(#7c4dff, title="Distribution Pressure", group=grp_palette)
col_trigger      = input.color(#ff6d00, title="Trigger Line", group=grp_palette)
col_convictUp    = input.color(#00e5ff, title="Conviction Rising", group=grp_palette)
col_convictDown  = input.color(#7c4dff, title="Conviction Falling", group=grp_palette)
col_baseline     = input.color(#455a64, title="Baseline", group=grp_palette)

// -- Core Logic --------------------------------------------------------------

applySmoothing(float src, int len) =>
    useExtraSmooth ? ta.sma(src, len) : src

// Step 1: Logarithmic Price Differential
anchorPrice = hlc3
logDelta    = math.log(anchorPrice) - math.log(anchorPrice[1])

// Step 2: Adaptive Volatility Noise Gate
dispersion    = ta.stdev(logDelta, 30)
gateThreshold = noiseGate * dispersion * close

// Step 3: Participation Normalization
baselineParticipation = ta.sma(volume, pressureWindow)[1]
participationCeiling  = baselineParticipation * participationCap
normalizedActivity    = math.min(volume, participationCeiling)

// Step 4: Directional Pressure Classification
barDelta           = anchorPrice - anchorPrice[1]
classifiedPressure = barDelta > gateThreshold ? normalizedActivity : barDelta < -gateThreshold ? -normalizedActivity : 0.0

// Step 5: Cumulative Pressure Oscillator
pressureOscillator = applySmoothing(math.sum(classifiedPressure, pressureWindow) / baselineParticipation, 3)

// Step 6: Trigger Line and Conviction Spread
triggerLine      = ta.ema(pressureOscillator, triggerSmoothing)
convictionSpread = pressureOscillator - triggerLine

// State Classification
isAccumulating = pressureOscillator >= 0
isConvictionUp = convictionSpread >= 0
bullishShift   = ta.crossover(pressureOscillator, triggerLine)
bearishShift   = ta.crossunder(pressureOscillator, triggerLine)

// -- Visuals -----------------------------------------------------------------

hline(0, title="Neutral Baseline", color=col_baseline, linestyle=hline.style_dashed, linewidth=1)

convictionColor = isConvictionUp ? color.new(col_convictUp, 55) : color.new(col_convictDown, 55)
plot(showConviction ? convictionSpread : na, title="Conviction Histogram", style=plot.style_columns, color=convictionColor, linewidth=3)

oscillatorColor = isAccumulating ? col_accumulation : col_distribution
pOscillator = plot(pressureOscillator, title="Institutional Pressure", color=oscillatorColor, linewidth=2)

pTrigger = plot(triggerLine, title="Trigger Line", color=col_trigger, linewidth=1)

pBaseline = plot(showPressureZones ? 0 : na, title="Baseline Reference", display=display.none)
fill(pOscillator, pBaseline, color=showPressureZones and isAccumulating ? color.new(col_accumulation, 88) : showPressureZones and not isAccumulating ? color.new(col_distribution, 88) : na, title="Pressure Zone Fill")

plotshape(showCrossSignals and bullishShift ? pressureOscillator : na, title="Bullish Shift", style=shape.circle, location=location.absolute, color=col_accumulation, size=size.tiny)
plotshape(showCrossSignals and bearishShift ? pressureOscillator : na, title="Bearish Shift", style=shape.circle, location=location.absolute, color=col_distribution, size=size.tiny)

// -- Alerts ------------------------------------------------------------------

alertcondition(bullishShift, title="Bullish Pressure Shift", message="Institutional buying pressure momentum shifting bullish on {{ticker}} ({{interval}})")
alertcondition(bearishShift, title="Bearish Pressure Shift", message="Institutional selling pressure momentum shifting bearish on {{ticker}} ({{interval}})")
alertcondition(ta.crossover(pressureOscillator, 0), title="Accumulation Phase", message="Net pressure turned positive on {{ticker}} ({{interval}})")
alertcondition(ta.crossunder(pressureOscillator, 0), title="Distribution Phase", message="Net pressure turned negative on {{ticker}} ({{interval}})")
````
