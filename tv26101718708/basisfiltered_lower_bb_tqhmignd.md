# Basis-Filtered Lower BB

- url: https://www.tradingview.com/script/TQhmIGND-Basis-Filtered-Lower-BB/
- type: indicator
- pine_id: PUB;d45ec4af0272456b8dd1459ffe483867
- version: 1.0

## Description

[b]Basis-Filtered Lower BB[/b] is a modified Bollinger Band indicator designed to help locate potential [b]long entries only[/b], based on @EdgeTools’ findings around lower-band mean reversion.

Instead of treating Bollinger Bands as breakout, squeeze, or support/resistance tools, this script focuses on downside volatility extremes. According to the referenced finding, the strongest edge came from [b]price closing below the lower Bollinger Band[/b], where the move may be unusually extended relative to the asset’s recent volatility regime and later revert upward.

The indicator filters the lower Bollinger Band with an offset RMA basis to reduce steep near-vertical drops during volatility expansion. The final [b]Filtered Lower BB[/b] line shows the higher value between the lower band and the basis filter, with optional SMA smoothing enabled by default.

Features:
[list]
[*]Built for studying potential [b]long-only mean-reversion entries[/b]
[*]EMA-based lower Bollinger Band
[*]Fixed 2 standard deviation multiplier
[*]Separate lengths for lower band and basis filter
[*]Percentage-based basis offset, suitable for logarithmic charts
[*]Smoothed filtered output
[*]Raw lower band and basis filter hidden by default
[/list]

This is a visual research tool for identifying lower-band penetration zones, not financial advice or a complete trading strategy.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mr.dmizer

//@version=6
indicator(
     shorttitle="Filtered LBB",
     title="Basis-Filtered Lower BB",
     overlay=true,
     timeframe="1W",
     timeframe_gaps=true
)

//──────────────────────────────────────────────────────────────────────────────
// Inputs
//──────────────────────────────────────────────────────────────────────────────

GROUP_BB     = "Lower Bollinger Band"
GROUP_BASIS  = "Basis Filter"
GROUP_OUTPUT = "Output"

TT_LOWER_LENGTH = "Length used for the Lower Bollinger Band. The basis for this band always uses EMA smoothing."
TT_SOURCE       = "Source data used for all calculations."
TT_BASIS_LENGTH = "Length used for the RMA basis filter."
TT_BASIS_OFFSET = "Moves the RMA basis filter up or down by percentage. This filter cuts off parts of the Lower BB when the basis is higher."
TT_FILTERED_SMA = "Optionally applies SMA smoothing to the final filtered line."

lowerLength = input.int(
     50,
     "Lower BB EMA Length",
     minval=1,
     tooltip=TT_LOWER_LENGTH,
     group=GROUP_BB
)

src = input(
     hl2,
     "Source",
     tooltip=TT_SOURCE,
     group=GROUP_BB
)

basisLength = input.int(
     20,
     "Basis Filter RMA Length",
     minval=1,
     tooltip=TT_BASIS_LENGTH,
     group=GROUP_BASIS
)

basisOffsetPercent = input.float(
     -50.0,
     "Basis Filter Offset %",
     tooltip=TT_BASIS_OFFSET,
     group=GROUP_BASIS
)

smoothFilteredLine = input.bool(
     true,
     "Smooth Filtered Lower BB with SMA",
     tooltip=TT_FILTERED_SMA,
     group=GROUP_OUTPUT
)

filteredSmaLength = input.int(
     5,
     "Filtered Lower BB SMA Length",
     minval=1,
     tooltip=TT_FILTERED_SMA,
     group=GROUP_OUTPUT
)

//──────────────────────────────────────────────────────────────────────────────
// Calculations
//──────────────────────────────────────────────────────────────────────────────

lowerBasisEma = ta.ema(src, lowerLength)
lowerDeviation = 2.0 * ta.stdev(src, lowerLength)
lowerBb = lowerBasisEma - lowerDeviation

basisFilterRaw = ta.rma(src, basisLength)
basisFilter = basisFilterRaw * (1 + basisOffsetPercent / 100)

// The filtered line uses whichever value is higher:
// the Lower BB or the offset Basis Filter.
filteredLowerBbRaw = math.max(lowerBb, basisFilter)

lowerBbVisible = lowerBb >= basisFilter ? lowerBb : na
basisFilterVisible = basisFilter >= lowerBb ? basisFilter : na

filteredLowerBb = smoothFilteredLine ? ta.sma(filteredLowerBbRaw, filteredSmaLength) : filteredLowerBbRaw

//──────────────────────────────────────────────────────────────────────────────
// Plots
//──────────────────────────────────────────────────────────────────────────────

plot(
     basisFilterVisible,
     "Basis Filter",
     color=#2962FF,
     style=plot.style_linebr,
     display=display.none
)

plot(
     lowerBbVisible,
     "Lower BB",
     color=#089981,
     style=plot.style_linebr,
     display=display.none
)

plot(
     filteredLowerBb,
     "Filtered Lower BB",
     color=#FF9800,
     style=plot.style_stepline
)
````
