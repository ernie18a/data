# Fibonacci Institutional Impulse

- url: https://www.tradingview.com/script/4EAFNwoG-Fibonacci-Institutional-Impulse/
- type: indicator
- pine_id: PUB;d3c47731c57d4c0bbf0d39aeeaa0a521
- version: 1.0

## Description

FII (Fibonacci Institutional Impulse) is a modified version of the original indicator created by blublub and distributed under the Mozilla Public License 2.0 (MPL 2.0).

This version was expanded and refined by kedwar13 to improve trend visualization and emphasize price interaction with the Fibonacci 0.5 deviation bands.

MODIFICATIONS
Changes made in this version include:
• Added 60 EMA and 200 EMA trend overlays
• Added Fibonacci 0.5 band crossing visualization
• Added configurable Fibonacci Band settings
• Added visual labels and alert conditions
• Improved chart readability and script organization
• Updated and standardized naming/labels

INDICATOR PURPOSE
This indicator is designed to highlight price interaction with the Fibonacci 0.5 deviation bands derived from a VWMA-based volatility structure.
The 0.5 bands may act as dynamic areas of:
• momentum continuation,
• trend confirmation,
• pullback reactions,
• or possible exhaustion.
The included EMA overlays help provide broader trend context and directional bias.

IMPORTANT DISCLAIMER
This indicator is NOT a standalone buy or sell signal system.
The plotted labels and alerts only indicate that price has crossed a Fibonacci 0.5 band. Crossings alone should not be treated as guaranteed entries or exits.
Signals should always be confirmed using additional analysis such as:
• market structure,
• price action,
• support/resistance,
• volume,
• or higher timeframe trend confirmation.

This tool is intended to be used as a confluence and market context indicator rather than an automated trading strategy.

CREDITS
Original script:
© blublub
Modified and extended by:
kedwar13

Licensed under MPL 2.0:
https://mozilla.org/MPL/2.0/

## Source Code

````pine
//@version=6
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © blublub
// Modified by TRJ3D1

indicator(
     "Trend Indicator with Fibonacci Band 0.5 crossings",
     shorttitle = "FII",
     overlay = true,
     format = format.price,
     precision = 2)

//━━━━━━━━━━━━━━━━━━
// EMA VARIABLES
//━━━━━━━━━━━━━━━━━━

shortEMA = ta.ema(close, 60)
longEMA  = ta.ema(close, 200)

plot(shortEMA, title = "60 EMA", color = color.green)
plot(longEMA,  title = "200 EMA", color = color.rgb(217, 103, 103), linewidth = 2)

//━━━━━━━━━━━━━━━━━━
// TREND VARIABLES
//━━━━━━━━━━━━━━━━━━

period      = input.int(5, "CCI Period")
coeff       = input.float(2.0, "ATR Multiplier")
AP          = input.int(1, "ATR Period")

ATR         = ta.sma(ta.tr, AP)

src         = input.source(hlc3, "Main Input Data / Symbol")

cci_value   = input.int(20, "CCI Value Threshold for Neutral Trend")
cci_top     = input.int(165, "CCI Top / Overbought")
cci_bottom  = input.int(-165, "CCI Bottom / Oversold")

upT         = low - ATR * coeff
downT       = high + ATR * coeff

//━━━━━━━━━━━━━━━━━━
// FIBONACCI BAND SETTINGS
//━━━━━━━━━━━━━━━━━━

FBB_length  = input.int(200, "Fibonacci Length", minval = 1)
FBB_mult    = input.float(2.5, "Fibonacci Multiplier", minval = 0.001, maxval = 50)

//━━━━━━━━━━━━━━━━━━
// FIBONACCI BAND CALCULATION
//━━━━━━━━━━━━━━━━━━

dev         = FBB_mult * ta.stdev(src, FBB_length)
FBB_basis   = ta.vwma(src, FBB_length)

lower_FBB   = FBB_basis - (0.5 * dev)
upper_FBB   = FBB_basis + (0.5 * dev)

//━━━━━━━━━━━━━━━━━━
// CROSS DETECTION
//━━━━━━━━━━━━━━━━━━

FBB_UpCross   = ta.crossover(src, lower_FBB)
FBB_DownCross = ta.crossover(src, upper_FBB)

//━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━

plotshape(
     FBB_UpCross,
     location = location.belowbar,
     style = shape.labelup,
     color = color.lime,
     size = size.small,
     title = "FIB 0.5 Buy Signal")

plotshape(
     FBB_DownCross,
     location = location.abovebar,
     style = shape.labeldown,
     color = color.red,
     size = size.small,
     title = "FIB 0.5 Sell Signal")

plot(lower_FBB, color = color.purple, linewidth = 2, title = "-0.5")
plot(upper_FBB, color = color.purple, linewidth = 2, title = "0.5")

//━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━

alertcondition(
     FBB_UpCross,
     title = "FIB 0.5 Buy Signal",
     message = "Price crossed lower 0.5 Fibonacci Band")

alertcondition(
     FBB_DownCross,
     title = "FIB 0.5 Sell Signal",
     message = "Price crossed upper 0.5 Fibonacci Band")
````
