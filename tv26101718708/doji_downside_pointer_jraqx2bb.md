# Doji Downside Pointer

- url: https://www.tradingview.com/script/JrAQx2bb-Doji-Downside-Pointer/
- type: indicator
- pine_id: PUB;98b4fdefecb84a409b3d0e2234b129f5
- version: 1.0

## Description

A Doji candle is a distinct technical analysis chart pattern that forms when a security's opening and closing prices are virtually equal, resulting in a cross-like shape that signals market indecision.

Locate the Trend: Find a clear upward or downward trend.Spot the Doji: Wait for the candle body to flatten.Confirm the Signal: Look at the very next candlestick.Manage Your Risk: Place stop-losses beyond the Doji wicks.

for educational purposes only

## Source Code

````pine
//@version=6
indicator('Doji Downside Pointer', overlay = true)

// Input for customization (Adjust how strict the Doji definition is)
bodyPercent = input.float(10.0, title = 'Doji Body Max % of Total Range', minval = 1.0, maxval = 30.0)

// Calculate the absolute size of the body and the total range of the candle
candleBody = math.abs(close - open)
candleRange = high - low

// Define the Doji condition: body must be smaller than X% of the total range
isDoji = candleRange > 0 and candleBody <= candleRange * (bodyPercent / 100.0)

// 1. Plot the downside arrow above the bar
plotshape(isDoji, title = 'Downside Arrow', style = shape.arrowdown, location = location.abovebar, color = color.red, size = size.small, offset = 0)

// 2. Plot the text 'D' slightly higher above the same bar to avoid overlapping
plotchar(isDoji, title = 'Doji Label', char = 'D', location = location.abovebar, color = color.yellow, size = size.small, offset = 0)
````
