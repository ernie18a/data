# Quantile Threshold Bands | NickJoan

- url: https://www.tradingview.com/script/ZWIsHftw-Quantile-Threshold-Bands-NickJoan/
- type: indicator
- pine_id: PUB;79c292a54aa14465b3aab52809551eab
- version: 4.0

## Description

Quantile Threshold Bands | NickJoan
Core Idea
Quantile Threshold Bands measures the position of price within a lookback window and uses that information to define adaptive upper and lower threshold bands. The script calculates two percentile levels from a user-defined lookback window and uses them to classify the current source value as bullish or bearish.

When the price moves above the upper quantile, the indicator turns bullish. When the price moves below the lower quantile, it turns bearish. When it returns inside the band area, the script keeps the last active state until the opposite threshold is crossed again. This gives the indicator a persistent regime structure.

Calculation Logic
The indicator works through three steps:
[list]
[*]Source selection.
- The user chooses the price series to analyze.
[*]Quantile calculation.
- The script looks back over a chosen number of bars.
- From that window, it calculates a lower quantile band and an upper quantile band.
- These values are obtained with a nearest-rank percentile calculation.
[*]State assignment.
- If the source is above the upper band, the state becomes bullish.
- If the source is below the lower band, the state becomes bearish.
- If the source is between the bands, the previous state remains active.
[/list]
What the Bands Mean
The lower and upper bands represent the selected percentile levels inside the recent price window.
[list]
[*]The lower band marks a lower threshold within recent price behavior.
[*]The upper band marks a higher threshold within recent price behavior.
[*]The area between them defines the central zone where price is neither breaking upward nor downward.
[/list]
Because the levels are recalculated on every bar, they adjust as the market changes. The result is a dynamic set of thresholds that follow the market’s own recent distribution.

Chart Output
The script displays four visual elements on the chart:
[list]
[*]Lower Quantile line.
[*]Upper Quantile line.
[*]Filled zone between the two bands.
[*]Colored candles showing the active state.
[/list]

The color logic is:
[list]
[*]Aqua when the regime is bullish.
[*]Olive when the regime is bearish.
[*]No color yet before the first valid state is established.
[/list]
The output is designed to make the current state readable at a glance.

Inputs
The indicator has four primary inputs:
[list]
[*]Source - The series used in the quantile calculation.
[*]Lookback - The number of bars used to build the rolling window.
[*]Lower Quantile % - The percentile used for the lower band.
[*]Upper Quantile % - The percentile used for the upper band.
[/list]
The lower percentile must be smaller than the upper percentile.

Alerts
The script includes alerts for regime changes:
[list]
[*]Long Signal - Triggers when the state turns bullish.
[*]Short Signal - Triggers when the state turns bearish.
[/list]
These alerts are designed to notify the trader when price breaks into a new regime.

How to Use It
This indicator can be used as a regime filter or market bias tool.

Typical use cases include:
[list]
[*]Directional bias filter. Use the bullish state when price is above the upper quantile and the bearish state when price is below the lower quantile.
[*]Threshold-based alerts. Use the long and short alerts to notify you when price breaks into a new percentile regime.
[*]Range / compression read. The distance between the two bands can help show whether recent price action has been compressed or expanded. A narrow band zone suggests tighter recent movement, while a wider band zone suggests broader recent movement.
[*]Trade filtering. Use it to decide whether to allow only long setups, only short setups, or no directional trades depending on regime.
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Nick_Joan

//@version=6
indicator(title="Quantile Threshold Bands | NickJoan", format = format.inherit, overlay = true)

// ─── Inputs ───────────────────────────────────────────────────────────────────
source           = input.source(close,'Source', group = "Settings")
lookback         = input.int(35, "Lookback", minval = 1, group = "Settings", tooltip = "Number of bars used to calculate the rolling quantile bands")
percentileMethod = input.string("Linear Interpolation", "Percentile Method", options = ["Linear Interpolation", "Nearest Rank"], group = "Settings")
lowerPercentile  = input.int(25, "Lower Quantile %", minval = 0, maxval = 100, group = "Bands")
upperPercentile  = input.int(80, "Upper Quantile %", minval = 0, maxval = 100, group = "Bands")
if lowerPercentile >= upperPercentile
    runtime.error("Lower Quantile % must be less than Upper Quantile %")

showFill  = input.bool(true, "Show Fill", group = "Colors")
bullColor = input.color(color.aqua, "Bullish Color", group = "Colors")
bearColor = input.color(color.olive, "Bearish Color", group = "Colors")

// ─── Calculations ─────────────────────────────────────────────────────────────
lowerBand = percentileMethod == "Linear Interpolation" ? ta.percentile_linear_interpolation(source, lookback, lowerPercentile) : ta.percentile_nearest_rank(source, lookback, lowerPercentile)
upperBand = percentileMethod == "Linear Interpolation" ? ta.percentile_linear_interpolation(source, lookback, upperPercentile) : ta.percentile_nearest_rank(source, lookback, upperPercentile)

// ─── Signal Conditions ─────────────────────────────────────────────────────────────
longCondition  = source > upperBand
shortCondition = source < lowerBand

var state = 0
state := longCondition ? 1 : shortCondition ? -1 : state

// ─── Plots and Colors ─────────────────────────────────────────────────────────────
stateColor = state == 1 ?  bullColor : state == -1 ? bearColor : na

p1 = plot(lowerBand, "Lower Quantile", color = bearColor, linewidth = 2)
p2 = plot(upperBand, "Upper Quantile", color = bullColor, linewidth = 2) 

fill(p1, p2, color = showFill ? color.new(stateColor, 80) : na)

plotcandle(open ,high, low, close, title = 'Color Bars', wickcolor = stateColor, bordercolor = stateColor, color = stateColor, display = display.pane)

// ─── Alerts ─────────────────────────────────────────────────────────────
longSignal    = state == 1 and state[1] != 1
shortSignal   = state == -1 and state[1] != -1

alertcondition(longSignal, title = "Long Signal", message = "Quantile Threshold Bands turned bullish")
alertcondition(shortSignal, title = "Short Signal", message = "Quantile Threshold Bands turned bearish")
````
