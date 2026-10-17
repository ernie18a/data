# SMA20/EMA50 Trend

- url: https://www.tradingview.com/script/c8vYRZZY-SMA20-EMA50-Trend/
- type: indicator
- pine_id: PUB;20667557f1b844baa597bd216617f916
- version: 2.0

## Description

Crossing between SMA20 & EMA50
so you can clearly see between golden cross & death cross

## Source Code

````pine
//@version=5
indicator("SMA20/EMA50 Trend", overlay=true)

sma20 = ta.sma(close, 20)
ema50 = ta.ema(close, 50)

uptrend = sma20 > ema50

// Single color variable used by both plots
trendColor = uptrend ? color.new(color.blue, 90) : color.new(color.orange, 80)
fillColor  = uptrend ? color.new(color.blue, 90) : color.new(color.orange, 90)

p1 = plot(sma20, color=trendColor, linewidth=1)
p2 = plot(ema50, color=trendColor, linewidth=1)

fill(p1, p2, color=fillColor)
````
