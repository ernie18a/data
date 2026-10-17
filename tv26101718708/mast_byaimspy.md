# MAST 

- url: https://www.tradingview.com/script/ByAIMSPy-MAST/
- type: indicator
- pine_id: PUB;526111f92da541b68137f7d01bce0724
- version: 1.0

## Description

What is the MAST Trend Indicator?

The MAST (Moving Average SuperTrend) Trend indicator is a systematic momentum-following system designed to filter market noise and isolate clean macro trends. By blending a structural volatility filter (Supertrend) with a localized momentum line (SMA/EMA), it maps out clear high-probability market cycles while ignoring minor counter-trend fluctuations.

Core Components & Mechanics

The Core Matrix Engine: The indicator runs a continuous matrix comparison between where the closing price sits relative to both your selected Moving Average (the baseline momentum) and the Supertrend band (the volatility boundary).

Color-Coded Market States: The ribbon cloud dynamically fills your chart screen using distinct color states to map structural health:
Green (Bullish Expansion): Price rules above both the MA and the Supertrend. This signals a clean long trend.
Red (Bearish Expansion): Price drops below both metrics, indicating active downward momentum.
Blue / Purple (Transition States): These warning colors flag compression or potential distribution phases where the MA and Supertrend conflict, warning you to avoid forcing positions in a choppy environment.
Volume Validation Guard: Trend changes must pass an institutional volume filter. If a trend flip occurs on low volume, the script strips out the buy/sell signal to protect you from retail traps and false breakouts.

Optimal Use Cases

The MAST system is highly effective for intraday trend-riding in fast-moving markets like Nifty, Bank Nifty, and Index Futures. It helps you identify when a market shifts from a range-bound state into an explosive directional trend.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © svennela

//@version=6
indicator("MAST by VS", overlay = true)

// --- CONFIGURATION INPUTS ---
maType  = input.string("SMA", "Moving Average Type", options = ["SMA", "EMA"])
maLen   = input.int(10, "Moving Average Period", minval = 1)
multp   = input.float(3.0, "Supertrend Multiplier", step = 0.1)
stLen   = input.int(10, "Supertrend Period", minval = 1)

// --- MOVING AVERAGE CALCULATION ---
float maValue = na
if maType == "SMA"
    maValue := ta.sma(close, maLen)
else
    maValue := ta.ema(close, maLen)

// --- SUPERTREND CALCULATION ---
[superTrend, dir] = ta.supertrend(multp, stLen)

// --- COLOR AND LOGIC LAYER ---
// Use hex-alpha appending (last 2 digits) to safely define transparency profiles in v6
color longFillColor  = color.new(color.lime, 80)
color shortFillColor = color.new(color.red, 80)
color bullTrendColor = color.new(color.blue, 80)
color bearTrendColor = color.new(color.purple, 80)

color lineCol = na
color fillCol = na

if close < maValue
    if close > superTrend
        lineCol := color.blue
        fillCol := bullTrendColor
    else
        lineCol := color.red
        fillCol := shortFillColor
else
    if close < superTrend
        lineCol := color.purple
        fillCol := bearTrendColor
    else
        lineCol := color.lime
        fillCol := longFillColor

// --- RENDER ENGINE ---
// Plots tracking components across the chart canvas
longStopPlot  = plot(dir == -1 ? superTrend : na, style = plot.style_linebr, color = color.gray, linewidth = 1, title = "Long Stop")
shortStopPlot = plot(dir ==  1 ? superTrend : na, style = plot.style_linebr, color = color.gray, linewidth = 1, title = "Short Stop")
maPlot        = plot(maValue, color = lineCol, linewidth = 2, title = "Trend Line")

// Fills chart channels based on localized trend variables
fill(maPlot, longStopPlot,  title = "Long State Filling",  color = fillCol)
fill(maPlot, shortStopPlot, title = "Short State Filling", color = fillCol)
````
