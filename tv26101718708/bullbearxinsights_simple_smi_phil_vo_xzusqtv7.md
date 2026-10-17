# BullBearXinsights Simple SMI [Phil Vo]

- url: https://www.tradingview.com/script/xZUSqtv7-BullBearXinsights-Simple-SMI-Phil-Vo/
- type: indicator
- pine_id: PUB;2e4a6d4e5b574d43abee1dd941a1cea1
- version: 1.0

## Description

Simple SMI [Phil Vo]

A straightforward Stochastic Momentum Index displayed in a separate panel, with an EMA signal line and adjustable overbought and oversold levels.

The indicator measures the closing price’s distance from the midpoint of the recent high–low range. Both that distance and the range are smoothed twice using EMAs to calculate the SMI.

Reading the indicator:

• Aqua line: SMI.
• Orange line: EMA signal line.
• Above zero: price is positioned toward the upper half of the smoothed range.
• Below zero: price is positioned toward the lower half.
• Above +40 or below −40: potential overbought or oversold conditions.

An SMI curling upward from below −40 can help identify recovering momentum. A downward turn above +40 can indicate weakening momentum. Crosses with the signal line provide another way to track momentum changes.

Default settings:

• Range length: 10 bars.
• Double EMA smoothing: 3 bars.
• Signal EMA length: 3 bars.
• Overbought/oversold levels: +40 and −40.

The indicator follows the chart timeframe. Use a 5-minute chart to study 5-minute momentum, or adjust the timeframe and settings to suit the analysis.

This script uses the standard SMI calculation without additional entry filters. It does not generate buy or sell signals. Read momentum alongside price structure, support, resistance, and volume.

Values update during the open candle and can change before it closes. Overbought and oversold readings alone do not confirm a reversal.

## Source Code

````pine
//@version=6
indicator("BullBearXinsights Simple SMI [Phil Vo]", shorttitle="SMI by BullBearXinsights", overlay=false, precision=2)

rangeLength  = input.int(10, "Range Length", minval=1)
smoothLength = input.int(3, "Double EMA Smoothing", minval=1)
signalLength = input.int(3, "Signal EMA Length", minval=1)
upperLevel   = input.float(40.0, "Overbought", minval=0, maxval=100)
lowerLevel   = input.float(-40.0, "Oversold", minval=-100, maxval=0)

// Standard SMI: double-smoothed distance from the range midpoint.
highestHigh = ta.highest(high, rangeLength)
lowestLow   = ta.lowest(low, rangeLength)
distance    = close - (highestHigh + lowestLow) / 2.0
priceRange  = highestHigh - lowestLow

smoothDistance = ta.ema(ta.ema(distance, smoothLength), smoothLength)
smoothRange    = ta.ema(ta.ema(priceRange, smoothLength), smoothLength)

smi    = smoothRange > 0 ? 200.0 * smoothDistance / smoothRange : 0.0
signal = ta.ema(smi, signalLength)

plot(smi, "SMI", color=color.aqua, linewidth=2)
plot(signal, "Signal EMA", color=color.orange, linewidth=1)
upper = hline(upperLevel, "Overbought", color=color.red)
lower = hline(lowerLevel, "Oversold", color=color.lime)
hline(0, "Zero", color=color.gray, linestyle=hline.style_dotted)
fill(upper, lower, color=color.new(color.blue, 94))

// Lines update during the open candle; use closed bars for confirmation.
````
