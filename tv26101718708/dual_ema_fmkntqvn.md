# Dual EMA

- url: https://www.tradingview.com/script/FMkNtQvN-Dual-EMA/
- type: indicator
- pine_id: PUB;bb97a479da554c24bbb5fda23d43e305
- version: 1.0

## Description

Here is the complete Pine Script code for a version 6 indicator that plots two Exponential Moving Averages (EMAs) with default lengths of 9 and 20. It includes customizable inputs so you can adjust the values directly from the indicator settings.

## Source Code

````pine
//@version=6
indicator(title="Custom Dual EMA (9, 20)", shorttitle="Dual EMA", overlay=true)

// --- Inputs ---
// These create the options in the indicator settings menu to change the EMA lengths.
ema1_length = input.int(defval=9, title="First EMA Length", minval=1)
ema2_length = input.int(defval=20, title="Second EMA Length", minval=1)

// --- Calculations ---
// Calculate the EMAs based on the closing price and the lengths provided in the inputs.
ema1 = ta.ema(close, ema1_length)
ema2 = ta.ema(close, ema2_length)

// --- Plotting ---
// Plot both EMAs on the chart.
plot(ema1, title="First EMA", color=color.blue, linewidth=2)
plot(ema2, title="Second EMA", color=color.orange, linewidth=2)

// Optional: Highlight crossovers
// Uncomment the lines below if you want shapes to appear when the EMAs cross.
// crossUp = ta.crossover(ema1, ema2)
// crossDown = ta.crossunder(ema1, ema2)
// plotshape(series=crossUp, title="Bullish Cross", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
// plotshape(series=crossDown, title="Bearish Cross", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)
````
