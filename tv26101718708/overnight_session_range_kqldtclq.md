# Overnight Session Range

- url: https://www.tradingview.com/script/KQlDtcLQ-Overnight-Session-Range/
- type: indicator
- pine_id: PUB;5879281629534d86afe03dda8c2731e3
- version: 1.0

## Description

Highlights any range. In order to start select a time range then box will appear on a chart

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Overnight Session Range", overlay = true, max_boxes_count = 500)

// --- Inputs ---
string sessionInput   = input.session("0000-0655", "Session Time", tooltip = "Define the start and end of the overnight range (e.g., 0000-0655)")
string timezoneInput  = input.string("Europe/London", "Timezone", options = ["Europe/London", "America/New_York", "UTC"], tooltip = "Select the timezone for the session")
color  boxColorInput  = input.color(color.new(#5b9cf6, 85), "Box Fill", group = "Style")
color  borderColor    = input.color(#5b9cf6, "Border Color", group = "Style")
int    boxTransparency = input.int(85, "Transparency", minval = 0, maxval = 100, group = "Style")

// --- Logic ---
var float sessionHigh = na
var float sessionLow  = na
var box   sessionBox  = na

// Check if current bar is within the defined session
bool inSession = not na(time(timeframe.period, sessionInput, timezoneInput))
bool isNewSession = inSession and not inSession[1]

if isNewSession
    // Reset values for a new session
    sessionHigh := high
    sessionLow  := low
    // Create a new box starting at the current bar
    sessionBox := box.new(
         left          = bar_index, 
         top           = sessionHigh, 
         right         = bar_index, 
         bottom        = sessionLow, 
         border_color  = borderColor, 
         bgcolor       = color.new(boxColorInput, boxTransparency),
         border_style  = line.style_solid
         )
else if inSession
    // Update high/low during the session
    sessionHigh := math.max(high, sessionHigh)
    sessionLow  := math.min(low, sessionLow)
    
    // Update existing box coordinates
    if not na(sessionBox)
        box.set_top(sessionBox, sessionHigh)
        box.set_bottom(sessionBox, sessionLow)
        box.set_right(sessionBox, bar_index)

// --- Visuals ---
// Optional: Plot dots to visualize tracking (internal check)
plot(inSession ? sessionHigh : na, "Session High", color.new(borderColor, 50), 1, plot.style_circles)
plot(inSession ? sessionLow : na, "Session Low", color.new(borderColor, 50), 1, plot.style_circles)
````
