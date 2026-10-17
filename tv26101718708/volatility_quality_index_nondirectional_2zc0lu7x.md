# Volatility Quality Index (Non-Directional)

- url: https://www.tradingview.com/script/2zc0LU7X-Volatility-Quality-Index-Non-Directional/
- type: indicator
- pine_id: PUB;5fdb1d6b9e7041fd8a4066821d1acfcd
- version: 1.0

## Description

Volatility Quality Index (Non-Directional) - no directional bias just movement continuation

## Source Code

````pine
//@version=6
indicator("Volatility Quality Index (Non-Directional)", overlay=false)

length       = input.int(14, "Length", minval=2)
smoothLength = input.int(5, "Smoothing", minval=1)

netMove = math.abs(close - close[length])

barMove = math.abs(close - close[1])
totalMove = 0.0

for i = 0 to length - 1
    totalMove += barMove[i]

quality = totalMove > 0 ? netMove / totalMove : 0.0
qualitySmoothed = ta.ema(quality, smoothLength)

plot(quality, "Raw Quality")
plot(qualitySmoothed, "Smoothed Quality", linewidth=2)

hline(0.25)
hline(0.50)
hline(0.75)
````
