# Momentum Candle Colors

- url: https://www.tradingview.com/script/JWJsNi2X-Momentum-Candle-Colors/
- type: indicator
- pine_id: PUB;b44bc538acba42be99d0274ad6a50ac2
- version: 1.0

## Description

Momentum candles above 50PTS, when the candle wicks bearisdh are more than 50 points thry are red and when they are bullish above 50 pts they are green

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © jacobchard21

//@version=6

plot(close)
//@version=5
indicator("Momentum Candle Colors", overlay=true)

// User input
momentumThreshold = input.float(50.0, title="Momentum Threshold")

// Calculate candle move
candleMove = math.abs(close - open)

// Conditions
bullMomentum = close > open and candleMove >= momentumThreshold
bearMomentum = close < open and candleMove >= momentumThreshold

// Color candles
barcolor(
     bullMomentum ? color.rgb(6, 182, 82, 31) :
     bearMomentum ? color.rgb(194, 7, 7, 26) :
     na
)
````
