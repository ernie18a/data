# EMA Momentum Differential

- url: https://www.tradingview.com/script/a8usmEoF-EMA-Momentum-Differential/
- type: indicator
- pine_id: PUB;b33f99071c3e48b88ec9c67e949b3f34
- version: 1.0

## Description

[b]Overview[/b]
EMA Momentum Differential visualizes both the distance between two Exponential Moving Averages (EMAs) and the rate at which that distance changes over time.

While many moving average indicators focus on crossover events, this indicator continuously measures the relationship between a fast EMA and a slow EMA to provide additional context about trend momentum.

The EMA spread is displayed as a histogram, while its first-order change (Momentum Differential) is plotted as a line, helping identify periods when directional momentum is strengthening or weakening.

Values are automatically normalized into pip units for improved readability across both JPY and non-JPY Forex pairs.

[b]How It Works[/b]
The indicator performs the following calculations:
- Calculates a Fast EMA.
- Calculates a Slow EMA.
- Measures the spread between both EMAs.
- Converts the spread into pip units.
- Calculates the change in spread from the previous bar (Momentum Differential).
- Displays the EMA spread as a histogram and the Momentum Differential as a line.

[b]Interpretation[/b]
General observations may include:
- Positive spread values indicate the fast EMA is above the slow EMA.
- Negative spread values indicate the fast EMA is below the slow EMA.
- An increasing Momentum Differential suggests the EMA spread is expanding.
- A decreasing Momentum Differential suggests the EMA spread is contracting.
- Momentum Differential crossing the zero line may indicate a change in the rate of trend expansion.

This indicator is intended to provide additional context for momentum analysis and should not be interpreted as a standalone trading system.

[b]Inputs[/b]
Fast EMA Length
Slow EMA Length

[b]Notes[/b]
EMA Momentum Differential is designed as an analytical tool for evaluating changes in EMA separation.

It does not generate buy or sell signals and should be used together with broader market analysis and appropriate risk management.

Disclaimer
[i]This indicator is provided for educational and analytical purposes only.
Nothing contained in this publication should be interpreted as financial or investment advice.
Past market behavior does not guarantee future results.[/i]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// © Vertex Algo Systems

//@version=6
indicator(title="EMA Momentum Differential", shorttitle="EMA Diff", overlay=false)

//=============================================================================
// Inputs
//=============================================================================

fastLength = input.int(10, "Fast EMA Length", minval=1)
slowLength = input.int(50, "Slow EMA Length", minval=2)

//=============================================================================
// EMA Calculation
//=============================================================================

fastEMA = ta.ema(close, fastLength)
slowEMA = ta.ema(close, slowLength)

//=============================================================================
// Momentum Differential
//=============================================================================

// Current EMA spread
spread = fastEMA - slowEMA

// Convert to pip units for Forex readability
pipMultiplier = syminfo.currency == "JPY" ? 100.0 : 10000.0
spreadPips = spread * pipMultiplier

// Rate of change of the spread
momentumDiff = spreadPips - spreadPips[1]

//=============================================================================
// Histogram Coloring
//=============================================================================

histColor =
     spreadPips >= 0
     ? (momentumDiff >= 0 ? color.lime : color.green)
     : (momentumDiff <= 0 ? color.red : color.orange)

//=============================================================================
// Plot
//=============================================================================

plot(
     spreadPips,
     title="EMA Spread",
     style=plot.style_histogram,
     linewidth=3,
     color=histColor)

plot(
     momentumDiff,
     title="Momentum Differential",
     color=color.white,
     linewidth=2)

hline(
     0,
     "Zero Line",
     color=color.gray,
     linestyle=hline.style_dashed)
````
