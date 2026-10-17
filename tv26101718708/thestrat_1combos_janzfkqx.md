# TheSTRAT 1-Combos

- url: https://www.tradingview.com/script/JaNzfkQX-TheSTRAT-1-Combos/
- type: indicator
- pine_id: PUB;eb3af49bdd2044b4821d5e295e450c12
- version: 1.0

## Description

Simple indicator that flags and sends an alert when a 3-1, 2-1, or 1-1 combination forms on the close of the 1 candle. This should give any STRAT user an opportunity to trade the break of the following candle.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Quant

//@version=6
indicator("The STRAT Patterns Alert", shorttitle="STRAT Alerts", overlay=true)

// --- Definitions ---
// Define the STRAT bar types
// 1 = Inside Bar
// 2 = Directional Bar
// 3 = Outside Bar

is_1 = high < high[1] and low > low[1]
is_2 = (high > high[1] and low >= low[1]) or (high <= high[1] and low < low[1])
is_3 = high > high[1] and low < low[1]

// --- Patterns ---
// Detect combinations ending in a '1'
pat_31 = is_1 and is_3[1]
pat_21 = is_1 and is_2[1]
pat_11 = is_1 and is_1[1]

// --- Visuals ---
// Highlight the patterns on the chart
plotshape(pat_31, title="3-1 Pattern", text="3-1", style=shape.labeldown, location=location.abovebar, color=color.new(#5b9cf6, 0), textcolor=color.white, size=size.small)
plotshape(pat_21, title="2-1 Pattern", text="2-1", style=shape.labeldown, location=location.abovebar, color=color.new(#089981, 0), textcolor=color.white, size=size.small)
plotshape(pat_11, title="1-1 Pattern", text="1-1", style=shape.labeldown, location=location.abovebar, color=color.new(#f23645, 0), textcolor=color.white, size=size.small)

// --- Alerts ---
// Trigger alerts on the close of the bar
if pat_31
    alert("STRAT 3-1 Pattern detected on " + syminfo.ticker + " (" + timeframe.period + ")", alert.freq_once_per_bar_close)

if pat_21
    alert("STRAT 2-1 Pattern detected on " + syminfo.ticker + " (" + timeframe.period + ")", alert.freq_once_per_bar_close)

if pat_11
    alert("STRAT 1-1 Pattern detected on " + syminfo.ticker + " (" + timeframe.period + ")", alert.freq_once_per_bar_close)
````
