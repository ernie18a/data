# Luminous Volume Flow & Breakout Matrix [Pineify]

- url: https://www.tradingview.com/script/8QTS89ip-Luminous-Volume-Flow-Breakout-Matrix-Pineify/
- type: indicator
- pine_id: PUB;825944f80b6147f5a56c3c31c64254bd
- version: 1.0

## Description

[b]Luminous Volume Flow & Breakout Matrix [Pineify][/b]

This indicator estimates directional money flow by splitting each bar's volume proportionally between buyers and sellers based on where price closed within its range. A close near the high attributes most volume to buying pressure; a close near the low attributes it to selling. The smoothed net delta becomes a volume momentum oscillator, while a separate statistical layer flags volume surges — bars where total volume exceeds its recent mean by a configurable number of standard deviations. When a surge aligns with a directional lean, it often marks the kind of institutional event that precedes sustained moves.

[b]Key Features[/b]

[list]
[*]Proportional volume splitting — fractional allocation based on close position within the bar's range, not a binary up/down classification

[*]EMA-smoothed volume delta oscillator with adaptive gradient coloring

[*]Statistical volume surge detection using a mean + standard deviation threshold

[*]Surge signals filtered by oscillator direction — bullish surges only fire when net flow is positive, bearish only when negative
[/list]

[b]How It Works[/b]

Rather than assigning all of a bar's volume to one side, the calculation uses a proportional model. If a bar's range is 10 points and the close sits 7 points above the low, 70% of volume is attributed to buying pressure and 30% to selling. This produces a continuous [i]volume delta[/i] that reflects intrabar conviction with more granularity than binary methods.

[list=1]
[*]For each bar, [i]buy volume[/i] = (close − low) / (high − low) × volume, and [i]sell volume[/i] = (high − close) / (high − low) × volume. Zero-range bars receive zero allocation to avoid division errors

[*]The raw delta (buy − sell) is smoothed with an EMA to strip out single-bar noise and reveal the underlying volume direction trend

[*]Independently, the indicator calculates a 20-bar SMA and standard deviation of total volume. Bars exceeding the mean by the configured multiplier times the standard deviation are flagged as surges

[*]The smoothed delta is normalized over a 50-bar window to a 0–1 range, then mapped to a bear-to-bull color gradient for visual momentum reading
[/list]

[b]How the Components Work Together[/b]

The volume delta oscillator and the surge detector answer two different questions. The oscillator reveals [i]direction[/i] — whether the prevailing volume is buyer- or seller-dominated. The surge detector reveals [i]magnitude[/i] — whether total participation is abnormally high. Neither signal alone is particularly useful: a volume spike in a mixed-delta environment is just noise, and steady directional flow without unusual volume is normal trending behavior.

The indicator combines both by only plotting surge markers when the oscillator confirms direction. A bullish triangle appears when volume exceeds the statistical threshold AND the smoothed delta is positive — meaning the abnormal volume is flowing toward buyers, not just appearing randomly. This two-filter approach reduces false signals from earnings gaps, data releases, or other events that produce big volume without clear directional intent.

[b]Trading Ideas and Insights[/b]

[list]
[*]A bullish surge triangle after a pullback into support may indicate institutional accumulation — the combination of extreme volume and positive delta suggests large buyers absorbing supply at a level they consider favorable

[*]Clusters of surge signals in the same direction over several bars carry more weight than isolated spikes. A single bar can be a data artifact; three or four surges in a week suggests a structural shift

[*]When the oscillator gradient fades from deep bull to neutral while price continues higher, consider that the move may be running on fumes — price is advancing but volume conviction is declining
[/list]

The proportional volume split is an approximation, not actual order flow data. Doji bars with small ranges but high volume will split nearly 50/50 regardless of the real buyer/seller composition. On instruments with thin volume or wide spreads, treat the oscillator as directional bias rather than precise measurement.

[b]Unique Aspects[/b]

[list]
[*]Proportional allocation produces a continuous delta spectrum rather than the binary all-or-nothing split many volume indicators use. A bar closing at 60% of its range assigns 60/40, preserving nuance that binary methods discard

[*]The surge detection is purely statistical — it adapts to the instrument's own volume profile rather than relying on fixed thresholds. A surge on a microcap and a surge on SPY are both defined relative to their own baselines

[*]Directional filtering of surges means the triangles only appear when both conditions align, making them relatively rare and targeted rather than noisy
[/list]

[b]How to Use[/b]

[list=1]
[*]Add the indicator to your chart. The colored columns show the smoothed volume delta — above zero means net buying pressure, below zero means net selling

[*]Watch the gradient intensity: deep, saturated colors indicate strong directional flow within the recent 50-bar context. Fading colors suggest conviction is weakening

[*]Look for triangle markers at the bottom (bullish surge) or top (bearish surge) of the indicator pane. These flag statistically unusual volume aligned with directional flow

[*]Adjust the Volume Surge Multiplier higher if you see too many signals — a value of 2.5–3.0 will isolate only the most extreme events
[/list]

[b]Customization[/b]

[list]
[*][b]Flow Smoothing Length[/b] (default: 14) — EMA period for the volume delta. Lower values track fast shifts in buying/selling pressure; higher values produce a smoother oscillator at the cost of 3–5 bars of additional lag

[*][b]Volume Surge Multiplier[/b] (default: 2.0) — How many standard deviations above the 20-bar volume mean qualifies as a surge. At 2.0, roughly 5% of bars will trigger in normally distributed volume; at 3.0, under 1%

[*][b]Bullish / Bearish Flow Color[/b] — Set the gradient endpoints for positive and negative volume flow. The gradient interpolates between these based on the oscillator's position within its 50-bar range
[/list]

[b]Conclusion[/b]

The Luminous Volume Flow & Breakout Matrix combines proportional volume splitting with statistical surge detection to surface moments where unusual volume carries clear directional intent. The oscillator provides continuous context on who controls the tape, while the surge markers highlight outlier events worth paying attention to. Best used as a confirmation layer alongside price structure — volume shows you the conviction behind a move, but not the map.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Pineify

//======================================================================//
//                    ____  _            _  __                          //
//                   |  _ \(_)_ __   ___(_)/ _|_   _                    //
//                   | |_) | | '_ \ / _ \ | |_| | | |                   //
//                   |  __/| | | | |  __/ |  _| |_| |                   //
//                   |_|   |_|_| |_|\___|_|_|  \__, |                   //
//                                             |___/                    //
//======================================================================//
//
// Luminous Volume Flow & Breakout Matrix
// ----------------------------------------
// Splits each bar's volume proportionally between buyers and sellers based
// on close position within the high-low range, then smooths the net delta
// into a momentum oscillator. A separate statistical layer detects volume
// surges — bars exceeding their 20-bar mean by N standard deviations.
//
// Core concepts:
//   1. Proportional volume split — continuous 0-100% allocation, not binary
//   2. EMA-smoothed delta — reveals underlying volume direction trend
//   3. Statistical surge detection — flags institutional-scale outlier bars
//

//@version=6
indicator("Luminous Volume Flow & Breakout Matrix [Pineify]",  format=format.volume)

//---------------------------------------------------------------------------------------------------------------------}
// INPUT SETTINGS
//---------------------------------------------------------------------------------------------------------------------{
GREEN = #089981
RED   = #F23645

grp_data  = "Calculations"
grp_style = "Aesthetics & Style"

lengthInput   = input.int(14, "Flow Smoothing Length", minval=1, group=grp_data, tooltip="EMA period for the volume delta oscillator. Lower values react faster to shifts in buying/selling pressure; higher values smooth out noise but add lag.")
thresholdMult = input.float(2.0, "Volume Surge Multiplier", step=0.5, group=grp_data, tooltip="Number of standard deviations above the 20-bar volume mean to qualify as a surge. At 2.0 roughly 5% of bars trigger; raise to 2.5–3.0 for rarer but stronger signals.")

bullColor = input.color(GREEN, "Bullish Flow Color", group=grp_style, tooltip="Gradient endpoint for positive (net buying) volume flow.")
bearColor = input.color(RED, "Bearish Flow Color", group=grp_style, tooltip="Gradient endpoint for negative (net selling) volume flow.")

//---------------------------------------------------------------------------------------------------------------------}
// CALCULATIONS
//---------------------------------------------------------------------------------------------------------------------{
// Proportional volume split: close position within the bar's range determines
// what fraction of total volume is attributed to buyers vs sellers.
// A close at 70% of the range → 70% buy volume, 30% sell volume.
barRange   = high - low
buyVolume  = barRange == 0 ? 0 : (close - low) / barRange * volume
sellVolume = barRange == 0 ? 0 : (high - close) / barRange * volume

deltaVolume = buyVolume - sellVolume

// EMA smoothing strips single-bar noise and reveals the directional trend
// in volume flow. The result oscillates around zero like a momentum indicator.
smoothedDelta = ta.ema(deltaVolume, lengthInput)

// Surge detection: bars where total volume exceeds mean + (stdev × multiplier)
// are statistically unusual — often linked to institutional activity or news events.
volMa        = ta.sma(volume, 20)
volDev       = ta.stdev(volume, 20)
volThreshold = volMa + (volDev * thresholdMult)
isSurge      = volume > volThreshold

// Normalize smoothed delta to [0, 1] over a 50-bar lookback for gradient mapping.
// This makes the color intensity adapt to recent conditions rather than using
// absolute values that would look different on every instrument.
highestDelta  = ta.highest(smoothedDelta, 50)
lowestDelta   = ta.lowest(smoothedDelta, 50)
gradientRatio = highestDelta == lowestDelta ? 0 : (smoothedDelta - lowestDelta) / (highestDelta - lowestDelta)

flowColor = color.from_gradient(gradientRatio, 0, 1, bearColor, bullColor)

//---------------------------------------------------------------------------------------------------------------------}
// PLOTTING & AESTHETICS
//---------------------------------------------------------------------------------------------------------------------{
plot(smoothedDelta, title="Volume Flow", color=flowColor, style=plot.style_columns)

// Surge markers only appear when direction aligns with the statistical outlier,
// filtering out directionless volume spikes from earnings, data releases, etc.
plotshape(isSurge and smoothedDelta > 0, title="Bullish Surge", style=shape.triangleup, location=location.bottom, color=bullColor, size=size.tiny)
plotshape(isSurge and smoothedDelta < 0, title="Bearish Surge", style=shape.triangledown, location=location.top, color=bearColor, size=size.tiny)

hline(0, "Equilibrium", color=color.new(color.gray, 50), linestyle=hline.style_dashed)
````
