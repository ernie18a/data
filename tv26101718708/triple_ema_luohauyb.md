# Triple EMA

- url: https://www.tradingview.com/script/lUohauYb-Triple-EMA/
- type: indicator
- pine_id: PUB;28084f6eeb114f51bd3fe0c6677216d9
- version: 1.0

## Description

Triple EMA Overlay is a simple trend-following indicator that plots three customizable exponential moving averages on the chart: 9 EMA, 21 EMA, and 50 EMA. It is designed to help traders quickly identify trend direction, dynamic support and resistance, and potential crossover zones.

Features
3 EMA lines on the chart.

Fully customizable EMA lengths.

Fully customizable line colors.

Adjustable line thickness for each EMA.

Default settings: 9 EMA green, 21 EMA blue, 50 EMA red.

How to use
Use the 9 EMA for short-term momentum.

Use the 21 EMA for medium-term trend confirmation.

Use the 50 EMA for broader trend direction.

A bullish bias is generally stronger when price stays above all three EMAs.

A bearish bias is generally stronger when price stays below all three EMAs.

This script is intended for visual analysis and can be used on any timeframe.

## Source Code

````pine
//@version=6
indicator("Triple EMA", overlay=true)

// Inputs
ema9Len   = input.int(9,  "EMA 9 Length",  minval=1)
ema21Len  = input.int(21, "EMA 21 Length", minval=1)
ema50Len  = input.int(50, "EMA 50 Length", minval=1)

ema9Col   = input.color(color.green, "EMA 9 Color")
ema21Col  = input.color(color.blue,  "EMA 21 Color")
ema50Col  = input.color(color.red,   "EMA 50 Color")

ema9Width  = input.int(2, "EMA 9 Thickness",  minval=1, maxval=10)
ema21Width = input.int(2, "EMA 21 Thickness", minval=1, maxval=10)
ema50Width = input.int(2, "EMA 50 Thickness", minval=1, maxval=10)

// Calculations
ema9  = ta.ema(close, ema9Len)
ema21 = ta.ema(close, ema21Len)
ema50 = ta.ema(close, ema50Len)

// Plots
plot(ema9,  title="EMA 9",  color=ema9Col,  linewidth=ema9Width)
plot(ema21, title="EMA 21", color=ema21Col, linewidth=ema21Width)
plot(ema50, title="EMA 50", color=ema50Col, linewidth=ema50Width)
````
