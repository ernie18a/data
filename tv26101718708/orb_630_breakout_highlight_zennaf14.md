# ORB 6:30 Breakout Highlight

- url: https://www.tradingview.com/script/zeNNaF14-ORB-6-30-Breakout-Highlight/
- type: indicator
- pine_id: PUB;8e9ca71e930e4fe187f84680a21eb0e2
- version: 1.0

## Description

Here is my personal orb breakout indicator that can be adjusted for any time frame or session.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("ORB 6:30 Breakout Highlight", overlay = true, max_boxes_count = 100)

// --- Inputs ---
string sessionInput  = input.session("0630-0645", "Opening Range Time", tooltip = "Define the opening range period (e.g., 0630-0645 for a 15-min range).")
string timezoneInput = input.string("America/New_York", "Timezone", tooltip = "The timezone for the session hours.")
color  rangeColor    = input.color(color.new(#5b9cf6, 90), "Range Fill Color")
color  breakoutColor = input.color(color.yellow, "Breakout Candle Color")

// --- Logic ---
// Check time states
bool inRange      = not na(time(timeframe.period, sessionInput, timezoneInput))
bool rangeStart   = inRange and not inRange[1]
bool rangeEnd     = not inRange and inRange[1]
bool afterRange   = not inRange and not na(time(timeframe.period, "0000-2359", timezoneInput)) // Active trading day

// State variables
var float rangeHigh      = na
var float rangeLow       = na
var int   rangeStartBar  = na
var bool  breakoutFound  = false
var box   rangeBox       = na

// Reset logic at the start of the range
if rangeStart
    rangeHigh     := high
    rangeLow      := low
    rangeStartBar := bar_index
    breakoutFound := false
    rangeBox      := box.new(bar_index, rangeHigh, bar_index, rangeLow, border_color = color.new(chart.fg_color, 50), bgcolor = rangeColor)

// Update range during the session
if inRange
    rangeHigh := math.max(high, rangeHigh)
    rangeLow  := math.min(low, rangeLow)
    box.set_top(rangeBox, rangeHigh)
    box.set_bottom(rangeBox, rangeLow)
    box.set_right(rangeBox, bar_index)

// Detect Breakout after the range is established
bool isBreakout = false

if afterRange and not breakoutFound and not na(rangeHigh)
    if close > rangeHigh or close < rangeLow
        isBreakout := true
        breakoutFound := true

// --- Visualization ---
// Highlight the breakout candle
barcolor(isBreakout ? breakoutColor : na, title = "Breakout Candle")

// Plot the range levels for clarity
plot(afterRange ? rangeHigh : na, "Range High", color = color.new(chart.fg_color, 70), style = plot.style_linebr)
plot(afterRange ? rangeLow : na, "Range Low", color = color.new(chart.fg_color, 70), style = plot.style_linebr)
````
