# Boshmann's Market Direction Hist

- url: https://www.tradingview.com/script/I787djWC-Boshmann-s-Market-Direction-Hist/
- type: indicator
- pine_id: PUB;4386e0b2a5e94ae4a6efdb06a76e8f63
- version: 2.0

## Description

[b]Boshmann's Market Direction Hist[/b]
The theory behind a directional histogram is to visually quantify not just the direction of a trend, but its underlying momentum and the distance between moving averages. While identifying a trend regime categorizes the market into a fixed state (bull, bear, or sideways), measuring the spread between a fast and slow moving average reveals whether that trend is accelerating, decelerating, or reaching exhaustion. By projecting this spread as an oscillator around a zero line, traders can easily spot momentum divergences and gauge the true strength of a directional move.

[b]How the Script Works: [/b]The script calculates the raw distance between a short-term moving average (20-period SMA) and a long-term moving average (100-period SMA). To ensure the indicator works seamlessly across any asset class or timeframe—whether a stock is trading at $5 or $50,000—it normalizes this distance as a percentage of the current price. It then plots this normalized momentum as a histogram. Finally, the histogram bars are painted using the exact same logic as the Regime Counters script: Green for Strong Bull, Red for Strong Bear, and Yellow for Sideways.
[b]
Why You Should Use It: [/b]This script is explicitly designed to be used in combination with the Regime Counters and Volatility Histogram scripts to form a complete, three-dimensional view of the market.

A user should use this histogram because while the Regime Counter tells you what state the market is in, the Direction Histogram tells you how strong that state is. For example, if the Regime Counter classifies the market as "Bullish" but you see the green bars on this histogram steadily shrinking toward the zero line, it is a leading indicator that upward momentum is dying long before the official regime flips. Together, the three scripts allow you to trade systematically: the Regime Counter dictates your directional bias, the Volatility script warns you of price expansion, and the Direction Histogram measures the real-time conviction pushing the trend.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © boshmann

//@version=6
indicator('Boshmann\'s Direction Hist v2 (Normalized)', overlay = false)

trendPeriod = input.int(200, 'Trend SMA Period', minval = 1)
shortPeriod = input.int(20, 'Short SMA Period', minval = 1)
longPeriod = input.int(100, 'Long SMA Period', minval = 1)

// ATR Normalization Period
atrPeriod = input.int(14, 'ATR Normalization Period', minval = 1)

trendSMA = ta.sma(close, trendPeriod)
shortSMA = ta.sma(close, shortPeriod)
longSMA = ta.sma(close, longPeriod)

isPriceAboveTrend = close > trendSMA
isShortAboveLong = shortSMA > longSMA

isStrongBull = isPriceAboveTrend and isShortAboveLong
isStrongBear = not isPriceAboveTrend and not isShortAboveLong
isSideways = not isStrongBull and not isStrongBear

colorBull = color.new(color.green, 0)
colorBear = color.new(color.red, 0)
colorSideways = color.new(#DAA520, 0)

dirColor = isStrongBull ? colorBull : isStrongBear ? colorBear : colorSideways

// v2 Normalization: Measure spread in units of Volatility (ATR)
rawSpread = shortSMA - longSMA
atrVal = ta.atr(atrPeriod)
// Protect against division by zero
dirHistVal = atrVal == 0 ? 0 : rawSpread / atrVal

plot(dirHistVal, style = plot.style_histogram, color = dirColor, linewidth = 3, title = 'Direction Hist Normalized')
hline(0, 'Zero Line', color = color.gray)
````
