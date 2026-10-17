# 1 EMA, SMA, Ichimoku Lagging & RSI

- url: https://www.tradingview.com/script/H6dg2QCL-1-EMA-SMA-Ichimoku-Lagging-RSI/
- type: indicator
- pine_id: PUB;3fd0f5f1bfdf40dea3eef6da5a835b35
- version: 1.0

## Description

combo of ema, sma, rsi and ichimoku, this is for confirmation of the trend

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ShaniDevPrabhu

//@version=6
indicator("Combo: EMA, SMA, Ichimoku Lagging & RSI", overlay=true)

// =======================
// 1. EMA 20 & SMA 16
// =======================
emaLength = input.int(20, title="EMA Length", group="Moving Averages")
smaLength = input.int(16, title="SMA Length", group="Moving Averages")

emaVal = ta.ema(close, emaLength)
smaVal = ta.sma(close, smaLength)

plot(emaVal, color=color.blue, title="EMA 20", linewidth=2)
plot(smaVal, color=color.orange, title="SMA 16", linewidth=2)

// =======================
// 2. Ichimoku Lagging Span
// =======================
// Standard Ichimoku settings use 26 for the displacement/lagging span
laggingSpanLength = input.int(26, title="Lagging Span Displacement", group="Ichimoku")

// The Lagging Span is simply the current close plotted 'X' periods in the past
plot(close, offset = -laggingSpanLength + 1, color=color.green, title="Ichimoku Lagging Span", linewidth=2)

// =======================
// 3. RSI (Standard 14)
// =======================
// Since RSI plots on a 0-100 scale, we can't overlay it directly on the price chart cleanly. 
// Instead, this script plots the RSI values in the Data Window and gives you visual alerts/shapes on the chart.
rsiLength = input.int(14, title="RSI Length", group="RSI")
rsiOverbought = input.int(70, title="RSI Overbought Level", group="RSI")
rsiOversold = input.int(30, title="RSI Oversold Level", group="RSI")

rsiVal = ta.rsi(close, rsiLength)

// Plotting RSI in the data window (hover to see value)
plot(rsiVal, title="RSI Value (Data Window Only)", color=color.purple, display=display.data_window)

// Visual Chart Signals for RSI (Optional)
rsiOB = rsiVal >= rsiOverbought
rsiOS = rsiVal <= rsiOversold

plotshape(rsiOB, title="RSI Overbought", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)
plotshape(rsiOS, title="RSI Oversold", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
````
