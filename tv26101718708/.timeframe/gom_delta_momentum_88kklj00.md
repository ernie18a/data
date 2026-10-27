# Gom Delta Momentum 

- url: https://www.tradingview.com/script/88Kklj00-Gom-Delta-Momentum/
- type: indicator
- pine_id: PUB;0d02eef236cb49da82fee6667007899f
- version: 1.0

## Description

Description:
Overview
The Gom Delta Momentum indicator is an advanced order flow tool designed to measure the cumulative strength of consecutive buying or selling pressure. While a standard Volume Delta indicator resets at the start of every new bar, Gom Delta Momentum mathematically accumulates the delta as long as the market's aggressive order flow remains moving in the same direction. When the order flow flips, the momentum resets, providing a clear visual representation of sustained trend strength versus order flow shifts.

How It Works (The Core Logic)
This script operates in two distinct phases: determining the intrabar delta, and then applying the Gom Momentum logic.

1. Tick-Based Delta Calculation:
Because native quote-based (Bid/Ask) data is not available for historical script calculations, this indicator utilizes a high-resolution Tick-Based Test. By using request.security_lower_tf(), the script breaks down the current chart timeframe into 1-second micro-bars. It compares each 1-second close to the previous close:

An upward tick classifies the volume as a Buy.

A downward tick classifies the volume as a Sell.
The script aggregates these micro-bars to calculate the true net Delta (Buy Volume minus Sell Volume) for the current chart bar.

2. The Gom Momentum Accumulation:
Once the current bar's net delta is calculated, it is fed into the Gom Momentum algorithm:

Continuation: If the previous bar's momentum was positive AND the current bar's delta is positive, the current delta is added to the running total. The same logic applies if both the previous momentum and current delta are negative.

Reversal (Reset): If the current bar's delta opposes the previous momentum (e.g., previous momentum was positive, but the current bar's delta is negative), the running accumulation is immediately broken. The momentum resets and becomes strictly the value of the current bar's delta.

Understanding the Visuals
To make momentum easy to read at a glance, the data is plotted as an absolute value histogram originating from a zero line.

Bar Height: Represents the total accumulated volume delta of the current uninterrupted sequence. Taller columns mean the one-sided order flow is continuing to build without interruption.

Bar Color: Indicates the direction of the momentum. Green columns mean the accumulated momentum is purely positive (buyers in control). Red columns mean the accumulated momentum is purely negative (sellers in control).

Educational Application (How to Use It)

Trend Strength: A healthy, strong trend is often accompanied by smoothly ascending Gom Momentum columns. This shows that not only is price moving, but consecutive order flow is continuously stacking in that direction.

Exhaustion / Divergence: If price continues to push higher but the green Gom Momentum columns begin to shrink (or reset completely), it indicates that aggressive consecutive buying is drying up, and a reversal or consolidation may be imminent.

Momentum Shifts: A sudden color change combined with a sharp drop in column height visually highlights exactly where the opposing side has stepped in and broken the previous chain of order flow.

Settings & Limitations

Lower Timeframe Input: Defaults to 1S (One Second) for maximum accuracy.

Data Availability: Accessing historical 1-second intrabar data requires the appropriate TradingView subscription tier. If you are viewing older historical data or are on a basic plan, you may need to adjust the lower timeframe input (e.g., to 15S or 1) for the indicator to render properly on higher timeframe charts.

## Source Code

````pine
//@version=6
indicator('GomDeltaMomentum Delta', overlay = false, max_bars_back = 5000)

// === INPUTS ===
ltf = input.timeframe('1S', 'Lower Timeframe')

// === 1-SECOND DELTA LOGIC ===
// Calculate delta strictly for each lower timeframe bar
float vol1s = volume
float delta1s = 0.0

if close > close[1]
    delta1s := vol1s
    delta1s
else if close < close[1]
    delta1s := -vol1s
    delta1s

// === AGGREGATE TO CHART TIMEFRAME ===
// Pull all 1-second deltas that occurred inside the current chart timeframe
deltaArray = request.security_lower_tf(syminfo.tickerid, ltf, delta1s)

// Sum the array to get the total delta for the current chart bar
float delta = 0.0
if array.size(deltaArray) > 0
    delta := array.sum(deltaArray)
    delta

// === GOM DELTA MOMENTUM LOGIC ===
// Use 'var' to declare the variable so its state persists across bars
var float gomDeltaMomentum = 0.0

if bar_index == 0
    gomDeltaMomentum := delta
    gomDeltaMomentum
else // Reference the previous bar's value using [1]
    if gomDeltaMomentum[1] >= 0 and delta >= 0
        gomDeltaMomentum := gomDeltaMomentum[1] + delta
        gomDeltaMomentum
    else if gomDeltaMomentum[1] <= 0 and delta <= 0
        gomDeltaMomentum := gomDeltaMomentum[1] + delta
        gomDeltaMomentum
    else
        gomDeltaMomentum := delta
        gomDeltaMomentum

// === PLOTTING ===
// Determine the color based on the momentum direction
plotColor = gomDeltaMomentum >= 0 ? color.new(color.green, 0) : color.new(color.red, 0)

// Plot the absolute value as requested, using columns for the 'bar' style
plot(math.abs(gomDeltaMomentum), title = 'GomDeltaMomentum', color = plotColor, style = plot.style_columns)

// Optional: Plot a zero line for reference at the base of the columns
hline(0, title = 'Zero Line', color = color.new(color.gray, 50), linestyle = hline.style_dashed)
````
