# Volatility Quality Index (Non-Directional) w/ Signal

- url: https://www.tradingview.com/script/0W0aSS8H-Volatility-Quality-Index-Non-Directional-w-Signal/
- type: indicator
- pine_id: PUB;beca04356241447e887ecefccc71036a
- version: 1.0

## Description

Volatility Quality Index (Non-Directional) w/ Signal

## Source Code

````pine
//@version=6
indicator("Volatility Quality Index (Non-Directional) w/ Signal", overlay=false)

length        = input.int(14, "Length", minval=2)
smoothLength  = input.int(5, "Smoothing", minval=1)
signalLength  = input.int(9, "Signal Length", minval=1)

// Net movement over lookback (directionless)
netMove = math.abs(close - close[length])

// Total path traveled
barMove = math.abs(close - close[1])

totalMove = 0.0
for i = 0 to length - 1
    totalMove += barMove[i]

// Efficiency ratio (quality of movement)
quality = totalMove > 0 ? netMove / totalMove : 0.0

// Smoothed main line
qualitySmoothed = ta.ema(quality, smoothLength)

// Signal line (slower EMA of smoothed quality)
signal = ta.ema(qualitySmoothed, signalLength)

// Plots
plot(quality, "Raw Quality", color=color.gray)
plot(qualitySmoothed, "Smoothed Quality", linewidth=2)
plot(signal, "Signal Line", linewidth=2)

// Reference levels
hline(0.25, "Low Quality")
hline(0.50, "Medium Quality")
hline(0.75, "High Quality")
````
