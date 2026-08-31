<!-- tradingview-pine-id: PUB;38a1851f2f3e42e89f6ae83345a039e5 -->
<!-- tradingviewscripts-format: 1 -->
# 3 EMAs by TradeZene

Source: https://www.tradingview.com/script/9oPqALsS-3-EMA-Trend-by-TradeZene/

## Description

Three EMAs in 1 Indicator

Overview

The 3 EMAs in 1 Indicator is a clean, lightweight trend-following tool that plots three customizable Exponential Moving Averages (EMAs) on a single chart, making it easy to identify the short-, medium-, and long-term market trend at a glance.

Designed for traders who prefer simplicity over clutter, this indicator provides visual trend confirmation through subtle background coloring while keeping the chart clean and easy to read.

Features

✅ Three fully customizable EMAs

EMA 1 (Default: 9)
EMA 2 (Default: 27)
EMA 3 (Default: 108)

✅ Individual show/hide options for each EMA

✅ Automatic trend background

Light Blue: Price is above EMA 2 (Bullish Bias)
Light Orange: Price is below EMA 2 (Bearish Bias)

✅ Lightweight and fast

Works smoothly on all timeframes and market instruments.

Suggested Usage

Many traders use the three EMA combination to:

Identify the overall market trend
Stay on the right side of momentum
Filter counter-trend trades
Improve trade selection alongside price action
Combine with support/resistance, VWAP, market structure, or volume analysis

This indicator is intentionally simple so it can fit into almost any trading strategy.

Default Settings

EMA 1: 9
EMA 2: 27
EMA 3: 108

These values can be customized to suit your trading style.

Disclaimer

This indicator is provided for educational and informational purposes only. It should not be considered financial or investment advice. Trading involves risk, and past performance does not guarantee future results. Always perform your own analysis and manage risk appropriately.

If you find this indicator useful, please consider giving it a 👍, adding it to your favorites, and share with your trader friends.

Happy Trading!

---

## Source Code

````pine
//=============================================================================
// TradeZene's 3 EMAs in 1 Indicator
// Version: 1.0
// Release Date: 08-Aug-2026
//@version=6

indicator("3 EMAs by TradeZene", shorttitle="TZ_3EMAs", overlay=true, timeframe="", timeframe_gaps=true)

// ======================================================
// INPUTS
// ======================================================

ema1Len = input.int(9, title="EMA 1 Length", minval=1)
ema2Len = input.int(27, title="EMA 2 Length", minval=1)
ema3Len = input.int(108, title="EMA 3 Length", minval=1)

showEMA1 = input.bool(true, "Show EMA 1")
showEMA2 = input.bool(true, "Show EMA 2")
showEMA3 = input.bool(true, "Show EMA 3")

// ======================================================
// EMA CALCULATIONS
// ======================================================

ema1 = ta.ema(close, ema1Len)
ema2 = ta.ema(close, ema2Len)
ema3 = ta.ema(close, ema3Len)

// ======================================================
// PLOT EMAs
// ======================================================

plot(showEMA1 ? ema1 : na, title="EMA 1", color=color.blue, linewidth=1)
plot(showEMA2 ? ema2 : na, title="EMA 2", color=color.black, linewidth=2)
plot(showEMA3 ? ema3 : na, title="EMA 3", color=color.orange, linewidth=2)

// ======================================================
// BACKGROUND LOGIC
// ======================================================

bullTrend = close > ema2
bearTrend = close < ema2
// Bullish only when FULL candle is above EMA 2
//bullTrend = open > ema2 and close > ema2

// Bearish only when FULL candle is below EMA 2
//bearTrend = open < ema2 and close < ema2

// Background coloring
bgcolor(bullTrend ? color.new(color.blue, 90) : bearTrend ? color.new(color.orange, 70) : na)
````
