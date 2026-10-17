# Momentum Flow Oscillator

- url: https://www.tradingview.com/script/KRnSaoTR-Momentum-Flow-Oscillator/
- type: indicator
- pine_id: PUB;30a78745e81e4225b2b4c803cc0dafda
- version: 1.0

## Description

Momentum Flow Oscillator

The Momentum Flow Oscillator is a multi-component momentum analysis tool designed to help traders study changes in market momentum, strength, and trend pressure through a single normalized oscillator.

Rather than relying on a single traditional oscillator, it combines three complementary components:

Momentum— measures price movement relative to market volatility using ATR normalization.
RSI Strength — evaluates relative price strength around a neutral zero line.
Trend Pressure — measures the relationship between price and an EMA baseline, normalized by volatility.

These components are combined into a single Momentum Flow value and smoothed to reduce short-term noise.

Key Components

Momentum Flow
The primary oscillator line represents the combined momentum conditions of the market.

Signal Line
A smoothed version of the Momentum Flow helps visualize changes in short-term momentum.

Momentum Histogram
The histogram displays the difference between Momentum Flow and its signal line, making changes in momentum expansion and contraction easier to observe.

Zero Line
The zero line provides a central reference for positive and negative momentum conditions.

Upper & Lower Levels
The configurable upper and lower levels provide additional reference points for identifying relatively strong or weak momentum conditions.

How to Read It

When Momentum Flow moves above the zero line, momentum is showing positive pressure. When it moves below zero, negative pressure is dominant.

Changes in the histogram can help identify periods where momentum is strengthening or losing strength.

Crosses between the Momentum Flow and Signal Line can highlight potential momentum shifts for further analysis.

The indicator is designed as a confirmation and market-analysis tool rather than a standalone trading system. It can be combined with price structure, trend analysis, volatility, volume, or other technical tools when evaluating market conditions.
Market Analysis

The indicator can be used across different markets and timeframes. ATR normalization helps account for differences in market volatility, making the underlying momentum measurements more adaptable across instruments.

The Momentum Flow Oscillator focuses on understanding market momentum rather than predicting future price movement.

Disclaimer: This indicator is for educational and informational purposes only and does not constitute financial or investment advice. Trading involves risk, and past performance does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Momentum Flow Oscillator", shorttitle="MFO", overlay=false)

//────────────────────────────────────────────
// INPUTS
//────────────────────────────────────────────
groupMomentum = "Momentum"
momentumLength = input.int(14, "Momentum Length", minval=2, group=groupMomentum)
rsiLength = input.int(14, "RSI Length", minval=2, group=groupMomentum)

groupTrend = "Trend Pressure"
emaLength = input.int(34, "Trend EMA Length", minval=2, group=groupTrend)

groupSmoothing = "Smoothing"
smoothLength = input.int(5, "Smoothing Length", minval=1, group=groupSmoothing)

groupLevels = "Levels"
overbought = input.float(60.0, "Upper Level", group=groupLevels)
oversold = input.float(-60.0, "Lower Level", group=groupLevels)

//────────────────────────────────────────────
// MOMENTUM COMPONENT
//────────────────────────────────────────────
priceChange = close - close[momentumLength]
atrValue = ta.atr(momentumLength)

normalizedMomentum = atrValue != 0 ? (priceChange / atrValue) * 20.0 : 0.0
momentumComponent = math.max(-100.0, math.min(100.0, normalizedMomentum))

//────────────────────────────────────────────
// RSI COMPONENT
//────────────────────────────────────────────
rsiValue = ta.rsi(close, rsiLength)
rsiComponent = (rsiValue - 50.0) * 2.0

//────────────────────────────────────────────
// TREND PRESSURE COMPONENT
//────────────────────────────────────────────
trendEma = ta.ema(close, emaLength)

trendDistance = atrValue != 0 ? ((close - trendEma) / atrValue) * 30.0 : 0.0
trendComponent = math.max(-100.0, math.min(100.0, trendDistance))

//────────────────────────────────────────────
// COMPOSITE OSCILLATOR
//────────────────────────────────────────────
rawOscillator = momentumComponent * 0.40 + rsiComponent * 0.35 + trendComponent * 0.25

oscillator = ta.ema(rawOscillator, smoothLength)
signal = ta.ema(oscillator, smoothLength)

histogram = oscillator - signal

//────────────────────────────────────────────
// MOMENTUM STATE
//────────────────────────────────────────────
bullishMomentum = oscillator > 0
bearishMomentum = oscillator < 0

bullishShift = ta.crossover(oscillator, signal)
bearishShift = ta.crossunder(oscillator, signal)

//────────────────────────────────────────────
// REFERENCE LEVELS
//────────────────────────────────────────────
hline(0, "Zero Line", color=color.gray)
hline(overbought, "Upper Level", color=color.red, linestyle=hline.style_dashed)
hline(oversold, "Lower Level", color=color.green, linestyle=hline.style_dashed)

//────────────────────────────────────────────
// HISTOGRAM
//────────────────────────────────────────────
histColor = histogram >= 0 ? (histogram > histogram[1] ? color.lime : color.green) : (histogram < histogram[1] ? color.red : color.orange)

plot(
     histogram,
     title="Momentum Histogram",
     style=plot.style_columns,
     color=histColor
)

//────────────────────────────────────────────
// OSCILLATOR LINE
//────────────────────────────────────────────
oscColor = oscillator >= 0 ? color.aqua : color.orange

plot(
     oscillator,
     title="Momentum Flow",
     color=oscColor,
     linewidth=2
)

//────────────────────────────────────────────
// SIGNAL LINE
//────────────────────────────────────────────
plot(
     signal,
     title="Signal",
     color=color.yellow,
     linewidth=1
)

//────────────────────────────────────────────
// MOMENTUM SHIFT MARKERS
//────────────────────────────────────────────
plotshape(
     bullishShift,
     title="Bullish Momentum Shift",
     style=shape.triangleup,
     location=location.bottom,
     color=color.lime,
     size=size.tiny
)

plotshape(
     bearishShift,
     title="Bearish Momentum Shift",
     style=shape.triangledown,
     location=location.top,
     color=color.red,
     size=size.tiny
)

//────────────────────────────────────────────
// ALERTS
//────────────────────────────────────────────
alertcondition(
     bullishShift,
     title="Bullish Momentum Shift",
     message="Vertex Momentum Flow Oscillator: Bullish momentum shift detected."
)

alertcondition(
     bearishShift,
     title="Bearish Momentum Shift",
     message="Vertex Momentum Flow Oscillator: Bearish momentum shift detected."
)
````
