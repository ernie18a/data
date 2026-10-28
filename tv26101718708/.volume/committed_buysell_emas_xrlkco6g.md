# Committed Buy-Sell + EMAs

- url: https://www.tradingview.com/script/XRlKCo6g-Committed-Buy-Sell-EMAs/
- type: indicator
- pine_id: PUB;d2b6ff380d1d42429194323bbc3ee55e
- version: 1.0

## Description

The indiactor paints bars/candles based on % of change and corresponding volumes.

Big move + More than 1.5 time average volume - Blue candles
Positive candles with greater than average volume - Green candles
Negative candles with greater than average volume - Red candles

5 EMAs

10, 20, 50, 65 and 200

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © krunal2711

//@version=6
indicator('Committed Buy-Sell', overlay = true)

// 1. Calculations
avgVol = ta.sma(volume, 20)
priceChangePct = 100 * (close - close[1]) / close[1]

// 2. Define Conditions
// Bullish (High Commitment): Vol > 1.5x average AND price up > 3%
bullishCondition = volume > 1.5 * avgVol and priceChangePct > 3

// NEW: Standard Bullish: Vol > average AND price up > 0%
// (Ensuring this doesn't override the 3% move)
standardBullish = volume > avgVol and priceChangePct > 0

// Bearish: Vol > 1.0x average AND price is negative (down)
bearishCondition = volume > avgVol and priceChangePct < 0

// 3. Plotting logic
// Priority: 1. Deep Blue (Strong) -> 2. Green (Moderate) -> 3. Red (Bearish)
barColor = bullishCondition ? color.rgb(24, 56, 236) : 
           standardBullish   ? color.green : 
           bearishCondition  ? color.red : na

barcolor(barColor)

// Shapes
plotshape(bullishCondition, style=shape.triangleup, location=location.belowbar, color=color.blue, size=size.small)
plotshape(bearishCondition, style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

// --- 1. EMA Calculations ---
ema10 = ta.ema(close, 10)
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)
ema65 = ta.ema(close, 65)
ema200 = ta.ema(close, 200)

// Plotting EMAs
plot(ema10, color=color.black, title="10 EMA", linewidth=2)
plot(ema20, color=color.blue,  title="20 EMA", linewidth=2)
plot(ema50, color=color.rgb(46, 207, 52), title="50 EMA", linewidth=2)
plot(ema65, color=color.rgb(64, 224, 208), title="65 EMA", linewidth=2)
plot(ema200, color=color.rgb(247, 23, 23), title="200 EMA", linewidth=2)//
````
