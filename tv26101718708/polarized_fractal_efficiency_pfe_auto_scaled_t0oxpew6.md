# Polarized Fractal Efficiency (PFE) - Auto Scaled

- url: https://www.tradingview.com/script/T0OxPew6/
- type: indicator
- pine_id: PUB;b0520c6659974067bdd051d20741c260
- version: 1.0

## Description

Polarized Fractal Efficiency (PFE) - Auto Scaled

Original concept by Hans Hannula, programmer and trader. First published in Technical Analysis of Stocks & Commodities magazine, January 1994.

The Polarized Fractal Efficiency (PFE) indicator measures the efficiency of price movement over a given period. It compares the direct distance between the start and end price to the actual path taken by the price.

A value near +100 indicates a highly efficient upward trend, while a value near -100 indicates a highly efficient downward trend. Values near 0 suggest choppy, inefficient price movement.

Key Feature: Automatic Scaling

The original PFE formula uses absolute price differences, which causes the indicator to behave differently depending on the price level of the underlying asset. At high price levels, the squaring of price differences in the formula leads to very large values, resulting in erratic and visually unusable indicator curves with no meaningful signal.

This version automatically scales the input prices based on their magnitude using a logarithmic approach, ensuring consistent and smooth indicator curves regardless of price.

Parameters:
- Observation Period (n): The lookback period for the PFE calculation (default: 10)
- Smoothing Length: EMA smoothing applied to the raw PFE values (default: 5)

Reference Lines:
- +60: Strong uptrend threshold
- -60: Strong downtrend threshold
- 0: Neutral / zero line

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © danny_tor

//@version=6
indicator("PFE scaler", overlay=false)

// Length of the observation period (default 10)
n = input.int(10, title="Observation Period (n)", minval=1)
emaLength = input.int(5, title="Smoothing Length")

// Automatic scaling based on magnitude of close
float scale = math.pow(10, math.floor(math.log(close) / math.log(10)))
float closeScaled = close / scale

// Calculate sign
sign = closeScaled[0] >= closeScaled[n] ? 1 : -1

// Calculate numerator of PFE formula
numerator = math.sqrt(math.pow(closeScaled[0] - closeScaled[n], 2) + math.pow(n, 2))

// Calculate denominator of PFE formula
sum_diffs = 0.0
for i = 1 to n
    sum_diffs += math.sqrt(math.pow(closeScaled[i] - closeScaled[i - 1], 2) + 1)

denominator = sum_diffs

// Calculate PFE value
pfe = sign * (numerator / denominator) * 100

// Smoothing with EMA
pfeSmoothed = ta.ema(pfe, emaLength)

// Plotting
plot(pfeSmoothed, color=color.green, linewidth=2)
hline(0, "Zero Line", color=color.gray)

// Reference lines
hline(60,  "up",       color=color.red)
hline(-60, "down",     color=color.green)
hline(0,   "zero line", color=color.gray)
````
