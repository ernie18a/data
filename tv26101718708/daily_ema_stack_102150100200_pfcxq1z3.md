# Daily EMA Stack 10/21/50/100/200

- url: https://www.tradingview.com/script/PFcXq1Z3-Daily-EMA-Stack-10-21-50-100-200/
- type: indicator
- pine_id: PUB;9f197035ef2544c1b2ccf919cc059cf7
- version: 2.0

## Description

Daily EMA Stack 10/21/50/100/200

A clean multi-timeframe EMA overlay that displays the 10, 21, 50, 100, and 200 Daily EMAs on any chart timeframe.

Unlike standard moving averages that recalculate based on the current chart interval, this indicator anchors all calculations to the Daily timeframe. Whether you're viewing a 1-minute, 5-minute, hourly, daily, or weekly chart, the displayed EMAs remain the true Daily EMAs.

Features:
• 10, 21, 50, 100, and 200 Daily EMAs
• One-click visibility instead of managing multiple indicators
• Individual EMA on/off controls
• Consistent Daily EMA levels across all timeframes
• Color-coded for quick identification
• Lightweight and uncluttered design

EMA Colors:
10 EMA – Red
21 EMA – Orange
50 EMA – Green
100 EMA – Cyan
200 EMA – Purple

Designed for momentum, swing, and growth traders who use Daily moving averages for trend analysis while executing on lower timeframes.

## Source Code

````pine
//@version=6
indicator("Adaptive Daily-Equivalent EMA Stack", overlay=true)

// Visibility Controls
show10  = input.bool(true, "10-Day Equivalent EMA")
show21  = input.bool(true, "21-Day Equivalent EMA")
show50  = input.bool(true, "50-Day Equivalent EMA")
show100 = input.bool(true, "100-Day Equivalent EMA")
show200 = input.bool(true, "200-Day Equivalent EMA")

// Bars per day by chart timeframe
barsPerDay = switch timeframe.period
    "1"  => 390
    "5"  => 78
    "30" => 13
    "65" => 6
    "D"  => 1
    "W"  => 1
    => 1

// Length multiplier
baseMultiplier = timeframe.period == "W" ? 1 : barsPerDay

// Equivalent EMA lengths
len10  = 10 * baseMultiplier
len21  = 21 * baseMultiplier
len50  = 50 * baseMultiplier
len100 = 100 * baseMultiplier
len200 = 200 * baseMultiplier

// EMA Calculations
ema10  = ta.ema(close, len10)
ema21  = ta.ema(close, len21)
ema50  = ta.ema(close, len50)
ema100 = ta.ema(close, len100)
ema200 = ta.ema(close, len200)

// Plots
plot(show10 ? ema10 : na, title="10-Day Equivalent EMA", color=color.rgb(242, 54, 69), linewidth=1)
plot(show21 ? ema21 : na, title="21-Day Equivalent EMA", color=color.rgb(255, 152, 0), linewidth=1)
plot(show50 ? ema50 : na, title="50-Day Equivalent EMA", color=color.rgb(76, 175, 80), linewidth=1)
plot(show100 ? ema100 : na, title="100-Day Equivalent EMA", color=color.rgb(38, 198, 218), linewidth=1)
plot(show200 ? ema200 : na, title="200-Day Equivalent EMA", color=color.rgb(74, 20, 140), linewidth=1)
````
