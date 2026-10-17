# Touch & CrossSMA 50/200/400 To Signal

- url: https://www.tradingview.com/script/UR4zj5AC-Touch-CrossSMA-50-200-400-To-Signal/
- type: indicator
- pine_id: PUB;49dbdb5b624e432fa565f7b7c42b7b5e
- version: 2.0

## Description

SMA Touch & Cross Signal is a clean trend signal indicator based on SMA 50, SMA 200 and normal SMA400 .

It focuses on key market structure changes by detecting when short-term momentum (SMA 50) interacts with long-term trend (SMA 200).

🔹 Features / 功能
SMA 50 / SMA 200 / SMA 400 trend lines
Signals when SMA 50 crosses SMA 200
Clean visual markers (no noise, no background clutter)
Suitable for trend reversal identification
🔹 How to use / 使用方法
Green triangle: SMA 50 crosses above SMA 200 (bullish shift / 多头趋势变化)
Red triangle: SMA 50 crosses below SMA 200 (bearish shift / 空头趋势变化)

This indicator helps traders identify potential trend changes and momentum shifts in a simple and clean way.

🔹 Best timeframe / 适用周期
1H (1小时)
4H (4小时）
Daily（日线)
🔹 Notes / 说明

This tool is designed for trend-following and breakout-confirmation strategies. It avoids noise and focuses only on meaningful structural changes.

This script is designed for educational and analytical purposes.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © yingxinxiong1 This script is designed for educational and analytical purposes.

//@version=6
indicator("Touch & CrossSMA 50/200/400 To Signal", shorttitle="SMA Touch", overlay=true)

// SMAs
sma50  = ta.sma(close, 50)
sma200 = ta.sma(close, 200)
sma400 = ta.sma(close, 400)

// Trend plots
plot(sma50,  title="SMA 50",  color=color.blue,   linewidth=2)
plot(sma200, title="SMA 200", color=color.yellow, linewidth=2)
plot(sma400, title="SMA 400", color=color.red,    linewidth=2)

// ─────────────────────
// SIGNAL LOGIC
// ─────────────────────

// "Touch" = crossover OR crossunder
bullSignal = ta.crossover(sma50, sma200)
bearSignal = ta.crossunder(sma50, sma200)

// ─────────────────────
// PLOT SIGNALS (only event-based)
// ─────────────────────
plotshape(bullSignal,
     title="Bull Touch/Cross",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.green,
     size=size.small,
     text="50>200")

plotshape(bearSignal,
     title="Bear Touch/Cross",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.small,
     text="50<200")

// ─────────────────────
// ALERTS
// ─────────────────────
alertcondition(bullSignal,
     title="Bullish SMA Cross",
     message="SMA 50 crossed ABOVE SMA 200")

alertcondition(bearSignal,
     title="Bearish SMA Cross",
     message="SMA 50 crossed BELOW SMA 200")
````
