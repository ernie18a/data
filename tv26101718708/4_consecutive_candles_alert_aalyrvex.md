# 4 Consecutive Candles Alert

- url: https://www.tradingview.com/script/aaLYrvEX-4-Consecutive-Candles-Alert/
- type: indicator
- pine_id: PUB;aeb3c579081749f7b63fd50df0cca56b
- version: 1.0

## Description

sends notification after 4 candles close in same direction on 5 min timeframe

## Source Code

````pine
//@version=6
indicator("4 Consecutive Candles Alert", overlay=true)

// Candle direction
bullish = close > open
bearish = close < open

// 4 consecutive bullish/bearish candles (confirmed closes, look back)
fourBullish = bullish[1] and bullish[2] and bullish[3] and bullish[4]
fourBearish = bearish[1] and bearish[2] and bearish[3] and bearish[4]

// Fire only once per new sequence — suppress if 5th bar back also matched
newBullishRun = fourBullish and not (bullish[2] and bullish[3] and bullish[4] and bullish[5])
newBearishRun = fourBearish and not (bearish[2] and bearish[3] and bearish[4] and bearish[5])

// Alert conditions (link these when creating an alert on the chart)
alertcondition(newBullishRun, title="4 Consecutive Bullish Candles", message="5M — 4 consecutive bullish candles closed!")
alertcondition(newBearishRun, title="4 Consecutive Bearish Candles", message="5M — 4 consecutive bearish candles closed!")

// Visual markers
plotshape(newBullishRun, title="Bullish Run", style=shape.triangleup, location=location.belowbar, color=color.new(color.green, 0), size=size.small)
plotshape(newBearishRun, title="Bearish Run", style=shape.triangledown, location=location.abovebar, color=color.new(color.red, 0), size=size.small)
````
