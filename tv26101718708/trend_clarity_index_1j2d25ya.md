# Trend Clarity Index

- url: https://www.tradingview.com/script/1J2D25yA-Trend-Clarity-Index/
- type: indicator
- pine_id: PUB;ed8ebc58ee614477a3afb04e189bb294
- version: 1.0

## Description

This indicator measures the quality of the current trend, not just its direction. It checks whether price is above or below the EMA and evaluates how strongly each candle closes in the direction of that trend.

A high score means the trend is clean and well-structured. A lower score suggests weak closes, noisy price action, or less reliable trend conditions.

Green = clean bullish trend
Red = clean bearish trend
Gray = neutral or unclear trend
Higher score = cleaner trend
Lower score = weaker or dirtier trend

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © scharb1


//@version=6
indicator("Trend Clarity Index", shorttitle="Trend Clairity", overlay=false)

// Inputs
emaLen = input.int(50, "Trend EMA")
smooth = input.int(5, "Smoothing")

// Trend
ema = ta.ema(close, emaLen)
bull = close > ema
bear = close < ema

// Close position inside candle
rng = math.max(high - low, syminfo.mintick)
closePos = (close - low) / rng * 100

// Distance from EMA
distance = math.abs(close - ema) / ema * 100
distanceScore = math.min(distance * 10, 100)

// Clean score
rawScore = bull ? closePos : bear ? 100 - closePos : 50
score = rawScore * 0.8 + distanceScore * 0.2
scoreSmooth = ta.sma(score, smooth)

// Signals
cleanBull = scoreSmooth > 65 and bull
cleanBear = scoreSmooth > 65 and bear
dirty = scoreSmooth < 35

// Color
lineColor = cleanBull ? color.lime : cleanBear ? color.red : color.gray

// Plot
plot(scoreSmooth, "Trend Clean Score", color=lineColor, linewidth=2)

hline(65, "Clean Trend", color=color.new(color.gray, 40))
hline(50, "Neutral", color=color.new(color.gray, 70))
hline(35, "Dirty", color=color.new(color.gray, 40))

// Background
bgcolor(cleanBull ? color.new(color.green, 85) : cleanBear ? color.new(color.red, 85) : dirty ? color.new(color.orange, 88) : na)
````
