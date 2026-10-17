#  ABN 8:30 AM Extended Level

- url: https://www.tradingview.com/script/jihuQvVw-ABN-8-30-AM-Extended-Level/
- type: indicator
- pine_id: PUB;c565f7ee79bd4b39ab183c5459ef304d
- version: 1.0

## Description

8:30 Open Indicator – Precision Market Bias Tool

The 8:30 Open Indicator is designed to help traders quickly identify daily market direction using one of the most important time-based levels in the market.

Built around the 8:30 AM session open, this tool provides a clear and structured way to frame bias:

Above 8:30 Open → Look for sells
Below 8:30 Open → Look for buys

This simple but powerful concept allows traders to align with intraday flow and avoid unnecessary noise.

🔹 Key Features:

Automatic marking of the 8:30 AM open level
Clean visual reference for intraday bias
Works across multiple markets (indices, gold, oil, forex)
Perfect for session-based trading strategies

🔹 Best Use Case:
Ideal for traders who focus on timing, precision, and high-probability setups, especially during the Asian and New York sessions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("8:30 AM Extended Level", overlay = true, max_lines_count = 100)

// --- Inputs ---
sessionInput = input.session("0830-0831", "Start Time", tooltip = "The time of day to start the line (e.g., 08:30 AM).")
timezone     = input.string("UTC-4", "Timezone", tooltip = "The timezone for the session (e.g., UTC-4 for New York).")
historyCount = input.int(2, "Days of History to Show", minval = 1, maxval = 100, tooltip = "Number of previous 8:30 AM lines to keep on the chart.")
lineColor    = input.color(#5b9cf6, "Line Color", group = "Style")
lineWidth    = input.int(1, "Line Width", minval = 1, group = "Style")
lineStyleStr = input.string("Solid", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = "Style")
showLabel    = input.bool(true, "Show Label", group = "Style")

// --- Logic ---
// Convert style string to line style constant
lineStyle = switch lineStyleStr
    "Solid"  => line.style_solid
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    => line.style_solid

// Time detection for the 8:30 AM candle (1-minute precision)
t            = time("1", sessionInput, timezone)
isNewSession = not na(t) and na(t[1])

// Array to manage multiple lines for historical days
var line[] linesArray = array.new_line()

if isNewSession
    // 1. Create the new line for today's 8:30 AM open
    newLine = line.new(
         x1    = bar_index, 
         y1    = open, 
         x2    = bar_index + 1, 
         y2    = open, 
         color = lineColor, 
         width = lineWidth, 
         style = lineStyle
         )
    
    // 2. Add to our tracking array
    array.push(linesArray, newLine)
    
    // 3. Manage historical lines: delete the oldest if we exceed historyCount
    if array.size(linesArray) > historyCount + 1
        line.delete(array.shift(linesArray))

    // 4. Create a label at the start point if enabled
    if showLabel
        label.new(bar_index, open, "8:30 AM OPEN", xloc.bar_index, yloc.price, #00000000, label.style_label_left, chart.fg_color, size.small)

// --- Extension Logic ---
// Every bar, we update the end point (x2) of the most recent line 
// so it continuously extends to the right until the next 8:30 AM session.
if array.size(linesArray) > 0
    currentLine = array.get(linesArray, array.size(linesArray) - 1)
    line.set_x2(currentLine, bar_index)

// Note: Historical lines stop updating once a new one is created, 
// so they remain as segments connecting one day's 8:30 AM to the next.
````
