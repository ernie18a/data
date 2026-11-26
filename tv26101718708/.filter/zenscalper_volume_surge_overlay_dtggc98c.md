# ZenScalper Volume Surge Overlay

- url: https://www.tradingview.com/script/DTGgc98c-ZenScalper-Volume-Surge-Overlay/
- type: indicator
- pine_id: PUB;c96a56aebab14b08ae5924d4e0e5ccbd
- version: 1.0

## Description

ZenScalper Volume Surge Overlay highlights unusual volume activity directly on the price chart by comparing current volume to a moving average of volume.

Features:

• Detects volume spikes relative to average volume.
• Displays labels above candles showing the strength of the surge:

2x = Volume is at least 2 times average
3x = Volume is at least 3 times average
4x = Volume is at least 4 times average
5x+ = Extreme volume expansion
• Helps identify potential breakout candles, liquidation events, reversals, institutional participation, and key reaction points.
• Designed to work alongside price action, VWAP, EMA, support/resistance, and market structure analysis.

Inputs:

Volume SMA Length: Defines the average volume baseline.
Label Size: Adjusts marker visibility.
Surge Thresholds: Customize the minimum multiples required for each label level.

This indicator does not generate buy or sell signals. It is intended as a volume confirmation tool to help traders quickly identify candles receiving significantly more participation than normal.

Best used in conjunction with trend, momentum, and price action analysis.

## Source Code

````pine
//@version=6
indicator("Volume Surge Overlay", overlay=true, max_labels_count=500)

// === INPUTS ===
volumeSMAPeriod = input.int(20, "Volume SMA Period")
volumeMultiplier = input.float(1.5, "Volume Surge Threshold (x Avg Volume)")
showTriangles = input.bool(true, "Show Surge Triangles")
showLabels = input.bool(true, "Show Volume Multiplier Markers")
showDebugText = input.bool(false, "Show Surge Ratio Breakdown")
labelYOffset = input.int(10, "Marker Y Offset (in ticks)")

// === CALCULATIONS ===
volSMA = ta.sma(volume, volumeSMAPeriod)
volRatio = volume / volSMA
isSurge = volume > volSMA * volumeMultiplier

// === FAKE LABELS FOR MULTIPLIER ===
plotshape(showLabels and isSurge and volRatio > 5, title="5x+", location=location.abovebar, style=shape.labeldown, text="5x+", size=size.tiny, color=color.gray, textcolor=color.white)
plotshape(showLabels and isSurge and volRatio > 4 and volRatio <= 5, title="5x", location=location.abovebar, style=shape.labeldown, text="5x", size=size.tiny, color=color.gray, textcolor=color.white)
plotshape(showLabels and isSurge and volRatio > 3 and volRatio <= 4, title="4x", location=location.abovebar, style=shape.labeldown, text="4x", size=size.tiny, color=color.gray, textcolor=color.white)
plotshape(showLabels and isSurge and volRatio > 2 and volRatio <= 3, title="3x", location=location.abovebar, style=shape.labeldown, text="3x", size=size.tiny, color=color.gray, textcolor=color.white)
plotshape(showLabels and isSurge and volRatio > 1.5 and volRatio <= 2, title="2x", location=location.abovebar, style=shape.labeldown, text="2x", size=size.tiny, color=color.gray, textcolor=color.white)
````
