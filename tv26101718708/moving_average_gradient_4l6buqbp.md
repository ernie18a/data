# Moving Average Gradient

- url: https://www.tradingview.com/script/4l6BuqBP-Moving-Average-Gradient/
- type: indicator
- pine_id: PUB;b77643bb2bc04c26b9a2623c3449bb28
- version: 1.0

## Description

The 'Moving Average Gradient' (MAG) is basically a measure of the gradient of a moving average.

Firstly a moving average (SMA or EMA) is overlayed onto the chart.

Then the gradient of this moving average is calculated and plotted below.

An optional smoothing average is also applied to the gradient.

This MAG is my own invention and is entirely new, as far as I know.


I've found it to be useful for divergences.

It can also be quite similar to the Stochastic, and works well taking a BUY signal when the gradient crosses over its moving average, and SELL when it crosses under.


In fact I backtested both this MAG, and the Stochastic as a comparison, within a strategy using the above signals, and the MAG delivered better results.

The strategy on BTCUSD 15 minute also included:

 * 4hr MACD Signal change > 0.0034 %

 * 4hr MACD Signal value < 0.5 % 


...for BUY, with the opposite for SELL.


And if you think that strategy involved writing Pine Script code, then you're probably not familiar with my suite of strategy tools published on here.

I was able to very quickly and easily create and backtest that strategy without writing any code at all, using just:

 * MAG or Stochastic

 * MACD

 * Simple BUY/SELL Indicator - to create the strategy rules using the above indicators (or I could've used my Custom BUY/SELL Indicator)

 * Simple Pyramid Strategy - to run the backtesting strategy (or I could've used my Complex Single Trade Strategy)

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © JustinTimeTunes

//@version=6
indicator(title = "Moving Average Gradient", shorttitle = "MAG")

// The 'Moving Average Gradient' (MAG) is basically a measure of the gradient of a moving average.
// Firstly a moving average (SMA or EMA) is overlayed onto the chart.
// Then the gradient of this moving average is calculated and plotted below.
// An optional smoothing average is also applied to the gradient.
// This MAG is my own invention and is entirely new, as far as I know.
//
// I've found it to be useful for divergences.
// It can also be quite similar to the Stochastic, and works well taking a BUY signal when the gradient crosses over its moving average, and SELL when it crosses under.
//
// In fact I backtested both this MAG, and the Stochastic as a comparison, within a strategy using the above signals, and the MAG delivered better results.
// The strategy on BTCUSD 15 minute also included:
//  * 4hr MACD Signal change > 0.0034 %
//  * 4hr MACD Signal value < 0.5 % 
// ...for BUY, with the opposite for SELL.
//
// And if you think that strategy involved writing Pine Script code, then you're probably not familiar with my suite of strategy tools published on here.
// I was able to very quickly and easily create and backtest that strategy without writing any code at all, using just:
//  * MAG or Stochastic
//  * MACD
//  * Simple BUY/SELL Indicator - to create the strategy rules using the above indicators (or I could've used my Custom BUY/SELL Indicator)
//  * Simple Pyramid Strategy - to run the backtesting strategy (or I could've used my Complex Single Trade Strategy)


// Inputs

float sourceInput = input.source(defval = close, title = "Source", group = "Moving Average", display = display.none)

string maTypeInput = input.string(defval = "SMA", title = "MA Type",  options = ["SMA", "EMA"], group = "Moving Average", display = display.none)

int maLengthInput = input.int(defval = 29, title = "MA Length", minval = 1, maxval = 10000, step = 1, group = "Moving Average", display = display.none)

int barsBackInput = input.int(defval = 1, title = "Bars Back", minval = 1, maxval = 1000, step = 1, group = "Gradient", display = display.none,
    tooltip = "Number of bars back to test gradient for.")

bool addSmoothingInput = input.bool(defval = true, title = "Add Smoothing MA", group = "Gradient Smoothing", display = display.none)

string smoothingTypeInput = input.string(defval = "EMA", title = "Gradient Smoothing Type", options = ["SMA", "EMA"], group = "Gradient Smoothing", display = display.none)

int smoothingLengthInput = input.int(defval = 5, title = "Gradient Smoothing Length", minval = 1, maxval = 10000, step = 1, group = "Gradient Smoothing", display = display.none)


// Calculations

float ma = (maTypeInput == "SMA" ? ta.sma(sourceInput, maLengthInput) : ta.ema(sourceInput, maLengthInput))

float gradient = ta.change(ma, barsBackInput)

float gradientMA = (smoothingTypeInput == "SMA" ? ta.sma(gradient, smoothingLengthInput) : ta.ema(gradient, smoothingLengthInput))


// GUI

maPlot = plot(series = ma, title = "Moving Average", linewidth = 2, color = color.white, force_overlay = true)

gradientPlot = plot(series = gradient, title = "Gradient", linewidth = 2, color = color.yellow, force_overlay = false)

smoothingColour = color.rgb(0, 0, 0, 100)
if addSmoothingInput
    smoothingColour := color.blue

gradientMAPlot = plot(series = gradientMA, title = "Gradient MA", linewidth = 2, color = smoothingColour, force_overlay = false)

midLinePlot = plot(0, color = na, editable = false, display = display.none)

hline(0, "Zero line", color = color.new(#787B86, 50), linestyle = hline.style_solid)

colourGradientLevel = ta.atr(400)
colourGradientLevel /= 2

fill(gradientPlot, midLinePlot, colourGradientLevel, 0, top_color = color.new(color.green, 0), bottom_color = color.new(color.green, 100), title = "Overbought")
fill(gradientPlot, midLinePlot, 0, colourGradientLevel * -1,  top_color = color.new(color.red, 100), bottom_color = color.new(color.red, 0), title = "Oversold")
````
