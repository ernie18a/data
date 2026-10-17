# Candle Counter/ Range Highlight-  9:30 or Futures 18:00 EST Open

- url: https://www.tradingview.com/script/TZ7m1ucy-Candle-Counter-Range-Highlight-9-30-or-Futures-18-00-EST-Open/
- type: indicator
- pine_id: PUB;75f56054b3304bed8d7cce05a66d6e70
- version: 1.0

## Description

This script counts candles and adds labels for the RTH 9:30 EST or Futures 18:00 EST Open.  This can be useful for chart analysis and identifying patterns.  You can also ask it to count and highlight several candles / highlight them together as a range.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Claude

//@version=6
indicator("Candle Counter", overlay=true, max_labels_count=500)

// ════════════════════════════════════════════════════════════════════════════════
// INPUT SETTINGS
// ════════════════════════════════════════════════════════════════════════════════

sessionReference = input.string("RTH Open (9:30 EST)", "Session Reference", 
     options=["RTH Open (9:30 EST)", "Futures Open (18:00 EST)"])

// Candle selection
startCandle = input.int(1, "Start Candle Number", minval=1, maxval=200)
endCandle = input.int(1, "End Candle Number", minval=1, maxval=200, 
     tooltip="Set to same as Start to mark single candle, or higher to mark a range")

// Display options
showLabels = input.bool(true, "Show Candle Numbers")
highlightColor = input.color(color.new(color.blue, 90), "Highlight Color")
labelColor = input.color(color.white, "Label Text Color")

// ════════════════════════════════════════════════════════════════════════════════
// SESSION TIME CALCULATION
// ════════════════════════════════════════════════════════════════════════════════

// Get time in EST
estTime = time("1", "America/New_York")
estHour = hour(estTime, "America/New_York")
estMinute = minute(estTime, "America/New_York")

// Detect new session based on selected reference
bool isNewSession = false
bool inSession = false

if sessionReference == "RTH Open (9:30 EST)"
    // RTH opens at 9:30 AM EST, Mon-Fri
    rthSession = "0930-1600:23456"
    sessionTime = time(timeframe.period, rthSession, "America/New_York")
    inSession := not na(sessionTime)
    isNewSession := inSession and na(sessionTime[1])
else
    // Futures open at 6:00 PM EST (18:00)
    // Detect when we cross 18:00
    prevEstHour = hour(estTime[1], "America/New_York")
    
    // New session when hour becomes 18 and previous hour was not 18
    // This works for any day of the week
    isNewSession := estHour == 18 and estMinute == 0 and prevEstHour != 18
    
    // We're "in session" from 18:00 onwards each day (24hr market)
    inSession := true

// ════════════════════════════════════════════════════════════════════════════════
// CANDLE COUNTING LOGIC
// ════════════════════════════════════════════════════════════════════════════════

var int candleNumber = 0
var int sessionCounter = 0

// Count sessions for debugging
if isNewSession
    sessionCounter := sessionCounter + 1

// Reset counter on new session, otherwise increment
if isNewSession
    candleNumber := 1
else if sessionReference == "RTH Open (9:30 EST)" and inSession
    candleNumber := candleNumber + 1
else if sessionReference == "Futures Open (18:00 EST)"
    // For futures, always increment (24hr market)
    candleNumber := candleNumber + 1
else
    candleNumber := 0

// Store the candle number for this bar
var int[] barCandleNumbers = array.new_int(0)
if barstate.isfirst
    array.clear(barCandleNumbers)

// Extend array if needed
while array.size(barCandleNumbers) <= bar_index
    array.push(barCandleNumbers, 0)

// Store current candle number
array.set(barCandleNumbers, bar_index, candleNumber)

// Retrieve the candle number for current bar
currentCandleNum = array.get(barCandleNumbers, bar_index)

// ════════════════════════════════════════════════════════════════════════════════
// VISUALIZATION
// ════════════════════════════════════════════════════════════════════════════════

// Ensure endCandle is >= startCandle
actualEnd = math.max(startCandle, endCandle)

// Check if current candle is in the range to mark
shouldMark = currentCandleNum >= startCandle and currentCandleNum <= actualEnd and currentCandleNum > 0

// Highlight the candle
bgcolor(shouldMark ? highlightColor : na, title="Candle Highlight")

// Draw label with candle number
if shouldMark and showLabels
    label.new(
         bar_index, 
         high, 
         str.tostring(currentCandleNum), 
         style=label.style_label_down,
         color=color.new(highlightColor, 0),
         textcolor=labelColor,
         size=size.small
     )

// ════════════════════════════════════════════════════════════════════════════════
// DEBUGGING INFO (Optional - can be displayed in status line)
// ════════════════════════════════════════════════════════════════════════════════

plot(currentCandleNum, "Current Candle #", display=display.data_window)
plot(sessionCounter, "Session Count", display=display.data_window)
plot(estHour, "EST Hour", display=display.data_window)
````
