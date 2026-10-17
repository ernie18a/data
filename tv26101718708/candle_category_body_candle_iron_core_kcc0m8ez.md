# Candle Category (Body %) - Candle Iron Core

- url: https://www.tradingview.com/script/kCc0m8ez-Candle-Category-Body-Candle-Iron-Core/
- type: indicator
- pine_id: PUB;60dad24dc4534c7a85d523a621c9487a
- version: 1.0

## Description

The Candle Category (Body %) - Candle Iron Core indicator [i] classifies every candle into one of three categories[/i] based exclusively on the relationship between the candle body and its total range.

The purpose of this tool is to help traders quickly identify the level of directional conviction present in each candle without relying on subjective visual interpretation.

Instead of treating all candles equally, this script highlights whether a candle represents:

[list]
[*]Trend Candle
[*]Semi-Trend Candle
[*]Non-Trending Candle
[/list]

This allows traders to objectively evaluate price action strength and market participation.

[b]Core Concept[/b]

The underlying idea is simple:

A candle with a large body relative to its total range generally reflects stronger directional intent, while a candle with a small body suggests indecision or balanced order flow.
The script measures the percentage of the candle body relative to the entire candle range.

[i]Mathematically:[/i]

Body Size = |Close - Open|

Total Range = High - Low

Body Percentage = (Body Size / Total Range) × 100

[b]Candle Classification[/b]
The indicator separates candles into three categories:

[b]1. Trend Candle[/b]

A candle is considered a Trend Candle when:

Body % ≥ Trend Threshold

These candles usually represent strong directional participation and momentum.

Default threshold:

50%
[b]2. Semi-Trend Candle[/b]

A candle is considered a Semi-Trend Candle when:

Semi-Trend Threshold ≤ Body % < Trend Threshold

These candles show moderate directional conviction but less strength than a full Trend Candle.

Default threshold:

20%
[b]3. Non-Trending Candle[/b]

A candle is considered Non-Trending when:

Body % < Semi-Trend Threshold

These candles typically reflect indecision, balanced participation, absorption, or consolidation.

[b]Settings[/b]
[i][b]Trend Candle Minimum Body %[/b][/i]

Defines the minimum body percentage required for a candle to be classified as a Trend Candle.

Default: 50%

[i][b]Semi-Trend Candle Minimum Body %[/b][/i]

Defines the minimum body percentage required for a candle to be classified as a Semi-Trend Candle.

Default: 20%

[b]What This Indicator Does NOT Use[/b]

This script intentionally ignores:

[list]
[*]Volume
[*]Volatility measurements
[*]ATR
[*]Market structure
[*]Order flow
[*]Delta
[*]Session information
[*]Time-based filters
[/list]

The classification is based solely on candle geometry.
This design keeps the indicator lightweight, objective, and universally applicable across all markets and timeframes.


[b]Practical Uses[/b]

Traders may use this indicator to:

[list]
[*]Identify strong momentum candles.
[*]Filter weak or indecisive price action.
[*]Study candle behavior statistically.
[*]Improve discretionary price action analysis.
[*]Build systematic trading models based on candle quality.
[*]Visually distinguish between expansion and consolidation phases.
[/list]


[b]Notes[/b]

This indicator does not generate trading signals and should not be used as a standalone trading system.
It is designed as a price action classification tool intended to complement a broader trading framework.

As always, market context remains essential.

## Source Code

````pine
//@version=6
// © Candle Iron Core
// Classifies and colors candles based on body percentage relative to the full candle range.

indicator("Candle Category (Body %) - Candle Iron Core", overlay=true)

// =====================
// Candle Body Thresholds
// =====================
trendThreshold = input.float(50.0, "Trend Candle Minimum Body %", step=1.0, minval=1, maxval=100)
semiTrendThreshold = input.float(20.0, "Semi-Trend Candle Minimum Body %", step=1.0, minval=0, maxval=99)

// =====================
// Candle Body Colors
// =====================
bullishTrendColor = input.color(color.rgb(13, 143, 24), "Bullish Trend Candle")
bearishTrendColor = input.color(color.rgb(253, 0, 0), "Bearish Trend Candle")

bullishSemiTrendColor = input.color(color.new(color.rgb(13, 143, 24), 65), "Bullish Semi-Trend Candle")
bearishSemiTrendColor = input.color(color.new(color.rgb(253, 0, 0), 65), "Bearish Semi-Trend Candle")

nonTrendingColor = input.color(color.rgb(0, 0, 0), "Non-Trending Candle")

// =====================
// Candle Calculation
// =====================
candleRange = high - low
bodySize = math.abs(close - open)

bodyPercent = candleRange > 0 ? bodySize / candleRange * 100.0 : 0.0

isBullish = close >= open
isTrend = bodyPercent >= trendThreshold
isSemiTrend = bodyPercent >= semiTrendThreshold and bodyPercent < trendThreshold

// =====================
// Final Candle Color
// =====================
finalColor =
     isTrend ? (isBullish ? bullishTrendColor : bearishTrendColor) :
     isSemiTrend ? (isBullish ? bullishSemiTrendColor : bearishSemiTrendColor) :
     nonTrendingColor

// =====================
// Apply Color To Native Candles
// =====================
barcolor(finalColor)
````
