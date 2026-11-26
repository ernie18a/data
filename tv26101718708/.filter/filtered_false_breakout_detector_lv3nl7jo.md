# Filtered False Breakout Detector

- url: https://www.tradingview.com/script/lV3NL7jO-filtered-false-breakout-detector/
- type: indicator
- pine_id: PUB;98ab777f7b92410a9d060f6a9fa8509b
- version: 1.0

## Description

The indicator has been updated with the requested filters to increase the reliability of the signals.
New Filter Logic:
Swing High/Low Filter: The "level-establishing" candle (Candle 1 in your sequence) must now be a local peak or trough. It checks the preceding 5 bars (adjustable in settings) to ensure the level being broken was actually a significant point of interest.
Higher Volume Requirement: The "breakout" candle (Candle 2) must now have a higher volume than the level-establishing candle. This ensures there is a surge of participation during the breach before the price fails.
Controls:
Swing Lookback: You can increase this value in the settings to look for even more significant peaks/troughs.
Volume Toggle: You can disable the volume requirement in the settings if you want to see signals based purely on price action.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Filtered False Breakout Detector", overlay = true, max_labels_count = 500)

// --- Colors ---
color C_GREEN = #089981
color C_RED   = #f23645

// --- Inputs ---
int   swingLookback = input.int(5, "Swing Lookback", minval = 2, tooltip = "Number of preceding bars to check if the level candle was a local high/low")
bool  useVolFilter  = input.bool(true, "Require Higher Breakout Volume", tooltip = "The breakout candle must have more volume than the level-establishing candle")

// --- Logic ---
// We look back at a 3-candle sequence: [2], [1], [0]
// Candle [2]: Establishes the level
// Candle [1]: Breaks the level
// Candle [0]: Closes back inside the level

// 1. Swing High/Low Filter (Candle [2] significance)
// We check if Candle [2] was the highest/lowest of the preceding 'n' bars
isSwingHigh = high[2] >= ta.highest(high, swingLookback)[3]
isSwingLow  = low[2]  <= ta.lowest(low, swingLookback)[3]

// 2. Volume Filter (Candle [1] vs Candle [2])
volFilter = not useVolFilter or (volume[1] > volume[2])

// Bearish False Breakout (Sell Signal)
bearLevel   = high[2]
bearBreak   = high[1] > bearLevel
bearFailure = close < bearLevel
bearSignal  = isSwingHigh and bearBreak and bearFailure and volFilter

// Bullish False Breakout (Buy Signal)
bullLevel   = low[2]
bullBreak   = low[1] < bullLevel
bullFailure = close > bullLevel
bullSignal  = isSwingLow and bullBreak and bullFailure and volFilter

// --- Visuals ---
plotshape(bullSignal, 
     title         = "Bullish False Breakout", 
     style         = shape.triangleup, 
     location      = location.belowbar, 
     color         = C_GREEN, 
     size          = size.small, 
     text          = "FBO", 
     textcolor     = C_GREEN)

plotshape(bearSignal, 
     title         = "Bearish False Breakout", 
     style         = shape.triangledown, 
     location      = location.abovebar, 
     color         = C_RED, 
     size          = size.small, 
     text          = "FBO", 
     textcolor     = C_RED)

// Alerts
alertcondition(bullSignal, title = "Bullish FBO", message = "Bullish False Breakout Detected")
alertcondition(bearSignal, title = "Bearish FBO", message = "Bearish False Breakout Detected")
````
