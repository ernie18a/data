# Weekly Open Bias - Adjustable EMAs

- url: https://www.tradingview.com/script/HxSFincl-Weekly-Open-Bias-Adjustable-EMAs/
- type: indicator
- pine_id: PUB;ad7a1eed42f5488eafcb27e87716a8ee
- version: 1.0

## Description

Weekly Open Bias IndicatorThis indicator helps traders track market sentiment by analyzing price action relative to the Weekly Open Price. 
It provides a clear visual anchor for long-term and swing trading biases.

Key FeaturesWeekly Anchor: Automatically tracks and plots the open price of the current week.

Dynamic Bias Shading: 
Background turns green when the price is above the weekly open, and red when it is below.Adjustable Moving Averages: 

Includes customizable Fast (9) and Slow (15) Exponential Moving Averages (EMAs) to capture trend direction.

Pine Script v6: Fully updated and optimized for TradingView’s latest script architecture.

How to Use It.
Bullish Bias: Look for long setups when the background is green and the fast EMA is above the slow EMA.

Bearish Bias: Look for short setups when the background is red and the fast EMA is below the slow EMA.Key Support/Resistance: Treat the blue weekly open line as a major psychological pivot point.

## Source Code

````pine
//@version=6
// Author: Simon20cent (Modified for Weekly Session)
indicator("Weekly Open Bias - Adjustable EMAs", overlay=true)

// --- INPUTS ---
// Allows you to change EMA lengths from the settings cog icon
emaFastLength = input.int(9, title="Fast EMA Length", minval=1)
emaSlowLength = input.int(15, title="Slow EMA Length", minval=1)

// --- WEEKLY OPEN LOGIC ---
// Track the start of a new weekly session (explicit boolean for v6)
is_new_week = (ta.change(time("W")) != 0)

// Persistent variable to store the weekly open price
var float weeklyOpen = na

// Update the weekly open value when a new week session begins
if is_new_week
    weeklyOpen := open

// Plot the Weekly Open Line
plot(weeklyOpen, title="Weekly Open", color=color.blue, linewidth=2, style=plot.style_stepline)

// --- BIAS COLORING ---
bool is_bullish = close > weeklyOpen
bool is_bearish = close < weeklyOpen

color biasColor = is_bullish ? color.new(color.green, 92) : is_bearish ? color.new(color.red, 92) : na
bgcolor(biasColor)

// --- ADJUSTABLE EMAs ---
emaFast = ta.ema(close, emaFastLength)
emaSlow = ta.ema(close, emaSlowLength)

plot(emaFast, color=color.green, title="Fast EMA Line")
plot(emaSlow, color=color.orange, title="Slow EMA Line")
````
