# Relative ATR Volatility Indicator

- url: https://www.tradingview.com/script/MlrIdwIW-Relative-ATR-Volatility-Indicator/
- type: indicator
- pine_id: PUB;708f111f33054d1a9874596510c00b4f
- version: 1.0

## Description

This relative volatility regime indicator measures whether current volatility is high, low, or "normal" compared to its own recent historical range.

It calculates ATR, then compares the current ATR reading against a rolling percentile window. By default, it looks back over the last 100 bars and marks:

[list]
[*] The upper volatility threshold, based on the 80th percentile of recent ATR readings (red)
[*] The lower volatility threshold, based on the 20th percentile of recent ATR readings (green)
[/list]

With the default settings of a 100-bar Rolling Window Length, Top Percentile of 80, and Bottom Percentile of 20:

If the white ATR line is above the red line, current volatility is in the highest 20% of recent ATR readings.

If the white ATR line is below the green line, current volatility is in the lowest 20% of recent ATR readings.

In other words, the script ranks current ATR against its own recent history and highlights volatility extremes. This makes it easier to objectively identify whether a market is currently in a high-volatility, low-volatility, or normal-volatility regime.

The indicator is directionally agnostic. A high ATR reading does not mean price is bullish or bearish; it simply means the market is moving more than usual. High ATR can occur during bullish expansion, bearish selloffs, large gaps, or choppy high-range conditions.

The main values are:

[list]
[*] White line = current ATR value
[*] Red line = upper ATR percentile threshold
[*] Green line = lower ATR percentile threshold
[*] Grey line = middle 50th percentile (turned off in Style Settings by default)
[*] ATR Ratio Upper = current ATR divided by the upper threshold
[*] ATR Ratio Lower = current ATR divided by the lower threshold
[/list]

The ATR Ratio values can be used as an input by other scripts or strategies:

[list]
[*] ATR Ratio Upper above 1 means ATR is above the upper volatility threshold
[*] ATR Ratio Lower below 1 means ATR is below the lower volatility threshold
[/list]

This script uses Pine Script's ta.percentile_nearest_rank() function to calculate rolling ATR percentile thresholds.

This is a lagging indicator, like most indicators, but it provides a useful way to classify volatility regimes objectively.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ZenAndTheArtOfTrading
// @version=6
indicator("Relative ATR Volatility", overlay = false)

// User inputs
atrLength       = input.int(14, "ATR Length")
windowLength    = input.int(100, "Rolling Window Length")
topPercent      = input.float(80, "Top Percentile")
bottomPercent   = input.float(20, "Bottom Percentile")

// Indicator values
atrValue        = ta.atr(atrLength)
bottomThreshold = ta.percentile_nearest_rank(atrValue, windowLength, bottomPercent)
topThreshold    = ta.percentile_nearest_rank(atrValue, windowLength, topPercent)
centerThreshold = ta.percentile_nearest_rank(atrValue, windowLength, 50)
isBottomX       = atrValue <= bottomThreshold
isTopX          = atrValue >= topThreshold
atrRatioUpper   = atrValue / topThreshold
atrRatioLower   = atrValue / bottomThreshold

// Visuals
topGradient     = 0.0
bottomGradient  = 0.0

if (isTopX and topThreshold > 0)
    topGradient := (atrValue - topThreshold) / topThreshold

if (isBottomX and bottomThreshold > 0)
    bottomGradient := (bottomThreshold - atrValue) / bottomThreshold

topGradient         := math.min(topGradient, 1.0)
bottomGradient      := math.min(bottomGradient, 1.0)

topTransparency     = 90 - int(topGradient * 80)
bottomTransparency  = 90 - int(bottomGradient * 80)

atrPlot             = plot(atrValue, "ATR", color = color.white)
bottomPlot          = plot(bottomThreshold, "Bottom X% Threshold", color = color.green, display = display.pane)
topPlot             = plot(topThreshold, "Top X% Threshold", color = color.red, display = display.pane)
centerPlot          = plot(centerThreshold, "Median ATR", color=color.gray, display=display.none)

topAtrFillValue     = isTopX ? atrValue : na
bottomAtrFillValue  = isBottomX ? atrValue : na

topAtrFillPlot      = plot(topAtrFillValue, "Top ATR Fill", display = display.none)
bottomAtrFillPlot   = plot(bottomAtrFillValue, "Bottom ATR Fill", display = display.none)

fill(topAtrFillPlot, topPlot, color = color.new(color.red, topTransparency))
fill(bottomAtrFillPlot, bottomPlot, color = color.new(color.green, bottomTransparency))

plot(atrRatioUpper, "ATR Ratio (vs Upper Band)", color.red, display=display.status_line)
plot(atrRatioLower, "ATR Ratio (vs Lower Band)", color.green, display=display.status_line)
````
