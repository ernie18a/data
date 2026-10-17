# Thermometer Oscillator

- url: https://www.tradingview.com/script/wDP3T97G-Thermometer-Oscillator/
- type: indicator
- pine_id: PUB;122edbe5e4434365a48e9f9771554390
- version: 1.0

## Description

Thermometer Oscillator scores each bar from -5 to +5 by comparing its close, open and range with the bar before, and smooths the score with a moving average.

HOW IT WORKS
The score is the sum of three parts:
• Close vs previous close: +2 higher, -2 lower, 0 unchanged.
• Close vs open: +2 up candle, -2 down candle, 0 doji.
• Range vs previous close: +1 if the whole bar is above the previous close (gap up that holds), -1 if the whole bar is below it, 0 if the bar touches it.
+5 is the strongest up bar (higher close, up candle, entirely above the previous close); -5 the strongest down bar.

HOW TO USE IT
• Readings at +3 to +5 or -3 to -5 show strong one-sided bars.
• The moving average shows the prevailing bias: above zero, up bars dominate; below zero, down bars dominate.
• A move of the average through zero marks a shift in that balance.

INPUTS
• MA Length: the moving average length (9).
• MA Type: EMA, SMA, WMA or RMA (EMA).

DRAWING AND LIMITATIONS
• Plotted in its own pane, blue score line and yellow average, with reference lines at +5, +3, 0, -3 and -5. Colours are set in the Style tab.
• The current bar's score changes until the bar closes.
• Works on any symbol and timeframe.

CREDITS
The Thermometer as taught by David Bowden.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © bashu9
//@version=6

//#region Header Info
// ——————————————————————————————————————————————————————————————————————————
// Indicator:   Thermometer Oscillator
// Author:      bashu9
// Description: Thermometer Oscillator: a -5..+5 close/open/range composite with a moving average.
// ——————————————————————————————————————————————————————————————————————————
//#endregion

indicator(title="Thermometer Oscillator", shorttitle="Thermo", overlay=false)

// ─────────────────────────────────────────────
// Component 1 · Close vs Previous Close  (+2 / 0 / -2)
// ─────────────────────────────────────────────
comp1 = close > close[1] ? 2 : close < close[1] ? -2 : 0

// ─────────────────────────────────────────────
// Component 2 · Close vs Today's Open  (+2 / 0 / -2)
// ─────────────────────────────────────────────
comp2 = close > open ? 2 : close < open ? -2 : 0

// ─────────────────────────────────────────────
// Component 3 · Today's Range vs Previous Close  (+1 / 0 / -1)
//   +1 → entire range ABOVE  prev close (low > close[1])
//   -1 → entire range BELOW  prev close (high < close[1])
//    0 → prev close is WITHIN or touches the range
// ─────────────────────────────────────────────
comp3 = low > close[1] ? 1 : high < close[1] ? -1 : 0

// ─────────────────────────────────────────────
// Thermometer value  (range: -5 to +5)
// ─────────────────────────────────────────────
thermo = comp1 + comp2 + comp3

// ─────────────────────────────────────────────
// Inputs · Moving Average
// ─────────────────────────────────────────────
ma_length = input.int(9,     title="MA Length",  minval=1)
ma_type   = input.string("EMA", title="MA Type", options=["EMA", "SMA", "WMA", "RMA"])

ma = switch ma_type
    "EMA" => ta.ema(thermo, ma_length)
    "SMA" => ta.sma(thermo, ma_length)
    "WMA" => ta.wma(thermo, ma_length)
    "RMA" => ta.rma(thermo, ma_length)

// ─────────────────────────────────────────────
// Line plot (RSI-style)
// ─────────────────────────────────────────────
plot(thermo,
     title     = "Thermometer",
     style     = plot.style_line,
     color     = color.new(#2196f3, 0),
     linewidth = 2)

plot(ma,
     title     = "MA",
     style     = plot.style_line,
     color     = color.new(color.yellow, 0),
     linewidth = 1)

// ─────────────────────────────────────────────
// Reference lines  (fixed scale -5 to +5)
// ─────────────────────────────────────────────
hline( 5, "+5",   color = color.new(#ef5350, 40),    linestyle = hline.style_dashed, linewidth = 1)
hline( 3, "+3",   color = color.new(#ef5350, 70),    linestyle = hline.style_dotted, linewidth = 1)
hline( 0, "Zero", color = color.new(color.gray, 20), linestyle = hline.style_solid,  linewidth = 1)
hline(-3, "-3",   color = color.new(#26a69a, 70),    linestyle = hline.style_dotted, linewidth = 1)
hline(-5, "-5",   color = color.new(#26a69a, 40),    linestyle = hline.style_dashed, linewidth = 1)
````
