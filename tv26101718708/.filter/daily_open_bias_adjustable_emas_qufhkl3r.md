# Daily Open Bias - Adjustable EMAs

- url: https://www.tradingview.com/script/qufhKl3r-Daily-Open-Bias-Adjustable-EMAs/
- type: indicator
- pine_id: PUB;09d4e9133c85438ebc3d699dafb81c5e
- version: 1.0

## Description

OverviewThis indicator is built around a foundational intraday rule: only look for long setups when the price is above the daily open, and only look for short setups when the price is below it. 
By using the daily opening price as a structural "line in the sand," this script filters out low-probability counter-trend trades and keeps you aligned with the dominant daily institutional momentum.
Developed in modern Pine Script v6, the script is optimized for indices like the NASDAQ (NQ) but works universally across any asset class.
Key FeaturesAutomatic Daily Open Plotter: Draws a clean, real-time step-line marking the exact opening price of the current daily session.Instant Bias Background Shading: Automatically shades the chart background green when the price trades above the daily open (bullish territory) and red when it trades below (bearish territory).
Adjustable Dual EMAs: Features two customizable Exponential Moving Averages (defaulting to 9 and 15 periods) to help you track immediate momentum, entries, and trailing stop-losses.
Clean UI & Performance: Lightweight code logic that removes screen clutter and ensures lag-free execution on fast timeframes like the 3-minute chart.

How to Trade It Bullish Bias (Green Background): 
Look for buying opportunities when the price holds above the blue Daily Open line. 
High-probability entries occur when the price pulls back to test the EMAs or the Daily Open line as support.
Bearish Bias (Red Background): Look for shorting opportunities when the price sustains below the blue Daily Open line. High-probability entries occur when the price rallies into the EMAs or the Daily Open line to test them as resistance.
Script architecture by Simon20cent.

## Source Code

````pine
//@version=6
// Author: Simon20cent
indicator("Daily Open Bias - Adjustable EMAs", overlay=true)

// --- INPUTS ---
// Allows you to change EMA lengths from the settings cog icon
emaFastLength = input.int(9, title="Fast EMA Length", minval=1)
emaSlowLength = input.int(15, title="Slow EMA Length", minval=1)

// --- DAILY OPEN LOGIC ---
// Track the start of a new daily session (explicit boolean for v6)
is_new_day = (ta.change(time("D")) != 0)

// Persistent variable to store the daily open price
var float dailyOpen = na

// Update the daily open value when a new day session begins
if is_new_day
    dailyOpen := open

// Plot the Daily Open Line
plot(dailyOpen, title="Daily Open", color=color.blue, linewidth=2, style=plot.style_stepline)

// --- BIAS COLORING ---
bool is_bullish = close > dailyOpen
bool is_bearish = close < dailyOpen

color biasColor = is_bullish ? color.new(color.green, 92) : is_bearish ? color.new(color.red, 92) : na
bgcolor(biasColor)

// --- ADJUSTABLE EMAs ---
emaFast = ta.ema(close, emaFastLength)
emaSlow = ta.ema(close, emaSlowLength)

plot(emaFast, color=color.green,  title="Fast EMA Line")
plot(emaSlow, color=color.orange, title="Slow EMA Line")
````
