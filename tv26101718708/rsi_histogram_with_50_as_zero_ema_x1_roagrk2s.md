# RSI Histogram with 50 as Zero (EMA x1)

- url: https://www.tradingview.com/script/RoagrK2s/
- type: indicator
- pine_id: PUB;a26982e6b67b4cf299a28a4ca3da79a7
- version: 2.0

## Description

RSI Histogram with 50 as Zero (EMA x1)

This indicator is a simplified RSI (Relative Strength Index) momentum tool designed to make market strength and weakness easier to visualize.

Instead of displaying RSI on its traditional 0–100 scale, the indicator centers RSI around the 50 level, treating it as the zero line. This allows traders to quickly identify bullish and bearish market conditions.

 Features

 RSI Histogram

The histogram displays RSI values relative to the 50 level.

* Above 0 → Bullish momentum
* Below 0 → Bearish momentum

This provides a clear view of market strength and momentum shifts.

 Smoothed RSI EMA

An Exponential Moving Average (EMA) is applied to the RSI to help identify the underlying momentum trend.

* EMA above 0 → Bullish bias
* EMA below 0 → Bearish bias

 Color-Coded Momentum

Histogram colors change based on the relationship between RSI and its EMA.

* RSI > EMA → Bright Green
* RSI < EMA → Dark Green

This helps visualize momentum acceleration and deceleration.

 Possible Uses

* Trend confirmation
* Momentum analysis
* Pullback and continuation setups
* Divergence analysis
* Confirmation alongside other technical indicators

 Notes

This indicator is not intended to generate direct buy or sell signals.

It is designed as a momentum and market-strength visualization tool and works best when combined with price action, volume analysis, trend analysis, and other technical tools.

## Source Code

````pine
//@version=6
indicator("RSI Histogram with 50 as Zero (EMA x1)", overlay=false, format=format.price)

// Input
length = input.int(defval=14, title="EMA Length", step=1)
rsi_length = input.int(defval=14, title="RSI Period", minval=1)

// RSI
rsi = ta.rsi(close, rsi_length)

// EMA
smoothed_rsi_ema = ta.ema(rsi, length)

// 50基準
rsi_diff_from_50 = rsi - 50

// 色分け
hist_color = rsi > smoothed_rsi_ema ? color.rgb(0, 212, 106) : color.rgb(95, 147, 145)

// RSI Histogram（棒グラフ・最細）
plot(rsi_diff_from_50, title="RSI Histogram (Centered at 50)", style=plot.style_columns, color=hist_color, linewidth=1)

// RSI EMA（ライン・最細）
plot(smoothed_rsi_ema - 50, title="RSI EMA (Centered at 50)", color=smoothed_rsi_ema > 50 ? color.lime : #F44336, linewidth=1)

// Zero Line
hline(0, title="Zero Line (Centered at 50)", color=#787B86)
````
