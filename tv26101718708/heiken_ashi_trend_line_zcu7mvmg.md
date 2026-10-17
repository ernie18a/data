# Heiken Ashi Trend Line

- url: https://www.tradingview.com/script/zcU7mVMG-Heiken-Ashi-Trend-Line/
- type: indicator
- pine_id: PUB;e7299abc51a944c58ea0f5b5312a663f
- version: 1.0

## Description

[b]Heiken Ashi Trend Line[/b]

Heiken Ashi candles are great for reading trend, but you lose the real price action in exchange for the smoothing. This indicator gives you the best of both: keep your regular candles on the chart, and overlay a single line that tracks the Heiken Ashi trend.

[b]What it plots[/b]

A single line drawn at the midpoint of the Heiken Ashi body (the average of HA Open and HA Close). The line is colored green when the current HA candle would be green (HA Close ≥ HA Open) and red when it would be red. You get the HA trend signal without giving up real candle visibility.

[b]Why the midpoint[/b]

The midpoint of the HA body smooths naturally because HA Open is itself a running average of prior HA values. Mixing it with HA Close produces a line that tracks price closely but with less noise than a raw close-based plot. No length parameter required, no arbitrary smoothing to tune.

[b]Offset setting[/b]

An adjustable offset (as a percentage of price) lets you shift the line above or below your candles so it doesn't overlap the price action. Percentage-based scaling means the same setting looks consistent across any ticker. 0.1% is visually similar on SPY as it is on a $20 stock. Set to 0 to keep it anchored to price, positive to push it above, negative to push it below. 

[b]How to use[/b]

Works on any ticker and any timeframe. No configuration required
Use the color to read trend direction at a glance
Use the slope as confirmation of momentum strength
Pairs well with your existing setups since it doesn't clutter the chart

[b]A note on transition bars[/b]

On bars where HA flips direction, the line's slope may briefly disagree with its color. This is the Heiken Ashi math being honest. HA Open on the first bar of a new direction is anchored near the prior body. It's rare and it's not a bug.

## Source Code

````pine
//@version=6
indicator("Heiken Ashi Trend Line", "HA Trend", overlay=true)

// Inputs
offsetPct = input.float(0.0, "Offset (%)", minval=-5.0, maxval=5.0, step=0.05,
     tooltip="Positive shifts the line above candles, negative below. Scales with price.")

// Heiken Ashi OHLC computed from the chart's real OHLC
haClose = (open + high + low + close) / 4
var float haOpen = na
haOpen := na(haOpen[1]) ? (open + close) / 2 : (haOpen[1] + haClose[1]) / 2

// Midpoint of the HA body
haMid = (haOpen + haClose) / 2

// Apply offset as a percentage of the midpoint
haMidOffset = haMid * (1 + offsetPct / 100)

// Color matches HA candle
haColor = haClose >= haOpen ? color.green : color.red

plot(haMidOffset, title="HA Trend", color=haColor, linewidth=2)
````
