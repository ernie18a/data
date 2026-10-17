# EMA Micro Trend Exhaustion

- url: https://www.tradingview.com/script/siDhdJ0m-EMA-Micro-Trend-Exhaustion/
- type: indicator
- pine_id: PUB;36d261a55c0645ddac7297f6b05f0c13
- version: 1.0

## Description

[b]Overview[/b]
EMA Micro Trend Exhaustion is a momentum oscillator that measures where a short-term Exponential Moving Average (EMA) is positioned relative to its own rolling range over a configurable lookback period.
Instead of evaluating price directly, the indicator analyzes the moving average itself. This approach helps reduce market noise and provides a clearer view of short-term trend extension.
The oscillator plots two histogram series:
• Distance from the current EMA to its highest EMA value within the lookback period.
• Distance from the current EMA to its lowest EMA value within the lookback period.
By measuring these distances, traders can quickly identify when short-term momentum becomes increasingly stretched.

[b]How It Works[/b]
The indicator first calculates a 10-period Exponential Moving Average.
It then determines the highest and lowest EMA values observed during the previous 10 bars.
The current EMA is compared against these two reference levels, and the resulting distances are normalized for JPY and non-JPY instruments so that values remain visually comparable across different Forex pairs.
The histogram represents the magnitude of these deviations.
As the EMA approaches its recent upper boundary, the upper-distance histogram moves toward its extreme.
Likewise, as the EMA approaches its recent lower boundary, the lower-distance histogram expands in the opposite direction.

[b]Interpretation[/b]
Large positive values indicate that the moving average is approaching its recent upper range.
Large negative values indicate proximity to its recent lower range.
These conditions suggest that short-term momentum has become increasingly extended relative to recent market behavior.
The indicator is designed to visualize momentum extension rather than generate standalone buy or sell signals.
It is generally more useful when combined with trend analysis, market structure, or price action.

[b]Typical Use Cases[/b]
• Detect short-term momentum exhaustion
• Monitor trend extension
• Identify potential pullback areas
• Filter momentum-based trading setups
• Confirm discretionary market analysis

[b]Inputs[/b]
EMA Length
Controls the moving average period.
Default: 10
Lookback Period
Defines the rolling range used to calculate EMA extremes.
Default: 10

[b]Notes[/b]
The indicator measures the behavior of the moving average itself rather than raw market price.
As a result, it reacts more smoothly than price-based oscillators and is intended as a market analysis tool instead of a complete trading system.

[b]Disclaimer[/b]
This indicator is provided for educational and analytical purposes only.
It does not provide financial advice and should not be used as the sole basis for trading decisions.

[b]Release Notes[/b]
Version 1.0
Initial public release.
Introduces an oscillator that visualizes the position of a short-term EMA within its recent rolling range.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// © vertexalgo

//@version=6
indicator(
     title = "EMA Micro Trend Exhaustion",
     shorttitle = "EMA Exhaustion",
     overlay = false,
     precision = 1)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

emaLength = input.int(
     defval = 10,
     title = "EMA Length",
     minval = 1,
     tooltip = "Length of the Exponential Moving Average.")

lookback = input.int(
     defval = 10,
     title = "Lookback Period",
     minval = 2,
     tooltip = "Rolling period used to calculate EMA extremes.")

normalizePoints = input.bool(
     defval = true,
     title = "Normalize Forex Points",
     tooltip = "Automatically normalizes values for JPY and non-JPY Forex pairs.")

showZeroLine = input.bool(
     defval = true,
     title = "Show Zero Line")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Symbol Information
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

isJPY = syminfo.currency == "JPY"

pointMultiplier =
     normalizePoints
         ? (isJPY ? 100.0 : 10000.0)
         : 1.0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA Calculation
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

emaValue = ta.ema(close, emaLength)

emaHighest = ta.highest(emaValue, lookback)
emaLowest  = ta.lowest(emaValue, lookback)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Distance Calculation
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

distanceUpper = (emaValue - emaHighest) * pointMultiplier
distanceLower = (emaValue - emaLowest) * pointMultiplier

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Plot Colors
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

upperColor = color.new(color.red, 35)
lowerColor = color.new(color.green, 35)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Plots
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(
     distanceUpper,
     title = "Distance to Upper EMA Range",
     style = plot.style_histogram,
     linewidth = 3,
     color = upperColor)

plot(
     distanceLower,
     title = "Distance to Lower EMA Range",
     style = plot.style_histogram,
     linewidth = 3,
     color = lowerColor)

plot(
     showZeroLine ? 0 : na,
     title = "Zero Line",
     color = color.gray,
     linewidth = 1)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alert Conditions
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

upperReset = ta.crossunder(distanceUpper, 0)
lowerReset = ta.crossover(distanceLower, 0)

alertcondition(
     upperReset,
     title = "Upper Exhaustion Reset",
     message = "EMA has started moving away from its recent upper range.")

alertcondition(
     lowerReset,
     title = "Lower Exhaustion Reset",
     message = "EMA has started moving away from its recent lower range.")
````
