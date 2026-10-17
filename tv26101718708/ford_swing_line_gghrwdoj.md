# Ford Swing Line

- url: https://www.tradingview.com/script/gGHRwDOJ-Ford-Swing-Line/
- type: indicator
- pine_id: PUB;aa259bbd86784a43a99c7e100a1af307
- version: 1.0

## Description

This Indicator grabs the most recent high and the most recent low and can be used to show when a higher high or lower low has formed on your time frame

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © saf18hornet

//@version=5
indicator("Ford Swing Line", overlay=true)

// Input for swing length
swingLength = input(5, title="Swing Length")

// Variables to track swing lines
var float lastHigh = na
var float lastLow = na
var line swingHighLine = na
var line swingLowLine = na
var line previousHighLine = na
var line previousLowLine = na
var float high_line = na
var float low_line = na
var float swing_line = na
var float previousHigh = na  // To track the previous significant high
var float previousLow = na   // To track the previous significant low

// Identify Higher Highs and Lower Lows based on High/Low
high_line := (high < high_line[1] and low > low_line[1]) ? high_line[1] : high
low_line := (high < high_line[1] and low > low_line[1]) ? low_line[1] : low

swing_line := (swing_line[1] == high_line or swing_line[1] == low_line) ? swing_line[1] : 
              (high_line > high_line[1] and low_line < low_line[1]) ? 
              (high_line[1] == swing_line[1] ? high_line : low_line) : 
              (high_line > high_line[1] ? high_line : low_line)

// Plot the swing line for High/Low
plot(swing_line, color=color.new(color.green, 0), title="Swing Line (High/Low)")

// Identify higher highs and lower lows
if high > ta.highest(high, swingLength)[1]
    lastHigh := high
    // Create or update the swing high line
    if na(swingHighLine)
        swingHighLine := line.new(bar_index, lastHigh, bar_index + 100, lastHigh, color=color.green, width=2)  // Extend the line to the right
    else
        line.set_xy1(swingHighLine, bar_index, lastHigh)  // Start from the current bar
        line.set_xy2(swingHighLine, bar_index + 100, lastHigh)  // Extend to the right

if low < ta.lowest(low, swingLength)[1]
    lastLow := low
    // Create or update the swing low line
    if na(swingLowLine)
        swingLowLine := line.new(bar_index, lastLow, bar_index + 100, lastLow, color=color.red, width=2)  // Extend the line to the right
    else
        line.set_xy1(swingLowLine, bar_index, lastLow)  // Start from the current bar
        line.set_xy2(swingLowLine, bar_index + 100, lastLow)  // Extend to the right

// Track the previous higher high when the swing line is redefined as the low line
if swing_line == low_line and not na(lastHigh) and lastHigh != high[1]
    previousHigh := lastHigh  // Store the last high when swing line is redefined

// Track the previous lower low when the swing line is redefined as the high line
if swing_line == high_line and not na(lastLow) and lastLow != low[1]
    previousLow := lastLow  // Store the last low when swing line is redefined

// Draw a horizontal ray at the previous higher high
if not na(previousHigh)
    if na(previousHighLine)
        previousHighLine := line.new(bar_index - 1, previousHigh, bar_index + 100, previousHigh, color=color.blue, width=2)  // Extend the line to the right
    else
        line.set_xy1(previousHighLine, bar_index - 1, previousHigh)  // Start from the previous bar
        line.set_xy2(previousHighLine, bar_index + 100, previousHigh)  // Extend to the right

// Draw a horizontal ray at the previous lower low
if not na(previousLow)
    if na(previousLowLine)
        previousLowLine := line.new(bar_index - 1, previousLow, bar_index + 100, previousLow, color=color.purple, width=2)  // Extend the line to the right
    else
        line.set_xy1(previousLowLine, bar_index - 1, previousLow)  // Start from the previous bar
        line.set_xy2(previousLowLine, bar_index + 100, previousLow)  // Extend to the right
````
