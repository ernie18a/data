# Trend Strength Regime Contrast Max

- url: https://www.tradingview.com/script/nEJmeLCd-Trend-Strength-Regime-Contrast-Max/
- type: indicator
- pine_id: PUB;c1f127864b3a43b7ac326f8c74143857
- version: 1.0

## Description

Trend Strength Regime Contrast Max
The indicator shows trend strength as a histogram with two color intensities per direction. It is designed as a simple regime filter and helps you recognize bullish and bearish phases at a glance.

How it works
The calculation is based on smoothed price changes from candle to candle:

First, the difference between two closing prices is calculated.
That value is turned into a smoothed trend component.
This component is smoothed again.
The result is displayed as a histogram around the zero line.
Color changes
Light green: The trend is bullish and getting stronger.
Dark green: The trend is bullish, but momentum is fading.
Light red: The trend is bearish and getting stronger.
Dark red: The trend is bearish, but momentum is fading.
A color change is an early warning for momentum shifts, not an automatic buy or sell signal.
How to use it
Spot trends faster.
See momentum weakening early.
Keep possible reversals on your radar.
Decide entries and exits only together with price action, zones, and volume.
Note
The indicator is not a full trading system. It is a visual filter for market regime and momentum. It works best together with market structure, levels, and volume.

## Source Code

````pine
//@version=5
indicator("Trend Strength Regime Contrast Max", overlay=false)

len = input.int(20, title="Trend Length", minval=1)
smooth = input.int(5, title="Trend Smoothing", minval=1)

priceChange = close - close[1]
trendRaw = ta.ema(priceChange, len)
trend = ta.sma(trendRaw, smooth)

bull = trend >= 0
bullStrong = bull and trend > nz(trend[1])
bearStrong = not bull and trend < nz(trend[1])

trendColor = bullStrong ? color.rgb(0, 255, 0) : bull ? color.rgb(0, 170, 0) : bearStrong ? color.rgb(180, 0, 0) : color.rgb(255, 0, 0)

plot(trend, title="Trend Strength", style=plot.style_histogram, color=trendColor, linewidth=4)
hline(0, title="Zero Line", color=color.rgb(120, 120, 120), linestyle=hline.style_dashed)
````
